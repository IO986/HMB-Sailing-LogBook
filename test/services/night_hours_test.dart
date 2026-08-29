import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/entry_conditions.dart';
import 'package:hmb_sailing_log/core/services/night_hours.dart';

void main() {
  // Biograd na Moru, mid-Adriatic — sunset in late August is around 19:20 UTC
  // (about 20:20 local), sunrise around 04:20 UTC.
  const lat = 43.94;
  const lon = 15.45;

  group('isNight', () {
    test('midday is not night', () {
      expect(NightHours.isNight(DateTime.utc(2026, 8, 27, 10), lat, lon), isFalse);
    });

    test('well after sunset is night', () {
      expect(NightHours.isNight(DateTime.utc(2026, 8, 27, 21), lat, lon), isTrue);
    });

    test('before sunrise is night', () {
      expect(NightHours.isNight(DateTime.utc(2026, 8, 27, 2), lat, lon), isTrue);
    });

    test('the same instant differs by latitude', () {
      // 23:00 UTC in late June: dark in the Adriatic, still light at Tromsø.
      final t = DateTime.utc(2026, 6, 21, 23);
      expect(NightHours.isNight(t, lat, lon), isTrue);
      // Polar day — the calculator says nothing rather than guessing.
      expect(NightHours.isNight(t, 69.65, 18.96), isFalse);
    });
  });

  group('forSamples', () {
    NightSample at(int hourUtc, int minute) => NightSample(
          timeUtc: DateTime.utc(2026, 8, 27, hourUtc, minute),
          latitude: lat,
          longitude: lon,
        );

    test('a leg counts only when both ends are dark', () {
      // 21:00 -> 21:20, both after sunset.
      expect(NightHours.forSamples([at(21, 0), at(21, 20)]),
          closeTo(1 / 3, 0.001));
      // 10:00 -> 10:20, broad daylight.
      expect(NightHours.forSamples([at(10, 0), at(10, 20)]), 0);
    });

    test('a gap longer than the cap is not sailed time', () {
      // Tracking off overnight would otherwise invent ten night hours. The
      // cap is half an hour, and it is the same half hour the mile
      // certificate uses — the two documents must never disagree.
      expect(NightHours.maxGap, const Duration(minutes: 30));
      expect(NightHours.forSamples([at(21, 0), at(21, 45)]), 0);
      expect(NightHours.forSamples([at(21, 0), at(23, 30)]), 0);
    });

    test('unordered samples give the same answer', () {
      final ordered =
          NightHours.forSamples([at(21, 0), at(21, 20), at(21, 40)]);
      final shuffled =
          NightHours.forSamples([at(21, 40), at(21, 0), at(21, 20)]);
      expect(shuffled, closeTo(ordered, 0.0001));
      expect(ordered, closeTo(2 / 3, 0.001));
    });

    test('a single sample is no time at all', () {
      expect(NightHours.forSamples([at(21, 0)]), 0);
      expect(NightHours.forSamples(const []), 0);
    });
  });

  group('weatherConditionFromCode', () {
    test('an unknown code is no claim about the sky', () {
      expect(weatherConditionFromCode(null), isNull);
    });

    test('WMO codes map to the keys the logbook prints', () {
      expect(weatherConditionFromCode(0), 'sunny');
      expect(weatherConditionFromCode(2), 'partly_cloudy');
      expect(weatherConditionFromCode(3), 'overcast');
      expect(weatherConditionFromCode(45), 'foggy');
      expect(weatherConditionFromCode(63), 'rain');
      expect(weatherConditionFromCode(95), 'thunderstorm');
      expect(weatherConditionFromCode(99), 'hail');
    });
  });
}
