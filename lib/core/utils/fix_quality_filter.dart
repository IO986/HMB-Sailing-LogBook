import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import 'distance_calculator.dart';

/// Ako dopadla kontrola jedného GPS fixu.
enum FixVerdict {
  /// Fix je použiteľný a nadväzuje na predošlý — smie sa zapísať do trasy
  /// aj narátať do prejdených míľ.
  accepted,

  /// Fix je nepresný (bunka/wifi namiesto GNSS) — zahodiť celý.
  rejectedAccuracy,

  /// Fix je presný, ale skok z predošlej polohy je fyzikálne nemožný —
  /// zahodiť celý.
  rejectedJump,

  /// Po dlhej diere v zázname (appka spala, GPS nemalo signál) sa fix prijme
  /// ako nový začiatok, ale vzdialenosť k nemu sa nepočíta: nevie sa, ktorou
  /// cestou loď medzitým šla.
  resynced,
}

/// Výsledok kontroly aj s prejdenou vzdialenosťou od posledného prijatého
/// fixu (0, keď sa počítať nemá).
class FixCheck {
  const FixCheck(this.verdict, this.distanceM);

  final FixVerdict verdict;

  /// Vzdialenosť od posledného prijatého fixu v metroch. Nenulová len pri
  /// [FixVerdict.accepted]; pri státí na kotve ostáva 0 aj tam (pozri
  /// [FixQualityFilter.minMoveM]).
  final double distanceM;

  bool get isAccepted =>
      verdict == FixVerdict.accepted || verdict == FixVerdict.resynced;
}

/// Rozhoduje, ktoré GPS fixy sú vôbec dôveryhodné.
///
/// Prečo to existuje (z terénu, plavba 24.–27. 8. 2026): do trasy sa
/// zapisovalo všetko, čo platforma poslala. Fix z bunky s presnosťou 500–700 m
/// tak spravil v denníku skok o kilometer a hneď späť, a keď loď posiela
/// polohu cez NMEA a telefónu medzitým zamrzne jeho vlastná poloha, striedanie
/// dvoch zdrojov nafúklo prejdené míle na trojnásobok (47,9 NM namiesto 16,0).
///
/// Trieda rieši KVALITU fixu; hustotu zapísanej trasy rieši
/// `TrackPointThrottle` a sú to zámerne dve nezávislé veci.
class FixQualityFilter {
  FixQualityFilter({
    this.maxAccuracyM = 50,
    this.maxSpeedKnots = 30,
    this.minJumpM = 100,
    this.minMoveM = 3,
    this.resyncGap = const Duration(minutes: 2),
    this.maxConsecutiveRejects = 5,
  });

  /// Nad touto presnosťou sa fix zahadzuje. Hodnota 0 znamená „presnosť
  /// neznáma" (tak prichádza poloha z NMEA) a strop sa neuplatní.
  final double maxAccuracyM;

  /// Rýchlosť, nad ktorú sa posun medzi dvoma fixmi považuje za skok.
  /// 30 kn je nad možnosti plachetnice aj typického motorového člna, ale
  /// pod hodnotami, ktoré robí GPS šum (stovky uzlov).
  final double maxSpeedKnots;

  /// Skok sa posudzuje až od tejto vzdialenosti — na krátkych úsekoch je
  /// podiel vzdialenosti a času príliš citlivý na zaokrúhlenie času.
  final double minJumpM;

  /// Menší posun sa do míľ nerátá: na kotve alebo v prístave by sa z GPS
  /// šumu za noc nazbierali míle, ktoré loď neprešla.
  final double minMoveM;

  /// Diera v zázname, po ktorej sa nadväznosť na predošlý fix vzdá.
  final Duration resyncGap;

  /// Po koľkých zahodených fixoch za sebou sa filter vzdá a prijme ďalší
  /// ako nový začiatok. Poistka proti zaseknutiu: keby sa loď naozaj
  /// premiestnila (prívoz, vlek) a filter by trval na svojom, tracking by
  /// od tej chvíle nezapísal už nič.
  final int maxConsecutiveRejects;

