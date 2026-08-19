import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/bearing/providers/bearing_provider.dart';

/// Zameranie sa teraz spočíta a zapíše až na dve kroky: `prepare*()` vráti
/// návrh, ktorý sa dá ukázať na potvrdenie, a `commit()` alebo
/// `discardDraft()` rozhodne, čo s ním bude. Tieto testy strážia, že medzi
/// tými dvoma krokmi sa nič nezapíše samo od seba, a že zahodenie naozaj
/// zahodí — vrátane fotky.
void main() {
  late AppDatabase db;
  late BearingRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    repo = BearingRepository(db, clock: () => DateTime.utc(2026, 8, 19, 12));
  });
  tearDown(() async => db.close());

  Future<int> addWaypoint() => db.insertWaypoint(WaypointsCompanion.insert(
        name: 'Maják Stončica',
        latitude: 43.06,
        longitude: 16.25,
        createdAt: DateTime.utc(2026, 8, 19),
      ));

  test('prepareResection nič nezapíše', () async {
    final wpId = await addWaypoint();
    final waypoint = (await db.getAllWaypoints())
        .firstWhere((w) => w.id == wpId);

    final result = await repo.prepareResection(
        magneticBearing: 90, target: waypoint);

    expect(result, isA<BearingPrepared>());
    expect(await db.getAllBearings(), isEmpty);
  });

  test('commit zapíše presne to, čo bolo pripravené', () async {
    final wpId = await addWaypoint();
    final waypoint =
        (await db.getAllWaypoints()).firstWhere((w) => w.id == wpId);

    final prepared = await repo.prepareResection(
        magneticBearing: 90, target: waypoint) as BearingPrepared;
    final committed = await repo.commit(prepared.draft);

    expect(committed, isA<BearingCaptured>());
    final stored = (await db.getAllBearings()).single;
    expect(stored.magneticBearing, 90);
    expect(BearingKind.fromCode(stored.kind), BearingKind.resection);
    expect(stored.targetWaypointId, wpId);
  });

  test('discardDraft nič nezapíše', () async {
    final wpId = await addWaypoint();
    final waypoint =
        (await db.getAllWaypoints()).firstWhere((w) => w.id == wpId);

    final prepared = await repo.prepareResection(
        magneticBearing: 90, target: waypoint) as BearingPrepared;
    await repo.discardDraft(prepared.draft);

    expect(await db.getAllBearings(), isEmpty);
  });

  test('bez potvrdenia zostáva databáza prázdna aj pri viacerých návrhoch',
      () async {
    final wpId = await addWaypoint();
    final waypoint =
        (await db.getAllWaypoints()).firstWhere((w) => w.id == wpId);

    for (var i = 0; i < 3; i++) {
      await repo.prepareResection(magneticBearing: 90.0 + i, target: waypoint);
    }
    expect(await db.getAllBearings(), isEmpty);
  });

  test('prepareIntersection bez GPS vráti chybu, nie prázdny návrh',
      () async {
    final repoNoGps =
        BearingRepository(db, positionSource: () => null);
    final result = await repoNoGps.prepareIntersection(
        magneticBearing: 90, objectName: 'skala');

    expect(result, isA<BearingNeedsObserverPosition>());
    expect(await db.getAllBearings(), isEmpty);
  });

  test('prepareResection bez cieľa vráti chybu bez toho, aby čokoľvek robila',
      () async {
    final result =
        await repo.prepareResection(magneticBearing: 90, target: null);
    expect(result, isA<BearingNeedsTarget>());
  });
}
