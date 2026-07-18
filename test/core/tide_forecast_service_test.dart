import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/tide_forecast_service.dart';

/// No real sockets — hands a canned body (or throws) back to dio and records
/// every request it saw.
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

({TideForecastService service, _FakeAdapter adapter}) _serviceWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  final adapter = _FakeAdapter(handler);
  dio.httpClientAdapter = adapter;
  return (service: TideForecastService(dio: dio), adapter: adapter);
}

/// Shape of a real Open-Meteo marine response, trimmed to a single tidal cycle.
Map<String, dynamic> _response(List<num?> heights) => {
      'latitude': 43.5,
      'longitude': 16.44,
      'hourly_units': {'time': 'iso8601', 'sea_level_height_msl': 'm'},
      'hourly': {
        'time': [
          for (var h = 0; h < heights.length; h++)
            '2026-07-18T${h.toString().padLeft(2, '0')}:00',
        ],
        'sea_level_height_msl': heights,
      },
    };

void main() {
  group('TideForecastService', () {
    test('asks Open-Meteo marine for sea level, with no API key', () async {
      final f = _serviceWith((_) async => _jsonBody(_response([0, 1, 0])));
      await f.service.fetchTides(lat: 43.5, lon: 16.44);

      final request = f.adapter.requests.single;
      expect(request.uri.host, 'marine-api.open-meteo.com');
      expect(request.uri.queryParameters['hourly'], 'sea_level_height_msl');
      expect(request.uri.queryParameters['latitude'], '43.5');
      expect(request.uri.queryParameters['longitude'], '16.44');
      // Nothing in the request may look like a credential.
      expect(request.uri.query.toLowerCase(), isNot(contains('key')));
    });

    test('parses the curve and marks times as UTC', () async {
      final f = _serviceWith((_) async => _jsonBody(_response([0.1, 0.4, 0.2])));
      final points = await f.service.fetchTides(lat: 43.5, lon: 16.44);

      final curve = points.where((p) => p.extremeType == null).toList();
      expect(curve, hasLength(3));
      expect(curve.first.time, DateTime.utc(2026, 7, 18));
      expect(curve.first.time.isUtc, isTrue);
      expect(curve[1].heightM, closeTo(0.4, 1e-9));
    });

    test('appends locally derived extremes to the curve', () async {
      final f = _serviceWith(
        (_) async => _jsonBody(_response([0, 1, 3, 1, 0, -2, 0])),
      );
      final points = await f.service.fetchTides(lat: 43.5, lon: 16.44);

      final extremes = points.where((p) => p.extremeType != null).toList();
      expect(extremes.map((e) => e.extremeType), ['high', 'low']);
    });

    test('an inland position (all-null heights) yields no data, not gaps',
        () async {
      // Open-Meteo answers 200 OK with nulls outside its marine grid.
      final f = _serviceWith(
        (_) async => _jsonBody(_response([null, null, null])),
      );
      expect(await f.service.fetchTides(lat: 48.15, lon: 17.11), isEmpty);
    });

    test('skips individual null samples but keeps the rest', () async {
      final f = _serviceWith(
        (_) async => _jsonBody(_response([0.1, null, 0.3])),
      );
      final points = await f.service.fetchTides(lat: 43.5, lon: 16.44);
      expect(points.where((p) => p.extremeType == null), hasLength(2));
    });

    test('a response without an hourly block yields no data', () async {
      final f = _serviceWith((_) async => _jsonBody({'error': true}));
      expect(await f.service.fetchTides(lat: 43.5, lon: 16.44), isEmpty);
    });

    test('propagates a transport failure so the caller can keep its cache',
        () async {
      final f = _serviceWith(
        (options) async => throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
      );
      expect(
        () => f.service.fetchTides(lat: 43.5, lon: 16.44),
        throwsA(isA<DioException>()),
      );
    });
  });
}
