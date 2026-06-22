import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TempUnit { celsius, fahrenheit }
enum DepthUnit { meters, feet }
enum WindUnit { knots, ms, beaufort }

class UnitsSettings {
  final TempUnit temp;
  final DepthUnit depth;
  final WindUnit wind;

  const UnitsSettings({
    this.temp = TempUnit.celsius,
    this.depth = DepthUnit.meters,
    this.wind = WindUnit.knots,
  });

  UnitsSettings copyWith({TempUnit? temp, DepthUnit? depth, WindUnit? wind}) =>
      UnitsSettings(
        temp: temp ?? this.temp,
        depth: depth ?? this.depth,
        wind: wind ?? this.wind,
      );

  // Formátovanie hodnôt
  String formatTemp(double? c) {
    if (c == null) return '-';
    if (temp == TempUnit.fahrenheit) return '${(c * 9 / 5 + 32).toStringAsFixed(1)} °F';
    return '${c.toStringAsFixed(1)} °C';
  }

  String formatDepth(double? m) {
    if (m == null) return '-';
    if (depth == DepthUnit.feet) return '${(m * 3.28084).toStringAsFixed(1)} ft';
    return '${m.toStringAsFixed(1)} m';
  }

  String formatWind(double? kn) {
    if (kn == null) return '-';
    switch (wind) {
      case WindUnit.knots: return '${kn.toStringAsFixed(1)} kn';
      case WindUnit.ms: return '${(kn * 0.514444).toStringAsFixed(1)} m/s';
      case WindUnit.beaufort: return 'Bft ${_beaufort(kn)}';
    }
  }

  String formatWindFull(double? kn) {
    if (kn == null) return '-';
    final bft = _beaufort(kn);
    switch (wind) {
      case WindUnit.knots: return '${kn.toStringAsFixed(0)} kn  (Bft $bft)';
      case WindUnit.ms: return '${(kn * 0.514444).toStringAsFixed(1)} m/s  (Bft $bft)';
      case WindUnit.beaufort: return 'Bft $bft  (${kn.toStringAsFixed(0)} kn)';
    }
  }

  // Fixné jednotky – vždy rovnaké
  String formatSpeed(double? kn) => kn == null ? '-' : '${kn.toStringAsFixed(1)} kn';
  String formatDistance(double? nm) => nm == null ? '-' : '${nm.toStringAsFixed(2)} NM';
  String formatCourse(double? deg) => deg == null ? '-' : '${deg.toStringAsFixed(0)}°';
  String formatPressure(double? hpa) => hpa == null ? '-' : '${hpa.toStringAsFixed(0)} hPa';

  int _beaufort(double kn) {
    if (kn < 1) return 0; if (kn < 6) return 1; if (kn < 12) return 2;
    if (kn < 20) return 3; if (kn < 29) return 4; if (kn < 39) return 5;
    if (kn < 50) return 6; if (kn < 62) return 7; if (kn < 75) return 8;
    if (kn < 89) return 9; if (kn < 103) return 10; if (kn < 118) return 11;
    return 12;
  }
}

class UnitsNotifier extends AsyncNotifier<UnitsSettings> {
  static const _kTemp = 'units_temp';
  static const _kDepth = 'units_depth';
  static const _kWind = 'units_wind';

  @override
  Future<UnitsSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return UnitsSettings(
      temp: TempUnit.values[prefs.getInt(_kTemp) ?? 0],
      depth: DepthUnit.values[prefs.getInt(_kDepth) ?? 0],
      wind: WindUnit.values[prefs.getInt(_kWind) ?? 0],
    );
  }

  Future<void> setTemp(TempUnit v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTemp, v.index);
    state = AsyncData(state.value!.copyWith(temp: v));
  }

  Future<void> setDepth(DepthUnit v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDepth, v.index);
    state = AsyncData(state.value!.copyWith(depth: v));
  }

  Future<void> setWind(WindUnit v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWind, v.index);
    state = AsyncData(state.value!.copyWith(wind: v));
  }
}

final unitsProvider = AsyncNotifierProvider<UnitsNotifier, UnitsSettings>(
  UnitsNotifier.new,
);

// Convenience – sync prístup s fallback
final unitsSyncProvider = Provider<UnitsSettings>((ref) {
  return ref.watch(unitsProvider).valueOrNull ?? const UnitsSettings();
});
