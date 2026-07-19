// Narrow import: drift also exports an `isNull`, which would clash with the
// matcher of the same name.
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

/// DAO behaviour for duty periods, plus the two delete paths that had to
/// change when the table arrived.
///
/// Those deletes matter most: `PRAGMA foreign_keys = ON` is set in beforeOpen,
/// so getting them wrong does not fail a build — it throws at runtime inside
/// screens that already shipped.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<int> makeCharter() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 14),
      createdAt: DateTime(2026, 7, 10),
    ));
    return c.id;
  }

  Future<int> makeDayLog(int charterId) async {
    final d = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: charterId,
      date: DateTime(2026, 7, 10),
    ));
    return d.id;
  }

  Future<int> startDuty(int charterId, String name,
      {int? dayLogId, DateTime? from, DateTime? to}) {
    return db.insertDutyPeriod(DutyPeriodsCompanion.insert(
      charterId: charterId,
      dayLogId: Value(dayLogId),
      crewName: name,
      fromUtc: from ?? DateTime.utc(2026, 7, 10, 9),
      toUtc: Value(to),
      createdAt: DateTime(2026, 7, 10),
    ));
  }

  group('running duties', () {
    test('a duty with no end is running; closing it takes it off the list',
        () async {
      final charter = await makeCharter();
      final id = await startDuty(charter, 'Ján');

      expect(await db.getRunningDuties(charter), hasLength(1));

      await db.closeDutyPeriod(id, DateTime.utc(2026, 7, 10, 13));
      expect(await db.getRunningDuties(charter), isEmpty);
    });

    test('two people starting together are two rows, closed independently',
        () async {
      final charter = await makeCharter();
      final from = DateTime.utc(2026, 7, 10, 9);
      final janId = await startDuty(charter, 'Ján', from: from);
      await startDuty(charter, 'Peter', from: from);

      expect(await db.getRunningDuties(charter), hasLength(2));

      await db.closeDutyPeriod(janId, DateTime.utc(2026, 7, 10, 13));
      final stillRunning = await db.getRunningDuties(charter);
      expect(stillRunning, hasLength(1));
      expect(stillRunning.single.crewName, 'Peter');
    });

    test('closeAllRunningDuties touches only its own charter', () async {
      final a = await makeCharter();
      final b = await makeCharter();
      await startDuty(a, 'Ján');
      await startDuty(b, 'Peter');

      await db.closeAllRunningDuties(a, DateTime.utc(2026, 7, 10, 18));

      expect(await db.getRunningDuties(a), isEmpty);
      expect(await db.getRunningDuties(b), hasLength(1));
    });

    test('a duty closed by the system is marked as such', () async {
      final charter = await makeCharter();
      await startDuty(charter, 'Ján');

      await db.closeAllRunningDuties(charter, DateTime.utc(2026, 7, 10, 18));

      final all = await db.watchDutiesForCharter(charter).first;
      expect(all.single.isAutoClosed, isTrue,
          reason: 'an end the skipper did not observe must be distinguishable');
    });
  });

  group('getDutiesOverlapping', () {
    test('a duty across midnight is returned for BOTH days', () async {
      final charter = await makeCharter();
      // 22:00 on the 10th until 02:00 on the 11th, UTC.
      await startDuty(charter, 'Ján',
          from: DateTime.utc(2026, 7, 10, 22), to: DateTime.utc(2026, 7, 11, 2));

      final day10 = await db.getDutiesOverlapping(
          charter, DateTime.utc(2026, 7, 10), DateTime.utc(2026, 7, 11));
      final day11 = await db.getDutiesOverlapping(
          charter, DateTime.utc(2026, 7, 11), DateTime.utc(2026, 7, 12));

      expect(day10, hasLength(1));
      expect(day11, hasLength(1));
    });

    test('a running duty is returned for any window after it began', () async {
      final charter = await makeCharter();
      await startDuty(charter, 'Ján', from: DateTime.utc(2026, 7, 10, 22));

      final later = await db.getDutiesOverlapping(
          charter, DateTime.utc(2026, 7, 12), DateTime.utc(2026, 7, 13));
      expect(later, hasLength(1));
    });

    test('a duty that ended before the window is not returned', () async {
      final charter = await makeCharter();
      await startDuty(charter, 'Ján',
          from: DateTime.utc(2026, 7, 9, 8), to: DateTime.utc(2026, 7, 9, 12));

      final day10 = await db.getDutiesOverlapping(
          charter, DateTime.utc(2026, 7, 10), DateTime.utc(2026, 7, 11));
      expect(day10, isEmpty);
    });

    test('a duty ending exactly at the window start does not overlap it',
        () async {
      // Half-open: a handover at midnight belongs to the earlier day only.
      final charter = await makeCharter();
      await startDuty(charter, 'Ján',
          from: DateTime.utc(2026, 7, 9, 20), to: DateTime.utc(2026, 7, 10));

      final day10 = await db.getDutiesOverlapping(
          charter, DateTime.utc(2026, 7, 10), DateTime.utc(2026, 7, 11));
      expect(day10, isEmpty);
    });
  });

  group('deletes', () {
    test('deleting a day log keeps its duties and nulls the link', () async {
      // A duty belongs to the charter. Deleting a day must not destroy
      // evidence of who was on watch.
      final charter = await makeCharter();
      final dayLog = await makeDayLog(charter);
      await startDuty(charter, 'Ján', dayLogId: dayLog);

      await db.deleteDayLog(dayLog);

      final remaining = await db.watchDutiesForCharter(charter).first;
      expect(remaining, hasLength(1));
      expect(remaining.single.dayLogId, isNull);
    });

    test('deleting a charter removes its duties without tripping the FK',
        () async {
      final charter = await makeCharter();
      final dayLog = await makeDayLog(charter);
      await startDuty(charter, 'Ján', dayLogId: dayLog);

      // Without deleteWatchPeriodsForCharter this throws once foreign keys
      // are enforced.
      await db.deleteCharter(charter);

      expect(await db.watchDutiesForCharter(charter).first, isEmpty);
    });

    test('foreign keys really are enforced in this test setup', () async {
      // Otherwise the two tests above would pass for the wrong reason.
      final result =
          await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(result.data.values.first, 1);
    });
  });

  group('edit', () {
    test('updateDutyPeriod can reopen a closed duty', () async {
      final charter = await makeCharter();
      final id = await startDuty(charter, 'Ján',
          from: DateTime.utc(2026, 7, 10, 9), to: DateTime.utc(2026, 7, 10, 13));

      await db.updateDutyPeriod(
          id, const DutyPeriodsCompanion(toUtc: Value(null)));

      expect(await db.getRunningDuties(charter), hasLength(1));
    });

    test('deleteDutyPeriod removes just that row', () async {
      final charter = await makeCharter();
      final id = await startDuty(charter, 'Ján');
      await startDuty(charter, 'Peter');

      await db.deleteDutyPeriod(id);

      final left = await db.watchDutiesForCharter(charter).first;
      expect(left.single.crewName, 'Peter');
    });
  });
}
