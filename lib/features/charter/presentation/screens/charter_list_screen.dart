import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../../bearing/providers/bearing_provider.dart';
import '../../providers/charter_provider.dart';
import '../../services/voyage_progress.dart';
import '../../../tracking/providers/tracking_provider.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../widgets/voyage_reminder_chips.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import '../../../../core/utils/localized_date.dart';

/// Jeden riadok zoznamu plavieb: buď plavba, alebo relácia zameraní zapísaná
/// mimo trackingu. Zámerne v tom istom zozname a zoradené podľa dátumu — pre
/// skipera je to jeden chronologický záznam toho, čo robil na vode, nie dve
/// oddelené miesta, kde treba hľadať.
sealed class _LogbookRow {
  DateTime get sortDate;
}

class _CharterRow extends _LogbookRow {
  final Charter charter;
  _CharterRow(this.charter);
  @override
  DateTime get sortDate => charter.dateFrom;
}

class _BearingSessionRow extends _LogbookRow {
  final BearingSession session;
  _BearingSessionRow(this.session);
  @override
  DateTime get sortDate => session.date;
}

class CharterListScreen extends ConsumerWidget {
  const CharterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartersAsync = ref.watch(chartersProvider);
    final sessions = ref.watch(orphanBearingSessionsProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HMB Sailing Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech_outlined),
            tooltip: l.milesBookTitle,
            onPressed: () => context.push('/miles'),
          ),
        ],
      ),
      body: chartersAsync.when(
        data: (charters) {
          if (charters.isEmpty && sessions.isEmpty) return const _EmptyState();
          final rows = <_LogbookRow>[
            for (final c in charters) _CharterRow(c),
            for (final s in sessions) _BearingSessionRow(s),
          ]..sort((a, b) => b.sortDate.compareTo(a.sortDate));
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: rows.length,
            itemBuilder: (ctx, i) => switch (rows[i]) {
              _CharterRow(:final charter) => _CharterCard(charter: charter),
              _BearingSessionRow(:final session) =>
                _BearingSessionCard(session: session),
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

// ── Bearing session card ─────────────────────────────────────

class _BearingSessionCard extends ConsumerWidget {
  final BearingSession session;
  const _BearingSessionCard({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = AppDate.of(context, ref);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(
            '/logbook/bearings/${DateFormat('yyyy-MM-dd').format(session.date)}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.architecture, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.bearingsTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(fmt.medium(session.date),
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Text(l.bearingSightCount(session.bearings.length),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      ),
    );
  }
}

// ── Charter Card ──────────────────────────────────────────────

class _CharterCard extends ConsumerWidget {
  final Charter charter;
  const _CharterCard({required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = AppDate.of(context, ref);
    final days = charter.dateTo.difference(charter.dateFrom).inDays + 1;
    final isNew = ref.watch(voyageProgressProvider(charter.id))
        .maybeWhen(data: (p) => p.isNew, orElse: () => false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/logbook/${charter.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isNew)
                        Text(AppLocalizations.of(context).newVoyage,
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600)),
                      Text(charter.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') context.go('/logbook/${charter.id}/edit');
                    if (v == 'delete') {
                      final l = AppLocalizations.of(context);
                      // Block delete only when this charter is actively being tracked
                      final isTracking = ref.read(isTrackingProvider);
                      if (isTracking) {
                        final activeDayLogId = GpsTrackingService().activeDayLogId;
                        if (activeDayLogId != null) {
                          final days = await ref.read(databaseProvider).getDayLogs(charter.id);
                          if (days.any((d) => d.id == activeDayLogId)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(l.cannotDeleteWhileTracking),
                                backgroundColor: Colors.red,
                              ));
                            }
                            return;
                          }
                        }
                      }
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.deleteCharterTitle),
                          content: Text(l.deleteCharterContent),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l.delete),
                            ),
                          ],
                        ),
                      ) ?? false;
                      if (ok) {
                        try {
                          debugPrint('[DELETE] Mazanie chartera ${charter.id}');
                          await ref.read(databaseProvider).deleteCharter(charter.id);
                          debugPrint('[DELETE] Úspech');
                          ref.invalidate(chartersProvider);
                        } catch (e, st) {
                          debugPrint('[DELETE] Chyba: $e\n$st');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: Colors.red));
                          }
                        }
                      }
                    }
                  },
                  itemBuilder: (ctx) {
                    final l = AppLocalizations.of(ctx);
                    return [
                      PopupMenuItem(value: 'edit',
                          child: ListTile(leading: const Icon(Icons.edit), title: Text(l.edit), contentPadding: EdgeInsets.zero)),
                      PopupMenuItem(value: 'delete',
                          child: ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: Text(l.delete, style: const TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
                    ];
                  },
                ),
              ]),
              const SizedBox(height: 4),
              Text('${fmt.medium(charter.dateFrom)} – ${fmt.medium(charter.dateTo)}  ·  ${AppLocalizations.of(context).daysCount(days)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              if (charter.vesselName != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.directions_boat, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(charter.vesselName!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ]),
              ],
              if (charter.skipperName != null) ...[
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(charter.skipperName!,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ]),
              ],
              const SizedBox(height: 8),
              Row(children: [
                _Badge(
                  charter.safetyBriefingDone
                      ? AppLocalizations.of(context).briefingDone
                      : AppLocalizations.of(context).briefingPending,
                  charter.safetyBriefingDone ? Colors.green : Colors.red,
                ),
                if (charter.checkInDone) ...[
                  _Badge(AppLocalizations.of(context).checkInDone, Colors.blue),
                ],
                if (charter.checkOutDone) ...[
                  _Badge(AppLocalizations.of(context).checkOutDone, Colors.orange),
                ],
              ]),
              VoyageReminderChips(charterId: charter.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.directions_boat_outlined, size: 72, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(l.noVoyages, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        Text(l.createFirstCharter, style: const TextStyle(color: Colors.grey)),
      ]),
    );
  }
}
