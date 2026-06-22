import '../database/app_database.dart';
import '../models/weather_data.dart';

class WeatherService {
  static final WeatherService _i = WeatherService._();
  factory WeatherService() => _i;
  WeatherService._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  Future<List<WeatherData>> getForecast() async {
    if (_db == null) return [];
    final snaps = await _db!.getWeatherSnapshots();
    return snaps.map((e) => WeatherData(
      time: e.forecastTime, windSpeed: e.windSpeed,
      windDirection: e.windDirection, waveHeight: e.waveHeight ?? 0,
      wavePeriod: e.wavePeriod ?? 0, airPressure: e.airPressure ?? 0,
      airTemp: e.airTemp ?? 0, waterTemp: e.waterTemp ?? 0,
      cloudCover: e.cloudCover ?? 0,
    )).toList();
  }

  Future<WeatherData?> getCurrentWeather() async {
    final f = await getForecast();
    return f.isEmpty ? null : f.first;
  }
}
