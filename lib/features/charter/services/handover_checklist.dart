import 'dart:convert';

enum ChecklistStatus { ok, damaged, missing }

ChecklistStatus _statusFromString(String s) => ChecklistStatus.values.firstWhere(
      (v) => v.name == s,
      orElse: () => ChecklistStatus.ok,
    );

/// Jedna položka kontrolného zoznamu odovzdávacieho protokolu. Foto a
/// poloha na lodi sú relevantné len keď [status] nie je [ChecklistStatus.ok].
class ChecklistItem {
  final String itemKey;
  final ChecklistStatus status;
  final String? note;
  final String? photoPath;
  final String? position;

  /// Popis položky, ktorú si dopísal skiper. Pevné položky ho nemajú —
  /// tie sa prekladajú cez [findItemDef]; vlastná sa preložiť nedá, lebo ju
  /// nikto nepreložil, a nesie sa presne tak, ako ju niekto napísal.
  final String? customLabel;

  /// Kategória, do ktorej vlastná položka patrí (kľúč z [HandoverCategoryDef]).
  /// Bez nej by sa pri vykresľovaní nemala kam zaradiť.
  final String? categoryKey;

  const ChecklistItem({
    required this.itemKey,
    this.status = ChecklistStatus.ok,
    this.note,
    this.photoPath,
    this.position,
    this.customLabel,
    this.categoryKey,
  });

  bool get isCustom => customLabel != null && customLabel!.isNotEmpty;

  ChecklistItem copyWith({
    ChecklistStatus? status,
    String? note,
    String? photoPath,
    String? position,
    bool clearNote = false,
    bool clearPhoto = false,
    bool clearPosition = false,
  }) =>
      ChecklistItem(
        itemKey: itemKey,
        status: status ?? this.status,
        note: clearNote ? null : (note ?? this.note),
        photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
        position: clearPosition ? null : (position ?? this.position),
        customLabel: customLabel,
        categoryKey: categoryKey,
      );

  Map<String, dynamic> toJson() => {
        'itemKey': itemKey,
        'status': status.name,
        if (note != null) 'note': note,
        if (photoPath != null) 'photoPath': photoPath,
        if (position != null) 'position': position,
        if (customLabel != null) 'customLabel': customLabel,
        if (categoryKey != null) 'categoryKey': categoryKey,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        itemKey: json['itemKey'] as String,
        status: _statusFromString(json['status'] as String? ?? 'ok'),
        note: json['note'] as String?,
        photoPath: json['photoPath'] as String?,
        position: json['position'] as String?,
        customLabel: json['customLabel'] as String?,
        categoryKey: json['categoryKey'] as String?,
      );
}

/// Definícia jednej položky checklistu (statický obsah, nie stav) —
/// popisky vo všetkých jazykoch appky. cs/pl/el/hr/sl sú voliteľné a keď chýbajú,
/// [itemLabel] použije anglický text (bezpečný fallback, nikdy sa nerozbije).
class HandoverItemDef {
  final String key;
  final String labelSk;
  final String labelEn;
  final String labelDe;
  final String labelEs;
  final String labelUk;
  final String labelCs;
  final String labelPl;
  final String labelEl;
  final String labelHr;
  final String labelSl;
  final String labelIt;
  const HandoverItemDef(this.key, this.labelSk, this.labelEn, this.labelDe,
      this.labelEs, this.labelUk,
      {this.labelCs = '',
      this.labelPl = '',
      this.labelEl = '',
      this.labelHr = '',
      this.labelSl = '',
      this.labelIt = ''});
}

/// Kategória (skupina) položiek checklistu.
class HandoverCategoryDef {
  final String key;
  final String labelSk;
  final String labelEn;
  final String labelDe;
  final String labelEs;
  final String labelUk;
  final List<HandoverItemDef> items;
  final String labelCs;
  final String labelPl;
  final String labelEl;
  final String labelHr;
  final String labelSl;
  final String labelIt;
  const HandoverCategoryDef(this.key, this.labelSk, this.labelEn, this.labelDe,
      this.labelEs, this.labelUk, this.items,
      {this.labelCs = '',
      this.labelPl = '',
      this.labelEl = '',
      this.labelHr = '',
      this.labelSl = '',
      this.labelIt = ''});
}

