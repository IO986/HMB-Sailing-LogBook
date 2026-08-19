import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/bearing/providers/bearing_provider.dart';
import 'package:hmb_sailing_log/features/bearing/services/bearing_geometry.dart';
import 'package:hmb_sailing_log/main.dart' show databaseProvider;
import 'package:latlong2/latlong.dart';

/// Reverzná triangulácia: poznám seba, hľadám bod.
///
/// Presne naopak než resekcia — tu je odstup v čase a priestore to, čo výpočet
/// vôbec umožňuje. Preto tu žiadne časové okno byť nesmie, a testy nižšie to
/// strážia: keby sa okno raz vrátilo, zameranie skaly s hodinovým odstupom by
/// prestalo fungovať.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  final noon = DateTime.utc(2026, 8, 19, 12);
  const split = LatLng(43.5081, 16.4402);

  double measured(LatLng from, LatLng to) =>
      (const Distance().bearing(from, to) + 360) % 360;

  /// Zapíše námer na neznámy objekt [target] z polohy [observer].
  Future<int> sight({
    required LatLng observer,
    required LatLng target,
    required String groupId,
    String name = 'neznáma skala',
    DateTime? at,
  }) =>
      db.insertBearing(BearingsCompanion.insert(
        kind: BearingKind.intersection.code,
        magneticBearing: measured(observer, target),
        declination: 0,
        declinationSource: const Value('gps'),
        trueBearing: measured(observer, target),
        observerLat: Value(observer.latitude),
        observerLon: Value(observer.longitude),
        sightGroupId: Value(groupId),
        label: Value(name),
        takenAt: at ?? noon,
      ));

  Future<void> settle(int expected) async {
    await container.read(bearingsProvider.future);
    for (var i = 0; i < 50; i++) {
      final rows = container.read(bearingsProvider).valueOrNull;
      if (rows != null && rows.length == expected) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('stream nedal $expected zameraní');
  }

  test('jediný námer objekt neurčí', () async {
    final target = BearingGeometry.destination(split, 20, 4);
    await sight(observer: split, target: target, groupId: 'g1');
    await settle(1);

    final groups = container.read(sightGroupsProvider);
    expect(groups, hasLength(1));
    expect(groups.single.bearings, hasLength(1));
    expect(groups.single.fix, isNull);
  });

  test('dva námery z rôznych miest určia objekt', () async {
    final target = BearingGeometry.destination(split, 20, 4);
    final second = BearingGeometry.destination(split, 90, 2);
    await sight(observer: split, target: target, groupId: 'g1');
    await sight(
        observer: second,
        target: target,
        groupId: 'g1',
        at: noon.add(const Duration(minutes: 20)));
    await settle(2);

    final group = container.read(sightGroupsProvider).single;
    expect(group.name, 'neznáma skala');
    expect(group.fix, isNotNull);
    expect(group.fix!.kind, BearingKind.intersection);
    expect(group.fix!.isOwnPosition, isFalse);
    expect(const Distance().distance(group.fix!.position, target),
        lessThan(80));
  });

  test('trojhodinový odstup je stále JEDEN objekt — okno tu byť nesmie',
      () async {
    // Toto je regresný test proti návratu časového okna. Bez odstupu by loď
    // nemala základnicu a výpočet by nemal z čoho vyjsť.
    final target = BearingGeometry.destination(split, 20, 5);
    await sight(observer: split, target: target, groupId: 'g1', at: noon);
    await sight(
        observer: BearingGeometry.destination(split, 100, 3),
        target: target,
        groupId: 'g1',
        at: noon.add(const Duration(hours: 3)));
    await settle(2);

    final group = container.read(sightGroupsProvider).single;
    expect(group.bearings, hasLength(2));
    expect(group.fix, isNotNull);
    expect(const Distance().distance(group.fix!.position, target),
        lessThan(120));
  });

  test('tri námery dajú trojuholník chyby', () async {
    final target = BearingGeometry.destination(split, 20, 4);
    await sight(observer: split, target: target, groupId: 'g1');
    await sight(
        observer: BearingGeometry.destination(split, 90, 3),
        target: target,
        groupId: 'g1',
        at: noon.add(const Duration(minutes: 30)));
    await sight(
        observer: BearingGeometry.destination(split, 300, 3),
        target: target,
        groupId: 'g1',
        at: noon.add(const Duration(hours: 1)));
    await settle(3);

    final group = container.read(sightGroupsProvider).single;
    expect(group.fix!.intersections, hasLength(3));
    expect(group.fix!.bearingCount, 3);
  });

  test('dve pátrania sa nemiešajú', () async {
    final rock = BearingGeometry.destination(split, 20, 4);
    final wreck = BearingGeometry.destination(split, 200, 3);
    final elsewhere = BearingGeometry.destination(split, 90, 2);

    await sight(observer: split, target: rock, groupId: 'g1', name: 'skala');
    await sight(
        observer: elsewhere, target: rock, groupId: 'g1', name: 'skala');
    await sight(observer: split, target: wreck, groupId: 'g2', name: 'vrak');
    await sight(
        observer: elsewhere, target: wreck, groupId: 'g2', name: 'vrak');
    await settle(4);

    final groups = container.read(sightGroupsProvider);
    expect(groups, hasLength(2));
    final byName = {for (final g in groups) g.name: g};
    expect(const Distance().distance(byName['skala']!.fix!.position, rock),
        lessThan(100));
    expect(const Distance().distance(byName['vrak']!.fix!.position, wreck),
        lessThan(100));
  });

  group('základnica', () {
    test('krátka základnica sa označí', () async {
      final target = BearingGeometry.destination(split, 20, 5);
      // Dvadsať metrov od seba — z toho sa triangulovať nedá.
      await sight(observer: split, target: target, groupId: 'g1');
      await sight(
          observer: BearingGeometry.destination(split, 90, 0.011),
          target: target,
          groupId: 'g1',
          at: noon.add(const Duration(minutes: 5)));
      await settle(2);

      final group = container.read(sightGroupsProvider).single;
      expect(group.baselineMeters, lessThan(kMinBaselineMeters));
      expect(group.baselineTooShort, isTrue);
    });

    test('dostatočná základnica sa neoznačí a meria najširší rozstup',
        () async {
      final target = BearingGeometry.destination(split, 20, 4);
      final far = BearingGeometry.destination(split, 90, 2);
      await sight(observer: split, target: target, groupId: 'g1');
      await sight(
          observer: far,
          target: target,
          groupId: 'g1',
          at: noon.add(const Duration(minutes: 20)));
      await settle(2);

      final group = container.read(sightGroupsProvider).single;
      expect(group.baselineTooShort, isFalse);
      expect(group.baselineMeters,
          closeTo(const Distance().distance(split, far), 30));
    });
  });

  test('resekcia sa medzi pátrania nezamotá', () async {
    final target = BearingGeometry.destination(split, 20, 4);
    await sight(observer: split, target: target, groupId: 'g1');
    await db.insertBearing(BearingsCompanion.insert(
      kind: BearingKind.resection.code,
      magneticBearing: 90,
      declination: 0,
      declinationSource: const Value('target'),
      trueBearing: 90,
      targetLat: const Value(43.06),
      targetLon: const Value(16.25),
      targetName: const Value('Maják'),
      takenAt: noon,
    ));
    await settle(2);

    expect(container.read(sightGroupsProvider), hasLength(1));
    expect(container.read(sightGroupsProvider).single.bearings, hasLength(1));
  });

  test('zmazanie skupiny vyhodí len ju', () async {
    final target = BearingGeometry.destination(split, 20, 4);
    await sight(observer: split, target: target, groupId: 'g1', name: 'skala');
    await sight(
        observer: BearingGeometry.destination(split, 90, 2),
        target: target,
        groupId: 'g2',
        name: 'vrak');
    await settle(2);

    await db.deleteBearingGroup('g1');
    await settle(1);

    final groups = container.read(sightGroupsProvider);
    expect(groups, hasLength(1));
    expect(groups.single.name, 'vrak');
  });

  test('názov skupiny berie ten z najnovšieho námeru', () async {
    final target = BearingGeometry.destination(split, 20, 4);
    await sight(
        observer: split, target: target, groupId: 'g1', name: 'skla');
    await sight(
        observer: BearingGeometry.destination(split, 90, 2),
        target: target,
        groupId: 'g1',
        name: 'skala',
        at: noon.add(const Duration(minutes: 10)));
    await settle(2);

    // Opravený preklep sa má prejaviť bez prepisovania starých riadkov.
    expect(container.read(sightGroupsProvider).single.name, 'skala');
  });

  test('skupiny sú zoradené od naposledy zameranej', () async {
    final target = BearingGeometry.destination(split, 20, 4);
    await sight(observer: split, target: target, groupId: 'g1', name: 'staré');
    await sight(
        observer: split,
        target: target,
        groupId: 'g2',
        name: 'nové',
        at: noon.add(const Duration(hours: 2)));
    await settle(2);

    expect(container.read(sightGroupsProvider).map((g) => g.name),
        ['nové', 'staré']);
  });
}
