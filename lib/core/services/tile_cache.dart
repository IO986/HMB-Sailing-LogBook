import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

/// Súborová cache mapových dlaždíc: každá zobrazená dlaždica sa uloží na
/// disk (write-through), takže prezeraná oblasť funguje aj offline. Naviac
/// [TileRegionDownloader] vie stiahnuť celý región dopredu.
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

  static Future<void> save(
      String layerId, int z, int x, int y, Uint8List bytes) async {
    try {
      final f = await fileFor(layerId, z, x, y);
      await f.parent.create(recursive: true);
      await f.writeAsBytes(bytes, flush: false);
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

/// TileProvider pre flutter_map: najprv disk, potom sieť (+ zápis na disk).
class CachingTileProvider extends TileProvider {
  final String layerId;
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
    responseType: ResponseType.bytes,
    headers: {'User-Agent': 'HMBSailingLog/1.21 (com.hmb.sailinglog)'},
  ));

  CachingTileProvider(this.layerId);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _CachedTileImage(
        url: getTileUrl(coordinates, options),
        layerId: layerId,
        z: coordinates.z,
        x: coordinates.x,
        y: coordinates.y,
      );

  static Future<Uint8List> fetchAndCache(
      String url, String layerId, int z, int x, int y) async {
    final resp = await _dio.get<List<int>>(url);
    final bytes = Uint8List.fromList(resp.data!);
    // fire-and-forget zápis; čítanie dlaždice naň nečaká
    TileCacheStore.save(layerId, z, x, y, bytes);
    return bytes;
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
          _CachedTileImage key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(_load(decode));

  Future<ImageInfo> _load(ImageDecoderCallback decode) async {
    Uint8List bytes;
    final file = await TileCacheStore.fileFor(layerId, z, x, y);
    if (await file.exists()) {
      bytes = await file.readAsBytes();
    } else {
      bytes = await CachingTileProvider.fetchAndCache(url, layerId, z, x, y);
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(buffer);
    final frame = await codec.getNextFrame();
    return ImageInfo(image: frame.image);
  }

  @override
  bool operator ==(Object other) =>
      other is _CachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

/// Stiahne dlaždice regiónu pre offline použitie na mori.
class TileRegionDownloader {
  static const layers = {
    'osm': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'seamark': 'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
  };
  static const maxTiles = 6000;

  bool _cancelled = false;
  void cancel() => _cancelled = true;

  static (int, int) _tileXY(double lat, double lon, int z) {
    final n = math.pow(2, z).toDouble();
    final x = ((lon + 180) / 360 * n).floor();
    final latRad = lat * math.pi / 180;
    final y = ((1 -
                math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
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
    void Function(int done, int total) onProgress,
  ) async {
    final jobs = <(String, String, int, int, int)>[]; // layer, url, z, x, y
    for (final entry in layers.entries) {
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
      await Future.wait(batch.map((j) async {
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
      }));
      onProgress(done, total);
    }
    return errors;
  }
}
