import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────────────────
// TABLES
// ─────────────────────────────────────────────────────────────

/// Celý charter (napr. "Plavba 2–9. máj 2026")
class Charters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();                    // "Plavba máj 2026"
  DateTimeColumn get dateFrom => dateTime()();
  DateTimeColumn get dateTo => dateTime()();
  TextColumn get vesselName => text().nullable()();    // názov lode
  TextColumn get vesselType => text().nullable()();    // Plachetnica / Katamaran...
  TextColumn get homePort => text().nullable()();      // domovský prístav
  TextColumn get skipperName => text().nullable()();
  TextColumn get crewNames => text().nullable()();     // pipe-separated
  TextColumn get notes => text().nullable()();
  BoolColumn get safetyBriefingDone => boolean().withDefault(const Constant(false))();
  BoolColumn get checkInDone => boolean().withDefault(const Constant(false))();
  BoolColumn get checkOutDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get remoteId => text().nullable()();       // UUID na serveri
  DateTimeColumn get syncedAt => dateTime().nullable()(); // posledná úspešná sync
  TextColumn get mmsi => text().nullable()();
  TextColumn get callsign => text().nullable()();
  RealColumn get vesselLengthM => real().nullable()();
  RealColumn get vesselBeamM => real().nullable()();
  RealColumn get vesselDraftM => real().nullable()();
  IntColumn get pdfRevision => integer().withDefault(const Constant(0))();
  TextColumn get myRole => text().nullable()(); // 'skipper' | 'coSkipper' | 'crew' | 'bosun' | 'radioOperator'
  // 'live' = plavba trackovaná/zapisovaná naživo v appke; 'gpx' = spätný
  // import staršej plavby zo súboru — slúži len na mapu a Knihu míľ,
  // nemá zmysel pre ňu pýtať check-in/SB/check-out ani ju ponúkať na
  // pokračovanie trackingu.
  TextColumn get source => text().withDefault(const Constant('live'))();
  // Rozšírený dotazník novej plavby (v14):
  TextColumn get vesselModel => text().nullable()();       // napr. Bavaria Cruiser 41
  TextColumn get charterCompany => text().nullable()();    // napr. Sunsail
  TextColumn get country => text().nullable()();           // krajina plavby
  TextColumn get cruisingArea => text().nullable()();      // oblasť, napr. Central Dalmatia
  IntColumn get berths => integer().nullable()();          // počet lôžok
  IntColumn get yearBuilt => integer().nullable()();       // rok výroby
  TextColumn get engine => text().nullable()();            // napr. Volvo Penta 40hp
  RealColumn get waterTankL => real().nullable()();
  RealColumn get fuelTankL => real().nullable()();
  RealColumn get engineHoursStart => real().nullable()();
  RealColumn get engineHoursEnd => real().nullable()();
  TextColumn get contactsJson => text().nullable()();      // JSON list telefónov chartru
  TextColumn get costsJson => text().nullable()();         // JSON list {label, amount}
  TextColumn get costCurrency => text().nullable()();      // mena nákladov, napr. EUR
  TextColumn get photosJson => text().nullable()();        // JSON list ciest k fotkám (max 3)
  // Detailná posádka {name, role, boatLicence, radioLicence} — skipperName
  // a crewNames sa z nej naďalej odvodzujú kvôli SB/PDF kompatibilite.
  TextColumn get crewJson => text().nullable()();
  // Polia pre oficiálny záznam Knihy míľ (ICC/RYA štýl) – vyplnené najmä pri
  // importovaných/trackovaných plavbách, kde chýbajú oproti ručne písaným
  // historickým plavbám.
  TextColumn get route => text().nullable()();               // trasa, ak sa líši od portFrom/portTo dní
  TextColumn get vesselFlag => text().nullable()();           // vlajka registrácie lode
  TextColumn get captainFirstName => text().nullable()();
  TextColumn get captainLastName => text().nullable()();
  TextColumn get captainQualification => text().nullable()(); // najvyššia dosiahnutá kvalifikácia
  TextColumn get logbookSignaturePath => text().nullable()(); // podpis kapitána potvrdzujúci míle
}

