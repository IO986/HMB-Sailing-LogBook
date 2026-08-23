import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/dhmz_observation_parser.dart';

String _fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  group('parseNumber', () {
    test('a dash means missing, not zero', () {
      // Zásadné: nula je platná teplota aj platný tlak. Keby sa `-` čítalo
      // ako 0, do denníka by sa zapísala vymyslená hodnota.
      expect(DhmzObservationParser.parseNumber('-'), isNull);
      expect(DhmzObservationParser.parseNumber(''), isNull);
      expect(DhmzObservationParser.parseNumber(null), isNull);
      expect(DhmzObservationParser.parseNumber('  '), isNull);
    });

    test('reads the shapes the feed actually uses', () {
      expect(DhmzObservationParser.parseNumber(' 14.8'), 14.8);
      expect(DhmzObservationParser.parseNumber('+0.5'), 0.5);
      expect(DhmzObservationParser.parseNumber('-0.4'), -0.4);
      expect(DhmzObservationParser.parseNumber('1020,7'), 1020.7);
    });

    test('nonsense is missing, not an exception', () {
      expect(DhmzObservationParser.parseNumber('jugo'), isNull);
    });
  });

  group('windDirectionToDegrees', () {
    test('maps the sixteen compass points', () {
      expect(DhmzObservationParser.windDirectionToDegrees('N'), 0);
      expect(DhmzObservationParser.windDirectionToDegrees('NE'), 45);
      expect(DhmzObservationParser.windDirectionToDegrees('E'), 90);
      expect(DhmzObservationParser.windDirectionToDegrees('SSW'), 202.5);
      expect(DhmzObservationParser.windDirectionToDegrees('W'), 270);
      expect(DhmzObservationParser.windDirectionToDegrees('nw'), 315);
    });

    test('calm has no direction', () {
      // 'C' je bezvetrie. Vrátiť 0° by znamenalo zapísať do denníka severný
      // vietor tam, kde nefúka nič.
      expect(DhmzObservationParser.windDirectionToDegrees('C'), isNull);
      expect(DhmzObservationParser.windDirectionToDegrees('-'), isNull);
      expect(DhmzObservationParser.windDirectionToDegrees(null), isNull);
      expect(DhmzObservationParser.windDirectionToDegrees('XYZ'), isNull);
    });
  });

  group('parseObservedAt', () {
    test('August is summer time, so 06:00 local is 04:00 UTC', () {
      final t = DhmzObservationParser.parseObservedAt('23.08.2026', '06');
      expect(t, isNotNull);
      expect(t!.isUtc, isTrue);
      expect(t.hour, 4);
      expect(t.day, 23);
    });

    test('January is winter time, so 06:00 local is 05:00 UTC', () {
      final t = DhmzObservationParser.parseObservedAt('15.01.2026', '06');
      expect(t!.hour, 5);
    });

    test('a broken date is null, not a crash', () {
      expect(DhmzObservationParser.parseObservedAt('nonsense', '06'), isNull);
      expect(DhmzObservationParser.parseObservedAt(null, '06'), isNull);
    });
  });

  group('parseLandStations on the real feed', () {
    late List<DhmzStationReading> stations;

    setUpAll(() {
      stations =
          DhmzObservationParser.parseLandStations(_fixture('dhmz_hrvatska_n.xml'));
    });

    test('reads the whole station list with coordinates', () {
      expect(stations.length, greaterThan(40));
      expect(stations.every((s) => s.station.isNotEmpty), isTrue);
      expect(stations.every((s) => s.latitude > 40 && s.latitude < 47), isTrue);
      expect(stations.every((s) => s.longitude > 12 && s.longitude < 20), isTrue);
    });

    test('wind is converted from m/s to knots', () {
      // Feed publikuje m/s. Keby sa hodnota vzala ako uzly, do denníka by
      // šiel vietor takmer o polovicu slabší, než aký naozaj bol.
      final withWind =
          stations.where((s) => s.windSpeedKnots != null).toList();
      expect(withWind, isNotEmpty);
      // 10,8 m/s je najsilnejší vietor v tomto behu -> ~21 kn. Nič v ňom
      // nesmie vyzerať ako desiatky uzlov navyše.
      expect(withWind.map((s) => s.windSpeedKnots!).reduce((a, b) => a > b ? a : b),
          lessThan(60));
      final maxMs = withWind
          .map((s) => s.windSpeedKnots! / 1.94384)
          .reduce((a, b) => a > b ? a : b);
      expect(maxMs, lessThan(40));
    });

    test('every station carries the same observation time, in UTC', () {
      expect(stations.every((s) => s.observedAt.isUtc), isTrue);
      expect(stations.map((s) => s.observedAt).toSet().length, 1);
    });

    test('stations with nothing to say are dropped', () {
      // Prázdna stanica by mohla vyhrať výber "najbližšia" a pripraviť
      // záznam aj o modelové hodnoty.
      expect(stations.every((s) => s.hasAnyValue), isTrue);
    });

    test('a garbage body yields nothing rather than throwing', () {
      expect(DhmzObservationParser.parseLandStations('not xml at all'), isEmpty);
      expect(DhmzObservationParser.parseLandStations(''), isEmpty);
      expect(DhmzObservationParser.parseLandStations('<Hrvatska></Hrvatska>'),
          isEmpty);
    });
  });

  group('parseSeaTemperatures', () {
    test('takes the last reading of the day per station', () {
      final sea =
          DhmzObservationParser.parseSeaTemperatures(_fixture('dhmz_more_n_populated.xml'));
      // Neskoršie terminy bývajú prázdne, takže "posledný" musí znamenať
      // poslednú NEPRÁZDNU hodnotu, nie posledný uzol.
      expect(sea['Božava'], 26.2);
      expect(sea['Crikvenica'], 25.0);
      expect(sea['Dubrovnik'], 27.7);
      expect(sea['Split'], 26.9);
    });

    test('the header row is not a station', () {
      final sea =
          DhmzObservationParser.parseSeaTemperatures(_fixture('dhmz_more_n_populated.xml'));
      expect(sea.keys.any((k) => k.contains('Termin mjerenja')), isFalse);
    });

    test('an early morning feed with no values yet is simply empty', () {
      // Reálny stav feedu o 07:11 — stanice sú vypísané, hodnoty ešte nie.
      final sea =
          DhmzObservationParser.parseSeaTemperatures(_fixture('dhmz_more_n.xml'));
      expect(sea, isEmpty);
    });

    test('a garbage body yields nothing rather than throwing', () {
      expect(DhmzObservationParser.parseSeaTemperatures('nope'), isEmpty);
    });
  });
}
