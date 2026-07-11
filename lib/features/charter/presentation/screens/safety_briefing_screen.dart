import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/signature_pad.dart';
import '../../providers/charter_provider.dart';

// ── Screen ────────────────────────────────────────────────────

class SafetyBriefingScreen extends ConsumerStatefulWidget {
  final int charterId;
  const SafetyBriefingScreen({super.key, required this.charterId});

  @override
  ConsumerState<SafetyBriefingScreen> createState() =>
      _SafetyBriefingScreenState();
}

class _SafetyBriefingScreenState extends ConsumerState<SafetyBriefingScreen> {
  final Set<int> _checkedItems = {};
  // All maps keyed by member index to handle duplicate names correctly
  final Map<int, List<List<Offset>>> _strokes = {};
  final Map<int, String?> _existingPaths = {};
  final Map<int, GlobalKey<SignaturePadState>> _padKeys = {};
  final Set<int> _editing = {};

  bool _initialized = false;
  bool _saving = false;
  bool _scrollLocked = false;

  final _scrollCtrl = ScrollController();

  List<({String name, String role})> _buildMembers(Charter c) {
    final r = <({String name, String role})>[];
    if (c.skipperName?.isNotEmpty == true) {
      r.add((name: c.skipperName!, role: 'skipper'));
    }
    for (final n in (c.crewNames ?? '').split('|').map((s) => s.trim()).where((s) => s.isNotEmpty)) {
      r.add((name: n, role: 'crew'));
    }
    return r;
  }

  // DB key that is unique even when two members share the same name
  String _dbKey(int index, String name) => '$index:$name';

