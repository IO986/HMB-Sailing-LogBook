import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/sync_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final itemsAsync = ref.watch(syncQueueItemsProvider);
    final snapshot = ref.watch(syncQueueSnapshotProvider).valueOrNull;
    final engine = ref.watch(syncEngineProvider);

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

          return Column(children: [
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
    };

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(row.entityType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label · ${l.syncRetryCount(row.retryCount)}'),
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
