import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../l10n/app_localizations.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;
  final VoidCallback onSave;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.pdfBytes,
    required this.onSave,
  });

  String _safeFileName(String t) =>
      t.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').replaceAll(RegExp(r'\s+'), '_');

  Future<void> _saveToDevice(BuildContext context) async {
    final l = AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: l.saveToDevice,
        fileName: '${_safeFileName(title)}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: pdfBytes,
      );
      if (result != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.exportSavedMsg(result.split('/').last)),
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
        pdfFileName: '${_safeFileName(title)}.pdf',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onSave,
        icon: const Icon(Icons.share),
        label: Text(l.saveAndShare),
      ),
    );
  }
}
