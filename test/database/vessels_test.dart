import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

/// Kto pláva stále na tej istej lodi, prepisoval pri každej novej plavbe to
/// isté — model, volací znak, MMSI, rozmery, nádrže. Zoznam lodí to drží raz.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<Vessel> add(
    String name, {
    bool own = false,
    DateTime? lastUsed,
    String? model,
  }) =>
      db.insertVessel(VesselsCompanion.insert(
        name: name,
        model: Value(model),
        isOwn: Value(own),
        createdAt: DateTime(2026, 1, 1),
        lastUsedAt: Value(lastUsed),
      ));

  test('vlastná loď stojí v zozname pred charterovými', () async {
    await add('Charterová', lastUsed: DateTime(2026, 8, 1));
    await add('Perun', own: true, lastUsed: DateTime(2026, 1, 5));

    final list = await db.getVessels();
    expect(list.first.name, 'Perun');
  });

  test('medzi rovnakými rozhoduje, z ktorej sa plavilo naposledy', () async {
    await add('Stará', lastUsed: DateTime(2025, 6, 1));
    await add('Nedávna', lastUsed: DateTime(2026, 8, 20));

    final list = await db.getVessels();
    expect(list.map((v) => v.name).toList(), ['Nedávna', 'Stará']);
  });

  test('loď sa hľadá podľa mena bez ohľadu na veľkosť písmen', () async {
    await add('Perun', model: 'Bavaria 46');

    final found = await db.findVesselByName('  peRUN ');
    expect(found?.model, 'Bavaria 46');
    expect(await db.findVesselByName('Iná'), isNull);
    expect(await db.findVesselByName('   '), isNull);
  });

  test('opakované uloženie tú istú loď prepíše, nezaloží druhú', () async {
    final first = await add('Perun', model: 'Bavaria 46');
    await db.updateVessel(VesselsCompanion(
      id: Value(first.id),
      model: const Value('Bavaria 46 Cruiser'),
      mmsi: const Value('256123456'),
    ));

    final all = await db.getVessels();
    expect(all, hasLength(1));
    expect(all.single.model, 'Bavaria 46 Cruiser');
    expect(all.single.mmsi, '256123456');
  });

  test('použitie lode posunie jej poradie', () async {
    final old = await add('Stará', lastUsed: DateTime(2025, 6, 1));
    await add('Nedávna', lastUsed: DateTime(2026, 8, 20));

    await db.touchVessel(old.id);

    final list = await db.getVessels();
    expect(list.first.name, 'Stará');
  });

  test('zmazanie lode nechá zvyšok zoznamu', () async {
    final v = await add('Na zmazanie');
    await add('Ostáva');

    await db.deleteVessel(v.id);

    expect((await db.getVessels()).map((x) => x.name), ['Ostáva']);
  });
}
