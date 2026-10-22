
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/charter_source.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../charter/presentation/screens/charter_edit_screen.dart'
    show CharterPrefill;
import '../../providers/miles_provider.dart';
import '../../services/miles_calculator.dart';
import '../../../../core/services/units_service.dart';
import '../../../../core/utils/localized_date.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../main.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../../tracking/providers/tracking_provider.dart';

class MilesBookScreen extends ConsumerWidget {
  const MilesBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final aggregateAsync = ref.watch(milesAggregateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.milesBookTitle),
      ),
      body: aggregateAsync.when(
        data: (agg) => _MilesBody(aggregate: agg),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _chooseKind(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.addHistoricalVoyage),
      ),
    );
  }

  /// A historical voyage is either a bare summary (miles and dates) or a
  /// transcription of the paper logbook, day by day.
  Future<void> _chooseKind(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: Text(l.milesAddSummary),
            subtitle: Text(l.milesAddSummaryHint),
            onTap: () => Navigator.pop(ctx, 'summary'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(l.milesAddPaperVoyage),
            subtitle: Text(l.milesAddPaperVoyageHint),
            onTap: () => Navigator.pop(ctx, 'paper'),
          ),
        ]),
      ),
    );
    if (!context.mounted) return;
    if (choice == 'summary') {
      context.push('/miles/historical/new');
    } else if (choice == 'paper') {
      await _createPaperVoyage(context, ref);
    }
  }

  /// Opens the ordinary new-voyage form and marks the result as written
  /// after the fact, so it never asks for check-in/out or receives live
  /// events. Offers a GPX file right away, since that rebuilds the days.
  Future<void> _createPaperVoyage(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final charter = await context.push<Charter>(
      '/logbook/new',
      extra: CharterPrefill(title: '', dateFrom: now, dateTo: now),
    );
    if (charter == null) return;

    final db = ref.read(databaseProvider);
    await db.updateCharter(ChartersCompanion(
      id: Value(charter.id),
      source: const Value(CharterSource.paper),
    ));
    ref.invalidate(milesAggregateProvider);
    ref.invalidate(milesAvailableYearsProvider);
    ref.invalidate(chartersProvider);
    ref.invalidate(activeChartersProvider);

    if (!context.mounted) return;
    final attach = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.paperVoyageGpxTitle),
        content: Text(l.paperVoyageGpxBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text(l.yes)),
        ],
      ),
    );
    if (!context.mounted) return;
    if (attach == true) {
      await context.push('/gpx-import', extra: charter.id);
      ref.invalidate(milesAggregateProvider);
      ref.invalidate(milesAvailableYearsProvider);
      ref.invalidate(chartersProvider);
    }
    // Days and entries are added on the voyage itself.
    if (context.mounted) context.push('/logbook/${charter.id}');
  }
}

