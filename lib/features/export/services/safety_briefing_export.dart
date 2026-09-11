import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/hmb_handbook.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/localized_date.dart';
import '../../../main.dart';
import '../../safety/services/custom_safety_items.dart';
import '../presentation/pdf_preview_screen.dart';
import 'pdf_export_service.dart';

/// PDF bezpečnostného brífingu — náhľad, uloženie, zdieľanie.
///
/// Vlastný doklad, nie výrez zo súhrnu plavby: charterová firma alebo škola
/// chce papier o tom, kto bol poučený a o čom. Súhrn plavby ostáva, aký bol.
///
/// Rovnaký vzor ako `exportHandoverProtocolPdf` — dáta si natiahne sám, aby
/// ho vedel vyrobiť aj hub, ktorý obrazovku brífingu vôbec neotvára.
Future<void> exportSafetyBriefingPdf(
  BuildContext context,
  WidgetRef ref, {
  required Charter charter,
}) async {
  final db = ref.read(databaseProvider);
  final signatures = await db.getSignaturesForCharter(charter.id);
  final customPoints = await CustomSafetyItems.briefingPoints();
  if (!context.mounted) return;

  // Zachytené pred awaitom — context sa cezeň prenášať nemá.
  final l = AppLocalizations.of(context);
  final dateFormat = AppDate.of(context, ref);
  final sections = SafetyBriefingContent.sectionsFor(
      Localizations.localeOf(context).languageCode);

  final covered = _coveredPoints(charter);
  final signatories = await _signatories(charter, signatures);

  final bytes = await PdfExportService.exportSafetyBriefing(
    l: l,
    dateFormat: dateFormat,
    charter: charter,
    sections: sections,
    customPoints: customPoints,
    covered: covered,
    signatories: signatories,
  );
  if (!context.mounted) return;

  final fileName = 'HMB_Briefing_'
      '${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}';

  await Navigator.of(context).push(MaterialPageRoute(
    builder: (ctx) => PdfPreviewScreen(
      title: l.safetyBriefingScreenTitle,
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

/// Body, ktoré skiper pri brífingu zaškrtol.
///
/// Prázdna množina pri brífingoch z čias, keď sa zaškrtnutia neukladali —
/// vtedy PDF vytlačí zoznam s prázdnymi štvorčekmi. To je pravdivejšie než
/// zaškrtnúť všetko za skipera.
Set<String> _coveredPoints(Charter charter) {
  final raw = charter.briefingCheckedJson;
  if (raw == null || raw.isEmpty) return const {};
  try {
    return (jsonDecode(raw) as List).cast<String>().toSet();
  } catch (e) {
    debugPrint('[BRIEFING PDF] checked items unreadable: $e');
    return const {};
  }
}

/// Posádka s podpismi v poradí, v akom ich obrazovka brífingu ukladala.
///
/// Kľúč `crewName` v databáze je `index:meno` (dvaja Petrovia na palube nie
/// sú výnimka), preto sa prefix pred tlačou odstrihne a riadky sa zoradia
/// podľa neho — inak by podpisy v doklade skákali podľa poradia v tabuľke.
Future<List<BriefingSignatory>> _signatories(
    Charter charter, List<CrewSignature> signatures) async {
  final rows = [...signatures]..sort((a, b) => _indexOf(a.crewName).compareTo(_indexOf(b.crewName)));

  final out = <BriefingSignatory>[];
  for (final row in rows) {
    Uint8List? bytes;
    final path = row.signaturePath;
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) bytes = await file.readAsBytes();
      } catch (e) {
        debugPrint('[BRIEFING PDF] signature unreadable: $e');
      }
    }
    out.add(BriefingSignatory(
      name: _displayName(row.crewName),
      role: row.role,
      signature: bytes,
      signedAt: row.signedAt,
    ));
  }
  return out;
}

int _indexOf(String crewName) {
  final i = crewName.indexOf(':');
  if (i < 0) return 0; // staré riadky bez indexu — nech ostanú na začiatku
  return int.tryParse(crewName.substring(0, i)) ?? 0;
}

String _displayName(String crewName) {
  final i = crewName.indexOf(':');
  return i < 0 ? crewName : crewName.substring(i + 1);
}
