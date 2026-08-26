import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

/// `lastSailDirectionForDay` is what makes the course stick between entries:
/// the skipper records a tack once and the automatic entries that follow keep
/// it. If it ever returned the wrong row, the logbook would quietly claim the
/// boat sailed a course nobody set.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<int> makeDayLog() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 8, 10),
      dateTo: DateTime(2026, 8, 14),
      createdAt: DateTime(2026, 8, 10),
    ));
    final d = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 8, 10),
    ));
    return d.id;
  }

  Future<void> addEntry(int dayLogId, DateTime ts,
      {String? pointOfSail, String? tack}) async {
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayLogId),
      timestamp: ts,
      pointOfSail: Value(pointOfSail),
      tack: Value(tack),
    ));
  }

  test('no entry with a course means nothing to carry over', () async {
    final day = await makeDayLog();
    await addEntry(day, DateTime.utc(2026, 8, 10, 9));

    expect(await db.lastSailDirectionForDay(day), isNull);
  });

  test('returns the newest recorded course, not the newest entry', () async {
    final day = await makeDayLog();
    await addEntry(day, DateTime.utc(2026, 8, 10, 9),
        pointOfSail: 'close_hauled', tack: 'P');
    await addEntry(day, DateTime.utc(2026, 8, 10, 11),
        pointOfSail: 'beam_reach', tack: 'S');
    // Automatic entry written after the tack, before the skipper set a course
    // again — it must not erase the last known one.
    await addEntry(day, DateTime.utc(2026, 8, 10, 12));

    final last = await db.lastSailDirectionForDay(day);
    expect(last?.pointOfSail, 'beam_reach');
    expect(last?.tack, 'S');
  });

  test('another day does not leak its course into this one', () async {
    final dayA = await makeDayLog();
    final dayB = await makeDayLog();
    await addEntry(dayA, DateTime.utc(2026, 8, 10, 9),
        pointOfSail: 'running');

    expect(await db.lastSailDirectionForDay(dayB), isNull);
    expect((await db.lastSailDirectionForDay(dayA))?.pointOfSail, 'running');
  });
}
