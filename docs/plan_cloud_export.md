# Automatický export do cloudového úložiska

## Context

Denný export sa dnes robí ručne: Export dňa → podpis → zdieľať. Na lodi to
znamená, že sa naň zabudne, a keď telefón spadne cez palubu alebo sa stratí,
záznamy sú preč. Cieľom je, aby sa po ukončení trackingu dňa PDF a GPX samy
dostali do cloudu bez ďalšieho ťukania.

### Rozhodnutia používateľa

- **Prihlásenie cez `google_sign_in` s rozsahom `drive.file`** — appka vidí len
  súbory, ktoré sama vytvorila. Google pri tomto rozsahu nevyžaduje
  bezpečnostný audit.
- **Ale nie natvrdo na Google.** Má byť možné pridať Proton Drive či iné
  úložisko. Google je prvá implementácia, nie jediná.
- **Nahráva sa PDF dňa + GPX trasy.** Záloha databázy nie (obsahuje všetky
  plavby a rýchlo rastie).
- **Spúšťače:** ukončenie trackingu dňa, check-out chartera, a ručné tlačidlo.
- **Fronta:** použiť existujúci outbox z `hmb_core`, nahrávania budú vidieť
  v obrazovke Fronta synchronizácie.

---

## 1. Architektúra

`hmb_core` sa **nemení**. Podľa pravidla 3 v CLAUDE.md sú konkrétne backendy
vecou aplikácie; knižnica pozná len `SyncTransport`.

Cloud **nie je nový mechanizmus** — je to ďalšia vetva toho, čo už stojí.
Rovnaký engine, rovnaká fronta, rovnaký `SyncPolicyTransport`, rovnaký model
nastavení.

```
SyncEngine ──► RoutingTransport                                  (nové, tenké)
   ├ 'cloud_export' ─► SyncPolicyTransport ─► CloudUploadTransport ─► CloudStorageProvider
   │                    (enabled: cloudEnabled)                       ├─ GoogleDriveStorage
   │                                                                  └─ ProtonDriveStorage (neskôr)
   └ ostatné ────────► SyncPolicyTransport ─► Strapi | Rest        (dnešný stav, nedotknutý)
                        (enabled: enabled)
```

**Každá vetva má vlastný `SyncPolicyTransport`.** Tým sa rieši pasca, ktorá by
inak zabila celý návrh: `SyncPolicyTransport.isReachable()`
(`lib/sync/sync_policy_transport.dart:33`) vracia `_isSyncEnabled() && ...`,
takže jedna spoločná politika nad oboma vetvami by pri vypnutej synchronizácii
s backendom zhasla aj nahrávanie na Disk. Dve inštancie, každá so svojím
prepínačom, to riešia bez písania novej logiky — trieda sa použije presne
tak, ako bola postavená.

Wi-Fi politika pre prílohy (`attachmentPolicy`) sa **zdieľa**. Nahrávané PDF
a GPX sú prílohy, takže existujúce pravidlo „pri mobilných dátach odlož" na ne
sadne bezo zmeny a nevzniká druhý, konkurenčný prepínač.

`RoutingTransport` je zámerne tenký: rozdelí dávku podľa `entityType`, zavolá
príslušnú vetvu a spojí výsledky (engine ich páruje cez `itemId`, nie poradím).
`isReachable()` vráti `true`, ak je dostupná aspoň jedna vetva.
`batchSize` = 1 — objem je pár súborov denne a odpadne delenie dávky.

**Prečo nie druhý engine:** outbox je jedna drift tabuľka a engine už rieši
perzistenciu, backoff aj reakciu na obnovenie spojenia. Druhý by to
duplikoval.

**Poučenie z implementácie bodu 2 (20. 7.):** `CloudUploadTransport` sa pred
pokusom o upload nesmie pýtať SDK, či je používateľ prihlásený —
`attemptLightweightAuthentication()`/`currentAccount` na tomto zariadení
vie ukázať account picker, aj keď je volaný "ticho". Keďže periodický sync
tick beží na pozadí bez priamej akcie používateľa, takéto volanie by mohlo
vyvolať Google dialóg mimo kontextu. Transport preto gate-uje na
`CloudStorageProvider.isSignedInNow` — čisto in-memory príznak, nikdy
nevolá platformové SDK — a keď je `false`, vráti `deferred` bez pokusu.
Skutočné (opätovné) prihlásenie sa smie diať len z priamej akcie
používateľa (tlačidlo v nastaveniach), nikdy z pozadia.

