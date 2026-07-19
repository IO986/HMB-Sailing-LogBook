// ── COLREG – slovenská verzia obsahu ────────────────────────────
// Spracované podľa: Tim Bartlett, "COLREG Komentovaná", RYA/IFP Publishing
// Preložené a skrátené pre potreby HMB Sailing Log
//
// Typy blokov sú v colreg_content.dart; tento súbor obsahuje iba dáta.

import 'colreg_content.dart';

final List<ColregSection> colregChaptersSk = [
  _chapter1,
  _chapter2,
  _chapter3,
  _chapter4,
  _chapter5,
  _chapter6,
  _chapter7,
];
// ── Kapitola 1: Kto, kedy, kde? ─────────────────────────────────

final _chapter1 = ColregSection(
  id: 'ch1',
  title: '1: Kto, kedy, kde?',
  blocks: [
    ColregText(
      'Prvá časť pravidiel COLREG (časť A: Všeobecne) obsahuje základné '
      'definície a rozsah platnosti pravidiel.',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule1',
      title: 'Pravidlo 1: Použitie',
      ruleNumber: '1',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 1: Použitie',
          text:
              'a) Tieto pravidlá sa vzťahujú na všetky plavidlá na otvorenom mori '
              'a na všetkých vodách s ním spojených, po ktorých môžu plávať '
              'námorné lode.\n\n'
              'b) Nič z týchto pravidiel nesmie brániť platnosti zvláštnych '
              'pravidiel vydaných príslušnými orgánmi pre plavbu v kotviskách, '
              'prístavoch, riekach, jazerách alebo na vnútrozemských vodných '
              'cestách spojených s otvoreným morom. Takéto zvláštne pravidlá '
              'sa však musia čo najviac zhodovať s týmito pravidlami.\n\n'
              'c) Nič z týchto pravidiel nesmie brániť platnosti zvláštnych '
              'pravidiel vlád jednotlivých krajín týkajúcich sa doplnkových '
              'svetiel, znakov alebo zvukových signálov vojnových lodí, lodí '
              'v konvojoch alebo rybárskych lodí pri spoločnom love.\n\n'
              'd) Pre účely týchto pravidiel môžu byť Organizáciou schválené '
              'systémy rozdelenia plavby.\n\n'
              'e) Ak vláda rozhodne, že plavidlo vzhľadom na svoju špeciálnu '
              'konštrukciu alebo účel nemôže plne splniť niektoré z týchto '
              'pravidiel (svetlá, znaky, zvukové zariadenia), musí čo najviac '
              'priblížiť svoje vybavenie týmto pravidlám.',
        ),
        ColregText(
          'Prvý odsek je jednoducho zrozumiteľný: ak sa nachádzate na '
          'akomkoľvek plavidle, na akejkoľvek vode spojenej s morom, platí '
          'pre vás COLREG.',
        ),
        ColregText(
          'Ďalšie odseky umožňujú vládam a miestnym úradom vytvoriť si '
          'vlastné predpisy pre špecifické miestne podmienky – napríklad '
          'obmedzenia rýchlosti v prístavoch, vyhradené VHF kanály, alebo '
          'pravidlo že miestny trajekt má prednosť pred všetkými ostatnými '
          'plavidlami.',
        ),
        ColregNote(
          'Miestne predpisy by mali COLREG doplňovať, nikdy by s ním nemali '
          'byť v rozpore.',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule2',
      title: 'Pravidlo 2: Zodpovednosť',
      ruleNumber: '2',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 2: Zodpovednosť',
          text:
              'a) Nič z týchto pravidiel neosvobodzuje loď, majiteľa, kapitána '
              'ani posádku od zodpovednosti za následky vyplývajúce z '
              'neplnenia týchto pravidiel alebo zanedbania bezpečnostných '
              'opatrení, ktoré vyžaduje dobrá námorná prax alebo zvláštne '
              'okolnosti daného prípadu.\n\n'
              'b) Pri výklade a používaní týchto pravidiel je potrebné brať '
              'do úvahy všetky nebezpečenstvá plavby a zrážky lodí, vrátane '
              'zvláštnych okolností, ktoré si môžu vyžiadať odstúpenie od '
              'týchto pravidiel, aby sa zabránilo bezprostrednému nebezpečenstvu.',
        ),
        ColregText(
          'Pravidlo 2 hovorí, že predpisy nenahrádzajú zdravý rozum a námornú '
          'prax. Pokiaľ by podmienky konkrétnej situácie spôsobili, že '
          'dodržanie litery predpisu by bolo nebezpečné, nielen že máte '
          'právo sa od neho odchýliť – dokonca sa to od vás vyžaduje.',
        ),
        ColregText(
          'Príklad: COLREG neudeľuje žiadne špeciálne práva zakotveným '
          'plavidlám, ale bolo by absurdné naraziť do boku zakotvenej lode '
          'a obviniť ju, že vám nedala prednosť.',
        ),
        ColregNote(
          'Pravidlo 2 ale neoprávňuje porušovať predpisy len preto, že sa '
          'to niekomu hodí alebo je to pohodlnejšie. Odchýlka je prípustná '
          'iba ak je „nutná, aby sa predišlo bezprostrednému nebezpečenstvu“.',
          type: ColregNoteType.warning,
        ),
      ],
    ),
    ColregSection(
      id: 'rule3',
      title: 'Pravidlo 3: Definície',
      ruleNumber: '3',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 3: Definície (výber)',
          text:
              'a) "Plavidlo" alebo "loď" – všetky plávajúce zariadenia, '
              'vrátane bezvýtlakových plavidiel, hydroplánov a ekranoplánov.\n\n'
              'b) "Loď so strojným pohonom" – akékoľvek plavidlo poháňané '
              'strojným zariadením.\n\n'
              'c) "Plachetnica" – akékoľvek plavidlo plávajúce pod plachtami, '
              'vrátane lode so strojným pohonom, ak tento pohon nie je '
              'používaný.\n\n'
              'd) "Loď vykonávajúca rybolov" – plavidlo loviace sieťami, '
              'šnúrami alebo iným zariadením, ktoré obmedzuje jeho '
              'manévrovaciu schopnosť (nezahŕňa trolling).\n\n'
              'f) "Neovládateľné plavidlo" – plavidlo, ktoré z výjimočných '
              'okolností nie je schopné manévrovať podľa pravidiel, a teda '
              'nemôže uvoľniť cestu inej lodi.\n\n'
              'g) "Plavidlo s obmedzenou manévrovacou schopnosťou" – plavidlo '
              'obmedzené v manévrovaní povahou vykonávanej práce (pokladanie '
              'kábelov, bagrovanie, doplňovanie zásob na mori, vlečenie, atď.).\n\n'
              'k) Lode sa považujú za plavidlá vo vzájomnom dohľade, len ak '
              'môže byť jedna vizuálne pozorovaná z druhej.\n\n'
              'l) "Znížená viditeľnosť" – akékoľvek podmienky znížené hmlou, '
              'oparom, snehom, dažďom, pieskovou búrkou a podobne.',
        ),
        ColregText(
          'Dôležité: "status" plavidla podľa COLREG závisí na tom, čo '
          'plavidlo právě robí – nie na tom, čo je schopné robiť.',
        ),
        ColregList([
          'Rybárska loď je "loďou vykonávajúcou rybolov" iba vtedy, keď '
              'skutočne používa rybárske vybavenie obmedzujúce manévrovanie. '
              'Nie je ňou, keď sa vracia domov z loviska.',
          'Plachetnica má práva a povinnosti "plachetnice" iba keď skutočne '
              'používa plachty. Ak pluje na motor (aj pri "motorsailingu"), '
              'je to "loď so strojným pohonom".',
        ]),
        ColregNote(
          'Plavidlá s obmedzenou manévrovacou schopnosťou: pokladanie '
          'navigačných znakov, kábelov; bagrovacie a hydrografické práce; '
          'doplňovanie zásob za plavby; štarty/pristávanie letadiel; '
          'odmínovacie práce; vlečné operácie podstatne obmedzujúce '
          'manévrovanie.',
          type: ColregNoteType.info,
        ),
      ],
    ),
  ],
);

