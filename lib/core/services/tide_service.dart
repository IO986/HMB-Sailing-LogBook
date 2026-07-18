import '../database/app_database.dart';
import '../models/tide_data.dart';

class TideService {
  static final TideService _i = TideService._();
  factory TideService() => _i;
  TideService._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  /// Kešovaná predpoveď aj s pôvodom (miesto + čas stiahnutia), aby volajúci
  /// vedel varovať pri starých alebo vzdialených dátach.
  Future<TideForecast> getForecast() async {
    final db = _db;
    if (db == null) return TideForecast.empty;

    final snaps = await db.getTideSnapshots();
    if (snaps.isEmpty) return TideForecast.empty;

    // Keš vždy patrí jednému miestu a jednému stiahnutiu (replaceTides ju
    // nahrádza celú), takže stačí prvý riadok.
    final origin = snaps.first;

    return TideForecast(
      points: [
        for (final e in snaps)
          TidePoint(
            time: e.time,
            heightM: e.heightM,
            extremeType: e.extremeType,
          ),
      ],
      latitude: origin.latitude,
      longitude: origin.longitude,
      downloadedAt: origin.downloadedAt,
      locationLabel: origin.locationLabel,
      manualSelection: origin.manualSelection,
    );
  }

  /// Najbližší nadchádzajúci príliv/odliv (extrém), alebo null bez dát.
  Future<TidePoint?> getNextExtreme() async {
    final forecast = await getForecast();
    return forecast.nextExtremeAfter(DateTime.now());
  }
}