/// Jeden deň plavby
class DayLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get charterId => integer().references(Charters, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get portFrom => text().nullable()();     // prístav odchodu
  TextColumn get portTo => text().nullable()();       // prístav príchodu
  TextColumn get vesselForDay => text().nullable()(); // loď/čln pre tento deň
  RealColumn get distanceNm => real().withDefault(const Constant(0.0))();
  // Počasie ráno/poludnie/večer (Beaufort)
  IntColumn get beaufortMorning => integer().nullable()();
  IntColumn get beaufortNoon => integer().nullable()();
  IntColumn get beaufortEvening => integer().nullable()();
  // More
  TextColumn get seaState => text().nullable()();     // "pokojné/mierne/rozbúrené"
  RealColumn get waveHeightM => real().nullable()();
  // Vítor
  TextColumn get windDirection => text().nullable()(); // "NE", "SW"...
  // Teploty
  RealColumn get airTempC => real().nullable()();
  RealColumn get waterTempC => real().nullable()();
  // GPS session
  TextColumn get sessionId => text().nullable()();    // link na GPS tracking
  // Správa dňa
  TextColumn get skipperNote => text().nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
}

/// Hodinový záznam počas dňa
class LogbookEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayLogId => integer().nullable().references(DayLogs, #id)();
  TextColumn get sessionId => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get sog => real().nullable()();          // Speed Over Ground (kn)
  RealColumn get cog => real().nullable()();          // Course Over Ground (°)
  RealColumn get heading => real().nullable()();
  RealColumn get windSpeed => real().nullable()();    // kn
  RealColumn get windDirection => real().nullable()();
  RealColumn get waveHeight => real().nullable()();
  RealColumn get airPressure => real().nullable()();
  RealColumn get airTemp => real().nullable()();
  RealColumn get waterTemp => real().nullable()();
  RealColumn get engineHours => real().nullable()();
  RealColumn get fuelConsumed => real().nullable()();
  IntColumn get fuelLevel => integer().nullable()();  // stav nádrže 0–100 %
  IntColumn get waterLevel => integer().nullable()(); // stav nádrže 0–100 %
  TextColumn get skipperName => text().nullable()();
  TextColumn get crewNames => text().nullable()();
  TextColumn get skipperNote => text().nullable()();
  BoolColumn get isAutoEntry => boolean().withDefault(const Constant(false))();
  TextColumn get weatherCondition => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  // Kvalita GPS fixu z LocationFix (hmb_core) – staré riadky (pred v16)
  // majú NULL, spätne sa nedopočítava.
  RealColumn get accuracyMeters => real().nullable()();
  TextColumn get locationSource => text().nullable()();
  BoolColumn get isMocked => boolean().nullable()();
}

/// GPS track pointy
class TrackPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get speed => real().nullable()();
  RealColumn get course => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  // Doplnkové polia z LocationFix (hmb_core) – staré riadky majú NULL,
  // spätne sa nedopočítavajú.
  RealColumn get accuracyMeters => real().nullable()();
  TextColumn get locationSource => text().nullable()();
  BoolColumn get isMocked => boolean().nullable()();
}

