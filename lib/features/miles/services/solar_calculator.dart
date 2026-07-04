import 'dart:math';

/// Lokálny výpočet východu/západu slnka (NOAA/Wikipedia "sunrise equation"
/// algoritmus, presnosť ~1-2 min) – bez volania externého API. Používa sa
/// na určenie, ktoré úseky GPS tracku patria do nočnej plavby.
class SolarCalculator {
  static const _j2000 = 2451545.0;

  /// Vráti (sunrise, sunset) v UTC pre daný kalendárny dátum a polohu.
  /// Oba môžu byť `null` pri polárnom dni/noci (slnko nevyjde/nezapadne).
  static ({DateTime? sunrise, DateTime? sunset}) sunriseSunsetUtc(
      DateTime date, double latDeg, double lonDeg) {
    final jdn = _julianDayNumber(date.year, date.month, date.day);

    final n = jdn - _j2000 + 0.0008;
    final jStar = n - lonDeg / 360.0;

    final mDeg = _mod360(357.5291 + 0.98560028 * jStar);
    final mRad = _degToRad(mDeg);
    final c = 1.9148 * sin(mRad) + 0.0200 * sin(2 * mRad) + 0.0003 * sin(3 * mRad);
    final lambdaDeg = _mod360(mDeg + c + 180.0 + 102.9372);
    final lambdaRad = _degToRad(lambdaDeg);

    final jTransit =
        _j2000 + jStar + 0.0053 * sin(mRad) - 0.0069 * sin(2 * lambdaRad);

    final delta = asin(sin(lambdaRad) * sin(_degToRad(23.4397)));
    final latRad = _degToRad(latDeg);

    final cosOmega0 = (sin(_degToRad(-0.833)) - sin(latRad) * sin(delta)) /
        (cos(latRad) * cos(delta));

    if (cosOmega0 > 1 || cosOmega0 < -1) {
      // Polárny deň (nikdy nezapadne) alebo polárna noc (nikdy nevyjde).
      return (sunrise: null, sunset: null);
    }

    final omega0Deg = _radToDeg(acos(cosOmega0));
    final jRise = jTransit - omega0Deg / 360.0;
    final jSet = jTransit + omega0Deg / 360.0;

    return (sunrise: _julianToDateTimeUtc(jRise), sunset: _julianToDateTimeUtc(jSet));
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / pi;
  static double _mod360(double deg) => deg - 360.0 * (deg / 360.0).floor();

  static double _julianDayNumber(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return (day +
            ((153 * m + 2) ~/ 5) +
            365 * y +
            (y ~/ 4) -
            (y ~/ 100) +
            (y ~/ 400) -
            32045)
        .toDouble();
  }

  static DateTime _julianToDateTimeUtc(double jd) {
    final jdShifted = jd + 0.5;
    final z = jdShifted.floor();
    final f = jdShifted - z;
    int a;
    if (z < 2299161) {
      a = z;
    } else {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha ~/ 4);
    }
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();

    final dayWithFraction = b - d - (30.6001 * e).floor() + f;
    final day = dayWithFraction.floor();
    final month = (e < 14) ? e - 1 : e - 13;
    final year = (month > 2) ? c - 4716 : c - 4715;

    final dayFraction = dayWithFraction - day;
    final totalSeconds = (dayFraction * 86400).round();
    final hour = totalSeconds ~/ 3600;
    final minute = (totalSeconds % 3600) ~/ 60;
    final second = totalSeconds % 60;

    return DateTime.utc(year, month, day, hour, minute, second);
  }
}
