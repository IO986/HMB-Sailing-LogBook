import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/nmea_parser_service.dart';

/// Vypočíta NMEA checksum (XOR všetkých znakov medzi `$` a `*`) a vráti
/// kompletnú vetu s `*HH` príponou – rovnaký algoritmus ako
/// NmeaParserService._checksum, ale nezávisle reimplementovaný, aby test
/// overoval skutočné správanie, nie len zhodu s vlastnou implementáciou.
String _withChecksum(String body) {
  var cs = 0;
  for (final code in body.codeUnits) {
    cs ^= code;
  }
  return '\$$body*${cs.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

void main() {
  final parser = NmeaParserService();

  group('RMC', () {
    test('parses a valid reference sentence (well-known example)', () {
      final result = parser.parseLine(
          r'$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A');
      expect(result, isNotNull);
      expect(result!.fix, isNotNull);
      expect(result.fix!.valid, isTrue);
      expect(result.fix!.latitude, closeTo(48.1173, 0.001));
      expect(result.fix!.longitude, closeTo(11.5167, 0.001));
      expect(result.fix!.speedKnots, 22.4);
      expect(result.fix!.courseDegrees, 84.4);
      // Parser predpokladá 2000+yy pre 2-ciferný rok (rozumné pre modernú
      // appku) - historický Wikipedia príklad je z roku 1994, ale reálne
      // sa vyparsuje ako 2094.
      expect(result.fix!.timestampUtc, DateTime.utc(2094, 3, 23, 12, 35, 19));
    });

    test('southern/western hemisphere flips sign', () {
      final line = _withChecksum('GPRMC,123519,A,4807.038,S,01131.000,W,0,0,230394,,');
      final result = parser.parseLine(line);
      expect(result!.fix!.latitude, lessThan(0));
      expect(result.fix!.longitude, lessThan(0));
    });

    test('empty lat/lon fields yield a null-position, invalid fix (not a crash)', () {
      final line = _withChecksum('GPRMC,123519,V,,,,,,,230394,,');
      final result = parser.parseLine(line);
      expect(result, isNotNull);
      expect(result!.fix!.valid, isFalse);
      expect(result.fix!.latitude, isNull);
      expect(result.fix!.longitude, isNull);
    });

    test('too few fields is treated as incomplete and discarded', () {
      final line = _withChecksum('GPRMC,123519,A');
      expect(parser.parseLine(line), isNull);
    });
  });

  group('GGA', () {
    test('parses a valid reference sentence (well-known example)', () {
      final result = parser.parseLine(
          r'$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47');
      expect(result!.fix!.valid, isTrue);
      expect(result.fix!.latitude, closeTo(48.1173, 0.001));
      expect(result.fix!.longitude, closeTo(11.5167, 0.001));
    });

    test('fix quality 0 (no fix) marks the result invalid', () {
      final line = _withChecksum('GPGGA,123519,4807.038,N,01131.000,E,0,00,,,M,,M,,');
      final result = parser.parseLine(line);
      expect(result!.fix!.valid, isFalse);
    });
  });

  group('VTG', () {
    test('parses course and speed', () {
      final line = _withChecksum('GPVTG,054.7,T,034.4,M,005.5,N,010.2,K');
      final result = parser.parseLine(line);
      expect(result!.fix!.courseDegrees, 54.7);
      expect(result.fix!.speedKnots, 5.5);
      expect(result.fix!.valid, isTrue);
    });
  });

  group('MWV (wind)', () {
    test('relative wind in knots passes through unchanged', () {
      final line = _withChecksum('IIMWV,045.0,R,12.5,N,A');
      final result = parser.parseLine(line);
      expect(result!.wind!.angleDegrees, 45.0);
      expect(result.wind!.speedKnots, 12.5);
      expect(result.wind!.isApparent, isTrue);
    });

    test('true wind reported in m/s is converted to knots', () {
      final line = _withChecksum('IIMWV,090.0,T,10.0,M,A');
      final result = parser.parseLine(line);
      expect(result!.wind!.speedKnots, closeTo(19.4384, 0.01));
      expect(result.wind!.isApparent, isFalse);
    });

    test('wind reported in km/h is converted to knots', () {
      final line = _withChecksum('IIMWV,090.0,R,36.0,K,A');
      final result = parser.parseLine(line);
      expect(result!.wind!.speedKnots, closeTo(19.4384, 0.05));
    });
  });

  group('DBT / DPT (depth)', () {
    test('DBT reads the metres field', () {
      final line = _withChecksum('IIDBT,8.2,f,2.5,M,4.6,F');
      final result = parser.parseLine(line);
      expect(result!.depth!.depthMeters, 2.5);
    });

    test('DPT adds transducer offset to depth', () {
      final line = _withChecksum('IIDPT,2.5,0.5,');
      final result = parser.parseLine(line);
      expect(result!.depth!.depthMeters, 3.0);
    });

    test('DBT without a depth value is discarded, not crashed on', () {
      final line = _withChecksum('IIDBT,,f,,M,,F');
      expect(parser.parseLine(line), isNull);
    });
  });

  group('HDG / HDT (heading)', () {
    test('HDG is reported as magnetic (isTrue=false)', () {
      final line = _withChecksum('IIHDG,123.4,,,,');
      final result = parser.parseLine(line);
      expect(result!.heading!.degrees, 123.4);
      expect(result.heading!.isTrue, isFalse);
    });

    test('HDT is reported as true (isTrue=true)', () {
      final line = _withChecksum('IIHDT,125.0,T');
      final result = parser.parseLine(line);
      expect(result!.heading!.degrees, 125.0);
      expect(result.heading!.isTrue, isTrue);
    });
  });

  group('Checksum validation', () {
    test('valid checksum is accepted', () {
      final line = _withChecksum('IIHDT,125.0,T');
      expect(parser.parseLine(line), isNotNull);
    });

    test('invalid checksum is rejected outright, even for otherwise valid fields', () {
      final good = _withChecksum('IIHDT,125.0,T');
      final tampered = '${good.substring(0, good.length - 2)}FF';
      expect(parser.parseLine(tampered), isNull);
    });

    test('sentence without a checksum at all is still parsed', () {
      expect(parser.parseLine('\$IIHDT,125.0,T'), isNotNull);
    });
  });

  group('Malformed / edge-case input', () {
    test('empty line is discarded', () {
      expect(parser.parseLine(''), isNull);
    });

    test('line without a leading \$ is discarded', () {
      expect(parser.parseLine('IIHDT,125.0,T*00'), isNull);
    });

    test('unrecognized sentence type is discarded', () {
      final line = _withChecksum('GPZZZ,1,2,3');
      expect(parser.parseLine(line), isNull);
    });

    test('trailing CR (CRLF source) does not break parsing', () {
      final line = '${_withChecksum('IIHDT,125.0,T')}\r';
      expect(parser.parseLine(line), isNotNull);
    });

    test('multiple sentences in one datagram/block are each parsed independently', () {
      final block = [
        _withChecksum('IIHDT,125.0,T'),
        _withChecksum('IIDPT,2.5,0.5,'),
        _withChecksum('IIMWV,045.0,R,12.5,N,A'),
      ].join('\r\n');

      final results = block
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .map(parser.parseLine)
          .toList();

      expect(results, hasLength(3));
      expect(results[0]!.heading, isNotNull);
      expect(results[1]!.depth, isNotNull);
      expect(results[2]!.wind, isNotNull);
    });
  });

  group('autopilot', () {
    test('HTC v režime track hlási zapnutý pilot', () {
      final r = parser.parseLine(
          _withChecksum('APHTC,A,0.0,V,T,,,,,,,,,'));
      expect(r!.autopilot!.engaged, isTrue);
      expect(r.autopilot!.mode, 'track');
    });

    test('HTC v manuáli hlási standby', () {
      final r = parser.parseLine(
          _withChecksum('APHTC,V,0.0,V,M,,,,,,,,,'));
      expect(r!.autopilot!.engaged, isFalse);
      expect(r.autopilot!.mode, 'standby');
    });

    test('APB s platnou navigáciou znamená riadenie po trase', () {
      final r = parser.parseLine(_withChecksum(
          'APAPB,A,A,0.10,R,N,V,V,011,M,DEST,011,M,011,M'));
      expect(r!.autopilot!.engaged, isTrue);
      expect(r.autopilot!.mode, 'track');
    });

    test('APB s neplatnou navigáciou nie je zapnutý pilot', () {
      final r = parser.parseLine(_withChecksum(
          'APAPB,V,V,0.10,R,N,V,V,011,M,DEST,011,M,011,M'));
      expect(r!.autopilot!.engaged, isFalse);
    });

    test('SeaTalk 0x84: bit vetra = pilot vo vetrovom režime', () {
      final r = parser.parseLine(_withChecksum('STALK,84,06,26,97,04,00,00,00,08'));
      expect(r!.autopilot!.engaged, isTrue);
      expect(r.autopilot!.mode, 'wind');
    });

    test('SeaTalk 0x84: nulový režim = standby', () {
      final r = parser.parseLine(_withChecksum('STALK,84,06,26,97,00,00,00,00,08'));
      expect(r!.autopilot!.engaged, isFalse);
      expect(r.autopilot!.mode, 'standby');
    });

    test('iný SeaTalk datagram sa neinterpretuje ako autopilot', () {
      expect(parser.parseLine(_withChecksum('STALK,00,02,00,00')), isNull);
    });
  });

  group('engine', () {
    test('RPM veta nesie otáčky', () {
      final r = parser.parseLine(_withChecksum('ERRPM,E,1,1850.0,10.5,A'));
      expect(r!.engine!.rpm, 1850.0);
    });
  });
}