// ── Kapitola 2: Vyhodnotenie rizika ─────────────────────────────

final _chapter2 = ColregSection(
  id: 'ch2',
  title: '2: Vyhodnotenie rizika',
  blocks: [
    ColregText(
      'Časť B Kapitola I COLREG obsahuje pravidlá platné za akýchkoľvek '
      'podmienok viditeľnosti (Pravidlá 4–10).',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule5',
      title: 'Pravidlo 5: Pozorovanie',
      ruleNumber: '5',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 5: Pozorovanie',
          text:
              'Každá loď musí viesť nepretržité a zodpovedné vizuálne a '
              'sluchové pozorovanie, ako aj pozorovanie pomocou všetkých '
              'dostupných prostriedkov podľa prevládajúcich okolností, tak '
              'aby bolo možné plne zhodnotiť situáciu a nebezpečenstvo zrážky.',
        ),
        ColregText(
          'Bez pozorovania nemôžete dúfať, že sa niečomu vyhnete, keď o tom '
          'ani nevedíte. Mnohé zrážky boli spôsobené nedodržaním riadneho '
          'pozorovania – viac než pri ktoromkoľvek inom pravidle.',
        ),
        ColregHeading('Slepé uhly'),
        ColregDiagram('blind_spots', 'Typické slepé uhly na plachetnici a motorovej jachte'),
        ColregText(
          'Väčšina plachetníc má aspoň dva výrazné slepé uhly: za prednou '
          'plachtou (kosatka/genoa) na záveternej strane a za stechou '
          'kajuty/sprayhoodom. Väčšina motorových jácht riadených z '
          'kormidelne má veľký slepý uhol za zádou a malé za stĺpikmi okien.',
        ),
        ColregList([
          'Nesedte/nestojte na rovnakom mieste dlhšie ako pár minút',
          'Pred zmenou kurzu sa dôkladne podívajte aj za záď',
          'Posaďte posádku na záveternú stranu pre lepší výhľad vpredu',
        ]),
        ColregHeading('Použitie radaru, VHF, AIS'),
        ColregText(
          'Ak vám radar, VHF alebo AIS pomôže lepšie zhodnotiť situáciu, je '
          'ich použitie povinné, nie voliteľné. V mlhe by bolo vrcholom '
          'nerozumnosti nepoužiť radar, ak ho máte k dispozícii.',
        ),
        ColregNote(
          'Nočné videnie sa rozvíja postupne až pol hodiny, ale stratí sa '
          'v okamihu, keď niekto rozsvieti baterku alebo svetlo v kajute. '
          'Používajte tlmené červené osvetlenie pri mapovom stolíku.',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule6',
      title: 'Pravidlo 6: Bezpečná rýchlosť',
      ruleNumber: '6',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 6: Bezpečná rýchlosť',
          text:
              'Každá loď musí vždy plávať bezpečnou rýchlosťou tak, aby mohla '
              'urobiť vhodné opatrenia na zabránenie zrážky a zastaviť na '
              'vzdialenosť zodpovedajúcu daným okolnostiam. Treba zohľadniť: '
              'viditeľnosť, hustotu provozu, manévrovaciu schopnosť (najmä '
              'brzdnú dráhu), nočné svetlá pozadia, stav vetra/mora/prúdu, '
              'ponor vo vzťahu k hĺbke vody, a (pri použití radaru) jeho '
              'charakteristiky a obmedzenia.',
        ),
        ColregText(
          'Rýchlosť samotná málokedy spôsobí zrážku, ale zväčšuje brzdnú '
          'dráhu, znižuje čas na rozhodnutie a zvyšuje škody pri zrážke.',
        ),
        ColregNote(
          'Vyšetrovatelia zrážky 14-metrovej jachty Wahkuna so 227-metrovou '
          'kontajnerovou loďou Nedlloyd Vespucci zistili, že kontajnerová '
          'loď plávala 25 uzlov pri viditeľnosti len 50 metrov! Z 19 ďalších '
          'lodí v okolí iba jedna znížila rýchlosť pre podmienky viditeľnosti.',
          type: ColregNoteType.story,
        ),
        ColregText(
          'Malé plavidlá majú jednu silnú výhodu: vysokú manévrovateľnosť. '
          'Skipperi plachetníc by však nemali túto výhodu zbytočne obmedzovať '
          'príliš komplikovaným oplachtením pri nízkej rýchlosti.',
        ),
      ],
    ),
    ColregSection(
      id: 'rule7',
      title: 'Pravidlo 7: Nebezpečenstvo zrážky',
      ruleNumber: '7',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 7: Nebezpečenstvo zrážky',
          text:
              'a) Každá loď musí použiť všetky dostupné prostriedky na '
              'stanovenie, či existuje nebezpečenstvo zrážky. Pri '
              'pochybnostiach treba predpokladať, že existuje.\n\n'
              'b) Ak je k dispozícii funkčný radar, musí byť náležite '
              'využitý vrátane pozorovania na vzdialených stupniciach.\n\n'
              'c) Závery sa nesmú robiť na základe neúplných informácií.\n\n'
              'd) Nebezpečenstvo zrážky treba pokladať za isté, ak sa '
              'výrazne nemení kompasový náměr na približujúce sa plavidlo. '
              'Nebezpečenstvo môže existovať aj pri meniacom sa náměre, '
              'najmä pri veľmi veľkých plavidlách alebo vlečných súpravách.',
        ),
        ColregHeading('Test nemenného náměru'),
        ColregDiagram('bearing_test', 'Zarovnanie blížiaceho sa plavidla so sloupkom zábradlia'),
        ColregText(
          'Klasický test: zarovnajte blížiace sa plavidlo s pevnou súčasťou '
          'vlastnej lode (napr. sloupik zábradlia). Ak zostáva zarovnané aj '
          'o niekoľko minút neskôr a vy ste plávali stabilným kurzom, '
          'kompasový náměr sa nezmenil – hrozí zrážka alebo veľmi tesné minutie.',
        ),
        ColregNote(
          'Pozor: ide o kontrolu relatívneho náměru, nie kompasového. Ak '
          'nedokážete udržať dokonale stabilný kurz, môže vám to dať falošný '
          'pocit bezpečia. Dávajte si pozor zvlášť na veľmi veľké plavidlá '
          'a dlhé vlečné súpravy – ak sa náměr na záď znižuje a na príď '
          'zvyšuje, narazíte niekde uprostred!',
          type: ColregNoteType.warning,
        ),
      ],
    ),
    ColregSection(
      id: 'rule8',
      title: 'Pravidlo 8: Činnosť pre zabránenie zrážke',
      ruleNumber: '8',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 8: Činnosť pre zabránenie zrážke',
          text:
              'a) Akákoľvek činnosť pre zabránenie zrážke musí byť pozitívna, '
              'včasná a v súlade s dobrou námornou praxou.\n\n'
              'b) Zmena kurzu a/alebo rýchlosti musí byť dostatočne výrazná, '
              'aby ju druhé plavidlo ľahko zistilo. Vyhnite sa sérii malých '
              'zmien.\n\n'
              'c) Ak je dostatok priestoru, samotná zmena kurzu môže byť '
              'najefektívnejším krokom.\n\n'
              'd) Akcia musí zaistiť bezpečné minutie – efektívnosť treba '
              'kontrolovať, kým sa plavidlá úplne nevzdialia.\n\n'
              'e) Ak je nutné, loď musí znížiť rýchlosť alebo zastaviť stroj.',
        ),
        ColregText(
          '„Pozitívna“ zmena kurzu znamená dostatočne výraznú, aby ju '
          'zaznamenala hliadka na druhom plavidle. Pri stretnutí takmer '
          'priamo proti sobě v noci môže stačiť zmena cca 10°, aby druhé '
          'plavidlo uvidelo červené svetlo namiesto zeleného. Pri pohľade '
          'zboku môže byť zmena 30–40° málo postrehnutelná.',
        ),
        ColregDiagram('positive_action', 'Porovnanie nevýraznej a výraznej zmeny kurzu'),
        ColregNote(
          'Pojem "neomedzí" (Pravidlo 8f): jachta menšia ako 20m je povinná '
          'neomedziť veľkú loď v úzkom kanáli – musí urobiť úhybný manéver '
          'dostatočne včas, aby otázka prednosti vôbec nenastala.',
          type: ColregNoteType.info,
        ),
        ColregHeading('Odhad vzdialenosti'),
        ColregText(
          'Vzdialenosť k horizontu (v míľach) je približne dvakrát druhá '
          'odmocnina výšky oka v metroch. Pri väčšine rekreačných plavidiel '
          'je horizont medzi 2 a 5 míľami.',
        ),
      ],
    ),
  ],
);

