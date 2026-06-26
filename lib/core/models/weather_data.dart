class WeatherData {
  final DateTime time;
  final double windSpeed;
  final double windDirection;
  final double waveHeight;
  final double wavePeriod;
  final double airPressure;
  final double airTemp;
  final double waterTemp;
  final double cloudCover;
  final int? weatherCode;
  final int? precipitationProbability;  // 0–100 %
  final double? precipitation;          // mm

  const WeatherData({
    required this.time,
    required this.windSpeed,
    required this.windDirection,
    required this.waveHeight,
    required this.wavePeriod,
    required this.airPressure,
    required this.airTemp,
    required this.waterTemp,
    required this.cloudCover,
    this.weatherCode,
    this.precipitationProbability,
    this.precipitation,
  });

  int get beaufort {
    if (windSpeed < 1) return 0;
    if (windSpeed < 6) return 1;
    if (windSpeed < 12) return 2;
    if (windSpeed < 20) return 3;
    if (windSpeed < 29) return 4;
    if (windSpeed < 39) return 5;
    if (windSpeed < 50) return 6;
    if (windSpeed < 62) return 7;
    if (windSpeed < 75) return 8;
    if (windSpeed < 89) return 9;
    if (windSpeed < 103) return 10;
    if (windSpeed < 118) return 11;
    return 12;
  }

  String get windDirectionLabel {
    const dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'];
    return dirs[((windDirection / 22.5) + 0.5).toInt() % 16];
  }
}
