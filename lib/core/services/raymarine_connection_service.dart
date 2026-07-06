import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
  int _consecutiveFailures = 0;

  /// Po toľkých po sebe nasledujúcich neúspešných pokusoch (zlá/neexistujúca
  /// IP, port otvorený ale bez NMEA dát a pod.) sa reconnect loop vzdá -
  /// inak by appka donekonečna skúšala pripojiť sa na hosta, ktorý nikdy
  /// neodpovie správne, potichu na pozadí pri každom spustení appky.
  static const _maxConsecutiveFailures = 5;

  /// Stream s aktuálnymi agregovanými dátami z inštrumentov.
  Stream<MarineInstrumentData> get dataStream => _dataCtrl.stream;

  /// Stream so zmenami stavu pripojenia.
  Stream<RaymarineConnectionState> get stateStream => _stateCtrl.stream;

  MarineInstrumentData get current => _current;

  /// Host/port posledného (aj neúspešného) pokusu o pripojenie - na
  /// zobrazenie v UI, aby bolo jasné KAM sa appka vlastne snaží pripojiť.
  String get host => _host;
  int get port => _port;
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
  ///
  /// Úspešný TCP handshake sám o sebe neznamená, že na druhej strane je
  /// naozaj NMEA gateway (port môže mať otvorený čokoľvek iné, alebo sieťová
  /// vrstva ho môže omylom "prijať"). Preto stav [RaymarineConnectionState.connected]
  /// nastavíme až po tom, čo príde a rozparsuje sa aspoň jedna platná NMEA
  /// veta — dovtedy ostáva stav `connecting`. Ak do [dataTimeout] žiadna
  /// platná veta nepríde, pripojenie sa považuje za neúspešné.
  Future<bool> connect({
    required String host,
    int port = 2000,
    bool autoReconnect = true,
    Duration timeout = const Duration(seconds: 6),
    Duration dataTimeout = const Duration(seconds: 5),
  }) async {
    final isNewTarget = host != _host || port != _port;
    _host = host;
    _port = port;
    _autoReconnect = autoReconnect;
    if (isNewTarget) _consecutiveFailures = 0;

    await _teardownSocket();
    _setState(RaymarineConnectionState.connecting);
    _lastError = null;

    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      _socket = socket;

      final firstDataCompleter = Completer<bool>();
      _socketSub = socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              final gotData = _onLine(line);
              if (gotData && !firstDataCompleter.isCompleted) {
                firstDataCompleter.complete(true);
              }
            },
            onError: (e) => _handleDisconnect('Socket error: $e'),
            onDone: () => _handleDisconnect('Spojenie ukončené'),
            cancelOnError: true,
          );

      final gotRealData = await firstDataCompleter.future
          .timeout(dataTimeout, onTimeout: () => false);

      if (!gotRealData) {
        debugPrint('[RAYMARINE] Connect: no NMEA data from $host:$port within ${dataTimeout.inSeconds}s');
        _lastError = 'Pripojené, ale neprišli žiadne NMEA dáta';
        await _teardownSocket();
        _setState(RaymarineConnectionState.error);
        _registerFailureAndMaybeReconnect();
        return false;
      }

      _consecutiveFailures = 0;
      _setState(RaymarineConnectionState.connected);
      _startStaleCheck();
      debugPrint('[RAYMARINE] Connected to $host:$port (NMEA data confirmed)');
      return true;
    } catch (e) {
      _lastError = e.toString();
      _setState(RaymarineConnectionState.error);
      debugPrint('[RAYMARINE] Connect failed: $e');
      _registerFailureAndMaybeReconnect();
      return false;
    }
  }

  void _registerFailureAndMaybeReconnect() {
    if (!_autoReconnect) return;
    _consecutiveFailures++;
    if (_consecutiveFailures >= _maxConsecutiveFailures) {
      debugPrint('[RAYMARINE] Giving up after $_consecutiveFailures failed attempts to $_host:$_port');
      _autoReconnect = false;
      _lastError = 'Nepodarilo sa pripojiť po $_consecutiveFailures pokusoch - vzdané';
      return;
    }
    _scheduleReconnect();
  }

  Future<void> disconnect() async {
    _autoReconnect = false;
    _consecutiveFailures = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _teardownSocket();
    _setState(RaymarineConnectionState.disconnected);
    debugPrint('[RAYMARINE] Disconnected by user');
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
    debugPrint('[RAYMARINE] Disconnected: $reason');
    _teardownSocket();
    _setState(RaymarineConnectionState.error);
    _registerFailureAndMaybeReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_autoReconnect && _host.isNotEmpty) {
        debugPrint('[RAYMARINE] Attempting reconnect to $_host:$_port');
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

  bool _onLine(String line) {
    final result = _parser.parseLine(line);
    if (result == null || result.isEmpty) return false;

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
      return false;
    }

    _current = updated;
    _dataCtrl.add(_current);
    return true;
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

  /// Skúsi nájsť NMEA WiFi gateway na lokálnej sieti bez toho, aby používateľ
  /// musel ručne zisťovať a zadávať IP adresu.
  ///
  /// Gateway môže byť buď sám prístupový bod WiFi siete s pevnou adresou na
  /// `.1` danej podsiete (Raymarine WiFi-1, RayNet a pod. — telefón dostane
  /// napr. 10.0.0.2, gateway je 10.0.0.1), ALEBO len ďalšie zariadenie
  /// pripojené do zdieľaného lodného/marina routra s ľubovoľnou adresou
  /// (napr. 192.168.89.53). Preto namiesto hádania jednej adresy
  /// preskenujeme celú `/24` podsieť telefónu (odvodenú z jeho aktuálnej
  /// IP, nie natvrdo napísanú) na štandardnom porte 2000 (TCP), všetky
  /// adresy naraz.
  ///
  /// Vráti IP adresu gateway, ktorý naozaj posiela platné NMEA dáta, alebo
  /// `null` ak sa žiadny nenašiel.
  ///
  /// Beží v dvoch fázach:
  /// 1. Rýchly TCP sken celej podsiete naraz (len či je port otvorený) —
  ///    lacné, ale samo o sebe nič nedokazuje (port môže mať otvorený
  ///    čokoľvek iné, alebo sieť "prijme" spojenie bez skutočného partnera).
  /// 2. Pre každú adresu s otvoreným portom over, či z nej naozaj prídu
  ///    rozparsovateľné NMEA vety — len to potvrdí, že ide o skutočný
  ///    gateway. Bez tohto kroku auto-detect vedel nahlásiť "nájdené" aj na
  ///    adrese, kde žiadny NMEA zdroj nebol.
  Future<String?> autoDetectHost({
    int port = 2000,
    Duration connectTimeout = const Duration(seconds: 1, milliseconds: 500),
    Duration dataTimeout = const Duration(seconds: 2),
  }) async {
    final subnetPrefixes = <String>{};
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final parts = addr.address.split('.');
          if (parts.length == 4) {
            subnetPrefixes.add('${parts[0]}.${parts[1]}.${parts[2]}');
          }
        }
      }
    } catch (e) {
      debugPrint('[RAYMARINE] autoDetect: interface list failed: $e');
    }

    final candidates = <String>{
      // Bežné pevné defaulty výrobcov WiFi-NMEA gateway (pre istotu, aj keby
      // sa telefón hlásil z inej podsiete napr. cez VPN/druhé rozhranie).
      '10.0.0.1',
      '192.168.4.1',
    };
    for (final prefix in subnetPrefixes) {
      for (var host = 1; host <= 254; host++) {
        candidates.add('$prefix.$host');
      }
    }

    // Fáza 1: rýchly sken, ktoré adresy majú vôbec otvorený port.
    final openPortResults = await Future.wait(candidates.map((probe) async {
      try {
        final socket = await Socket.connect(probe, port, timeout: connectTimeout);
        socket.destroy();
        return probe;
      } catch (_) {
        return null;
      }
    }));
    final openPorts = openPortResults.whereType<String>().toList();

    if (openPorts.isEmpty) {
      debugPrint('[RAYMARINE] autoDetect: no open port $port found on subnet');
      return null;
    }

    // Fáza 2: over každú kandidátku, či naozaj posiela platné NMEA vety.
    for (final candidate in openPorts) {
      final confirmed = await _probeForNmeaData(candidate, port, dataTimeout);
      if (confirmed) {
        debugPrint('[RAYMARINE] autoDetect: confirmed NMEA gateway at $candidate:$port');
        return candidate;
      }
    }
    debugPrint('[RAYMARINE] autoDetect: ${openPorts.length} host(s) had port $port open, none sent valid NMEA data');
    return null;
  }

  /// Otvorí krátkodobé skúšobné spojenie na [host]:[port] a overí, či z neho
  /// do [dataTimeout] príde aspoň jedna rozparsovateľná NMEA veta.
  Future<bool> _probeForNmeaData(
      String host, int port, Duration dataTimeout) async {
    Socket? socket;
    StreamSubscription? sub;
    try {
      socket = await Socket.connect(host, port,
          timeout: const Duration(seconds: 2));
      final completer = Completer<bool>();
      sub = socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              final result = _parser.parseLine(line);
              if (result != null && !result.isEmpty && !completer.isCompleted) {
                completer.complete(true);
              }
            },
            onError: (_) {
              if (!completer.isCompleted) completer.complete(false);
            },
            cancelOnError: true,
          );
      return await completer.future.timeout(dataTimeout, onTimeout: () => false);
    } catch (_) {
      return false;
    } finally {
      await sub?.cancel();
      try {
        socket?.destroy();
      } catch (_) {}
    }
  }
}
