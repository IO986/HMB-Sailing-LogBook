/// Obsah z HMB príručky

class SafetyBriefingContent {
  static const List<BriefingSection> sections = [
    BriefingSection('1. Účel inštruktáže', [
      'Táto inštruktáž slúži na zabezpečenie bezpečnosti posádky a lode.',
      'Každý člen posádky je povinný venovať jej plnú pozornosť.',
    ]),
    BriefingSection('2. Základné pravidlá', [
      'Kapitán má vždy posledné slovo.',
      'Každý je zodpovedný za seba aj za ostatných, kapitán za všetko.',
      'Na palube sa pohybujeme opatrne a s rozvahou.',
      'Alkohol počas plavby je zakázaný.',
      'Voda a elektrina sú obmedzené zdroje – šetriť.',
    ]),
    BriefingSection('3. Záchranné vesty a bezpečnostné vybavenie', [
      'Každý má pridelenú záchrannú vestu a vie si ju správne obliecť.',
      'Kapitán určuje, kedy je nosenie vesty povinné.',
      'Posádka pozná umiestnenie MOB vybavenia a záchranného raftu.',
    ]),
    BriefingSection('4. Pohyb na palube', [
      'Platí pravidlo „jedna ruka pre seba, druhá pre loď".',
      'Pozor na rahno, laná a navijaky.',
      'Pohyb po palube po náveternom boku.',
      'Pri zhoršených podmienkach používať istenie.',
    ]),
    BriefingSection('5. Požiar a plyn', [
      'Každý vie, kde sú hasiace prístroje a protipožiarna deka.',
      'Pri úniku plynu: nič nezapínať ani nevypínať, nefajčiť, okamžite informovať kapitána.',
      'Veľký požiar = cieľom je únik, nie hasenie.',
      'Opustenie lode nariaďuje výhradne kapitán.',
    ]),
    BriefingSection('6. Motor, elektrina a voda', [
      'Posádka vie, ako sa motor štartuje a vypína.',
      'Pozná umiestnenie bilge púmp.',
      'Pri zatečení vody okamžite informovať kapitána.',
    ]),
    BriefingSection('7. Zdravotná bezpečnosť', [
      'Lekárnička je na známom mieste.',
      'Hlásiť úrazy, popáleniny, vyčerpanie alebo chlad.',
      'Alergie a zdravotné obmedzenia nahlásiť kapitánovi.',
    ]),
    BriefingSection('8. Muž cez palubu (MOB)', [
      'Najlepšia prevencia je nespadnúť do vody.',
      'Ak sa to stane: 1. Ukazovať  2. Kričať  3. Neustále sledovať osobu',
      'Stlačiť MOB tlačidlo.',
      'Záchranu riadi kapitán.',
    ]),
    BriefingSection('9. Lodná toaleta (Heads)', [
      'Lodná toaleta nie je domáce WC.',
      'Do toalety patrí len ľudský odpad a lodný/rýchlo rozložiteľný toaletný papier.',
      'ZAKÁZANÉ: vlhčené utierky, hygienické vložky, tampóny, papierové utierky.',
      'Po použití systém dostatočne prepláchnuť.',
      'Pri probléme okamžite informovať kapitána.',
    ]),
    BriefingSection('10. Komunikácia', [
      'Núdzový kanál VHF je 16.',
      'Mayday a DSC vykonáva kapitán alebo ním určená osoba, ale poznajú to všetci.',
    ]),
    BriefingSection('11. Záver', [
      'Každý člen posádky potvrdzuje, že inštruktáži rozumel.',
      'Otázky sú vítané pred vyplávaním.',
    ]),
  ];
}

class BriefingSection {
  final String title;
  final List<String> items;
  const BriefingSection(this.title, this.items);
}

// ── Výbava jednotlivca (editovateľná) ────────────────────────────

class IndividualGearContent {
  static const Map<String, List<String>> categories = {
    'Obuv': [
      'Pevná obuv (tenisky s protišmykovou podrážkou, najlepšie bledou)',
      'Sandále alebo šlapky (kroksy)',
    ],
    'Oblečenie': [
      'Čiapka (teplejšia + šiltovka)',
      'Spodné prádlo',
      'Funkčné prádlo',
      'Termoprádlo',
      'Teplá vrstva (fleece)',
      'Nepremokavé a vetruodolné oblečenie',
      'Tepláky',
      'Kraťasy',
      'Plavky',
      'Rukavice (najlepšie bez prstov – jachtárske/cyklistické)',
    ],
    'Hygiena': [
      'Uterák (ideálne 2×)',
      'Osobná hygiena (zubná kefka, pasta, sprchový gel)',
      'Vlhčené obrúsky',
      'Opaľovací krém (UV50) + panthenol',
      'Balzam na pery',
    ],
    'Ostatné': [
      'Slnečné okuliare + šnúrka',
      'Čelovka (s červeným svetlom)',
      'Power bank + nabíjačka',
      'Osobná lekárnička (osobné lieky, alergie, kinetóza...)',
      'Vodotesný obal na telefón',
    ],
    'Doklady': [
      'Pas alebo občiansky preukaz',
      'EU zdravotný preukaz',
      'Cestovné poistenie',
      '⚠️ Balenie do ruksakov/tašiek (najlepšie nepremokavých), NIE pevných kufrov!',
    ],
  };
}


