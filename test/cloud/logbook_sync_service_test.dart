import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/cloud/domain/cloud_storage_provider.dart';
import 'package:hmb_sailing_log/features/cloud/services/logbook_sync_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `composeChangeset`'s JSON goes to a temp file before upload — no
/// platform channel in `flutter test`, so point path_provider at a real
/// temp dir, same trick as auto_export_service_test.dart.
class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._path);
  final String _path;
  @override
  Future<String?> getTemporaryPath() async => _path;
}

/// A [CloudStorageProvider] backed by an in-memory map, shared between two
/// [LogbookSyncService] instances the way a real Drive account is shared
/// between two phones — good enough to exercise `syncNow()`'s push→list→
/// download wiring without any network.
class _SharedFakeDrive implements CloudStorageProvider {
  final Map<String, List<int>> _filesByPath = {};
  final Map<String, DateTime> _modifiedByPath = {};
  var _nextId = 0;

  String _pathOf(List<String> folderPath, String fileName) =>
      '${folderPath.join('/')}/$fileName';

  @override
  String get id => 'fake';
  @override
  String get displayName => 'Fake Drive';
  @override
  Future<CloudAccount?> get currentAccount async =>
      const CloudAccount(email: 'skipper@example.com');
  @override
  bool get isSignedInNow => true;
  @override
  Future<CloudAccount?> signIn() async => const CloudAccount(email: 'skipper@example.com');
  @override
  Future<void> signOut() async {}

  @override
  Future<String> upload({
    required File file,
    required String fileName,
    required List<String> folderPath,
    required String mimeType,
  }) async {
    final path = _pathOf(folderPath, fileName);
    _filesByPath[path] = await file.readAsBytes();
    // Strictly increasing even within the same test tick, so two pushes in
    // the same run don't collide on `since` comparisons.
    _modifiedByPath[path] =
        DateTime.now().toUtc().add(Duration(microseconds: _nextId));
    return 'fake-${_nextId++}';
  }

  @override
  Future<List<CloudFile>> listFiles(List<String> folderPath) async {
    final prefix = '${folderPath.join('/')}/';
    return [
      for (final path in _filesByPath.keys)
        if (path.startsWith(prefix))
          CloudFile(
            id: path,
            name: path.substring(prefix.length),
            modifiedTime: _modifiedByPath[path],
          ),
    ];
  }

  @override
  Future<List<int>> downloadFile(String fileId) async => _filesByPath[fileId]!;
}