// ── Kapitola 3: Úzke kanály a systémy rozdelenia plavby ─────────

final _chapter3 = ColregSection(
  id: 'ch3',
  title: '3: Úzke kanály a systémy rozdelenia plavby',
  blocks: [
    ColregText(
      'Pravidlá 9 a 10 sa zaoberajú plavbou v úzkych kanáloch a systémoch '
      'rozdelenej plavby (TSS). Princípy zhrnuté:',
    ),
    ColregList([
      'plávajte vpravo',
      'malé plavidlá neprekážajte v kanáli',
      'neprekážajte ani pri rybolove',
      'nekrižujte kanál priamo pred prídou plavidla v ňom plávajúceho',
      'používajte zvukové signály',
      'buďte opatrní v zákrutách, do ktorých nevidíte',
      'v kanáli nekotvte',
    ]),
  ],
  children: [
    ColregSection(
      id: 'rule9',
      title: 'Pravidlo 9: Úzke plavebné dráhy',
      ruleNumber: '9',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 9: Úzke plavebné dráhy',
          text:
              'a) Loď plávajúca úzkym prielivom alebo plavebnou dráhou sa '
              'musí držať vonkajšej strany dráhy na svojom pravoboku, čo '
              'najbližšie ako je to bezpečné.\n\n'
              'b) Loď kratšia ako 20m alebo plachetnica nesmie obmedziť '
              'priechod lode, ktorá môže bezpečne plávať len v hraniciach '
              'úzkeho prielivu.\n\n'
              'c) Loď vykonávajúca rybolov nesmie obmedziť priechod žiadneho '
              'plavidla v úzkom prielive.\n\n'
              'd) Loď nesmie krížiť úzky prieliv, ak by tým obmedzila pohyb '
              'lode plávajúcej v ňom. Druhá loď môže pri pochybnostiach '
              'použiť zvukový signál (Pravidlo 34d).\n\n'
              'e) Predbiehanie v úzkom prielive vyžaduje zvukové signály '
              '(dva dlhé + jeden/dva krátke tóny).\n\n'
              'f) Pri približovaní k zákrute alebo skrytému úseku – '
              'zvláštna opatrnosť a zvukový signál (jeden dlhý tón).\n\n'
              'g) Vyhnite sa kotveniu v úzkom prielive.',
        ),
        ColregDiagram('narrow_channel', 'Správne a nesprávne držanie sa v kanáli'),
        ColregText(
          'Slovo "úzky" nie je v COLREG definované. Súdne rozhodnutia '
          'naznačujú hornú hranicu okolo 2 míľ. Ak je kanál značený '
          'červenými a zelenými bójami, veľké lode ho budú pravdepodobne '
          'pokladať za úzky kanál.',
        ),
        ColregNote(
          'Praktickým riešením je drziet sa úplne mimo kanála, na mělkej '
          'vode, kam veľké lode nemôžu vplávať (ak to miestne pravidlá '
          'umožňujú).',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule10',
      title: 'Pravidlo 10: Systémy rozdelenej plavby',
      ruleNumber: '10',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 10: Systémy rozdelenej plavby (skrátené)',
          text:
              'Loď používajúca systém rozdelenej plavby (TSS) musí:\n'
              '• plávať v určenom smere pre danú dráhu\n'
              '• drziet sa čo najviac mimo deliacej linie/pásma\n'
              '• vstupovať/vystupovať na koncoch dráhy, alebo pod čo '
              'najmenším uhlom\n\n'
              'Krížiť dráhu sa má pokiaľ možno pod pravým uhlom k smeru '
              'provozu. Pobrežnú plavebnú zónu môžu používať lode kratšie '
              'ako 20m, plachetnice a rybárske lode.',
        ),
        ColregDiagram('tss_diagram', 'Systém rozdelenej plavby – schéma'),
        ColregList([
          'Plávajte v smere dráhy',
          'Vstupujte na koncoch',
          'Pripájajte sa pod širokým uhlom',
          'Ak musíte krížiť, krížte pod pravým uhlom',
        ]),
        ColregNote(
          'Plachetnica pod plachtami nesmie veľkú loď v TSS obmedziť, ale '
          'veľká loď je jej povinná dať prednosť. V praxi: vyhnite sa '
          'veľkým loďiam ako sa len dá a čo najrýchlejšie TSS opustite.',
          type: ColregNoteType.warning,
        ),
      ],
    ),
  ],
);

