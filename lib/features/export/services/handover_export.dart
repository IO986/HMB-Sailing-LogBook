import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/localized_date.dart';
import '../../../main.dart';
import '../../charter/services/handover_checklist.dart';
import '../presentation/pdf_preview_screen.dart';
import 'pdf_export_service.dart';

/// PDF odovzdávacieho protokolu — náhľad, uloženie, zdieľanie.
///
/// Bývalo to súkromnou metódou obrazovky protokolu. Odkedy exporty žijú na
/// jednom mieste, potrebuje ich vyrobiť aj hub, ktorý tú obrazovku vôbec
/// neotvára — a protokol sa exportuje spravidla až potom, čo je podpísaný
/// a zavretý, teda vtedy, keď doň už nikto nevstupuje.
Future<void> exportHandoverProtocolPdf(
  BuildContext context,
  WidgetRef ref, {
  required Charter charter,
  required String type,
}) async {
  final db = ref.read(databaseProvider);
  final protocol = await db.getHandoverProtocol(charter.id, type);
  if (protocol == null || !context.mounted) return;

  // Zachytené pred awaitom — context sa cezeň prenášať nemá.
  final l = AppLocalizations.of(context);
  final dateFormat = AppDate.of(context, ref);

  final bytes = await PdfExportService.exportHandoverProtocol(
    dateFormat: dateFormat,
    l: l,
    charter: charter,
    protocol: protocol,
    checklist: checklistFromJson(protocol.checklistJson),
  );
  if (!context.mounted) return;

  final title = type == 'checkOut' ? l.checkOutProtocol : l.checkInProtocol;
  final fileName = 'HMB_Protokol_${type}_'
      '${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}';

  await Navigator.of(context).push(MaterialPageRoute(
    builder: (ctx) => PdfPreviewScreen(
      title: title,
      pdfBytes: bytes,
      suggestedFileName: fileName,
      onSave: () async {
        Navigator.of(ctx).pop();
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName.pdf');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)]);
      },
    ),
  ));
}
