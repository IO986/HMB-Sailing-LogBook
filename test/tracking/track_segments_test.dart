import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/utils/track_segments.dart';

void main() {
  final t0 = DateTime.utc(2026, 10, 7, 7);
  var id = 0;

  // ~0,0009° zemepisnej šírky ≈ 100 m.
  TrackPoint pt(String session, int seconds, double northM) => TrackPoint(
        id: id++,
        sessionId: session,
        timestamp: t0.add(Duration(seconds: seconds)),
        latitude: 43.5 + northM / 111320,
        longitude: 16.0,
      );

  test('súvislá trasa ostane jedným úsekom', () {
    final s = TrackSegments.of([
      for (var i = 0; i < 10; i++) pt('a', i * 10, i * 30.0),
    ]);
    expect(s.segments, hasLength(1));
    expect(s.gaps, isEmpty);
  });

  test('dlhá pauza s veľkým posunom je diera', () {
    final s = TrackSegments.of([
      pt('a', 0, 0),
      pt('a', 10, 30),
      pt('a', 45 * 60, 4000), // 45 min, 4 km
      pt('a', 45 * 60 + 10, 4030),
    ]);
    expect(s.segments, hasLength(2));
    expect(s.gaps.single.duration, const Duration(minutes: 44, seconds: 50));
    expect(s.gapLines.single, hasLength(2));
    expect(s.solidLines, hasLength(2));
  });

  test('stojaca loď nie je diera, hoci body dlho nechodia', () {
    final s = TrackSegments.of([
      pt('a', 0, 0),
      pt('a', 60 * 60, 50), // hodina na bóji, posun 50 m
    ]);
    expect(s.gaps, isEmpty);
  });

  test('dve session sa nespájajú ani prerušovanou čiarou', () {
    final s = TrackSegments.of([
      pt('a', 0, 0),
      pt('a', 10, 30),
      pt('b', 3600, 9000),
      pt('b', 3610, 9030),
    ]);
    expect(s.segments, hasLength(2));
    expect(s.gaps, isEmpty);
  });
}
