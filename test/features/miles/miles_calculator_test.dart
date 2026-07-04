import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/miles/services/miles_calculator.dart';

Charter _charter({
  required int id,
  String vesselName = 'Delfin',
  int year = 2025,
  String? myRole = 'skipper',
}) =>
    Charter(
      id: id,
      title: 'Plavba $id',
      dateFrom: DateTime.utc(year, 6, 1),
      dateTo: DateTime.utc(year, 6, 8),
      vesselName: vesselName,
      safetyBriefingDone: false,
      checkInDone: false,
      checkOutDone: false,
      createdAt: DateTime.utc(year, 5, 1),
      pdfRevision: 0,
      myRole: myRole,
    );

DayLog _dayLog({required int id, required int charterId, required DateTime date, double distanceNm = 20}) =>
    DayLog(
      id: id,
      charterId: charterId,
      date: date,
      distanceNm: distanceNm,
      isComplete: true,
    );

TrackPoint _point(int id, DateTime ts, {double lat = 43.5, double lon = 16.4}) => TrackPoint(
      id: id,
      timestamp: ts,
      latitude: lat,
      longitude: lon,
    );

HistoricalVoyage _historical({
  required int id,
  int year = 2015,
  double distanceNm = 100,
  int? daysCount = 5,
}) =>
    HistoricalVoyage(
      id: id,
      dateFrom: DateTime.utc(year, 7, 1),
      dateTo: DateTime.utc(year, 7, 5),
      vesselName: 'Stará loď',
      distanceNm: distanceNm,
      daysCount: daysCount,
      role: 'crew',
      createdAt: DateTime.utc(year, 7, 6),
    );

void main() {
  test('sums NM and days across charters and historical voyages', () {
    final charter = _charter(id: 1);
    final day1 = _dayLog(id: 1, charterId: 1, date: DateTime.utc(2025, 6, 1), distanceNm: 20);
    final day2 = _dayLog(id: 2, charterId: 1, date: DateTime.utc(2025, 6, 2), distanceNm: 30);
    final historical = _historical(id: 1, distanceNm: 100, daysCount: 5);

    final result = MilesCalculator.aggregate(
      charters: [charter],
      dayLogsByCharter: {1: [day1, day2]},
      trackPointsByDayLog: const {},
      historicalVoyages: [historical],
    );

    expect(result.totalNm, 150); // 20 + 30 + 100
    expect(result.daysAtSea, 7); // 2 charter days + 5 historical
    expect(result.voyageCount, 2); // 1 charter + 1 historical
    expect(result.voyages, hasLength(2));
    expect(result.voyages.any((v) => v.isManualEntry), isTrue);
  });

  test('breaks down NM by year and by vessel', () {
    final charterA = _charter(id: 1, vesselName: 'Delfin', year: 2024);
    final charterB = _charter(id: 2, vesselName: 'Amfora', year: 2025);
    final dayA = _dayLog(id: 1, charterId: 1, date: DateTime.utc(2024, 6, 1), distanceNm: 40);
    final dayB = _dayLog(id: 2, charterId: 2, date: DateTime.utc(2025, 6, 1), distanceNm: 60);

    final result = MilesCalculator.aggregate(
      charters: [charterA, charterB],
      dayLogsByCharter: {1: [dayA], 2: [dayB]},
      trackPointsByDayLog: const {},
      historicalVoyages: const [],
    );

    expect(result.nmByYear[2024], 40);
    expect(result.nmByYear[2025], 60);
    expect(result.nmByVessel['Delfin'], 40);
    expect(result.nmByVessel['Amfora'], 60);
  });

  test('year filter excludes non-matching charters and historical voyages', () {
    final charterA = _charter(id: 1, year: 2024);
    final charterB = _charter(id: 2, year: 2025);
    final dayA = _dayLog(id: 1, charterId: 1, date: DateTime.utc(2024, 6, 1), distanceNm: 40);
    final dayB = _dayLog(id: 2, charterId: 2, date: DateTime.utc(2025, 6, 1), distanceNm: 60);
    final historical2024 = _historical(id: 1, year: 2024, distanceNm: 10);

    final result = MilesCalculator.aggregate(
      charters: [charterA, charterB],
      dayLogsByCharter: {1: [dayA], 2: [dayB]},
      trackPointsByDayLog: const {},
      historicalVoyages: [historical2024],
      filter: const MilesFilter(year: 2024),
    );

    expect(result.totalNm, 50); // 40 + 10, not 60
    expect(result.voyageCount, 2);
  });

  test('counts night hours only for consecutive night-time track points', () {
    final charter = _charter(id: 1);
    // 22:00 -> 22:15 UTC on equator: well after sunset (~18:00), both night,
    // gap under the 30 min pause-detection cutoff.
    final day = _dayLog(id: 1, charterId: 1, date: DateTime.utc(2025, 6, 1));
    final points = [
      _point(1, DateTime.utc(2025, 6, 1, 22, 0), lat: 0, lon: 0),
      _point(2, DateTime.utc(2025, 6, 1, 22, 15), lat: 0, lon: 0),
    ];

    final result = MilesCalculator.aggregate(
      charters: [charter],
      dayLogsByCharter: {1: [day]},
      trackPointsByDayLog: {1: points},
      historicalVoyages: const [],
    );

    expect(result.nightHours, closeTo(0.25, 0.02));
  });

  test('does not count daytime track points as night hours', () {
    final charter = _charter(id: 1);
    final day = _dayLog(id: 1, charterId: 1, date: DateTime.utc(2025, 6, 1));
    // Midday on the equator: well within daylight.
    final points = [
      _point(1, DateTime.utc(2025, 6, 1, 11, 0), lat: 0, lon: 0),
      _point(2, DateTime.utc(2025, 6, 1, 12, 0), lat: 0, lon: 0),
    ];

    final result = MilesCalculator.aggregate(
      charters: [charter],
      dayLogsByCharter: {1: [day]},
      trackPointsByDayLog: {1: points},
      historicalVoyages: const [],
    );

    expect(result.nightHours, 0);
  });

  test('skips large gaps between points (tracking likely paused)', () {
    final charter = _charter(id: 1);
    final day = _dayLog(id: 1, charterId: 1, date: DateTime.utc(2025, 6, 1));
    final points = [
      _point(1, DateTime.utc(2025, 6, 1, 22, 0), lat: 0, lon: 0),
      _point(2, DateTime.utc(2025, 6, 1, 23, 59), lat: 0, lon: 0), // ~2h gap
    ];

    final result = MilesCalculator.aggregate(
      charters: [charter],
      dayLogsByCharter: {1: [day]},
      trackPointsByDayLog: {1: points},
      historicalVoyages: const [],
    );

    expect(result.nightHours, 0);
  });
}
