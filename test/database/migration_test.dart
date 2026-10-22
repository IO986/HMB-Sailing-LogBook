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

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v7 to current (v37)', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v8 to current (v37)', () async {
    final connection = await verifier.startAt(8);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v9 to current (v37)', () async {
    final connection = await verifier.startAt(9);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v10 to current (v37): handoverProtocols.extraNotes', () async {
    final connection = await verifier.startAt(10);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v11 to current (v37): logbook record fields', () async {
    final connection = await verifier.startAt(11);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v12 to current (v37): Charters.source', () async {
    final connection = await verifier.startAt(12);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v13 to current (v37): extended charter form fields', () async {
    final connection = await verifier.startAt(13);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v14 to current (v37): trackPoints location metadata', () async {
    final connection = await verifier.startAt(14);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v15 to current (v37): logbookEntries location metadata', () async {
    final connection = await verifier.startAt(15);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v16 to current (v37): outbox table', () async {
    final connection = await verifier.startAt(16);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v17 to current (v37): tideSnapshots table', () async {
    final connection = await verifier.startAt(17);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v18 to current (v37): tide location label + manual flag',
      () async {
    final connection = await verifier.startAt(18);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v19 to current (v37): dutyPeriods table', () async {
    final connection = await verifier.startAt(19);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v20 to current (v37): logbookEntries.eventType', () async {
    final connection = await verifier.startAt(20);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v21 to current (v37): logbookEntries.sailMode', () async {
    final connection = await verifier.startAt(21);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
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
    await verifier.migrateAndValidate(db, 37);

    final rows = await db.select(db.logbookEntries).get();
    final withPrefix =
        rows.firstWhere((r) => r.skipperNote == 'Vyplavanie z mariny');
    expect(withPrefix.sailMode, 'motor,main',
        reason: 'the propulsion moves into its own column');

    final plain = rows.firstWhere((r) => r.skipperNote == 'Zaznam bez prefixu');
    // `isNull` would clash with drift's expression builder of the same name.
    expect(plain.sailMode, null, reason: 'a note without a prefix is left alone');
  });

  test('migrate v22 to current (v37): crewAssessments table', () async {
    final connection = await verifier.startAt(22);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v23 to current (v37): charters.tidalWaters', () async {
    final connection = await verifier.startAt(23);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v24 to current (v37): bearings table', () async {
    final connection = await verifier.startAt(24);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v25 to current (v37): bearings.hiddenFromMap', () async {
    final connection = await verifier.startAt(25);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v28 to current (v37): sail direction columns', () async {
    final connection = await verifier.startAt(28);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v29 to current (v37): depth + engine hours', () async {
    final connection = await verifier.startAt(29);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v30 to current (v37): anchor watch flag on sessions', () async {
    final connection = await verifier.startAt(30);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v31 to current (v37): tidal waters on historical voyages',
      () async {
    final connection = await verifier.startAt(31);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v32 to current (v37): vessels table', () async {
    final connection = await verifier.startAt(32);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  // PRAVIDLO: pri každom zvýšení schemaVersion pridaj nový
  // `dart run drift_dev schema dump ... drift_schemas/` a `schema generate`,
  // potom sem doplň `verifier.startAt(<staraVerzia>)` +
  // `migrateAndValidate(db, <NOVÁ_NAJNOVŠIA_VERZIA>)` – vždy cieľ na aktuálne
  // najnovšiu verziu, nie na medzikrok. Postup: docs/migrations.md

  test('migrate v33 to current (v37)', () async {
    final connection = await verifier.startAt(33);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v34 to current (v37): sync uuid + updatedAt columns',
      () async {
    final connection = await verifier.startAt(34);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  // Rows have to exist before the upgrade: the v35 backfill reads them, and an
  // empty-table migration never touches that code. Restoring a v34 backup on
  // build 81 crashed exactly here ("Null check operator used on a null value").
  void insertV34Rows(dynamic raw) {
    raw.execute("INSERT INTO charters (title, date_from, date_to, created_at) "
        "VALUES ('Kornati', 0, 86400, 100)");
    raw.execute("INSERT INTO day_logs (charter_id, date) VALUES (1, 200)");
    raw.execute("INSERT INTO logbook_entries (timestamp) VALUES (300)");
    raw.execute("INSERT INTO waypoints (name, latitude, longitude, created_at) "
        "VALUES ('Zut', 43.9, 15.3, 400)");
    raw.execute("INSERT INTO sailing_sessions (session_id, start_time) "
        "VALUES ('s1', 500)");
  }

  Future<void> expectSyncColumnsFilled(AppDatabase db) async {
    for (final (table, source) in const [
      ('charters', 'created_at'),
      ('day_logs', 'date'),
      ('logbook_entries', 'timestamp'),
      ('waypoints', 'created_at'),
    ]) {
      final row = (await db
              .customSelect('SELECT sync_uuid, updated_at, $source AS src '
                  'FROM $table')
              .get())
          .single;
      expect(row.read<String?>('sync_uuid'), hasLength(36), reason: table);
      expect(row.read<int?>('updated_at'), row.read<int>('src'), reason: table);
    }
    final session = (await db
            .customSelect('SELECT updated_at, start_time FROM sailing_sessions')
            .get())
        .single;
    expect(session.read<int?>('updated_at'), session.read<int>('start_time'));
    expect((await db.getAllCharters()).single.archived, false);
  }

  test('v34 with rows migrates to current (v37) and backfills sync columns',
      () async {
    final schema = await verifier.schemaAt(34);
    insertV34Rows(schema.rawDatabase);

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 37);

    await expectSyncColumnsFilled(db);
  });

  test('v34 left half-migrated by the crashed backfill still upgrades',
      () async {
    // What the crash left on the phone: v35 columns added, user_version
    // still 34. The next start re-runs the v35 step on top of them.
    final schema = await verifier.schemaAt(34);
    insertV34Rows(schema.rawDatabase);
    // Same DDL drift's addColumn wrote on the phone (`"sync_uuid" TEXT NULL`).
    for (final t in ['charters', 'day_logs', 'logbook_entries', 'waypoints']) {
      schema.rawDatabase
          .execute('ALTER TABLE $t ADD COLUMN "sync_uuid" TEXT NULL');
      schema.rawDatabase
          .execute('ALTER TABLE $t ADD COLUMN "updated_at" INTEGER NULL');
    }
    schema.rawDatabase.execute(
        'ALTER TABLE sailing_sessions ADD COLUMN "updated_at" INTEGER NULL');

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 37);

    await expectSyncColumnsFilled(db);
  });

  test('migrate v35 to current (v37): charters.archived', () async {
    final connection = await verifier.startAt(35);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);
  });

  test('migrate v36 to current (v37): night hours by hand + estimated track',
      () async {
    final connection = await verifier.startAt(36);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 37);

    // Old rows keep working and the new columns start empty / false.
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'x',
      dateFrom: DateTime(2026, 7, 1),
      dateTo: DateTime(2026, 7, 1),
      createdAt: DateTime(2026, 7, 1),
    ));
    final d = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: c.id, date: DateTime(2026, 7, 1)));
    expect(d.nightHoursManual, equals(null)); // drift also exports isNull
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 's',
      dayLogId: Value(d.id),
      startTime: DateTime(2026, 7, 1),
    ));
    expect((await db.getSessionsForDay(d.id)).single.isEstimated, isFalse);
  });
}