// ── Kapitola 4: Kto dáva prednosť? ──────────────────────────────

final _chapter4 = ColregSection(
  id: 'ch4',
  title: '4: Kto dáva prednosť?',
  blocks: [
    ColregText(
      'Táto časť (Pravidlá 11–18) sa vzťahuje na lode vo vzájomnom dohľade '
      'a obsahuje pravidlá, ktoré platia v zásade nezmenené od roku 1863.',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule12',
      title: 'Pravidlo 12: Plachetnice',
      ruleNumber: '12',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 12: Plachetnice',
          text:
              'Ak sa k sebe približujú dve plachetnice tak, že vzniká '
              'nebezpečenstvo zrážky, musí jedna z nich uvoľniť cestu druhej:\n\n'
              'i) Ak má každá vietr z inej strany – loď s vetrom z ľavoboku '
              'musí uvoľniť cestu.\n\n'
              'ii) Ak majú obe vietr z rovnakej strany – loď na vetrnej '
              'strane musí uvoľniť cestu lodi na záveternej strane.\n\n'
              'iii) Ak loď s vetrom z ľavoboku vidí druhú loď z vetrnej '
              'strany a nemôže určiť, z ktorej strany má táto loď vietr, '
              'musí jej uvoľniť cestu.',
        ),
        ColregDiagram('sailboat_opposite_tack', 'Vietr z rôznych strán – ľavobočná uvoľní cestu'),
        ColregDiagram('sailboat_same_tack', 'Vietr z rovnakej strany – vetrná uvoľní cestu'),
        ColregText(
          'Bod iii) platí len keď je druhé plavidlo proti vetru od vás a vy '
          'pluje na ľavobočnom vetre. Inými slovami: pri pochybnostiach, '
          'predpokladajte že máte dať prednosť.',
        ),
        ColregNote(
          'Aj keď nevidíte na ktorom vetre druhá loď pluje, jej hliadka to '
          'vidí jasne. Ak chcete riešiť situáciu zakrižovaním, urobte to '
          's veľkým predstihom. Pri pochybnostiach je najbezpečnejšie '
          'odpadnúť na paralelný kurz a znovu vyhodnotiť situáciu.',
          type: ColregNoteType.warning,
        ),
      ],
    ),
    ColregSection(
      id: 'rule13',
      title: 'Pravidlo 13: Predbiehanie',
      ruleNumber: '13',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 13: Predbiehanie',
          text:
              'a) Bez ohľadu na čokoľvek v tejto časti, každá loď predbiehajúca '
              'inú loď sa musí držať mimo dráhy predbiehanej lode.\n\n'
              'b) Loď je predbiehajúca, ak sa približuje z smeru viac ako '
              '22,5° za traversom – v takej polohe, že by v noci videla '
              'len záďové svetlo predbiehanej lode, nie bočné svetlá.\n\n'
              'c) Pri pochybnostiach treba predpokladať predbiehanie.\n\n'
              'd) Žiadna následná zmena vzájomného postavenia nemôže zmeniť '
              'status predbiehajúcej lode, kým predbiehanie nie je úplne '
              'dokončené.',
        ),
        ColregDiagram('overtaking_sector', 'Sektor predbiehania – 22,5° za traversom'),
        ColregText(
          'Toto pravidlo má absolútnu prioritu nad ostatnými pravidlami '
          'pre plavbu a manévrovanie (s výjimkou Pravidla 19 – znížená '
          'viditeľnosť). Rýchlo plávajúca plachetnica musí dať prednosť '
          'pomaly plávajúcemu motorovému člnu, ak ho predbieha!',
        ),
        ColregNote(
          'Po fatálnej zrážke bagra Bowbelle s diskotékovou loďou Marchioness '
          'sa zistilo, že pri predbiehaní veľkej a malej lode môže vzniknúť '
          'nebezpečná interakcia vĺn – menšie plavidlo môže stratiť kontrolu '
          'a stočiť sa pod príď väčšej lode.',
          type: ColregNoteType.story,
        ),
      ],
    ),
    ColregSection(
      id: 'rule14_15',
      title: 'Pravidlá 14 a 15: Motorové lode',
      ruleNumber: '14-15',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 14: Lode plávajúce proti sobě',
          text:
              'Ak sa k sebe približujú dve lode so strojným pohonom v '
              'opačnom alebo takmer opačnom kurze tak, že vzniká '
              'nebezpečenstvo zrážky, musí každá z nich zmeniť svoj smer '
              'plavby vpravo, aby míňala druhú loď po ľavej strane.',
        ),
        ColregDiagram('head_on_situation', 'Stretnutie proti sebe – obe odbočia vpravo'),
        ColregNote(
          'ZLATÉ PRAVIDLO: Ak sa stretávate takmer priamo proti sobe, '
          'NIKDY nezatáčajte doľava! Ak druhá loď zatočí doľava keď vy '
          'zatočíte doprava, máte vážny problém – buď zastavte, alebo '
          'pokračujte v otočke o 180° a uniknite.',
          type: ColregNoteType.danger,
        ),
        ColregRuleBox(
          title: 'Pravidlo 15: Krížiace sa trasy',
          text:
              'Ak sa krížia trasy dvoch lodí so strojným pohonom tak, že '
              'vzniká nebezpečenstvo zrážky, musí loď, ktorá má druhú loď '
              'po svojej pravej strane, uvoľniť cestu a vyvarovať sa '
              'krížiť trasu pred prídou druhej lode.',
        ),
        ColregDiagram('crossing_situation', 'Krížiace sa trasy – loď s druhou loďou na pravoboku uvoľní cestu'),
        ColregText(
          'Toto je rovnaké pravidlo ako "pravidlo pravej ruky" na malom '
          'kruhovom objazde. Loď uvoľňujúca cestu by mala zmeniť kurz '
          'doprava alebo zpomaliť – nie prejazdiť pred prídou.',
        ),
      ],
    ),
    ColregSection(
      id: 'rule16_17',
      title: 'Pravidlá 16 a 17: Činnosť lode',
      ruleNumber: '16-17',
      blocks: [
        ColregText(
          'V jazyku COLREG existujú plavidlá ktoré "uvoľňujú cestu" a '
          'plavidlá "ktorým je uvoľňovaná cesta" (drziace kurz). Neexistuje '
          'nič ako plavidlo, ktoré "má prednosť".',
        ),
        ColregRuleBox(
          title: 'Pravidlo 16: Činnosť lode uvoľňujúcej cestu',
          text:
              'Každá loď povinná uvoľniť cestu musí, pokiaľ je to možné, '
              'urobiť včasnú a rozhodnú akciu pre bezpečné minutie.',
        ),
        ColregRuleBox(
          title: 'Pravidlo 17: Činnosť lode, ktorej je uvoľňovaná cesta',
          text:
              'a) i) Loď, ktorej je uvoľňovaná cesta, musí udržovať svoj '
              'smer a rýchlosť.\n'
              'ii) Ak zistí, že druhá loď nekoná podľa pravidiel, môže sama '
              'prijať opatrenia.\n\n'
              'b) Ak sa loď ocitne tak blízko, že zrážke nemôže byť '
              'zabránené len akciou lode uvoľňujúcej cestu, musí urobiť '
              'všetko pre odvrátenie zrážky.\n\n'
              'c) Loď so strojným pohonom by sa pri vlastnej akcii nemala '
              'stáčať doľava, ak je druhá loď po jej ľavej strane.',
        ),
        ColregHeading('Štyri fázy vývoja situácie'),
        ColregList([
          '1. Prípravná fáza – žiadne riziko (lode mimo dohľadu/daleko)',
          '2. Prvá fáza – povinnosť: drziet smer a rýchlosť, monitorovať vývoj',
          '3. Druhá fáza – dobrovoľný zákrok: hliadka zistí, že cesta jej '
              'nie je uvoľňovaná, môže reagovať (typicky odbočiť doprava)',
          '4. Tretia fáza – povinný zákrok: zrážke nemožno zabrániť len '
              'akciou druhej lode, odbočka doľava sa stáva prípustnou',
        ], numbered: true),
        ColregNote(
          'Odporúčanie z odbornej literatúry: na otvorenom mori by loď, '
          'ktorej je uvoľňovaná cesta, nemala dovoliť priblíženie druhej '
          'lode na menej ako cca 12 vlastných dĺžok bez vlastného zákroku.',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'rule18',
      title: 'Pravidlo 18: Vzájomné povinnosti lodí',
      ruleNumber: '18',
      blocks: [
        ColregText(
          'Toto pravidlo určuje hierarchiu, kto uvoľňuje cestu komu na '
          'otvorenej vode (s prioritou Pravidiel 9, 10 a 13):',
        ),
        ColregList([
          'neovládateľné plavidlo',
          'plavidlo s obmedzenou manévrovacou schopnosťou',
          'plavidlo obmedzené ponorom',
          'plavidlo vykonávajúce rybolov',
          'plachetnica',
          'loď so strojným pohonom',
          'hydroplán či ekranoplán',
        ], numbered: true),
        ColregNote(
          'Drziet sa z cesty všetkému, čo je v tomto zozname VYŠŠIE ako vy. '
          'Napríklad motorová loď musí uvoľniť cestu plachetnici, '
          'plachetnica musí uvoľniť cestu rybárskej lodi.',
          type: ColregNoteType.info,
        ),
      ],
    ),
  ],
);

