import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/core/models/sync_settings.dart';
import 'package:hmb_sailing_log/sync/sync_policy_transport.dart';

class _FakeInner implements SyncTransport {
  final List<List<OutboxItem>> calls = [];
  SyncItemResult Function(OutboxItem item)? resultFor;

  @override
  int get batchSize => 5;

  @override
  Future<bool> isReachable() async => true;

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async {
    calls.add(batch);
    return [
      for (final item in batch)
        resultFor?.call(item) ??
            SyncItemResult(itemId: item.id, outcome: SyncItemOutcome.success),
    ];
  }
}

OutboxItem _item(String id, {List<Attachment> attachments = const []}) => OutboxItem(
      id: id,
      entityType: 'log_entry',
      operation: SyncOperation.create,
      payload: const {},
      createdAt: DateTime.utc(2026, 1, 1),
      attachments: attachments,
    );

const _photo = [
  Attachment(
    localPath: '/tmp/p.jpg',
    field: 'photo',
    mimeType: 'image/jpeg',
    sizeBytes: 1,
  ),
];

void main() {
  test('batchSize delegates to the inner transport', () {
    final inner = _FakeInner();
    final policy = SyncPolicyTransport(
      inner: inner,
      isSyncEnabled: () => true,
      attachmentPolicy: () => AttachmentSyncPolicy.always,
      isOnWifi: () async => true,
    );
    expect(policy.batchSize, 5);
  });

  group('sync disabled', () {
    test('every item comes back as a retryable failure, inner never called', () async {
      final inner = _FakeInner();
      final policy = SyncPolicyTransport(
        inner: inner,
        isSyncEnabled: () => false,
        attachmentPolicy: () => AttachmentSyncPolicy.always,
        isOnWifi: () async => true,
      );

      final results = await policy.push([_item('a'), _item('b')]);

      expect(inner.calls, isEmpty);
      expect(results, hasLength(2));
      for (final r in results) {
        expect(r.outcome, SyncItemOutcome.failure);
        expect(r.retryable, isTrue);
      }
    });

    test('isReachable is false when disabled, regardless of the inner transport', () async {
      final policy = SyncPolicyTransport(
        inner: _FakeInner(),
        isSyncEnabled: () => false,
        attachmentPolicy: () => AttachmentSyncPolicy.always,
        isOnWifi: () async => true,
      );
      expect(await policy.isReachable(), isFalse);
    });
  });

  group('attachment policy: never', () {
    test('items with attachments are always skipped, even on Wi-Fi', () async {
      final inner = _FakeInner();
      final policy = SyncPolicyTransport(
        inner: inner,
        isSyncEnabled: () => true,
        attachmentPolicy: () => AttachmentSyncPolicy.never,
        isOnWifi: () async => true,
      );

      final results = await policy.push([_item('photo-item', attachments: _photo)]);

      expect(inner.calls, isEmpty);
      expect(results.single.outcome, SyncItemOutcome.failure);
      expect(results.single.retryable, isTrue);
    });

    test('items without attachments still sync normally', () async {
      final inner = _FakeInner();
      final policy = SyncPolicyTransport(
        inner: inner,
        isSyncEnabled: () => true,
        attachmentPolicy: () => AttachmentSyncPolicy.never,
        isOnWifi: () async => false,
      );

      final results = await policy.push([_item('plain')]);

      expect(inner.calls, hasLength(1));
      expect(results.single.outcome, SyncItemOutcome.success);
    });
  });

  group('attachment policy: wifiOnly', () {
    test('items with attachments are skipped when not on Wi-Fi', () async {
      final inner = _FakeInner();
      final policy = SyncPolicyTransport(
        inner: inner,
        isSyncEnabled: () => true,
        attachmentPolicy: () => AttachmentSyncPolicy.wifiOnly,
        isOnWifi: () async => false,
      );

      final results = await policy.push([_item('photo-item', attachments: _photo)]);

      expect(inner.calls, isEmpty);
      expect(results.single.outcome, SyncItemOutcome.failure);
      expect(results.single.retryable, isTrue);
    });

    test('items with attachments are sent when on Wi-Fi', () async {
      final inner = _FakeInner();
      final policy = SyncPolicyTransport(
        inner: inner,
        isSyncEnabled: () => true,
        attachmentPolicy: () => AttachmentSyncPolicy.wifiOnly,
        isOnWifi: () async => true,
      );

      final results = await policy.push([_item('photo-item', attachments: _photo)]);

      expect(inner.calls, hasLength(1));
      expect(results.single.outcome, SyncItemOutcome.success);
    });

    test('a mixed batch splits: attachment item deferred, plain item sent', () async {
      final inner = _FakeInner();
      final policy = SyncPolicyTransport(
        inner: inner,
        isSyncEnabled: () => true,
        attachmentPolicy: () => AttachmentSyncPolicy.wifiOnly,
        isOnWifi: () async => false,
      );

      final results = await policy.push([
        _item('plain'),
        _item('photo-item', attachments: _photo),
      ]);

      expect(inner.calls.single.map((i) => i.id), ['plain']);
      final byId = {for (final r in results) r.itemId: r};
      expect(byId['plain']!.outcome, SyncItemOutcome.success);
      expect(byId['photo-item']!.outcome, SyncItemOutcome.failure);
      expect(byId['photo-item']!.retryable, isTrue);
    });
  });

  group('attachment policy: always', () {
    test('items with attachments are sent regardless of Wi-Fi state', () async {
      final inner = _FakeInner();
      final policy = SyncPolicyTransport(
        inner: inner,
        isSyncEnabled: () => true,
        attachmentPolicy: () => AttachmentSyncPolicy.always,
        isOnWifi: () async => false,
      );

      final results = await policy.push([_item('photo-item', attachments: _photo)]);

      expect(inner.calls, hasLength(1));
      expect(results.single.outcome, SyncItemOutcome.success);
    });
  });
}
