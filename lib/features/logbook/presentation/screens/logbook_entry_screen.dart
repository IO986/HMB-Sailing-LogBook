import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/weather_repository.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/services/units_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/weather_condition_lookup.dart';
import '../../../../shared/widgets/location_quality_badge.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

// Spôsob plavby - multi-select
const _sailOptions = [
  (value: 'motor',   label: 'Motor',       icon: Icons.settings),
  (value: 'main',    label: 'Main',        icon: Icons.sailing),
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
  DateTime _ts = DateTime.now().toUtc();
  double? _lat, _lon, _sog, _cog;
  double? _accuracyMeters;
  String? _locationSource;
  bool? _isMocked;
  int? _existingId;

  final _noteCtrl = TextEditingController();
  final _windSpeedCtrl = TextEditingController();
  final _windDirCtrl = TextEditingController();
  final _waveCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _airTempCtrl = TextEditingController();
  final _waterTempCtrl = TextEditingController();
  final _pressureCtrl = TextEditingController();

  // Spôsob plavby - multi-select
  final Set<String> _sailModes = {'motor'};
  String? _weatherCondition;
  String? _photoPath;
  int? _fuelLevel;
  int? _waterLevel;

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
        _accuracyMeters = e.accuracyMeters;
        _locationSource = e.locationSource;
        _isMocked = e.isMocked;
        _windSpeedCtrl.text = e.windSpeed?.toStringAsFixed(0) ?? '';
        _windDirCtrl.text = e.windDirection?.toStringAsFixed(0) ?? '';
        _waveCtrl.text = e.waveHeight?.toStringAsFixed(1) ?? '';
        _fuelCtrl.text = e.fuelConsumed?.toStringAsFixed(1) ?? '';
        _engineCtrl.text = e.engineHours?.toStringAsFixed(1) ?? '';
        _airTempCtrl.text = e.airTemp?.toStringAsFixed(1) ?? '';
        _waterTempCtrl.text = e.waterTemp?.toStringAsFixed(1) ?? '';
        _pressureCtrl.text = e.airPressure?.toStringAsFixed(0) ?? '';

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
        _weatherCondition = e.weatherCondition;
        _photoPath = e.photoPath;
        _fuelLevel = e.fuelLevel;
        _waterLevel = e.waterLevel;
      });
    } catch (_) {}
  }

  Future<void> _autoFill() async {
    final pos = GpsTrackingService().lastPosition
        ?? LocationService().lastPosition;
    setState(() {
      _lat = pos?.latitude; _lon = pos?.longitude;
      _sog = pos != null ? pos.speed * 1.94384 : null;
      _cog = pos?.heading;
      _accuracyMeters = (pos != null && pos.accuracy > 0) ? pos.accuracy : null;
      _locationSource = pos != null ? LocationService().lastSource?.name : null;
      _isMocked = pos != null ? LocationService().lastIsMocked : null;
    });
    try {
      var w = await WeatherService().getCurrentWeather();
      // Ak nie je cache, skús synchrónizovať a znova prečítaj.
      if (w == null && pos != null) {
        await WeatherRepository().syncWeather(
            lat: pos.latitude, lon: pos.longitude);
        w = await WeatherService().getCurrentWeather();
      }
      if (w != null && mounted) setState(() {
        _windSpeedCtrl.text = w!.windSpeed.toStringAsFixed(0);
        _windDirCtrl.text = w.windDirection.toStringAsFixed(0);
        _waveCtrl.text = w.waveHeight.toStringAsFixed(1);
        if (w.airTemp != 0) _airTempCtrl.text = w.airTemp.toStringAsFixed(1);
        if (w.waterTemp != 0) _waterTempCtrl.text = w.waterTemp.toStringAsFixed(1);
        if (w.airPressure != 0) _pressureCtrl.text = w.airPressure.toStringAsFixed(0);
        _weatherCondition ??= _conditionFromCode(w.weatherCode);
      });
    } catch (_) {}
  }

  static String _conditionFromCode(int? code) {
    if (code == null) return 'partly_cloudy';
    if (code <= 1) return 'sunny';
    if (code == 2) return 'partly_cloudy';
    if (code == 3) return 'overcast';
    if (code == 45 || code == 48) return 'foggy';
    if (code >= 51 && code <= 57) return 'drizzle';
    if (code == 61 || code == 80) return 'light_rain';
    if (code == 63 || code == 81) return 'rain';
    if (code == 65 || code == 82) return 'heavy_rain';
    if (code >= 66 && code <= 67) return 'rain';
    if (code >= 71 && code <= 77) return 'cold';
    if (code == 85 || code == 86) return 'cold';
    if (code == 95) return 'thunderstorm';
    if (code == 96 || code == 99) return 'hail';
    return 'overcast';
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
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l.save,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Časová pečiatka záznamu (UTC, needitovateľná)
        _TimestampBadge(_ts, isEdit: isEdit),
        const SizedBox(height: 16),

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
        if (_lat != null && _lon != null) ...[
          const SizedBox(height: 4),
          LocationQualityBadge(
            accuracyMeters: _accuracyMeters,
            locationSource: _locationSource,
            isMocked: _isMocked,
            timestamp: _ts,
          ),
        ],
        const SizedBox(height: 16),

        _Sec(l.weatherSeaSection),
        _WeatherConditionField(
          condition: _weatherCondition,
          onChanged: (v) => setState(() => _weatherCondition = v),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Num(ctrl: _windSpeedCtrl, label: l.windSpeed, suffix: 'kn')),
          const SizedBox(width: 12),
          Expanded(child: _Num(ctrl: _windDirCtrl, label: l.windDirection, suffix: '°')),
        ]),
        const SizedBox(height: 8),
        _Num(ctrl: _waveCtrl, label: l.waveHeight2,
            suffix: units.depth == DepthUnit.meters ? 'm' : 'ft'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Num(ctrl: _airTempCtrl, label: l.airTempLabel, suffix: '°C')),
          const SizedBox(width: 12),
          Expanded(child: _Num(ctrl: _waterTempCtrl, label: l.waterTempLabel, suffix: '°C')),
          const SizedBox(width: 12),
          Expanded(child: _Num(ctrl: _pressureCtrl, label: l.pressureLabel, suffix: 'hPa')),
        ]),
        const SizedBox(height: 16),

        _Sec(l.engineSection),
        Row(children: [
          Expanded(child: _Num(ctrl: _engineCtrl, label: l.engineHours, suffix: 'h')),
          const SizedBox(width: 12),
          Expanded(child: _Num(ctrl: _fuelCtrl, label: l.fuel, suffix: 'L')),
        ]),
        const SizedBox(height: 8),
        _PercentField(
          label: l.fuelLevel,
          value: _fuelLevel,
          onChanged: (v) => setState(() => _fuelLevel = v),
        ),
        _PercentField(
          label: l.waterLevel,
          value: _waterLevel,
          onChanged: (v) => setState(() => _waterLevel = v),
        ),
        const SizedBox(height: 16),

        _Sec(l.noteSection),
        TextFormField(
          controller: _noteCtrl,
          maxLines: 4,
          decoration: InputDecoration(hintText: l.noteHint),
        ),
        const SizedBox(height: 16),

        _Sec(l.photoSection),
        _PhotoPicker(
          photoPath: _photoPath,
          onPick: (path) => setState(() => _photoPath = path),
          onRemove: () => setState(() => _photoPath = null),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);
    final engine = ref.read(syncEngineProvider);

    // Ulož sail modes ako prefix do poznámky
    final modesStr = _sailModes.isNotEmpty ? _sailModes.join(',') : 'motor';
    final note = _noteCtrl.text.trim();
    final fullNote = '[${modesStr}]${note.isNotEmpty ? " $note" : ""}';
    final payload = _buildPayload(fullNote);
    final attachments = await _buildAttachments();

    if (_existingId != null) {
      final companion = LogbookEntriesCompanion(
        windSpeed: Value(double.tryParse(_windSpeedCtrl.text)),
        windDirection: Value(double.tryParse(_windDirCtrl.text)),
        waveHeight: Value(double.tryParse(_waveCtrl.text)),
        fuelConsumed: Value(double.tryParse(_fuelCtrl.text)),
        engineHours: Value(double.tryParse(_engineCtrl.text)),
        airTemp: Value(double.tryParse(_airTempCtrl.text)),
        waterTemp: Value(double.tryParse(_waterTempCtrl.text)),
        airPressure: Value(double.tryParse(_pressureCtrl.text)),
        skipperNote: Value(fullNote),
        weatherCondition: Value(_weatherCondition),
        photoPath: Value(_photoPath),
        fuelLevel: Value(_fuelLevel),
        waterLevel: Value(_waterLevel),
      );
      // Lokálny zápis a enqueue() musia byť atomické — buď oboje, alebo nič.
      await db.transaction(() async {
        await db.updateLogbookEntry(_existingId!, companion);
        await engine.enqueue(
          entityType: 'log_entry',
          operation: SyncOperation.update,
          entityId: _existingId.toString(),
          payload: payload,
          attachments: attachments,
        );
      });
    } else {
      final companion = LogbookEntriesCompanion.insert(
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
        airTemp: Value(double.tryParse(_airTempCtrl.text)),
        waterTemp: Value(double.tryParse(_waterTempCtrl.text)),
        airPressure: Value(double.tryParse(_pressureCtrl.text)),
        skipperNote: Value(fullNote),
        weatherCondition: Value(_weatherCondition),
        photoPath: Value(_photoPath),
        fuelLevel: Value(_fuelLevel),
        waterLevel: Value(_waterLevel),
        accuracyMeters: Value(_accuracyMeters),
        locationSource: Value(_locationSource),
        isMocked: Value(_isMocked),
      );

      late final int newId;
      await db.transaction(() async {
        newId = await db.insertLogbookEntry(companion);
        await engine.enqueue(
          entityType: 'log_entry',
          entityId: newId.toString(),
          payload: payload,
          attachments: attachments,
        );
      });

      if (mounted && _lat != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: LocationQualityBadge(
            accuracyMeters: _accuracyMeters,
            locationSource: _locationSource,
            isMocked: _isMocked,
            timestamp: _ts,
          ),
          duration: const Duration(seconds: 3),
        ));
      }
    }

    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  /// Čo pôjde na server — mapovanie doménového modelu na opaque payload,
  /// ktorý `hmb_core` nikdy neinterpretuje.
  Map<String, dynamic> _buildPayload(String note) => {
        'dayLogId': widget.dayLogId,
        'timestamp': _ts.toUtc().toIso8601String(),
        'latitude': _lat,
        'longitude': _lon,
        'sog': _sog,
        'cog': _cog,
        'windSpeed': double.tryParse(_windSpeedCtrl.text),
        'windDirection': double.tryParse(_windDirCtrl.text),
        'waveHeight': double.tryParse(_waveCtrl.text),
        'fuelConsumed': double.tryParse(_fuelCtrl.text),
        'engineHours': double.tryParse(_engineCtrl.text),
        'airTemp': double.tryParse(_airTempCtrl.text),
        'waterTemp': double.tryParse(_waterTempCtrl.text),
        'airPressure': double.tryParse(_pressureCtrl.text),
        'skipperNote': note,
        'weatherCondition': _weatherCondition,
        'fuelLevel': _fuelLevel,
        'waterLevel': _waterLevel,
      };

  Future<List<Attachment>> _buildAttachments() async {
    final path = _photoPath;
    if (path == null) return const [];
    final file = File(path);
    if (!await file.exists()) return const [];
    return [
      Attachment(
        localPath: path,
        field: 'photo',
        mimeType: 'image/jpeg',
        sizeBytes: await file.length(),
      ),
    ];
  }

  @override
  void dispose() {
    _noteCtrl.dispose(); _windSpeedCtrl.dispose(); _windDirCtrl.dispose();
    _waveCtrl.dispose(); _fuelCtrl.dispose(); _engineCtrl.dispose();
    _airTempCtrl.dispose(); _waterTempCtrl.dispose(); _pressureCtrl.dispose();
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

class _PercentField extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  const _PercentField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final has = value != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(has ? '$value%' : '–',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: has ? null : Theme.of(context).colorScheme.outline)),
        IconButton(
          icon: Icon(has ? Icons.close : Icons.add, size: 18),
          onPressed: () => onChanged(has ? null : 50),
        ),
      ]),
      if (has)
        Slider(
          value: value!.toDouble(),
          min: 0, max: 100, divisions: 20,
          label: '$value%',
          onChanged: (v) => onChanged(v.round()),
        ),
    ]);
  }
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

