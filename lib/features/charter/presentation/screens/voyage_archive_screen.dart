import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import '../../../../core/utils/localized_date.dart';

/// Plavby, ktoré skiper ručne odložil z hlavného zoznamu Denníka.
///
/// Archivácia je vratná a nič nemaže — mapa, Kniha míľ a exporty na tejto
/// plavbe fungujú ďalej, len v hlavnom zozname už nezavadzia.
class VoyageArchiveScreen extends ConsumerWidget {
  const VoyageArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final archivedAsync = ref.watch(archivedChartersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.voyageArchiveTitle)),
      body: archivedAsync.when(
        data: (charters) {
          if (charters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.archive_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(l.voyageArchiveEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: charters.length,
            itemBuilder: (ctx, i) =>
                _ArchivedCharterCard(charter: charters[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _ArchivedCharterCard extends ConsumerWidget {
  final Charter charter;
  const _ArchivedCharterCard({required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = AppDate.of(context, ref);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/logbook/${charter.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(charter.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${fmt.medium(charter.dateFrom)} – ${fmt.medium(charter.dateTo)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (charter.vesselName != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.directions_boat,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(charter.vesselName!,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade700)),
                    ]),
                  ],
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await ref
                    .read(databaseProvider)
                    .setCharterArchived(charter.id, false);
                ref.invalidate(chartersProvider);
                ref.invalidate(activeChartersProvider);
                ref.invalidate(archivedChartersProvider);
              },
              icon: const Icon(Icons.unarchive_outlined, size: 18),
              label: Text(l.unarchiveVoyage),
            ),
          ]),
        ),
      ),
    );
  }
}
