import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

/// Súborová cache mapových dlaždíc: každá zobrazená dlaždica sa uloží na
/// disk (write-through) a zostane v zariadení. Uložená dlaždica sa vždy
/// ukáže ako prvá — offline je to celý výsledok a súbor sa pri chybe siete
/// nikdy nemaže. Ak sa dá skúsiť sieť, tá istá viditeľná dlaždica sa potichu
/// obnoví na pozadí (show-cached-then-refresh): zhodné bajty sa nechajú
/// tak, odlišné sa zapíšu atomicky (dočasný súbor + premenovanie) a
/// zobrazená dlaždica dostane druhý snímok bez prekreslenia vrstvy.
/// Obnova je najviac raz na URL za beh aplikácie a týka sa len dlaždíc,
/// ktoré mapa naozaj zobrazuje — nikdy sa neprechádza celá cache.
/// Zbierka uložených dlaždíc je základ budúcej offline mapy, ale len pre
/// oblasti, kde už dáta sú. Naviac [TileRegionDownloader] vie stiahnuť
/// seamark región dopredu (existujúce dlaždice preskakuje).
class TileCacheStore {
  static Directory? _root;

  static Future<Directory> _rootDir() async {
    if (_root != null) return _root!;
    final docs = await getApplicationDocumentsDirectory();
    _root = Directory('${docs.path}/map_tiles');
    await _root!.create(recursive: true);
    return _root!;
  }

  static Future<File> fileFor(String layerId, int z, int x, int y) async {
    final root = await _rootDir();
    return File('${root.path}/$layerId/$z/$x/$y.png');
  }

  /// Koreň cache pre testy (bez path_provider).
  @visibleForTesting
  static set rootForTesting(Directory? dir) => _root = dir;

  /// Koreňový adresár cache, pre volajúcich mimo tohto súboru (napr. ručný
  /// export dlaždíc v `BackupService`) — nech cestu k `map_tiles` pozná
  /// len toto miesto.
  static Future<Directory> directory() => _rootDir();

  static Future<void> save(
    String layerId,
    int z,
    int x,
    int y,
    Uint8List bytes,
  ) async {
    try {
      final f = await fileFor(layerId, z, x, y);
      await TileFileCache.writeAtomic(f, bytes);
    } catch (e) {
      debugPrint('[TILES] save failed: $e');
    }
  }

  /// Veľkosť cache v bajtoch (na zobrazenie v UI).
  static Future<int> cacheSizeBytes() async {
    final root = await _rootDir();
    var total = 0;
    if (await root.exists()) {
      await for (final e in root.list(recursive: true, followLinks: false)) {
        if (e is File) total += await e.length();
      }
    }
    return total;
  }
}

/// Výsledok obnovy jednej dlaždice.
enum TileRefreshResult {
  /// Sieť vrátila rovnaké bajty (alebo 304) — súbor ostal nedotknutý.
  same,

  /// Bajty sa líšili a nový súbor je bezpečne na disku.
  changed,

  /// Sieť, dekódovanie alebo zápis zlyhali — starý súbor ostal nedotknutý.
  failed,
}

/// Rozhodovanie o bajtoch a súboroch dlaždice, oddelené od siete a UI,
/// aby sa dalo testovať s dočasným adresárom.
class TileFileCache {
  static var _tmpCounter = 0;

  /// Bajty súboru, alebo null keď chýba / je prázdny / nejde prečítať.
  static Future<Uint8List?> readUsable(File file) async {
    try {
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    }
  }

  /// Zapíše do dočasného súboru v tom istom adresári a premenuje ho cez
  /// starý súbor. Starý súbor sa nikdy nemaže vopred; pri chybe zostane.
  static Future<void> writeAtomic(File file, Uint8List bytes) async {
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.${pid}_${_tmpCounter++}.tmp');
    try {
      await tmp.writeAsBytes(bytes, flush: true);
      await tmp.rename(file.path);
    } catch (_) {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      rethrow;
    }
  }