// ── Kapitola 5: Hmla! ────────────────────────────────────────────

final _chapter5 = ColregSection(
  id: 'ch5',
  title: '5: Hmla!',
  blocks: [
    ColregNote(
      'ZA ZNÍŽENEJ VIDITEĻNOSTI NEEXISTUJE NIČ TAKÉ AKO PLAVIDLO '
      'UVOĻŇUJÚCE CESTU ALEBO PLAVIDLO, KTOREMU JE UVOĻŇOVANÁ CESTA. '
      'Pravidlo 19 plne nahrádza Pravidlá 11–18.',
      type: ColregNoteType.danger,
    ),
  ],
  children: [
    ColregSection(
      id: 'rule19',
      title: 'Pravidlo 19: Plavba v zníženej viditeľnosti',
      ruleNumber: '19',
      blocks: [
        ColregRuleBox(
          title: 'Pravidlo 19: Plavba v zníženej viditeľnosti',
          text:
              'a) Týka sa lodí, ktoré nie sú vo vzájomnom dohľade v oblasti '
              'zníženej viditeľnosti.\n\n'
              'b) Každé plavidlo musí plávať bezpečnou rýchlosťou. Loď so '
              'strojným pohonom musí mať motory pripravené k okamžitému '
              'manévru.\n\n'
              'd) Plavidlo zistivšie iné plavidlo iba radarom musí určiť, '
              'či vzniká nebezpečenstvo zrážky. Ak áno, vyhnite sa:\n'
              '  i) zmene kurzu doľava, ak je druhé plavidlo pred traversom '
              '(a nejde o predbiehanie)\n'
              '  ii) zmene kurzu smerom k druhému plavidlu, ak je na '
              'traverze alebo za ním\n\n'
              'e) Pri zaslyšaní mlhového signálu spredu, alebo nemožnosti '
              'zabrániť prílišnému zblíženiu, treba znížiť rýchlosť na '
              'minimum potrebné k udržaniu kurzu, prípadne zastaviť.',
        ),
        ColregText(
          'V praxi to znamená: nesmiete robiť nič, čo by zvýšilo riziko – '
          'preložené pozitívne, pravidlo hovorí toto:',
        ),
        ColregList([
          'Zmeňte kurz DOPRAVA, ak sa k vám blíži plavidlo spredu',
          'Zmeňte kurz DOPRAVA, ak sa blíži z ľavoboku alebo zozadu na ľavej strane',
          'Zmeňte kurz DOĻAVA, ak sa blíži z pravoboku alebo zozadu na pravej strane',
        ]),
        ColregDiagram('fog_radar_avoidance', 'Manévrovanie podľa radaru v mlhe'),
        ColregNote(
          'Wahkuna (2003): jachta i kontajnerová loď Nedlloyd Vespucci sa '
          'navzájom zachytili na radare už na 6 míľ. Kapitán jachty znížil '
          'rýchlosť myslíac si, že kontajnerová loď proplava vpred. Veliteľ '
          'kontajnerovej lode pokračoval rýchlosťou 25 uzlov. O pár minút '
          'neskôr príď kontajnerovej lode narazila do takmer stojacej jachty.',
          type: ColregNoteType.story,
        ),
        ColregHeading('Pravidlo lorda Scruttona (1933)'),
        ColregText(
          'Mali by ste byť schopní zastaviť na polovicu vzdialenosti, na '
          'ktorú dohliadnete. Toto pravidlo je len hrubým vodítkom – pri '
          'plachetniciach je dôležitejšie zachovať manévrovateľnosť než '
          'mechanicky zpomaliť.',
        ),
      ],
    ),
    ColregSection(
      id: 'fog_signals',
      title: 'Zvukové signály za zníženej viditeľnosti',
      blocks: [
        ColregText(
          'Pravidlo 35 podrobne určuje zvukové signály v hmle. Základné '
          'pravidlá pre plavidlá za plavby:',
        ),
        ColregList([
          'So strojným pohonom: 1× dlhý tón (5s) každé 2 minúty',
          'Zastavené so strojným pohonom: 2× dlhý tón každé 2 minúty',
          'Ostatné (plachetnice, rybárske lode, vlečné súpravy): 1 dlhý + '
              '2 krátke tóny (Morseovo D) každé 2 minúty',
          'Vlečené plavidlo (posledné v rade): 1 dlhý + 3 krátke tóny '
              '(Morseovo B) každé 2 minúty',
        ]),
        ColregHeading('Plavidlá na kotve alebo nasedlé'),
        ColregList([
          'Na kotve (< 100m): 5s zvonenie každú minútu',
          'Na kotve (> 100m): 5s zvonenie + 5s gong, každú minútu',
          'Nasedlé (< 100m): 3 údery na zvon pred a po zvonení, každú minútu',
          'Dobrovoľný signál pre kotvu: 1 krátky + 1 dlhý + 1 krátky tón '
              '(Morseovo R)',
        ]),
        ColregNote(
          'Plavidlá kratšie ako 12m nemusia mať zvon/gong, ale musia mať '
          'iný účinný zvukový signál v intervaloch kratších ako 2 minúty.',
          type: ColregNoteType.info,
        ),
      ],
    ),
  ],
);

