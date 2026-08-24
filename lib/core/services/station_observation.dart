import '../database/app_database.dart';
import '../utils/distance_calculator.dart';

/// Odkiaľ meranie pochádza.
///
/// Nie je to kozmetika: každý zdroj má iné pokrytie a iné silné miesta, a keď
/// sa dve merania z rôznych zdrojov nezhodujú, používateľ má vedieť, ktoré je
/// ktoré.
enum ObservationSource {
  /// Chorvátsky hydrometeorologický zavod — pobrežné a ostrovné stanice,
  /// tendencia tlaku, teplota mora. Len Chorvátsko.
  dhmz('DHMZ'),

  /// Letiskové správy METAR (NOAA Aviation Weather). Celosvetové pokrytie
  /// a jediný z dvoch zdrojov, ktorý hlási nárazy.
  metar('METAR');

  const ObservationSource(this.label);

  final String label;
}

/// Jedno meranie z jednej stanice, nech už prišlo odkiaľkoľvek.
///
/// Existuje preto, aby mapa nemusela poznať zdroje: kreslí zoznam meraní,
/// nie zoznam DHMZ staníc. Pridanie ďalšieho zdroja je potom otázka jednej
/// služby, nie zásahu do obrazovky.
class StationObservation {
  const StationObservation({
    required this.station,
    required this.latitude,
    required this.longitude,
    required this.observedAt,
    required this.source,
    this.code,
    this.windSpeedKnots,
    this.windDirectionDeg,
    this.gustKnots,
    this.airTemp,
    this.airPressure,
    this.pressureTendency,
    this.waterTemp,
  });

  /// Meno stanice tak, ako ho hlási zdroj.
  final String station;

  /// Kód stanice, keď ho má (METAR má ICAO, DHMZ nie).
  final String? code;

  final double latitude;
  final double longitude;

  /// Čas merania v UTC.
  final DateTime observedAt;

  final ObservationSource source;

  final double? windSpeedKnots;

  /// Meteorologický smer — ODKIAĽ fúka. `null` znamená bezvetrie alebo
  /// premenlivý smer, nie nulu.
  final double? windDirectionDeg;

  /// Náraz v uzloch. Hlási ho len METAR, a aj ten len keď nejaký je.
  final double? gustKnots;

  final double? airTemp;
  final double? airPressure;

  /// Zmena tlaku za 3 h. Dáva ju len DHMZ; model túto hodnotu nepozná vôbec.
  final double? pressureTendency;

  final double? waterTemp;

  /// Prevod uloženého merania DHMZ na spoločný tvar.
  factory StationObservation.fromDhmz(DhmzObservation o) => StationObservation(
        station: o.station,
        latitude: o.latitude,
        longitude: o.longitude,
        observedAt: o.observedAt.toUtc(),
        source: ObservationSource.dhmz,
        windSpeedKnots: o.windSpeedKnots,
        windDirectionDeg: o.windDirectionDeg,
        airTemp: o.airTemp,
        airPressure: o.airPressure,
        pressureTendency: o.pressureTendency,
        waterTemp: o.waterTemp,
      );
}

/// Zlúči merania z viacerých zdrojov do jedného zoznamu.
///
/// Dve pravidlá, obe vecné:
///
/// 1. **Zastarané preč.** Feed sa môže ticho zastaviť — predpovednému feedu
///    DHMZ sa to stalo a mesiace vracal syntakticky platné, dva mesiace staré
///    dáta. Meranie bez čerstvosti nie je meranie.
/// 2. **Pri zhode vyhráva DHMZ.** Letisko a pobrežná stanica pár kilometrov
///    od seba sú pre skipera to isté miesto, ale DHMZ nesie tendenciu tlaku aj
///    teplotu mora, ktoré METAR nemá. Cenou je chýbajúci náraz — ten sa preto
///    z prekrytého METARu prenesie.
List<StationObservation> mergeObservations({
  required List<StationObservation> primary,
  required List<StationObservation> secondary,
  required Duration maxAge,
  DateTime? now,
  double dedupeRadiusM = 5000,
}) {
  final at = (now ?? DateTime.now()).toUtc();
  bool fresh(StationObservation o) =>
      at.difference(o.observedAt.toUtc()).abs() <= maxAge;

  final out = [for (final o in primary) if (fresh(o)) o];

  for (final candidate in secondary) {
    if (!fresh(candidate)) continue;
    final overlapIndex = out.indexWhere((kept) =>
        DistanceCalculator.distanceM(kept.latitude, kept.longitude,
            candidate.latitude, candidate.longitude) <
        dedupeRadiusM);
    if (overlapIndex < 0) {
      out.add(candidate);
      continue;
    }
    final kept = out[overlapIndex];
    // Prekrytá stanica sa zahodí, ale náraz z nej je jediný, ktorý je —
    // zahodiť ho by znamenalo stratiť údaj, ktorý nikto iný nedá.
    if (kept.gustKnots == null && candidate.gustKnots != null) {
      out[overlapIndex] = StationObservation(
        station: kept.station,
        code: kept.code,
        latitude: kept.latitude,
        longitude: kept.longitude,
        observedAt: kept.observedAt,
        source: kept.source,
        windSpeedKnots: kept.windSpeedKnots,
        windDirectionDeg: kept.windDirectionDeg,
        gustKnots: candidate.gustKnots,
        airTemp: kept.airTemp,
        airPressure: kept.airPressure,
        pressureTendency: kept.pressureTendency,
        waterTemp: kept.waterTemp,
      );
    }
  }
  return out;
}
