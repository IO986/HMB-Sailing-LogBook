import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/signature_pad.dart';
import '../../../export/services/pdf_export_service.dart';
import '../../providers/charter_provider.dart';
import '../../services/handover_checklist.dart';

String _statusLabel(AppLocalizations l, ChecklistStatus s) => switch (s) {
      ChecklistStatus.ok => l.checklistItemOk,
      ChecklistStatus.damaged => l.checklistItemDamaged,
      ChecklistStatus.missing => l.checklistItemMissing,
    };

class HandoverProtocolScreen extends ConsumerStatefulWidget {
  final int charterId;
  final String type; // 'checkIn' | 'checkOut'
  const HandoverProtocolScreen({super.key, required this.charterId, required this.type});

  @override
  ConsumerState<HandoverProtocolScreen> createState() => _HandoverProtocolScreenState();
}

class _HandoverProtocolScreenState extends ConsumerState<HandoverProtocolScreen> {
  Charter? _charter;
  HandoverProtocol? _existing;

  DateTime _dateTime = DateTime.now();
  final _locationCtrl = TextEditingController();
  final _engineHoursCtrl = TextEditingController();
  final _extraNotesCtrl = TextEditingController();
  int? _fuelLevel;
  int? _waterLevel;
  late List<ChecklistItem> _checklist = defaultChecklist(widget.type);

  final _skipperNameCtrl = TextEditingController();
  final _companyRepCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  List<List<Offset>> _skipperStrokes = [];
  List<List<Offset>> _companyStrokes = [];
  final _skipperPadKey = GlobalKey<SignaturePadState>();
  final _companyPadKey = GlobalKey<SignaturePadState>();
  String? _skipperSignaturePath;
  DateTime? _skipperSignedAt;
  String? _companySignaturePath;
  DateTime? _companySignedAt;

  bool _loading = true;
  bool _saving = false;

  bool get _isCheckOut => widget.type == 'checkOut';
  bool get _isClosed => _skipperSignedAt != null && _companySignedAt != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final charters = await db.getAllCharters();
    _charter = charters.where((c) => c.id == widget.charterId).firstOrNull;
    _skipperNameCtrl.text = _charter?.skipperName ?? '';

