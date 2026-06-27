import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/marine_instrument_data.dart';
import '../services/raymarine_connection_service.dart';
import 'nmea_parser_service.dart';

/// UDP receiver — počúva NMEA 0183 datagramy na zadanom porte.
/// Použitie: simulátory (napr. NMEA Sim), gateway zariadenia
/// s UDP broadcast módom (Yacht Devices YDWG-02, niektoré B&G).
///
/// Mobil sa nepripája nikam — LEN počúva na porte. Zdroj musí
/// posielať datagramy na IP mobilu (unicast) alebo broadcast.
class UdpReceiverService {
  static final UdpReceiverService _i = UdpReceiverService._();
  factory UdpReceiverService() => _i;
  UdpReceiverService._();

  final _parser = NmeaParserService();

  RawDatagramSocket? _socket;
  StreamSubscription? _sub;

  final _dataCtrl = StreamController<MarineInstrumentData>.broadcast();
  final _stateCtrl = StreamController<RaymarineConnectionState>.broadcast();

  MarineInstrumentData _current = const MarineInstrumentData();
  RaymarineConnectionState _state = RaymarineConnectionState.disconnected;
  String? _lastError;
  int _port = 10110;

  Stream<MarineInstrumentData> get dataStream => _dataCtrl.stream;
  Stream<RaymarineConnectionState> get stateStream => _stateCtrl.stream;
  MarineInstrumentData get current => _current;
  RaymarineConnectionState get state => _state;
  String? get lastError => _lastError;
  bool get isListening => _state == RaymarineConnectionState.connected;

  static const _staleTimeout = Duration(seconds: 8);
  bool get hasFreshData {
    final last = _current.lastUpdate;
    if (last == null) return false;
    return DateTime.now().difference(last) < _staleTimeout;
  }

  Future<bool> start({int port = 10110}) async {
    _port = port;
    await _teardown();
    _lastError = null;

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      _socket!.broadcastEnabled = true;
      _sub = _socket!.listen(
        _onEvent,
        onError: (e) => _handleError('UDP chyba: $e'),
        onDone: () => _handleError('UDP socket zatvorený'),
        cancelOnError: true,
      );
      _setState(RaymarineConnectionState.connected);
      print('[UDP] Počúvam na porte $port');
      return true;
    } catch (e) {
      _lastError = e.toString();
      _setState(RaymarineConnectionState.error);
      print('[UDP] Bind zlyhalo: $e');
      return false;
    }
  }

  Future<void> stop() async {
    await _teardown();
    _setState(RaymarineConnectionState.disconnected);
    print('[UDP] Zastavený');
  }

  Future<void> _teardown() async {
    await _sub?.cancel();
    _sub = null;
    _socket?.close();
    _socket = null;
  }

  void _handleError(String reason) {
    _lastError = reason;
    print('[UDP] $reason');
    _teardown();
    _setState(RaymarineConnectionState.error);
  }

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _socket?.receive();
    if (dg == null) return;
    final raw = utf8.decode(dg.data, allowMalformed: true);
    for (final line in raw.split('\n')) {
      _onLine(line.trim());
    }
  }

  void _onLine(String line) {
    if (line.isEmpty) return;
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
    _teardown();
    _dataCtrl.close();
    _stateCtrl.close();
  }
}
