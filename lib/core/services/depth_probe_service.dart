import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Hĺbka dna v jednom bode z EMODnet Bathymetry.
///
/// Izobaty, ktoré kreslí vrstva `emodnet:contours`, sú riedke a nad
/// priblížením 12 už žiadne nie sú — na otázku „koľko je tu pod kýlom" teda
/// neodpovedajú. Podkladový model `emodnet:mean` sa ale dá vyskúšať bodovo
/// cez WMS GetFeatureInfo a ten hodnotu vráti pri akomkoľvek priblížení.
///
/// NIE je to hydrografické dielo: mriežka má ~115 m na bunku a je poskladaná
/// z prieskumov rôzneho veku a presnosti. Slúži na plánovanie, nie na
/// rozhodnutie, či sa dá niekade prejsť.
class DepthProbeService {
  static final DepthProbeService _i = DepthProbeService._();
  factory DepthProbeService() => _i;
  DepthProbeService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'User-Agent': 'HMBSailingLog/1.30 (com.hmb.sailinglog)'},
  ));

  static const _endpoint = 'https://ows.emodnet-bathymetry.eu/wms';
  static const _earthRadius = 6378137.0;

  /// Web Mercator (EPSG:3857) z WGS84.
  static (double, double) _toMercator(LatLng p) {
    final x = _earthRadius * p.longitude * math.pi / 180;
    final y = _earthRadius *
        math.log(math.tan(math.pi / 4 + p.latitude * math.pi / 360));
    return (x, y);
  }

  /// Hĺbka v metroch (kladná = pod hladinou), alebo null.
  ///
  /// Null znamená „nevieme" — súš, mimo pokrytia, alebo nedostupná sieť.
  /// Volajúci to musí rozlíšiť od nuly: nula je hladina, null je bez údaja.
  Future<double?> depthAt(LatLng point) async {
    final (cx, cy) = _toMercator(point);
    // Malý štvorec okolo bodu; pýtame sa na jeho stredný pixel. Rozmer je
    // vecne jedno, len musí sedieť s I/J nižšie.
    const half = 2000.0;
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        _endpoint,
        queryParameters: {
          'SERVICE': 'WMS',
          'VERSION': '1.3.0',
          'REQUEST': 'GetFeatureInfo',
          'LAYERS': 'emodnet:mean',
          'QUERY_LAYERS': 'emodnet:mean',
          'STYLES': '',
          'CRS': 'EPSG:3857',
          'BBOX': '${cx - half},${cy - half},${cx + half},${cy + half}',
          'WIDTH': '101',
          'HEIGHT': '101',
          'I': '50',
          'J': '50',
          'FORMAT': 'image/png',
          'INFO_FORMAT': 'application/json',
        },
        options: Options(responseType: ResponseType.json),
      );
      final features = resp.data?['features'];
      if (features is! List || features.isEmpty) return null;
      final raw = (features.first as Map)['properties']?['Depth'];
      if (raw is! num) return null;
      // EMODnet vracia zápornú hodnotu pod hladinou; appka počíta hĺbku
      // kladne. Kladná hodnota (súš nad morom) údaj o hĺbke nie je.
      final metres = -raw.toDouble();
      return metres <= 0 ? null : metres;
    } catch (_) {
      // Offline je bežný stav, nie chyba — vrstva je bonus.
      return null;
    }
  }
}
