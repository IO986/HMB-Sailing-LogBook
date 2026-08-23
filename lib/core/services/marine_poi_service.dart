import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'lat': lat,
        'lon': lon,
        if (name != null) 'name': name,
        'tags': tags,
      };

  static MarinePoi? fromJson(Map<String, dynamic> j) {
    final id = j['id'], type = j['type'];
    final lat = (j['lat'] as num?)?.toDouble();
    final lon = (j['lon'] as num?)?.toDouble();
    if (id is! String || type is! String || lat == null || lon == null) {
      return null;
    }
    return MarinePoi(
      id: id,
      type: type,
      lat: lat,
      lon: lon,
      name: j['name'] as String?,
      tags: Map<String, String>.from(
          (j['tags'] as Map?)?.cast<String, String>() ?? const {}),
    );
  }
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

  // Viac mirrorov — skúšajú sa v poradí, kým jeden neodpovie. Hlavný
  // overpass-api.de často vracia 504 pri preťažení a kumi.systems prestal
  // odpovedať vôbec (overené 27. 7. — timeout na oboch); maps.mail.ru aj
  // private.coffee bežia, len pomalšie (~12 s), preto vyšší receiveTimeout.
  static const _endpoints = [
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    'https://overpass-api.de/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
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

  /// Keš prežíva reštart appky.
  ///
  /// Overpass je pomalý a je to cudzia infraštruktúra zadarmo; raz stiahnutá
  /// oblasť sa nemá sťahovať znova len preto, že sa appka medzitým zavrela.
  /// Na lodi bez signálu je to navyše jediný spôsob, ako vôbec niečo ukázať.
  ///
  /// Kotviská a maríny sa menia rádovo v rokoch, takže sa nič nezahadzuje
  /// podľa veku — súbor sa prepíše, keď pribudnú nové bunky.
  static const _diskFile = 'marine_poi_cache.json';
  bool _diskLoaded = false;
  Future<void>? _diskLoading;
  Timer? _diskSaveDebounce;

  Future<void> _loadFromDisk() {
    if (_diskLoaded) return Future.value();
    return _diskLoading ??= () async {
      try {
        final dir = await getApplicationSupportDirectory();
        final file = File('${dir.path}/$_diskFile');
        if (await file.exists()) {
          final raw = jsonDecode(await file.readAsString());
          if (raw is Map) {
            raw.forEach((key, value) {
              if (key is! String || value is! List) return;
              _cells[key] = [
                for (final e in value)
                  if (e is Map<String, dynamic>)
                    if (MarinePoi.fromJson(e) case final poi?) poi,
              ];
            });
          }
          debugPrint('[POI] disk cache loaded: ${_cells.length} cells');
        }
      } catch (e) {
        debugPrint('[POI] disk cache load failed: $e');
      } finally {
        _diskLoaded = true;
      }
    }();
  }

  /// Zápis sa zlučuje — pri posune mapy pribúdajú bunky po dávkach a súbor
  /// netreba prepisovať po každej.
  void _scheduleDiskSave() {
    _diskSaveDebounce?.cancel();
    _diskSaveDebounce = Timer(const Duration(seconds: 3), () async {
      try {
        final dir = await getApplicationSupportDirectory();
        final file = File('${dir.path}/$_diskFile');
        await file.writeAsString(jsonEncode({
          for (final e in _cells.entries)
            e.key: [for (final poi in e.value) poi.toJson()],
        }));
      } catch (e) {
        debugPrint('[POI] disk cache save failed: $e');
      }
    });
  }

  /// Vráti POI pre daný výrez. Chýbajúce bunky dotiahne jedným Overpass
  /// dotazom (bbox = zjednotenie chýbajúcich buniek); pri chybe siete vráti
  /// aspoň to, čo už je v keši.
  Future<List<MarinePoi>> fetchForBounds(LatLngBounds bounds) async {
    await _loadFromDisk();
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

  /// Ako dlho sa čaká na jeden mirror, kým sa k nemu pridá ďalší.
  ///
  /// Predtým sa mirrory skúšali striktne po sebe: keď prvý odpovedal 12 s,
  /// čakalo sa 12 s, hoci druhý by bol hotový za dve. Preto sa dotaz po
  /// tomto čase POŠLE aj na ďalší mirror a berie sa prvá platná odpoveď.
  static const _hedgeDelay = Duration(seconds: 3);

  /// Pošle dotaz na mirrory s odstupom a vezme prvú platnú odpoveď.
  ///
  /// Zámerne nie všetky naraz: verejné Overpass servery sú cudzia
  /// infraštruktúra zadarmo a štyri súbežné dotazy na každý posun mapy by
  /// boli neslušné. Ďalší sa pridá, až keď predošlý mlčí.
  Future<Response> _fetchWithFallback(String query) async {
    final completer = Completer<Response>();
    var pending = _endpoints.length;
    Object? lastError;

    void attempt(String endpoint) {
      _post(endpoint, query).then((resp) {
        if (resp.statusCode == 200 && resp.data is Map) {
          if (!completer.isCompleted) completer.complete(resp);
          return;
        }
        lastError = 'HTTP ${resp.statusCode}';
        debugPrint('[POI] $endpoint returned ${resp.statusCode}');
        if (--pending == 0 && !completer.isCompleted) {
          completer.completeError(
              Exception('all Overpass endpoints failed: $lastError'));
        }
      }).catchError((Object e) {
        lastError = e;
        debugPrint('[POI] $endpoint failed ($e)');
        if (--pending == 0 && !completer.isCompleted) {
          completer.completeError(
              Exception('all Overpass endpoints failed: $lastError'));
        }
      });
    }

    final timers = <Timer>[];
    for (var i = 0; i < _endpoints.length; i++) {
      final endpoint = _endpoints[i];
      if (i == 0) {
        attempt(endpoint);
      } else {
        timers.add(Timer(_hedgeDelay * i, () {
          if (!completer.isCompleted) attempt(endpoint);
        }));
      }
    }

    try {
      return await completer.future;
    } finally {
      // Mirrory, ktoré sa ešte nespustili, už netreba obťažovať.
      for (final t in timers) {
        t.cancel();
      }
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
      _scheduleDiskSave();
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
