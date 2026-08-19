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

/// Resekcia predpokladá, že loď medzi jednotlivými odčítaniami stojí, preto sa
/// do jedného výsledku smú zliať len námery z krátkeho okna a len na RÔZNE
/// známe body. Toto sú pravidlá, ktoré to držia.
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

  /// Zapíše námer na známy bod [mark] z (nezaznamenanej) polohy [observer].
  ///
  /// Poloha pozorovateľa sa zámerne NEukladá — presne tak vzniká riadok, keď
  /// GPS nie je, a práve to musí resekcia zvládnuť.
  Future<int> sight({
    required LatLng observer,
    required LatLng mark,
    required int markId,
    String? markName,
    DateTime? at,
  }) =>
      db.insertBearing(BearingsCompanion.insert(
        kind: BearingKind.resection.code,
        magneticBearing: measured(observer, mark),
        declination: 0,
        declinationSource: const Value('target'),
        trueBearing: measured(observer, mark),
        targetWaypointId: Value(markId),
        targetLat: Value(mark.latitude),
        targetLon: Value(mark.longitude),
        targetName: Value(markName),
        takenAt: at ?? noon,
      ));

  Future<int> addWaypoint(LatLng at, String name) => db.insertWaypoint(
        WaypointsCompanion.insert(
          name: name,
          latitude: at.latitude,
          longitude: at.longitude,
          createdAt: noon,
        ),
      );

  Future<void> settle(int expected) async {
    await container.read(bearingsProvider.future);
    for (var i = 0; i < 50; i++) {
      final rows = container.read(bearingsProvider).valueOrNull;
      if (rows != null && rows.length == expected) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('stream nedal $expected zameraní');
  }

  test('jeden známy bod polohu nedá', () async {
    final mark = BearingGeometry.destination(split, 20, 4);
    await sight(observer: split, mark: mark, markId: await addWaypoint(mark, 'A'));
    await settle(1);

    expect(container.read(resectionTargetCountProvider), 1);
    expect(container.read(resectionFixProvider), isNull);
  });

  test('dva rôzne body dajú moju polohu, aj bez GPS v riadkoch', () async {
    final a = BearingGeometry.destination(split, 0, 4);
    final b = BearingGeometry.destination(split, 90, 4);
    await sight(observer: split, mark: a, markId: await addWaypoint(a, 'A'));
    await sight(
        observer: split,
        mark: b,
        markId: await addWaypoint(b, 'B'),
        at: noon.add(const Duration(minutes: 1)));
    await settle(2);

    final fix = container.read(resectionFixProvider);
    expect(fix, isNotNull);
    expect(fix!.isOwnPosition, isTrue);
    expect(const Distance().distance(fix.position, split), lessThan(80));
    // Ani jeden riadok nemá polohu pozorovateľa — to je celý zmysel.
    for (final row in container.read(resectionBearingsProvider)) {
      expect(row.observerLat, isNull);
    }
  });

  test('dva námery na TEN ISTÝ bod polohu nedajú', () async {
    final a = BearingGeometry.destination(split, 20, 4);
    final id = await addWaypoint(a, 'A');
    await sight(observer: split, mark: a, markId: id);
    await sight(
        observer: split,
        mark: a,
        markId: id,
        at: noon.add(const Duration(minutes: 1)));
    await settle(2);

    // Z bodu sa berie len najnovší námer, takže zostáva jediná priamka.
    expect(container.read(resectionBearingsProvider), hasLength(1));
    expect(container.read(resectionTargetCountProvider), 1);
    expect(container.read(resectionFixProvider), isNull);
  });

  test('opakovaný námer na ten istý bod je oprava, nie ďalšia priamka',
      () async {
    final a = BearingGeometry.destination(split, 0, 4);
    final b = BearingGeometry.destination(split, 90, 4);
    final idA = await addWaypoint(a, 'A');
    await sight(observer: split, mark: a, markId: idA);
    await sight(observer: split, mark: b, markId: await addWaypoint(b, 'B'));
    // Tretí námer prekontroluje prvý bod.
    await sight(
        observer: split,
        mark: a,
        markId: idA,
        at: noon.add(const Duration(minutes: 2)));
    await settle(3);

    expect(container.read(resectionBearingsProvider), hasLength(2));
    expect(container.read(resectionFixProvider), isNotNull);
  });

  test('starý námer do polohy nevstúpi', () async {
    final a = BearingGeometry.destination(split, 0, 4);
    final b = BearingGeometry.destination(split, 90, 4);
    await sight(
        observer: split,
        mark: a,
        markId: await addWaypoint(a, 'A'),
        at: noon.subtract(const Duration(hours: 1)));
    await sight(observer: split, mark: b, markId: await addWaypoint(b, 'B'));
    await settle(2);

    expect(container.read(resectionBearingsProvider), hasLength(1));
    expect(container.read(resectionFixProvider), isNull);
  });

  test('okno sa počíta od najnovšieho námeru, nie od aktuálneho času',
      () async {
    // Resekcia spred týždňa je stále vnútorne konzistentný záznam a má sa dať
    // prezrieť na mape.
    final lastWeek = noon.subtract(const Duration(days: 7));
    final a = BearingGeometry.destination(split, 0, 4);
    final b = BearingGeometry.destination(split, 90, 4);
    await sight(
        observer: split,
        mark: a,
        markId: await addWaypoint(a, 'A'),
        at: lastWeek);
    await sight(
        observer: split,
        mark: b,
        markId: await addWaypoint(b, 'B'),
        at: lastWeek.add(const Duration(seconds: 30)));
    await settle(2);

    expect(container.read(resectionBearingsProvider), hasLength(2));
    expect(container.read(resectionFixProvider), isNotNull);
  });

  test('hľadanie objektu resekciu neovplyvní', () async {
    final a = BearingGeometry.destination(split, 0, 4);
    final b = BearingGeometry.destination(split, 90, 4);
    await sight(observer: split, mark: a, markId: await addWaypoint(a, 'A'));
    await sight(observer: split, mark: b, markId: await addWaypoint(b, 'B'));
    // Námer na neznámy objekt je iný druh a do resekcie nepatrí.
    await db.insertBearing(BearingsCompanion.insert(
      kind: BearingKind.intersection.code,
      magneticBearing: 200,
      declination: 0,
      declinationSource: const Value('gps'),
      trueBearing: 200,
      observerLat: const Value(43.5),
      observerLon: const Value(16.4),
      sightGroupId: const Value('skupina'),
      label: const Value('skala'),
      takenAt: noon,
    ));
    await settle(3);

    expect(container.read(resectionBearingsProvider), hasLength(2));
    expect(container.read(resectionFixProvider), isNotNull);
  });

  test('po zmazaní námerov poloha zmizne', () async {
    final a = BearingGeometry.destination(split, 0, 4);
    final b = BearingGeometry.destination(split, 90, 4);
    await sight(observer: split, mark: a, markId: await addWaypoint(a, 'A'));
    await sight(observer: split, mark: b, markId: await addWaypoint(b, 'B'));
    await settle(2);
    expect(container.read(resectionFixProvider), isNotNull);

    await db.deleteAllBearings();
    await settle(0);

    expect(container.read(resectionBearingsProvider), isEmpty);
    expect(container.read(resectionFixProvider), isNull);
  });

  test('zmazaný waypoint polohu nezhodí — počíta sa z odpisu', () async {
    final a = BearingGeometry.destination(split, 0, 4);
    final b = BearingGeometry.destination(split, 90, 4);
    final idA = await addWaypoint(a, 'A');
    await sight(observer: split, mark: a, markId: idA, markName: 'A');
    await sight(observer: split, mark: b, markId: await addWaypoint(b, 'B'));
    await settle(2);

    await db.deleteWaypoint(idA);
    await settle(2);

    // Priamka sa kreslí z uloženej polohy bodu, nie z waypointu, takže
    // výsledok prežije aj jeho zmazanie.
    final fix = container.read(resectionFixProvider);
    expect(fix, isNotNull);
    expect(const Distance().distance(fix!.position, split), lessThan(80));
  });

  test('bearingLineOf postaví resekčnú priamku z bodu, opačným kurzom',
      () async {
    final mark = BearingGeometry.destination(split, 90, 4);
    await sight(
        observer: split, mark: mark, markId: await addWaypoint(mark, 'A'));
    await settle(1);

    final row = container.read(resectionBearingsProvider).single;
    final line = bearingLineOf(row)!;
    expect(line.origin.latitude, closeTo(mark.latitude, 1e-9));
    // Nameraný kurz je na východ, priamka teda vedie na západ.
    expect(line.trueBearing, closeTo((row.trueBearing + 180) % 360, 1e-9));
  });
}
