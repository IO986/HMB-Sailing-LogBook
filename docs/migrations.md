# Ako pridať novú Drift migráciu

Databáza (`lib/core/database/app_database.dart`) používa stepwise
migrácie (žiadny `destructiveFallback` — dáta používateľov sa pri
update appky nemažú). Pri každej zmene schémy (nová tabuľka, nový
stĺpec, zmena typu...) postupuj takto:

1. **Uprav tabuľky** v `app_database.dart` (nový stĺpec ako `nullable()`,
   nová tabuľka atď.) a **zvýš `schemaVersion`** o 1.
2. **Napíš migračný krok** v `onUpgrade`:
   ```dart
   if (from < <NOVÁ_VERZIA>) {
     await m.addColumn(tabulka, tabulka.novyStlpec);
     // alebo: await m.createTable(novaTabulka);
   }
   ```
3. **Spusti build_runner**, aby sa vygeneroval `app_database.g.dart`:
   ```
   dart run build_runner build
   ```
4. **Vytvor nový schema snapshot**:
   ```
   dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/
   ```
   Vytvorí `drift_schemas/drift_schema_v<NOVÁ_VERZIA>.json`. Starší
   commitnutý snapshot (napr. v7) sa nemaže — potrebný pre test
   upgrade cesty zo starej verzie.
5. **Rozšír test** `test/database/migration_test.dart`:
   ```
   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
   ```
   (prepíše `schema.dart`/pridá `schema_v<N>.dart`), potom doplň test:
   ```dart
   test('migrate v<STARÁ> to v<NOVÁ>', () async {
     final connection = await verifier.startAt(<STARÁ>);
     final db = AppDatabase.forTesting(connection);
     addTearDown(db.close);
     await verifier.migrateAndValidate(db, <NOVÁ>);
   });
   ```
6. **Spusti testy**: `flutter test`.

## Známe pasce
- Ak `app_database.g.dart` chýba/je prázdny: zmaž ho aj `.dart_tool/build`,
  spusti `build_runner` znova.
- `flutter pub get` vie posunúť `intl` — po ňom vždy
  `flutter pub add intl:^0.20.2`.
- Editácia existujúceho záznamu vždy cez `update`, nikdy `insert`
  (duplicitné riadky).