/// Reálny odovzdávací checklist prevzatý z HMB Príručky (Bezpečnosť tab).
/// Check-in a check-out majú odlišný obsah – nie je to ten istý zoznam
/// prechádzaný dvakrát.
const List<HandoverCategoryDef> checkInCategories = [
  HandoverCategoryDef('electrical', 'Elektrické vybavenie', 'Electrical equipment',
      'Elektrische Ausrüstung', 'Equipo eléctrico', 'Електрообладнання', [
    HandoverItemDef('electrical_switches', 'Vypínače a ističe', 'Switches and breakers',
        'Schalter und Sicherungsautomaten', 'Interruptores y disyuntores', 'Вимикачі та автомати',
        labelCs: 'Vypínače a jističe', labelPl: 'Wyłączniki i bezpieczniki', labelEl: 'Διακόπτες και ασφάλειες', labelHr: 'Prekidači i osigurači', labelSl: 'Stikala in odklopniki', labelIt: 'Interruttori e magnetotermici'),
    HandoverItemDef('electrical_windlass', 'Kotvový naviják (ankerspill)', 'Anchor windlass',
        'Ankerwinde', 'Molinete del ancla', 'Якірна лебідка',
        labelCs: 'Kotevní naviják', labelPl: 'Winda kotwiczna', labelEl: 'Εργάτης άγκυρας', labelHr: 'Sidreno vitlo', labelSl: 'Sidrno vitlo', labelIt: 'Salpa ancora'),
    HandoverItemDef('electrical_nav_instruments', 'Navigačné prístroje', 'Navigation instruments',
        'Navigationsinstrumente', 'Instrumentos de navegación', 'Навігаційні прилади',
        labelCs: 'Navigační přístroje', labelPl: 'Przyrządy nawigacyjne', labelEl: 'Όργανα ναυσιπλοΐας', labelHr: 'Navigacijski instrumenti', labelSl: 'Navigacijski instrumenti', labelIt: 'Strumenti di navigazione'),
    HandoverItemDef('electrical_vhf', 'VHF rádio', 'VHF radio',
        'UKW-Funkgerät', 'Radio VHF', 'Радіостанція VHF',
        labelCs: 'VHF rádio', labelPl: 'Radio VHF', labelEl: 'Ασύρματος VHF', labelHr: 'VHF radio', labelSl: 'Radio VHF', labelIt: 'Radio VHF'),
    HandoverItemDef('electrical_battery_indicator', 'Indikátor stavu batérie', 'Battery status indicator',
        'Batteriestandsanzeige', 'Indicador de estado de batería', 'Індикатор стану батареї',
        labelCs: 'Indikátor stavu baterie', labelPl: 'Wskaźnik stanu akumulatora', labelEl: 'Δείκτης κατάστασης μπαταρίας', labelHr: 'Pokazivač stanja baterije', labelSl: 'Kazalnik stanja akumulatorja', labelIt: 'Indicatore di carica delle batterie'),
    HandoverItemDef('electrical_nav_lights', 'Pozičné svetlá', 'Navigation lights',
        'Positionslichter', 'Luces de navegación', 'Ходові вогні',
        labelCs: 'Poziční světla', labelPl: 'Światła nawigacyjne', labelEl: 'Φώτα ναυσιπλοΐας', labelHr: 'Navigacijska svjetla', labelSl: 'Navigacijske luči', labelIt: 'Luci di navigazione'),
    HandoverItemDef('electrical_autopilot', 'Autopilot', 'Autopilot',
        'Autopilot', 'Piloto automático', 'Автопілот',
        labelCs: 'Autopilot', labelPl: 'Autopilot', labelEl: 'Αυτόματος πιλότος', labelHr: 'Autopilot', labelSl: 'Avtopilot', labelIt: 'Pilota automatico'),
    HandoverItemDef('electrical_fuses', 'Poistky', 'Fuses',
        'Sicherungen', 'Fusibles', 'Запобіжники',
        labelCs: 'Pojistky', labelPl: 'Bezpieczniki', labelEl: 'Ασφάλειες', labelHr: 'Osigurači', labelSl: 'Varovalke', labelIt: 'Fusibili'),
    HandoverItemDef('electrical_water_level', 'Indikátor hladiny vody', 'Water level indicator',
        'Wasserstandsanzeige', 'Indicador de nivel de agua', 'Індикатор рівня води',
        labelCs: 'Indikátor hladiny vody', labelPl: 'Wskaźnik poziomu wody', labelEl: 'Δείκτης στάθμης νερού', labelHr: 'Pokazivač razine vode', labelSl: 'Kazalnik ravni vode', labelIt: 'Indicatore del livello dell\'acqua'),
    HandoverItemDef('electrical_spare_bulbs', 'Náhradné žiarovky', 'Spare bulbs',
        'Ersatzglühbirnen', 'Bombillas de repuesto', 'Запасні лампочки',
        labelCs: 'Náhradní žárovky', labelPl: 'Zapasowe żarówki', labelEl: 'Εφεδρικοί λαμπτήρες', labelHr: 'Rezervne žarulje', labelSl: 'Rezervne žarnice', labelIt: 'Lampadine di ricambio'),
    HandoverItemDef('electrical_depth_sounder', 'Lodný sonar (merač hĺbky)', 'Depth sounder',
        'Echolot', 'Sonda de profundidad', 'Ехолот',
        labelCs: 'Lodní sonar (měřič hloubky)', labelPl: 'Echosonda (głębokościomierz)', labelEl: 'Βυθόμετρο', labelHr: 'Dubinomjer', labelSl: 'Globinomer', labelIt: 'Ecoscandaglio'),
    HandoverItemDef('electrical_pumps', 'Čerpadlá (pumpy)', 'Pumps',
        'Pumpen', 'Bombas', 'Помпи',
        labelCs: 'Čerpadla (pumpy)', labelPl: 'Pompy', labelEl: 'Αντλίες', labelHr: 'Pumpe', labelSl: 'Črpalke', labelIt: 'Pompe'),
  ], labelCs: 'Elektrické vybavení', labelPl: 'Wyposażenie elektryczne', labelEl: 'Ηλεκτρολογικός εξοπλισμός', labelHr: 'Električna oprema', labelSl: 'Električna oprema', labelIt: 'Impianto elettrico'),
  HandoverCategoryDef('engine', 'Motor a palivo', 'Engine and fuel',
      'Motor und Kraftstoff', 'Motor y combustible', 'Двигун і паливо', [
    HandoverItemDef('engine_refuel', 'Dotankovanie', 'Refuelling',
        'Auftanken', 'Repostaje', 'Дозаправлення',
        labelCs: 'Dotankování', labelPl: 'Tankowanie', labelEl: 'Ανεφοδιασμός καυσίμου', labelHr: 'Punjenje goriva', labelSl: 'Dotakanje goriva', labelIt: 'Rifornimento'),
    HandoverItemDef('engine_vbelt', 'Napnutie V-remeňov', 'V-belt tension',
        'Keilriemenspannung', 'Tensión de las correas', 'Натяг клинових ременів',
        labelCs: 'Napnutí klínových řemenů', labelPl: 'Napięcie pasków klinowych', labelEl: 'Τάση τραπεζοειδών ιμάντων', labelHr: 'Napetost klinastog remena', labelSl: 'Napetost klinastega jermena', labelIt: 'Tensione della cinghia trapezoidale'),
    HandoverItemDef('engine_cooling_water', 'Kontrola prívodu chladiacej vody', 'Cooling water intake check',
        'Kühlwasserzufuhr prüfen', 'Comprobación de la toma de agua de refrigeración', 'Перевірка подачі охолоджувальної води',
        labelCs: 'Kontrola přívodu chladicí vody', labelPl: 'Kontrola dopływu wody chłodzącej', labelEl: 'Έλεγχος εισαγωγής νερού ψύξης', labelHr: 'Provjera dovoda rashladne vode', labelSl: 'Pregled dovoda hladilne vode', labelIt: 'Verifica della presa dell\'acqua di raffreddamento'),
    HandoverItemDef('engine_oil', 'Motorový olej', 'Engine oil',
        'Motoröl', 'Aceite del motor', 'Моторна олива',
        labelCs: 'Motorový olej', labelPl: 'Olej silnikowy', labelEl: 'Λάδι μηχανής', labelHr: 'Motorno ulje', labelSl: 'Motorno olje', labelIt: 'Olio motore'),
    HandoverItemDef('engine_fuel_filter', 'Palivový filter', 'Fuel filter',
        'Kraftstofffilter', 'Filtro de combustible', 'Паливний фільтр',
        labelCs: 'Palivový filtr', labelPl: 'Filtr paliwa', labelEl: 'Φίλτρο καυσίμου', labelHr: 'Filtar goriva', labelSl: 'Filter goriva', labelIt: 'Filtro del carburante'),
    HandoverItemDef('engine_fuel_level', 'Hladina paliva v nádrži', 'Fuel tank level',
        'Füllstand des Kraftstofftanks', 'Nivel del tanque de combustible', 'Рівень палива в баку',
        labelCs: 'Hladina paliva v nádrži', labelPl: 'Poziom paliwa w zbiorniku', labelEl: 'Στάθμη καυσίμου στη δεξαμενή', labelHr: 'Razina u tanku goriva', labelSl: 'Raven v rezervoarju goriva', labelIt: 'Livello del serbatoio del carburante'),
    HandoverItemDef('engine_gearbox_oil', 'Olej v prevodovke', 'Gearbox oil',
        'Getriebeöl', 'Aceite de la transmisión', 'Олива в редукторі',
        labelCs: 'Olej v převodovce', labelPl: 'Olej w przekładni', labelEl: 'Λάδι κιβωτίου ταχυτήτων', labelHr: 'Ulje u reduktoru', labelSl: 'Olje v menjalniku', labelIt: 'Olio dell\'invertitore'),
    HandoverItemDef('engine_coolant_level', 'Hladina chladiacej kvapaliny', 'Coolant level',
        'Kühlmittelstand', 'Nivel de refrigerante', 'Рівень охолоджувальної рідини',
        labelCs: 'Hladina chladicí kapaliny', labelPl: 'Poziom płynu chłodzącego', labelEl: 'Στάθμη ψυκτικού υγρού', labelHr: 'Razina rashladne tekućine', labelSl: 'Raven hladilne tekočine', labelIt: 'Livello del liquido di raffreddamento'),
    HandoverItemDef('engine_fuel_tank_condition', 'Kontrola stavu palivovej nádrže a jej upevnenia',
        'Fuel tank condition and mounting check',
        'Zustand und Befestigung des Kraftstofftanks prüfen',
        'Comprobación del estado y la sujeción del tanque de combustible',
        'Перевірка стану паливного бака та його кріплення',
        labelCs: 'Kontrola stavu palivové nádrže a jejího upevnění', labelPl: 'Kontrola stanu i mocowania zbiornika paliwa', labelEl: 'Έλεγχος κατάστασης και στερέωσης δεξαμενής καυσίμου', labelHr: 'Provjera stanja i učvršćenja tanka goriva', labelSl: 'Pregled stanja in pritrditve rezervoarja goriva', labelIt: 'Verifica dello stato e del fissaggio del serbatoio del carburante'),
  ], labelCs: 'Motor a palivo', labelPl: 'Silnik i paliwo', labelEl: 'Μηχανή και καύσιμο', labelHr: 'Motor i gorivo', labelSl: 'Motor in gorivo', labelIt: 'Motore e carburante'),
  HandoverCategoryDef('nav_docs', 'Navigačné pomôcky a doklady', 'Navigation aids and documents',
      'Navigationshilfen und Dokumente', 'Ayudas a la navegación y documentos', 'Навігаційні засоби та документи', [
    HandoverItemDef('nav_docs_paper_charts', 'Papierové mapy a navigácia', 'Paper charts and navigation',
        'Papierseekarten und Navigation', 'Cartas náuticas de papel y navegación', 'Паперові карти та навігація',
        labelCs: 'Papírové mapy a navigace', labelPl: 'Mapy papierowe i nawigacja', labelEl: 'Χάρτινοι χάρτες και ναυσιπλοΐα', labelHr: 'Papirnate karte i navigacija', labelSl: 'Papirnate karte in navigacija', labelIt: 'Carte nautiche cartacee e navigazione'),
    HandoverItemDef('nav_docs_sailing_permit', 'Povolenie na plavbu (sailing permit)', 'Sailing permit',
        'Fahrterlaubnis (Sailing Permit)', 'Permiso de navegación', 'Дозвіл на плавання',
        labelCs: 'Povolení k plavbě (sailing permit)', labelPl: 'Zezwolenie na żeglugę (sailing permit)', labelEl: 'Άδεια πλου (sailing permit)', labelHr: 'Dozvola za plovidbu', labelSl: 'Dovoljenje za plovbo', labelIt: 'Licenza di navigazione'),
    HandoverItemDef('nav_docs_aids', 'Navigačné pomôcky', 'Navigation aids',
        'Navigationshilfen', 'Ayudas a la navegación', 'Навігаційні засоби',
        labelCs: 'Navigační pomůcky', labelPl: 'Pomoce nawigacyjne', labelEl: 'Ναυτιλιακά βοηθήματα', labelHr: 'Navigacijska pomagala', labelSl: 'Navigacijski pripomočki', labelIt: 'Ausili alla navigazione'),
    HandoverItemDef('nav_docs_crew_list', 'Zoznam posádky (crew list)', 'Crew list',
        'Crew-Liste', 'Lista de tripulación', 'Список екіпажу',
        labelCs: 'Seznam posádky (crew list)', labelPl: 'Lista załogi (crew list)', labelEl: 'Κατάσταση πληρώματος (crew list)', labelHr: 'Popis posade', labelSl: 'Seznam posadke', labelIt: 'Lista dell\'equipaggio'),
    HandoverItemDef('nav_docs_binoculars', 'Ďalekohľad', 'Binoculars',
        'Fernglas', 'Prismáticos', 'Бінокль',
        labelCs: 'Dalekohled', labelPl: 'Lornetka', labelEl: 'Κιάλια', labelHr: 'Dalekozor', labelSl: 'Daljnogled', labelIt: 'Binocolo'),
  ], labelCs: 'Navigační pomůcky a doklady', labelPl: 'Pomoce nawigacyjne i dokumenty', labelEl: 'Ναυτιλιακά βοηθήματα και έγγραφα', labelHr: 'Navigacijska pomagala i dokumenti', labelSl: 'Navigacijski pripomočki in dokumenti', labelIt: 'Ausili alla navigazione e documenti'),
  HandoverCategoryDef('hull', 'Trup lode', 'Hull',
      'Rumpf', 'Casco', 'Корпус', [
    HandoverItemDef('hull_deck', 'Paluba lode', 'Deck',
        'Deck', 'Cubierta', 'Палуба',
        labelCs: 'Paluba lodi', labelPl: 'Pokład', labelEl: 'Κατάστρωμα', labelHr: 'Paluba', labelSl: 'Krov', labelIt: 'Coperta'),
    HandoverItemDef('hull_bow', 'Prova lode', 'Bow',
        'Bug', 'Proa', 'Ніс судна',
        labelCs: 'Příď lodi', labelPl: 'Dziób', labelEl: 'Πλώρη', labelHr: 'Pramac', labelSl: 'Premec', labelIt: 'Prua'),
    HandoverItemDef('hull_under_floorboards', 'Priestor pod palubovými doskami', 'Space under the floorboards',
        'Raum unter den Bodenbrettern', 'Espacio bajo las tablas del suelo', 'Простір під пайолами',
        labelCs: 'Prostor pod podlahovými deskami', labelPl: 'Przestrzeń pod podłogami', labelEl: 'Χώρος κάτω από τα δάπεδα', labelHr: 'Prostor ispod podnica', labelSl: 'Prostor pod podnicami', labelIt: 'Spazio sotto i paglioli'),
    HandoverItemDef('hull_stern', 'Záď lode', 'Stern',
        'Heck', 'Popa', 'Корма',
        labelCs: 'Záď lodi', labelPl: 'Rufa', labelEl: 'Πρύμνη', labelHr: 'Krma', labelSl: 'Krma', labelIt: 'Poppa'),
    HandoverItemDef('hull_sides', 'Boky lode', 'Hull sides',
        'Rumpfseiten', 'Costados del casco', 'Борти корпусу',
        labelCs: 'Boky lodi', labelPl: 'Burty', labelEl: 'Πλευρές γάστρας', labelHr: 'Bokovi trupa', labelSl: 'Boki trupa', labelIt: 'Fiancate dello scafo'),
    HandoverItemDef('hull_underwater', 'Podvodná časť trupu', 'Underwater part of the hull',
        'Unterwasserschiff', 'Obra viva del casco', 'Підводна частина корпусу',
        labelCs: 'Podvodní část trupu', labelPl: 'Podwodna część kadłuba', labelEl: 'Ύφαλο τμήμα γάστρας', labelHr: 'Podvodni dio trupa', labelSl: 'Podvodni del trupa', labelIt: 'Opera viva dello scafo'),
  ], labelCs: 'Trup lodi', labelPl: 'Kadłub', labelEl: 'Γάστρα', labelHr: 'Trup', labelSl: 'Trup', labelIt: 'Scafo'),
  HandoverCategoryDef('safety_gear', 'Bezpečnostné vybavenie', 'Safety equipment',
      'Sicherheitsausrüstung', 'Equipo de seguridad', 'Засоби безпеки', [
    HandoverItemDef('safety_gear_life_jackets', 'Záchranné vesty', 'Life jackets',
        'Rettungswesten', 'Chalecos salvavidas', 'Рятувальні жилети',
        labelCs: 'Záchranné vesty', labelPl: 'Kamizelki ratunkowe', labelEl: 'Σωσίβια', labelHr: 'Prsluci za spašavanje', labelSl: 'Rešilni jopiči', labelIt: 'Giubbotti di salvataggio'),
    HandoverItemDef('safety_gear_extinguishers', 'Hasiace prístroje', 'Fire extinguishers',
        'Feuerlöscher', 'Extintores', 'Вогнегасники',
        labelCs: 'Hasicí přístroje', labelPl: 'Gaśnice', labelEl: 'Πυροσβεστήρες', labelHr: 'Vatrogasni aparati', labelSl: 'Gasilni aparati', labelIt: 'Estintori'),
    HandoverItemDef('safety_gear_harnesses', 'Bezpečnostné postroje', 'Safety harnesses',
        'Sicherheitsgurte (Lifebelts)', 'Arneses de seguridad', 'Страхувальні обв\'язки',
        labelCs: 'Bezpečnostní postroje', labelPl: 'Uprzęże bezpieczeństwa', labelEl: 'Ζώνες ασφαλείας', labelHr: 'Sigurnosni pojasevi', labelSl: 'Varnostni pasovi', labelIt: 'Cinture di sicurezza'),
    HandoverItemDef('safety_gear_flares', 'Svetlice', 'Flares',
        'Signalraketen', 'Bengalas', 'Сигнальні ракети',
        labelCs: 'Světlice', labelPl: 'Rakiety sygnałowe', labelEl: 'Φωτοβολίδες', labelHr: 'Signalne rakete', labelSl: 'Signalne rakete', labelIt: 'Razzi di segnalazione'),
  ], labelCs: 'Bezpečnostní vybavení', labelPl: 'Sprzęt bezpieczeństwa', labelEl: 'Εξοπλισμός ασφαλείας', labelHr: 'Sigurnosna oprema', labelSl: 'Varnostna oprema', labelIt: 'Dotazioni di sicurezza'),
  HandoverCategoryDef('galley', 'Kuchyňa', 'Galley',
      'Pantry (Galley)', 'Cocina', 'Камбуз', [
    HandoverItemDef('galley_fridge', 'Chladnička', 'Fridge',
        'Kühlschrank', 'Nevera', 'Холодильник',
        labelCs: 'Lednička', labelPl: 'Lodówka', labelEl: 'Ψυγείο', labelHr: 'Hladnjak', labelSl: 'Hladilnik', labelIt: 'Frigorifero'),
    HandoverItemDef('galley_gas_shutoff', 'Hlavný plynový uzáver', 'Main gas shut-off valve',
        'Gashaupthahn', 'Válvula principal de corte de gas', 'Головний газовий кран',
        labelCs: 'Hlavní plynový uzávěr', labelPl: 'Główny zawór gazu', labelEl: 'Κεντρική βαλβίδα αερίου', labelHr: 'Glavni zaporni ventil plina', labelSl: 'Glavni zaporni ventil plina', labelIt: 'Valvola principale di intercettazione del gas'),
    HandoverItemDef('galley_stove', 'Sporák a jeho upevnenie', 'Stove and its mounting',
        'Herd und seine Befestigung', 'Cocina y su sujeción', 'Плита та її кріплення',
        labelCs: 'Sporák a jeho upevnění', labelPl: 'Kuchenka i jej mocowanie', labelEl: 'Εστία και η στερέωσή της', labelHr: 'Štednjak i njegovo učvršćenje', labelSl: 'Štedilnik in njegova pritrditev', labelIt: 'Fornello e suo fissaggio'),
    HandoverItemDef('galley_gas_bottles', 'Plynové fľaše (2 ks)', 'Gas bottles (2 pcs)',
        'Gasflaschen (2 Stück)', 'Bombonas de gas (2 uds.)', 'Газові балони (2 шт.)',
        labelCs: 'Plynové lahve (2 ks)', labelPl: 'Butle gazowe (2 szt.)', labelEl: 'Φιάλες αερίου (2 τεμ.)', labelHr: 'Plinske boce (2 kom)', labelSl: 'Plinske jeklenke (2 kos)', labelIt: 'Bombole del gas (2 pz)'),
  ], labelCs: 'Kuchyně', labelPl: 'Kambuz', labelEl: 'Μαγειρείο', labelHr: 'Brodska kuhinja', labelSl: 'Ladijska kuhinja', labelIt: 'Cucina di bordo'),
  HandoverCategoryDef('cabins', 'Kajuty', 'Cabins',
      'Kajüten', 'Camarotes', 'Каюти', [
    HandoverItemDef('cabins_bedding', 'Posteľná bielizeň', 'Bedding',
        'Bettwäsche', 'Ropa de cama', 'Постільна білизна',
        labelCs: 'Ložní prádlo', labelPl: 'Pościel', labelEl: 'Κλινοσκεπάσματα', labelHr: 'Posteljina', labelSl: 'Posteljnina', labelIt: 'Biancheria da letto'),
    HandoverItemDef('cabins_storage', 'Úložné priestory', 'Storage spaces',
        'Stauräume', 'Espacios de almacenamiento', 'Місця зберігання',
        labelCs: 'Úložné prostory', labelPl: 'Schowki', labelEl: 'Αποθηκευτικοί χώροι', labelHr: 'Prostori za odlaganje', labelSl: 'Odlagalni prostori', labelIt: 'Vani di stivaggio'),
  ], labelCs: 'Kajuty', labelPl: 'Kabiny', labelEl: 'Καμπίνες', labelHr: 'Kabine', labelSl: 'Kabine', labelIt: 'Cabine'),
  HandoverCategoryDef('water_heads', 'Voda, WC a kúpeľne', 'Water, heads and bathrooms',
      'Wasser, WC und Bäder', 'Agua, baños y aseos', 'Вода, гальюни та ванні', [
    HandoverItemDef('water_heads_tanks', 'Vodné nádrže', 'Water tanks',
        'Wassertanks', 'Tanques de agua', 'Баки для води',
        labelCs: 'Vodní nádrže', labelPl: 'Zbiorniki wody', labelEl: 'Δεξαμενές νερού', labelHr: 'Tankovi vode', labelSl: 'Rezervoarji vode', labelIt: 'Serbatoi dell\'acqua'),
    HandoverItemDef('water_heads_toilet_valves', 'WC (ventily)', 'Toilet (valves)',
        'WC (Ventile)', 'Inodoro (válvulas)', 'Гальюн (клапани)',
        labelCs: 'WC (ventily)', labelPl: 'WC (zawory)', labelEl: 'Τουαλέτα (βαλβίδες)', labelHr: 'Toalet (ventili)', labelSl: 'Stranišče (ventili)', labelIt: 'Bagno (valvole)'),
    HandoverItemDef('water_heads_shower_pump', 'Čerpanie vody zo sprchovej vaničky', 'Shower sump pump',
        'Duschwannen-Lenzpumpe', 'Bomba de achique de la ducha', 'Помпа душового піддона',
        labelCs: 'Čerpání vody ze sprchové vaničky', labelPl: 'Pompa brodzika prysznicowego', labelEl: 'Αντλία λεκάνης ντους', labelHr: 'Pumpa kaljuže tuša', labelSl: 'Črpalka kaluže tuša', labelIt: 'Pompa di sentina della doccia'),
    HandoverItemDef('water_heads_waste_tank', 'Prepnutie odpadovej nádrže a vypustenie',
        'Waste tank switch-over and pump-out',
        'Umschalten und Entleeren des Fäkalientanks',
        'Conmutación y vaciado del tanque de aguas negras',
        'Перемикання та випорожнення фекального бака',
        labelCs: 'Přepnutí odpadní nádrže a vypuštění', labelPl: 'Przełączenie i opróżnienie zbiornika fekaliów', labelEl: 'Εναλλαγή και εκκένωση δεξαμενής λυμάτων', labelHr: 'Preusmjeravanje i pražnjenje fekalnog tanka', labelSl: 'Preusmeritev in praznjenje fekalnega rezervoarja', labelIt: 'Deviazione e svuotamento del serbatoio delle acque nere'),
    HandoverItemDef('water_heads_transom_shower', 'Zadná sprcha', 'Transom shower',
        'Heckdusche', 'Ducha de popa', 'Кормовий душ',
        labelCs: 'Zadní sprcha', labelPl: 'Prysznic rufowy', labelEl: 'Ντους πρύμνης', labelHr: 'Tuš na krmenom zrcalu', labelSl: 'Tuš na krmnem zrcalu', labelIt: 'Doccetta di poppa'),
  ], labelCs: 'Voda, WC a koupelny', labelPl: 'Woda, WC i łazienki', labelEl: 'Νερό, τουαλέτες και μπάνια', labelHr: 'Voda, toaleti i kupaonice', labelSl: 'Voda, stranišča in kopalnice', labelIt: 'Acqua, bagni e servizi'),
  HandoverCategoryDef('sails_steering', 'Plachty a kormidlovanie', 'Sails and steering',
      'Segel und Steuerung', 'Velas y gobierno', 'Вітрила та кермування', [
    HandoverItemDef('sails_steering_reefing', 'Balenie a reefovanie plachiet – napnutie lán',
        'Sail furling and reefing – line tension',
        'Segel einrollen und reffen – Leinenspannung',
        'Enrollado y rizado de velas – tensión de cabos',
        'Згортання та рифлення вітрил – натяг тросів',
        labelCs: 'Balení a refování plachet – napnutí lan', labelPl: 'Zwijanie i refowanie żagli – napięcie lin', labelEl: 'Μάζεμα και μούδα πανιών – τάση σχοινιών', labelHr: 'Namotavanje i kraćenje jedara – napetost konopa', labelSl: 'Navijanje in krajšanje jader – napetost vrvi', labelIt: 'Avvolgimento e riduzione delle vele - tensione delle cime'),
    HandoverItemDef('sails_steering_halyards', 'Stav halyárd (zdvíhacích lán)', 'Halyard condition',
        'Zustand der Fallen', 'Estado de las drizas', 'Стан фалів',
        labelCs: 'Stav vytahovacích lan (fal)', labelPl: 'Stan falów', labelEl: 'Κατάσταση μαντάρων', labelHr: 'Stanje podigača', labelSl: 'Stanje dvižnih vrvi', labelIt: 'Stato delle drizze'),
    HandoverItemDef('sails_steering_rudder', 'Kormidlo', 'Rudder',
        'Ruder', 'Timón', 'Кермо',
        labelCs: 'Kormidlo', labelPl: 'Ster', labelEl: 'Πηδάλιο', labelHr: 'Kormilo', labelSl: 'Krmilo', labelIt: 'Timone'),
    HandoverItemDef('sails_steering_stoppers', 'Stopéry', 'Rope clutches',
        'Fallenstopper', 'Mordazas', 'Стопори',
        labelCs: 'Stopéry', labelPl: 'Stopery lin', labelEl: 'Στόπερ σχοινιών', labelHr: 'Stoperi konopa', labelSl: 'Zaskočke vrvi', labelIt: 'Stopper delle cime'),
    HandoverItemDef('sails_steering_furling_gear', 'Stav navíjacích zariadení (furling)', 'Furling gear condition',
        'Zustand der Rollanlagen', 'Estado de los enrolladores', 'Стан закруток (фурлерів)',
        labelCs: 'Stav navíjecích zařízení (furling)', labelPl: 'Stan urządzeń zwijających (furling)', labelEl: 'Κατάσταση συστημάτων περιτύλιξης (furling)', labelHr: 'Stanje sustava za namotavanje', labelSl: 'Stanje sistema za navijanje', labelIt: 'Stato dell\'avvolgifiocco'),
    HandoverItemDef('sails_steering_sails', 'Stav plachiet', 'Sail condition',
        'Zustand der Segel', 'Estado de las velas', 'Стан вітрил',
        labelCs: 'Stav plachet', labelPl: 'Stan żagli', labelEl: 'Κατάσταση πανιών', labelHr: 'Stanje jedara', labelSl: 'Stanje jader', labelIt: 'Stato delle vele'),
    HandoverItemDef('sails_steering_winches', 'Winche', 'Winches',
        'Winschen', 'Winches', 'Лебідки',
        labelCs: 'Winše', labelPl: 'Kabestany (winsze)', labelEl: 'Βίντσια', labelHr: 'Vinčevi', labelSl: 'Vinči', labelIt: 'Winch'),
    HandoverItemDef('sails_steering_sheets', 'Stav šotových lán', 'Sheet condition',
        'Zustand der Schoten', 'Estado de las escotas', 'Стан шкотів',
        labelCs: 'Stav škotových lan', labelPl: 'Stan szotów', labelEl: 'Κατάσταση σχοινιών (σκότες)', labelHr: 'Stanje škota', labelSl: 'Stanje škot', labelIt: 'Stato delle scotte'),
  ], labelCs: 'Plachty a kormidlování', labelPl: 'Żagle i sterowanie', labelEl: 'Πανιά και πηδάλιο', labelHr: 'Jedra i kormilarenje', labelSl: 'Jadra in krmiljenje', labelIt: 'Vele e timoneria'),
  HandoverCategoryDef('often_forgotten', 'Často zabudnuté', 'Often forgotten',
      'Oft vergessen', 'A menudo olvidado', 'Часто забувають', [
    HandoverItemDef('often_forgotten_bosun_chair_ladder', 'Bosunov rebrík na lezenie na sťažeň',
        'Mast climbing ladder',
        'Mastleiter', 'Escalera para subir al mástil', 'Драбина для підйому на щоглу',
        labelCs: 'Žebřík na lezení na stěžeň', labelPl: 'Drabinka do wchodzenia na maszt', labelEl: 'Σκάλα ανάβασης στον ιστό', labelHr: 'Ljestve za penjanje na jarbol', labelSl: 'Lestev za vzpon na jambor', labelIt: 'Scaletta per salire in testa d\'albero'),
    HandoverItemDef('often_forgotten_spare_vbelt', 'Náhradné V-remene pre hlavný motor',
        'Spare V-belts for the main engine',
        'Ersatz-Keilriemen für den Hauptmotor',
        'Correas de repuesto para el motor principal',
        'Запасні клинові ремені для головного двигуна',
        labelCs: 'Náhradní klínové řemeny pro hlavní motor', labelPl: 'Zapasowe paski klinowe do silnika głównego', labelEl: 'Εφεδρικοί ιμάντες για την κύρια μηχανή', labelHr: 'Rezervni klinasti remeni za glavni motor', labelSl: 'Rezervni klinasti jermeni za glavni motor', labelIt: 'Cinghie trapezoidali di ricambio per il motore principale'),
    HandoverItemDef('often_forgotten_bosun_chair', 'Stav bosunového kresla', 'Bosun\'s chair condition',
        'Zustand des Bootsmannsstuhls', 'Estado de la silla de contramaestre', 'Стан боцманського крісла',
        labelCs: 'Stav bosmanského křesla', labelPl: 'Stan krzesełka bosmańskiego', labelEl: 'Κατάσταση καθίσματος ναύτη', labelHr: 'Penjalica za jarbol', labelSl: 'Sedež za vzpon na jambor', labelIt: 'Seggiolino d\'albero (bosun chair)'),
    HandoverItemDef('often_forgotten_saltwater_pump_impeller', 'Gumový impulzný kolektor pre čerpadlo slanej vody',
        'Raw water pump impeller',
        'Impeller der Seewasserpumpe', 'Rodete de la bomba de agua salada', 'Імпелер помпи забортної води',
        labelCs: 'Impeler čerpadla mořské vody', labelPl: 'Wirnik pompy wody morskiej', labelEl: 'Φτερωτή αντλίας θαλασσινού νερού', labelHr: 'Impeler pumpe morske vode', labelSl: 'Impeler črpalke morske vode', labelIt: 'Girante della pompa dell\'acqua di mare'),
    HandoverItemDef('often_forgotten_halyard_condition', 'Stav zdvíhacieho lana', 'Hoisting line condition',
        'Zustand der Hissleine', 'Estado del cabo de izado', 'Стан підіймального троса',
        labelCs: 'Stav zvedacího lana', labelPl: 'Stan liny podnoszącej', labelEl: 'Κατάσταση ανυψωτικού σχοινιού', labelHr: 'Stanje konopa za dizanje', labelSl: 'Stanje vrvi za dviganje', labelIt: 'Stato della cima di sollevamento'),
    HandoverItemDef('often_forgotten_dinghy_condition', 'Stav člna (dinghy)', 'Dinghy condition',
        'Zustand des Beiboots', 'Estado del bote auxiliar', 'Стан тузика (дінгі)',
        labelCs: 'Stav člunu (dinghy)', labelPl: 'Stan pontonu (dinghy)', labelEl: 'Κατάσταση βοηθητικής λέμβου (dinghy)', labelHr: 'Stanje gumenjaka', labelSl: 'Stanje gumenjaka', labelIt: 'Stato del tender'),
  ], labelCs: 'Často zapomenuté', labelPl: 'Często zapominane', labelEl: 'Συχνά ξεχνιούνται', labelHr: 'Često zaboravljeno', labelSl: 'Pogosto pozabljeno', labelIt: 'Spesso dimenticato'),
  HandoverCategoryDef('misc', 'Rôzne', 'Miscellaneous',
      'Verschiedenes', 'Varios', 'Різне', [
    HandoverItemDef('misc_spare_rudder', 'Náhradné kormidlo', 'Spare rudder',
        'Notruder', 'Timón de repuesto', 'Запасне кермо',
        labelCs: 'Náhradní kormidlo', labelPl: 'Ster zapasowy', labelEl: 'Εφεδρικό πηδάλιο', labelHr: 'Rezervno kormilo', labelSl: 'Rezervno krmilo', labelIt: 'Timone di scorta'),
    HandoverItemDef('misc_bucket_brush_sponge', 'Vedro, kefa, špongia', 'Bucket, brush, sponge',
        'Eimer, Bürste, Schwamm', 'Cubo, cepillo, esponja', 'Відро, щітка, губка',
        labelCs: 'Kbelík, kartáč, houba', labelPl: 'Wiadro, szczotka, gąbka', labelEl: 'Κουβάς, βούρτσα, σφουγγάρι', labelHr: 'Kanta, četka, spužva', labelSl: 'Vedro, krtača, goba', labelIt: 'Secchio, spazzola, spugna'),
    HandoverItemDef('misc_oar_locks', 'Háky na veslá člna', 'Dinghy oar locks',
        'Ruderdollen des Beiboots', 'Chumaceras del bote', 'Кочети для весел тузика',
        labelCs: 'Vidlice na vesla člunu', labelPl: 'Dulki wioseł pontonu', labelEl: 'Σκαρμοί κουπιών λέμβου', labelHr: 'Vilice za vesla gumenjaka', labelSl: 'Vilice za vesla gumenjaka', labelIt: 'Scalmi dei remi del tender'),
    HandoverItemDef('misc_lifebuoy', 'Záchranný kruh alebo podkova', 'Lifebuoy or horseshoe buoy',
        'Rettungsring oder Hufeisen-Rettungsmittel', 'Aro o herradura salvavidas', 'Рятувальний круг або підкова',
        labelCs: 'Záchranný kruh nebo podkova', labelPl: 'Koło ratunkowe lub podkowa', labelEl: 'Σωσίβιο κυκλικό ή πέταλο', labelHr: 'Kolut za spašavanje ili potkova', labelSl: 'Rešilni obroč ali podkev', labelIt: 'Salvagente anulare o a ferro di cavallo'),
    HandoverItemDef('misc_anchor_lines', 'Kotvové laná', 'Anchor lines',
        'Ankerleinen', 'Cabos del ancla', 'Якірні троси',
        labelCs: 'Kotevní lana', labelPl: 'Liny kotwiczne', labelEl: 'Σχοινιά άγκυρας', labelHr: 'Sidreni konopi', labelSl: 'Sidrne vrvi', labelIt: 'Cime di ancoraggio'),
    HandoverItemDef('misc_bilge_pump', 'Ručná bilge pumpa', 'Manual bilge pump',
        'Handlenzpumpe', 'Bomba de achique manual', 'Ручна трюмна помпа',
        labelCs: 'Ruční bilžní pumpa', labelPl: 'Ręczna pompa zęzowa', labelEl: 'Χειροκίνητη αντλία σεντίνας', labelHr: 'Ručna kaljužna pumpa', labelSl: 'Ročna kalužna črpalka', labelIt: 'Pompa di sentina manuale'),
    HandoverItemDef('misc_extension_cable', 'Predlžovací elektrický kábel', 'Electrical extension cable',
        'Verlängerungskabel', 'Cable alargador eléctrico', 'Електричний подовжувач',
        labelCs: 'Prodlužovací elektrický kabel', labelPl: 'Przedłużacz elektryczny', labelEl: 'Ηλεκτρική μπαλαντέζα', labelHr: 'Produžni električni kabel', labelSl: 'Električni podaljšek', labelIt: 'Prolunga elettrica'),
    HandoverItemDef('misc_lifebuoy_light', 'Záchranná bója so svetlom', 'Lifebuoy with light',
        'Rettungsboje mit Licht', 'Boya salvavidas con luz', 'Рятувальний буй зі світлом',
        labelCs: 'Záchranná bóje se světlem', labelPl: 'Boja ratunkowa ze światłem', labelEl: 'Σωσίβια σημαδούρα με φως', labelHr: 'Kolut za spašavanje sa svjetlom', labelSl: 'Rešilni obroč z lučjo', labelIt: 'Salvagente con luce'),
    HandoverItemDef('misc_spare_anchor', 'Záložná kotva', 'Spare anchor',
        'Ersatzanker', 'Ancla de respeto', 'Запасний якір',
        labelCs: 'Záložní kotva', labelPl: 'Kotwica zapasowa', labelEl: 'Εφεδρική άγκυρα', labelHr: 'Rezervno sidro', labelSl: 'Rezervno sidro', labelIt: 'Ancora di scorta'),
    HandoverItemDef('misc_dinghy_oars_pump', 'Veslá a pumpa pre čln', 'Dinghy oars and pump',
        'Riemen und Pumpe für das Beiboot', 'Remos y bomba del bote', 'Весла та помпа для тузика',
        labelCs: 'Vesla a pumpa pro člun', labelPl: 'Wiosła i pompka do pontonu', labelEl: 'Κουπιά και αντλία για τη λέμβο', labelHr: 'Vesla i pumpa za gumenjak', labelSl: 'Vesla in tlačilka za gumenjak', labelIt: 'Remi e pompa del tender'),
    HandoverItemDef('misc_shroud_cutter', 'Shroud cutter (nôž na lanká)', 'Shroud cutter',
        'Wantenschneider', 'Cortaobenques', 'Різак для вант',
        labelCs: 'Shroud cutter (nůž na lanka)', labelPl: 'Obcinak want (nóż do olinowania)', labelEl: 'Κόφτης ξαρτιών', labelHr: 'Rezač sartija', labelSl: 'Rezalnik jamborskih vrvi', labelIt: 'Tronchese tagliasartie'),
  ], labelCs: 'Různé', labelPl: 'Różne', labelEl: 'Διάφορα', labelHr: 'Razno', labelSl: 'Razno', labelIt: 'Varie'),
];

