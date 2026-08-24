import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/metar_observation_service.dart';
import 'package:hmb_sailing_log/core/services/station_observation.dart';
import 'package:latlong2/latlong.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Object data) => ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

({MetarObservationService service, _FakeAdapter adapter}) _serviceWith(
  Future<ResponseBody> Function(RequestOptions options) handler, {
  Duration minInterval = Duration.zero,
}) {
  final dio = Dio();
  final adapter = _FakeAdapter(handler);
  dio.httpClientAdapter = adapter;
  return (
    service: MetarObservationService.forTesting(dio, minInterval: minInterval),
    adapter: adapter,
  );
}

/// Riadok v tvare, aký naozaj vracia aviationweather.gov.
Map<String, dynamic> _row({
  String icao = 'LDZD',
  String name = 'Zadar Arpt, ZD, HR',
  double lat = 44.1,
  double lon = 15.35,
  int obsTime = 1787565600,
  Object? wdir = 260,
  Object? wspd = 7,
  Object? wgst,
  Object? temp = 31,
  Object? altim = 1016,
}) =>
    {
      'icaoId': icao,
      'name': name,
      'lat': lat,
      'lon': lon,
      'obsTime': obsTime,
      'wdir': wdir,
      'wspd': wspd,
      if (wgst != null) 'wgst': wgst,
      'temp': temp,
      'altim': altim,
    };

void main() {
  group('parseMetars', () {
    test('rýchlosť je v uzloch, čas v UTC', () {
      final out = MetarObservationService.parseMetars([_row()]);

      expect(out, hasLength(1));
      final o = out.single;
      // METAR hlási uzly priamo — žiadny prevod sa robiť nesmie.
      expect(o.windSpeedKnots, 7);
      expect(o.windDirectionDeg, 260);
      expect(o.source, ObservationSource.metar);
      expect(o.code, 'LDZD');
      expect(o.observedAt.isUtc, isTrue);
      expect(o.observedAt.millisecondsSinceEpoch, 1787565600 * 1000);
    });

    test('premenlivý smer VRB nie je sever', () {
      // "VRB" príde ako reťazec; keby spadol na nulu, šípka by ukazovala na
      // sever a tvrdila by niečo, čo stanica nenamerala.
      final out = MetarObservationService.parseMetars([_row(wdir: 'VRB')]);

      expect(out.single.windDirectionDeg, isNull);
      expect(out.single.windSpeedKnots, 7);
    });

    test('náraz slabší než stredný vietor sa zahodí', () {
      final out =
          MetarObservationService.parseMetars([_row(wspd: 20, wgst: 14)]);

      expect(out.single.gustKnots, isNull);
    });

    test('náraz sa prevezme, keď dáva zmysel', () {
      final out =
          MetarObservationService.parseMetars([_row(wspd: 12, wgst: 25)]);

      expect(out.single.gustKnots, 25);
    });

    test('stanica bez polohy alebo času sa preskočí, zvyšok prejde', () {
      final broken = _row(icao: 'XXXX')..remove('lat');
      final noTime = _row(icao: 'YYYY')..remove('obsTime');
      final out = MetarObservationService.parseMetars([
        broken,
        noTime,
        _row(icao: 'LDSP'),
      ]);

      expect(out.map((o) => o.code), ['LDSP']);
    });

    test('nezmyselné telo nevyhodí výnimku', () {
      expect(MetarObservationService.parseMetars('<html>'), isEmpty);
      expect(MetarObservationService.parseMetars(null), isEmpty);
      expect(MetarObservationService.parseMetars([42, 'x']), isEmpty);
    });
  });

  group('fetchForBounds', () {
    test('bbox ide v poradí juh, západ, sever, východ', () async {
      final s = _serviceWith((_) async => _jsonBody([_row()]));
      await s.service.fetchForBounds(
        LatLngBounds(const LatLng(43, 15), const LatLng(45, 17)),
      );

      final q = s.adapter.requests.single.queryParameters;
      expect(q['bbox'], '43.00,15.00,45.00,17.00');
      expect(q['format'], 'json');
    });

    test('pri pohľade na pol sveta sa nesťahuje nič', () async {
      // Odpoveď by mala tisíce staníc a mapa by z nich bola nečitateľná.
      final s = _serviceWith((_) async => _jsonBody([_row()]));
      final out = await s.service.fetchForBounds(
        LatLngBounds(const LatLng(20, -30), const LatLng(60, 40)),
      );

      expect(out, isEmpty);
      expect(s.adapter.requests, isEmpty);
    });

    test('rovnaký výrez druhýkrát nesiaha na sieť', () async {
      final s = _serviceWith((_) async => _jsonBody([_row()]));
      final bounds = LatLngBounds(const LatLng(43, 15), const LatLng(45, 17));
      await s.service.fetchForBounds(bounds);
      await s.service.fetchForBounds(bounds);

      expect(s.adapter.requests, hasLength(1));
    });

    test('minimálny odstup drží dotazy pri zemi pri rýchlom posune', () async {
      final s = _serviceWith((_) async => _jsonBody([_row()]),
          minInterval: const Duration(seconds: 20));
      await s.service.fetchForBounds(
        LatLngBounds(const LatLng(43, 15), const LatLng(45, 17)),
      );
      // Iný výrez v tej istej sekunde — bez stropu by to bola druhá dávka.
      await s.service.fetchForBounds(
        LatLngBounds(const LatLng(46, 12), const LatLng(47, 13)),
      );

      expect(s.adapter.requests, hasLength(1));
    });

    test('pád siete vráti poslednú keš, nie prázdno', () async {
      var calls = 0;
      final s = _serviceWith((_) async {
        calls++;
        if (calls == 1) return _jsonBody([_row()]);
        throw DioException(
            requestOptions: RequestOptions(path: ''), message: 'offline');
      });

      await s.service.fetchForBounds(
        LatLngBounds(const LatLng(43, 15), const LatLng(45, 17)),
      );
      // Iný výrez, takže keš pre neho neplatí a pôjde sa na sieť — a spadne.
      final out = await s.service.fetchForBounds(
        LatLngBounds(const LatLng(46, 12), const LatLng(47, 13)),
      );

      expect(s.adapter.requests, hasLength(2),
          reason: 'druhý dotaz musí naozaj odletieť, inak test neskúša nič');
      expect(out, hasLength(1));
      expect(out.single.code, 'LDZD');
    });
  });
}
