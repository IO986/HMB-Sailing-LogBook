import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

class BackupMetadata {
  final int schemaVersion;
  final String appVersion;
  final String buildNumber;
  final DateTime exportedAt;

  BackupMetadata({
    required this.schemaVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.exportedAt,
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'exportedAt': exportedAt.toIso8601String(),
      };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
        schemaVersion: json['schemaVersion'] as int,
        appVersion: json['appVersion'] as String? ?? '?',
        buildNumber: json['buildNumber'] as String? ?? '?',
        exportedAt: DateTime.parse(json['exportedAt'] as String),
      );
}

/// Export/import celej lokálnej DB ako jeden zdieľateľný `.hmbbackup` súbor
/// (zip: sailing_logbook.db + metadata.json).
class BackupService {
  static final BackupService _i = BackupService._();
  factory BackupService() => _i;
  BackupService._();

  static const _dbFileName = 'sailing_logbook.db';
  static const _metaFileName = 'metadata.json';

  Future<File> _liveDbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _dbFileName));
  }

  /// Vytvorí bezpečný snapshot živej DB (`VACUUM INTO`) a zabalí ho spolu s
  /// metadátami do `.hmbbackup` zipu v temp adresári. Funguje aj počas
  /// aktívneho GPS trackingu – `VACUUM INTO` nevyžaduje zatvorenie spojenia.
  Future<File> createSnapshotZip(AppDatabase db) async {
    final tempDir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final snapshotFile = File(p.join(tempDir.path, 'hmb_snapshot_$stamp.db'));
    if (await snapshotFile.exists()) await snapshotFile.delete();

    final escapedPath = snapshotFile.path.replaceAll("'", "''");
    await db.customStatement("VACUUM INTO '$escapedPath'");

    final info = await PackageInfo.fromPlatform();
    final metadata = BackupMetadata(
      schemaVersion: db.schemaVersion,
      appVersion: info.version,
      buildNumber: info.buildNumber,
      exportedAt: DateTime.now().toUtc(),
    );

    final dbBytes = await snapshotFile.readAsBytes();
    final metaBytes = utf8.encode(jsonEncode(metadata.toJson()));

    final archive = Archive()
      ..addFile(ArchiveFile(_dbFileName, dbBytes.length, dbBytes))
      ..addFile(ArchiveFile(_metaFileName, metaBytes.length, metaBytes));
    final zipBytes = ZipEncoder().encodeBytes(archive);

    await snapshotFile.delete();

    final dateStamp = DateFormat('ddMMyyHHmm').format(DateTime.now());
    final zipFile =
        File(p.join(tempDir.path, 'HMBSaillog_backup_$dateStamp.hmbbackup'));
    await zipFile.writeAsBytes(zipBytes);
    return zipFile;
  }

  /// Prečíta iba metadáta zálohy (bez extrakcie DB) – na validáciu pred
  /// potvrdzovacím dialógom.
  Future<BackupMetadata> readMetadata(String zipPath) async {
    final archive = ZipDecoder().decodeBytes(await File(zipPath).readAsBytes());
    final entry = archive.files.where((f) => f.name == _metaFileName).firstOrNull;
    if (entry == null) {
      throw const FormatException('Záloha neobsahuje metadata.json');
    }
    return BackupMetadata.fromJson(
        jsonDecode(utf8.decode(entry.content)) as Map<String, dynamic>);
  }

  /// Prepíše živý DB súbor obsahom zálohy. Volajúci MUSÍ pred týmto zavolať
  /// `close()` na starej [AppDatabase] inštancii a po tomto vytvoriť novú
  /// `AppDatabase()` + `wireDatabaseSingletons` + `ref.invalidate(databaseProvider)`.
  Future<void> applyRestore(String zipPath) async {
    final archive = ZipDecoder().decodeBytes(await File(zipPath).readAsBytes());
    final dbEntry = archive.files.where((f) => f.name == _dbFileName).firstOrNull;
    if (dbEntry == null) {
      throw const FormatException('Záloha neobsahuje $_dbFileName');
    }

    final liveDb = await _liveDbFile();
    for (final suffix in ['-wal', '-shm']) {
      final side = File('${liveDb.path}$suffix');
      if (await side.exists()) await side.delete();
    }
    await liveDb.writeAsBytes(dbEntry.content);
  }
}
