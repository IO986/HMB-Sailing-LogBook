import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';
import '../../../../shared/widgets/port_autocomplete.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class CharterDetailScreen extends ConsumerWidget {
  final int charterId;
  const CharterDetailScreen({super.key, required this.charterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartersAsync = ref.watch(chartersProvider);
    final dayLogsAsync = ref.watch(dayLogsProvider(charterId));

    return chartersAsync.when(
      data: (charters) {
        Charter? charter;
        try { charter = charters.firstWhere((c) => c.id == charterId); }
        catch (_) { return Scaffold(body: Center(child: Text(AppLocalizations.of(context).voyageNotFound))); }

        return Scaffold(
          appBar: AppBar(
            title: Text(charter.title, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.health_and_safety_outlined),
                tooltip: AppLocalizations.of(context).briefingOpenBriefing,
                onPressed: () => context.go('/logbook/$charterId/briefing'),
              ),
              IconButton(icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/logbook/$charterId/edit')),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => context.go('/logbook/$charterId/export'),
              ),
            ],
          ),
          body: dayLogsAsync.when(
            data: (days) => _Body(charter: charter!, days: days),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}

class _Body extends ConsumerWidget {
  final Charter charter;
  final List<DayLog> days;
  const _Body({required this.charter, required this.days});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmtRange = DateFormat('d. MMM yyyy', 'sk');
    final crew = (charter.crewNames ?? '').split('|').where((s) => s.isNotEmpty).toList();
    final totalNm = days.fold<double>(0, (s, d) => s + d.distanceNm);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Info karta
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.directions_boat, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(charter.vesselName ?? AppLocalizations.of(context).unknownVessel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              if (charter.vesselType != null)
                Text(charter.vesselType!,
                    style: TextStyle(color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 6),
            Text('${fmtRange.format(charter.dateFrom)} – ${fmtRange.format(charter.dateTo)}',
                style: TextStyle(color: Colors.grey.shade600)),
            if (charter.homePort != null)
              Text('⚓ ${charter.homePort}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const Divider(height: 16),
            if (charter.skipperName != null)
              _InfoRow(Icons.person, AppLocalizations.of(context).captain, charter.skipperName!),
            if (crew.isNotEmpty)
              _InfoRow(Icons.group, AppLocalizations.of(context).crew, crew.join(', ')),
            if (totalNm > 0)
              _InfoRow(Icons.straighten, AppLocalizations.of(context).total, '${totalNm.toStringAsFixed(1)} NM'),
            // Status badges
            if (charter.safetyBriefingDone || charter.checkInDone || charter.checkOutDone)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(spacing: 6, children: [
                  if (charter.safetyBriefingDone) _Badge(AppLocalizations.of(context).briefingDone, Colors.green),
                  if (charter.checkInDone) _Badge(AppLocalizations.of(context).checkInDone, Colors.blue),
                  if (charter.checkOutDone) _Badge(AppLocalizations.of(context).checkOutDone, Colors.orange),
                ]),
              ),
          ]),
        )),
        const SizedBox(height: 8),

        // Dni plavby
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(children: [
            Text(AppLocalizations.of(context).voyageDaysCount(days.length),
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (days.length > 1)
              TextButton.icon(
                onPressed: () => _deleteMultiple(context, ref),
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: Text(AppLocalizations.of(context).bulkDelete),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ]),
        ),

        if (days.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(
              AppLocalizations.of(context).noDays,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            )),
          ),

        ...days.map((d) => _DayCard(day: d, charterId: charter.id)),
        const SizedBox(height: 80),
      ],
    );
  }

  void _deleteMultiple(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _MultiDeleteDialog(
        days: days,
        onDelete: (ids) async {
          final db = ref.read(databaseProvider);
          await db.deleteDayLogs(ids);
          ref.invalidate(dayLogsProvider(charter.id));
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      Icon(icon, size: 15, color: Colors.grey),
      const SizedBox(width: 6),
      Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ]),
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: color,
        fontWeight: FontWeight.w600)),
  );
}

