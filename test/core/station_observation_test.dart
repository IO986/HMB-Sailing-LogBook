import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/station_observation.dart';

StationObservation _obs({
  required String station,
  required ObservationSource source,
  double lat = 44.10,
  double lon = 15.20,
  double? wind = 10,
  double? gust,
  Duration age = Duration.zero,
  DateTime? now,
}) =>
    StationObservation(
      station: station,
      latitude: lat,
      longitude: lon,
      observedAt: (now ?? DateTime.utc(2026, 8, 24, 12)).subtract(age),
      source: source,
      windSpeedKnots: wind,
      gustKnots: gust,
    );

void main() {
  final now = DateTime.utc(2026, 8, 24, 12);
  const maxAge = Duration(hours: 3);

  test('zastarané meranie sa zahodí z oboch zdrojov', () {
    // Feed sa môže ticho zastaviť a vracať staré dáta, ktoré vyzerajú platne.
    final out = mergeObservations(
      primary: [
        _obs(
            station: 'Zadar',
            source: ObservationSource.dhmz,
            age: const Duration(hours: 5)),
      ],
      secondary: [
        _obs(
            station: 'Zadar Arpt',
            source: ObservationSource.metar,
            lat: 46,
            lon: 16,
            age: const Duration(hours: 4)),
      ],
      maxAge: maxAge,
      now: now,
    );

    expect(out, isEmpty);
  });

  test('vzdialené stanice ostávajú obe', () {
    final out = mergeObservations(
      primary: [_obs(station: 'Zadar', source: ObservationSource.dhmz)],
      secondary: [
        _obs(
            station: 'Split Arpt',
            source: ObservationSource.metar,
            lat: 43.54,
            lon: 16.30),
      ],
      maxAge: maxAge,
      now: now,
    );

    expect(out.map((o) => o.station), ['Zadar', 'Split Arpt']);
  });

  test('pri zhode do piatich kilometrov vyhráva DHMZ', () {
    // Letisko a pobrežná stanica pár kilometrov od seba sú pre skipera to isté
    // miesto; DHMZ nesie tendenciu tlaku aj teplotu mora, ktoré METAR nemá.
    final out = mergeObservations(
      primary: [
        _obs(station: 'Zadar', source: ObservationSource.dhmz, wind: 6),
      ],
      secondary: [
        _obs(
            station: 'Zadar Arpt',
            source: ObservationSource.metar,
            lat: 44.11,
            lon: 15.21,
            wind: 9),
      ],
      maxAge: maxAge,
      now: now,
    );

    expect(out, hasLength(1));
    expect(out.single.source, ObservationSource.dhmz);
    expect(out.single.windSpeedKnots, 6);
  });

  test('náraz z prekrytého METARu sa nestratí', () {
    // DHMZ nárazy nehlási vôbec. Zahodiť prekrytú stanicu aj s nárazom by
    // znamenalo stratiť údaj, ktorý nikto iný nedá.
    final out = mergeObservations(
      primary: [
        _obs(station: 'Zadar', source: ObservationSource.dhmz, wind: 6),
      ],
      secondary: [
        _obs(
            station: 'Zadar Arpt',
            source: ObservationSource.metar,
            lat: 44.11,
            lon: 15.21,
            wind: 9,
            gust: 22),
      ],
      maxAge: maxAge,
      now: now,
    );

    expect(out.single.source, ObservationSource.dhmz);
    expect(out.single.windSpeedKnots, 6, reason: 'meranie DHMZ ostáva');
    expect(out.single.gustKnots, 22, reason: 'náraz prežije z METARu');
  });

  test('zastaraná stanica DHMZ neprekryje čerstvý METAR', () {
    final out = mergeObservations(
      primary: [
        _obs(
            station: 'Zadar',
            source: ObservationSource.dhmz,
            age: const Duration(hours: 6)),
      ],
      secondary: [
        _obs(
            station: 'Zadar Arpt',
            source: ObservationSource.metar,
            lat: 44.11,
            lon: 15.21),
      ],
      maxAge: maxAge,
      now: now,
    );

    expect(out.map((o) => o.source), [ObservationSource.metar]);
  });
}
