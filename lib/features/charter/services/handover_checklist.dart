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

  const ChecklistItem({
    required this.itemKey,
    this.status = ChecklistStatus.ok,
    this.note,
    this.photoPath,
    this.position,
  });

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
      );

  Map<String, dynamic> toJson() => {
        'itemKey': itemKey,
        'status': status.name,
        if (note != null) 'note': note,
        if (photoPath != null) 'photoPath': photoPath,
        if (position != null) 'position': position,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        itemKey: json['itemKey'] as String,
        status: _statusFromString(json['status'] as String? ?? 'ok'),
        note: json['note'] as String?,
        photoPath: json['photoPath'] as String?,
        position: json['position'] as String?,
      );
}

/// Definícia jednej položky checklistu (statický obsah, nie stav) —
/// popisky vo všetkých 5 jazykoch appky.
class HandoverItemDef {
  final String key;
  final String labelSk;
  final String labelEn;
  final String labelDe;
  final String labelEs;
  final String labelUk;
  const HandoverItemDef(this.key, this.labelSk, this.labelEn, this.labelDe,
      this.labelEs, this.labelUk);
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
  const HandoverCategoryDef(this.key, this.labelSk, this.labelEn, this.labelDe,
      this.labelEs, this.labelUk, this.items);
}

/// Reálny odovzdávací checklist prevzatý z HMB Príručky (Bezpečnosť tab).
/// Check-in a check-out majú odlišný obsah – nie je to ten istý zoznam
/// prechádzaný dvakrát.
const List<HandoverCategoryDef> checkInCategories = [
  HandoverCategoryDef('electrical', 'Elektrické vybavenie', 'Electrical equipment',
      'Elektrische Ausrüstung', 'Equipo eléctrico', 'Електрообладнання', [
    HandoverItemDef('electrical_switches', 'Vypínače a ističe', 'Switches and breakers',
        'Schalter und Sicherungsautomaten', 'Interruptores y disyuntores', 'Вимикачі та автомати'),
    HandoverItemDef('electrical_windlass', 'Kotvový naviják (ankerspill)', 'Anchor windlass',
        'Ankerwinde', 'Molinete del ancla', 'Якірна лебідка'),
    HandoverItemDef('electrical_nav_instruments', 'Navigačné prístroje', 'Navigation instruments',
        'Navigationsinstrumente', 'Instrumentos de navegación', 'Навігаційні прилади'),
    HandoverItemDef('electrical_vhf', 'VHF rádio', 'VHF radio',
        'UKW-Funkgerät', 'Radio VHF', 'Радіостанція VHF'),
    HandoverItemDef('electrical_battery_indicator', 'Indikátor stavu batérie', 'Battery status indicator',
        'Batteriestandsanzeige', 'Indicador de estado de batería', 'Індикатор стану батареї'),
    HandoverItemDef('electrical_nav_lights', 'Pozičné svetlá', 'Navigation lights',
        'Positionslichter', 'Luces de navegación', 'Ходові вогні'),
    HandoverItemDef('electrical_autopilot', 'Autopilot', 'Autopilot',
        'Autopilot', 'Piloto automático', 'Автопілот'),
    HandoverItemDef('electrical_fuses', 'Poistky', 'Fuses',
        'Sicherungen', 'Fusibles', 'Запобіжники'),
    HandoverItemDef('electrical_water_level', 'Indikátor hladiny vody', 'Water level indicator',
        'Wasserstandsanzeige', 'Indicador de nivel de agua', 'Індикатор рівня води'),
    HandoverItemDef('electrical_spare_bulbs', 'Náhradné žiarovky', 'Spare bulbs',
        'Ersatzglühbirnen', 'Bombillas de repuesto', 'Запасні лампочки'),
    HandoverItemDef('electrical_depth_sounder', 'Lodný sonar (merač hĺbky)', 'Depth sounder',
        'Echolot', 'Sonda de profundidad', 'Ехолот'),
    HandoverItemDef('electrical_pumps', 'Čerpadlá (pumpy)', 'Pumps',
        'Pumpen', 'Bombas', 'Помпи'),
  ]),
  HandoverCategoryDef('engine', 'Motor a palivo', 'Engine and fuel',
      'Motor und Kraftstoff', 'Motor y combustible', 'Двигун і паливо', [
    HandoverItemDef('engine_refuel', 'Dotankovanie', 'Refuelling',
        'Auftanken', 'Repostaje', 'Дозаправлення'),
    HandoverItemDef('engine_vbelt', 'Napnutie V-remeňov', 'V-belt tension',
        'Keilriemenspannung', 'Tensión de las correas', 'Натяг клинових ременів'),
    HandoverItemDef('engine_cooling_water', 'Kontrola prívodu chladiacej vody', 'Cooling water intake check',
        'Kühlwasserzufuhr prüfen', 'Comprobación de la toma de agua de refrigeración', 'Перевірка подачі охолоджувальної води'),
    HandoverItemDef('engine_oil', 'Motorový olej', 'Engine oil',
        'Motoröl', 'Aceite del motor', 'Моторна олива'),
    HandoverItemDef('engine_fuel_filter', 'Palivový filter', 'Fuel filter',
        'Kraftstofffilter', 'Filtro de combustible', 'Паливний фільтр'),
    HandoverItemDef('engine_fuel_level', 'Hladina paliva v nádrži', 'Fuel tank level',
        'Füllstand des Kraftstofftanks', 'Nivel del tanque de combustible', 'Рівень палива в баку'),
    HandoverItemDef('engine_gearbox_oil', 'Olej v prevodovke', 'Gearbox oil',
        'Getriebeöl', 'Aceite de la transmisión', 'Олива в редукторі'),
    HandoverItemDef('engine_coolant_level', 'Hladina chladiacej kvapaliny', 'Coolant level',
        'Kühlmittelstand', 'Nivel de refrigerante', 'Рівень охолоджувальної рідини'),
    HandoverItemDef('engine_fuel_tank_condition', 'Kontrola stavu palivovej nádrže a jej upevnenia',
        'Fuel tank condition and mounting check',
        'Zustand und Befestigung des Kraftstofftanks prüfen',
        'Comprobación del estado y la sujeción del tanque de combustible',
        'Перевірка стану паливного бака та його кріплення'),
  ]),
  HandoverCategoryDef('nav_docs', 'Navigačné pomôcky a doklady', 'Navigation aids and documents',
      'Navigationshilfen und Dokumente', 'Ayudas a la navegación y documentos', 'Навігаційні засоби та документи', [
    HandoverItemDef('nav_docs_paper_charts', 'Papierové mapy a navigácia', 'Paper charts and navigation',
        'Papierseekarten und Navigation', 'Cartas náuticas de papel y navegación', 'Паперові карти та навігація'),
    HandoverItemDef('nav_docs_sailing_permit', 'Povolenie na plavbu (sailing permit)', 'Sailing permit',
        'Fahrterlaubnis (Sailing Permit)', 'Permiso de navegación', 'Дозвіл на плавання'),
    HandoverItemDef('nav_docs_aids', 'Navigačné pomôcky', 'Navigation aids',
        'Navigationshilfen', 'Ayudas a la navegación', 'Навігаційні засоби'),
    HandoverItemDef('nav_docs_crew_list', 'Zoznam posádky (crew list)', 'Crew list',
        'Crew-Liste', 'Lista de tripulación', 'Список екіпажу'),
    HandoverItemDef('nav_docs_binoculars', 'Ďalekohľad', 'Binoculars',
        'Fernglas', 'Prismáticos', 'Бінокль'),
  ]),
  HandoverCategoryDef('hull', 'Trup lode', 'Hull',
      'Rumpf', 'Casco', 'Корпус', [
    HandoverItemDef('hull_deck', 'Paluba lode', 'Deck',
        'Deck', 'Cubierta', 'Палуба'),
    HandoverItemDef('hull_bow', 'Prova lode', 'Bow',
        'Bug', 'Proa', 'Ніс судна'),
    HandoverItemDef('hull_under_floorboards', 'Priestor pod palubovými doskami', 'Space under the floorboards',
        'Raum unter den Bodenbrettern', 'Espacio bajo las tablas del suelo', 'Простір під пайолами'),
    HandoverItemDef('hull_stern', 'Záď lode', 'Stern',
        'Heck', 'Popa', 'Корма'),
    HandoverItemDef('hull_sides', 'Boky lode', 'Hull sides',
        'Rumpfseiten', 'Costados del casco', 'Борти корпусу'),
    HandoverItemDef('hull_underwater', 'Podvodná časť trupu', 'Underwater part of the hull',
        'Unterwasserschiff', 'Obra viva del casco', 'Підводна частина корпусу'),
  ]),
  HandoverCategoryDef('safety_gear', 'Bezpečnostné vybavenie', 'Safety equipment',
      'Sicherheitsausrüstung', 'Equipo de seguridad', 'Засоби безпеки', [
    HandoverItemDef('safety_gear_life_jackets', 'Záchranné vesty', 'Life jackets',
        'Rettungswesten', 'Chalecos salvavidas', 'Рятувальні жилети'),
    HandoverItemDef('safety_gear_extinguishers', 'Hasiace prístroje', 'Fire extinguishers',
        'Feuerlöscher', 'Extintores', 'Вогнегасники'),
    HandoverItemDef('safety_gear_harnesses', 'Bezpečnostné postroje', 'Safety harnesses',
        'Sicherheitsgurte (Lifebelts)', 'Arneses de seguridad', 'Страхувальні обв\'язки'),
    HandoverItemDef('safety_gear_flares', 'Svetlice', 'Flares',
        'Signalraketen', 'Bengalas', 'Сигнальні ракети'),
  ]),
  HandoverCategoryDef('galley', 'Kuchyňa', 'Galley',
      'Pantry (Galley)', 'Cocina', 'Камбуз', [
    HandoverItemDef('galley_fridge', 'Chladnička', 'Fridge',
        'Kühlschrank', 'Nevera', 'Холодильник'),
    HandoverItemDef('galley_gas_shutoff', 'Hlavný plynový uzáver', 'Main gas shut-off valve',
        'Gashaupthahn', 'Válvula principal de corte de gas', 'Головний газовий кран'),
    HandoverItemDef('galley_stove', 'Sporák a jeho upevnenie', 'Stove and its mounting',
        'Herd und seine Befestigung', 'Cocina y su sujeción', 'Плита та її кріплення'),
    HandoverItemDef('galley_gas_bottles', 'Plynové fľaše (2 ks)', 'Gas bottles (2 pcs)',
        'Gasflaschen (2 Stück)', 'Bombonas de gas (2 uds.)', 'Газові балони (2 шт.)'),
  ]),
  HandoverCategoryDef('cabins', 'Kajuty', 'Cabins',
      'Kajüten', 'Camarotes', 'Каюти', [
    HandoverItemDef('cabins_bedding', 'Posteľná bielizeň', 'Bedding',
        'Bettwäsche', 'Ropa de cama', 'Постільна білизна'),
    HandoverItemDef('cabins_storage', 'Úložné priestory', 'Storage spaces',
        'Stauräume', 'Espacios de almacenamiento', 'Місця зберігання'),
  ]),
  HandoverCategoryDef('water_heads', 'Voda, WC a kúpeľne', 'Water, heads and bathrooms',
      'Wasser, WC und Bäder', 'Agua, baños y aseos', 'Вода, гальюни та ванні', [
    HandoverItemDef('water_heads_tanks', 'Vodné nádrže', 'Water tanks',
        'Wassertanks', 'Tanques de agua', 'Баки для води'),
    HandoverItemDef('water_heads_toilet_valves', 'WC (ventily)', 'Toilet (valves)',
        'WC (Ventile)', 'Inodoro (válvulas)', 'Гальюн (клапани)'),
    HandoverItemDef('water_heads_shower_pump', 'Čerpanie vody zo sprchovej vaničky', 'Shower sump pump',
        'Duschwannen-Lenzpumpe', 'Bomba de achique de la ducha', 'Помпа душового піддона'),
    HandoverItemDef('water_heads_waste_tank', 'Prepnutie odpadovej nádrže a vypustenie',
        'Waste tank switch-over and pump-out',
        'Umschalten und Entleeren des Fäkalientanks',
        'Conmutación y vaciado del tanque de aguas negras',
        'Перемикання та випорожнення фекального бака'),
    HandoverItemDef('water_heads_transom_shower', 'Zadná sprcha', 'Transom shower',
        'Heckdusche', 'Ducha de popa', 'Кормовий душ'),
  ]),
  HandoverCategoryDef('sails_steering', 'Plachty a kormidlovanie', 'Sails and steering',
      'Segel und Steuerung', 'Velas y gobierno', 'Вітрила та кермування', [
    HandoverItemDef('sails_steering_reefing', 'Balenie a reefovanie plachiet – napnutie lán',
        'Sail furling and reefing – line tension',
        'Segel einrollen und reffen – Leinenspannung',
        'Enrollado y rizado de velas – tensión de cabos',
        'Згортання та рифлення вітрил – натяг тросів'),
    HandoverItemDef('sails_steering_halyards', 'Stav halyárd (zdvíhacích lán)', 'Halyard condition',
        'Zustand der Fallen', 'Estado de las drizas', 'Стан фалів'),
    HandoverItemDef('sails_steering_rudder', 'Kormidlo', 'Rudder',
        'Ruder', 'Timón', 'Кермо'),
    HandoverItemDef('sails_steering_stoppers', 'Stopéry', 'Rope clutches',
        'Fallenstopper', 'Mordazas', 'Стопори'),
    HandoverItemDef('sails_steering_furling_gear', 'Stav navíjacích zariadení (furling)', 'Furling gear condition',
        'Zustand der Rollanlagen', 'Estado de los enrolladores', 'Стан закруток (фурлерів)'),
    HandoverItemDef('sails_steering_sails', 'Stav plachiet', 'Sail condition',
        'Zustand der Segel', 'Estado de las velas', 'Стан вітрил'),
    HandoverItemDef('sails_steering_winches', 'Winche', 'Winches',
        'Winschen', 'Winches', 'Лебідки'),
    HandoverItemDef('sails_steering_sheets', 'Stav šotových lán', 'Sheet condition',
        'Zustand der Schoten', 'Estado de las escotas', 'Стан шкотів'),
  ]),
  HandoverCategoryDef('often_forgotten', 'Často zabudnuté', 'Often forgotten',
      'Oft vergessen', 'A menudo olvidado', 'Часто забувають', [
    HandoverItemDef('often_forgotten_bosun_chair_ladder', 'Bosunov rebrík na lezenie na sťažeň',
        'Mast climbing ladder',
        'Mastleiter', 'Escalera para subir al mástil', 'Драбина для підйому на щоглу'),
    HandoverItemDef('often_forgotten_spare_vbelt', 'Náhradné V-remene pre hlavný motor',
        'Spare V-belts for the main engine',
        'Ersatz-Keilriemen für den Hauptmotor',
        'Correas de repuesto para el motor principal',
        'Запасні клинові ремені для головного двигуна'),
    HandoverItemDef('often_forgotten_bosun_chair', 'Stav bosunového kresla', 'Bosun\'s chair condition',
        'Zustand des Bootsmannsstuhls', 'Estado de la silla de contramaestre', 'Стан боцманського крісла'),
    HandoverItemDef('often_forgotten_saltwater_pump_impeller', 'Gumový impulzný kolektor pre čerpadlo slanej vody',
        'Raw water pump impeller',
        'Impeller der Seewasserpumpe', 'Rodete de la bomba de agua salada', 'Імпелер помпи забортної води'),
    HandoverItemDef('often_forgotten_halyard_condition', 'Stav zdvíhacieho lana', 'Hoisting line condition',
        'Zustand der Hissleine', 'Estado del cabo de izado', 'Стан підіймального троса'),
    HandoverItemDef('often_forgotten_dinghy_condition', 'Stav člna (dinghy)', 'Dinghy condition',
        'Zustand des Beiboots', 'Estado del bote auxiliar', 'Стан тузика (дінгі)'),
  ]),
  HandoverCategoryDef('misc', 'Rôzne', 'Miscellaneous',
      'Verschiedenes', 'Varios', 'Різне', [
    HandoverItemDef('misc_spare_rudder', 'Náhradné kormidlo', 'Spare rudder',
        'Notruder', 'Timón de repuesto', 'Запасне кермо'),
    HandoverItemDef('misc_bucket_brush_sponge', 'Vedro, kefa, špongia', 'Bucket, brush, sponge',
        'Eimer, Bürste, Schwamm', 'Cubo, cepillo, esponja', 'Відро, щітка, губка'),
    HandoverItemDef('misc_oar_locks', 'Háky na veslá člna', 'Dinghy oar locks',
        'Ruderdollen des Beiboots', 'Chumaceras del bote', 'Кочети для весел тузика'),
    HandoverItemDef('misc_lifebuoy', 'Záchranný kruh alebo podkova', 'Lifebuoy or horseshoe buoy',
        'Rettungsring oder Hufeisen-Rettungsmittel', 'Aro o herradura salvavidas', 'Рятувальний круг або підкова'),
    HandoverItemDef('misc_anchor_lines', 'Kotvové laná', 'Anchor lines',
        'Ankerleinen', 'Cabos del ancla', 'Якірні троси'),
    HandoverItemDef('misc_bilge_pump', 'Ručná bilge pumpa', 'Manual bilge pump',
        'Handlenzpumpe', 'Bomba de achique manual', 'Ручна трюмна помпа'),
    HandoverItemDef('misc_extension_cable', 'Predlžovací elektrický kábel', 'Electrical extension cable',
        'Verlängerungskabel', 'Cable alargador eléctrico', 'Електричний подовжувач'),
    HandoverItemDef('misc_lifebuoy_light', 'Záchranná bója so svetlom', 'Lifebuoy with light',
        'Rettungsboje mit Licht', 'Boya salvavidas con luz', 'Рятувальний буй зі світлом'),
    HandoverItemDef('misc_spare_anchor', 'Záložná kotva', 'Spare anchor',
        'Ersatzanker', 'Ancla de respeto', 'Запасний якір'),
    HandoverItemDef('misc_dinghy_oars_pump', 'Veslá a pumpa pre čln', 'Dinghy oars and pump',
        'Riemen und Pumpe für das Beiboot', 'Remos y bomba del bote', 'Весла та помпа для тузика'),
    HandoverItemDef('misc_shroud_cutter', 'Shroud cutter (nôž na lanká)', 'Shroud cutter',
        'Wantenschneider', 'Cortaobenques', 'Різак для вант'),
  ]),
];

