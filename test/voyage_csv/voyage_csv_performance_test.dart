import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_codec.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_record.dart';

/// A voyage of weeks has hundreds of thousands of track points, and each row
/// has 139 cells. The first version copied the cell map for every cell and
/// wrote them to the file one by one; on a phone the export ran for minutes.
/// These are generous bounds, there to catch a return of that, not to measure.
void main() {
  const points = 100000;

  Iterable<VoyageCsvRecord> records() sync* {
    yield VoyageCsvRecord.meta(
      exportedAt: DateTime.utc(2026, 10, 22),
      appVersion: 'x',
      schemaVersion: 37,
      includesTrack: true,
    );
    final t0 = DateTime.utc(2026, 10, 6);
    for (var i = 0; i < points; i++) {
      yield VoyageCsvRecord('track', id: i + 1, parentId: 1)
        ..set('time_utc', t0.add(Duration(seconds: i * 5)))
        ..set('lat', 43.0 + i * 1e-6)
        ..set('lon', 15.0 + i * 1e-6)
        ..set('speed_kn', 5.5)
        ..set('course_deg', 270)
        ..set('accuracy_m', 4.5);
    }
  }

  test('a hundred thousand track points are written in seconds', () {
    final sw = Stopwatch()..start();
    final text = VoyageCsvWriter.write(records());
    sw.stop();

    expect(text.length, greaterThan(points * 100));
    expect(sw.elapsed, lessThan(const Duration(seconds: 20)),
        reason: 'took ${sw.elapsed}');
  });

  test('and read back in seconds', () {
    final text = VoyageCsvWriter.write(records());
    final sw = Stopwatch()..start();
    final doc = VoyageCsvReader.read(text);
    sw.stop();

    expect(doc.ofType('track').length, points);
    expect(sw.elapsed, lessThan(const Duration(seconds: 20)),
        reason: 'took ${sw.elapsed}');
  });

  test('written straight to a file the way the export does', () async {
    final dir = await Directory.systemTemp.createTemp('hmb_csv_perf');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/big.csv');

    final sw = Stopwatch()..start();
    final sink = file.openWrite();
    try {
      VoyageCsvWriter.writeTo(sink, records());
    } finally {
      await sink.flush();
      await sink.close();
    }
    sw.stop();

    expect(await file.length(), greaterThan(points * 100));
    expect(sw.elapsed, lessThan(const Duration(seconds: 20)),
        reason: 'took ${sw.elapsed}');
  });
}
