import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/crew_member_ref.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../../export/services/export_service.dart';
import '../../../export/services/pdf_export_service.dart';
import '../../services/voyage_miles_summary.dart';

/// Hodnotenie posádky po plavbe a export potvrdení o naplávaných míľach.
///
/// Jeden súbor na člena posádky: potvrdenie ide tomu človeku, nie celej lodi.
class CrewCertificatesScreen extends ConsumerStatefulWidget {
  const CrewCertificatesScreen({required this.charterId, super.key});

  final int charterId;

  @override
  ConsumerState<CrewCertificatesScreen> createState() =>
      _CrewCertificatesScreenState();
}

class _CrewCertificatesScreenState
    extends ConsumerState<CrewCertificatesScreen> {
  /// Rozpracované hodnotenie podľa mena — ukladá sa až pri exporte alebo
  /// odchode z obrazovky, aby ťukanie do hviezdičiek nešlo do DB po jednej.
  final _drafts = <String, _Draft>{};

  /// Mená skiperov — ich hodnotenie sa nezbiera ani neukladá.
  final _skippers = <String>{};
  bool _loaded = false;
  bool _busy = false;

  Future<void> _load(List<CrewMemberRef> crew) async {
    final db = ref.read(databaseProvider);
    final stored = await db.getCrewAssessments(widget.charterId);
    final byName = {for (final a in stored) a.crewName: a};
    setState(() {
      for (final member in crew) {
        _drafts[member.name] = _Draft.from(byName[member.name]);
        if (member.isSkipper) _skippers.add(member.name);
      }
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    for (final entry in _drafts.entries) {
      if (entry.value.isEmpty || _skippers.contains(entry.key)) continue;
      await db.upsertCrewAssessment(CrewAssessmentsCompanion.insert(
        charterId: widget.charterId,
        crewName: entry.key,
        helming: Value(entry.value.helming),
        navigation: Value(entry.value.navigation),
        harbourManoeuvres: Value(entry.value.harbour),
        teamwork: Value(entry.value.teamwork),
        nightSailing: Value(entry.value.nightSailing),
        note: Value(entry.value.note.trim().isEmpty ? null : entry.value.note.trim()),
        updatedAt: DateTime.now().toUtc(),
      ));
    }
  }

  Future<void> _export(Charter charter, List<CrewMemberRef> crew,
      {required bool saveToDevice}) async {
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);
    try {
      await _save();

      final days = await db.getDayLogs(charter.id);
      final points = <TrackPoint>[];
      for (final day in days) {
        for (final session in await db.getSessionsForDay(day.id)) {
          points.addAll(await db.getTrackPointsForSession(session.sessionId));
        }
      }
      final summary = summariseVoyage(
        days: days,
        points: points,
        area: charter.cruisingArea ?? charter.homePort,
      );

      Uint8List? signature;
      final signaturePath = charter.logbookSignaturePath;
      if (signaturePath != null && File(signaturePath).existsSync()) {
        signature = await File(signaturePath).readAsBytes();
      }

      final files = <XFile>[];
      for (final member in crew) {
        final bytes = await PdfExportService.buildCrewMilesCertificate(
          l: l,
          charter: charter,
          crew: member,
          summary: summary,
          assessment: member.isSkipper
              ? null
              : await db.getCrewAssessment(charter.id, member.name),
          skipperSignature: signature,
        );
        // Kópia v priečinku appky ostáva vždy — potvrdenie sa dá znova
        // nájsť aj keď užívateľ zdieľanie zruší.
        final file = await ExportService().saveBytesLocally(
          bytes,
          '${charter.title} ${member.name}',
          'pdf',
          charterTitle: charter.title,
        );
        files.add(XFile(file.path));

        if (saveToDevice) {
          await FilePicker.platform.saveFile(
            dialogTitle: l.saveToDevice,
            fileName: _fileName(charter, member),
            bytes: bytes,
          );
        }
      }

      if (!mounted) return;
      if (!saveToDevice) {
        await Share.shareXFiles(files, subject: l.crewCertTitle);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.crewCertShared)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).exportErrorMsg('$e')),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Meno súboru pri ukladaní do zariadenia — človek si ho hľadá medzi
  /// stiahnutými, tak nesie plavbu aj meno člena posádky.
  String _fileName(Charter charter, CrewMemberRef member) {
    String slug(String s) => s
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return 'HMB_Mile_${slug(charter.title)}_${slug(member.name)}.pdf';
  }

  Future<void> _setTidal(Charter charter, bool? value) async {
    await ref.read(databaseProvider).updateCharter(ChartersCompanion(
          id: Value(charter.id),
          tidalWaters: Value(value),
        ));
    ref.invalidate(chartersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chartersAsync = ref.watch(chartersProvider);

    // Hodnotenie sa ukladá aj pri odchode — skiper môže posádku ohodnotiť
    // teraz a exportovať potvrdenia až po návrate do prístavu.
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) unawaited(_save());
      },
      child: Scaffold(
      appBar: AppBar(title: Text(l.crewCertTitle)),
      body: chartersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (charters) {
          final charter =
              charters.where((c) => c.id == widget.charterId).firstOrNull;
          if (charter == null) return Center(child: Text(l.voyageNotFound));

          final crew = CrewMemberRef.parse(charter.crewJson,
              skipperName: charter.skipperName, crewNames: charter.crewNames);
          if (crew.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l.crewCertNoCrew,
                  textAlign: TextAlign.center)),
            );
          }
          if (!_loaded) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _load(crew));
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.crewCertWatersLabel,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        // Školy a RYA rozlišujú prílivové a neprílivové míle,
                        // preto to ide na potvrdenie.
                        SegmentedButton<int>(
                          segments: [
                            ButtonSegment(
                                value: 1, label: Text(l.crewCertWatersTidal)),
                            ButtonSegment(
                                value: 0,
                                label: Text(l.crewCertWatersNonTidal)),
                          ],
                          emptySelectionAllowed: true,
                          selected: charter.tidalWaters == null
                              ? const <int>{}
                              : {charter.tidalWaters! ? 1 : 0},
                          onSelectionChanged: (sel) => _setTidal(
                              charter, sel.isEmpty ? null : sel.first == 1),
                        ),
                      ]),
                ),
              ),
              for (final member in crew)
                _CrewCard(
                  member: member,
                  draft: _drafts[member.name] ??= _Draft.empty(),
                  onChanged: () => setState(() {}),
                ),
            ],
          );
        },
      ),
      floatingActionButton: chartersAsync.valueOrNull == null
          ? null
          : Builder(builder: (context) {
              final charter = chartersAsync.value!
                  .where((c) => c.id == widget.charterId)
                  .firstOrNull;
              if (charter == null) return const SizedBox();
              final crew = CrewMemberRef.parse(charter.crewJson,
                  skipperName: charter.skipperName,
                  crewNames: charter.crewNames);
              if (crew.isEmpty) return const SizedBox();
              return Row(mainAxisSize: MainAxisSize.min, children: [
                FloatingActionButton(
                  heroTag: 'crewCertSave',
                  tooltip: l.saveToDevice,
                  onPressed: _busy
                      ? null
                      : () => _export(charter, crew, saveToDevice: true),
                  child: const Icon(Icons.save_alt),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'crewCertShare',
                  onPressed: _busy
                      ? null
                      : () => _export(charter, crew, saveToDevice: false),
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(l.crewCertExport),
                ),
              ]);
            }),
      ),
    );
  }
}