const List<HandoverCategoryDef> checkOutCategories = [
  HandoverCategoryDef('return_yacht', 'Vrátenie jachty', 'Returning the yacht',
      'Rückgabe der Yacht', 'Devolución del yate', 'Повернення яхти', [
    HandoverItemDef('return_yacht_refuel', 'Dotankovať nádrž', 'Refuel the tank',
        'Tank auffüllen', 'Repostar el tanque', 'Дозаправити бак'),
    HandoverItemDef('return_yacht_handover_confirmation', 'Získať potvrdenie o odovzdaní jachty',
        'Obtain confirmation of yacht handover',
        'Bestätigung der Yachtübergabe einholen',
        'Obtener confirmación de la entrega del yate',
        'Отримати підтвердження передачі яхти'),
    HandoverItemDef('return_yacht_arrival_time', 'Prísť do mariny v dohodnutom čase',
        'Arrive at the marina at the agreed time',
        'Zur vereinbarten Zeit in der Marina ankommen',
        'Llegar a la marina a la hora acordada',
        'Прибути в марину в узгоджений час'),
    HandoverItemDef('return_yacht_deposit', 'Vrátiť zálohu', 'Return the deposit',
        'Kaution zurückerhalten', 'Devolución de la fianza', 'Повернення застави'),
    HandoverItemDef('return_yacht_contact_company', 'Kontaktovať charterovú spoločnosť pri príchode do mariny',
        'Contact the charter company on arrival at the marina',
        'Charterfirma bei Ankunft in der Marina kontaktieren',
        'Contactar con la empresa de chárter al llegar a la marina',
        'Зв\'язатися з чартерною компанією після прибуття в марину'),
  ]),
  HandoverCategoryDef('cleanliness', 'Čistota a poriadok', 'Cleanliness and order',
      'Sauberkeit und Ordnung', 'Limpieza y orden', 'Чистота та порядок', [
    HandoverItemDef('cleanliness_exterior', 'Loď vyčistená – exteriér', 'Boat cleaned – exterior',
        'Boot gereinigt – außen', 'Barco limpio – exterior', 'Судно прибране – зовні'),
    HandoverItemDef('cleanliness_interior', 'Loď vyčistená – interiér', 'Boat cleaned – interior',
        'Boot gereinigt – innen', 'Barco limpio – interior', 'Судно прибране – всередині'),
    HandoverItemDef('cleanliness_cabins', 'Kajuty upratané', 'Cabins tidied',
        'Kajüten aufgeräumt', 'Camarotes ordenados', 'Каюти прибрані'),
    HandoverItemDef('cleanliness_galley', 'Kuchyňa vyčistená', 'Galley cleaned',
        'Pantry gereinigt', 'Cocina limpia', 'Камбуз прибраний'),
    HandoverItemDef('cleanliness_toilet', 'WC vyčistené', 'Toilet cleaned',
        'WC gereinigt', 'Inodoro limpio', 'Гальюн прибраний'),
    HandoverItemDef('cleanliness_trash', 'Odpadky odstránené', 'Trash removed',
        'Müll entsorgt', 'Basura retirada', 'Сміття винесене'),
  ]),
  HandoverCategoryDef('technical', 'Technický stav', 'Technical condition',
      'Technischer Zustand', 'Estado técnico', 'Технічний стан', [
    HandoverItemDef('technical_fuel', 'Palivo doplnené', 'Fuel topped up',
        'Kraftstoff aufgefüllt', 'Combustible repostado', 'Паливо долите'),
    HandoverItemDef('technical_water', 'Voda doplnená', 'Water topped up',
        'Wasser aufgefüllt', 'Agua repostada', 'Вода долита'),
    HandoverItemDef('technical_damage', 'Poškodenia zdokumentované a hlásené', 'Damage documented and reported',
        'Schäden dokumentiert und gemeldet', 'Daños documentados y comunicados', 'Пошкодження задокументовані та повідомлені'),
    HandoverItemDef('technical_sails', 'Plachty zložené a zviazané', 'Sails furled and secured',
        'Segel geborgen und gesichert', 'Velas plegadas y trincadas', 'Вітрила згорнуті та закріплені'),
    HandoverItemDef('technical_lines', 'Laná upratané', 'Lines tidied',
        'Leinen aufgeräumt', 'Cabos ordenados', 'Троси прибрані'),
  ]),
  HandoverCategoryDef('handover', 'Odovzdanie', 'Handover',
      'Übergabe', 'Entrega', 'Передача', [
    HandoverItemDef('handover_keys', 'Kľúče odovzdané', 'Keys handed over',
        'Schlüssel übergeben', 'Llaves entregadas', 'Ключі передані'),
    HandoverItemDef('handover_documents', 'Doklady odovzdané', 'Documents handed over',
        'Dokumente übergeben', 'Documentos entregados', 'Документи передані'),
    HandoverItemDef('handover_life_jackets', 'Záchranné vesty vrátené', 'Life jackets returned',
        'Rettungswesten zurückgegeben', 'Chalecos salvavidas devueltos', 'Рятувальні жилети повернені'),
  ]),
];

List<HandoverCategoryDef> _categoriesFor(String type) =>
    type == 'checkOut' ? checkOutCategories : checkInCategories;

/// Popisok položky v aktuálnej lokalizácii appky.
String itemLabel(String localeCode, HandoverItemDef d) => switch (localeCode) {
      'sk' => d.labelSk,
      'de' => d.labelDe,
      'es' => d.labelEs,
      'uk' => d.labelUk,
      _ => d.labelEn,
    };

String categoryLabel(String localeCode, HandoverCategoryDef c) =>
    switch (localeCode) {
      'sk' => c.labelSk,
      'de' => c.labelDe,
      'es' => c.labelEs,
      'uk' => c.labelUk,
      _ => c.labelEn,
    };

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

List<ChecklistItem> checklistFromJson(String json) {
  final decoded = jsonDecode(json) as List;
  return decoded
      .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

String checklistToJson(List<ChecklistItem> items) =>
    jsonEncode(items.map((e) => e.toJson()).toList());
