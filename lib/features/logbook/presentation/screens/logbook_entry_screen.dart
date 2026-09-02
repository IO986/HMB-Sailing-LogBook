import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../../../core/database/app_database.dart';
import '../../../../core/models/crew_member_ref.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/providers/sync_settings_provider.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/raymarine_connection_service.dart';
import '../../../../core/services/udp_receiver_service.dart';
import '../../../../core/services/weather_repository.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/services/units_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/weather_condition_lookup.dart';
import '../../../../core/models/sail_mode.dart';
import '../../../../core/models/point_of_sail.dart';
import '../../../../shared/widgets/sail_direction_picker.dart';
import '../../../../shared/widgets/location_quality_badge.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import '../../../../core/utils/localized_date.dart';
import '../../../../core/services/dhmz_observation_service.dart';
import '../../../../core/services/entry_conditions.dart';
import '../../../../shared/widgets/weather_source_badge.dart';
import '../../../../shared/widgets/helmsman_picker.dart';
import '../../../../shared/widgets/sail_mode_picker.dart';

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

  /// Hodnoty počasia tak, ako sa načítali pri otvorení existujúceho záznamu.
  ///
  /// Keď ich skiper prepíše, zapísaný zdroj by klamal — hodnota už nie je zo
  /// stanice ani z modelu, ale jeho vlastné odčítanie. Pri uložení sa preto
  /// porovnáva a zdroj sa v tom prípade zahodí.
  String? _loadedWeather;

  static String _weatherSignature(double? windSpeed, double? windDir,
          double? airTemp, double? waterTemp, double? pressure) =>
      [windSpeed, windDir, airTemp, waterTemp, pressure].join('|');

  // Pôvod hodnôt počasia — pozri LogbookEntries.weatherSource.
  String? _weatherSource;
  String? _weatherStation;
  double? _weatherStationDistanceM;
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
  final _depthCtrl = TextEditingController();

  // Spôsob plavby - multi-select
  final Set<String> _sailModes = {'motor'};

  /// Kurz voči vetru aj s bokom — políčko so siluetou z papierového denníka.
  /// `null` znamená „nezaznamenané"; nikdy sa nedopĺňa odhadom.
  SailDirection? _sailDirection;
  String? _weatherCondition;
  String? _photoPath;
  int? _fuelLevel;
  int? _waterLevel;

  /// Posádka danej plavby — zdroj pre výber kormidelníka. Prázdna, kým sa
  /// nenačíta charter (alebo keď plavba nemá vyplnenú posádku vôbec).
  List<CrewMemberRef> _crew = [];
  String? _helmsman;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) _loadEntry(); else _autoFill();
    _loadCrew();
  }

  /// Posádka sa načítava nezávisle od zvyšku formulára — pri novom zázname
  /// z nej treba len defaultne vybrať skipera, pri edite ju treba na to,
  /// aby chip so `skipperName` uloženým v zázname mal čo zobraziť.
  Future<void> _loadCrew() async {
    final dayLog = await ref.read(databaseProvider).getDayLogById(widget.dayLogId);
    if (dayLog == null) return;
    final charter = await ref.read(databaseProvider).getCharterById(dayLog.charterId);
    if (charter == null || !mounted) return;
    final crew = CrewMemberRef.parse(
      charter.crewJson,
      skipperName: charter.skipperName,
      crewNames: charter.crewNames,
    );
    setState(() {
      _crew = crew;
      // Nový záznam bez explicitnej voľby defaultne patrí skiperovi plavby.
      if (widget.entryId == null && _helmsman == null) {
        final skipper = crew.where((c) => c.isSkipper).firstOrNull;
        _helmsman = skipper?.name;
      }
    });
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
        _weatherSource = e.weatherSource;
        _weatherStation = e.weatherStation;
        _weatherStationDistanceM = e.weatherStationDistanceM;
        _loadedWeather = _weatherSignature(
          e.windSpeed, e.windDirection, e.airTemp, e.waterTemp, e.airPressure);
        _windSpeedCtrl.text = e.windSpeed?.toStringAsFixed(0) ?? '';
        _windDirCtrl.text = e.windDirection?.toStringAsFixed(0) ?? '';
        _waveCtrl.text = e.waveHeight?.toStringAsFixed(1) ?? '';
        _fuelCtrl.text = e.fuelConsumed?.toStringAsFixed(1) ?? '';
        _engineCtrl.text = e.engineHours?.toStringAsFixed(1) ?? '';
        _airTempCtrl.text = e.airTemp?.toStringAsFixed(1) ?? '';
        _waterTempCtrl.text = e.waterTemp?.toStringAsFixed(1) ?? '';
        _pressureCtrl.text = e.airPressure?.toStringAsFixed(0) ?? '';
        _depthCtrl.text = e.depthMeters?.toStringAsFixed(1) ?? '';

        // Spôsob plavby má vlastný stĺpec; prefix [mode1,mode2] v poznámke
        // je starý formát (do v21) a číta sa už len ako záloha, napr. pri
        // zázname stiahnutom zo servera.
        final parsed = parseSailMode(e.sailMode, e.skipperNote);
        _sailModes
          ..clear()
          ..addAll(parsed.modes);
        _noteCtrl.text = parsed.note;
        _sailDirection = SailDirection.fromCodes(e.pointOfSail, e.tack);
        _weatherCondition = e.weatherCondition;
        _photoPath = e.photoPath;
        _fuelLevel = e.fuelLevel;
        _waterLevel = e.waterLevel;
        _helmsman = e.skipperName;
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
      // Ak nie je nič v keši, skús doplniť — ale nikdy na to nečakaj tak, aby
      // sa formulár nedal vyplniť bez siete.
      if (pos != null && await WeatherService().getCurrentWeather() == null) {
        await WeatherRepository()
            .syncWeather(lat: pos.latitude, lon: pos.longitude);
      }
      unawaited(DhmzObservationService().sync());

      // Cez ten istý reťazec priorít ako automatický záznam: prístroje na
      // lodi → stanica DHMZ → model. Predtým si ručný záznam bral rovno
      // model, takže sa oba spôsoby zápisu líšili.
      if (pos == null) return;
      final c = await EntryConditionsBuilder().build(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      final w = await WeatherService().getCurrentWeather();
      if (!mounted) return;
      setState(() {
        if (c.windSpeed != null) {
          _windSpeedCtrl.text = c.windSpeed!.toStringAsFixed(0);
        }
        if (c.windDirection != null) {
          _windDirCtrl.text = c.windDirection!.toStringAsFixed(0);
        }
        if (c.waveHeight != null) {
          _waveCtrl.text = c.waveHeight!.toStringAsFixed(1);
        }
        if (c.airTemp != null) _airTempCtrl.text = c.airTemp!.toStringAsFixed(1);
        if (c.waterTemp != null) {
          _waterTempCtrl.text = c.waterTemp!.toStringAsFixed(1);
        }
        if (c.airPressure != null) {
          _pressureCtrl.text = c.airPressure!.toStringAsFixed(0);
        }
        // Hĺbka ide výhradne zo sondy — model ani stanica ju nemajú odkiaľ
        // vedieť. Keď loď sondu nemá, políčko ostane prázdne na ručný zápis.
        final depth = _instrumentDepthMeters();
        if (depth != null) _depthCtrl.text = depth.toStringAsFixed(1);
        _weatherSource = c.source.code;
        _weatherStation = c.station;
        _weatherStationDistanceM = c.stationDistanceM;
        _weatherCondition ??= c.condition ??
            (w == null ? null : weatherConditionFromCode(w.weatherCode));
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
        SailModePicker(
          value: _sailModes,
          onChanged: (v) => setState(() {
            _sailModes
              ..clear()
              ..addAll(v);
          }),
        ),
        const SizedBox(height: 16),

        // Kurz voči vetru — silueta lode s bokmi, ako na papieri
        _Sec(l.sailDirection),
        SailDirectionPicker(
          value: _sailDirection,
          onChanged: (v) => setState(() => _sailDirection = v),
        ),
        const SizedBox(height: 16),

        if (_crew.isNotEmpty) ...[
          _Sec(l.helmsmanLabel),
          HelmsmanPicker(
            crew: _crew,
            selected: _helmsman,
            onChanged: (v) => setState(() => _helmsman = v),
          ),
          const SizedBox(height: 16),
        ],

        _Sec(l.navigationSection),
        _NavRow(l.latitude, _lat?.toStringAsFixed(6) ?? '-'),
        _NavRow(l.longitude, _lon?.toStringAsFixed(6) ?? '-'),
        _NavRow('SOG', ref.watch(unitsSyncProvider).formatSpeed(_sog)),
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
        WeatherSourceBadge(
          weatherSource: _weatherSource,
          station: _weatherStation,
          stationDistanceM: _weatherStationDistanceM,
        ),
        const SizedBox(height: 4),
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
        Row(children: [
          Expanded(
            child: _Num(ctrl: _waveCtrl, label: l.waveHeight2,
                suffix: units.depth == DepthUnit.meters ? 'm' : 'ft'),
          ),
          const SizedBox(width: 12),
          // Hĺbka pod lodou: pri zapojenej sonde je predvyplnená z NMEA,
          // inak sa dá zapísať ručne (papierový denník ju má tiež).
          Expanded(child: _Num(ctrl: _depthCtrl, label: l.depthLabel, suffix: 'm')),
        ]),
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
    final syncEnabled = ref.read(syncSettingsProvider).valueOrNull?.enabled ?? false;

    final modesStr = _sailModes.isNotEmpty ? _sailModes.join(',') : null;
    final note = _noteCtrl.text.trim();
    final payload = _buildPayload(note, modesStr);
    final attachments = await _buildAttachments();

    if (_existingId != null) {
      // Ak sa hodnoty počasia oproti načítanému stavu zmenili, sú to už
      // údaje skipera a nie stanice — zdroj sa musí zahodiť, inak by záznam
      // tvrdil, že ich nameral niekto iný.
      final editedWeather = _weatherSignature(
            double.tryParse(_windSpeedCtrl.text),
            double.tryParse(_windDirCtrl.text),
            double.tryParse(_airTempCtrl.text),
            double.tryParse(_waterTempCtrl.text),
            double.tryParse(_pressureCtrl.text),
          ) !=
          _loadedWeather;

      final companion = LogbookEntriesCompanion(
        weatherSource: Value(editedWeather ? null : _weatherSource),
        weatherStation: Value(editedWeather ? null : _weatherStation),
        weatherStationDistanceM:
            Value(editedWeather ? null : _weatherStationDistanceM),
        windSpeed: Value(double.tryParse(_windSpeedCtrl.text)),
        windDirection: Value(double.tryParse(_windDirCtrl.text)),
        waveHeight: Value(double.tryParse(_waveCtrl.text)),
        fuelConsumed: Value(double.tryParse(_fuelCtrl.text)),
        engineHours: Value(double.tryParse(_engineCtrl.text)),
        airTemp: Value(double.tryParse(_airTempCtrl.text)),
        waterTemp: Value(double.tryParse(_waterTempCtrl.text)),
        airPressure: Value(double.tryParse(_pressureCtrl.text)),
        depthMeters: Value(double.tryParse(_depthCtrl.text)),
        skipperNote: Value(note),
        sailMode: Value(modesStr),
        pointOfSail: Value(_sailDirection?.pointOfSail.code),
        tack: Value(_sailDirection?.tack?.code),
        weatherCondition: Value(_weatherCondition),
        photoPath: Value(_photoPath),
        fuelLevel: Value(_fuelLevel),
        waterLevel: Value(_waterLevel),
        skipperName: Value(_helmsman),
      );
      // Lokálny zápis a enqueue() musia byť atomické — buď oboje, alebo nič.
      // Pri vypnutej synchronizácii sa enqueue vôbec nevolá, inak by outbox
      // rástol donekonečna aj keď ho nič nikdy neodošle.
      await db.transaction(() async {
        await db.updateLogbookEntry(_existingId!, companion);
        if (syncEnabled) {
          await engine.enqueue(
            entityType: 'log_entry',
            operation: SyncOperation.update,
            entityId: _existingId.toString(),
            payload: payload,
            attachments: attachments,
          );
        }
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
        depthMeters: Value(double.tryParse(_depthCtrl.text)),
        skipperNote: Value(note),
        sailMode: Value(modesStr),
        pointOfSail: Value(_sailDirection?.pointOfSail.code),
        tack: Value(_sailDirection?.tack?.code),
        weatherCondition: Value(_weatherCondition),
        photoPath: Value(_photoPath),
        fuelLevel: Value(_fuelLevel),
        waterLevel: Value(_waterLevel),
        skipperName: Value(_helmsman),
        accuracyMeters: Value(_accuracyMeters),
        locationSource: Value(_locationSource),
        isMocked: Value(_isMocked),
        weatherSource: Value(_weatherSource),
        weatherStation: Value(_weatherStation),
        weatherStationDistanceM: Value(_weatherStationDistanceM),
      );

      late final int newId;
      await db.transaction(() async {
        newId = await db.insertLogbookEntry(companion);
        if (syncEnabled) {
          await engine.enqueue(
            entityType: 'log_entry',
            entityId: newId.toString(),
            payload: payload,
            attachments: attachments,
          );
        }
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

  /// Čerstvá hĺbka z lodných prístrojov, alebo null.
  double? _instrumentDepthMeters() {
    final tcp = RaymarineConnectionService();
    final udp = UdpReceiverService();
    final d = tcp.isConnected && tcp.hasFreshData
        ? tcp.current
        : (udp.isListening && udp.hasFreshData ? udp.current : null);
    if (d == null) return null;
    final at = d.depthLastUpdate;
    if (at == null || DateTime.now().difference(at) > const Duration(seconds: 10)) {
      return null;
    }
    return d.depthMeters;
  }

  /// Čo pôjde na server — mapovanie doménového modelu na opaque payload,
  /// ktorý `hmb_core` nikdy neinterpretuje.
  Map<String, dynamic> _buildPayload(String note, String? sailMode) => {
        'sailMode': sailMode,
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
        'depthMeters': double.tryParse(_depthCtrl.text),
        'skipperNote': note,
        'skipperName': _helmsman,
        'pointOfSail': _sailDirection?.pointOfSail.code,
        'tack': _sailDirection?.tack?.code,
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
    _depthCtrl.dispose();
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
    final picked = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (picked == null) return;
    // image_picker uklada zmenšenú kópiu do CACHE priečinka (súbor
    // "scaled_..."), ktorý systém smie kedykoľvek vymazať — treba kópiu do
    // trvalého úložiska appky.
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/logbook_photos');
    await dir.create(recursive: true);
    final file = File(
        '${dir.path}/log_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await File(picked.path).copy(file.path);
    onPick(file.path);
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

class _TimestampBadge extends ConsumerWidget {
  final DateTime ts;
  final bool isEdit;
  const _TimestampBadge(this.ts, {required this.isEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsSyncProvider);
    final date = AppDate.of(context, ref).medium(units.atZone(ts));
    final time = units.formatTimeWithZone(ts, seconds: true);
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
          Text(time, style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
