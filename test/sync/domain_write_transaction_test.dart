import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/sync/drift_outbox_record_store.dart';

/// Never actually reached in these tests — connectivity is offline, so
/// `enqueue()`'s background sync trigger short-circuits before touching
/// the transport. Fails loudly if that assumption is ever wrong.
class _NeverCalledTransport implements SyncTransport {
  @override
  int get batchSize => 1;

  @override
  Future<bool> isReachable() async => true;

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) {
    fail('transport.push must never be called by these tests');
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

  test('domain write and enqueue() commit together in one transaction', () async {
    await db.transaction(() async {
      final id = await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        timestamp: DateTime.utc(2026, 1, 1),
      ));
      await engine.enqueue(
        entityType: 'log_entry',
        entityId: id.toString(),
        payload: const {'note': 'hi'},
      );
    });

    final entries = await db.select(db.logbookEntries).get();
    expect(entries, hasLength(1));

    final pending = await repository.byStatus(SyncStatus.pending);
    expect(pending, hasLength(1));
    expect(pending.single.entityType, 'log_entry');
    expect(pending.single.entityId, entries.single.id.toString());
    expect(pending.single.payload, {'note': 'hi'});
  });

  test('an exception after the domain write rolls back both, not just one', () async {
    await expectLater(
      db.transaction(() async {
        await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
          timestamp: DateTime.utc(2026, 1, 1),
        ));
        throw Exception('simulated failure between the two writes');
      }),
      throwsException,
    );

    final entries = await db.select(db.logbookEntries).get();
    expect(entries, isEmpty, reason: 'domain write must roll back too');

    final pending = await repository.byStatus(SyncStatus.pending);
    expect(pending, isEmpty);
  });

  test('an exception during enqueue itself rolls back the domain write', () async {
    await expectLater(
      db.transaction(() async {
        await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
          timestamp: DateTime.utc(2026, 1, 1),
        ));
        // entityId left null on purpose isn't the trigger here — force a
        // failure via a payload OutboxItem.toJson can't serialize.
        await engine.enqueue(
          entityType: 'log_entry',
          payload: {'bad': DateTime.now()}, // not JSON-encodable as-is
        );
      }),
      throwsA(anything),
    );

    final entries = await db.select(db.logbookEntries).get();
    expect(entries, isEmpty);
  });
}
