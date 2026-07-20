import 'dart:io';
import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/skipper_profile.dart';
import 'package:hmb_sailing_log/features/cloud/services/auto_export_service.dart';
import 'package:hmb_sailing_log/sync/drift_outbox_record_store.dart';
import 'package:hmb_sailing_log/sync/sync_entity_types.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Same "connectivity offline" trick as domain_write_transaction_test.dart —
/// enqueue()'s background sync trigger never reaches a transport, so what
/// lands in the outbox is all this test needs to check.
class _NeverCalledTransport implements SyncTransport {
  @override
  int get batchSize => 1;
  @override
  Future<bool> isReachable() async => true;
  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) {
    fail('transport.push must never be called by this test');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('sk', null));

  late AppDatabase db;
  late OutboxRepository repository;
  late SyncEngine engine;
  late int dayLogId;
  late Directory storageDir;

  setUp(() async {
    // ExportService.saveBytesLocally() goes through path_provider for the
    // persistent-storage root — no platform channel in `flutter test`, so
    // point it at a real temp dir instead (repo convention per
    // test/services/backup_service_test.dart's comment: parts that need
    // path_provider are normally left to manual device testing, but here
    // "saves to a real persistent path" is the actual thing being verified).
    storageDir = await Directory.systemTemp.createTemp('auto_export_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(storageDir.path);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = OutboxRepository(store: DriftOutboxRecordStore(db));
    engine = SyncEngine(
      repository: repository,
      transport: _NeverCalledTransport(),
      connectivity: ValueConnectivityService(online: false),
    );

    final charter = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba testov 2026',
      dateFrom: DateTime.utc(2026, 7, 20),
      dateTo: DateTime.utc(2026, 7, 27),
      createdAt: DateTime.utc(2026, 7, 20),
    ));
    final day = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: charter.id,
      date: DateTime.utc(2026, 7, 20),
    ));
    dayLogId = day.id;
  });

  tearDown(() async {
    await db.close();
    await storageDir.delete(recursive: true);
  });

  test('cloud export enabled: queues PDF + GPX, files exist on disk', () async {
    await AutoExportService().exportAndEnqueueDay(
      db: db,
      engine: engine,
      cloudEnabled: true,
      locale: const Locale('sk'),
      skipperProfile: const SkipperProfile(),
      dayLogId: dayLogId,
    );

    final pending = await repository.byStatus(SyncStatus.pending);
    expect(pending, hasLength(2));
    expect(pending.every((i) => i.entityType == SyncEntityType.cloudExport), isTrue);

    for (final item in pending) {
      final path = item.attachments.single.localPath;
      expect(File(path).existsSync(), isTrue, reason: '$path should exist on disk');
    }
  });

  test('cloud export disabled: builds files locally but queues nothing', () async {
    await AutoExportService().exportAndEnqueueDay(
      db: db,
      engine: engine,
      cloudEnabled: false,
      locale: const Locale('sk'),
      skipperProfile: const SkipperProfile(),
      dayLogId: dayLogId,
    );

    final pending = await repository.byStatus(SyncStatus.pending);
    expect(pending, isEmpty);
  });
}

/// Both `getApplicationDocumentsPath` and `getExternalStoragePath` point at
/// the same temp dir — `ExportService.saveBytesLocally` only needs *some*
/// writable, persistent-looking root, not the real distinction between them.
class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._path);
  final String _path;
  @override
  Future<String?> getApplicationDocumentsPath() async => _path;
  @override
  Future<String?> getExternalStoragePath() async => _path;
}
