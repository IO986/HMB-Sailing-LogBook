import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import '../../../core/database/app_database.dart';
import '../../../core/utils/distance_calculator.dart';

/// Stav lode v jednom okamihu prehrávania.
class PlaybackFix {
  const PlaybackFix({
    required this.position,
    required this.time,
    this.sog,
    this.cog,
    this.interpolated = false,
  });

  final LatLng position;
  final DateTime time;
  final double? sog;
  final double? cog;

  /// True, keď poloha vznikla dopočtom medzi dvoma bodmi, nie priamo z fixu.
  final bool interpolated;
}

/// Vyhľadávanie polohy v čase nad zaznamenanou trasou.
///
/// Bez UI a bez databázy, aby sa dalo testovať samostatne. Trasa sa predpokladá
/// zoradená podľa času — tak ju vracajú `dayTrackPointsProvider`
/// a `charterTrackPointsProvider`.
class TrackPlayback {
  TrackPlayback(this.points)
      : assert(true, 'points must be sorted by timestamp');

  final List<TrackPoint> points;

  /// Medzera, cez ktorú sa už poloha nedopočítava.
  ///
  /// Keď tracking uprostred dňa vypadol (systém zabil appku, skiper vypol
  /// plavbu a o hodinu ju zapol inde), spojnica medzi poslednými dvoma bodmi
  /// nie je trasa lode. Interpolovať cez takú dieru by v prehrávaní ukázalo
  /// loď plávať naprieč polostrovom.
  static const maxInterpolationGap = Duration(minutes: 10);

  bool get isEmpty => points.isEmpty;

  DateTime? get start => points.isEmpty ? null : points.first.timestamp;
  DateTime? get end => points.isEmpty ? null : points.last.timestamp;

  Duration get duration {
    final s = start, e = end;
    if (s == null || e == null) return Duration.zero;
    return e.difference(s);
  }

  /// Poloha v čase [t], alebo `null` pri prázdnej trase.
  ///
  /// Pred prvým bodom vracia prvý, za posledným posledný — prehrávanie tak
  /// nikdy nezostane bez značky, aj keď posuvník ide po celom dni a trasa
  /// pokrýva len jeho časť.
  PlaybackFix? fixAt(DateTime t) {
    if (points.isEmpty) return null;

    final first = points.first;
    if (!t.isAfter(first.timestamp)) {
      return _fixOf(first, points.length > 1 ? points[1] : null);
    }
    final last = points.last;
    if (!t.isBefore(last.timestamp)) return _fixOf(last);

    // Binárne vyhľadávanie: staršie plavby spred TrackPointThrottle majú
    // desaťtisíce bodov na deň a celá plavba ich môže mať stotisíc. Lineárny
    // prechod pri každom posune posuvníka by mapu zosekal.
    var lo = 0;
    var hi = points.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) ~/ 2;
      if (points[mid].timestamp.isAfter(t)) {
        hi = mid;
      } else {
        lo = mid;
      }
    }

    final a = points[lo];
    final b = points[hi];
    final gap = b.timestamp.difference(a.timestamp);

    // Cez dieru v zázname sa nedopočítava — drž sa posledného skutočného bodu.
    // Rýchlosť a kurz sa cez dieru nedopočítavajú vôbec: úsečka cez hodinovú
    // medzeru nie je pohyb lode.
    if (gap > maxInterpolationGap || gap <= Duration.zero) return _fixOf(a);

    final ratio =
        t.difference(a.timestamp).inMilliseconds / gap.inMilliseconds;
    return PlaybackFix(
      position: LatLng(
        a.latitude + (b.latitude - a.latitude) * ratio,
        a.longitude + (b.longitude - a.longitude) * ratio,
      ),
      time: t,
      // Rýchlosť a kurz sa neinterpolujú: sú to hodnoty odčítané v konkrétnom
      // okamihu, nie spojitá veličina, a kurz by sa cez sever priemeroval na
      // opačnú stranu.
      sog: a.speed ?? _derivedSog(a, b),
      cog: a.course ?? _derivedCog(a, b),
      interpolated: true,
    );
  }

  /// Rýchlosť dopočítaná z dvojice bodov, keď ju záznam neobsahuje.
  ///
  /// Importované GPX bývajú len poloha a čas — ten z HMB Academy má 22 500
  /// bodov a ani jeden údaj o rýchlosti. Bez dopočtu by prehrávanie takej
  /// plavby neukázalo nič a vyzeralo by pokazene.
  static double? _derivedSog(TrackPoint a, TrackPoint b) {
    final seconds = b.timestamp.difference(a.timestamp).inMilliseconds / 1000;
    if (seconds <= 0) return null;
    final metres = DistanceCalculator.distanceM(
        a.latitude, a.longitude, b.latitude, b.longitude);
    return metres / seconds * 1.94384; // m/s -> uzly
  }

  /// Kurz dopočítaný ako bearing medzi dvoma bodmi.
  ///
  /// Pri zanedbateľnom posune sa nevracia nič: z dvoch takmer totožných bodov
  /// vyjde náhodný smer, a to je v zázname horšie než prázdna hodnota.
  static double? _derivedCog(TrackPoint a, TrackPoint b) {
    final metres = DistanceCalculator.distanceM(
        a.latitude, a.longitude, b.latitude, b.longitude);
    if (metres < _minCourseDistM) return null;
    return DistanceCalculator.bearing(
        a.latitude, a.longitude, b.latitude, b.longitude);
  }

  /// Rovnaký prah, aký používa živý tracking pri počítaní kurzu z bearingu.
  static const _minCourseDistM = 8.0;

  /// Index posledného bodu, ktorý v čase [t] loď už prešla. `-1` pred štartom.
  ///
  /// Na odlíšenie prejdenej časti trasy od zvyšku.
  int passedIndex(DateTime t) {
    if (points.isEmpty || t.isBefore(points.first.timestamp)) return -1;
    if (!t.isBefore(points.last.timestamp)) return points.length - 1;

    var lo = 0;
    var hi = points.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) ~/ 2;
      if (points[mid].timestamp.isAfter(t)) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return lo;
  }

  /// Fix priamo na zaznamenanom bode. [next] slúži len na dopočet rýchlosti
  /// a kurzu, keď ich bod sám neobsahuje.
  static PlaybackFix _fixOf(TrackPoint p, [TrackPoint? next]) => PlaybackFix(
        position: LatLng(p.latitude, p.longitude),
        time: p.timestamp,
        sog: p.speed ?? (next == null ? null : _derivedSog(p, next)),
        cog: p.course ?? (next == null ? null : _derivedCog(p, next)),
      );
}
