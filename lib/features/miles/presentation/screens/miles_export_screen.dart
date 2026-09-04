import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/skipper_profile_provider.dart';
import '../../../../core/utils/localized_date.dart';
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

  @override
  void dispose() {
    _recipient.dispose();
    _issuer.dispose();
    _qualification.dispose();
    _idNumber.dispose();
    super.dispose();
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
    setState(() => _busy = true);
    try {
      final chosen = aggregate.voyages.where(_isSelected).toList();
      if (chosen.isEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(l.milesExportNoVoyages)));
        return;
      }
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
