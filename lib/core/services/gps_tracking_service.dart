import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:latlong2/latlong.dart' hide DistanceCalculator;
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/logbook_event_type.dart';
import '../models/point_of_sail.dart';
import '../models/marine_instrument_data.dart';
import '../utils/distance_calculator.dart';
import '../utils/fix_quality_filter.dart';
import '../utils/track_point_throttle.dart';
import 'geocoding_service.dart';
import 'location_service.dart';
import 'raymarine_connection_service.dart';
import 'udp_receiver_service.dart';
import 'entry_conditions.dart';
import 'weather_repository.dart';
import 'dhmz_observation_service.dart';

class GpsTrackingService {
  static final GpsTrackingService _i = GpsTrackingService._();
  factory GpsTrackingService() => _i;
  GpsTrackingService._();

  final _weatherRepo = WeatherRepository();
  final _conditions = EntryConditionsBuilder();
  StreamSubscription<Position>? _posSub;
  final _posCtrl = StreamController<Position>.broadcast();
  SailingSession? _currentSession;
  Position? _lastPosition;
  AppDatabase? _db;
  Timer? _logbookTimer;
  Timer? _weatherTimer;
  Timer? _instrumentWatchTimer;
  int? _activeDayLogId;
  int _logIntervalSeconds = 3600;
  SyncEngine? _syncEngine;
  bool Function() _isSyncEnabled = () => false;

  // Course change detection
  double? _lastLoggedCourse;
  DateTime? _courseChangeStart;
  double? _courseChangeHeading;

  // GPS track cache + NM accumulation
  final List<LatLng> _trackCache = [];
  double _totalDistanceNm = 0.0;
  // Posledná hodnota zapísaná do DB — priebežný zápis beží až po tomto prahu,
  // aby sa neupdatovalo pri každom fixe.
  double _lastPersistedNm = 0.0;
  LatLng? _lastTrackPoint;

  // Course over ground počítaný z bearing medzi poslednými dvoma fixmi —
  // Position.heading z telefónu je nespoľahlivý (pri nízkej rýchlosti alebo
  // bez pohybu často hlási 0°, potvrdené na testovacej jazde: COG ostával
  // 0° takmer po celý čas napriek reálnemu pohybu). Bearing sa prepočíta len
  // keď sa poloha posunula aspoň o _minCourseDistM, inak GPS šum/duplicitné
  // fixy vygenerujú náhodný/nulový kurz.
  static const double _minCourseDistM = 8;
  double? _lastComputedCourseDeg;

  // Zápis trackpointu sa škrtí, súčet míľ nie — pozri TrackPointThrottle.
  final _trackPointThrottle = TrackPointThrottle();

  // Kvalita fixu: nepresné polohy a fyzikálne nemožné skoky sa do trasy ani
  // do míľ vôbec nedostanú — pozri FixQualityFilter.
  final _fixFilter = FixQualityFilter();

  // ── Stav lodných prístrojov: autopilot a motor ──────────────────────
  //
  // Zapísaný stav sa mení až po dvoch rovnakých vzorkách za sebou
  // (_instrumentWatchPeriod × 2). Jedna chýbajúca veta alebo krátky
  // prepad otáčok pri radení tak nespraví v denníku pár záznamov
  // „motor zhasol / motor naštartoval" v tej istej minúte.
  static const _instrumentWatchPeriod = Duration(seconds: 5);
  bool? _autopilotLogged;
  bool? _autopilotPending;
  bool? _engineLogged;
  bool? _enginePending;
  DateTime? _engineRunningSince;

