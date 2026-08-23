import '../database/app_database.dart';
import 'dhmz_observation_service.dart';
import 'weather_repository.dart';

/// Odkiaľ pochádzajú hodnoty počasia v zázname denníka.
///
/// Poradie je poradím dôveryhodnosti: prístroje na lodi merajú tam, kde loď
/// je; stanica meria naozaj, ale inde; model nemeria vôbec.
enum WeatherSource {
  /// Lodné prístroje cez NMEA.
  nmea,

  /// Pozemná stanica DHMZ.
  dhmz,

  /// Predpovedný model (Open-Meteo).
  model;

  String get code => name;
}

/// Podmienky zapísané do jedného záznamu denníka, aj s ich pôvodom.
class EntryConditions {
  const EntryConditions({
    required this.source,
    this.windSpeed,
    this.windDirection,
    this.airTemp,
    this.airPressure,
    this.pressureTendency,
    this.waterTemp,
    this.waveHeight,
    this.station,
    this.stationDistanceM,
  });

  final WeatherSource source;
  final double? windSpeed;
  final double? windDirection;
  final double? airTemp;
  final double? airPressure;
  final double? pressureTendency;
  final double? waterTemp;

  /// Vlny vždy z modelu — nemeria ich ani lodný prístroj, ani pozemná stanica.
  final double? waveHeight;

  final String? station;
  final double? stationDistanceM;
}

/// Zostaví podmienky pre záznam denníka z najlepšieho dostupného zdroja.
///
/// Jedno miesto pre automatický aj ručný zápis. Predtým si ich ručný záznam
/// (`logbook_entry_screen`) skladal sám a bral rovno model, takže sa oba
/// spôsoby zápisu už rozišli raz — druhýkrát to nemá ako.
///
/// Nikdy nevyhadzuje výnimku a nikdy nečaká na sieť: keď nie je nič, vráti
/// prázdne podmienky s modelovým zdrojom (pravidlo 4 — offline-first).
class EntryConditionsBuilder {
  EntryConditionsBuilder({
    WeatherRepository? weather,
    DhmzObservationService? dhmz,
  })  : _weather = weather ?? WeatherRepository(),
        _dhmz = dhmz ?? DhmzObservationService();

  final WeatherRepository _weather;
  final DhmzObservationService _dhmz;

  /// [instrumentWind] a [instrumentWaterTemp] podáva volajúci z NMEA, ak sú
  /// čerstvé — táto trieda o lodných prístrojoch nič nevie a vedieť nemá.
  Future<EntryConditions> build({
    required double latitude,
    required double longitude,
    DateTime? at,
    ({double? speedKnots, double? directionDeg})? instrumentWind,
    double? instrumentWaterTemp,
  }) async {
    final now = at ?? DateTime.now();

    final WeatherSnapshot? model =
        await _weather.getNearestWeather(now).catchError((_) => null);

    DhmzNearestObservation? station;
    try {
      station = await _dhmz.nearest(
        latitude: latitude,
        longitude: longitude,
        now: now,
      );
    } catch (_) {
      station = null;
    }

    final obs = station?.observation;
    final hasInstrumentWind = instrumentWind?.speedKnots != null;

    // Zdroj sa určuje podľa toho, odkiaľ prišiel VIETOR — je to hodnota, na
    // ktorej pri plavbe najviac záleží a ktorá sa medzi zdrojmi líši najviac.
    final source = hasInstrumentWind
        ? WeatherSource.nmea
        : (obs?.windSpeedKnots != null ? WeatherSource.dhmz : WeatherSource.model);

    return EntryConditions(
      source: source,
      windSpeed: instrumentWind?.speedKnots ??
          obs?.windSpeedKnots ??
          model?.windSpeed,
      windDirection: hasInstrumentWind
          ? instrumentWind?.directionDeg
          : (obs?.windSpeedKnots != null
              ? obs?.windDirectionDeg
              : model?.windDirection),
      airTemp: obs?.airTemp ?? model?.airTemp,
      airPressure: obs?.airPressure ?? model?.airPressure,
      pressureTendency: obs?.pressureTendency,
      waterTemp: instrumentWaterTemp ?? obs?.waterTemp ?? model?.waterTemp,
      waveHeight: model?.waveHeight,
      station: source == WeatherSource.dhmz ? obs?.station : null,
      stationDistanceM:
          source == WeatherSource.dhmz ? station?.distanceM : null,
    );
  }
}
