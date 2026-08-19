/// World Magnetic Model evaluation — magnetic declination (variation) for a
/// position and date.
///
/// The phone's magnetometer reports a *magnetic* heading. Charts, and every
/// bearing drawn on the map, work in *true* north. The difference is the
/// magnetic declination, and it is not small: roughly +4°E in the Adriatic,
/// +8°E in the Baltic, and past +15° off Norway. Plotting a magnetic bearing
/// as if it were true puts a 5 NM sight line most of a mile off.
///
/// This is the standard WMM spherical-harmonic evaluation to degree 12, using
/// the official NOAA coefficients in [kWmm2025Coefficients]. It reproduces
/// NOAA's own published test vectors — see
/// `test/core/magnetic_declination_test.dart`, which runs the whole official
/// `WMM2025_TestValues.txt` set through it.
///
/// Pure Dart on purpose: no Flutter, no drift, so it can be tested directly.
library;

import 'dart:math' as math;

import 'wmm_2025_coefficients.dart';

/// The geomagnetic field at one point, in the local geodetic frame.
///
/// Component sign conventions follow the WMM: [north]/[east] lie in the
/// horizontal plane, [vertical] is positive downwards.
class GeomagneticField {
  /// Angle from true north to magnetic north, degrees, **east positive**.
  ///
  /// Add it to a magnetic bearing to get a true bearing:
  /// `true = magnetic + declination`.
  final double declination;

  /// Dip angle below horizontal, degrees, positive downwards.
  final double inclination;

  /// North component (X), nT.
  final double north;

  /// East component (Y), nT.
  final double east;

  /// Vertical component (Z), nT, positive down.
  final double vertical;

  /// Horizontal intensity (H), nT.
  final double horizontalIntensity;

  /// Total intensity (F), nT.
  final double totalIntensity;

  /// False once the date falls outside the coefficient set's validity window.
  ///
  /// The model still returns a number — secular variation extrapolates —
  /// but the error grows, and the coefficients want replacing with the next
  /// WMM release. Surfaced so the UI can say so instead of quietly drifting.
  final bool withinValidity;

  const GeomagneticField({
    required this.declination,
    required this.inclination,
    required this.north,
    required this.east,
    required this.vertical,
    required this.horizontalIntensity,
    required this.totalIntensity,
    required this.withinValidity,
  });
}

class MagneticDeclination {
  MagneticDeclination._();

  /// Highest degree/order of the model.
  static const int _maxDegree = 12;

  /// WGS84 ellipsoid, kilometres.
  static const double _wgs84SemiMajorKm = 6378.137;
  static const double _wgs84Flattening = 1 / 298.257223563;
  static const double _wgs84E2 =
      _wgs84Flattening * (2 - _wgs84Flattening);

  /// Declination in degrees, east positive, at a position and date.
  ///
  /// [date] defaults to now; only the date matters, not the time of day.
  /// [altitudeKm] is height above the WGS84 ellipsoid — leave it at sea level
  /// for anything afloat.
  static double at(
    double latitude,
    double longitude, {
    DateTime? date,
    double altitudeKm = 0,
  }) =>
      fieldAt(
        latitude: latitude,
        longitude: longitude,
        date: date,
        altitudeKm: altitudeKm,
      ).declination;

  /// Full field solution at a position and date.
  static GeomagneticField fieldAt({
    required double latitude,
    required double longitude,
    DateTime? date,
    double altitudeKm = 0,
  }) =>
      fieldAtDecimalYear(
        latitude: latitude,
        longitude: longitude,
        decimalYear: decimalYear(date ?? DateTime.now().toUtc()),
        altitudeKm: altitudeKm,
      );

  /// Decimal year as the WMM defines it: whole year plus the elapsed fraction
  /// of that year, so 1 January is exactly `year.0`.
  static double decimalYear(DateTime date) {
    final utc = date.toUtc();
    final startOfYear = DateTime.utc(utc.year);
    final startOfNext = DateTime.utc(utc.year + 1);
    final elapsed = utc.difference(startOfYear).inSeconds;
    final total = startOfNext.difference(startOfYear).inSeconds;
    return utc.year + elapsed / total;
  }

