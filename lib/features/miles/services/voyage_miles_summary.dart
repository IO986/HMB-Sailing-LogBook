import 'dart:math' as math;

import '../../../core/database/app_database.dart';
import '../../../core/services/night_hours.dart';

/// Súhrn jednej plavby pre potvrdenie o naplávaných míľach.
class VoyageMilesSummary {
  const VoyageMilesSummary({
    required this.daysAtSea,
    required this.dayNm,
    required this.nightNm,
    required this.nightHours,
    required this.area,
    required this.dateFrom,
    required this.dateTo,
  });

  /// Počet dní denníka, nie kalendárny rozdiel — deň bez zápisu sa neráta.
  final int daysAtSea;
  final double dayNm;
  final double nightNm;
  final double nightHours;
  final String? area;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  double get totalNm => dayNm + nightNm;

  static const empty = VoyageMilesSummary(
    daysAtSea: 0,
    dayNm: 0,
    nightNm: 0,
    nightHours: 0,
    area: null,
    dateFrom: null,
    dateTo: null,
  );
}

/// Medzera medzi bodmi, po ktorej sa úsek nepočíta — tracking bol vypnutý
/// alebo appku zabil systém a o trase medzitým nevieme nič.
const _maxGap = NightHours.maxGap;

/// Skok, ktorý nemôže byť plavba (GPS chyba). Rovnaká hranica ako pri živom
/// počítaní v GpsTrackingService.
const _maxLegNm = 10.0;

/// Rozdelí prejdené míle na denné a nočné.
///
/// Úsek sa počíta ako nočný, keď sú oba jeho konce po západe alebo pred
/// východom slnka v mieste a čase daného bodu — rovnaké kritérium, aké
/// používa výpočet nočných hodín v knihe míľ, aby si obe čísla odpovedali.
VoyageMilesSummary summariseVoyage({
  required List<DayLog> days,
  required List<TrackPoint> points,
  String? area,
}) {
  if (days.isEmpty && points.isEmpty) return VoyageMilesSummary.empty;

  final sorted = [...points]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  var dayNm = 0.0;
  var nightNm = 0.0;
  var nightHours = 0.0;

  for (var i = 1; i < sorted.length; i++) {
    final prev = sorted[i - 1];
    final curr = sorted[i];
    final gap = curr.timestamp.difference(prev.timestamp);
    if (gap <= Duration.zero || gap > _maxGap) continue;

    final nm = _distanceNm(prev, curr);
    if (nm >= _maxLegNm) continue;

    if (_isNight(prev) && _isNight(curr)) {
      nightNm += nm;
      nightHours += gap.inSeconds / 3600.0;
    } else {
      dayNm += nm;
    }
  }

  // Bez trasy (ručne zadaná alebo importovaná plavba bez bodov) ostáva
  // vzdialenosť z denníka a všetko sa počíta ako denná plavba — hádať noc
  // z ničoho by bolo horšie než ju nevykázať.
  if (sorted.length < 2) {
    dayNm = days.fold<double>(0, (sum, d) => sum + d.distanceNm);
  }

  final dates = days.map((d) => d.date).toList()..sort();

  return VoyageMilesSummary(
    daysAtSea: days.length,
    dayNm: dayNm,
    nightNm: nightNm,
    nightHours: nightHours,
    area: area,
    dateFrom: dates.isEmpty ? null : dates.first,
    dateTo: dates.isEmpty ? null : dates.last,
  );
}

double _distanceNm(TrackPoint a, TrackPoint b) {
  const earthRadiusNm = 3440.065;
  final dLat = _rad(b.latitude - a.latitude);
  final dLon = _rad(b.longitude - a.longitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(a.latitude)) *
          math.cos(_rad(b.latitude)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return 2 * earthRadiusNm * math.asin(math.min(1, math.sqrt(h)));
}

double _rad(double deg) => deg * math.pi / 180.0;

bool _isNight(TrackPoint p) =>
    NightHours.isNight(p.timestamp, p.latitude, p.longitude);
