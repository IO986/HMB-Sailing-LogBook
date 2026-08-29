import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

/// The anchor watch records track points so the GPX does not have a hole over
/// the night the boat lay at anchor. Those points must never reach the miles:
/// swinging on the chain is not a passage, and it happens after dark, so a
/// leak would inflate both the distance and the night hours on the one
/// document a skipper hands over as proof.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<int> makeDayLog() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 8, 27),
      dateTo: DateTime(2026, 8, 28),
      createdAt: DateTime(2026, 8, 27),
    ));
    final d = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 8, 27),
    ));
    return d.id;
  }

  Future<void> makeSession(String id, int dayLogId,
      {required bool anchorWatch, bool active = false}) async {
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: id,
      startTime: DateTime.utc(2026, 8, 27, 17),
      dayLogId: Value(dayLogId),
      isActive: Value(active),
      isAnchorWatch: Value(anchorWatch),
    ));
  }

  /// Two points a minute apart, roughly 200 m of movement — enough that a leak
  /// into the mileage would be visible.
  Future<void> addPoints(String sessionId, int hourUtc) async {
    await db.insertTrackPoint(TrackPointsCompanion.insert(
      sessionId: Value(sessionId),
      timestamp: DateTime.utc(2026, 8, 27, hourUtc, 0),
      latitude: 43.7490,
      longitude: 15.7570,
    ));
    await db.insertTrackPoint(TrackPointsCompanion.insert(
      sessionId: Value(sessionId),
      timestamp: DateTime.utc(2026, 8, 27, hourUtc, 1),
      latitude: 43.7508,
      longitude: 15.7570,
    ));
  }

  test('a day lists only its voyage sessions unless asked otherwise', () async {
    final day = await makeDayLog();
    await makeSession('voyage', day, anchorWatch: false);
    await makeSession('anchor', day, anchorWatch: true);

    expect((await db.getSessionsForDay(day)).map((s) => s.sessionId),
        ['voyage']);
    expect(
        (await db.getSessionsForDay(day, includeAnchorWatch: true))
            .map((s) => s.sessionId)
            .toSet(),
        {'voyage', 'anchor'});
  });

  test('swinging at anchor is not distance sailed', () async {
    final day = await makeDayLog();
    await makeSession('voyage', day, anchorWatch: false);
    await makeSession('anchor', day, anchorWatch: true);
    await addPoints('voyage', 10);
    await addPoints('anchor', 22);

    final withAnchor = await db.recordedDistanceNmForDay(day);
    // Only the voyage leg counts; the anchor leg is the same length, so a
    // leak would double the number.
    expect(withAnchor, greaterThan(0));
    expect(withAnchor, lessThan(0.2));

    final voyageOnly =
        await db.recordedDistanceNmForDay(day, excludeSessionId: 'voyage');
    expect(voyageOnly, 0, reason: 'nothing but the anchor watch is left');
  });

  test('a night at anchor is not night sailing', () async {
    final day = await makeDayLog();
    await makeSession('anchor', day, anchorWatch: true);
    // 22:00 and 22:01 UTC in the Adriatic — well after sunset.
    await addPoints('anchor', 22);

    expect(await db.nightHoursForDay(day), 0);
  });

  test('the anchor watch is not a voyage the app should resume', () async {
    final day = await makeDayLog();
    await makeSession('anchor', day, anchorWatch: true, active: true);

    // Both of these drive tracking. An anchor watch answering either one would
    // make the app write logbook entries under a session that is not a voyage,
    // or offer to "resume the interrupted voyage" the morning after.
    expect(await db.getActiveSession(), isNull);
    expect(await db.getInterruptedSession(), isNull);
    expect((await db.getActiveAnchorWatchSession())?.sessionId, 'anchor');
  });

  test('closing the watch stamps an end so nothing looks interrupted', () async {
    final day = await makeDayLog();
    await makeSession('anchor', day, anchorWatch: true, active: true);

    await db.closeSession('anchor', endTime: DateTime.utc(2026, 8, 28, 7));

    final stored = (await db.getSessionsForDay(day, includeAnchorWatch: true))
        .firstWhere((s) => s.sessionId == 'anchor');
    expect(stored.isActive, isFalse);
    // .toUtc() is not redundant: drift hands the row back flagged local.
    expect(stored.endTime?.toUtc(), DateTime.utc(2026, 8, 28, 7));
  });
}
