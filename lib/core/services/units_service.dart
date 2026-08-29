import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

/// Ako sa píše dátum všade, kde ho skiper vidí.
///
/// Nie je to jednotka, ale patrí to sem z rovnakého dôvodu ako jednotky: je
/// to voľba zobrazenia, ktorá nemení ani jeden uložený údaj. V databáze aj v
/// exportoch je dátum vždy strojový, prepína sa len to, čo sa vykreslí.
enum DateStyle {
  /// Podľa jazyka appky — v slovenčine „piatok 21. augusta 2026",
  /// v angličtine „Friday 21 August 2026". Predvolené.
  appLanguage,

  /// 21.08.2026 — európsky číselný zápis.
  dmy,

  /// 08/21/2026 — americký číselný zápis.
  mdy,

  /// 2026-08-21 — ISO 8601. Jednoznačné bez ohľadu na zvyklosti, praktické
  /// v medzinárodnej posádke a pri triedení exportov.
  iso,
}

/// V akom pásme sa tlačí čas všade, kde ho skiper číta.
///
/// Uložený okamih sa nemení — v databáze je vždy UTC. Prepína sa len to, na
/// aké hodiny sa prepočíta pri zobrazení a v PDF.
enum TimeZoneMode {
  /// Čas telefónu, teda pásmo oblasti, v ktorej sa loď nachádza (pokiaľ má
  /// telefón pásmo nastavené správne — pri roamingu si ho nastaví sám).
  /// Predvolené: skiper číta ten istý čas, aký má na hodinkách.
  local,

  /// UTC. Konvencia lodného denníka — jednoznačné bez ohľadu na to, kde sa
  /// loď nachádzala a či práve platil letný čas.
  utc,
}

const _kmPerNm = 1.852;

class UnitsSettings {
  final TempUnit temp;
  final DepthUnit depth;
  final WindUnit wind;
  final DistanceUnit distance;
  final SpeedUnit speed;
  final DateStyle dateStyle;
  final TimeZoneMode timeZone;

  const UnitsSettings({
    this.temp = TempUnit.celsius,
    this.depth = DepthUnit.meters,
    this.wind = WindUnit.knots,
    this.distance = DistanceUnit.nauticalMiles,
    this.speed = SpeedUnit.knots,
    this.dateStyle = DateStyle.appLanguage,
    this.timeZone = TimeZoneMode.local,
  });

  UnitsSettings copyWith({
    TempUnit? temp,
    DepthUnit? depth,
    WindUnit? wind,
    DistanceUnit? distance,
    SpeedUnit? speed,
    DateStyle? dateStyle,
    TimeZoneMode? timeZone,
  }) =>
      UnitsSettings(
        temp: temp ?? this.temp,
        depth: depth ?? this.depth,
        wind: wind ?? this.wind,
        distance: distance ?? this.distance,
        speed: speed ?? this.speed,
        dateStyle: dateStyle ?? this.dateStyle,
        timeZone: timeZone ?? this.timeZone,
      );

  // ── Čas ─────────────────────────────────────────────────────────
  // Uložený okamih je vždy UTC; tieto metódy ho prepočítajú na pásmo, ktoré
  // si skiper zvolil. Volajú sa aj tam, kde predtým stálo `.toUtc()` natvrdo
  // — `.toUtc()` nebolo nikdy zbytočné: drift vracia DateTime označený ako
  // lokálny, takže formátovanie bez prevodu by vypísalo lokálny čas a
  // označilo ho ako UTC.

  /// Okamih prevedený do zvoleného pásma.
  DateTime atZone(DateTime t) =>
      timeZone == TimeZoneMode.utc ? t.toUtc() : t.toLocal();

  /// Posun pásma pre daný okamih, napr. `UTC+2`. Berie sa k okamihu, nie k
  /// „teraz" — inak by záznam z júla vyšiel v zime o hodinu vedľa.
  String offsetLabel(DateTime t) {
    final off = t.toLocal().timeZoneOffset;
    final sign = off.isNegative ? '-' : '+';
    final h = off.inHours.abs();
    final m = off.inMinutes.abs() % 60;
    return m == 0
        ? 'UTC$sign$h'
        : 'UTC$sign$h:${m.toString().padLeft(2, '0')}';
  }

  /// Označenie pásma pre hlavičky, pätičky a podpisy. Pri lokálnom čase aj s
  /// posunom, aby dokument ostal jednoznačný aj pre čitateľa, ktorý nevie,
  /// kde loď bola.
  String zoneLabel(DateTime t) =>
      timeZone == TimeZoneMode.utc ? 'UTC' : 'LT (${offsetLabel(t)})';

  /// Krátky čas v zvolenom pásme, bez označenia pásma — pre stĺpce tabuliek,
  /// kde označenie stojí v hlavičke.
  String formatTime(DateTime t, {bool seconds = false}) =>
      DateFormat(seconds ? 'HH:mm:ss' : 'HH:mm').format(atZone(t));

  /// Čas aj s označením pásma — pre miesta, kde stojí osamote.
  String formatTimeWithZone(DateTime t, {bool seconds = false}) =>
      '${formatTime(t, seconds: seconds)} ${zoneLabel(t)}';

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
  static const _kDateStyle = 'units_date_style';
  static const _kTimeZone = 'units_time_zone';

  @override
  Future<UnitsSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return UnitsSettings(
      temp: TempUnit.values[prefs.getInt(_kTemp) ?? 0],
      depth: DepthUnit.values[prefs.getInt(_kDepth) ?? 0],
      wind: WindUnit.values[prefs.getInt(_kWind) ?? 0],
      distance: DistanceUnit.values[prefs.getInt(_kDistance) ?? 0],
      speed: SpeedUnit.values[prefs.getInt(_kSpeed) ?? 0],
      dateStyle: DateStyle.values[prefs.getInt(_kDateStyle) ?? 0],
      timeZone: TimeZoneMode.values[prefs.getInt(_kTimeZone) ?? 0],
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

  Future<void> setDateStyle(DateStyle v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDateStyle, v.index);
    state = AsyncData(state.value!.copyWith(dateStyle: v));
  }

  Future<void> setTimeZone(TimeZoneMode v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTimeZone, v.index);
    state = AsyncData(state.value!.copyWith(timeZone: v));
  }
}

final unitsProvider = AsyncNotifierProvider<UnitsNotifier, UnitsSettings>(
  UnitsNotifier.new,
);

// Convenience – sync prístup s fallback
final unitsSyncProvider = Provider<UnitsSettings>((ref) {
  return ref.watch(unitsProvider).valueOrNull ?? const UnitsSettings();
});
