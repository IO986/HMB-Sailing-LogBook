import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../../export/services/export_service.dart';
import '../services/voyage_csv_exporter.dart';

/// Opens the export of a whole voyage as one CSV file: choose whether the
/// track goes with it, then write the file and share it.
Future<void> showVoyageCsvExport(BuildContext context, Charter charter) =>
    showDialog<void>(
      context: context,
      builder: (_) => VoyageCsvExportDialog(charter: charter),
    );

class VoyageCsvExportDialog extends ConsumerStatefulWidget {
  final Charter charter;
  const VoyageCsvExportDialog({super.key, required this.charter});

  @override
  ConsumerState<VoyageCsvExportDialog> createState() =>
      _VoyageCsvExportDialogState();
}

class _VoyageCsvExportDialogState extends ConsumerState<VoyageCsvExportDialog> {
  /// A track point costs about this many bytes in the file; the estimate is
  /// there so that nobody is surprised by a 30 MB attachment.
  static const _bytesPerTrackPoint = 80;

  bool _includeTrack = true;
  bool _busy = false;
  int? _trackPoints;

  @override
  void initState() {
    super.initState();
    _countTrack();
  }

  Future<void> _countTrack() async {
    try {
      final n = await VoyageCsvExporter.trackPointCount(
          ref.read(databaseProvider), widget.charter.id);
      if (mounted) setState(() => _trackPoints = n);
    } catch (e) {
      debugPrint('[CSV] counting track points failed: $e');
      if (mounted) setState(() => _trackPoints = 0);
    }
  }

  static String _megabytes(int points) {
    final mb = points * _bytesPerTrackPoint / (1024 * 1024);
    return mb < 0.1 ? '< 0,1 MB' : '≈ ${mb.toStringAsFixed(1).replaceAll('.', ',')} MB';
  }

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final db = ref.read(databaseProvider);
    final appVersion = ref.read(appVersionProvider);
    final charter = widget.charter;

    setState(() => _busy = true);
    try {
      final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final file = await ExportService().exportFile(
        'HMB_voyage_${charter.title}_$stamp',
        'csv',
        charterTitle: charter.title,
      );
      final sink = file.openWrite(encoding: utf8);
      try {
        await VoyageCsvExporter.write(db, charter.id, sink,
            includeTrack: _includeTrack, appVersion: appVersion);
      } finally {
        await sink.flush();
        await sink.close();
      }

      navigator.pop();
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    } catch (e, st) {
      debugPrint('[CSV] export failed: $e\n$st');
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(
        content: Text(l.csvExportFailed),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final points = _trackPoints;

    return AlertDialog(
      title: Text(l.exportsCsvTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l.exportsCsvDesc),
          const SizedBox(height: 12),
          SwitchListTile(
            key: const ValueKey('csv-include-track'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.csvExportIncludeTrack),
            subtitle: Text(points == null
                ? '…'
                : '${l.csvExportTrackPoints}: $points'
                    '${points > 0 ? '  ${_megabytes(points)}' : ''}'),
            value: _includeTrack,
            onChanged: _busy ? null : (v) => setState(() => _includeTrack = v),
          ),
          const SizedBox(height: 8),
          Text(
            l.csvExportPrivacy,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const ValueKey('csv-export-go'),
          onPressed: _busy ? null : _export,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.csvExportAction),
        ),
      ],
    );
  }
}