// ── Kapitola 6: Svetlá a denné znaky ────────────────────────────

final _chapter6 = ColregSection(
  id: 'ch6',
  title: '6: Svetlá a denné znaky',
  blocks: [
    ColregText('Svetlá v COLREG slúžia trom účelom:'),
    ColregList([
      'Informujú o prítomnosti plavidla',
      'Informujú o smere plavby plavidla',
      'Informujú o statuse plavidla podľa COLREG',
    ], numbered: true),
    ColregText(
      'Denné znaky sú trojrozmerné geometrické tvary, ktoré sa vystavujú '
      'počas dňa namiesto svetiel.',
    ),
  ],
  children: [
    ColregSection(
      id: 'rule21',
      title: 'Pravidlo 21: Definície svetiel',
      ruleNumber: '21',
      blocks: [
        ColregList([
          '"Stožárové svetlo" – biele svetlo nad podlhovastou osou lode, '
              'viditeľné v oblúku 225°, od priameho smeru vpred do 22,5° '
              'za traversom na každej strane',
          '"Bočné svetlá" – zelené na pravoboku, červené na ľavoboku, '
              'viditeľné v oblúku 112,5° (od vpredu do 22,5° za traversom)',
          '"Záďové svetlo" – biele svetlo na zádi, viditeľné v oblúku 135°',
          '"Remorkérové svetlo" – žlté svetlo, rovnaké ako záďové',
          '"Všesmerné svetlo" – viditeľné v celom obzore (360°)',
        ]),
        ColregDiagram('light_sectors', 'Sektory bočných svetiel – zelené a červené'),
        ColregNote(
          'Zelené bočné svetlo = vy máte prednosť (plavidlo, ktorému sa '
          'uvoľňuje cesta). Červené bočné svetlo = vy musíte uvoľniť cestu. '
          'Toto je najdôležitejšia praktická skutočnosť celého COLREG!',
          type: ColregNoteType.danger,
        ),
        ColregDiagram('masthead_light', 'Stožárové (motorové) svetlo – pokrýva rovnaký sektor ako obe bočné'),
      ],
    ),
    ColregSection(
      id: 'lights_table',
      title: 'Kto vystavuje aké svetlá a znaky',
      blocks: [
        ColregHeading('Loď so strojným pohonom za plavby (Pravidlo 23)'),
        ColregDiagram('power_vessel_lights', 'Motorová loď – bočné, záďové a stožárové svetlo'),
        ColregText(
          'Plavidlá < 50m: 4 svetlá (zelené, červené, biele záďové, biele '
          'stožárové). Plavidlá > 50m: + druhé stožárové svetlo (vyššie '
          'a vzadu). Plavidlá < 20m môžu mať kombinované bočné svetlo. '
          'Plavidlá < 12m môžu mať len všesmerné biele + bočné svetlá.',
        ),
        ColregHeading('Plachetnica za plavby (Pravidlo 25)'),
        ColregDiagram('sailboat_lights', 'Plachetnica – bočné a záďové svetlo, žiadne stožárové'),
        ColregText(
          'Plachetnice < 20m môžu mať kombinované bočné svetlo na vrchole '
          'stožiara (trikolóra), alebo voliteľne dve všesmerné svetlá '
          '(červené nad zeleným) na vrchole stožiara navyše k bočným '
          'svetlám na úrovni paluby (nie však spoločne s trikolórou).',
        ),
        ColregNote(
          'Plachetnica plávajúca SÚČASNE pod plachtami a na motore '
          '(motorsailing) sa POVAŽUJE za loď so strojným pohonom! Musí '
          'vystavovať stožárové svetlo a vo dne čierny kužel vrcholom dole.',
          type: ColregNoteType.warning,
        ),
        ColregText(
          'Plachetnice a veslice < 7m: ak nemôžu nosiť riadne svetlá, musia '
          'mať aspoň pripravenú elektrickú baterku s bielym svetlom.',
        ),
        ColregHeading('Rybárske lode (Pravidlo 26)'),
        ColregDiagram('trawler_lights', 'Trauler – zelené nad bielym + bočné a záďové'),
        ColregDiagram('fishing_lights', 'Iný rybolov – červené nad bielym'),
        ColregText(
          'Trauler (vlečná sieť): zelené nad bielym všesmerným svetlom. '
          'Iný rybolov: červené nad bielym. Vo dne: dva čierne kužele '
          'vrcholmi k sobě.',
        ),
        ColregHeading('Neovládateľné a obmedzene manévrovateľné plavidlá (Pravidlo 27)'),
        ColregDiagram('not_under_command', 'Neovládateľné – dve červené svetlá'),
        ColregDiagram('restricted_maneuverability', 'Obmedzená manévrovateľnosť – červená-biela-červená'),
        ColregText(
          'Neovládateľné: 2× červené všesmerné svetlo vertikálne, 2 koule '
          'vo dne. Obmedzená manévrovateľnosť (bagrovanie, kábelovanie, '
          'doplňovanie zásob): červené-biele-červené, vo dne koule-'
          'kosočtverec-koule.',
        ),
        ColregHeading('Plavidlo obmedzené ponorom (Pravidlo 28)'),
        ColregDiagram('draft_constrained', '3× červené svetlo vertikálne, alebo valec vo dne'),
        ColregHeading('Zakotvené a nasedlé plavidlo (Pravidlo 30)'),
        ColregDiagram('anchored_vessel', 'Kotva – biele svetlo vpredu (vyššie) a vzadu (nižšie)'),
        ColregText(
          'Plavidlá < 50m môžu mať len jedno všesmerné biele svetlo. Vo '
          'dne: čierna koule vpredu (plavidlá > 7m). Nasedlé plavidlo: '
          'kotevné svetlá + 2× červené svetlo vertikálne + 3 koule vo dne.',
        ),
        ColregHeading('Vlečenie a tlačenie (Pravidlo 24)'),
        ColregDiagram('towing_lights', 'Vlečná súprava – dve/tri stožárové svetlá + žlté remorkérové'),
        ColregText(
          'Vlečná loď: 2 stožárové svetlá vertikálne (3 ak vlek > 200m) + '
          'žlté remorkérové svetlo nad záďovým. Vlečený objekt: bočné a '
          'záďové svetlo, žiadne stožárové. Vo dne (vlek > 200m): kosočtverec '
          'na vlečnej i poslednej vlečenej lodi.',
        ),
      ],
    ),
    ColregSection(
      id: 'visibility',
      title: 'Pravidlo 22: Viditeľnosť svetiel',
      ruleNumber: '22',
      blocks: [
        ColregText('Minimálna viditeľnosť svetiel podľa veľkosti lode:'),
        ColregList([
          'Lode ≥ 50m: stožárové 6 míľ, bočné/záďové 3 míle',
          'Lode 12–50m: stožárové 5 míľ (3 míle ak < 20m), bočné/záďové 2 míle',
          'Lode < 12m: stožárové 2 míle, bočné 1 míla, záďové 2 míle',
        ]),
        ColregNote(
          'Pre malé plachetnice je kriticky dôležité udržiavať svetlá '
          'funkčné: poškriabané sklo, slabá batéria, alebo náklon lode '
          'o viac ako 5° môžu výrazne znížiť viditeľnosť svetla – môžete '
          'byť prakticky neviditeľní až do chvíle, keď je už príliš neskoro.',
          type: ColregNoteType.warning,
        ),
        ColregNote(
          'Ouzo (2006): tri telá jachtárov boli vylovené pri Isle of Wight. '
          'Trajekt Pride of Bilbao sa pravdepodobne s 25-stopovou jachtou '
          'zrazil alebo ju prevrátil svojou vlnou. Jachta nebola viditeľná '
          'na radare trajektu, hoci mala radarový odražač.',
          type: ColregNoteType.story,
        ),
      ],
    ),
  ],
);

