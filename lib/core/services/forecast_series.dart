/// Spoločná časová os predpovedných vrstiev mapy.
///
/// Vietor, prúdy, zrážky aj oblačnosť sa sťahujú ako hodinový rad a posuvník
/// času nad mapou v ňom len listuje — nič sa pri jeho posune nesťahuje.
///
/// Prečo hodinový rad a nie „aktuálna hodnota": Open-Meteo počíta kvótu podľa
/// POČTU SÚRADNÍC, nie podľa počtu hodín. Dva dni predpovede pre tú istú
/// mriežku teda stoja presne toľko, čo jediná hodnota — a tá istá kvóta nás
/// predtým zrazila na kolená, keď som zväčšil mriežku.
class ForecastSeries {
  const ForecastSeries({required this.times});

  /// Časy jednotlivých krokov, v UTC, vzostupne.
  final List<DateTime> times;

  /// Koľko hodín dopredu sa sťahuje.
  ///
  /// Dva dni sú pre plánovanie prechodu dosť a dlhší rad by len nafukoval
  /// odpoveď — model má aj tak ďalej klesajúcu výpovednú hodnotu.
  static const forecastHours = 48;

  bool get isEmpty => times.isEmpty;

  /// Index kroku pre daný posun od teraz, orezaný na dostupný rozsah.
  ///
  /// Hľadá sa podľa skutočného času, nie ako „prvý prvok + offset": rad môže
  /// začínať o polnoci daného dňa, takže index a hodina od teraz nie sú to
  /// isté číslo.
  int indexForOffset(int hoursFromNow, {DateTime? now}) {
    if (times.isEmpty) return 0;
    final target =
        (now ?? DateTime.now().toUtc()).add(Duration(hours: hoursFromNow));

    var best = 0;
    var bestDiff = (times[0].difference(target)).abs();
    for (var i = 1; i < times.length; i++) {
      final diff = (times[i].difference(target)).abs();
      if (diff >= bestDiff) continue;
      best = i;
      bestDiff = diff;
    }
    return best;
  }

  /// Rozparsuje pole časov z odpovede Open-Meteo.
  ///
  /// Časy prichádzajú bez zóny (`2026-08-23T10:00`) pri `timezone=UTC`, takže
  /// sa musia označiť ako UTC ručne — inak by ich Dart čítal ako lokálne a
  /// posuvník by ukazoval o pásmo vedľa.
  static List<DateTime> parseTimes(List<dynamic>? raw) {
    if (raw == null) return const [];
    final out = <DateTime>[];
    for (final t in raw) {
      if (t is! String) continue;
      final parsed = DateTime.tryParse(t.endsWith('Z') ? t : '${t}Z');
      if (parsed != null) out.add(parsed.toUtc());
    }
    return out;
  }
}
