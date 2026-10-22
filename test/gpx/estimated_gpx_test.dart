import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/utils/gpx_exporter.dart';
import 'package:hmb_sailing_log/features/gpx_import/services/gpx_importer.dart';
import 'package:hmb_sailing_log/features/gpx_import/services/gpx_voyage_reconstructor.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';

/// A track drawn through log entries has points hours apart. Every pair would
/// count as a gap in the recording and be split into its own `<trkseg>`, which
/// leaves a GPX viewer with dots and no line.
void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('sk'));
  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<(DayLog, SailingSession, List<TrackPoint>)> build(
      {required bool estimated}) async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'x',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 10),
      createdAt: DateTime(2026, 7, 10),
    ));
    final day = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 7, 10),
      portFrom: const Value('Biograd'),
      portTo: const Value('Žut'),
    ));
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 's1',
      dayLogId: Value(day.id),
      startTime: DateTime.utc(2026, 7, 10, 8),
      name: const Value('Estimated from log entries'),
      isEstimated: Value(estimated),
    ));
    await db.insertTrackPointsBatch([
      for (final (h, lat, lon) in [
        (8, 43.90, 15.40),
        (11, 43.95, 15.45),
        (14, 44.00, 15.50),
      ])
        TrackPointsCompanion.insert(
          sessionId: const Value('s1'),
          timestamp: DateTime.utc(2026, 7, 10, h),
          latitude: lat,
          longitude: lon,
        ),
    ]);
    final session = (await db.getSessionsForDay(day.id)).single;
    return (day, session, await db.getTrackPointsForSession('s1'));
  }

  int segments(String gpx) => '<trkseg>'.allMatches(gpx).length;

  test('an estimated track is one continuous segment', () async {
    final (day, session, points) = await build(estimated: true);
    final bytes =
        await GpxExporter.buildDayGpxBytes(day, [session], {'s1': points});
    final gpx = utf8.decode(bytes);

    expect(segments(gpx), 1);
    expect('<trkpt'.allMatches(gpx).length, 3);
  });

  test('a measured track with the same holes is still split, as before',
      () async {
    final (day, session, points) = await build(estimated: false);
    final bytes =
        await GpxExporter.buildDayGpxBytes(day, [session], {'s1': points});

    expect(segments(utf8.decode(bytes)), 3);
  });

  test('in a whole-voyage file the estimate is named as one', () async {
    final (day, session, points) = await build(estimated: true);
    final charter = (await db.getCharterById(day.charterId))!;
    final bytes = await GpxExporter.buildCharterGpxBytes(
        charter, [day], {day.id: [session]}, {'s1': points});
    final gpx = utf8.decode(bytes);

    expect(gpx, contains('Biograd → Žut${GpxExporter.estimateSuffix}'));
  });

  test('importing that file back does not turn the tag into a port', () {
    final parsed = GpxImporter.parse('''
<gpx version="1.1"><trk><name>sobota 10.7.: Biograd → Žut (estimated)</name>
<trkseg><trkpt lat="43.9" lon="15.4"><time>2026-07-10T08:00:00Z</time></trkpt></trkseg></trk></gpx>''');
    final name = parsed.tracks.single.name;
    expect(GpxVoyageReconstructor.portsFromTrackName(name), ('Biograd', 'Žut'));
  });
}