---

## 2. Rozhranie úložiska

Nový `lib/features/cloud/domain/cloud_storage_provider.dart` — čistý Dart,
bez Googlu:

```dart
abstract class CloudStorageProvider {
  String get id;                    // 'google_drive', 'proton_drive'
  String get displayName;

  Future<bool> get isSignedIn;
  Future<CloudAccount?> signIn();   // null = používateľ zrušil
  Future<void> signOut();

  /// Nahrá súbor do [folderPath] (napr. ['HMB_Sailing_Log_DATA', 'Plavba 2026']).
  /// Vracia identifikátor súboru v úložisku.
  Future<String> upload({
    required File file,
    required String fileName,
    required List<String> folderPath,
    required String mimeType,
  });
}
```

Implementácia `lib/features/cloud/data/google_drive_storage.dart` cez
`google_sign_in` + `googleapis` (Drive v3) +
`extension_google_sign_in_as_googleapis_auth`.

**Proton Drive zatiaľ nejde** (overené 2026-07-19). Proton nemá verejné API;
stavia SDK, ktorého preview je na GitHube, ale **autentifikácia pre samostatné
integrácie tretích strán ešte nie je podporovaná** — používateľa by sme nemali
ako prihlásiť. Produkčná pripravenosť je cielená na koniec 2026 / začiatok
2027 a je to odhad. Neoficiálny most `henrybear327/Proton-API-Bridge` (Go,
reverzne inžinierovaný, používa ho rclone) sa z Fluttera nedá rozumne použiť.
K tomu je Proton E2E šifrovaný, takže nahranie znamená implementovať ich
kľúčovú hierarchiu, nie len poslať bajty s tokenom.

**Ak je cieľom nedávať dáta Googlu, jednoduchší je WebDAV** (Nextcloud,
ownCloud, Koofr, vlastný server): URL + meno + heslo + HTTP PUT, žiadny OAuth,
žiadne SHA-1 ani Play App Signing, a `dio` je už v projekte. Menej práce než
Google Drive. Ako druhá implementácia `CloudStorageProvider` dáva zmysel skôr
než Proton.

Priečinky sa pri `drive.file` dajú vytvárať a appka ich potom vidí (sú jej
vlastné). Štruktúra zrkadlí lokálnu z `export_service.dart:335-356`:
`HMB_Sailing_Log_DATA / {nazov_plavby} / Day_{yyyy-MM-dd}`.

---

## 3. Bezhlavý export

Dnes všetky štyri metódy v `export_service.dart` berú `BuildContext` a končia
zdieľaním. Pre automat treba cestu bez UI.

Použiteľné už existuje:
- `PdfExportService.exportDay(...)` (`pdf_export_service.dart:222`) je statická,
  bez kontextu, vracia `File`. Vyžaduje `AppLocalizations` — získa sa cez
  `AppLocalizations.delegate.load(locale)`, kontext netreba.
- `GpxExporter.buildDayGpxBytes` (`lib/core/utils/gpx_exporter.dart`).
- Poradie dotazov na dáta dňa odpozorovať z `export_service.dart:145-165`.

**Hotové 20. 7.** `lib/features/cloud/services/auto_export_service.dart`:
`Future<void> exportAndEnqueueDay({required Ref ref, required int dayLogId,
Uint8List? mapScreenshot})` — načíta charter, deň, záznamy, služby a
sessions, vyrobí PDF aj GPX, uloží ich do **trvalého** adresára cez
`ExportService.saveBytesLocally` (predtým `_buildExportDir`/
`_saveBytesLocally`, teraz public práve kvôli tomuto — nie do temp, súbor
musí prežiť do ďalšieho spustenia appky) a zaradí do outboxu.

**Mapa v PDF musí byť v oboch cestách.**

