import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../main.dart';
import '../../sync/drift_outbox_record_store.dart';
import '../../sync/rest_transport.dart';
import '../../sync/strapi_transport.dart';
import '../../sync/sync_entity_types.dart';
import '../../sync/sync_policy_transport.dart';
import '../config/api_constants.dart';
import '../database/app_database.dart';
import '../models/sync_settings.dart';
import '../services/account_service.dart';
import '../services/gps_tracking_service.dart';
import 'sync_settings_provider.dart';

/// Shared so the sync engine and the queue-status UI observe the exact same
/// connectivity signal (one platform-channel listener, not two).
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityPlusService();
  ref.onDispose(service.dispose);
  return service;
});

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityServiceProvider);
  yield await connectivity.isOnline;
  yield* connectivity.onlineChanges;
});

final outboxRepositoryProvider = Provider<OutboxRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return OutboxRepository(store: DriftOutboxRecordStore(db));
});

Future<bool> _isOnWifi() async {
  final results = await Connectivity().checkConnectivity();
  return results.contains(ConnectivityResult.wifi);
}

/// A transport that always reports every item as a non-retryable failure —
/// used only when the custom-server URL is missing/invalid, so a bad
/// setting surfaces as "failed" in the queue instead of crashing provider
/// construction (`RestTransport` throws on a non-HTTPS/unparsable URL).
class _MisconfiguredTransport implements SyncTransport {
  @override
  int get batchSize => 1;

  @override
  Future<bool> isReachable() async => false;

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async => [
        for (final item in batch)
          SyncItemResult(
            itemId: item.id,
            outcome: SyncItemOutcome.failure,
            retryable: false,
            errorMessage:
                'custom sync server URL is missing or invalid (must be HTTPS)',
          ),
      ];
}

SyncTransport _buildBaseTransport(
  SyncSettings settings,
  String appVersion,
  String Function() customAuthToken,
) {
  switch (settings.target) {
    case SyncTarget.hmbAcademy:
      return StrapiTransport(
        baseUrl: kApiBase,
        authToken: () => AccountService().token ?? '',
        collectionByEntityType: kDefaultStrapiCollections,
        appVersion: appVersion,
      );
    case SyncTarget.custom:
      try {
        return RestTransport(
          baseUrl: settings.customUrl,
          authToken: customAuthToken,
          appVersion: appVersion,
        );
      } catch (_) {
        return _MisconfiguredTransport();
      }
  }
}

/// The transport actually used for a sync cycle: picked per
/// [SyncSettings.target] and wrapped with the enabled/attachment-policy
/// gates hmb_core doesn't know about. Rebuilds whenever settings change;
/// the custom token itself is re-read fresh on every push (via `ref.read`
/// in the closure below), not baked in at construction, so saving/clearing
/// it doesn't require rebuilding this provider.
final syncTransportProvider = Provider<SyncTransport>((ref) {
  final settings = ref.watch(syncSettingsProvider).valueOrNull ?? const SyncSettings();
  final appVersion = ref.watch(appVersionProvider);

  return SyncPolicyTransport(
    inner: _buildBaseTransport(
      settings,
      appVersion,
      () => ref.read(syncCustomTokenProvider).valueOrNull ?? '',
    ),
    isSyncEnabled: () => settings.enabled,
    attachmentPolicy: () => settings.attachmentPolicy,
    isOnWifi: _isOnWifi,
  );
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final settings = ref.watch(syncSettingsProvider).valueOrNull ?? const SyncSettings();
  final engine = SyncEngine(
    repository: ref.watch(outboxRepositoryProvider),
    transport: ref.watch(syncTransportProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    config: SyncConfig(periodicRetry: Duration(minutes: settings.intervalMinutes)),
  );
  // No background/foreground service, no WorkManager — this timer only
  // runs while the app process is alive, by design (see docs/SYNC_API.md).
  if (settings.enabled) engine.start();
  ref.onDispose(engine.dispose);

  // GpsTrackingService is a plain singleton outside Riverpod (no `ref` of
  // its own) — this is the one place it can be handed the live engine, and
  // it re-runs whenever this provider rebuilds (e.g. settings change swaps
  // the transport), so it never holds a stale/disposed engine.
  GpsTrackingService().setSyncEngine(engine, () => settings.enabled);

  return engine;
});

final syncQueueSnapshotProvider = StreamProvider<SyncQueueSnapshot>((ref) {
  return ref.watch(syncEngineProvider).queue;
});

/// Full item list for the queue screen (counts alone aren't enough to
/// render rows) — reads the drift table directly rather than adding a
/// list-returning method to hmb_core's OutboxRepository.
final syncQueueItemsProvider = StreamProvider<List<OutboxRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllOutboxRows();
});
