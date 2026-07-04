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

  test('onCreate builds a schema matching the current (v9) snapshot', () async {
    final connection = await verifier.startAt(9);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 9);
  });

  test('migrate v7 to current (v9)', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 9);
  });

  test('migrate v8 to current (v9): historicalVoyages table, charters.myRole', () async {
    final connection = await verifier.startAt(8);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 9);
  });

  // PRAVIDLO: pri každom zvýšení schemaVersion pridaj nový
  // `dart run drift_dev schema dump ... drift_schemas/` a `schema generate`,
  // potom sem doplň `verifier.startAt(<staraVerzia>)` +
  // `migrateAndValidate(db, <NOVÁ_NAJNOVŠIA_VERZIA>)` – vždy cieľ na aktuálne
  // najnovšiu verziu, nie na medzikrok. Postup: docs/migrations.md
}
