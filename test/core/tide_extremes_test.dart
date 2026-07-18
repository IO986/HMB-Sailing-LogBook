import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/tide_data.dart';
import 'package:hmb_sailing_log/core/services/tide_extremes.dart';

final _epoch = DateTime.utc(2026, 7, 18);

List<TidePoint> _curve(List<double> heights, {Duration? step}) {
  final s = step ?? const Duration(hours: 1);
  return [
    for (var i = 0; i < heights.length; i++)
      TidePoint(time: _epoch.add(s * i), heightM: heights[i]),
  ];
}

void main() {
  group('findTideExtremes', () {
    test('a curve shorter than three samples has no confirmable extreme', () {
      expect(findTideExtremes(_curve([1, 2])), isEmpty);
      expect(findTideExtremes(const []), isEmpty);
    });

    test('a flat curve has no extremes', () {
      expect(findTideExtremes(_curve([2, 2, 2, 2, 2])), isEmpty);
    });

    test('a monotonic curve has no extremes', () {
      expect(findTideExtremes(_curve([1, 2, 3, 4, 5])), isEmpty);
    });

    test('classifies a peak as high and a trough as low', () {
      final result = findTideExtremes(_curve([0, 1, 3, 1, 0, -2, 0, 1]));
      expect(result.map((e) => e.extremeType), ['high', 'low']);
      expect(result.first.isHigh, isTrue);
      expect(result.last.isLow, isTrue);
    });

    test('ignores the endpoints — a peak at the edge is not confirmable', () {
      // Highest sample is the very first one; with no left neighbour it must
      // not be reported.
      final result = findTideExtremes(_curve([9, 3, 2, 1]));
      expect(result.where((e) => e.isHigh), isEmpty);
    });

    test('sorts the input by time before scanning', () {
      final shuffled = _curve([0, 1, 3, 1, 0]).reversed.toList();
      final result = findTideExtremes(shuffled);
      expect(result.single.extremeType, 'high');
      expect(result.single.time, _epoch.add(const Duration(hours: 2)));
    });

    test('a symmetric peak keeps the sample time, refined height equals it',
        () {
      final result = findTideExtremes(_curve([1, 2, 1]));
      expect(result.single.time, _epoch.add(const Duration(hours: 1)));
      expect(result.single.heightM, closeTo(2, 1e-9));
    });

    test('an asymmetric peak shifts toward the taller neighbour', () {
      // Right neighbour is higher, so the true crest lies after the sample.
      final result = findTideExtremes(_curve([0, 3, 2]));
      expect(result.single.time.isAfter(_epoch.add(const Duration(hours: 1))),
          isTrue);
      // Interpolated crest must not sit below the samples it was fitted to.
      expect(result.single.heightM, greaterThanOrEqualTo(3));
    });

    test('parabolic refinement puts a sampled sine crest within 5 minutes '
        'of the analytic one', () {
      // Semidiurnal M2-like tide: 12.4 h period, 5 m amplitude, crest at
      // exactly t = 3.1 h. Hourly samples alone would be off by up to 30 min.
      const periodHours = 12.4;
      const amplitude = 5.0;
      final heights = [
        for (var h = 0; h < 26; h++)
          amplitude * sin(2 * pi * h / periodHours),
      ];

      final result = findTideExtremes(_curve(heights));
      final firstHigh = result.firstWhere((e) => e.isHigh);

      final analyticCrest =
          _epoch.add(const Duration(minutes: 186)); // 3.1 h
      final errorMinutes = firstHigh.time
          .difference(analyticCrest)
          .inMilliseconds
          .abs() /
          60000.0;

      expect(errorMinutes, lessThan(5));
      expect(firstHigh.heightM, closeTo(amplitude, 0.05));
    });

    test('finds two highs and two lows per day in real Saint-Malo data', () {
      // Open-Meteo sea_level_height_msl, 48.65N 2.15W, 2026-07-18 UTC.
      // Saint-Malo has one of the largest tidal ranges in the world.
      final result = findTideExtremes(_curve(const [
        -1.64, -3.84, -5.45, -5.86, -4.67, -2.17, //
        0.76, 3.09, 4.20, 4.09, 3.03, 1.30, //
        -0.79, -2.88, -4.54, -5.26, -4.55, -2.47, //
        0.31, 2.78, 4.19, 4.36, 3.50, 1.90,
      ]));

      final highs = result.where((e) => e.isHigh).toList();
      final lows = result.where((e) => e.isLow).toList();
      expect(highs, hasLength(2));
      expect(lows, hasLength(2));

      // Semidiurnal: consecutive highs sit roughly 12.4 h apart.
      final spacingHours =
          highs[1].time.difference(highs[0].time).inMinutes / 60.0;
      expect(spacingHours, closeTo(12.4, 0.6));

      // Range stays in the neighbourhood of the sampled 10.2 m.
      final range = highs.map((e) => e.heightM).reduce(max) -
          lows.map((e) => e.heightM).reduce(min);
      expect(range, closeTo(10.2, 0.7));
    });

    test('honours a sampling step other than one hour', () {
      final result = findTideExtremes(
        _curve([0, 3, 2], step: const Duration(minutes: 30)),
      );
      final offset =
          result.single.time.difference(_epoch).inMinutes;
      // Crest sits between the 30 min and 60 min samples.
      expect(offset, inInclusiveRange(30, 60));
    });
  });
}
