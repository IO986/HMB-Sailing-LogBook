# Kde sme skončili — 29. 8. 2026

Veľká dávka. Build **63 je na Google Play** (nahral ho skiper 29. 8.),
`main` je odvtedy o tri commity ďalej. Ďalší upload **musí byť 64** —
kód 63 je spotrebovaný.

## Čo je v builde 63 (1.32.0+63, commit `42daac0`)

Schéma **v30 → v32**. Záloha z 63 sa do staršej appky nenaimportuje.

- **Miestny čas** všade, prepínač v Nastavenia → Jednotky (predvolene
  miestny, UTC na výber). PDF v hlavičke stĺpca aj v pätičke uvádza, ktoré
  pásmo tlačí. GPX zámerne ostáva v UTC — je to dáta pre iný softvér.
- **Nočné hodiny** zo skutočného západu slnka pre polohu lode: značka pri
  zázname, súčet za deň aj za plavbu, v denníku aj v PDF.
- **Kotevná stráž nad plochou** (polygón) namiesto kruhu, pre úzku zátoku.
  Kruh ostáva predvolený. Plocha prežije reštart appky, zaniká s kotvou.
- **Kotvová stráž zapisuje vlastnú trasu** (schéma v31,
  `sailing_sessions.is_anchor_watch`), takže noc na kotve už nie je diera
  v GPX. Do míľ, vzdialenosti dňa ani nočných hodín sa neráta.
- **Kotvová stráž prežije reštart appky** — dovtedy po zabití ticho zmizla,
  bez alarmu a bez stopy v denníku.
- **Potvrdenie o míľach** cez formulár (`/miles/export`): pre seba alebo
  pre člena posádky, výber plavieb, meno a kvalifikácia vystavovateľa
  z profilu skipera. PDF nesie veliteľa plavby, oblasť, prílivové vody,
  funkciu a rozpis míľ podľa funkcie; pri plavbách, kde držiteľ nebol
  veliteľ, ostáva miesto na podpis veliteľa. Schéma v32 pridala
  `historical_voyages.tidal_waters`.
- **PDF prestalo rezať údaje**: stĺpec Pohon tlačil `Hlavná+` namiesto
  `Hlavná+Genoa` a `Bočný` namiesto `Bočný vietor S` — bok, na ktorom loď
  plávala, z dokladu miznul. Poznámky sa už nerežú, fotky sú 120×90.
- **Zmena kurzu** má vlastný typ udalosti, pravidlo 30° udržaných minútu.
- Automatické záznamy konečne zapisujú **stav oblohy** a **pohon**.
- Záznam **„Kotva spustená"** nesie vietor, tlak, teploty, hĺbku a pohon —
  dovtedy mal len čas a polohu.

## Čo je na `main` navyše (ešte nie na Play)

- `02c751e` — **automatické pokračovanie plavby** po zabití appky (do troch
  hodín ticha sa rozbehne samo a len oznámi, koľko chýba; medzeru dopočíta
  priamkou len na ťuknutie) a **červený pruh** cez vrch každej karty, kým je
  plavba otvorená a nič sa nezapisuje.
- `da6638c`, `f1572f0` — opravy CI.

## Nočné hodiny: 1,7 vs 0,9

Skiper našiel, že tá istá importovaná plavba vykázala v PDF 1,7 nočnej
hodiny a v Knihe míľ 0,9. Boli to **dve kópie prahu medzery** — denník
rátal medzeru do 2 h, Kniha míľ do 30 min. `NightHours.maxGap` je teraz
jediná kópia a má **30 minút** (hodnota, ktorá je už vytlačená na vydaných
potvrdeniach). `nightHoursForDay` už nepadá späť na záznamy denníka:
sú redšie než prah, takže z nich vychádzalo číslo závislé od intervalu
zapisovania. Test `night_hours_agreement_test.dart` ženie obe cesty
z jedných bodov a porovnáva ich.

## Otvorené: appku zabíja systém — a je to SAMSUNG, nie Honor

Vo štvrtok 27. 8. má denník **päť „Začiatkov plavby"** (09:09, 09:33,
15:29, 18:39, 19:17 UTC) a jediný „Koniec" (19:20). Diera 17:54 → 18:39
UTC = 45 minút, priamka cez ňu 3,07 NM. Míle dňa sú pritom v poriadku
(28,3 NM oproti 27,7 NM súčtu priamok po odfiltrovaní GPS skokov).

**Dôležité: dialo sa to na Samsungu S24, nie na Honore.** Prvé kolo rád
mierilo na Honor („Spustenie aplikácií") a je pre S24 irelevantné. Na
Samsungu sú tri bežné príčiny a dve nie sú zabitie systémom:

1. **Odswipovanie z prehľadu nedávnych** — Samsung ukončí proces aj
   s foreground service a obíde tým dialóg „nechať bežať" (ten je len na
   tlačidle späť). Päť reštartov v rôznych časoch tomu sedí.
2. Uspávanie nepoužívaných aplikácií (zapnuté z výroby).
3. Nastavenie batérie appky, ktoré nie je „Neobmedzené".

Skiperovi boli poslané inštrukcie k nastaveniam telefónu. **30. 8. ide na
ďalšiu plavbu a testuje ďalej.**

### Čo od neho po plavbe chcieť

**Zálohu dát**, nie PDF — obsahuje jednotlivé sessions s časmi a všetky
body trasy, takže sa z nej priamo prečíta, koľkokrát a na ako dlho sa
trasovanie prerušilo. Z PDF sa to odvodzuje len nepriamo.
A jednu vetu: **odswipol appku, alebo zmizla sama?**

### Ďalší krok v kóde (nezačatý)

1. **Diagnostika príčiny.** Pri `AppLifecycleState.detached` zapísať značku:
   keď je pri ďalšom štarte prítomná, appku niekto zavrel riadne (swipe);
   keď chýba a session je prerušená, proces zomrel tvrdo. Lacné, bez
   natívneho kódu, a odstráni dohady.
2. Výslovné `android:stopWithTask="false"` na službe v manifeste (dnes tam
   nie je uvedené vôbec, spolieha sa na predvolenú hodnotu).
3. Obrazovky nastavení **podľa výrobcu** — Samsung má iné než Honor; dnes
   appka otvára androidovú optimalizáciu batérie, ktorá na oboch
   nerozhoduje. A overovať stav cez `permission_handler`, nie len otvoriť
   obrazovku a predpokladať.

