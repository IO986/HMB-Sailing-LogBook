import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Zrážkový radar z RainViewer (zadarmo, bez API kľúča).
/// Vracia URL šablónu dlaždíc najnovšej radarovej snímky; cesta snímky sa
/// obnovuje raz za ~10 minút (RainViewer generuje nové snímky každých 10 min).
class RainRadarService {
  static final RainRadarService _i = RainRadarService._();
  factory RainRadarService() => _i;
  RainRadarService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  String? _tileUrl;
  DateTime? _fetchedAt;

  /// Šablóna pre flutter_map TileLayer ({z}/{x}/{y}), alebo null keď sa
  /// nepodarilo načítať zoznam snímok.
  Future<String?> latestTileUrl() async {
    final now = DateTime.now();
    if (_tileUrl != null &&
        _fetchedAt != null &&
        now.difference(_fetchedAt!) < const Duration(minutes: 10)) {
      return _tileUrl;
    }
    try {
      final resp = await _dio
          .get('https://api.rainviewer.com/public/weather-maps.json');
      final past = (resp.data['radar']?['past'] as List?) ?? const [];
      if (past.isEmpty) return _tileUrl;
      final path = past.last['path'] as String;
      final host = resp.data['host'] as String? ?? 'https://tilecache.rainviewer.com';
      // 256 px, farebná schéma 2, s vyhladzovaním (1) a snow (1)
      _tileUrl = '$host$path/256/{z}/{x}/{y}/2/1_1.png';
      _fetchedAt = now;
      debugPrint('[RADAR] frame: $path');
    } catch (e) {
      debugPrint('[RADAR] fetch failed: $e');
    }
    return _tileUrl;
  }
}