class _Draft {
  _Draft({
    this.helming,
    this.navigation,
    this.harbour,
    this.teamwork,
    this.nightSailing,
    String note = '',
  }) : noteCtrl = TextEditingController(text: note);

  factory _Draft.empty() => _Draft();

  factory _Draft.from(CrewAssessment? a) => _Draft(
        helming: a?.helming,
        navigation: a?.navigation,
        harbour: a?.harbourManoeuvres,
        teamwork: a?.teamwork,
        nightSailing: a?.nightSailing,
        note: a?.note ?? '',
      );

  int? helming;
  int? navigation;
  int? harbour;
  int? teamwork;
  int? nightSailing;
  final TextEditingController noteCtrl;

  String get note => noteCtrl.text;

  bool get isEmpty =>
      helming == null &&
      navigation == null &&
      harbour == null &&
      teamwork == null &&
      nightSailing == null &&
      note.trim().isEmpty;
}

class _CrewCard extends StatelessWidget {
  const _CrewCard({
    required this.member,
    required this.draft,
    required this.onChanged,
  });

  final CrewMemberRef member;
  final _Draft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(member.isSkipper ? Icons.star : Icons.person,
                color: member.isSkipper ? Colors.amber.shade700 : null),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(member.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(member.roleLabel(l),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
          ]),
          if (member.isSkipper) ...[
            const SizedBox(height: 6),
            // Skiper posádku hodnotí — sám sa nehodnotí. Potvrdenie o
            // míľach však dostane tiež, plavbu odplával s nimi.
            Text(l.crewCertSkipperRates,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ] else ...[
          const SizedBox(height: 8),
          _SkillRow(
              label: l.crewSkillHelming,
              value: draft.helming,
              onChanged: (v) { draft.helming = v; onChanged(); }),
          _SkillRow(
              label: l.crewSkillNavigation,
              value: draft.navigation,
              onChanged: (v) { draft.navigation = v; onChanged(); }),
          _SkillRow(
              label: l.crewSkillHarbour,
              value: draft.harbour,
              onChanged: (v) { draft.harbour = v; onChanged(); }),
          _SkillRow(
              label: l.crewSkillTeamwork,
              value: draft.teamwork,
              onChanged: (v) { draft.teamwork = v; onChanged(); }),
          _SkillRow(
              label: l.crewSkillNightSailing,
              value: draft.nightSailing,
              onChanged: (v) { draft.nightSailing = v; onChanged(); }),
          const SizedBox(height: 8),
          TextField(
            controller: draft.noteCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: l.crewCertNoteHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          ],
        ]),
      ),
    );
  }
}

/// Jedna zručnosť: 1–5 hviezdičiek, ťuknutie na tú istú hodnotu ju zruší.
class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        if (value == null)
          Text(l.crewCertNotRated,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        for (var i = 1; i <= 5; i++)
          IconButton(
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            tooltip: '$i',
            icon: Icon(
              (value ?? 0) >= i ? Icons.star : Icons.star_border,
              size: 20,
              color: (value ?? 0) >= i ? Colors.amber.shade700 : Colors.grey,
            ),
            onPressed: () => onChanged(value == i ? null : i),
          ),
      ]),
    );
  }
}
