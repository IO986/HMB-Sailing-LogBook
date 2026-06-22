import 'package:drift/drift.dart';

class WeatherSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  DateTimeColumn get forecastTime => dateTime()();
  DateTimeColumn get downloadedAt => dateTime()();

  RealColumn get windSpeed => real()();
  RealColumn get windDirection => real()();

  RealColumn get waveHeight => real().nullable()();
  RealColumn get wavePeriod => real().nullable()();

  RealColumn get airPressure => real().nullable()();

  RealColumn get airTemp => real().nullable()();
  RealColumn get waterTemp => real().nullable()();

  RealColumn get cloudCover => real().nullable()();
}