// ── Photo picker widget ───────────────────────────────────────

class _PhotoPicker extends StatelessWidget {
  final String? photoPath;
  final ValueChanged<String> onPick;
  final VoidCallback onRemove;
  const _PhotoPicker({required this.photoPath, required this.onPick, required this.onRemove});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (file != null) onPick(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (photoPath != null && File(photoPath!).existsSync()) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(photoPath!),
              width: double.infinity, height: 200, fit: BoxFit.cover),
        ),
        Positioned(top: 6, right: 6, child: CircleAvatar(
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: onRemove,
          ),
        )),
      ]);
    }
    return Row(children: [
      Expanded(child: OutlinedButton.icon(
        icon: const Icon(Icons.camera_alt),
        label: Text(l.camera),
        onPressed: () => _pick(context, ImageSource.camera),
      )),
      const SizedBox(width: 12),
      Expanded(child: OutlinedButton.icon(
        icon: const Icon(Icons.photo_library),
        label: Text(l.gallery),
        onPressed: () => _pick(context, ImageSource.gallery),
      )),
    ]);
  }
}

// ── Weather condition data ────────────────────────────────────

String _wcLabel(AppLocalizations l, String key) {
  switch (key) {
    case 'sunny':         return l.wcSunny;
    case 'partly_cloudy': return l.wcPartlyCloudy;
    case 'overcast':      return l.wcOvercast;
    case 'light_rain':    return l.wcLightRain;
    case 'rain':          return l.wcRain;
    case 'heavy_rain':    return l.wcHeavyRain;
    case 'drizzle':       return l.wcDrizzle;
    case 'thunderstorm':  return l.wcThunderstorm;
    case 'iso_thunder':   return l.wcIsoThunderstorm;
    case 'hail':          return l.wcHail;
    case 'dust':          return l.wcDust;
    case 'foggy':         return l.wcFoggy;
    case 'windy':         return l.wcWindy;
    case 'cold':          return l.wcCold;
    default:              return key;
  }
}

