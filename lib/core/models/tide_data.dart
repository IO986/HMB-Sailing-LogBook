import 'dart:math' as math;

/// Jeden bod predikovanej krivky prílivu/odlivu.
///
/// `heightM` je nad strednou hladinou mora (MSL), nie nad mapovým datom.
class TidePoint {
  final DateTime time;
  final double heightM;
  /// 'high' / 'low' pri extrémoch, inak null.
  final String? extremeType;

  const TidePoint({required this.time, required this.heightM, this.extremeType});

  bool get isHigh => extremeType == 'high';
  bool get isLow => extremeType == 'low';
}

/// Kešovaná predpoveď aj s údajmi o tom, odkiaľ a kedy pochádza.
///
/// Bez nich by karta ukazovala predpoveď pre prístav vzdialený stovky míľ
/// alebo dávno expirovanú, a to bez akéhokoľvek varovania.
class TideForecast {
  final List<TidePoint> points;

  /// Miesto, pre ktoré bola predpoveď stiahnutá.
  final double? latitude;
  final double? longitude;
  final DateTime? downloadedAt;

  /// Názov ručne zvoleného miesta (napr. "Split, Croatia"), inak null.
  final String? locationLabel;

  /// True, ak si miesto vybral používateľ — vtedy je vzdialenosť od
  /// aktuálnej polohy zámerná a nemá sa hlásiť ako problém.
  final bool manualSelection;

  const TideForecast({
    required this.points,
    this.latitude,
    this.longitude,
    this.downloadedAt,
    this.locationLabel,
    this.manualSelection = false,
  });

  static const empty = TideForecast(points: []);

  bool get isEmpty => points.isEmpty;

  /// Predpoveď má zmysel len po koniec stiahnutého okna.
  bool isExpiredAt(DateTime now) {
    if (points.isEmpty) return true;
    final last = points.map((p) => p.time).reduce((a, b) => a.isAfter(b) ? a : b);
    return now.toUtc().isAfter(last);
  }

  /// Vzdušná vzdialenosť od miesta stiahnutia, v km (haversine).
  double? distanceKmFrom(double lat, double lon) {
    final originLat = latitude;
    final originLon = longitude;
    if (originLat == null || originLon == null) return null;

    const earthRadiusKm = 6371.0;
    double toRad(double d) => d * math.pi / 180.0;

    final dLat = toRad(lat - originLat);
    final dLon = toRad(lon - originLon);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRad(originLat)) *
            math.cos(toRad(lat)) *
            math.pow(math.sin(dLon / 2), 2);
    return earthRadiusKm * 2 * math.asin(math.min(1, math.sqrt(a)));
  }

  /// Najbližší nadchádzajúci extrém, alebo null bez dát.
  TidePoint? nextExtremeAfter(DateTime now) {
    final future = points
        .where((p) => p.extremeType != null && p.time.isAfter(now.toUtc()))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return future.isEmpty ? null : future.first;
  }
}
