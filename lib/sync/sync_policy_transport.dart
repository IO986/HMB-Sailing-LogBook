import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../core/models/sync_settings.dart';

/// Wraps a real [SyncTransport] with app-level policy gates hmb_core itself
/// knows nothing about: the user's enable/disable toggle, and the
/// attachment Wi-Fi policy.
///
/// Skipped items come back as [SyncItemOutcome.deferred], not `failure` —
/// they were never actually attempted, so they cost nothing against
/// `retryCount` and are retried again next cycle without limit, until the
/// gate clears. See docs/SYNC_API.md §7.
class SyncPolicyTransport implements SyncTransport {
  SyncPolicyTransport({
    required SyncTransport inner,
    required bool Function() isSyncEnabled,
    required AttachmentSyncPolicy Function() attachmentPolicy,
    required Future<bool> Function() isOnWifi,
  })  : _inner = inner,
        _isSyncEnabled = isSyncEnabled,
        _attachmentPolicy = attachmentPolicy,
        _isOnWifi = isOnWifi;

  final SyncTransport _inner;
  final bool Function() _isSyncEnabled;
  final AttachmentSyncPolicy Function() _attachmentPolicy;
  final Future<bool> Function() _isOnWifi;

  @override
  int get batchSize => _inner.batchSize;

  @override
  Future<bool> isReachable() async => _isSyncEnabled() && await _inner.isReachable();

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async {
    if (!_isSyncEnabled()) {
      return [for (final item in batch) _skip(item, 'sync is disabled')];
    }

    final policy = _attachmentPolicy();
    final allowAttachments = switch (policy) {
      AttachmentSyncPolicy.never => false,
      AttachmentSyncPolicy.always => true,
      AttachmentSyncPolicy.wifiOnly => await _isOnWifi(),
    };

    final toSend = <OutboxItem>[];
    final skipped = <OutboxItem>[];
    for (final item in batch) {
      if (item.attachments.isNotEmpty && !allowAttachments) {
        skipped.add(item);
      } else {
        toSend.add(item);
      }
    }

    final sent = toSend.isEmpty ? <SyncItemResult>[] : await _inner.push(toSend);
    return [
      ...sent,
      for (final item in skipped)
        _skip(item, 'attachment sync deferred by local Wi-Fi policy'),
    ];
  }

  SyncItemResult _skip(OutboxItem item, String reason) => SyncItemResult(
        itemId: item.id,
        outcome: SyncItemOutcome.deferred,
        errorMessage: reason,
      );
}
