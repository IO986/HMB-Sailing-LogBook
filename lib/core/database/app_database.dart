import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/distance_calculator.dart';

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
  // Prílivové vs. neprílivové vody — RYA a školy to na potvrdení o míľach
  // rozlišujú. NULL = skiper to pri plavbe neurčil.
  BoolColumn get tidalWaters => boolean().nullable()();
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

  /// Machine-readable kind of an automatic entry (see [LogbookEventType]),
  /// e.g. 'anchor_dropped'. NULL for ordinary manual entries.
  ///
  /// Exists so the UI and the PDF can recognise an event without matching on
  /// the note text. That matching is why `skipperNote` accumulated three
  /// spellings of "voyage start" — including a raw l10n key that leaked into
  /// the database — and why the note could never be translated. Rows written
  /// before v21 have NULL here and are resolved from the note as a fallback.
  TextColumn get eventType => text().nullable()();

  /// Spôsob plavby v čase záznamu: 'motor', 'main', 'genoa', 'reef1', 'reef2',
  /// viac naraz oddelených čiarkou.
  ///
  /// Do v21 sa to ukladalo ako prefix `[motor,main]` v `skipperNote`, takže
  /// automatické záznamy (tie poznámku nepíšu v tomto tvare) spôsob plavby
  /// nemali vôbec a detail im ho dopĺňal na 'motor' — z terénu: "v detaile je
  /// vždy motor, aj keď som ho vypol". v22 prefix vyťahuje do stĺpca.
  TextColumn get sailMode => text().nullable()();

  /// Kurz voči vetru (`close_hauled` … `running`) a bok, na ktorom vietor
  /// prichádza (`S`/`P`).
  ///
  /// Papierový denník to má ako jedno políčko so siluetou lode; tu sú to dva
  /// stĺpce, lebo pri behu na plný vietor bok neexistuje a `tack` vtedy ostáva
  /// prázdny. Nezamieňať so [sailMode], ktorý hovorí, čo je vytiahnuté.
  TextColumn get pointOfSail => text().nullable()();
  TextColumn get tack => text().nullable()();

  TextColumn get weatherCondition => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  // Kvalita GPS fixu z LocationFix (hmb_core) – staré riadky (pred v16)
  // majú NULL, spätne sa nedopočítava.
  RealColumn get accuracyMeters => real().nullable()();
  TextColumn get locationSource => text().nullable()();
  BoolColumn get isMocked => boolean().nullable()();

  /// Odkiaľ pochádzajú hodnoty počasia v tomto zázname:
  /// `nmea` (lodné prístroje), `dhmz` (pozemná stanica), `model` (predpoveď).
  ///
  /// Doteraz sa zdroj lepil do textu poznámky ("Auto [NMEA]"), odkiaľ sa
  /// nedal prečítať ani preložiť ani dostať do PDF. V dokladovateľnom
  /// zázname musí byť vidno, či je hodnota meraná alebo počítaná.
  TextColumn get weatherSource => text().nullable()();

  /// Názov stanice pri `weatherSource == 'dhmz'`, inak `null`.
  TextColumn get weatherStation => text().nullable()();

  /// Ako ďaleko bola stanica v okamihu zápisu. Bez tohto je názov stanice
  /// polovičná informácia — vietor spoza kopca 20 km ďaleko je niečo iné
  /// než vietor z majáka, pri ktorom loď práve stojí.
  RealColumn get weatherStationDistanceM => real().nullable()();
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

