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
      weatherCode: e.weatherCode,
      precipitationProbability: e.precipitationProbability,
      precipitation: e.precipitation,
      downloadedAt: e.downloadedAt,
      modelName: e.modelName,
    )).toList();
  }

  /// Riadok, ktorý najlepšie sedí na „teraz".
  ///
  /// Nie `first`: keš siaha do minulosti, takže prvý riadok je najstarší
  /// stiahnutý čas a po pár hodinách by sa ako aktuálne počasie ukazovalo
  /// ráno, ktoré už dávno bolo.
  Future<WeatherData?> getCurrentWeather() async {
    final f = await getForecast();
    if (f.isEmpty) return null;
    final now = DateTime.now();
    f.sort((a, b) => a.time
        .difference(now)
        .abs()
        .compareTo(b.time.difference(now).abs()));
    return f.first;
  }
}
