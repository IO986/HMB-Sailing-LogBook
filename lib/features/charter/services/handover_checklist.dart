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

/// Definícia jednej položky checklistu (statický obsah, nie stav).
class HandoverItemDef {
  final String key;
  final String labelSk;
  final String labelEn;
  const HandoverItemDef(this.key, this.labelSk, this.labelEn);
}

/// Kategória (skupina) položiek checklistu.
class HandoverCategoryDef {
  final String key;
  final String labelSk;
  final String labelEn;
  final List<HandoverItemDef> items;
  const HandoverCategoryDef(this.key, this.labelSk, this.labelEn, this.items);
}

/// Reálny odovzdávací checklist prevzatý z HMB Príručky (Bezpečnosť tab,
/// `hmb_handbook.dart` `YachtHandoverChecklist`). Check-in a check-out majú
/// odlišný obsah – nie je to ten istý zoznam prechádzaný dvakrát.
const List<HandoverCategoryDef> checkInCategories = [
  HandoverCategoryDef('electrical', 'Elektrické vybavenie', 'Electrical equipment', [
    HandoverItemDef('electrical_switches', 'Vypínače a ističe', 'Switches and breakers'),
    HandoverItemDef('electrical_windlass', 'Kotvový naviják (ankerspill)', 'Anchor windlass'),
    HandoverItemDef('electrical_nav_instruments', 'Navigačné prístroje', 'Navigation instruments'),
    HandoverItemDef('electrical_vhf', 'VHF rádio', 'VHF radio'),
    HandoverItemDef('electrical_battery_indicator', 'Indikátor stavu batérie', 'Battery status indicator'),
    HandoverItemDef('electrical_nav_lights', 'Pozičné svetlá', 'Navigation lights'),
    HandoverItemDef('electrical_autopilot', 'Autopilot', 'Autopilot'),
    HandoverItemDef('electrical_fuses', 'Poistky', 'Fuses'),
    HandoverItemDef('electrical_water_level', 'Indikátor hladiny vody', 'Water level indicator'),
    HandoverItemDef('electrical_spare_bulbs', 'Náhradné žiarovky', 'Spare bulbs'),
    HandoverItemDef('electrical_depth_sounder', 'Lodný sonar (merač hĺbky)', 'Depth sounder'),
    HandoverItemDef('electrical_pumps', 'Čerpadlá (pumpy)', 'Pumps'),
  ]),
  HandoverCategoryDef('engine', 'Motor a palivo', 'Engine and fuel', [
    HandoverItemDef('engine_refuel', 'Dotankovanie', 'Refuelling'),
    HandoverItemDef('engine_vbelt', 'Napnutie V-remeňov', 'V-belt tension'),
    HandoverItemDef('engine_cooling_water', 'Kontrola prívodu chladiacej vody', 'Cooling water intake check'),
    HandoverItemDef('engine_oil', 'Motorový olej', 'Engine oil'),
    HandoverItemDef('engine_fuel_filter', 'Palivový filter', 'Fuel filter'),
    HandoverItemDef('engine_fuel_level', 'Hladina paliva v nádrži', 'Fuel tank level'),
    HandoverItemDef('engine_gearbox_oil', 'Olej v prevodovke', 'Gearbox oil'),
    HandoverItemDef('engine_coolant_level', 'Hladina chladiacej kvapaliny', 'Coolant level'),
    HandoverItemDef('engine_fuel_tank_condition', 'Kontrola stavu palivovej nádrže a jej upevnenia',
        'Fuel tank condition and mounting check'),
  ]),
  HandoverCategoryDef('nav_docs', 'Navigačné pomôcky a doklady', 'Navigation aids and documents', [
    HandoverItemDef('nav_docs_paper_charts', 'Papierové mapy a navigácia', 'Paper charts and navigation'),
    HandoverItemDef('nav_docs_sailing_permit', 'Povolenie na plavbu (sailing permit)', 'Sailing permit'),
    HandoverItemDef('nav_docs_aids', 'Navigačné pomôcky', 'Navigation aids'),
    HandoverItemDef('nav_docs_crew_list', 'Zoznam posádky (crew list)', 'Crew list'),
    HandoverItemDef('nav_docs_binoculars', 'Ďalekohľad', 'Binoculars'),
  ]),
  HandoverCategoryDef('hull', 'Trup lode', 'Hull', [
    HandoverItemDef('hull_deck', 'Paluba lode', 'Deck'),
    HandoverItemDef('hull_bow', 'Prova lode', 'Bow'),
    HandoverItemDef('hull_under_floorboards', 'Priestor pod palubovými doskami', 'Space under the floorboards'),
    HandoverItemDef('hull_stern', 'Záď lode', 'Stern'),
    HandoverItemDef('hull_sides', 'Boky lode', 'Hull sides'),
    HandoverItemDef('hull_underwater', 'Podvodná časť trupu', 'Underwater part of the hull'),
  ]),
  HandoverCategoryDef('safety_gear', 'Bezpečnostné vybavenie', 'Safety equipment', [
    HandoverItemDef('safety_gear_life_jackets', 'Záchranné vesty', 'Life jackets'),
    HandoverItemDef('safety_gear_extinguishers', 'Hasiace prístroje', 'Fire extinguishers'),
    HandoverItemDef('safety_gear_harnesses', 'Bezpečnostné postroje', 'Safety harnesses'),
    HandoverItemDef('safety_gear_flares', 'Svetlice', 'Flares'),
  ]),
  HandoverCategoryDef('galley', 'Kuchyňa', 'Galley', [
    HandoverItemDef('galley_fridge', 'Chladnička', 'Fridge'),
    HandoverItemDef('galley_gas_shutoff', 'Hlavný plynový uzáver', 'Main gas shut-off valve'),
    HandoverItemDef('galley_stove', 'Sporák a jeho upevnenie', 'Stove and its mounting'),
    HandoverItemDef('galley_gas_bottles', 'Plynové fľaše (2 ks)', 'Gas bottles (2 pcs)'),
  ]),
  HandoverCategoryDef('cabins', 'Kajuty', 'Cabins', [
    HandoverItemDef('cabins_bedding', 'Posteľná bielizeň', 'Bedding'),
    HandoverItemDef('cabins_storage', 'Úložné priestory', 'Storage spaces'),
  ]),
  HandoverCategoryDef('water_heads', 'Voda, WC a kúpeľne', 'Water, heads and bathrooms', [
    HandoverItemDef('water_heads_tanks', 'Vodné nádrže', 'Water tanks'),
    HandoverItemDef('water_heads_toilet_valves', 'WC (ventily)', 'Toilet (valves)'),
    HandoverItemDef('water_heads_shower_pump', 'Čerpanie vody zo sprchovej vaničky', 'Shower sump pump'),
    HandoverItemDef('water_heads_waste_tank', 'Prepnutie odpadovej nádrže a vypustenie',
        'Waste tank switch-over and pump-out'),
    HandoverItemDef('water_heads_transom_shower', 'Zadná sprcha', 'Transom shower'),
  ]),
  HandoverCategoryDef('sails_steering', 'Plachty a kormidlovanie', 'Sails and steering', [
    HandoverItemDef('sails_steering_reefing', 'Balenie a reefovanie plachiet – napnutie lán',
        'Sail furling and reefing – line tension'),
    HandoverItemDef('sails_steering_halyards', 'Stav halyárd (zdvíhacích lán)', 'Halyard condition'),
    HandoverItemDef('sails_steering_rudder', 'Kormidlo', 'Rudder'),
    HandoverItemDef('sails_steering_stoppers', 'Stopéry', 'Rope clutches'),
    HandoverItemDef('sails_steering_furling_gear', 'Stav navíjacích zariadení (furling)', 'Furling gear condition'),
    HandoverItemDef('sails_steering_sails', 'Stav plachiet', 'Sail condition'),
    HandoverItemDef('sails_steering_winches', 'Winche', 'Winches'),
    HandoverItemDef('sails_steering_sheets', 'Stav šotových lán', 'Sheet condition'),
  ]),
  HandoverCategoryDef('often_forgotten', 'Často zabudnuté', 'Often forgotten', [
    HandoverItemDef('often_forgotten_bosun_chair_ladder', 'Bosunov rebrík na lezenie na sťažeň',
        'Mast climbing ladder'),
    HandoverItemDef('often_forgotten_spare_vbelt', 'Náhradné V-remene pre hlavný motor',
        'Spare V-belts for the main engine'),
    HandoverItemDef('often_forgotten_bosun_chair', 'Stav bosunového kresla', 'Bosun\'s chair condition'),
    HandoverItemDef('often_forgotten_saltwater_pump_impeller', 'Gumový impulzný kolektor pre čerpadlo slanej vody',
        'Raw water pump impeller'),
    HandoverItemDef('often_forgotten_halyard_condition', 'Stav zdvíhacieho lana', 'Hoisting line condition'),
    HandoverItemDef('often_forgotten_dinghy_condition', 'Stav člna (dinghy)', 'Dinghy condition'),
  ]),
  HandoverCategoryDef('misc', 'Rôzne', 'Miscellaneous', [
    HandoverItemDef('misc_spare_rudder', 'Náhradné kormidlo', 'Spare rudder'),
    HandoverItemDef('misc_bucket_brush_sponge', 'Vedro, kefa, špongia', 'Bucket, brush, sponge'),
    HandoverItemDef('misc_oar_locks', 'Háky na veslá člna', 'Dinghy oar locks'),
    HandoverItemDef('misc_lifebuoy', 'Záchranný kruh alebo podkova', 'Lifebuoy or horseshoe buoy'),
    HandoverItemDef('misc_anchor_lines', 'Kotvové laná', 'Anchor lines'),
    HandoverItemDef('misc_bilge_pump', 'Ručná bilge pumpa', 'Manual bilge pump'),
    HandoverItemDef('misc_extension_cable', 'Predlžovací elektrický kábel', 'Electrical extension cable'),
    HandoverItemDef('misc_lifebuoy_light', 'Záchranná bója so svetlom', 'Lifebuoy with light'),
    HandoverItemDef('misc_spare_anchor', 'Záložná kotva', 'Spare anchor'),
    HandoverItemDef('misc_dinghy_oars_pump', 'Veslá a pumpa pre čln', 'Dinghy oars and pump'),
    HandoverItemDef('misc_shroud_cutter', 'Shroud cutter (nôž na lanká)', 'Shroud cutter'),
  ]),
];

