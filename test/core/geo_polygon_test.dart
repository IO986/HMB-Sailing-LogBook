import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/utils/geo_polygon.dart';
import 'package:latlong2/latlong.dart';

/// The anchor watch decides whether to wake the crew from these answers, so
/// the interesting cases are the ones where a naive implementation is
/// confidently wrong: a concave bay, the antimeridian, and high latitudes.
void main() {
  /// A square of roughly [sideM] metres with its south-west corner at
  /// [lat]/[lon]. Built from metres so the same shape can be placed anywhere
  /// on the globe and compared.
  List<LatLng> square(double lat, double lon, double sideM) {
    final dLat = sideM / _mPerDegLat;
    final dLon = sideM / (_mPerDegLat * math.cos(lat * math.pi / 180));
    return [
      LatLng(lat, lon),
      LatLng(lat, lon + dLon),
      LatLng(lat + dLat, lon + dLon),
      LatLng(lat + dLat, lon),
    ];
  }

  group('contains', () {
    final quad = [
      const LatLng(43.740, 15.750),
      const LatLng(43.740, 15.756),
      const LatLng(43.746, 15.756),
      const LatLng(43.746, 15.750),
    ];

    test('a point in the middle is inside', () {
      expect(GeoPolygon.contains(quad, const LatLng(43.743, 15.753)), isTrue);
    });

    test('a point well outside is outside', () {
      expect(GeoPolygon.contains(quad, const LatLng(43.760, 15.753)), isFalse);
    });

    test('a notch in an L-shaped bay is outside, not merely off-centre', () {
      // The whole reason a polygon replaces a circle: this point sits inside
      // the bounding box and close to the "centre", and a radius test would
      // happily call it inside.
      final bay = [
        const LatLng(43.740, 15.750),
        const LatLng(43.740, 15.760),
        const LatLng(43.744, 15.760),
        const LatLng(43.744, 15.754),
        const LatLng(43.748, 15.754),
        const LatLng(43.748, 15.750),
      ];
      expect(GeoPolygon.contains(bay, const LatLng(43.746, 15.758)), isFalse);
      expect(GeoPolygon.contains(bay, const LatLng(43.742, 15.758)), isTrue);
    });

    test('a ray through a vertex is not counted twice', () {
      // Due west of the top-left corner, at exactly its latitude.
      expect(GeoPolygon.contains(quad, const LatLng(43.746, 15.740)), isFalse);
      // Due west of the bottom-left corner, at exactly its latitude.
      expect(GeoPolygon.contains(quad, const LatLng(43.740, 15.740)), isFalse);
    });

    test('winding order does not matter', () {
      final reversed = quad.reversed.toList();
      const p = LatLng(43.743, 15.753);
      expect(GeoPolygon.contains(reversed, p), GeoPolygon.contains(quad, p));
      // Not exact: the projection origin is the ring's first point, which
      // differs between the two orderings. Centimetres, against a watch that
      // triggers on metres.
      expect(GeoPolygon.distanceToEdgeM(reversed, p),
          closeTo(GeoPolygon.distanceToEdgeM(quad, p), 0.1));
    });

    test('fewer than three points is never inside', () {
      expect(GeoPolygon.contains(const [], const LatLng(43.74, 15.75)), isFalse);
      expect(GeoPolygon.contains(quad.take(2).toList(), quad.first), isFalse);
    });
  });

  group('distance to the edge', () {
    test('a point 30 m from an edge measures 30 m', () {
      final ring = square(43.74, 15.75, 200);
      // 30 m north of the southern edge, halfway along it.
      final p = LatLng(ring.first.latitude + 30 / _mPerDegLat,
          (ring[0].longitude + ring[1].longitude) / 2);
      expect(GeoPolygon.distanceToEdgeM(ring, p), closeTo(30, 1));
    });

    test('the nearest edge is a corner, not an extended line', () {
      final ring = square(43.74, 15.75, 200);
      // Diagonally off the south-west corner: 30 m south and 30 m west.
      final p = LatLng(
          ring.first.latitude - 30 / _mPerDegLat,
          ring.first.longitude -
              30 / (_mPerDegLat * math.cos(43.74 * math.pi / 180)));
      // The perpendicular to either extended edge would say 30 m.
      expect(GeoPolygon.distanceToEdgeM(ring, p), closeTo(42.4, 1.5));
    });

    test('a repeated corner does not produce NaN', () {
      final ring = [
        const LatLng(43.740, 15.750),
        const LatLng(43.740, 15.750), // tapped twice
        const LatLng(43.740, 15.756),
        const LatLng(43.746, 15.756),
      ];
      final d = GeoPolygon.distanceToEdgeM(ring, const LatLng(43.742, 15.752));
      expect(d.isNaN, isFalse);
      expect(d, greaterThan(0));
    });

    test('signedClearanceM changes sign across an edge', () {
      final ring = square(43.74, 15.75, 200);
      final lonMid = (ring[0].longitude + ring[1].longitude) / 2;
      final inside = LatLng(ring.first.latitude + 20 / _mPerDegLat, lonMid);
      final outside = LatLng(ring.first.latitude - 20 / _mPerDegLat, lonMid);
      expect(GeoPolygon.signedClearanceM(ring, inside), greaterThan(0));
      expect(GeoPolygon.signedClearanceM(ring, outside), lessThan(0));
    });
  });

  group('the earth is not flat and not a cylinder', () {
    test('the same shape gives the same clearance at 70°N as at 43°N', () {
      final adriatic = square(43.74, 15.75, 200);
      final tromso = square(69.65, 18.96, 200);
      expect(GeoPolygon.distanceToEdgeM(adriatic, GeoPolygon.centroid(adriatic)),
          closeTo(100, 2));
      expect(GeoPolygon.distanceToEdgeM(tromso, GeoPolygon.centroid(tromso)),
          closeTo(100, 2));
    });

    test('a ring straddling the antimeridian still works', () {
      final ring = [
        const LatLng(-16.50, 179.98),
        const LatLng(-16.50, -179.98),
        const LatLng(-16.46, -179.98),
        const LatLng(-16.46, 179.98),
      ];
      expect(GeoPolygon.contains(ring, const LatLng(-16.48, 180.0)), isTrue);
      expect(GeoPolygon.contains(ring, const LatLng(-16.48, 179.90)), isFalse);
      final area = GeoPolygon.areaM2(ring);
      expect(area, greaterThan(0));
      // Roughly 4.3 km x 4.4 km — not a band around the planet.
      expect(area, lessThan(50e6));
    });
  });

  group('isUsable', () {
    test('a ring needs three distinct corners', () {
      expect(GeoPolygon.isUsable(const []), isFalse);
      expect(GeoPolygon.isUsable([const LatLng(43.74, 15.75)]), isFalse);
      expect(
          GeoPolygon.isUsable(
              [const LatLng(43.74, 15.75), const LatLng(43.75, 15.76)]),
          isFalse);
      expect(
          GeoPolygon.isUsable(List.filled(3, const LatLng(43.74, 15.75))),
          isFalse,
          reason: 'three identical taps enclose nothing');
    });

    test('an area below GPS noise is not worth guarding', () {
      expect(GeoPolygon.isUsable(square(43.74, 15.75, 3)), isFalse);
      expect(GeoPolygon.isUsable(square(43.74, 15.75, 40)), isTrue);
    });
  });

  group('hasSelfIntersection', () {
    test('a bow tie is caught', () {
      final bowTie = [
        const LatLng(43.740, 15.750),
        const LatLng(43.746, 15.756),
        const LatLng(43.740, 15.756),
        const LatLng(43.746, 15.750),
      ];
      expect(GeoPolygon.hasSelfIntersection(bowTie), isTrue);
    });

    test('convex and concave rings are fine', () {
      expect(GeoPolygon.hasSelfIntersection(square(43.74, 15.75, 200)), isFalse);
      final bay = [
        const LatLng(43.740, 15.750),
        const LatLng(43.740, 15.760),
        const LatLng(43.744, 15.760),
        const LatLng(43.744, 15.754),
        const LatLng(43.748, 15.754),
        const LatLng(43.748, 15.750),
      ];
      expect(GeoPolygon.hasSelfIntersection(bay), isFalse);
    });

    test('a triangle can never cross itself', () {
      expect(
          GeoPolygon.hasSelfIntersection([
            const LatLng(43.740, 15.750),
            const LatLng(43.740, 15.756),
            const LatLng(43.746, 15.753),
          ]),
          isFalse);
    });
  });

  group('encode / decode', () {
    test('a ring survives the round trip', () {
      final ring = square(43.74, 15.75, 200);
      final back = GeoPolygon.decode(GeoPolygon.encode(ring));
      expect(back.length, ring.length);
      for (var i = 0; i < ring.length; i++) {
        expect(back[i].latitude, closeTo(ring[i].latitude, 1e-9));
        expect(back[i].longitude, closeTo(ring[i].longitude, 1e-9));
      }
    });

    test('garbage never throws — it degrades to the circle', () {
      // This runs while restoring the watch after the system killed the app.
      // An exception here would kill the restore silently and the skipper
      // would sleep believing his anchor was being watched.
      for (final bad in [
        null,
        '',
        '[]',
        '[[1]]',
        '[["a","b"]]',
        '[[91.0, 0.0]]',
        '{"lat":1}',
        'not json at all',
      ]) {
        expect(GeoPolygon.decode(bad), isEmpty, reason: 'input: $bad');
      }
    });
  });
}

/// Metres per degree of latitude, the same constant the projection uses.
const _mPerDegLat = 6371000 * math.pi / 180;
