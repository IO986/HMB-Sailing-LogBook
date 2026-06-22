import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/marine_instrument_data.dart';
import '../services/raymarine_connection_service.dart';

const _prefKeyHost = 'raymarine_host';
const _prefKeyPort = 'raymarine_port';
const _prefKeyAutoConnect = 'raymarine_auto_connect';

/// Stream najnovších agregovaných dát z lodných inštrumentov.
final marineDataProvider = StreamProvider<MarineInstrumentData>((ref) {
  return RaymarineConnectionService().dataStream;
});

/// Stream aktuálneho stavu pripojenia.
final raymarineConnectionStateProvider =
    StreamProvider<RaymarineConnectionState>((ref) {
  return RaymarineConnectionService().stateStream;
});

/// Uložené nastavenia pripojenia (IP, port, auto-connect).
class RaymarineSettings {
  final String host;
  final int port;
  final bool autoConnect;
  const RaymarineSettings({
    this.host = '',
    this.port = 2000,
    this.autoConnect = false,
  });

  RaymarineSettings copyWith({String? host, int? port, bool? autoConnect}) =>
      RaymarineSettings(
        host: host ?? this.host,
        port: port ?? this.port,
        autoConnect: autoConnect ?? this.autoConnect,
      );

  bool get isConfigured => host.isNotEmpty;
}

class RaymarineSettingsNotifier extends StateNotifier<RaymarineSettings> {
  RaymarineSettingsNotifier() : super(const RaymarineSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = RaymarineSettings(
      host: prefs.getString(_prefKeyHost) ?? '',
      port: prefs.getInt(_prefKeyPort) ?? 2000,
      autoConnect: prefs.getBool(_prefKeyAutoConnect) ?? false,
    );
  }

  Future<void> save({
    required String host,
    required int port,
    required bool autoConnect,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyHost, host);
    await prefs.setInt(_prefKeyPort, port);
    await prefs.setBool(_prefKeyAutoConnect, autoConnect);
    state = RaymarineSettings(host: host, port: port, autoConnect: autoConnect);
  }
}

final raymarineSettingsProvider =
    StateNotifierProvider<RaymarineSettingsNotifier, RaymarineSettings>(
        (ref) => RaymarineSettingsNotifier());