const List<HandoverCategoryDef> checkOutCategories = [
  HandoverCategoryDef('return_yacht', 'Vrátenie jachty', 'Returning the yacht', [
    HandoverItemDef('return_yacht_refuel', 'Dotankovať nádrž', 'Refuel the tank'),
    HandoverItemDef('return_yacht_handover_confirmation', 'Získať potvrdenie o odovzdaní jachty',
        'Obtain confirmation of yacht handover'),
    HandoverItemDef('return_yacht_arrival_time', 'Prísť do mariny v dohodnutom čase',
        'Arrive at the marina at the agreed time'),
    HandoverItemDef('return_yacht_deposit', 'Vrátiť zálohu', 'Return the deposit'),
    HandoverItemDef('return_yacht_contact_company', 'Kontaktovať charterovú spoločnosť pri príchode do mariny',
        'Contact the charter company on arrival at the marina'),
  ]),
  HandoverCategoryDef('cleanliness', 'Čistota a poriadok', 'Cleanliness and order', [
    HandoverItemDef('cleanliness_exterior', 'Loď vyčistená – exteriér', 'Boat cleaned – exterior'),
    HandoverItemDef('cleanliness_interior', 'Loď vyčistená – interiér', 'Boat cleaned – interior'),
    HandoverItemDef('cleanliness_cabins', 'Kajuty upratané', 'Cabins tidied'),
    HandoverItemDef('cleanliness_galley', 'Kuchyňa vyčistená', 'Galley cleaned'),
    HandoverItemDef('cleanliness_toilet', 'WC vyčistené', 'Toilet cleaned'),
    HandoverItemDef('cleanliness_trash', 'Odpadky odstránené', 'Trash removed'),
  ]),
  HandoverCategoryDef('technical', 'Technický stav', 'Technical condition', [
    HandoverItemDef('technical_fuel', 'Palivo doplnené', 'Fuel topped up'),
    HandoverItemDef('technical_water', 'Voda doplnená', 'Water topped up'),
    HandoverItemDef('technical_damage', 'Poškodenia zdokumentované a hlásené', 'Damage documented and reported'),
    HandoverItemDef('technical_sails', 'Plachty zložené a zviazané', 'Sails furled and secured'),
    HandoverItemDef('technical_lines', 'Laná upratané', 'Lines tidied'),
  ]),
  HandoverCategoryDef('handover', 'Odovzdanie', 'Handover', [
    HandoverItemDef('handover_keys', 'Kľúče odovzdané', 'Keys handed over'),
    HandoverItemDef('handover_documents', 'Doklady odovzdané', 'Documents handed over'),
    HandoverItemDef('handover_life_jackets', 'Záchranné vesty vrátené', 'Life jackets returned'),
  ]),
];

List<HandoverCategoryDef> _categoriesFor(String type) =>
    type == 'checkOut' ? checkOutCategories : checkInCategories;

/// Popisok položky v aktuálnej lokalizácii. Pre `sk` vráti slovenský text
/// (volajúci si popri tom môže zvlášť zobraziť EN glosu malým písmom);
/// pre ostatné jazyky appky (en/de/es/uk) sa vracia anglický text
/// (fallback – checklist nie je plne preložený do všetkých 5 jazykov).
String itemLabel(String localeCode, HandoverItemDef d) =>
    localeCode == 'sk' ? d.labelSk : d.labelEn;

String categoryLabel(String localeCode, HandoverCategoryDef c) =>
    localeCode == 'sk' ? c.labelSk : c.labelEn;

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
