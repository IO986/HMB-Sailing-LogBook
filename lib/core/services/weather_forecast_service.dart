import 'package:dio/dio.dart';

class WeatherForecastService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchForecast({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'hourly': [
          'temperature_2m',
          'surface_pressure',
          'cloud_cover',
          'wind_speed_10m',
          'wind_direction_10m',
          'weather_code',
          'precipitation_probability',
          'precipitation',
        ].join(','),
        'wind_speed_unit': 'kn',
        'forecast_days': 3,
      },
    );

    return response.data;
  }
}
