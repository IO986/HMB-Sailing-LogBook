import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import '../utils/geo_grid.dart';

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

  /// Po 429 sa chvíľu neskúša nič — ďalšie dotazy by limit len predlžovali.
  static const _rateLimitBackoff = Duration(minutes: 10);

  /// Najkratší odstup medzi dvoma sťahovaniami.
  ///
  /// Pri posúvaní mapy sa výrez mení stále a hrubý kľúč to nezachytí — v logu
  /// bolo vidno sťahovanie každú sekundu. Šípky sú orientačná vrstva, na
  /// dvadsať sekúnd starých hodnotách sa nič nestratí, a limit Open-Meteo sa
  /// tým prestane míňať zbytočne.
  static const _minRefetchInterval = Duration(seconds: 20);

  List<WindPoint>? _cache;
  String? _cacheKey;
  DateTime? _fetchedAt;
  DateTime? _rateLimitedUntil;

  /// Kľúč je zámerne hrubý (0,1°): drobné posuny mapy tak nespúšťajú nové
  /// sťahovanie. Plocha sa NEVYPCHÁVA ako pri vrstve počasia — tam ide o
  /// spojité pole, ktoré sa interpoluje, tu o riedku mriežku šípok, a
  /// roztiahnuť 4×4 body cez väčšiu plochu by znamenalo menej šípok v tom,
  /// čo je naozaj vidno.
  String _key(LatLngBounds b) =>
      '${b.south.toStringAsFixed(1)}:${b.west.toStringAsFixed(1)}:'
      '${b.north.toStringAsFixed(1)}:${b.east.toStringAsFixed(1)}';

  Future<List<WindPoint>> fetchForBounds(LatLngBounds bounds) async {
    final key = _key(bounds);
    if (_cache != null &&
        _cacheKey == key &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 15)) {
      return _cache!;
    }

    final limited = _rateLimitedUntil;
    if (limited != null && DateTime.now().isBefore(limited)) {
      return _cache ?? const [];
    }

    if (_cache != null &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < _minRefetchInterval) {
      return _cache!;
    }

    // Spoločná mriežka s vrstvou počasia — tá istá matematika napísaná
    // dvakrát by sa časom rozišla.
    final cells = gridOverBounds(bounds, _grid);
    final lats = [for (final c in cells) c.lat];
    final lons = [for (final c in cells) c.lon];

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
      _rateLimitedUntil = null;
      debugPrint('[WIND] grid fetched: ${points.length} points');
      return points;
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        _rateLimitedUntil = DateTime.now().add(_rateLimitBackoff);
        debugPrint('[WIND] rate limited, backing off');
      }
      return _cache ?? const [];
    } catch (e) {
      debugPrint('[WIND] fetch failed: $e');
      return _cache ?? const [];
    }
  }
}
