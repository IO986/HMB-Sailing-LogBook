import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';
import 'package:hmb_sailing_log/features/gpx_import/services/gpx_importer.dart';
import 'package:hmb_sailing_log/features/gpx_import/services/gpx_voyage_reconstructor.dart';
import 'package:hmb_sailing_log/features/logbook/services/estimated_track_builder.dart';
import 'package:hmb_sailing_log/features/miles/services/miles_calculator.dart';

/// A voyage transcribed from paper has entries but no GPS. The line drawn
/// through them is for the map and for GPX; it must never feed night hours,
/// and the skipper's own figures from the paper must win over anything
/// computed.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<(int charterId, int dayId)> makeDay() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Z papiera',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 10),
      createdAt: DateTime(2026, 7, 10),
      source: const Value(CharterSource.paper),
    ));
    final d = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: c.id, date: DateTime(2026, 7, 10)));
    return (c.id, d.id);
  }

  Future<void> entry(int dayId, DateTime t, {double? lat, double? lon}) =>
      db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: Value(dayId),
        timestamp: t,
        latitude: Value(lat),
        longitude: Value(lon),
      ));

  group('rebuildForDay', () {
    test('draws one estimated session through the positioned entries',
        () async {
      final (_, dayId) = await makeDay();
      await entry(dayId, DateTime.utc(2026, 7, 10, 8), lat: 43.90, lon: 15.40);
      await entry(dayId, DateTime.utc(2026, 7, 10, 9)); // no position, skipped
      await entry(dayId, DateTime.utc(2026, 7, 10, 12), lat: 44.00, lon: 15.50);

      final r = await EstimatedTrackBuilder.rebuildForDay(db, dayId);

      expect(r.outcome, EstimatedTrackOutcome.built);
      expect(r.distanceNm, greaterThan(5));
      final session = (await db.getSessionsForDay(dayId)).single;
      expect(session.isEstimated, isTrue);
      expect(session.name, EstimatedTrackBuilder.sessionName);
      final points = await db.getTrackPointsForSession(session.sessionId);
      expect(points.length, 2);
    });

    test('running it again replaces the estimate instead of stacking',
        () async {
      final (_, dayId) = await makeDay();
      await entry(dayId, DateTime.utc(2026, 7, 10, 8), lat: 43.90, lon: 15.40);
      await entry(dayId, DateTime.utc(2026, 7, 10, 12), lat: 44.00, lon: 15.50);
      await EstimatedTrackBuilder.rebuildForDay(db, dayId);
      await entry(dayId, DateTime.utc(2026, 7, 10, 15), lat: 44.10, lon: 15.60);

      await EstimatedTrackBuilder.rebuildForDay(db, dayId);

      final session = (await db.getSessionsForDay(dayId)).single;
      expect(
          (await db.getTrackPointsForSession(session.sessionId)).length, 3);
    });

    test('needs two positions, and clears a stale estimate', () async {
      final (_, dayId) = await makeDay();
      await entry(dayId, DateTime.utc(2026, 7, 10, 8), lat: 43.90, lon: 15.40);
      expect((await EstimatedTrackBuilder.rebuildForDay(db, dayId)).outcome,
          EstimatedTrackOutcome.needsTwoEntries);
      expect(await db.getSessionsForDay(dayId), isEmpty);
    });

    test('never touches a measured track', () async {
      final (_, dayId) = await makeDay();
      await db.upsertSession(SailingSessionsCompanion.insert(
        sessionId: 'real',
        dayLogId: Value(dayId),
        startTime: DateTime.utc(2026, 7, 10, 7),
      ));
      await entry(dayId, DateTime.utc(2026, 7, 10, 8), lat: 43.90, lon: 15.40);
      await entry(dayId, DateTime.utc(2026, 7, 10, 12), lat: 44.00, lon: 15.50);

      final r = await EstimatedTrackBuilder.rebuildForDay(db, dayId);

      expect(r.outcome, EstimatedTrackOutcome.realTrackExists);
      final sessions = await db.getSessionsForDay(dayId);
      expect(sessions.single.sessionId, 'real');
    });

    test('a GPX imported afterwards replaces the estimate', () async {
      final (charterId, dayId) = await makeDay();
      await entry(dayId, DateTime(2026, 7, 10, 8), lat: 43.90, lon: 15.40);
      await entry(dayId, DateTime(2026, 7, 10, 12), lat: 44.00, lon: 15.50);
      await EstimatedTrackBuilder.rebuildForDay(db, dayId);

      await GpxVoyageReconstructor.addTracksToCharter(db, charterId, [
        GpxTrack(name: 'real', points: [
          GpxTrackPoint(lat: 43.9, lon: 15.4, time: DateTime(2026, 7, 10, 9)),
          GpxTrackPoint(lat: 43.95, lon: 15.45, time: DateTime(2026, 7, 10, 10)),
        ]),
      ]);

      final sessions = await db.getSessionsForDay(dayId);
      expect(sessions.single.isEstimated, isFalse);
      expect(sessions.single.name, 'real');
    });
  });

  group('night hours', () {
    // Local-time evening hours, but compared as UTC by the calculator; the
    // positions are in the Adriatic, so 22:00-22:20 UTC is well after sunset.
    Future<void> nightEntries(int dayId) async {
      await entry(dayId, DateTime.utc(2026, 7, 10, 22, 0), lat: 43.9, lon: 15.4);
      await entry(dayId, DateTime.utc(2026, 7, 10, 22, 20), lat: 43.95, lon: 15.45);
    }

    test('an estimated track is never counted as night', () async {
      final (_, dayId) = await makeDay();
      await nightEntries(dayId);
      await EstimatedTrackBuilder.rebuildForDay(db, dayId);

      expect(await db.nightHoursForDay(dayId), 0);
    });

    test('the figure from the paper wins over any computation', () async {
      final (_, dayId) = await makeDay();
      await nightEntries(dayId);
      await db.setDayFigures(dayId, distanceNm: 12.5, nightHours: 3.5);

      expect(await db.nightHoursForDay(dayId), 3.5);
      final day = (await db.getDayLogById(dayId))!;
      expect(day.distanceNm, 12.5);
    });

    test('clearing it hands the day back to the computation', () async {
      final (_, dayId) = await makeDay();
      await db.setDayFigures(dayId, distanceNm: 12.5, nightHours: 3.5);
      await db.setDayFigures(dayId, distanceNm: 12.5, nightHours: null);

      expect(await db.nightHoursForDay(dayId), 0);
      expect((await db.getDayLogById(dayId))!.nightHoursManual, equals(null));
    });

    test('the mile book takes the manual figure per day', () async {
      final (charterId, dayId) = await makeDay();
      await db.setDayFigures(dayId, distanceNm: 20, nightHours: 4);
      final charter = (await db.getCharterById(charterId))!;
      final day = (await db.getDayLogById(dayId))!;

      final agg = MilesCalculator.aggregate(
        charters: [charter],
        dayLogsByCharter: {charterId: [day]},
        trackPointsByDayLog: const {},
        historicalVoyages: const [],
      );

      expect(agg.totalNm, 20);
      expect(agg.nightHours, 4);
    });
  });
}
