import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/gps_tracking_service.dart';
import '../../../core/services/marine_poi_service.dart';
import '../../../core/services/ocean_current_service.dart';
import '../../../core/services/rain_radar_service.dart';
import '../../../core/services/wind_grid_service.dart';
import '../../../features/tracking/providers/tracking_provider.dart';
import '../../../main.dart';

final waypointsProvider = FutureProvider<List<Waypoint>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllWaypoints();
});

/// GPS trasa aktuálnej session – obnoví sa pri každom novom GPS bode.
final currentTrackProvider = Provider<List<LatLng>>((ref) {
  ref.watch(positionStreamProvider); // Rebuild on every new GPS position
  return GpsTrackingService().trackPoints;
});

/// GPS trasa vybraného dňa (na prehliadanie na mape mimo aktívneho
/// trackingu – importovaná/historická plavba, nie len cez PDF export).
final dayTrackPreviewProvider =
    FutureProvider.family<List<LatLng>, int>((ref, dayLogId) async {
  final db = ref.watch(databaseProvider);
  final sessions = await db.getSessionsForDay(dayLogId);
  final points = <LatLng>[];
  for (final s in sessions) {
    final pts = await db.getTrackPointsForSession(s.sessionId);
    points.addAll(pts.map((p) => LatLng(p.latitude, p.longitude)));
  }
  return points;
});

/// GPS trasa celej plavby (všetky dni spojené) – na prehliadanie celej
/// trasy naraz namiesto po jednotlivých dňoch.
final charterTrackPreviewProvider =
    FutureProvider.family<List<LatLng>, int>((ref, charterId) async {
  final db = ref.watch(databaseProvider);
  final days = await db.getDayLogs(charterId);
  final points = <LatLng>[];
  for (final day in days) {
    final sessions = await db.getSessionsForDay(day.id);
    for (final s in sessions) {
      final pts = await db.getTrackPointsForSession(s.sessionId);
      points.addAll(pts.map((p) => LatLng(p.latitude, p.longitude)));
    }
  }
  return points;
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
  final show = ref.watch(
      mapNotifierProvider.select((s) => s.showMarinePois));
  if (!show) return const [];
  final bounds = ref.watch(mapViewBoundsProvider);
  if (bounds == null) return const [];
  return MarinePoiService().fetchForBounds(bounds);
});

/// URL šablóna dlaždíc najnovšej radarovej snímky (RainViewer), alebo null.
final rainRadarUrlProvider = FutureProvider<String?>((ref) async {
  final show = ref.watch(
      mapNotifierProvider.select((s) => s.showRainRadar));
  if (!show) return null;
  return RainRadarService().latestTileUrl();
});

/// Mriežka šípok vetra pre viditeľný výrez (Open-Meteo).
final windGridProvider = FutureProvider<List<WindPoint>>((ref) async {
  final show = ref.watch(
      mapNotifierProvider.select((s) => s.showWindGrid));
  if (!show) return const [];
  final bounds = ref.watch(mapViewBoundsProvider);
  if (bounds == null) return const [];
  return WindGridService().fetchForBounds(bounds);
});

/// Mriežka šípok reálneho morského prúdu pre viditeľný výrez (Open-Meteo).
/// Odlišná od [MapState.showOceanCurrents], ktorá kreslí curated globálne
/// prúdy — táto je predpoveď pre práve zobrazené miesto.
final currentGridProvider = FutureProvider<List<SeaCurrentPoint>>((ref) async {
  final show = ref.watch(
      mapNotifierProvider.select((s) => s.showCurrentGrid));
  if (!show) return const [];
  final bounds = ref.watch(mapViewBoundsProvider);
  if (bounds == null) return const [];
  return OceanCurrentService().fetchForBounds(bounds);
});

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() => const MapState();

  void toggleFollowGps() =>
      state = state.copyWith(followGps: !state.followGps);

  void setFollowGps(bool v) => state = state.copyWith(followGps: v);

  void toggleSeamarks() =>
      state = state.copyWith(showSeamarks: !state.showSeamarks);

  void toggleMarinePois() =>
      state = state.copyWith(showMarinePois: !state.showMarinePois);

  void toggleRainRadar() =>
      state = state.copyWith(showRainRadar: !state.showRainRadar);

  void toggleWindGrid() =>
      state = state.copyWith(showWindGrid: !state.showWindGrid);

  void toggleOceanCurrents() =>
      state = state.copyWith(showOceanCurrents: !state.showOceanCurrents);

  void toggleCurrentGrid() =>
      state = state.copyWith(showCurrentGrid: !state.showCurrentGrid);

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
        showRainRadar: state.showRainRadar,
        showWindGrid: state.showWindGrid,
        showOceanCurrents: state.showOceanCurrents,
        showCurrentGrid: state.showCurrentGrid,
        followGps: state.followGps,
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
  /// Zrážkový radar (RainViewer overlay).
  final bool showRainRadar;
  /// Šípky vetra v mriežke (Open-Meteo).
  final bool showWindGrid;
  /// Referenčná vrstva hlavných oceánskych prúdov (lokálne curated dáta).
  final bool showOceanCurrents;
  /// Šípky reálneho morského prúdu v mriežke (Open-Meteo predpoveď).
  final bool showCurrentGrid;
  final bool followGps;
  /// Ak nastavené, mapa zobrazuje trasu tohto dňa namiesto živého trackingu.
  final int? previewDayLogId;
  /// Ak nastavené, mapa zobrazuje spojenú trasu celej tejto plavby.
  /// Vzájomne sa vylučuje s [previewDayLogId].
  final int? previewCharterId;
  final String? previewLabel;
  const MapState({
    this.showSeamarks = true,
    this.showMarinePois = false,
    this.showRainRadar = false,
    this.showWindGrid = false,
    this.showOceanCurrents = false,
    this.showCurrentGrid = false,
    this.followGps = true,
    this.previewDayLogId,
    this.previewCharterId,
    this.previewLabel,
  });
  MapState copyWith({
    bool? showSeamarks,
    bool? showMarinePois,
    bool? showRainRadar,
    bool? showWindGrid,
    bool? showOceanCurrents,
    bool? showCurrentGrid,
    bool? followGps,
    int? previewDayLogId,
    int? previewCharterId,
    String? previewLabel,
  }) => MapState(
        showSeamarks: showSeamarks ?? this.showSeamarks,
        showMarinePois: showMarinePois ?? this.showMarinePois,
        showRainRadar: showRainRadar ?? this.showRainRadar,
        showWindGrid: showWindGrid ?? this.showWindGrid,
        showOceanCurrents: showOceanCurrents ?? this.showOceanCurrents,
        showCurrentGrid: showCurrentGrid ?? this.showCurrentGrid,
        followGps: followGps ?? this.followGps,
        previewDayLogId: previewDayLogId ?? this.previewDayLogId,
        previewCharterId: previewCharterId ?? this.previewCharterId,
        previewLabel: previewLabel ?? this.previewLabel,
      );
}

final mapNotifierProvider =
    NotifierProvider<MapNotifier, MapState>(MapNotifier.new);
