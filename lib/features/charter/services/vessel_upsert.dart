import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';

/// Údaje lode tak, ako ich vyplnil formulár plavby.
///
/// Medzikrok medzi obrazovkou a databázou: obrazovka drží
/// `TextEditingController`-y a testovať sa nedá, databáza pozná len companion.
/// Tu je to, čo sa medzi nimi môže pokaziť — a to sa otestovať dá.
class VesselDraft {
  const VesselDraft({
    required this.name,
    this.model,
    this.vesselType,
    this.callsign,
    this.mmsi,
    this.lengthM,
    this.beamM,
    this.draftM,
    this.berths,
    this.yearBuilt,
    this.engine,
    this.waterTankL,
    this.fuelTankL,
    this.homePort,
    this.country,
    this.isOwn = false,
  });

  final String name;
  final String? model;
  final String? vesselType;
  final String? callsign;
  final String? mmsi;
  final double? lengthM;
  final double? beamM;
  final double? draftM;
  final int? berths;
  final int? yearBuilt;
  final String? engine;
  final double? waterTankL;
  final double? fuelTankL;
  final String? homePort;
  final String? country;
  final bool isOwn;

  /// [keepMissing] necháva prázdne polia na pokoji namiesto toho, aby ich
  /// zapísalo ako NULL.
  ///
  /// Rozdiel je celý zmysel zoznamu lodí. Keď skiper loď VYBRAL zo zoznamu
  /// a upravuje jej kartu, prázdne pole znamená „zmaž to" — inak by sa
  /// vymyslený údaj nedal odstrániť. Keď sa loď našla len podľa mena (plavba
  /// založená rýchlym štartom, staršia plavba s chudobnejšou kartou), prázdne
  /// pole znamená „o tomto neviem" a MMSI, volací znak či rozmery uložené
  /// z minula sa prepísať na NULL nesmú.
  VesselsCompanion toCompanion({
    DateTime? usedAt,
    bool keepMissing = false,
  }) {
    Value<T> v<T>(T? value) => value == null && keepMissing
        ? const Value.absent()
        : Value(value as T);

    return VesselsCompanion(
      name: Value(name.trim()),
      model: v(model),
      vesselType: v(vesselType),
      callsign: v(callsign),
      mmsi: v(mmsi),
      lengthM: v(lengthM),
      beamM: v(beamM),
      draftM: v(draftM),
      berths: v(berths),
      yearBuilt: v(yearBuilt),
      engine: v(engine),
      waterTankL: v(waterTankL),
      fuelTankL: v(fuelTankL),
      homePort: v(homePort),
      country: v(country),
      isOwn: Value(isOwn),
      lastUsedAt: Value(usedAt ?? DateTime.now()),
    );
  }
}

/// Uloží loď z formulára do zoznamu lodí a vráti jej id.
///
/// Kto pláva stále na tej istej lodi, nemá pri každej plavbe prepisovať model,
/// volací znak, MMSI, rozmery a nádrže. Preto:
///
/// * [knownId] (loď vybraná zo zoznamu) má prednosť — premenovanie lode potom
///   prepíše ten istý riadok a nezaloží druhý;
/// * inak sa hľadá podľa mena, aby dve plavby na „Perune" neurobili dva Peruny;
/// * prázdne meno neukladá nič — loď bez mena nie je loď.
///
/// Vracia `null`, keď sa neuložilo nič.
Future<int?> upsertVesselFromDraft(
  AppDatabase db,
  VesselDraft draft, {
  int? knownId,
  DateTime? now,
}) async {
  final name = draft.name.trim();
  if (name.isEmpty) return null;

  final picked = knownId != null ? await db.getVesselById(knownId) : null;
  final existing = picked ?? await db.findVesselByName(name);

  if (existing == null) {
    final data = draft.toCompanion(usedAt: now);
    final created =
        await db.insertVessel(data.copyWith(createdAt: Value(now ?? DateTime.now())));
    return created.id;
  }

  // Loď vybraná zo zoznamu sa edituje celá — vymazané pole sa naozaj vymaže.
  // Loď nájdená podľa mena sa len dopĺňa: čo formulár nenesie, ostáva.
  final data = draft.toCompanion(usedAt: now, keepMissing: picked == null);
  await db.updateVessel(data.copyWith(id: Value(existing.id)));
  return existing.id;
}