    final existing = await db.getHandoverProtocol(widget.charterId, widget.type);
    if (existing != null) {
      _existing = existing;
      _dateTime = existing.dateTimeUtc.toLocal();
      _locationCtrl.text = existing.location ?? '';
      _fuelLevel = existing.fuelLevel;
      _waterLevel = existing.waterLevel;
      _engineHoursCtrl.text = existing.engineHours?.toString() ?? '';
      _extraNotesCtrl.text = existing.extraNotes ?? '';
      _checklist = checklistFromJson(existing.checklistJson);
      _skipperNameCtrl.text = existing.skipperName ?? _skipperNameCtrl.text;
      _skipperSignaturePath = existing.skipperSignaturePath;
      _skipperSignedAt = existing.skipperSignedAt;
      _companyRepCtrl.text = existing.companyRepName ?? '';
      _companyNameCtrl.text = existing.companyName ?? '';
      _companySignaturePath = existing.companySignaturePath;
      _companySignedAt = existing.companySignedAt;
    } else if (_isCheckOut) {
      // Predvyplnenie spoločných metadát z check-in protokolu. Samotný
      // checklist NIE je rovnaký zoznam ako pri check-in (iné položky,
      // viď handover_checklist.dart) – stavia sa z vlastných checkOut
      // kategórií, nekopíruje sa.
      final checkIn = await db.getHandoverProtocol(widget.charterId, 'checkIn');
      if (checkIn != null) {
        _locationCtrl.text = checkIn.location ?? '';
        _fuelLevel = checkIn.fuelLevel;
        _waterLevel = checkIn.waterLevel;
        _engineHoursCtrl.text = checkIn.engineHours?.toString() ?? '';
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context, initialDate: _dateTime,
      firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    setState(() {
      _dateTime = DateTime(d.year, d.month, d.day, t?.hour ?? _dateTime.hour, t?.minute ?? _dateTime.minute);
    });
  }

  Future<void> _pickPhoto(int index, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (file == null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${docsDir.path}/handover_photos/charter_${widget.charterId}');
    await photoDir.create(recursive: true);
    final dest = File(
        '${photoDir.path}/${widget.type}_${_checklist[index].itemKey}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await File(file.path).copy(dest.path);

    setState(() => _checklist[index] = _checklist[index].copyWith(photoPath: dest.path));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final docsDir = await getApplicationDocumentsDirectory();
    final sigDir = Directory('${docsDir.path}/handover_signatures/charter_${widget.charterId}');
    await sigDir.create(recursive: true);

    var skipperPath = _skipperSignaturePath;
    var skipperSignedAt = _skipperSignedAt;
    if (_skipperStrokes.isNotEmpty) {
      final bytes = await _skipperPadKey.currentState?.toBytes();
      if (bytes != null) {
        final file = File('${sigDir.path}/${widget.type}_skipper.png');
        await file.writeAsBytes(bytes);
        skipperPath = file.path;
        skipperSignedAt = DateTime.now().toUtc();
      }
    }

    var companyPath = _companySignaturePath;
    var companySignedAt = _companySignedAt;
    if (_companyStrokes.isNotEmpty) {
      final bytes = await _companyPadKey.currentState?.toBytes();
      if (bytes != null) {
        final file = File('${sigDir.path}/${widget.type}_company.png');
        await file.writeAsBytes(bytes);
        companyPath = file.path;
        companySignedAt = DateTime.now().toUtc();
      }
    }

    await db.upsertHandoverProtocol(HandoverProtocolsCompanion(
      charterId: Value(widget.charterId),
      type: Value(widget.type),
      dateTimeUtc: Value(_dateTime.toUtc()),
      location: Value(_locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim()),
      fuelLevel: Value(_fuelLevel),
      waterLevel: Value(_waterLevel),
      engineHours: Value(double.tryParse(_engineHoursCtrl.text)),
      checklistJson: Value(checklistToJson(_checklist)),
      skipperName: Value(_skipperNameCtrl.text.trim().isEmpty ? null : _skipperNameCtrl.text.trim()),
      skipperSignaturePath: Value(skipperPath),
      skipperSignedAt: Value(skipperSignedAt),
      companyRepName: Value(_companyRepCtrl.text.trim().isEmpty ? null : _companyRepCtrl.text.trim()),
      companyName: Value(_companyNameCtrl.text.trim().isEmpty ? null : _companyNameCtrl.text.trim()),
      companySignaturePath: Value(companyPath),
      companySignedAt: Value(companySignedAt),
      extraNotes: Value(_extraNotesCtrl.text.trim().isEmpty ? null : _extraNotesCtrl.text.trim()),
      createdAt: Value(_existing?.createdAt ?? DateTime.now().toUtc()),
    ));

    ref.invalidate(chartersProvider);
    setState(() => _saving = false);
    if (mounted) context.pop();
  }

  Future<void> _exportPdf() async {
    final charter = _charter;
    if (charter == null) return;
    final db = ref.read(databaseProvider);
    final protocol = await db.getHandoverProtocol(widget.charterId, widget.type);
    if (protocol == null) return;

    final bytes = await PdfExportService.exportHandoverProtocol(
      charter: charter,
      protocol: protocol,
      checklist: checklistFromJson(protocol.checklistJson),
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/HMB_Protokol_${widget.type}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    if (mounted) await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_loading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    final title = _isCheckOut ? l.checkOutProtocol : l.checkInProtocol;
    final fmt = DateFormat('d.M.yyyy HH:mm');
    final readOnly = _isClosed;
    final categories = _isCheckOut ? checkOutCategories : checkInCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (readOnly || _existing != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: l.exportPdf,
              onPressed: _exportPdf,
            ),
          if (!readOnly)
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text(l.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (readOnly)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.lock_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(l.protocolClosedNotice)),
            ]),
          ),

        Text('${_charter?.vesselName ?? "-"}  ·  ${_charter?.callsign ?? _charter?.mmsi ?? ""}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(_charter?.title ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),

        InkWell(
          onTap: readOnly ? null : _pickDate,
          child: InputDecorator(
            decoration: InputDecoration(labelText: l.handoverDateTime, prefixIcon: const Icon(Icons.event)),
            child: Text(fmt.format(_dateTime)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationCtrl,
          enabled: !readOnly,
          decoration: InputDecoration(labelText: l.handoverLocation),
        ),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: TextField(
            controller: _engineHoursCtrl,
            enabled: !readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.engineHours, suffixText: 'h'),
          )),
        ]),
        const SizedBox(height: 12),
        _PercentField(label: l.fuelLevel, value: _fuelLevel,
            onChanged: readOnly ? null : (v) => setState(() => _fuelLevel = v)),
        _PercentField(label: l.waterLevel, value: _waterLevel,
            onChanged: readOnly ? null : (v) => setState(() => _waterLevel = v)),
        const SizedBox(height: 16),

        for (final category in categories)
          _CategorySection(
            category: category,
            localeCode: localeCode,
            l: l,
            readOnly: readOnly,
            checklist: _checklist,
            onItemChanged: readOnly
                ? null
                : (itemKey, updated) {
                    final idx = _checklist.indexWhere((i) => i.itemKey == itemKey);
                    if (idx != -1) setState(() => _checklist[idx] = updated);
                  },
            onPickPhoto: readOnly
                ? null
                : (itemKey, source) {
                    final idx = _checklist.indexWhere((i) => i.itemKey == itemKey);
                    if (idx != -1) _pickPhoto(idx, source);
                  },
          ),
        const SizedBox(height: 16),

        TextField(
          controller: _extraNotesCtrl,
          enabled: !readOnly,
          maxLines: 3,
          decoration: InputDecoration(labelText: l.extraNotesLabel),
        ),
        const SizedBox(height: 24),

        Text(l.skipperSignature, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: _skipperNameCtrl,
          enabled: !readOnly,
          decoration: InputDecoration(labelText: l.skipperSignature),
        ),
        const SizedBox(height: 8),
        _SignatureBox(
          existingPath: _skipperSignaturePath,
          strokes: _skipperStrokes,
          padKey: _skipperPadKey,
          readOnly: readOnly,
          onStrokeAdded: (s) => setState(() => _skipperStrokes = [..._skipperStrokes, s]),
          onClear: () => setState(() => _skipperStrokes = []),
          clearLabel: l.clear,
        ),
        const SizedBox(height: 24),

        Text(l.companySignatureSection, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: _companyRepCtrl,
          enabled: !readOnly,
          decoration: InputDecoration(labelText: l.companyRepName),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _companyNameCtrl,
          enabled: !readOnly,
          decoration: InputDecoration(labelText: l.companyNameLabel),
        ),
        const SizedBox(height: 8),
        _SignatureBox(
          existingPath: _companySignaturePath,
          strokes: _companyStrokes,
          padKey: _companyPadKey,
          readOnly: readOnly,
          onStrokeAdded: (s) => setState(() => _companyStrokes = [..._companyStrokes, s]),
          onClear: () => setState(() => _companyStrokes = []),
          clearLabel: l.clear,
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _engineHoursCtrl.dispose();
    _extraNotesCtrl.dispose();
    _skipperNameCtrl.dispose();
    _companyRepCtrl.dispose();
    _companyNameCtrl.dispose();
    super.dispose();
  }
}

// ── Helpers ───────────────────────────────────────────────────

class _PercentField extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int?>? onChanged;
  const _PercentField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final has = value != null;
    final readOnly = onChanged == null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(has ? '$value%' : '–',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: has ? null : Theme.of(context).colorScheme.outline)),
        if (!readOnly)
          IconButton(
            icon: Icon(has ? Icons.close : Icons.add, size: 18),
            onPressed: () => onChanged!(has ? null : 50),
          ),
      ]),
      if (has)
        Slider(
          value: value!.toDouble(), min: 0, max: 100, divisions: 20,
          label: '$value%',
          onChanged: readOnly ? null : (v) => onChanged!(v.round()),
        ),
    ]);
  }
}

