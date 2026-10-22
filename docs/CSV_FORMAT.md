# Formát „HMB voyage CSV“ (verzia 1)

Jeden súbor so všetkými údajmi jednej plavby: loď, skiper a posádka, dni,
záznamy denníka, trasa, služby, odovzdávací protokol, hodnotenie a zamerania.
Dá sa otvoriť v Exceli, poslať e-mailom a načítať späť do appky.

Zdroj pravdy je katalóg v
`lib/features/voyage_csv/format/voyage_csv_schema.dart`. Tento dokument s ním
musí sedieť — hlída to test `test/voyage_csv/voyage_csv_format_test.dart`:
zlyhá, keď je stĺpec v kóde a nie je tu (alebo je tu pod iným typom záznamu).

**Nie je v súbore:** fotky a obrázky podpisov (nie sú to text). Podpisy
v súbore nesú len meno, rolu a čas podpisu. Údaje mimo plavby (uložené body,
cache počasia a prílivu, fronta synchronizácie) tiež nie.

## Súbor

- UTF-8 s bajtovou značkou (BOM), aby ho tabuľkový procesor čítal ako UTF-8.
- Oddeľovač je čiarka, koniec riadka CRLF (čítač berie aj LF).
- Pole s čiarkou, úvodzovkou alebo zalomením riadka je v `"…"`, úvodzovka
  vo vnútri sa zdvojí (`""`). Je to RFC 4180.
- Prvý riadok je hlavička, spoločná pre všetky typy záznamov. Názvy stĺpcov sú
  malými písmenami. Poradie stĺpcov sa nesmie spoliehať; čítač ich hľadá podľa
  názvu.
- Každý ďalší riadok je jeden záznam. Prázdna bunka znamená „nezaznamenané“.
- Prvý záznam je vždy `meta`.

## Typy hodnôt

| druh | zápis |
|---|---|
| text | tak, ako je. Text začínajúci `=`, `+`, `-` alebo `@` má pred sebou apostrof, aby ho tabuľka nespustila ako vzorec; čítač ho zase odstráni. Text, ktorý už začína apostrofmi pred takým znakom, dostane ešte jeden. |
| celé číslo | `12` |
| desatinné číslo | bodka, najkratší zápis, ktorý sa číta späť presne (`43.5123`, `5.0`) |
| logická hodnota | `true` alebo `false` |
| okamih | ISO 8601 v UTC s `Z`: `2026-10-06T02:05:30Z` (zlomky sekundy len ak nejaké sú). Čas bez pásma sa číta ako UTC. |
| deň | `RRRR-MM-DD`, bez časového pásma |

Polohy sú desatinné stupne WGS84, juh a západ so znamienkom mínus. Rýchlosti
sú v uzloch, vzdialenosti v námorných míľach, hĺbky a vlny v metroch, tlak
v hPa, teploty v °C.

## Spoločné stĺpce

| stĺpec | význam |
|---|---|
| `record_type` | typ záznamu (pozri nižšie) |
| `id` | číslo záznamu, jedinečné v rámci svojho typu v tomto súbore. Nie je to id z databázy: import pridelí nové. |
| `parent_id` | `id` rodiča. Typ rodiča vyplýva z typu záznamu (pozri „Väzby“). Prázdne, ak záznam patrí plavbe samotnej. |

## Typy záznamov

Stĺpce, ktoré typ nepoužíva, sú v jeho riadkoch prázdne.

### `meta`

Prvý záznam súboru. Podľa neho čítač vie, čo číta.

| stĺpec | význam |
|---|---|
| `format` | vždy `hmb-voyage` |
| `version` | verzia formátu, celé číslo |
| `exported_at_utc` | kedy sa súbor vytvoril |
| `app_version` | verzia appky, ktorá ho vytvorila |
| `schema_version` | verzia databázy tej appky |
| `includes_track` | či súbor obsahuje body trasy (`track`) |

### `charter`

Hlavička plavby a lode. Jeden záznam.

