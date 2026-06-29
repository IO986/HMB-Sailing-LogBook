import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/marine_instrument_data.dart';
import '../services/raymarine_connection_service.dart';
import '../services/udp_receiver_service.dart';

const _prefKeyHost = 'raymarine_host';
const _prefKeyPort = 'raymarine_port';
const _prefKeyAutoConnect = 'raymarine_auto_connect';
const _prefKeyConnectionType = 'nmea_connection_type';
const _prefKeyUdpPort = 'nmea_udp_port';

enum NmeaConnectionType { tcp, udp }

/// Stream najnovších agregovaných dát z lodných inštrumentov (TCP).
final marineDataProvider = StreamProvider<MarineInstrumentData>((ref) {
  return RaymarineConnectionService().dataStream;
});

/// Stream aktuálneho stavu TCP pripojenia.
final raymarineConnectionStateProvider =
    StreamProvider<RaymarineConnectionState>((ref) {
  return RaymarineConnectionService().stateStream;
});

/// Stream dát z UDP prijímača.
final udpDataProvider = StreamProvider<MarineInstrumentData>((ref) {
  return UdpReceiverService().dataStream;
});

/// Stream stavu UDP prijímača.
final udpConnectionStateProvider =
    StreamProvider<RaymarineConnectionState>((ref) {
  return UdpReceiverService().stateStream;
});

/// Uložené nastavenia pripojenia (IP, port, auto-connect, typ, UDP port).
class RaymarineSettings {
  final String host;
  final int port;
  final bool autoConnect;
  final NmeaConnectionType connectionType;
  final int udpListenPort;

  const RaymarineSettings({
    this.host = '',
    this.port = 2000,
    this.autoConnect = false,
    this.connectionType = NmeaConnectionType.tcp,
    this.udpListenPort = 10110,
  });

  RaymarineSettings copyWith({
    String? host,
    int? port,
    bool? autoConnect,
    NmeaConnectionType? connectionType,
    int? udpListenPort,
  }) =>
      RaymarineSettings(
        host: host ?? this.host,
        port: port ?? this.port,
        autoConnect: autoConnect ?? this.autoConnect,
        connectionType: connectionType ?? this.connectionType,
        udpListenPort: udpListenPort ?? this.udpListenPort,
      );

  bool get isConfigured =>
      connectionType == NmeaConnectionType.udp || host.isNotEmpty;
}

class RaymarineSettingsNotifier extends StateNotifier<RaymarineSettings> {
  RaymarineSettingsNotifier() : super(const RaymarineSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final typeStr = prefs.getString(_prefKeyConnectionType) ?? 'tcp';
    state = RaymarineSettings(
      host: prefs.getString(_prefKeyHost) ?? '',
      port: prefs.getInt(_prefKeyPort) ?? 2000,
      autoConnect: prefs.getBool(_prefKeyAutoConnect) ?? false,
      connectionType:
          typeStr == 'udp' ? NmeaConnectionType.udp : NmeaConnectionType.tcp,
      udpListenPort: prefs.getInt(_prefKeyUdpPort) ?? 10110,
    );
  }

  Future<void> save({
    required String host,
    required int port,
    required bool autoConnect,
    required NmeaConnectionType connectionType,
    required int udpListenPort,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyHost, host);
    await prefs.setInt(_prefKeyPort, port);
    await prefs.setBool(_prefKeyAutoConnect, autoConnect);
    await prefs.setString(
        _prefKeyConnectionType,
        connectionType == NmeaConnectionType.udp ? 'udp' : 'tcp');
    await prefs.setInt(_prefKeyUdpPort, udpListenPort);
    state = RaymarineSettings(
      host: host,
      port: port,
      autoConnect: autoConnect,
      connectionType: connectionType,
      udpListenPort: udpListenPort,
    );
  }
}

final raymarineSettingsProvider =
    StateNotifierProvider<RaymarineSettingsNotifier, RaymarineSettings>(
        (ref) => RaymarineSettingsNotifier());
