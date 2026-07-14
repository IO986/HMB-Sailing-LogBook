import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

/// Bod predpovede vetra pre šípku na mape.
class WindPoint {
  final double lat;
  final double lon;
  final double speedKn;
  final double dirDeg; // meteorologicky: odkiaľ fúka
  const WindPoint(this.lat, this.lon, this.speedKn, this.dirDeg);
}

/// Aktuálny vietor v mriežke bodov cez viditeľný výrez mapy (Open-Meteo,
/// zadarmo, bez kľúča — rovnaké API ako predpoveď v záložke Počasie).
/// Jedna dávková požiadavka pre celú mriežku; cache 15 min na výrez.
class WindGridService {
  static final WindGridService _i = WindGridService._();
  factory WindGridService() => _i;
  WindGridService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  ));

  static const _grid = 4; // 4×4 bodov
  List<WindPoint>? _cache;
  String? _cacheKey;
  DateTime? _fetchedAt;

  String _key(LatLngBounds b) =>
      '${b.south.toStringAsFixed(1)}:${b.west.toStringAsFixed(1)}:'
      '${b.north.toStringAsFixed(1)}:${b.east.toStringAsFixed(1)}';

  Future<List<WindPoint>> fetchForBounds(LatLngBounds bounds) async {
    final key = _key(bounds);
    if (_cache != null &&
        _cacheKey == key &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) <
            const Duration(minutes: 15)) {
      return _cache!;
    }

    final lats = <double>[];
    final lons = <double>[];
    for (var i = 0; i < _grid; i++) {
      for (var j = 0; j < _grid; j++) {
        lats.add(bounds.south +
            (bounds.north - bounds.south) * (i + 0.5) / _grid);
        lons.add(bounds.west +
            (bounds.east - bounds.west) * (j + 0.5) / _grid);
      }
    }

    try {
      final resp = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lats.map((v) => v.toStringAsFixed(3)).join(','),
          'longitude': lons.map((v) => v.toStringAsFixed(3)).join(','),
          'current': 'wind_speed_10m,wind_direction_10m',
          'wind_speed_unit': 'kn',
        },
      );
      // Pri viacerých súradniciach vráti Open-Meteo pole objektov,
      // pri jednej jediný objekt.
      final data = resp.data;
      final list = data is List ? data : [data];
      final points = <WindPoint>[];
      for (var i = 0; i < list.length && i < lats.length; i++) {
        final cur = list[i]['current'];
        if (cur == null) continue;
        final spd = (cur['wind_speed_10m'] as num?)?.toDouble();
        final dir = (cur['wind_direction_10m'] as num?)?.toDouble();
        if (spd == null || dir == null) continue;
        points.add(WindPoint(lats[i], lons[i], spd, dir));
      }
      _cache = points;
      _cacheKey = key;
      _fetchedAt = DateTime.now();
      debugPrint('[WIND] grid fetched: ${points.length} points');
      return points;
    } catch (e) {
      debugPrint('[WIND] fetch failed: $e');
      return _cache ?? const [];
    }
  }
}
