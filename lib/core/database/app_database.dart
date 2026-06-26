import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────────────────
// TABLES
// ─────────────────────────────────────────────────────────────

/// Celý charter (napr. "Plavba 2–9. máj 2026")
class Charters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();                    // "Plavba máj 2026"
  DateTimeColumn get dateFrom => dateTime()();
  DateTimeColumn get dateTo => dateTime()();
  TextColumn get vesselName => text().nullable()();    // názov lode
  TextColumn get vesselType => text().nullable()();    // Plachetnica / Katamaran...
  TextColumn get homePort => text().nullable()();      // domovský prístav
  TextColumn get skipperName => text().nullable()();
  TextColumn get crewNames => text().nullable()();     // pipe-separated
  TextColumn get notes => text().nullable()();
  BoolColumn get safetyBriefingDone => boolean().withDefault(const Constant(false))();
  BoolColumn get checkInDone => boolean().withDefault(const Constant(false))();
  BoolColumn get checkOutDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get remoteId => text().nullable()();       // UUID na serveri
  DateTimeColumn get syncedAt => dateTime().nullable()(); // posledná úspešná sync
}

/// Jeden deň plavby
class DayLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get charterId => integer().references(Charters, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get portFrom => text().nullable()();     // prístav odchodu
  TextColumn get portTo => text().nullable()();       // prístav príchodu
  TextColumn get vesselForDay => text().nullable()(); // loď/čln pre tento deň
  RealColumn get distanceNm => real().withDefault(const Constant(0.0))();
  // Počasie ráno/poludnie/večer (Beaufort)
  IntColumn get beaufortMorning => integer().nullable()();
  IntColumn get beaufortNoon => integer().nullable()();
  IntColumn get beaufortEvening => integer().nullable()();
  // More
  TextColumn get seaState => text().nullable()();     // "pokojné/mierne/rozbúrené"
  RealColumn get waveHeightM => real().nullable()();
  // Vítor
  TextColumn get windDirection => text().nullable()(); // "NE", "SW"...
  // Teploty
  RealColumn get airTempC => real().nullable()();
  RealColumn get waterTempC => real().nullable()();
  // GPS session
  TextColumn get sessionId => text().nullable()();    // link na GPS tracking
  // Správa dňa
  TextColumn get skipperNote => text().nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
}

/// Hodinový záznam počas dňa
class LogbookEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayLogId => integer().nullable().references(DayLogs, #id)();
  TextColumn get sessionId => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get sog => real().nullable()();          // Speed Over Ground (kn)
  RealColumn get cog => real().nullable()();          // Course Over Ground (°)
  RealColumn get heading => real().nullable()();
  RealColumn get windSpeed => real().nullable()();    // kn
  RealColumn get windDirection => real().nullable()();
  RealColumn get waveHeight => real().nullable()();
  RealColumn get airPressure => real().nullable()();
  RealColumn get airTemp => real().nullable()();
  RealColumn get waterTemp => real().nullable()();
  RealColumn get engineHours => real().nullable()();
  RealColumn get fuelConsumed => real().nullable()();
  TextColumn get skipperName => text().nullable()();
  TextColumn get crewNames => text().nullable()();
  TextColumn get skipperNote => text().nullable()();
  BoolColumn get isAutoEntry => boolean().withDefault(const Constant(false))();
  TextColumn get weatherCondition => text().nullable()();
  TextColumn get photoPath => text().nullable()();
}

/// GPS track pointy
class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get speed => real().nullable()();
  RealColumn get course => real().nullable()();
  RealColumn get accuracy => real().nullable()();
}

