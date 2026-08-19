/// Geometria zameraní: kam čiara vedie a kde sa čiary pretnú.
///
/// Ten istý výpočet slúži oboch úlohám, len sa doň vchádza z opačnej strany
/// (podrobne v `BearingKind`):
///
/// * resekcia — priamky vychádzajú zo zameraných ZNÁMYCH bodov opačným
///   kurzom a ich priesečník je poloha pozorovateľa;
/// * intersection — priamky vychádzajú zo známych polôh POZOROVATEĽA
///   nameraným kurzom a ich priesečník je hľadaný objekt.
///
/// Matematika je v oboch prípadoch tá istá, preto tu nie sú dva výpočty:
/// smer priamky pripraví [BearingGeometry.lineFor] a zvyšok je jedno
/// pretínanie polpriamok.
///
/// Čisté Dart bez Fluttera a bez drift, aby sa dalo testovať priamo. Vstupom
/// je [BearingLine] — odľahčený tvar riadku z tabuľky `bearings`, takže
/// výpočet nezávisí od databázy.
library;

import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../../core/models/bearing_kind.dart';

const double _earthRadiusM = 6371000;
const double _metersPerNm = 1852.0;

/// Jedna zámerná priamka: z ktorého ZNÁMEHO bodu vychádza a ktorým smerom.
class BearingLine {
  /// Známy bod, z ktorého priamka vychádza.
  ///
  /// Pri hľadaní objektu je to poloha pozorovateľa, pri resekcii zameraný
  /// waypoint. Preto sa nemenuje `observer`: pri resekcii pozorovateľ známy
  /// nie je, je to práve to hľadané.
  final LatLng origin;

  /// Kurz priamky (°, 0–360) — už po oprave o deklináciu a už otočený podľa
  /// druhu zamerania, teda to, čo pripraví [BearingGeometry.lineFor].
  final double trueBearing;

  /// Polovičná šírka kužeľa neistoty (°).
  final double uncertaintyDeg;

  /// Voliteľné id riadku, aby volajúci vedel priradiť výsledok späť.
  final int? id;

  const BearingLine({
    required this.origin,
    required this.trueBearing,
    this.uncertaintyDeg = 8,
    this.id,
  });
}

/// Odhad polohy z priesečníkov viacerých zameraní.
class BearingFix {
  /// Vypočítaná poloha. ČO to je, hovorí [kind]:
  /// pri `resection` poloha pozorovateľa, pri `intersection` zameraný objekt.
  final LatLng position;

  /// Ktorá z dvoch úloh sa riešila — bez toho je [position] dvojznačná.
  final BearingKind kind;

  /// Polomer odhadovanej chyby v metroch.
  final double errorRadiusMeters;

  /// Vrcholy "trojuholníka chyby" — priesečníky jednotlivých dvojíc.
  /// Pri dvoch zameraniach je tu jediný bod.
  final List<LatLng> intersections;

  /// Počet zameraní, z ktorých fix vznikol.
  final int bearingCount;

  /// Najmenší uhol, pod ktorým sa niektoré dve čiary pretínajú (°, 0–90).
  ///
  /// Kvalita fixu stojí a padá na ňom: čiary pretínajúce sa pod 20° dajú
  /// priesečník, ktorý sa po ceste rozmaže na stovky metrov. Klasické
  /// pravidlo je mieriť na 90° pri dvoch zameraniach a ~60° pri troch.
  final double cutAngleDeg;

  const BearingFix({
    required this.position,
    required this.kind,
    required this.errorRadiusMeters,
    required this.intersections,
    required this.bearingCount,
    required this.cutAngleDeg,
  });

  /// Pri resekcii je [position] moja poloha, takže ju možno porovnať s GPS.
  bool get isOwnPosition => kind == BearingKind.resection;

  /// Fix pod 30° rezného uhla je slabý — hodí sa na to upozorniť, nie ho
  /// zamlčať; aj slabý fix je lepší než žiadny, keď padne GPS.
  bool get isWeak => cutAngleDeg < 30;
}

class BearingGeometry {
  BearingGeometry._();

  /// Postaví zámernú priamku pre daný druh zamerania.
  ///
  /// [knownPoint] je to, čo je pri danom druhu známe — poloha pozorovateľa
  /// pri hľadaní objektu, zameraný waypoint pri resekcii. [measuredTrueBearing]
  /// je vždy to, čo sa naozaj odčítalo (po oprave o deklináciu); otočenie na
  /// opačný kurz pri resekcii rieši `BearingKind.lineBearing`, aby na to
  /// nemusel myslieť každý volajúci zvlášť.
  static BearingLine lineFor({
    required BearingKind kind,
    required LatLng knownPoint,
    required double measuredTrueBearing,
    double uncertaintyDeg = 8,
    int? id,
  }) =>
      BearingLine(
        origin: knownPoint,
        trueBearing: kind.lineBearing(measuredTrueBearing),
        uncertaintyDeg: uncertaintyDeg,
        id: id,
      );

