import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

/// Departure and arrival ports are filled by reverse geocoding at the moment
/// the voyage starts and ends — the two moments most likely to have no
/// internet on board, because the phone hangs on the instruments' WiFi, which
/// leads nowhere. The day then reads "? → ?" in the export forever.
///
/// firstFixForDay/lastFixForDay are what makes that recoverable: the positions
/// are in the database all along, so the names can be looked up later.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<int> makeDayLog() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 8, 31),
      dateTo: DateTime(2026, 8, 31),
      createdAt: DateTime(2026, 8, 31),
    ));
    final d = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 8, 31),
    ));
    return d.id;
  }

  Future<void> addSession(String id, int dayLogId,
      {bool anchorWatch = false}) async {
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: id,
      startTime: DateTime.utc(2026, 8, 31, 6),
      dayLogId: Value(dayLogId),
      isAnchorWatch: Value(anchorWatch),
    ));
  }

  Future<void> addPoint(String sessionId, int hourUtc, double lat, double lon) =>
      db.insertTrackPoint(TrackPointsCompanion.insert(
        sessionId: Value(sessionId),
        timestamp: DateTime.utc(2026, 8, 31, hourUtc),
        latitude: lat,
        longitude: lon,
      ));

  test('edges come from the whole day, across an interrupted voyage', () async {
    final dayId = await makeDayLog();
    // The real case: the app was restarted mid-voyage, so the day is two
    // separate legs. Komiža in the morning, Brač in the afternoon.
    await addSession('leg-1', dayId);
    await addSession('leg-2', dayId);
    await addPoint('leg-1', 7, 43.0445, 16.0868);
    await addPoint('leg-1', 9, 43.1000, 16.2000);
    await addPoint('leg-2', 11, 43.1400, 16.3000);
    await addPoint('leg-2', 13, 43.1607, 16.3611);

    final first = await db.firstFixForDay(dayId);
    final last = await db.lastFixForDay(dayId);
    expect(first!.lat, closeTo(43.0445, 0.0001));
    expect(last!.lon, closeTo(16.3611, 0.0001));
  });

  test('falls back to logbook positions when no track was recorded', () async {
    final dayId = await makeDayLog();
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayId),
      timestamp: DateTime.utc(2026, 8, 31, 8),
      latitude: const Value(43.0445),
      longitude: const Value(16.0868),
    ));
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayId),
      timestamp: DateTime.utc(2026, 8, 31, 14),
      latitude: const Value(43.1607),
      longitude: const Value(16.3611),
    ));

    final first = await db.firstFixForDay(dayId);
    final last = await db.lastFixForDay(dayId);
    expect(first!.lon, closeTo(16.0868, 0.0001));
    expect(last!.lat, closeTo(43.1607, 0.0001));
  });

  test('a day with nothing recorded has no edges', () async {
    final dayId = await makeDayLog();
    expect(await db.firstFixForDay(dayId), isNull);
    expect(await db.lastFixForDay(dayId), isNull);
  });
}
