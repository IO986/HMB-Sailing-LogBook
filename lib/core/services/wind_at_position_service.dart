import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/distance_calculator.dart';

/// Ktorý model dal hodnoty v [WindReading].
///
/// Nie je to kozmetika: každý z nich má vlastnú podmienku uvedenia zdroja a
/// odčet pri lodi má hovoriť, čí je to číslo.
enum WindModelSource {
  openMeteo('Open-Meteo'),
  metNo('MET Norway');

  const WindModelSource(this.attribution);

  /// Text do atribúcie na mape.
  final String attribution;
}

/// Vietor v jednom bode — na odčítanie pri lodi, nie na kreslenie mriežky.
class WindReading {
  const WindReading({
    required this.speedKn,
    required this.dirDeg,
    required this.gustKn,
    required this.fetchedAt,
    required this.source,
  });

  /// Stredná rýchlosť vetra v uzloch.
  final double speedKn;

  /// Meteorologický smer: ODKIAĽ fúka, v stupňoch.
  final double dirDeg;

  /// Náraz v uzloch, alebo `null` keď ho model pre toto miesto nedal.
  ///
  /// Nulou sa nenahrádza: „bez nárazov" a „nevieme" sú dve rôzne veci a
  /// nulový náraz pri desiatich uzloch vetra je nezmysel, ktorý by sa
  /// vykreslil ako údaj.
  final double? gustKn;

  final DateTime fetchedAt;

  final WindModelSource source;
}

