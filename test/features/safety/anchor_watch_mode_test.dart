import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/utils/geo_polygon.dart';
import 'package:hmb_sailing_log/features/safety/presentation/screens/safety_screen.dart';
import 'package:latlong2/latlong.dart';

/// The one decision that wakes the crew at three in the morning.
///
/// `_listen` hangs off the `LocationService` singleton and `restore()` calls
/// into platform channels, so neither is driven here. The decision itself is
/// a pure function and that is what these tests hold down.
void main() {
  const anchor = LatLng(43.7430, 15.7530);

  /// A bay open to the south-east: the boat may swing along the shore but
  /// not across it. Roughly 400 m across.
  const bay = [
    LatLng(43.7400, 15.7500),
    LatLng(43.7400, 15.7560),
    LatLng(43.7440, 15.7560),
    LatLng(43.7440, 15.7540),
    LatLng(43.7460, 15.7540),
    LatLng(43.7460, 15.7500),
  ];

  group('circle mode', () {
    test('inside the radius is not drifting, outside is', () {
      // ~22 m north of the anchor.
      const near = LatLng(43.7432, 15.7530);
      // ~110 m north of the anchor.
      const far = LatLng(43.7440, 15.7530);
      expect(
          anchorIsDrifting(
              fix: near, anchor: anchor, radiusM: 50, zone: const []),
          isFalse);
      expect(
          anchorIsDrifting(
              fix: far, anchor: anchor, radiusM: 50, zone: const []),
          isTrue);
    });

    test('exactly on the radius is not yet drifting', () {
      // The circle has always used a bare `>`; a boat sitting exactly on the
      // line is inside. Keep it that way — this is the parity the zone mode
      // was required to preserve.
      final onEdge = _northOf(anchor, 50);
      expect(anchorDistanceM(anchor, onEdge), closeTo(50, 0.5));
      expect(
          anchorIsDrifting(
              fix: onEdge, anchor: anchor, radiusM: 50.6, zone: const []),
          isFalse);
    });
  });

  group('zone mode', () {
    test('inside the bay is not drifting, outside it is', () {
      expect(
          anchorIsDrifting(
              fix: const LatLng(43.7420, 15.7530),
              anchor: anchor,
              radiusM: 50,
              zone: bay),
          isFalse);
      expect(
          anchorIsDrifting(
              fix: const LatLng(43.7450, 15.7555),
              anchor: anchor,
              radiusM: 50,
              zone: bay),
          isTrue,
          reason: 'the notch in the bay is outside, however close it looks');
    });

    test('the two modes really are different answers', () {
      // 150 m north of the anchor: outside a 50 m circle, but still inside
      // the bay. This is the whole point of the feature.
      final fix = _northOf(anchor, 150);
      expect(
          anchorIsDrifting(
              fix: fix, anchor: anchor, radiusM: 50, zone: const []),
          isTrue);
      expect(
          anchorIsDrifting(fix: fix, anchor: anchor, radiusM: 50, zone: bay),
          isFalse);
    });
  });

  group('a broken ring falls back to the circle, never to a standing alarm', () {
    test('two tapped corners are not a zone', () {
      // GeoPolygon.contains returns false for every position on such a ring,
      // so treating it as a zone would ring the alarm all night.
      const half = [LatLng(43.7400, 15.7500), LatLng(43.7400, 15.7560)];
      expect(
          anchorIsDrifting(
              fix: const LatLng(43.7432, 15.7530),
              anchor: anchor,
              radiusM: 50,
              zone: half),
          isFalse);
    });

    test('an empty ring is the plain circle', () {
      final far = _northOf(anchor, 200);
      expect(
          anchorIsDrifting(
              fix: far, anchor: anchor, radiusM: 50, zone: const []),
          isTrue);
    });
  });

  group('what survives being killed by the system', () {
    test('a zone round-trips through storage', () {
      final back = GeoPolygon.decode(GeoPolygon.encode(bay));
      expect(back.length, bay.length);
      // The restored ring must decide identically, or the watch would change
      // its mind about the same boat after a restart.
      const fix = LatLng(43.7450, 15.7555);
      expect(anchorIsDrifting(fix: fix, anchor: anchor, radiusM: 50, zone: back),
          anchorIsDrifting(fix: fix, anchor: anchor, radiusM: 50, zone: bay));
    });

    test('unreadable storage degrades to the circle, not to an alarm', () {
      final restored = GeoPolygon.decode('half a json {');
      expect(restored, isEmpty);
      expect(
          anchorIsDrifting(
              fix: const LatLng(43.7432, 15.7530),
              anchor: anchor,
              radiusM: 50,
              zone: restored),
          isFalse);
    });
  });
}

/// A position [metres] due north of [from].
LatLng _northOf(LatLng from, double metres) {
  const mPerDegLat = 6371000 * 3.141592653589793 / 180;
  return LatLng(from.latitude + metres / mPerDegLat, from.longitude);
}
