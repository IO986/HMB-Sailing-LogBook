import 'dart:async';
import 'package:geolocator/geolocator.dart';

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

  StreamSubscription<Position>? _androidSub;
  StreamSubscription<MarineInstrumentData>? _raymarineSub;
  StreamSubscription<MarineInstrumentData>? _udpSub;
  Timer? _fallbackCheckTimer;

  final _ctrl = StreamController<Position>.broadcast();
  Position? _lastPosition;
  Position? _lastAndroidPosition;
  bool _initialized = false;
  bool _usingRaymarine = false;

  Stream<Position> get stream => _ctrl.stream;
  Position? get lastPosition => _lastPosition;

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
    });

    print('[LOC] Location service started');
  }

  Future<void> _initAndroidGps() async {
    final svcOn = await Geolocator.isLocationServiceEnabled();
    if (!svcOn) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) return;

    // Načítaj poslednú known position okamžite
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _lastAndroidPosition = last;
        _reEvaluateSource();
      }
    } catch (_) {}

    // Spusti stream
    _androidSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      _lastAndroidPosition = pos;
      _reEvaluateSource();
    }, onError: (e) => print('[LOC] Android GPS error: $e'));
  }

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
      _ctrl.add(pos);
      return;
    }

    // Fallback na Android GPS
    if (_lastAndroidPosition != null) {
      _usingRaymarine = false;
      _lastPosition = _lastAndroidPosition;
      _ctrl.add(_lastAndroidPosition!);
    }
  }

  void dispose() {
    _androidSub?.cancel();
    _raymarineSub?.cancel();
    _udpSub?.cancel();
    _fallbackCheckTimer?.cancel();
    _ctrl.close();
  }
}
