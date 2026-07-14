import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../models/marine_instrument_data.dart';
import 'raymarine_connection_service.dart';
import 'udp_receiver_service.dart';

/// Singleton GPS service - vždy aktívny, nezávislý od trackingu.
///
/// Zdroj polohy má dve úrovne priority:
/// 1. Lodné inštrumenty (Raymarine NMEA GPS fix) - ak sú pripojené a dáta
///    sú "fresh" (prišli v posledných 8s), použijú sa tieto dáta.
/// 2. Android GPS (geolocator) - fallback, keď Raymarine nie je pripojený
///    alebo jeho dáta vypadli.
///
/// Ostatné časti appky (GpsTrackingService, weather sync, logbook) nemusia
/// vedieť o Raymarine vôbec - dostávajú jednotný Position stream a vždy
/// majú najlepší dostupný zdroj.
class LocationService {
  static final LocationService _i = LocationService._();
  factory LocationService() => _i;
  LocationService._();

  final _gps = GeolocatorLocationService();

  StreamSubscription<LocationFix>? _androidSub;
  StreamSubscription<MarineInstrumentData>? _raymarineSub;
  StreamSubscription<MarineInstrumentData>? _udpSub;
  Timer? _fallbackCheckTimer;

  final _ctrl = StreamController<Position>.broadcast();
  final ValueNotifier<LocationAvailability?> availability = ValueNotifier(null);
  Position? _lastPosition;
  // Posledný fix, ktorý sa reálne poslal do streamu — _reEvaluateSource() sa
  // volá aj z 4s fallback timeru bez ohľadu na to, či prišiel nový fix;
  // bez dedupe by tak do streamu tieklo to isté staré position donekonečna
  // (potvrdené v teréne: GPX export mal desiatky identických duplicitných
  // bodov na tú istú sekundu a periodické auto-záznamy denníka z nich brali
  // zastaraný SOG/COG).
  Position? _lastEmittedPosition;
  Position? _lastAndroidPosition;
  LocationSource? _lastAndroidSource;
  bool _lastAndroidIsMocked = false;
  LocationSource? _lastSource;
  bool _lastIsMocked = false;
  bool _initialized = false;
  bool _usingRaymarine = false;

  Stream<Position> get stream => _ctrl.stream;
  Position? get lastPosition => _lastPosition;

  /// Zdroj poslednej emitovanej polohy (gnss/network/cached/unknown), na
  /// ukladanie kvality fixu spolu so záznamom (denník, quick-photo).
  LocationSource? get lastSource => _lastSource;

  /// True, ak platforma poslednú emitovanú polohu nahlásila ako mockovanú.
  bool get lastIsMocked => _lastIsMocked;

  /// True, ak posledná emitovaná poloha pochádza z lodných inštrumentov.
  bool get isUsingInstrumentGps => _usingRaymarine;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _initAndroidGps();
    _listenToNmea();

