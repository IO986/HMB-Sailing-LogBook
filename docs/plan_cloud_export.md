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
(`lib/sync/sync_policy_transport.dart:32`) vracia `_isSyncEnabled() && ...`,
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

  /// Nahrá súbor do [folderPath] (napr. ['HMB Sailing Log', 'Plavba 2026']).
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

Priečinky sa pri `drive.file` dajú vytvárať a appka ich potom vidí (sú jej
vlastné). Štruktúra zrkadlí lokálnu z `export_service.dart:335-356`:
`HMB Sailing Log / {nazov_plavby} / Day_{yyyy-MM-dd}`.

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

Nový `lib/features/cloud/services/auto_export_service.dart`:
`Future<void> exportAndEnqueueDay(int dayLogId)` — načíta charter, deň,
záznamy, služby a sessions, vyrobí PDF aj GPX, uloží ich do **trvalého**
adresára (`_buildExportDir`, nie do temp — súbor musí prežiť do ďalšieho
spustenia appky) a zaradí do outboxu.

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

Postup pri ukončení dňa: potvrdenie → **odfotenie mapy mimo stromu**
(s hláškou o priebehu, `delay` aspoň 2 s na dokreslenie dlaždíc) → zastavenie
trackingu → zloženie PDF s obrázkom → zaradenie do fronty.

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

---

## 5. Spúšťače

- **Koniec dňa** — v `handleStopTap`
  (`tracking_control_dialogs.dart:133-153`), nie v bezkontextovom
  `TrackingNotifier.stopTracking()`. Dôvod je mapa: odfotenie widgetu mimo
  stromu potrebuje `BuildContext` (viď §3).
  **Pozor:** `GpsTrackingService.stopTracking()` nuluje `_activeDayLogId`
  (`gps_tracking_service.dart:306`), takže id treba zachytiť **pred** volaním.
  **Druhá pasca:** cesta „Zastaviť a ukončiť" (`main_scaffold.dart:280-283`)
  volá `SystemNavigator.pop()` hneď po zastavení. Priamy upload by appka
  zabila; fronta to rieši sama, odošle sa pri ďalšom spustení. Nikdy nečakať
  na dokončenie uploadu v tejto ceste.
- **Check-out chartera** — `handover_protocol_screen.dart`, po uložení
  check-out protokolu zaradiť charterové PDF.
- **Ručne** — tlačidlo v `export_screen.dart` vedľa zdieľania. Neaktívne, kým
  nie sú hotové snímky mapy; dovtedy ukazuje existujúcu hlášku
  `generatingMaps`. Vďaka tomu ide na Disk PDF s mapou, na rozdiel od
  automatu (viď §3).

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
- UI **vnútri `_AccountSection`** (`settings_screen.dart:626`), pod dnešnými
  prepínačmi synchronizácie: `SwitchListTile` pre cloud, `RadioListTile`
  pre poskytovateľa (rovnako ako dnešné `RadioListTile<SyncTarget>` na `:705`),
  tlačidlo prihlásiť/odhlásiť s menom účtu, prepínače PDF a GPX.

`attachmentPolicy` sa nezdvojuje — platí spoločne pre backend aj cloud.

---

## 7. KROK 0 — Google Cloud Console (prerekvizita, nie „potom")

Bez toho sa prihlásenie na zariadení nedá ani otestovať, takže to musí byť
skôr než bod 1.

**Údaje, ktoré do konzoly treba (už zistené):**

| položka | hodnota |
|---|---|
| Package name | `com.hmbsailinglogbook.app` |
| SHA-1 debug | `C2:00:42:E8:39:BD:8E:DA:10:A6:F8:7A:75:F7:A8:C4:CD:80:9A:05` |
| SHA-1 upload | `01:0C:5E:8C:F7:18:BC:C5:E4:20:C1:8B:FC:5E:36:B8:BF:8F:41:2F` |

Pozor: `namespace` v Gradle je `com.sailinglogbook.app`, ale pre OAuth
rozhoduje **`applicationId`**, teda `com.hmbsailinglogbook.app`
(`android/app/build.gradle:43`).

**Kroky:**
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

**Neskôr, pred publikovaním:** Play Console → Data safety doplniť, že appka
pristupuje k súborom používateľa a nahráva ich na jeho Disk.

---

## 8. Balíky

`google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth`.
Prvé dva sú veľké; sledovať dopad na veľkosť APK (dnes debug 209 MB, release
podstatne menej).

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

1. `CloudStorageProvider` + `GoogleDriveStorage` + prihlásenie v sync karte.
   Overiť, že sa dá prihlásiť a nahrať testovací súbor.
2. `CloudUploadTransport` + `RoutingTransport` + zapojenie do
   `sync_provider.dart`, s testami.
3. Vytiahnuť mapu dňa do `day_map_view.dart` a overiť `captureFromWidget`
   **na Honore** — či snímka mimo stromu naozaj obsahuje dlaždice.
   Toto je najrizikovejší kus; kým nezbehne, body 4 a 5 nemajú zmysel.
4. `AutoExportService` (PDF s mapou + GPX do trvalého adresára).
5. Spúšťač na konci dňa v `handleStopTap`.
5. Ručné tlačidlo v exporte.
6. Check-out chartera.
7. Príručka v 5 jazykoch + `docs/SYNC_API.md` (nový typ `cloud_export`).

---

## Verifikácia

- `flutter analyze lib test` — 0 errors (dnešný baseline).
- `flutter test` — celá sada zelená (dnes 245).
- Na Honore: prihlásiť účet, ukončiť deň v režime lietadlo, overiť čakajúce
  položky vo Fronte synchronizácie, obnoviť sieť a overiť súbory na Disku
  v priečinku `HMB Sailing Log/{plavba}/Day_{dátum}`.
- Overiť, že vypnutie synchronizácie s backendom **nezastaví** nahrávanie na
  Disk — to je tá pasca s `isReachable`.
