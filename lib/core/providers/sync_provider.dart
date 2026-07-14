import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../main.dart';
import '../../sync/drift_outbox_record_store.dart';
import '../../sync/strapi_transport.dart';
import '../config/api_constants.dart';
import '../database/app_database.dart';
import '../services/account_service.dart';

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

/// TODO: `baseUrl`/`collectionByEntityType` are placeholders until the
/// Strapi CMS is provisioned, and nothing in the app calls `enqueue()` yet —
/// domain writes (logbook entries, quick-photo) still go straight to drift.
/// This wiring only makes the queue UI (badge + queue screen) functional
/// and ready to observe/drive once that's connected.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    repository: ref.watch(outboxRepositoryProvider),
    transport: StrapiTransport(
      baseUrl: kApiBase,
      authToken: () => AccountService().token ?? '',
      collectionByEntityType: const {'logbook_entry': 'logbook-entries'},
    ),
    connectivity: ref.watch(connectivityServiceProvider),
  );
  engine.start();
  ref.onDispose(engine.dispose);
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