/// Vizuálne zameranie námerovým kompasom.
///
/// Jeden riadok = jedno namierenie telefónu, ale úloha je dvojaká a rozhoduje
/// o nej [kind] (kód z `BearingKind`):
///
/// * `resection` — zameriaval sa ZNÁMY bod (waypoint) a hľadá sa poloha
///   pozorovateľa. Vtedy je [observerLat]/[observerLon] NULL, pretože práve
///   to je neznáme, a naopak `target*` je vyplnené. GPS netreba.
/// * `intersection` — zameriaval sa NEZNÁMY objekt zo známej polohy a hľadá sa
///   ten objekt. Vtedy je vyplnený pozorovateľ a `target*` je NULL. GPS treba.
///
/// Preto sú obe skupiny súradníc nullable: presne jedna z nich je pri každom
/// riadku známa. Invariant drží `BearingKind.needsObserverPosition` /
/// `needsKnownTarget` a kontroluje ho `BearingRepository.capture`.
///
/// Zámerne sa ukladá aj surový magnetický kurz, aj použitá deklinácia, aj
/// výsledný pravý kurz. Samotný `trueBearing` by stačil na kreslenie, ale
/// zameranie je navigačný záznam: keď sa neskôr vymenia WMM koeficienty,
/// musí sa dať pozrieť, s akou opravou bol riadok zapísaný — a magnetický
/// kurz je to jediné, čo prístroj naozaj nameral.
class Bearings extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Druh zamerania — stabilný kód z `BearingKind`, nikdy preložený text.
  TextColumn get kind => text()();

  /// Poloha pozorovateľa v okamihu zamerania.
  ///
  /// NULL pri resekcii: tam sa poloha pozorovateľa počíta z priesečníka, nie
  /// zapisuje. To je celý dôvod, prečo resekcia funguje aj bez GPS.
  RealColumn get observerLat => real().nullable()();
  RealColumn get observerLon => real().nullable()();

  /// Presnosť GPS fixu (m) v okamihu zamerania, ak bola známa.
  RealColumn get accuracyMeters => real().nullable()();

  /// Zameraný známy bod — waypoint, na ktorý skiper mieril (len resekcia).
  ///
  /// Ukladá sa odkaz AJ odfotená kópia názvu a súradníc. Je to zámerne opačné
  /// rozhodnutie než pri `navTargetIdProvider`, ktorý drží len id, aby
  /// navigácia zomrela so zmazaným bodom: zameranie je archívny záznam
  /// merania, ktoré sa naozaj stalo, a zmazanie waypointu ho nesmie
  /// prepísať ani zneplatniť.
  ///
  /// `onDelete: setNull` zámerne: zmazanie waypointu z mapy nesmie ani zhodiť
  /// mazanie (FK by ho odmietlo), ani zmazať zameranie. Odkaz zmizne, odpis
  /// polohy a názvu zostane, takže riadok je v denníku aj v PDF ďalej čitateľný.
  IntColumn get targetWaypointId => integer()
      .nullable()
      .references(Waypoints, #id, onDelete: KeyAction.setNull)();
  RealColumn get targetLat => real().nullable()();
  RealColumn get targetLon => real().nullable()();
  TextColumn get targetName => text().nullable()();

  /// Nameraný magnetický kurz (°), tak ako prišiel z magnetometra.
  RealColumn get magneticBearing => real()();

  /// Magnetická deklinácia použitá na prevod (°, východ kladný).
  RealColumn get declination => real()();

  /// Odkiaľ sa vzala poloha, na ktorej sa deklinácia vyhodnotila:
  /// `gps`, `target` alebo `lastKnown`.
  ///
  /// Pri resekcii bez GPS sa WMM počíta v mieste zameraného waypointu —
  /// deklinácia sa na niekoľkých míľach nezmení natoľko, aby to bolo merateľné.
  /// Len na doloženie, ako riadok vznikol; nikdy sa podľa toho nerozhoduje.
  TextColumn get declinationSource => text().nullable()();

  /// Pravý kurz (°) = magnetický + deklinácia, znormalizovaný do 0–360.
  RealColumn get trueBearing => real()();

  /// Polovičná šírka kužeľa neistoty (°).
  ///
  /// Telefónový kompas na lodi má reálne ±5–10° kvôli železu a elektronike.
  /// Čiara sa preto kreslí ako kužeľ — tenká čiara by tvrdila presnosť,
  /// ktorú meranie nemá.
  RealColumn get uncertaintyDeg =>
      real().withDefault(const Constant(8.0))();

  /// Skupina zameraní na ten istý neznámy objekt (len `intersection`).
  ///
  /// Reverzná triangulácia zbiera námery na jeden objekt z rôznych polôh, aj
  /// s hodinovým odstupom. Spájať ich podľa času či uhla by pri dvoch skalách
  /// vedľa seba tichom vyrobilo nezmyselný priesečník, preto skupinu určuje
  /// skiper a drží ju toto id. Názov objektu je v [label], rovnaký pre celú
  /// skupinu.
  TextColumn get sightGroupId => text().nullable()();

  /// Pri `intersection` názov hľadaného objektu (rovnaký pre celú skupinu),
  /// pri `resection` voliteľná poznámka k meraniu.
  TextColumn get label => text().nullable()();

  /// Fotka scény v okamihu zamerania.
  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get takenAt => dateTime()();

  /// Deň a plavba, do ktorých zameranie patrí. NULL, ak sa zameriavalo
  /// mimo aktívneho trackingu.
  IntColumn get dayLogId => integer().nullable().references(DayLogs, #id)();
  IntColumn get charterId => integer().nullable().references(Charters, #id)();

  /// Skryté z mapy, ale zameranie samo zostáva — mazanie z mapy je vedomé
  /// upratanie zaplnenej mapy počas plavby, nie rozhodnutie zahodiť záznam.
  ///
  /// Skutočné zmazanie riadku je len na dennom zázname (`day_log_screen`,
  /// `bearing_session_screen`): tam skiper vidí zameranie ako riadok
  /// v denníku, nie ako čiaru medzi desiatkami iných na preplnenej mape, a
  /// má tak šancu si rozmyslieť, či ho naozaj zahodiť.
  BoolColumn get hiddenFromMap =>
      boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
        // Resekcia bez zameraného bodu je len uhol bez zmyslu; hľadanie
        // objektu bez polohy pozorovateľa nemá odkiaľ vychádzať. Radšej
        // výnimka pri zápise než riadok, ktorý sa nedá nakresliť ani vysvetliť.
        "CHECK ((kind = 'resection' AND target_lat IS NOT NULL "
            "AND target_lon IS NOT NULL AND sight_group_id IS NULL) OR "
            "(kind = 'intersection' AND observer_lat IS NOT NULL "
            "AND observer_lon IS NOT NULL AND sight_group_id IS NOT NULL))",
      ];
}

/// Podpisy posádky na safety briefingu
/// Hodnotenie člena posádky od skipera po plavbe (RYA štýl).
///
/// Zručnosti sú 1–5, NULL znamená "neriešené" — skiper nemusí hodnotiť to,
/// čo počas plavby nevidel. Jeden riadok na dvojicu (plavba, člen posádky);
/// posádka nemá vlastnú tabuľku, drží sa v Charters.crewJson, preto je
/// kľúčom meno.
class CrewAssessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get charterId => integer().references(Charters, #id)();
  TextColumn get crewName => text()();
  IntColumn get helming => integer().nullable()();
  IntColumn get navigation => integer().nullable()();
  IntColumn get harbourManoeuvres => integer().nullable()();
  IntColumn get teamwork => integer().nullable()();
  IntColumn get nightSailing => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}

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
  RealColumn get precipitation => real().nullable()();

  /// Ktorý model hodnotu vyrobil (napr. "ARPAE ICON-2I").
  ///
  /// Uložené s dátami, nie dopočítané pri zobrazení: keď sa loď medzitým
  /// presunie do inej krajiny, kešovaná predpoveď stále pochádza z modelu,
  /// ktorý platil tam, kde sa sťahovala. Prázdne pri starších záznamoch.
  TextColumn get modelName => text().nullable()();               // mm
}