| stĺpec | význam |
|---|---|
| `uuid` | stála identita plavby; podľa nej import pozná súbor, ktorý už raz načítal |
| `title` | názov plavby |
| `date_from_utc`, `date_to_utc` | začiatok a koniec plavby |
| `vessel_name`, `vessel_type`, `vessel_model`, `vessel_flag` | loď: názov, typ, model, vlajka |
| `home_port`, `charter_company`, `country`, `cruising_area`, `route` | domovský prístav, charterová firma, krajina, oblasť, trasa |
| `callsign`, `mmsi` | volací znak, MMSI |
| `length_m`, `beam_m`, `draft_m` | rozmery lode |
| `berths`, `year_built`, `engine` | lôžka, rok výroby, motor |
| `water_tank_l`, `fuel_tank_l` | nádrže |
| `engine_hours_start`, `engine_hours_end` | motohodiny na začiatku a na konci |
| `cost_currency` | mena nákladov |
| `my_role` | rola majiteľa telefónu v plavbe |
| `tidal_waters` | plavba v prílivových vodách |
| `captain_first_name`, `captain_last_name`, `captain_qualification` | kapitán z Knihy míľ a jeho najvyššia kvalifikácia |
| `safety_briefing_done`, `check_in_done`, `check_out_done`, `archived` | stav plavby |
| `source` | odkiaľ plavba vznikla (`live`, `gpx`, `paper`, `csv`) |
| `created_utc` | kedy plavba vznikla |
| `note` | poznámky k plavbe |

### `crew`

Skiper a posádka, jeden záznam na osobu.

| stĺpec | význam |
|---|---|
| `name` | meno |
| `role` | `skipper` alebo `crew` |
| `qualification` | najvyššia dosiahnutá kvalifikácia |
| `boat_licence` | číslo lodného preukazu |
| `radio_licence` | číslo rádiového preukazu |
| `other_certs` | ďalšie osvedčenia |

### `contact`

Kontakty chartru, jedno telefónne číslo na záznam.

| stĺpec | význam |
|---|---|
| `value` | telefónne číslo |

### `cost`

Náklady plavby.

| stĺpec | význam |
|---|---|
| `name` | označenie položky |
| `amount` | suma v mene plavby (pozri záznam `charter`) |

### `briefing`

Body bezpečnostného brífingu, ktoré skiper naozaj prebral.

| stĺpec | význam |
|---|---|
| `value` | text bodu tak, ako ho skiper videl |

### `day`

Jeden deň plavby.

| stĺpec | význam |
|---|---|
| `date` | deň |
| `port_from`, `port_to` | prístav odchodu a príchodu |
| `vessel_for_day` | loď pre tento deň |
| `distance_nm` | míle dňa |
| `beaufort_morning`, `beaufort_noon`, `beaufort_evening` | vietor v Beauforte |
| `sea_state`, `wave_height_m` | more |
| `wind_direction` | smer vetra, text (napr. `NE`) |
| `air_temp_c`, `water_temp_c` | teploty |
| `engine_hours` | motohodiny dňa |
| `night_hours_manual` | nočné hodiny zadané ručne z papierového denníka |
| `complete` | deň je uzavretý |
| `note` | správa dňa |

### `session`

Relácia trasovania. `parent_id` je `id` dňa.

| stĺpec | význam |
|---|---|
| `from_utc`, `to_utc` | začiatok a koniec |
| `name` | názov |
| `distance_nm` | vzdialenosť relácie |
| `max_speed_kn`, `avg_speed_kn` | najvyššia a priemerná rýchlosť |
| `anchor_watch` | úsek nahratý kotvovou strážou, nie plavbou |
| `estimated` | trasa nakreslená cez záznamy, nie zmeraná |

### `entry`

Záznam denníka. `parent_id` je `id` dňa, `session_ref` je `id` relácie
(`session`), ak záznam vznikol počas nej.

| stĺpec | význam |
|---|---|
| `time_utc` | čas záznamu |
| `lat`, `lon` | poloha |
| `sog_kn`, `cog_deg`, `heading_deg` | rýchlosť nad dnom, kurz nad dnom, kurz lode |
| `wind_kn`, `wind_dir_deg` | vietor: rýchlosť a smer, z ktorého fúka (meteorologická konvencia) |
| `wave_m`, `pressure_hpa` | vlny, tlak |
| `air_temp_c`, `water_temp_c` | teploty |
| `engine_hours`, `fuel_consumed_l` | motohodiny, spotreba paliva |
| `fuel_level_pct`, `water_level_pct` | stav nádrží |
| `helmsman`, `crew_names` | kormidelník, posádka |
| `note` | poznámka |
| `auto_entry` | záznam vznikol automaticky |
| `event_type` | druh automatického záznamu (napr. `anchor_dropped`) |
| `sail_mode` | spôsob plavby (`motor`, `main`, `genoa`…, oddelené čiarkou) |
| `point_of_sail`, `tack` | kurz voči vetru a bok |
| `depth_m` | hĺbka pod lodou |
| `weather_condition` | stav oblohy |
| `accuracy_m`, `location_source` | kvalita a zdroj polohy |
| `mocked` | poloha je simulovaná |
| `weather_source`, `weather_station`, `weather_station_distance_m` | odkiaľ je počasie: `nmea`, `dhmz`, `model`; stanica a jej vzdialenosť |
| `session_ref` | pozri vyššie |

