/// Zamerania jedného dňa zapísané mimo plavby — samostatný riadok v zozname
/// plavieb, nie len neviditeľná čiara na mape.
///
/// Skiper si zamerá aj bez toho, aby stlačil Spustiť tracking (na kotve,
/// pri chôdzi po brehu). Bez tejto obrazovky boli také zamerania viditeľné
/// len na mape, kým bola zapnutá vrstva zameraní — nikde v dennom zázname,
/// nikde v PDF.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/bearing_kind.dart';
import '../../../export/presentation/pdf_preview_screen.dart';
import '../../../export/services/pdf_export_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/bearing_provider.dart';
import '../../services/bearing_geometry.dart';
import '../widgets/bearing_session_map_view.dart';

class BearingSessionScreen extends ConsumerStatefulWidget {
  final DateTime date;
  const BearingSessionScreen({super.key, required this.date});

  @override
  ConsumerState<BearingSessionScreen> createState() =>
      _BearingSessionScreenState();
}

class _BearingSessionScreenState extends ConsumerState<BearingSessionScreen> {
  final _screenshotController = ScreenshotController();
  Uint8List? _mapScreenshot;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    // Dlaždice satelitnej vrstvy potrebujú čas na stiahnutie/načítanie
    // z cache skôr, než má zmysel obrázok odfotiť — rovnaký odstup ako pri
    // dennom exporte (export_screen.dart), z tých istých dôvodov.
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      try {
        final img = await _screenshotController.capture(pixelRatio: 2.0);
        if (mounted) setState(() => _mapScreenshot = img);
      } catch (_) {
        // Náhľad je pomôcka, nie podmienka exportu — PDF vznikne aj bez neho.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(bearingSessionForDateProvider(widget.date));
    final bearings = session?.bearings ?? const <Bearing>[];

    final resections = latestResectionCluster(bearings);
    final resectionLines =
        resections.map(bearingLineOf).whereType<BearingLine>().toList();
    final resectionFix = resectionLines.length < 2
        ? null
        : BearingGeometry.fix(resectionLines, kind: BearingKind.resection);
    final objectGroups = sightGroupsFrom(bearings);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE d. MMMM yyyy', 'sk').format(widget.date)),
        actions: [
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf),
            onPressed: bearings.isEmpty || _exporting
                ? null
                : () => _export(bearings, resectionFix, objectGroups, l),
          ),
        ],
      ),
      body: bearings.isEmpty
          ? Center(child: Text(l.bearingsEmpty))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (resectionLines.isNotEmpty || objectGroups.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 260,
                      child: Screenshot(
                        controller: _screenshotController,
                        child: BearingSessionMapView(
                          bearings: bearings,
                          resectionFix: resectionFix,
                          sightGroups: objectGroups,
                          l: l,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text('${l.bearingsTitle} (${bearings.length})',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 6),
                for (final b in bearings)
                  _BearingRow(
                    bearing: b,
                    onDelete: () async {
                      final repo = ref.read(bearingRepositoryProvider);
                      final groupId = b.sightGroupId;
                      if (groupId != null) {
                        await repo.deleteGroup(groupId);
                      } else {
                        await repo.delete(b.id);
                      }
                    },
                  ),
              ],
            ),
    );
  }

  /// Ide cez rovnaký náhľad ako denný a plavebný export
  /// (`PdfPreviewScreen`): sťahovacia ikona uloží PDF do viditeľného
  /// úložiska cez systémový dialóg, tlačidlo dole ho zdieľa. Predošlá
  /// verzia mlčky uložila len do súkromného adresára appky a rovno otvorila
  /// zdieľanie — bez možnosti dostať súbor niekam, kde ho skiper sám nájde.
  Future<void> _export(List<Bearing> bearings, BearingFix? resectionFix,
      List<SightGroup> objectGroups, AppLocalizations l) async {
    setState(() => _exporting = true);
    Uint8List bytes;
    try {
      bytes = await PdfExportService.buildBearingSessionPdfBytes(
        date: widget.date,
        bearings: bearings,
        l: l,
        mapScreenshot: _mapScreenshot,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l.bearingSaveFailed}\n$e'),
        backgroundColor: Colors.red,
      ));
      setState(() => _exporting = false);
      return;
    }
    if (!mounted) return;
    setState(() => _exporting = false);

    final dateStr = DateFormat('yyyy-MM-dd').format(widget.date);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: '${l.bearingsTitle} – $dateStr',
        pdfBytes: bytes,
        suggestedFileName: 'zamerania_$dateStr',
        onSave: () async {
          Navigator.of(context).pop();
          await Share.shareXFiles(
              [
                XFile.fromData(bytes,
                    mimeType: 'application/pdf',
                    name: 'zamerania_$dateStr.pdf'),
              ],
              subject: '${l.bearingsTitle} – $dateStr');
        },
      ),
    ));
  }
}

class _BearingRow extends StatelessWidget {
  final Bearing bearing;
  final Future<void> Function() onDelete;
  const _BearingRow({required this.bearing, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = bearing.targetName ?? bearing.label;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(
          BearingKind.fromCode(bearing.kind) == BearingKind.resection
              ? Icons.architecture
              : Icons.push_pin_outlined,
          size: 15,
          color: Colors.grey,
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 44,
          child: Text(DateFormat('HH:mm').format(bearing.takenAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '${(bearing.trueBearing.round() % 360).toString().padLeft(3, '0')}°',
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            name == null || name.isEmpty ? '—' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.close, size: 16),
          visualDensity: VisualDensity.compact,
          tooltip: l.delete,
        ),
      ]),
    );
  }
}
