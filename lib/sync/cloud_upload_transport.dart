import 'dart:io';

import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:path/path.dart' as p;

import '../features/cloud/domain/cloud_storage_provider.dart';

/// [SyncTransport] for the `cloud_export` branch — uploads a queued day
/// PDF/GPX via [CloudStorageProvider]. Lives entirely in the app, same as
/// `StrapiTransport`/`RestTransport`: `hmb_core` never sees Google Drive.
///
/// Wrapped in its own `SyncPolicyTransport` in `sync_provider.dart` (gated
/// on `settings.cloudEnabled`, not `settings.enabled`) — see
/// `docs/plan_cloud_export.md` §1 for why the two branches must never share
/// one policy instance.
class CloudUploadTransport implements SyncTransport {
  CloudUploadTransport({required CloudStorageProvider provider}) : _provider = provider;

  final CloudStorageProvider _provider;

  @override
  // A handful of files a day — no bulk endpoint to batch against, same
  // reasoning as StrapiTransport/RestTransport.
  int get batchSize => 1;

  @override
  Future<bool> isReachable() async => true;

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async {
    // Never call anything that might restore/authenticate a session from
    // here — this runs on a background sync tick (periodic timer,
    // connectivity restore), not a foreground user action. On this app's
    // Android/Credential Manager combination, even the SDK's "silent"
    // restore path can show an account-picker sheet when no in-memory
    // session exists (docs/HANDOVER.md, 20. 7.); doing that from a
    // background tick would be exactly the unprompted-popup bug already
    // fixed once for the settings screen. `isSignedInNow` is a plain
    // in-memory check, never touches the SDK.
    if (!_provider.isSignedInNow) {
      return [for (final item in batch) _deferred(item, 'cloud storage not signed in')];
    }
    return [for (final item in batch) await _pushOne(item)];
  }

  Future<SyncItemResult> _pushOne(OutboxItem item) async {
    if (item.attachments.isEmpty) {
      return SyncItemResult(
        itemId: item.id,
        outcome: SyncItemOutcome.failure,
        retryable: false,
        errorMessage: 'cloud_export item "${item.id}" has no attachment to upload',
      );
    }
    final attachment = item.attachments.first;
    final folderPath = (item.payload['folder'] as List?)?.cast<String>() ?? const <String>[];

    try {
      final fileId = await _provider.upload(
        file: File(attachment.localPath),
        fileName: p.basename(attachment.localPath),
        folderPath: folderPath,
        mimeType: attachment.mimeType,
      );
      return SyncItemResult(itemId: item.id, outcome: SyncItemOutcome.success, remoteId: fileId);
    } on StateError catch (e) {
      // GoogleDriveStorage.upload() throws this specifically for "not
      // signed in" — shouldn't normally be reachable past the
      // isSignedInNow gate above, but a sign-out racing this push is
      // possible, so treat it the same way rather than as a hard failure.
      return _deferred(item, e.toString());
    } catch (e) {
      return SyncItemResult(
        itemId: item.id,
        outcome: SyncItemOutcome.failure,
        retryable: true,
        errorMessage: e.toString(),
      );
    }
  }

  SyncItemResult _deferred(OutboxItem item, String reason) => SyncItemResult(
        itemId: item.id,
        outcome: SyncItemOutcome.deferred,
        errorMessage: reason,
      );
}
