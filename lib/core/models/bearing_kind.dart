/// Čo je na zameraní známe a čo sa z neho počíta.
///
/// Zameranie je vždy uhol medzi dvoma bodmi — pozorovateľom a objektom. Ktorý
/// z nich je známy, rozhoduje o tom, čo priesečník viacerých zameraní vlastne
/// znamená, a to sú dve úplne odlišné úlohy:
///
/// * [resection] — poznám objekt, hľadám seba. Vidím maják, viem ktorý to na
///   mape je, netuším kde som. Moja poloha leží na opačnom kurze od majáka,
///   takže priesečník takých spätných priamok z dvoch–troch známych bodov dá
///   moju polohu. **GPS na to netreba** — poloha pozorovateľa je práve to
///   neznáme. Merania musia byť takmer súčasné, lebo predpokladajú, že loď
///   medzi nimi stojí.
///
/// * [intersection] — poznám seba, hľadám objekt. Vidím skalu, ktorá na mape
///   nie je, a chcem ju tam dostať. Zameriam ju z niekoľkých svojich polôh a
///   priesečník priamok dá jej polohu. GPS je tu nutná. Merania sa naopak
///   zámerne robia s odstupom, aby loď medzi nimi prešla kus cesty — bez
///   takej základnice sa priamky pretínajú pod ostrým uhlom a výsledok je
///   rozmazaný.
///
/// Ukladá sa ako stabilný [code], nikdy nie ako preložený text — z rovnakého
/// dôvodu, pre aký ho má `LogbookEventType`: keď sa raz typ záznamu hádal
/// z poznámky používateľa, skončilo to troma pravopismi tej istej udalosti
/// v produkčnej databáze.
///
/// Čisté Dart bez drift a bez Fluttera, aby sa dalo testovať priamo.
library;

enum BearingKind {
  /// Zameranie na známy bod; hľadá sa poloha pozorovateľa.
  resection('resection'),

  /// Zameranie zo známej polohy na neznámy objekt; hľadá sa objekt.
  intersection('intersection');

  final String code;
  const BearingKind(this.code);

  static BearingKind? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final value in values) {
      if (value.code == code) return value;
    }
    return null;
  }

  /// Kurz, ktorým sa od známeho bodu kreslí priamka na mape.
  ///
  /// Pri [intersection] sa kreslí od pozorovateľa tam, kam mieril, teda
  /// nameraným kurzom. Pri [resection] sa kreslí od zameraného objektu späť
  /// k pozorovateľovi, teda opačným kurzom — pozorovateľ je niekde na nej.
  double lineBearing(double trueBearing) => switch (this) {
        intersection => trueBearing % 360,
        resection => (trueBearing + 180) % 360,
      };

  /// Potrebuje tento druh zamerania známu polohu pozorovateľa (GPS)?
  bool get needsObserverPosition => this == intersection;

  /// Potrebuje tento druh zamerania vybraný známy bod?
  bool get needsKnownTarget => this == resection;
}