// ── Weather condition tile (tappable) ────────────────────────

class _WeatherConditionField extends StatefulWidget {
  final String? condition;
  final ValueChanged<String> onChanged;
  const _WeatherConditionField({required this.condition, required this.onChanged});

  @override
  State<_WeatherConditionField> createState() => _WeatherConditionFieldState();
}

class _WeatherConditionFieldState extends State<_WeatherConditionField> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final emoji = wcEmoji(widget.condition);
    final label = widget.condition != null ? _wcLabel(l, widget.condition!) : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            if (emoji != null)
              Text(emoji, style: const TextStyle(fontSize: 26))
            else
              Icon(Icons.wb_cloudy_outlined, size: 26,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.weatherConditionLabel,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(label ?? '—',
                  style: TextStyle(
                    fontSize: 16,
                    color: label != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
            ])),
            Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ]),
        ),
      ),
      if (_expanded) ...[
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: wcList.map((wc) {
          final selected = widget.condition == wc.key;
          return ChoiceChip(
            avatar: Text(wc.emoji, style: const TextStyle(fontSize: 16)),
            label: Text(_wcLabel(l, wc.key)),
            selected: selected,
            onSelected: (_) {
              widget.onChanged(wc.key);
              setState(() => _expanded = false);
            },
          );
        }).toList()),
      ],
    ]);
  }
}

// ─────────────────────────────────────────────────────────────

class _TimestampBadge extends StatelessWidget {
  final DateTime ts;
  final bool isEdit;
  const _TimestampBadge(this.ts, {required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final utc = ts.toUtc();
    final date = DateFormat('d. MMM yyyy').format(utc);
    final time = DateFormat('HH:mm:ss').format(utc);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Icon(Icons.schedule, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text('$time UTC', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold, fontFeatures: [const FontFeature.tabularFigures()])),
        ]),
        const Spacer(),
        if (isEdit)
          Tooltip(
            message: AppLocalizations.of(context).timestampCannotBeChanged,
            child: Icon(Icons.lock_outline, size: 16, color: Theme.of(context).colorScheme.outline),
          ),
      ]),
    );
  }
}