  /// The evaluation itself, taking the decimal year directly.
  ///
  /// Exposed because NOAA's test vectors are given at exact decimal years
  /// (2025.0, 2027.5, …) that no calendar date lands on precisely.
  static GeomagneticField fieldAtDecimalYear({
    required double latitude,
    required double longitude,
    required double decimalYear,
    double altitudeKm = 0,
  }) {
    final yearsFromEpoch = decimalYear - kWmm2025Epoch;

    // ── Coefficients advanced to the requested date by secular variation ──
    final g = List.generate(
        _maxDegree + 1, (_) => List<double>.filled(_maxDegree + 1, 0));
    final h = List.generate(
        _maxDegree + 1, (_) => List<double>.filled(_maxDegree + 1, 0));
    for (final row in kWmm2025Coefficients) {
      final n = row[0].toInt();
      final m = row[1].toInt();
      g[n][m] = row[2] + yearsFromEpoch * row[4];
      h[n][m] = row[3] + yearsFromEpoch * row[5];
    }

    final latRad = latitude * math.pi / 180;
    final lonRad = longitude * math.pi / 180;

    // ── Geodetic → geocentric spherical ───────────────────────────────
    // The model is evaluated on a sphere, but positions arrive on the WGS84
    // ellipsoid; the two latitudes differ by up to ~0.19°.
    final sinGd = math.sin(latRad);
    final cosGd = math.cos(latRad);
    final curvature =
        _wgs84SemiMajorKm / math.sqrt(1 - _wgs84E2 * sinGd * sinGd);
    final pAxis = (curvature + altitudeKm) * cosGd;
    final zAxis = (curvature * (1 - _wgs84E2) + altitudeKm) * sinGd;
    final radiusKm = math.sqrt(pAxis * pAxis + zAxis * zAxis);
    final sinPhi = zAxis / radiusKm;
    var cosPhi = pAxis / radiusKm;

    // The Y component divides by cos(latitude), which collapses at the
    // geographic poles. Nothing sails there; clamp rather than emit NaN.
    const polarFloor = 1e-10;
    if (cosPhi.abs() < polarFloor) cosPhi = polarFloor;

    // ── Schmidt semi-normalised Legendre functions and dP/dφ ──────────
    final p = List.generate(
        _maxDegree + 1, (_) => List<double>.filled(_maxDegree + 1, 0));
    final dp = List.generate(
        _maxDegree + 1, (_) => List<double>.filled(_maxDegree + 1, 0));
    p[0][0] = 1;
    dp[0][0] = 0;

    for (var n = 1; n <= _maxDegree; n++) {
      for (var m = 0; m <= n; m++) {
        if (n == m) {
          // Diagonal. The m == 1 step carries no normalisation factor —
          // that is what makes P(1,1) come out as cos(φ) exactly.
          final k = m == 1 ? 1.0 : math.sqrt((2 * m - 1) / (2 * m));
          p[n][m] = k * cosPhi * p[n - 1][m - 1];
          dp[n][m] =
              k * (cosPhi * dp[n - 1][m - 1] - sinPhi * p[n - 1][m - 1]);
        } else {
          // Vertical recursion. At n == m + 1 the n-2 term is multiplied by
          // a factor that is exactly zero, so the missing row costs nothing.
          final denom = math.sqrt((n * n - m * m).toDouble());
          final older = math.sqrt(((n - 1) * (n - 1) - m * m).toDouble());
          final p2 = n >= 2 ? p[n - 2][m] : 0.0;
          final dp2 = n >= 2 ? dp[n - 2][m] : 0.0;
          p[n][m] =
              ((2 * n - 1) * sinPhi * p[n - 1][m] - older * p2) / denom;
          dp[n][m] = ((2 * n - 1) *
                      (sinPhi * dp[n - 1][m] + cosPhi * p[n - 1][m]) -
                  older * dp2) /
              denom;
        }
      }
    }

    // ── Field summation, geocentric frame ─────────────────────────────
    final ratio = kWmmGeomagneticRadiusKm / radiusKm;
    var geocentricNorth = 0.0;
    var geocentricEast = 0.0;
    var geocentricDown = 0.0;
    var ratioPow = ratio * ratio; // becomes ratio^(n+2) inside the loop

    for (var n = 1; n <= _maxDegree; n++) {
      ratioPow *= ratio;
      for (var m = 0; m <= n; m++) {
        final cosML = math.cos(m * lonRad);
        final sinML = math.sin(m * lonRad);
        final inPhase = g[n][m] * cosML + h[n][m] * sinML;
        final quadrature = g[n][m] * sinML - h[n][m] * cosML;
        geocentricNorth -= ratioPow * inPhase * dp[n][m];
        geocentricEast += ratioPow * m * quadrature * p[n][m];
        geocentricDown -= ratioPow * (n + 1) * inPhase * p[n][m];
      }
    }
    geocentricEast /= cosPhi;

    // ── Geocentric → geodetic frame ───────────────────────────────────
    // Rotate by the angle between the radius vector and the ellipsoid
    // normal. Small (≤ ~0.19°) but it moves X and Z measurably.
    final tilt = math.asin(sinPhi) - latRad;
    final cosTilt = math.cos(tilt);
    final sinTilt = math.sin(tilt);
    final north = geocentricNorth * cosTilt - geocentricDown * sinTilt;
    final vertical = geocentricNorth * sinTilt + geocentricDown * cosTilt;
    final east = geocentricEast;

    final horizontal = math.sqrt(north * north + east * east);
    final total = math.sqrt(horizontal * horizontal + vertical * vertical);

    return GeomagneticField(
      declination: math.atan2(east, north) * 180 / math.pi,
      inclination: math.atan2(vertical, horizontal) * 180 / math.pi,
      north: north,
      east: east,
      vertical: vertical,
      horizontalIntensity: horizontal,
      totalIntensity: total,
      withinValidity: decimalYear >= kWmm2025Epoch &&
          decimalYear <= kWmm2025ValidUntil,
    );
  }
}
