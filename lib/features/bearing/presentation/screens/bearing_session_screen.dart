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
import '../../../../core/utils/localized_date.dart';
import '../../../../core/services/units_service.dart';

class BearingSessionScreen extends ConsumerStatefulWidget {
  final DateTime date;

  /// Otvorené z hubu exportov: PDF sa vyrobí samo, hneď ako je snímka mapy
  /// hotová. Zameranie sa tlačí aj s mapou a odfotiť ju vie len táto
  /// obrazovka, takže cesta k PDF vedie cezňu aj vtedy, keď skiper klikol
  /// inde.
  final bool autoExport;

  const BearingSessionScreen(
      {super.key, required this.date, this.autoExport = false});

  @override
  ConsumerState<BearingSessionScreen> createState() =>
      _BearingSessionScreenState();
}

class _BearingSessionScreenState extends ConsumerState<BearingSessionScreen> {
  final _screenshotController = ScreenshotController();
  Uint8List? _mapScreenshot;
  bool _exporting = false;
  bool _autoExportDone = false;

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
      _maybeAutoExport();
    });
  }

  /// Export spustený príchodom z hubu. Beží raz — po odfotení mapy, aby PDF
  /// nevyšlo bez nej.
  void _maybeAutoExport() {
    if (!widget.autoExport || _autoExportDone || !mounted) return;
    final session = ref.read(bearingSessionForDateProvider(widget.date));
    final bearings = session?.bearings ?? const <Bearing>[];
    if (bearings.isEmpty) return;
    _autoExportDone = true;

    final resections = latestResectionCluster(bearings);
    final resectionLines =
        resections.map(bearingLineOf).whereType<BearingLine>().toList();
    final resectionFix = resectionLines.length < 2
        ? null
        : BearingGeometry.fix(resectionLines, kind: BearingKind.resection);
    _export(bearings, resectionFix, sightGroupsFrom(bearings),
        AppLocalizations.of(context));
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
        title: Text(AppDate.of(context, ref).long(widget.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l.delete,
            onPressed: bearings.isEmpty || _exporting
                ? null
                : () => _deleteWholeDay(bearings, l),
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

  /// Zmaže celý denný záznam zameraní.
  ///
  /// Riadok v zozname plavieb nie je samostatná entita — vzniká zoskupením
  /// zameraní podľa dňa (`orphanBearingSessionsProvider`). Zmazaním
  /// posledného zamerania teda zmizne aj on, bez ďalšieho upratovania.
  ///
  /// Na rozdiel od "skryť z mapy" je toto naozaj nevratné a zmizne aj z PDF —
  /// preto potvrdenie a červené tlačidlo.
  Future<void> _deleteWholeDay(
      List<Bearing> bearings, AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteEntryTitle),
        content: Text(l.bearingsDeleteDayConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repo = ref.read(bearingRepositoryProvider);
    // Skupinové zamerania sa mažú celé naraz, takže tá istá skupina by inak
    // prišla na rad toľkokrát, koľko má členov.
    final doneGroups = <String>{};
    for (final b in bearings) {
      final groupId = b.sightGroupId;
      if (groupId != null) {
        if (doneGroups.add(groupId)) await repo.deleteGroup(groupId);
      } else {
        await repo.delete(b.id);
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
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
        dateFormat: AppDate.of(context, ref),
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

class _BearingRow extends ConsumerWidget {
  final Bearing bearing;
  final Future<void> Function() onDelete;
  const _BearingRow({required this.bearing, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Text(ref.watch(unitsSyncProvider).formatTime(bearing.takenAt),
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
