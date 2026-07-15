import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../core/providers/sync_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Persistent header strip: "● offline · 3 čakajú". Hidden (animated away)
/// when there is nothing to report — online, nothing pending, nothing
/// failed. Tapping it opens the full queue screen.
class SyncQueueBadge extends ConsumerWidget {
  const SyncQueueBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final snapshot = ref.watch(syncQueueSnapshotProvider).valueOrNull;
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;

    final visible = snapshot != null &&
        (!online ||
            snapshot.pending > 0 ||
            snapshot.failed > 0 ||
            snapshot.conflicts > 0 ||
            snapshot.deferred > 0);

    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        heightFactor: visible ? 1 : 0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: visible ? 1 : 0,
          child: snapshot == null
              ? const SizedBox.shrink()
              : _BadgeContent(snapshot: snapshot, online: online, l: l),
        ),
      ),
    );
  }
}

class _BadgeContent extends StatelessWidget {
  const _BadgeContent({
    required this.snapshot,
    required this.online,
    required this.l,
  });

  final SyncQueueSnapshot snapshot;
  final bool online;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final segments = <String>[
      if (!online) l.syncOffline,
      if (snapshot.pending > 0) l.syncPendingCount(snapshot.pending),
      // Distinct from "pending"/"failed" — held back by a local policy
      // (sync disabled, Wi-Fi-only attachments), not an attempt that
      // happened and didn't work.
      if (snapshot.deferred > 0) l.syncDeferredCount(snapshot.deferred),
      if (snapshot.failed > 0) l.syncFailedCount(snapshot.failed),
    ];

    final color = snapshot.failed > 0
        ? Colors.red.shade700
        : (!online ? Colors.blueGrey.shade700 : Colors.blue.shade700);

    return Material(
      color: color,
      child: InkWell(
        onTap: () => context.push('/sync-queue'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration:
                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(
                segments.join(' · '),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (snapshot.isSyncing)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
          ]),
        ),
      ),
    );
  }
}
