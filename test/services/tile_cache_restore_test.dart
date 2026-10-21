import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/backup_service.dart';
import 'package:hmb_sailing_log/core/services/tile_cache.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('tiles_restore_');
    TileCacheStore.rootForTesting = Directory(p.join(root.path, 'map_tiles'));
  });

  tearDown(() async {
    TileCacheStore.rootForTesting = null;
    await root.delete(recursive: true);
  });

  List<int> zipOf(Map<String, List<int>> files) {
    final a = Archive();
    files.forEach((n, b) => a.addFile(ArchiveFile(n, b.length, b)));
    return ZipEncoder().encodeBytes(a);
  }

  test('restores tiles from a zip file', () async {
    final f = File(p.join(root.path, 'b.zip'))
      ..writeAsBytesSync(zipOf({'sat/5/1/2.png': [1, 2, 3]}));
    final n = await BackupService().restoreTileCacheFromFile(f.path);
    expect(n, 1);
    final dir = await TileCacheStore.directory();
    expect(File(p.join(dir.path, 'sat', '5', '1', '2.png')).readAsBytesSync(),
        [1, 2, 3]);
  });

  test('rejects non-zip and empty input', () async {
    expect(() => BackupService().restoreTileCacheFromBytes([1, 2, 3]),
        throwsFormatException);
    expect(() => BackupService().restoreTileCacheFromBytes(zipOf({})),
        throwsFormatException);
  });

  test('skips entries that escape the cache dir', () async {
    expect(
        () => BackupService()
            .restoreTileCacheFromBytes(zipOf({'../evil.png': [9]})),
        throwsFormatException);
    expect(File(p.join(root.path, 'evil.png')).existsSync(), isFalse);
  });
}