**Pozor na omyl, ktorý som v tejto session urobil:** strážca cez
WorkManager/AlarmManager appku nevzkriesi len tak — od Androidu 12 sa
foreground service vo všeobecnosti nesmie spustiť z pozadia. Výnimka cez
presný budík existuje, ale `USE_EXACT_ALARM` / `SCHEDULE_EXACT_ALARM` je
pre Play rovnako sledovaná ako `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.
Presun zápisu do izolátu služby je najväčší zisk nezávislý od výrobcu, ale
znamená postaviť drift isolate server — dva izoláty nad tou istou SQLite
priamo sú cesta k poškodeným dátam.

## Nástroje a CI

Lokálny Flutter upgradnutý **3.44.9 → 3.47.2**, tá istá stable, akú beží
CI. Dôvod: 3.44.9 nehlásil lint na nepoužité importy, ktorý CI hlási, a
warningy sú tam fatálne — CI kvôli tomu spadlo na `main`.

**Nikdy negatovať cez `flutter analyze | grep -c`.** Výstup má ~500 riadkov
a nástroj ho reže na 30 000 znakov, takže počet vyjde čistý, kým warning
sedí pod rezom. Takto prešli na `main` dva warningy za sebou. Gatovať
presne tak, ako CI, a čítať návratový kód:

```
flutter analyze --no-fatal-infos > /dev/null 2>&1; echo $?
flutter test > /dev/null 2>&1; echo $?
```

3.47 si pri prvom behu samo dopísalo `analyzer: exclude:` do
`analysis_options.yaml` a pohlo tranzitívnymi pinmi v `pubspec.lock`;
`intl` ostáva caret, ako musí.

## Stav zariadení

Na **Honore** (REA_NX9) je sideloadnuté APK z vetvy pred uploadom — hlási
sa ako 1.31.0+62 a **nemá** automatické pokračovanie ani červený pruh.
Skiperov **Samsung S24** má build 63 z Play.

Archív `release_builds/HMB-Sailing-Log-v1.32.0-build63.aab` JE presne ten
súbor, ktorý šiel na Play (postavený z `42daac0` na Fluttri 3.44.9).
Neprepisovať — prestavba na novšom toolchaine dá iný súbor s rovnakým
kódom verzie, ktorý sa už nahrať nedá.

## Neoverené na vode

Kotevná plocha a jej alarm, detekcia zmeny kurzu (30° / 1 min — na
štvrtkových dátach vyrobilo staré pravidlo 25°/15 min devätnásť záznamov,
nové ich spraví viac), a NMEA autopilot s otáčkami motora ešte z buildu 62.

---

# Kde sme skončili — 27. 8. 2026

Krátka poznámka, nie plnohodnotná session — len zápis budúcej úlohy, aby
sa nestratila.

## Nové Google Play požiadavky na kvalitu (mail od Google, 27. 8.)

Google Play zavádza od **februára 2027** limity na pamäť a povinnú
optimalizáciu kódu, a od **apríla 2027** požiadavku na bezproblémovú
migráciu medzi zariadeniami. Nesplnenie neznamená zákaz appky, len
"zníženú viditeľnosť a možnosti publikovania" (presne nešpecifikované).
Netreba riešiť teraz, ale patrí to na zoznam pred rokom 2027:

- **Zero-Tap Sign-In (apríl 2027)** — appka MÁ Google Sign-In (cloud
  export na Drive), takže sa jej to bude týkať. Ide o implementáciu
  `Android Restore Credentials API`, aby sa prihlásenie obnovilo samo pri
  prechode na nové zariadenie. Zatiaľ neimplementované, čaká na túto
  úlohu.
- **Optimalizácia kódu (25% shrink/obfuscation pre DEX >10 MB)** —
  overené: release build (`android/app/build.gradle:58-60`) už má
  `minifyEnabled true` + `shrinkResources true` s R8/ProGuard. Toto appka
  pravdepodobne spĺňa už teraz, len si to pred nasadením overiť ešte raz
  (limit sa mohol medzičasom spresniť).
- **Limity pamäte** (RSS+Swap ~1-2 GB podľa RAM triedy zariadenia,
  bitmapy do 200-400 MB v pozadí/cache) — nič konkrétne nezmerané.
  Rizikové miesta na budúce overenie: generovanie PDF s mapovými
  snímkami (`pdf_export_service.dart`), kamerový náhľad na Kompase,
  disková cache dlaždíc mapy (`tile_cache.dart`) — či sa dekódované
  bitmapy nedržia zbytočne dlho v pamäti mimo popredia appky.

Zdroj: [Android Developers Blog, august
2026](https://android-developers.googleblog.com/2026/08/app-quality-memory-optimization-secure-onboarding.html),
[Play Console technical quality requirements](https://support.google.com/googleplay/android-developer/answer/17492799).

---

# Kde sme skončili — 26. 8. 2026 (večer, dva paralelné terminály)

`main` bola na `f3dfffb`, tento commit ju posúva ďalej. Overené pred
commitom presne tým, čo beží v CI: `flutter analyze --no-fatal-infos`
**exit 0** (0 chýb, 0 warningov, 496 infos — tie CI prepúšťa), `flutter test`
**614 testov prešlo**.

Pracovalo sa v dvoch termináloch naraz do tých istých súborov (hlavne
`lib/l10n/*.arb`). Nič sa nestratilo, ale kto bude pokračovať, nech si
uvedomí, že tento commit obsahuje **dva nezávislé prúdy**.

## Prúd A — kurz voči vetru (druhý terminál)

Papierový lodný denník má políčko so siluetou lode: kde je vietor a z ktorého
boku. Appka to teraz vie tiež.

- **Schéma v29** — `logbook_entries` dostalo stĺpce `point_of_sail` a `tack`.
  Dva stĺpce zámerne, nie jeden: pri behu na plný vietor bok neexistuje a
  `tack` vtedy ostáva prázdny.
- **`lib/core/models/point_of_sail.dart`** — enum `PointOfSail`
  (`close_hauled`, `close_reach`, `beam_reach`, `broad_reach`, `running`) a
  `Tack`. Čistý Dart, bez driftu a Flutteru, aby sa dal testovať priamo.
  Kódy sa **nikdy neprekladajú** — v databáze aj v exporte stojí
  `beam_reach`, nech je appka v akomkoľvek jazyku.
- **Nezamieňať so `sailMode`** (motor/hlavná/genova). `sailMode` hovorí, ČO je
  vytiahnuté; `pointOfSail` hovorí, KAM sa ide voči vetru.
- **`sail_direction_picker.dart`** — silueta lode, ťuká sa na polohu na tom
  boku, z ktorého fúka (ľavobok červený, pravobok zelený). Opätovné ťuknutie
  výber zruší; odhadnutý údaj je horší ako prázdne políčko.
- **`quick_sail_change_sheet.dart`** + rýchla akcia v `main_scaffold.dart` —
  počas plavby sú vedľa seba dve tlačidlá, obrat a fotka. Obe zapisujú do
  denníka bez otvárania formulára; na kormidle je na vypĺňanie polí neskoro.
  Vedľa seba, nie nad sebou — nad sebou horné tlačidlo prekrývalo obsah.
- **Preberá sa do automatických záznamov**, rovnako ako `sailMode`: kurz sa
  nemení každou minútou, skiper ho prepne pri obrate a medzitým platí ďalej
  (`lastSailDirectionForDay`).
- Ide aj **do PDF** vedľa spôsobu plavby.
- l10n v 11 jazykoch + bod v príručke denníka.
- Testy: `point_of_sail_test`, `sail_direction_dao_test`,
  `sail_direction_labels_test`, `schema_v29`.

### Prúd A, druhá vec — strojové poznámky v denníku

`lib/shared/utils/auto_entry_note.dart`. Automatické záznamy si písali
poznámku `Auto [MODEL]` / `Automaticky [NMEA]` — nikdy to nebola veta pre
človeka, bola to značka pre appku, navyše po slovensky. Chorvát v exporte
čítal slovenské slovo a k nemu kód zdroja, ktorý mu nič nehovoril. Zdroj
počasia má od schémy v27 vlastný stĺpec (`weatherSource`) a zobrazuje sa
preložený; v `auto_entry_note.dart` ostáva len rozpoznanie starých riadkov,
aby sa tá značka nedostala na oči. Test: `auto_entry_note_test`.

## Prúd B — postup na pripojenie B&G do príručky (prvý terminál)

Do `guideInstrBody` pribudol vo **všetkých 11 jazykoch** odsek o pripojení
Navico plotrov. Nadväzuje na sekciu nižšie, kde je popísané, ako sa to na
lodi vypátralo.

Zámerne tam **nie je konkrétna adresa `169.254.160.58`** — tá patrí jednému
plotru. Namiesto nej je návod, kde si ju každý nájde
(`Settings → Network → Diagnostics`, položka IP address), aby text platil aj
na inej lodi. Názvy položiek v menu ostali po anglicky vo všetkých jazykoch,
lebo plotter je anglický.

## Zajtra v práci — odkiaľ pokračovať

Poradie podľa toho, čo je najbližšie k hotovému:

1. **Vyskúšať kurz voči vetru na vode.** Kód aj testy sú hotové, ale rýchla
   akcia pri obrate je vec, ktorá sa dá posúdiť až za kormidlom — či sa dá
   trafiť jednou rukou a či nechýba potvrdenie, že sa zápis uložil.
2. **GoFree discovery.** Teraz už má oporu v dátach: vieme, že plotter
   servíruje 0183 na `169.254.x.x:10110` a že broadcast na `UDP 2052`
   takmer isto obsahuje presne tú dvojicu. Odchytiť ho a podať existujúcemu
   TCP klientovi by znamenalo, že používateľ nezadáva nič. Rozsah: nová malá
   služba + úprava `autoDetectHost`, ktorý dnes skenuje len port 2000, a
   jeho jediného volania v `main_scaffold.dart`. **Nezačaté, čaká na súhlas.**
3. **Vetva `feat/emodnet-depths`** je na origine stále a je zbytočná
   (dávno zliata): `git push origin --delete feat/emodnet-depths`
4. **Verzia sa stále nebumpovala.** Čo je na Console, nie je v gite — pýtať
   sa pred bumpom, version code sa nedá použiť druhýkrát. Od build 60 sa
   nazbieralo dosť na ďalší build: hĺbky, meranie hĺbky ťuknutím, odstránená
   vrstva staníc, oprava sekania mapy, MeteoAlarm, kurz voči vetru.
5. **PMTiles/R2** ostáva tam, kde bolo — archív žije na
   `maps.hmba.fyi/adriatic.pmtiles`, vektorové vykresľovanie sa vrátilo
   pre výkon na Honore. Detaily v sekcii nižšie.

## Nezacommitované naschvál

`.claude/settings.local.json` (lokálne nastavenie), `screenshot.jpg` a
`lodný denník.jpeg` (obrázky odložené v koreni repa — ak sú potrebné, patria
do `docs/`, inak preč).

---

# Kde sme skončili — 26. 8. 2026 (NMEA na lodi)

## B&G Zeus³ 12" (NOS v25.2) — FUNGUJE, a nie tak, ako by človek čakal

Skipperov plotter sa podarilo pripojiť. Funkčné nastavenie v appke:

- režim **TCP**
- **IP `169.254.160.58`**
- **port `10110`**

Číta všetko. Telefón musí byť na **WiFi sieti Zeusu** (jeho AP dáva podsieť
`192.168.76.x`, telefón dostal `.65`, brána je `192.168.76.1`).

**Prečo práve táto adresa:** `169.254.160.58` je **vlastné ethernetové
rozhranie Zeusu** (link-local), nie WiFi. Vidno ju v plotri na dvoch
miestach — `Settings → Network → NMEA 0183` ako Eth/WiFi výstup, a pri
položke iperf servera. NMEA 0183 server beží **len na ethernetovej strane**;
Zeus ale smeruje medzi svojím ethernetom a WiFi, takže z telefónu je
dosiahnuteľný, hoci je to iná podsieť.

**Čo NEfunguje a prečo (aby sa to neskúšalo znova):**

- `192.168.76.1:2053` — spojenie sa nadviaže, dáta žiadne. Je to **GoFree**
  služba s vlastným protokolom (JSON/binárne), nie textové NMEA vety.
- `192.168.76.1:10110` a `:2000` — spojenie sa nadviaže, dáta žiadne. Nie je
  tam ten 0183 server.
- **UDP režim** — v appke sa nedá zadať cieľová IP a je to správne: appka len
  počúva na porte, adresu určuje zdroj. Zeus svoj výstup nasmerovať nevie,
  to pole je len na čítanie (je to „kde počúvam", nie „kam posielam").
- `Serial` bol na plotri vypnutý; na telefón je aj tak nanič (je na kábel).

**Autodetekcia v appke to nikdy nenájde.** `autoDetectHost`
(`raymarine_connection_service.dart`) skenuje podsieť telefónu **len na TCP
porte 2000**. Hľadaná adresa je v úplne inej podsieti (`169.254.x.x`) a na
inom porte, takže sken z princípu zlyhá — používateľ to musí zadať ručne.

## Otvorené / na zváženie

- **Stabilita adresy:** `169.254.x.x` je self-assigned (APIPA). Zvyčajne
  ostáva rovnaká, ale po výmene hardvéru alebo dlhšom odpojení sa môže
  zmeniť. Ak to raz prestane fungovať, adresu treba znova prečítať v
  `Settings → Network → Diagnostics` (položka IP address).
- **Discovery:** GoFree na `UDP 2052` vysiela broadcast s JSON zoznamom
  služieb, kde je IP aj port streamu — takmer isto presne tá dvojica
  `169.254.160.58:10110`. Odchytiť ten broadcast a podať ho existujúcemu TCP
  klientovi by odstránilo ručné zadávanie. Neimplementované, čaká na
  rozhodnutie.
- **Zapnúť „Automaticky pripojiť pri spustení"**, nech sa to po reštarte
  obnoví samo.
- Ak by sa Zeus raz ukázal ako slepá ulička (iná loď, iný plotter), cesta cez
  **NMEA 2000 gateway** (Yacht Devices YDWG-02 — UDP broadcast, Actisense
  W2K-1, Digital Yacht WLN10) funguje s appkou bez zmeny kódu. Na charterovej
  lodi je to ale zásah do zbernice a rozhodnutie majiteľa.

---

# Kde sme skončili — 26. 8. 2026 (večer)

`main` je na `98beb2c`, pushnutá. Nadväzuje na sekciu nižšie (ta istá
session, o pár hodín neskôr — pretiahla `98beb2c` cez `1e3f808`, pred tým
pretiahla aj `hmb_core` na v1.1.0, bez ktorého appka nekompiluje).

## PMTiles na R2 — vyskúšané, vrátené späť

Plán z predchádzajúcej sekcie ("Ďalší krok: PMTiles na Cloudflare R2") sa
zrealizoval, otestoval na Honore a **vrátil späť**. Zhrnutie, nech sa
budúca session nepúšťa do toho istého znova bez dôvodu:

- **Infraštruktúra funguje a ostáva pripravená**: Cloudflare účet, R2 bucket
  `hmb-maps`, custom domain `maps.hmba.fyi` (nová malá doména, kúpená len na
  toto — `hmba.boats` zámerne nepresúvaná na Cloudflare DNS, riziko pre
  mail/ostatné záznamy). `pmtiles`/`wrangler`/`rclone` nainštalované v
  `~/bin`. Extrakcia Jadranu z denného Protomaps buildu (`pmtiles extract
  https://build.protomaps.com/<YYYYMMDD>.pmtiles ... --bbox=12.0,39.5,20.0,46.0
  --maxzoom=14`) funguje, dáva ~994 MB. Upload cez `wrangler r2 object put`
  má tvrdý limit 300 MiB na súbor — na väčšie treba `rclone` (S3 API,
  `--s3-no-check-bucket` flag nutný, token je bucket-scoped bez práv na
  `ListBuckets`/`CreateBucket`; endpoint **bez** `.eu.` prefixu, pokiaľ
  bucket nie je vyslovene v EU jurisdikcii). Archív je stále na
  `maps.hmba.fyi/adriatic.pmtiles`, nikto ho nemaže — ďalšia session ho
  môže rovno použiť, nemusí nič extrahovať znova.
- **Vektorové vykresľovanie (`vector_map_tiles` 9.0.0-beta.11 +
  vendorovaný fork `vector_map_tiles_pmtiles` 1.5.0) skompilovalo** — vyžadovalo
  vendorovanie balíka do `packages/` (pridanie `TileOffset get tileOffset`
  gettera, ktorý 9.x pridala oproti 8.x), viď git história commitu, ktorý to
  potom revertol, pre presný diff.
- **Prečo sa to vrátilo**: na reálnom Honore (mid-range telefón) bolo
  vykresľovanie vektorových dlaždíc citeľne pomalšie/trhanejšie než pôvodný
  raster OSM — CPU réžia dekódovania MVT + štýlovania pri každom
  posune/zoome. Navyše popisky (mená miest) potrebujú font/glyph službu
  (`protomaps.github.io/basemaps-assets/fonts/...`) — **druhú externú
  závislosť za behu**, presne to, čo malo self-hosting odstrániť; na mori
  bez signálu by popisky proste nenačítalo.
- **Skutočný dôvod celej migrácie** (pripomienka, nech sa nezabudne
  nabudúce) bol vždy len `TileRegionDownloader`, nie živá mapa —
  `CachingTileProvider` (pasívne kešovanie toho, čo si používateľ pozrel) je
  a vždy bolo v poriadku. Táto session to poriešila najkratšou cestou:
  `'osm'` sa vyhodilo z `TileRegionDownloader.baseLayers`
  (`lib/core/services/tile_cache.dart`), živá mapa ostala nedotknutá,
  žiadny nový balík, žiadne nové riziko.
- **Ak sa má PMTiles/R2 riešenie použiť budúcnosti**, najreálnejšie
  miesto je práve tam, kde chýba teraz: `TileRegionDownloader`
  potrebuje vlastný, self-hosted zdroj namiesto `tile.openstreetmap.org`,
  aby "stiahnuť oblasť offline" sťahovalo aj základnú mapu, nielen
  seamarky (viď nižšie). Buď (a) rastrové PNG dlaždice vygenerované raz
  a hosťované na tom istom bucket/doméne (žiadna Flutter-side zmena,
  len iný zdroj URL), alebo (b) znova vektor, až raz vyjde stabilná
  (nie beta) verzia `vector_map_tiles` s prijateľným výkonom.

## Sekanie mapy pri zoome — opravené

`onPositionChanged` volal `setState()` na CELÝ `_MapScreenState` pri každej,
aj nepatrnej zmene rotácie — pri štípaní dvoma prstami (zoom gesto) sa
rotácia takmer vždy nepatrne zmení, takže sa prekresľovala celá obrazovka
(všetky dlaždicové vrstvy, markery, FAB stĺpce) niekoľkokrát za sekundu.
`_mapRotationDeg` je teraz `ValueNotifier`, čítajú ho len dva widgety, čo
ho naozaj potrebujú (kompas hore, šípka lode pri prehrávaní). Overené na
Honore cez `PerformanceOverlay` (dočasne pridaný do `main.dart`, potom
odstránený) a subjektívne potvrdené používateľom ("o dosť lepšie").

Podobný, menší problém bol aj pri vrstvách meraného vetra/POI — `ref.watch`
na ich providerov bol na začiatku `build()`, takže každé sieťové
dotiahnutie prekreslilo celú obrazovku. Presunuté do vlastných `Consumer`
widgetov okolo príslušných `MarkerLayer`.

## Vrstva meraného vetra zo staníc — odstránená z mapy

Na explicitnú žiadosť používateľa ("zbytočné informácie"). `stationWindProvider`,
`showStationWind` a súvisiaci FAB/marker/legenda vyhodené z
`map_provider.dart`/`map_screen.dart`. `DhmzObservationService`/
`MetarObservationService` OSTÁVAJÚ — používa ich denník (zápis nameraných
podmienok) a `nearest_stations_card.dart` na Počasí obrazovke, tie sa
netýkali.

## Kontakty na POI klikateľné

`marine_poi_sheet.dart`: telefón/web/email z OSM tagov teraz spúšťajú
`tel:`/`https:`/`mailto:` cez `url_launcher` namiesto obyčajného
`SelectableText`. Nový l10n kľúč `poiCannotOpen` (11 jazykov).

## Otvorené

- Rovnaké body ako v sekcii nižšie (`feat/emodnet-depths` vetva,
  `[STATIONS]` debugPrint, verzia sa nebumpovala) — nezmenené.
- `TileRegionDownloader` teraz sťahuje len seamarky pre offline použitie,
  nie základnú mapu — viď vyššie, "Ak sa má PMTiles/R2 riešenie použiť".

---

# Kde sme skončili — 26. 8. 2026

`main` je na `e68e651`, pushnutá, CI zelené. Nič nezostalo len na jednom
stroji okrem vecí vymenovaných v „Čo NIE je v gite" na konci tejto sekcie.

## Čo pribudlo (24. 8.)

**Hĺbky na mape** — voliteľná vrstva z EMODnet Bathymetry.

- Dlaždicová služba EMODnet dáva len **nepriehľadný** podklad, ktorý by
  prekryl mapu. Preto sa kreslí WMS vrstva `emodnet:contours` — priehľadné
  PNG so samotnými izobatami a popiskom hĺbky.
- Leží **pod** seamarkami zámerne: bóje a svetlá sú navigačné značky a
  patria navrch.
- `maxNativeZoom: 12`. Overené meraním: nad priblížením 12 vracia EMODnet
  prázdnu dlaždicu (vždy presne 1784 B), a to **aj nad hlbokým Jadranom** —
  nie je to limit mierky, hustejšie izobaty proste neexistujú. Bez
  `maxNativeZoom` by hĺbnice pri priblížení ticho zmizli.
- Štandardne vypnuté, prepínač vo Vrstvách (`Icons.waves`).

**Hĺbka v bode** — `lib/core/services/depth_probe_service.dart`.

- Izobaty na otázku „koľko je pod kýlom" neodpovedajú. Odpovedá podkladový
  model `emodnet:mean` cez WMS **GetFeatureInfo**: vráti hĺbku v bode pri
  akomkoľvek priblížení, odpoveď má pár stoviek bajtov.
- Krátke ťuknutie do mapy. Meria sa **len pri zapnutej vrstve hĺbok** — inak
  by každé zablúdené ťuknutie znamenalo dotaz do siete. Pravítko má prednosť,
  dlhé podržanie ostáva waypoint.
- Rešpektuje prepínač meter/stopa (`UnitsSettings.formatDepth`).
- Rozlíšenie mriežky je **~115 m na bunku** (odmerané: vzorky po 40 m, hodnota
  sa mení každé tri). Desatiny metra v odpovedi sú falošná presnosť
  interpolácie. Je to podklad na plánovanie, **nie námorná mapa** — príručka
  to hovorí otvorene vo všetkých 11 jazykoch.

**Oprava CI** — `const showBackendSync = false` v `settings_screen.dart` robí
z vetiev pod ním mŕtvy kód. CI beží `flutter analyze --no-fatal-infos`, kde
infos prejdú, ale **warningy nie**. Kód pod prepínačom má ostať, tak dostal
cielené `// ignore: dead_code`. `final` namiesto `const` nepomôže, analyzátor
si hodnotu aj tak vyhodnotí.

## Mapové podklady zadarmo — čo sa overilo živým dotazom

| podklad | bez kľúča | reálne dáta nad Jadranom |
|---|---|---|
| Esri World Ocean Base | áno | **len po z10** — vyššie vracia HTTP 200 a dlaždicu „Map data not yet available" (rovnaké md5 z11–z16), hoci metadáta hlásia LOD 0–16 |
| Esri World Topo / NatGeo | áno | po z16 |
| Esri World Shaded Relief | áno | po ~z13 |
| OpenTopoMap | áno | po z16, pravidlá prísnejšie než OSM |
| EOX Sentinel-2 cloudless | áno | po z16, 10 m; **CC BY-NC-SA**, komerčné použitie chce licenciu od EOX |
| EMODnet Bathymetry | áno | po z16 (podklad), izobaty len po z12 |
| NASA GIBS | áno | max z9 návrhom |
| GEBCO WMS | — | starý endpoint 404 |

Pozor na pascu: viacero služieb vracia **HTTP 200 s náhradnou dlaždicou**
namiesto chyby. Vždy porovnať md5 dlaždíc naprieč zoomami, nie len status.

## Ďalší krok: PMTiles na Cloudflare R2

**Prečo vôbec:** `TileRegionDownloader` (`lib/core/services/tile_cache.dart`,
`maxTiles = 6000`) predsťahuje oblasť z `tile.openstreetmap.org` a z Esri.
Pravidlá OSM to zakazujú doslovne — „bulk downloading" je definované ako
„any pre-emptive fetching of tiles other than those a user is actively
viewing", a „Offline use is not permitted on tile.openstreetmap.org".
Zákaz je na správanie, nie na objem z jednej IP, a blokuje sa podľa
User-Agentu (`com.hmb.sailinglog`), takže by to zasiahlo všetkých
používateľov naraz. Pravidlá **nerozlišujú** komerčné a nekomerčné použitie.

`CachingTileProvider` (pasívny cache toho, čo si používateľ pozrel) je v
poriadku a ostáva — problém je len ten predsťahovač.

**Prečo R2 a nie VPS:** appka je zadarmo natrvalo, takže náklad nesmie rásť s
počtom používateľov. R2 má 10 GB úložiska a **egress zadarmo**, čítacie
operácie 10 mil./mesiac zadarmo. Jadran do z14 sú rádovo stovky MB. VPS by
stál 48–75 €/rok za to isté. PMTiles je jeden súbor čítaný cez HTTP Range —
**žiadny tile server nebeží**, stačí statické úložisko.

**Postup:**

1. Účet Cloudflare + R2 bucket (cez web, nedá sa skriptom). **Hneď nastaviť
   spending limit** — R2 chce kartu aj pri free tier.
2. `pmtiles` CLI — Go binárka, jeden súbor:
   `https://github.com/protomaps/go-pmtiles/releases` (v1.31.2,
   `go-pmtiles_1.31.2_Windows_x86_64.zip`). Na stroji **nie je**.
3. `npm i -g wrangler` na nahranie (node v24 na stroji je, wrangler nie).
4. `pmtiles extract` s bboxom Jadranu priamo z denného planet buildu
   Protomaps cez HTTP range — **planet sťahovať netreba**. Pozor:
   `https://build.protomaps.com/` vracia 404, správnu URL denného buildu
   treba dohľadať v dokumentácii Protomaps.
5. Vo Flutteri `vector_map_tiles_pmtiles`.
6. Dáta sú OSM pod **ODbL** — redistribúcia povolená s atribúciou. To je
   presne to, čo `tile.openstreetmap.org` zakazuje; rozdiel nie je v dátach,
   ale v tom, koho infraštruktúru zaťažuješ.

Keď raz VPS bude, ten istý súbor sa len presunie, nič sa neprerába.

## Otvorené

- **Vetva `feat/emodnet-depths`** je na origine stále, už je zbytočná (zliata
  fast-forward): `git push origin --delete feat/emodnet-depths`
- **APK v telefóne** (Honor REA NX9) je z `c49dd3f`, teda bez opravy CI — na
  správanie appky to nemá vplyv. Neprejdené: či ťuknutie mlčí pri vypnutej
  vrstve a či pravítko dostane prednosť.
- **`debugPrint('[STATIONS] …')`** v `map_provider.dart` sa vypíše pri každom
  obnovení staníc aj v release. Ak už netreba, je to jeden riadok von.
- **Predsťahovač dlaždíc** sa zatiaľ nezmenil — čaká na rozhodnutie vyššie.
- **Verzia sa nebumpovala.** Čo je na Console, nie je v gite — pýtať sa pred
  bumpom, version code sa nedá použiť druhýkrát.

## Čo NIE je v gite

Poznámky, ktoré si Claude drží medzi sedeniami, žijú v adresári
`~/.claude/projects/C--dev-sailing-logbook/memory/` — sú **viazané na stroj**
a na iný počítač neprejdú. Tento súbor je ich prenosná verzia; čo má prežiť
presun, musí skončiť tu.

---

# Kde sme skončili — 20. 7. 2026

Prenosný zápis stavu, aby sa dalo pokračovať z iného počítača. Všetko
podstatné je v gite; nič dôležité nezostalo len na jednom stroji.

## Vetvy

Všetko je zliate do `main` (`22db172`, pushnutá) a vetvy sú po zlúčení
zmazané, lokálne aj na GitHube. Aktuálne existuje len `main`.

- `feat/duty-roster` → zliata do `main`.
- `feat/colreg-en` → zliata do `main`.
- `feat/tides-open-meteo` → zliata skôr, vetva už bola zmazaná.
- `feat/hmb-core-sync`, `feat/map-compass-l10n`,
  `worktree-ka-dop-dne-to-o-som-rustling-kahn` → zliate, zmazané 20. 7.

## Čo je hotové (na `main`)

**Službukonajúca posádka** (kto má kedy službu — dôkazný záznam po incidente
v Chorvátsku):

- Schéma **v20** — tabuľka `duty_periods`, jeden riadok na osobu,
  `to_utc IS NULL` = služba beží.
- Schéma **v21** — stĺpec `logbook_entries.event_type`, aby sa poznámky dali
  prekladať a nematchovali sa reťazce.
- Čistá logika bez Flutteru a driftu: `lib/features/duty/domain/`
  (`duty_rules.dart`, `crew_member.dart`).
- UI: karta v Bezpečnosti, nástup do služby, rozpis so spätným zápisom,
  celoobrazovková inšpekčná obrazovka pre kontrolu na palube.
- PDF: pás služby na dennej strane + záznamy medzi záznamami dňa.
- Do PDF pribudol **Noto Sans** — predtým sa mená tlačili bez diakritiky
  (`Ján Novák` → `Jan Novak`) a cyrilika sa nevykreslila vôbec.
- PDF dostalo locale: 64 reťazcov preložených do 5 jazykov.
- „Kapitán" → „skipper" naprieč textami.
- Slnko a mesiac presunuté z karty denníka do PDF exportu dňa.

**Anglický COLREG** — `colreg_content_en.dart` + `colreg_content_sk.dart`
(rozdelené zo spoločného súboru), slovenčina zostáva default.

**Prílivy/odlivy** — online forecast cez Open-Meteo, `tide_repository.dart`,
`tide_forecast_service.dart`, `tide_extremes.dart`.

**Sync fixy (20. 7., dôležité)** — na telefóne sa zistilo:

1. Outbox riadok sa vytváral pri **každom** zápise do denníka bez ohľadu na
   `settings.enabled` — vypnutá synchronizácia fronta aj tak rástla
   donekonečna. Opravené: `engine.enqueue()` je teraz podmienené
   `settings.enabled` na všetkých 4 miestach zápisu (`logbook_entry_screen.dart`
   ×2, `quick_photo_log_sheet.dart`, `gps_tracking_service.dart` auto-entry).
   Lokálny zápis prebehne vždy, len sa nevytvorí outbox riadok.
2. `StrapiTransport`/`RestTransport` nemali `connectTimeout`/`sendTimeout`/
   `receiveTimeout` na Dio kliente — pri slabom/žiadnom signáli pokus visel na
   platformovom defaulte (rádovo minúty), čo pri väčšej fronte držalo rádio
   aktívne a vybíjalo batériu. Pridané limity 10s/20s/20s.
3. Nové tlačidlo **„Doplniť staršie záznamy"** v nastaveniach (sync karta) —
   keďže vypnutá synchronizácia znamená, že staré záznamy nemajú outbox
   riadok vôbec, zapnutie sync-u ich nedobehne samo. Tlačidlo
   (`lib/sync/log_entry_backfill_service.dart`) prejde všetky lokálne
   záznamy, porovná s existujúcim outboxom podľa `entityId` a doplní chýbajúce.

**CI opravené** — `flutter analyze --no-fatal-infos` padal na main na tri
warningy (nepoužitý import/premenná), nie na chybu; teraz zelené.

**Stav:** `flutter analyze lib test` 0 errors (490 zvyšných je len info-level
lint, existovali už predtým), `flutter test` **251 zelených**. CI na `main`
zelené (`22db172`).

## Čo zostáva

- `docs/SYNC_API.md` — poznámka o rezervovanom type `duty_period`.
- `docs/uzivatelska_prirucka.md` — sekcia o službe (in-app príručka v 5
  jazykoch **už hotová**, chýba len tento markdown).

## Ďalšia téma: automatický export do cloudu

Plán je celý v **`docs/plan_cloud_export.md`**. Ešte sa nezačalo — ani
KROK 0 (Google Cloud Console) nie je spravený. Toto je ďalšie na rade.

Zhrnutie plánu:

- Po ukončení dňa a pri check-oute sa PDF + GPX samy nahrajú na Disk.
- Cloud **nie je nový mechanizmus** — je to ďalšia vetva existujúceho
  outboxu z `hmb_core`, každá vetva má vlastný `SyncPolicyTransport`.
- Nastavenia idú **do existujúcej sync karty**, nie do novej sekcie.
- Rozhranie `CloudStorageProvider`, aby sa dal pridať Proton Drive a iné.
- Mapa musí byť v PDF aj pri automate — rieši to
  `ScreenshotController.captureFromWidget` (vykreslenie mimo stromu).

### KROK 0 — hotové 20. 7.

Google Cloud Console — nový projekt (appka dovtedy nepoužívala žiadnu Cloud
službu). Podrobný postup je v pláne, §7.

- [x] Nový GCP projekt.
- [x] Zapnuté **Google Drive API**.
- [x] OAuth consent screen, scope len `drive.file`, prepnuté do **In
      production** (v *Testing* by refresh tokeny expirovali po 7 dňoch).
- [x] OAuth client Android **debug** — SHA-1
      `3C:4B:92:57:48:2C:20:9A:8B:D5:05:8C:A8:4D:BB:A5:97:CB:AE:6C`
      (per-stroj hodnota z `~/.android/debug.keystore` tohto počítača — na
      inom stroji si ju vždy pretiahni cez `keytool -list -v -keystore ...
      -alias androiddebugkey -storepass android -keypass android`,
      nespoliehaj sa na tento zápis).
- [x] OAuth client Android **upload** — SHA-1
      `01:0C:5E:8C:F7:18:BC:C5:E4:20:C1:8B:FC:5E:36:B8:BF:8F:41:2F`.
- [x] OAuth client Android **Play App Signing** — SHA-1
      `90:49:70:2B:1F:F1:54:E6:99:D0:06:29:DE:A4:BF:50:5B:DA:4D:E3` (Play
      Console → Chránené službou Google Play → Ochrana Play Store →
      Spravovať podpisovanie aplikácií v Play — menu sa v rôznych
      lokalizáciách/verziách volá inak, hľadaj "App signing key
      certificate"). Sailinglog je na testovacom kanáli, takže appku pre
      testerov podpisuje Google, nie upload kľúč.
- [x] OAuth client **Web application** (zistené až pri testovaní bodu 1,
      pôvodný plán o ňom nevedel) — `google_sign_in` 7.x na Androide
      vyžaduje `serverClientId`, keď sa nepoužíva `google-services.json`/
      Firebase (viď `google_sign_in_android`'s README, "Integration"). Bez
      neho `initialize()`/`authenticate()` zlyhá potichu (žiadny
      viditeľný efekt po stlačení "Prihlásiť"). Client ID
      `67335624649-fpmgdt6cae47i6i8qq5ll6upvaivnofa.apps.googleusercontent.com`
      je v `lib/core/config/api_constants.dart` (`kGoogleWebClientId`) —
      nie je to tajný kľúč, smie byť v zdrojáku (rovnaké ako Firebase
      `default_web_client_id`).

KROK 0 hotový (vrátane dodatočného Web clientu). **Body 1 a 2 z poradia
implementácie (plán, §10) sú hotové a overené na Honore:**

- Bod 1 — `CloudStorageProvider` + `GoogleDriveStorage` + prihlásenie v sync
  karte + testy (`test/cloud/google_drive_storage_test.dart`), plus reálny
  sign-in a test upload na zariadení do priečinka `HMB_Sailing_Log_DATA` na
  Google Drive.
- Bod 2 — `CloudUploadTransport` + `RoutingTransport`, zapojené do
  `syncTransportProvider`/`syncEngineProvider` v `sync_provider.dart`
  (`engine.start()` teraz beží aj keď je zapnutý len `cloudEnabled`, nielen
  `enabled`). Testy: `test/sync/cloud_upload_transport_test.dart`,
  `test/sync/routing_transport_test.dart` (vrátane kľúčového testu z plánu
  §9 — vypnutý backend sync nezastaví cloud upload, a naopak).
- Vedľajšia oprava počas testovania: `attemptLightweightAuthentication()`
  na tomto zariadení nie je skutočne tichá (ukáže account picker aj bez
  akcie), preto `CloudUploadTransport` gate-uje na `CloudStorageProvider.
  isSignedInNow` (čisto in-memory, nikdy nevolá SDK) namiesto
  `currentAccount` — inak by periodický sync tick vedel vyvolať Google
  dialóg na pozadí, mimo akéhokoľvek used akcie.
- Priečinok na Drive premenovaný na `HMB_Sailing_Log_DATA` (namiesto
  medzerou oddeleného "HMB Sailing Log").

**Bod 3 — hotový a overený na Honore, najrizikovejší kus zo `§10` je za nami:**

- Mapa dňa vytiahnutá z `export_screen.dart`'s `_DayMapPreview` do
  `lib/features/export/presentation/widgets/day_map_view.dart`
  (`DayMapView`) — rovnaký widget pre foreground export aj budúci
  headless auto-export.
- Na Honore sa `captureFromWidget` **bez `context:` parametra** rozbil
  úplne (`No MediaQuery widget ancestor found`) — offscreen render vtedy
  nie je napojený na žiadny `FlutterView`. Oprava: vždy odovzdať `context:`
  z volajúceho widgetu.
- Väčšie zistenie presahujúce pôvodný plán: **satelitná vrstva (ArcGIS
  World_Imagery) sa v appke necachovala vôbec, ani na interaktívnej mape.**
  `TileCacheStore`/`CachingTileProvider` bol zapojený len pre OSM/dark/
  seamark vrstvy. `map_screen.dart`'s satelitná `TileLayer` aj
  `DayMapView`'s obe vrstvy teraz majú `tileProvider: CachingTileProvider(...)`
  so zdieľanými `layerId` (`'satellite'`, `'seamark'`) — tak dlaždice
  nacachované z bežného prezerania mapy (aj cez deň) sú k dispozícii aj
  headless snímke. Overené naživo: prepnutie interaktívnej mapy na satelit
  → počkanie → `DayMapView` capture mimo stromu ukázal reálny terén, nie
  sivý obdĺžnik.
- `DayMapView` dostal aj `TileDisplay.instantaneous()` namiesto default
  fade-in — widget existuje len na to, aby sa odfotil, fade-in animácia
  nemá čo animovať a v `captureFromWidget` necháva visieť
  `AnimationController`y po zahodení stromu (scheduler to hlási ako leak).
- Test `test/export/day_map_view_test.dart`: `captureFromWidget` musí bežať
  cez `tester.runAsync(...)` — `testWidgets` má falošné hodiny, reálny
  `delay:` v `captureFromWidget` bez toho nikdy neuplynie (10-minútový
  timeout, dvakrát, kým sa na to prišlo). Tile provider v teste je fake
  (žiadna sieť) — `DayMapView` preto dostal injektovateľný
  `tileProviderBuilder` parameter (default `CachingTileProvider.new`).

**Bod 4 — hotový, testy zelené (zatiaľ neoverené na Honore):**

- Nový `lib/features/cloud/services/auto_export_service.dart` —
  `AutoExportService.exportAndEnqueueDay({required AppDatabase db, required
  SyncEngine engine, required bool cloudEnabled, required Locale locale,
  required SkipperProfile skipperProfile, required int dayLogId, Uint8List?
  mapScreenshot})`. Znovupoužíva presne tie isté buildery ako ručný export
  (`PdfExportService.buildDayPdfBytes`, `GpxExporter.buildDayGpxBytes`) a
  rovnaké trvalé úložisko (`ExportService.saveBytesLocally`, teraz public —
  predtým `_saveBytesLocally`, premenované na znovupoužitie naprieč
  triedami) — auto-nahraný deň vyzerá identicky ako ručne exportovaný.
- `mapScreenshot` sa **nezachytáva vnútri tejto triedy** — nemá
  `BuildContext`. Volajúci (bod 5, `handleStopTap`) odfotí mapu a bajty
  odovzdá dnu.
- **Berie hotové hodnoty, nie Riverpod `Ref`** — objavené pri zapájaní do
  bodu 5: na verzii `flutter_riverpod` (2.6.1), ktorú appka používa, `Ref`
  a `WidgetRef` sú **nesúvisiace typy** (nie je medzi nimi vzťah
  podtyp/nadtyp). Pôvodný návrh s `required Ref ref` by sa nedal zavolať z
  `handleStopTap`, ktoré má len `WidgetRef`. Volajúci si teda sám prečíta
  všetko cez svoj vlastný `ref.read(...)` a pošle hotové hodnoty — čistejšie
  aj ľahšie testovateľné (test už nepotrebuje `ProviderContainer`).
- Gate na `cloudEnabled` sa počíta u volajúceho cez
  `await ref.read(syncSettingsProvider.future)`, nie `.valueOrNull` —
  druhý spôsob počas testovania odhalil reálny race: ak
  `syncSettingsProvider` v appke ešte nikdy nedobehol (headless volanie
  skôr, než niečo iné prečíta nastavenia), `.valueOrNull` je `null` a
  `cloudEnabled ?? false` potichu vynechá enqueue aj keď má používateľ
  cloud export zapnutý. `await .future` čaká na skutočnú hodnotu.
- Test `test/cloud/auto_export_service_test.dart` — `flutter test` nemá
  platform channel pre `path_provider`; namiesto vynechania testovania
  (ako `test/services/backup_service_test.dart` robí pre `BackupService`)
  sa tu nastavil `PathProviderPlatform.instance` na fake ukazujúci na
  dočasný adresár, keďže "ukladá sa na trvalé miesto" je práve to hlavné,
  čo bod 4 má overiť. Potreboval aj `initializeDateFormatting('sk', null)`
  — `GpxExporter.buildDayGpxBytes` volá `DateFormat(..., 'sk')` a appka
  túto inicializáciu bežne robí v `main.dart`, testy nie automaticky.

**Bod 5 — pôvodná verzia (spúšťač priamo v `handleStopTap`), overená na
Honore, potom nahradená (viď nižšie).** Prvý pokus zachytával mapu mimo
stromu cez `ScreenshotController.captureFromWidget` s 2s `delay` a hneď po
zastavení trackingu volal `AutoExportService.exportAndEnqueueDay(...)`
automaticky, bez akéhokoľvek zásahu používateľa.

### Bug: biela/prázdna mapa v automaticky nahranom PDF (nájdené a opravené 20. 7.)

Po prvom reálnom teste na Honore nahlásené: PDF na Drive malo mapu úplne
bielu — ani podklad (satelit), nič. Zvýšenie `delay` z 2 s na 4 s **nepomohlo**
(rovnaký bug, znova overené pulled PDF).

**Príčina:** `screenshot` balík (`captureFromWidget`/`widgetToUiImage`,
`screenshot-3.0.0/lib/screenshot.dart:115-259`) si stavia **vlastný,
izolovaný `PipelineOwner`/`BuildOwner`** mimo reálneho `SchedulerBinding`.
Jeho retry slučka prekresľuje strom len keď `BuildOwner.onBuildScheduled`
nahlási dirty stav — ale `flutter_map`'s dlaždice (`CachingTileProvider._load`
v `tile_cache.dart`) sa načítavajú **asynchrónne** (čítanie súboru z disku +
decode kodeku), aj keď sú už na disku cachované. Repaint po dokončení tohto
načítania sa v tomto izolovanom strome nikdy reálne neuplatnil — žiadny
`delay` to nevyriešil, lebo problém nebol v čase, ale v tom, že asynchrónne
obrázkové frames nikdy nedostali skutočný repaint v tejto izolovanej
pipeline. `export_screen.dart`'s `_DayMapPreview` (bod 3) tento bug nikdy
nemal — tam sa `Screenshot(controller:...)` mountuje **priamo do reálneho,
viditeľného stromu appky**, takže skutočné `SchedulerBinding` frames + reálny
`setState` z `Image`'s frame listenera prekreslia dlaždice normálne.

**Oprava:** `_captureDayMap` prestal používať `captureFromWidget` a namiesto
toho vloží `DayMapView` do reálneho stromu cez `OverlayEntry` posunutý
ďaleko mimo viditeľnej plochy (`Positioned(left: -2000, top: -2000, ...)`) —
rovnaká reálna vykresľovacia pipeline ako `export_screen.dart`, len
neviditeľná pre používateľa. Overené na Honore: mapa v PDF teraz ukazuje
skutočný terén, nie biely obdĺžnik.

### Zmena návrhu: Stop už automaticky neexportuje (rozhodnutie používateľa, 20. 7.)

Používateľ chce po ukončení trackingu ešte možnosť **finálnej úpravy
záznamu** (počasie, poznámky posádky, služby) predtým, než sa deň zabalí do
PDF a pošle na Drive. Pôvodné automatické volanie
`AutoExportService.exportAndEnqueueDay(...)` priamo v `handleStopTap` túto
možnosť nedávalo — export prebehol okamžite po potvrdení Stop.

**Nový tok:**
- `handleStopTap` (`tracking_control_dialogs.dart`) už **nezachytáva mapu
  ani nevolá `AutoExportService`**. Po potvrdení len zastaví tracking a
  presmeruje na Denník dňa (`context.go('/logbook/$charterId/day/$dayLogId')`)
  — `charterId` sa dočíta cez `db.getDayLogById(dayLogId)`. Skipper si tu
  môže záznamy opraviť/doplniť.
- Skutočný export (PDF+GPX zostavenie, cloud enqueue) sa presunul do
  `export_screen.dart`'s `_doExport` — presne to miesto, ktoré bolo pôvodne
  plánované ako bod 6 („ručné tlačidlo"), teraz slúži pre **obe** cesty
  naraz. Po tom, čo skipper potvrdí uloženie v `PdfPreviewScreen` (po
  podpise a náhľade), sa navyše zavolá nová `_maybeQueueToCloud(dayLogId,
  skipperProfile)`, ktorá cloud-zaradí presne tak, ako predtým robil
  `AutoExportService.exportAndEnqueueDay` priamo z `handleStopTap` — len o
  krok neskôr, po tom, čo skipper mal šancu deň upraviť.
- `_captureDayMap`/`OverlayEntry`-fix (vyššie) zostáva len ako referenčný
  popis vyriešeného bugu — samotný kód bol z `tracking_control_dialogs.dart`
  odstránený spolu s automatickým volaním; `export_screen.dart` má už svoju
  vlastnú, overene funkčnú on-tree mapovú snímku (bod 3), netreba duplikovať.
- Cesta „Zastaviť a ukončiť" (`main_scaffold.dart`, appka sa hneď ukončí)
  ostáva **automatická** — niet tam čas na review obrazovku, appka mizne
  hneď po potvrdení. Zachytáva `dayLogId` pred `stopTracking()` a volá
  `AutoExportService` (bez mapy) awaitnuto pred `SystemNavigator.pop()`,
  presne ako predtým.
- L10n reťazec `finishingDayExport` (progress dialóg pre starý auto-flow) je
  už nepoužitý a bol odstránený z 5 jazykov.

### Cloud enqueue teraz gate-uje na skutočné prihlásenie, nielen na prepínač

Zistené pri revízii: `cloudEnabled` sa predtým počítalo len z
`settings.cloudEnabled` (prepínač v nastaveniach). Ak bol prepínač zapnutý,
ale relácia nebola v pamäti skutočne prihlásená (napr. po reštarte appky
predtým, než `currentAccount` stihol doplniť `_cloudAccount`), vznikla
`cloud_export` položka vo fronte, ktorú `CloudUploadTransport` (gate na
`isSignedInNow`) nikdy nemohol odoslať — zostala „odložené" navždy. Presne
takto vznikla väčšina z **23 zaseknutých položiek** nájdených pri testovaní
dnes. Oprava: `cloudEnabled` sa teraz počíta ako
`settings.cloudEnabled && cloudStorageProvider.isSignedInNow` na oboch
miestach (`export_screen.dart`'s `_maybeQueueToCloud`, `main_scaffold.dart`).

### Nastavenia — vyčistenie (20. 7.)

- Popis pri prepínači cloud exportu (`syncCloudEnableToggleDesc`) bol stále
  starý text „automatické nahrávanie pribudne neskôr" — aktualizovaný vo
  všetkých 5 jazykoch, aby presne popisoval, čo appka teraz reálne robí.
- Tlačidlo **„Test nahrávania"** (`_testCloudUpload`, nahrávalo dummy .txt
  na Drive) odstránené — slúžilo len na overenie počas vývoja bodu 1, teraz
  nadbytočné. Odstránené aj zodpovedajúce l10n kľúče
  (`syncCloudTestUploadAction/Success/Failure`).
- **hmba.boats voľba dočasne skrytá.** `RadioListTile<SyncTarget>` picker
  (HMB Sailing Academy / Vlastný server) odstránený zo `_AccountSection` —
  backend na hmba.boats zatiaľ nie je pripravený. Zapnutie synchronizácie
  teraz vynúti `SyncTarget.custom` (jediná zapojená cesta), aby sa
  nestalo, že niekomu s predvoleným/starým `settings.target ==
  SyncTarget.hmbAcademy` reálny transport potichu ignoruje vyplnené
  URL/token polia. `_testConnection` zjednodušené na jedinú (custom) vetvu.
- **Wi-Fi politika príloh — nová možnosť „Použiť mobilné dáta".** Existujúca
  politika (`attachmentPolicy: wifiOnly` ako default) blokuje nahrávanie
  príloh (PDF/GPX aj obyčajné foto-prílohy), kým appka nevidí Wi-Fi — na
  mori to znamená, že fronta čaká donekonečna. Pridaný
  `allowMobileDataForAttachmentsProvider` (session-only `StateProvider<bool>`
  v `sync_provider.dart`, nepersistuje sa naschvál) a v `sync_queue_screen.dart`
  banner „Príloha čaká na Wi-Fi" s tlačidlom „Použiť mobilné dáta", ktoré
  override zapne a hneď spustí `engine.syncNow()`. Reset len reštartom
  appky — zabudnutý override si tak nemlčky nezožerie dáta na budúcej plavbe.
- **Tlačidlo „Vymazať frontu"** v `sync_queue_screen.dart` (ikona
  `delete_sweep_outlined` v AppBar, s potvrdzovacím dialógom) — nová
  `AppDatabase.deleteAllOutboxRows()`. Pridané kvôli 23 zaseknutým
  testovacím položkám vo fronte na Honore (vznikli ešte pred gate-om na
  `isSignedInNow` vyššie); keďže telefón bol v čase písania tejto poznámky
  odpojený od USB, čistenie cez `adb`/`sqlite3` sa nedalo dokončiť priamo —
  namiesto jednorazového zásahu pribudlo trvalé tlačidlo v appke, nabudúce
  to spraví používateľ sám.

**Stav po dnešných zmenách:** `flutter analyze lib test` 0 errors (486
zvyšných je info-level lint, nič nové), `flutter test` **267 zelených**.
Zmeny ešte len treba znova overiť na Honore (telefón bol koncom dňa
odpojený) — najmä nový tok Stop → Denník → ručný Export s cloud enqueue.

**Ďalší krok:** znova overiť na Honore celý nový tok (Stop → úprava v
Denníku → Export s podpisom → cloud enqueue), potom check-out chartera
(`handover_protocol_screen.dart` zatiaľ cloud-export nevolá) a napokon
príručka v 5 jazykoch + `docs/SYNC_API.md`.

## Prostredie

- Testovací telefón: Honor, `AF2SVB3727002028`, package
  `com.hmbsailinglogbook.app`, launcher activity
  `com.sailinglogbook.app.MainActivity` (pozor, líši sa od package).
- Databáza na zariadení: `app_flutter/sailing_logbook.db`, čítať cez
  `adb exec-out run-as ... cat` (PowerShell presmerovanie binárku pokazí,
  pridá BOM — použiť bash).
- Na Windows pred buildom pozabíjať zvyšné `dart.exe` / `flutter_tester.exe`.
- Jednorazové skripty písať v Darte, nie v PowerShelli: PS 5.1 číta `.ps1`
  ako ANSI a rozsype diakritiku aj cyriliku ešte pred spustením.