  /// Bod vzdialený [distanceNm] námorných míľ v smere [bearingDeg].
  ///
  /// Ortodroma, nie rovná čiara v Mercatorovej projekcii — na 5 NM je rozdiel
  /// zanedbateľný, ale rovnaký vzorec slúži aj na dlhšie čiary.
  static LatLng destination(
      LatLng from, double bearingDeg, double distanceNm) {
    final angular = distanceNm * _metersPerNm / _earthRadiusM;
    final theta = _rad(bearingDeg);
    final lat1 = _rad(from.latitude);
    final lon1 = _rad(from.longitude);

    final sinLat2 = math.sin(lat1) * math.cos(angular) +
        math.cos(lat1) * math.sin(angular) * math.cos(theta);
    final lat2 = math.asin(sinLat2.clamp(-1.0, 1.0));
    final lon2 = lon1 +
        math.atan2(
          math.sin(theta) * math.sin(angular) * math.cos(lat1),
          math.cos(angular) - math.sin(lat1) * sinLat2,
        );

    return LatLng(_deg(lat2), _normaliseLon(_deg(lon2)));
  }

  /// Trojica bodov na vykreslenie kužeľa neistoty: ľavá hrana, os, pravá
  /// hrana — všetky vo vzdialenosti [lengthNm] od začiatku priamky.
  static ({LatLng left, LatLng centre, LatLng right}) cone(
      BearingLine line, double lengthNm) {
    return (
      left: destination(
          line.origin, line.trueBearing - line.uncertaintyDeg, lengthNm),
      centre: destination(line.origin, line.trueBearing, lengthNm),
      right: destination(
          line.origin, line.trueBearing + line.uncertaintyDeg, lengthNm),
    );
  }

  /// Priesečník dvoch zámerných priamok, alebo null.
  ///
  /// Vracia null, keď sú čiary (takmer) rovnobežné, alebo keď priesečník leží
  /// za začiatkom niektorej z nich — priamka je polpriamka, riešenie vzadu je
  /// matematický artefakt, nie poloha. Platí pre oba druhy: pri resekcii ide
  /// stále dopredu, len od majáka ku mne.
  ///
  /// Rovnaký začiatok oboch priamok (dva námery na TEN ISTÝ waypoint) tým
  /// prepadne tiež: vyjde `ta == 0`, čo je správne — z jedného bodu sa poloha
  /// vytriangulovať nedá, hoci by uhly zvierali čokoľvek.
  static LatLng? intersection(BearingLine a, BearingLine b) {
    final origin = _midpoint(a.origin, b.origin);
    final pa = _toLocal(a.origin, origin);
    final pb = _toLocal(b.origin, origin);
    final da = _direction(a.trueBearing);
    final db = _direction(b.trueBearing);

    final denom = da.x * db.y - da.y * db.x;
    // ~0.5° a menej sa už nedá poctivo pretnúť.
    if (denom.abs() < 1e-8) return null;

    final dx = pb.x - pa.x;
    final dy = pb.y - pa.y;
    final ta = (dx * db.y - dy * db.x) / denom;
    final tb = (dx * da.y - dy * da.x) / denom;
    if (ta <= 0 || tb <= 0) return null;

    return _toLatLng(
        _Point(pa.x + ta * da.x, pa.y + ta * da.y), origin);
  }

  /// Uhol, pod ktorým sa dve zámerné priamky pretínajú (°, 0–90).
  static double cutAngle(BearingLine a, BearingLine b) {
    var diff = (a.trueBearing - b.trueBearing).abs() % 180;
    if (diff > 90) diff = 180 - diff;
    return diff;
  }