  /// Motohodiny dňa narátané z otáčok. Základ sa berie z DayLogu, takže
  /// prerušený tracking ani reštart appky ich nevynuluje.
  double _engineHours = 0;
  double _lastPersistedEngineHours = 0;

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
  /// cez `ref`. `isSyncEnabled` je zámerne callback, nie bool zachytený raz
  /// — `syncEngineProvider` sa prestavia pri každej zmene nastavení a
  /// odovzdá čerstvý closure, takže vypnutie synchronizácie zaberie okamžite
  /// aj počas bežiaceho trackingu.
  void setSyncEngine(SyncEngine engine, bool Function() isSyncEnabled) {
    _syncEngine = engine;
    _isSyncEnabled = isSyncEnabled;
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
    /// Vzdialenosť prejdená, kým appka nebežala — po neúmyselnom vypnutí ju
    /// užívateľ môže dať dopočítať (odhad po priamke medzi posledným
    /// zaznamenaným bodom a polohou pri obnovení).
    double bridgedDistanceNm = 0,
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
    // Základ pre NM sa prepočíta z uložených bodov predošlých úsekov dňa,
    // nie z DayLog.distanceNm: keď appku vypne systém alebo užívateľ
    // uprostred plavby, stopTracking() nikdy nedobehne a uložená hodnota
    // ostane pozadu. Body v DB sú vždy kompletné (nahlásené z terénu:
    // po nechcenom vypnutí appky sa počítala len druhá časť plavby).
    _totalDistanceNm = dayLogId != null
        ? await _db!.recordedDistanceNmForDay(dayLogId,
                excludeSessionId: sessionId) +
            bridgedDistanceNm
        : bridgedDistanceNm;
    _lastPersistedNm = _totalDistanceNm;
    _lastTrackPoint = null;
    _trackPointThrottle.reset();
    _fixFilter.reset();
    _lastComputedCourseDeg = null;
    _autopilotLogged = null;
    _autopilotPending = null;
    _engineLogged = null;
    _enginePending = null;
    _engineRunningSince = null;
    _engineHours = dayLogId != null
        ? (await _db!.getDayLogById(dayLogId))?.engineHours ?? 0
        : 0;
    _lastPersistedEngineHours = _engineHours;
    debugPrint('[GPS] Session created: ${_currentSession?.sessionId}, '
        'starting NM: ${_totalDistanceNm.toStringAsFixed(2)}');

    // Tracking je jediný konzument, ktorý potrebuje presnú polohu aj so
    // zhasnutou obrazovkou — drží ju bežiaci foreground service.
    LocationService().requestPrecise(this, survivesBackground: true);

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

    // Autopilot a motor — sleduj prepnutia a rátaj motohodiny.
    _instrumentWatchTimer =
        Timer.periodic(_instrumentWatchPeriod, (_) => _pollInstruments());

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
    // Merania zo staníc sa ťahajú spolu s predpoveďou. Fire-and-forget:
    // záznam do denníka na ne nikdy nečaká (pravidlo 4 — offline-first).
    unawaited(DhmzObservationService().sync());
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

    LocationService().releasePrecise(this);
    await _posSub?.cancel(); _posSub = null;
    _logbookTimer?.cancel(); _logbookTimer = null;
    _weatherTimer?.cancel(); _weatherTimer = null;
    _instrumentWatchTimer?.cancel(); _instrumentWatchTimer = null;
    await _flushEngineHours(force: true);
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
    _lastPersistedNm = 0.0;
    _lastTrackPoint = null;
    _activeDayLogId = null;
  }