### `track`

Bod trasy. `parent_id` je `id` relácie (`session`).

| stĺpec | význam |
|---|---|
| `time_utc` | čas |
| `lat`, `lon` | poloha |
| `altitude_m` | výška |
| `speed_kn`, `course_deg` | rýchlosť a kurz |
| `accuracy_m`, `location_source` | kvalita a zdroj |
| `mocked` | poloha je simulovaná |

### `duty`

Služba člena posádky. `parent_id` je `id` dňa, alebo prázdne.

| stĺpec | význam |
|---|---|
| `name`, `role` | kto a v akej role |
| `from_utc`, `to_utc` | od a do; prázdne `to_utc` znamená, že služba beží |
| `note` | poznámka |
| `auto_closed` | službu uzavrela appka |

### `handover`

Odovzdávací protokol lode. Najviac jeden `checkIn` a jeden `checkOut`.

| stĺpec | význam |
|---|---|
| `handover_type` | `checkIn` alebo `checkOut` |
| `time_utc` | čas protokolu |
| `location` | miesto (marína) |
| `fuel_level_pct`, `water_level_pct`, `engine_hours` | stav pri odovzdaní |
| `skipper_name`, `skipper_signed_utc` | skiper a kedy podpísal |
| `company_rep`, `company_name`, `company_signed_utc` | zástupca firmy, firma a kedy podpísal |
| `note` | poznámky mimo štandardného zoznamu |

### `checklist`

Položka zoznamu odovzdávacieho protokolu. `parent_id` je `id` protokolu.

| stĺpec | význam |
|---|---|
| `item_key` | kľúč položky |
| `status` | `ok`, `damaged` alebo `missing` |
| `note` | poznámka k položke |
| `position` | miesto na lodi |
| `custom_label` | vlastný názov položky |
| `category_key` | kategória |

### `assessment`

Hodnotenie člena posádky skiperom.

| stĺpec | význam |
|---|---|
| `name` | hodnotený |
| `helming`, `navigation`, `harbour_manoeuvres`, `teamwork`, `night_sailing` | známky |
| `note` | poznámka |

### `signature`

Podpis člena posádky: len údaj o ňom, obrázok v súbore nie je.

| stĺpec | význam |
|---|---|
| `name`, `role` | kto |
| `signed_utc` | kedy podpísal |

### `bearing`

Zameranie. `parent_id` je `id` dňa, alebo prázdne.

| stĺpec | význam |
|---|---|
| `bearing_kind` | druh zamerania |
| `lat`, `lon`, `accuracy_m` | poloha pozorovateľa a jej presnosť |
| `target_lat`, `target_lon`, `target_name` | zameraný bod |
| `magnetic_bearing_deg`, `declination_deg`, `declination_source`, `true_bearing_deg`, `uncertainty_deg` | meranie a prevod na pravý kurz |
| `sight_group` | skupina zameraní jednej resekcie |
| `label` | označenie |
| `time_utc` | kedy sa zameralo |
| `hidden_from_map` | skryté na mape |

## Väzby

| typ | `parent_id` ukazuje na |
|---|---|
| `session` | `day` |
| `entry` | `day` |
| `track` | `session` |
| `duty` | `day` (nepovinné) |
| `checklist` | `handover` |
| `bearing` | `day` (nepovinné) |
| ostatné | — (patria plavbe) |

## Verzovanie a čítanie

- Zmeny, ktoré nič nerozbijú (nový stĺpec, nový typ záznamu), verziu
  nemenia. Čítač ignoruje, čo nepozná, a upozorní na to.
- Zmena významu existujúceho stĺpca zvýši `version`. Čítač odmietne súbor
  s vyššou verziou, než pozná, a povie to.
- Nečitateľná bunka stojí jednu hodnotu, nie celý import.