  /// Obnoví [file] z [fetch]. [fetch] vráti null pre „nezmenené“ (304).
  /// [validate] musí potvrdiť, že nové bajty sa dajú dekódovať — inak sa
  /// starý (dobrý) súbor nechá tak.
  static Future<TileRefreshResult> refresh(
    File file, {
    required Future<Uint8List?> Function() fetch,
    required Future<bool> Function(Uint8List bytes) validate,
  }) async {
    try {
      final old = await readUsable(file);
      final fresh = await fetch();
      if (fresh == null) return TileRefreshResult.same;
      if (old != null && listEquals(old, fresh)) return TileRefreshResult.same;
      if (fresh.isEmpty || !await validate(fresh)) {
        return TileRefreshResult.failed;
      }
      await writeAtomic(file, fresh);
      return TileRefreshResult.changed;
    } catch (_) {
      return TileRefreshResult.failed;
    }
  }
}

/// TileProvider pre flutter_map: najprv disk, potom sieť (+ zápis na disk).
class CachingTileProvider extends TileProvider {
  final String layerId;
  static final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.bytes,
      headers: {'User-Agent': 'HMBSailingLog/1.21 (com.hmb.sailinglog)'},
    ),
  );

  CachingTileProvider(this.layerId);

  /// URL, ktoré sa už v tomto behu aplikácie obnovili (alebo práve čerstvo
  /// stiahli). Dlaždica sa obnovuje najviac raz na URL a beh.
  static final Set<String> _refreshedUrls = {};

  /// Test: nahradí sieťové stiahnutie pri obnove (null = 304 nezmenené).
  @visibleForTesting
  static Future<Uint8List?> Function(String url, DateTime? since)?
      refreshFetchOverride;

  /// Test: nahradí kontrolu, či sa dá skúsiť sieť.
  @visibleForTesting
  static Future<bool> Function()? canTryNetworkOverride;

  @visibleForTesting
  static void resetRefreshState() => _refreshedUrls.clear();

  static Future<bool> _canTryNetwork() async {
    final o = canTryNetworkOverride;
    if (o != null) return o();
    try {
      final c = await Connectivity().checkConnectivity();
      return c.isEmpty || c.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return true; // nevieme zistiť — skúsime, zlyhanie je tiché
    }
  }

  /// Jeden pokus o stiahnutie pre obnovu (bez opakovaní — je to len tichá
  /// kontrola). Vráti null pri 304 Not Modified.
  static Future<Uint8List?> _fetchForRefresh(
    String url,
    DateTime? since,
  ) async {
    final o = refreshFetchOverride;
    if (o != null) return o(url, since);
    final resp = await _dio.get<List<int>>(
      url,
      options: Options(
        headers: since == null
            ? null
            : {'If-Modified-Since': HttpDate.format(since.toUtc())},
        validateStatus: (s) => s != null && ((s >= 200 && s < 300) || s == 304),
      ),
    );
    if (resp.statusCode == 304) return null;
    return Uint8List.fromList(resp.data!);
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _CachedTileImage(
        url: getTileUrl(coordinates, options),
        layerId: layerId,
        z: coordinates.z,
        x: coordinates.x,
        y: coordinates.y,
      );

  /// Koľkokrát skúsiť dlaždicu stiahnuť, kým sa vzdá.
  ///
  /// Jeden pokus nestačí. Telefón na lodi stráca sieť neustále — hotspot
  /// prístrojov bez internetu, prepnutie z Wi-Fi na dáta, výpadok DNS pri
  /// prebúdzaní. Bez opakovania ostal po takom výpadku na mape biely štvorec
  /// navždy: dlaždica raz zlyhala, flutter_map si chybu podržal a nič ju už
  /// nešlo znova (nahlásené z terénu — mapa sa po zapnutí Wi-Fi sama
  /// nespravila).
  static const _attempts = 3;

  static Future<Uint8List> fetchAndCache(
    String url,
    String layerId,
    int z,
    int x,
    int y,
  ) async {
    Object? lastError;
    for (var attempt = 0; attempt < _attempts; attempt++) {
      if (attempt > 0) {
        // Krátka pauza medzi pokusmi: keď sa sieť práve zdvíha, druhý pokus
        // o pol sekundy neskôr už prejde, a keď nie, nemá zmysel držať
        // dekódovanie dlaždice dlhšie.
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
      try {
        final resp = await _dio.get<List<int>>(url);
        final bytes = Uint8List.fromList(resp.data!);
        // fire-and-forget zápis; čítanie dlaždice naň nečaká
        TileCacheStore.save(layerId, z, x, y, bytes);
        return bytes;
      } catch (e) {
        lastError = e;
      }
    }
    TileCacheStats.failed(layerId);
    debugPrint(
      '[TILES] $layerId $z/$x/$y failed after $_attempts tries: $lastError',
    );
    throw lastError!;
  }
}

/// Koľko dlaždíc prišlo z disku, koľko zo siete a koľko nedorazilo.
///
/// Bez tohto sa cache ladí naslepo: na mape je vidieť len výsledok, nie to,
/// či dlaždica chýbala v cache, alebo tam bola a nedala sa prečítať. Súčty
/// sa vypisujú po dávkach, nie po dlaždici — jeden riadok na dlaždicu by
/// pri posúvaní mapy zaplavil log a spomalil samotné vykresľovanie.
class TileCacheStats {
  static final Map<String, int> _hits = {};
  static final Map<String, int> _net = {};
  static final Map<String, int> _fails = {};
  static final Map<String, int> _refreshSame = {};
  static final Map<String, int> _refreshChanged = {};
  static var _sinceReport = 0;

  /// Po koľkých dlaždiciach sa vypíše súhrn.
  static const _reportEvery = 50;

  /// Koľko dlaždíc sa v tomto behu úspešne načítalo (z disku alebo siete).
  /// Mapa podľa toho pozná „ešte nič nenakreslené“ bez toho, aby menila
  /// kľúč vrstvy, keď už dlaždice vidno.
  static int loadedCount = 0;

  static void hit(String layer) {
    loadedCount++;
    _bump(_hits, layer);
  }

  static void fetched(String layer) {
    loadedCount++;
    _bump(_net, layer);
  }

  static void failed(String layer) => _bump(_fails, layer);

  /// Tichá obnova: sieť vrátila rovnakú / inú dlaždicu než na disku.
  static void refreshedSame(String layer) => _bump(_refreshSame, layer);
  static void refreshedChanged(String layer) => _bump(_refreshChanged, layer);

  static void _bump(Map<String, int> counter, String layer) {
    counter[layer] = (counter[layer] ?? 0) + 1;
    if (++_sinceReport < _reportEvery) return;
    _sinceReport = 0;
    report();
  }

  /// Vypíše súhrn za všetky vrstvy — volá sa sám po dávke, dá sa aj ručne.
  static void report() {
    final layers = {
      ..._hits.keys,
      ..._net.keys,
      ..._fails.keys,
      ..._refreshSame.keys,
      ..._refreshChanged.keys,
    };
    for (final layer in layers) {
      debugPrint(
        '[TILES] $layer cache=${_hits[layer] ?? 0} '
        'net=${_net[layer] ?? 0} fail=${_fails[layer] ?? 0} '
        'refreshSame=${_refreshSame[layer] ?? 0} '
        'refreshChanged=${_refreshChanged[layer] ?? 0}',
      );
    }
  }
}

class _CachedTileImage extends ImageProvider<_CachedTileImage> {
  final String url;
  final String layerId;
  final int z, x, y;
  const _CachedTileImage({
    required this.url,
    required this.layerId,
    required this.z,
    required this.x,
    required this.y,
  });

  @override
  Future<_CachedTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _CachedTileImage key,
    ImageDecoderCallback decode,
  ) {
    late final _TileCompleter completer;
    completer = _TileCompleter(_load(decode, () => completer));
    return completer;
  }

  static Future<ui.Image> _decodeImage(
    ImageDecoderCallback decode,
    Uint8List bytes,
  ) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(buffer);
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  Future<ImageInfo> _load(
    ImageDecoderCallback decode,
    _TileCompleter Function() completer,
  ) async {
    final file = await TileCacheStore.fileFor(layerId, z, x, y);
    // 1. Uložená dlaždica, ktorá sa dekóduje, sa ukáže hneď; offline je to
    //    celý výsledok. Súbor sa pri chybe siete nikdy nemaže.
    final cached = await TileFileCache.readUsable(file);
    if (cached != null) {
      try {
        final image = await _decodeImage(decode, cached);
        TileCacheStats.hit(layerId);
        // 2. Tichá obnova práve tejto zobrazenej dlaždice (až po prvom
        //    snímku, aby nikdy nepredbehla zobrazenie uloženej verzie).
        Timer.run(() => unawaited(_refresh(file, decode, completer())));
        return ImageInfo(image: image);
      } catch (e) {
        // 6. Chýbajúci / prázdny / nedekódovateľný súbor: stiahni ako doteraz.
        debugPrint('[TILES] $layerId $z/$x/$y cached file unusable: $e');
      }
    }
    final bytes = await CachingTileProvider.fetchAndCache(
      url,
      layerId,
      z,
      x,
      y,
    );
    TileCacheStats.fetched(layerId);
    CachingTileProvider._refreshedUrls.add(url); // práve čerstvé
    return ImageInfo(image: await _decodeImage(decode, bytes));
  }

  Future<void> _refresh(
    File file,
    ImageDecoderCallback decode,
    _TileCompleter completer,
  ) async {
    // 7. Najviac raz na URL a beh. Pridanie až po kontrole siete: offline
    //    pokus nespáli obnovu, keď sa sieť vráti.
    if (CachingTileProvider._refreshedUrls.contains(url)) return;
    if (!await CachingTileProvider._canTryNetwork()) return;
    if (!CachingTileProvider._refreshedUrls.add(url)) return;

    DateTime? since;
    try {
      since = await file.lastModified();
    } catch (_) {}

    final result = await TileFileCache.refresh(
      file,
      fetch: () => CachingTileProvider._fetchForRefresh(url, since),
      validate: (bytes) async {
        try {
          (await _decodeImage(decode, bytes)).dispose();
          return true;
        } catch (_) {
          return false;
        }
      },
    );
    switch (result) {
      case TileRefreshResult.same:
        TileCacheStats.refreshedSame(layerId);
      case TileRefreshResult.failed:
        break;
      case TileRefreshResult.changed:
        TileCacheStats.refreshedChanged(layerId);
        // 5. Nová dlaždica je bezpečne na disku — druhý snímok na tom istom
        //    streame, bez zrušenia vrstvy a bez prázdnej medzery.
        final fresh = await TileFileCache.readUsable(file);
        if (fresh == null) return;
        try {
          final image = await _decodeImage(decode, fresh);
          completer.showRefreshed(ImageInfo(image: image));
        } catch (_) {}
    }
  }

  @override
  bool operator ==(Object other) =>
      other is _CachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

/// Jednosnímkový completer, ktorý vie po obnove poslať druhý snímok.
class _TileCompleter extends OneFrameImageStreamCompleter {
  _TileCompleter(super.image);

  void showRefreshed(ImageInfo info) {
    try {
      setImage(info);
    } catch (_) {
      info.dispose(); // completer už zanikol
    }
  }
}

/// Stiahne dlaždice regiónu pre offline použitie na mori.
class TileRegionDownloader {
  /// Vrstvy, ktoré sa sťahujú vždy.
  ///
  /// Základná mapa tu zámerne CHÝBA: `tile.openstreetmap.org` bulk
  /// sťahovanie výslovne zakazuje (viď docs/HANDOVER.md, "PMTiles na
  /// Cloudflare R2"). Základná mapa je teraz vlastná vektorová vrstva
  /// (`VectorBasemapProvider`, PMTiles z R2) s vlastným súborovým cache —
  /// tento predsťahovač sa jej netýka.
  static const baseLayers = {
    'seamark': 'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
  };

  /// Satelitné snímky a ich popisky.
  ///
  /// Sťahujú sa len tomu, kto satelit naozaj používa: sú rádovo väčšie než
  /// mapové dlaždice a niekomu, kto sa na satelit nikdy neprepne, by len
  /// zabrali miesto v telefóne a čas na linke.
  ///
  /// Popisky sú tu s nimi zámerne. Samotné snímky nemajú jediné meno, takže
  /// satelit bez nich je offline nemý presne vtedy, keď na názve zátoky
  /// najviac záleží.
  static const satelliteLayers = {
    'satellite': 'https://server.arcgisonline.com/ArcGIS/rest/services/'
        'World_Imagery/MapServer/tile/{z}/{y}/{x}',
    'sat_labels': 'https://server.arcgisonline.com/ArcGIS/rest/services/'
        'Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
  };

  /// Čo sa stiahne pri danom nastavení podkladu.
  static Map<String, String> layersFor({required bool satellite}) => {
        ...baseLayers,
        if (satellite) ...satelliteLayers,
      };

  static const maxTiles = 6000;

  bool _cancelled = false;
  void cancel() => _cancelled = true;

  static (int, int) _tileXY(double lat, double lon, int z) {
    final n = math.pow(2, z).toDouble();
    final x = ((lon + 180) / 360 * n).floor();
    final latRad = lat * math.pi / 180;
    final y =
        ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
                2 *
                n)
            .floor();
    return (x.clamp(0, n.toInt() - 1), y.clamp(0, n.toInt() - 1));
  }

  /// Počet dlaždíc pre bounds v zoomoch [minZ]..[maxZ] (jedna vrstva).
  static int countTiles(LatLngBounds b, int minZ, int maxZ) {
    var total = 0;
    for (var z = minZ; z <= maxZ; z++) {
      final (x1, y1) = _tileXY(b.north, b.west, z);
      final (x2, y2) = _tileXY(b.south, b.east, z);
      total += (x2 - x1 + 1) * (y2 - y1 + 1);
    }
    return total;
  }

  /// Sťahuje postupne; hlási progres cez [onProgress] (hotovo, celkovo).
  /// Existujúce dlaždice preskakuje. Vráti počet chýb.
  Future<int> download(
    LatLngBounds b,
    int minZ,
    int maxZ,
    void Function(int done, int total) onProgress, {
    bool satellite = false,
  }) async {
    final jobs = <(String, String, int, int, int)>[]; // layer, url, z, x, y
    for (final entry in layersFor(satellite: satellite).entries) {
      for (var z = minZ; z <= maxZ; z++) {
        final (x1, y1) = _tileXY(b.north, b.west, z);
        final (x2, y2) = _tileXY(b.south, b.east, z);
        for (var x = x1; x <= x2; x++) {
          for (var y = y1; y <= y2; y++) {
            final url = entry.value
                .replaceAll('{z}', '$z')
                .replaceAll('{x}', '$x')
                .replaceAll('{y}', '$y');
            jobs.add((entry.key, url, z, x, y));
          }
        }
      }
    }

    var done = 0;
    var errors = 0;
    final total = jobs.length;
    // 4 paralelné sťahovania — slušnosť voči free tile serverom
    const parallel = 4;
    for (var i = 0; i < jobs.length; i += parallel) {
      if (_cancelled) break;
      final batch = jobs.skip(i).take(parallel);
      await Future.wait(
        batch.map((j) async {
          final (layer, url, z, x, y) = j;
          try {
            final f = await TileCacheStore.fileFor(layer, z, x, y);
            if (!await f.exists()) {
              await CachingTileProvider.fetchAndCache(url, layer, z, x, y);
            }
          } catch (_) {
            errors++;
          }
          done++;
        }),
      );
      onProgress(done, total);
    }
    return errors;
  }
}