/// Vietor a nárazy v polohe lode (Open-Meteo).
///
/// Zámerne oddelené od [WindGridService]: tá kreslí riedku mriežku šípok cez
/// celý výrez, toto je JEDNA súradnica pre miesto, kde loď naozaj je. Rozdiel
/// nie je kozmetický — Open-Meteo počíta svoj denný limit podľa počtu
/// súradníc, takže odčet pri lodi stojí stotinu toho, čo vrstva.
///
/// Je to MODEL, nie meranie. Prístroje na lodi ani stanica DHMZ sem
/// nevstupujú; kde treba najlepší dostupný zdroj, je na to
/// `EntryConditionsBuilder`.
class WindAtPositionService {
  static final WindAtPositionService _i = WindAtPositionService._(Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
    ),
  ));
  factory WindAtPositionService() => _i;
  WindAtPositionService._(this._dio, {Duration? minInterval})
      : _minInterval = minInterval ?? _defaultMinInterval;

  /// Vlastná inštancia s podstrčeným klientom — testy nesmú siahať na sieť
  /// ani sa navzájom ovplyvňovať cez keš singletonu.
  @visibleForTesting
  factory WindAtPositionService.forTesting(Dio dio,
          {Duration minInterval = Duration.zero}) =>
      WindAtPositionService._(dio, minInterval: minInterval);

  final Dio _dio;

  /// Kým je odčet mladší, nesiaha sa na sieť. Vietor sa za štvrť hodiny
  /// nezmení tak, aby to šípka pri lodi ukázala.
  static const _maxAge = Duration(minutes: 15);

  /// Ako ďaleko musí loď odísť, aby sa hodnota prestala považovať za platnú.
  ///
  /// Päť kilometrov je hrubo pod rozlíšením modelu, takže bližší presun by
  /// aj tak vrátil to isté číslo — len by minul limit.
  static const _maxDriftM = 5000.0;

  /// Po HTTP 429 sa chvíľu neskúša nič, rovnako ako pri vrstvách.
  static const _rateLimitBackoff = Duration(minutes: 10);

  /// Najkratší odstup medzi dvoma sťahovaniami.
  ///
  /// Odčet sleduje aj stred mapy, keď je loď mimo výrez, a rýchle posuny cez
  /// stovky kilometrov by inak vyrobili sériu dotazov. Vietor spred minúty je
  /// stále vietor.
  static const _defaultMinInterval = Duration(seconds: 60);

  final Duration _minInterval;

  WindReading? _cached;
  double? _lat;
  double? _lon;
  DateTime? _lastAttempt;
  DateTime? _rateLimitedUntil;
  Future<WindReading?>? _inFlight;

  /// Narazilo sa na denný limit API?
  ///
  /// UI to potrebuje vedieť: bez tohto vyzerá vyčerpaný limit presne ako
  /// bezvetrie a používateľ hľadá chybu v appke.
  bool get isRateLimited {
    final until = _rateLimitedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  /// Posledný známy odčet bez ohľadu na vek — na okamžité vykreslenie, kým
  /// dobehne nový.
  WindReading? get lastReading => _cached;

  Future<WindReading?> fetchAt(double lat, double lon) {
    final cached = _cached;
    if (cached != null && _lat != null && _lon != null) {
      final fresh = DateTime.now().difference(cached.fetchedAt) < _maxAge;
      final near =
          DistanceCalculator.distanceM(_lat!, _lon!, lat, lon) < _maxDriftM;
      if (fresh && near) return Future.value(cached);
    }

    final last = _lastAttempt;
    if (last != null && DateTime.now().difference(last) < _minInterval) {
      return Future.value(cached);
    }

    // Poloha prichádza z GPS každých pár sekúnd a widget sa pri každej
    // prekresľuje; bez tohto by po vyprší platnosti odletelo naraz desať
    // rovnakých dotazov.
    return _inFlight ??= _fetch(lat, lon).whenComplete(() => _inFlight = null);
  }

  Future<WindReading?> _fetch(double lat, double lon) async {
    _lastAttempt = DateTime.now();
    final reading =
        await _fetchOpenMeteo(lat, lon) ?? await _fetchMetNo(lat, lon);
    if (reading == null) return _cached;
    _cached = reading;
    _lat = lat;
    _lon = lon;
    return reading;
  }

  /// Prvá voľba: dáva nárazy a je to ten istý model ako vo vrstvách mapy,
  /// takže odčet a farebná plocha nehovoria každý svoje.
  Future<WindReading?> _fetchOpenMeteo(double lat, double lon) async {
    if (isRateLimited) return null;
    try {
      final resp = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat.toStringAsFixed(3),
          'longitude': lon.toStringAsFixed(3),
          'current': 'wind_speed_10m,wind_direction_10m,wind_gusts_10m',
          'wind_speed_unit': 'kn',
        },
      );

      // Pri jednej súradnici vracia Open-Meteo jediný objekt, nie pole —
      // ale pole tu neprekáža a chráni pred zmenou na ich strane.
      final data = resp.data;
      final first = data is List ? (data.isEmpty ? null : data.first) : data;
      final current = (first is Map) ? first['current'] : null;
      if (current is! Map) return _cached;

      final speed = (current['wind_speed_10m'] as num?)?.toDouble();
      final dir = (current['wind_direction_10m'] as num?)?.toDouble();
      if (speed == null || dir == null) return _cached;

      // Nárazy sú posledné pridané pole a jediné, ktoré sa nedalo overiť
      // (limit API), preto sa berú ako nepovinné — keď neprídu, odčet ostane
      // platný aj bez nich.
      final gust = (current['wind_gusts_10m'] as num?)?.toDouble();

      _rateLimitedUntil = null;
      return WindReading(
        speedKn: speed,
        dirDeg: dir,
        // Náraz slabší než stredný vietor je chyba dát, nie údaj.
        gustKn: (gust != null && gust >= speed) ? gust : null,
        fetchedAt: DateTime.now(),
        source: WindModelSource.openMeteo,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        _rateLimitedUntil = DateTime.now().add(_rateLimitBackoff);
        debugPrint('[WIND@POS] rate limited, backing off');
      }
      return null;
    } catch (e) {
      debugPrint('[WIND@POS] open-meteo failed: $e');
      return null;
    }
  }

  /// Záskok: Nórsky meteorologický ústav (MET Norway).
  ///
  /// Prečo vôbec druhý zdroj — Open-Meteo má denný limit na IP a keď sa
  /// vyčerpá, odčet pri lodi zmizne. Vietor je bezpečnostný údaj a nemá
  /// prestať kvôli cudziemu limitu.
  ///
  /// Nedáva nárazy: pole `wind_speed_of_gust` model pre Jadran neposiela
  /// (overené na 44,1 N 15,2 E), takže náraz ostane neznámy. Radšej menej
  /// údajov než vymyslený náraz.
  ///
  /// Podmienky MET vyžadujú identifikujúcu hlavičku `User-Agent` a uvedenie
  /// zdroja; to druhé rieši atribúcia na mape cez [WindModelSource].
  Future<WindReading?> _fetchMetNo(double lat, double lon) async {
    try {
      final resp = await _dio.get(
        'https://api.met.no/weatherapi/locationforecast/2.0/compact',
        queryParameters: {
          'lat': lat.toStringAsFixed(3),
          'lon': lon.toStringAsFixed(3),
        },
        options: Options(headers: {'User-Agent': _userAgent}),
      );

      final data = resp.data;
      if (data is! Map) return null;
      final series = (data['properties'] as Map?)?['timeseries'];
      if (series is! List || series.isEmpty) return null;
      final details =
          ((series.first as Map?)?['data'] as Map?)?['instant'] as Map?;
      final d = (details?['details']) as Map?;
      if (d == null) return null;

      final ms = (d['wind_speed'] as num?)?.toDouble();
      final dir = (d['wind_from_direction'] as num?)?.toDouble();
      if (ms == null || dir == null) return null;

      // MET vracia metre za sekundu, appka počíta v uzloch.
      return WindReading(
        speedKn: ms * _knotsPerMs,
        dirDeg: dir,
        gustKn: null,
        fetchedAt: DateTime.now(),
        source: WindModelSource.metNo,
      );
    } catch (e) {
      debugPrint('[WIND@POS] met.no failed: $e');
      return null;
    }
  }

  static const _knotsPerMs = 1.94384;

  /// MET Norway odmieta anonymné dotazy; hlavička musí appku pomenovať a dať
  /// kontakt.
  static const _userAgent = 'HMBSailingLog/1.30 (https://hmba.boats)';
}
