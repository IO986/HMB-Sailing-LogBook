import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/wind_at_position_service.dart';

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

ResponseBody _jsonBody(Object data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

({WindAtPositionService service, _FakeAdapter adapter}) _serviceWith(
  Future<ResponseBody> Function(RequestOptions options) handler, {
  Duration minInterval = Duration.zero,
}) {
  final dio = Dio();
  final adapter = _FakeAdapter(handler);
  dio.httpClientAdapter = adapter;
  return (
    service: WindAtPositionService.forTesting(dio, minInterval: minInterval),
    adapter: adapter,
  );
}

/// Odpoveď MET Norway, ktorá slúži ako záskok. Rýchlosť je v m/s.
Map<String, dynamic> _metNo({num ms = 5, num dir = 200}) => {
      'properties': {
        'timeseries': [
          {
            'time': '2026-08-23T13:00:00Z',
            'data': {
              'instant': {
                'details': {
                  'wind_speed': ms,
                  'wind_from_direction': dir,
                },
              },
            },
          },
        ],
      },
    };

bool _isMetNo(RequestOptions o) => o.uri.host == 'api.met.no';

Map<String, dynamic> _current({
  num speed = 12,
  num dir = 45,
  num? gust = 18,
}) =>
    {
      'current': {
        'wind_speed_10m': speed,
        'wind_direction_10m': dir,
        if (gust != null) 'wind_gusts_10m': gust,
      },
    };

void main() {
  test('rozparsuje vietor, smer aj náraz', () async {
    final s = _serviceWith((_) async => _jsonBody(_current()));
    final r = await s.service.fetchAt(44.1, 15.2);

    expect(r, isNotNull);
    expect(r!.speedKn, 12);
    expect(r.dirDeg, 45);
    expect(r.gustKn, 18);
  });

  test('chýbajúci náraz nezruší odčet, len ostane neznámy', () async {
    final s = _serviceWith((_) async => _jsonBody(_current(gust: null)));
    final r = await s.service.fetchAt(44.1, 15.2);

    expect(r!.speedKn, 12);
    expect(r.gustKn, isNull);
  });

  test('náraz slabší než stredný vietor sa zahodí', () async {
    // Náraz pod strednou rýchlosťou je chyba dát; vykresliť ho ako údaj by
    // znamenalo ukázať skiperovi nezmysel.
    final s = _serviceWith((_) async => _jsonBody(_current(speed: 20, gust: 14)));
    final r = await s.service.fetchAt(44.1, 15.2);

    expect(r!.speedKn, 20);
    expect(r.gustKn, isNull);
  });

  test('malý posun lode nespustí nové sťahovanie', () async {
    final s = _serviceWith((_) async => _jsonBody(_current()));
    await s.service.fetchAt(44.1, 15.2);
    // ~1,1 km na sever — hlboko pod prahom.
    await s.service.fetchAt(44.11, 15.2);

    expect(s.adapter.requests, hasLength(1));
  });

  test('posun za prah keš zneplatní', () async {
    var speed = 12;
    final s = _serviceWith((_) async {
      final body = _jsonBody(_current(speed: speed));
      speed = 25;
      return body;
    });
    await s.service.fetchAt(44.1, 15.2);
    // ~11 km na sever, teda viac než päťkilometrový prah.
    final r = await s.service.fetchAt(44.2, 15.2);

    expect(s.adapter.requests, hasLength(2));
    expect(r!.speedKn, 25);
  });

  test('po 429 sa prejde na MET Norway a prepočíta sa na uzly', () async {
    final s = _serviceWith((o) async {
      if (_isMetNo(o)) return _jsonBody(_metNo(ms: 10));
      return _jsonBody({'error': true}, status: 429);
    });

    final r = await s.service.fetchAt(44.1, 15.2);

    expect(r, isNotNull);
    expect(r!.source, WindModelSource.metNo);
    expect(r.speedKn, closeTo(19.44, 0.01));
    expect(r.dirDeg, 200);
    // MET pre Jadran nárazy nedáva a vymyslieť sa nesmú.
    expect(r.gustKn, isNull);
    expect(s.service.isRateLimited, isTrue);
  });

  test('po 429 sa na Open-Meteo už nesiaha, ide sa rovno na záskok', () async {
    final s = _serviceWith((o) async {
      if (_isMetNo(o)) return _jsonBody(_metNo());
      return _jsonBody({'error': true}, status: 429);
    });

    await s.service.fetchAt(44.1, 15.2);
    // Za prahom vzdialenosti, takže sa sťahuje znova — ale už len z MET.
    await s.service.fetchAt(44.4, 15.2);

    final hosts = s.adapter.requests.map((r) => r.uri.host).toList();
    expect(hosts, ['api.open-meteo.com', 'api.met.no', 'api.met.no']);
  });

  test('MET Norway dostane identifikujúcu hlavičku', () async {
    // Bez nej dotazy odmieta — je to podmienka ich používania.
    final s = _serviceWith((o) async {
      if (_isMetNo(o)) return _jsonBody(_metNo());
      return _jsonBody({'error': true}, status: 429);
    });
    await s.service.fetchAt(44.1, 15.2);

    final met = s.adapter.requests.firstWhere(_isMetNo);
    expect(met.headers['User-Agent'], contains('HMBSailingLog'));
  });

  test('minimálny odstup drží dotazy pri zemi aj pri rýchlom posune',
      () async {
    final s = _serviceWith((_) async => _jsonBody(_current()),
        minInterval: const Duration(seconds: 60));
    await s.service.fetchAt(44.1, 15.2);
    // Skok o stovky kilometrov, ale v tej istej sekunde.
    await s.service.fetchAt(46.0, 13.0);

    expect(s.adapter.requests, hasLength(1));
  });

  test('dotaz pýta uzly a všetky tri polia', () async {
    final s = _serviceWith((_) async => _jsonBody(_current()));
    await s.service.fetchAt(44.1, 15.2);

    final q = s.adapter.requests.single.queryParameters;
    expect(q['wind_speed_unit'], 'kn');
    expect(q['current'], contains('wind_gusts_10m'));
    // Jedna súradnica, nie mriežka — limit Open-Meteo sa počíta podľa nich.
    expect(q['latitude'], '44.100');
    expect(q['longitude'], '15.200');
  });
}
