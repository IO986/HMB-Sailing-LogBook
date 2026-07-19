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

  test('onCreate builds a schema matching the current (v21) snapshot', () async {
    final connection = await verifier.startAt(21);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v7 to current (v21)', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v8 to current (v21)', () async {
    final connection = await verifier.startAt(8);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v9 to current (v21)', () async {
    final connection = await verifier.startAt(9);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v10 to current (v21): handoverProtocols.extraNotes', () async {
    final connection = await verifier.startAt(10);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v11 to current (v21): logbook record fields', () async {
    final connection = await verifier.startAt(11);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v12 to current (v21): Charters.source', () async {
    final connection = await verifier.startAt(12);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v13 to current (v21): extended charter form fields', () async {
    final connection = await verifier.startAt(13);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v14 to current (v21): trackPoints location metadata', () async {
    final connection = await verifier.startAt(14);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v15 to current (v21): logbookEntries location metadata', () async {
    final connection = await verifier.startAt(15);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v16 to current (v21): outbox table', () async {
    final connection = await verifier.startAt(16);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v17 to current (v21): tideSnapshots table', () async {
    final connection = await verifier.startAt(17);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v18 to current (v21): tide location label + manual flag',
      () async {
    final connection = await verifier.startAt(18);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v19 to current (v21): dutyPeriods table', () async {
    final connection = await verifier.startAt(19);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  test('migrate v20 to current (v21): logbookEntries.eventType', () async {
    final connection = await verifier.startAt(20);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 21);
  });

  // PRAVIDLO: pri každom zvýšení schemaVersion pridaj nový
  // `dart run drift_dev schema dump ... drift_schemas/` a `schema generate`,
  // potom sem doplň `verifier.startAt(<staraVerzia>)` +
  // `migrateAndValidate(db, <NOVÁ_NAJNOVŠIA_VERZIA>)` – vždy cieľ na aktuálne
  // najnovšiu verziu, nie na medzikrok. Postup: docs/migrations.md
}
