/// Kurz plachetnice voči vetru a bok, na ktorom vietor prichádza.
///
/// Papierový lodný denník to má ako jedno políčko: silueta lode s polohami po
/// oboch bokoch a pod ňou riadky `S-` a `P-`. Je to jeden údaj v dvoch
/// súradniciach — „beam reach na pravoboku" — a appka to tak aj ukladá:
/// [PointOfSail] a [Tack] vedľa seba.
///
/// Nezamieňať so `sailMode` (motor/hlavná/genova). Ten hovorí, ČO je
/// vytiahnuté; toto hovorí, KAM sa ide voči vetru.
///
/// Čistý Dart zámerne: bez driftu a bez Flutteru, aby sa dal testovať priamo.
library;

/// Poloha lode voči vetru, od ostro proti vetru po vietor zozadu.
///
/// Kódy sa nikdy neprekladajú — v databáze aj v exporte stojí `beam_reach`,
/// nech je appka v akomkoľvek jazyku. Preklad je vecou UI.
enum PointOfSail {
  /// Ostro proti vetru, zhruba 30–50° od smeru vetra.
  closeHauled('close_hauled'),

  /// Uvoľnené proti vetru, zhruba 50–80°.
  closeReach('close_reach'),

  /// Vietor kolmo z boku, zhruba 90°.
  beamReach('beam_reach'),

  /// Vietor zozadu z boku, zhruba 100–160°.
  broadReach('broad_reach'),

  /// Vietor priamo zozadu. Jediná poloha, ktorá bok nerozlišuje — na papieri
  /// preto stojí v strede pod siluetou.
  running('running');

  const PointOfSail(this.code);

  final String code;

  static PointOfSail? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final v in values) {
      if (v.code == code) return v;
    }
    return null;
  }
}

/// Bok, na ktorom loď prijíma vietor.
///
/// Kódy `S` a `P` sú zámerne tie isté písmená, aké má papierový formulár, aby
/// sa vytlačený a appkový denník čítali rovnako.
enum Tack {
  starboard('S'),
  port('P');

  const Tack(this.code);

  final String code;

  static Tack? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    final c = code.trim().toUpperCase();
    for (final v in values) {
      if (v.code == c) return v;
    }
    return null;
  }

  Tack get opposite => this == starboard ? port : starboard;
}

/// Kurz voči vetru aj s bokom — to, čo na papieri vyplní jedno políčko.
class SailDirection {
  const SailDirection(this.pointOfSail, this.tack);

  final PointOfSail pointOfSail;

  /// Pri [PointOfSail.running] je `null`: vietor ide priamo zozadu a bok
  /// nemá čo rozlišovať. Vypĺňať ho tam by znamenalo zapísať údaj, ktorý
  /// nikto nemeral.
  final Tack? tack;

  /// Zloží dvojicu z uložených kódov, alebo vráti `null`, keď kurz chýba.
  static SailDirection? fromCodes(String? pointOfSail, String? tack) {
    final p = PointOfSail.fromCode(pointOfSail);
    if (p == null) return null;
    return SailDirection(
      p,
      p == PointOfSail.running ? null : Tack.fromCode(tack),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SailDirection &&
      other.pointOfSail == pointOfSail &&
      other.tack == tack;

  @override
  int get hashCode => Object.hash(pointOfSail, tack);
}
