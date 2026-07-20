import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/core/models/sync_settings.dart';
import 'package:hmb_sailing_log/sync/routing_transport.dart';
import 'package:hmb_sailing_log/sync/sync_entity_types.dart';
import 'package:hmb_sailing_log/sync/sync_policy_transport.dart';

/// Records every item it's asked to push and reports them all as success —
/// stands in for `CloudUploadTransport` on one side and
/// `StrapiTransport`/`RestTransport` on the other, since this test is about
/// routing + policy gating, not either transport's own upload logic (those
/// have their own tests).
class _RecordingTransport implements SyncTransport {
  final List<OutboxItem> pushed = [];
  var reachable = true;

  @override
  int get batchSize => 1;

  @override
  Future<bool> isReachable() async => reachable;

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async {
    pushed.addAll(batch);
    return [for (final item in batch) SyncItemResult(itemId: item.id, outcome: SyncItemOutcome.success)];
  }
}

OutboxItem _item(String id, String entityType) => OutboxItem(
      id: id,
      entityType: entityType,
      operation: SyncOperation.create,
      payload: const {},
      createdAt: DateTime.now().toUtc(),
    );

void main() {
  test('cloud_export goes to the cloud branch, everything else to default', () async {
    final cloudInner = _RecordingTransport();
    final defaultInner = _RecordingTransport();
    final transport = RoutingTransport(cloudTransport: cloudInner, defaultTransport: defaultInner);

    final cloudItem = _item('cloud-1', SyncEntityType.cloudExport);
    final logItem = _item('log-1', SyncEntityType.logEntry);

    final results = await transport.push([cloudItem, logItem]);

    expect(cloudInner.pushed.map((i) => i.id), [cloudItem.id]);
    expect(defaultInner.pushed.map((i) => i.id), [logItem.id]);
    expect(results, hasLength(2));
    expect(results.every((r) => r.outcome == SyncItemOutcome.success), isTrue);
  });

  test('isReachable is true if at least one branch is reachable', () async {
    final cloudInner = _RecordingTransport()..reachable = false;
    final defaultInner = _RecordingTransport()..reachable = true;
    final transport = RoutingTransport(cloudTransport: cloudInner, defaultTransport: defaultInner);

    expect(await transport.isReachable(), isTrue);
  });

  test('isReachable is false only when both branches are unreachable', () async {
    final cloudInner = _RecordingTransport()..reachable = false;
    final defaultInner = _RecordingTransport()..reachable = false;
    final transport = RoutingTransport(cloudTransport: cloudInner, defaultTransport: defaultInner);

    expect(await transport.isReachable(), isFalse);
  });

  test(
      'key test: disabling backend sync does not stop cloud export, and vice '
      'versa — because each branch has its own SyncPolicyTransport', () async {
    final cloudInner = _RecordingTransport();
    final defaultInner = _RecordingTransport();

    // Backend sync disabled, cloud export enabled.
    final backendDisabled = SyncPolicyTransport(
      inner: defaultInner,
      isSyncEnabled: () => false,
      attachmentPolicy: () => AttachmentSyncPolicy.always,
      isOnWifi: () async => true,
    );
    final cloudEnabled = SyncPolicyTransport(
      inner: cloudInner,
      isSyncEnabled: () => true,
      attachmentPolicy: () => AttachmentSyncPolicy.always,
      isOnWifi: () async => true,
    );
    final transport = RoutingTransport(cloudTransport: cloudEnabled, defaultTransport: backendDisabled);

    final cloudItem = _item('cloud-1', SyncEntityType.cloudExport);
    final logItem = _item('log-1', SyncEntityType.logEntry);
    final results = await transport.push([cloudItem, logItem]);

    final cloudResult = results.firstWhere((r) => r.itemId == cloudItem.id);
    final logResult = results.firstWhere((r) => r.itemId == logItem.id);
    expect(cloudResult.outcome, SyncItemOutcome.success,
        reason: 'cloud export must keep running while backend sync is off');
    expect(logResult.outcome, SyncItemOutcome.deferred,
        reason: 'disabled backend sync must defer, not reach the transport');
    expect(defaultInner.pushed, isEmpty, reason: 'disabled policy must never call push at all');

    // And the reverse: backend enabled, cloud disabled.
    final backendEnabled = SyncPolicyTransport(
      inner: _RecordingTransport(),
      isSyncEnabled: () => true,
      attachmentPolicy: () => AttachmentSyncPolicy.always,
      isOnWifi: () async => true,
    );
    final cloudDisabled = SyncPolicyTransport(
      inner: _RecordingTransport(),
      isSyncEnabled: () => false,
      attachmentPolicy: () => AttachmentSyncPolicy.always,
      isOnWifi: () async => true,
    );
    final reverseTransport =
        RoutingTransport(cloudTransport: cloudDisabled, defaultTransport: backendEnabled);
    final reverseResults = await reverseTransport.push([_item('cloud-2', SyncEntityType.cloudExport), _item('log-2', SyncEntityType.logEntry)]);

    expect(
      reverseResults.firstWhere((r) => r.itemId == 'cloud-2').outcome,
      SyncItemOutcome.deferred,
    );
    expect(
      reverseResults.firstWhere((r) => r.itemId == 'log-2').outcome,
      SyncItemOutcome.success,
    );
  });
}
