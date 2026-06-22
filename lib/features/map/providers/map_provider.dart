import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../main.dart';

final waypointsProvider = FutureProvider<List<Waypoint>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllWaypoints();
});

final currentTrackProvider = Provider<List<LatLng>>((ref) => []);

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() => const MapState();

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
