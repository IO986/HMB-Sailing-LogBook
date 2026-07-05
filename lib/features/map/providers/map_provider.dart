import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/gps_tracking_service.dart';
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

/// Záznamy s fotkami pre aktuálny deň — reaktívne sleduje DB zmeny.
final photoEntryMarkersProvider = StreamProvider<List<LogbookEntry>>((ref) {
  final isTracking = ref.watch(isTrackingProvider);
  if (!isTracking) return Stream.value([]);
  final dayLogId = GpsTrackingService().activeDayLogId;
  if (dayLogId == null) return Stream.value([]);
  return ref.read(databaseProvider).watchPhotoEntriesForDay(dayLogId);
});

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() => const MapState();

  void toggleFollowGps() =>
      state = state.copyWith(followGps: !state.followGps);

  void setFollowGps(bool v) => state = state.copyWith(followGps: v);

  void toggleSeamarks() =>
      state = state.copyWith(showSeamarks: !state.showSeamarks);

  /// Zobraz trasu vybraného dňa namiesto aktuálnej živej trasy.
  void previewDay(int dayLogId, String label) => state = MapState(
        showSeamarks: state.showSeamarks,
        followGps: state.followGps,
        previewDayLogId: dayLogId,
        previewLabel: label,
      );

  /// Zobraz spojenú trasu celej plavby (všetky dni).
  void previewCharter(int charterId, String label) => state = MapState(
        showSeamarks: state.showSeamarks,
        followGps: state.followGps,
        previewCharterId: charterId,
        previewLabel: label,
      );

  /// Vráť sa k živej trase aktuálneho trackingu.
  void clearPreview() => state = MapState(
        showSeamarks: state.showSeamarks,
        followGps: state.followGps,
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
}

class MapState {
  final bool showSeamarks;
  final bool followGps;
  /// Ak nastavené, mapa zobrazuje trasu tohto dňa namiesto živého trackingu.
  final int? previewDayLogId;
  /// Ak nastavené, mapa zobrazuje spojenú trasu celej tejto plavby.
  /// Vzájomne sa vylučuje s [previewDayLogId].
  final int? previewCharterId;
  final String? previewLabel;
  const MapState({
    this.showSeamarks = true,
    this.followGps = true,
    this.previewDayLogId,
    this.previewCharterId,
    this.previewLabel,
  });
  MapState copyWith({
    bool? showSeamarks,
    bool? followGps,
    int? previewDayLogId,
    int? previewCharterId,
    String? previewLabel,
  }) => MapState(
        showSeamarks: showSeamarks ?? this.showSeamarks,
        followGps: followGps ?? this.followGps,
        previewDayLogId: previewDayLogId ?? this.previewDayLogId,
        previewCharterId: previewCharterId ?? this.previewCharterId,
        previewLabel: previewLabel ?? this.previewLabel,
      );
}

final mapNotifierProvider =
    NotifierProvider<MapNotifier, MapState>(MapNotifier.new);
