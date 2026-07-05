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
import '../../../export/presentation/signature_pad_dialog.dart';
import '../../providers/miles_provider.dart';

/// Záznam do Knihy míľ pre plavbu z trackingu/GPX importu (na rozdiel od
/// ručne zadanej [HistoricalVoyageFormScreen]). Dátumy/míle/oblasť sa berú
/// z Charter+DayLogs a sú tu len na zobrazenie – uprav ich cez Denník
/// plavby. Editovateľné je len to, čo z trackingu nevieme: trasa (ak
/// chýbajú prístavy), vlajka, kapitán a jeho podpis potvrdzujúci míle.
class CharterLogbookRecordScreen extends ConsumerStatefulWidget {
  final int charterId;
  const CharterLogbookRecordScreen({super.key, required this.charterId});

  @override
  ConsumerState<CharterLogbookRecordScreen> createState() =>
      _CharterLogbookRecordScreenState();
}

class _CharterLogbookRecordScreenState extends ConsumerState<CharterLogbookRecordScreen> {
  final _vesselCtrl = TextEditingController();
  final _vesselTypeCtrl = TextEditingController();
  final _vesselFlagCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _captainFirstCtrl = TextEditingController();
  final _captainLastCtrl = TextEditingController();
  final _captainQualCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  Charter? _charter;
  List<DayLog> _days = [];
  String? _signaturePath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final charter = await db.getCharterById(widget.charterId);
    if (charter == null || !mounted) return;
    final days = await db.getDayLogs(widget.charterId);

    _vesselCtrl.text = charter.vesselName ?? '';
    _vesselTypeCtrl.text = charter.vesselType ?? '';
    _vesselFlagCtrl.text = charter.vesselFlag ?? '';
    _routeCtrl.text = charter.route ?? _defaultRoute(days);
    _roleCtrl.text = charter.myRole ?? '';
    _captainFirstCtrl.text = charter.captainFirstName ?? '';
    _captainLastCtrl.text = charter.captainLastName ?? '';
    _captainQualCtrl.text = charter.captainQualification ?? '';
    _noteCtrl.text = charter.notes ?? '';

    setState(() {
      _charter = charter;
      _days = days;
      _signaturePath = charter.logbookSignaturePath;
      _loading = false;
    });
  }

  String _defaultRoute(List<DayLog> days) {
    if (days.isEmpty) return '';
    final from = days.first.portFrom;
    final to = days.last.portTo;
    if (from == null || to == null) return '';
    return '$from → $to';
  }

  Future<void> _captureSignature() async {
    final captainName = '${_captainFirstCtrl.text.trim()} ${_captainLastCtrl.text.trim()}'.trim();
    final bytes = await showSignaturePadDialog(context,
        signerName: captainName.isEmpty ? null : captainName);
    if (bytes == null || !mounted) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final sigDir = Directory('${docsDir.path}/signatures/charter_logbook');
    await sigDir.create(recursive: true);
    final file = File('${sigDir.path}/${widget.charterId}.png');
    await file.writeAsBytes(bytes);
    if (mounted) setState(() => _signaturePath = file.path);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);

    await db.updateCharter(ChartersCompanion(
      id: Value(widget.charterId),
      vesselName: Value(_vesselCtrl.text.trim().isEmpty ? null : _vesselCtrl.text.trim()),
      vesselType: Value(_vesselTypeCtrl.text.trim().isEmpty ? null : _vesselTypeCtrl.text.trim()),
      vesselFlag: Value(_vesselFlagCtrl.text.trim().isEmpty ? null : _vesselFlagCtrl.text.trim()),
      route: Value(_routeCtrl.text.trim().isEmpty ? null : _routeCtrl.text.trim()),
      myRole: Value(_roleCtrl.text.trim().isEmpty ? null : _roleCtrl.text.trim()),
      captainFirstName:
          Value(_captainFirstCtrl.text.trim().isEmpty ? null : _captainFirstCtrl.text.trim()),
      captainLastName:
          Value(_captainLastCtrl.text.trim().isEmpty ? null : _captainLastCtrl.text.trim()),
      captainQualification:
          Value(_captainQualCtrl.text.trim().isEmpty ? null : _captainQualCtrl.text.trim()),
      logbookSignaturePath: Value(_signaturePath),
      notes: Value(_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()),
    ));

    ref.invalidate(milesAggregateProvider);
    ref.invalidate(milesAvailableYearsProvider);

    setState(() => _saving = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final charter = _charter;
    if (charter == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.error)));
    }

    final fmt = DateFormat('d.M.yyyy');
    final totalNm = _days.fold<double>(0, (sum, d) => sum + d.distanceNm);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.logbookRecordTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(charter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${fmt.format(charter.dateFrom)} – ${fmt.format(charter.dateTo)}'
                  '  ·  ${totalNm.toStringAsFixed(1)} NM'
                  '${charter.homePort != null ? "  ·  ${charter.homePort}" : ""}'),
              const SizedBox(height: 6),
              Text(l.logbookTrackedHint,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
        ),
        const SizedBox(height: 16),

        TextField(controller: _vesselCtrl, decoration: InputDecoration(labelText: l.vessel)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _vesselTypeCtrl, decoration: InputDecoration(labelText: l.vesselType))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _vesselFlagCtrl, decoration: InputDecoration(labelText: l.vesselFlag))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _routeCtrl, decoration: InputDecoration(labelText: l.routeSection)),
        const SizedBox(height: 12),
        TextField(controller: _roleCtrl, decoration: InputDecoration(labelText: l.roleLabel)),
        const SizedBox(height: 16),

        Text(l.logbookSignatureSection, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _captainFirstCtrl, decoration: InputDecoration(labelText: l.captainFirstName))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _captainLastCtrl, decoration: InputDecoration(labelText: l.captainLastName))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _captainQualCtrl, decoration: InputDecoration(labelText: l.captainQualification)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: Icon(_signaturePath == null ? Icons.draw : Icons.edit),
          label: Text(_signaturePath == null ? l.addSignature : l.briefingEditSignature),
          onPressed: _captureSignature,
        ),
        if (_signaturePath != null) ...[
          const SizedBox(height: 8),
          Container(
            height: 80,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
            child: Image.file(File(_signaturePath!), fit: BoxFit.contain),
          ),
        ],
        const SizedBox(height: 16),

        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: l.noteSection),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _vesselCtrl.dispose();
    _vesselTypeCtrl.dispose();
    _vesselFlagCtrl.dispose();
    _routeCtrl.dispose();
    _roleCtrl.dispose();
    _captainFirstCtrl.dispose();
    _captainLastCtrl.dispose();
    _captainQualCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
