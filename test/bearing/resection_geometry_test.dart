import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/bearing/services/bearing_geometry.dart';
import 'package:latlong2/latlong.dart';

/// Resekcia: poznám body na mape, hľadám seba.
///
/// Inverzná úloha k `bearing_geometry_test.dart`, ktorý zo známych polôh
/// pozorovateľa hľadá zameraný objekt. Tu sa vie, kde sú majáky, a hľadá sa
/// loď. Oba súbory vedľa seba sú najlepší opis toho, čím sa dva režimy
/// námerového kompasu líšia.
void main() {
  const split = LatLng(43.5081, 16.4402);

  double metres(LatLng a, LatLng b) => const Distance().distance(a, b);

  /// Kurz, ktorý by skiper z [from] na [to] naozaj odčítal (0–360).
  ///
  /// `Distance().bearing()` vracia -180..180, takže sa musí normalizovať —
  /// inak by testy pracovali s číslami, aké z kompasu nikdy neprídu.
  double measured(LatLng from, LatLng to) =>
      (const Distance().bearing(from, to) + 360) % 360;

  /// Zámerné priamky tak, ako ich postaví appka: zo známych bodov, opačným
  /// kurzom, než skiper odčítal.
  List<BearingLine> sightsFrom(
    LatLng observer,
    List<LatLng> marks, {
    double uncertainty = 8,
    double bearingError = 0,
  }) =>
      [
        for (final mark in marks)
          BearingGeometry.lineFor(
            kind: BearingKind.resection,
            knownPoint: mark,
            measuredTrueBearing:
                (measured(observer, mark) + bearingError + 360) % 360,
            uncertaintyDeg: uncertainty,
          ),
      ];

  BearingFix? resect(List<BearingLine> lines) =>
      BearingGeometry.fix(lines, kind: BearingKind.resection);

  group('lineFor', () {
    test('resekčná priamka vychádza zo zameraného bodu, nie z lode', () {
      const mark = LatLng(43.06, 16.25);
      final line = BearingGeometry.lineFor(
        kind: BearingKind.resection,
        knownPoint: mark,
        measuredTrueBearing: 90,
      );
      expect(line.origin, mark);
      // Maják vidím na východ, teda ja som od majáka na západ.
      expect(line.trueBearing, closeTo(270, 1e-9));
    });

    test('dopredná priamka vychádza z pozorovateľa nameraným kurzom', () {
      final line = BearingGeometry.lineFor(
        kind: BearingKind.intersection,
        knownPoint: split,
        measuredTrueBearing: 90,
      );
      expect(line.origin, split);
      expect(line.trueBearing, closeTo(90, 1e-9));
    });
  });

  group('nájdenie vlastnej polohy', () {
    test('dva známe body vrátia skutočnú polohu pozorovateľa', () {
      // Kolmý rez: jeden bod na juh, druhý na západ.
      final marks = [
        BearingGeometry.destination(split, 0, 4),
        BearingGeometry.destination(split, 90, 4),
      ];
      final fix = resect(sightsFrom(split, marks))!;

      expect(fix.kind, BearingKind.resection);
      expect(fix.isOwnPosition, isTrue);
      expect(metres(fix.position, split), lessThan(60));
    });

    test('tri známe body dajú trojuholník chyby a stále sedia', () {
      final marks = [
        BearingGeometry.destination(split, 10, 5),
        BearingGeometry.destination(split, 130, 4),
        BearingGeometry.destination(split, 250, 6),
      ];
      final fix = resect(sightsFrom(split, marks))!;

      expect(fix.bearingCount, 3);
      expect(fix.intersections, hasLength(3));
      expect(metres(fix.position, split), lessThan(80));
    });

    test('funguje aj keď je loď medzi bodmi, nie pod nimi', () {
      // Klasická situácia v kanáli: maják vpredu, mys vzadu, ostrov bokom.
      final marks = [
        BearingGeometry.destination(split, 0, 3),
        BearingGeometry.destination(split, 180, 3),
        BearingGeometry.destination(split, 95, 2),
      ];
      final fix = resect(sightsFrom(split, marks))!;
      expect(metres(fix.position, split), lessThan(80));
    });

    test('jediný známy bod polohu nedá', () {
      final marks = [BearingGeometry.destination(split, 45, 4)];
      expect(resect(sightsFrom(split, marks)), isNull);
    });
  });

  group('kvalita fixu', () {
    test('kolmý rez je silný, ostrý slabý', () {
      final sharp = resect(sightsFrom(split, [
        BearingGeometry.destination(split, 0, 4),
        BearingGeometry.destination(split, 90, 4),
      ]))!;
      final shallow = resect(sightsFrom(split, [
        BearingGeometry.destination(split, 0, 4),
        BearingGeometry.destination(split, 12, 4),
      ]))!;

      expect(sharp.isWeak, isFalse);
      expect(shallow.isWeak, isTrue);
      expect(shallow.errorRadiusMeters,
          greaterThan(sharp.errorRadiusMeters * 2));
    });

    test('vzdialenejšie body dajú väčšiu chybu pri tej istej neistote', () {
      final near = resect(sightsFrom(split, [
        BearingGeometry.destination(split, 0, 1),
        BearingGeometry.destination(split, 90, 1),
      ]))!;
      final far = resect(sightsFrom(split, [
        BearingGeometry.destination(split, 0, 8),
        BearingGeometry.destination(split, 90, 8),
      ]))!;
      // Rameno páky: ±8° na 8 NM je osemkrát horšie než na 1 NM.
      expect(far.errorRadiusMeters, greaterThan(near.errorRadiusMeters * 4));
    });

    test('chyba fixu zodpovedá ±8° na danú vzdialenosť', () {
      // 4 NM a ±8° dá naprieč asi 0,56 NM ≈ 1040 m; pri kolmom reze z dvoch
      // bodov je výsledný polomer okolo 1,4-násobku. Test drží poriadok
      // veľkosti, nie presné číslo — ide o to, aby appka netvrdila metre.
      final fix = resect(sightsFrom(split, [
        BearingGeometry.destination(split, 0, 4),
        BearingGeometry.destination(split, 90, 4),
      ]))!;
      expect(fix.errorRadiusMeters, greaterThan(800));
      expect(fix.errorRadiusMeters, lessThan(2500));
    });

    test('presnejší kompas zmenší chybu, polohu nezmení', () {
      final marks = [
        BearingGeometry.destination(split, 0, 4),
        BearingGeometry.destination(split, 90, 4),
      ];
      final rough = resect(sightsFrom(split, marks, uncertainty: 8))!;
      final fine = resect(sightsFrom(split, marks, uncertainty: 1))!;

      expect(fine.errorRadiusMeters, lessThan(rough.errorRadiusMeters / 4));
      expect(metres(fine.position, rough.position), lessThan(1));
    });
  });

  group('chybné odčítania', () {
    test('kurz otočený o 180° nevyrobí falošnú polohu', () {
      // Klasický omyl: skiper odčíta reciproký kurz z ružice. Priamky potom
      // z bodov utekajú opačným smerom a ich riešenie leží za nimi, takže
      // ho polpriamková podmienka zahodí. Radšej žiadna poloha než tichom
      // vymyslená.
      final marks = [
        BearingGeometry.destination(split, 0, 4),
        BearingGeometry.destination(split, 90, 4),
      ];
      expect(resect(sightsFrom(split, marks, bearingError: 180)), isNull);
    });

    test('dva námery na ten istý bod polohu nedajú', () {
      final mark = BearingGeometry.destination(split, 45, 4);
      // Obe priamky vychádzajú z toho istého miesta — z jedného bodu sa
      // vytriangulovať nedá, aj keby uhly zvierali čokoľvek.
      expect(resect(sightsFrom(split, [mark, mark])), isNull);
    });

    test('malá chyba kurzu polohu posunie, nezničí', () {
      final marks = [
        BearingGeometry.destination(split, 0, 4),
        BearingGeometry.destination(split, 90, 4),
      ];
      final fix = resect(sightsFrom(split, marks, bearingError: 3))!;
      // 3° na 4 NM je zhruba 390 m naprieč; výsledok sa má posunúť približne
      // o toľko, nie odletieť.
      final off = metres(fix.position, split);
      expect(off, greaterThan(100));
      expect(off, lessThan(1200));
    });
  });

  group('kužeľ resekcie', () {
    test('rozširuje sa od zameraného bodu smerom k lodi', () {
      const mark = LatLng(43.06, 16.25);
      final line = BearingGeometry.lineFor(
        kind: BearingKind.resection,
        knownPoint: mark,
        measuredTrueBearing: 0,
        uncertaintyDeg: 8,
      );
      final near = BearingGeometry.cone(line, 1);
      final far = BearingGeometry.cone(line, 5);

      // Vrchol je na majáku, takže bližšie k nemu je kužeľ užší.
      expect(metres(near.left, near.right),
          lessThan(metres(far.left, far.right)));
      // A obe hrany vychádzajú z toho istého bodu na mape.
      expect(line.origin, mark);
    });
  });
}