const List<HandoverCategoryDef> checkOutCategories = [
  HandoverCategoryDef('return_yacht', 'Vrátenie jachty', 'Returning the yacht',
      'Rückgabe der Yacht', 'Devolución del yate', 'Повернення яхти', [
    HandoverItemDef('return_yacht_refuel', 'Dotankovať nádrž', 'Refuel the tank',
        'Tank auffüllen', 'Repostar el tanque', 'Дозаправити бак',
        labelCs: 'Zatankovat nádrž', labelPl: 'Zatankować zbiornik', labelEl: 'Ανεφοδιασμός δεξαμενής', labelHr: 'Napuniti tank gorivom', labelSl: 'Napolniti rezervoar z gorivom', labelIt: 'Riempire il serbatoio del carburante'),
    HandoverItemDef('return_yacht_handover_confirmation', 'Získať potvrdenie o odovzdaní jachty',
        'Obtain confirmation of yacht handover',
        'Bestätigung der Yachtübergabe einholen',
        'Obtener confirmación de la entrega del yate',
        'Отримати підтвердження передачі яхти',
        labelCs: 'Získat potvrzení o předání jachty', labelPl: 'Uzyskać potwierdzenie przekazania jachtu', labelEl: 'Λήψη επιβεβαίωσης παράδοσης σκάφους', labelHr: 'Ishoditi potvrdu o primopredaji jahte', labelSl: 'Pridobiti potrdilo o primopredaji jahte', labelIt: 'Ottenere la conferma della riconsegna dello yacht'),
    HandoverItemDef('return_yacht_arrival_time', 'Prísť do mariny v dohodnutom čase',
        'Arrive at the marina at the agreed time',
        'Zur vereinbarten Zeit in der Marina ankommen',
        'Llegar a la marina a la hora acordada',
        'Прибути в марину в узгоджений час',
        labelCs: 'Přijet do maríny v dohodnutém čase', labelPl: 'Przybyć do mariny o umówionej porze', labelEl: 'Άφιξη στη μαρίνα στη συμφωνημένη ώρα', labelHr: 'Doći u marinu u dogovoreno vrijeme', labelSl: 'Priti v marino ob dogovorjenem času', labelIt: 'Arrivare in marina all\'ora concordata'),
    HandoverItemDef('return_yacht_deposit', 'Vrátiť zálohu', 'Return the deposit',
        'Kaution zurückerhalten', 'Devolución de la fianza', 'Повернення застави',
        labelCs: 'Vrátit zálohu', labelPl: 'Zwrot kaucji', labelEl: 'Επιστροφή εγγύησης', labelHr: 'Povrat depozita', labelSl: 'Vračilo varščine', labelIt: 'Restituzione della cauzione'),
    HandoverItemDef('return_yacht_contact_company', 'Kontaktovať charterovú spoločnosť pri príchode do mariny',
        'Contact the charter company on arrival at the marina',
        'Charterfirma bei Ankunft in der Marina kontaktieren',
        'Contactar con la empresa de chárter al llegar a la marina',
        'Зв\'язатися з чартерною компанією після прибуття в марину',
        labelCs: 'Kontaktovat charterovou společnost při příjezdu do maríny', labelPl: 'Skontaktować się z firmą czarterową po przybyciu do mariny', labelEl: 'Επικοινωνία με την εταιρεία ναύλωσης κατά την άφιξη στη μαρίνα', labelHr: 'Javiti se charter tvrtki po dolasku u marinu', labelSl: 'Javiti se čarter podjetju ob prihodu v marino', labelIt: 'Contattare la società di charter all\'arrivo in marina'),
  ], labelCs: 'Vrácení jachty', labelPl: 'Zwrot jachtu', labelEl: 'Επιστροφή σκάφους', labelHr: 'Vraćanje jahte', labelSl: 'Vračanje jahte', labelIt: 'Riconsegna dello yacht'),
  HandoverCategoryDef('cleanliness', 'Čistota a poriadok', 'Cleanliness and order',
      'Sauberkeit und Ordnung', 'Limpieza y orden', 'Чистота та порядок', [
    HandoverItemDef('cleanliness_exterior', 'Loď vyčistená – exteriér', 'Boat cleaned – exterior',
        'Boot gereinigt – außen', 'Barco limpio – exterior', 'Судно прибране – зовні',
        labelCs: 'Loď vyčištěná – exteriér', labelPl: 'Jacht wyczyszczony – na zewnątrz', labelEl: 'Σκάφος καθαρισμένο – εξωτερικά', labelHr: 'Brod očišćen – vanjski dio', labelSl: 'Plovilo očiščeno – zunanjost', labelIt: 'Barca pulita - esterno'),
    HandoverItemDef('cleanliness_interior', 'Loď vyčistená – interiér', 'Boat cleaned – interior',
        'Boot gereinigt – innen', 'Barco limpio – interior', 'Судно прибране – всередині',
        labelCs: 'Loď vyčištěná – interiér', labelPl: 'Jacht wyczyszczony – wewnątrz', labelEl: 'Σκάφος καθαρισμένο – εσωτερικά', labelHr: 'Brod očišćen – unutrašnjost', labelSl: 'Plovilo očiščeno – notranjost', labelIt: 'Barca pulita - interno'),
    HandoverItemDef('cleanliness_cabins', 'Kajuty upratané', 'Cabins tidied',
        'Kajüten aufgeräumt', 'Camarotes ordenados', 'Каюти прибрані',
        labelCs: 'Kajuty uklizené', labelPl: 'Kabiny posprzątane', labelEl: 'Καμπίνες τακτοποιημένες', labelHr: 'Kabine pospremljene', labelSl: 'Kabine pospravljene', labelIt: 'Cabine riordinate'),
    HandoverItemDef('cleanliness_galley', 'Kuchyňa vyčistená', 'Galley cleaned',
        'Pantry gereinigt', 'Cocina limpia', 'Камбуз прибраний',
        labelCs: 'Kuchyně vyčištěná', labelPl: 'Kambuz wyczyszczony', labelEl: 'Μαγειρείο καθαρισμένο', labelHr: 'Kuhinja očišćena', labelSl: 'Kuhinja očiščena', labelIt: 'Cucina pulita'),
    HandoverItemDef('cleanliness_toilet', 'WC vyčistené', 'Toilet cleaned',
        'WC gereinigt', 'Inodoro limpio', 'Гальюн прибраний',
        labelCs: 'WC vyčištěné', labelPl: 'WC wyczyszczone', labelEl: 'Τουαλέτα καθαρισμένη', labelHr: 'Toalet očišćen', labelSl: 'Stranišče očiščeno', labelIt: 'Bagno pulito'),
    HandoverItemDef('cleanliness_trash', 'Odpadky odstránené', 'Trash removed',
        'Müll entsorgt', 'Basura retirada', 'Сміття винесене',
        labelCs: 'Odpadky odstraněny', labelPl: 'Śmieci usunięte', labelEl: 'Σκουπίδια απομακρύνθηκαν', labelHr: 'Smeće uklonjeno', labelSl: 'Smeti odstranjene', labelIt: 'Rifiuti rimossi'),
  ], labelCs: 'Čistota a pořádek', labelPl: 'Czystość i porządek', labelEl: 'Καθαριότητα και τάξη', labelHr: 'Čistoća i red', labelSl: 'Čistoča in red', labelIt: 'Pulizia e ordine'),
  HandoverCategoryDef('technical', 'Technický stav', 'Technical condition',
      'Technischer Zustand', 'Estado técnico', 'Технічний стан', [
    HandoverItemDef('technical_fuel', 'Palivo doplnené', 'Fuel topped up',
        'Kraftstoff aufgefüllt', 'Combustible repostado', 'Паливо долите',
        labelCs: 'Palivo doplněno', labelPl: 'Paliwo uzupełnione', labelEl: 'Καύσιμο συμπληρώθηκε', labelHr: 'Gorivo nadopunjeno', labelSl: 'Gorivo dopolnjeno', labelIt: 'Carburante rifornito'),
    HandoverItemDef('technical_water', 'Voda doplnená', 'Water topped up',
        'Wasser aufgefüllt', 'Agua repostada', 'Вода долита',
        labelCs: 'Voda doplněna', labelPl: 'Woda uzupełniona', labelEl: 'Νερό συμπληρώθηκε', labelHr: 'Voda nadopunjena', labelSl: 'Voda dopolnjena', labelIt: 'Acqua rifornita'),
    HandoverItemDef('technical_damage', 'Poškodenia zdokumentované a hlásené', 'Damage documented and reported',
        'Schäden dokumentiert und gemeldet', 'Daños documentados y comunicados', 'Пошкодження задокументовані та повідомлені',
        labelCs: 'Poškození zdokumentována a nahlášena', labelPl: 'Uszkodzenia udokumentowane i zgłoszone', labelEl: 'Ζημιές καταγράφηκαν και αναφέρθηκαν', labelHr: 'Oštećenja dokumentirana i prijavljena', labelSl: 'Poškodbe dokumentirane in prijavljene', labelIt: 'Danni documentati e segnalati'),
    HandoverItemDef('technical_sails', 'Plachty zložené a zviazané', 'Sails furled and secured',
        'Segel geborgen und gesichert', 'Velas plegadas y trincadas', 'Вітрила згорнуті та закріплені',
        labelCs: 'Plachty složené a svázané', labelPl: 'Żagle zwinięte i zabezpieczone', labelEl: 'Πανιά μαζεμένα και ασφαλισμένα', labelHr: 'Jedra namotana i osigurana', labelSl: 'Jadra zvita in zavarovana', labelIt: 'Vele avvolte e assicurate'),
    HandoverItemDef('technical_lines', 'Laná upratané', 'Lines tidied',
        'Leinen aufgeräumt', 'Cabos ordenados', 'Троси прибрані',
        labelCs: 'Lana uklizena', labelPl: 'Liny uporządkowane', labelEl: 'Σχοινιά τακτοποιημένα', labelHr: 'Konopi pospremljeni', labelSl: 'Vrvi pospravljene', labelIt: 'Cime riordinate'),
  ], labelCs: 'Technický stav', labelPl: 'Stan techniczny', labelEl: 'Τεχνική κατάσταση', labelHr: 'Tehničko stanje', labelSl: 'Tehnično stanje', labelIt: 'Stato tecnico'),
  HandoverCategoryDef('handover', 'Odovzdanie', 'Handover',
      'Übergabe', 'Entrega', 'Передача', [
    HandoverItemDef('handover_keys', 'Kľúče odovzdané', 'Keys handed over',
        'Schlüssel übergeben', 'Llaves entregadas', 'Ключі передані',
        labelCs: 'Klíče předány', labelPl: 'Klucze przekazane', labelEl: 'Κλειδιά παραδόθηκαν', labelHr: 'Ključevi predani', labelSl: 'Ključi predani', labelIt: 'Chiavi consegnate'),
    HandoverItemDef('handover_documents', 'Doklady odovzdané', 'Documents handed over',
        'Dokumente übergeben', 'Documentos entregados', 'Документи передані',
        labelCs: 'Doklady předány', labelPl: 'Dokumenty przekazane', labelEl: 'Έγγραφα παραδόθηκαν', labelHr: 'Dokumenti predani', labelSl: 'Dokumenti predani', labelIt: 'Documenti consegnati'),
    HandoverItemDef('handover_life_jackets', 'Záchranné vesty vrátené', 'Life jackets returned',
        'Rettungswesten zurückgegeben', 'Chalecos salvavidas devueltos', 'Рятувальні жилети повернені',
        labelCs: 'Záchranné vesty vráceny', labelPl: 'Kamizelki ratunkowe zwrócone', labelEl: 'Σωσίβια επιστράφηκαν', labelHr: 'Prsluci za spašavanje vraćeni', labelSl: 'Rešilni jopiči vrnjeni', labelIt: 'Giubbotti di salvataggio restituiti'),
  ], labelCs: 'Předání', labelPl: 'Przekazanie', labelEl: 'Παράδοση', labelHr: 'Primopredaja', labelSl: 'Primopredaja', labelIt: 'Riconsegna'),
];

