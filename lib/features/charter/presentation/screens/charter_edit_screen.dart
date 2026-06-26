import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class CharterEditScreen extends ConsumerStatefulWidget {
  final String? charterId;
  const CharterEditScreen({super.key, this.charterId});

  @override
  ConsumerState<CharterEditScreen> createState() => _CharterEditScreenState();
}

class _CharterEditScreenState extends ConsumerState<CharterEditScreen> {
  final _titleCtrl = TextEditingController();
  final _vesselCtrl = TextEditingController();
  final _vesselTypeCtrl = TextEditingController();
  final _homePortCtrl = TextEditingController();
  final _skipperCtrl = TextEditingController();
  final _crewCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now().add(const Duration(days: 7));
  bool _briefing = false, _checkIn = false, _checkOut = false;
  bool _loading = false;
  Charter? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.charterId != null) _loadCharter();
  }

  Future<void> _loadCharter() async {
    final db = ref.read(databaseProvider);
    final all = await db.getAllCharters();
    final id = int.tryParse(widget.charterId!);
    if (id == null) return;
    try {
      final c = all.firstWhere((c) => c.id == id);
      setState(() {
        _existing = c;
        _titleCtrl.text = c.title;
        _vesselCtrl.text = c.vesselName ?? '';
        _vesselTypeCtrl.text = c.vesselType ?? '';
        _homePortCtrl.text = c.homePort ?? '';
        _skipperCtrl.text = c.skipperName ?? '';
        _crewCtrl.text = (c.crewNames ?? '').replaceAll('|', ', ');
        _notesCtrl.text = c.notes ?? '';
        _dateFrom = c.dateFrom;
        _dateTo = c.dateTo;
        _briefing = c.safetyBriefingDone;
        _checkIn = c.checkInDone;
        _checkOut = c.checkOutDone;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.charterId == null;
    final fmt = DateFormat('d. MMM yyyy', 'sk');
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l.newMultidayVoyage : l.editCharter),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l.save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(l.basicInfo),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l.voyageNameRequired,
              hintText: 'e.g. Trip 2–9 May 2026',
              prefixIcon: const Icon(Icons.sailing),
            ),
          ),
          const SizedBox(height: 12),
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

          _Section(l.vessel),
          TextField(
            controller: _vesselCtrl,
            decoration: InputDecoration(
              labelText: l.vesselName,
              hintText: 'e.g. Elan 45',
              prefixIcon: const Icon(Icons.directions_boat),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vesselTypeCtrl,
            decoration: InputDecoration(
              labelText: l.vesselType,
              hintText: 'Sailboat / Catamaran / Motor...',
              prefixIcon: const Icon(Icons.category),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _homePortCtrl,
            decoration: InputDecoration(
              labelText: l.homePort,
              hintText: 'Departure/arrival port',
              prefixIcon: const Icon(Icons.anchor),
            ),
          ),
          const SizedBox(height: 16),

          _Section(l.crew),
          TextField(
            controller: _skipperCtrl,
            decoration: InputDecoration(
              labelText: l.captain,
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _crewCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l.crew,
              hintText: 'Names separated by comma\ne.g. Peter Smith, Jana Smith',
              prefixIcon: const Icon(Icons.group),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          _Section(l.notesLabel),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '${l.notesLabel}...',
              prefixIcon: const Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          _Section(l.statusLabel),
          CheckboxListTile(
            title: Text(l.safetyBriefingDoneLabel),
            value: _briefing,
            onChanged: (v) => setState(() => _briefing = v ?? false),
            secondary: const Icon(Icons.checklist),
          ),
          CheckboxListTile(
            title: Text(l.checkInDoneLabel),
            value: _checkIn,
            onChanged: (v) => setState(() => _checkIn = v ?? false),
            secondary: const Icon(Icons.login),
          ),
          CheckboxListTile(
            title: Text(l.checkOutDoneLabel),
            value: _checkOut,
            onChanged: (v) => setState(() => _checkOut = v ?? false),
            secondary: const Icon(Icons.logout),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _pickDate(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isFrom ? _dateFrom : _dateTo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = d;
        if (_dateTo.isBefore(_dateFrom)) _dateTo = _dateFrom.add(const Duration(days: 7));
      } else {
        _dateTo = d;
      }
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).enterVoyageName)));
      return;
    }
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);
    final crew = _crewCtrl.text.trim().isEmpty ? null
        : _crewCtrl.text.split(',').map((e) => e.trim())
            .where((e) => e.isNotEmpty).join('|');

    final companion = ChartersCompanion(
      id: _existing != null ? Value(_existing!.id) : const Value.absent(),
      title: Value(_titleCtrl.text.trim()),
      dateFrom: Value(_dateFrom),
      dateTo: Value(_dateTo),
      vesselName: Value(_vesselCtrl.text.trim().isEmpty ? null : _vesselCtrl.text.trim()),
      vesselType: Value(_vesselTypeCtrl.text.trim().isEmpty ? null : _vesselTypeCtrl.text.trim()),
      homePort: Value(_homePortCtrl.text.trim().isEmpty ? null : _homePortCtrl.text.trim()),
      skipperName: Value(_skipperCtrl.text.trim().isEmpty ? null : _skipperCtrl.text.trim()),
      crewNames: Value(crew),
      notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      safetyBriefingDone: Value(_briefing),
      checkInDone: Value(_checkIn),
      checkOutDone: Value(_checkOut),
      createdAt: Value(_existing?.createdAt ?? DateTime.now()),
    );

    if (_existing != null) {
      await db.updateCharter(companion);
    } else {
      await db.insertCharter(companion);
    }

    ref.invalidate(chartersProvider);
    setState(() => _loading = false);
    if (mounted) context.go('/logbook');
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _vesselCtrl.dispose(); _vesselTypeCtrl.dispose();
    _homePortCtrl.dispose(); _skipperCtrl.dispose(); _crewCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
  );
}
