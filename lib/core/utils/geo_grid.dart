import 'package:flutter_map/flutter_map.dart';

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
