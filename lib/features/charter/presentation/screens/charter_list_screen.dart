import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class CharterListScreen extends ConsumerWidget {
  const CharterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartersAsync = ref.watch(chartersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('HMB Sailing Log')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/logbook/new'),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).newMultidayVoyage),
      ),
      body: chartersAsync.when(
        data: (charters) => charters.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: charters.length,
                itemBuilder: (ctx, i) => _CharterCard(charter: charters[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _CharterCard extends ConsumerWidget {
  final Charter charter;
  const _CharterCard({required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('d. MMM yyyy', 'sk');
    final days = charter.dateTo.difference(charter.dateFrom).inDays + 1;

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
                  child: Text(charter.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') context.go('/logbook/${charter.id}/edit');
                    if (v == 'delete') {
                      final l = AppLocalizations.of(context);
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
                          await ref.read(databaseProvider).deleteCharter(charter.id);
                          ref.invalidate(chartersProvider);
                        } catch (e) {
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
              Text('${fmt.format(charter.dateFrom)} – ${fmt.format(charter.dateTo)}  ·  $days dní',
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
                if (charter.safetyBriefingDone) ...[
                  _Badge(AppLocalizations.of(context).briefingDone, Colors.green),
                ],
                if (charter.checkInDone) ...[
                  _Badge(AppLocalizations.of(context).checkInDone, Colors.blue),
                ],
                if (charter.checkOutDone) ...[
                  _Badge(AppLocalizations.of(context).checkOutDone, Colors.orange),
                ],
              ]),
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
