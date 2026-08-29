import 'dart:convert';
import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Uzavretá plocha na mape a otázky, ktoré sa jej dajú klásť.
///
/// Vzniklo to pre kotvovú stráž: kruh s polomerom nevystihne úzku zátoku,
/// kde loď smie zatáčať pozdĺž brehu, ale nie cezeň. Nič doménové tu ale
/// nie je — je to obyčajný mnohouholník a `contains` nevie, či stráži kotvu
/// alebo niečo iné.
///
/// **Počíta sa v metroch, nie v stupňoch.** Prstenec sa premietne do
/// lokálnej roviny voči svojmu prvému bodu (rovnaký postup ako
/// `BearingGeometry`) a až tam sa robí ray casting aj vzdialenosť. Dôvody sú
/// dva a oba sú praktické:
///
/// 1. Na antimeridiáne by prstenec s vrcholmi 179,99° a −179,99° v stupňoch
///    vyrobil lúč cez pol planéty. Normalizácia rozdielu dĺžky na ±180°
///    okolo jedného počiatku to rieši sama.
/// 2. Vzdialenosť k hrane v stupňoch je anizotropná — na 70° s. š. je stupeň
///    dĺžky tretinový oproti stupňu šírky, takže „najbližšia hrana" vyjde
///    nesprávna a číslo na obrazovke je nezmysel.
///
/// Cena je zanedbateľná: pri dvadsiatich rohoch je to hrsť násobení raz za
/// GPS fix.
class GeoPolygon {
  const GeoPolygon._();

  static const _earthRadiusM = 6371000.0;

  /// Plocha menšia než toto sa nedá strážiť: je pod úrovňou šumu GPS, takže
  /// by loď bola striedavo dnu a von bez toho, aby sa pohla.
  static const minUsableAreaM2 = 100.0;

  /// Dá sa nad týmto prstencom vôbec strážiť?
  ///
  /// Volajúci to musí overiť **skôr**, než prepne do režimu plochy. Pri
  /// menej než troch bodoch vracia [contains] `false` pre každú polohu, čo
  /// by znamenalo trvalý alarm — najhorší možný spôsob, akým môže táto
  /// funkcia zlyhať. Záložný režim je vždy kruh, nikdy „plocha s pokazeným
  /// prstencom".
  static bool isUsable(List<LatLng> ring) =>
      ring.length >= 3 && areaM2(ring) >= minUsableAreaM2;

  /// Pretína sa prstenec sám so sebou („mašľa")?
  ///
  /// Even–odd pravidlo dá aj na takom tvare dobre definovanú odpoveď, ale
  /// prekvapivú: laloky sa striedajú dnu a von. Neopravuje sa to — volajúci
  /// má taký prstenec odmietnuť a nechať skipera opraviť rohy. Kto si myslí,
  /// že stráži oba laloky, a dostane alarm v jednom z nich, je na tom horšie
  /// než ten, komu appka rovno povie, že tvar nedáva zmysel.
  static bool hasSelfIntersection(List<LatLng> ring) {
    if (ring.length < 4) return false;
    final p = _project(ring);
    final n = p.length;
    for (var i = 0; i < n; i++) {
      final a1 = p[i];
      final a2 = p[(i + 1) % n];
      for (var j = i + 1; j < n; j++) {
        // Susedné hrany zdieľajú vrchol; to nie je prekríženie.
        if (j == i || (j + 1) % n == i || (i + 1) % n == j) continue;
        if (_segmentsCross(a1, a2, p[j], p[(j + 1) % n])) return true;
      }
    }
    return false;
  }

  /// Leží bod vnútri prstenca? Even–odd (crossing number).
  ///
  /// Test hrany je polootvorený, aby sa vrchol započítal práve raz.
  /// Bod ležiaci presne na hrane je nešpecifikovaný — reálny GPS fix tam
  /// nepadne a dôsledkom by bol jeden tik, nie zlý alarm.
  ///
  /// Prstenec s menej než tromi bodmi vracia `false`; pozri [isUsable].
  static bool contains(List<LatLng> ring, LatLng point) {
    if (ring.length < 3) return false;
    final p = _project(ring);
    final q = _projectPoint(ring.first, point);
    var inside = false;
    for (var i = 0, j = p.length - 1; i < p.length; j = i++) {
      final yi = p[i].dy, yj = p[j].dy;
      if ((yi > q.dy) != (yj > q.dy)) {
        final x = p[j].dx + (q.dy - yi) * (p[j].dx - p[i].dx) / (yj - yi);
        if (q.dx < x) inside = !inside;
      }
    }
    return inside;
  }

  /// Vzdialenosť bodu k najbližšej hrane v metroch. Vždy kladná — či je bod
  /// dnu, hovorí [contains].
  static double distanceToEdgeM(List<LatLng> ring, LatLng point) {
    if (ring.isEmpty) return double.infinity;
    final p = _project(ring);
    final q = _projectPoint(ring.first, point);
    if (p.length == 1) return _dist(q, p.first);
    var best = double.infinity;
    for (var i = 0; i < p.length; i++) {
      final d = _pointToSegmentM(q, p[i], p[(i + 1) % p.length]);
      if (d < best) best = d;
    }
    return best;
  }

  /// Vzdialenosť k hrane so znamienkom: kladná vnútri, záporná vonku.
  ///
  /// Jedno číslo, ktoré odpovie aj na „driftuje?", aj na „koľko mu ostáva?".
  static double signedClearanceM(List<LatLng> ring, LatLng point) {
    final d = distanceToEdgeM(ring, point);
    return contains(ring, point) ? d : -d;
  }

