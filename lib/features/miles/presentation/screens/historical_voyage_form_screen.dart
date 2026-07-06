import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/skipper_profile_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../export/presentation/signature_pad_dialog.dart';
import '../../providers/miles_provider.dart';

class HistoricalVoyageFormScreen extends ConsumerStatefulWidget {
  final String? voyageId;
  const HistoricalVoyageFormScreen({super.key, this.voyageId});

  @override
  ConsumerState<HistoricalVoyageFormScreen> createState() => _HistoricalVoyageFormScreenState();
}

class _HistoricalVoyageFormScreenState extends ConsumerState<HistoricalVoyageFormScreen> {
  final _vesselCtrl = TextEditingController();
  final _vesselTypeCtrl = TextEditingController();
  final _vesselFlagCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  final _nmCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _nightHoursCtrl = TextEditingController();
  final _roleCtrl = TextEditingController(text: 'skipper');
  final _captainFirstCtrl = TextEditingController();
  final _captainLastCtrl = TextEditingController();
  final _captainQualCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now();
  String? _signaturePath;
  bool _loading = false;
  int? _existingId;

  bool get _isNew => widget.voyageId == null;

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      _load();
    } else {
      _prefillCaptainFromProfile();
    }
  }

  Future<void> _prefillCaptainFromProfile() async {
    final profile = await ref.read(skipperProfileProvider.future);
    if (!mounted || profile.fullName.isEmpty) return;
    final parts = profile.fullName.trim().split(RegExp(r'\s+'));
    setState(() {
      _captainFirstCtrl.text = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' ') : parts.first;
      _captainLastCtrl.text = parts.length > 1 ? parts.last : '';
      if (profile.licenseType.isNotEmpty) _captainQualCtrl.text = profile.licenseType;
    });
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.voyageId!);
    if (id == null) return;
    final all = await ref.read(databaseProvider).getAllHistoricalVoyages();
    final v = all.where((v) => v.id == id).firstOrNull;
    if (v == null || !mounted) return;
    setState(() {
      _existingId = v.id;
      _dateFrom = v.dateFrom;
      _dateTo = v.dateTo;
      _vesselCtrl.text = v.vesselName;
      _vesselTypeCtrl.text = v.vesselType ?? '';
      _vesselFlagCtrl.text = v.vesselFlag ?? '';
      _areaCtrl.text = v.area ?? '';
      _routeCtrl.text = v.route ?? '';
      _nmCtrl.text = v.distanceNm.toString();
      _daysCtrl.text = v.daysCount?.toString() ?? '';
      _nightHoursCtrl.text = v.nightHours?.toString() ?? '';
      _roleCtrl.text = v.role;
      _captainFirstCtrl.text = v.captainFirstName ?? '';
      _captainLastCtrl.text = v.captainLastName ?? '';
      _captainQualCtrl.text = v.captainQualification ?? '';
      _signaturePath = v.logbookSignaturePath;
      _noteCtrl.text = v.note ?? '';
    });
  }

  Future<void> _pickDate(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isFrom ? _dateFrom : _dateTo,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = d;
        if (_dateTo.isBefore(_dateFrom)) _dateTo = _dateFrom;
      } else {
        _dateTo = d;
      }
    });
  }

  Future<void> _captureSignature() async {
    final captainName = '${_captainFirstCtrl.text.trim()} ${_captainLastCtrl.text.trim()}'.trim();
    final bytes = await showSignaturePadDialog(context,
        signerName: captainName.isEmpty ? null : captainName);
    if (bytes == null || !mounted) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final sigDir = Directory('${docsDir.path}/signatures/historical_voyages');
    await sigDir.create(recursive: true);
    final file = File('${sigDir.path}/${_existingId ?? DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    if (mounted) setState(() => _signaturePath = file.path);
  }

  Future<void> _save() async {
    if (_vesselCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);

    final companion = HistoricalVoyagesCompanion(
      dateFrom: Value(_dateFrom),
      dateTo: Value(_dateTo),
      vesselName: Value(_vesselCtrl.text.trim()),
      vesselType: Value(_vesselTypeCtrl.text.trim().isEmpty ? null : _vesselTypeCtrl.text.trim()),
      vesselFlag: Value(_vesselFlagCtrl.text.trim().isEmpty ? null : _vesselFlagCtrl.text.trim()),
      area: Value(_areaCtrl.text.trim().isEmpty ? null : _areaCtrl.text.trim()),
      route: Value(_routeCtrl.text.trim().isEmpty ? null : _routeCtrl.text.trim()),
      distanceNm: Value(double.tryParse(_nmCtrl.text) ?? 0),
      daysCount: Value(int.tryParse(_daysCtrl.text)),
      nightHours: Value(double.tryParse(_nightHoursCtrl.text)),
      role: Value(_roleCtrl.text.trim().isEmpty ? 'skipper' : _roleCtrl.text.trim()),
      captainFirstName:
          Value(_captainFirstCtrl.text.trim().isEmpty ? null : _captainFirstCtrl.text.trim()),
      captainLastName:
          Value(_captainLastCtrl.text.trim().isEmpty ? null : _captainLastCtrl.text.trim()),
      captainQualification:
          Value(_captainQualCtrl.text.trim().isEmpty ? null : _captainQualCtrl.text.trim()),
      logbookSignaturePath: Value(_signaturePath),
      note: Value(_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()),
      createdAt: Value(DateTime.now()),
    );

    if (_existingId != null) {
      await db.updateHistoricalVoyage(_existingId!, companion);
    } else {
      await db.insertHistoricalVoyage(companion);
    }

    ref.invalidate(milesAggregateProvider);
    ref.invalidate(historicalVoyagesProvider);
    ref.invalidate(milesAvailableYearsProvider);

    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.delete),
        content: Text(l.deleteHistoricalVoyageConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || _existingId == null) return;

    await ref.read(databaseProvider).deleteHistoricalVoyage(_existingId!);
    ref.invalidate(milesAggregateProvider);
    ref.invalidate(historicalVoyagesProvider);
    ref.invalidate(milesAvailableYearsProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = DateFormat('d. MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.addHistoricalVoyage : l.editHistoricalVoyage),
        actions: [
          if (!_isNew) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(l.save, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(child: InkWell(
            onTap: () => _pickDate(true),
            child: InputDecorator(
              decoration: InputDecoration(labelText: l.dateFrom, prefixIcon: const Icon(Icons.calendar_today)),
              child: Text(fmt.format(_dateFrom)),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: InkWell(
            onTap: () => _pickDate(false),
            child: InputDecorator(
              decoration: InputDecoration(labelText: l.dateTo, prefixIcon: const Icon(Icons.calendar_today)),
              child: Text(fmt.format(_dateTo)),
            ),
          )),
        ]),
        const SizedBox(height: 16),

        TextField(controller: _vesselCtrl, decoration: InputDecoration(labelText: l.vessel)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _vesselTypeCtrl, decoration: InputDecoration(labelText: l.vesselType))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _vesselFlagCtrl, decoration: InputDecoration(labelText: l.vesselFlag))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _areaCtrl, decoration: InputDecoration(labelText: l.areaLabel)),
        const SizedBox(height: 12),
        TextField(controller: _routeCtrl, decoration: InputDecoration(labelText: l.routeSection)),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: TextField(
            controller: _nmCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.distanceNmLabel),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: _daysCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.daysCountLabel),
          )),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _nightHoursCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.nightHoursLabel),
        ),
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
    _areaCtrl.dispose();
    _routeCtrl.dispose();
    _nmCtrl.dispose();
    _daysCtrl.dispose();
    _nightHoursCtrl.dispose();
    _roleCtrl.dispose();
    _captainFirstCtrl.dispose();
    _captainLastCtrl.dispose();
    _captainQualCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
