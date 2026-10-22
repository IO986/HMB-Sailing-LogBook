import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/localized_date.dart';
import '../../../main.dart';
import '../../charter/providers/charter_provider.dart';
import '../../miles/providers/miles_provider.dart';
import '../format/voyage_csv_codec.dart';
import '../format/voyage_csv_record.dart';
import '../services/voyage_csv_importer.dart';

/// Reads a voyage CSV made by this app into a new voyage: pick the file, see
/// what is in it, import.
class VoyageCsvImportScreen extends ConsumerStatefulWidget {
  /// A file already read, so the screen opens on its preview. For tests: the
  /// system file picker cannot be driven from one.
  @visibleForTesting
  final VoyageCsvDocument? initialDocument;

  const VoyageCsvImportScreen({super.key, this.initialDocument});

  @override
  ConsumerState<VoyageCsvImportScreen> createState() =>
      _VoyageCsvImportScreenState();
}

class _VoyageCsvImportScreenState extends ConsumerState<VoyageCsvImportScreen> {
  VoyageCsvDocument? _doc;
  VoyageCsvPreview? _preview;
  Charter? _existing;
  String? _fileName;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final doc = widget.initialDocument;
    if (doc != null) _show(doc, 'voyage.csv');
  }

  Future<void> _show(VoyageCsvDocument doc, String fileName) async {
    final existing =
        await VoyageCsvImporter.findExisting(ref.read(databaseProvider), doc);
    if (!mounted) return;
    setState(() {
      _doc = doc;
      _preview = VoyageCsvImporter.preview(doc);
      _existing = existing;
      _fileName = fileName;
    });
  }

  Future<void> _pick() async {
    final l = AppLocalizations.of(context);
    try {
      // FileType.any, not a `csv` filter: some Android file managers cannot
      // map the extension to a type. The content is checked below.
      final picked = await FilePicker.platform.pickFiles(type: FileType.any);
      final path = picked?.files.single.path;
      if (path == null) return;

      setState(() => _busy = true);
      final bytes = await File(path).readAsBytes();
      final doc = VoyageCsvReader.read(utf8.decode(bytes, allowMalformed: true));
      await _show(doc, picked!.files.single.name);
    } on VoyageCsvFormatException catch (e) {
      if (mounted) _problem(_problemText(l, e));
    } catch (e, st) {
      debugPrint('[CSV] reading the file failed: $e\n$st');
      if (mounted) _problem(l.importCsvFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final doc = _doc;
    if (doc == null) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _busy = true);
    try {
      final result =
          await VoyageCsvImporter.importInto(ref.read(databaseProvider), doc);

      invalidateMilesData(ref);
      ref.invalidate(chartersProvider);
      ref.invalidate(activeChartersProvider);
      ref.invalidate(archivedChartersProvider);
      ref.invalidate(dayLogsProvider(result.charterId));

      messenger.showSnackBar(SnackBar(content: Text(l.importCsvDone)));
      router.go('/logbook/${result.charterId}');
    } on VoyageAlreadyImportedException catch (e) {
      final db = ref.read(databaseProvider);
      final existing = await db.getCharterById(e.charterId);
      if (mounted) setState(() => _existing = existing);
    } catch (e, st) {
      debugPrint('[CSV] import failed: $e\n$st');
      if (mounted) _problem(l.importCsvFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _problemText(AppLocalizations l, VoyageCsvFormatException e) =>
      switch (e.problem) {
        VoyageCsvProblem.empty ||
        VoyageCsvProblem.noRecords ||
        VoyageCsvProblem.noVoyage =>
          l.csvProblemNoData,
        VoyageCsvProblem.notOurs ||
        VoyageCsvProblem.otherFormat ||
        VoyageCsvProblem.noVersion =>
          l.csvProblemNotOurs,
        VoyageCsvProblem.newerVersion => l.csvProblemNewer,
      };

  static String _warningLabel(AppLocalizations l, VoyageCsvWarningKind k) =>
      switch (k) {
        VoyageCsvWarningKind.unknownColumns => l.csvWarnUnknownColumns,
        VoyageCsvWarningKind.unknownType => l.csvWarnUnknownType,
        VoyageCsvWarningKind.extraMeta => l.csvWarnExtraMeta,
        VoyageCsvWarningKind.badNumber => l.csvWarnBadNumber,
        VoyageCsvWarningKind.repeatedId => l.csvWarnRepeatedId,
        VoyageCsvWarningKind.orphan => l.csvWarnOrphan,
        VoyageCsvWarningKind.invalid => l.csvWarnInvalid,
        VoyageCsvWarningKind.duplicate => l.csvWarnDuplicate,
      };

  void _problem(String message) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.error),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final preview = _preview;

    return Scaffold(
      appBar: AppBar(title: Text(l.importCsvTitle)),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (preview == null) ...[
                Text(l.importCsvIntro),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    key: const ValueKey('csv-import-pick'),
                    onPressed: _pick,
                    icon: const Icon(Icons.file_open_outlined),
                    label: Text(l.importCsvPick),
                  ),
                ),
              ] else ...[
                _PreviewCard(
                    preview: preview, fileName: _fileName, l: l, ref: ref),
                if (preview.warnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l.importCsvWarnings,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  for (final w in preview.warnings.take(8))
                    Text('• ${_warningLabel(l, w.kind)}: ${w.detail}'),
                  if (preview.warnings.length > 8)
                    Text('… +${preview.warnings.length - 8}'),
                ],
                const SizedBox(height: 20),
                if (_existing != null) ...[
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: ListTile(
                      key: const ValueKey('csv-import-already'),
                      leading: const Icon(Icons.info_outline),
                      title: Text(l.importCsvAlready),
                      subtitle: Text(_existing!.title),
                      trailing: TextButton(
                        onPressed: () => context.go('/logbook/${_existing!.id}'),
                        child: Text(l.importCsvOpenExisting),
                      ),
                    ),
                  ),
                ] else
                  FilledButton.icon(
                    key: const ValueKey('csv-import-go'),
                    onPressed: _import,
                    icon: const Icon(Icons.download_done),
                    label: Text(l.importCsvAction),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _pick,
                  child: Text(l.importCsvPickAnother),
                ),
              ],
            ]),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final VoyageCsvPreview preview;
  final String? fileName;
  final AppLocalizations l;
  final WidgetRef ref;
  const _PreviewCard({
    required this.preview,
    required this.fileName,
    required this.l,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = AppDate.of(context, ref);
    final from = preview.from;
    final to = preview.to;

    Widget line(String text) => Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(text),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (fileName != null)
            Text(fileName!,
                style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(preview.title ?? '—',
              style: Theme.of(context).textTheme.titleMedium),
          if (preview.vesselName != null) line(preview.vesselName!),
          if (from != null && to != null)
            line('${fmt.medium(from.toLocal())} – ${fmt.medium(to.toLocal())}'),
          const Divider(height: 20),
          if (preview.count('crew') > 0)
            line('${l.crew}: ${preview.count('crew')}'),
          if (preview.count('day') > 0)
            line(l.voyageDaysCount(preview.count('day'))),
          if (preview.count('entry') > 0)
            line(l.recordCount(preview.count('entry'))),
          line(preview.includesTrack
              ? '${l.csvExportTrackPoints}: ${preview.count('track')}'
              : l.importCsvNoTrack),
          if (preview.count('handover') > 0)
            line('${l.handoverMenuTitle}: ${preview.count('handover')}'),
          if (preview.count('bearing') > 0)
            line('${l.bearingsTitle}: ${preview.count('bearing')}'),
        ]),
      ),
    );
  }
}
