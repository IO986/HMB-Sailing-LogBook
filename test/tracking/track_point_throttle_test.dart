import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/utils/track_point_throttle.dart';
import 'package:latlong2/latlong.dart';

/// Bod posunutý o [metres] na sever od [from]. 1' zemepisnej šírky = 1852 m.
LatLng _north(LatLng from, double metres) =>
    LatLng(from.latitude + metres / 111320.0, from.longitude);

void main() {
  final t0 = DateTime.utc(2026, 8, 21, 10);
  const start = LatLng(43.5, 16.4);

  group('TrackPointThrottle', () {
    test('the first point of a voyage is always recorded', () {
      expect(TrackPointThrottle().accept(start, now: t0), isTrue);
    });

    test('fixes arriving faster than the interval are dropped', () {
      final throttle = TrackPointThrottle();
      throttle.accept(start, now: t0);

      // Ďaleko dosť, ale príliš skoro.
      final soon = t0.add(const Duration(seconds: 2));
      expect(throttle.accept(_north(start, 100), now: soon), isFalse);
    });

    test('a boat crawling slower than the threshold is not silenced forever',
        () {
      // Regresia: keď sa vzdialenosť merala od predošlého FIXU a nie od
      // posledného zapísaného bodu, loď idúca 6 m za fix nezapísala po prvom
      // bode už nikdy nič.
      final throttle = TrackPointThrottle();
      var now = t0;
      var point = start;
      expect(throttle.accept(point, now: now), isTrue);

      var recorded = 0;
      for (var i = 0; i < 30; i++) {
        now = now.add(const Duration(seconds: 2));
        point = _north(point, 6);
        if (throttle.accept(point, now: now)) recorded++;
      }
      expect(recorded, greaterThan(0));
    });

    test('sitting at anchor records nothing beyond the first point', () {
      final throttle = TrackPointThrottle();
      var now = t0;
      expect(throttle.accept(start, now: now), isTrue);

      var recorded = 0;
      for (var i = 0; i < 100; i++) {
        now = now.add(const Duration(seconds: 10));
        // GPS šum okolo kotvy, rádovo jednotky metrov.
        if (throttle.accept(_north(start, i.isEven ? 3 : -3), now: now)) {
          recorded++;
        }
      }
      expect(recorded, 0);
    });

    test('a real leg records roughly one point per interval, not per fix', () {
      // 6 uzlov = ~3,09 m/s, fix každé 2 s → ~6,2 m na fix.
      final throttle = TrackPointThrottle();
      var now = t0;
      var point = start;
      throttle.accept(point, now: now);

      var fixes = 0;
      var recorded = 0;
      for (var i = 0; i < 1800; i++) {
        now = now.add(const Duration(seconds: 2));
        point = _north(point, 6.2);
        fixes++;
        if (throttle.accept(point, now: now)) recorded++;
      }

      expect(fixes, 1800);
      // Prah je 5 s aj 10 m; pri 6,2 m/fix rozhoduje vzdialenosť, takže
      // vychádza bod na každý druhý fix — teda rádovo polovica, nie všetko.
      expect(recorded, lessThan(fixes ~/ 2 + 1));
      expect(recorded, greaterThan(fixes ~/ 4));
    });

    test('reset makes the next point count as a first point again', () {
      final throttle = TrackPointThrottle();
      throttle.accept(start, now: t0);
      throttle.reset();

      expect(throttle.lastRecordedPoint, isNull);
      expect(throttle.accept(_north(start, 1), now: t0), isTrue);
    });

    test('thresholds are configurable', () {
      final throttle = TrackPointThrottle(
        minInterval: const Duration(seconds: 30),
        minDistanceM: 100,
      );
      throttle.accept(start, now: t0);

      final later = t0.add(const Duration(seconds: 31));
      expect(throttle.accept(_north(start, 50), now: later), isFalse);
      expect(throttle.accept(_north(start, 150), now: later), isTrue);
    });
  });
}
