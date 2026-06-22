# ⛵ Sailing Logbook

Profesionálna Flutter aplikácia pre jachting – offline mapy, GPS tracking, lodný denník, počasie a bezpečnostné funkcie.

## Funkcie

- 🗺️ **Offline mapy** – OpenStreetMap + OpenSeaMap nautická vrstva (bez Google Maps)
- 📍 **GPS Tracking** – kontinuálny záznam trasy aj na pozadí
- 📖 **Lodný denník** – automatické záznamy s GPS, počasím a poznámkami
- 🌦️ **Počasie** – Open-Meteo Marine API (vietor, vlny, Beaufort, grafy)
- ⚓ **Anchor Alarm** – monitorovanie driftovania s nastaviteľným polomerom
- 🆘 **MOB** – Man Overboard s okamžitým zápisom GPS polohy
- 📤 **Exporty** – GPX export trás

## Technológie

| Vrstva | Technológia |
|--------|-------------|
| Framework | Flutter 3.x |
| State | Riverpod 2 |
| Navigácia | GoRouter |
| Mapa | flutter_map + OpenSeaMap |
| Databáza | Isar (real-time) + SQLite (reporting) |
| Počasie | Open-Meteo Marine API |
| GPS | geolocator + background_service |

## Inštalácia a spustenie

### Požiadavky
- Flutter SDK ≥ 3.2.0
- Android Studio / VS Code
- Android SDK (pre Windows vývoj)

### Kroky

```bash
# 1. Klonovať repozitár
git clone https://github.com/TVOJ_USERNAME/sailing_logbook.git
cd sailing_logbook

# 2. Stiahnuť závislosti
flutter pub get

# 3. Generovať kód (Isar + Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 4. Spustiť na Android zariadení / emulátore
flutter run
```

### Generovanie kódu

Projekt používa code generation pre Isar modely a Riverpod providers.
Po každej zmene modelov alebo providerov spusti:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Pre sledovanie zmien počas vývoja:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Štruktúra projektu

```
lib/
├── main.dart                    # Vstupný bod
├── app_router.dart              # GoRouter konfigurácia
├── core/
│   ├── database/
│   │   ├── isar_service.dart    # Databázová vrstva
│   │   └── models/              # Isar modely
│   ├── services/
│   │   ├── gps_tracking_service.dart
│   │   ├── weather_service.dart
│   │   └── background_service.dart
│   └── utils/
│       ├── gpx_exporter.dart
│       └── distance_calculator.dart
├── features/
│   ├── map/                     # Mapa + waypoints
│   ├── tracking/                # GPS tracking
│   ├── logbook/                 # Lodný denník
│   ├── weather/                 # Počasie
│   ├── safety/                  # MOB + Anchor alarm
│   └── settings/                # Nastavenia
└── shared/
    ├── theme/                   # AppTheme
    └── widgets/                 # Zdieľané widgety
```

## Mapové zdroje

- **Základná mapa**: OpenStreetMap (zadarmo)
- **Nautická vrstva**: OpenSeaMap seamarky (zadarmo)
- **Offline**: flutter_map_tile_caching (FMTC)

## Počasie

- **Primárny zdroj**: Open-Meteo Marine API (zadarmo, bez API kľúča)
- **Cache**: 6 hodín lokálne
- **Plánované**: NOAA GFS GRIB pre 72h offline predpoveď

## Nahranie na GitHub

```bash
git init
git add .
git commit -m "Initial commit – Sailing Logbook v1.0"
git branch -M main
git remote add origin https://github.com/TVOJ_USERNAME/sailing_logbook.git
git push -u origin main
```

## Roadmapa

- [ ] Offline GRIB počasie (NOAA GFS)
- [ ] MBTiles offline mapa stiahnutie
- [ ] AIS / NMEA integrácia
- [ ] PDF export lodného denníka
- [ ] Racing mode (polar diagram, VMG)
- [ ] Charter management modul
- [ ] Cloud sync (Supabase)

## Licencia

MIT
