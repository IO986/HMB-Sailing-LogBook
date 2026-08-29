import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

import '../generated_migrations/schema.dart';

/// DÔLEŽITÉ: `onUpgrade` v app_database.dart je reťaz `if (from < N)` blokov
/// bez ohľadu na cieľovú verziu (`to`) – keď appka migruje, vždy migruje až
/// na aktuálny `schemaVersion`. Preto musí `migrateAndValidate(db, target)`
/// nižšie VŽDY používať `target == AppDatabase().schemaVersion` (aktuálne
/// najnovšia verzia), nikdy medzikrok – inak neskorší `from < N` blok potichu
/// pridá stĺpce/tabuľky navyše oproti staršiemu očakávanému snapshotu a test
/// nezmyselne zlyhá (objavené pri v7→v8 teste po pridaní v9).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('onCreate builds a schema matching the current (v29) snapshot', () async {
    final connection = await verifier.startAt(29);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v7 to current (v31)', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v8 to current (v31)', () async {
    final connection = await verifier.startAt(8);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v9 to current (v31)', () async {
    final connection = await verifier.startAt(9);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v10 to current (v31): handoverProtocols.extraNotes', () async {
    final connection = await verifier.startAt(10);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v11 to current (v31): logbook record fields', () async {
    final connection = await verifier.startAt(11);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v12 to current (v31): Charters.source', () async {
    final connection = await verifier.startAt(12);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v13 to current (v31): extended charter form fields', () async {
    final connection = await verifier.startAt(13);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v14 to current (v31): trackPoints location metadata', () async {
    final connection = await verifier.startAt(14);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v15 to current (v31): logbookEntries location metadata', () async {
    final connection = await verifier.startAt(15);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v16 to current (v31): outbox table', () async {
    final connection = await verifier.startAt(16);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v17 to current (v31): tideSnapshots table', () async {
    final connection = await verifier.startAt(17);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v18 to current (v31): tide location label + manual flag',
      () async {
    final connection = await verifier.startAt(18);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v19 to current (v31): dutyPeriods table', () async {
    final connection = await verifier.startAt(19);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v20 to current (v31): logbookEntries.eventType', () async {
    final connection = await verifier.startAt(20);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v21 to current (v31): logbookEntries.sailMode', () async {
    final connection = await verifier.startAt(21);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('v22 moves the old [motor,main] note prefix into sailMode', () async {
    // Shape is not enough here: rows written before v22 carry the propulsion
    // inside the note and would otherwise lose it. The rows have to exist
    // *before* the migration runs, so they go in through the raw v21 database
    // — the first query on an AppDatabase would already upgrade it.
    final schema = await verifier.schemaAt(21);
    schema.rawDatabase.execute(
        "INSERT INTO logbook_entries (timestamp, skipper_note) "
        "VALUES (0, '[motor,main] Vyplavanie z mariny')");
    schema.rawDatabase.execute(
        "INSERT INTO logbook_entries (timestamp, skipper_note) "
        "VALUES (0, 'Zaznam bez prefixu')");

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 31);

    final rows = await db.select(db.logbookEntries).get();
    final withPrefix =
        rows.firstWhere((r) => r.skipperNote == 'Vyplavanie z mariny');
    expect(withPrefix.sailMode, 'motor,main',
        reason: 'the propulsion moves into its own column');

    final plain = rows.firstWhere((r) => r.skipperNote == 'Zaznam bez prefixu');
    // `isNull` would clash with drift's expression builder of the same name.
    expect(plain.sailMode, null, reason: 'a note without a prefix is left alone');
  });

  test('migrate v22 to current (v31): crewAssessments table', () async {
    final connection = await verifier.startAt(22);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v23 to current (v31): charters.tidalWaters', () async {
    final connection = await verifier.startAt(23);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v24 to current (v31): bearings table', () async {
    final connection = await verifier.startAt(24);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v25 to current (v31): bearings.hiddenFromMap', () async {
    final connection = await verifier.startAt(25);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v28 to current (v31): sail direction columns', () async {
    final connection = await verifier.startAt(28);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v29 to current (v31): depth + engine hours', () async {
    final connection = await verifier.startAt(29);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  test('migrate v30 to current (v31): anchor watch flag on sessions', () async {
    final connection = await verifier.startAt(30);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 31);
  });

  // PRAVIDLO: pri každom zvýšení schemaVersion pridaj nový
  // `dart run drift_dev schema dump ... drift_schemas/` a `schema generate`,
  // potom sem doplň `verifier.startAt(<staraVerzia>)` +
  // `migrateAndValidate(db, <NOVÁ_NAJNOVŠIA_VERZIA>)` – vždy cieľ na aktuálne
  // najnovšiu verziu, nie na medzikrok. Postup: docs/migrations.md
}
