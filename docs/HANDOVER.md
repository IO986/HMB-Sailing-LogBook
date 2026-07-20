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
