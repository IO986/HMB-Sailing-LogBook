import 'package:flutter/foundation.dart' show debugPrint;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/gps_tracking_service.dart';
import '../../../core/services/marine_poi_service.dart';
import '../../../features/tracking/providers/tracking_provider.dart';
import '../../../main.dart';

/// Podkladová mapa: OSM/tmavá dlaždicová mapa alebo satelitné snímky.
/// Uchováva sa ako user setting v [MapState.baseMap].
enum BaseMap { osm, satellite }

final waypointsProvider = FutureProvider<List<Waypoint>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllWaypoints();
});

/// Cieľ navigácie k waypointu (VMG WP na prístrojovej doske).
///
/// Drží sa len id, nie odfotená kópia waypointu. Predtým tu sedel celý
/// [Waypoint] a po zmazaní bodu z mapy navigácia ďalej ukazovala kurz a
/// vzdialenosť k bodu, ktorý už neexistoval — a vypnúť sa dala len ručne
/// cez "žiadny cieľ". Odvodený [navTargetProvider] vracia null, len čo
/// bod zmizne zo zoznamu, takže navigácia padne sama.
final navTargetIdProvider = StateProvider<int?>((ref) => null);

/// Waypoint, ku ktorému sa práve naviguje, alebo null.
final navTargetProvider = Provider<Waypoint?>((ref) {
  final id = ref.watch(navTargetIdProvider);
  if (id == null) return null;
  // Počas obnovy zoznamu drží valueOrNull predchádzajúce dáta, takže
  // navigácia neprebleskne pri každom invalidate.
  final waypoints = ref.watch(waypointsProvider).valueOrNull;
  if (waypoints == null) return null;
  for (final w in waypoints) {
    if (w.id == id) return w;
  }
  return null;
});

/// GPS trasa aktuálnej session – obnoví sa pri každom novom GPS bode.
final currentTrackProvider = Provider<List<LatLng>>((ref) {
  ref.watch(positionStreamProvider); // Rebuild on every new GPS position
  return GpsTrackingService().trackPoints;
});

/// Body trasy vybraného dňa, zoradené podľa času.
///
/// Celé `TrackPoint`, nie len súradnice: prehrávanie na časovej osi potrebuje
/// čas, rýchlosť aj kurz. Deň môže mať viac úsekov, keď sa tracking uprostred
/// prerušil, preto sa spájajú všetky session dňa.
final dayTrackPointsProvider =
    FutureProvider.family<List<TrackPoint>, int>((ref, dayLogId) async {
  final db = ref.watch(databaseProvider);
  final sessions = await db.getSessionsForDay(dayLogId);
  final points = <TrackPoint>[];
  for (final s in sessions) {
    points.addAll(await db.getTrackPointsForSession(s.sessionId));
  }
  points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return points;
});

/// Body trasy celej plavby (všetky dni spojené), zoradené podľa času.
final charterTrackPointsProvider =
    FutureProvider.family<List<TrackPoint>, int>((ref, charterId) async {
  final db = ref.watch(databaseProvider);
  final days = await db.getDayLogs(charterId);
  final points = <TrackPoint>[];
  for (final day in days) {
    final sessions = await db.getSessionsForDay(day.id);
    for (final s in sessions) {
      points.addAll(await db.getTrackPointsForSession(s.sessionId));
    }
  }
  points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return points;
});

/// GPS trasa vybraného dňa (na prehliadanie na mape mimo aktívneho
/// trackingu – importovaná/historická plavba, nie len cez PDF export).
///
/// Odvodené z [dayTrackPointsProvider], aby sa tie isté body neťahali
/// z databázy dvakrát — mapa ich kreslí a prehrávanie po nich chodí.
final dayTrackPreviewProvider =
    FutureProvider.family<List<LatLng>, int>((ref, dayLogId) async {
  final points = await ref.watch(dayTrackPointsProvider(dayLogId).future);
  return [for (final p in points) LatLng(p.latitude, p.longitude)];
});

/// GPS trasa celej plavby (všetky dni spojené) – na prehliadanie celej
/// trasy naraz namiesto po jednotlivých dňoch.
final charterTrackPreviewProvider =
    FutureProvider.family<List<LatLng>, int>((ref, charterId) async {
  final points = await ref.watch(charterTrackPointsProvider(charterId).future);
  return [for (final p in points) LatLng(p.latitude, p.longitude)];
});

/// Denníkové záznamy s polohou pre aktuálny deň (s fotkou aj bez) —
/// reaktívne sleduje DB zmeny, na vykreslenie značiek na mape počas trackingu.
final dayEntryMarkersProvider = StreamProvider<List<LogbookEntry>>((ref) {
  final isTracking = ref.watch(isTrackingProvider);
  if (!isTracking) return Stream.value([]);
  final dayLogId = GpsTrackingService().activeDayLogId;
  if (dayLogId == null) return Stream.value([]);
  return ref.read(databaseProvider).watchMappableEntriesForDay(dayLogId);
});

