import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import '../../../l10n/app_localizations.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;
  final VoidCallback onSave;
  final String? suggestedFileName;
  final Uint8List? gpxBytes;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.pdfBytes,
    required this.onSave,
    this.suggestedFileName,
    this.gpxBytes,
  });

  String _safeFileName(String t) =>
      t.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').replaceAll(RegExp(r'\s+'), '_');

  String get _baseName => suggestedFileName ?? _safeFileName(title);

  Future<void> _saveToDevice(BuildContext context) async {
    final l = AppLocalizations.of(context);
    try {
      // 1. Ulož PDF cez systémový dialóg (vždy funguje)
      final pdfResult = await FilePicker.platform.saveFile(
        dialogTitle: l.saveToDevice,
        fileName: '$_baseName.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: pdfBytes,
      );
      if (pdfResult == null) return;

      // 2. Ulož GPX – najprv skús priamo vedľa PDF, ak to zlyhá → share sheet
      if (gpxBytes != null) {
        bool gpxSaved = false;
        try {
          final dir = File(pdfResult).parent.path;
          final gpxPath = '$dir/$_baseName.gpx';
          await File(gpxPath).writeAsBytes(gpxBytes!);
          gpxSaved = true;
        } catch (_) {}

        if (!gpxSaved) {
          // Záložný plán: zapíš do cache, zdieľaj cez share sheet
          final tmp = await getTemporaryDirectory();
          final gpxFile = File('${tmp.path}/$_baseName.gpx');
          await gpxFile.writeAsBytes(gpxBytes!);
          await Share.shareXFiles(
            [XFile(gpxFile.path, mimeType: 'application/gpx+xml', name: '$_baseName.gpx')],
            subject: '$_baseName.gpx',
          );
          gpxSaved = true;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l.exportSavedPdfGpx('$_baseName.pdf', '$_baseName.gpx')),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
          ));
        }
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.exportSavedMsg(pdfResult.split('/').last)),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.closeWithoutSaving,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l.saveToDevice,
            onPressed: () => _saveToDevice(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) async => pdfBytes,
        initialPageFormat: PdfPageFormat.a4,
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: '$_baseName.pdf',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onSave,
        icon: const Icon(Icons.share),
        label: Text(l.saveAndShare),
      ),
    );
  }
}
