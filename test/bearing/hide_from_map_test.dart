import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/bearing/providers/bearing_provider.dart';
import 'package:hmb_sailing_log/main.dart' show databaseProvider;

/// "Zmazať z mapy" nesmie zmazať záznam. Skryje ho z toho, čo kreslí živá
/// mapa, ale riadok zostáva v databáze — a teda aj v dennom zázname a v PDF,
/// ktoré čítajú z [bearingsProvider] priamo, nie z odfiltrovanej verzie.
void main() {
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

  final noon = DateTime.utc(2026, 8, 20, 12);

  Future<int> addIntersection({String groupId = 'g1'}) =>
      db.insertBearing(BearingsCompanion.insert(
        kind: BearingKind.intersection.code,
        magneticBearing: 90,
        declination: 4.2,
        declinationSource: const Value('gps'),
        trueBearing: 94.2,
        observerLat: const Value(43.5),
        observerLon: const Value(16.4),
        sightGroupId: Value(groupId),
        label: const Value('skala'),
        takenAt: noon,
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

  test('nové zameranie je viditeľné na mape aj v denníku', () async {
    await addIntersection();
    await settle(1);

    expect(container.read(mapVisibleBearingsProvider), hasLength(1));
    expect(container.read(bearingsProvider).valueOrNull, hasLength(1));
  });

  test('hideFromMap zmizne z mapy, ale zostane v denníku', () async {
    final id = await addIntersection();
    await settle(1);

    await container.read(bearingRepositoryProvider).hideFromMap(id);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(container.read(mapVisibleBearingsProvider), isEmpty);
    // bearingsProvider je zdroj pre denník aj PDF — riadok tam zostáva.
    expect(container.read(bearingsProvider).valueOrNull, hasLength(1));
    expect(container.read(bearingsProvider).valueOrNull!.single.hiddenFromMap,
        isTrue);
  });

  test('hideGroupFromMap skryje celú skupinu naraz', () async {
    await addIntersection(groupId: 'g1');
    await addIntersection(groupId: 'g1');
    await addIntersection(groupId: 'g2');
    await settle(3);

    await container.read(bearingRepositoryProvider).hideGroupFromMap('g1');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(container.read(mapVisibleBearingsProvider), hasLength(1));
    expect(container.read(bearingsProvider).valueOrNull, hasLength(3));
  });

  test('hideAllFromMap vyprázdni mapu, denník zostane plný', () async {
    await addIntersection(groupId: 'g1');
    await addIntersection(groupId: 'g2');
    await settle(2);

    await container.read(bearingRepositoryProvider).hideAllFromMap();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(container.read(mapVisibleBearingsProvider), isEmpty);
    expect(container.read(bearingsProvider).valueOrNull, hasLength(2));
  });

  test('skryté zameranie sa dá z denníka aj naozaj zmazať', () async {
    final id = await addIntersection();
    await settle(1);

    await container.read(bearingRepositoryProvider).hideFromMap(id);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await container.read(bearingRepositoryProvider).delete(id);
    await settle(0);

    expect(container.read(bearingsProvider).valueOrNull, isEmpty);
  });
}