List<HandoverCategoryDef> _categoriesFor(String type) =>
    type == 'checkOut' ? checkOutCategories : checkInCategories;

/// Popisok položky v aktuálnej lokalizácii appky.
String itemLabel(String localeCode, HandoverItemDef d) => switch (localeCode) {
      'sk' => d.labelSk,
      'de' => d.labelDe,
      'es' => d.labelEs,
      'uk' => d.labelUk,
      'cs' => d.labelCs.isEmpty ? d.labelEn : d.labelCs,
      'pl' => d.labelPl.isEmpty ? d.labelEn : d.labelPl,
      'el' => d.labelEl.isEmpty ? d.labelEn : d.labelEl,
      'hr' => d.labelHr.isEmpty ? d.labelEn : d.labelHr,
      'sl' => d.labelSl.isEmpty ? d.labelEn : d.labelSl,
      'it' => d.labelIt.isEmpty ? d.labelEn : d.labelIt,
      _ => d.labelEn,
    };

String categoryLabel(String localeCode, HandoverCategoryDef c) =>
    switch (localeCode) {
      'sk' => c.labelSk,
      'de' => c.labelDe,
      'es' => c.labelEs,
      'uk' => c.labelUk,
      'cs' => c.labelCs.isEmpty ? c.labelEn : c.labelCs,
      'pl' => c.labelPl.isEmpty ? c.labelEn : c.labelPl,
      'el' => c.labelEl.isEmpty ? c.labelEn : c.labelEl,
      'hr' => c.labelHr.isEmpty ? c.labelEn : c.labelHr,
      'sl' => c.labelSl.isEmpty ? c.labelEn : c.labelSl,
      'it' => c.labelIt.isEmpty ? c.labelEn : c.labelIt,
      _ => c.labelEn,
    };

