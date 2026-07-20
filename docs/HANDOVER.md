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

**Bod 5 — hotový (spúšťač na konci dňa), testy zelené, zatiaľ neoverené na
Honore:**

- `handleStopTap` (`tracking_control_dialogs.dart`): po potvrdení zachytí
  `GpsTrackingService().activeDayLogId` **pred** `stopTracking()` (ktoré ho
  nuluje), ukáže progress dialóg (`l.finishingDayExport`), odfotí mapu dňa
  mimo stromu (`_captureDayMap` — načíta track pointy dňa cez
  `db.getSessionsForDay`/`getTrackPointsForSession`, `captureFromWidget`
  s `context:` a 2s `delay`), zastaví tracking, zavolá
  `AutoExportService.exportAndEnqueueDay(...)`. Zlyhanie snímky (výnimka,
  `context` už nemounted) nikdy nezastaví uloženie dňa — PDF sa spraví aj
  bez mapy, používateľ dostane `pdfMapUnavailable` hlášku (nikdy potichu,
  presne podľa plánu §3).
- Cesta „Zastaviť a ukončiť" (`main_scaffold.dart`, appka sa hneď
  ukončí): rovnaké zachytenie `dayLogId` pred `stopTracking()`, ale
  **bez** snímky mapy (niet času na `captureFromWidget`) a volanie
  `AutoExportService` sa **awaituje** pred `SystemNavigator.pop()` — je to
  čisto lokálna práca (PDF/GPX zostavenie + zápis súboru + outbox insert,
  žiadna sieť), takže musí dobehnúť skôr, než proces zomrie, inak by sa
  deň stratil úplne, nielen neodoslal.
- Nový l10n reťazec `finishingDayExport` (5 jazykov).

**Ďalší krok:** bod 6 — ručné tlačidlo v `export_screen.dart` a check-out
chartera (`handover_protocol_screen.dart`). Predtým treba na Honore reálne
overiť celý reťazec bodov 3–5 (ukončenie dňa so zapnutým cloud exportom).

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