Snímka nevzniká z dát, ale odfotením vykresleného widgetu — `export_screen`
volá `capture()` na `flutter_map`, ktorý je práve na obrazovke
(`export_screen.dart:84-85`). Pri ukončení dňa taký widget neexistuje.
Rieši to `ScreenshotController.captureFromWidget(...)`, ktoré vykreslí widget
**mimo stromu** (`screenshot-3.0.0/lib/screenshot.dart:95`), takže mapu vieme
odfotiť aj bez toho, aby ju používateľ videl.

Aby obe cesty dávali identický obrázok, mapa dňa sa vytiahne z
`export_screen.dart` do samostatného widgetu (`_DayMapPreview` → nový
`lib/features/export/presentation/widgets/day_map_view.dart`) a obe cesty
budú renderovať ten istý.

Dve podmienky, na ktorých to stojí, a obe sú splnené:
- **Dlaždice musia byť lokálne**, inak vyjde sivý obdĺžnik.
  `TileCacheStore` (`lib/core/services/tile_cache.dart:14`) je write-through
  cache na disk, takže oblasť, ktorú skipper cez deň pozeral, je uložená.
  Plus existuje sťahovanie regiónu vopred (`:129`).
- **Potrebný `BuildContext`** (kvôli MediaQuery a téme). Preto sa snímka
  urobí v `handleStopTap` (`tracking_control_dialogs.dart:133`), ktoré kontext
  má a beží, kým je appka živá — nie v bezkontextovom
  `TrackingNotifier.stopTracking()`.

**Overené 20. 7. na Honore — obe podmienky platili presnejšie, než znelo
vyššie:** `BuildContext` nie je len "kvôli MediaQuery a téme" ako všeobecná
odporúčaná prax — bez odovzdania `context:` priamo do
`captureFromWidget(...)` render úplne zlyhá (`No MediaQuery widget
ancestor found`), lebo offscreen strom vtedy nie je napojený na žiadny
`FlutterView`. A "dlaždice musia byť lokálne" platilo len pre OSM/dark/
seamark vrstvy — satelitná (ArcGIS World_Imagery), ktorú `DayMapView`
používa ako podklad, sa v appke necachovala vôbec, ani na interaktívnej
mape. Oboje opravené (viď `docs/HANDOVER.md`, bod 3).

**Druhý, závažnejší bug (nájdený a opravený 20. 7., po prvom reálnom teste
na Honore):** aj s vyššie uvedenými opravami bola mapa v automaticky
nahranom PDF **úplne biela** — ani podklad. Príčina nebola v čase (`delay`
2 s → 4 s nič nezmenilo), ale v tom, že `screenshot` balíka
`captureFromWidget` beží nad **vlastným, izolovaným `PipelineOwner`/
`BuildOwner`** mimo reálneho `SchedulerBinding` appky. `flutter_map`'s
dlaždice sa načítavajú asynchrónne (`CachingTileProvider._load` — súbor z
disku + decode kodeku, aj keď je tile už cachovaná), a repaint po takom
asynchrónnom dokončení sa v tejto izolovanej pipeline nikdy reálne
neuplatnil. Riešenie: `_captureDayMap` prestal používať
`captureFromWidget` úplne a namiesto toho vkladá `DayMapView` do
**reálneho** stromu appky cez `OverlayEntry` posunutý mimo viditeľnú
plochu (`Positioned(left: -2000, top: -2000)`) — presne ten istý mechanizmus
ako `export_screen.dart`'s overene funkčný `_DayMapPreview` (bod 3), len
neviditeľný. Detaily v `docs/HANDOVER.md`.

**Zmena návrhu (rozhodnutie používateľa, 20. 7.): mapová snímka aj celý
export sa presunuli preč z `handleStopTap`.** Pôvodne opísaný postup nižšie
(potvrdenie → snímka mimo stromu → zastavenie → PDF → fronta, všetko
automaticky v jednom ťahu) už neplatí — nahradil ho tok v §5 nižšie, kde
Stop len uloží deň a otvorí Denník na úpravu, a samotný export (vrátane
snímky mapy) sa deje až keď skipper explicitne potvrdí export. Text nižšie
zostáva ako popis vyriešeného problému s mapou, nie ako aktuálny tok.

**Ak sa snímka nepodarí** (nedokreslené dlaždice, výnimka): PDF sa vyrobí aj
tak, vytlačí `pdfMapUnavailable`, ale používateľ dostane hlášku, že sa nahralo
bez mapy. Nikdy nie potichu — mapleský PDF, o ktorom nikto nevie, je horší
než chýbajúci.

