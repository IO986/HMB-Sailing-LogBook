import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/point_of_sail.dart';

void main() {
  group('PointOfSail codes', () {
    test('round-trip through the stored code', () {
      for (final p in PointOfSail.values) {
        expect(PointOfSail.fromCode(p.code), p);
      }
    });

    test('unknown or empty code reads as not recorded', () {
      expect(PointOfSail.fromCode(null), isNull);
      expect(PointOfSail.fromCode(''), isNull);
      expect(PointOfSail.fromCode('beam'), isNull);
    });
  });

  group('Tack', () {
    test('accepts the paper form letters, in any case', () {
      expect(Tack.fromCode('S'), Tack.starboard);
      expect(Tack.fromCode('p'), Tack.port);
      expect(Tack.fromCode(' S '), Tack.starboard);
      expect(Tack.fromCode('X'), isNull);
    });

    test('opposite flips the side', () {
      expect(Tack.starboard.opposite, Tack.port);
      expect(Tack.port.opposite, Tack.starboard);
    });
  });

  group('SailDirection.fromCodes', () {
    test('keeps the tack for a sided course', () {
      final d = SailDirection.fromCodes('beam_reach', 'S');
      expect(d, const SailDirection(PointOfSail.beamReach, Tack.starboard));
    });

    test('drops the tack when running — dead astern has no side', () {
      final d = SailDirection.fromCodes('running', 'P');
      expect(d, const SailDirection(PointOfSail.running, null));
      expect(d!.tack, isNull);
    });

    test('no course means no record, whatever the tack column holds', () {
      expect(SailDirection.fromCodes(null, 'S'), isNull);
      expect(SailDirection.fromCodes('', 'S'), isNull);
    });

    test('a sided course with no tack stays half-filled, not guessed', () {
      final d = SailDirection.fromCodes('close_hauled', null);
      expect(d, const SailDirection(PointOfSail.closeHauled, null));
    });
  });
}
