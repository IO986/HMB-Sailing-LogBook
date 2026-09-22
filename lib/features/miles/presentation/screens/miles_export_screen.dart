import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/skipper_profile_provider.dart';
import '../../../../core/utils/localized_date.dart';
import '../../../../main.dart';
import '../../../export/presentation/signature_pad_dialog.dart';
import '../../../export/presentation/widgets/day_map_view.dart';
import '../../../export/providers/export_map_provider.dart';
import '../../../export/services/export_service.dart';
import '../../../export/services/pdf_export_service.dart';
import '../../providers/miles_provider.dart';
import '../../services/miles_calculator.dart';

/// Formulár pred vystavením potvrdenia o naplávaných míľach.
///
/// Potvrdenie je doklad pre niekoho konkrétneho — pre seba do vlastného
/// zoznamu míľ, alebo pre člena posádky, ktorý si oň požiadal. Doteraz sa
/// generovalo bez mena a bez výberu, takže z neho nebolo poznať ani to, komu
/// patrí, ani kto ho vystavil. Papier, ktorý sa odovzdáva na úrad, si to
/// nemôže dovoliť.
class MilesExportScreen extends ConsumerStatefulWidget {
  const MilesExportScreen({super.key});

  @override
  ConsumerState<MilesExportScreen> createState() => _MilesExportScreenState();
}

class _MilesExportScreenState extends ConsumerState<MilesExportScreen> {
  bool _forSelf = true;
  final _recipient = TextEditingController();
  final _issuer = TextEditingController();
  final _qualification = TextEditingController();

  /// Číslo pasu/OP na potvrdenie. Pre seba sa predvyplní z profilu, pre člena
  /// posádky sa zadá a nikam sa neukladá — cudzí doklad appka neuchováva.
  final _idNumber = TextEditingController();

  /// Kľúče vybraných plavieb. `null` znamená „ešte som sa nedotkol výberu",
  /// takže platí všetko — skiper, ktorý chce celú knihu, nemusí odklikať
  /// dvadsať zaškrtávadiel.
  Set<String>? _selected;

  bool _busy = false;
  bool _profileLoaded = false;

  /// Mapa celej trasy naprieč vybranými plavbami — rovnaký princíp ako
  /// mapa celej plavby v exporte jedného charteru, len so súradnicami zo
  /// všetkých vybraných plavieb dokopy. Ručne dopísané historické plavby do
  /// nej neprispejú nič, GPS trasu nemajú.
  final ScreenshotController _routeMapController = ScreenshotController();
  List<TrackPoint> _routeTrackPoints = [];
  Uint8List? _routeMapShot;
  Set<int> _routeCharterIds = {};
  bool _loadingRouteMap = false;

