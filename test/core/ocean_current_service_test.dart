import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/ocean_current_service.dart';
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

({OceanCurrentService service, _FakeAdapter adapter}) _serviceWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  final adapter = _FakeAdapter(handler);
  dio.httpClientAdapter = adapter;
  return (service: OceanCurrentService.forTesting(dio), adapter: adapter);
}

Map<String, dynamic> _hourly(List<num?> speeds, List<num?> dirs) => {
      'hourly_units': {
        'ocean_current_velocity': 'km/h',
        'ocean_current_direction': '°',
      },
      'hourly': {
        'time': [
          for (var h = 0; h < speeds.length; h++)
            '2026-07-18T${h.toString().padLeft(2, '0')}:00',
        ],
        'ocean_current_velocity': speeds,
        'ocean_current_direction': dirs,
      },
    };

void main() {
  group('knots conversion', () {
    test('converts km/h to knots at the exact definition', () {
      // 1 knot is defined as 1.852 km/h.
      expect(OceanCurrentService.knotsFromKmh(1.852), closeTo(1, 1e-9));
      expect(OceanCurrentService.knotsFromKmh(0), 0);
      expect(OceanCurrentService.knotsFromKmh(3.704), closeTo(2, 1e-9));
    });
  });

  group('OceanCurrentService.fetchForecast', () {
    test('asks the marine API for the current variables', () async {
      final f = _serviceWith((_) async => _jsonBody(_hourly([0.6], [18])));
      await f.service.fetchForecast(lat: 43.5, lon: 16.44);

      final request = f.adapter.requests.single;
      expect(request.uri.host, 'marine-api.open-meteo.com');
      expect(request.uri.queryParameters['hourly'],
          'ocean_current_velocity,ocean_current_direction');
    });

    test('reports speed in knots, never km/h', () async {
      // 1.852 km/h must surface as exactly 1 kn.
      final f = _serviceWith((_) async => _jsonBody(_hourly([1.852], [90])));
      final points = await f.service.fetchForecast(lat: 43.5, lon: 16.44);

      expect(points.single.speedKn, closeTo(1, 1e-9));
      expect(points.single.dirDeg, 90);
      expect(points.single.time, DateTime.utc(2026, 7, 18));
    });

    test('an inland position yields no data rather than zeros', () async {
      final f = _serviceWith(
        (_) async => _jsonBody(_hourly([null, null], [null, null])),
      );
      expect(await f.service.fetchForecast(lat: 48.15, lon: 17.11), isEmpty);
    });

    test('skips individual null samples but keeps the rest', () async {
      final f = _serviceWith(
        (_) async => _jsonBody(_hourly([0.6, null, 0.4], [18, null, 27])),
      );
      final points = await f.service.fetchForecast(lat: 43.5, lon: 16.44);
      expect(points, hasLength(2));
    });

    test('a response without an hourly block yields no data', () async {
      final f = _serviceWith((_) async => _jsonBody({'error': true}));
      expect(await f.service.fetchForecast(lat: 43.5, lon: 16.44), isEmpty);
    });

    test('propagates a transport failure', () async {
      final f = _serviceWith(
        (options) async => throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
      );
      expect(
        () => f.service.fetchForecast(lat: 43.5, lon: 16.44),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('OceanCurrentService.fetchForBounds', () {
    // The wind layer samples cell centres of a 4x4 grid — eighths 1,3,5,7 of
    // the span. If the current layer used the same formula both sets of
    // arrows would land on identical coordinates and overlap on screen.
    List<double> windGridFractions() =>
        [for (var i = 0; i < 4; i++) (i + 0.5) / 4];

    test('samples points the wind grid never uses, so arrows interleave',
        () async {
      final f = _serviceWith((_) async => _jsonBody([
            for (var i = 0; i < 9; i++)
              {
                'current': {
                  'ocean_current_velocity': 1.852,
                  'ocean_current_direction': 90,
                }
              }
          ]));

      await f.service.fetchForBounds(
        LatLngBounds(const LatLng(0, 0), const LatLng(8, 8)),
      );

      final request = f.adapter.requests.single;
      final lats = request.uri.queryParameters['latitude']!
          .split(',')
          .map(double.parse)
          .toSet();
      final lons = request.uri.queryParameters['longitude']!
          .split(',')
          .map(double.parse)
          .toSet();

      // Span is 8 degrees, so wind sits at 1, 3, 5, 7 and current at 2, 4, 6.
      final windLats = windGridFractions().map((f) => f * 8).toSet();
      expect(lats.intersection(windLats), isEmpty);
      expect(lons.intersection(windLats), isEmpty);
      expect(lats, {2.0, 4.0, 6.0});
    });

    test('every sampled point stays inside the requested bounds', () async {
      final f = _serviceWith((_) async => _jsonBody(const []));
      await f.service.fetchForBounds(
        LatLngBounds(const LatLng(43, 16), const LatLng(44, 17)),
      );

      final request = f.adapter.requests.single;
      final lats = request.uri.queryParameters['latitude']!
          .split(',')
          .map(double.parse);
      final lons = request.uri.queryParameters['longitude']!
          .split(',')
          .map(double.parse);

      expect(lats.every((v) => v > 43 && v < 44), isTrue);
      expect(lons.every((v) => v > 16 && v < 17), isTrue);
    });
  });

  group('OceanCurrentService.nearestTo', () {
    final base = DateTime.utc(2026, 7, 18);
    List<SeaCurrentPoint> points() => [
          for (var h = 0; h < 4; h++)
            SeaCurrentPoint(
              lat: 43.5,
              lon: 16.44,
              speedKn: h.toDouble(),
              dirDeg: 0,
              time: base.add(Duration(hours: h)),
            ),
        ];

    test('picks the sample closest in time, before or after', () {
      expect(
        OceanCurrentService.nearestTo(
                points(), base.add(const Duration(hours: 2, minutes: 10)))!
            .speedKn,
        2,
      );
      expect(
        OceanCurrentService.nearestTo(
                points(), base.add(const Duration(hours: 2, minutes: 50)))!
            .speedKn,
        3,
      );
    });

    test('clamps to the ends rather than returning nothing', () {
      expect(
        OceanCurrentService.nearestTo(
                points(), base.subtract(const Duration(days: 1)))!
            .speedKn,
        0,
      );
      expect(
        OceanCurrentService.nearestTo(points(), base.add(const Duration(days: 1)))!
            .speedKn,
        3,
      );
    });

    test('an empty list has no nearest sample', () {
      expect(OceanCurrentService.nearestTo(const [], base), isNull);
    });
  });
}
