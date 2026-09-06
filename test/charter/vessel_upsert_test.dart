import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/charter/services/vessel_upsert.dart';

/// Zmysel zoznamu lodí je opakovaná plavba na tej istej lodi: kto pláva na
/// svojej, nemá pri každej plavbe znova prepisovať model, volací znak, MMSI,
/// rozmery a nádrže. Databázová vrstva bola otestovaná, cesta z formulára nie —
/// a presne v takej diere sa stratila pamäť skipera v builde 69.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  const perun = VesselDraft(
    name: 'Perun',
    model: 'Bavaria 46',
    mmsi: '256123456',
    lengthM: 14.2,
    isOwn: true,
  );

  test('prvá plavba loď založí', () async {
    final id = await upsertVesselFromDraft(db, perun);

    expect(id, isNotNull);
    final saved = (await db.getVessels()).single;
    expect(saved.name, 'Perun');
    expect(saved.model, 'Bavaria 46');
    expect(saved.mmsi, '256123456');
    expect(saved.isOwn, isTrue);
    expect(saved.lastUsedAt, isNotNull);
  });

  test('druhá plavba na tej istej lodi nezaloží druhú loď', () async {
    await upsertVesselFromDraft(db, perun);
    await upsertVesselFromDraft(db, perun);

    expect(await db.getVessels(), hasLength(1));
  });

  test('meno sa páruje bez ohľadu na veľkosť písmen a medzery', () async {
    await upsertVesselFromDraft(db, perun);
    await upsertVesselFromDraft(db, const VesselDraft(name: '  perun '));

    final all = await db.getVessels();
    expect(all, hasLength(1));
    // Meno sa zapíše tak, ako ho skiper naposledy napísal — ale bez medzier
    // navyše, aby sa z jednej lode nestali dve.
    expect(all.single.name, 'perun');
  });

  test('doplnené údaje sa do uloženej lode zapíšu', () async {
    await upsertVesselFromDraft(db, const VesselDraft(name: 'Perun'));
    await upsertVesselFromDraft(db, perun);

    final saved = (await db.getVessels()).single;
    expect(saved.model, 'Bavaria 46');
    expect(saved.lengthM, 14.2);
  });

  /// Plavba založená rýchlym štartom nesie z lode často len meno. Keby sa
  /// takým uložením prepísali uložené údaje na NULL, zoznam lodí by si sám
  /// mazal to, kvôli čomu existuje.
  test('loď nájdená podľa mena si údaje, ktoré formulár nenesie, ponechá',
      () async {
    await upsertVesselFromDraft(db, perun);

    await upsertVesselFromDraft(db, const VesselDraft(name: 'Perun'));

    final saved = (await db.getVessels()).single;
    expect(saved.model, 'Bavaria 46');
    expect(saved.mmsi, '256123456');
    expect(saved.lengthM, 14.2);
  });

  /// Loď vybranú zo zoznamu skiper edituje celú — vymazané pole sa naozaj
  /// vymaže, inak by sa raz zle zadané MMSI nedalo odstrániť.
  test('pri vybranej lodi vymazané pole naozaj vymaže údaj', () async {
    final id = await upsertVesselFromDraft(db, perun);

    await upsertVesselFromDraft(
        db, const VesselDraft(name: 'Perun', model: 'Bavaria 46'),
        knownId: id);

    final saved = (await db.getVessels()).single;
    expect(saved.model, 'Bavaria 46');
    expect(saved.mmsi, isNull, reason: 'vyprázdnené pole sa má prejaviť');
  });

  /// Loď vybraná zo zoznamu sa dá premenovať a musí ostať tá istá — inak by
  /// preklep v mene ticho založil druhú loď.
  test('premenovanie vybranej lode prepíše ten istý riadok', () async {
    final id = await upsertVesselFromDraft(db, perun);

    await upsertVesselFromDraft(
      db,
      const VesselDraft(name: 'Perun II', model: 'Bavaria 46'),
      knownId: id,
    );

    final all = await db.getVessels();
    expect(all, hasLength(1));
    expect(all.single.id, id);
    expect(all.single.name, 'Perun II');
  });

  test('iná loď je iný riadok', () async {
    await upsertVesselFromDraft(db, perun);
    await upsertVesselFromDraft(db, const VesselDraft(name: 'Kirke'));

    expect((await db.getVessels()).map((v) => v.name), containsAll(['Perun', 'Kirke']));
  });

  test('loď bez mena sa neuloží', () async {
    final id = await upsertVesselFromDraft(db, const VesselDraft(name: '   '));

    expect(id, isNull);
    expect(await db.getVessels(), isEmpty);
  });

  /// Poradie v zozname riadi lastUsedAt — loď, na ktorej sa práve plaví, má
  /// byť pri ďalšej plavbe navrchu.
  test('opakované uloženie posunie loď dopredu', () async {
    await upsertVesselFromDraft(db, const VesselDraft(name: 'Stará'),
        now: DateTime(2025, 6, 1));
    await upsertVesselFromDraft(db, const VesselDraft(name: 'Nová'),
        now: DateTime(2026, 8, 1));
    expect((await db.getVessels()).first.name, 'Nová');

    await upsertVesselFromDraft(db, const VesselDraft(name: 'Stará'),
        now: DateTime(2026, 9, 1));
    expect((await db.getVessels()).first.name, 'Stará');
  });

  test('vlastná loď stojí pred charterovými', () async {
    await upsertVesselFromDraft(db, const VesselDraft(name: 'Charterová'),
        now: DateTime(2026, 9, 1));
    await upsertVesselFromDraft(db, perun, now: DateTime(2025, 1, 1));

    expect((await db.getVessels()).first.name, 'Perun');
  });

  test('loď zmazaná zo zoznamu sa pri ďalšej plavbe založí znova', () async {
    final id = await upsertVesselFromDraft(db, perun);
    await db.deleteVessel(id!);

    // Formulár si stále pamätá staré id — nesmie na ňom uviaznuť.
    final again = await upsertVesselFromDraft(db, perun, knownId: id);

    expect(again, isNotNull);
    expect((await db.getVessels()).single.name, 'Perun');
  });

  test('vessels companion neprepíše createdAt pri aktualizácii', () async {
    final id = await upsertVesselFromDraft(db, perun, now: DateTime(2026, 1, 1));
    final created = (await db.getVesselById(id!))!.createdAt;

    await upsertVesselFromDraft(db, perun, knownId: id, now: DateTime(2026, 9, 1));

    expect((await db.getVesselById(id))!.createdAt, created);
    expect((await db.getVesselById(id))!.lastUsedAt, DateTime(2026, 9, 1));
  });
}
