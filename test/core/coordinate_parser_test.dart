import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/utils/coordinate_parser.dart';

void main() {
  double? lat(String s) => CoordinateParser.parseLatitude(s);
  double? lon(String s) => CoordinateParser.parseLongitude(s);

  group('latitude', () {
    test('decimal degrees, with comma, sign or hemisphere', () {
      expect(lat('43.5123'), closeTo(43.5123, 1e-9));
      expect(lat('43,5123'), closeTo(43.5123, 1e-9));
      expect(lat('-43.5123'), closeTo(-43.5123, 1e-9));
      expect(lat('43.5123 N'), closeTo(43.5123, 1e-9));
      expect(lat('N 43.5123'), closeTo(43.5123, 1e-9));
      expect(lat('43.5123 S'), closeTo(-43.5123, 1e-9));
      expect(lat('43.5123° n'), closeTo(43.5123, 1e-9));
    });

    test('degrees and decimal minutes, as the app itself prints them', () {
      expect(lat("43° 30.738' N"), closeTo(43 + 30.738 / 60, 1e-9));
      expect(lat('43 30.738 N'), closeTo(43 + 30.738 / 60, 1e-9));
      expect(lat("43°30,738'N"), closeTo(43 + 30.738 / 60, 1e-9));
      expect(lat("43° 30.738' S"), closeTo(-(43 + 30.738 / 60), 1e-9));
    });

    test('degrees, minutes and seconds', () {
      expect(lat('43°30\'44" N'), closeTo(43 + 30 / 60 + 44 / 3600, 1e-9));
    });

    test('values at the limits', () {
      expect(lat('90'), 90);
      expect(lat('0'), 0);
      expect(lat('-90'), -90);
    });

    test('rejects what it cannot read with certainty', () {
      expect(lat(''), isNull);
      expect(lat('   '), isNull);
      expect(lat('abc'), isNull);
      expect(lat('90.0001'), isNull);
      expect(lat("43° 60' N"), isNull); // 60 minutes
      expect(lat("43.5° 30' N"), isNull); // minutes after fractional degrees
      expect(lat('43.5 E'), isNull); // east on a latitude
      expect(lat('43.5 N N'), isNull);
      expect(lat('43.5 x'), isNull);
      expect(lat('43..5'), isNull);
      expect(lat('1 2 3 4'), isNull);
    });
  });

  group('longitude', () {
    test('hemisphere decides the sign', () {
      expect(lon('15.4410 E'), closeTo(15.441, 1e-9));
      expect(lon('15.4410 W'), closeTo(-15.441, 1e-9));
      expect(lon("15° 26.46' E"), closeTo(15 + 26.46 / 60, 1e-9));
    });

    test('goes to 180, not 90', () {
      expect(lon('179.9'), closeTo(179.9, 1e-9));
      expect(lon('180.1'), isNull);
    });

    test('rejects a north hemisphere on a longitude', () {
      expect(lon('15.4 N'), isNull);
    });
  });
}