/// GPS session (jedna plavba/deň)
class SailingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().unique()();
  IntColumn get dayLogId => integer().nullable().references(DayLogs, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get name => text().nullable()();
  RealColumn get totalDistanceNm => real().withDefault(const Constant(0.0))();
  RealColumn get maxSpeedKnots => real().withDefault(const Constant(0.0))();
  RealColumn get avgSpeedKnots => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// Waypoints
class Waypoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

/// Podpisy posádky na safety briefingu
class CrewSignatures extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get charterId => integer().references(Charters, #id)();
  TextColumn get crewName => text()();
  TextColumn get role => text().withDefault(const Constant('crew'))(); // 'skipper' | 'crew'
  TextColumn get signaturePath => text().nullable()();  // cesta k PNG súboru
  DateTimeColumn get signedAt => dateTime().nullable()();
}

/// Službukonajúca posádka — JEDEN RIADOK NA OSOBU.
///
/// Dvaja ľudia môžu nastúpiť do služby naraz, ale končia nezávisle, preto sa
/// spoločný nástup ukladá ako viac riadkov s rovnakým [fromUtc]; každý sa
/// uzatvára samostatne. Bežiaca služba = `toUtc IS NULL` — to je stav, ktorý
/// appka ukazuje kontrole na palube počas plavby.
///
/// Služba patrí charteru, nie dňu: [dayLogId] je len pomocný odkaz na deň,
/// v ktorom služba začala. Zaradenie do dňa (napr. v PDF) sa počíta prienikom
/// časov, aby služba cez polnoc nevypadla z druhého dňa.
class DutyPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get charterId => integer().references(Charters, #id)();
  IntColumn get dayLogId => integer().nullable().references(DayLogs, #id)();

  /// Odpis mena z posádky chartera v čase založenia. Zámerne nie FK: meno sa
  /// v charteri môže neskôr opraviť, ale už zapísaná služba je dôkazný záznam
  /// a meniť sa nesmie.
  TextColumn get crewName => text()();
  TextColumn get role => text().withDefault(const Constant('crew'))(); // 'skipper' | 'crew'

  DateTimeColumn get fromUtc => dateTime()();
  DateTimeColumn get toUtc => dateTime().nullable()();   // NULL = služba beží
  TextColumn get note => text().nullable()();

  /// True, ak službu uzavrel systém (napr. check-out), nie skipper ručne.
  BoolColumn get isAutoClosed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Počasie cache
class WeatherSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get forecastTime => dateTime()();
  DateTimeColumn get downloadedAt => dateTime()();
  RealColumn get windSpeed => real()();
  RealColumn get windDirection => real()();
  RealColumn get waveHeight => real().nullable()();
  RealColumn get wavePeriod => real().nullable()();
  RealColumn get airPressure => real().nullable()();
  RealColumn get airTemp => real().nullable()();
  RealColumn get waterTemp => real().nullable()();
  RealColumn get cloudCover => real().nullable()();
  IntColumn get weatherCode => integer().nullable()();
  IntColumn get precipitationProbability => integer().nullable()();  // 0–100 %
  RealColumn get precipitation => real().nullable()();               // mm
}

/// Kešované predikcie prílivu/odlivu (online fetch, offline zobrazenie —
/// rovnaký vzor ako [WeatherSnapshots]). `heightM` je výška hladiny nad
/// strednou hladinou mora (MSL), nie nad mapovým datom (LAT) a nie absolútna
/// hĺbka — na hĺbku pod kýlom sa nesmie použiť.
class TideSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get time => dateTime()();
  DateTimeColumn get downloadedAt => dateTime()();
  RealColumn get heightM => real()();
  /// 'high' / 'low' pri extrémoch (z providera), inak null (bod na krivke).
  TextColumn get extremeType => text().nullable()();
  /// Názov miesta, ak si ho používateľ vybral ručne (napr. "Split, Croatia").
  TextColumn get locationLabel => text().nullable()();
  /// True, ak predpoveď patrí ručne zvolenej oblasti, nie aktuálnej polohe —
  /// vtedy sa nesmie hlásiť, že je stiahnutá "ďaleko odtiaľto".
  BoolColumn get manualSelection =>
      boolean().withDefault(const Constant(false))();
}

/// Ručne zadaná historická plavba (spred používania appky) – plne sa
/// počíta do súhrnov v Knihe míľ.
class HistoricalVoyages extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dateFrom => dateTime()();
  DateTimeColumn get dateTo => dateTime()();
  TextColumn get vesselName => text()();
  TextColumn get vesselType => text().nullable()();
  TextColumn get area => text().nullable()();          // oblasť plavby
  RealColumn get distanceNm => real().withDefault(const Constant(0.0))();
  IntColumn get daysCount => integer().nullable()();    // ak null, dopočíta sa z dátumov
  RealColumn get nightHours => real().nullable()();
  TextColumn get role => text().withDefault(const Constant('skipper'))(); // funkcia na lodi, voľný text
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  // Polia pre oficiálny záznam Knihy míľ (ICC/RYA štýl), rovnaké ako na Charters.
  TextColumn get route => text().nullable()();
  TextColumn get vesselFlag => text().nullable()();
  TextColumn get captainFirstName => text().nullable()();
  TextColumn get captainLastName => text().nullable()();
  TextColumn get captainQualification => text().nullable()();
  TextColumn get logbookSignaturePath => text().nullable()();
}

/// Odovzdávací protokol lode (check-in pri prevzatí, check-out pri
/// vrátení) – max. jeden od každého typu na charter, uzavretie sa počíta
/// odvodene (obidva podpisy vyplnené), nie samostatným stĺpcom.
class HandoverProtocols extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get charterId => integer().references(Charters, #id)();
  TextColumn get type => text()(); // 'checkIn' | 'checkOut'
  DateTimeColumn get dateTimeUtc => dateTime()();
  TextColumn get location => text().nullable()(); // marína
  IntColumn get fuelLevel => integer().nullable()();  // 0-100 %
  IntColumn get waterLevel => integer().nullable()(); // 0-100 %
  RealColumn get engineHours => real().nullable()();
  TextColumn get checklistJson => text().withDefault(const Constant('[]'))();
  TextColumn get skipperName => text().nullable()();
  TextColumn get skipperSignaturePath => text().nullable()();
  DateTimeColumn get skipperSignedAt => dateTime().nullable()();
  TextColumn get companyRepName => text().nullable()();
  TextColumn get companyName => text().nullable()();
  TextColumn get companySignaturePath => text().nullable()();
  DateTimeColumn get companySignedAt => dateTime().nullable()();
  TextColumn get extraNotes => text().nullable()(); // poznámky mimo štandardného checklistu
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {charterId, type},
      ];
}

