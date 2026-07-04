import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../providers/miles_provider.dart';

const _roles = ['skipper', 'coSkipper', 'crew'];

class HistoricalVoyageFormScreen extends ConsumerStatefulWidget {
  final String? voyageId;
  const HistoricalVoyageFormScreen({super.key, this.voyageId});

  @override
  ConsumerState<HistoricalVoyageFormScreen> createState() => _HistoricalVoyageFormScreenState();
}

class _HistoricalVoyageFormScreenState extends ConsumerState<HistoricalVoyageFormScreen> {
  final _vesselCtrl = TextEditingController();
  final _vesselTypeCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _nmCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _nightHoursCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now();
  String _role = 'skipper';
  bool _loading = false;
  int? _existingId;

  bool get _isNew => widget.voyageId == null;

  @override
  void initState() {
    super.initState();
    if (!_isNew) _load();
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
      _areaCtrl.text = v.area ?? '';
      _nmCtrl.text = v.distanceNm.toString();
      _daysCtrl.text = v.daysCount?.toString() ?? '';
      _nightHoursCtrl.text = v.nightHours?.toString() ?? '';
      _role = v.role;
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

  Future<void> _save() async {
    if (_vesselCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);

    final companion = HistoricalVoyagesCompanion(
      dateFrom: Value(_dateFrom),
      dateTo: Value(_dateTo),
      vesselName: Value(_vesselCtrl.text.trim()),
      vesselType: Value(_vesselTypeCtrl.text.trim().isEmpty ? null : _vesselTypeCtrl.text.trim()),
      area: Value(_areaCtrl.text.trim().isEmpty ? null : _areaCtrl.text.trim()),
      distanceNm: Value(double.tryParse(_nmCtrl.text) ?? 0),
      daysCount: Value(int.tryParse(_daysCtrl.text)),
      nightHours: Value(double.tryParse(_nightHoursCtrl.text)),
      role: Value(_role),
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

  String _roleLabel(AppLocalizations l, String role) => switch (role) {
        'coSkipper' => l.roleCoSkipper,
        'crew' => l.roleCrew,
        _ => l.roleSkipper,
      };

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
            child: Text(l.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        TextField(controller: _vesselTypeCtrl, decoration: InputDecoration(labelText: l.vesselType)),
        const SizedBox(height: 12),
        TextField(controller: _areaCtrl, decoration: InputDecoration(labelText: l.areaLabel)),
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
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _role,
          decoration: InputDecoration(labelText: l.roleLabel),
          items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(_roleLabel(l, r)))).toList(),
          onChanged: (v) => setState(() => _role = v ?? 'skipper'),
        ),
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
    _areaCtrl.dispose();
    _nmCtrl.dispose();
    _daysCtrl.dispose();
    _nightHoursCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