/// Aktuálny viditeľný výrez mapy — map_screen ho aktualizuje (debounced)
/// pri posune/zoome; POI aj veterná vrstva naň reagujú.
final mapViewBoundsProvider = StateProvider<LatLngBounds?>((_) => null);

/// Kotviská/maríny/prístavy/tankovanie pre viditeľný výrez (Overpass API,
/// kešované po bunkách v MarinePoiService). Prázdne, kým je vrstva vypnutá.
final marinePoisProvider = FutureProvider<List<MarinePoi>>((ref) async {
  final show = ref.watch(mapNotifierProvider.select((s) => s.showMarinePois));
  if (!show) return const [];
  final bounds = ref.watch(mapViewBoundsProvider);
  if (bounds == null) return const [];
  return MarinePoiService().fetchForBounds(bounds);
});

class MapNotifier extends Notifier<MapState> {
  // Kľúče do SharedPreferences pre uchované vrstvy/prepínače mapy.
  static const _kSeamarks = 'map_show_seamarks';
  static const _kMarinePois = 'map_show_marine_pois';
  static const _kBathymetry = 'map_show_bathymetry';

  // Kľúče zrušených vrstiev počasia ('map_weather_overlay', 'map_show_wind_grid',
  // 'map_show_ocean_currents', 'map_show_current_grid', 'map_show_rain_radar')
  // sa už nečítajú. Staré hodnoty ostávajú v SharedPreferences ležať a nikomu
  // neprekážajú; mazať cudzie kľúče pri aktualizácii je viac rizika než úžitku.
  static const _kBearings = 'map_show_bearings';
  static const _kFollowGps = 'map_follow_gps';
  static const _kNorthLocked = 'map_north_locked';
  static const _kBaseMap = 'map_base_map';

  @override
  MapState build() {
    // Notifier.build() musí vrátiť synchronne — vráti defaulty a hneď
    // spustí asynchrónne načítanie uchovaných hodnôt, ktoré stav prepíše.
    // Preview polia sa zámerne neukladajú (sú prechodné).
    _load();
    return const MapState();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = state.copyWith(
      showSeamarks: p.getBool(_kSeamarks) ?? state.showSeamarks,
      showMarinePois: p.getBool(_kMarinePois) ?? state.showMarinePois,
      showBathymetry: p.getBool(_kBathymetry) ?? state.showBathymetry,
      showBearings: p.getBool(_kBearings) ?? state.showBearings,
      followGps: p.getBool(_kFollowGps) ?? state.followGps,
      northLocked: p.getBool(_kNorthLocked) ?? state.northLocked,
      baseMap: BaseMap.values.firstWhere(
        (b) => b.name == p.getString(_kBaseMap),
        orElse: () => state.baseMap,
      ),
    );
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSeamarks, state.showSeamarks);
    await p.setBool(_kMarinePois, state.showMarinePois);
    await p.setBool(_kBathymetry, state.showBathymetry);
    await p.setBool(_kBearings, state.showBearings);
    await p.setBool(_kFollowGps, state.followGps);
    await p.setBool(_kNorthLocked, state.northLocked);
    await p.setString(_kBaseMap, state.baseMap.name);
  }

  void toggleFollowGps() {
    state = state.copyWith(followGps: !state.followGps);
    _persist();
  }

  void setFollowGps(bool v) {
    debugPrint('[MAP] setFollowGps($v) called, was ${state.followGps}');
    state = state.copyWith(followGps: v);
    _persist();
  }

  void toggleBathymetry() {
    state = state.copyWith(showBathymetry: !state.showBathymetry);
    _persist();
  }

  void toggleSeamarks() {
    state = state.copyWith(showSeamarks: !state.showSeamarks);
    _persist();
  }

  void toggleMarinePois() {
    state = state.copyWith(showMarinePois: !state.showMarinePois);
    _persist();
  }

  void toggleBearings() {
    state = state.copyWith(showBearings: !state.showBearings);
    _persist();
  }

  void setNorthLocked(bool v) {
    state = state.copyWith(northLocked: v);
    _persist();
  }

  void toggleBaseMap() {
    state = state.copyWith(
      baseMap: state.baseMap == BaseMap.osm ? BaseMap.satellite : BaseMap.osm,
    );
    _persist();
  }

  /// Zobraz trasu vybraného dňa namiesto aktuálnej živej trasy.
  void previewDay(int dayLogId, String label) => state = _withPreview(
        previewDayLogId: dayLogId,
        previewLabel: label,
      );

  /// Zobraz spojenú trasu celej plavby (všetky dni).
  void previewCharter(int charterId, String label) => state = _withPreview(
        previewCharterId: charterId,
        previewLabel: label,
      );

  /// Vráť sa k živej trase aktuálneho trackingu.
  void clearPreview() => state = _withPreview();

  /// Nový stav so zachovanými vrstvami, ale nastaveným/vynulovaným preview
  /// (copyWith nevie nulovať, preto samostatný helper).
  MapState _withPreview({
    int? previewDayLogId,
    int? previewCharterId,
    String? previewLabel,
  }) =>
      MapState(
        showSeamarks: state.showSeamarks,
        showMarinePois: state.showMarinePois,
        showBathymetry: state.showBathymetry,
        followGps: state.followGps,
        northLocked: state.northLocked,
        baseMap: state.baseMap,
        previewDayLogId: previewDayLogId,
        previewCharterId: previewCharterId,
        previewLabel: previewLabel,
      );

  Future<void> addWaypoint(String name, double lat, double lon) async {
    final db = ref.read(databaseProvider);
    await db.insertWaypoint(WaypointsCompanion.insert(
      name: name,
      latitude: lat,
      longitude: lon,
      createdAt: DateTime.now(),
    ));
    ref.invalidate(waypointsProvider);
  }

  Future<void> deleteWaypoint(int id) async {
    final db = ref.read(databaseProvider);
    await db.deleteWaypoint(id);
    // Navigácia na zmazaný bod sa vypína tu, nie až v UI — zmazať waypoint
    // sa dá aj inokade než z dialógu, ktorý sa pýta.
    if (ref.read(navTargetIdProvider) == id) {
      ref.read(navTargetIdProvider.notifier).state = null;
    }
    ref.invalidate(waypointsProvider);
  }

  Future<void> renameWaypoint(int id, String name) async {
    final db = ref.read(databaseProvider);
    await db.updateWaypointName(id, name);
    ref.invalidate(waypointsProvider);
  }
}