/// Jedna zbaliteľná kategória checklistu (napr. "Elektrické vybavenie")
/// so svojimi položkami. Predvolene zbalená kvôli objemu (~70 položiek
/// pri check-in).
class _CategorySection extends StatefulWidget {
  final HandoverCategoryDef category;
  final String localeCode;
  final AppLocalizations l;
  final bool readOnly;
  final List<ChecklistItem> checklist;
  final void Function(String itemKey, ChecklistItem updated)? onItemChanged;
  final void Function(String itemKey, ImageSource source)? onPickPhoto;

  const _CategorySection({
    required this.category,
    required this.localeCode,
    required this.l,
    required this.readOnly,
    required this.checklist,
    required this.onItemChanged,
    required this.onPickPhoto,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  @override
  Widget build(BuildContext context) {
    final itemKeys = widget.category.items.map((i) => i.key).toSet();
    final items = widget.checklist.where((i) => itemKeys.contains(i.itemKey)).toList();
    final issues = items.where((i) => i.status != ChecklistStatus.ok).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(categoryLabel(widget.localeCode, widget.category),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: issues > 0
            ? Text('$issues ⚠', style: TextStyle(color: Colors.red.shade700, fontSize: 12))
            : null,
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          for (final itemDef in widget.category.items)
            _ChecklistItemTile(
              item: widget.checklist.firstWhere((i) => i.itemKey == itemDef.key),
              itemDef: itemDef,
              localeCode: widget.localeCode,
              l: widget.l,
              readOnly: widget.readOnly,
              onChanged: widget.onItemChanged == null
                  ? null
                  : (updated) => widget.onItemChanged!(itemDef.key, updated),
              onPickPhoto: widget.onPickPhoto == null
                  ? null
                  : (source) => widget.onPickPhoto!(itemDef.key, source),
            ),
        ],
      ),
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final HandoverItemDef itemDef;
  final String localeCode;
  final AppLocalizations l;
  final bool readOnly;
  final ValueChanged<ChecklistItem>? onChanged;
  final ValueChanged<ImageSource>? onPickPhoto;

  const _ChecklistItemTile({
    required this.item,
    required this.itemDef,
    required this.localeCode,
    required this.l,
    required this.readOnly,
    required this.onChanged,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final expanded = item.status != ChecklistStatus.ok;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(itemLabel(localeCode, itemDef), style: const TextStyle(fontWeight: FontWeight.w600)),
          if (localeCode == 'sk')
            Text('(${itemDef.labelEn})',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          SegmentedButton<ChecklistStatus>(
            segments: ChecklistStatus.values
                .map((s) => ButtonSegment(value: s, label: Text(_statusLabel(l, s))))
                .toList(),
            selected: {item.status},
            onSelectionChanged: readOnly || onChanged == null
                ? null
                : (s) => onChanged!(item.copyWith(status: s.first)),
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.note,
              enabled: !readOnly,
              decoration: InputDecoration(labelText: l.noteSection),
              onChanged: onChanged == null ? null : (v) => onChanged!(item.copyWith(note: v)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.position,
              enabled: !readOnly,
              decoration: InputDecoration(labelText: l.damagePosition),
              onChanged: onChanged == null ? null : (v) => onChanged!(item.copyWith(position: v)),
            ),
            const SizedBox(height: 8),
            if (item.photoPath != null && File(item.photoPath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(item.photoPath!), height: 140, fit: BoxFit.cover),
              )
            else if (!readOnly && onPickPhoto != null)
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l.camera),
                  onPressed: () => onPickPhoto!(ImageSource.camera),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: Text(l.gallery),
                  onPressed: () => onPickPhoto!(ImageSource.gallery),
                )),
              ]),
          ],
        ]),
      ),
    );
  }
}

