import 'package:dio/dio.dart';

import '../models/tide_data.dart';
import 'tide_extremes.dart';

/// Fetch cez Open-Meteo Marine API — zadarmo, bez API kľúča, globálne
/// pokrytie. Rovnaký online fetch + lokálny cache vzor ako
/// [WeatherForecastService]/[MarineWeatherService] pre počasie – appka po
/// prvom stiahnutí funguje offline z uloženej cache.
///
/// Výšky sú vztiahnuté k **strednej hladine mora (MSL)**, nie k mapovému
/// datu (LAT). Nesmú sa použiť na výpočet hĺbky pod kýlom — viď upozornenie
/// v karte prílivu.
class TideForecastService {
  final Dio _dio;

  TideForecastService({Dio? dio}) : _dio = dio ?? Dio();

  static const _endpoint = 'https://marine-api.open-meteo.com/v1/marine';

  /// Hodinová krivka hladiny spolu s lokálne dopočítanými extrémami.
  ///
  /// Vráti prázdny zoznam, ak miesto nemá morské pokrytie (vnútrozemie
  /// odpovedá 200 OK s null hodnotami). Hádže [DioException], keď zlyhá
  /// samotná požiadavka, napr. bez pripojenia.
  Future<List<TidePoint>> fetchTides({
    required double lat,
    required double lon,
    int days = 7,
  }) async {
    final response = await _dio.get(
      _endpoint,
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'hourly': 'sea_level_height_msl',
        'timezone': 'UTC',
        'forecast_days': days,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final hourly = data['hourly'] as Map<String, dynamic>?;
    if (hourly == null) return const [];

    final times = (hourly['time'] as List?) ?? const [];
    final heights = (hourly['sea_level_height_msl'] as List?) ?? const [];

    final curve = <TidePoint>[];
    for (var i = 0; i < times.length && i < heights.length; i++) {
      final height = heights[i];
      // Vnútrozemie / mimo pokrytia vráti nully; preskočíme ich, nech volajúci
      // vidí "tu prílivy nemáme" a nie krivku plnú dier.
      if (height == null) continue;
      curve.add(
        TidePoint(
          // API pýtame v UTC, ale reťazce nenesú príponu zóny.
          time: DateTime.parse('${times[i]}Z').toUtc(),
          heightM: (height as num).toDouble(),
        ),
      );
    }

    if (curve.isEmpty) return const [];
    return [...curve, ...findTideExtremes(curve)];
  }
}
