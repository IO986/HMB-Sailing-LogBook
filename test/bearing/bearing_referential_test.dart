import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';

/// Zameranie visí na waypointe, dni aj plavbe, a `beforeOpen` zapína
/// `PRAGMA foreign_keys = ON`. Prvá verzia tejto tabuľky preto tichom
/// zamínovala tri celkom obyčajné operácie: zmazať waypoint, zmazať deň,
/// zmazať plavbu. Každá z nich padala na `FOREIGN KEY constraint failed`.
///
/// Tieto testy držia obe strany rozhodnutia: mazanie musí prejsť, a záznam
/// merania, ktoré sa naozaj stalo, sa pri tom nesmie stratiť ani prepísať.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    // Vynúť otvorenie databázy, aby beforeOpen stihol zapnúť cudzie kľúče.
    await db.getAllWaypoints();
  });
  tearDown(() async => db.close());

  final noon = DateTime.utc(2026, 8, 19, 12);

  test('cudzie kľúče sú naozaj zapnuté', () async {
    // Keby neboli, celý tento súbor by nič nedokazoval.
    final rows = await db.customSelect('PRAGMA foreign_keys').get();
    expect(rows.first.data.values.first, 1);
  });

  Future<int> addWaypoint(String name) => db.insertWaypoint(
        WaypointsCompanion.insert(
          name: name,
          latitude: 43.06,
          longitude: 16.25,
          createdAt: noon,
        ),
      );

  Future<int> addResection(int waypointId) =>
      db.insertBearing(BearingsCompanion.insert(
        kind: BearingKind.resection.code,
        magneticBearing: 90,
        declination: 4.2,
        trueBearing: 94.2,
        takenAt: noon,
        targetWaypointId: Value(waypointId),
        targetLat: const Value(43.06),
        targetLon: const Value(16.25),
        targetName: const Value('Maják Stončica'),
      ));

  group('zmazanie zameraného waypointu', () {
    test('prejde a zameranie prežije s odpisom polohy aj názvu', () async {
      final wpId = await addWaypoint('Maják Stončica');
      await addResection(wpId);

      await db.deleteWaypoint(wpId);

      final stored = (await db.getAllBearings()).single;
      // Odkaz zmizol...
      expect(stored.targetWaypointId, isNull);
      // ...ale meranie zostalo použiteľné: bez odpisu by sa čiara už nedala
      // nakresliť ani vysvetliť, kam skiper vlastne mieril.
      expect(stored.targetName, 'Maják Stončica');
      expect(stored.targetLat, closeTo(43.06, 1e-9));
      expect(stored.targetLon, closeTo(16.25, 1e-9));
      expect(stored.trueBearing, closeTo(94.2, 1e-9));
    });

    test('zmaže sa len odkaz zamerania na TEN zmazaný bod', () async {
      final gone = await addWaypoint('Zmazaný');
      final kept = await addWaypoint('Zostáva');
      await addResection(gone);
      await addResection(kept);

      await db.deleteWaypoint(gone);

      final ids = (await db.getAllBearings()).map((b) => b.targetWaypointId);
      expect(ids, containsAll(<int?>[null, kept]));
    });
  });

  group('zmazanie dňa a plavby', () {
    Future<({int charterId, int dayLogId})> makeDay() async {
      final charter = await db.insertCharter(ChartersCompanion.insert(
        title: 'Plavba',
        dateFrom: noon,
        dateTo: noon,
        createdAt: noon,
      ));
      final day = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: charter.id,
        date: noon,
      ));
      return (charterId: charter.id, dayLogId: day.id);
    }

    Future<int> addIntersection({int? dayLogId, int? charterId}) =>
        db.insertBearing(BearingsCompanion.insert(
          kind: BearingKind.intersection.code,
          magneticBearing: 90,
          declination: 4.2,
          trueBearing: 94.2,
          takenAt: noon,
          observerLat: const Value(43.5),
          observerLon: const Value(16.4),
          sightGroupId: const Value('skupina-1'),
          label: const Value('neznáma skala'),
          dayLogId: Value(dayLogId),
          charterId: Value(charterId),
        ));

    test('deň so zameraniami sa zmaže a vezme ich s sebou', () async {
      final v = await makeDay();
      await addIntersection(dayLogId: v.dayLogId, charterId: v.charterId);

      await db.deleteDayLog(v.dayLogId);

      // Zamerania sú obsah dňa, tak ako denníkové záznamy — mazanie dňa
      // používateľa vopred varuje, že sa zmažú všetky záznamy za ten deň.
      expect(await db.getAllBearings(), isEmpty);
    });

    test('plavba so zameraniami sa zmaže', () async {
      final v = await makeDay();
      await addIntersection(dayLogId: v.dayLogId, charterId: v.charterId);

      await db.deleteCharter(v.charterId);

      expect(await db.getAllBearings(), isEmpty);
    });

    test('zameranie priradené len k plavbe, nie k dňu, mazanie nezhodí',
        () async {
      final v = await makeDay();
      await addIntersection(charterId: v.charterId);

      await db.deleteCharter(v.charterId);

      expect(await db.getAllBearings(), isEmpty);
    });

    test('zameranie mimo plavby zmazanie dňa neovplyvní', () async {
      final v = await makeDay();
      await addIntersection(dayLogId: v.dayLogId, charterId: v.charterId);
      await addIntersection(); // bez dňa aj plavby

      await db.deleteDayLog(v.dayLogId);

      expect(await db.getAllBearings(), hasLength(1));
      expect((await db.getAllBearings()).single.dayLogId, isNull);
    });
  });

  group('CHECK drží invariant druhu zamerania', () {
    test('resekcia bez zameraného bodu sa nezapíše', () async {
      await expectLater(
        db.insertBearing(BearingsCompanion.insert(
          kind: BearingKind.resection.code,
          magneticBearing: 90,
          declination: 4.2,
          trueBearing: 94.2,
          takenAt: noon,
        )),
        throwsA(anything),
      );
    });

    test('hľadanie objektu bez polohy pozorovateľa sa nezapíše', () async {
      await expectLater(
        db.insertBearing(BearingsCompanion.insert(
          kind: BearingKind.intersection.code,
          magneticBearing: 90,
          declination: 4.2,
          trueBearing: 94.2,
          takenAt: noon,
          sightGroupId: const Value('skupina-1'),
        )),
        throwsA(anything),
      );
    });

    test('hľadanie objektu bez skupiny sa nezapíše', () async {
      // Bez skupiny by sa námery nedali priradiť k tomu istému objektu.
      await expectLater(
        db.insertBearing(BearingsCompanion.insert(
          kind: BearingKind.intersection.code,
          magneticBearing: 90,
          declination: 4.2,
          trueBearing: 94.2,
          takenAt: noon,
          observerLat: const Value(43.5),
          observerLon: const Value(16.4),
        )),
        throwsA(anything),
      );
    });

    test('resekcia so skupinou sa nezapíše', () async {
      // Skupiny patria len hľadaniu objektu; inde by miešali dva výpočty.
      await expectLater(
        db.insertBearing(BearingsCompanion.insert(
          kind: BearingKind.resection.code,
          magneticBearing: 90,
          declination: 4.2,
          trueBearing: 94.2,
          takenAt: noon,
          targetLat: const Value(43.06),
          targetLon: const Value(16.25),
          sightGroupId: const Value('skupina-1'),
        )),
        throwsA(anything),
      );
    });

    test('neznámy druh sa nezapíše', () async {
      await expectLater(
        db.insertBearing(BearingsCompanion.insert(
          kind: 'triangulacia',
          magneticBearing: 90,
          declination: 4.2,
          trueBearing: 94.2,
          takenAt: noon,
          observerLat: const Value(43.5),
          observerLon: const Value(16.4),
        )),
        throwsA(anything),
      );
    });
  });
}