Výnimka je cesta „Zastaviť a ukončiť" (`main_scaffold.dart:280-283`), ktorá
appku hneď zabíja. Tam sa snímka nestíha; deň sa zaradí bez mapy a doplní sa
pri ďalšom otvorení exportu.

---

## 4. Zaradenie do fronty

```dart
await engine.enqueue(
  entityType: 'cloud_export',
  entityId: 'day-$dayLogId-pdf',
  payload: {'kind': 'day_pdf', 'dayLogId': dayLogId, 'folder': [...]},
  attachments: [Attachment(localPath: pdf.path, field: 'file',
      mimeType: 'application/pdf')],
);
```

`entityType` je v `hmb_core` voľný reťazec, ktorý knižnica nikdy
neinterpretuje (`outbox_item.dart:8-10`) — pridanie `cloud_export` do
`lib/sync/sync_entity_types.dart` je čisto aplikačná vec.

`CloudUploadTransport.push` prejde prílohy, nahrá ich cez
`CloudStorageProvider` a vráti `SyncItemResult` s `remoteId` = id súboru
v úložisku. Chyba siete → `failure` s `retryable: true`; chýbajúce
prihlásenie → `deferred`, aby sa nemíňal `retryCount` (rovnaká úvaha ako
v `SyncPolicyTransport`, viď `docs/SYNC_API.md §7`).

**Dôležité, poučenie z 20. 7.:** volanie `engine.enqueue(entityType:
'cloud_export', ...)` musí byť podmienené `settings.cloudEnabled` **už na
mieste zápisu** (v `AutoExportService`/`handleStopTap`/check-oute), nie až
neskôr v `SyncPolicyTransport`/`RoutingTransport`. Presne tento bug sa dnes
opravoval pre bežný log sync — `engine.enqueue()` sa volalo bez ohľadu na
`settings.enabled`, takže outbox rástol donekonečna aj s vypnutou
synchronizáciou (viď `docs/HANDOVER.md`, sekcia „Sync fixy"). Cloud vetva
potrebuje rovnaký gate pri zápise, inak sa ten istý bug zopakuje pre
`cloud_export` položky.

**Druhé poučenie, po prvom reálnom teste (20. 7.):** samotné
`settings.cloudEnabled` (prepínač) **nestačí** — treba aj skutočný
`CloudStorageProvider.isSignedInNow`. Ak je prepínač zapnutý, ale appka
nemá v pamäti reálnu prihlásenú reláciu (napr. tesne po štarte appky),
`cloud_export` položka sa aj tak zaradí do fronty, ale
`CloudUploadTransport` (gate na `isSignedInNow`) ju nikdy neodošle — zostane
„odložené" navždy. Presne takto vzniklo 23 zaseknutých položiek nájdených
pri testovaní. Gate na zápise je teda
`settings.cloudEnabled && cloudStorageProvider.isSignedInNow`, nie len prvé.

---

## 5. Spúšťače

**Zmenené 20. 7. (rozhodnutie používateľa):** Stop už **neexportuje priamo**
— skipper má dostať šancu záznam ešte upraviť predtým, než sa zabalí do PDF
a pošle na Drive. Skutočný spúšťač je teraz len jeden kód, volaný z dvoch
miest:

- **Koniec dňa (bežná cesta, appka ostáva otvorená)** — `handleStopTap`
  (`tracking_control_dialogs.dart`) po potvrdení len zastaví tracking a
  presmeruje na Denník dňa (`/logbook/{charterId}/day/{dayLogId}`; `charterId`
  sa dočíta cez `db.getDayLogById(dayLogId)`). **Nezachytáva mapu, nevolá
  `AutoExportService`.** Skipper si tu môže opraviť/doplniť záznamy.
  **Pozor:** `GpsTrackingService.stopTracking()` nuluje `_activeDayLogId`
  (`gps_tracking_service.dart:311`), takže `dayLogId` treba prečítať
  **pred** volaním, presne ako predtým.
- **Skutočný export** — `export_screen.dart`'s `_doExport` (jednodňová
  vetva, `widget.dayLogId != null`), presne to miesto, ktoré bolo v pláne
  pôvodne bodom 6 („ručné tlačidlo"). Po podpise, náhľade (`PdfPreviewScreen`)
  a potvrdení uloženia (`onSave`) sa navyše zavolá nová
  `_maybeQueueToCloud(dayLogId, skipperProfile)` — zostaví PDF/GPX cez
  `AutoExportService.exportAndEnqueueDay(...)` znova (z aktuálneho stavu DB,
  teda vrátane práve vykonaných úprav) a zaradí do cloud fronty, ak
  `cloudEnabled && isSignedInNow`. Mapová snímka pre túto vetvu je tá istá,
  ktorú si obrazovka aj tak vyrobila na zobrazenie náhľadu (`_mapScreenshots`)
  — žiadna duplicitná off-tree snímka.
- **Cesta „Zastaviť a ukončiť"** (`main_scaffold.dart:280-283`, appka sa
  hneď ukončí) zostáva **automatická** — niet tam čas na review obrazovku.
  Zachytí `dayLogId` pred `stopTracking()`, zavolá `AutoExportService` (bez
  mapy) **awaitnuto** pred `SystemNavigator.pop()` — je to čisto lokálna
  práca (PDF/GPX + zápis súboru + outbox insert, žiadna sieť), musí
  dobehnúť skôr, než proces zomrie.
