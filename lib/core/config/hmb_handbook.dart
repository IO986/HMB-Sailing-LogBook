/// Obsah z HMB príručky — safety briefing a zoznam výbavy jednotlivca,
/// lokalizované do všetkých jazykov appky. Referenčný odovzdávací
/// checklist žije v `features/charter/services/handover_checklist.dart`
/// (SK/EN definície zdieľané s interaktívnym protokolom).

class BriefingSection {
  final String title;
  final List<String> items;
  const BriefingSection(this.title, this.items);
}

/// Koľko zaškrtávacích bodov má brífing v danom jazyku.
///
/// Vlastné body skipera idú za príručkovými, takže ich index začína práve tu.
int briefingPointCount(List<BriefingSection> sections) =>
    sections.fold(0, (sum, s) => sum + s.items.length);

class SafetyBriefingContent {
  static List<BriefingSection> sectionsFor(String locale) => switch (locale) {
        'en' => _en,
        'de' => _de,
        'es' => _es,
        'uk' => _uk,
        'cs' => _cs,
        'pl' => _pl,
        'el' => _el,
        'hr' => _hr,
        'sl' => _sl,
        'it' => _it,
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

  static const List<BriefingSection> _cs = [
    BriefingSection('1. Účel instruktáže', [
      'Tato instruktáž slouží k zajištění bezpečnosti posádky a lodi.',
      'Každý člen posádky jí musí věnovat plnou pozornost.',
    ]),
    BriefingSection('2. Základní pravidla', [
      'Kapitán má vždy poslední slovo.',
      'Každý je zodpovědný za sebe i za ostatní; kapitán za všechno.',
      'Po palubě se pohybujeme opatrně a s rozvahou.',
      'Alkohol během plavby je zakázán.',
      'Voda a elektřina jsou omezené zdroje – šetřete jimi.',
    ]),
    BriefingSection('3. Záchranné vesty a bezpečnostní vybavení', [
      'Každý má přidělenou záchrannou vestu a umí si ji správně obléknout.',
      'Kapitán určuje, kdy je nošení vesty povinné.',
      'Posádka zná umístění MOB vybavení a záchranného raftu.',
    ]),
    BriefingSection('4. Pohyb na palubě', [
      'Platí pravidlo „jedna ruka pro sebe, druhá pro loď".',
      'Pozor na ráhno, lana a navijáky.',
      'Po palubě se pohybujte po návětrné straně.',
      'Při zhoršených podmínkách používejte jištění.',
    ]),
    BriefingSection('5. Požár a plyn', [
      'Každý ví, kde jsou hasicí přístroje a hasicí deka.',
      'Únik plynu: nic nezapínat ani nevypínat, nekouřit, okamžitě informovat kapitána.',
      'Velký požár = cílem je únik, ne hašení.',
      'Opuštění lodi nařizuje výhradně kapitán.',
    ]),
    BriefingSection('6. Motor, elektřina a voda', [
      'Posádka ví, jak se motor startuje a vypíná.',
      'Zná umístění bilžních čerpadel.',
      'Při zatékání vody okamžitě informujte kapitána.',
    ]),
    BriefingSection('7. Zdraví a první pomoc', [
      'Lékárnička je na známém místě.',
      'Hlaste úrazy, popáleniny, vyčerpání nebo podchlazení.',
      'Alergie a zdravotní omezení nahlaste kapitánovi.',
    ]),
    BriefingSection('8. Muž přes palubu (MOB)', [
      'Nejlepší prevence je nespadnout do vody.',
      'Pokud se to stane: 1. Ukazovat  2. Křičet  3. Neustále sledovat osobu',
      'Stiskněte tlačítko MOB.',
      'Záchranu řídí kapitán.',
    ]),
    BriefingSection('9. Lodní toaleta (Heads)', [
      'Lodní toaleta není domácí WC.',
      'Do toalety patří jen lidský odpad a lodní/rychle rozložitelný toaletní papír.',
      'ZAKÁZÁNO: vlhčené ubrousky, hygienické vložky, tampony, papírové utěrky.',
      'Po použití systém důkladně propláchněte.',
      'Jakýkoli problém okamžitě hlaste kapitánovi.',
    ]),
    BriefingSection('10. Komunikace', [
      'Nouzový kanál VHF je 16.',
      'Mayday a DSC provádí kapitán nebo určená osoba, ale postup zná každý.',
    ]),
    BriefingSection('11. Závěr', [
      'Každý člen posádky potvrdí, že instruktáži porozuměl.',
      'Dotazy jsou před odplutím vítány.',
    ]),
  ];

  static const List<BriefingSection> _pl = [
    BriefingSection('1. Cel odprawy', [
      'Ta odprawa służy zapewnieniu bezpieczeństwa załogi i jachtu.',
      'Każdy członek załogi musi poświęcić jej pełną uwagę.',
    ]),
    BriefingSection('2. Podstawowe zasady', [
      'Kapitan zawsze ma ostatnie słowo.',
      'Każdy odpowiada za siebie i za innych; kapitan za wszystko.',
      'Po pokładzie poruszamy się ostrożnie i z rozwagą.',
      'Alkohol podczas rejsu jest zabroniony.',
      'Woda i prąd to ograniczone zasoby – oszczędzaj je.',
    ]),
    BriefingSection('3. Kamizelki ratunkowe i sprzęt bezpieczeństwa', [
      'Każdy ma przydzieloną kamizelkę i potrafi ją poprawnie założyć.',
      'Kapitan decyduje, kiedy noszenie kamizelki jest obowiązkowe.',
      'Załoga zna umiejscowienie sprzętu MOB i tratwy ratunkowej.',
    ]),
    BriefingSection('4. Poruszanie się po pokładzie', [
      'Obowiązuje zasada „jedna ręka dla siebie, druga dla jachtu".',
      'Uważaj na bom, liny i winsze.',
      'Poruszaj się po nawietrznej stronie pokładu.',
      'W pogarszających się warunkach używaj asekuracji.',
    ]),
    BriefingSection('5. Pożar i gaz', [
      'Każdy wie, gdzie są gaśnice i koc gaśniczy.',
      'Wyciek gazu: niczego nie włączać ani wyłączać, nie palić, natychmiast poinformować kapitana.',
      'Duży pożar = celem jest ucieczka, nie gaszenie.',
      'Opuszczenie jachtu zarządza wyłącznie kapitan.',
    ]),
    BriefingSection('6. Silnik, prąd i woda', [
      'Załoga wie, jak uruchomić i wyłączyć silnik.',
      'Zna umiejscowienie pomp zęzowych.',
      'Przy przecieku wody natychmiast poinformuj kapitana.',
    ]),
    BriefingSection('7. Zdrowie i pierwsza pomoc', [
      'Apteczka jest w znanym miejscu.',
      'Zgłaszaj urazy, oparzenia, wyczerpanie lub wychłodzenie.',
      'Alergie i ograniczenia zdrowotne zgłoś kapitanowi.',
    ]),
    BriefingSection('8. Człowiek za burtą (MOB)', [
      'Najlepszą prewencją jest nie wpaść do wody.',
      'Jeśli się to stanie: 1. Wskazuj  2. Krzycz  3. Nieustannie obserwuj osobę',
      'Naciśnij przycisk MOB.',
      'Akcją ratunkową kieruje kapitan.',
    ]),
    BriefingSection('9. Toaleta jachtowa (Heads)', [
      'Toaleta jachtowa to nie domowe WC.',
      'Do toalety trafia tylko ludzki odpad i jachtowy/szybko rozkładalny papier toaletowy.',
      'ZABRONIONE: nawilżane chusteczki, podpaski, tampony, ręczniki papierowe.',
      'Po użyciu dokładnie przepłucz system.',
      'Każdy problem natychmiast zgłoś kapitanowi.',
    ]),
    BriefingSection('10. Łączność', [
      'Awaryjny kanał VHF to 16.',
      'Mayday i DSC obsługuje kapitan lub wyznaczona osoba, ale procedurę zna każdy.',
    ]),
    BriefingSection('11. Zakończenie', [
      'Każdy członek załogi potwierdza, że zrozumiał odprawę.',
      'Pytania przed wypłynięciem są mile widziane.',
    ]),
  ];

  static const List<BriefingSection> _el = [
    BriefingSection('1. Σκοπός της ενημέρωσης', [
      'Αυτή η ενημέρωση υπάρχει για την ασφάλεια του πληρώματος και του σκάφους.',
      'Κάθε μέλος του πληρώματος πρέπει να της δώσει πλήρη προσοχή.',
    ]),
    BriefingSection('2. Βασικοί κανόνες', [
      'Ο κυβερνήτης έχει πάντα τον τελευταίο λόγο.',
      'Ο καθένας είναι υπεύθυνος για τον εαυτό του και τους άλλους· ο κυβερνήτης για τα πάντα.',
      'Κινούμαστε στο κατάστρωμα προσεκτικά και με σύνεση.',
      'Το αλκοόλ κατά τον πλου απαγορεύεται.',
      'Το νερό και το ρεύμα είναι περιορισμένοι πόροι – εξοικονομήστε τα.',
    ]),
    BriefingSection('3. Σωσίβια και εξοπλισμός ασφαλείας', [
      'Ο καθένας έχει ένα σωσίβιο και ξέρει να το φορά σωστά.',
      'Ο κυβερνήτης αποφασίζει πότε είναι υποχρεωτικό το σωσίβιο.',
      'Το πλήρωμα γνωρίζει τη θέση του εξοπλισμού MOB και της σωσίβιας σχεδίας.',
    ]),
    BriefingSection('4. Μετακίνηση στο κατάστρωμα', [
      'Ισχύει ο κανόνας «ένα χέρι για εσένα, ένα για το σκάφος».',
      'Προσοχή στη ματσούκα, τα σχοινιά και τα βίντσια.',
      'Κινηθείτε στην προσήνεμη πλευρά του καταστρώματος.',
      'Σε δυσμενείς συνθήκες χρησιμοποιήστε ζώνη ασφαλείας.',
    ]),
    BriefingSection('5. Φωτιά και αέριο', [
      'Ο καθένας ξέρει πού είναι οι πυροσβεστήρες και η πυρίμαχη κουβέρτα.',
      'Διαρροή αερίου: μην ανοίγετε/κλείνετε τίποτε, μην καπνίζετε, ενημερώστε αμέσως τον κυβερνήτη.',
      'Μεγάλη φωτιά = στόχος είναι η διαφυγή, όχι η κατάσβεση.',
      'Την εγκατάλειψη του σκάφους τη διατάζει αποκλειστικά ο κυβερνήτης.',
    ]),
    BriefingSection('6. Μηχανή, ρεύμα και νερό', [
      'Το πλήρωμα ξέρει πώς ξεκινά και σταματά η μηχανή.',
      'Γνωρίζει τη θέση των αντλιών σεντίνας.',
      'Σε εισροή νερού ενημερώστε αμέσως τον κυβερνήτη.',
    ]),
    BriefingSection('7. Υγεία και πρώτες βοήθειες', [
      'Το κιτ πρώτων βοηθειών βρίσκεται σε γνωστό σημείο.',
      'Αναφέρετε τραυματισμούς, εγκαύματα, εξάντληση ή υποθερμία.',
      'Αναφέρετε αλλεργίες και ιατρικά προβλήματα στον κυβερνήτη.',
    ]),
    BriefingSection('8. Άνθρωπος στη θάλασσα (MOB)', [
      'Η καλύτερη πρόληψη είναι να μην πέσετε στο νερό.',
      'Αν συμβεί: 1. Δείχνετε  2. Φωνάζετε  3. Παρακολουθείτε συνεχώς το άτομο',
      'Πατήστε το κουμπί MOB.',
      'Τη διάσωση τη διευθύνει ο κυβερνήτης.',
    ]),
    BriefingSection('9. Τουαλέτα σκάφους (Heads)', [
      'Η τουαλέτα του σκάφους δεν είναι οικιακό WC.',
      'Μέσα πάει μόνο ανθρώπινο απόβλητο και ναυτικό/γρήγορα διαλυόμενο χαρτί υγείας.',
      'ΑΠΑΓΟΡΕΥΟΝΤΑΙ: υγρά μαντηλάκια, σερβιέτες, ταμπόν, χαρτί κουζίνας.',
      'Μετά τη χρήση ξεπλύνετε καλά το σύστημα.',
      'Κάθε πρόβλημα αναφέρετέ το αμέσως στον κυβερνήτη.',
    ]),
    BriefingSection('10. Επικοινωνία', [
      'Το κανάλι έκτακτης ανάγκης VHF είναι το 16.',
      'Το Mayday και το DSC τα χειρίζεται ο κυβερνήτης ή ορισμένο άτομο, αλλά όλοι γνωρίζουν τη διαδικασία.',
    ]),
    BriefingSection('11. Κλείσιμο', [
      'Κάθε μέλος του πληρώματος επιβεβαιώνει ότι κατάλαβε την ενημέρωση.',
      'Ερωτήσεις είναι ευπρόσδεκτες πριν τον απόπλου.',
    ]),
  ];

  static const List<BriefingSection> _hr = [
    BriefingSection('1. Svrha instruktaže', [
      'Ova instruktaža postoji radi sigurnosti posade i broda.',
      'Svaki član posade dužan joj je posvetiti punu pozornost.',
    ]),
    BriefingSection('2. Osnovna pravila', [
      'Zapovjednik uvijek ima zadnju riječ.',
      'Svatko je odgovoran za sebe i za ostale, a zapovjednik za sve.',
      'Po palubi se krećemo oprezno i promišljeno.',
      'Alkohol je tijekom plovidbe zabranjen.',
      'Voda i struja ograničeni su resursi – štedite ih.',
    ]),
    BriefingSection('3. Prsluci za spašavanje i sigurnosna oprema', [
      'Svatko ima dodijeljen prsluk za spašavanje i zna ga pravilno obući.',
      'Zapovjednik određuje kada je nošenje prsluka obvezno.',
      'Posada zna gdje se nalazi MOB oprema i splav za spašavanje.',
    ]),
    BriefingSection('4. Kretanje po palubi', [
      'Vrijedi pravilo "jedna ruka za sebe, jedna za brod".',
      'Pazite na bum, konope i vinčeve.',
      'Krećite se privjetrinskom stranom palube.',
      'U pogoršanim uvjetima koristite sigurnosni pojas.',
    ]),
    BriefingSection('5. Požar i plin', [
      'Svatko zna gdje su vatrogasni aparati i protupožarna deka.',
      'Curenje plina: ništa ne uključujte ni isključujte, ne pušite, odmah obavijestite zapovjednika.',
      'Veliki požar = cilj je bijeg, a ne gašenje.',
      'Napuštanje broda naređuje isključivo zapovjednik.',
    ]),
    BriefingSection('6. Motor, struja i voda', [
      'Posada zna kako pokrenuti i zaustaviti motor.',
      'Zna gdje se nalaze kaljužne pumpe.',
      'Prodor vode odmah prijavite zapovjedniku.',
    ]),
    BriefingSection('7. Zdravlje i prva pomoć', [
      'Kutija prve pomoći nalazi se na poznatom mjestu.',
      'Prijavite ozljede, opekline, iscrpljenost ili pothlađenost.',
      'Alergije i zdravstvene tegobe prijavite zapovjedniku.',
    ]),
    BriefingSection('8. Čovjek u moru (MOB)', [
      'Najbolja prevencija je ne pasti u more.',
      'Ako se dogodi: 1. Pokazujte  2. Vičite  3. Neprekidno promatrajte osobu',
      'Pritisnite MOB tipku.',
      'Spašavanjem upravlja zapovjednik.',
    ]),
    BriefingSection('9. Brodski toalet (heads)', [
      'Brodski toalet nije kućni WC.',
      'Unutra ide samo ljudski otpad i brodski/brzo razgradivi toaletni papir.',
      'ZABRANJENO: vlažne maramice, higijenski ulošci, tamponi, papirnati ručnici.',
      'Nakon uporabe temeljito isperite sustav.',
      'Svaki problem odmah prijavite zapovjedniku.',
    ]),
    BriefingSection('10. Komunikacija', [
      'Kanal za pogibelj na VHF-u je 16.',
      'Mayday i DSC obavlja zapovjednik ili određena osoba, ali svi znaju postupak.',
    ]),
    BriefingSection('11. Zaključak', [
      'Svaki član posade potvrđuje da je razumio instruktažu.',
      'Pitanja prije isplovljenja su dobrodošla.',
    ]),
  ];

  static const List<BriefingSection> _sl = [
    BriefingSection('1. Namen brifinga', [
      'Ta brifing je namenjen varnosti posadke in plovila.',
      'Vsak član posadke mu mora nameniti polno pozornost.',
    ]),
    BriefingSection('2. Osnovna pravila', [
      'Poveljnik ima vedno zadnjo besedo.',
      'Vsak je odgovoren zase in za druge, poveljnik pa za vse.',
      'Po krovu se gibljemo previdno in premišljeno.',
      'Alkohol med plovbo je prepovedan.',
      'Voda in elektrika sta omejena vira – varčujte z njima.',
    ]),
    BriefingSection('3. Rešilni jopiči in varnostna oprema', [
      'Vsak ima dodeljen rešilni jopič in ga zna pravilno obleči.',
      'Poveljnik določi, kdaj je nošenje jopiča obvezno.',
      'Posadka ve, kje sta oprema MOB in rešilni splav.',
    ]),
    BriefingSection('4. Gibanje po krovu', [
      'Velja pravilo "ena roka zase, ena za plovilo".',
      'Pazite na bum, vrvi in vinče.',
      'Gibljite se po privetrni strani krova.',
      'V slabšajočih se razmerah uporabite varnostni pas.',
    ]),
    BriefingSection('5. Požar in plin', [
      'Vsak ve, kje so gasilni aparati in protipožarna odeja.',
      'Uhajanje plina: ničesar ne vklapljajte ali izklapljajte, ne kadite, takoj obvestite poveljnika.',
      'Velik požar = cilj je pobeg, ne gašenje.',
      'Zapustitev plovila odredi izključno poveljnik.',
    ]),
    BriefingSection('6. Motor, elektrika in voda', [
      'Posadka zna zagnati in ustaviti motor.',
      'Ve, kje so kalužne črpalke.',
      'Vdor vode takoj javite poveljniku.',
    ]),
    BriefingSection('7. Zdravje in prva pomoč', [
      'Komplet prve pomoči je na znanem mestu.',
      'Prijavite poškodbe, opekline, izčrpanost ali podhladitev.',
      'Alergije in zdravstvene težave sporočite poveljniku.',
    ]),
    BriefingSection('8. Človek v morju (MOB)', [
      'Najboljše preprečevanje je, da ne padete v morje.',
      'Če se zgodi: 1. Kažite  2. Kričite  3. Neprekinjeno opazujte osebo',
      'Pritisnite gumb MOB.',
      'Reševanje vodi poveljnik.',
    ]),
    BriefingSection('9. Ladijsko stranišče (heads)', [
      'Ladijsko stranišče ni domači WC.',
      'Notri sodijo samo človeški iztrebki in ladijski/hitro razgradljivi toaletni papir.',
      'PREPOVEDANO: vlažni robčki, higienski vložki, tamponi, papirnate brisače.',
      'Po uporabi sistem temeljito izperite.',
      'Vsako težavo takoj javite poveljniku.',
    ]),
    BriefingSection('10. Komunikacija', [
      'Kanal za klic v sili na VHF je 16.',
      'Mayday in DSC opravi poveljnik ali določena oseba, vendar postopek poznajo vsi.',
    ]),
    BriefingSection('11. Zaključek', [
      'Vsak član posadke potrdi, da je brifing razumel.',
      'Vprašanja pred izplutjem so dobrodošla.',
    ]),
  ];

  static const List<BriefingSection> _it = [
    BriefingSection('1. Scopo del briefing', [
      "Questo briefing serve a garantire la sicurezza dell'equipaggio e della barca.",
      "Ogni membro dell'equipaggio è tenuto a prestarvi piena attenzione.",
    ]),
    BriefingSection('2. Regole di base', [
      "Il comandante ha sempre l'ultima parola.",
      'Ognuno è responsabile di sé e degli altri, il comandante di tutto.',
      'Sulla coperta ci si muove con prudenza e ponderatezza.',
      "L'alcol durante la navigazione è vietato.",
      "L'acqua e l'elettricità sono risorse limitate – risparmiatele.",
    ]),
    BriefingSection('3. Giubbotti di salvataggio e dotazioni di sicurezza', [
      'A ciascuno è assegnato un giubbotto di salvataggio e sa indossarlo correttamente.',
      'Il comandante decide quando indossare il giubbotto è obbligatorio.',
      "L'equipaggio sa dove si trovano le dotazioni MOB e la zattera di salvataggio.",
    ]),
    BriefingSection('4. Spostarsi in coperta', [
      'Vale la regola "una mano per sé, una per la barca".',
      'Attenzione al boma, alle cime e ai winch.',
      'Muoversi lungo il lato sopravvento della coperta.',
      'Con condizioni in peggioramento usare la cintura di sicurezza.',
    ]),
    BriefingSection('5. Incendio e gas', [
      'Tutti sanno dove sono gli estintori e la coperta antincendio.',
      'Fuga di gas: non accendere né spegnere nulla, non fumare, avvisare subito il comandante.',
      'Incendio esteso = l\'obiettivo è la fuga, non lo spegnimento.',
      "L'abbandono della barca è ordinato esclusivamente dal comandante.",
    ]),
    BriefingSection('6. Motore, elettricità e acqua', [
      "L'equipaggio sa avviare e fermare il motore.",
      'Sa dove si trovano le pompe di sentina.',
      "Segnalare subito al comandante l'ingresso di acqua.",
    ]),
    BriefingSection('7. Salute e primo soccorso', [
      'La cassetta di pronto soccorso si trova in un punto noto.',
      'Segnalare ferite, ustioni, spossatezza o ipotermia.',
      'Comunicare al comandante allergie e problemi di salute.',
    ]),
    BriefingSection('8. Uomo in mare (MOB)', [
      'La prevenzione migliore è non cadere in acqua.',
      'Se accade: 1. Indicare  2. Gridare  3. Non perdere di vista la persona',
      'Premere il pulsante MOB.',
      'Il comandante dirige il recupero.',
    ]),
    BriefingSection('9. Bagno di bordo (heads)', [
      'Il bagno di bordo non è un WC domestico.',
      'Vi vanno solo rifiuti organici umani e carta igienica nautica o a rapida dissoluzione.',
      'VIETATI: salviette umidificate, assorbenti, tamponi, carta da cucina.',
      "Dopo l'uso sciacquare a fondo l'impianto.",
      'Segnalare subito al comandante qualsiasi problema.',
    ]),
    BriefingSection('10. Comunicazioni', [
      'Il canale VHF di soccorso è il 16.',
      'Mayday e DSC sono gestiti dal comandante o da una persona designata, ma tutti conoscono la procedura.',
    ]),
    BriefingSection('11. Conclusione', [
      "Ogni membro dell'equipaggio conferma di aver compreso il briefing.",
      'Le domande prima della partenza sono benvenute.',
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
        'cs' => _cs,
        'pl' => _pl,
        'el' => _el,
        'hr' => _hr,
        'sl' => _sl,
        'it' => _it,
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

  static const Map<String, List<String>> _cs = {
    'Obuv': [
      'Pevná obuv (tenisky s protiskluzovou podrážkou, nejlépe světlou)',
      'Sandály nebo žabky (crocs)',
    ],
    'Oblečení': [
      'Čepice (teplejší + kšiltovka)',
      'Spodní prádlo',
      'Funkční prádlo',
      'Termoprádlo',
      'Teplá vrstva (fleece)',
      'Nepromokavé a větruodolné oblečení',
      'Tepláky',
      'Kraťasy',
      'Plavky',
      'Rukavice (nejlépe bezprsté – jachtařské/cyklistické)',
    ],
    'Hygiena': [
      'Ručník (ideálně 2×)',
      'Osobní hygiena (zubní kartáček, pasta, sprchový gel)',
      'Vlhčené ubrousky',
      'Opalovací krém (UV50) + panthenol',
      'Balzám na rty',
    ],
    'Ostatní': [
      'Sluneční brýle + šňůrka',
      'Čelovka (s červeným světlem)',
      'Power banka + nabíječka',
      'Osobní lékárnička (osobní léky, alergie, kinetóza...)',
      'Vodotěsný obal na telefon',
    ],
    'Doklady': [
      'Pas nebo občanský průkaz',
      'Evropský průkaz zdravotního pojištění',
      'Cestovní pojištění',
      '⚠️ Balení do batohů/tašek (nejlépe nepromokavých), NE pevných kufrů!',
    ],
  };

  static const Map<String, List<String>> _pl = {
    'Obuwie': [
      'Solidne obuwie (trampki z antypoślizgową podeszwą, najlepiej jasną)',
      'Sandały lub klapki (crocsy)',
    ],
    'Odzież': [
      'Czapka (cieplejsza + z daszkiem)',
      'Bielizna',
      'Bielizna funkcyjna',
      'Bielizna termiczna',
      'Ciepła warstwa (polar)',
      'Odzież nieprzemakalna i wiatroszczelna',
      'Spodnie dresowe',
      'Krótkie spodenki',
      'Strój kąpielowy',
      'Rękawice (najlepiej bez palców – żeglarskie/rowerowe)',
    ],
    'Higiena': [
      'Ręcznik (idealnie 2×)',
      'Higiena osobista (szczoteczka, pasta, żel pod prysznic)',
      'Nawilżane chusteczki',
      'Krem z filtrem (UV50) + pantenol',
      'Balsam do ust',
    ],
    'Inne': [
      'Okulary przeciwsłoneczne + sznurek',
      'Latarka czołowa (z czerwonym światłem)',
      'Power bank + ładowarka',
      'Osobista apteczka (własne leki, alergie, choroba lokomocyjna...)',
      'Wodoodporne etui na telefon',
    ],
    'Dokumenty': [
      'Paszport lub dowód osobisty',
      'Europejska karta ubezpieczenia zdrowotnego',
      'Ubezpieczenie podróżne',
      '⚠️ Pakuj w plecaki/miękkie torby (najlepiej wodoodporne), NIE w twarde walizki!',
    ],
  };

  static const Map<String, List<String>> _el = {
    'Υποδήματα': [
      'Στιβαρά παπούτσια (αθλητικά με αντιολισθητική σόλα, κατά προτίμηση ανοιχτόχρωμη)',
      'Σανδάλια ή σαγιονάρες (crocs)',
    ],
    'Ρουχισμός': [
      'Σκούφος (ζεστός + καπέλο)',
      'Εσώρουχα',
      'Ισοθερμικά εσώρουχα (base layer)',
      'Θερμικά εσώρουχα',
      'Ζεστή στρώση (fleece)',
      'Αδιάβροχα και αντιανεμικά ρούχα',
      'Φόρμα',
      'Σορτς',
      'Μαγιό',
      'Γάντια (κατά προτίμηση χωρίς δάχτυλα – ιστιοπλοΐας/ποδηλασίας)',
    ],
    'Υγιεινή': [
      'Πετσέτα (ιδανικά 2×)',
      'Ατομική υγιεινή (οδοντόβουρτσα, οδοντόκρεμα, αφρόλουτρο)',
      'Υγρά μαντηλάκια',
      'Αντηλιακό (UV50) + πανθενόλη',
      'Βάλσαμο χειλιών',
    ],
    'Άλλα': [
      'Γυαλιά ηλίου + κορδόνι',
      'Φακός κεφαλής (με κόκκινο φως)',
      'Power bank + φορτιστής',
      'Ατομικό κιτ πρώτων βοηθειών (φάρμακα, αλλεργίες, ναυτία...)',
      'Αδιάβροχη θήκη κινητού',
    ],
    'Έγγραφα': [
      'Διαβατήριο ή ταυτότητα',
      'Ευρωπαϊκή κάρτα ασφάλισης υγείας',
      'Ταξιδιωτική ασφάλιση',
      '⚠️ Πακετάρετε σε σακίδια/μαλακές τσάντες (κατά προτίμηση αδιάβροχες), ΟΧΙ σκληρές βαλίτσες!',
    ],
  };

  static const Map<String, List<String>> _hr = {
    'Obuća': [
      'Čvrsta obuća (tenisice s protukliznim potplatom, najbolje svijetlim)',
      'Sandale ili japanke (crocsice)',
    ],
    'Odjeća': [
      'Kapa (topla + s šiltom)',
      'Donje rublje',
      'Funkcionalno rublje',
      'Termo rublje',
      'Topli sloj (flis)',
      'Nepromočiva i vjetrootporna odjeća',
      'Trenirka',
      'Kratke hlače',
      'Kupaći kostim',
      'Rukavice (najbolje bez prstiju – jedriličarske/biciklističke)',
    ],
    'Higijena': [
      'Ručnik (idealno 2×)',
      'Osobna higijena (četkica, pasta, gel za tuširanje)',
      'Vlažne maramice',
      'Krema za sunčanje (UV50) + pantenol',
      'Balzam za usne',
    ],
    'Ostalo': [
      'Sunčane naočale + vezica',
      'Čeona svjetiljka (s crvenim svjetlom)',
      'Power bank + punjač',
      'Osobna kutija prve pomoći (osobni lijekovi, alergije, morska bolest...)',
      'Vodootporna navlaka za mobitel',
    ],
    'Dokumenti': [
      'Putovnica ili osobna iskaznica',
      'Europska kartica zdravstvenog osiguranja',
      'Putno osiguranje',
      '⚠️ Pakirajte u ruksake/meke torbe (najbolje nepromočive), NE u tvrde kofere!',
    ],
  };

  static const Map<String, List<String>> _sl = {
    'Obutev': [
      'Trdna obutev (superge z nedrsečim podplatom, najbolje svetlim)',
      'Sandali ali natikači (crocsi)',
    ],
    'Oblačila': [
      'Kapa (toplejša + s ščitkom)',
      'Spodnje perilo',
      'Funkcionalno perilo',
      'Termo perilo',
      'Topla plast (flis)',
      'Nepremočljiva in vetrovna oblačila',
      'Trenirka',
      'Kratke hlače',
      'Kopalke',
      'Rokavice (najbolje brez prstov – jadralne/kolesarske)',
    ],
    'Higiena': [
      'Brisača (idealno 2×)',
      'Osebna higiena (zobna ščetka, pasta, gel za prhanje)',
      'Vlažni robčki',
      'Krema za sončenje (UV50) + pantenol',
      'Balzam za ustnice',
    ],
    'Drugo': [
      'Sončna očala + vrvica',
      'Čelna svetilka (z rdečo lučjo)',
      'Power bank + polnilnik',
      'Osebna lekarna (osebna zdravila, alergije, morska bolezen...)',
      'Vodoodporen ovitek za telefon',
    ],
    'Dokumenti': [
      'Potni list ali osebna izkaznica',
      'Evropska kartica zdravstvenega zavarovanja',
      'Potovalno zavarovanje',
      '⚠️ Pakirajte v nahrbtnike/mehke torbe (najbolje nepremočljive), NE v trde kovčke!',
    ],
  };

  static const Map<String, List<String>> _it = {
    'Calzature': [
      'Scarpe robuste (sneaker con suola antiscivolo, meglio se chiara)',
      'Sandali o infradito (crocs)',
    ],
    'Abbigliamento': [
      'Berretto (uno caldo + uno con visiera)',
      'Biancheria intima',
      'Biancheria tecnica',
      'Biancheria termica',
      'Strato caldo (pile)',
      'Abbigliamento impermeabile e antivento',
      'Pantaloni della tuta',
      'Pantaloncini',
      'Costume da bagno',
      'Guanti (meglio se senza dita – da vela/da ciclismo)',
    ],
    'Igiene': [
      'Asciugamano (idealmente 2×)',
      'Igiene personale (spazzolino, dentifricio, bagnoschiuma)',
      'Salviette umidificate',
      'Crema solare (UV50) + pantenolo',
      'Burrocacao',
    ],
    'Altro': [
      'Occhiali da sole + laccetto',
      'Lampada frontale (con luce rossa)',
      'Power bank + caricabatterie',
      'Kit medico personale (farmaci propri, allergie, mal di mare...)',
      'Custodia impermeabile per il telefono',
    ],
    'Documenti': [
      "Passaporto o carta d'identità",
      'Tessera sanitaria europea',
      'Assicurazione di viaggio',
      '⚠️ Metti tutto in zaini/borse morbide (meglio se impermeabili), NON in valigie rigide!',
    ],
  };
}
