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

KROK 0 hotový — môže sa začať bod 1 z poradia implementácie (plán, §10):
`CloudStorageProvider` + `GoogleDriveStorage` + prihlásenie v sync karte.

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
