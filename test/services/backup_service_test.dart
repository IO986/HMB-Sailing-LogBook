import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/backup_service.dart';

/// [BackupService.createSnapshotZip]/[applyRestore] potrebujú path_provider
/// (platform channel), preto ich tu neskúšame end-to-end – overuje sa
/// manuálne na zariadení. Toto pokrýva parsovanie neznámeho/užívateľom
/// vybraného .hmbbackup súboru, čo je jediná časť bez platform-channel
/// závislostí a zároveň časť pracujúca s nedôveryhodným vstupom.
void main() {
  Future<String> writeZip(Directory dir, Archive archive) async {
    final path = '${dir.path}/test.hmbbackup';
    await File(path).writeAsBytes(ZipEncoder().encodeBytes(archive));
    return path;
  }

  test('readMetadata parses a valid backup zip', () async {
    final dir = await Directory.systemTemp.createTemp('hmb_backup_test');
    addTearDown(() => dir.delete(recursive: true));

    final metaJson = utf8.encode(jsonEncode({
      'schemaVersion': 8,
      'appVersion': '1.20.4',
      'buildNumber': '24',
      'exportedAt': '2026-07-04T12:00:00.000Z',
    }));
    final archive = Archive()
      ..addFile(ArchiveFile('metadata.json', metaJson.length, metaJson))
      ..addFile(ArchiveFile('sailing_logbook.db', 3, [1, 2, 3]));
    final path = await writeZip(dir, archive);

    final metadata = await BackupService().readMetadata(path);

    expect(metadata.schemaVersion, 8);
    expect(metadata.appVersion, '1.20.4');
    expect(metadata.buildNumber, '24');
    expect(metadata.exportedAt, DateTime.parse('2026-07-04T12:00:00.000Z'));
  });

  test('readMetadata throws FormatException when metadata.json is missing', () async {
    final dir = await Directory.systemTemp.createTemp('hmb_backup_test');
    addTearDown(() => dir.delete(recursive: true));

    final archive = Archive()
      ..addFile(ArchiveFile('sailing_logbook.db', 3, [1, 2, 3]));
    final path = await writeZip(dir, archive);

    expect(() => BackupService().readMetadata(path), throwsFormatException);
  });
}
