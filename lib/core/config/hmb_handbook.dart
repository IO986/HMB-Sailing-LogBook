/// Obsah z HMB príručky — safety briefing a zoznam výbavy jednotlivca,
/// lokalizované do všetkých 5 jazykov appky. Referenčný odovzdávací
/// checklist žije v `features/charter/services/handover_checklist.dart`
/// (SK/EN definície zdieľané s interaktívnym protokolom).

class BriefingSection {
  final String title;
  final List<String> items;
  const BriefingSection(this.title, this.items);
}

class SafetyBriefingContent {
  static List<BriefingSection> sectionsFor(String locale) => switch (locale) {
        'en' => _en,
        'de' => _de,
        'es' => _es,
        'uk' => _uk,
        _ => _sk,
      };

  static const List<BriefingSection> _sk = [
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

  static const List<BriefingSection> _en = [
    BriefingSection('1. Purpose of the briefing', [
      'This briefing exists to keep the crew and the boat safe.',
      'Every crew member must give it their full attention.',
    ]),
    BriefingSection('2. Basic rules', [
      'The captain always has the final word.',
      'Everyone is responsible for themselves and the others; the captain for everything.',
      'Move around the deck carefully and deliberately.',
      'Alcohol is forbidden while under way.',
      'Water and electricity are limited resources – conserve them.',
    ]),
    BriefingSection('3. Life jackets and safety equipment', [
      'Everyone has an assigned life jacket and knows how to put it on correctly.',
      'The captain decides when wearing a life jacket is mandatory.',
      'The crew knows the location of the MOB equipment and the life raft.',
    ]),
    BriefingSection('4. Moving on deck', [
      'The rule is "one hand for yourself, one for the boat".',
      'Watch out for the boom, lines and winches.',
      'Move along the windward side of the deck.',
      'Use a harness in worsening conditions.',
    ]),
    BriefingSection('5. Fire and gas', [
      'Everyone knows where the fire extinguishers and fire blanket are.',
      'Gas leak: switch nothing on or off, no smoking, inform the captain immediately.',
      'Large fire = the goal is escape, not firefighting.',
      'Only the captain orders abandoning ship.',
    ]),
    BriefingSection('6. Engine, electricity and water', [
      'The crew knows how to start and stop the engine.',
      'Knows the location of the bilge pumps.',
      'Report water ingress to the captain immediately.',
    ]),
    BriefingSection('7. Health and first aid', [
      'The first-aid kit is in a known place.',
      'Report injuries, burns, exhaustion or hypothermia.',
      'Report allergies and medical conditions to the captain.',
    ]),
    BriefingSection('8. Man overboard (MOB)', [
      'The best prevention is not falling in.',
      'If it happens: 1. Point  2. Shout  3. Keep watching the person',
      'Press the MOB button.',
      'The captain directs the rescue.',
    ]),
    BriefingSection('9. Marine toilet (heads)', [
      'The marine toilet is not a household WC.',
      'Only human waste and marine/quick-dissolving toilet paper go in.',
      'FORBIDDEN: wet wipes, sanitary pads, tampons, paper towels.',
      'Flush the system thoroughly after use.',
      'Report any problem to the captain immediately.',
    ]),
    BriefingSection('10. Communication', [
      'The emergency VHF channel is 16.',
      'Mayday and DSC are handled by the captain or a designated person, but everyone knows the procedure.',
    ]),
    BriefingSection('11. Closing', [
      'Every crew member confirms they understood the briefing.',
      'Questions are welcome before departure.',
    ]),
  ];

  static const List<BriefingSection> _de = [
    BriefingSection('1. Zweck der Einweisung', [
      'Diese Einweisung dient der Sicherheit der Crew und des Schiffes.',
      'Jedes Crew-Mitglied muss ihr die volle Aufmerksamkeit widmen.',
    ]),
    BriefingSection('2. Grundregeln', [
      'Der Kapitän hat immer das letzte Wort.',
      'Jeder ist für sich und die anderen verantwortlich, der Kapitän für alles.',
      'An Deck bewegen wir uns vorsichtig und mit Bedacht.',
      'Alkohol während der Fahrt ist verboten.',
      'Wasser und Strom sind begrenzte Ressourcen – sparen.',
    ]),
    BriefingSection('3. Rettungswesten und Sicherheitsausrüstung', [
      'Jeder hat eine zugeteilte Rettungsweste und weiß, wie man sie richtig anlegt.',
      'Der Kapitän bestimmt, wann das Tragen der Weste Pflicht ist.',
      'Die Crew kennt den Ort der MOB-Ausrüstung und der Rettungsinsel.',
    ]),
    BriefingSection('4. Bewegung an Deck', [
      'Es gilt die Regel „eine Hand für dich, eine für das Schiff".',
      'Vorsicht vor Baum, Leinen und Winschen.',
      'An Deck auf der Luvseite bewegen.',
      'Bei schlechten Bedingungen Lifebelt benutzen.',
    ]),
    BriefingSection('5. Feuer und Gas', [
      'Jeder weiß, wo Feuerlöscher und Löschdecke sind.',
      'Bei Gasleck: nichts ein- oder ausschalten, nicht rauchen, sofort den Kapitän informieren.',
      'Großes Feuer = Ziel ist die Flucht, nicht das Löschen.',
      'Das Verlassen des Schiffes ordnet ausschließlich der Kapitän an.',
    ]),
    BriefingSection('6. Motor, Strom und Wasser', [
      'Die Crew weiß, wie der Motor gestartet und gestoppt wird.',
      'Kennt den Ort der Bilgepumpen.',
      'Bei Wassereinbruch sofort den Kapitän informieren.',
    ]),
    BriefingSection('7. Gesundheit', [
      'Der Erste-Hilfe-Kasten ist an einem bekannten Ort.',
      'Verletzungen, Verbrennungen, Erschöpfung oder Unterkühlung melden.',
      'Allergien und gesundheitliche Einschränkungen dem Kapitän melden.',
    ]),
    BriefingSection('8. Mann über Bord (MOB)', [
      'Die beste Vorbeugung ist, nicht ins Wasser zu fallen.',
      'Wenn es passiert: 1. Zeigen  2. Rufen  3. Die Person ständig im Blick behalten',
      'MOB-Taste drücken.',
      'Die Rettung leitet der Kapitän.',
    ]),
    BriefingSection('9. Bordtoilette (Heads)', [
      'Die Bordtoilette ist kein Haushalts-WC.',
      'Nur menschliche Abfälle und schnell zersetzliches Bord-Toilettenpapier gehören hinein.',
      'VERBOTEN: Feuchttücher, Damenbinden, Tampons, Papiertücher.',
      'Nach Benutzung das System gründlich durchspülen.',
      'Bei Problemen sofort den Kapitän informieren.',
    ]),
    BriefingSection('10. Kommunikation', [
      'Der Notrufkanal auf VHF ist 16.',
      'Mayday und DSC führt der Kapitän oder eine bestimmte Person aus, aber alle kennen das Verfahren.',
    ]),
    BriefingSection('11. Abschluss', [
      'Jedes Crew-Mitglied bestätigt, die Einweisung verstanden zu haben.',
      'Fragen sind vor dem Ablegen willkommen.',
    ]),
  ];

  static const List<BriefingSection> _es = [
    BriefingSection('1. Propósito del briefing', [
      'Este briefing sirve para garantizar la seguridad de la tripulación y del barco.',
      'Cada tripulante debe prestarle plena atención.',
    ]),
    BriefingSection('2. Reglas básicas', [
      'El capitán siempre tiene la última palabra.',
      'Cada uno es responsable de sí mismo y de los demás; el capitán, de todo.',
      'En cubierta nos movemos con cuidado y cabeza.',
      'El alcohol durante la navegación está prohibido.',
      'El agua y la electricidad son recursos limitados: hay que ahorrarlos.',
    ]),
    BriefingSection('3. Chalecos salvavidas y equipo de seguridad', [
      'Cada uno tiene un chaleco asignado y sabe ponérselo correctamente.',
      'El capitán decide cuándo es obligatorio llevar el chaleco.',
      'La tripulación conoce la ubicación del equipo MOB y de la balsa salvavidas.',
    ]),
    BriefingSection('4. Movimiento en cubierta', [
      'Rige la regla «una mano para ti, otra para el barco».',
      'Cuidado con la botavara, los cabos y los winches.',
      'Moverse por cubierta por el costado de barlovento.',
      'Con mal tiempo, usar arnés.',
    ]),
    BriefingSection('5. Fuego y gas', [
      'Todos saben dónde están los extintores y la manta ignífuga.',
      'Fuga de gas: no encender ni apagar nada, no fumar, avisar de inmediato al capitán.',
      'Fuego grande = el objetivo es escapar, no apagarlo.',
      'Solo el capitán ordena abandonar el barco.',
    ]),
    BriefingSection('6. Motor, electricidad y agua', [
      'La tripulación sabe cómo arrancar y apagar el motor.',
      'Conoce la ubicación de las bombas de achique.',
      'Ante una vía de agua, avisar de inmediato al capitán.',
    ]),
    BriefingSection('7. Salud', [
      'El botiquín está en un lugar conocido.',
      'Informar de heridas, quemaduras, agotamiento o frío.',
      'Comunicar alergias y limitaciones médicas al capitán.',
    ]),
    BriefingSection('8. Hombre al agua (MOB)', [
      'La mejor prevención es no caer al agua.',
      'Si ocurre: 1. Señalar  2. Gritar  3. No perder de vista a la persona',
      'Pulsar el botón MOB.',
      'El rescate lo dirige el capitán.',
    ]),
    BriefingSection('9. Inodoro marino (heads)', [
      'El inodoro marino no es un WC doméstico.',
      'Solo admite residuos humanos y papel higiénico marino de rápida disolución.',
      'PROHIBIDO: toallitas húmedas, compresas, tampones, papel de cocina.',
      'Después de usarlo, enjuagar bien el sistema.',
      'Ante cualquier problema, avisar de inmediato al capitán.',
    ]),
    BriefingSection('10. Comunicación', [
      'El canal VHF de emergencia es el 16.',
      'El Mayday y el DSC los realiza el capitán o la persona designada, pero todos conocen el procedimiento.',
    ]),
    BriefingSection('11. Cierre', [
      'Cada tripulante confirma que ha entendido el briefing.',
      'Las preguntas son bienvenidas antes de zarpar.',
    ]),
  ];

  static const List<BriefingSection> _uk = [
    BriefingSection('1. Мета інструктажу', [
      'Цей інструктаж забезпечує безпеку екіпажу та судна.',
      'Кожен член екіпажу зобов\'язаний приділити йому повну увагу.',
    ]),
    BriefingSection('2. Основні правила', [
      'Останнє слово завжди за капітаном.',
      'Кожен відповідає за себе і за інших, капітан — за все.',
      'На палубі рухаємось обережно та розважливо.',
      'Алкоголь під час плавання заборонений.',
      'Вода та електрика — обмежені ресурси, заощаджуй.',
    ]),
    BriefingSection('3. Рятувальні жилети та засоби безпеки', [
      'У кожного є призначений рятувальний жилет і кожен вміє його правильно одягнути.',
      'Капітан визначає, коли носіння жилета обов\'язкове.',
      'Екіпаж знає розташування MOB-обладнання та рятувального плота.',
    ]),
    BriefingSection('4. Пересування палубою', [
      'Діє правило «одна рука для себе, друга для судна».',
      'Обережно з гіком, тросами та лебідками.',
      'Пересувайся палубою з навітряного борту.',
      'У складних умовах використовуй страховку.',
    ]),
    BriefingSection('5. Пожежа і газ', [
      'Кожен знає, де вогнегасники та протипожежна ковдра.',
      'Витік газу: нічого не вмикати й не вимикати, не палити, негайно повідомити капітана.',
      'Велика пожежа = мета — евакуація, не гасіння.',
      'Наказ покинути судно віддає виключно капітан.',
    ]),
    BriefingSection('6. Двигун, електрика і вода', [
      'Екіпаж знає, як запустити та вимкнути двигун.',
      'Знає розташування трюмних помп.',
      'При надходженні води негайно повідомити капітана.',
    ]),
    BriefingSection('7. Здоров\'я', [
      'Аптечка у відомому місці.',
      'Повідомляй про травми, опіки, виснаження чи переохолодження.',
      'Про алергії та медичні обмеження повідом капітана.',
    ]),
    BriefingSection('8. Людина за бортом (MOB)', [
      'Найкраща профілактика — не впасти у воду.',
      'Якщо сталося: 1. Вказуй  2. Кричи  3. Постійно стеж за людиною',
      'Натисни кнопку MOB.',
      'Рятуванням керує капітан.',
    ]),
    BriefingSection('9. Суднові туалети (heads)', [
      'Судновий туалет — не домашній WC.',
      'Туди належать лише людські відходи та судновий/швидкорозчинний туалетний папір.',
      'ЗАБОРОНЕНО: вологі серветки, гігієнічні прокладки, тампони, паперові рушники.',
      'Після використання ретельно промий систему.',
      'При проблемі негайно повідом капітана.',
    ]),
    BriefingSection('10. Зв\'язок', [
      'Аварійний канал VHF — 16.',
      'Mayday і DSC виконує капітан або призначена ним особа, але процедуру знають усі.',
    ]),
    BriefingSection('11. Завершення', [
      'Кожен член екіпажу підтверджує, що зрозумів інструктаж.',
      'Питання вітаються до відплиття.',
    ]),
  ];
}

// ── Výbava jednotlivca (editovateľná) ────────────────────────────

class IndividualGearContent {
  static Map<String, List<String>> categoriesFor(String locale) =>
      switch (locale) {
        'en' => _en,
        'de' => _de,
        'es' => _es,
        'uk' => _uk,
        _ => _sk,
      };