  Future<void> _onPosition(Position pos) async {
    if (_db == null || _currentSession == null) {
      _lastPosition = pos;
      _posCtrl.add(pos);
      return;
    }

    final latLng = LatLng(pos.latitude, pos.longitude);

    // Kvalita fixu sa posudzuje PRED čímkoľvek ďalším: nepresná poloha
    // (bunka/wifi) ani nemožný skok nesmú ovplyvniť ani trasu, ani míle,
    // ani kurz, ani auto-záznam v denníku — a preto sa taký fix nepustí ani
    // do _lastPosition.
    // Čas príchodu, nie pos.timestamp: ten môže byť z cache a pri polohe
    // z NMEA ide o čas z GPS vety — miešali by sa dve rôzne časové osi
    // a rýchlosť medzi fixmi by z toho vyšla nezmyselná.
    final check = _fixFilter.check(latLng,
        accuracyM: pos.accuracy, at: DateTime.now());
    if (!check.isAccepted) {
      debugPrint('[GPS] Fix rejected (${check.verdict.name}): '
          '${pos.latitude.toStringAsFixed(5)},${pos.longitude.toStringAsFixed(5)} '
          'acc=${pos.accuracy.toStringAsFixed(0)}m');
      return;
    }

    _lastPosition = pos;
    _posCtrl.add(pos);

    // Bearing k aktuálnemu fixu z predošlého bodu — kým je _lastTrackPoint
    // ešte "predošlý" bod (prepíše sa až nižšie). Pri zanedbateľnom posune
    // (GPS šum, duplicitný fix) ponechaj posledný známy kurz.
    if (_lastTrackPoint != null && check.distanceM >= _minCourseDistM) {
      _lastComputedCourseDeg = DistanceCalculator.bearing(
        _lastTrackPoint!.latitude, _lastTrackPoint!.longitude,
        pos.latitude, pos.longitude,
      );
    }

    await _checkCourseChange(pos);

    // Súčet míľ: len z prijatých fixov a len zo skutočného posunu.
    // Vzdialenosť po diere v zázname (resynced) sa nepočíta — nevie sa,
    // ktorou cestou loď medzitým šla.
    _totalDistanceNm += check.distanceM / 1852;
    _lastTrackPoint = latLng;

    if (_trackPointThrottle.accept(latLng)) {
      _trackCache.add(latLng);
      final loc = LocationService();
      await _db!.insertTrackPoint(TrackPointsCompanion.insert(
        sessionId: drift.Value(_currentSession!.sessionId),
        timestamp: pos.timestamp,
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitude: drift.Value(pos.altitude),
        speed: drift.Value(_kts(pos.speed)),
        course: drift.Value(_lastComputedCourseDeg ?? pos.heading),
        accuracy: drift.Value(pos.accuracy),
        // Odkiaľ bod je, sa musí dať prečítať aj spätne zo zálohy: bez toho
        // sa pri hlásení „trasa skáče" nedá odlíšiť poloha z lodných
        // prístrojov od polohy z telefónu (stĺpce existujú od v16, ale
        // tracking ich nikdy nevyplnil).
        accuracyMeters: drift.Value(pos.accuracy > 0 ? pos.accuracy : null),
        locationSource: drift.Value(
            loc.isUsingInstrumentGps ? 'instruments' : loc.lastSource?.name),
        isMocked: drift.Value(loc.lastIsMocked),
      ));
    }

    await _persistDistanceIfGrown();

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

  /// Zapíše prejdené NM do session a DayLogu, keď narástli aspoň o ~90 m.
  ///
  /// Bez priebežného zápisu by hodnotu videl len stopTracking(), takže po
  /// vypnutí appky uprostred plavby by v denníku ostalo staré číslo.
  Future<void> _persistDistanceIfGrown() async {
    final session = _currentSession;
    if (_db == null || session == null) return;
    if (_totalDistanceNm - _lastPersistedNm < 0.05) return;
    _lastPersistedNm = _totalDistanceNm;

    await _db!.updateSessionDistance(session.id, _totalDistanceNm);
    final dayLogId = _activeDayLogId;
    if (dayLogId != null) {
      await _db!.updateDayLog(DayLogsCompanion(
        id: drift.Value(dayLogId),
        distanceNm: drift.Value(_totalDistanceNm),
      ));
    }
  }

  /// Sleduje autopilota a motor a zapisuje ich prepnutia do denníka.
  ///
  /// Beží z timeru, nie zo streamu NMEA viet: veta o autopilote chodí aj
  /// niekoľkokrát za sekundu a stav sa musí posudzovať v čase, nie na každý
  /// rámec. Zmena sa zapíše až keď ju potvrdí druhá vzorka — inak by jedna
  /// stratená veta alebo prepad otáčok pri radení vyrobil v denníku dvojicu
  /// záznamov v tej istej minúte.
  Future<void> _pollInstruments() async {
    if (_db == null || _currentSession == null) return;
    final nmea = _freshNmea();
    const fieldStale = Duration(seconds: 10);
    bool fresh(DateTime? t) =>
        t != null && DateTime.now().difference(t) < fieldStale;

    // ── Autopilot ──
    if (nmea != null &&
        nmea.autopilotEngaged != null &&
        fresh(nmea.autopilotLastUpdate)) {
      final engaged = nmea.autopilotEngaged!;
      if (engaged == _autopilotLogged) {
        _autopilotPending = null;
      } else if (_autopilotPending == engaged) {
        final first = _autopilotLogged == null;
        _autopilotPending = null;
        _autopilotLogged = engaged;
        // Pri prvom čítaní sa zapíše len zapnutý pilot: „autopilot vypnutý"
        // na začiatku plavby nie je udalosť, to je normálny stav.
        if (!first || engaged) {
          await createAutomaticLogbookEntry(
            event: engaged
                ? LogbookEventType.autopilotOn
                : LogbookEventType.autopilotOff,
            note: engaged ? (nmea.autopilotMode ?? 'auto') : '',
          );
        }
      } else {
        _autopilotPending = engaged;
      }
    } else {
      _autopilotPending = null;
    }

    // ── Motor ──
    if (nmea != null && nmea.engineRpm != null && fresh(nmea.engineLastUpdate)) {
      final running = nmea.isEngineRunning;
      if (running) {
        final since = _engineRunningSince;
        final now = DateTime.now();
        if (since != null) {
          _engineHours += now.difference(since).inMilliseconds / 3600000.0;
        }
        _engineRunningSince = now;
      } else {
        _engineRunningSince = null;
      }

      if (running == _engineLogged) {
        _enginePending = null;
      } else if (_enginePending == running) {
        final first = _engineLogged == null;
        _enginePending = null;
        _engineLogged = running;
        if (!first || running) {
          await createAutomaticLogbookEntry(
            event: running
                ? LogbookEventType.engineStart
                : LogbookEventType.engineStop,
          );
        }
      } else {
        _enginePending = running;
      }
    } else {
      // Prístroje o motore mlčia — beh sa nedá ďalej rátať ani predpokladať.
      _enginePending = null;
      _engineRunningSince = null;
    }

    await _flushEngineHours();
  }

  /// Zapíše narátané motohodiny do DayLogu. Priebežne, nie až na konci —
  /// z rovnakého dôvodu ako prejdené míle (pozri [_persistDistanceIfGrown]).
  Future<void> _flushEngineHours({bool force = false}) async {
    final dayLogId = _activeDayLogId;
    if (_db == null || dayLogId == null) return;
    if (!force && _engineHours - _lastPersistedEngineHours < 0.01) return;
    if (_engineHours <= 0) return;
    _lastPersistedEngineHours = _engineHours;
    try {
      await _db!.updateDayLog(DayLogsCompanion(
        id: drift.Value(dayLogId),
        engineHours: drift.Value(_engineHours),
      ));
    } catch (e) {
      debugPrint('[GPS] Engine hours update failed: $e');
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

  Future<void> createAutomaticLogbookEntry({
    String? note,
    LogbookEventType? event,
    SailDirection? sailDirection,
    bool isAutoEntry = true,
  }) async {
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

    final nmea = _freshNmea();

    const fieldStale = Duration(seconds: 10);
    bool freshField(DateTime? t) =>
        t != null && DateTime.now().difference(t) < fieldStale;
    final windFresh = nmea != null && freshField(nmea.windLastUpdate);

    // Hĺbka pod kýlom zo sondy. Do denníka patrí z rovnakého dôvodu ako
    // poloha: spätne sa nedá zistiť odnikiaľ a pri nájazde na plytčinu je to
    // prvý údaj, na ktorý sa každý pýta. Zapíše sa len meranie čerstvé
    // v rovnakom zmysle ako vietor — stará hodnota zo sondy je horšia než
    // žiadna.
    final depthMeters =
        nmea != null && freshField(nmea.depthLastUpdate) ? nmea.depthMeters : null;

    final sog = (nmea?.sogKnots) ?? _kts(pos.speed);
    // pos.heading z telefónu je nespoľahlivý (často 0°) — uprednostni kurz
    // dopočítaný z bearing medzi poslednými GPS bodmi.
    final cog = (nmea?.cogDegrees) ?? _lastComputedCourseDeg ?? pos.heading;

    // Vietor, teploty a tlak: prístroje na lodi → najbližšia stanica DHMZ →
    // model. Prostredný stupeň je nový; kto prístroje nemá, mal doteraz
    // v dokladovateľnom zázname čistý výstup modelu.
    final conditions = await _conditions.build(
      latitude: pos.latitude,
      longitude: pos.longitude,
      instrumentWind: windFresh
          ? (speedKnots: nmea.windSpeedKnots, directionDeg: nmea.windAngleDegrees)
          : null,
      instrumentWaterTemp: nmea?.waterTempCelsius,
    );

    final src = conditions.source.code;
    debugPrint('[GPS] Entry data — SOG:${sog.toStringAsFixed(1)}kn COG:${cog.toStringAsFixed(0)}° '
        'depth:${depthMeters?.toStringAsFixed(1) ?? '-'}m '
        'wind:${conditions.windSpeed?.toStringAsFixed(1)}kn/'
        '${conditions.windDirection?.toStringAsFixed(0)}° '
        'source:$src${conditions.station == null ? '' : ' (${conditions.station})'}');

    // Poznámka ostáva prázdna. Zdroj počasia má vlastný stĺpec
    // (weatherSource) a v denníku aj v exporte sa ukazuje preložený —
    // značka 'Auto [MODEL]' v texte bola po slovensky a v cudzojazyčnom
    // exporte nečitateľná. Staré riadky si ju nesú ďalej, čítanie ich
    // pozná (isMachineAutoNote).

    // Vždy použi aktuálny čas — pos.timestamp je čas GPS fixu (môže byť starý z cache).
    final entryTimestamp = DateTime.now().toUtc();
    final entryNote = note ?? '';

    // Prevezmi posledný spôsob plavby dňa: skiper prepne motor/plachty raz
    // a automatické zápisy majú pokračovať v tom, čo zadal.
    final sailMode = _activeDayLogId != null
        ? await _db!.lastSailModeForDay(_activeDayLogId!)
        : null;

    // Kurz voči vetru sa preberá rovnako ako spôsob plavby: skiper ho zadá
    // pri obrate a dovtedy platí ďalej. Volajúci ho môže prebiť — presne to
    // robí rýchle tlačidlo obratu.
    final direction = sailDirection ??
        (_activeDayLogId != null
            ? await _db!.lastSailDirectionForDay(_activeDayLogId!).then(
                (r) => r == null
                    ? null
                    : SailDirection.fromCodes(r.pointOfSail, r.tack))
            : null);

    final companion = LogbookEntriesCompanion.insert(
      dayLogId: drift.Value(_activeDayLogId),
      sessionId: drift.Value(_currentSession!.sessionId),
      timestamp: entryTimestamp,
      sailMode: drift.Value(sailMode),
      latitude: drift.Value(pos.latitude),
      longitude: drift.Value(pos.longitude),
      sog: drift.Value(sog),
      cog: drift.Value(cog),
      windSpeed: drift.Value(conditions.windSpeed),
      windDirection: drift.Value(conditions.windDirection),
      waveHeight: drift.Value(conditions.waveHeight),
      airPressure: drift.Value(conditions.airPressure),
      airTemp: drift.Value(conditions.airTemp),
      waterTemp: drift.Value(conditions.waterTemp),
      depthMeters: drift.Value(depthMeters),
      // Motohodiny narátané z otáčok — v ručnom zázname ich skiper píše sám,
      // tu ich vie appka doplniť sama.
      engineHours: drift.Value(_engineHours > 0 ? _engineHours : null),
      weatherSource: drift.Value(conditions.source.code),
      weatherStation: drift.Value(conditions.station),
      weatherStationDistanceM: drift.Value(conditions.stationDistanceM),
      skipperNote: drift.Value(entryNote),
      pointOfSail: drift.Value(direction?.pointOfSail.code),
      tack: drift.Value(direction?.tack?.code),
      eventType: drift.Value(event?.code),
      isAutoEntry: drift.Value(isAutoEntry),
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
      'windSpeed': conditions.windSpeed,
      'windDirection': conditions.windDirection,
      'waveHeight': conditions.waveHeight,
      'airPressure': conditions.airPressure,
      'airTemp': conditions.airTemp,
      'waterTemp': conditions.waterTemp,
      'depthMeters': depthMeters,
      'engineHours': _engineHours > 0 ? _engineHours : null,
      'weatherSource': conditions.source.code,
      'weatherStation': conditions.station,
      'skipperNote': entryNote,
      'pointOfSail': direction?.pointOfSail.code,
      'tack': direction?.tack?.code,
    };

    final engine = _syncEngine;
    if (engine == null || !_isSyncEnabled()) {
      // syncEngineProvider ešte nebol vytvorený, alebo je synchronizácia
      // vypnutá — zapíš len lokálne. Pri vypnutej synchronizácii sa outbox
      // riadok zámerne vôbec nevytvára (nie je len odložený), inak by fronta
      // rástla donekonečna bez toho, aby sa to niekedy odoslalo.
      debugPrint('[GPS] Auto entry: sync engine not wired yet or sync disabled, local-only write');
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
    _instrumentWatchTimer?.cancel();
    _posCtrl.close();
  }
}
