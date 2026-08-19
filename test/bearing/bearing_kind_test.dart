import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';

void main() {
  group('kódy', () {
    test('kód prežije okrúhlu cestu', () {
      for (final kind in BearingKind.values) {
        expect(BearingKind.fromCode(kind.code), kind);
      }
    });

    test('neznámy, prázdny a chýbajúci kód dá null', () {
      expect(BearingKind.fromCode('triangulacia'), isNull);
      expect(BearingKind.fromCode(''), isNull);
      expect(BearingKind.fromCode(null), isNull);
    });

    test('kódy sú stabilné reťazce, na ktoré sa smie spoliehať databáza', () {
      // Zmena týchto hodnôt osirotí už uložené riadky.
      expect(BearingKind.resection.code, 'resection');
      expect(BearingKind.intersection.code, 'intersection');
    });
  });

  group('lineBearing', () {
    test('pri hľadaní objektu sa kreslí nameraným kurzom', () {
      expect(BearingKind.intersection.lineBearing(90), 90);
      expect(BearingKind.intersection.lineBearing(0), 0);
      expect(BearingKind.intersection.lineBearing(359), 359);
    });

    test('pri hľadaní vlastnej polohy sa kreslí opačným kurzom', () {
      // Maják vidím na 090°, teda ja som od majáka na 270°.
      expect(BearingKind.resection.lineBearing(90), 270);
      expect(BearingKind.resection.lineBearing(270), 90);
    });

    test('opačný kurz sa zloží do 0–360', () {
      expect(BearingKind.resection.lineBearing(200), 20);
      expect(BearingKind.resection.lineBearing(359), 179);
      expect(BearingKind.resection.lineBearing(180), 0);
      expect(BearingKind.resection.lineBearing(360), 180);
    });

    test('dvojnásobné otočenie vráti pôvodný kurz', () {
      for (final measured in [0.0, 37.5, 90.0, 183.2, 275.0, 359.9]) {
        final there = BearingKind.resection.lineBearing(measured);
        final back = BearingKind.resection.lineBearing(there);
        expect(back, closeTo(measured % 360, 1e-9), reason: '$measured');
      }
    });
  });

  group('čo ktorý druh potrebuje', () {
    test('hľadanie objektu potrebuje GPS, hľadanie seba nie', () {
      expect(BearingKind.intersection.needsObserverPosition, isTrue);
      // Toto je celý zmysel resekcie: funguje, keď GPS padne.
      expect(BearingKind.resection.needsObserverPosition, isFalse);
    });

    test('hľadanie seba potrebuje vybraný známy bod, hľadanie objektu nie',
        () {
      expect(BearingKind.resection.needsKnownTarget, isTrue);
      expect(BearingKind.intersection.needsKnownTarget, isFalse);
    });

    test('žiadny druh nepotrebuje oboje ani nič', () {
      // Keby bol taký druh, nemal by čo počítať — alebo by nemal vstup.
      for (final kind in BearingKind.values) {
        expect(kind.needsObserverPosition && kind.needsKnownTarget, isFalse,
            reason: kind.code);
        expect(kind.needsObserverPosition || kind.needsKnownTarget, isTrue,
            reason: kind.code);
      }
    });
  });
}
