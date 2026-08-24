import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

import 'station_observation.dart';

/// Namerané hlásenia z letísk (METAR) pre ľubovoľné miesto na svete.
///
/// Prečo práve METAR: appka nie je len pre Jadran, ale jediný meraný zdroj,
/// ktorý mala, bol chorvátsky DHMZ. Mimo Chorvátska ostávala vrstva meraní
/// prázdna. METAR-y vydávajú letiská celého sveta každú polhodinu, sú
/// bezplatné, bez kľúča, a rýchlosť hlásia **rovno v uzloch** — teda v tom, v
/// čom sa plachtí.
///
/// Ich slabina je poloha: letiská bývajú vo vnútrozemí a na ostrovoch ich je
/// málo. Preto sa nikdy neprepočítavajú na polohu lode — kreslia sa tam, kde
/// naozaj stoja, a vzdialenosť si posúdi ten, kto sa pozerá.
///
/// Zdroj je NOAA Aviation Weather Center, teda vláda USA a public domain.
class MetarObservationService {
  static final MetarObservationService _i =
      MetarObservationService._(Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  )));
  factory MetarObservationService() => _i;
  MetarObservationService._(this._dio, {Duration? minInterval})
      : _minInterval = minInterval ?? _defaultMinInterval;

  @visibleForTesting
  factory MetarObservationService.forTesting(Dio dio,
          {Duration minInterval = Duration.zero}) =>
      MetarObservationService._(dio, minInterval: minInterval);

  final Dio _dio;

  static const _endpoint = 'https://aviationweather.gov/api/data/metar';

  /// Stanice hlásia po pol hodine; častejšie sťahovanie by nič nové neprinieslo.
  static const cacheTtl = Duration(minutes: 15);

  /// Najkratší odstup medzi dvoma sťahovaniami — posúvanie mapy mení výrez
  /// stále a hrubý kľúč to nezachytí.
  static const _defaultMinInterval = Duration(seconds: 20);

  final Duration _minInterval;

  /// Nad týmto rozsahom výrezu sa nesťahuje nič.
  ///
  /// Pri pohľade na pol sveta by odpoveď obsahovala tisíce staníc a mapa by
  /// z nich bola nečitateľná ešte skôr, než by sa dokreslila.
  static const maxSpanDeg = 12.0;

  List<StationObservation>? _cache;
  String? _cacheKey;
  DateTime? _fetchedAt;
  DateTime? _lastAttempt;

  /// Hrubý kľúč (desatiny stupňa): drobné posuny mapy nespúšťajú sťahovanie.
  static String cacheKey(LatLngBounds b) =>
      '${b.south.toStringAsFixed(1)}:${b.west.toStringAsFixed(1)}:'
      '${b.north.toStringAsFixed(1)}:${b.east.toStringAsFixed(1)}';

  /// Merania pre viditeľný výrez. Nikdy nevyhadzuje výnimku — bez siete
  /// vráti poslednú keš, prípadne prázdny zoznam (pravidlo offline-first).
  Future<List<StationObservation>> fetchForBounds(LatLngBounds bounds) async {
    if (bounds.north - bounds.south > maxSpanDeg ||
        bounds.east - bounds.west > maxSpanDeg) {
      return _cache ?? const [];
    }

    final key = cacheKey(bounds);
    final at = _fetchedAt;
    if (_cache != null &&
        _cacheKey == key &&
        at != null &&
        DateTime.now().difference(at) < cacheTtl) {
      return _cache!;
    }

    final last = _lastAttempt;
    if (last != null && DateTime.now().difference(last) < _minInterval) {
      return _cache ?? const [];
    }
    _lastAttempt = DateTime.now();

    try {
      final resp = await _dio.get(_endpoint, queryParameters: {
        // Poradie je juh, západ, sever, východ.
        'bbox': '${bounds.south.toStringAsFixed(2)},'
            '${bounds.west.toStringAsFixed(2)},'
            '${bounds.north.toStringAsFixed(2)},'
            '${bounds.east.toStringAsFixed(2)}',
        'format': 'json',
      });

      final parsed = parseMetars(resp.data);
      _cache = parsed;
      _cacheKey = key;
      _fetchedAt = DateTime.now();
      debugPrint('[METAR] ${parsed.length} stations');
      return parsed;
    } catch (e) {
      debugPrint('[METAR] fetch failed: $e');
      return _cache ?? const [];
    }
  }

  /// Rozparsuje odpoveď služby.
  ///
  /// Obranné zámerne: pole je cudzie a jedna pokazená stanica nesmie vziať
  /// so sebou celý zoznam.
  @visibleForTesting
  static List<StationObservation> parseMetars(dynamic data) {
    if (data is! List) return const [];
    final out = <StationObservation>[];
    for (final row in data) {
      if (row is! Map) continue;
      final lat = _toDouble(row['lat']);
      final lon = _toDouble(row['lon']);
      final obs = _toInt(row['obsTime']);
      if (lat == null || lon == null || obs == null) continue;

      final name = (row['name'] as String?)?.trim();
      final icao = (row['icaoId'] as String?)?.trim();
      if ((name == null || name.isEmpty) && (icao == null || icao.isEmpty)) {
        continue;
      }

      final speed = _toDouble(row['wspd']);
      out.add(StationObservation(
        station: (name == null || name.isEmpty) ? icao! : name,
        code: (icao == null || icao.isEmpty) ? null : icao,
        latitude: lat,
        longitude: lon,
        observedAt:
            DateTime.fromMillisecondsSinceEpoch(obs * 1000, isUtc: true),
        source: ObservationSource.metar,
        windSpeedKnots: speed,
        // "VRB" (premenlivý) príde ako reťazec a nie je to smer — nechať ho
        // spadnúť na nulu by nakreslilo šípku na sever.
        windDirectionDeg: _toDouble(row['wdir']),
        // Náraz slabší než stredný vietor je chyba hlásenia, nie údaj.
        gustKnots: _gust(_toDouble(row['wgst']), speed),
        airTemp: _toDouble(row['temp']),
        airPressure: _toDouble(row['altim']),
      ));
    }
    return out;
  }

  static double? _gust(double? gust, double? speed) {
    if (gust == null) return null;
    if (speed != null && gust < speed) return null;
    return gust;
  }

  static double? _toDouble(dynamic v) =>
      v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);

  static int? _toInt(dynamic v) =>
      v is num ? v.toInt() : (v is String ? int.tryParse(v) : null);
}