/// GPS session (jedna plavba/deň)
class SailingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().unique()();
  IntColumn get dayLogId => integer().nullable().references(DayLogs, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get name => text().nullable()();
  RealColumn get totalDistanceNm => real().withDefault(const Constant(0.0))();
  RealColumn get maxSpeedKnots => real().withDefault(const Constant(0.0))();
  RealColumn get avgSpeedKnots => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// Waypoints
class Waypoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

/// Počasie cache
class WeatherSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get forecastTime => dateTime()();
  DateTimeColumn get downloadedAt => dateTime()();
  RealColumn get windSpeed => real()();
  RealColumn get windDirection => real()();
  RealColumn get waveHeight => real().nullable()();
  RealColumn get wavePeriod => real().nullable()();
  RealColumn get airPressure => real().nullable()();
  RealColumn get airTemp => real().nullable()();
  RealColumn get waterTemp => real().nullable()();
  RealColumn get cloudCover => real().nullable()();
  IntColumn get weatherCode => integer().nullable()();
  IntColumn get precipitationProbability => integer().nullable()();  // 0–100 %
  RealColumn get precipitation => real().nullable()();               // mm
}

// ─────────────────────────────────────────────────────────────
// DATABASE
// ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Charters, DayLogs, LogbookEntries,
  TrackPoints, SailingSessions, Waypoints, WeatherSnapshots,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(logbookEntries, logbookEntries.weatherCondition);
        await m.addColumn(logbookEntries, logbookEntries.photoPath);
        await m.addColumn(weatherSnapshots, weatherSnapshots.weatherCode);
      }
      if (from < 3) {
        await m.addColumn(weatherSnapshots, weatherSnapshots.precipitationProbability);
        await m.addColumn(weatherSnapshots, weatherSnapshots.precipitation);
      }
      if (from < 4) {
        await m.addColumn(charters, charters.remoteId);
        await m.addColumn(charters, charters.syncedAt);
      }
    },
    beforeOpen: (details) async {},
  );

  // ── Charters ────────────────────────────────────────────────

  Future<List<Charter>> getAllCharters() =>
      (select(charters)..orderBy([(c) => OrderingTerm.desc(c.dateFrom)])).get();

  Future<Charter> insertCharter(ChartersCompanion c) async {
    final id = await into(charters).insert(c);
    return (select(charters)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateCharter(ChartersCompanion c) =>
      (update(charters)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> updateCharterSync(int id,
      {required String remoteId, required DateTime syncedAt}) =>
      (update(charters)..where((t) => t.id.equals(id))).write(
        ChartersCompanion(
          remoteId: Value(remoteId),
          syncedAt: Value(syncedAt),
        ),
      );

  Future<void> deleteCharter(int id) async {
    // Skontroluj či nemá aktívnu session
    final active = await getActiveSession();
    if (active != null) {
      // Skontroluj či aktívna session patrí k tomuto charteru
      final days = await getDayLogs(id);
      final dayIds = days.map((d) => d.id).toSet();
      if (active.dayLogId != null && dayIds.contains(active.dayLogId)) {
        throw Exception('Nemožno zmazať plavbu počas aktívneho trackingu');
      }
    }
    // Cascade: zmaž day logs a ich entries
    final days = await getDayLogs(id);
    for (final d in days) {
      await deleteDayLog(d.id);
    }
    await (delete(charters)..where((c) => c.id.equals(id))).go();
  }

  // ── Day Logs ─────────────────────────────────────────────────

  Future<List<DayLog>> getDayLogs(int charterId) =>
      (select(dayLogs)
            ..where((d) => d.charterId.equals(charterId))
            ..orderBy([(d) => OrderingTerm(expression: d.date)]))
          .get();

  Future<DayLog> insertDayLog(DayLogsCompanion d) async {
    final id = await into(dayLogs).insert(d);
    return (select(dayLogs)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateDayLog(DayLogsCompanion d) =>
      (update(dayLogs)..where((t) => t.id.equals(d.id.value))).write(d);

  Future<void> deleteDayLog(int id) async {
    await (delete(logbookEntries)..where((e) => e.dayLogId.equals(id))).go();
    await (delete(sailingSessions)..where((s) => s.dayLogId.equals(id))).go();
    await (delete(dayLogs)..where((d) => d.id.equals(id))).go();
  }

  Future<void> deleteDayLogs(List<int> ids) async {
    for (final id in ids) { await deleteDayLog(id); }
  }

  Future<int?> getLatestDayLogId() async {
    final rows = await (select(dayLogs)
          ..orderBy([(d) => OrderingTerm.desc(d.date)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first.id;
  }

  // ── Logbook Entries ──────────────────────────────────────────

  Future<List<LogbookEntry>> getEntriesForDay(int dayLogId) =>
      (select(logbookEntries)
            ..where((e) => e.dayLogId.equals(dayLogId))
            ..orderBy([(e) => OrderingTerm(expression: e.timestamp)]))
          .get();

  Stream<List<LogbookEntry>> watchEntriesForDay(int dayLogId) =>
      (select(logbookEntries)
            ..where((e) => e.dayLogId.equals(dayLogId))
            ..orderBy([(e) => OrderingTerm(expression: e.timestamp)]))
          .watch();

  Future<List<LogbookEntry>> getEntriesForSession(String sessionId) =>
      (select(logbookEntries)
            ..where((e) => e.sessionId.equals(sessionId))
            ..orderBy([(e) => OrderingTerm(expression: e.timestamp)]))
          .get();

  Future<int> insertLogbookEntry(LogbookEntriesCompanion e) =>
      into(logbookEntries).insert(e);

  Future<void> updateLogbookEntry(int id, LogbookEntriesCompanion entry) =>
      (update(logbookEntries)..where((e) => e.id.equals(id))).write(entry);

  Future<void> deleteLogbookEntry(int id) =>
      (delete(logbookEntries)..where((e) => e.id.equals(id))).go();

  Future<void> deleteLogbookEntries(List<int> ids) async {
    for (final id in ids) { await deleteLogbookEntry(id); }
  }

  Future<void> deleteEntriesForDay(int dayLogId) =>
      (delete(logbookEntries)..where((e) => e.dayLogId.equals(dayLogId))).go();

  // ── Track Points ─────────────────────────────────────────────

  Future<int> insertTrackPoint(TrackPointsCompanion e) =>
      into(trackPoints).insert(e);

  Future<List<TrackPoint>> getTrackPointsForSession(String sessionId) =>
      (select(trackPoints)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
          .get();

  // ── Sessions ─────────────────────────────────────────────────

  Future<int> upsertSession(SailingSessionsCompanion s) =>
      into(sailingSessions).insertOnConflictUpdate(s);

  Future<SailingSession?> getActiveSession() =>
      (select(sailingSessions)
            ..where((s) => s.isActive.equals(true))
            ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<SailingSession>> getSessionsForDay(int dayLogId) =>
      (select(sailingSessions)..where((s) => s.dayLogId.equals(dayLogId))).get();

  Future<void> fixOrphanedSessions() async {
    final active = await (select(sailingSessions)
          ..where((s) => s.isActive.equals(true))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .get();
    if (active.length > 1) {
      for (final s in active.skip(1)) {
        await (update(sailingSessions)..where((r) => r.id.equals(s.id)))
            .write(SailingSessionsCompanion(
          isActive: const Value(false),
          endTime: Value(s.startTime.add(const Duration(minutes: 1))),
        ));
      }
      print('[DB] Fixed ${active.length - 1} orphaned sessions');
    }
  }

  // ── Waypoints ─────────────────────────────────────────────────

  Future<List<Waypoint>> getAllWaypoints() =>
      (select(waypoints)..orderBy([(w) => OrderingTerm(expression: w.name)])).get();

  Future<int> insertWaypoint(WaypointsCompanion e) =>
      into(waypoints).insert(e);

  Future<void> deleteWaypoint(int id) =>
      (delete(waypoints)..where((w) => w.id.equals(id))).go();

  // ── Weather ───────────────────────────────────────────────────

  Future<int> insertWeatherSnapshot(WeatherSnapshotsCompanion e) =>
      into(weatherSnapshots).insert(e);

  Future<void> clearAllWeather() => delete(weatherSnapshots).go();

  Future<void> clearOldWeather() =>
      (delete(weatherSnapshots)
            ..where((w) => w.downloadedAt.isSmallerThanValue(
                DateTime.now().subtract(const Duration(hours: 72)))))
          .go();

  Future<List<WeatherSnapshot>> getWeatherSnapshots() =>
      (select(weatherSnapshots)
            ..orderBy([(w) => OrderingTerm(expression: w.forecastTime)]))
          .get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sailing_logbook.db'));
    return NativeDatabase.createInBackground(file);
  });
}
