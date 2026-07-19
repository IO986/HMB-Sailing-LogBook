import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:latlong2/latlong.dart' hide DistanceCalculator;
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/logbook_event_type.dart';
import '../models/marine_instrument_data.dart';
import '../utils/distance_calculator.dart';
import 'geocoding_service.dart';
import 'location_service.dart';
import 'raymarine_connection_service.dart';
import 'udp_receiver_service.dart';
import 'weather_repository.dart';

class GpsTrackingService {
  static final GpsTrackingService _i = GpsTrackingService._();
  factory GpsTrackingService() => _i;
  GpsTrackingService._();

  final _weatherRepo = WeatherRepository();
  StreamSubscription<Position>? _posSub;
  final _posCtrl = StreamController<Position>.broadcast();
  SailingSession? _currentSession;
  Position? _lastPosition;
  AppDatabase? _db;
  Timer? _logbookTimer;
  Timer? _weatherTimer;
  int? _activeDayLogId;
  int _logIntervalSeconds = 3600;
  SyncEngine? _syncEngine;

  // Course change detection
  double? _lastLoggedCourse;
  DateTime? _courseChangeStart;
  double? _courseChangeHeading;

  // GPS track cache + NM accumulation
  final List<LatLng> _trackCache = [];
  double _totalDistanceNm = 0.0;
  LatLng? _lastTrackPoint;

  // Course over ground počítaný z bearing medzi poslednými dvoma fixmi —
  // Position.heading z telefónu je nespoľahlivý (pri nízkej rýchlosti alebo
  // bez pohybu často hlási 0°, potvrdené na testovacej jazde: COG ostával
  // 0° takmer po celý čas napriek reálnemu pohybu). Bearing sa prepočíta len
  // keď sa poloha posunula aspoň o _minCourseDistM, inak GPS šum/duplicitné
  // fixy vygenerujú náhodný/nulový kurz.
  static const double _minCourseDistM = 8;
  double? _lastComputedCourseDeg;

  Stream<Position> get positionStream => _posCtrl.stream;
  Position? get lastPosition => _lastPosition ?? LocationService().lastPosition;
  bool get isTracking => _posSub != null;
  SailingSession? get currentSession => _currentSession;
  int? get activeDayLogId => _activeDayLogId;
  List<LatLng> get trackPoints => List.unmodifiable(_trackCache);
  double get totalDistanceNm => _totalDistanceNm;

  void setDatabase(AppDatabase db) {
    _db = db;
    debugPrint('[GPS] DB set');
  }

  /// Prepojené z `syncEngineProvider` (viď sync_provider.dart), akonáhle je
  /// vytvorený prvý riverpod `ProviderContainer` — táto trieda je singleton
  /// mimo riverpod, takže `enqueue()` musí dostať `SyncEngine` takto, nie
  /// cez `ref`.
  void setSyncEngine(SyncEngine engine) {
    _syncEngine = engine;
  }

