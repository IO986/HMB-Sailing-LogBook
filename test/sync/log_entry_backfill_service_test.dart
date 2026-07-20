import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/sync/drift_outbox_record_store.dart';
import 'package:hmb_sailing_log/sync/log_entry_backfill_service.dart';

/// Mirrors `domain_write_transaction_test.dart`'s assumption: connectivity is
/// offline, so `enqueue()`'s background sync trigger never reaches the
/// transport — this test only cares what lands in the outbox, not what a
/// push would do with it.
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
  late AppDatabase db;
  late OutboxRepository repository;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = OutboxRepository(store: DriftOutboxRecordStore(db));
    engine = SyncEngine(
      repository: repository,
      transport: _NeverCalledTransport(),
      connectivity: ValueConnectivityService(online: false),
    );
  });

  tearDown(() => db.close());

  test('queues entries with no outbox row, skips entries already queued',
      () async {
    final untouchedId = await db.insertLogbookEntry(
      LogbookEntriesCompanion.insert(timestamp: DateTime.utc(2026, 1, 1)),
    );
    final alreadyQueuedId = await db.insertLogbookEntry(
      LogbookEntriesCompanion.insert(timestamp: DateTime.utc(2026, 1, 2)),
    );
    final sentId = await db.insertLogbookEntry(
      LogbookEntriesCompanion.insert(timestamp: DateTime.utc(2026, 1, 3)),
    );

    // Simulates an entry written while sync was already on: it has an
    // outbox row (still pending) and must not be double-queued.
    await repository.insert(OutboxItem(
      id: 'existing-pending',
      entityType: 'log_entry',
      entityId: alreadyQueuedId.toString(),
      operation: SyncOperation.create,
      payload: const {'note': 'already queued'},
      createdAt: DateTime.now().toUtc(),
    ));
    // Simulates an entry that was already sent successfully in the past —
    // also must not be re-queued.
    await repository.insert(OutboxItem(
      id: 'existing-sent',
      entityType: 'log_entry',
      entityId: sentId.toString(),
      operation: SyncOperation.create,
      payload: const {'note': 'already sent'},
      createdAt: DateTime.now().toUtc(),
      status: SyncStatus.sent,
      syncedAt: DateTime.now().toUtc(),
    ));

    final queuedCount =
        await backfillUnsyncedLogEntries(db: db, engine: engine);

    expect(queuedCount, 1);

    final allItems = <OutboxItem>[
      ...await repository.byStatus(SyncStatus.pending),
      ...await repository.byStatus(SyncStatus.sent),
    ];
    final allEntityIds = allItems.map((i) => i.entityId);
    expect(allEntityIds, containsAll([
      untouchedId.toString(),
      alreadyQueuedId.toString(),
      sentId.toString(),
    ]));
    // Only one new row was created — for the untouched entry.
    final pending = await repository.byStatus(SyncStatus.pending);
    expect(
      pending.where((i) => i.entityId == untouchedId.toString()),
      hasLength(1),
    );
  });

  test('nothing to backfill returns 0 without touching the outbox', () async {
    await db.insertLogbookEntry(
      LogbookEntriesCompanion.insert(timestamp: DateTime.utc(2026, 1, 1)),
    );
    await backfillUnsyncedLogEntries(db: db, engine: engine);

    final queuedCount =
        await backfillUnsyncedLogEntries(db: db, engine: engine);
    expect(queuedCount, 0);
  });
}