class _SignatureBox extends StatelessWidget {
  final String? existingPath;
  final List<List<Offset>> strokes;
  final GlobalKey<SignaturePadState> padKey;
  final bool readOnly;
  final ValueChanged<List<Offset>> onStrokeAdded;
  final VoidCallback onClear;
  final String clearLabel;

  const _SignatureBox({
    required this.existingPath,
    required this.strokes,
    required this.padKey,
    required this.readOnly,
    required this.onStrokeAdded,
    required this.onClear,
    required this.clearLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasSaved = existingPath != null && File(existingPath!).existsSync();
    if (hasSaved && strokes.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: Colors.white,
          height: 100,
          alignment: Alignment.centerLeft,
          child: Image.file(File(existingPath!), height: 90, fit: BoxFit.contain),
        ),
      );
    }
    if (readOnly) {
      return Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
        alignment: Alignment.center,
        child: const Icon(Icons.edit_off, color: Colors.grey),
      );
    }
    return Column(children: [
      Container(
        height: 120,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
        child: SignaturePad(
          key: padKey,
          strokes: strokes,
          onStrokeAdded: onStrokeAdded,
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.clear, size: 14),
          label: Text(clearLabel, style: const TextStyle(fontSize: 12)),
        ),
      ),
    ]);
  }
}
