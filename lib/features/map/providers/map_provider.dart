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
  const MapState({this.showSeamarks = true, this.followGps = true});
  MapState copyWith({bool? showSeamarks, bool? followGps}) => MapState(
        showSeamarks: showSeamarks ?? this.showSeamarks,
        followGps: followGps ?? this.followGps,
      );
}

final mapNotifierProvider =
    NotifierProvider<MapNotifier, MapState>(MapNotifier.new);
