# Kde sme skončili — 19. 7. 2026

Prenosný zápis stavu, aby sa dalo pokračovať z iného počítača. Všetko
podstatné je v gite; nič dôležité nezostalo len na jednom stroji.

## Vetvy

| vetva | stav |
|---|---|
| `main` | `ee5fc57`, pushnutá. Obsahuje prílivy (zliate dnes). |
| `feat/duty-roster` | 10 commitov nad `main`. **Hlavná rozrobená vetva.** |
| `feat/colreg-en` | 1 commit nad `main`, anglický COLREG. Nezliata. |
| `feat/tides-open-meteo` | už zliata do `main`, dá sa zmazať. |

## Čo je hotové na `feat/duty-roster`

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

**Stav:** `flutter analyze lib test` 0 errors, `flutter test` **245 zelených**.
Overené na Honore vrátane migrácie **v19 → v21 na reálnych dátach** (nič sa
nestratilo).

## Čo zostáva na `feat/duty-roster`

- `docs/SYNC_API.md` — poznámka o rezervovanom type `duty_period`.
- `docs/uzivatelska_prirucka.md` — sekcia o službe (in-app príručka v 5
  jazykoch **už hotová**, chýba len tento markdown).
- Rozhodnúť, či zliať do `main` alebo cez PR.

## Ďalšia téma: automatický export do cloudu

Plán je celý v **`docs/plan_cloud_export.md`**. Zhrnutie:

- Po ukončení dňa a pri check-oute sa PDF + GPX samy nahrajú na Disk.
- Cloud **nie je nový mechanizmus** — je to ďalšia vetva existujúceho
  outboxu z `hmb_core`, každá vetva má vlastný `SyncPolicyTransport`.
- Nastavenia idú **do existujúcej sync karty**, nie do novej sekcie.
- Rozhranie `CloudStorageProvider`, aby sa dal pridať Proton Drive a iné.
- Mapa musí byť v PDF aj pri automate — rieši to
  `ScreenshotController.captureFromWidget` (vykreslenie mimo stromu).

### Čo treba spraviť ako prvé (KROK 0, bez kódu)

Google Cloud Console — **existujúci projekt netreba rušiť**, appka dnes
nepoužíva žiadnu Cloud službu. Podrobný postup je v pláne, §7. Skratka:

1. Zapnúť **Google Drive API**.
2. OAuth consent screen, rozsah `drive.file`, a **prepnúť do *In production***
   (v *Testing* expirujú refresh tokeny po 7 dňoch — automat by ticho odumrel).
3. Tri OAuth clienty typu Android, package `com.hmbsailinglogbook.app`:
   - debug `C2:00:42:E8:39:BD:8E:DA:10:A6:F8:7A:75:F7:A8:C4:CD:80:9A:05`
   - upload `01:0C:5E:8C:F7:18:BC:C5:E4:20:C1:8B:FC:5E:36:B8:BF:8F:41:2F`
   - **Play App Signing** — odtlačok vytiahnuť z Play Console → Test and
     release → App integrity → App signing key certificate. Sailinglog je na
     testovacom kanáli, takže appku pre testerov podpisuje Google, nie upload
     kľúč. Bez tohto clientu ide prihlásenie na vývojárskom telefóne, ale
     testerom z Play nie.

Poradie implementácie je v pláne, §10. Prvý kód až po KROKU 0, lebo bez
OAuth clientu sa prihlásenie nedá ani otestovať.

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
