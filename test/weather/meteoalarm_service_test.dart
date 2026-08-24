import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/meteoalarm_service.dart';

String _fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();

void main() {
  group('awarenessLevelFor', () {
    test('farba v názve rozhoduje', () {
      expect(MeteoAlarmService.awarenessLevelFor('Red wind warning', null), 4);
      expect(
          MeteoAlarmService.awarenessLevelFor('Orange rain warning', null), 3);
      expect(
          MeteoAlarmService.awarenessLevelFor('Yellow thunderstorm warning',
              null),
          2);
    });

    test('bez farby rozhodne vážnosť', () {
      expect(MeteoAlarmService.awarenessLevelFor('Wind warning', 'Extreme'), 4);
      expect(MeteoAlarmService.awarenessLevelFor('Wind warning', 'Severe'), 3);
      expect(MeteoAlarmService.awarenessLevelFor('Wind warning', 'Minor'), 1);
    });

    test('neznáma vážnosť nepadá na najhorší ani najlepší stupeň', () {
      // Vymyslieť červenú by strašilo, vymyslieť zelenú by uspávalo.
      expect(MeteoAlarmService.awarenessLevelFor('Wind warning', null), 2);
      expect(MeteoAlarmService.awarenessLevelFor('Wind warning', 'nonsense'), 2);
    });
  });

  group('parseFeed na skutočnom chorvátskom feede', () {
    test('rozparsuje výstrahy aj s platnosťou', () {
      final items =
          MeteoAlarmService.parseFeed(_fixture('meteoalarm_croatia.xml'));

      expect(items, isNotEmpty);
      final first = items.first;
      expect(first.identifier, isNotEmpty);
      expect(first.event, isNotEmpty);
      expect(first.areaDesc, isNotEmpty);
      expect(first.expires.isAfter(first.onset), isTrue);
      expect(first.onset.isUtc, isTrue);
      expect(first.awarenessLevel, inInclusiveRange(1, 4));
      // Odkaz na podrobný CAP dokument je to, čo umožní text v jazyku appky.
      expect(first.capUrl, contains('meteoalarm.org'));
    });

    test('nezmyselné telo nevyhodí výnimku', () {
      expect(MeteoAlarmService.parseFeed('<html>nope'), isEmpty);
      expect(MeteoAlarmService.parseFeed(''), isEmpty);
    });

    test('položka bez času platnosti sa zahodí', () {
      // Výstraha, o ktorej sa nedá povedať dokedy platí, je na mori
      // nepoužiteľná — a zobraziť ju navždy je horšie než nezobraziť nič.
      const xml = '''
<feed xmlns="http://www.w3.org/2005/Atom"
      xmlns:cap="urn:oasis:names:tc:emergency:cap:1.2">
  <entry>
    <cap:identifier>x1</cap:identifier>
    <cap:event>Yellow wind warning</cap:event>
    <cap:areaDesc>Coastal</cap:areaDesc>
    <cap:onset>2026-08-24T10:00:00+00:00</cap:onset>
  </entry>
</feed>''';
      expect(MeteoAlarmService.parseFeed(xml), isEmpty);
    });
  });

  group('parseDetail', () {
    test('vyberie blok v jazyku appky', () {
      final d =
          MeteoAlarmService.parseDetail(_fixture('meteoalarm_cap.xml'), 'hr');

      expect(d, isNotNull);
      expect(d!.language, startsWith('hr'));
      expect(d.description, isNotEmpty);
      expect(d.sender, contains('DHMZ'));
    });

    test('bez zhody jazyka padne na angličtinu', () {
      // Slovenčinu chorvátsky feed nemá; anglický blok tam je vždy.
      final d =
          MeteoAlarmService.parseDetail(_fixture('meteoalarm_cap.xml'), 'sk');

      expect(d!.language, startsWith('en'));
      expect(d.instruction, isNotEmpty);
    });

    test('nezmyselné telo vráti null', () {
      expect(MeteoAlarmService.parseDetail('not xml', 'en'), isNull);
    });
  });
}
