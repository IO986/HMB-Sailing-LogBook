import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  cloud,

  /// Rýchlosť vetra v uzloch.
  ///
  /// Ako plocha, nie šípky: spojité pole ukáže, kde vietor zosilňuje a kde
  /// slabne, na čo je riedka mriežka šípok slepá. Šípky sa kreslia navrchu —
  /// tie zas vedia smer a číslo, čo farba nepovie.
  wind;

  static WeatherOverlay fromIndex(int? i) =>
      (i == null || i < 0 || i >= values.length) ? none : values[i];
}

/// Pravidelná mriežka hodnôt nad výrezom mapy.
///
/// Nesie VŠETKY hodnoty vrátane núl, nie len tie nad prahom: prázdne miesta sú
/// pri vyhladzovaní rovnako dôležité ako plné, inak by okraje plôch skákali.
class OverlayField {
  const OverlayField({
    required this.bounds,
    required this.size,
    required this.values,
    required this.overlay,
  });

  final LatLngBounds bounds;

  /// Mriežka je [size]×[size].
  final int size;

  /// Hodnoty po riadkoch od juhu na sever, v každom riadku od západu na východ.
  final List<double> values;

  final WeatherOverlay overlay;

  /// Hodnota na mriežkovej pozícii, orezaná na okraje.
  double at(int row, int col) {
    final r = row.clamp(0, size - 1);
    final c = col.clamp(0, size - 1);
    return values[r * size + c];
  }

  /// Nie je čo kresliť — nikde nič nad prahom viditeľnosti.
  bool get isEmpty =>
      values.every((v) => v < WeatherOverlayGridService.minVisible(overlay));

  double get maxValue =>
      values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
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

  /// Hustota mriežky.
  ///
  /// Bola 16×16 = 256 bodov a bola to chyba: Open-Meteo počíta svoj limit
  /// podľa POČTU SÚRADNÍC, nie požiadaviek, takže každý posun mapy stál 256
  /// „volaní" a po pár posunoch vracalo API HTTP 429 — vrstva prestala
  /// fungovať úplne, aj vietor s ňou.
  ///
  /// 10×10 stačí: plynulosť nerobí hustota, ale bilineárna interpolácia do
  /// rastra (viď `weather_overlay_raster.dart`).
  static const gridSize = 10;

  /// O koľko väčšia plocha sa sťahuje, než je práve vidno.
  ///
  /// Kým sa mapa hýbe vnútri stiahnutej plochy, na sieť sa nesiaha vôbec —
  /// posun je tak plynulý a limit sa nemíňa.
  static const _padFactor = 0.6;

  /// Po HTTP 429 sa chvíľu neskúša nič. Ďalšie dotazy by limit len
  /// predlžovali a používateľ by aj tak nič nedostal.
  static const _rateLimitBackoff = Duration(minutes: 10);

  DateTime? _rateLimitedUntil;

