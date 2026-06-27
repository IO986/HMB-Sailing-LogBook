import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/marine_instrument_data.dart';
import 'nmea_parser_service.dart';

/// Singleton služba pre pripojenie k Raymarine WiFi gateway (alebo inému
/// NMEA 0183 TCP/UDP zdroju na lodi).
///
/// Raymarine WiFi gateway (napr. RayNet, AXIOM s WiFi-1) typicky vysiela
/// NMEA 0183 ako TCP server na porte 2000 alebo 10110, prípadne ako UDP
/// broadcast na rovnakých portoch. Telefón sa najprv pripojí na WiFi sieť
/// gateway (alebo gateway sa pripojí do lodnej siete), potom appka otvorí
/// TCP/UDP socket na danú IP a port.
///
/// Bežné defaulty:
/// - Raymarine WiFi-1 / RayNet: 10.0.0.1, port 2000 (TCP)
/// - Mnohé iné gateway (Vesper, Yacht Devices, Digital Yacht): port 10110
class RaymarineConnectionService {
  static final RaymarineConnectionService _i = RaymarineConnectionService._();
  factory RaymarineConnectionService() => _i;
  RaymarineConnectionService._();

  final _parser = NmeaParserService();

  Socket? _socket;
  StreamSubscription? _socketSub;
  Timer? _reconnectTimer;
  Timer? _staleCheckTimer;

  final _dataCtrl = StreamController<MarineInstrumentData>.broadcast();
  final _stateCtrl = StreamController<RaymarineConnectionState>.broadcast();

  MarineInstrumentData _current = const MarineInstrumentData();
  RaymarineConnectionState _state = RaymarineConnectionState.disconnected;
  String? _lastError;
  String _host = '';
  int _port = 2000;
  bool _autoReconnect = false;

  /// Stream s aktuálnymi agregovanými dátami z inštrumentov.
  Stream<MarineInstrumentData> get dataStream => _dataCtrl.stream;

  /// Stream so zmenami stavu pripojenia.
  Stream<RaymarineConnectionState> get stateStream => _stateCtrl.stream;

  MarineInstrumentData get current => _current;
  RaymarineConnectionState get state => _state;
  String? get lastError => _lastError;
  bool get isConnected => _state == RaymarineConnectionState.connected;

  /// Považujeme dáta za "živé", ak prišli za posledných 8 sekúnd.
  /// Po tomto čase fallback prepne na telefónne GPS / predpoveď.
  static const _staleTimeout = Duration(seconds: 8);

  bool get hasFreshData {
    final last = _current.lastUpdate;
    if (last == null) return false;
    return DateTime.now().difference(last) < _staleTimeout;
  }

  /// Pripojí sa na zadanú IP a port. Ak [autoReconnect] je true, pri výpadku
  /// spojenia sa bude periodicky pokúšať znova pripojiť na pozadí.
  Future<bool> connect({
    required String host,
    int port = 2000,
    bool autoReconnect = true,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    _host = host;
    _port = port;
    _autoReconnect = autoReconnect;

    await _teardownSocket();
    _setState(RaymarineConnectionState.connecting);
    _lastError = null;

    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      _socket = socket;

      _socketSub = socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _onLine,
            onError: (e) => _handleDisconnect('Socket error: $e'),
            onDone: () => _handleDisconnect('Spojenie ukončené'),
            cancelOnError: true,
          );

      _setState(RaymarineConnectionState.connected);
      _startStaleCheck();
      print('[RAYMARINE] Connected to $host:$port');
      return true;
    } catch (e) {
      _lastError = e.toString();
      _setState(RaymarineConnectionState.error);
      print('[RAYMARINE] Connect failed: $e');
      if (_autoReconnect) _scheduleReconnect();
      return false;
    }
  }

  Future<void> disconnect() async {
    _autoReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _teardownSocket();
    _setState(RaymarineConnectionState.disconnected);
    print('[RAYMARINE] Disconnected by user');
  }

  Future<void> _teardownSocket() async {
    _staleCheckTimer?.cancel();
    _staleCheckTimer = null;
    await _socketSub?.cancel();
    _socketSub = null;
    try {
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
  }

  void _handleDisconnect(String reason) {
    _lastError = reason;
    print('[RAYMARINE] Disconnected: $reason');
    _teardownSocket();
    _setState(RaymarineConnectionState.error);
    if (_autoReconnect) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_autoReconnect && _host.isNotEmpty) {
        print('[RAYMARINE] Attempting reconnect to $_host:$_port');
        connect(host: _host, port: _port, autoReconnect: true);
      }
    });
  }

  void _startStaleCheck() {
    _staleCheckTimer?.cancel();
    _staleCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Ak dlho neprišli žiadne dáta hoci socket je "connected",
      // gateway mohol zamrznúť - vynúť reconnect.
      final last = _current.lastUpdate;
      if (last != null &&
          DateTime.now().difference(last) > const Duration(seconds: 20) &&
          _state == RaymarineConnectionState.connected) {
        _handleDisconnect('Žiadne dáta 20s - reconnect');
      }
    });
  }

  void _onLine(String line) {
    final result = _parser.parseLine(line);
    if (result == null || result.isEmpty) return;

    final now = DateTime.now();
    var updated = _current;

    if (result.fix != null && result.fix!.valid) {
      final fix = result.fix!;
      updated = updated.copyWith(
        latitude: fix.latitude,
        longitude: fix.longitude,
        sogKnots: fix.speedKnots,
        cogDegrees: fix.courseDegrees,
        gpsTimestampUtc: fix.timestampUtc,
        lastUpdate: now,
      );
    } else if (result.wind != null) {
      final w = result.wind!;
      updated = updated.copyWith(
        windSpeedKnots: w.speedKnots,
        windAngleDegrees: w.angleDegrees,
        windIsApparent: w.isApparent,
        lastUpdate: now,
        windLastUpdate: now,
      );
    } else if (result.depth != null) {
      updated = updated.copyWith(
        depthMeters: result.depth!.depthMeters,
        lastUpdate: now,
        depthLastUpdate: now,
      );
    } else if (result.waterTemp != null) {
      updated = updated.copyWith(
        waterTempCelsius: result.waterTemp!.celsius,
        lastUpdate: now,
      );
    } else if (result.heading != null) {
      final h = result.heading!;
      updated = updated.copyWith(
        headingDegrees: h.degrees,
        headingIsTrue: h.isTrue,
        lastUpdate: now,
      );
    } else if (result.engine != null) {
      updated = updated.copyWith(
        engineRpm: result.engine!.rpm,
        lastUpdate: now,
      );
    } else {
      return;
    }

    _current = updated;
    _dataCtrl.add(_current);
  }

  void _setState(RaymarineConnectionState s) {
    _state = s;
    _stateCtrl.add(s);
  }

  void dispose() {
    _autoReconnect = false;
    _reconnectTimer?.cancel();
    _teardownSocket();
    _dataCtrl.close();
    _stateCtrl.close();
  }
}
