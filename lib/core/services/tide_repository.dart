import 'package:drift/drift.dart' as drift;
import 'tide_forecast_service.dart';
import '../database/app_database.dart';

class TideRepository {
  static final TideRepository _i = TideRepository._();
  factory TideRepository() => _i;
  TideRepository._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  final _forecast = TideForecastService();

  Future<void> syncTides({
    required double lat,
    required double lon,
    required String apiKey,
  }) async {
    final db = _db;
    if (db == null) return;
    await db.clearAllTides();

    final data = await _forecast.fetchTides(lat: lat, lon: lon, apiKey: apiKey);
    final now = DateTime.now();

    final heights = (data['heights'] as List?) ?? const [];
    for (final h in heights) {
      final map = h as Map<String, dynamic>;
      await db.insertTideSnapshot(TideSnapshotsCompanion.insert(
        latitude: lat, longitude: lon,
        time: DateTime.fromMillisecondsSinceEpoch((map['dt'] as int) * 1000, isUtc: true),
        downloadedAt: now,
        heightM: (map['height'] as num).toDouble(),
      ));
    }

    final extremes = (data['extremes'] as List?) ?? const [];
    for (final e in extremes) {
      final map = e as Map<String, dynamic>;
      final type = (map['type'] as String).toLowerCase(); // "High" / "Low"
      await db.insertTideSnapshot(TideSnapshotsCompanion.insert(
        latitude: lat, longitude: lon,
        time: DateTime.fromMillisecondsSinceEpoch((map['dt'] as int) * 1000, isUtc: true),
        downloadedAt: now,
        heightM: (map['height'] as num).toDouble(),
        extremeType: drift.Value(type),
      ));
    }
  }
}