// ── Kapitola 7: Signály a kľúčové body (výtah) ──────────────────

final _chapter7 = ColregSection(
  id: 'ch7',
  title: '7: Manévrovacie signály a núdzové signály',
  blocks: [],
  children: [
    ColregSection(
      id: 'rule34',
      title: 'Pravidlo 34: Manévrovacie a výstražné signály',
      ruleNumber: '34',
      blocks: [
        ColregText('Vo vzájomnom dohľade, plavba so strojným pohonom:'),
        ColregList([
          '1× krátky tón = "Mením kurz vpravo"',
          '2× krátky tón = "Mením kurz vľavo"',
          '3× krátky tón = "Dávam zadný chod"',
          '5× (alebo viac) krátkych rýchlych tónov = "Nerozumiem vašim '
              'úmyslom / pochybujem o vašej akcii" (výstražný signál)',
          '1× dlhý tón = blížite sa k zákrute/skrytému miestu v kanáli',
        ]),
        ColregHeading('V úzkom kanáli pri predbiehaní'),
        ColregList([
          '2 dlhé + 1 krátky tón = "Zamýšľam vás predbehnúť po vašej '
              'pravej strane"',
          '2 dlhé + 2 krátke tóny = "Zamýšľam vás predbehnúť po vašej '
              'ľavej strane"',
          'Odpoveď súhlasu: 1 dlhý-1 krátky-1 dlhý-1 krátky tón (Morseovo C)',
        ]),
        ColregNote(
          'Krátky tón = cca 1 sekunda. Dlhý (predĺžený) tón = 4–6 sekúnd. '
          'Tieto signály môžu byť doplnené svetelnými zábleskami rovnakého '
          'významu (1, 2 alebo 3 záblesky).',
          type: ColregNoteType.info,
        ),
      ],
    ),
    ColregSection(
      id: 'emergency',
      title: 'Pravidlo 37 a Príloha IV: Núdzové signály',
      blocks: [
        ColregText(
          'Plavidlo v núdzi musí použiť alebo vystaviť tieto signály '
          '(samostatne alebo spoločne):',
        ),
        ColregList([
          'Rádiotelegrafický/iný signál SOS (...---...) v Morseovej abecede',
          'Rádiofónne vysielané slovo "Mayday"',
          'Raketa alebo granát s červenými hvězdami, jednotlivo v krátkych intervaloch',
          'Padáková raketa alebo ručná pochodeň s červeným svetlom',
          'Oranžový dymový signál',
          'Pomalé a opakované zvedanie a spúšťanie rozpažených paží',
          'Štvorcová vlajka s koulou (alebo podobným predmetom) nad/pod ňou',
          'Mezinárodný kódový signál N.C.',
          'Plamene na lodi (napr. horiaci sud s dehtom)',
          'Signály z núdzových rádiobójí (EPIRB) alebo SART transponderov',
        ]),
        ColregNote(
          'Zneužitie núdzových signálov pre iné účely je podľa COLREG '
          'zakázané a trestné.',
          type: ColregNoteType.danger,
        ),
      ],
    ),
    ColregSection(
      id: 'key_points',
      title: 'Kľúčové body – rýchly súhrn',
      blocks: [
        ColregList([
          'Držte hliadku pečlivo (Pravidlo 5)',
          'Dodržujte bezpečnú rýchlosť (Pravidlo 6)',
          'Systematicky hodnoťte riziko zrážky pomocou náměrov a radaru '
              '(Pravidlo 7)',
          'Úhybné manévre robte včas a výrazne (Pravidlo 8)',
        ], numbered: true),
        ColregHeading('Na otvorenom mori dajte prednosť (v tomto poradí zhora):'),
        ColregList([
          'plavidlu, ktoré predbiehate',
          'neovládateľnému plavidlu',
          'plavidlu s obmedzenou manévrovacou schopnosťou',
          'plavidlu obmedzenému ponorom',
          'plavidlu vykonávajúcemu rybolov',
          'plachetnici (ak ste motorová loď)',
        ]),
        ColregHeading('Pri stretnutí motorových lodí:'),
        ColregList([
          'Plávajúce proti sobě → obe odbočia DOPRAVA',
          'Krížiace sa trasy → loď s druhou loďou na PRAVOBOKU uvoľní cestu',
        ]),
        ColregHeading('Pri stretnutí plachetníc:'),
        ColregList([
          'Rôzny vietr → loď s vetrom z ĻAVOBOKU uvoľní cestu',
          'Rovnaký vietr → VETRNÁ loď uvoľní cestu ZÁVETRNEJ',
        ]),
        ColregHeading('V hmle:'),
        ColregList([
          'Vydávajte mlhový signál (1 dlhý tón/2min pre motor, Morseovo D '
              'pre plachetnicu)',
          'Spomaľte tak, aby ste počuli signály iných plavidiel',
          'Žiadne plavidlo "nemá prednosť" – platí len Pravidlo 19',
        ]),
        ColregHeading('V noci:'),
        ColregList([
          'Plachetnica: bočné + záďové svetlo',
          'Motorová loď < 50m: bočné + záďové + 1 stožárové svetlo',
          'Motorsailing = motorová loď (vypnite trikolóru, zapnite stožárové '
              'svetlo)',
        ]),
        ColregHeading('Pri uvoľňovaní cesty:'),
        ColregList([
          'Nepriechádzajte druhému plavidlu pred prídou',
          'Zmena kurzu je obvykle efektívnejšia ako zmena rýchlosti',
          'Zmena musí byť dostatočne výrazná, aby si jej druhé plavidlo všimlo',
        ]),
        ColregHeading('Pri udržiavaní kurzu (keď je vám uvoľňovaná cesta):'),
        ColregNote(
          'Pravidlo hovorí, že plavidlo, ktorému je uvoľňovaná cesta, '
          '"musí udržovať stabilný smer a rýchlosť... kým nie je zrejmé, '
          'že plavidlo uvoľňujúce cestu nekoná náležité kroky." Toto je '
          'POVINNÉ, nie dobrovoľné ani odporúčané.',
          type: ColregNoteType.danger,
        ),
      ],
    ),
  ],
);
