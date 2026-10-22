import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';
import 'package:hmb_sailing_log/features/logbook/services/estimated_track_builder.dart';

/// `PRAGMA foreign_keys = ON`, so a delete that forgets a referencing table
/// does not fail a build; it throws on the phone.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  test('a transcribed voyage with everything attached can be deleted',
      () async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Z papiera',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 11),
      createdAt: DateTime(2026, 7, 10),
      source: const Value(CharterSource.paper),
    ));
    final d1 = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: c.id, date: DateTime(2026, 7, 10)));
    final d2 = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: c.id, date: DateTime(2026, 7, 11)));
    await db.setDayFigures(d1.id, distanceNm: 12, nightHours: 2);

    for (final d in [d1, d2]) {
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: Value(d.id),
        timestamp: DateTime.utc(2026, 7, 10, 8),
        latitude: const Value(43.9),
        longitude: const Value(15.4),
      ));
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: Value(d.id),
        timestamp: DateTime.utc(2026, 7, 10, 12),
        latitude: const Value(44.0),
        longitude: const Value(15.5),
      ));
      await EstimatedTrackBuilder.rebuildForDay(db, d.id);
    }

    await db.deleteCharter(c.id);

    expect(await db.getCharterById(c.id), equals(null));
    expect(await db.getDayLogs(c.id), isEmpty);
    expect(await db.getSessionsForDay(d1.id, includeAnchorWatch: true), isEmpty);
    // No orphaned track points left behind either.
    final left = await db.select(db.trackPoints).get();
    expect(left, isEmpty);
  });

  test('a manual historical voyage can be deleted', () async {
    final id = await db.into(db.historicalVoyages).insert(
          HistoricalVoyagesCompanion.insert(
            dateFrom: DateTime(2020, 7, 1),
            dateTo: DateTime(2020, 7, 8),
            vesselName: 'Stará loď',
            createdAt: DateTime(2026, 7, 1),
          ),
        );
    await db.deleteHistoricalVoyage(id);
    expect(await db.getAllHistoricalVoyages(), isEmpty);
  });
}
