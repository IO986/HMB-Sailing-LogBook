import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/bearing/services/bearing_geometry.dart';
import 'package:latlong2/latlong.dart';

/// Vzdialenosť v metroch, na overovanie výsledkov.
double _metres(LatLng a, LatLng b) => const Distance().distance(a, b);

void main() {
  // Stredný Jadran, aby čísla zodpovedali reálnemu použitiu.
  const split = LatLng(43.5081, 16.4402);

  group('destination', () {
    test('sever posunie zemepisnú šírku a nechá dĺžku na mieste', () {
      final p = BearingGeometry.destination(split, 0, 1);
      expect(p.latitude, greaterThan(split.latitude));
      expect(p.longitude, closeTo(split.longitude, 1e-9));
      // 1 NM na sever je z definície 1 uhlová minúta šírky.
      expect((p.latitude - split.latitude) * 60, closeTo(1.0, 0.01));
    });

    test('východ posunie dĺžku a nechá šírku na mieste', () {
      final p = BearingGeometry.destination(split, 90, 1);
      expect(p.longitude, greaterThan(split.longitude));
      expect(p.latitude, closeTo(split.latitude, 1e-4));
    });

    test('vzdialenosť sedí na zadaný počet míľ', () {
      // Projekcia počíta na guli s R = 6371 km, rovnako ako
      // DistanceCalculator, ktorým appka meria najazdené míle. Referenčná
      // Distance() z latlong2 je elipsoidálna, takže sa na 5 NM rozchádzajú
      // asi o 0,2 % — to je rozdiel modelov, nie chyba projekcie.
      for (final bearing in [0.0, 45.0, 137.0, 250.0, 359.0]) {
        final p = BearingGeometry.destination(split, bearing, 5);
        expect(_metres(split, p), closeTo(5 * 1852, 5 * 1852 * 0.003),
            reason: 'kurz $bearing');
      }
    });

    test('kurz 360 a kurz 0 dávajú ten istý bod', () {
      final a = BearingGeometry.destination(split, 0, 3);
      final b = BearingGeometry.destination(split, 360, 3);
      expect(_metres(a, b), lessThan(0.5));
    });
  });

  group('cone', () {
    test('hrany ležia symetricky okolo osi', () {
      const line = BearingLine(
          origin: split, trueBearing: 90, uncertaintyDeg: 8);
      final c = BearingGeometry.cone(line, 5);
      final leftGap = _metres(c.centre, c.left);
      final rightGap = _metres(c.centre, c.right);
      expect(leftGap, closeTo(rightGap, 1));
      // Na 5 NM je ±8° zhruba 0,7 NM na každú stranu — to je ten dôvod,
      // prečo sa kreslí kužeľ a nie čiara.
      expect(leftGap, closeTo(5 * 1852 * 0.1405, 60));
    });
  });

  group('intersection', () {
    test('dve kolmé zamerania sa pretnú tam, kde majú', () {
      // Pozorovateľ A juhozápadne mieri na severovýchod, pozorovateľ B
      // juhovýchodne mieri na severozápad. Stretnú sa nad nimi.
      final target = BearingGeometry.destination(split, 45, 3);
      const a = BearingLine(origin: split, trueBearing: 45);
      final bObserver = BearingGeometry.destination(split, 90, 2);
      final b = BearingLine(
        origin: bObserver,
        trueBearing:
            (const Distance().bearing(bObserver, target) + 360) % 360,
      );

      final hit = BearingGeometry.intersection(a, b);
      expect(hit, isNotNull);
      expect(_metres(hit!, target), lessThan(30));
    });

    test('rovnobežné zamerania nemajú priesečník', () {
      const a = BearingLine(origin: split, trueBearing: 30);
      final b = BearingLine(
          origin: BearingGeometry.destination(split, 120, 1),
          trueBearing: 30);
      expect(BearingGeometry.intersection(a, b), isNull);
    });

    test('priesečník za chrbtom sa zahodí', () {
      // Západný pozorovateľ mieri mierne na západ od severu, východný mierne
      // na východ — dopredu sa rozbiehajú, takže ich priamky sa stretnú až
      // za nimi. To nie je poloha zameraného objektu.
      const a = BearingLine(origin: split, trueBearing: 350);
      final b = BearingLine(
          origin: BearingGeometry.destination(split, 90, 2),
          trueBearing: 10);
      expect(BearingGeometry.intersection(a, b), isNull);
    });

    test('opačné kurzy na tú istú vec sa nepovažujú za fix', () {
      const a = BearingLine(origin: split, trueBearing: 90);
      final b = BearingLine(
          origin: BearingGeometry.destination(split, 90, 2),
          trueBearing: 270);
      // Rovnobežné (a teda degenerované), nie priesečník.
      expect(BearingGeometry.intersection(a, b), isNull);
    });
  });

  group('cutAngle', () {
    test('kolmé čiary dajú 90°', () {
      expect(
          BearingGeometry.cutAngle(
            const BearingLine(origin: split, trueBearing: 0),
            const BearingLine(origin: split, trueBearing: 90),
          ),
          closeTo(90, 1e-9));
    });

    test('uhol sa vždy zloží do 0–90°', () {
      expect(
          BearingGeometry.cutAngle(
            const BearingLine(origin: split, trueBearing: 10),
            const BearingLine(origin: split, trueBearing: 350),
          ),
          closeTo(20, 1e-9));
      expect(
          BearingGeometry.cutAngle(
            const BearingLine(origin: split, trueBearing: 0),
            const BearingLine(origin: split, trueBearing: 179),
          ),
          closeTo(1, 1e-9));
    });
  });

  // Tieto testy opisujú hľadanie ZAMERANÉHO OBJEKTU zo známych polôh
  // pozorovateľa. Resekcia (hľadanie vlastnej polohy) má vlastný súbor,
  // resection_geometry_test.dart — sú to inverzné úlohy a vedľa seba je
  // najlepšie vidieť, čím sa líšia.
  group('fix – priesečník dopredných zameraní', () {
    /// Postaví zamerania z [from] na spoločný cieľ [target].
    List<BearingLine> sightsOn(LatLng target, List<LatLng> from,
        {double uncertainty = 8}) =>
        [
          for (final o in from)
            BearingLine(
              origin: o,
              // Distance().bearing() vracia -180..180, nie 0..360.
              trueBearing: (const Distance().bearing(o, target) + 360) % 360,
              uncertaintyDeg: uncertainty,
            ),
        ];

    test('jedno zameranie fix nedá', () {
      expect(
          BearingGeometry.fix(
              [const BearingLine(origin: split, trueBearing: 45)],
              kind: BearingKind.intersection),
          isNull);
    });

    test('dve zamerania nájdu spoločný cieľ', () {
      final target = BearingGeometry.destination(split, 20, 4);
      final lines = sightsOn(target, [
        split,
        BearingGeometry.destination(split, 90, 3),
      ]);
      final fix = BearingGeometry.fix(lines, kind: BearingKind.intersection)!;
      expect(_metres(fix.position, target), lessThan(50));
      expect(fix.bearingCount, 2);
      expect(fix.intersections, hasLength(1));
    });

    test('tri zamerania dajú tri priesečníky a menší rozptyl', () {
      final target = BearingGeometry.destination(split, 20, 4);
      final lines = sightsOn(target, [
        split,
        BearingGeometry.destination(split, 90, 3),
        BearingGeometry.destination(split, 300, 3),
      ]);
      final fix = BearingGeometry.fix(lines, kind: BearingKind.intersection)!;
      expect(fix.bearingCount, 3);
      expect(fix.intersections, hasLength(3));
      expect(_metres(fix.position, target), lessThan(60));
    });

    test('ostrý rezný uhol sa označí za slabý fix', () {
      final target = BearingGeometry.destination(split, 20, 6);
      // Pozorovatelia takmer v jednej línii s cieľom, len mierne bokom —
      // čiary sa pretínajú pod pár stupňami a fix sa rozmaže.
      final lines = sightsOn(target, [
        split,
        BearingGeometry.destination(
            BearingGeometry.destination(split, 20, 1), 110, 0.3),
      ]);
      final fix = BearingGeometry.fix(lines, kind: BearingKind.intersection)!;
      expect(fix.isWeak, isTrue);
      expect(fix.cutAngleDeg, lessThan(30));
    });

    test('kolmý rez je silný fix a chyba je menšia', () {
      final target = BearingGeometry.destination(split, 0, 3);
      final sharp = BearingGeometry.fix(kind: BearingKind.intersection, sightsOn(target, [
        split,
        BearingGeometry.destination(split, 90, 3),
      ]))!;
      final shallow = BearingGeometry.fix(kind: BearingKind.intersection, sightsOn(target, [
        split,
        BearingGeometry.destination(
            BearingGeometry.destination(split, 0, 1), 90, 0.2),
      ]))!;
      expect(sharp.isWeak, isFalse);
      expect(sharp.errorRadiusMeters, lessThan(shallow.errorRadiusMeters));
    });

    test('širší kužeľ znamená väčšiu chybu fixu', () {
      final target = BearingGeometry.destination(split, 0, 3);
      final observers = [split, BearingGeometry.destination(split, 90, 3)];
      final tight = BearingGeometry.fix(
          sightsOn(target, observers, uncertainty: 3),
          kind: BearingKind.intersection)!;
      final loose = BearingGeometry.fix(
          sightsOn(target, observers, uncertainty: 12),
          kind: BearingKind.intersection)!;
      expect(loose.errorRadiusMeters,
          greaterThan(tight.errorRadiusMeters * 2));
    });

    test('samé rovnobežné čiary fix nedajú', () {
      final lines = [
        const BearingLine(origin: split, trueBearing: 45),
        BearingLine(
            origin: BearingGeometry.destination(split, 135, 2),
            trueBearing: 45),
      ];
      expect(BearingGeometry.fix(lines, kind: BearingKind.intersection), isNull);
    });

    test('nepoužiteľná dvojica fix nezhodí, keď zvyšok dáva zmysel', () {
      final target = BearingGeometry.destination(split, 20, 4);
      final good = sightsOn(target, [
        split,
        BearingGeometry.destination(split, 90, 3),
      ]);
      // Tretia čiara mieri preč a s jednou z predošlých je rovnobežná.
      final lines = [
        ...good,
        BearingLine(
            origin: BearingGeometry.destination(split, 180, 2),
            trueBearing: good.first.trueBearing),
      ];
      final fix = BearingGeometry.fix(lines, kind: BearingKind.intersection);
      expect(fix, isNotNull);
      expect(fix!.intersections, isNotEmpty);
    });
  });

  group('trueFromMagnetic', () {
    test('východná deklinácia sa pripočíta', () {
      expect(trueFromMagnetic(90, 4.2), closeTo(94.2, 1e-9));
    });

    test('západná deklinácia sa odpočíta', () {
      expect(trueFromMagnetic(90, -6.5), closeTo(83.5, 1e-9));
    });

    test('výsledok zostane v 0–360', () {
      expect(trueFromMagnetic(358, 5), closeTo(3, 1e-9));
      expect(trueFromMagnetic(2, -5), closeTo(357, 1e-9));
      expect(trueFromMagnetic(0, -0.0001), greaterThanOrEqualTo(0));
    });
  });
}
