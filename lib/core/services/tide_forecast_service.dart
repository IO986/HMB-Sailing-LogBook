import 'package:dio/dio.dart';

/// Fetch cez WorldTides API v3 (https://www.worldtides.info) — globálne
/// pokrytie, vyžaduje API kľúč (zdarma tier pri registrácii). Rovnaký online
/// fetch + lokálny cache vzor ako [WeatherForecastService]/[MarineWeatherService]
/// pre počasie – appka po prvom stiahnutí funguje offline z uloženej cache.
class TideForecastService {
  final Dio _dio = Dio();

  /// Vráti `{'heights': [...], 'extremes': [...]}` — surové WorldTides dáta.
  /// Hádže [DioException] pri zlom/chýbajúcom kľúči alebo bez pripojenia.
  Future<Map<String, dynamic>> fetchTides({
    required double lat,
    required double lon,
    required String apiKey,
    int days = 4,
  }) async {
    final response = await _dio.get(
      'https://www.worldtides.info/api/v3',
      queryParameters: {
        'heights': '',
        'extremes': '',
        'lat': lat,
        'lon': lon,
        'step': 1800, // 30 min
        'length': days * 86400,
        'key': apiKey,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
