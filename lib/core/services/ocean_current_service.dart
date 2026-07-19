import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

/// Prúd v jednom bode a čase.
///
/// Smer je oceánografický — udáva, KAM prúd tečie (na rozdiel od vetra, ktorý
/// sa udáva odkiaľ fúka). Rýchlosť je v uzloch.
class SeaCurrentPoint {
  final double lat;
  final double lon;
  final double speedKn;
  final double dirDeg;
  final DateTime? time;

  const SeaCurrentPoint({
    required this.lat,
    required this.lon,
    required this.speedKn,
    required this.dirDeg,
    this.time,
  });
}

/// Reálny morský prúd z Open-Meteo Marine (zadarmo, bez kľúča).
///
/// Dopĺňa curated globálne prúdy v `ocean_currents_content.dart` — tie sú
/// referenčná príručka (Golfský prúd a spol.), toto je predpoveď pre konkrétne
/// miesto a čas.
///
/// API vracia rýchlosť v km/h; na mori sú zmysluplné uzly, takže sa prepočíta
/// hneď pri parsovaní a von ide výhradne [SeaCurrentPoint.speedKn].
class OceanCurrentService {
  static final OceanCurrentService _i = OceanCurrentService._();
  factory OceanCurrentService() => _i;
  OceanCurrentService._();

  @visibleForTesting
  OceanCurrentService.forTesting(Dio dio) : _dio = dio;

  Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  ));

  static const _endpoint = 'https://marine-api.open-meteo.com/v1/marine';
  static const _hourlyVars = 'ocean_current_velocity,ocean_current_direction';

  /// 1 uzol = 1,852 km/h.
  static const kmhPerKnot = 1.852;
  static double knotsFromKmh(double kmh) => kmh / kmhPerKnot;

  // ── Karta: hodinový priebeh pre jednu polohu ──────────────────

  /// Hodinová predpoveď prúdu pre jedno miesto.
  ///
  /// Prázdny zoznam = miesto nemá morské pokrytie (vnútrozemie vracia 200 OK
  /// s null hodnotami). Hádže [DioException], keď zlyhá požiadavka.
  Future<List<SeaCurrentPoint>> fetchForecast({
    required double lat,
    required double lon,
    int days = 3,
  }) async {
    final resp = await _dio.get(_endpoint, queryParameters: {
      'latitude': lat,
      'longitude': lon,
      'hourly': _hourlyVars,
      'timezone': 'UTC',
      'forecast_days': days,
    });

    final data = resp.data as Map<String, dynamic>;
    final hourly = data['hourly'] as Map<String, dynamic>?;
    if (hourly == null) return const [];

    final times = (hourly['time'] as List?) ?? const [];
    final speeds = (hourly['ocean_current_velocity'] as List?) ?? const [];
    final dirs = (hourly['ocean_current_direction'] as List?) ?? const [];

    final points = <SeaCurrentPoint>[];
    for (var i = 0; i < times.length; i++) {
      if (i >= speeds.length || i >= dirs.length) break;
      final speed = speeds[i];
      final dir = dirs[i];
      if (speed == null || dir == null) continue;
      points.add(SeaCurrentPoint(
        lat: lat,
        lon: lon,
        speedKn: knotsFromKmh((speed as num).toDouble()),
        dirDeg: (dir as num).toDouble(),
        // API pýtame v UTC, ale reťazce nenesú príponu zóny.
        time: DateTime.parse('${times[i]}Z').toUtc(),
      ));
    }
    return points;
  }

  /// Prúd platný najbližšie k [when] (predvolene teraz).
  static SeaCurrentPoint? nearestTo(List<SeaCurrentPoint> points, DateTime when) {
    if (points.isEmpty) return null;
    final target = when.toUtc();
    SeaCurrentPoint? best;
    Duration? bestGap;
    for (final p in points) {
      final time = p.time;
      if (time == null) continue;
      final gap = (time.difference(target)).abs();
      if (bestGap == null || gap < bestGap) {
        best = p;
        bestGap = gap;
      }
    }
    return best ?? points.first;
  }

  // ── Mapa: mriežka cez viditeľný výrez ─────────────────────────

  /// Vetrová mriežka vzorkuje stredy buniek 4×4, teda zlomky 1/8, 3/8, 5/8,
  /// 7/8 výrezu. Prúd preto vzorkuje rohy tých istých buniek — 2/8, 4/8, 6/8 —
  /// takže obe mriežky sa prekladajú a šípky si nesadnú na seba. Body zostávajú
  /// tam, kde ich dáta naozaj platia; neposúva sa kresba, ale vzorkovanie.
  static const _grid = 3; // 3×3 bodov, posunuté o pol bunky oproti vetru
  static const _windGrid = 4;
  List<SeaCurrentPoint>? _cache;
  String? _cacheKey;
  DateTime? _fetchedAt;

  String _key(LatLngBounds b) =>
      '${b.south.toStringAsFixed(1)}:${b.west.toStringAsFixed(1)}:'
      '${b.north.toStringAsFixed(1)}:${b.east.toStringAsFixed(1)}';

  /// Aktuálny prúd v mriežke bodov cez výrez mapy. Jedna dávková
  /// požiadavka, cache 15 min na výrez — rovnaký vzor ako [WindGridService].
  Future<List<SeaCurrentPoint>> fetchForBounds(LatLngBounds bounds) async {
    final key = _key(bounds);
    if (_cache != null &&
        _cacheKey == key &&
        _fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 15)) {
      return _cache!;
    }

    final lats = <double>[];
    final lons = <double>[];
    for (var i = 0; i < _grid; i++) {
      for (var j = 0; j < _grid; j++) {
        lats.add(bounds.south +
            (bounds.north - bounds.south) * (i + 1) / _windGrid);
        lons.add(
            bounds.west + (bounds.east - bounds.west) * (j + 1) / _windGrid);
      }
    }

    try {
      final resp = await _dio.get(_endpoint, queryParameters: {
        'latitude': lats.map((v) => v.toStringAsFixed(3)).join(','),
        'longitude': lons.map((v) => v.toStringAsFixed(3)).join(','),
        'current': _hourlyVars,
      });

      // Pri viacerých súradniciach vráti Open-Meteo pole objektov,
      // pri jednej jediný objekt.
      final data = resp.data;
      final list = data is List ? data : [data];
      final points = <SeaCurrentPoint>[];
      for (var i = 0; i < list.length && i < lats.length; i++) {
        final cur = list[i]['current'];
        if (cur == null) continue;
        final speed = (cur['ocean_current_velocity'] as num?)?.toDouble();
        final dir = (cur['ocean_current_direction'] as num?)?.toDouble();
        // Pevnina vracia nully — taký bod sa jednoducho nekreslí.
        if (speed == null || dir == null) continue;
        points.add(SeaCurrentPoint(
          lat: lats[i],
          lon: lons[i],
          speedKn: knotsFromKmh(speed),
          dirDeg: dir,
        ));
      }
      _cache = points;
      _cacheKey = key;
      _fetchedAt = DateTime.now();
      debugPrint('[CURRENT] grid fetched: ${points.length} points');
      return points;
    } catch (e) {
      debugPrint('[CURRENT] fetch failed: $e');
      return _cache ?? const [];
    }
  }
}