/// Kešované merania z pozemných staníc DHMZ (meteo.hr).
///
/// Na rozdiel od [WeatherSnapshots] to nie je predpoveď, ale hodnota, ktorú
/// niekto naozaj nameral. Do denníka má prednosť pred modelom — pozri
/// `DhmzObservationService`.
///
/// Tabuľka je keš, nie archív: pri každej synchronizácii sa prepíše celá.
/// Historické hodnoty netreba, do záznamu sa hodnota kopíruje v okamihu zápisu.
class DhmzObservations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get station => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  /// Čas merania v UTC. Podľa neho sa zahadzujú zastarané feedy.
  DateTimeColumn get observedAt => dateTime()();
  DateTimeColumn get downloadedAt => dateTime()();

  RealColumn get airTemp => real().nullable()();
  RealColumn get airPressure => real().nullable()();

  /// Zmena tlaku za 3 h (hPa). Model túto hodnotu nedáva vôbec.
  RealColumn get pressureTendency => real().nullable()();

  RealColumn get windSpeedKnots => real().nullable()();

  /// `null` znamená bezvetrie alebo chýbajúci údaj — smer vtedy neexistuje.
  RealColumn get windDirectionDeg => real().nullable()();

  RealColumn get waterTemp => real().nullable()();
}

