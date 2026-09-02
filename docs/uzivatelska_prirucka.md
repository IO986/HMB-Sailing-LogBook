# HMB Sailing Log – Príručka pre nových jachtárov

> Váš spoľahlivý lodný denník – jednoducho a prehľadne

---

## Čo táto aplikácia robí?

HMB Sailing Log je digitálny **lodný denník** pre váš telefón. Nahrádza papierový zápisník, do ktorého posádky tradične zaznamenávajú priebeh plavby.

Aplikácia za vás:
- **automaticky zaznamenáva trasu** plavby pomocou GPS telefónu
- **ukladá záznamy** o polohe, počasí a rýchlosti
- **zobrazuje predpoveď počasia**, prílivy/odlivy aj námerané dáta zo staníc
- **upozorní vás**, ak sa loď pohne zo zakotvenia
- pomáha so **záchranárskymi postupmi** (MOB, Mayday)
- vie zamerať **vlastnú polohu alebo neznámy bod** kompasom, aj bez GPS/signálu
- vytvorí **PDF lodný denník** s mapou trasy a certifikát naplávaných míľ

---

## Obsah

1. [Prvý raz s aplikáciou](#1-prvý-raz-s-aplikáciou)
2. [Kde sa čo nachádza](#2-kde-sa-čo-nachádza)
3. [Mapa](#3-mapa)
4. [Lodné prístroje](#4-lodné-prístroje)
5. [Lodný denník a spustenie plavby](#5-lodný-denník-a-spustenie-plavby)
6. [Počasie](#6-počasie)
7. [Bezpečnosť](#7-bezpečnosť)
8. [Kompas – námerový (resekcia a triangulácia)](#8-kompas--námerový-resekcia-a-triangulácia)
9. [Nastavenia](#9-nastavenia)
10. [Vytvorenie PDF lodného denníka a knihy míľ](#10-vytvorenie-pdf-lodného-denníka-a-knihy-míľ)
11. [Zálohovanie a cloud export](#11-zálohovanie-a-cloud-export)
12. [Tipy pre dlhšie plavby](#12-tipy-pre-dlhšie-plavby)

---

## 1. Prvý raz s aplikáciou

Keď prvýkrát otvoríte aplikáciu, zobrazí sa otázka: *„Chcete pripojiť aplikáciu k lodným prístrojom?"*

**Čo to znamená?** Niektoré lode majú WiFi bránu, cez ktorú môže telefón čítať dáta priamo z lodnej elektroniky (napr. Raymarine). Cez toto prepojenie aplikácia dostane presnejšie dáta o vetre, hĺbke a kurze než z internetu.

**Ak nevieš:** Vyber **„Nateraz nie"** – aplikácia bude fungovať skvele aj bez toho. Bude používať GPS telefónu a internetovú predpoveď počasia. Toto nastavenie môžeš zmeniť neskôr v Nastaveniach.

---

## 2. Kde sa čo nachádza

V dolnej časti obrazovky je sedem záložiek (poradie aj veľkosť ikon si vieš v Nastaveniach prispôsobiť, prípadne nepoužívané skryť):

| Záložka | Popis |
|---------|-------|
| 🗺 **Mapa** | Poloha, trasa, waypointy, kotviská a prístavy, hĺbky, prehrávanie plavby |
| 📖 **Denník** | Lodný denník, tu sa spúšťa a ukončuje plavba |
| ☁️ **Počasie** | Predpoveď, výstrahy, prílivy, morský prúd, namerané stanice |
| ⚡ **Lodné prístroje** | Live displeje – rýchlosť, vietor, hĺbka, kompas, navigácia k waypointu |
| ⚓ **Bezpečnosť** | MOB, kotviaci alarm, brífing, MAYDAY karta, služba posádky |
| 🧭 **Kompas** | Námerový kompas – zameranie vlastnej polohy alebo neznámeho bodu |
| ⚙️ **Nastavenia** | Jazyk, jednotky, prístroje, cloud export, záloha dát |

---

## 3. Mapa

Otvorte záložku **Mapa**. Zobrazí sa vaša aktuálna poloha ako bodka.

Na mape vidíte:
- kde sa práve nachádzate a trasu, ktorú ste prešli počas aktívnej plavby
- body záujmu, ktoré ste si uložili (waypointy) – pridáte ich podržaním prsta na mape
- **prehrávanie plavby** – vyberte ľubovoľnú plavbu alebo deň (ikona trasy) a dole sa objaví posuvník: prejdite plavbu v čase a sledujte polohu, rýchlosť, kurz, vietor aj tlak v ktoromkoľvek okamihu. Zvislé čiarky na posuvníku sú udalosti – začiatok/koniec plavby, kotva, drift, MOB

**Prepínateľné vrstvy** (ikona vrstiev vpravo):
- **Satelit / mapa** – prepnutie základnej vrstvy
- **Seamarky** – navigačné značky (vraky, plytčiny, bóje) z OpenSeaMap
- **Hĺbky** – hĺbnice z EMODnet Bathymetry s hĺbkou v metroch. Je to model dna z prieskumov, **nie námorná mapa**: na plánovanie prielivu áno, na rozhodnutie „prejdem tadiaľ" nie. Pri zapnutej vrstve ťuknutím do mapy prečítaš hĺbku v danom bode (treba signál)
- **Prístavy** – klikateľná vrstva kotvísk, marín, prístavov a tankovacích staníc pre lode (dáta z OpenStreetMap): ťukni na ikonku a uvidíš názov, VHF kanál, telefón, web, hĺbku či kapacitu, ak sú známe. **Telefón a web sú priamo klikateľné** – ťuknutím zavoláš alebo otvoríš stránku. Miesto si vieš rovno uložiť ako waypoint

**Ďalšie funkcie:**
- **Pravítko** (fialová ikona) – ťukaj body na mape: súčet NM, kurz poslednej nohy a ETA pri aktuálnej rýchlosti; body sa prichytávajú na waypointy
- **Offline mapa** (ikona sťahovania) – stiahne seamarky pre viditeľnú oblasť na použitie bez signálu; keď máš zapnutý satelit, aj snímky a ich popisky. Základná mapa sa sťahuje priebežne sama, ako ju prezeráš, tak zostane dostupná aj bez signálu len tam, kade si už prešiel
- **Zámok severu** – podrž ružicu kompasu vľavo hore; mapa sa prestane otáčať a ostane na sever
- V nočnom režime sa mapa automaticky prepne na tmavé dlaždice; zvolené vrstvy, sledovanie GPS aj zámok severu sa pamätajú medzi spusteniami

---

## 4. Lodné prístroje

Záložka **Lodné prístroje** je digitálny navigačný panel – tmavá obrazovka s farebnými číslami v štýle lodnej elektroniky.

### Čo tu vidíte

| Skratka | Čo znamená | Popis |
|---------|-----------|-------|
| **SOG** | Speed Over Ground | Vaša aktuálna rýchlosť v uzloch (1 uzol = 1,85 km/h) |
| **TWS** | True Wind Speed | Skutočná rýchlosť vetra v uzloch |
| **TWA** | True Wind Angle | Uhol vetra voči osi lode (zelená = z pravoboku, červená = z ľavoboku) |
| **DEPTH** | Hĺbka | Hĺbka vody pod loďou v metroch – sčervenie pri menej ako 5 m |
| **VMG WP** | Velocity Made Good | Rýchlosť približovania sa k vybranému waypointu |

### Autopilot a motor

Dve farebné dlaždice (zelená = zapnuté, červená = vypnuté) ukazujú stav autopilota aj motora. Ak sú pripojené lodné prístroje (NMEA gateway), prepnutie sa zachytí a zapíše do denníka samo. Bez prístrojov appka použije posledný **ručný** zápis (čip Autopilot/Motor v prehodení plachiet, pozri kapitolu [5.2](#52-čo-sa-deje-počas-plavby)) a dlaždicu označí štítkom **MANUAL**.

### Kompas na paneli

Veľký kruh kompasu v dolnej časti obrazovky ukazuje aktuálny kurz (uprostred, v stupňoch), ružicu (N, E, S, W) a šípku vetra (TWA).

### Navigácia k waypointu

Klepnite na panel **VMG WP** a vyberte cieľový waypoint. Aplikácia zobrazí vzdialenosť (NM), smer (BRG) aj rýchlosť približovania (VMG). Navigáciu vypnete voľbou „Žiadny cieľ" v tej istej dlaždici – vypne ju aj zmazanie waypointu na mape.

> Waypointy sa pridávajú na záložke Mapa. Ak ešte žiadne nemáte, aplikácia vás tam presmeruje.

### Zdroj dát

Vpravo hore vidíte štítok **GPS** (telefón + internetová predpoveď) alebo **NMEA** (dáta priamo z lodných prístrojov cez WiFi gateway, TCP aj UDP – Raymarine aj iné značky). Nastavenia pripojenia sú v Nastavenia → Prístroje.

---

## 5. Lodný denník a spustenie plavby

Záložka **Denník** je srdcom aplikácie. Tu nájdete všetky plavby a odtiaľto sa spúšťa aj ukončuje zaznamenávanie.

### 5.1 Spustenie plavby

1. Klepnite na veľké tlačidlo **„Spustiť plavbu"**.
2. Aplikácia sa opýta len na frekvenciu automatických zápisov (dá sa zmeniť pri každom ďalšom spustení) – žiadny formulár netreba vyplniť vopred.
3. Ak existuje rozostavaná plavba, appka sa opýta, či pokračovať v nej alebo založiť nový záznam.

Aplikácia začne zaznamenávať trasu GPS a automaticky pridávať záznamy do denníka. Chýbajúce údaje (check-in, brífing, karta lode/posádky) appka pripomenie farebnými štítkami priamo na karte plavby – ťuknutím na štítok ich doplníte.

### 5.2 Čo sa deje počas plavby

- GPS nahrávanie beží na pozadí aj keď aplikáciu zatvoríte; v oznamovacej lište telefónu je viditeľné upozornenie o aktívnom trackingu
- Záznamy sa automaticky pridávajú podľa nastavenej frekvencie
- Vľavo dole sú rýchle tlačidlá na jedno ťuknutie, bez formulára: **kormidelník** (kto drží kormidlo), **prehodenie plachiet** (pohon a kurz voči vetru – motor, hlavná, genoa, refy) a **fotoaparát**. Čipy **Autopilot** a **Motor** v prehodení plachiet sú výnimka – appka si pamätá, či práve bežia, takže jedno ťuknutie znamená ZAP alebo VYP, a zapíše sa to ako vlastná udalosť (nie prehodenie plachiet), aj keby ste v tom istom ťuknutí zmenili aj plachty
- Ak sa appka počas plavby vypne bez ukončenia trasovania (systém ju zavrie, nechcený swipe), pri ďalšom spustení ponúkne pokračovanie v tej istej plavbe

> Pri prvom spustení plavby appka pripomenie nastavenie batérie – bez neho vie systém (najmä Honor/Huawei) trasovanie na pozadí vypnúť.

### 5.3 Zastavenie plavby

Klepnite na **Stop**. Aplikácia sa opýta: pokračuje zajtra (pridá ďalší deň), ukončiť plavbu, alebo rozhodnúť neskôr.

### 5.4 Zoznam plavieb a detail dňa

Pre každú plavbu vidíte názov, dátumy, plavidlo, počet dní a stav (✓ Brífing, ✓ Check-in, ✓ Check-out). Klepnutím na plavbu otvoríte zoznam dní; klepnutím na deň uvidíte trasu, počasie dňa, denníkový zápis a automatické aj ručné záznamy.

Mená prístavov odkiaľ/kam appka doplní sama (podľa polohy pri začiatku a konci plavby), ale automatické určenie nemusí byť vždy presné – trafí najbližšie pomenované miesto na mape, nie nutne to, čo by ste tam napísali vy. Ťuknutím na riadok s prístavmi v hornej časti dňa ich viete kedykoľvek opraviť ručne.

Okrem automatických záznamov môžete pridať vlastný tlačidlom **Pridať ručne** – polohu, silu a smer vetra, výšku vĺn, motohodiny, palivo, poznámku aj fotografiu.

### 5.5 Podrobný formulár plavby a odovzdávací protokol

- **Ikona lode** v detaile plavby otvorí kartu s parametrami lode, oblasťou plavby a posádkou (vrátane preukazov skippera a fotiek lode).
- **Ikona podania rúk** otvorí odovzdávací protokol (check-in/check-out) pri charteri: kontrolný zoznam výbavy (plachty, lanovie, kotva, navigácia, vesty, raft...) s poznámkou, polohou a fotkou pre každú položku, stav paliva/vody/motohodín a podpisy oboch strán. Check-out si predvyplní údaje z check-in a zvýrazní nové poškodenia.

---

## 6. Počasie

Klepnite na záložku **Počasie**.

### Predpoveď a výstrahy

Aplikácia stiahne predpoveď podľa aktuálnej polohy z národného meteorologického modelu (napr. Jadran a Taliansko ARPAE ICON-2I, Škandinávia MET Norway, inde ECMWF) a automaticky sa aktualizuje pri zmene polohy. Hore sa zobrazia **úradné výstrahy** (MeteoAlarm) od národnej meteorologickej služby, ak pre danú oblasť nejaké platia.

Bez signálu appka ukáže poslednú uloženú predpoveď a vždy aj to, kedy sa stiahla; staršia než šesť hodín sa označí oranžovo.

### Namerané dáta zo staníc

Karta **Stanice – namerané** ukazuje, čo naozaj niekto nameral (nie model) – zo staníc DHMZ (Chorvátsko) a METAR (letiská po celom svete), aj so vzdialenosťou a časom merania.

### Slnko, mesiac, prílivy a prúd

- Východ/západ slnka a fáza mesiaca sa počítajú priamo v zariadení, internet netreba
- Karta **Príliv/odliv** stiahne 7-dňovú predpoveď zadarmo; kešuje sa, takže zostane čitateľná aj offline
- Karta **Morský prúd** ukazuje predpoveď rýchlosti a smeru pre aktuálnu polohu

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

---

## 7. Bezpečnosť

Toto je najdôležitejšia sekcia aplikácie. Klepnite na záložku ⚓ **Bezpečnosť**.

### 7.1 MOB – Muž cez palubu

Červené tlačidlo **MOB** podržte stlačené (nie krátke klepnutie, aby sa predišlo náhodnej aktivácii). Aplikácia zaznamená GPS polohu pádu, zobrazuje vzdialenosť a smer k nej a spustí hodiny od začiatku záchrannej akcie.

### 7.2 Kotviaci alarm

Po ukotvení nastavte polomer (odporúčané aspoň 2× dĺžka kotevného lana) a klepnite na **Aktivovať**. Ak loď opustí okruh, appka hlasno zapípa a zobrazí výstrahu.

### 7.3 Bezpečnostný brífing

Kontrolný zoznam bodov (kde sú vesty, ako použiť VHF, kde je lekárnička) pred plavbou. Každý člen posádky sa podpíše priamo na obrazovke; podpisy sa automaticky zahrnú do PDF exportu. Tracking sa dá spustiť aj bez vyplneného brífingu – appka to len pripomenie štítkom v Denníku. Brífing vyžaduje najprv vyplnenú kartu lode a posádky.

### 7.4 Služba posádky

Záznam o tom, kto mal kedy službu na palube.

- **Nastúpiť do služby** – vyber jedného alebo viacerých ľudí naraz, mená sa berú z posádky plavby
- **Zobraziť pre kontrolu** – celoobrazovková karta pre kontrolu na palube (kto slúži, od kedy, čas lokálne aj UTC)
- **Rozpis služieb** – spätné doplnenie aj úprava; nočná služba cez polnoc je jeden záznam, v PDF sa objaví na oboch dňoch
- Nástup aj ukončenie sa zapíšu do denníka a do PDF exportu; appka službu nikdy neukončí sama, po 12 hodinách len upozorní

### 7.5 MAYDAY karta a tiesňové kontakty

Postup pre tiesňové volanie na VHF kanál 16 – krok za krokom pre DSC aj hlasový skript. Volací znak a MMSI sa doplnia automaticky z Nastavenia → Identifikácia plavidla. Zoznam tiesňových kontaktov sa vyberá podľa aktuálnej polohy (aj bez zapnutého trasovania) a pri prechode do inej krajiny sa čísla samé vymenia.

### 7.6 COLREG, výbava, signály

- **COLREG** – pravidlá predchádzania zrážkam na mori, dostupné po slovensky a anglicky (ostatné jazyky zobrazia anglický text)
- **Zoznam výbavy** – vlastný kontrolný zoznam vecí na palubu
- **Signály a námorná abeceda** – NATO hláskovacia abeceda, signálne vlajky, denné tvary

---

## 8. Kompas – námerový (resekcia a triangulácia)

Záložka **Kompas** rieši dve odlišné úlohy pomocou magnetického kompasu telefónu a výhľadu zadnej kamery ako pozadia pre zameranie.

**Moja poloha (resekcia)** – nájdi seba, GPS netreba:
1. Over si na mape aspoň dva viditeľné body (maják, vrchol, kostol) ako waypointy.
2. Na kompase prepni na „Moja poloha", vyber prvý zameriavaný bod, namier kríž naň a stlač Zameraj. Skontroluj kurz a ulož.
3. Vyber druhý bod a zopakuj – ideálne do 5 minút, resekcia predpokladá, že loď medzi zameraniami stojí.
4. Na mape uvidíš priesečník dvoch čiar – tvoju polohu. Tretí bod spresní odhad.

**Neznámy bod (reverzná triangulácia)** – nájdi objekt, GPS treba:
1. Prepni na „Neznámy bod", pomenuj, čo zameriavaš (napr. „neznáma skala"), namier a zameraj.
2. Presuň loď aspoň o pár sto metrov a zameraj ten istý objekt znova.
3. Na mape sa objaví značka s vypočítanou polohou objektu – uložíš ju ako waypoint.

Telefónny kompas má reálnu chybu okolo ±8°, preto sa okolo priamky kreslí kužeľ neistoty. Zameranie sa uloží aj bez zapnutého trackingu (na kotve, na brehu) a nájdeš ho v zozname plavieb ako samostatný riadok medzi jednotlivými plavbami, s možnosťou PDF exportu mapky a tabuľky zameraní.

---

## 9. Nastavenia

Klepnite na záložku ⚙️ **Nastavenia**.

### Merné jednotky

| Veličina | Možnosti |
|----------|----------|
| Vzdialenosť | NM alebo km |
| Rýchlosť | uzly alebo km/h |
| Teplota | °C alebo °F |
| Hĺbka a vlny | metre alebo stopy |
| Vietor | uzly / m/s / Beaufort |

### Jazyk aplikácie

Aplikácia je dostupná v **11 jazykoch**: slovenčina, čeština, angličtina, nemčina, taliančina, španielčina, poľština, gréčtina, ukrajinčina, chorvátčina, slovinčina.

### Identifikácia plavidla

Zadajte volací znak a MMSI číslo lode – automaticky sa doplnia v MAYDAY karte.

### Lodné prístroje (NMEA)

Ak loď má NMEA→WiFi gateway (napr. Digital Yacht, Yacht Devices, Actisense, Quark-elec – funguje aj s plottermi ako Raymarine, B&G/Navico a podobne), pripojte telefón na jeho WiFi a zadajte IP a port (alebo skúste automatické vyhľadanie). Po pripojení sa v Lodných prístrojoch zobrazí štítok **NMEA**.

### Spodné menu

Podrž a potiahni ikonu pre zmenu poradia záložiek, prepínačom skry tie, ktoré nepoužívaš, a nastav veľkosť ikon. Skryté karty otvoríš priamo tu v Nastaveniach.

### Cloud export (Google Drive)

Po prihlásení Google účtom sa PDF a GPX z ukončeného dňa automaticky nahrajú na váš vlastný Google Disk, do priečinka `HMB_Sailing_Log_DATA`. Appka vidí a zapisuje len súbory, ktoré sama vytvorila (najužšie možné oprávnenie). Bez prihlásenia zostáva všetko iba v telefóne. Pozri aj kapitolu [Zálohovanie a cloud export](#11-zálohovanie-a-cloud-export).

---

## 10. Vytvorenie PDF lodného denníka a knihy míľ

### Lodný denník

1. V Denníku otvorte plavbu a klepnite na **Export PDF** (celá plavba alebo jeden deň).
2. Počkajte na vygenerovanie máp, podpíšte sa prstom ako skipper a exportujte.
3. Vyberte uloženie do telefónu alebo zdieľanie.

PDF obsahuje titulnú stranu, mapu s trasou, tabuľku zápisov, denné záznamy, prehľad služby posádky aj podpis skipera. Každý export dostane jedinečné ID dokumentu a číslo revízie viditeľné v pätičke; QR kód na podpisovej strane obsahuje kryptografický odtlačok obsahu – akákoľvek zmena dát zmení QR kód.

### Kniha míľ

Ikona v Denníku plavby zobrazí súhrn všetkých plavieb: celkové námorné míle, dni na mori, počet plavieb, nočné hodiny, rozpad podľa roka a lode. Tlačidlom **+** pridáte aj historickú plavbu spred používania appky. Pre každého člena posádky viete vyexportovať dvojjazyčné PDF potvrdenie o naplávaných míľach s hodnotením zručností od skippera a QR kódom na overenie pravosti.

---

## 11. Zálohovanie a cloud export

V **Nastavenia → Záloha dát**:

- **Exportovať zálohu** – uloží celý denník (plavby, záznamy, nastavenia) do jedného súboru (`.hmbbackup`), ktorý môžete zdieľať alebo uložiť
- **Obnoviť zo zálohy** – nahradí aktuálne dáta obsahom vybranej zálohy; pred prepísaním sa automaticky vytvorí bezpečnostná záloha súčasného stavu. Obnova je zablokovaná počas aktívneho GPS trackingu

Okrem ručnej zálohy je tu aj **automatický cloud export** cez Google Drive (Nastavenia → Cloud export) – po prihlásení sa PDF a GPX z ukončeného dňa nahrajú samé, bez ďalšieho zásahu.

---

## 12. Tipy pre dlhšie plavby

**Batéria:** GPS neustále zaťažuje batériu. Appka sama prepína GPS presnosť podľa toho, či na nej práve záleží (sledovanie plavby, mapa, kompas, kotvová stráž, MOB), inak šetrí. Na dlhé plavby si aj tak vezmite powerbanku alebo nabíjajte v lodnej elektrine.

**Offline:** Aplikácia funguje bez internetu – GPS, denník, mapa aj bezpečnostné funkcie. Internet potrebujete na stiahnutie predpovede počasia a na cloud export.

**Záloha dát:** Dáta sú uložené v telefóne. Ak stratíte telefón, stratíte aj záznamy – pokiaľ nemáte zapnutý cloud export alebo si pravidelne nerobíte ručnú zálohu (viď vyššie).

**Fotky:** K zápisom môžete prikladať fotky – kotviská, zaujímavé miesta, prípadné poškodenia lode pre check-out.

---

## Rýchly štart – čo robiť pred každou plavbou

```
☐  1. Skontroluj predpoveď počasia (záložka Počasie)
☐  2. Vyplň Bezpečnostný brífing s posádkou
☐  3. Prejdi Check-in zoznam (ak preberáš loď)
☐  4. Vyplň identifikáciu plavidla v Nastaveniach
☐  5. Klepni na Denník → Spustiť plavbu
☐  6. Dobrý vietor! ⛵
```

---

*HMB Sailing Log*
