import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
}