- **Check-out chartera** — `handover_protocol_screen.dart`, po uložení
  check-out protokolu zaradiť charterové PDF. **Zatiaľ nespravené.**

---

## 6. Nastavenia

**Žiadny nový provider a žiadna nová sekcia.** Rozšíri sa to, čo existuje:

- `lib/core/models/sync_settings.dart` — pribudnú polia `cloudEnabled`,
  `cloudProvider` (enum `CloudProvider { googleDrive }`, pripravený na ďalšie),
  `cloudUploadPdf`, `cloudUploadGpx`. Rovnaký `copyWith` vzor.
- `lib/core/providers/sync_settings_provider.dart` — nové kľúče do
  `shared_preferences` a `setX` metódy, presne podľa existujúceho vzoru
  (`:49-82`). Prihlásený účet a token do `flutter_secure_storage`, rovnako ako
  `readSyncCustomToken` (`:7-28`).
- UI **vnútri `_AccountSection`** (`settings_screen.dart:628`), pod dnešnými
  prepínačmi synchronizácie: `SwitchListTile` pre cloud, `RadioListTile`
  pre poskytovateľa (rovnako ako dnešné `RadioListTile<SyncTarget>` na `:709`),
  tlačidlo prihlásiť/odhlásiť s menom účtu, prepínače PDF a GPX.

`attachmentPolicy` sa nezdvojuje — platí spoločne pre backend aj cloud.

**Zmenené 20. 7., po prvom reálnom teste:**
- Popis pri cloud prepínači (`syncCloudEnableToggleDesc`) aktualizovaný —
  automatické nahrávanie po ukončení dňa už nie je „pribudne neskôr", je
  hotové a popis to má povedať.
- Tlačidlo „Test nahrávania" (dummy .txt na Drive, slúžilo len na overenie
  bodu 1 počas vývoja) odstránené i s l10n kľúčmi.
- `RadioListTile<SyncTarget>` picker (HMB Sailing Academy / Vlastný server)
  dočasne odstránený — hmba.boats backend zatiaľ nie je pripravený.
  Zapnutie synchronizácie teraz vynúti `SyncTarget.custom`.
- Wi-Fi-only politika príloh dostala možnosť dočasného override
  (`allowMobileDataForAttachmentsProvider`, session-only) s bannerom v
  `sync_queue_screen.dart` — na mori Wi-Fi spravidla nie je, fronta by inak
  čakala donekonečna.
- `sync_queue_screen.dart` dostal aj tlačidlo „Vymazať frontu"
  (`AppDatabase.deleteAllOutboxRows()`) pre staré zaseknuté položky.

---

## 7. KROK 0 — Google Cloud Console (prerekvizita, nie „potom")

Bez toho sa prihlásenie na zariadení nedá ani otestovať, takže to musí byť
skôr než bod 1.

**Údaje, ktoré do konzoly treba (už zistené):**