    // Periodicky over, či treba prepnúť zdroj (napr. Raymarine vypadol
    // a medzitým neprišla žiadna nová Android pozícia, ktorá by spustila
    // prehodnotenie).
    _fallbackCheckTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _reEvaluateSource();
      // Zachytí povolenie polohy udelené cez systémové nastavenia bez
      // reštartu appky — len kontrola stavu, nepýta znova (to robí až
      // explicitný retryPermission() z UI).
      if (_androidSub == null) _refreshAvailabilityAndMaybeStart();
    });

    debugPrint('[LOC] Location service started');
  }

  Future<void> _initAndroidGps() async {
    var avail = await _gps.checkAvailability();
    if (avail.permission == LocationPermissionState.denied) {
      await _gps.requestPermission();
      avail = await _gps.checkAvailability();
    }
    availability.value = avail;
    if (!avail.usable) return;
    await _startAndroidStream();
  }

  /// Kontrola stavu bez pýtania permission — zachytí povolenie/zapnutie GPS
  /// zmenené mimo appky (systémové nastavenia), kým appka beží.
  Future<void> _refreshAvailabilityAndMaybeStart() async {
    final avail = await _gps.checkAvailability();
    availability.value = avail;
    if (avail.usable) await _startAndroidStream();
  }

  /// Explicitný retry z UI (napr. banner "Poloha nepovolená") — jediné
  /// miesto okrem prvého spustenia, ktoré smie zobraziť systémový dialóg.
  Future<bool> retryPermission() async {
    await _gps.requestPermission();
    final avail = await _gps.checkAvailability();
    availability.value = avail;
    if (avail.usable) await _startAndroidStream();
    return avail.usable;
  }

  Future<void> _startAndroidStream() async {
    if (_androidSub != null) return;

    // Načítaj poslednú known position okamžite (bez čakania na live fix)
    try {
      final last = await _gps.getBest(
        config: const LocationConfig(
          quickFixTimeout: Duration.zero,
          preciseFixTimeout: Duration.zero,
        ),
      );
      if (last != null) {
        _lastAndroidPosition = _fixToPosition(last);
        _lastAndroidSource = last.source;
        _lastAndroidIsMocked = last.isMocked;
        _reEvaluateSource();
      }
    } catch (_) {}

    // Spusti stream
    _androidSub = _gps.watch().listen((fix) {
      _lastAndroidPosition = _fixToPosition(fix);
      _lastAndroidSource = fix.source;
      _lastAndroidIsMocked = fix.isMocked;
      _reEvaluateSource();
    }, onError: (e) => debugPrint('[LOC] Android GPS error: $e'));
  }

  Position _fixToPosition(LocationFix fix) => Position(
        latitude: fix.latitude,
        longitude: fix.longitude,
        timestamp: fix.timestamp,
        accuracy: fix.accuracyMeters,
        altitude: fix.altitudeMeters ?? 0,
        altitudeAccuracy: 0,
        heading: fix.headingDegrees ?? 0,
        headingAccuracy: 0,
        speed: fix.speedMps ?? 0,
        speedAccuracy: 0,
      );

  void _listenToNmea() {
    _raymarineSub = RaymarineConnectionService().dataStream
        .listen((_) => _reEvaluateSource());
    _udpSub = UdpReceiverService().dataStream
        .listen((_) => _reEvaluateSource());
  }

  /// Rozhodne, ktorý zdroj polohy je aktuálne najlepší, a ak treba,
  /// emituje nový Position do spoločného streamu.
  /// Priorita: TCP NMEA → UDP NMEA → Android GPS.
  void _reEvaluateSource() {
    final tcp = RaymarineConnectionService();
    final udp = UdpReceiverService();

    MarineInstrumentData? nmea;
    if (tcp.isConnected && tcp.hasFreshData && tcp.current.hasGpsFix) {
      nmea = tcp.current;
    } else if (udp.isListening && udp.hasFreshData && udp.current.hasGpsFix) {
      nmea = udp.current;
    }

    if (nmea != null) {
      final pos = Position(
        latitude: nmea.latitude!,
        longitude: nmea.longitude!,
        timestamp: nmea.gpsTimestampUtc ?? DateTime.now(),
        accuracy: 0,
        altitude: _lastAndroidPosition?.altitude ?? 0,
        altitudeAccuracy: 0,
        heading: nmea.cogDegrees ?? nmea.headingDegrees ?? 0,
        headingAccuracy: 0,
        speed: (nmea.sogKnots ?? 0) / 1.94384,
        speedAccuracy: 0,
      );
      _usingRaymarine = true;
      _lastPosition = pos;
      _lastSource = LocationSource.gnss;
      _lastIsMocked = false;
      _emit(pos);
      return;
    }

    // Fallback na Android GPS
    if (_lastAndroidPosition != null) {
      _usingRaymarine = false;
      _lastPosition = _lastAndroidPosition;
      _lastSource = _lastAndroidSource;
      _lastIsMocked = _lastAndroidIsMocked;
      _emit(_lastAndroidPosition!);
    }
  }

  /// Do streamu pošle fix len ak je od posledného odoslaného skutočne iný —
  /// pozri komentár pri _lastEmittedPosition.
  void _emit(Position pos) {
    final last = _lastEmittedPosition;
    final same = last != null &&
        last.timestamp == pos.timestamp &&
        last.latitude == pos.latitude &&
        last.longitude == pos.longitude;
    if (same) return;
    _lastEmittedPosition = pos;
    _ctrl.add(pos);
  }

  void dispose() {
    _androidSub?.cancel();
    _raymarineSub?.cancel();
    _udpSub?.cancel();
    _fallbackCheckTimer?.cancel();
    _ctrl.close();
  }
}
