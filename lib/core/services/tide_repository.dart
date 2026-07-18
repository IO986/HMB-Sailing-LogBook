import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/tide_data.dart';
import 'tide_forecast_service.dart';

/// Výsledok pokusu o stiahnutie predpovede — volajúci potrebuje rozlíšiť
/// "nepodarilo sa spojiť" od "toto miesto proste prílivy nemá", inak by
/// jachtár vo vnútrozemí donekonečna klikal na obnoviť.
enum TideSyncResult {
  /// Nová predpoveď je stiahnutá a uložená.
  updated,

  /// Miesto nemá morské pokrytie (vnútrozemie). Stará keš zostáva.
  noCoverage,

  /// Fetch zlyhal (offline, výpadok API). Stará keš zostáva použiteľná.
  failed,
}

class TideRepository {
  static final TideRepository _i = TideRepository._();
  factory TideRepository() => _i;
  TideRepository._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  TideForecastService _forecast = TideForecastService();

  @visibleForTesting
  void setForecastService(TideForecastService service) => _forecast = service;

  /// [locationLabel] a [manualSelection] sa vyplnia, keď si oblasť zvolil
  /// používateľ (napr. plánuje plavbu z domu ďaleko od mora).
  Future<TideSyncResult> syncTides({
    required double lat,
    required double lon,
    String? locationLabel,
    bool manualSelection = false,
  }) async {
    final db = _db;
    if (db == null) return TideSyncResult.failed;

    // Fetch ide vždy PRED zápisom. Keš sa nahradí až keď sú nové dáta v ruke,
    // takže obnovenie bez signálu nechá pôvodnú predpoveď nedotknutú.
    final List<TidePoint> points;
    try {
      points = await _forecast.fetchTides(lat: lat, lon: lon);
    } catch (_) {
      return TideSyncResult.failed;
    }

    if (points.isEmpty) return TideSyncResult.noCoverage;

    final now = DateTime.now();
    await db.replaceTides([
      for (final p in points)
        TideSnapshotsCompanion.insert(
          latitude: lat,
          longitude: lon,
          time: p.time,
          downloadedAt: now,
          heightM: p.heightM,
          extremeType: drift.Value(p.extremeType),
          locationLabel: drift.Value(locationLabel),
          manualSelection: drift.Value(manualSelection),
        ),
    ]);

    return TideSyncResult.updated;
  }
}
