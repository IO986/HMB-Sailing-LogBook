import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/sync/drift_outbox_record_store.dart';

void main() {
  late AppDatabase db;
  late DriftOutboxRecordStore store;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = DriftOutboxRecordStore(db);
  });

  tearDown(() => db.close());

  OutboxItem item({
    String id = 'a',
    List<Attachment> attachments = const [],
    String? entityId,
    String? errorMessage,
    DateTime? lastAttemptAt,
    DateTime? syncedAt,
    String? version,
    String? remoteId,
  }) =>
      OutboxItem(
        id: id,
        entityType: 'record',
        entityId: entityId,
        operation: SyncOperation.update,
        payload: const {'note': 'hi', 'count': 3},
        createdAt: DateTime.utc(2026, 1, 1),
        attachments: attachments,
        errorMessage: errorMessage,
        lastAttemptAt: lastAttemptAt,
        syncedAt: syncedAt,
        version: version,
        remoteId: remoteId,
      );

  test('put then getById round-trips every field through hmb_core OutboxItem.fromJson', () async {
    final original = item(
      entityId: 'e1',
      errorMessage: 'boom',
      lastAttemptAt: DateTime.utc(2026, 1, 1, 1),
      syncedAt: DateTime.utc(2026, 1, 1, 2),
      version: 'v3',
      remoteId: 'srv-9',
      attachments: const [
        Attachment(
          localPath: '/tmp/p.jpg',
          field: 'photo',
          mimeType: 'image/jpeg',
          sizeBytes: 5,
          remoteRef: 'r1',
        ),
      ],
    );

    await store.put('hmb_core.outbox', original.id, original.toJson());
    final raw = await store.getById('hmb_core.outbox', original.id);
    final back = OutboxItem.fromJson(raw!);

    expect(back.id, original.id);
    expect(back.entityType, original.entityType);
    expect(back.entityId, 'e1');
    expect(back.operation, SyncOperation.update);
    expect(back.payload, {'note': 'hi', 'count': 3});
    expect(back.attachments.single.localPath, '/tmp/p.jpg');
    expect(back.attachments.single.remoteRef, 'r1');
    expect(back.errorMessage, 'boom');
    expect(back.lastAttemptAt, DateTime.utc(2026, 1, 1, 1));
    expect(back.syncedAt, DateTime.utc(2026, 1, 1, 2));
    expect(back.version, 'v3');
    expect(back.remoteId, 'srv-9');
  });

  test('put upserts — a second put with the same id replaces the row', () async {
    await store.put('c', 'a', item(id: 'a').toJson());
    await store.put('c', 'a', item(id: 'a', remoteId: 'updated').toJson());

    final all = await store.getAll('c');
    expect(all, hasLength(1));
    expect(OutboxItem.fromJson(all.single).remoteId, 'updated');
  });

  test('getById returns null for a missing id', () async {
    expect(await store.getById('c', 'missing'), isNull);
  });

  test('getAll returns every stored record', () async {
    await store.put('c', 'a', item(id: 'a').toJson());
    await store.put('c', 'b', item(id: 'b').toJson());
    expect(await store.getAll('c'), hasLength(2));
  });

  test('delete removes the record', () async {
    await store.put('c', 'a', item(id: 'a').toJson());
    await store.delete('c', 'a');
    expect(await store.getAll('c'), isEmpty);
  });

  test('deleteWhere removes only matching records', () async {
    await store.put('c', 'a', item(id: 'a', remoteId: 'keep').toJson());
    await store.put('c', 'b', item(id: 'b', remoteId: 'drop').toJson());

    await store.deleteWhere(
      'c',
      (record) => record['remoteId'] == 'drop',
    );

    final remaining = await store.getAll('c');
    expect(remaining, hasLength(1));
    expect(OutboxItem.fromJson(remaining.single).id, 'a');
  });

  test('watch emits on put and delete', () async {
    final events = <void>[];
    final sub = store.watch('c').listen(events.add);

    await store.put('c', 'a', item(id: 'a').toJson());
    await store.delete('c', 'a');
    await Future<void>.delayed(Duration.zero);

    expect(events, hasLength(2));
    await sub.cancel();
  });

  test('works end to end through hmb_core OutboxRepository (real drift index, not in-memory)', () async {
    final repository = OutboxRepository(store: store);
    await repository.insert(item(id: 'a'));
    await repository.insert(
      item(id: 'b').copyWith(status: SyncStatus.sent, syncedAt: DateTime.utc(2026, 1, 2)),
    );

    final pending = await repository.pendingItems(limit: 10);
    expect(pending.map((i) => i.id), ['a']);

    final snapshot = await repository.watchQueue().first;
    expect(snapshot.pending, 1);
  });
}
