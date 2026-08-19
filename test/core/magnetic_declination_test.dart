/// Validates the WMM implementation against NOAA's own published test vectors.
///
/// `test/fixtures/wmm2025_test_values.txt` is the unmodified
/// `WMM2025_TestValues.txt` shipped in NOAA's WMM2025 coefficient archive. If
/// this file is ever regenerated for a newer model, drop in the new test
/// values alongside the new coefficients — the point of the fixture is that it
/// comes from NOAA, not from us.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/utils/magnetic_declination.dart';
import 'package:hmb_sailing_log/core/utils/wmm_2025_coefficients.dart';

class _Vector {
  final double year, altitudeKm, lat, lon;
  final double declination, inclination, h, x, y, z, f;
  const _Vector(this.year, this.altitudeKm, this.lat, this.lon,
      this.declination, this.inclination, this.h, this.x, this.y, this.z, this.f);
}

List<_Vector> _loadVectors() {
  final file = File('test/fixtures/wmm2025_test_values.txt');
  final vectors = <_Vector>[];
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final f = trimmed.split(RegExp(r'\s+')).map(double.parse).toList();
    vectors.add(_Vector(
        f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10]));
  }
  return vectors;
}

void main() {
  group('WMM2025 against NOAA test values', () {
    final vectors = _loadVectors();

    test('the fixture actually loaded', () {
      expect(vectors, isNotEmpty);
      // The published set covers five epochs at two altitudes.
      expect(vectors.length, greaterThanOrEqualTo(50));
    });

    test('declination matches to 0.01°', () {
      for (final v in vectors) {
        final field = MagneticDeclination.fieldAtDecimalYear(
          latitude: v.lat,
          longitude: v.lon,
          decimalYear: v.year,
          altitudeKm: v.altitudeKm,
        );
        expect(field.declination, closeTo(v.declination, 0.01),
            reason: 'D at ${v.lat}/${v.lon} @ ${v.year}, ${v.altitudeKm} km');
      }
    });

    test('inclination matches to 0.01°', () {
      for (final v in vectors) {
        final field = MagneticDeclination.fieldAtDecimalYear(
          latitude: v.lat,
          longitude: v.lon,
          decimalYear: v.year,
          altitudeKm: v.altitudeKm,
        );
        expect(field.inclination, closeTo(v.inclination, 0.01),
            reason: 'I at ${v.lat}/${v.lon} @ ${v.year}');
      }
    });

    test('X, Y, Z, H and F match to 1 nT', () {
      for (final v in vectors) {
        final field = MagneticDeclination.fieldAtDecimalYear(
          latitude: v.lat,
          longitude: v.lon,
          decimalYear: v.year,
          altitudeKm: v.altitudeKm,
        );
        final where = '${v.lat}/${v.lon} @ ${v.year}';
        expect(field.north, closeTo(v.x, 1.0), reason: 'X at $where');
        expect(field.east, closeTo(v.y, 1.0), reason: 'Y at $where');
        expect(field.vertical, closeTo(v.z, 1.0), reason: 'Z at $where');
        expect(field.horizontalIntensity, closeTo(v.h, 1.0),
            reason: 'H at $where');
        expect(field.totalIntensity, closeTo(v.f, 1.0), reason: 'F at $where');
      }
    });
  });

  group('coefficient table', () {
    test('holds every degree 1..12 term exactly once', () {
      expect(kWmm2025Coefficients.length, 90); // sum of (n+1) for n = 1..12
      final seen = <String>{};
      for (final row in kWmm2025Coefficients) {
        final n = row[0].toInt();
        final m = row[1].toInt();
        expect(m, lessThanOrEqualTo(n));
        expect(seen.add('$n:$m'), isTrue, reason: 'duplicate term $n/$m');
      }
      for (var n = 1; n <= 12; n++) {
        for (var m = 0; m <= n; m++) {
          expect(seen.contains('$n:$m'), isTrue, reason: 'missing term $n/$m');
        }
      }
    });

    test('order-zero terms carry no h coefficient', () {
      // h(n,0) is meaningless — sin(0·λ) is zero — and NOAA writes it as 0.
      for (final row in kWmm2025Coefficients.where((r) => r[1] == 0)) {
        expect(row[3], 0.0);
        expect(row[5], 0.0);
      }
    });
  });

  group('practical sailing behaviour', () {
    test('Adriatic declination is a few degrees east', () {
      // Split, mid-2026. Charted variation for the central Adriatic is
      // around +4°E; anything outside 2°–7° means the model is wrong.
      final d = MagneticDeclination.at(43.5, 16.4,
          date: DateTime.utc(2026, 7, 1));
      expect(d, greaterThan(2.0));
      expect(d, lessThan(7.0));
    });

    test('declination is east-positive, so it adds to a magnetic bearing', () {
      // A true bearing east of the magnetic one wherever declination is east.
      const magnetic = 90.0;
      final d = MagneticDeclination.at(43.5, 16.4,
          date: DateTime.utc(2026, 7, 1));
      final trueBearing = (magnetic + d) % 360;
      expect(trueBearing, greaterThan(magnetic));
    });

    test('decimal year puts 1 January at year.0', () {
      expect(MagneticDeclination.decimalYear(DateTime.utc(2026)),
          closeTo(2026.0, 1e-9));
      expect(MagneticDeclination.decimalYear(DateTime.utc(2026, 7, 2, 12)),
          closeTo(2026.5, 2e-3));
    });

    test('flags dates past the model validity window', () {
      final valid = MagneticDeclination.fieldAtDecimalYear(
          latitude: 43.5, longitude: 16.4, decimalYear: 2027.0);
      expect(valid.withinValidity, isTrue);

      final expired = MagneticDeclination.fieldAtDecimalYear(
          latitude: 43.5, longitude: 16.4, decimalYear: 2031.0);
      expect(expired.withinValidity, isFalse);
      // Still returns a usable number rather than throwing.
      expect(expired.declination.isFinite, isTrue);
    });

    test('survives the poles without emitting NaN', () {
      for (final lat in [90.0, -90.0, 89.9999]) {
        final field = MagneticDeclination.fieldAtDecimalYear(
            latitude: lat, longitude: 0, decimalYear: 2026.0);
        expect(field.declination.isFinite, isTrue, reason: 'lat $lat');
        expect(field.totalIntensity.isFinite, isTrue, reason: 'lat $lat');
      }
    });
  });
}
