import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/services/units_service.dart';
import '../../../../main.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

// Spôsob plavby - multi-select
const _sailOptions = [
  (value: 'motor',   label: 'Motor',       icon: Icons.settings),
  (value: 'main',    label: 'Hlavná',      icon: Icons.sailing),
  (value: 'genoa',   label: 'Genoa',       icon: Icons.air),
  (value: 'reef1',   label: 'Reef 1',      icon: Icons.arrow_downward),
  (value: 'reef2',   label: 'Reef 2',      icon: Icons.arrow_downward),
];

class LogbookEntryScreen extends ConsumerStatefulWidget {
  final int dayLogId;
  final String? entryId;
  const LogbookEntryScreen({super.key, required this.dayLogId, this.entryId});

  @override
  ConsumerState<LogbookEntryScreen> createState() => _State();
}

class _State extends ConsumerState<LogbookEntryScreen> {
  bool _loading = false;
  DateTime _ts = DateTime.now();
  double? _lat, _lon, _sog, _cog;
  int? _existingId;

  final _noteCtrl = TextEditingController();
  final _windSpeedCtrl = TextEditingController();
  final _windDirCtrl = TextEditingController();
  final _waveCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();

  // Spôsob plavby - multi-select
  final Set<String> _sailModes = {'motor'};

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) _loadEntry(); else _autoFill();
  }

  Future<void> _loadEntry() async {
    final id = int.tryParse(widget.entryId!);
    if (id == null) return;
    final entries = await ref.read(databaseProvider).getEntriesForDay(widget.dayLogId);
    try {
      final e = entries.firstWhere((e) => e.id == id);
      setState(() {
        _existingId = e.id;
        _ts = e.timestamp;
        _lat = e.latitude; _lon = e.longitude;
        _sog = e.sog; _cog = e.cog;
        _windSpeedCtrl.text = e.windSpeed?.toStringAsFixed(0) ?? '';
        _windDirCtrl.text = e.windDirection?.toStringAsFixed(0) ?? '';
        _waveCtrl.text = e.waveHeight?.toStringAsFixed(1) ?? '';
        _fuelCtrl.text = e.fuelConsumed?.toStringAsFixed(1) ?? '';
        _engineCtrl.text = e.engineHours?.toStringAsFixed(1) ?? '';

        // Načítaj poznámku a sail modes (uložené ako prefix [mode1,mode2])
        final note = e.skipperNote ?? '';
        final modeMatch = RegExp(r'^\[([^\]]+)\]\s*').firstMatch(note);
        if (modeMatch != null) {
          _sailModes.clear();
          _sailModes.addAll(modeMatch.group(1)!.split(','));
          _noteCtrl.text = note.substring(modeMatch.end);
        } else {
          _noteCtrl.text = note;
        }
      });
    } catch (_) {}
  }

  Future<void> _autoFill() async {
    final pos = GpsTrackingService().lastPosition;
    setState(() {
      _lat = pos?.latitude; _lon = pos?.longitude;
      _sog = pos != null ? pos.speed * 1.94384 : null;
      _cog = pos?.heading;
    });
    try {
      final w = await WeatherService().getCurrentWeather();
      if (w != null && mounted) setState(() {
        _windSpeedCtrl.text = w.windSpeed.toStringAsFixed(0);
        _windDirCtrl.text = w.windDirection.toStringAsFixed(0);
        _waveCtrl.text = w.waveHeight.toStringAsFixed(1);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(unitsSyncProvider);
    final isEdit = widget.entryId != null;

    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.editEntry : l.newEntry),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l.save,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Spôsob plavby - multi-select chips
        _Sec(l.sailMode),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _sailOptions.map((opt) {
            final sel = _sailModes.contains(opt.value);
            return FilterChip(
              avatar: Icon(opt.icon, size: 15,
                  color: sel ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface),
              label: Text(opt.value == 'main' ? l.sailMain : opt.label),
              selected: sel,
              onSelected: (v) => setState(() {
                if (v) _sailModes.add(opt.value);
                else _sailModes.remove(opt.value);
              }),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        _Sec(l.navigationSection),
        _NavRow(l.latitude, _lat?.toStringAsFixed(6) ?? '-'),
        _NavRow(l.longitude, _lon?.toStringAsFixed(6) ?? '-'),
        _NavRow('SOG', _sog != null ? '${_sog!.toStringAsFixed(1)} kn' : '-'),
        _NavRow('COG', _cog != null ? '${_cog!.toStringAsFixed(0)}°' : '-'),
        const SizedBox(height: 16),

        _Sec(l.weatherSeaSection),
        Row(children: [
          Expanded(child: _Num(ctrl: _windSpeedCtrl, label: l.windSpeed, suffix: 'kn')),
          const SizedBox(width: 12),
          Expanded(child: _Num(ctrl: _windDirCtrl, label: l.windDirection, suffix: '°')),
        ]),
        const SizedBox(height: 8),
        _Num(ctrl: _waveCtrl, label: l.waveHeight2,
            suffix: units.depth == DepthUnit.meters ? 'm' : 'ft'),
        const SizedBox(height: 16),

        _Sec(l.engineSection),
        Row(children: [
          Expanded(child: _Num(ctrl: _engineCtrl, label: l.engineHours, suffix: 'h')),
          const SizedBox(width: 12),
          Expanded(child: _Num(ctrl: _fuelCtrl, label: l.fuel, suffix: 'L')),
        ]),
        const SizedBox(height: 16),

        _Sec(l.noteSection),
        TextFormField(
          controller: _noteCtrl,
          maxLines: 4,
          decoration: InputDecoration(hintText: l.noteHint),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);

    // Ulož sail modes ako prefix do poznámky
    final modesStr = _sailModes.isNotEmpty ? _sailModes.join(',') : 'motor';
    final note = _noteCtrl.text.trim();
    final fullNote = '[${modesStr}]${note.isNotEmpty ? " $note" : ""}';

    if (_existingId != null) {
      await db.updateLogbookEntry(_existingId!, LogbookEntriesCompanion(
        windSpeed: Value(double.tryParse(_windSpeedCtrl.text)),
        windDirection: Value(double.tryParse(_windDirCtrl.text)),
        waveHeight: Value(double.tryParse(_waveCtrl.text)),
        fuelConsumed: Value(double.tryParse(_fuelCtrl.text)),
        engineHours: Value(double.tryParse(_engineCtrl.text)),
        skipperNote: Value(fullNote),
      ));
    } else {
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: Value(widget.dayLogId),
        sessionId: Value(GpsTrackingService().currentSession?.sessionId),
        timestamp: _ts,
        latitude: Value(_lat), longitude: Value(_lon),
        sog: Value(_sog), cog: Value(_cog),
        windSpeed: Value(double.tryParse(_windSpeedCtrl.text)),
        windDirection: Value(double.tryParse(_windDirCtrl.text)),
        waveHeight: Value(double.tryParse(_waveCtrl.text)),
        fuelConsumed: Value(double.tryParse(_fuelCtrl.text)),
        engineHours: Value(double.tryParse(_engineCtrl.text)),
        skipperNote: Value(fullNote),
      ));
    }

    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _noteCtrl.dispose(); _windSpeedCtrl.dispose(); _windDirCtrl.dispose();
    _waveCtrl.dispose(); _fuelCtrl.dispose(); _engineCtrl.dispose();
    super.dispose();
  }
}

// ── Helpers ───────────────────────────────────────────────────

class _Sec extends StatelessWidget {
  final String t;
  const _Sec(this.t);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold)));
}

class _NavRow extends StatelessWidget {
  final String l, v;
  const _NavRow(this.l, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Text(l, style: const TextStyle(color: Colors.grey)),
      const Spacer(),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]));
}

class _Num extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, suffix;
  const _Num({required this.ctrl, required this.label, required this.suffix});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, suffixText: suffix));
}
