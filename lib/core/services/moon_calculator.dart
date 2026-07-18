import 'dart:math';

/// Lokálny výpočet mesačnej fázy (bez volania externého API), rovnaký duch
/// ako [SolarCalculator] pre východ/západ slnka – fáza mesiaca je globálne
/// rovnaká v danom okamihu (paralaxa je pre účely tejto appky zanedbateľná),
/// takže na rozdiel od slnka nepotrebuje polohu.
class MoonCalculator {
  /// Overený referenčný novmesiac (astronomicky presný, používaný ako epoch
  /// vo väčšine jednoduchých fázových výpočtov).
  static final _knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
  static const _synodicMonthDays = 29.530588853;

  /// Vek mesiaca v dňoch od posledného novmesiaca (0 .. ~29.53).
  static double ageDays(DateTime date) {
    final diffDays =
        date.toUtc().difference(_knownNewMoon).inMilliseconds / 86400000.0;
    final normalized = diffDays % _synodicMonthDays;
    return normalized < 0 ? normalized + _synodicMonthDays : normalized;
  }

  /// Osvetlená časť disku (0 = novmesiac, 1 = spln).
  static double illumination(DateTime date) {
    final phaseAngle = ageDays(date) / _synodicMonthDays * 2 * pi;
    return (1 - cos(phaseAngle)) / 2;
  }

  /// `true` pokiaľ mesiac dorastá (novmesiac → spln).
  static bool isWaxing(DateTime date) =>
      ageDays(date) / _synodicMonthDays < 0.5;

  /// Index fázy 0..7 (New, Waxing Crescent, First Quarter, Waxing Gibbous,
  /// Full, Waning Gibbous, Last Quarter, Waning Crescent) – 8 rovnakých
  /// úsekov posunutých o pol úseku, bežná konvencia.
  static int phaseIndex(DateTime date) {
    final fraction = ageDays(date) / _synodicMonthDays;
    return (((fraction + 1 / 16) % 1) * 8).floor();
  }
}