// ── Day Card ──────────────────────────────────────────────────

class _DayCard extends ConsumerWidget {
  final DayLog day;
  final int charterId;
  const _DayCard({required this.day, required this.charterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayName = DateFormat('EEEE d. MMMM yyyy', 'sk').format(day.date);
    final entriesAsync = ref.watch(logbookEntriesForDayProvider(day.id));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/logbook/$charterId/day/${day.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(dayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'delete') {
                    final l = AppLocalizations.of(context);
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l.deleteDayTitle),
                        content: Text(l.deleteDayContent(dayName)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l.no)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l.delete),
                          ),
                        ],
                      ),
                    ) ?? false;
                    if (ok) {
                      await ref.read(databaseProvider).deleteDayLog(day.id);
                      ref.invalidate(dayLogsProvider(charterId));
                    }
                  }
                  if (v == 'export')
                    context.go('/logbook/$charterId/day/${day.id}/export');
                },
                itemBuilder: (ctx) {
                  final l = AppLocalizations.of(ctx);
                  return [
                    PopupMenuItem(value: 'export',
                      child: ListTile(leading: const Icon(Icons.picture_as_pdf),
                          title: Text(l.exportPdf), contentPadding: EdgeInsets.zero)),
                    PopupMenuItem(value: 'delete',
                      child: ListTile(leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(l.delete, style: const TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero)),
                  ];
                },
              ),
            ]),

            // Trasa
            if (day.portFrom != null || day.portTo != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.anchor, size: 13, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('${day.portFrom ?? "?"}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward, size: 13)),
                  Text('${day.portTo ?? "?"}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (day.distanceNm > 0)
                    Text('  ·  ${day.distanceNm.toStringAsFixed(1)} NM',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
              ),

            const SizedBox(height: 6),
            Row(children: [
              if (day.beaufortNoon != null)
                _Chip('Bft ${day.beaufortNoon}', Icons.air),
              if (day.waveHeightM != null)
                _Chip('${day.waveHeightM!.toStringAsFixed(1)} m', Icons.waves),
              if (day.airTempC != null)
                _Chip('${day.airTempC!.toStringAsFixed(0)}°C', Icons.thermostat),
              entriesAsync.when(
                data: (e) => _Chip(AppLocalizations.of(context).entriesShort(e.length), Icons.list_alt),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip(this.label, this.icon);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11),
      const SizedBox(width: 3),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]),
  );
}

// ── Multi Delete Dialog ───────────────────────────────────────

class _MultiDeleteDialog extends StatefulWidget {
  final List<DayLog> days;
  final Function(List<int>) onDelete;
  const _MultiDeleteDialog({required this.days, required this.onDelete});

  @override
  State<_MultiDeleteDialog> createState() => _MultiDeleteDialogState();
}

class _MultiDeleteDialogState extends State<_MultiDeleteDialog> {
  final Set<int> _selected = {};
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEEE d. MMMM', 'sk');
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.selectDaysTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(shrinkWrap: true, children: widget.days.map((d) =>
          CheckboxListTile(
            title: Text(fmt.format(d.date)),
            subtitle: Text('${d.portFrom ?? "?"} → ${d.portTo ?? "?"}'),
            value: _selected.contains(d.id),
            onChanged: (v) => setState(() {
              if (v == true) _selected.add(d.id); else _selected.remove(d.id);
            }),
          )).toList()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        TextButton(
          onPressed: () => setState(() {
            _selected.clear();
            for (final d in widget.days) _selected.add(d.id);
          }),
          child: Text(l.selectAll),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _selected.isEmpty ? null : () {
            Navigator.pop(context);
            widget.onDelete(_selected.toList());
          },
          child: Text(l.deleteCount(_selected.length)),
        ),
      ],
    );
  }
}
