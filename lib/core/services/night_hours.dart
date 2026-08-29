import '../../features/miles/services/solar_calculator.dart';

/// Kedy je noc a koľko jej na plavbe bolo.
///
/// Jedno pravidlo pre celú appku: noc je čas pred východom a po západe slnka
/// **pre tú polohu, kde loď v tej chvíli bola** — nie podľa hodín a nie podľa
/// pásma telefónu. Ten istý čas je v auguste v Jadrane deň a v Škandinávii
/// noc, takže sa počíta z každého bodu zvlášť.
///
/// Predtým žila tá istá funkcia dvakrát (Kniha míľ a súhrn plavby) v dvoch
/// kópiách. Denník potreboval tretiu — namiesto toho je tu jedna a obe
/// pôvodné ju volajú, aby potvrdenie o míľach a denník nikdy nevykázali
/// o tej istej plavbe dve rôzne čísla.
class NightHours {
  const NightHours._();

  /// Medzera medzi dvoma bodmi, ktorá sa už neráta ako plavba. Vypnuté
  /// trasovanie cez noc by inak vyrobilo desať nočných hodín, ktoré nikto
  /// neodplával.
  ///
  /// Tridsať minút, nie viac, a je to jediná kópia tohto čísla v appke.
  /// Kým existovala druhá (Kniha míľ počítala s 30 minútami, denník s dvomi
  /// hodinami), tá istá importovaná plavba vykázala v PDF 1,7 nočnej hodiny
  /// a v Knihe míľ 0,9 — dva doklady o jednej noci. Hodnota je tá, ktorá je
  /// už vytlačená v potvrdeniach o naplávaných míľach; meniť ju znamená
  /// prepisovať aj to, čo skiperi dávno odovzdali.
  static const maxGap = Duration(minutes: 30);

  /// Je v [whenUtc] na pozícii [lat]/[lon] tma?
  ///
  /// Pri polárnom dni aj polárnej noci vracia `false`: keď slnko nezapadne
  /// ani nevyjde, tento výpočet o nej nemá čo povedať a vymyslená noc je
  /// horšia než žiadna.
  static bool isNight(DateTime whenUtc, double lat, double lon) {
    final utc = whenUtc.toUtc();
    final solar = SolarCalculator.sunriseSunsetUtc(
        DateTime.utc(utc.year, utc.month, utc.day), lat, lon);
    final sunrise = solar.sunrise;
    final sunset = solar.sunset;
    if (sunrise == null || sunset == null) return false;
    return utc.isBefore(sunrise) || utc.isAfter(sunset);
  }

  /// Nočné hodiny z časovej rady polôh.
  ///
  /// Úsek sa počíta ako nočný len vtedy, keď je tma na oboch jeho koncoch —
  /// súmrak tak padne na tú stranu, kde loď väčšinu úseku naozaj bola.
  static double forSamples(Iterable<NightSample> samples) {
    final sorted = [...samples]..sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
    var hours = 0.0;
    for (var i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];
      final gap = curr.timeUtc.difference(prev.timeUtc);
      if (gap <= Duration.zero || gap > maxGap) continue;
      if (prev.isNight && curr.isNight) hours += gap.inSeconds / 3600.0;
    }
    return hours;
  }
}

/// Jeden bod trasy alebo záznam denníka, zredukovaný na to, čo výpočet noci
/// potrebuje. Drží aj samotný fakt „bola tma", aby sa slnko pre ten istý bod
/// nepočítalo dvakrát.
class NightSample {
  NightSample({
    required this.timeUtc,
    required double latitude,
    required double longitude,
  }) : isNight = NightHours.isNight(timeUtc, latitude, longitude);

  final DateTime timeUtc;
  final bool isNight;
}
