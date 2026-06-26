# HMB Sailing Log – Príručka pre nových jachtárov

> Váš spoľahlivý lodný denník – jednoducho a prehľadne

---

## Čo táto aplikácia robí?

HMB Sailing Log je digitálny **lodný denník** pre váš telefón. Nahrádza papierový zápisník, do ktorého posádky tradične zaznamenávajú priebehy plavieb.

Aplikácia za vás:
- **automaticky zaznamenáva trasu** plavby pomocou GPS telefónu
- **ukladá záznamy** o polohe, počasí a rýchlosti
- **zobrazuje predpoveď počasia** pre miesto, kde sa nachádzate
- **upozorní vás**, ak sa loď pohne zo zakotvenia
- pomáha so **záchranárskymi postupmi** (MOB, Mayday)
- vytvorí **PDF lodný denník** s mapou trasy

---

## Obsah

1. [Prvý raz s aplikáciou](#1-prvý-raz-s-aplikáciou)
2. [Kde sa čo nachádza](#2-kde-sa-čo-nachádza)
3. [Mapa](#3-mapa)
4. [Nástroje (Instruments)](#4-nástroje-instruments)
5. [Lodný denník (Logbook) a spustenie plavby](#5-lodný-denník-logbook-a-spustenie-plavby)
6. [Počasie](#6-počasie)
7. [Bezpečnosť](#7-bezpečnosť)
8. [Nastavenia](#8-nastavenia)
9. [Vytvorenie PDF lodného denníka](#9-vytvorenie-pdf-lodného-denníka)
10. [Tipy pre dlhšie plavby](#10-tipy-pre-dlhšie-plavby)

---

## 1. Prvý raz s aplikáciou

Keď prvýkrát otvoríte aplikáciu, zobrazí sa otázka: *„Chcete pripojiť aplikáciu k lodným prístrojom?"*

**Čo to znamená?** Niektoré lode majú WiFi, cez ktorú môže telefón komunikovať s lodnou elektronikou (napr. Raymarine). Cez toto prepojenie aplikácia dostane presnejšie dáta o vetre, hĺbke a kurze priamo z lodných prístrojov.

**Ak nevieš:** Vyber **„Nateraz nie"** – aplikácia bude fungovať skvele aj bez toho. Bude používať GPS telefónu a internetovú predpoveď počasia. Toto nastavenie môžeš zmeniť neskôr.

---

## 2. Kde sa čo nachádza

V dolnej časti obrazovky je šesť záložiek:

| Záložka | Popis |
|---------|-------|
| 🗺 **Mapa** | Zobrazuje vašu polohu na mape |
| ⚡ **Nástroje** | Live displeje – rýchlosť, vietor, hĺbka, kompas |
| 📖 **Logbook** | Váš lodný denník + tu sa spúšťa plavba |
| ☁️ **Počasie** | Predpoveď počasia a výška vĺn |
| ⚓ **Bezpečnosť** | Núdzové tlačidlá, brífing, MAYDAY karta |
| ⚙️ **Nastavenia** | Jazyk, jednotky, Raymarine, účet |

---

## 3. Mapa

Otvorte záložku **Mapa**. Zobrazí sa vaša aktuálna poloha ako bodka.

Na mape vidíte:
- kde sa práve nachádzate
- trasu, ktorú ste prešli počas aktívnej plavby
- body záujmu, ktoré ste si uložili (tzv. waypointy)

**Waypoint** je miesto, ktoré si chcete zapamätať – prístav, kotevná zátoká, mýtnica. Waypoint pridáte klepnutím na príslušné tlačidlo v mape.

---

## 4. Nástroje (Instruments)

Záložka **Nástroje** je digitálny navigačný panel – tmavá obrazovka s farebnými číslami v štýle lodnej elektroniky.

### Čo tu vidíte

| Skratka | Čo znamená | Popis |
|---------|-----------|-------|
| **SOG** | Speed Over Ground | Vaša aktuálna rýchlosť v uzloch (1 uzol = 1,85 km/h) |
| **TWS** | True Wind Speed | Skutočná rýchlosť vetra v uzloch |
| **TWA** | True Wind Angle | Uhol vetra voči osi lode (zelená = z pravoboku, červená = z ľavoboku) |
| **DEPTH** | Hĺbka | Hĺbka vody pod loďou v metroch – sčervenie pri menej ako 5 m |
| **VMG WP** | Velocity Made Good | Rýchlosť približovania sa k vybranému waypointu |

### Kompas

Veľký kruh kompasu v dolnej časti obrazovky ukazuje:
- aktuálny **kurz** (heading) uprostred kruhu v stupňoch
- **ružicu** (N, E, S, W) ktorá sa otáča podľa pohybu lode
- **šípku vetra** (TWA) – zelená šípka pre pravobokový vietor, červená pre ľavobokový

### Navigácia k waypointu

Klepnite na panel **VMG WP** a vyberte cieľový waypoint. Aplikácia zobrazí:
- vzdialenosť k cieľu v námorných míľach (NM)
- smer k cieľu (BRG – bearing)
- rýchlosť približovania sa k nemu (VMG)

> Waypointy sa pridávajú na záložke Mapa. Ak ešte žiadne nemáte, aplikácia vás presmeruje na Mapu.

### Zdroj dát

Vpravo hore vidíte malý štítok:
- **GPS** = aplikácia používa GPS telefónu a internetovú predpoveď
- **RAYMARINE** = aplikácia je pripojená k lodným prístrojom a dáta sú presnejšie

---

## 5. Lodný denník (Logbook) a spustenie plavby

Záložka **Logbook** je srdcom aplikácie. Tu nájdete všetky plavby a odtiaľto sa spúšťa zaznamenávanie novej plavby.

### 5.1 Spustenie plavby

1. Klepnite na záložku **Logbook**.
2. Klepnite na tlačidlo **+** (vpravo dole).
3. Zobrazí sa okno „Nová plavba" s dvoma možnosťami:

| Typ | Popis |
|-----|-------|
| **Viacdňová** | Plavba trvajúca viac dní (charter). Záznamy sa triedia podľa dní. |
| **Samostatná** | Jednodňový výlet. |

4. Vyberte, či chcete pridať plavbu do **existujúceho voyageu** alebo vytvoriť **nový**.
5. Pri novom voyagi zadajte:
   - názov (napr. „Chorvátsko jún 2025") – voliteľné
   - odhadovaný počet dní
   - frekvenciu automatických zápisov
6. Klepnite na **Spustiť tracking**.

Aplikácia začne zaznamenávať trasu GPS a automaticky pridávať záznamy do denníka.

### 5.2 Čo sa deje počas plavby

- GPS nahrávanie beží na pozadí aj keď aplikáciu zatvoríte
- V oznamovacej lište telefónu je viditeľné upozornenie o aktívnom trackingu
- Záznamy sa automaticky pridávajú podľa nastavenej frekvencie

### 5.3 Zastavenie plavby

Otvorte **Logbook**, nájdite aktívnu plavbu a klepnite na **Stop**. Aplikácia sa opýta:
- **Pokračuje zajtra** – pridá ďalší deň k viacdňovej plavbe
- **Ukončiť plavbu** – plavba sa uzavrie
- **Rozhodnúť neskôr** – tracking zastaví, stav plavby zostane otvorený

### 5.4 Zoznam plavieb

Pre každú plavbu vidíte:
- Názov a dátumy
- Názov plavidla
- Počet dní
- Stav: ✓ Brífing, ✓ Check-in, ✓ Check-out

**Úprava / zmazanie plavby:**
- Klepnite na plavbu → otvorí sa detail
- Ikona ceruzky (vpravo hore) = úprava
- Podržte na zázname pre hromadné mazanie

### 5.5 Detail plavby – zoznam dní

Klepnite na plavbu. Uvidíte zoznam dní – každý deň je jeden riadok. Dni sa vytvárajú automaticky počas trackovania.

### 5.6 Denný záznam

Klepnite na konkrétny deň. Otvorí sa stránka s:

- **Trasou** – odkiaľ, kam, aká vzdialenosť
- **Počasím dňa** – ráno, poludnie, večer (smer a sila vetra, stav mora, výška vĺn, typ počasia)
- **Denníkovým zápisom** – voľný text: čo sa stalo, kde ste kotvili, zaujímavosti
- **Zápismi** – automaticky vytvorené záznamy z trackovania

### 5.7 Ručný zápis

Okrem automatických záznamov môžete pridať vlastný klepnutím na **Pridať ručne**. Vyplníte:
- polohu (GPS súradnice)
- silu a smer vetra, výšku vĺn, typ počasia
- režim plachtovania
- hodiny motora, palivo
- poznámku
- fotografiu (z kamery alebo galérie)

---

## 6. Počasie

Klepnite na záložku **Počasie**.

### Predpoveď na 3 dni

Aplikácia stiahne predpoveď pre miesto, kde sa nachádzate. Uvidíte:

- **Tabuľku** s hodinou, silou vetra, výškou vĺn a zrážkami
- **Graf vetra** – vizuálny prehľad na 3 dni
- **Graf vĺn** – výška vĺn na 3 dni
- **Denné teploty** vzduchu a vody

Predpoveď si môžete stiahnuť tlačidlom **Aktualizovať predpoveď**.

> Ak nemáte internet, zobrazí sa naposledy stiahnutá predpoveď.

### Sila vetra – čo znamenajú čísla?

Aplikácia používa **Beaufortovu stupnicu** (0–12):

| Stupeň | Popis | Orientačná rýchlosť |
|--------|-------|---------------------|
| 0 | Bezvetrie | 0 km/h |
| 3 | Slabý vietor | ~20 km/h |
| 5 | Čerstvý vietor | ~40 km/h |
| 6 | Silný vietor | ~50 km/h |
| 7 | Búrkový vietor | ~60 km/h |
| 8–9 | Búrka | 70–90 km/h |
| 12 | Orkán | nad 120 km/h |

### Live dáta z lodných prístrojov

Ak je aplikácia pripojená k Raymarine (viď Nastavenia), v záložke Počasie sa navyše zobrazí sekcia s live hodnotami z prístrojov lode – vietor, hĺbka, teplota vody, kurz.

---

## 7. Bezpečnosť

Toto je najdôležitejšia sekcia aplikácie. Klepnite na záložku ⚓ **Bezpečnosť**.

### 7.1 MOB – Muž cez palubu

**MOB** (Man Overboard) je postup, keď niekto z posádky spadne do vody.

Červené tlačidlo **MOB** podržte stlačené pre aktiváciu.

Po aktivácii aplikácia:
- zaznamená GPS polohu miesta pádu
- zobrazuje vzdialenosť k záchrannej polohe
- zobrazuje smer, ktorým sa treba otočiť
- spustí hodiny od začiatku záchrannej akcie

> Tlačidlo sa aktivuje podržaním (nie jednoduchým klepnutím) – aby sa predišlo náhodnej aktivácii.

### 7.2 Kotviaci alarm

Keď ukotvíte loď, aktivujte alarm, aby vás upozornil ak loď začne driftovať.

**Ako nastaviť:**
1. Ukotvite loď.
2. Otvorte **Bezpečnosť → Kotviaci alarm**.
3. Nastavte rádius – odporúčame aspoň 50 m (plus dĺžka reťaze).
4. Klepnite na **Aktivovať**.

Ak loď opustí nastavený okruh, aplikácia hlasno zapípa a zobrazí výstrahu.

### 7.3 Bezpečnostný brífing

Pred každou plavbou by mal skiper oboznámiť posádku s bezpečnostnými inštrukciami. Aplikácia obsahuje kontrolný zoznam 12 bodov – napr. kde sú záchranné vesty, ako použiť VHF rádio, kde je lekárnička.

Po prejdení každého bodu ho zaškrtnite. Keď dokončíte celý brífing, stav plavby sa automaticky označí ako **Brífing ✓**.

### 7.4 MAYDAY karta

Karta s presným postupom tiesňového volania, ak sa dostanete do vážneho nebezpečenstva.

Obsahuje:
- **Postup pre DSC** – krok za krokom s použitím červeného tlačidla na VHF rádiu
- **Hlasový skript** – čo presne povedať na VHF kanáli 16

Kartu si vyplňte vopred:
- počet osôb na palube
- povaha núdze

GPS súradnice, volací znak a MMSI sa doplnia automaticky.

> Volací znak a MMSI sa automaticky prenesú z **Nastavenia → Identifikácia plavidla**.

### 7.5 Tiesňové kontakty

Zoznam záchranných služieb a tiesňových čísel pre oblasť, kde sa nachádzate. Klepnutím na číslo voláte priamo.

### 7.6 COLREG – Pravidlá plavby

Základné pravidlá morskej premávky. Užitočné pri otázkach počas plavby alebo pred skúškami.

### 7.7 Zoznam výbavy

Vytvorte si vlastný kontrolný zoznam vecí, ktoré si beriete na palubu. Pred plavbou zaškrtajte každú položku.

### 7.8 Check-in a Check-out

Kontrolné zoznamy pri preberaní a odovzdávaní plavidla od charter spoločnosti.

**Check-in** (preberanie lode): dokumenty, bezpečnostná výbava, palivo, voda, motor, takeláž, fotodokumentácia poškodení.

**Check-out** (odovzdávanie lode): upratovanie, doplnenie paliva a vody, odovzdanie kľúčov.

Po dokončení sa stav uloží do plavby (✓ Check-in, ✓ Check-out).

### 7.9 Signály a námorná abeceda

- **Hláskovacia abeceda NATO** – Alpha, Bravo, Charlie... (používa sa pri komunikácii na VHF)
- **Signálne vlajky** – obrázky vlajok a ich významy
- **Denné tvary** – geometrické tvary, ktoré plavidlá vykladajú počas dňa

---

## 8. Nastavenia

Klepnite na záložku ⚙️ **Nastavenia**.

### Merné jednotky

| Veličina | Možnosti |
|----------|----------|
| Teplota | °C alebo °F |
| Hĺbka a vlny | metre alebo stopy |
| Vietor | uzly (kn) / m/s / Beaufort |

### Jazyk aplikácie

Aplikácia je dostupná v piatich jazykoch:
🇬🇧 Angličtina · 🇩🇪 Nemčina · 🇪🇸 Španielčina · 🇸🇰 Slovenčina · 🇺🇦 Ukrajiná

### Identifikácia plavidla

Zadajte **volací znak** (napr. `OE 1234`) a **MMSI** číslo lode. Tieto údaje sa automaticky vyplnia v MAYDAY karte.

### Morské prístroje (Raymarine)

Ak loď má WiFi bránu pre lodné prístroje, môžete aplikáciu pripojiť. Budete dostávať presné dáta o vetre, hĺbke a kurze priamo z prístroja lode.

Potrebujete:
- telefón pripojený na WiFi sieť lode
- IP adresu a port brány (skúste `10.0.0.1`, port `2000`)

Klepnite na **Pripojiť**. Po úspešnom pripojení sa v záložke Nástroje zobrazí štítok **RAYMARINE**.

### Online účet

Prihlásenie do online účtu pre synchronizáciu denníka s logbook.hmba.boats. Klepnite na **Registrovať** alebo **Prihlásiť sa**.

---

## 9. Vytvorenie PDF lodného denníka

Na konci plavby môžete vygenerovať **oficiálny PDF lodný denník** s mapou trasy.

### Ako na to

1. V záložke **Logbook** otvorte svoju plavbu.
2. Klepnite na tlačidlo **Export PDF**.
3. Vyberte, či chcete exportovať celú plavbu alebo len jeden deň.
4. Počkajte, kým aplikácia vygeneruje náhľady máp.
5. Zobrazí sa plocha na **podpis skipera** – podpíšte sa prstom.
6. Klepnite na **Podpísať a exportovať**.
7. Vyberte uloženie do telefónu alebo zdieľanie (e-mail, WhatsApp...).

### Čo PDF obsahuje

- titulná strana s názvom plavby a plavidla
- mapa s vyznačenou trasou každého dňa
- tabuľka zápisov (čas, poloha, vietor, more)
- denné záznamy a poznámky
- podpis skipera

---

## 10. Tipy pre dlhšie plavby

**Batéria:** GPS neustále zaťažuje batériu. Na dlhé plavby si vezmite powerbanku alebo nabíjajte telefón v lodnej elektrine.

**Offline:** Aplikácia funguje bez internetu – GPS, denník aj bezpečnostné funkcie. Internet potrebujete len na stiahnutie predpovede počasia.

**Záloha dát:** Dáta sú uložené v telefóne. Ak stratíte telefón, stratíte aj záznamy – pokiaľ nemáte zapnutú online synchronizáciu (Nastavenia → Online účet).

**Fotky:** K zápisom môžete prikladať fotky – kotviská, zaujímavé miesta, prípadné poškodenia lode pre check-out.

---

## Rýchly štart – čo robiť pred každou plavbou

```
☐  1. Skontroluj predpoveď počasia (záložka Počasie)
☐  2. Vyplň Bezpečnostný brífing s posádkou
☐  3. Prejdi Check-in zoznam (ak preberáš loď)
☐  4. Vyplň identifikáciu plavidla v Nastaveniach
☐  5. Klepni na Logbook → + → Spustiť tracking
☐  6. Dobrý vietor! ⛵
```

---

*HMB Sailing Log · logbook.hmba.boats*