class MapState {
  final bool showSeamarks;

  /// Klikateľná vrstva kotvísk, marín a prístavov (OSM/Overpass).
  final bool showMarinePois;

  /// Izobaty z EMODnet Bathymetry — hĺbnice s popiskom hĺbky.
  ///
  /// Vypnuté od začiatku: je to sieťová vrstva navyše a nad plytkým pobrežím
  /// pridá do mapy čiary, ktoré tam väčšinu času nikto nepotrebuje. Kto
  /// pláva mimo vyznačených trás, si ju zapne.
  ///
  /// NIE JE to náhrada za námornú mapu — EMODnet je zjednotený model dna z
  /// prieskumov rôzneho veku a rozlíšenia, nie hydrografické dielo. Na
  /// plánovanie prielivu áno, na rozhodnutie „prejdem tadiaľ" nie.
  final bool showBathymetry;

  /// Zámerné priamky z námerového kompasu vrátane krížového fixu.
  ///
  /// Zapnuté od začiatku: keď si skiper dá prácu s odčítaním kurzu, čiara
  /// má byť na mape hneď, nie až po hľadaní prepínača vo vrstvách.
  final bool showBearings;
  final bool followGps;

  /// Rotácia mapy zamknutá na sever (north-up). Podržaním kompasu sa
  /// prepína; uchováva sa medzi spusteniami ako user setting.
  final bool northLocked;

  /// Podkladová mapa (OSM vs satelit). Uchováva sa ako user setting —
  /// prežije prepnutie tabu aj reštart appky.
  final BaseMap baseMap;

  /// Ak nastavené, mapa zobrazuje trasu tohto dňa namiesto živého trackingu.
  final int? previewDayLogId;

  /// Ak nastavené, mapa zobrazuje spojenú trasu celej tejto plavby.
  /// Vzájomne sa vylučuje s [previewDayLogId].
  final int? previewCharterId;
  final String? previewLabel;
  const MapState({
    this.showSeamarks = true,
    this.showMarinePois = false,
    this.showBathymetry = false,
    this.showBearings = true,
    this.followGps = true,
    this.northLocked = false,
    this.baseMap = BaseMap.osm,
    this.previewDayLogId,
    this.previewCharterId,
    this.previewLabel,
  });
  MapState copyWith({
    bool? showSeamarks,
    bool? showMarinePois,
    bool? showBathymetry,
    bool? showBearings,
    bool? followGps,
    bool? northLocked,
    BaseMap? baseMap,
    int? previewDayLogId,
    int? previewCharterId,
    String? previewLabel,
  }) =>
      MapState(
        showSeamarks: showSeamarks ?? this.showSeamarks,
        showMarinePois: showMarinePois ?? this.showMarinePois,
        showBathymetry: showBathymetry ?? this.showBathymetry,
        showBearings: showBearings ?? this.showBearings,
        followGps: followGps ?? this.followGps,
        northLocked: northLocked ?? this.northLocked,
        baseMap: baseMap ?? this.baseMap,
        previewDayLogId: previewDayLogId ?? this.previewDayLogId,
        previewCharterId: previewCharterId ?? this.previewCharterId,
        previewLabel: previewLabel ?? this.previewLabel,
      );
}

final mapNotifierProvider =
    NotifierProvider<MapNotifier, MapState>(MapNotifier.new);
