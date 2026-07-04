import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../export/services/pdf_export_service.dart';
import '../../providers/miles_provider.dart';
import '../../services/miles_calculator.dart';

class MilesBookScreen extends ConsumerWidget {
  const MilesBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final aggregateAsync = ref.watch(milesAggregateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.milesBookTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: l.saveToDevice,
            onPressed: aggregateAsync.maybeWhen(
              data: (agg) => () => _exportPdf(context, agg, saveLocally: true),
              orElse: () => null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l.exportPdf,
            onPressed: aggregateAsync.maybeWhen(
              data: (agg) => () => _exportPdf(context, agg, saveLocally: false),
              orElse: () => null,
            ),
          ),
        ],
      ),
      body: aggregateAsync.when(
        data: (agg) => _MilesBody(aggregate: agg),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/miles/historical/new'),
        icon: const Icon(Icons.add),
        label: Text(l.addHistoricalVoyage),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, MilesAggregate agg,
      {required bool saveLocally}) async {
    final l = AppLocalizations.of(context);
    try {
      final pdfBytes = await PdfExportService.exportMilesCertificate(aggregate: agg);
      final fileName = 'HMB_Kniha_Mil_${DateTime.now().millisecondsSinceEpoch}.pdf';
      if (saveLocally) {
        await FilePicker.platform.saveFile(
          dialogTitle: l.saveToDevice,
          fileName: fileName,
          bytes: pdfBytes,
        );
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.errorMsg(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
    }
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
    final fmt = DateFormat('d.M.yyyy');

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
                    '${v.isManualEntry ? "* " : ""}${v.vesselName}  ·  ${v.distanceNm.toStringAsFixed(1)} NM'),
                subtitle: Text(
                    '${fmt.format(v.dateFrom)} – ${fmt.format(v.dateTo)}'
                    '${v.area != null ? " · ${v.area}" : ""}'),
                onTap: v.isManualEntry
                    ? () => context.push('/miles/historical/${v.historicalVoyageId}/edit')
                    : null,
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

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double nm;
  const _BreakdownRow({required this.label, required this.nm});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(label),
          const Spacer(),
          Text('${nm.toStringAsFixed(1)} NM', style: const TextStyle(fontWeight: FontWeight.w600)),
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