  Future<void> _init(int charterId, List<({String name, String role})> members) async {
    if (_initialized) return;
    _initialized = true;
    final sigs = await ref.read(databaseProvider).getSignaturesForCharter(charterId);
    // Build a fast lookup: crewName stored in DB → signaturePath
    final sigMap = {for (final s in sigs) s.crewName: s.signaturePath};
    for (var i = 0; i < members.length; i++) {
      _padKeys.putIfAbsent(i, () => GlobalKey<SignaturePadState>());
      _strokes.putIfAbsent(i, () => []);
      // Try indexed key first (new format), fall back to plain name (old data)
      final path = sigMap[_dbKey(i, members[i].name)] ?? sigMap[members[i].name];
      if (path != null) _existingPaths[i] = path;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chartersAsync = ref.watch(chartersProvider);

    return chartersAsync.when(
      data: (charters) {
        final idx = charters.indexWhere((c) => c.id == widget.charterId);
        if (idx < 0) return const Scaffold(body: Center(child: Text('Not found')));
        final charter = charters[idx];
        final members = _buildMembers(charter);

        // SB je podmienený vyplnenou kartou lode a posádky — bez lode a
        // skippera nemá kto a za čo podpisovať.
        final detailsComplete = (charter.vesselName?.isNotEmpty ?? false) &&
            (charter.skipperName?.isNotEmpty ?? false);
        if (!detailsComplete) {
          final l = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(title: Text(l.safetyBriefingScreenTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_boat_outlined,
                        size: 48, color: Colors.grey.shade500),
                    const SizedBox(height: 16),
                    Text(l.sbNeedsVesselCard,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: const Icon(Icons.directions_boat),
                      label: Text(l.editCharter),
                      onPressed: () =>
                          context.go('/logbook/${widget.charterId}/edit'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        _init(widget.charterId, members);

        return Scaffold(
          appBar: AppBar(
            title: Text(l.safetyBriefingScreenTitle),
            actions: [
              if (_saving)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: l.briefingSave,
                  onPressed: () => _save(context, charter, members),
                ),
            ],
          ),
          body: NotificationListener<ScrollNotification>(
            // Block scroll while drawing
            onNotification: (_) => _scrollLocked,
            child: ListView(
              controller: _scrollCtrl,
              physics: _scrollLocked
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // ── Done banner ───────────────────────────────
                if (charter.safetyBriefingDone)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.verified, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.briefingDoneLabel,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Text(l.briefingDoneSubtitle,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      )),
                    ]),
                  ),

                // ── Charter header ────────────────────────────
                _CharterHeader(charter: charter),
                const SizedBox(height: 16),

                // ── Checklist (only when not yet completed) ───
                if (!charter.safetyBriefingDone) ...[
                  _ChecklistCard(
                    checked: _checkedItems,
                    onChanged: (i, v) => setState(() {
                      if (v) _checkedItems.add(i);
                      else _checkedItems.remove(i);
                    }),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Crew signatures ───────────────────────────
                Text(l.briefingCrewSignaturesSection,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),

                if (members.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(l.briefingNoCrew,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic)),
                  )
                else
                  ...members.asMap().entries.map((e) {
                    final i = e.key;
                    final m = e.value;
                    return _SignatureCard(
                      key: ValueKey(i),
                      member: m,
                      existingPath: _existingPaths[i],
                      strokes: _strokes[i] ?? [],
                      padKey: _padKeys[i] ?? GlobalKey(),
                      isEditing: _editing.contains(i),
                      onStartEdit: () => setState(() => _editing.add(i)),
                      onStrokeAdded: (stroke) => setState(() {
                        _strokes.putIfAbsent(i, () => []).add(stroke);
                        _existingPaths[i] = null;
                      }),
                      onClear: () => setState(() {
                        _strokes[i] = [];
                        _editing.add(i);
                      }),
                      onDrawStart: () => setState(() => _scrollLocked = true),
                      onDrawEnd: () => setState(() => _scrollLocked = false),
                    );
                  }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }

  Future<void> _save(BuildContext context, Charter charter,
      List<({String name, String role})> members) async {
    if (_saving) return;

    // Briefing bez podpisov nemá hodnotu — ulož len keď je podpísaný
    // každý člen posádky (nakreslený ťah alebo už uložený podpis).
    final unsigned = <String>[];
    for (var i = 0; i < members.length; i++) {
      final hasDrawn = (_strokes[i] ?? const []).isNotEmpty;
      final hasSaved = _existingPaths[i] != null;
      if (!hasDrawn && !hasSaved) unsigned.add(members[i].name);
    }
    if (members.isEmpty || unsigned.isNotEmpty) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(members.isEmpty
            ? l.briefingNoCrew
            : '${l.briefingSignHere}: ${unsigned.join(", ")}'),
        backgroundColor: Colors.orange.shade800,
      ));
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(databaseProvider);
      final docsDir = await getApplicationDocumentsDirectory();
      final sigDir = Directory(
          '${docsDir.path}/signatures/charter_${widget.charterId}');
      await sigDir.create(recursive: true);

      for (var i = 0; i < members.length; i++) {
        final m = members[i];
        String? savePath = _existingPaths[i];
        final strokes = _strokes[i] ?? [];

        if (strokes.isNotEmpty) {
          final bytes = await _padKeys[i]?.currentState?.toBytes();
          if (bytes != null) {
            final safe = m.name.replaceAll(RegExp(r'[^\w]'), '_');
            final file = File('${sigDir.path}/${i}_$safe.png');
            await file.writeAsBytes(bytes);
            savePath = file.path;
            _existingPaths[i] = savePath;
            _strokes[i] = [];
            _editing.remove(i);
          }
        }

        await db.upsertCrewSignature(CrewSignaturesCompanion.insert(
          charterId: widget.charterId,
          crewName: _dbKey(i, m.name),
          role: Value(m.role),
          signaturePath: Value(savePath),
          signedAt: Value(savePath != null ? DateTime.now().toUtc() : null),
        ));
      }

      await db.updateCharter(ChartersCompanion(
        id: Value(widget.charterId),
        safetyBriefingDone: const Value(true),
      ));
      ref.invalidate(chartersProvider);

      if (context.mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.briefingSavedOk),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e, st) {
      debugPrint('[BRIEFING SAVE] ERROR: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chyba pri ukladaní: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Charter header ────────────────────────────────────────────

class _CharterHeader extends StatelessWidget {
  final Charter charter;
  const _CharterHeader({required this.charter});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d. MMMM yyyy', 'sk');
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(charter.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        if (charter.vesselName != null)
          Text('⛵ ${charter.vesselName}',
              style: TextStyle(color: Colors.grey.shade600)),
        Text('${fmt.format(charter.dateFrom)} – ${fmt.format(charter.dateTo)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        if (charter.homePort != null)
          Text('⚓ ${charter.homePort}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ]),
    ));
  }
}

// ── Safety checklist ──────────────────────────────────────────

class _ChecklistCard extends StatelessWidget {
  final Set<int> checked;
  final void Function(int, bool) onChanged;
  const _ChecklistCard({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      l.briefingItem1, l.briefingItem2, l.briefingItem3, l.briefingItem4,
      l.briefingItem5, l.briefingItem6, l.briefingItem7, l.briefingItem8,
      l.briefingItem9, l.briefingItem10, l.briefingItem11, l.briefingItem12,
    ];
    return Card(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(l.safetyBriefingCard,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const Divider(height: 8),
        ...items.asMap().entries.map((e) => CheckboxListTile(
          dense: true,
          value: checked.contains(e.key),
          onChanged: (v) => onChanged(e.key, v ?? false),
          title: Text(e.value, style: const TextStyle(fontSize: 13)),
          controlAffinity: ListTileControlAffinity.leading,
        )),
      ]),
    ));
  }
}

// ── Single signature card ─────────────────────────────────────

class _SignatureCard extends StatelessWidget {
  final ({String name, String role}) member;
  final String? existingPath;
  final List<List<Offset>> strokes;
  final GlobalKey<SignaturePadState> padKey;
  final bool isEditing;
  final VoidCallback onStartEdit;
  final void Function(List<Offset>) onStrokeAdded;
  final VoidCallback onClear;
  final VoidCallback onDrawStart;
  final VoidCallback onDrawEnd;

  const _SignatureCard({
    super.key,
    required this.member,
    required this.existingPath,
    required this.strokes,
    required this.padKey,
    required this.isEditing,
    required this.onStartEdit,
    required this.onStrokeAdded,
    required this.onClear,
    required this.onDrawStart,
    required this.onDrawEnd,
  });

  bool get _hasSaved => existingPath != null && File(existingPath!).existsSync();
  bool get _hasDrawn => strokes.isNotEmpty;
  bool get _showPad => isEditing || _hasDrawn || !_hasSaved;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isSigned = _hasSaved || _hasDrawn;
    final roleLabel =
        member.role == 'skipper' ? l.briefingSkipper : l.briefingCrew;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Icon(
              member.role == 'skipper' ? Icons.star : Icons.person,
              size: 16,
              color: member.role == 'skipper' ? Colors.amber : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(roleLabel,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(width: 8),
            Expanded(child: Text(member.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15))),
            if (isSigned)
              const Icon(Icons.verified, color: Colors.green, size: 20),
          ]),
          const SizedBox(height: 10),

          // Saved PNG (read-only) — shown when signed and not editing
          if (_hasSaved && !_showPad) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(File(existingPath!),
                  height: 90, fit: BoxFit.contain,
                  alignment: Alignment.centerLeft),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: onStartEdit,
              icon: const Icon(Icons.edit, size: 14),
              label: Text(l.briefingEditSignature,
                  style: const TextStyle(fontSize: 12)),
            ),
          ],

          // Signature pad — shown when no saved sig, or editing, or has drawn
          if (_showPad) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SignaturePad(
                  key: padKey,
                  strokes: strokes,
                  onStrokeAdded: onStrokeAdded,
                  onDrawStart: onDrawStart,
                  onDrawEnd: onDrawEnd,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(children: [
              Text(l.briefingSignHere,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic)),
              const Spacer(),
              TextButton(
                onPressed: onClear,
                child: Text(l.briefingClear,
                    style: const TextStyle(fontSize: 12)),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}