  static const Map<String, List<String>> _sk = {
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

  static const Map<String, List<String>> _en = {
    'Footwear': [
      'Sturdy shoes (trainers with non-slip soles, ideally light-coloured)',
      'Sandals or flip-flops (crocs)',
    ],
    'Clothing': [
      'Hat (warm one + cap)',
      'Underwear',
      'Base layers',
      'Thermal underwear',
      'Warm layer (fleece)',
      'Waterproof and windproof clothing',
      'Sweatpants',
      'Shorts',
      'Swimwear',
      'Gloves (ideally fingerless – sailing/cycling)',
    ],
    'Hygiene': [
      'Towel (ideally 2×)',
      'Personal hygiene (toothbrush, toothpaste, shower gel)',
      'Wet wipes',
      'Sunscreen (UV50) + panthenol',
      'Lip balm',
    ],
    'Other': [
      'Sunglasses + strap',
      'Headlamp (with red light)',
      'Power bank + charger',
      'Personal first-aid kit (own medication, allergies, motion sickness...)',
      'Waterproof phone case',
    ],
    'Documents': [
      'Passport or ID card',
      'EU health insurance card',
      'Travel insurance',
      '⚠️ Pack in backpacks/soft bags (ideally waterproof), NOT hard suitcases!',
    ],
  };

  static const Map<String, List<String>> _de = {
    'Schuhe': [
      'Festes Schuhwerk (Turnschuhe mit rutschfester, am besten heller Sohle)',
      'Sandalen oder Badelatschen (Crocs)',
    ],
    'Kleidung': [
      'Mütze (warme + Schirmmütze)',
      'Unterwäsche',
      'Funktionswäsche',
      'Thermounterwäsche',
      'Warme Schicht (Fleece)',
      'Wasser- und winddichte Kleidung',
      'Jogginghose',
      'Shorts',
      'Badesachen',
      'Handschuhe (am besten fingerlos – Segel-/Radhandschuhe)',
    ],
    'Hygiene': [
      'Handtuch (ideal 2×)',
      'Körperpflege (Zahnbürste, Zahnpasta, Duschgel)',
      'Feuchttücher',
      'Sonnencreme (UV50) + Panthenol',
      'Lippenbalsam',
    ],
    'Sonstiges': [
      'Sonnenbrille + Band',
      'Stirnlampe (mit Rotlicht)',
      'Powerbank + Ladegerät',
      'Persönliche Reiseapotheke (eigene Medikamente, Allergien, Reisekrankheit...)',
      'Wasserdichte Handyhülle',
    ],
    'Dokumente': [
      'Reisepass oder Personalausweis',
      'EU-Krankenversicherungskarte',
      'Reiseversicherung',
      '⚠️ In Rucksäcke/weiche Taschen packen (am besten wasserdicht), KEINE Hartschalenkoffer!',
    ],
  };

  static const Map<String, List<String>> _es = {
    'Calzado': [
      'Calzado firme (zapatillas con suela antideslizante, mejor clara)',
      'Sandalias o chanclas (crocs)',
    ],
    'Ropa': [
      'Gorro (uno cálido + gorra)',
      'Ropa interior',
      'Ropa técnica',
      'Ropa térmica',
      'Capa de abrigo (forro polar)',
      'Ropa impermeable y cortavientos',
      'Pantalón de chándal',
      'Pantalones cortos',
      'Bañador',
      'Guantes (mejor sin dedos – de vela/ciclismo)',
    ],
    'Higiene': [
      'Toalla (idealmente 2×)',
      'Higiene personal (cepillo y pasta de dientes, gel de ducha)',
      'Toallitas húmedas',
      'Crema solar (UV50) + pantenol',
      'Bálsamo labial',
    ],
    'Otros': [
      'Gafas de sol + cordón',
      'Frontal (con luz roja)',
      'Power bank + cargador',
      'Botiquín personal (medicación propia, alergias, mareo...)',
      'Funda impermeable para el móvil',
    ],
    'Documentos': [
      'Pasaporte o DNI',
      'Tarjeta sanitaria europea',
      'Seguro de viaje',
      '⚠️ Equipaje en mochilas/bolsas (mejor impermeables), ¡NO maletas rígidas!',
    ],
  };

  static const Map<String, List<String>> _uk = {
    'Взуття': [
      'Міцне взуття (кросівки з неслизькою підошвою, найкраще світлою)',
      'Сандалі або шльопанці (крокси)',
    ],
    'Одяг': [
      'Шапка (тепла + кепка)',
      'Спідня білизна',
      'Функціональна білизна',
      'Термобілизна',
      'Теплий шар (фліс)',
      'Водо- та вітронепроникний одяг',
      'Спортивні штани',
      'Шорти',
      'Купальний одяг',
      'Рукавиці (найкраще безпалі – яхтові/велосипедні)',
    ],
    'Гігієна': [
      'Рушник (в ідеалі 2×)',
      'Особиста гігієна (зубна щітка, паста, гель для душу)',
      'Вологі серветки',
      'Сонцезахисний крем (UV50) + пантенол',
      'Бальзам для губ',
    ],
    'Інше': [
      'Сонцезахисні окуляри + шнурок',
      'Налобний ліхтар (з червоним світлом)',
      'Павербанк + зарядка',
      'Особиста аптечка (власні ліки, алергії, заколисування...)',
      'Водонепроникний чохол для телефона',
    ],
    'Документи': [
      'Паспорт або ID-картка',
      'Європейська картка медичного страхування',
      'Туристичне страхування',
      '⚠️ Пакуй у рюкзаки/сумки (найкраще водонепроникні), НЕ в тверді валізи!',
    ],
  };
}
