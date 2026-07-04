import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

import '../generated_migrations/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('onCreate builds a schema matching the committed v7 snapshot', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 7);
  });

  test('migrate v7 to v8 (fuelLevel, waterLevel columns)', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 8);
  });

  test('onCreate builds a schema matching the committed v8 snapshot', () async {
    final connection = await verifier.startAt(8);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 8);
  });

  // PRAVIDLO: pri každom zvýšení schemaVersion pridaj nový
  // `dart run drift_dev schema dump ... drift_schemas/` a `schema generate`,
  // potom sem doplň `verifier.startAt(<staraVerzia>)` +
  // `migrateAndValidate(db, <novaVerzia>)` test pre danú fromXToY migráciu.
  // Postup: docs/migrations.md
}
