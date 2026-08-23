import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Jeden bod pravidelnej mriežky nad viditeľným výrezom mapy.
typedef GridCell = ({double lat, double lon, double latSpan, double lonSpan});

/// Rovnomerná mriežka [n]×[n] bodov nad [bounds].
///
/// Body sú v strede svojich buniek, nie v rohoch — vrstva sa kreslí ako
/// obdĺžniky okolo nich a inak by presahovala výrez.
///
/// Spoločné pre vrstvu vetra aj zrážok. Predtým to mala každá služba vlastné
/// a bola to tá istá matematika napísaná dvakrát.
List<GridCell> gridOverBounds(LatLngBounds bounds, int n) {
  final latSpan = (bounds.north - bounds.south) / n;
  final lonSpan = (bounds.east - bounds.west) / n;
  return [
    for (var i = 0; i < n; i++)
      for (var j = 0; j < n; j++)
        (
          lat: bounds.south + latSpan * (i + 0.5),
          lon: bounds.west + lonSpan * (j + 0.5),
          latSpan: latSpan,
          lonSpan: lonSpan,
        ),
  ];
}

/// Rozšíri výrez o [factor] jeho veľkosti na každú stranu.
///
/// Vrstvy počasia sa sťahujú pre väčšiu plochu, než je práve vidno, a kým sa
/// mapa hýbe vnútri nej, nesiaha sa na sieť vôbec. Bez toho stál každý posun
/// jedno stiahnutie — a keďže Open-Meteo počíta limit podľa počtu súradníc,
/// nie požiadaviek, pár posunov mapy stačilo na HTTP 429 a vrstva prestala
/// fungovať úplne.
LatLngBounds padBounds(LatLngBounds b, double factor) {
  final latPad = (b.north - b.south) * factor;
  final lonPad = (b.east - b.west) * factor;
  return LatLngBounds(
    LatLng(
      (b.south - latPad).clamp(-85.0, 85.0),
      (b.west - lonPad).clamp(-180.0, 180.0),
    ),
    LatLng(
      (b.north + latPad).clamp(-85.0, 85.0),
      (b.east + lonPad).clamp(-180.0, 180.0),
    ),
  );
}

/// Je [inner] celý vnútri [outer]?
bool boundsContain(LatLngBounds outer, LatLngBounds inner) =>
    inner.south >= outer.south &&
    inner.north <= outer.north &&
    inner.west >= outer.west &&
    inner.east <= outer.east;
