import '../database/app_database.dart';
import '../models/tide_data.dart';

class TideService {
  static final TideService _i = TideService._();
  factory TideService() => _i;
  TideService._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  Future<List<TidePoint>> getForecast() async {
    if (_db == null) return [];
    final snaps = await _db!.getTideSnapshots();
    return snaps
        .map((e) => TidePoint(
              time: e.time,
              heightM: e.heightM,
              extremeType: e.extremeType,
            ))
        .toList();
  }

  /// Najbližší nadchádzajúci príliv/odliv (extrém), alebo null bez dát.
  Future<TidePoint?> getNextExtreme() async {
    final points = await getForecast();
    final now = DateTime.now().toUtc();
    final future = points
        .where((p) => p.extremeType != null && p.time.isAfter(now))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return future.isEmpty ? null : future.first;
  }
}