// ── Yacht Handover Checklist ──────────────────────────────────

class YachtHandoverChecklist {
  static const Map<String, List<String>> checkIn = {
    'Elektrické vybavenie': [
      'Vypínače a ističe',
      'Kotvový naviják (ankerspill)',
      'Navigačné prístroje',
      'VHF rádio',
      'Indikátor stavu batérie',
      'Pozičné svetlá',
      'Autopilot',
      'Poistky',
      'Indikátor hladiny vody',
      'Náhradné žiarovky',
      'Lodný sonar (merač hĺbky)',
      'Čerpadlá (pumpy)',
    ],
    'Motor a palivo': [
      'Dotankovanie',
      'Napnutie V-remeňov',
      'Kontrola prívodu chladiacej vody',
      'Motorový olej',
      'Palivový filter',
      'Hladina paliva v nádrži',
      'Olej v prevodovke',
      'Hladina chladiacej kvapaliny',
      'Kontrola stavu palivovej nádrže a jej upevnenia',
    ],
    'Navigačné pomôcky a doklady': [
      'Papierové mapy a navigácia',
      'Povolenie na plavbu (sailing permit)',
      'Navigačné pomôcky',
      'Zoznam posádky (crew list)',
      'Ďalekohľad',
    ],
    'Trup lode': [
      'Paluba lode',
      'Prova lode',
      'Priestor pod palubovými doskami',
      'Záď lode',
      'Boky lode',
      'Podvodná časť trupu',
    ],
    'Bezpečnostné vybavenie': [
      'Záchranné vesty',
      'Hasiace prístroje',
      'Bezpečnostné postroje',
      'Svetlice',
    ],
    'Kuchyňa (Galley)': [
      'Chladnička',
      'Hlavný plynový uzáver',
      'Sporák a jeho upevnenie',
      'Plynové fľaše (2 ks)',
    ],
    'Kajuty': [
      'Posteľná bielizeň',
      'Úložné priestory',
    ],
    'Voda, WC a kúpeľne': [
      'Vodné nádrže',
      'WC (ventily)',
      'Čerpanie vody zo sprchovej vaničky',
      'Prepnutie odpadovej nádrže a vypustenie',
      'Zadná sprcha',
    ],
    'Plachty a kormidlovanie': [
      'Balenie a reefovanie plachiet – napnutie lán',
      'Stav halyárd (zdvíhacích lán)',
      'Kormidlo',
      'Stopéry',
      'Stav navíjacích zariadení (furling)',
      'Stav plachiet',
      'Winche',
      'Stav šotových lán',
    ],
    'Často zabudnuté': [
      'Bosunov rebrík na lezenie na sťažeň',
      'Náhradné V-remene pre hlavný motor',
      'Stav bosunového kresla',
      'Gumový impulzný kolektor pre čerpadlo slanej vody',
      'Stav zdvíhacieho lana',
      'Stav člna (dinghy)',
    ],
    'Rôzne': [
      'Náhradné kormidlo',
      'Vedro, kefa, špongia',
      'Háky na veslá člna',
      'Záchranný kruh alebo podkova',
      'Kotvové laná',
      'Ručná bilge pumpa',
      'Predlžovací elektrický kábel',
      'Záchranná bója so svetlom',
      'Záložná kotva',
      'Veslá a pumpa pre čln',
      'Shroud cutter (nôž na lanka)',
    ],
  };

  static const Map<String, List<String>> checkOut = {
    'Vrátenie jachty': [
      'Dotankovať nádrž',
      'Získať potvrdenie o odovzdaní jachty',
      'Prísť do mariny v dohodnutom čase',
      'Vrátiť zálohu',
      'Kontaktovať charterovú spoločnosť pri príchode do mariny',
    ],
    'Čistota a poriadok': [
      'Loď vyčistená – exteriér',
      'Loď vyčistená – interiér',
      'Kajuty upratané',
      'Kuchyňa vyčistená',
      'WC vyčistené',
      'Odpadky odstránené',
    ],
    'Technický stav': [
      'Palivo doplnené',
      'Voda doplnená',
      'Poškodenia zdokumentované a hlásené',
      'Plachty zložené a zviazané',
      'Laná upratané',
    ],
    'Odovzdanie': [
      'Kľúče odovzdané',
      'Doklady odovzdané',
      'Záchranné vesty vrátené',
    ],
  };
}
