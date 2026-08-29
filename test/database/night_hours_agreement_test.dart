import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/services/night_hours.dart';
import 'package:hmb_sailing_log/features/miles/services/miles_calculator.dart';

/// The logbook PDF and the mile certificate are two documents about the same
/// night. They are handed to different people — a charter company and a
/// national authority — so they must never carry two different numbers.
///
/// They did: the PDF counted a gap of up to two hours as sailed time while
/// the miles book capped it at thirty minutes, so one imported voyage came
/// out as 1.7 night hours in the export and 0.9 in the miles book. Both now
/// go through NightHours; this test is what keeps them there.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<int> makeDay() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Import',
      dateFrom: DateTime(2026, 8, 27),
      dateTo: DateTime(2026, 8, 28),
      createdAt: DateTime(2026, 8, 27),
    ));
    final d = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 8, 27),
    ));
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 'imported',
      startTime: DateTime.utc(2026, 8, 27, 19),
      dayLogId: Value(d.id),
      isActive: const Value(false),
    ));
    return d.id;
  }

  Future<void> point(DateTime whenUtc, double lat) =>
      db.insertTrackPoint(TrackPointsCompanion.insert(
        sessionId: const Value('imported'),
        timestamp: whenUtc,
        latitude: lat,
        longitude: 15.7570,
      ));

  /// The miles book's own path, through the same points the PDF would see.
  Future<double> milesBookNightHours(int dayLogId) async {
    final points = <TrackPoint>[];
    for (final s in await db.getSessionsForDay(dayLogId)) {
      points.addAll(await db.getTrackPointsForSession(s.sessionId));
    }
    return MilesCalculator.nightHoursForPoints(points);
  }

  test('a sparse imported track gives one answer, not two', () async {
    final day = await makeDay();
    // An imported GPX with coarse sampling: twenty minutes between fixes,
    // then a 45-minute hole where the other device stopped logging.
    var lat = 43.7400;
    for (final t in [
      DateTime.utc(2026, 8, 27, 21, 0),
      DateTime.utc(2026, 8, 27, 21, 20),
      DateTime.utc(2026, 8, 27, 21, 40),
      // hole
      DateTime.utc(2026, 8, 27, 22, 25),
      DateTime.utc(2026, 8, 27, 22, 45),
    ]) {
      await point(t, lat);
      lat += 0.002;
    }

    final fromLogbook = await db.nightHoursForDay(day);
    final fromMilesBook = await milesBookNightHours(day);

    expect(fromLogbook, closeTo(fromMilesBook, 1e-9),
        reason: 'the export and the certificate disagree about the same night');
    // 20 + 20 + 20 minutes counted, the 45-minute hole dropped.
    expect(fromLogbook, closeTo(1.0, 0.001));
  });

  test('a day with no track claims no night hours at all', () async {
    final day = await makeDay();
    // Entries exist, but no track. Guessing night hours from hourly entries
    // would print a number the miles book reports as zero.
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(day),
      timestamp: DateTime.utc(2026, 8, 27, 21),
      latitude: const Value(43.74),
      longitude: const Value(15.75),
    ));
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(day),
      timestamp: DateTime.utc(2026, 8, 27, 22),
      latitude: const Value(43.75),
      longitude: const Value(15.75),
    ));

    expect(await db.nightHoursForDay(day), 0);
    expect(await milesBookNightHours(day), 0);
  });

  test('the cap itself has exactly one home', () {
    expect(NightHours.maxGap, const Duration(minutes: 30));
  });
}
