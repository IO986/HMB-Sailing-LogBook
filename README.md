# ⛵ HMB Sailing Log

Profesionálna Flutter aplikácia pre jachting – offline mapy, GPS tracking, lodný denník, námerový kompas, bezpečnostné funkcie a PDF export s podpismi.

**Aktuálna verzia: v1.20.2** | [Releases](https://github.com/IO986/HMB-Sailing-LogBook/releases)

## Funkcie

| | Funkcia | Popis |
|---|---------|-------|
| 🗺️ | **Mapa** | OpenStreetMap + OpenSeaMap nautická vrstva, waypointy |
| ⚡ | **Nástroje** | Live displeje SOG / TWS / TWA / DEPTH / VMG |
| 📖 | **Lodný denník** | Automatické záznamy s GPS, počasím a fotografiami |
| 🌦️ | **Počasie** | Open-Meteo Marine API – vietor, vlny, Beaufort, grafy |
| ⚓ | **Kotviaci alarm** | Monitorovanie driftu s nastaviteľným polomerom |
| 🆘 | **MOB** | Man Overboard s okamžitým zápisom GPS polohy |
| 📋 | **Bezpečnosť** | MAYDAY karta, brífing s podpismi posádky, COLREG, Morse |
| 🧭 | **Námerový kompas** | Kamera + magnetometer – tilt-kompenzovaný kurz s AR vizualizáciou |
| 🌙 | **Nočný režim** | Červený filter pre zachovanie nočného videnia |
| 📤 | **Export** | PDF s DocID, číslom revízie a QR overením; GPX trasa |
| 🌐 | **Multijazyčnosť** | SK / EN / DE / ES / UK |
| 📡 | **Raymarine** | Prepojenie s lodnou elektronikou cez WiFi (NMEA 0183) |
| 📚 | **Príručka** | Interaktívna príručka priamo v appke |

## Navigácia

```
🗺 Mapa → ⚡ Nástroje → 📖 Logbook → ☁️ Počasie → ⚓ Bezpečnosť → 🧭 Kompas → ⚙️ Nastavenia
```

## Changelog

### v1.20.2 (aktuálna)
- **Námerový kompas** – kamera + tilt-kompenzovaný magnetický kurz, pohyblivá lišta, AR vizualizácia
- **Low-pass filter** – smoothing surového magnetometra, indikátor stability (Stable / Calibrating…)
- Oprava inverzie kompasu (S ukazoval ako N)
- **Nočný režim** – červený ColorFiltered overlay, toggle v Nastavenia → Zobrazenie
- Oprava načítavania mapových dlaždíc pri prvom otvorení
- Spresnený hint pre Raymarine IP adresu (gateway WiFi ≠ interná IP chartplotteru)

### v1.19.0
- Prvý release pre interné testovanie na Google Play

### v1.18.0
- PDF export: DocID (`HMBSL-{id}-{rok}`), číslo revízie, QR kód s SHA-256 odtlačkom
- Bezpečnostný brífing s digitálnymi podpismi posádky na obrazovke
- Online účet skrytý (coming v2.0) – backend nie je live
- `print` → `debugPrint` v celom projekte (release builds)

### v1.17.0
- Interaktívna príručka (SK/EN/DE/ES/UK)
- Branding update

## Technológie

| Vrstva | Technológia |
|--------|-------------|
| Framework | Flutter 3.44.x |
| State | Riverpod 2 |
| Navigácia | GoRouter |
| Mapa | flutter_map + OpenSeaMap |
| Databáza | Drift (SQLite) |
| Počasie | Open-Meteo Marine API |
| GPS | geolocator + flutter_background_service |
| Kompas | sensors_plus (magnetometer + akcelerometer) |
| Kamera | camera package |
| PDF | pdf + printing + barcode (QR) |
| Bezpečné úložisko | flutter_secure_storage (Keychain / EncryptedSharedPrefs) |
| Lokalizácia | Flutter gen-l10n (.arb súbory) |

## Inštalácia a spustenie

```bash
git clone https://github.com/IO986/HMB-Sailing-LogBook.git
cd HMB-Sailing-LogBook
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

### Build release

**Android AAB:**
```bash
flutter build appbundle --release
```
> ⚠️ Pred buildom vždy zvýš `+buildNumber` v `pubspec.yaml` (Play Console odmietne už použité číslo, viď db5ff32).

**iOS (unsigned – Sideloadly):**
Spustite GitHub Actions workflow `iOS Build (unsigned – Sideloadly)` → stiahni IPA artefakt.

## Štruktúra projektu

```
lib/
├── core/
│   ├── config/            # API constants
│   ├── database/          # Drift (schéma v7)
│   ├── providers/         # Riverpod providers
│   └── services/          # GPS, počasie, Raymarine, NMEA, geocoding
├── features/
│   ├── map/               # Mapa + waypointy
│   ├── instruments/       # Live nástroje
│   ├── charter/           # Správa plavieb
│   ├── compass/           # Námerový kompas s kamerou
│   ├── safety/            # MOB, kotva, MAYDAY, COLREG
│   ├── export/            # PDF + GPX
│   ├── help/              # Príručka
│   └── settings/          # Nastavenia
└── l10n/                  # .arb súbory – SK/EN/DE/ES/UK
```

> **Pravidlo:** Stringy patria do `.arb` súborov. Nikdy neupravuj `app_localizations*.dart` priamo – sú generované cez `flutter gen-l10n`.

## Roadmapa

- [x] GPS tracking + automatické záznamy
- [x] Multijazyčnosť (SK/EN/DE/ES/UK)
- [x] PDF export s DocID, revíziou a QR overením
- [x] Raymarine WiFi (NMEA 0183)
- [x] MAYDAY karta + bezpečnostný brífing s podpismi
- [x] Kotviaci alarm a MOB
- [x] Námerový kompas s kamerou (AR)
- [x] Nočný režim
- [x] iOS build cez GitHub Actions
- [ ] Cloud sync / online účet (v2.0)
- [ ] Polárny diagram
- [ ] Offline GRIB počasie
- [ ] AIS / NMEA 2000

## Licencia

MIT
