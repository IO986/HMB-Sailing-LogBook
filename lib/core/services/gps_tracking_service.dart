import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/marine_instrument_data.dart';
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

  // Course change detection
  double? _lastLoggedCourse;
  DateTime? _courseChangeStart;
  double? _courseChangeHeading;

  Stream<Position> get positionStream => _posCtrl.stream;
  Position? get lastPosition => _lastPosition ?? LocationService().lastPosition;
  bool get isTracking => _posSub != null;
  SailingSession? get currentSession => _currentSession;
  int? get activeDayLogId => _activeDayLogId;

  void setDatabase(AppDatabase db) {
    _db = db;
    print('[GPS] DB set');
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
    print('[GPS] startTracking dayLogId=$dayLogId interval=${logIntervalSeconds}s');

    if (isTracking) { print('[GPS] Already tracking'); return; }
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
    print('[GPS] Session created: ${_currentSession?.sessionId}');

    // Použi LocationService stream (GPS je už aktívne)
    _posSub = LocationService().stream.listen(
      _onPosition,
      onError: (e) => print('[GPS] Stream err: $e'),
    );

    // Ak už máme polohu, spracuj ju
    final existingPos = LocationService().lastPosition;
    if (existingPos != null) {
      _lastPosition = existingPos;
      print('[GPS] Using existing position: ${existingPos.latitude}, ${existingPos.longitude}');
    }

    print('[GPS] Started OK, interval=${_logIntervalSeconds}s');

    // _posSub už beží, prvý záznam naplánuj
    _scheduleFirstEntry();

    // Počasie
    Timer(const Duration(seconds: 3), _syncWeather);
    _weatherTimer = Timer.periodic(const Duration(hours: 1), (_) => _syncWeather());

    // Auto logbook timer
    print('[GPS] Starting logbook timer: ${_logIntervalSeconds}s');
    _logbookTimer = Timer.periodic(
      Duration(seconds: _logIntervalSeconds),
      (_) async {
        print('[GPS] Auto logbook timer fired');
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
      print('[GPS] First entry: using existing position');
      await Future.delayed(const Duration(seconds: 2)); // krátka pauza
      await createAutomaticLogbookEntry(note: 'Voyage start');
      return;
    }

    // Čakaj na prvý GPS update z LocationService (max 60s)
    print('[GPS] Waiting for first GPS position...');
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
      await createAutomaticLogbookEntry(note: 'Voyage start');
    } catch (e) {
      print('[GPS] First entry failed: $e');
    } finally {
      await sub.cancel();
    }
  }

  void _syncWeather() {
    final pos = _lastPosition ?? LocationService().lastPosition;
    if (pos == null) return;
    _weatherRepo.syncWeather(lat: pos.latitude, lon: pos.longitude)
        .then((_) => print('[GPS] Weather synced'))
        .catchError((e) => print('[GPS] Weather err: $e'));
  }

  Future<void> stopTracking() async {
    print('[GPS] stopTracking');

    // Záverečný záznam
    if (_lastPosition != null) {
      await createAutomaticLogbookEntry(note: 'Voyage end');
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
      ));
      print('[GPS] Session ended: ${_currentSession!.sessionId}');
      _currentSession = null;
    }
    _activeDayLogId = null;
  }

  Future<void> _onPosition(Position pos) async {
    _lastPosition = pos;
    _posCtrl.add(pos);
    if (_db == null || _currentSession == null) return;

    await _checkCourseChange(pos);

    await _db!.insertTrackPoint(TrackPointsCompanion.insert(
      sessionId: drift.Value(_currentSession!.sessionId),
      timestamp: pos.timestamp,
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: drift.Value(pos.altitude),
      speed: drift.Value(_kts(pos.speed)),
      course: drift.Value(pos.heading),
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

  Future<void> createAutomaticLogbookEntry({String? note}) async {
    if (_currentSession == null || _db == null) {
      print('[GPS] Cannot create entry: no session or db');
      return;
    }
    final pos = _lastPosition ?? LocationService().lastPosition;
    if (pos == null) {
      print('[GPS] Cannot create entry: no GPS position');
      return;
    }

    print('[GPS] Creating auto entry: note=$note dayLogId=$_activeDayLogId pos=${pos.latitude.toStringAsFixed(4)},${pos.longitude.toStringAsFixed(4)}');

    final weather = await _weatherRepo.getNearestWeather(DateTime.now())
        .catchError((_) => null);
    final nmea = _freshNmea();

    const fieldStale = Duration(seconds: 10);
    bool freshField(DateTime? t) =>
        t != null && DateTime.now().difference(t) < fieldStale;
    final windFresh = nmea != null && freshField(nmea.windLastUpdate);

    final sog = (nmea?.sogKnots) ?? _kts(pos.speed);
    final cog = (nmea?.cogDegrees) ?? pos.heading;
    final windSpd = windFresh ? nmea!.windSpeedKnots : weather?.windSpeed;
    final windDir = windFresh ? nmea!.windAngleDegrees : weather?.windDirection;
    final waterTmp = nmea?.waterTempCelsius ?? weather?.waterTemp;

    final src = nmea != null ? 'NMEA' : 'meteo';
    print('[GPS] Entry data — SOG:${sog.toStringAsFixed(1)}kn COG:${cog.toStringAsFixed(0)}° '
        'wind:${windSpd?.toStringAsFixed(1)}kn/${windDir?.toStringAsFixed(0)}° '
        'source:$src');

    // Pre bežné auto záznamy (nie Voyage start/end) pridam zdroj do note
    final entryNote = note ?? 'Auto [$src]';

    await _db!.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: drift.Value(_activeDayLogId),
      sessionId: drift.Value(_currentSession!.sessionId),
      timestamp: pos.timestamp.toUtc(),
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
      isAutoEntry: const drift.Value(true),
    ));

    print('[GPS] Auto entry created OK');
  }

  Future<void> _checkCourseChange(Position pos) async {
    if (_kts(pos.speed) < 0.5) return;
    final course = pos.heading;
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
