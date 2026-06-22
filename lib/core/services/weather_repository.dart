import 'package:drift/drift.dart' as drift;
import 'weather_forecast_service.dart';
import 'marine_weather_service.dart';
import '../database/app_database.dart';

class WeatherRepository {
  static final WeatherRepository _i = WeatherRepository._();
  factory WeatherRepository() => _i;
  WeatherRepository._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  final _forecast = WeatherForecastService();
  final _marine = MarineWeatherService();

  Future<void> syncWeather({required double lat, required double lon}) async {
    final db = _db;
    if (db == null) return;
    await db.clearOldWeather();

    final forecast = await _forecast.fetchForecast(lat: lat, lon: lon);
    final marine = await _marine.fetchMarine(lat: lat, lon: lon);

    final fh = forecast['hourly'] as Map<String, dynamic>;
    final mh = marine['hourly'] as Map<String, dynamic>;
    final ft = (fh['time'] as List).cast<String>();
    final mt = (mh['time'] as List).cast<String>();

    for (int i = 0; i < ft.length; i++) {
      final mi = mt.indexOf(ft[i]);
      await db.insertWeatherSnapshot(WeatherSnapshotsCompanion.insert(
        latitude: lat, longitude: lon,
        forecastTime: DateTime.parse(ft[i]),
        downloadedAt: DateTime.now(),
        windSpeed: (fh['wind_speed_10m'][i] as num).toDouble(),
        windDirection: (fh['wind_direction_10m'][i] as num).toDouble(),
        airPressure: drift.Value((fh['surface_pressure'][i] as num?)?.toDouble()),
        airTemp: drift.Value((fh['temperature_2m'][i] as num?)?.toDouble()),
        cloudCover: drift.Value((fh['cloud_cover'][i] as num?)?.toDouble()),
        waveHeight: mi >= 0 ? drift.Value((mh['wave_height'][mi] as num?)?.toDouble()) : const drift.Value.absent(),
        wavePeriod: mi >= 0 ? drift.Value((mh['wave_period'][mi] as num?)?.toDouble()) : const drift.Value.absent(),
        waterTemp: mi >= 0 ? drift.Value((mh['sea_surface_temperature'][mi] as num?)?.toDouble()) : const drift.Value.absent(),
      ));
    }
  }

  Future<WeatherSnapshot?> getNearestWeather(DateTime time) async {
    final db = _db;
    if (db == null) return null;
    final all = await db.getWeatherSnapshots();
    if (all.isEmpty) return null;
    all.sort((a, b) => a.forecastTime.difference(time).abs()
        .compareTo(b.forecastTime.difference(time).abs()));
    return all.first;
  }
}