  @override
  void dispose() {
    _recipient.dispose();
    _issuer.dispose();
    _qualification.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  /// Dotiahne body trasy pre práve vybrané plavby, len keď sa výber
  /// naozaj zmenil — inak by každý rebuild formulára znova sťahoval dáta
  /// a znova fotil mapu.
  void _syncRouteMap(List<VoyageRow> chosen) {
    final charterIds = chosen
        .where((v) => !v.isManualEntry && v.charterId != null)
        .map((v) => v.charterId!)
        .toSet();
    if (charterIds.length == _routeCharterIds.length &&
        charterIds.containsAll(_routeCharterIds)) {
      return;
    }
    _routeCharterIds = charterIds;
    // Nie priamo: toto sa volá z buildu a _loadRouteMap by setState-om
    // spustil rebuild ešte počas prebiehajúceho buildu.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadRouteMap(charterIds));
  }

  Future<void> _loadRouteMap(Set<int> charterIds) async {
    setState(() {
      _loadingRouteMap = true;
      _routeMapShot = null;
      _routeTrackPoints = [];
    });
    final db = ref.read(databaseProvider);
    final pts = <TrackPoint>[];
    for (final id in charterIds) {
      pts.addAll(await db.getTrackPointsForCharter(id));
    }
    pts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (!mounted) return;
    setState(() {
      _routeTrackPoints = pts;
      _loadingRouteMap = false;
    });
    if (pts.isEmpty) return;
    // Čas na stiahnutie/načítanie dlaždíc z keše, inak by v PDF ostal
    // sivý štvorec — rovnaká lehota ako pri mape jednej plavby.
    await Future.delayed(const Duration(milliseconds: 2000));
    try {
      final img = await _routeMapController.capture(pixelRatio: 1.0);
      if (mounted) setState(() => _routeMapShot = img);
    } catch (_) {}
  }

  static String _keyOf(VoyageRow v) =>
      v.isManualEntry ? 'h:${v.historicalVoyageId}' : 'c:${v.charterId}';

  bool _isSelected(VoyageRow v) =>
      _selected == null || _selected!.contains(_keyOf(v));

  void _toggle(VoyageRow v, List<VoyageRow> all) {
    setState(() {
      _selected ??= all.map(_keyOf).toSet();
      final key = _keyOf(v);
      if (!_selected!.remove(key)) _selected!.add(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final aggregateAsync = ref.watch(milesAggregateProvider);

    // Meno a kvalifikácia vystavovateľa sú v profile skipera — predvyplniť
    // ich je rozdiel medzi formulárom na jedno ťuknutie a prepisovaním toho
    // istého údaja pri každom potvrdení.
    ref.watch(skipperProfileProvider).whenData((profile) {
      if (_profileLoaded) return;
      _profileLoaded = true;
      _issuer.text = profile.fullName;
      _qualification.text = profile.licenseType;
      if (_forSelf) _idNumber.text = profile.idNumber;
    });

    return aggregateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l.milesExportTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l.milesExportTitle)),
        body: Center(child: Text('$e')),
      ),
      data: (aggregate) => Scaffold(
        appBar: AppBar(title: Text(l.milesExportTitle)),
        body: _form(context, l, aggregate),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _export(aggregate, saveLocally: true),
                  icon: const Icon(Icons.save_alt),
                  label: Text(l.saveToDevice),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _export(aggregate, saveLocally: false),
                  icon: const Icon(Icons.share),
                  label: Text(l.share),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// Prepnutie „pre seba / pre člena posádky".
  ///
  /// Číslo dokladu ide s tým: svoje sa predvyplní z profilu, pri posádke sa
  /// pole vyprázdni, aby sa cudzie potvrdenie nevystavilo s číslom skipera.
  Future<void> _setForSelf(bool forSelf) async {
    setState(() => _forSelf = forSelf);
    if (!forSelf) {
      setState(() => _idNumber.clear());
      return;
    }
    try {
      final profile = await ref.read(skipperProfileProvider.future);
      if (mounted) setState(() => _idNumber.text = profile.idNumber);
    } catch (_) {
      // Profil je pohodlie, nie podmienka.
    }
  }

  /// Výber mena zo zoznamu posádok.
  ///
  /// Zoznam, nie automatické dopĺňanie: skiper si väčšinou meno presne
  /// nepamätá tak, ako ho zapísal, a hľadá ho očami.
  Future<void> _pickRecipient(
      BuildContext context, AppLocalizations l, List<String> names) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(l.milesExportPickCrew,
                style: Theme.of(ctx).textTheme.titleMedium),
          ),
          for (final name in names)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(name),
              selected: name.toLowerCase() ==
                  _recipient.text.trim().toLowerCase(),
              onTap: () => Navigator.pop(ctx, name),
            ),
        ]),
      ),
    );
    if (picked == null) return;
    setState(() => _recipient.text = picked);
  }

  Widget _form(
      BuildContext context, AppLocalizations l, MilesAggregate aggregate) {
    final dateFmt = AppDate.of(context, ref);
    // Zoznam posádok zo všetkých plavieb. Kým sa načítava (alebo keď zlyhá),
    // ostáva prázdny a pole sa správa ako obyčajné textové — formulár sa
    // kvôli nemu nikdy nezasekne.
    final crewNames =
        ref.watch(knownCrewNamesProvider).valueOrNull ?? const <String>[];
    final chosen =
        aggregate.voyages.where(_isSelected).toList(growable: false);
    _syncRouteMap(chosen);
    final satellite = ref.watch(exportSatelliteMapProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text(l.milesExportFor, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(l.milesExportForSelf)),
            ButtonSegment(value: false, label: Text(l.milesExportForCrew)),
          ],
          selected: {_forSelf},
          onSelectionChanged: (s) => _setForSelf(s.first),
        ),
        if (!_forSelf) ...[
          const SizedBox(height: 12),
          // Meno sa dá napísať, ale hlavne vybrať: ten človek je už v appke
          // zapísaný ako posádka plavby, na ktorej bol, a ručné prepisovanie
          // vie preklepom rozdvojiť jednu osobu na dve potvrdenia.
          TextField(
            controller: _recipient,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l.milesExportRecipient,
              border: const OutlineInputBorder(),
              suffixIcon: crewNames.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l.milesExportPickCrew,
                      icon: const Icon(Icons.group),
                      onPressed: () => _pickRecipient(context, l, crewNames),
                    ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _idNumber,
          decoration: InputDecoration(
            labelText: l.crewCertIdDocument,
            helperText: _forSelf ? null : l.crewCertIdNotStored,
            helperMaxLines: 2,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Text(l.milesExportIssuer, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _issuer,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l.pdfSkipperLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qualification,
          decoration: InputDecoration(
            labelText: l.milesExportQualification,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: Text(l.milesExportVoyages,
                style: Theme.of(context).textTheme.titleSmall),
          ),
          TextButton(
            onPressed: () => setState(() => _selected =
                chosen.length == aggregate.voyages.length
                    ? <String>{}
                    : null),
            child: Text(chosen.length == aggregate.voyages.length
                ? l.milesExportSelectNone
                : l.milesExportSelectAll),
          ),
        ]),
        if (_routeTrackPoints.isNotEmpty || _loadingRouteMap)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.route, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.mapVoyageOverview,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _routeMapShot != null
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 18)
                      : const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                ]),
                const SizedBox(height: 10),
                Screenshot(
                  controller: _routeMapController,
                  child: SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: DayMapView(
                        trackPoints: _routeTrackPoints,
                        satellite: satellite,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        for (final v in aggregate.voyages)
          CheckboxListTile(
            dense: true,
            value: _isSelected(v),
            onChanged: (_) => _toggle(v, aggregate.voyages),
            title: Text(
                '${dateFmt.short(v.dateFrom)} – ${dateFmt.short(v.dateTo)}  ·  ${v.vesselName}'),
            subtitle: Text([
              v.area,
              if (v.role != null && v.role!.isNotEmpty) _roleLabel(v.role!, l),
              '${v.distanceNm.toStringAsFixed(1)} NM',
            ].whereType<String>().join('  ·  ')),
          ),
        const SizedBox(height: 16),
        Text(
          l.milesExportChosenSummary(
              '${chosen.length}',
              chosen
                  .fold<double>(0, (s, v) => s + v.distanceNm)
                  .toStringAsFixed(1)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _roleLabel(String role, AppLocalizations l) => switch (role) {
        'skipper' => l.roleSkipper,
        'coSkipper' => l.roleCoSkipper,
        'crew' => l.roleCrew,
        _ => role,
      };

  Future<void> _export(MilesAggregate aggregate,
      {required bool saveLocally}) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final dateFormat = AppDate.of(context, ref);

    // Výber plavieb sa kontroluje EŠTE pred podpisom: nechať skipera
    // podpísať sa a až potom mu povedať, že nevybral ani jednu plavbu, by
    // bol podpis nazmar.
    final chosen = aggregate.voyages.where(_isSelected).toList();
    if (chosen.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l.milesExportNoVoyages)));
      return;
    }

    // Podpis vystavovateľa, rovnako ako pri exporte denníka. Zrušený pad
    // znamená zrušený export — nepodpísané potvrdenie o míľach je papier,
    // na ktorom nikto za čísla neručí.
    final issuer = _issuer.text.trim();
    final signatureImage =
        await showSignaturePadDialog(context, signerName: issuer.isEmpty ? null : issuer);
    if (signatureImage == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final bytes = await PdfExportService.exportMilesCertificate(
        dateFormat: dateFormat,
        l: l,
        aggregate: MilesCalculator.restrictTo(aggregate, chosen),
        signerName: _issuer.text.trim().isEmpty ? null : _issuer.text.trim(),
        issuerQualification: _qualification.text.trim().isEmpty
            ? null
            : _qualification.text.trim(),
        recipientName: _forSelf ? null : _recipient.text.trim(),
        idNumber: _idNumber.text.trim(),
        forSelf: _forSelf,
        signatureImage: signatureImage,
        routeMap: _routeMapShot,
      );

      final docName = 'HMB Kniha mil '
          '${DateTime.now().toIso8601String().substring(0, 10)}';
      // Kópia do priečinka appky ide vždy, rovnako ako pri exporte plavby:
      // systémový dialóg si skiper môže odkliknúť, ale doklad má ostať
      // niekde, kde sa dá nájsť aj o mesiac.
      final saved =
          await ExportService().saveBytesLocally(bytes, docName, 'pdf');
      if (saveLocally) {
        await FilePicker.platform.saveFile(
          dialogTitle: l.saveToDevice,
          fileName: '$docName.pdf',
          bytes: bytes,
        );
      } else {
        final dir = await getTemporaryDirectory();
        final tmp = File('${dir.path}/$docName.pdf');
        await tmp.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(tmp.path)], subject: l.pdfMilesTitle);
      }
      messenger.showSnackBar(
          SnackBar(content: Text(l.exportSavedMsg(saved.path))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(l.errorMsg(e.toString())),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

}
