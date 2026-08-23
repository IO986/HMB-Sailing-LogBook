import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utils/geo_grid.dart';

/// Ktorá plošná vrstva počasia je nad mapou.
///
/// Sú to výplne, nie značky, takže sa navzájom vylučujú — dve poloprehľadné
/// plochy cez seba nie sú čitateľné ani jedna.
enum WeatherOverlay {
  none,

  /// Zrážky v mm/h.
  precipitation,

  /// Oblačnosť v percentách.
  cloud;

  static WeatherOverlay fromIndex(int? i) =>
      (i == null || i < 0 || i >= values.length) ? none : values[i];
}

/// Hodnota v jednej bunke mriežky.
class OverlayCell {
  const OverlayCell({
    required this.lat,
    required this.lon,
    required this.latSpan,
    required this.lonSpan,
    required this.value,
  });

  final double lat;
  final double lon;
  final double latSpan;
  final double lonSpan;

  /// mm/h pri zrážkach, percentá pri oblačnosti.
  final double value;
}

/// Plošné vrstvy počasia nad mapou z modelu Open-Meteo.
///
/// Nahradili radarové dlaždice z RainVieweru, ktoré sa bez API kľúča končili
/// pri zoome 7 a nad ním vracali PNG s nápisom "Zoom Level Not Supported" —
/// vrstva sa tak dala použiť jedine pri pohľade na celý Jadran naraz.
///
/// Sú to **modely, nie meranie**, a UI to musí pomenovať. Namerané zrážky
/// ukazuje samostatná obrazovka s radarovou snímkou DHMZ.
class WeatherOverlayGridService {
  static final WeatherOverlayGridService _i = WeatherOverlayGridService._();
  factory WeatherOverlayGridService() => _i;
  WeatherOverlayGridService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  ));

  /// Hustejšie než vietor (4×4): šípka sa dá čítať aj riedko, ale plocha musí
  /// mať tvar, inak je z prehánky štvorec cez pol mora. 8×8 = 64 bodov ide
  /// stále jedným volaním.
  static const _grid = 8;

  /// Pod týmto sa bunka nekreslí. Model dáva aj stotiny milimetra a jednotky
  /// percent oblačnosti, z ktorých by bola mapa zafarbená aj za jasného dňa.
  static double minVisible(WeatherOverlay overlay) =>
      overlay == WeatherOverlay.cloud ? 10 : 0.1;

  final _cache = <WeatherOverlay, List<OverlayCell>>{};
  final _cacheKey = <WeatherOverlay, String>{};
  final _fetchedAt = <WeatherOverlay, DateTime>{};

  String _key(LatLngBounds b) =>
      '${b.south.toStringAsFixed(1)}:${b.west.toStringAsFixed(1)}:'
      '${b.north.toStringAsFixed(1)}:${b.east.toStringAsFixed(1)}';

  Future<List<OverlayCell>> fetchForBounds(
      LatLngBounds bounds, WeatherOverlay overlay) async {
    if (overlay == WeatherOverlay.none) return const [];

    final key = _key(bounds);
    final at = _fetchedAt[overlay];
    if (_cache[overlay] != null &&
        _cacheKey[overlay] == key &&
        at != null &&
        DateTime.now().difference(at) < const Duration(minutes: 15)) {
      return _cache[overlay]!;
    }

    final field = overlay == WeatherOverlay.cloud
        ? 'cloud_cover'
        : 'precipitation';
    final cells = gridOverBounds(bounds, _grid);
    final threshold = minVisible(overlay);

    try {
      final resp = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': cells.map((c) => c.lat.toStringAsFixed(3)).join(','),
          'longitude': cells.map((c) => c.lon.toStringAsFixed(3)).join(','),
          'current': field,
        },
      );
      // Pri viacerých súradniciach vráti Open-Meteo pole objektov,
      // pri jednej jediný objekt — rovnako ako pri vetre.
      final data = resp.data;
      final list = data is List ? data : [data];

      final out = <OverlayCell>[];
      for (var i = 0; i < list.length && i < cells.length; i++) {
        final v = (list[i]['current']?[field] as num?)?.toDouble();
        if (v == null || v < threshold) continue;
        final c = cells[i];
        out.add(OverlayCell(
          lat: c.lat,
          lon: c.lon,
          latSpan: c.latSpan,
          lonSpan: c.lonSpan,
          value: v,
        ));
      }
      _cache[overlay] = out;
      _cacheKey[overlay] = key;
      _fetchedAt[overlay] = DateTime.now();
      return out;
    } catch (_) {
      return _cache[overlay] ?? const [];
    }
  }
}

/// Farba bunky podľa vrstvy a hodnoty.
Color overlayColor(WeatherOverlay overlay, double value) =>
    overlay == WeatherOverlay.cloud
        ? _cloudColor(value)
        : _precipitationColor(value);

/// Stupnica zrážok zámerne kopíruje tú, akú používa radar DHMZ (mm/h): kto si
/// zvykol čítať oficiálnu snímku, vidí v appke tie isté farby pre tie isté
/// hodnoty a nemusí prepínať dve legendy v hlave.
Color _precipitationColor(double mmPerHour) {
  if (mmPerHour < 0.5) return const Color(0xFF9BE7FF);
  if (mmPerHour < 2.5) return const Color(0xFF29B6F6);
  if (mmPerHour < 10) return const Color(0xFF1565C0);
  if (mmPerHour < 25) return const Color(0xFF43A047);
  if (mmPerHour < 50) return const Color(0xFFFDD835);
  if (mmPerHour < 100) return const Color(0xFFFB8C00);
  return const Color(0xFFD32F2F);
}

/// Oblačnosť je odtieň sivej, nie farebná škála: farba by na mape súperila
/// so zrážkami aj s vetrom a pritom ide len o "koľko je zamračené".
Color _cloudColor(double percent) {
  if (percent < 25) return const Color(0xFFE0E0E0);
  if (percent < 50) return const Color(0xFFBDBDBD);
  if (percent < 75) return const Color(0xFF9E9E9E);
  return const Color(0xFF616161);
}