/// Simulates two devices on the same account: `dbA`/`dbB` are separate
/// SQLite instances, and a changeset composed from one is applied to the
/// other — exactly the shape `LogbookSyncService.syncNow()` drives over
/// Google Drive, minus the network.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase dbA;
  late AppDatabase dbB;

  late Directory tempDir;

  setUp(() async {
    dbA = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    dbB = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('logbook_sync_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
  });
  tearDown(() async {
    await dbA.close();
    await dbB.close();
    await tempDir.delete(recursive: true);
  });

  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  final noon = DateTime.utc(2026, 9, 22, 12);

  test('a charter, day log and entry created on A appear on B with FKs resolved',
      () async {
    final charter = await dbA.insertCharter(ChartersCompanion.insert(
      title: 'Plavba A',
      dateFrom: noon,
      dateTo: noon,
      createdAt: noon,
      updatedAt: Value(noon),
    ));
    final day = await dbA.insertDayLog(DayLogsCompanion.insert(
      charterId: charter.id,
      date: noon,
      updatedAt: Value(noon),
    ));
    await dbA.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(day.id),
      timestamp: noon,
      skipperNote: const Value('z kokpitu'),
      updatedAt: Value(noon),
    ));

    final changeset = await composeChangeset(dbA, epoch);
    await applyChangesets(dbB, [changeset]);

    final chartersB = await dbB.getAllCharters();
    expect(chartersB, hasLength(1));
    expect(chartersB.single.title, 'Plavba A');

    final daysB = await dbB.getDayLogs(chartersB.single.id);
    expect(daysB, hasLength(1));

    final entriesB = await dbB.getEntriesForDay(daysB.single.id);
    expect(entriesB, hasLength(1));
    expect(entriesB.single.skipperNote, 'z kokpitu');
  });

  test('a row edited on both sides keeps whichever has the newer updatedAt',
      () async {
    await dbA.insertCharter(ChartersCompanion.insert(
      title: 'Pôvodný názov',
      dateFrom: noon,
      dateTo: noon,
      createdAt: noon,
      updatedAt: Value(noon),
    ));
    var changeset = await composeChangeset(dbA, epoch);
    await applyChangesets(dbB, [changeset]);

    // B renames it a minute later — newer than A's version.
    final later = noon.add(const Duration(minutes: 1));
    final onB = (await dbB.getAllCharters()).single;
    await dbB.updateCharter(ChartersCompanion(
      id: Value(onB.id),
      title: const Value('Premenované na B'),
      updatedAt: Value(later),
    ));

    // A never touched it again — still the old updatedAt when it re-sends
    // (simulates A pushing an unrelated later change that happens to
    // re-include this row, e.g. after a broader "since" window).
    changeset = await composeChangeset(dbA, epoch);
    await applyChangesets(dbB, [changeset]);

    expect((await dbB.getAllCharters()).single.title, 'Premenované na B',
        reason: 'B\'s newer edit must survive A\'s older copy arriving after it');
  });

  test('applying the same changeset twice does not duplicate rows', () async {
    await dbA.insertCharter(ChartersCompanion.insert(
      title: 'Raz',
      dateFrom: noon,
      dateTo: noon,
      createdAt: noon,
      updatedAt: Value(noon),
    ));
    final changeset = await composeChangeset(dbA, epoch);

    await applyChangesets(dbB, [changeset]);
    await applyChangesets(dbB, [changeset]);

    expect(await dbB.getAllCharters(), hasLength(1));
  });

  test('track points dedup by (sessionId, timestamp) instead of a uuid',
      () async {
    await dbA.insertTrackPoint(TrackPointsCompanion.insert(
      sessionId: const Value('session-1'),
      timestamp: noon,
      latitude: 43.5,
      longitude: 16.4,
    ));
    final changeset = await composeChangeset(dbA, epoch);

    await applyChangesets(dbB, [changeset]);
    await applyChangesets(dbB, [changeset]); // second device's own re-pull

    final points = await dbB.getTrackPointsForSession('session-1');
    expect(points, hasLength(1));
    expect(points.single.latitude, 43.5);
  });

  test('a day log whose charter has not arrived yet is dropped, not crashed',
      () async {
    final charter = await dbA.insertCharter(ChartersCompanion.insert(
      title: 'Plavba A',
      dateFrom: noon,
      dateTo: noon,
      createdAt: noon,
      updatedAt: Value(noon),
    ));
    await dbA.insertDayLog(DayLogsCompanion.insert(
      charterId: charter.id,
      date: noon,
      updatedAt: Value(noon),
    ));

    final changeset = await composeChangeset(dbA, epoch);
    // Only the day log arrives on B, its charter's row is missing from
    // this (contrived) changeset — simulates the parent not having synced
    // yet.
    changeset['charters'] = <Map<String, dynamic>>[];

    await applyChangesets(dbB, [changeset]);

    expect(await dbB.getAllCharters(), isEmpty);
    // No exception thrown, and nothing orphaned into existence either.
  });

  group('syncNow end-to-end (single device, fake Drive)', () {
    test('pushes to the sync/ folder and never re-applies its own upload',
        () async {
      final drive = _SharedFakeDrive();
      const service = LogbookSyncService();

      await dbA.insertCharter(ChartersCompanion.insert(
        title: 'Plavba A',
        dateFrom: noon,
        dateTo: noon,
        createdAt: noon,
        updatedAt: Value(noon),
      ));

      await service.syncNow(db: dbA, provider: drive, deviceId: 'phone-a');

      final uploaded = await drive.listFiles(const ['HMB_Sailing_Log_DATA', 'sync']);
      expect(uploaded, hasLength(1));
      expect(uploaded.single.name, startsWith('phone-a-'));

      // A second cycle must not duplicate the charter it already has, even
      // though its own file is sitting right there in the "sync/" folder.
      await service.syncNow(db: dbA, provider: drive, deviceId: 'phone-a');
      expect(await dbA.getAllCharters(), hasLength(1));
    });
  });
}