  LatLng? _lastAccepted;
  DateTime? _lastAcceptedAt;
  int _consecutiveRejects = 0;

  /// Bod, od ktorého sa meria kumulatívny posun pre [minMoveM] — na rozdiel
  /// od [_lastAccepted] sa NEPOSÚVA pri každom prijatom fixe, len keď sa
  /// posun od neho reálne narátal do míľ. Bez tohto rozdielu (pôvodná
  /// chyba, nájdená z terénu 1.9.: 18,8 NM zredukovaných na 4,2 NM) sa
  /// vzdialenosť porovnávala vždy len oproti PREDOŠLÉMU fixu — pri hustom
  /// 1 Hz NMEA feede a plachtení pod ~6 uzlami je krok medzi dvoma po sebe
  /// idúcimi fixmi takmer vždy pod 3 m, takže sa každý jednotlivý krok
  /// zaokrúhlil na 0 a reálny, len pomaly rastúci posun sa nikdy nesčítal.
  LatLng? _distanceBaseline;

  /// Posledný prijatý bod, alebo `null` kým sa neprijalo nič.
  LatLng? get lastAccepted => _lastAccepted;

  void reset() {
    _lastAccepted = null;
    _lastAcceptedAt = null;
    _distanceBaseline = null;
    _consecutiveRejects = 0;
  }

  /// Posúdi fix. [accuracyM] je presnosť v metroch (0 alebo záporné =
  /// neznáma), [at] je čas fixu.
  FixCheck check(LatLng candidate, {required double accuracyM, required DateTime at}) {
    if (accuracyM > 0 && accuracyM > maxAccuracyM) {
      _consecutiveRejects++;
      if (_consecutiveRejects <= maxConsecutiveRejects) {
        return const FixCheck(FixVerdict.rejectedAccuracy, 0);
      }
      // Presnejšie fixy neprichádzajú (telefón vidí len bunky) — radšej
      // hrubá poloha než prázdna trasa, ale bez nadväznosti na predošlú.
      return _resync(candidate, at);
    }

    final last = _lastAccepted;
    final lastAt = _lastAcceptedAt;
    if (last == null || lastAt == null) return _resync(candidate, at);

    final elapsed = at.difference(lastAt);
    if (elapsed >= resyncGap || elapsed.isNegative) {
      return _resync(candidate, at);
    }

    final distM = DistanceCalculator.distanceM(
      last.latitude, last.longitude, candidate.latitude, candidate.longitude);

    final seconds = elapsed.inMilliseconds / 1000.0;
    if (distM > minJumpM && seconds > 0) {
      final knots = distM / seconds * 1.94384;
      if (knots > maxSpeedKnots) {
        _consecutiveRejects++;
        if (_consecutiveRejects <= maxConsecutiveRejects) {
          return const FixCheck(FixVerdict.rejectedJump, 0);
        }
        return _resync(candidate, at);
      }
    }

    _consecutiveRejects = 0;
    _lastAccepted = candidate;
    _lastAcceptedAt = at;

    final baseline = _distanceBaseline ??= candidate;
    final fromBaselineM = DistanceCalculator.distanceM(
      baseline.latitude, baseline.longitude,
      candidate.latitude, candidate.longitude);
    if (fromBaselineM < minMoveM) {
      // Posun od poslednej NARÁTANEJ polohy je zatiaľ pod prahom — nechaj
      // baseline na mieste, nech sa ďalší (aj drobný) krok pripočíta k tomu
      // istému základu, kým sa spolu nenazbiera aspoň minMoveM.
      return const FixCheck(FixVerdict.accepted, 0);
    }
    _distanceBaseline = candidate;
    return FixCheck(FixVerdict.accepted, fromBaselineM);
  }

  FixCheck _resync(LatLng candidate, DateTime at) {
    _consecutiveRejects = 0;
    _lastAccepted = candidate;
    _lastAcceptedAt = at;
    _distanceBaseline = candidate;
    return const FixCheck(FixVerdict.resynced, 0);
  }
}