  /// Poloha z dvoch alebo viacerých zameraní.
  ///
  /// Pri dvoch čiarach je výsledkom ich priesečník. Pri troch a viac sa
  /// priesečníky všetkých dvojíc spriemerujú a ich rozptyl dá "trojuholník
  /// chyby" — presne ten cocked hat, ktorý sa kreslí do papierovej mapy.
  ///
  /// [kind] len opíše, čo výsledok znamená; do výpočtu nevstupuje, pretože
  /// otočenie kurzu už spravila [lineFor]. Všetky [lines] musia byť toho
  /// istého druhu — miešať resekciu s hľadaním objektu nemá zmysel, sú to
  /// priesečníky dvoch rôznych vecí.
  ///
  /// Vracia null, keď sa nenašiel ani jeden použiteľný priesečník.
  static BearingFix? fix(List<BearingLine> lines,
      {required BearingKind kind}) {
    if (lines.length < 2) return null;

    final points = <LatLng>[];
    var smallestCut = 90.0;
    var worstConeRadius = 0.0;

    for (var i = 0; i < lines.length; i++) {
      for (var j = i + 1; j < lines.length; j++) {
        final point = intersection(lines[i], lines[j]);
        if (point == null) continue;
        points.add(point);

        final angle = cutAngle(lines[i], lines[j]);
        if (angle < smallestCut) smallestCut = angle;

        worstConeRadius = math.max(
            worstConeRadius, _coneRadius(lines[i], lines[j], point, angle));
      }
    }
    if (points.isEmpty) return null;

    final centre = _centroid(points);

    // Dva nezávislé odhady chyby; ber ten horší. Rozptyl priesečníkov
    // vystihne nesúlad medzi zameraniami, kužele vystihnú presnosť samotného
    // prístroja — a pri dvoch čiarach je rozptyl z definície nula, takže bez
    // kužeľov by fix tvrdil, že je presný na centimeter.
    final spread = points.fold<double>(
        0, (worst, p) => math.max(worst, _distanceM(centre, p)));

    return BearingFix(
      position: centre,
      kind: kind,
      errorRadiusMeters: math.max(spread, worstConeRadius),
      intersections: points,
      bearingCount: lines.length,
      cutAngleDeg: smallestCut,
    );
  }

  /// Chyba priesečníka daná šírkou kužeľov a rezným uhlom.
  ///
  /// Každá čiara je presná na `d·tan(u)` naprieč; pri reznom uhle α sa táto
  /// priečna neistota premietne do polohy s faktorom `1/sin α`. Preto sa fix
  /// pri malých uhloch rozpadá.
  static double _coneRadius(
      BearingLine a, BearingLine b, LatLng point, double angleDeg) {
    final sinCut = math.sin(_rad(angleDeg));
    if (sinCut.abs() < 1e-6) return double.infinity;
    final wa = _distanceM(a.origin, point) * math.tan(_rad(a.uncertaintyDeg));
    final wb = _distanceM(b.origin, point) * math.tan(_rad(b.uncertaintyDeg));
    return math.sqrt(wa * wa + wb * wb) / sinCut;
  }

  // ── Lokálna rovina ────────────────────────────────────────────────
  // Na pár míľ okolo lode sa dá pracovať v rovine východ/sever v metroch.
  // Priesečník dvoch priamok je tam obyčajná lineárna algebra namiesto
  // pretínania dvoch veľkých kružníc.

  static _Point _toLocal(LatLng p, LatLng origin) {
    const latScale = _earthRadiusM * math.pi / 180;
    final lonScale = latScale * math.cos(_rad(origin.latitude));
    return _Point(
      (p.longitude - origin.longitude) * lonScale,
      (p.latitude - origin.latitude) * latScale,
    );
  }

  static LatLng _toLatLng(_Point p, LatLng origin) {
    const latScale = _earthRadiusM * math.pi / 180;
    final lonScale = latScale * math.cos(_rad(origin.latitude));
    return LatLng(
      origin.latitude + p.y / latScale,
      _normaliseLon(origin.longitude + p.x / lonScale),
    );
  }

  /// Jednotkový vektor kurzu vo východ/sever súradniciach. Kurz sa ráta od
  /// severu v smere hodinových ručičiek, preto sin na východ a cos na sever.
  static _Point _direction(double bearingDeg) =>
      _Point(math.sin(_rad(bearingDeg)), math.cos(_rad(bearingDeg)));

  static LatLng _midpoint(LatLng a, LatLng b) => LatLng(
        (a.latitude + b.latitude) / 2,
        (a.longitude + b.longitude) / 2,
      );

  static LatLng _centroid(List<LatLng> points) {
    var lat = 0.0, lon = 0.0;
    for (final p in points) {
      lat += p.latitude;
      lon += p.longitude;
    }
    return LatLng(lat / points.length, lon / points.length);
  }

  static double _distanceM(LatLng a, LatLng b) {
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return _earthRadiusM * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  static double _normaliseLon(double lon) {
    var l = (lon + 180) % 360;
    if (l < 0) l += 360;
    return l - 180;
  }

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}

class _Point {
  final double x; // východ, m
  final double y; // sever, m
  const _Point(this.x, this.y);
}

/// Pravý kurz z nameraného magnetického a deklinácie, znormalizovaný na 0–360.
double trueFromMagnetic(double magneticBearing, double declination) {
  final t = (magneticBearing + declination) % 360;
  return t < 0 ? t + 360 : t;
}