/// Úradné výstrahy pred nebezpečným počasím (MeteoAlarm).
///
/// Nie je to model ani meranie, ale rozhodnutie národnej meteorologickej
/// služby — v Chorvátsku DHMZ, v Británii Met Office, vo Švédsku SMHI.
/// MeteoAlarm je len spoločná strecha, pod ktorou tie služby svoje výstrahy
/// zverejňujú, takže jedna integrácia pokrýva celú Európu.
///
/// Tabuľka je keš, nie archív: pri každej synchronizácii sa prepíše celá.
class WeatherWarnings extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Identifikátor z CAP — to isté varovanie sa v novšom vydaní feedu
  /// objaví s tým istým identifikátorom.
  TextColumn get identifier => text()();

  /// Dvojpísmenový kód krajiny, ktorej feed to priniesol.
  TextColumn get country => text()();

  /// Oblasť platnosti tak, ako ju pomenoval vydavateľ ("Coastal Zadar").
  TextColumn get areaDesc => text()();

  /// Typ výstrahy vo vetách vydavateľa ("Yellow thunderstorm warning").
  TextColumn get event => text()();

  /// Stupeň 1–4 podľa MeteoAlarm: zelená, žltá, oranžová, červená.
  IntColumn get awarenessLevel => integer()();

  /// Odkedy platí a dokedy, v UTC. Po `expires` sa výstraha nezobrazuje.
  DateTimeColumn get onset => dateTime()();
  DateTimeColumn get expires => dateTime()();

  DateTimeColumn get downloadedAt => dateTime()();

  /// Text v jazyku, ktorý sa vo feede našiel — nie nutne v jazyku appky.
  TextColumn get description => text().nullable()();
  TextColumn get instruction => text().nullable()();

  /// Jazyk, v ktorom sú [description] a [instruction] naozaj napísané.
  /// UI to musí vedieť: tvrdiť, že je to po slovensky, keď je to po
  /// chorvátsky, je horšie než to nepovedať vôbec.
  TextColumn get language => text().nullable()();

  /// Kto výstrahu vydal ("DHMZ Državni hidrometeorološki zavod").
  TextColumn get sender => text().nullable()();

  /// Odkaz na podrobný dokument CAP.
  ///
  /// Popis a pokyn sa doťahujú až keď o ne niekto požiada: sú tam vo viacerých
  /// jazykoch a sťahovať ich pre všetky výstrahy v krajine dopredu by bolo
  /// desiatky dotazov za text, ktorý väčšinou nikto neotvorí.
  TextColumn get capUrl => text().nullable()();
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
  CrewAssessments,
  HistoricalVoyages, HandoverProtocols, OutboxRows, TideSnapshots,
  DutyPeriods, Bearings, DhmzObservations, WeatherWarnings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 29;

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
      if (from < 21) {
        // logbookEntries sa v onUpgrade nikdy nevytvára cez createTable,
        // takže tu pasca vyššie neplatí a addColumn stačí bez gardy.
        await m.addColumn(logbookEntries, logbookEntries.eventType);
      }
      if (from < 22) {
        await m.addColumn(logbookEntries, logbookEntries.sailMode);
        // Prefix z poznámky presuň do stĺpca a poznámku nechaj čistú.
        await customStatement(
          "UPDATE logbook_entries "
          "SET sail_mode = substr(skipper_note, 2, instr(skipper_note, ']') - 2), "
          "    skipper_note = ltrim(substr(skipper_note, instr(skipper_note, ']') + 1)) "
          "WHERE skipper_note LIKE '[%]%'",
        );
      }
      if (from < 23) {
        await m.createTable(crewAssessments);
      }
      if (from < 24) {
        await m.addColumn(charters, charters.tidalWaters);
      }
      if (from < 25) {
        // createTable stavia AKTUÁLNY tvar tabuľky (vrátane hiddenFromMap
        // pridaného v26), takže nasledujúci addColumn blok pre DB staršie
        // než 25 nesmie bežať — rovnaká pasca ako pri tideSnapshots vyššie.
        await m.createTable(bearings);
      }
      if (from >= 25 && from < 26) {
        await m.addColumn(bearings, bearings.hiddenFromMap);
      }
      if (from < 27) {
        await m.createTable(dhmzObservations);
        await m.addColumn(logbookEntries, logbookEntries.weatherSource);
        await m.addColumn(logbookEntries, logbookEntries.weatherStation);
        await m.addColumn(
            logbookEntries, logbookEntries.weatherStationDistanceM);
      }
      if (from < 28) {
        await m.createTable(weatherWarnings);
        await m.addColumn(weatherSnapshots, weatherSnapshots.modelName);
      }
      if (from < 29) {
        await m.addColumn(logbookEntries, logbookEntries.pointOfSail);
        await m.addColumn(logbookEntries, logbookEntries.tack);
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
    // Zamerania mimo dní (zapísané bez aktívneho trackingu) by inak zostali
    // s odkazom na zmazanú plavbu a FK by mazanie odmietlo.
    await (delete(bearings)..where((b) => b.charterId.equals(id))).go();
    // Bez tohto by FK zhodilo mazanie plavby, ktorej posádku skiper hodnotil.
    await (delete(crewAssessments)..where((a) => a.charterId.equals(id))).go();
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
    // Zamerania patria dňu rovnako ako denníkové záznamy, takže idú s ním —
    // a bez tohto by ich FK odkaz mazanie dňa zhodil.
    await (delete(bearings)..where((b) => b.dayLogId.equals(id))).go();
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

  /// Every entry in the whole database, not scoped to a day/session —
  /// used by the sync backfill button to find entries that predate the
  /// user turning sync on (see `lib/sync/log_entry_backfill_service.dart`).
  Future<List<LogbookEntry>> getAllLogbookEntries() =>
      select(logbookEntries).get();

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

  /// Posledný známy spôsob plavby v danom dni.
  ///
  /// Automatické záznamy ho preberajú od posledného záznamu — skiper prepne
  /// motor/plachty raz a ďalšie automatické zápisy majú pokračovať v tom, čo
  /// zadal, nie mlčky hlásiť motor.
  Future<String?> lastSailModeForDay(int dayLogId) async {
    final rows = await (select(logbookEntries)
          ..where((e) => e.dayLogId.equals(dayLogId) & e.sailMode.isNotNull())
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first.sailMode;
  }

  /// Posledný zapísaný kurz voči vetru v danom dni.
  ///
  /// Rovnaká logika ako pri [lastSailModeForDay]: kurz sa nemení každou
  /// minútou, takže automatické záznamy ho preberajú od posledného zápisu.
  /// Skiper ho prepne pri obrate a medzitým platí ďalej. Vracia dvojicu
  /// kódov tak, ako sú v stĺpcoch — preklad na model je vecou volajúceho.
  Future<({String? pointOfSail, String? tack})?> lastSailDirectionForDay(
      int dayLogId) async {
    final rows = await (select(logbookEntries)
          ..where((e) => e.dayLogId.equals(dayLogId) & e.pointOfSail.isNotNull())
          ..orderBy([(e) => OrderingTerm.desc(e.timestamp)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    return (pointOfSail: rows.first.pointOfSail, tack: rows.first.tack);
  }

  Future<void> updateSessionDistance(int id, double distanceNm) =>
      (update(sailingSessions)..where((s) => s.id.equals(id)))
          .write(SailingSessionsCompanion(totalDistanceNm: Value(distanceNm)));

  /// Vzdialenosť už zaznamenaná pre daný deň, prepočítaná z uložených bodov.
  ///
  /// DayLog.distanceNm ani SailingSession.totalDistanceNm sa nedajú brať ako
  /// základ pre pokračujúcu plavbu: zapisujú sa priebežne, ale posledný úsek
  /// pred vypnutím appky sa do nich dostať nemusí. Body v DB sú jediné, čo
  /// vypnutie appky uprostred plavby spoľahlivo prežije (nahlásené z terénu:
  /// po nechcenom vypnutí appky mal denník iba druhú časť plavby).
  Future<double> recordedDistanceNmForDay(int dayLogId,
      {String? excludeSessionId}) async {
    var total = 0.0;
    for (final session in await getSessionsForDay(dayLogId)) {
      if (session.sessionId == excludeSessionId) continue;
      final points = await getTrackPointsForSession(session.sessionId);
      for (var i = 1; i < points.length; i++) {
        final nm = DistanceCalculator.distanceM(
              points[i - 1].latitude, points[i - 1].longitude,
              points[i].latitude, points[i].longitude,
            ) /
            1852;
        // Rovnaký filter ako pri živom počítaní — ignoruj GPS skoky.
        if (nm < 10) total += nm;
      }
    }
    return total;
  }

  /// Session, ktorá sa nikdy neukončila — appku vypol systém alebo užívateľ
  /// uprostred trasovania.
  ///
  /// Rozlišovacím znakom je endTime: ten zapisuje jedine stopTracking(), takže
  /// jeho absencia znamená, že plavba nebola ukončená v appke. Netreba na to
  /// žiadny časový limit.
  Future<SailingSession?> getInterruptedSession() =>
      (select(sailingSessions)
            ..where((s) => s.endTime.isNull() & s.isActive.equals(true))
            ..orderBy([(s) => OrderingTerm.desc(s.startTime)])
            ..limit(1))
          .getSingleOrNull();

  Future<TrackPoint?> getLastTrackPoint(String sessionId) =>
      (select(trackPoints)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(1))
          .getSingleOrNull();

  /// Uzavrie prerušenú session časom posledného zaznamenaného bodu.
  ///
  /// Predtým dostala endTime = štart + 1 minúta, takže trojhodinový úsek
  /// vyzeral v exporte ako minútový a kazil trvanie aj priemernú rýchlosť.
  Future<void> closeInterruptedSession(SailingSession session) async {
    final last = await getLastTrackPoint(session.sessionId);
    await (update(sailingSessions)..where((r) => r.id.equals(session.id)))
        .write(SailingSessionsCompanion(
      isActive: const Value(false),
      endTime: Value(last?.timestamp ?? session.startTime),
    ));
  }

  Future<void> fixOrphanedSessions() async {
    final active = await (select(sailingSessions)
          ..where((s) => s.isActive.equals(true))
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .get();
    if (active.length > 1) {
      for (final s in active.skip(1)) {
        await closeInterruptedSession(s);
      }
      debugPrint('[DB] Fixed ${active.length - 1} orphaned sessions');
    }
  }

  // ── Crew assessments ─────────────────────────────────────────

  Future<List<CrewAssessment>> getCrewAssessments(int charterId) =>
      (select(crewAssessments)..where((a) => a.charterId.equals(charterId)))
          .get();

  Future<CrewAssessment?> getCrewAssessment(int charterId, String crewName) =>
      (select(crewAssessments)
            ..where((a) => a.charterId.equals(charterId) & a.crewName.equals(crewName))
            ..limit(1))
          .getSingleOrNull();

  /// Uloží hodnotenie; kľúčom je dvojica (plavba, meno). Meno sa dá v karte
  /// plavby prepísať, takže staré hodnotenie sa nespáruje — to je vedomé,
  /// hodnotenie patrí konkrétnemu človeku, nie riadku v zozname.
  Future<void> upsertCrewAssessment(CrewAssessmentsCompanion entry) async {
    final existing =
        await getCrewAssessment(entry.charterId.value, entry.crewName.value);
    if (existing == null) {
      await into(crewAssessments).insert(entry);
      return;
    }
    await (update(crewAssessments)..where((a) => a.id.equals(existing.id)))
        .write(entry);
  }

  Future<void> deleteCrewAssessment(int id) =>
      (delete(crewAssessments)..where((a) => a.id.equals(id))).go();

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

  // ── Zamerania (námerový kompas) ────────────────────────────────

  /// Zamerania od najnovšieho po najstaršie.
  Future<List<Bearing>> getAllBearings() => (select(bearings)
        ..orderBy([
          (b) => OrderingTerm(
              expression: b.takenAt, mode: OrderingMode.desc)
        ]))
      .get();

  /// Živý zoznam zameraní pre mapu — po zapísaní nového sa čiara objaví
  /// bez toho, aby si obrazovka musela pýtať obnovu.
  Stream<List<Bearing>> watchAllBearings() => (select(bearings)
        ..orderBy([
          (b) => OrderingTerm(
              expression: b.takenAt, mode: OrderingMode.desc)
        ]))
      .watch();

  Future<List<Bearing>> getBearingsForDay(int dayLogId) => (select(bearings)
        ..where((b) => b.dayLogId.equals(dayLogId))
        ..orderBy([(b) => OrderingTerm(expression: b.takenAt)]))
      .get();

  Future<List<Bearing>> getBearingsForCharter(int charterId) =>
      (select(bearings)
            ..where((b) => b.charterId.equals(charterId))
            ..orderBy([(b) => OrderingTerm(expression: b.takenAt)]))
          .get();

  /// Zamerania jednej skupiny (jeden hľadaný neznámy objekt), od najstaršieho.
  Future<List<Bearing>> getBearingsInGroup(String sightGroupId) =>
      (select(bearings)
            ..where((b) => b.sightGroupId.equals(sightGroupId))
            ..orderBy([(b) => OrderingTerm(expression: b.takenAt)]))
          .get();

  Future<int> insertBearing(BearingsCompanion e) => into(bearings).insert(e);

  /// Zmaže celú skupinu námerov na jeden objekt — buď sa hľadaný bod uloží
  /// ako waypoint, alebo sa pátranie vzdá; polovica námerov nie je na nič.
  Future<void> deleteBearingGroup(String sightGroupId) =>
      (delete(bearings)..where((b) => b.sightGroupId.equals(sightGroupId)))
          .go();

  /// Skryje zameranie z mapy bez zmazania riadku — vidno ho ďalej v denníku
  /// aj v PDF, len sa prestane kresliť. Skutočné zmazanie je `deleteBearing`.
  Future<void> hideBearingFromMap(int id) =>
      (update(bearings)..where((b) => b.id.equals(id)))
          .write(const BearingsCompanion(hiddenFromMap: Value(true)));

  Future<void> hideBearingGroupFromMap(String sightGroupId) =>
      (update(bearings)..where((b) => b.sightGroupId.equals(sightGroupId)))
          .write(const BearingsCompanion(hiddenFromMap: Value(true)));

  Future<void> hideAllBearingsFromMap() =>
      update(bearings).write(const BearingsCompanion(hiddenFromMap: Value(true)));

  Future<void> updateBearingLabel(int id, String? label) =>
      (update(bearings)..where((b) => b.id.equals(id)))
          .write(BearingsCompanion(label: Value(label)));

  Future<void> deleteBearing(int id) =>
      (delete(bearings)..where((b) => b.id.equals(id))).go();

  /// Nevratne zmaže VŠETKY zamerania. "Vyčistiť mapu" toto nevolá —
  /// tam ide o `hideAllBearingsFromMap`, ktoré záznam nechá v denníku.
  Future<void> deleteAllBearings() => delete(bearings).go();

  // ── Weather ───────────────────────────────────────────────────

  Future<int> insertWeatherSnapshot(WeatherSnapshotsCompanion e) =>
      into(weatherSnapshots).insert(e);

  Future<void> clearAllWeather() => delete(weatherSnapshots).go();

  /// Vymení celú keš predpovede naraz.
  ///
  /// V transakcii zámerne: mazanie a zápis musia byť jedna operácia, inak
  /// pád medzi nimi nechá používateľa bez predpovede — a to práve vtedy, keď
  /// je sieť najhoršia.
  Future<void> replaceWeatherSnapshots(
          List<WeatherSnapshotsCompanion> rows) async =>
      transaction(() async {
        await delete(weatherSnapshots).go();
        await batch((b) => b.insertAll(weatherSnapshots, rows));
      });

  /// Výstrahy, ktoré ešte platia, od najzávažnejšej.
  ///
  /// Filtruje sa časom, nie len tým, čo prišlo z feedu: keš môže prežiť dlhšie
  /// než výstraha a zobraziť skončené varovanie je horšie než nezobraziť nič.
  Future<List<WeatherWarning>> getActiveWeatherWarnings(DateTime now) =>
      (select(weatherWarnings)
            ..where((w) => w.expires.isBiggerThanValue(now))
            ..orderBy([
              (w) => OrderingTerm.desc(w.awarenessLevel),
              (w) => OrderingTerm.asc(w.onset),
            ]))
          .get();

  /// Keš sa vždy prepisuje celá — feed je aktuálny stav, nie prírastok, a
  /// odvolaná výstraha musí zmiznúť.
  Future<void> replaceWeatherWarnings(
          List<WeatherWarningsCompanion> rows) async =>
      transaction(() async {
        await delete(weatherWarnings).go();
        if (rows.isNotEmpty) {
          await batch((b) => b.insertAll(weatherWarnings, rows));
        }
      });

  Future<void> updateWarningDetail(int id,
          {required String? description,
          required String? instruction,
          required String? language,
          required String? sender}) =>
      (update(weatherWarnings)..where((w) => w.id.equals(id))).write(
        WeatherWarningsCompanion(
          description: Value(description),
          instruction: Value(instruction),
          language: Value(language),
          sender: Value(sender),
        ),
      );

  Future<List<DhmzObservation>> getDhmzObservations() =>
      select(dhmzObservations).get();

  /// Keš sa vždy prepisuje celá — staré merania nemajú komu poslúžiť a
  /// polovičná výmena by nechala v tabuľke stanice, ktoré feed prestal hlásiť.
  Future<void> replaceDhmzObservations(
          List<DhmzObservationsCompanion> rows) async =>
      transaction(() async {
        await delete(dhmzObservations).go();
        await batch((b) => b.insertAll(dhmzObservations, rows));
      });

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

  /// Wipes the whole sync queue — used by the queue screen's "clear queue"
  /// action for stale items a past policy change left stuck forever (e.g.
  /// cloud_export entries queued before enqueue was gated on an actual
  /// signed-in session). Safe: the outbox only ever holds already-persisted
  /// domain data plus a delivery record, never the source of truth for it.
  Future<void> deleteAllOutboxRows() => delete(outboxRows).go();

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
