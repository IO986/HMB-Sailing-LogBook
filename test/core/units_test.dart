import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';

/// Distances and speeds are stored in NM and knots everywhere — the DB, the
/// tracker and the GPX export — and only the display converts. That keeps old
/// records comparable with new ones after the setting is flipped, which is the
/// whole point of having the setting rather than a second stored unit.
void main() {
  const nautical = UnitsSettings();
  const metric = UnitsSettings(
    distance: DistanceUnit.kilometers,
    speed: SpeedUnit.kmh,
  );

  group('distance', () {
    test('nautical miles are shown as they are stored', () {
      expect(nautical.formatDistance(12.5, decimals: 1), '12.5 NM');
      expect(nautical.distanceLabel, 'NM');
    });

    test('kilometres convert at 1.852', () {
      expect(metric.distanceValue(1), closeTo(1.852, 0.0001));
      expect(metric.formatDistance(10, decimals: 1), '18.5 km');
      expect(metric.distanceLabel, 'km');
    });

    test('null reads as a dash, not as zero', () {
      expect(nautical.formatDistance(null), '-');
      expect(metric.formatDistance(null), '-');
    });

    test('decimals are caller-controlled, two by default', () {
      expect(nautical.formatDistance(3.14159), '3.14 NM');
      expect(nautical.formatDistance(3.14159, decimals: 0), '3 NM');
    });
  });

  group('speed', () {
    test('knots stay knots', () {
      expect(nautical.formatSpeed(6.2), '6.2 kn');
      expect(nautical.speedLabel, 'kn');
    });

    test('km/h uses the same factor as km', () {
      expect(metric.speedValue(10), closeTo(18.52, 0.0001));
      expect(metric.formatSpeed(10), '18.5 km/h');
      expect(metric.speedLabel, 'km/h');
    });

    test('null reads as a dash', () {
      expect(metric.formatSpeed(null), '-');
    });
  });

  test('distance and speed are independent switches', () {
    // A river skipper may want km with knots, or the other way round.
    const kmWithKnots = UnitsSettings(distance: DistanceUnit.kilometers);
    expect(kmWithKnots.formatDistance(10, decimals: 1), '18.5 km');
    expect(kmWithKnots.formatSpeed(6.2), '6.2 kn');

    const nmWithKmh = UnitsSettings(speed: SpeedUnit.kmh);
    expect(nmWithKmh.formatDistance(10, decimals: 1), '10.0 NM');
    expect(nmWithKmh.formatSpeed(10), '18.5 km/h');
  });

  test('wind keeps its own unit, unaffected by the boat speed switch', () {
    // Wind is reported in knots or Beaufort even on a river.
    expect(metric.formatWind(20), '20.0 kn');
    const beaufort = UnitsSettings(
      speed: SpeedUnit.kmh,
      wind: WindUnit.beaufort,
    );
    // 20 kn is a fresh breeze - Bft 5 on the WMO knots scale.
    expect(beaufort.formatWind(20), 'Bft 5');
  });

  test('Beaufort reads the knots scale, not the km/h one', () {
    const bft = UnitsSettings(wind: WindUnit.beaufort);
    // Upper bound of each force in knots, then the first value above it.
    expect(bft.formatWind(0.5), 'Bft 0');
    expect(bft.formatWind(3), 'Bft 1');
    expect(bft.formatWind(6), 'Bft 2');
    expect(bft.formatWind(10), 'Bft 3');
    expect(bft.formatWind(16), 'Bft 4');
    expect(bft.formatWind(21), 'Bft 5');
    expect(bft.formatWind(27), 'Bft 6');
    // A gale must not be reported as a breeze - this is what was broken.
    expect(bft.formatWind(33), 'Bft 7');
    expect(bft.formatWind(40), 'Bft 8');
    expect(bft.formatWind(47), 'Bft 9');
    expect(bft.formatWind(55), 'Bft 10');
    expect(bft.formatWind(63), 'Bft 11');
    expect(bft.formatWind(64), 'Bft 12');
  });

  test('temperature label and value follow the unit', () {
    const f = UnitsSettings(temp: TempUnit.fahrenheit);
    expect(metric.tempLabel, '°C');
    expect(f.tempLabel, '°F');
    expect(metric.tempValue(20), 20);
    expect(f.tempValue(20), closeTo(68, 0.001));
    expect(f.formatTemp(20, decimals: 0), '68 °F');
    expect(metric.formatTemp(null), '-');
  });

  test('copyWith carries the other units through', () {
    final mixed = nautical
        .copyWith(distance: DistanceUnit.kilometers)
        .copyWith(temp: TempUnit.fahrenheit);

    expect(mixed.distance, DistanceUnit.kilometers);
    expect(mixed.temp, TempUnit.fahrenheit);
    expect(mixed.speed, SpeedUnit.knots, reason: 'untouched');
    expect(mixed.depth, DepthUnit.meters, reason: 'untouched');
  });
}