/// SQL-native backing store for `hmb_core`'s generic sync outbox
/// (`OutboxRepository`/`RecordStore` — see `lib/sync/drift_outbox_record_store.dart`).
/// Column shape mirrors `OutboxItem` field-for-field so `payload`/
/// `attachments` round-trip through JSON without reinterpreting them —
/// this app never reads those columns' contents directly, only
/// `hmb_core`'s own (de)serialization does.
///
/// Table name is explicitly `outbox` (not the pluralized default) to match
/// TASK_SYNC_ENGINE.md section 5 exactly; the Dart class is `OutboxRows`
/// (not `Outbox`/`OutboxItem`) so the drift-generated row type doesn't
/// collide with `hmb_core`'s own `OutboxItem` class where both are
/// imported together.
class OutboxRows extends Table {
  @override
  String get tableName => 'outbox';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get attachments => text()();
  TextColumn get status => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get lastHttpStatus => integer().nullable()();
  TextColumn get version => text().nullable()();
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────
// DATABASE
// ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Charters, DayLogs, LogbookEntries,
  TrackPoints, SailingSessions, Waypoints, WeatherSnapshots, CrewSignatures,
  HistoricalVoyages, HandoverProtocols, OutboxRows, TideSnapshots,
  DutyPeriods,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 20;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_outbox_status_created '
        'ON outbox (status, created_at)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(logbookEntries, logbookEntries.weatherCondition);
        await m.addColumn(logbookEntries, logbookEntries.photoPath);
        await m.addColumn(weatherSnapshots, weatherSnapshots.weatherCode);
      }
      if (from < 3) {
        await m.addColumn(weatherSnapshots, weatherSnapshots.precipitationProbability);
        await m.addColumn(weatherSnapshots, weatherSnapshots.precipitation);
      }
      if (from < 4) {
        await m.addColumn(charters, charters.remoteId);
        await m.addColumn(charters, charters.syncedAt);
      }
      if (from < 5) {
        await m.createTable(crewSignatures);
      }
      if (from < 6) {
        await m.addColumn(charters, charters.mmsi);
        await m.addColumn(charters, charters.callsign);
        await m.addColumn(charters, charters.vesselLengthM);
        await m.addColumn(charters, charters.vesselBeamM);
        await m.addColumn(charters, charters.vesselDraftM);
      }
      if (from < 7) {
        await m.addColumn(charters, charters.pdfRevision);
      }
      if (from < 8) {
        await m.addColumn(logbookEntries, logbookEntries.fuelLevel);
        await m.addColumn(logbookEntries, logbookEntries.waterLevel);
      }
      if (from < 9) {
        await m.createTable(historicalVoyages);
        await m.addColumn(charters, charters.myRole);
      } else if (from < 12) {
        // historicalVoyages už existuje (vzniklo vo v9) – createTable vyššie
        // by ho pri staršom `from` postavilo rovno s týmito stĺpcami, takže
        // addColumn tu smie bežať len keď tabuľka vznikla PRED v12.
        await m.addColumn(historicalVoyages, historicalVoyages.route);
        await m.addColumn(historicalVoyages, historicalVoyages.vesselFlag);
        await m.addColumn(historicalVoyages, historicalVoyages.captainFirstName);
        await m.addColumn(historicalVoyages, historicalVoyages.captainLastName);
        await m.addColumn(historicalVoyages, historicalVoyages.captainQualification);
        await m.addColumn(historicalVoyages, historicalVoyages.logbookSignaturePath);
      }
      if (from < 10) {
        // createTable stavia podľa AKTUÁLNEJ definície tabuľky (vrátane
        // extraNotes), takže tu sa nižšie addColumn pre extraNotes
        // nesmie zopakovať – inak "duplicate column name" pri migrácii
        // z verzie < 10.
        await m.createTable(handoverProtocols);
      } else if (from < 11) {
        await m.addColumn(handoverProtocols, handoverProtocols.extraNotes);
      }
      if (from < 12) {
        await m.addColumn(charters, charters.route);
        await m.addColumn(charters, charters.vesselFlag);
        await m.addColumn(charters, charters.captainFirstName);
        await m.addColumn(charters, charters.captainLastName);
        await m.addColumn(charters, charters.captainQualification);
        await m.addColumn(charters, charters.logbookSignaturePath);
      }
      if (from < 13) {
        await m.addColumn(charters, charters.source);
      }
      if (from < 14) {
        await m.addColumn(charters, charters.vesselModel);
        await m.addColumn(charters, charters.charterCompany);
        await m.addColumn(charters, charters.country);
        await m.addColumn(charters, charters.cruisingArea);
        await m.addColumn(charters, charters.berths);
        await m.addColumn(charters, charters.yearBuilt);
        await m.addColumn(charters, charters.engine);
        await m.addColumn(charters, charters.waterTankL);
        await m.addColumn(charters, charters.fuelTankL);
        await m.addColumn(charters, charters.engineHoursStart);
        await m.addColumn(charters, charters.engineHoursEnd);
        await m.addColumn(charters, charters.contactsJson);
        await m.addColumn(charters, charters.costsJson);
        await m.addColumn(charters, charters.costCurrency);
        await m.addColumn(charters, charters.photosJson);
        await m.addColumn(charters, charters.crewJson);
      }
      if (from < 15) {
        await m.addColumn(trackPoints, trackPoints.accuracyMeters);
        await m.addColumn(trackPoints, trackPoints.locationSource);
        await m.addColumn(trackPoints, trackPoints.isMocked);
      }
      if (from < 16) {
        await m.addColumn(logbookEntries, logbookEntries.accuracyMeters);
        await m.addColumn(logbookEntries, logbookEntries.locationSource);
        await m.addColumn(logbookEntries, logbookEntries.isMocked);
      }
      if (from < 17) {
        await m.createTable(outboxRows);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_outbox_status_created '
          'ON outbox (status, created_at)',
        );
      }
      if (from < 18) {
        // createTable stavia AKTUÁLNY tvar tabuľky, teda už aj so stĺpcami
        // pridanými v v19 — preto sa nasledujúci blok pre tieto DB preskočí.
        await m.createTable(tideSnapshots);
      }
      if (from >= 18 && from < 19) {
        await m.addColumn(tideSnapshots, tideSnapshots.locationLabel);
        await m.addColumn(tideSnapshots, tideSnapshots.manualSelection);
      }
      if (from < 20) {
        // Rovnaká pasca ako pri tideSnapshots vyššie: createTable stavia
        // AKTUÁLNY tvar, takže prípadný neskorší addColumn blok pre
        // dutyPeriods musí byť strážený `from >= 20`.
        await m.createTable(dutyPeriods);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ── Charters ────────────────────────────────────────────────

  Future<List<Charter>> getAllCharters() =>
      (select(charters)..orderBy([(c) => OrderingTerm.desc(c.dateFrom)])).get();

  Future<Charter?> getCharterById(int id) =>
      (select(charters)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Charter> insertCharter(ChartersCompanion c) async {
    final id = await into(charters).insert(c);
    return (select(charters)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateCharter(ChartersCompanion c) =>
      (update(charters)..where((t) => t.id.equals(c.id.value))).write(c);

  Future<void> updateCharterSync(int id,
      {required String remoteId, required DateTime syncedAt}) =>
      (update(charters)..where((t) => t.id.equals(id))).write(
        ChartersCompanion(
          remoteId: Value(remoteId),
          syncedAt: Value(syncedAt),
        ),
      );

  /// Inkrementuje počítadlo revízií PDF a vráti nové číslo.
  Future<int> incrementPdfRevision(int charterId) async {
    final charter = await (select(charters)..where((t) => t.id.equals(charterId))).getSingle();
    final newRev = charter.pdfRevision + 1;
    await (update(charters)..where((t) => t.id.equals(charterId))).write(
      ChartersCompanion(pdfRevision: Value(newRev)),
    );
    return newRev;
  }

  Future<void> deleteCharter(int id) async {
    final days = await getDayLogs(id);
    for (final d in days) {
      await deleteDayLog(d.id);
    }
    await deleteSignaturesForCharter(id);
    await deleteHandoverProtocolsForCharter(id);
    await deleteDutyPeriodsForCharter(id);
    await (delete(charters)..where((c) => c.id.equals(id))).go();
  }

  // ── Day Logs ─────────────────────────────────────────────────

  Future<List<DayLog>> getDayLogs(int charterId) =>
      (select(dayLogs)
            ..where((d) => d.charterId.equals(charterId))
            ..orderBy([(d) => OrderingTerm(expression: d.date)]))
          .get();

  Future<DayLog> insertDayLog(DayLogsCompanion d) async {
    final id = await into(dayLogs).insert(d);
    return (select(dayLogs)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateDayLog(DayLogsCompanion d) =>
      (update(dayLogs)..where((t) => t.id.equals(d.id.value))).write(d);

  Future<void> deleteDayLog(int id) async {
    // Služby sa NEmažú — patria charteru, nie dňu, a sú dôkazný záznam.
    // Odkaz na deň sa len vynuluje, inak by FK zhodilo mazanie dňa.
    await (update(dutyPeriods)..where((w) => w.dayLogId.equals(id)))
        .write(const DutyPeriodsCompanion(dayLogId: Value(null)));
    await (delete(logbookEntries)..where((e) => e.dayLogId.equals(id))).go();
    await (delete(sailingSessions)..where((s) => s.dayLogId.equals(id))).go();
    await (delete(dayLogs)..where((d) => d.id.equals(id))).go();
  }

  Future<void> deleteDayLogs(List<int> ids) async {
    for (final id in ids) { await deleteDayLog(id); }
  }

  Future<DayLog?> getDayLogById(int id) =>
      (select(dayLogs)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<int?> getLatestDayLogId() async {
    final rows = await (select(dayLogs)
          ..orderBy([(d) => OrderingTerm.desc(d.date)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first.id;
  }

  // ── Logbook Entries ──────────────────────────────────────────

  Future<List<LogbookEntry>> getEntriesForDay(int dayLogId) =>
      (select(logbookEntries)
            ..where((e) => e.dayLogId.equals(dayLogId))
            ..orderBy([(e) => OrderingTerm(expression: e.timestamp)]))
          .get();

  Stream<List<LogbookEntry>> watchEntriesForDay(int dayLogId) =>
      (select(logbookEntries)
            ..where((e) => e.dayLogId.equals(dayLogId))
            ..orderBy([(e) => OrderingTerm(expression: e.timestamp)]))
          .watch();

  Stream<List<LogbookEntry>> watchMappableEntriesForDay(int dayLogId) =>
      (select(logbookEntries)
            ..where((e) => e.dayLogId.equals(dayLogId) & e.latitude.isNotNull())
            ..orderBy([(e) => OrderingTerm(expression: e.timestamp)]))
          .watch();

  Future<List<LogbookEntry>> getEntriesForSession(String sessionId) =>
      (select(logbookEntries)
            ..where((e) => e.sessionId.equals(sessionId))
            ..orderBy([(e) => OrderingTerm(expression: e.timestamp)]))
          .get();

  Future<int> insertLogbookEntry(LogbookEntriesCompanion e) =>
      into(logbookEntries).insert(e);

  Future<void> updateLogbookEntry(int id, LogbookEntriesCompanion entry) =>
      (update(logbookEntries)..where((e) => e.id.equals(id))).write(entry);

  Future<void> deleteLogbookEntry(int id) =>
      (delete(logbookEntries)..where((e) => e.id.equals(id))).go();

  Future<void> deleteLogbookEntries(List<int> ids) async {
    for (final id in ids) { await deleteLogbookEntry(id); }
  }

  Future<void> deleteEntriesForDay(int dayLogId) =>
      (delete(logbookEntries)..where((e) => e.dayLogId.equals(dayLogId))).go();

  // ── Track Points ─────────────────────────────────────────────

  Future<int> insertTrackPoint(TrackPointsCompanion e) =>
      into(trackPoints).insert(e);

  /// Vloží veľa bodov v jednej transakcii – oproti `insertTrackPoint` volanému
  /// v cykle je toto rádovo rýchlejšie (GPX import vie mať desaťtisíce bodov,
  /// jednotlivé awaitované inserty by bežali cez DB izolát jeden po druhom).
  Future<void> insertTrackPointsBatch(List<TrackPointsCompanion> points) =>
      batch((b) => b.insertAll(trackPoints, points));

  Future<List<TrackPoint>> getTrackPointsForSession(String sessionId) =>
      (select(trackPoints)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
          .get();

  // ── Sessions ─────────────────────────────────────────────────

  Future<int> upsertSession(SailingSessionsCompanion s) =>
      into(sailingSessions).insertOnConflictUpdate(s);

  Future<SailingSession?> getActiveSession() =>
      (select(sailingSessions)
            ..where((s) => s.isActive.equals(true))
            ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<SailingSession>> getSessionsForDay(int dayLogId) =>
      (select(sailingSessions)..where((s) => s.dayLogId.equals(dayLogId))).get();

  Future<void> fixOrphanedSessions() async {
    final active = await (select(sailingSessions)
          ..where((s) => s.isActive.equals(true))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .get();
    if (active.length > 1) {
      for (final s in active.skip(1)) {
        await (update(sailingSessions)..where((r) => r.id.equals(s.id)))
            .write(SailingSessionsCompanion(
          isActive: const Value(false),
          endTime: Value(s.startTime.add(const Duration(minutes: 1))),
        ));
      }
      debugPrint('[DB] Fixed ${active.length - 1} orphaned sessions');
    }
  }

  // ── Waypoints ─────────────────────────────────────────────────

  Future<List<Waypoint>> getAllWaypoints() =>
      (select(waypoints)..orderBy([(w) => OrderingTerm(expression: w.name)])).get();

  Future<int> insertWaypoint(WaypointsCompanion e) =>
      into(waypoints).insert(e);

  Future<void> deleteWaypoint(int id) =>
      (delete(waypoints)..where((w) => w.id.equals(id))).go();

  Future<void> updateWaypointName(int id, String name) =>
      (update(waypoints)..where((w) => w.id.equals(id)))
          .write(WaypointsCompanion(name: Value(name)));

  // ── Weather ───────────────────────────────────────────────────

  Future<int> insertWeatherSnapshot(WeatherSnapshotsCompanion e) =>
      into(weatherSnapshots).insert(e);

  Future<void> clearAllWeather() => delete(weatherSnapshots).go();

  Future<void> clearOldWeather() =>
      (delete(weatherSnapshots)
            ..where((w) => w.downloadedAt.isSmallerThanValue(
                DateTime.now().subtract(const Duration(hours: 72)))))
          .go();

  Future<List<WeatherSnapshot>> getWeatherSnapshots() =>
      (select(weatherSnapshots)
            ..orderBy([(w) => OrderingTerm(expression: w.forecastTime)]))
          .get();

  // ── Tide ──────────────────────────────────────────────────────

  Future<int> insertTideSnapshot(TideSnapshotsCompanion e) =>
      into(tideSnapshots).insert(e);

  Future<void> clearAllTides() => delete(tideSnapshots).go();

  /// Atomicky nahradí celú kešu novou sadou. Stará keš zmizne až vtedy, keď
  /// sú nové dáta po ruke — zlyhaný fetch tak nesmie pripraviť používateľa
  /// o predpoveď, ktorá dovtedy fungovala.
  Future<void> replaceTides(List<TideSnapshotsCompanion> rows) =>
      transaction(() async {
        await delete(tideSnapshots).go();
        await batch((b) => b.insertAll(tideSnapshots, rows));
      });

  Future<List<TideSnapshot>> getTideSnapshots() =>
      (select(tideSnapshots)..orderBy([(t) => OrderingTerm(expression: t.time)]))
          .get();

  // ── Crew Signatures ───────────────────────────────────────────

  Stream<List<CrewSignature>> watchSignaturesForCharter(int charterId) =>
      (select(crewSignatures)
            ..where((s) => s.charterId.equals(charterId))
            ..orderBy([(s) => OrderingTerm(expression: s.id)]))
          .watch();

  Future<List<CrewSignature>> getSignaturesForCharter(int charterId) =>
      (select(crewSignatures)
            ..where((s) => s.charterId.equals(charterId))
            ..orderBy([(s) => OrderingTerm(expression: s.id)]))
          .get();

  Future<void> upsertCrewSignature(CrewSignaturesCompanion sig) =>
      into(crewSignatures).insertOnConflictUpdate(sig);

  Future<void> deleteSignaturesForCharter(int charterId) =>
      (delete(crewSignatures)..where((s) => s.charterId.equals(charterId))).go();

  // ── Duty Periods (službukonajúca posádka) ────────────────────

  /// Práve bežiace služby (`toUtc IS NULL`). Stream, aby inšpekčná obrazovka
  /// zostala živá aj keď službu založí iná obrazovka.
  Stream<List<DutyPeriod>> watchRunningDuties(int charterId) =>
      (select(dutyPeriods)
            ..where((w) => w.charterId.equals(charterId) & w.toUtc.isNull())
            ..orderBy([(w) => OrderingTerm(expression: w.fromUtc)]))
          .watch();

  Future<List<DutyPeriod>> getRunningDuties(int charterId) =>
      (select(dutyPeriods)
            ..where((w) => w.charterId.equals(charterId) & w.toUtc.isNull())
            ..orderBy([(w) => OrderingTerm(expression: w.fromUtc)]))
          .get();

  Stream<List<DutyPeriod>> watchDutiesForCharter(int charterId) =>
      (select(dutyPeriods)
            ..where((w) => w.charterId.equals(charterId))
            ..orderBy([(w) => OrderingTerm.desc(w.fromUtc)]))
          .watch();

  /// Služby, ktoré zasahujú do okna [from, to). Bežiaca služba (`toUtc` NULL)
  /// sa počíta ako trvajúca donekonečna, takže do okna zasiahne vždy, keď
  /// začala pred jeho koncom.
  ///
  /// Toto je metóda, ktorou sa služby zaraďujú do dní — nie cez `dayLogId`,
  /// aby služba cez polnoc vyšla na oboch denných stranách.
  Future<List<DutyPeriod>> getDutiesOverlapping(
    int charterId,
    DateTime fromUtc,
    DateTime toUtc,
  ) =>
      (select(dutyPeriods)
            ..where((w) =>
                w.charterId.equals(charterId) &
                w.fromUtc.isSmallerThanValue(toUtc) &
                (w.toUtc.isNull() | w.toUtc.isBiggerThanValue(fromUtc)))
            ..orderBy([(w) => OrderingTerm(expression: w.fromUtc)]))
          .get();

  Future<int> insertDutyPeriod(DutyPeriodsCompanion w) =>
      into(dutyPeriods).insert(w);

  Future<void> closeDutyPeriod(int id, DateTime toUtc,
          {bool isAutoClosed = false}) =>
      (update(dutyPeriods)..where((w) => w.id.equals(id))).write(
        DutyPeriodsCompanion(
          toUtc: Value(toUtc),
          isAutoClosed: Value(isAutoClosed),
        ),
      );

  /// Uzavrie všetky bežiace služby chartera — použije sa pri check-oute.
  /// Zámerne sa nevolá na časovači: automaticky dopísaný koniec by bol čas,
  /// ktorý skipper nikdy nevidel.
  Future<void> closeAllRunningDuties(int charterId, DateTime toUtc) =>
      (update(dutyPeriods)
            ..where((w) => w.charterId.equals(charterId) & w.toUtc.isNull()))
          .write(DutyPeriodsCompanion(
        toUtc: Value(toUtc),
        isAutoClosed: const Value(true),
      ));

  Future<void> updateDutyPeriod(int id, DutyPeriodsCompanion w) =>
      (update(dutyPeriods)..where((t) => t.id.equals(id))).write(w);

  Future<void> deleteDutyPeriod(int id) =>
      (delete(dutyPeriods)..where((w) => w.id.equals(id))).go();

  Future<void> deleteDutyPeriodsForCharter(int charterId) =>
      (delete(dutyPeriods)..where((w) => w.charterId.equals(charterId))).go();

  // ── Historical Voyages (Kniha míľ) ─────────────────────────────

  Future<List<HistoricalVoyage>> getAllHistoricalVoyages() =>
      (select(historicalVoyages)
            ..orderBy([(v) => OrderingTerm.desc(v.dateFrom)]))
          .get();

  Future<int> insertHistoricalVoyage(HistoricalVoyagesCompanion v) =>
      into(historicalVoyages).insert(v);

  Future<void> updateHistoricalVoyage(int id, HistoricalVoyagesCompanion v) =>
      (update(historicalVoyages)..where((t) => t.id.equals(id))).write(v);

  Future<void> deleteHistoricalVoyage(int id) =>
      (delete(historicalVoyages)..where((t) => t.id.equals(id))).go();

  // ── Handover Protocols (check-in/check-out) ────────────────────

  Future<HandoverProtocol?> getHandoverProtocol(int charterId, String type) =>
      (select(handoverProtocols)
            ..where((h) => h.charterId.equals(charterId) & h.type.equals(type)))
          .getSingleOrNull();

  Future<int> upsertHandoverProtocol(HandoverProtocolsCompanion h) =>
      into(handoverProtocols).insert(
        h,
        onConflict: DoUpdate(
          (old) => h,
          target: [handoverProtocols.charterId, handoverProtocols.type],
        ),
      );

  Future<void> deleteHandoverProtocolsForCharter(int charterId) =>
      (delete(handoverProtocols)..where((h) => h.charterId.equals(charterId))).go();

  // ── Outbox (hmb_core sync engine RecordStore backing) ──────────

  Future<void> upsertOutboxRow(OutboxRowsCompanion row) =>
      into(outboxRows).insertOnConflictUpdate(row);

  Future<OutboxRow?> getOutboxRow(String id) =>
      (select(outboxRows)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<OutboxRow>> getAllOutboxRows() => select(outboxRows).get();

  Future<void> deleteOutboxRow(String id) =>
      (delete(outboxRows)..where((r) => r.id.equals(id))).go();

  /// Every outbox row, for the sync queue screen's item list. Counts for
  /// the header badge come from `OutboxRepository.watchQueue()` instead —
  /// this is only for rendering the actual list.
  Stream<List<OutboxRow>> watchAllOutboxRows() => select(outboxRows).watch();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sailing_logbook.db'));
    return NativeDatabase.createInBackground(file);
  });
}
