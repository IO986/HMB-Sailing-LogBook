import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';
import 'package:hmb_sailing_log/features/gpx_import/services/gpx_importer.dart';
import 'package:hmb_sailing_log/features/gpx_import/services/gpx_voyage_reconstructor.dart';

void main() {
  group('portsFromTrackName', () {
    test('reads the names this app writes on export', () {
      expect(
        GpxVoyageReconstructor.portsFromTrackName(
            'streda 8.7.: Biograd → Žut'),
        ('Biograd', 'Žut'),
      );
      expect(
        GpxVoyageReconstructor.portsFromTrackName('8.7.2026: Biograd → Biograd'),
        ('Biograd', 'Biograd'),
      );
    });

    test('a coordinate or ? side means no port was known', () {
      expect(
        GpxVoyageReconstructor.portsFromTrackName(
            '8.7.: 43.9370, 15.4410 → Žut'),
        (null, 'Žut'),
      );
      expect(GpxVoyageReconstructor.portsFromTrackName('8.7.: ? → ?'),
          (null, null));
    });

    test('names from other apps are not guessed at', () {
      expect(GpxVoyageReconstructor.portsFromTrackName('Morning sail'),
          (null, null));
      expect(GpxVoyageReconstructor.portsFromTrackName(null), (null, null));
      expect(GpxVoyageReconstructor.portsFromTrackName('a → b → c'),
          (null, null));
    });
  });

  group('addTracksToCharter', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    });
    tearDown(() async => db.close());

    Future<int> paperCharter({DateTime? from, DateTime? to}) async {
      final c = await db.insertCharter(ChartersCompanion.insert(
        title: 'Z papiera',
        dateFrom: from ?? DateTime(2026, 7, 10),
        dateTo: to ?? DateTime(2026, 7, 10),
        createdAt: DateTime(2026, 7, 10),
        source: const Value(CharterSource.paper),
      ));
      return c.id;
    }

    GpxTrackPoint pt(DateTime t, double lat, double lon) =>
        GpxTrackPoint(lat: lat, lon: lon, time: t);

    test('splits a multi-day track into one day each, with miles', () async {
      final id = await paperCharter();
      final track = GpxTrack(name: 'Biograd → Žut', points: [
        pt(DateTime(2026, 7, 10, 9), 43.90, 15.40),
        pt(DateTime(2026, 7, 10, 12), 43.95, 15.45),
        pt(DateTime(2026, 7, 11, 9), 43.95, 15.45),
        pt(DateTime(2026, 7, 11, 11), 44.00, 15.50),
      ]);

      final summary =
          await GpxVoyageReconstructor.addTracksToCharter(db, id, [track]);

      expect(summary.daysCreated, 2);
      final days = await db.getDayLogs(id);
      expect(days.map((d) => d.date.day), [10, 11]);
      for (final d in days) {
        expect(d.distanceNm, greaterThan(1));
        expect((await db.getSessionsForDay(d.id)).length, 1);
      }
    });

    test('extends a day typed in from paper and keeps its own figures',
        () async {
      final id = await paperCharter();
      final typed = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: id,
        date: DateTime(2026, 7, 10),
        distanceNm: const Value(12.5),
        portFrom: const Value('Marina Kornati'),
      ));

      final summary = await GpxVoyageReconstructor.addTracksToCharter(db, id, [
        GpxTrack(name: 'pondelok 10.7.: Biograd → Žut', points: [
          pt(DateTime(2026, 7, 10, 9), 43.90, 15.40),
          pt(DateTime(2026, 7, 10, 12), 43.95, 15.45),
        ]),
      ]);

      expect(summary.daysCreated, 0);
      expect(summary.daysExtended, 1);
      expect((await db.getDayLogs(id)).length, 1);
      final day = (await db.getDayLogById(typed.id))!;
      expect(day.distanceNm, 12.5); // the paper figure wins
      expect(day.portFrom, 'Marina Kornati'); // typed port wins
      expect(day.portTo, 'Žut'); // the missing one is filled in
    });

    test('importing the same file twice does not double the miles', () async {
      final id = await paperCharter();
      final tracks = [
        GpxTrack(name: 'Morning', points: [
          pt(DateTime(2026, 7, 10, 9), 43.90, 15.40),
          pt(DateTime(2026, 7, 10, 12), 43.95, 15.45),
        ]),
      ];
      await GpxVoyageReconstructor.addTracksToCharter(db, id, tracks);
      final again =
          await GpxVoyageReconstructor.addTracksToCharter(db, id, tracks);

      expect(again.duplicatesSkipped, 1);
      final day = (await db.getDayLogs(id)).single;
      expect((await db.getSessionsForDay(day.id)).length, 1);
    });

    test('points without a time are skipped and counted', () async {
      final id = await paperCharter();
      final summary = await GpxVoyageReconstructor.addTracksToCharter(db, id, [
        GpxTrack(name: 'x', points: [
          const GpxTrackPoint(lat: 43.9, lon: 15.4),
          pt(DateTime(2026, 7, 10, 9), 43.90, 15.40),
          pt(DateTime(2026, 7, 10, 10), 43.91, 15.41),
        ]),
      ]);
      expect(summary.untimedPointsSkipped, 1);
      expect(summary.daysCreated, 1);
    });

    test('widens the voyage dates to cover the imported days', () async {
      final id = await paperCharter(
          from: DateTime(2026, 7, 11), to: DateTime(2026, 7, 11));
      await GpxVoyageReconstructor.addTracksToCharter(db, id, [
        GpxTrack(name: 'x', points: [
          pt(DateTime(2026, 7, 9, 9), 43.90, 15.40),
          pt(DateTime(2026, 7, 9, 10), 43.91, 15.41),
          pt(DateTime(2026, 7, 13, 9), 43.90, 15.40),
          pt(DateTime(2026, 7, 13, 10), 43.91, 15.41),
        ]),
      ]);
      final c = (await db.getCharterById(id))!;
      expect(c.dateFrom.day, 9);
      expect(c.dateTo.day, 13);
    });
  });
}