/// Popis položky do zoznamu aj do dokladu.
///
/// Vlastná položka nesie svoj text so sebou; pevná sa preloží do jazyka
/// appky. Keď sa nenájde ani jedno (protokol z novšej verzie appky), ostane
/// aspoň kľúč — prázdny riadok v podpísanom doklade je horší než slug.
String checklistItemLabel(String localeCode, ChecklistItem item) {
  if (item.isCustom) return item.customLabel!;
  final def = findItemDef(item.itemKey);
  return def == null ? item.itemKey : itemLabel(localeCode, def);
}

/// Kľúč pre novú vlastnú položku. Prefix drží vlastné položky rozoznateľné
/// od pevných aj bez pohľadu do [customLabel].
///
/// K času sa pripája počítadlo: hodiny majú na Windows aj na niektorých
/// Androidoch hrubšie rozlíšenie než mikrosekunda, takže dve položky pridané
/// hneď po sebe by dostali ten istý kľúč a v protokole by sa prepísali.
int _customKeySeq = 0;

String customChecklistKey() =>
    'custom_${DateTime.now().microsecondsSinceEpoch}_${_customKeySeq++}';

/// Nájde definíciu položky podľa kľúča (naprieč oboma checklistmi – slugy
/// sú globálne unikátne).
HandoverItemDef? findItemDef(String itemKey) {
  for (final cat in [...checkInCategories, ...checkOutCategories]) {
    for (final item in cat.items) {
      if (item.key == itemKey) return item;
    }
  }
  return null;
}

