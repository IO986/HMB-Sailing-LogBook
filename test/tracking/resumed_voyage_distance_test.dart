import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/export/services/export_service.dart';

/// A voyage that gets interrupted — the app is killed mid-track and the user
/// taps Start → Continue — used to come out with only the second leg counted:
/// the running total lived in memory and was written to the day log by
/// stopTracking() alone, which a kill never reaches. The distance is therefore
/// derived from the stored track points, which do survive.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<int> makeDay() async {
    final charter = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 8, 8),
      dateTo: DateTime(2026, 8, 8),
      createdAt: DateTime(2026, 8, 8),
    ));
    final day = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: charter.id,
      date: DateTime(2026, 8, 8),
    ));
    return day.id;
  }

  /// One leg: [count] points, each [stepDeg] of latitude further north.
  Future<String> addLeg(
    int dayLogId,
    String sessionId, {
    required double startLat,
    required int count,
    double stepDeg = 0.01,
    DateTime? start,
  }) async {
    final t0 = start ?? DateTime.utc(2026, 8, 8, 9);
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: sessionId,
      startTime: t0,
      dayLogId: Value(dayLogId),
    ));
    for (var i = 0; i < count; i++) {
      await db.insertTrackPoint(TrackPointsCompanion.insert(
        sessionId: Value(sessionId),
        timestamp: t0.add(Duration(minutes: i)),
        latitude: startLat + i * stepDeg,
        longitude: 17.0,
      ));
    }
    return sessionId;
  }

  test('a resumed voyage keeps the distance of the earlier leg', () async {
    final dayLogId = await makeDay();
    // 10 legs of 0.01° latitude ≈ 0.6 NM each.
    await addLeg(dayLogId, 'leg-1', startLat: 48.0, count: 11);

    final beforeResume = await db.recordedDistanceNmForDay(dayLogId);
    expect(beforeResume, closeTo(6.0, 0.1));

    // The app is killed here: stopTracking never runs, so the day log still
    // holds whatever it held before.
    expect((await db.getDayLogById(dayLogId))!.distanceNm, 0);

    // Start → Continue creates a fresh session for the same day; the baseline
    // must come from the points already recorded, not from the day log.
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 'leg-2',
      startTime: DateTime.utc(2026, 8, 8, 11),
      dayLogId: Value(dayLogId),
    ));
    final baseline = await db.recordedDistanceNmForDay(dayLogId,
        excludeSessionId: 'leg-2');
    expect(baseline, closeTo(6.0, 0.1),
        reason: 'the interrupted leg still counts');
  });

  test('both legs together make up the day total', () async {
    final dayLogId = await makeDay();
    await addLeg(dayLogId, 'leg-1', startLat: 48.0, count: 11);
    await addLeg(dayLogId, 'leg-2',
        startLat: 48.2,
        count: 6,
        start: DateTime.utc(2026, 8, 8, 11));

    expect(await db.recordedDistanceNmForDay(dayLogId), closeTo(9.0, 0.2));
  });

  test('a GPS jump between two points is ignored, as it is when live',
      () async {
    final dayLogId = await makeDay();
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 'jumpy',
      startTime: DateTime.utc(2026, 8, 8, 9),
      dayLogId: Value(dayLogId),
    ));
    for (final (i, lat) in [48.0, 48.01, 60.0, 60.01].indexed) {
      await db.insertTrackPoint(TrackPointsCompanion.insert(
        sessionId: const Value('jumpy'),
        timestamp: DateTime.utc(2026, 8, 8, 9).add(Duration(minutes: i)),
        latitude: lat,
        longitude: 17.0,
      ));
    }

    // 0.6 + (skipped 700 NM jump) + 0.6
    expect(await db.recordedDistanceNmForDay(dayLogId), closeTo(1.2, 0.1));
  });

  test('sessions of other days do not leak in', () async {
    final dayOne = await makeDay();
    final dayTwo = await makeDay();
    await addLeg(dayOne, 'day-one', startLat: 48.0, count: 11);
    await addLeg(dayTwo, 'day-two', startLat: 45.0, count: 21);

    expect(await db.recordedDistanceNmForDay(dayOne), closeTo(6.0, 0.1));
    expect(await db.recordedDistanceNmForDay(dayTwo), closeTo(12.0, 0.2));
  });

  test('a day with no track has no distance', () async {
    expect(await db.recordedDistanceNmForDay(await makeDay()), 0);
  });

  group('an interrupted session', () {
    test('is the one without an endTime - a stopped one is not', () async {
      final dayLogId = await makeDay();
      await addLeg(dayLogId, 'killed', startLat: 48.0, count: 5);

      final found = await db.getInterruptedSession();
      expect(found?.sessionId, 'killed');

      // stopTracking() writes endTime; after that it is no longer a candidate.
      await db.closeInterruptedSession(found!);
      expect(await db.getInterruptedSession(), isNull);
    });

    test('is closed at its last point, not a minute after it started',
        () async {
      final dayLogId = await makeDay();
      final start = DateTime.utc(2026, 8, 8, 9);
      await addLeg(dayLogId, 'killed',
          startLat: 48.0, count: 20, start: start);

      await db.closeInterruptedSession((await db.getInterruptedSession())!);

      final closed = (await db.getSessionsForDay(dayLogId)).single;
      expect(closed.isActive, isFalse);
      // 20 points, one a minute apart.
      // Drift hands times back in local time, so compare instants.
      expect(closed.endTime!.isAtSameMomentAs(
          start.add(const Duration(minutes: 19))), isTrue);
    });

    test('with no points at all falls back to its start time', () async {
      final dayLogId = await makeDay();
      final start = DateTime.utc(2026, 8, 8, 9);
      await db.upsertSession(SailingSessionsCompanion.insert(
        sessionId: 'empty',
        startTime: start,
        dayLogId: Value(dayLogId),
      ));

      await db.closeInterruptedSession((await db.getInterruptedSession())!);
      expect((await db.getSessionsForDay(dayLogId)).single.endTime!
          .isAtSameMomentAs(start), isTrue);
    });

    test('fixOrphanedSessions keeps the newest and closes the rest properly',
        () async {
      final dayLogId = await makeDay();
      await addLeg(dayLogId, 'older',
          startLat: 48.0, count: 5, start: DateTime.utc(2026, 8, 8, 9));
      await addLeg(dayLogId, 'newer',
          startLat: 48.2, count: 5, start: DateTime.utc(2026, 8, 8, 14));

      await db.fixOrphanedSessions();

      final byId = {
        for (final s in await db.getSessionsForDay(dayLogId)) s.sessionId: s
      };
      expect(byId['newer']!.isActive, isTrue);
      expect(byId['older']!.isActive, isFalse);
      expect(byId['older']!.endTime!
          .isAtSameMomentAs(DateTime.utc(2026, 8, 8, 9, 4)), isTrue,
          reason: 'the last point, not start + 1 min');
    });
  });

  group('GPX file names', () {
    test('a single leg keeps the plain name', () {
      expect(ExportService.gpxDocName('Plavba 8.8.2026', 1, 1),
          'Plavba 8.8.2026');
    });

    test('an interrupted day gets one file per leg, not one name twice', () {
      final names = [
        ExportService.gpxDocName('Plavba 8.8.2026', 1, 2),
        ExportService.gpxDocName('Plavba 8.8.2026', 2, 2),
      ];
      expect(names.toSet(), hasLength(2), reason: 'the legs must not collide');
      for (final n in names) {
        expect(n, contains('Plavba 8.8.2026'));
      }
    });
  });
}
