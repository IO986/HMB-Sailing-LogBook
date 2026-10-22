import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/logbook/services/track_position.dart';

void main() {
  TrackPoint p(int minute, double lat, double lon, {int hour = 10}) => TrackPoint(
        id: 0,
        timestamp: DateTime.utc(2026, 7, 10, hour, minute),
        latitude: lat,
        longitude: lon,
      );

  final track = [
    p(0, 43.00, 15.00),
    p(10, 43.10, 15.20),
    p(20, 43.20, 15.40),
  ];

  DateTime at(int minute, {int hour = 10}) =>
      DateTime.utc(2026, 7, 10, hour, minute);

  test('interpolates linearly between the two enclosing points', () {
    final pos = TrackPosition.at(track, at(5))!;
    expect(pos.lat, closeTo(43.05, 1e-9));
    expect(pos.lon, closeTo(15.10, 1e-9));

    final quarter = TrackPosition.at(track, at(12, hour: 10))!;
    expect(quarter.lat, closeTo(43.12, 1e-9));
  });

  test('an exact point returns that point', () {
    final pos = TrackPosition.at(track, at(10))!;
    expect(pos.lat, 43.10);
    expect(pos.lon, 15.20);
  });

  test('first and last point are included', () {
    expect(TrackPosition.at(track, at(0))!.lat, 43.00);
    expect(TrackPosition.at(track, at(20))!.lat, 43.20);
  });

  test('never extrapolates beyond the recording', () {
    expect(TrackPosition.at(track, at(59, hour: 9)), isNull);
    expect(TrackPosition.at(track, at(21)), isNull);
  });

  test('a hole longer than ten minutes is not bridged', () {
    final holey = [p(0, 43.0, 15.0), p(30, 43.3, 15.3)];
    expect(TrackPosition.at(holey, at(15)), isNull);
    // ...but a ten-minute stretch is.
    final close = [p(0, 43.0, 15.0), p(10, 43.1, 15.1)];
    expect(TrackPosition.at(close, at(5)), isNotNull);
  });

  test('works with an empty track and a local DateTime', () {
    expect(TrackPosition.at(const [], at(5)), isNull);
    // The same instant given in another time zone representation.
    final local = at(5).toLocal();
    expect(TrackPosition.at(track, local)!.lat, closeTo(43.05, 1e-9));
  });

  test('a long recording is searched correctly', () {
    final long = [
      for (var i = 0; i < 600; i++)
        TrackPoint(
          id: i,
          timestamp: DateTime.utc(2026, 7, 10, 8).add(Duration(seconds: i * 30)),
          latitude: 43 + i * 0.001,
          longitude: 15 + i * 0.001,
        ),
    ];
    final pos = TrackPosition.at(long, DateTime.utc(2026, 7, 10, 8, 2, 15))!;
    // 135 s after the start is 4.5 points.
    expect(pos.lat, closeTo(43 + 4.5 * 0.001, 1e-9));
  });
}