List<ChecklistItem> defaultChecklist(String type) => _categoriesFor(type)
    .expand((cat) => cat.items)
    .map((item) => ChecklistItem(itemKey: item.key))
    .toList();

/// Doplní do checklistu vlastné položky skipera, ktoré v ňom ešte nie sú.
///
/// Vlastné položky sú uložené globálne (`CustomSafetyItems`), lebo skiper si
/// tú istú vec píše do každého protokolu. Volá sa aj na existujúci protokol:
/// položka pridaná po jeho založení sa tak objaví aj v ňom — pokiaľ ho už
/// niekto nepodpísal, vtedy je protokol aj tak len na čítanie.
///
/// [customs] je (kategória, popis); položky pre kategórie, ktoré tento typ
/// protokolu nemá, sa ticho preskočia — check-in a check-out majú vlastné
/// kategórie.
List<ChecklistItem> withCustomItems(
  List<ChecklistItem> checklist,
  String type,
  List<({String categoryKey, String label})> customs,
) {
  final categoryKeys = {for (final c in _categoriesFor(type)) c.key};
  final existing = {
    for (final i in checklist)
      if (i.isCustom) '${i.categoryKey}|${i.customLabel}',
  };

  return [
    ...checklist,
    for (final c in customs)
      if (categoryKeys.contains(c.categoryKey) &&
          !existing.contains('${c.categoryKey}|${c.label}'))
        ChecklistItem(
          itemKey: customChecklistKey(),
          customLabel: c.label,
          categoryKey: c.categoryKey,
        ),
  ];
}

List<ChecklistItem> checklistFromJson(String json) {
  final decoded = jsonDecode(json) as List;
  return decoded
      .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

String checklistToJson(List<ChecklistItem> items) =>
    jsonEncode(items.map((e) => e.toJson()).toList());
