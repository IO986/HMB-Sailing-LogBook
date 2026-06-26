# ⛵ HMB Sailing Log

Profesionálna Flutter aplikácia pre jachting – offline mapy, GPS tracking, lodný denník, počasie a bezpečnostné funkcie.

## Funkcie

| | Funkcia | Popis |
|---|---------|-------|
| 🗺️ | **Mapa** | OpenStreetMap + OpenSeaMap nautická vrstva, waypointy |
| ⚡ | **Nástroje** | Live displeje SOG / TWS / TWA / DEPTH / VMG, kompas |
| 📖 | **Lodný denník** | Automatické záznamy s GPS, počasím a fotografiami |
| 🌦️ | **Počasie** | Open-Meteo Marine API – vietor, vlny, Beaufort, grafy |
| ⚓ | **Kotviaci alarm** | Monitorovanie driftu s nastaviteľným polomerom |
| 🆘 | **MOB** | Man Overboard s okamžitým zápisom GPS polohy |
| 📋 | **Bezpečnosť** | MAYDAY karta, brífing, COLREG, emergency kontakty |
| 📤 | **Export** | PDF lodný denník s mapou a podpisom skipera, GPX |
| 🌐 | **Multijazyčnosť** | SK / EN / DE / ES / UK |
| 📡 | **Raymarine** | Prepojenie s lodnou elektronikou cez WiFi (NMEA) |
| 📚 | **Príručka** | Interaktívna príručka pre nových jachtárov priamo v appke |

## Štruktúra navigácie

```
🗺 Mapa  →  ⚡ Nástroje  →  📖 Logbook  →  ☁️ Počasie  →  ⚓ Bezpečnosť  →  ⚙️ Nastavenia
```

Plavba sa spúšťa z **Logbook → +** (FAB tlačidlo).

## Technológie

| Vrstva | Technológia |
|--------|-------------|
| Framework | Flutter 3.x |
| State | Riverpod 2 |
| Navigácia | GoRouter |
| Mapa | flutter_map + OpenSeaMap |
| Databáza | Drift (SQLite) |
| Počasie | Open-Meteo Marine API |
| GPS | geolocator + background service |
| PDF | pdf package + custom renderer |
| Lokalizácia | Flutter l10n (manuálne) |

## Inštalácia a spustenie

### Požiadavky
- Flutter SDK ≥ 3.2.0
- Android Studio / VS Code
- Android SDK (pre Windows vývoj)

### Kroky

```bash
git clone https://github.com/IO986/HMB-Sailing-LogBook.git
cd HMB-Sailing-LogBook
flutter pub get
flutter run
```

## Štruktúra projektu

```
lib/
├── main.dart
├── app_router.dart
├── core/
│   ├── database/          # Drift databáza
│   ├── models/            # Dátové modely
│   ├── providers/         # Riverpod providers
│   └── services/          # GPS, počasie, Raymarine, export
├── features/
│   ├── map/               # Mapa + waypointy
│   ├── instruments/       # Live navigačné prístroje
│   ├── charter/           # Správa plavieb (charter list, day log)
│   ├── logbook/           # Záznamy lodného denníka
│   ├── tracking/          # GPS tracking
│   ├── weather/           # Predpoveď počasia
│   ├── safety/            # MOB, kotviaci alarm, MAYDAY, COLREG
│   ├── export/            # PDF a GPX export
│   ├── help/              # Užívateľská príručka
│   └── settings/          # Nastavenia
├── shared/
│   └── widgets/           # MainScaffold, zdieľané widgety
└── l10n/                  # Lokalizácia (SK/EN/DE/ES/UK)
```

## Bezpečnostné funkcie

- **MOB** – aktivácia podržaním červeného tlačidla, sledovanie vzdialenosti a smeru
- **Kotviaci alarm** – nastaviteľný rádius, akustický alarm pri driftovaní
- **MAYDAY karta** – DSC postup + hlasový skript, autofill z nastavení plavidla
- **Bezpečnostný brífing** – 12-bodový kontrolný zoznam pre posádku
- **Emergency kontakty** – podľa GPS polohy (krajina/oblasť)
- **COLREG** – pravidlá plavby v aplikácii

## Lokalizácia

| Jazyk | Kód | Stav |
|-------|-----|------|
| Slovenčina | `sk` | ✅ kompletná |
| English | `en` | ✅ kompletná |
| Deutsch | `de` | ✅ kompletná |
| Español | `es` | ✅ kompletná |
| Українська | `uk` | ✅ kompletná |

## Roadmapa

- [x] GPS tracking s automatickými zápismi
- [x] Multijazyčnosť (SK/EN/DE/ES/UK)
- [x] PDF export s mapou a podpisom skipera
- [x] Raymarine WiFi prepojenie
- [x] MAYDAY karta s DSC postupom
- [x] Kotviaci alarm a MOB
- [x] Interaktívna príručka pre nových jachtárov
- [ ] Cloud sync (logbook.hmba.boats)
- [ ] Offline GRIB počasie
- [ ] AIS / NMEA integrácia

## Licencia

MIT