  /// Ťažisko prstenca. Pri degenerovanom tvare padá na priemer vrcholov,
  /// aby nikdy nevrátilo NaN.
  static LatLng centroid(List<LatLng> ring) {
    if (ring.isEmpty) return const LatLng(0, 0);
    if (ring.length < 3) return _vertexMean(ring);
    final p = _project(ring);
    var a = 0.0, cx = 0.0, cy = 0.0;
    for (var i = 0; i < p.length; i++) {
      final j = (i + 1) % p.length;
      final cross = p[i].dx * p[j].dy - p[j].dx * p[i].dy;
      a += cross;
      cx += (p[i].dx + p[j].dx) * cross;
      cy += (p[i].dy + p[j].dy) * cross;
    }
    if (a.abs() < 1e-9) return _vertexMean(ring);
    a *= 0.5;
    return _unproject(ring.first, _Pt(cx / (6 * a), cy / (6 * a)));
  }

  /// Plocha prstenca v metroch štvorcových. Nezáleží na smere obchádzania.
  static double areaM2(List<LatLng> ring) {
    if (ring.length < 3) return 0;
    final p = _project(ring);
    var sum = 0.0;
    for (var i = 0; i < p.length; i++) {
      final j = (i + 1) % p.length;
      sum += p[i].dx * p[j].dy - p[j].dx * p[i].dy;
    }
    return sum.abs() / 2;
  }

  /// Prstenec ako text do `SharedPreferences`: `[[lat,lon],…]`.
  static String encode(List<LatLng> ring) =>
      jsonEncode([for (final p in ring) [p.latitude, p.longitude]]);

  /// Opak [encode], ktorý **nikdy nevyhodí výnimku**.
  ///
  /// Číta sa to pri obnove kotvovej stráže po tom, čo appku zabil systém.
  /// Výnimka na tomto mieste by obnovu ticho zabila — stráž by po reštarte
  /// nikdy neožila a skiper by spal v presvedčení, že mu niekto sleduje
  /// kotvu. Nezmyselný vstup preto dáva prázdny prstenec, teda pád späť na
  /// kruh.
  static List<LatLng> decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <LatLng>[];
      for (final item in decoded) {
        if (item is! List || item.length < 2) return const [];
        final lat = item[0], lon = item[1];
        if (lat is! num || lon is! num) return const [];
        if (lat.isNaN || lon.isNaN || lat.abs() > 90 || lon.abs() > 180) {
          return const [];
        }
        out.add(LatLng(lat.toDouble(), lon.toDouble()));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  // ── Lokálna rovina ──────────────────────────────────────────────

  static List<_Pt> _project(List<LatLng> ring) =>
      [for (final p in ring) _projectPoint(ring.first, p)];

  static _Pt _projectPoint(LatLng origin, LatLng p) {
    final latScale = _earthRadiusM * math.pi / 180;
    final lonScale = latScale * math.cos(origin.latitude * math.pi / 180);
    return _Pt(_normaliseLon(p.longitude - origin.longitude) * lonScale,
        (p.latitude - origin.latitude) * latScale);
  }

  static LatLng _unproject(LatLng origin, _Pt p) {
    final latScale = _earthRadiusM * math.pi / 180;
    final lonScale = latScale * math.cos(origin.latitude * math.pi / 180);
    return LatLng(origin.latitude + p.dy / latScale,
        origin.longitude + (lonScale == 0 ? 0 : p.dx / lonScale));
  }

  /// Rozdiel zemepisných dĺžok do ±180°. Bez toho by prstenec cez 180.
  /// poludník vyrobil hranu okolo celej planéty.
  static double _normaliseLon(double deg) {
    var d = deg;
    while (d > 180) {
      d -= 360;
    }
    while (d < -180) {
      d += 360;
    }
    return d;
  }

  static LatLng _vertexMean(List<LatLng> ring) => LatLng(
        ring.map((p) => p.latitude).reduce((a, b) => a + b) / ring.length,
        ring.map((p) => p.longitude).reduce((a, b) => a + b) / ring.length,
      );

  static double _dist(_Pt a, _Pt b) =>
      math.sqrt((a.dx - b.dx) * (a.dx - b.dx) + (a.dy - b.dy) * (a.dy - b.dy));

  /// Vzdialenosť bodu k úsečke, nie k jej predĺženiu: parameter sa oreže na
  /// [0,1], takže pri bode šikmo za rohom vyjde vzdialenosť k rohu.
  static double _pointToSegmentM(_Pt p, _Pt a, _Pt b) {
    final abx = b.dx - a.dx, aby = b.dy - a.dy;
    final len2 = abx * abx + aby * aby;
    // Dvakrát ťuknutý ten istý roh: úsečka nemá dĺžku, meria sa k bodu.
    if (len2 == 0) return _dist(p, a);
    var t = ((p.dx - a.dx) * abx + (p.dy - a.dy) * aby) / len2;
    t = t.clamp(0.0, 1.0);
    return _dist(p, _Pt(a.dx + t * abx, a.dy + t * aby));
  }

  static bool _segmentsCross(_Pt a1, _Pt a2, _Pt b1, _Pt b2) {
    double cross(_Pt o, _Pt p, _Pt q) =>
        (p.dx - o.dx) * (q.dy - o.dy) - (p.dy - o.dy) * (q.dx - o.dx);
    final d1 = cross(a1, a2, b1);
    final d2 = cross(a1, a2, b2);
    final d3 = cross(b1, b2, a1);
    final d4 = cross(b1, b2, a2);
    return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
  }
}

/// Bod v lokálnej rovine, v metroch.
class _Pt {
  const _Pt(this.dx, this.dy);
  final double dx;
  final double dy;
}
