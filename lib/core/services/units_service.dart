import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TempUnit { celsius, fahrenheit }
enum DepthUnit { meters, feet }
enum WindUnit { knots, ms, beaufort }

/// Jednotka vzdialenosti. Vnútri appky aj v DB je vždy NM — prepína sa len
/// zobrazenie, aby staré záznamy a exporty ostali porovnateľné.
enum DistanceUnit { nauticalMiles, kilometers }

/// Jednotka rýchlosti lode. Nesúvisí s [WindUnit]: na rieke sa jazdí v km/h,
/// ale vietor sa aj tam hlási v uzloch alebo Bft.
enum SpeedUnit { knots, kmh }

const _kmPerNm = 1.852;

class UnitsSettings {
  final TempUnit temp;
  final DepthUnit depth;
  final WindUnit wind;
  final DistanceUnit distance;
  final SpeedUnit speed;

  const UnitsSettings({
    this.temp = TempUnit.celsius,
    this.depth = DepthUnit.meters,
    this.wind = WindUnit.knots,
    this.distance = DistanceUnit.nauticalMiles,
    this.speed = SpeedUnit.knots,
  });

  UnitsSettings copyWith({
    TempUnit? temp,
    DepthUnit? depth,
    WindUnit? wind,
    DistanceUnit? distance,
    SpeedUnit? speed,
  }) =>
      UnitsSettings(
        temp: temp ?? this.temp,
        depth: depth ?? this.depth,
        wind: wind ?? this.wind,
        distance: distance ?? this.distance,
        speed: speed ?? this.speed,
      );

  // Formátovanie hodnôt

  /// Označenie jednotky teploty — pre tabuľky, kde jednotka stojí v hlavičke
  /// stĺpca a nie pri každej hodnote (PDF denník).
  String get tempLabel => temp == TempUnit.fahrenheit ? '°F' : '°C';

  double tempValue(double c) =>
      temp == TempUnit.fahrenheit ? c * 9 / 5 + 32 : c;

  String formatTemp(double? c, {int decimals = 1}) => c == null
      ? '-'
      : '${tempValue(c).toStringAsFixed(decimals)} $tempLabel';

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

  /// Označenie jednotky vetra — pre displeje, kde hodnota a jednotka
  /// nestoja vedľa seba (prístrojová doska).
  String get windLabel => switch (wind) {
        WindUnit.knots => 'kn',
        WindUnit.ms => 'm/s',
        WindUnit.beaufort => 'Bft',
      };

  double windValue(double kn) => switch (wind) {
        WindUnit.knots => kn,
        WindUnit.ms => kn * 0.514444,
        WindUnit.beaufort => _beaufort(kn).toDouble(),
      };

  String formatWindFull(double? kn) {
    if (kn == null) return '-';
    final bft = _beaufort(kn);
    switch (wind) {
      case WindUnit.knots: return '${kn.toStringAsFixed(0)} kn  (Bft $bft)';
      case WindUnit.ms: return '${(kn * 0.514444).toStringAsFixed(1)} m/s  (Bft $bft)';
      case WindUnit.beaufort: return 'Bft $bft  (${kn.toStringAsFixed(0)} kn)';
    }
  }

  // ── Vzdialenosť a rýchlosť ──────────────────────────────────────
  // Hodnoty prichádzajú vždy v NM a uzloch — konvertuje sa až pri zobrazení.

  String get distanceLabel =>
      distance == DistanceUnit.kilometers ? 'km' : 'NM';

  String get speedLabel => speed == SpeedUnit.kmh ? 'km/h' : 'kn';

  double distanceValue(double nm) =>
      distance == DistanceUnit.kilometers ? nm * _kmPerNm : nm;

  double speedValue(double kn) => speed == SpeedUnit.kmh ? kn * _kmPerNm : kn;

  /// Vzdialenosť aj s jednotkou, [decimals] desatinných miest.
  String formatDistance(double? nm, {int decimals = 2}) => nm == null
      ? '-'
      : '${distanceValue(nm).toStringAsFixed(decimals)} $distanceLabel';

  String formatSpeed(double? kn, {int decimals = 1}) => kn == null
      ? '-'
      : '${speedValue(kn).toStringAsFixed(decimals)} $speedLabel';

  // Fixné jednotky – vždy rovnaké
  String formatCourse(double? deg) => deg == null ? '-' : '${deg.toStringAsFixed(0)}°';
  String formatPressure(double? hpa) => hpa == null ? '-' : '${hpa.toStringAsFixed(0)} hPa';

  /// Beaufort z rýchlosti vetra **v uzloch** (WMO tabuľka).
  ///
  /// Predtým tu boli prahy km/h (1-5-11-19-28...) aplikované na uzly, takže
  /// každý stupeň vyšiel o dva-tri nižšie — 30 kn (Bft 7, blízko víchrice)
  /// sa hlásilo ako Bft 4. Prístrojová doska, denník aj PDF ťahajú Bft odtiaľ.
  int _beaufort(double kn) {
    if (kn < 1) return 0; if (kn < 4) return 1; if (kn < 7) return 2;
    if (kn < 11) return 3; if (kn < 17) return 4; if (kn < 22) return 5;
    if (kn < 28) return 6; if (kn < 34) return 7; if (kn < 41) return 8;
    if (kn < 48) return 9; if (kn < 56) return 10; if (kn < 64) return 11;
    return 12;
  }
}

class UnitsNotifier extends AsyncNotifier<UnitsSettings> {
  static const _kTemp = 'units_temp';
  static const _kDepth = 'units_depth';
  static const _kWind = 'units_wind';
  static const _kDistance = 'units_distance';
  static const _kSpeed = 'units_speed';

  @override
  Future<UnitsSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return UnitsSettings(
      temp: TempUnit.values[prefs.getInt(_kTemp) ?? 0],
      depth: DepthUnit.values[prefs.getInt(_kDepth) ?? 0],
      wind: WindUnit.values[prefs.getInt(_kWind) ?? 0],
      distance: DistanceUnit.values[prefs.getInt(_kDistance) ?? 0],
      speed: SpeedUnit.values[prefs.getInt(_kSpeed) ?? 0],
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

  Future<void> setDistance(DistanceUnit v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDistance, v.index);
    state = AsyncData(state.value!.copyWith(distance: v));
  }

  Future<void> setSpeed(SpeedUnit v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSpeed, v.index);
    state = AsyncData(state.value!.copyWith(speed: v));
  }
}

final unitsProvider = AsyncNotifierProvider<UnitsNotifier, UnitsSettings>(
  UnitsNotifier.new,
);

// Convenience – sync prístup s fallback
final unitsSyncProvider = Provider<UnitsSettings>((ref) {
  return ref.watch(unitsProvider).valueOrNull ?? const UnitsSettings();
});
