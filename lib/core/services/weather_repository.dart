import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import 'forecast_model_selector.dart';
import 'marine_weather_service.dart';
import 'weather_forecast_service.dart';

class WeatherRepository {
  static final WeatherRepository _i =
      WeatherRepository._(WeatherForecastService(), MarineWeatherService());
  factory WeatherRepository() => _i;
  WeatherRepository._(this._forecast, this._marine);

  /// Vlastná inštancia s podstrčenými službami — testy nesmú siahať na sieť
  /// ani sa navzájom ovplyvňovať cez keš singletonu.
  @visibleForTesting
  factory WeatherRepository.forTesting({
    required AppDatabase db,
    required WeatherForecastService forecast,
    required MarineWeatherService marine,
  }) =>
      WeatherRepository._(forecast, marine)..setDatabase(db);

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  final WeatherForecastService _forecast;
  final MarineWeatherService _marine;

  /// Stiahne predpoveď a až potom prepíše keš.
  ///
  /// Poradie je celý zmysel tejto metódy. Predtým sa keš mazala HNEĎ na
  /// začiatku, takže obnovenie bez signálu zmazalo poslednú uloženú predpoveď
  /// a nechalo prázdnu obrazovku — presný opak toho, čo sľubuje príručka aj
  /// pravidlo offline-first. Rovnaký vzor už drží `TideRepository.syncTides`.
  ///
  /// Berie **národný model podľa polohy** (viď [ForecastModelSelector]) a keď
  /// preň v danom mieste dáta nie sú, padá na automatický výber Open-Meteo.
  Future<void> syncWeather({required double lat, required double lon}) async {
    final db = _db;
    if (db == null) return;

    final regional = ForecastModelSelector.forPosition(lat, lon);
    Map<String, dynamic> forecast;
    ForecastModel? used = regional;
    try {
      forecast =
          await _forecast.fetchForecast(lat: lat, lon: lon, model: regional.id);
      if (!_hasHours(forecast)) throw const FormatException('no hourly data');
    } catch (e) {
      // Rozlišuje sa, PREČO to spadlo. Mimo pokrytia vracia Open-Meteo
      // odpoveď so `latitude: nan` a bez hodnôt — `nan` nie je platný JSON,
      // takže to skončí na parseri. To má zmysel skúsiť znova s automatickým
      // výberom.
      //
      // Výpadok siete nie: druhý dotaz by spadol rovnako a na kolísavom
      // spojení by sa každé sťahovanie zdvojilo.
      if (!_looksLikeMissingCoverage(e)) rethrow;
      debugPrint('[WEATHER] ${regional.id} has no data here ($e), '
          'falling back to best match');
      used = null;
      forecast = await _forecast.fetchForecast(lat: lat, lon: lon);
    }

    // Vnútrozemské miesta (napr. Zvolen) nemajú morské dáta vôbec —
    // marine-api na ne odpovie HTTP 400. To nie je dôvod zahodiť predpoveď
    // počasia, ktorú sme už stiahli, len vlny/teplotu vody vynechať.
    Map<String, dynamic>? marine;
    try {
      marine = await _marine.fetchMarine(lat: lat, lon: lon);
    } catch (e) {
      debugPrint('[WEATHER] no marine data here ($e)');
    }

    final fh = forecast['hourly'] as Map<String, dynamic>;
    final mh = marine?['hourly'] as Map<String, dynamic>?;
    final ft = (fh['time'] as List).cast<String>();
    final mt = (mh?['time'] as List?)?.cast<String>() ?? const <String>[];

    final now = DateTime.now();
    final rows = <WeatherSnapshotsCompanion>[];
    for (var i = 0; i < ft.length; i++) {
      final mi = mt.indexOf(ft[i]);
      rows.add(WeatherSnapshotsCompanion.insert(
        latitude: lat,
        longitude: lon,
        forecastTime: DateTime.parse(ft[i]),
        downloadedAt: now,
        windSpeed: (fh['wind_speed_10m'][i] as num).toDouble(),
        windDirection: (fh['wind_direction_10m'][i] as num).toDouble(),
        airPressure:
            drift.Value((fh['surface_pressure'][i] as num?)?.toDouble()),
        airTemp: drift.Value((fh['temperature_2m'][i] as num?)?.toDouble()),
        cloudCover: drift.Value((fh['cloud_cover'][i] as num?)?.toDouble()),
        weatherCode: drift.Value((fh['weather_code'][i] as num?)?.toInt()),
        waveHeight: mi >= 0
            ? drift.Value((mh!['wave_height'][mi] as num?)?.toDouble())
            : const drift.Value.absent(),
        wavePeriod: mi >= 0
            ? drift.Value((mh!['wave_period'][mi] as num?)?.toDouble())
            : const drift.Value.absent(),
        waterTemp: mi >= 0
            ? drift.Value(
                (mh!['sea_surface_temperature'][mi] as num?)?.toDouble())
            : const drift.Value.absent(),
        precipitationProbability:
            drift.Value((fh['precipitation_probability']?[i] as num?)?.toInt()),
        precipitation:
            drift.Value((fh['precipitation']?[i] as num?)?.toDouble()),
        modelName: drift.Value(used?.attribution),
      ));
    }

    if (rows.isEmpty) return;
    await db.replaceWeatherSnapshots(rows);
  }

  /// Vyzerá chyba na „tento model sem nevidí" a nie na výpadok siete?
  ///
  /// Dio zabalí výnimku z parsera do vlastnej, takže sa musí pozrieť aj
  /// dovnútra. Okrem `nan` odpovede (rieši parser -> FormatException)
  /// Open-Meteo vie na nepokrytú polohu odpovedať aj rovno HTTP 400 s
  /// `{"reason":"No data is available for this location"}` — overené na
  /// ICON-D2 pre Zvolen, ktorý je v hrubom obdĺžniku modelu, ale mimo jeho
  /// reálneho pokrytia (Nemecko a okolie).
  static bool _looksLikeMissingCoverage(Object e) {
    if (e is FormatException) return true;
    if (e is DioException) {
      if (e.error is FormatException || e.type == DioExceptionType.unknown) {
        return true;
      }
      final data = e.response?.data;
      final reason = data is Map ? data['reason'] : null;
      return e.response?.statusCode == 400 &&
          reason is String &&
          reason.toLowerCase().contains('no data');
    }
    return false;
  }

  static bool _hasHours(Map<String, dynamic> forecast) {
    final hourly = forecast['hourly'];
    if (hourly is! Map) return false;
    final times = hourly['time'];
    return times is List && times.isNotEmpty;
  }

  Future<WeatherSnapshot?> getNearestWeather(DateTime time) async {
    final db = _db;
    if (db == null) return null;
    final all = await db.getWeatherSnapshots();
    if (all.isEmpty) return null;
    all.sort((a, b) => a.forecastTime
        .difference(time)
        .abs()
        .compareTo(b.forecastTime.difference(time).abs()));
    return all.first;
  }
}
