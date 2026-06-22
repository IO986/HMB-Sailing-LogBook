import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../models/marine_instrument_data.dart';
import 'raymarine_connection_service.dart';

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
    _listenToRaymarine();

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

  void _listenToRaymarine() {
    _raymarineSub = RaymarineConnectionService().dataStream.listen((data) {
      _reEvaluateSource();
    });
  }

  /// Rozhodne, ktorý zdroj polohy je aktuálne najlepší, a ak treba,
  /// emituje nový Position do spoločného streamu.
  void _reEvaluateSource() {
    final raymarine = RaymarineConnectionService();

    if (raymarine.isConnected &&
        raymarine.hasFreshData &&
        raymarine.current.hasGpsFix) {
      final d = raymarine.current;
      final pos = Position(
        latitude: d.latitude!,
        longitude: d.longitude!,
        timestamp: d.gpsTimestampUtc ?? DateTime.now(),
        accuracy: 0,
        altitude: _lastAndroidPosition?.altitude ?? 0,
        altitudeAccuracy: 0,
        heading: d.cogDegrees ?? d.headingDegrees ?? 0,
        headingAccuracy: 0,
        speed: (d.sogKnots ?? 0) / 1.94384, // knots -> m/s
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
    _fallbackCheckTimer?.cancel();
    _ctrl.close();
  }
}
