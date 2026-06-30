import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';
import '../../../tracking/presentation/widgets/tracking_start_sheet.dart' show TrackingIntervalSelector;
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
  final _mmsiCtrl = TextEditingController();
  final _callsignCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _beamCtrl = TextEditingController();
  final _draftCtrl = TextEditingController();
  final _skipperCtrl = TextEditingController();
  final List<TextEditingController> _crewControllers = [];
  final _notesCtrl = TextEditingController();
  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now().add(const Duration(days: 7));
  bool _checkIn = false, _checkOut = false;
  bool _loading = false;
  Charter? _existing;
  int _logInterval = 60;

  bool get _isNew => widget.charterId == null;

  @override
  void initState() {
    super.initState();
    _crewControllers.add(TextEditingController());
    if (!_isNew) _loadCharter();
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
        _mmsiCtrl.text = c.mmsi ?? '';
        _callsignCtrl.text = c.callsign ?? '';
        _lengthCtrl.text = c.vesselLengthM?.toString() ?? '';
        _beamCtrl.text = c.vesselBeamM?.toString() ?? '';
        _draftCtrl.text = c.vesselDraftM?.toString() ?? '';
        _skipperCtrl.text = c.skipperName ?? '';
        final crewList = (c.crewNames ?? '').split('|')
            .map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        for (final ctrl in _crewControllers) ctrl.dispose();
        _crewControllers.clear();
        if (crewList.isEmpty) {
          _crewControllers.add(TextEditingController());
        } else {
          for (final name in crewList) {
            _crewControllers.add(TextEditingController(text: name));
          }
        }
        _notesCtrl.text = c.notes ?? '';
        _dateFrom = c.dateFrom;
        _dateTo = c.dateTo;
        _checkIn = c.checkInDone;
        _checkOut = c.checkOutDone;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d. MMM yyyy', 'sk');
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.newMultidayVoyage : l.editCharter),
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
              hintText: 'napr. Plavba 2–9. máj 2026',
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
              prefixIcon: const Icon(Icons.directions_boat),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vesselTypeCtrl,
            decoration: InputDecoration(
              labelText: l.vesselType,
              hintText: 'Plachetnica / Katamaran / Motor...',
              prefixIcon: const Icon(Icons.category),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _homePortCtrl,
            decoration: InputDecoration(
              labelText: l.homePort,
              hintText: 'Prístav odchodu/príchodu',
              prefixIcon: const Icon(Icons.anchor),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(
              controller: _mmsiCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l.mmsi,
                hintText: '9-miestne číslo',
                prefixIcon: const Icon(Icons.radio),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: _callsignCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l.callsign,
                prefixIcon: const Icon(Icons.signal_cellular_alt),
              ),
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(
              controller: _lengthCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.vesselLengthM,
                prefixIcon: const Icon(Icons.straighten),
              ),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _beamCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.vesselBeamM,
                prefixIcon: const Icon(Icons.width_normal),
              ),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _draftCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.vesselDraftM,
                prefixIcon: const Icon(Icons.water),
              ),
            )),
          ]),
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
          ..._crewControllers.asMap().entries.map((e) {
            final i = e.key;
            final ctrl = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      labelText: '${l.crew} ${i + 1}',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                ),
                if (_crewControllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => setState(() {
                      ctrl.dispose();
                      _crewControllers.removeAt(i);
                    }),
                  ),
                ],
              ]),
            );
          }),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l.crew),
            onPressed: () => setState(() {
              _crewControllers.add(TextEditingController());
            }),
          ),
          const SizedBox(height: 16),

          // Log interval iba pri vytváraní nového chartera cez tracking flow
          if (_isNew) ...[
            _Section(l.logFrequency),
            TrackingIntervalSelector(
              value: _logInterval,
              onChanged: (v) => setState(() => _logInterval = v),
            ),
            const SizedBox(height: 16),
          ],

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

          // Status checkboxes only visible when editing (not creating new)
          if (!_isNew) ...[
            _Section(l.statusLabel),
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
          ],
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

  double? _parseDouble(String s) => s.trim().isEmpty ? null : double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).enterVoyageName)));
      return;
    }
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);
    final crewList = _crewControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final crew = crewList.isEmpty ? null : crewList.join('|');

    final companion = ChartersCompanion(
      id: _existing != null ? Value(_existing!.id) : const Value.absent(),
      title: Value(_titleCtrl.text.trim()),
      dateFrom: Value(_dateFrom),
      dateTo: Value(_dateTo),
      vesselName: Value(_vesselCtrl.text.trim().isEmpty ? null : _vesselCtrl.text.trim()),
      vesselType: Value(_vesselTypeCtrl.text.trim().isEmpty ? null : _vesselTypeCtrl.text.trim()),
      homePort: Value(_homePortCtrl.text.trim().isEmpty ? null : _homePortCtrl.text.trim()),
      mmsi: Value(_mmsiCtrl.text.trim().isEmpty ? null : _mmsiCtrl.text.trim()),
      callsign: Value(_callsignCtrl.text.trim().isEmpty ? null : _callsignCtrl.text.trim()),
      vesselLengthM: Value(_parseDouble(_lengthCtrl.text)),
      vesselBeamM: Value(_parseDouble(_beamCtrl.text)),
      vesselDraftM: Value(_parseDouble(_draftCtrl.text)),
      skipperName: Value(_skipperCtrl.text.trim().isEmpty ? null : _skipperCtrl.text.trim()),
      crewNames: Value(crew),
      notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      safetyBriefingDone: _existing != null
          ? Value(_existing!.safetyBriefingDone)
          : const Value(false),
      checkInDone: Value(_checkIn),
      checkOutDone: Value(_checkOut),
      createdAt: Value(_existing?.createdAt ?? DateTime.now()),
    );

    if (_existing != null) {
      await db.updateCharter(companion);
      ref.invalidate(chartersProvider);
      setState(() => _loading = false);
      if (mounted) context.go('/logbook');
    } else {
      final charter = await db.insertCharter(companion);
      ref.invalidate(chartersProvider);
      // Ulož zvolený log interval pre briefing screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pending_log_interval', _logInterval);
      setState(() => _loading = false);
      // New charter always goes to safety briefing before tracking
      if (mounted) context.go('/logbook/${charter.id}/briefing');
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _vesselCtrl.dispose(); _vesselTypeCtrl.dispose();
    _homePortCtrl.dispose(); _mmsiCtrl.dispose(); _callsignCtrl.dispose();
    _lengthCtrl.dispose(); _beamCtrl.dispose(); _draftCtrl.dispose();
    _skipperCtrl.dispose(); _notesCtrl.dispose();
    for (final c in _crewControllers) c.dispose();
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