| položka | hodnota |
|---|---|
| Package name | `com.hmbsailinglogbook.app` |
| SHA-1 debug | `3C:4B:92:57:48:2C:20:9A:8B:D5:05:8C:A8:4D:BB:A5:97:CB:AE:6C` — **per-stroj**, z `~/.android/debug.keystore`; na inom počítači pretiahni znova cez `keytool -list -v -keystore ... -alias androiddebugkey -storepass android -keypass android` |
| SHA-1 upload | `01:0C:5E:8C:F7:18:BC:C5:E4:20:C1:8B:FC:5E:36:B8:BF:8F:41:2F` |
| SHA-1 Play App Signing | `90:49:70:2B:1F:F1:54:E6:99:D0:06:29:DE:A4:BF:50:5B:DA:4D:E3` |
| Web client ID (`serverClientId`, bod 8) | `67335624649-fpmgdt6cae47i6i8qq5ll6upvaivnofa.apps.googleusercontent.com` |

Pozor: `namespace` v Gradle je `com.sailinglogbook.app`, ale pre OAuth
rozhoduje **`applicationId`**, teda `com.hmbsailinglogbook.app`
(`android/app/build.gradle:43`).

**Kroky:** (hotové 20. 7. — konkrétne hodnoty a stav zaškrtávania sú v
`docs/HANDOVER.md`, tu zostáva len postup ako referencia)
1. console.cloud.google.com → **použiť existujúci projekt**, ak nejaký je.
   Nič sa neruší: appka dnes nepoužíva žiadnu Cloud službu (žiadny Firebase,
   žiadny `google-services.json`, žiadny Maps kľúč v manifeste — jediný
   „google" balík je `google_fonts`, ktorý beží bez kľúča). Zapnutie API aj
   založenie OAuth clientu sú prírastkové operácie. Nový projekt len vtedy,
   ak žiadny neexistuje.
2. APIs & Services → Library → **Google Drive API** → Enable.
3. OAuth consent screen: typ External, názov appky, kontaktný e-mail.
   Scope pridať **`.../auth/drive.file`** — nič viac.

   **Prepnúť do stavu *In production*, nenechať v *Testing*.** Testing má
   strop 100 ručne pridaných test users a hlavne **refresh tokeny expirujú
   po 7 dňoch** — pri funkcii, ktorá má nahrávať ticho na pozadí, by sa po
   týždni prestala diať a nikto by nevedel prečo.
   `drive.file` je **non-sensitive** rozsah, takže prechod do produkcie
   nevyžaduje bezpečnostný audit (ten platí pre `drive` a `drive.readonly`).
   To je aj dôvod, prečo je zvolený práve tento rozsah.
4. Credentials → Create credentials → OAuth client ID → **Android**.
   Vyplniť package name a SHA-1 **debug** kľúča. Uložiť.
5. To isté ešte raz pre SHA-1 **upload** kľúča (jeden client = jeden odtlačok).
6. **Play App Signing — pre tento projekt to NIE je okrajový prípad.**
   Sailinglog je na testovacom kanáli v Play, takže appku, ktorú dostanú
   testeri, podpisuje Google svojím kľúčom, nie upload kľúčom vyššie.
   Odtlačok vziať z Play Console → Test and release → App integrity →
   **App signing key certificate** a založiť naň ďalší OAuth client.

   Bez neho vznikne mätúci stav: na vývojárskom telefóne z `flutter install`
   prihlásenie ide, testerom z Play nie, a vyzerá to ako chyba v kóde.

   Pozn.: „testovanie" v Play Console (distribučný kanál) a „Testing"
   v OAuth consent screen (bod 3) sú dve nesúvisiace veci s rovnakým názvom.
7. Android client ID sa **nedáva do kódu** ani do `google-services.json`;
   `google_sign_in` ho na Androide páruje cez podpis a package name.
8. **Objavené až pri implementácii bodu 1 z §10, pôvodne tu chýbalo:**
   `google_sign_in` 7.x (aktuálna major verzia, viď §8 nižšie) vyžaduje na
   Androide `serverClientId`, ak appka nepoužíva `google-services.json`/
   Firebase — inak `GoogleSignIn.instance.initialize()`/`authenticate()`
   zlyhá **potichu** (žiadna chybová hláška, tlačidlo len ostane vyšednuté).
   Credentials → Create credentials → OAuth client ID → **Web application**
   (redirect URI nechať prázdne). Vzniknutý Client ID (nie Secret — ten sa
   pri tomto flow nepoužíva vôbec, appka nemá backend) ide priamo do kódu
   ako `kGoogleWebClientId` v `lib/core/config/api_constants.dart` — na
   rozdiel od Android clientov to **nie je** tajná hodnota (rovnaká logika
   ako Firebase `default_web_client_id`).

**Neskôr, pred publikovaním:** Play Console → Data safety doplniť, že appka
pristupuje k súborom používateľa a nahráva ich na jeho Disk.

---

## 8. Balíky

`google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth`.
Prvé dva sú veľké; sledovať dopad na veľkosť APK (dnes debug 209 MB, release
podstatne menej).

**Ďalšie poučenie z 20. 7.:** `StrapiTransport`/`RestTransport` pôvodne
nemali na Dio klientovi žiadny `connectTimeout`/`sendTimeout`/
`receiveTimeout` — pri slabom/žiadnom signáli pokus visel na platformovom
defaulte (rádovo minúty), čo pri väčšej fronte držalo rádio zbytočne
dlho aktívne a vybíjalo batériu (opravené pridaním limitov 10s/20s/20s).
`GoogleDriveStorage`/`CloudUploadTransport` musia mať rovnaké explicitné
limity od začiatku — veľkorysejšie pre samotný upload PDF/GPX (väčšie
súbory, pomalšie spojenie na mori), ale nikdy bez stropu.

---

## 9. Testy

- `cloud_upload_transport_test.dart` — falošný `CloudStorageProvider`: úspech →
  `success` s `remoteId`; výpadok siete → `failure` + `retryable`;
  neprihlásený → `deferred` a `retryCount` sa nezvýši.
- `routing_transport_test.dart` — `cloud_export` ide do cloudu, `log_entry` do
  pôvodného transportu, výsledky sa párujú podľa `itemId`; `isReachable`
  vráti true, keď je dostupná aspoň jedna vetva. **Kľúčový test:** vypnutá
  synchronizácia s backendom + zapnutý cloud → nahrávanie stále beží,
  a naopak. To je celý dôvod, prečo má každá vetva vlastnú politiku.
- `auto_export_service_test.dart` — nad `NativeDatabase.memory()`: po ukončení
  dňa vzniknú dve položky vo fronte, súbory existujú na disku.
- `day_map_view_test.dart` — widget test, že `captureFromWidget` nad mapou dňa
  vráti neprázdny PNG. Nedokáže síce, že sú v ňom dlaždice, ale zachytí, keď
  sa vykresľovanie mimo stromu rozbije úplne (chýbajúca MediaQuery a pod.).
- Ručný test na Honore: zapnúť režim lietadlo, ukončiť deň, overiť že položky
  čakajú vo fronte, zapnúť sieť a overiť, že sa nahrali.

---

## 10. Poradie

1. **Hotové 20. 7., overené na Honore.** `CloudStorageProvider` +
   `GoogleDriveStorage` + prihlásenie v sync karte. Overiť, že sa dá
   prihlásiť a nahrať testovací súbor.
2. **Hotové 20. 7., overené na Honore.** `CloudUploadTransport` +
   `RoutingTransport` + zapojenie do `sync_provider.dart`, s testami.
3. **Hotové 20. 7., overené na Honore.** Vytiahnuť mapu dňa do
   `day_map_view.dart` a overiť `captureFromWidget` **na Honore** — či
   snímka mimo stromu naozaj obsahuje dlaždice. Toto bol najrizikovejší
   kus; tri reálne problémy sa našli a opravili (detaily v
   `docs/HANDOVER.md`): chýbajúci `context:` parameter (bez neho žiadna
   `MediaQuery`), satelitná vrstva sa nikde necachovala (opravené
   `tileProvider: CachingTileProvider(...)` aj na interaktívnej mape), a
   fade-in animácia dlaždíc nechávala visieť `AnimationController`y po
   `captureFromWidget` (opravené `TileDisplay.instantaneous()`).
4. **Hotové 20. 7., testy zelené (ešte neoverené na Honore).**
   `AutoExportService` (PDF s mapou + GPX do trvalého adresára). Poučenie:
   gate na `cloudEnabled` musí čakať na `syncSettingsProvider.future`, nie
   čítať `.valueOrNull` — headless volanie môže bežať skôr, než nastavenia
   niekde inde v appke vôbec dobehnú, a `.valueOrNull` by v tom okne potichu
   čítal ako vypnuté (detaily `docs/HANDOVER.md`).
5. **Hotové a overené na Honore 20. 7. (dva kolá).** Prvé kolo: spúšťač na
   konci dňa priamo v `handleStopTap` + núdzová cesta „Zastaviť a ukončiť"
   (`main_scaffold.dart`). Poučenie: `AutoExportService` napokon berie
   hotové hodnoty (`AppDatabase`, `SyncEngine`, `bool`, `Locale`,
   `SkipperProfile`), nie Riverpod `Ref` — na `flutter_riverpod` 2.6.1 sú
   `Ref` a `WidgetRef` nesúvisiace typy. Reálny test na Honore odhalil bielu
   mapu v PDF (viď §3) — opravené (`OverlayEntry` namiesto
   `captureFromWidget`). Druhé kolo, po rozhodnutí používateľa: Stop už
   priamo neexportuje, presúva sa na Denník na úpravu; export + cloud
   enqueue presunuté do ručného exportu (bod 6, teraz zlúčený s týmto
   bodom — viď §5). Cesta „Zastaviť a ukončiť" ostala automatická.
6. **Hotové 20. 7., zlúčené s bodom 5 vyššie** — `export_screen.dart`'s
   `_doExport`/`onSave` je teraz aj ten „ručný spúšťač", nie len zdieľanie
   lokálneho súboru.
7. Check-out chartera (`handover_protocol_screen.dart`) — **zatiaľ
   nespravené**, ďalší krok.
8. Príručka v 5 jazykoch + `docs/SYNC_API.md` (nový typ `cloud_export`) —
   zatiaľ nespravené.

**Vedľajšie položky vyriešené 20. 7. mimo pôvodného poradia:**
- Cloud enqueue gate rozšírený o `isSignedInNow` (nielen prepínač) — viď §4.
- Nastavenia vyčistené: popis pri prepínači cloud exportu, odstránené
  tlačidlo „Test nahrávania", hmba.boats voľba dočasne skrytá.
- `sync_queue_screen.dart`: nová možnosť „Použiť mobilné dáta" pre Wi-Fi-only
  politiku príloh (bez toho fronta na mori čaká donekonečna), a tlačidlo
  „Vymazať frontu" pre zaseknuté staré položky.

---

## Verifikácia

- `flutter analyze lib test` — 0 errors (dnešný baseline, 486 zvyšných
  info-level lint issues, nič nové).
- `flutter test` — celá sada zelená (267).
- **Overené na Honore 20. 7.:** mapa v automaticky nahranom PDF ukazuje
  reálne dlaždice (satelit + seamark), nie biely obdĺžnik — po oprave
  popísanej v §3.
- **Ešte treba overiť na Honore** (telefón bol koncom dňa 20. 7. odpojený
  od USB): nový tok Stop → Denník (úprava záznamu) → `export_screen.dart`
  (podpis, náhľad, potvrdenie) → cloud enqueue s `_maybeQueueToCloud`.
  Predtým overené len staré, už nahradené priame volanie z `handleStopTap`.
- Na Honore: prihlásiť účet, ukončiť deň v režime lietadlo, overiť čakajúce
  položky vo Fronte synchronizácie, obnoviť sieť a overiť súbory na Disku
  v priečinku `HMB_Sailing_Log_DATA/{plavba}/Day_{dátum}`.
- Overiť, že vypnutie synchronizácie s backendom **nezastaví** nahrávanie na
  Disk — to je tá pasca s `isReachable`.
- **Zatiaľ nespravené kvôli odpojenému telefónu:** vyčistenie 23 starých
  zaseknutých položiek vo fronte na Honore — pribudlo namiesto toho trvalé
  tlačidlo „Vymazať frontu" v `sync_queue_screen.dart`, použiť pri ďalšom
  pripojení telefónu.
