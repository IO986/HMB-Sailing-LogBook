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
   test('migrate v<STARÁ> to current (v<NOVÁ>)', () async {
     final connection = await verifier.startAt(<STARÁ>);
     final db = AppDatabase.forTesting(connection);
     addTearDown(db.close);
     await verifier.migrateAndValidate(db, <NOVÁ>);
   });
   ```
   **DÔLEŽITÉ**: druhý argument `migrateAndValidate(db, X)` musí byť VŽDY
   aktuálne najnovší `schemaVersion`, nikdy medzikrok. `onUpgrade` je reťaz
   `if (from < N)` blokov bez ohľadu na `to` — pri behu appky sa vždy
   migruje až na najnovšiu verziu, takže test na medzikrok (napr. cieľ v8
   keď existuje aj v9) skončí falošným zlyhaním, lebo neskorší `from < 9`
   blok sa aj tak potichu spustí a pridá stĺpce/tabuľky navyše oproti
   staršiemu očakávanému snapshotu. Preto pri KAŽDEJ ďalšej fáze uprav aj
   existujúce staršie testy tak, aby ich `migrateAndValidate` cieľ
   ukazoval na novú najnovšiu verziu (nie na verziu z čias, keď boli
   napísané).
6. **Spusti testy**: `flutter test`.

## Známe pasce
- Ak `app_database.g.dart` chýba/je prázdny: zmaž ho aj `.dart_tool/build`,
  spusti `build_runner` znova.
- `flutter pub get` vie posunúť `intl` — po ňom vždy
  `flutter pub add intl:^0.20.2`.
- Editácia existujúceho záznamu vždy cez `update`, nikdy `insert`
  (duplicitné riadky).
- **`createTable` vs `addColumn` pre stĺpec pridaný do tej istej tabuľky
  o pár verzií neskôr**: `m.createTable(tabulka)` stavia tabuľku podľa
  AKTUÁLNEJ definície v kóde (nie podľa historického stavu v čase, keď
  bola tabuľka vytvorená) — ak teda pridáš nový stĺpec do tabuľky, ktorá
  vznikla v skoršej migrácii, a napíšeš samostatný `addColumn` krok pre
  neskoršiu verziu, migrácia z verzie PRED vznikom tabuľky zlyhá s
  `duplicate column name` (createTable ho už vytvoril, addColumn sa ho
  potom pokúsi pridať znova). Rieš cez `if (from < <verzia_vzniku_tabulky>)
  createTable(...) else if (from < <verzia_noveho_stlpca>) addColumn(...)`
  — nie dva samostatné `if (from < N)` bloky za sebou.
- Ak `flutter test`/`flutter build` zlyhá s `PathAccessException:
  Deletion failed ... sqlite3.dll (Access is denied)`: zvyškový
  `flutter_tester.exe` proces z predchádzajúceho (napr. prerušeného)
  behu drží zámok na DLL — ukonči ho (`Get-Process flutter_tester |
  Stop-Process -Force`) a skús znova.
