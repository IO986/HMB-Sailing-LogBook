import 'package:dio/dio.dart';

class MarineWeatherService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchMarine({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get(
      'https://marine-api.open-meteo.com/v1/marine',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'hourly': [
          'wave_height',
          'wave_period',
          'sea_surface_temperature',
        ].join(','),
        'forecast_days': 3,
      },
    );

    return response.data;
  }
}
