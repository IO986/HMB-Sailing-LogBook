import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Prístav / marína / kotvisko / tankovacia stanica z OpenStreetMap
/// (Overpass API).
class MarinePoi {
  final String id; // "node/123" | "way/456" — unikátne naprieč dotazmi
  final String type; // anchorage | marina | harbour | fuel
  final double lat;
  final double lon;
  final String? name;
  final Map<String, String> tags;

  const MarinePoi({
    required this.id,
    required this.type,
    required this.lat,
    required this.lon,
    this.name,
    required this.tags,
  });
}

/// Sťahuje kotviská, maríny a prístavy z Overpass API (OSM dáta) pre
/// viditeľný výsek mapy. Výsledky sa kešujú v pamäti po bunkách 0.25°,
/// takže opakované posúvanie mapy po tej istej oblasti už nič nesťahuje.
class MarinePoiService {
  static final MarinePoiService _i = MarinePoiService._();
  factory MarinePoiService() => _i;
  MarinePoiService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      // Overpass vracia 406 na požiadavky bez User-Agent (dio ho sám
      // neposiela) — overené na zariadení aj curl-om s prázdnym UA.
      'User-Agent': 'HMBSailingLog/1.21 (com.hmb.sailinglog)',
      'Accept': 'application/json',
    },
  ));

  // Hlavný endpoint + mirror — hlavný občas vracia 504 pri preťažení.
  static const _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];
  static const _cellDeg = 0.25;
  // Strop na jeden fetch — pri oddialenej mape nesťahuj polovicu Jadranu.
  static const _maxCellsPerFetch = 12;

  final Map<String, List<MarinePoi>> _cells = {};
  // Bežiaci fetch per bunka — keď provider medzičasom rebuildne, nová
  // exekúcia na prebiehajúci fetch POČKÁ (inak vráti prázdno a markery sa
  // objavia až pri ďalšej zmene stavu mapy).
  final Map<String, Future<void>> _inFlight = {};

  String _cellKey(int cx, int cy) => '$cx:$cy';

  /// Vráti POI pre daný výrez. Chýbajúce bunky dotiahne jedným Overpass
  /// dotazom (bbox = zjednotenie chýbajúcich buniek); pri chybe siete vráti
  /// aspoň to, čo už je v keši.
  Future<List<MarinePoi>> fetchForBounds(LatLngBounds bounds) async {
    final cxMin = (bounds.west / _cellDeg).floor();
    final cxMax = (bounds.east / _cellDeg).floor();
    final cyMin = (bounds.south / _cellDeg).floor();
    final cyMax = (bounds.north / _cellDeg).floor();

    final missing = <(int, int)>[];
    final pending = <Future<void>>{};
    for (var cx = cxMin; cx <= cxMax; cx++) {
      for (var cy = cyMin; cy <= cyMax; cy++) {
        final key = _cellKey(cx, cy);
        final inFlight = _inFlight[key];
        if (inFlight != null) {
          pending.add(inFlight);
        } else if (!_cells.containsKey(key)) {
          missing.add((cx, cy));
        }
      }
    }

    final tooManyCells =
        (cxMax - cxMin + 1) * (cyMax - cyMin + 1) > _maxCellsPerFetch;
    if (missing.isNotEmpty && !tooManyCells) {
      pending.add(_fetchCells(missing));
    }
    await Future.wait(pending);

    final result = <MarinePoi>[];
    final seen = <String>{};
    for (var cx = cxMin; cx <= cxMax; cx++) {
      for (var cy = cyMin; cy <= cyMax; cy++) {
        for (final poi in _cells[_cellKey(cx, cy)] ?? const <MarinePoi>[]) {
          if (seen.add(poi.id) && bounds.contains(LatLng(poi.lat, poi.lon))) {
            result.add(poi);
          }
        }
      }
    }
    return result;
  }

  Future<Response> _post(String endpoint, String query) => _dio.post(
        endpoint,
        data: {'data': query},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

  /// Hlavný server dostane 4 s — ak dovtedy neodpovie (typicky preťaženie,
  /// 504), letí dotaz na mirror. Pomalá odpoveď hlavného servera sa tým
  /// nezruší, len sa na ňu nečaká.
  Future<Response> _fetchWithFallback(String query) async {
    try {
      return await _post(_endpoints[0], query)
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[POI] primary slow/failed ($e), using mirror');
      return _post(_endpoints[1], query);
    }
  }

  Future<void> _fetchCells(List<(int, int)> cells) {
    final future = _doFetchCells(cells);
    for (final (cx, cy) in cells) {
      _inFlight[_cellKey(cx, cy)] = future;
    }
    return future;
  }

  Future<void> _doFetchCells(List<(int, int)> cells) async {
    // Bbox = zjednotenie chýbajúcich buniek (sú vždy blízko seba,
    // lebo pochádzajú z jedného viditeľného výrezu).
    final south = cells.map((c) => c.$2).reduce((a, b) => a < b ? a : b) * _cellDeg;
    final north = (cells.map((c) => c.$2).reduce((a, b) => a > b ? a : b) + 1) * _cellDeg;
    final west = cells.map((c) => c.$1).reduce((a, b) => a < b ? a : b) * _cellDeg;
    final east = (cells.map((c) => c.$1).reduce((a, b) => a > b ? a : b) + 1) * _cellDeg;
    final bbox = '$south,$west,$north,$east';

    final query = '''
[out:json][timeout:15];
(
  node["seamark:type"~"^(anchorage|harbour|marina)\$"]($bbox);
  way["seamark:type"~"^(anchorage|harbour|marina)\$"]($bbox);
  node["leisure"="marina"]($bbox);
  way["leisure"="marina"]($bbox);
  node["waterway"="fuel"]($bbox);
  way["waterway"="fuel"]($bbox);
);
out center 300;
''';

    try {
      final resp = await _fetchWithFallback(query);
      final elements = (resp.data['elements'] as List?) ?? const [];

      // Najprv priprav prázdne bunky, aby sa oblasť bez POI tiež zapamätala.
      for (final (cx, cy) in cells) {
        _cells.putIfAbsent(_cellKey(cx, cy), () => []);
      }

      for (final e in elements) {
        final rawTags = (e['tags'] as Map?) ?? const {};
        final tags = <String, String>{
          for (final t in rawTags.entries) t.key.toString(): t.value.toString(),
        };
        final lat = (e['lat'] ?? e['center']?['lat']) as num?;
        final lon = (e['lon'] ?? e['center']?['lon']) as num?;
        if (lat == null || lon == null) continue;

        final seamark = tags['seamark:type'];
        final String type;
        if (tags['waterway'] == 'fuel') {
          type = 'fuel';
        } else if (seamark == 'anchorage') {
          type = 'anchorage';
        } else if (seamark == 'marina' || tags['leisure'] == 'marina') {
          type = 'marina';
        } else {
          type = 'harbour';
        }

        final poi = MarinePoi(
          id: '${e['type']}/${e['id']}',
          type: type,
          lat: lat.toDouble(),
          lon: lon.toDouble(),
          name: tags['name'] ?? tags['seamark:name'],
          tags: tags,
        );
        final key = _cellKey(
          (poi.lon / _cellDeg).floor(),
          (poi.lat / _cellDeg).floor(),
        );
        // POI tesne za okrajom dotazovaného bboxu patrí do bunky, ktorú sme
        // nedotiahli celú — nekešuj ju, dotiahne sa so svojou bunkou.
        if (_cells.containsKey(key)) _cells[key]!.add(poi);
      }
      debugPrint('[POI] Overpass fetch ok: ${elements.length} elements, bbox=$bbox');
    } catch (e) {
      debugPrint('[POI] Overpass fetch failed: $e');
      // Nekešuj neúspech — bunky sa skúsia znova pri ďalšom posune mapy.
    } finally {
      for (final (cx, cy) in cells) {
        _inFlight.remove(_cellKey(cx, cy));
      }
    }
  }
}
