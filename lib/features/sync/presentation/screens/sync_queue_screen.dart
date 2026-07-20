import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../main.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final itemsAsync = ref.watch(syncQueueItemsProvider);
    final snapshot = ref.watch(syncQueueSnapshotProvider).valueOrNull;
    final engine = ref.watch(syncEngineProvider);
    final allowMobileData = ref.watch(allowMobileDataForAttachmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.syncQueueTitle),
        actions: [
          IconButton(
            tooltip: l.syncNowAction,
            icon: (snapshot?.isSyncing ?? false)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: (snapshot?.isSyncing ?? false)
                ? null
                : () => engine.syncNow(),
          ),
          IconButton(
            tooltip: l.syncClearQueueAction,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _confirmClearQueue(context, ref, l),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('$e')),
        data: (rows) {
          final sorted = [...rows]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          final failedCount =
              sorted.where((r) => r.status == SyncStatus.failed.name).length;
          final waitingForWifi = !allowMobileData &&
              sorted.any((r) =>
                  r.status == SyncStatus.deferred.name &&
                  (r.errorMessage?.contains('Wi-Fi policy') ?? false));

          return Column(children: [
            if (waitingForWifi)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const Icon(Icons.wifi_off, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.syncWifiOverrideBanner)),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(allowMobileDataForAttachmentsProvider.notifier)
                              .state = true;
                          engine.syncNow();
                        },
                        child: Text(l.syncWifiOverrideAction),
                      ),
                    ]),
                  ),
                ),
              )
            else if (allowMobileData)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(children: [
                  Icon(Icons.signal_cellular_alt,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.syncWifiOverrideActive,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ),
                ]),
              ),
            if (failedCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => engine.retryFailed(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l.syncRetryFailedAction),
                  ),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: sorted.isEmpty
                    ? _EmptyState(key: const ValueKey('empty'), l: l)
                    : ListView.separated(
                        key: const ValueKey('list'),
                        padding: const EdgeInsets.all(16),
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _QueueItemTile(row: sorted[i], l: l),
                      ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Future<void> _confirmClearQueue(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.syncClearQueueConfirmTitle),
            content: Text(l.syncClearQueueConfirmContent),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await ref.read(databaseProvider).deleteAllOutboxRows();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.syncClearQueueDone)));
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(l.syncQueueEmpty, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
}

class _QueueItemTile extends StatelessWidget {
  const _QueueItemTile({required this.row, required this.l});
  final OutboxRow row;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final status = SyncStatus.values.byName(row.status);
    final (icon, color, label) = switch (status) {
      SyncStatus.pending => (Icons.schedule, Colors.blueGrey, l.syncStatusPending),
      SyncStatus.sending => (Icons.upload, Colors.blue, l.syncStatusSending),
      SyncStatus.sent => (Icons.check_circle, Colors.green, l.syncStatusSent),
      SyncStatus.failed => (Icons.error_outline, Colors.red, l.syncStatusFailed),
      SyncStatus.conflict => (Icons.warning_amber, Colors.orange, l.syncStatusConflict),
      // Held back by a local policy (sync disabled, Wi-Fi-only attachments),
      // never a real attempt — not the same as "failed". No retry count:
      // it's never spent for this status. The specific reason (which
      // policy) shows in the errorMessage line below, same as other
      // statuses.
      SyncStatus.deferred =>
        (Icons.pause_circle_outline, Colors.blueGrey, l.syncStatusDeferred),
    };

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(row.entityType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status == SyncStatus.deferred
                  ? label
                  : '$label · ${l.syncRetryCount(row.retryCount)}',
            ),
            if (row.errorMessage != null)
              Text(
                row.errorMessage!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        isThreeLine: row.errorMessage != null,
      ),
    );
  }
}