  Future<bool> _checkPermission() async {
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied)
      p = await Geolocator.requestPermission();
    return p == LocationPermission.whileInUse || p == LocationPermission.always;
  }

  Future<void> startTracking({
    String? sessionName,
    int? dayLogId,
    String? skipperName,
    int logIntervalSeconds = 3600,
  }) async {
    _logIntervalSeconds = logIntervalSeconds;
    debugPrint('[GPS] startTracking dayLogId=$dayLogId interval=${logIntervalSeconds}s');

    if (isTracking) { debugPrint('[GPS] Already tracking'); return; }
    if (_db == null) throw Exception('DB not initialized');

    final ok = await _checkPermission();
    if (!ok) throw Exception('Location permission denied');

    final sessionId = const Uuid().v4();
    _activeDayLogId = dayLogId;

    await _db!.upsertSession(SailingSessionsCompanion.insert(
      sessionId: sessionId,
      startTime: DateTime.now().toUtc(),
      name: drift.Value(sessionName ?? 'Plavba ${DateTime.now().toLocal()}'),
      isActive: const drift.Value(true),
      dayLogId: drift.Value(dayLogId),
    ));

    _currentSession = await _db!.getActiveSession();
    _trackCache.clear();
    // Základ pre NM je to, čo už bolo pre tento deň uložené — plavba sa
    // môže cez deň viackrát zastaviť/spustiť (reštart appky, prestávka),
    // a bez tohto sa pri každom ďalšom stopTracking() prepočítaná vzdialenosť
    // predošlých úsekov strácala (potvrdené: export ukázal "0.0 NM celkom"
    // napriek správnej trase na mape).
    _totalDistanceNm = dayLogId != null
        ? (await _db!.getDayLogById(dayLogId))?.distanceNm ?? 0.0
        : 0.0;
    _lastTrackPoint = null;
    _lastComputedCourseDeg = null;
    debugPrint('[GPS] Session created: ${_currentSession?.sessionId}, '
        'starting NM: ${_totalDistanceNm.toStringAsFixed(2)}');

    // Použi LocationService stream (GPS je už aktívne)
    _posSub = LocationService().stream.listen(
      _onPosition,
      onError: (e) => debugPrint('[GPS] Stream err: $e'),
    );

    // Ak už máme polohu, spracuj ju
    final existingPos = LocationService().lastPosition;
    if (existingPos != null) {
      _lastPosition = existingPos;
      debugPrint('[GPS] Using existing position: ${existingPos.latitude}, ${existingPos.longitude}');
    }

    debugPrint('[GPS] Started OK, interval=${_logIntervalSeconds}s');

    // _posSub už beží, prvý záznam naplánuj
    _scheduleFirstEntry();

    // Počasie
    Timer(const Duration(seconds: 3), _syncWeather);
    _weatherTimer = Timer.periodic(const Duration(hours: 1), (_) => _syncWeather());

    // Auto logbook timer
    debugPrint('[GPS] Starting logbook timer: ${_logIntervalSeconds}s');
    _logbookTimer = Timer.periodic(
      Duration(seconds: _logIntervalSeconds),
      (_) async {
        debugPrint('[GPS] Auto logbook timer fired');
        await createAutomaticLogbookEntry();
      },
    );
  }

  /// Počkaj na GPS a urob prvý záznam
  void _scheduleFirstEntry() async {
    // Ak máme pozíciu z LocationService, urob záznam okamžite
    final existing = _lastPosition ?? LocationService().lastPosition;
    if (existing != null) {
      _lastPosition = existing;
      debugPrint('[GPS] First entry: using existing position');
      await Future.delayed(const Duration(seconds: 2));
      await createAutomaticLogbookEntry(
          note: 'Voyage start', event: LogbookEventType.voyageStart);
      _geocodeDeparture(existing.latitude, existing.longitude);
      return;
    }

    // Čakaj na prvý GPS update z LocationService (max 60s)
    debugPrint('[GPS] Waiting for first GPS position...');
    StreamSubscription? sub;
    Completer<Position> completer = Completer();
    sub = LocationService().stream.listen((pos) {
      if (!completer.isCompleted) completer.complete(pos);
    });

    try {
      final pos = await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('GPS timeout'),
      );
      _lastPosition = pos;
      await createAutomaticLogbookEntry(
          note: 'Voyage start', event: LogbookEventType.voyageStart);
      _geocodeDeparture(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('[GPS] First entry failed: $e');
    } finally {
      await sub.cancel();
    }
  }

  void _geocodeDeparture(double lat, double lon) async {
    if (_activeDayLogId == null || _db == null) return;
    try {
      final dayLog = await _db!.getDayLogById(_activeDayLogId!);
      if (dayLog == null) return;
      if (dayLog.portFrom != null && dayLog.portFrom!.isNotEmpty) return; // user-set, neprepisuj
      final name = await GeocodingService().reverseGeocode(lat, lon);
      if (name != null) {
        await _db!.updateDayLog(DayLogsCompanion(
          id: drift.Value(dayLog.id),
          portFrom: drift.Value(name),
        ));
        debugPrint('[GEO] Departure port: $name');
      }
    } catch (e) {
      debugPrint('[GEO] _geocodeDeparture: $e');
    }
  }

  void _geocodeArrival(double lat, double lon) async {
    if (_activeDayLogId == null || _db == null) return;
    try {
      final dayLog = await _db!.getDayLogById(_activeDayLogId!);
      if (dayLog == null) return;
      if (dayLog.portTo != null && dayLog.portTo!.isNotEmpty) return; // user-set, neprepisuj
      final name = await GeocodingService().reverseGeocode(lat, lon);
      if (name != null) {
        await _db!.updateDayLog(DayLogsCompanion(
          id: drift.Value(dayLog.id),
          portTo: drift.Value(name),
        ));
        debugPrint('[GEO] Arrival port: $name');
      }
    } catch (e) {
      debugPrint('[GEO] _geocodeArrival: $e');
    }
  }

  void _syncWeather() {
    final pos = _lastPosition ?? LocationService().lastPosition;
    if (pos == null) return;
    _weatherRepo.syncWeather(lat: pos.latitude, lon: pos.longitude)
        .then((_) => debugPrint('[GPS] Weather synced'))
        .catchError((e) => debugPrint('[GPS] Weather err: $e'));
  }

  Future<void> stopTracking() async {
    debugPrint('[GPS] stopTracking');

    // Záverečný záznam + geocoding príchodu
    if (_lastPosition != null) {
      await createAutomaticLogbookEntry(
          note: 'Voyage end', event: LogbookEventType.voyageEnd);
      _geocodeArrival(_lastPosition!.latitude, _lastPosition!.longitude);
    }

    await _posSub?.cancel(); _posSub = null;
    _logbookTimer?.cancel(); _logbookTimer = null;
    _weatherTimer?.cancel(); _weatherTimer = null;
    _lastLoggedCourse = null;
    _courseChangeStart = null;
    _courseChangeHeading = null;

    if (_currentSession != null && _db != null) {
      await _db!.upsertSession(SailingSessionsCompanion(
        id: drift.Value(_currentSession!.id),
        sessionId: drift.Value(_currentSession!.sessionId),
        startTime: drift.Value(_currentSession!.startTime),
        endTime: drift.Value(DateTime.now().toUtc()),
        isActive: const drift.Value(false),
        totalDistanceNm: drift.Value(_totalDistanceNm),
      ));
      debugPrint('[GPS] Session ended: ${_currentSession!.sessionId}, '
          '${_totalDistanceNm.toStringAsFixed(2)} NM');

      // Ulož NM do DayLog — vždy prepíš aktuálnym súčtom (_totalDistanceNm už
      // v sebe má aj vzdialenosť z predošlých úsekov toho istého dňa, viď
      // startTracking). Predošlá podmienka "len keď je 0" ticho zahadzovala
      // vzdialenosť pri druhom a ďalšom reštarte trackingu v ten istý deň.
      if (_activeDayLogId != null) {
        try {
          final dayLog = await _db!.getDayLogById(_activeDayLogId!);
          if (dayLog != null) {
            await _db!.updateDayLog(DayLogsCompanion(
              id: drift.Value(dayLog.id),
              distanceNm: drift.Value(_totalDistanceNm),
            ));
            debugPrint('[GPS] DayLog NM updated: ${_totalDistanceNm.toStringAsFixed(2)}');
          }
        } catch (e) {
          debugPrint('[GPS] DayLog NM update failed: $e');
        }
      }

      if (_activeDayLogId != null) {
        try {
          await _db!.updateDayLog(DayLogsCompanion(
            id: drift.Value(_activeDayLogId!),
            isComplete: const drift.Value(true),
          ));
        } catch (e) {
          debugPrint('[GPS] DayLog isComplete update failed: $e');
        }
      }

      _currentSession = null;
    }
    _trackCache.clear();
    _totalDistanceNm = 0.0;
    _lastTrackPoint = null;
    _activeDayLogId = null;
  }

  Future<void> _onPosition(Position pos) async {
    _lastPosition = pos;
    _posCtrl.add(pos);
    if (_db == null || _currentSession == null) return;

    // Bearing k aktuálnemu fixu z predošlého bodu — kým je _lastTrackPoint
    // ešte "predošlý" bod (prepíše sa až nižšie). Pri zanedbateľnom posune
    // (GPS šum, duplicitný fix) ponechaj posledný známy kurz.
    final latLng = LatLng(pos.latitude, pos.longitude);
    double distM = 0;
    if (_lastTrackPoint != null) {
      distM = DistanceCalculator.distanceM(
        _lastTrackPoint!.latitude, _lastTrackPoint!.longitude,
        pos.latitude, pos.longitude,
      );
      if (distM >= _minCourseDistM) {
        _lastComputedCourseDeg = DistanceCalculator.bearing(
          _lastTrackPoint!.latitude, _lastTrackPoint!.longitude,
          pos.latitude, pos.longitude,
        );
      }
    }

    await _checkCourseChange(pos);

    // Track cache + NM accumulation
    if (_lastTrackPoint != null) {
      final d = distM / 1852; // m -> NM
      if (d < 10) _totalDistanceNm += d; // Ignoruj GPS skoky > 10 NM
    }
    _lastTrackPoint = latLng;
    _trackCache.add(latLng);

    await _db!.insertTrackPoint(TrackPointsCompanion.insert(
      sessionId: drift.Value(_currentSession!.sessionId),
      timestamp: pos.timestamp,
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: drift.Value(pos.altitude),
      speed: drift.Value(_kts(pos.speed)),
      course: drift.Value(_lastComputedCourseDeg ?? pos.heading),
      accuracy: drift.Value(pos.accuracy),
    ));

    final kts = _kts(pos.speed);
    if (kts > _currentSession!.maxSpeedKnots) {
      await _db!.upsertSession(SailingSessionsCompanion(
        id: drift.Value(_currentSession!.id),
        sessionId: drift.Value(_currentSession!.sessionId),
        startTime: drift.Value(_currentSession!.startTime),
        maxSpeedKnots: drift.Value(kts),
      ));
      _currentSession = await _db!.getActiveSession();
    }
  }

  /// Vráti aktuálne NMEA dáta z aktívneho zdroja (TCP alebo UDP), ak sú čerstvé.
  MarineInstrumentData? _freshNmea() {
    final tcp = RaymarineConnectionService();
    if (tcp.isConnected && tcp.hasFreshData) return tcp.current;
    final udp = UdpReceiverService();
    if (udp.isListening && udp.hasFreshData) return udp.current;
    return null;
  }

  Future<void> createAutomaticLogbookEntry({String? note, LogbookEventType? event}) async {
    if (_currentSession == null || _db == null) {
      debugPrint('[GPS] Cannot create entry: no session or db');
      return;
    }
    final pos = _lastPosition ?? LocationService().lastPosition;
    if (pos == null) {
      debugPrint('[GPS] Cannot create entry: no GPS position');
      return;
    }

    debugPrint('[GPS] Creating auto entry: note=$note dayLogId=$_activeDayLogId pos=${pos.latitude.toStringAsFixed(4)},${pos.longitude.toStringAsFixed(4)}');

    final weather = await _weatherRepo.getNearestWeather(DateTime.now())
        .catchError((_) => null);
    final nmea = _freshNmea();

    const fieldStale = Duration(seconds: 10);
    bool freshField(DateTime? t) =>
        t != null && DateTime.now().difference(t) < fieldStale;
    final windFresh = nmea != null && freshField(nmea.windLastUpdate);

    final sog = (nmea?.sogKnots) ?? _kts(pos.speed);
    // pos.heading z telefónu je nespoľahlivý (často 0°) — uprednostni kurz
    // dopočítaný z bearing medzi poslednými GPS bodmi.
    final cog = (nmea?.cogDegrees) ?? _lastComputedCourseDeg ?? pos.heading;
    final windSpd = windFresh ? nmea.windSpeedKnots : weather?.windSpeed;
    final windDir = windFresh ? nmea.windAngleDegrees : weather?.windDirection;
    final waterTmp = nmea?.waterTempCelsius ?? weather?.waterTemp;

    final src = nmea != null ? 'NMEA' : 'meteo';
    debugPrint('[GPS] Entry data — SOG:${sog.toStringAsFixed(1)}kn COG:${cog.toStringAsFixed(0)}° '
        'wind:${windSpd?.toStringAsFixed(1)}kn/${windDir?.toStringAsFixed(0)}° '
        'source:$src');

    // Pre bežné auto záznamy (nie Voyage start/end) pridam zdroj do note
    final entryNote = note ?? 'Auto [$src]';

    // Vždy použi aktuálny čas — pos.timestamp je čas GPS fixu (môže byť starý z cache).
    final entryTimestamp = DateTime.now().toUtc();

    final companion = LogbookEntriesCompanion.insert(
      dayLogId: drift.Value(_activeDayLogId),
      sessionId: drift.Value(_currentSession!.sessionId),
      timestamp: entryTimestamp,
      latitude: drift.Value(pos.latitude),
      longitude: drift.Value(pos.longitude),
      sog: drift.Value(sog),
      cog: drift.Value(cog),
      windSpeed: drift.Value(windSpd),
      windDirection: drift.Value(windDir),
      waveHeight: drift.Value(weather?.waveHeight),
      airPressure: drift.Value(weather?.airPressure),
      airTemp: drift.Value(weather?.airTemp),
      waterTemp: drift.Value(waterTmp),
      skipperNote: drift.Value(entryNote),
      eventType: drift.Value(event?.code),
      isAutoEntry: const drift.Value(true),
      accuracyMeters: drift.Value(pos.accuracy > 0 ? pos.accuracy : null),
      locationSource: drift.Value(LocationService().lastSource?.name),
      isMocked: drift.Value(LocationService().lastIsMocked),
    );

    // Rovnaká payload shape ako manuálny zápis (logbook_entry_screen.dart) —
    // accuracyMeters/locationSource/isMocked ostávajú zámerne lokálne, viď
    // KROK "enqueue wiring".
    final payload = {
      'dayLogId': _activeDayLogId,
      'timestamp': entryTimestamp.toIso8601String(),
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'sog': sog,
      'cog': cog,
      'windSpeed': windSpd,
      'windDirection': windDir,
      'waveHeight': weather?.waveHeight,
      'airPressure': weather?.airPressure,
      'airTemp': weather?.airTemp,
      'waterTemp': waterTmp,
      'skipperNote': entryNote,
    };

    final engine = _syncEngine;
    if (engine == null) {
      // syncEngineProvider ešte nebol vytvorený (napr. appka sa ešte len
      // spúšťa) — zapíš aspoň lokálne, nezahadzuj záznam.
      debugPrint('[GPS] Auto entry: sync engine not wired yet, local-only write');
      await _db!.insertLogbookEntry(companion);
    } else {
      // Lokálny zápis a enqueue() musia byť atomické — buď oboje, alebo nič.
      await _db!.transaction(() async {
        final newId = await _db!.insertLogbookEntry(companion);
        await engine.enqueue(
          entityType: 'log_entry',
          entityId: newId.toString(),
          payload: payload,
        );
      });
    }

    debugPrint('[GPS] Auto entry created OK');
  }

  Future<void> _checkCourseChange(Position pos) async {
    if (_kts(pos.speed) < 0.5) return;
    // Bez spoľahlivo dopočítaného kurzu (ešte žiadny predošlý bod, alebo
    // posledný posun bol pod _minCourseDistM) nemá zmysel porovnávať —
    // pos.heading z telefónu býva 0°/nespoľahlivý.
    final course = _lastComputedCourseDeg;
    if (course == null) return;
    if (_lastLoggedCourse == null) { _lastLoggedCourse = course; return; }

    double diff = (course - _lastLoggedCourse!).abs();
    if (diff > 180) diff = 360 - diff;

    if (diff > 25) {
      if (_courseChangeStart == null) {
        _courseChangeStart = DateTime.now();
        _courseChangeHeading = course;
      } else {
        final elapsed = DateTime.now().difference(_courseChangeStart!);
        if (elapsed.inMinutes >= 15) {
          double diffFromStart = (course - _courseChangeHeading!).abs();
          if (diffFromStart > 180) diffFromStart = 360 - diffFromStart;
          if (diffFromStart > 20) {
            await createAutomaticLogbookEntry(note: 'Zmena kurzu');
            _lastLoggedCourse = course;
          }
          _courseChangeStart = null;
          _courseChangeHeading = null;
        }
      }
    } else {
      if (_courseChangeStart == null) _lastLoggedCourse = course;
    }
  }

  double _kts(double ms) => ms * 1.94384;

  void dispose() {
    _posSub?.cancel();
    _logbookTimer?.cancel();
    _weatherTimer?.cancel();
    _posCtrl.close();
  }
}