class _MilesBody extends ConsumerWidget {
  final MilesAggregate aggregate;
  const _MilesBody({required this.aggregate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final filter = ref.watch(milesFilterProvider);
    final yearsAsync = ref.watch(milesAvailableYearsProvider);
    final fmt = AppDate.of(context, ref);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        yearsAsync.when(
          data: (years) => Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(
              label: Text(l.filterAllYears),
              selected: filter.year == null,
              onSelected: (_) =>
                  ref.read(milesFilterProvider.notifier).state = const MilesFilter(),
            ),
            for (final y in years)
              ChoiceChip(
                label: Text('$y'),
                selected: filter.year == y,
                onSelected: (_) =>
                    ref.read(milesFilterProvider.notifier).state = MilesFilter(year: y),
              ),
          ]),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: _StatTile(
              label: l.totalNm, value: aggregate.totalNm.toStringAsFixed(1), icon: Icons.straighten)),
          Expanded(child: _StatTile(
              label: l.daysAtSea, value: '${aggregate.daysAtSea}', icon: Icons.calendar_month)),
        ]),
        Row(children: [
          Expanded(child: _StatTile(
              label: l.voyageCount, value: '${aggregate.voyageCount}', icon: Icons.sailing)),
          Expanded(child: _StatTile(
              label: l.nightHoursLabel, value: aggregate.nightHours.toStringAsFixed(1),
              icon: Icons.dark_mode_outlined)),
        ]),
        const SizedBox(height: 16),

        if (aggregate.nmByYear.isNotEmpty) ...[
          _SectionTitle(l.byYear),
          ...(aggregate.nmByYear.keys.toList()..sort((a, b) => b.compareTo(a)))
              .map((y) => _BreakdownRow(label: '$y', nm: aggregate.nmByYear[y]!)),
          const SizedBox(height: 16),
        ],

        if (aggregate.nmByVessel.isNotEmpty) ...[
          _SectionTitle(l.byVessel),
          ...(aggregate.nmByVessel.keys.toList()..sort())
              .map((v) => _BreakdownRow(label: v, nm: aggregate.nmByVessel[v]!)),
          const SizedBox(height: 16),
        ],

        _SectionTitle(l.milesBookTitle),
        ...aggregate.voyages.map((v) => Card(
              child: ListTile(
                leading: Icon(v.isManualEntry ? Icons.edit_note : Icons.sailing),
                title: Text(
                    '${v.isManualEntry ? "* " : ""}${v.vesselName}  ·  ${ref.watch(unitsSyncProvider).formatDistance(v.distanceNm, decimals: 1)}'),
                subtitle: Text(
                    '${fmt.short(v.dateFrom)} – ${fmt.short(v.dateTo)}'
                    '${v.area != null ? " · ${v.area}" : ""}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'delete') _delete(context, ref, v);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l.delete),
                    ),
                  ],
                ),
                onTap: v.isManualEntry
                    ? () => context.push('/miles/historical/${v.historicalVoyageId}/edit')
                    : () => context.push('/miles/charter/${v.charterId}/logbook'),
              ),
            )),
        if (aggregate.voyages.any((v) => v.isManualEntry)) ...[
          const SizedBox(height: 8),
          Text(l.manualEntryExplanation,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  /// Deletes a voyage from the book: a manual entry removes its row, a
  /// recorded voyage removes the whole charter with its days and entries.
  Future<void> _delete(BuildContext context, WidgetRef ref, VoyageRow v) async {
    final l = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);
    final charterId = v.charterId;

    if (!v.isManualEntry && charterId != null && ref.read(isTrackingProvider)) {
      final activeDayLogId = GpsTrackingService().activeDayLogId;
      if (activeDayLogId != null) {
        final days = await db.getDayLogs(charterId);
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

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(v.isManualEntry ? l.delete : l.deleteCharterTitle),
        content: Text(v.isManualEntry
            ? l.deleteHistoricalVoyageConfirm
            : l.deleteCharterContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final historicalId = v.historicalVoyageId;
      if (v.isManualEntry && historicalId != null) {
        await db.deleteHistoricalVoyage(historicalId);
      } else if (charterId != null) {
        await db.deleteCharter(charterId);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }
    ref.invalidate(milesAggregateProvider);
    ref.invalidate(historicalVoyagesProvider);
    ref.invalidate(milesAvailableYearsProvider);
    ref.invalidate(chartersProvider);
    ref.invalidate(activeChartersProvider);
    ref.invalidate(archivedChartersProvider);

    // A year filter whose last voyage was just deleted would leave an empty
    // list with no chip to switch back from.
    final year = ref.read(milesFilterProvider).year;
    if (year != null) {
      final years = await ref.read(milesAvailableYearsProvider.future);
      if (!years.contains(year)) {
        ref.read(milesFilterProvider.notifier).state = const MilesFilter();
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
      );
}

class _BreakdownRow extends ConsumerWidget {
  final String label;
  final double nm;
  const _BreakdownRow({required this.label, required this.nm});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(label),
          const Spacer(),
          Text(ref.watch(unitsSyncProvider).formatDistance(nm, decimals: 1),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ])),
          ]),
        ),
      );
}
