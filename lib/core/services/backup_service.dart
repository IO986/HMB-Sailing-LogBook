import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/cloud/domain/cloud_storage_provider.dart';
import '../database/app_database.dart';
import 'crash_log_service.dart';
import 'tile_cache.dart';

/// Separate from `LogbookSyncService`'s `['HMB_Sailing_Log_DATA', 'sync']` —
/// that folder holds row-level JSON changesets meant to be merged; this one
/// holds whole-database snapshots meant to be restored wholesale via
/// [BackupService.applyRestore].
const _cloudBackupFolder = ['HMB_Sailing_Log_DATA', 'backups'];

/// Separate folder from [_cloudBackupFolder] — tile cache zips can be much
/// larger than a DB snapshot and are never part of the restore flow that
/// folder serves ([BackupService.applyRestore] never reads from here).
const _cloudTileCacheFolder = ['HMB_Sailing_Log_DATA', 'map_tiles_backup'];

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

    // Voliteľné: ak appka niekedy spadla, cestuje záznam so zálohou, aby sa
    // dal vyžiadať aj od používateľa na mori bez adb/logcat.
    final crashLog = File(p.join(
        (await getApplicationDocumentsDirectory()).path, CrashLogService.fileName));
    if (await crashLog.exists()) {
      final crashBytes = await crashLog.readAsBytes();
      archive.addFile(
          ArchiveFile(CrashLogService.fileName, crashBytes.length, crashBytes));
    }

    final zipBytes = ZipEncoder().encodeBytes(archive);

    await snapshotFile.delete();

    final dateStamp = DateFormat('ddMMyyHHmm').format(DateTime.now());
    final zipFile =
        File(p.join(tempDir.path, 'HMBSaillog_backup_$dateStamp.hmbbackup'));
    await zipFile.writeAsBytes(zipBytes);
    return zipFile;
  }

  /// Zabalí celú stiahnutú mapovú cache (`map_tiles/`) do samostatného zipu
  /// pre ručné uloženie/zdieľanie v Nastaveniach. Zámerne oddelené od
  /// [createSnapshotZip]: je to len cache (dá sa znova stiahnuť), môže byť
  /// rádovo väčšia než samotný denník a [applyRestore] ju nikdy
  /// nerozbaľuje späť — ale raz stiahnuté dlaždice z oblasti, kam sa loď už
  /// nevráti, sú jediná kópia, ktorá na mori ešte bude k dispozícii.
  Future<File> createTileCacheZip() async {
    final tilesDir = await TileCacheStore.directory();
    final archive = Archive();
    if (await tilesDir.exists()) {
      await for (final entity
          in tilesDir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final rel = p
            .relative(entity.path, from: tilesDir.path)
            .replaceAll(Platform.pathSeparator, '/');
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(rel, bytes.length, bytes));
      }
    }
    final zipBytes = ZipEncoder().encodeBytes(archive);

    final tempDir = await getTemporaryDirectory();
    final dateStamp = DateFormat('ddMMyyHHmm').format(DateTime.now());
    final zipFile =
        File(p.join(tempDir.path, 'HMBSaillog_maptiles_$dateStamp.zip'));
    await zipFile.writeAsBytes(zipBytes);
    return zipFile;
  }

  /// Ručný upload mapovej cache na Drive (`map_tiles_backup`) — volané len
  /// z tlačidla v Nastaveniach, nie automaticky po Stope ako [uploadSnapshot]:
  /// súbor môže byť rádovo väčší a skiper má rozhodnúť, kedy ho poslať.
  Future<void> uploadTileCacheToCloud({
    required CloudStorageProvider provider,
    required String deviceId,
  }) async {
    final zipFile = await createTileCacheZip();
    try {
      await provider.upload(
        file: zipFile,
        fileName: '$deviceId-${DateTime.now().millisecondsSinceEpoch}.zip',
        folderPath: _cloudTileCacheFolder,
        mimeType: 'application/zip',
      );
    } finally {
      if (await zipFile.exists()) await zipFile.delete();
    }
  }

  /// Stiahne najnovší nahraný tile-cache zip (z ktoréhokoľvek zariadenia) a
  /// rozbalí ho do živej `map_tiles/` cache — presne scenár po
  /// preinštalovaní appky alebo výmene telefónu, kde sú dlaždice inak preč.
  /// Existujúce súbory sa prepíšu; nové (stiahnuté medzičasom na tomto
  /// zariadení) sa nemažú, zip ich jednoducho neobsahuje.
  Future<void> restoreTileCacheFromCloud(CloudStorageProvider provider) async {
    final files = await provider.listFiles(_cloudTileCacheFolder);
    if (files.isEmpty) {
      throw const FormatException('Žiadna záloha mapových dlaždíc na cloude');
    }
    files.sort((a, b) =>
        (b.modifiedTime ?? DateTime(0)).compareTo(a.modifiedTime ?? DateTime(0)));
    final bytes = await provider.downloadFile(files.first.id);
    final archive = ZipDecoder().decodeBytes(bytes);

    final tilesDir = await TileCacheStore.directory();
    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      final out = File(p.join(tilesDir.path, entry.name));
      await out.parent.create(recursive: true);
      await out.writeAsBytes(entry.content as List<int>);
    }
  }

  /// Snapshot celej DB nahraný do `backups` priečinka na cloude, volané po
  /// každom zastavení trackingu (viď `TrackingNotifier.stopTracking`) —
  /// nezávislá poistka pre obnovu zo zariadenia, nie cross-device sync
  /// (to rieši `LogbookSyncService`, ktorý ide prírastkovo).
  Future<void> uploadSnapshot({
    required AppDatabase db,
    required CloudStorageProvider provider,
    required String deviceId,
  }) async {
    final zipFile = await createSnapshotZip(db);
    try {
      await provider.upload(
        file: zipFile,
        fileName: '$deviceId-${DateTime.now().millisecondsSinceEpoch}.hmbbackup',
        folderPath: _cloudBackupFolder,
        mimeType: 'application/zip',
      );
    } finally {
      if (await zipFile.exists()) await zipFile.delete();
    }
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