  /// Narazilo sa na denný limit API?
  ///
  /// Prázdna vrstva a vyčerpaný limit vyzerajú na mape rovnako — bez tohto
  /// príznaku by appka na oboje napísala „v tomto výreze slabý vietor" a
  /// tvrdila by tým niečo, čo nevie.
  bool get isRateLimited {
    final until = _rateLimitedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  /// Pod týmto sa nekreslí nič. Model dáva aj stotiny milimetra a jednotky
  /// percent oblačnosti, z ktorých by bola mapa zafarbená aj za jasného dňa.
  static double minVisible(WeatherOverlay overlay) => switch (overlay) {
        WeatherOverlay.cloud => 10,
        // Pod dva uzly je hladina; farbiť ju by len zašpinilo mapu.
        WeatherOverlay.wind => 2,
        _ => 0.1,
      };

  static String _apiField(WeatherOverlay overlay) => switch (overlay) {
        WeatherOverlay.cloud => 'cloud_cover',
        WeatherOverlay.wind => 'wind_speed_10m',
        _ => 'precipitation',
      };

  final _cache = <WeatherOverlay, OverlayField>{};
  final _fetchedAt = <WeatherOverlay, DateTime>{};

  Future<OverlayField?> fetchForBounds(
      LatLngBounds bounds, WeatherOverlay overlay) async {
    if (overlay == WeatherOverlay.none) return null;

    final cached = _cache[overlay];
    final at = _fetchedAt[overlay];
    final fresh = at != null &&
        DateTime.now().difference(at) < const Duration(minutes: 15);

    // Kým je viditeľný výrez celý vnútri už stiahnutej plochy, nesiaha sa na
    // sieť — to je celý dôvod, prečo sa sťahuje väčšia plocha.
    if (cached != null && fresh && boundsContain(cached.bounds, bounds)) {
      return cached;
    }
    debugPrint('[OVERLAY] ${overlay.name} refetch '
        '(cached=${cached != null} fresh=$fresh)');

    final limited = _rateLimitedUntil;
    if (limited != null && DateTime.now().isBefore(limited)) {
      return cached;
    }

    final field = _apiField(overlay);
    final padded = padBounds(bounds, _padFactor);
    final cells = gridOverBounds(padded, gridSize);

    try {
      final resp = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': cells.map((c) => c.lat.toStringAsFixed(3)).join(','),
          'longitude': cells.map((c) => c.lon.toStringAsFixed(3)).join(','),
          'current': field,
          if (overlay == WeatherOverlay.wind) 'wind_speed_unit': 'kn',
        },
      );
      // Pri viacerých súradniciach vráti Open-Meteo pole objektov,
      // pri jednej jediný objekt — rovnako ako pri vetre.
      final data = resp.data;
      final list = data is List ? data : [data];
      if (list.length < cells.length) return _cache[overlay];

      final values = <double>[
        for (var i = 0; i < cells.length; i++)
          (list[i]['current']?[field] as num?)?.toDouble() ?? 0,
      ];

      final out = OverlayField(
        bounds: padded,
        size: gridSize,
        values: values,
        overlay: overlay,
      );
      _cache[overlay] = out;
      _fetchedAt[overlay] = DateTime.now();
      _rateLimitedUntil = null;
      debugPrint('[OVERLAY] ${overlay.name} fetched, max=${out.maxValue}');
      return out;
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        _rateLimitedUntil = DateTime.now().add(_rateLimitBackoff);
        debugPrint('[OVERLAY] rate limited, backing off');
      }
      return _cache[overlay];
    } catch (e) {
      debugPrint('[OVERLAY] ${overlay.name} fetch failed: $e');
      return _cache[overlay];
    }
  }
}

/// Farba bunky podľa vrstvy a hodnoty.
Color overlayColor(WeatherOverlay overlay, double value) => switch (overlay) {
      WeatherOverlay.cloud => _cloudColor(value),
      WeatherOverlay.wind => windColor(value),
      _ => _precipitationColor(value),
    };

/// Stupnica rýchlosti vetra v uzloch.
///
/// Modrá pre hladinu, cez zelenú a žltú do červenej — rovnaké poradie, aké
/// pozná každý z máp vetra, takže sa nemusí učiť nová konvencia. Prahy sedia
/// na to, čo skipera zaujíma: 12 kn je príjemná plavba, 20 kn refovanie,
/// 30 kn už rozhodovanie, či vôbec vyplávať.
Color windColor(double knots) {
  if (knots < 6) return const Color(0xFF3E7BD6);
  if (knots < 12) return const Color(0xFF35A79C);
  if (knots < 18) return const Color(0xFF7CB342);
  if (knots < 24) return const Color(0xFFFDD835);
  if (knots < 30) return const Color(0xFFFB8C00);
  if (knots < 40) return const Color(0xFFE53935);
  return const Color(0xFF8E24AA);
}

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
  if (percent < 25) return const Color(0xFFE8E8E8);
  if (percent < 50) return const Color(0xFFC4C4C4);
  if (percent < 75) return const Color(0xFF9E9E9E);
  return const Color(0xFF6E6E6E);
}
