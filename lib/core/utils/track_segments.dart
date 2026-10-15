import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import '../database/app_database.dart';
import 'distance_calculator.dart';

/// Úsek, počas ktorého telefón nedoručil polohu, hoci sa loď pohla.
///
/// Spojiť body pred dierou a po nej plnou čiarou by tvrdilo, že loď išla po
/// priamke — v októbri 2026 tak trasa na mape aj v GPX viedla cez ostrov.
class TrackGapSpan {
  const TrackGapSpan(this.before, this.after);

  final TrackPoint before;
  final TrackPoint after;

  Duration get duration => after.timestamp.difference(before.timestamp);

  /// Vzdušná vzdialenosť — loď prešla najmenej toľko, skutočne viac.
  double get straightNm => DistanceCalculator.distanceNm(
      before.latitude, before.longitude, after.latitude, after.longitude);
}

/// Trasa rozdelená na súvislé úseky a diery medzi nimi.
class TrackSegments {
  const TrackSegments(this.segments, this.gaps);

  /// Súvislé úseky, každý aspoň s jedným bodom.
  final List<List<TrackPoint>> segments;
  final List<TrackGapSpan> gaps;

  /// Diera začína, keď medzi bodmi uplynuli aspoň 3 minúty a loď sa pohla
  /// aspoň o 300 m. Samotný čas nestačí: stojaca loď (obed na bóji) body
  /// nezapisuje, lebo trasovanie má filter 5 m — a to diera nie je.
  /// Rovnaké prahy používa GpsTrackingService pri hlásení diery naživo.
  static const gapMinDuration = Duration(minutes: 3);
  static const gapMinDistanceM = 300.0;

  static bool isGap(TrackPoint a, TrackPoint b) =>
      b.timestamp.difference(a.timestamp) >= gapMinDuration &&
      DistanceCalculator.distanceM(
              a.latitude, a.longitude, b.latitude, b.longitude) >=
          gapMinDistanceM;

  /// Rozdelí body podľa session a podľa dier. Dve rôzne session (prerušená
  /// a obnovená plavba, dva dni) sa nikdy nespájajú — ani prerušovanou
  /// čiarou, tam nejde o výpadok polohy, ale o koniec záznamu.
  factory TrackSegments.of(List<TrackPoint> points) {
    final bySession = <String?, List<TrackPoint>>{};
    for (final p in points) {
      bySession.putIfAbsent(p.sessionId, () => []).add(p);
    }
    final segments = <List<TrackPoint>>[];
    final gaps = <TrackGapSpan>[];
    for (final pts in bySession.values) {
      pts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      var current = <TrackPoint>[pts.first];
      for (var i = 1; i < pts.length; i++) {
        if (isGap(pts[i - 1], pts[i])) {
          segments.add(current);
          gaps.add(TrackGapSpan(pts[i - 1], pts[i]));
          current = [];
        }
        current.add(pts[i]);
      }
      segments.add(current);
    }
    return TrackSegments(segments, gaps);
  }

  static LatLng _ll(TrackPoint p) => LatLng(p.latitude, p.longitude);

  /// Úseky na plnú čiaru.
  List<List<LatLng>> get solidLines => [
        for (final s in segments)
          if (s.length >= 2) [for (final p in s) _ll(p)],
      ];

  /// Spojnice cez diery na prerušovanú čiaru.
  List<List<LatLng>> get gapLines => [
        for (final g in gaps) [_ll(g.before), _ll(g.after)],
      ];

  static const empty = TrackSegments([], []);
}
