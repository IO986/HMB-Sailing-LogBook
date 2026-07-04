import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/miles/services/solar_calculator.dart';

void main() {
  test('equator on equinox: sunrise/sunset close to 06:00/18:00 UTC', () {
    final result = SolarCalculator.sunriseSunsetUtc(
        DateTime.utc(2026, 3, 20), 0.0, 0.0);

    expect(result.sunrise, isNotNull);
    expect(result.sunset, isNotNull);

    final sunriseMinutes = result.sunrise!.hour * 60 + result.sunrise!.minute;
    final sunsetMinutes = result.sunset!.hour * 60 + result.sunset!.minute;

    expect(sunriseMinutes, closeTo(6 * 60, 20));
    expect(sunsetMinutes, closeTo(18 * 60, 20));
  });

  test('day length roughly 12h at equator on equinox', () {
    final result = SolarCalculator.sunriseSunsetUtc(
        DateTime.utc(2026, 3, 20), 0.0, 0.0);
    final dayLength = result.sunset!.difference(result.sunrise!);
    expect(dayLength.inMinutes, closeTo(12 * 60, 20));
  });

  test('polar night: sun never rises above the Arctic circle in winter', () {
    final result = SolarCalculator.sunriseSunsetUtc(
        DateTime.utc(2026, 12, 21), 78.0, 15.0);
    expect(result.sunrise, isNull);
    expect(result.sunset, isNull);
  });

  test('sunrise is before sunset on a normal day', () {
    final result = SolarCalculator.sunriseSunsetUtc(
        DateTime.utc(2026, 7, 4), 45.0, 13.0);
    expect(result.sunrise!.isBefore(result.sunset!), isTrue);
  });
}
