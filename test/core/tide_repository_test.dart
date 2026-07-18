import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/tide_data.dart';
import 'package:hmb_sailing_log/core/services/tide_forecast_service.dart';
import 'package:hmb_sailing_log/core/services/tide_repository.dart';
import 'package:hmb_sailing_log/core/services/tide_service.dart';

/// Stands in for the network: either answers with canned points or throws.
class _StubForecastService implements TideForecastService {
  _StubForecastService.returning(this._points) : _error = null;
  _StubForecastService.failing(Object error)
      : _points = const [],
        _error = error;

  final List<TidePoint> _points;
  final Object? _error;
  int calls = 0;

  @override
  Future<List<TidePoint>> fetchTides({
    required double lat,
    required double lon,
    int days = 7,
  }) async {
    calls++;
    final error = _error;
    if (error != null) throw error;
    return _points;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<TidePoint> _samplePoints(DateTime start) => [
      TidePoint(time: start, heightM: 0.1),
      TidePoint(time: start.add(const Duration(hours: 1)), heightM: 0.4),
      TidePoint(time: start.add(const Duration(hours: 2)), heightM: 0.1),
      TidePoint(
        time: start.add(const Duration(hours: 1)),
        heightM: 0.42,
        extremeType: 'high',
      ),
    ];

void main() {
  late AppDatabase db;
  final start = DateTime.utc(2026, 7, 18);

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    TideRepository().setDatabase(db);
    TideService().setDatabase(db);
  });

  tearDown(() async => db.close());

  Future<void> seedCache() async {
    TideRepository().setForecastService(
      _StubForecastService.returning(_samplePoints(start)),
    );
    final result =
        await TideRepository().syncTides(lat: 43.5, lon: 16.44);
    expect(result, TideSyncResult.updated);
  }

  group('TideRepository.syncTides', () {
    test('stores the fetched curve and its extremes', () async {
      await seedCache();

      final forecast = await TideService().getForecast();
      expect(forecast.points, hasLength(4));
      expect(forecast.points.where((p) => p.isHigh), hasLength(1));
      expect(forecast.latitude, closeTo(43.5, 1e-9));
      expect(forecast.longitude, closeTo(16.44, 1e-9));
      expect(forecast.downloadedAt, isNotNull);
    });

    test('a failed fetch reports failure and leaves the cache intact',
        () async {
      // This is the regression that matters offline: refreshing without a
      // signal used to wipe a perfectly usable forecast before discovering
      // the network was gone.
      await seedCache();

      final stub = _StubForecastService.failing(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/'),
          reason: 'offline',
        ),
      );
      TideRepository().setForecastService(stub);

      final result = await TideRepository().syncTides(lat: 43.5, lon: 16.44);

      expect(result, TideSyncResult.failed);
      expect(stub.calls, 1);
      final forecast = await TideService().getForecast();
      expect(forecast.points, hasLength(4),
          reason: 'cache must survive a failed refresh');
    });

    test('an out-of-coverage position reports noCoverage and keeps the cache',
        () async {
      await seedCache();

      TideRepository()
          .setForecastService(_StubForecastService.returning(const []));
      final result = await TideRepository().syncTides(lat: 48.15, lon: 17.11);

      expect(result, TideSyncResult.noCoverage);
      final forecast = await TideService().getForecast();
      expect(forecast.points, hasLength(4));
    });

    test('a successful fetch replaces the previous position entirely',
        () async {
      await seedCache();

      final later = start.add(const Duration(days: 1));
      TideRepository().setForecastService(
        _StubForecastService.returning([
          TidePoint(time: later, heightM: 2),
          TidePoint(time: later.add(const Duration(hours: 1)), heightM: 3),
        ]),
      );
      await TideRepository().syncTides(lat: 48.65, lon: -2.15);

      final forecast = await TideService().getForecast();
      expect(forecast.points, hasLength(2),
          reason: 'stale rows from the old position must not linger');
      expect(forecast.latitude, closeTo(48.65, 1e-9));
    });
  });

  group('manually picked area', () {
    test('remembers the place name and that the choice was deliberate',
        () async {
      TideRepository().setForecastService(
        _StubForecastService.returning(_samplePoints(start)),
      );
      await TideRepository().syncTides(
        lat: 43.5,
        lon: 16.44,
        locationLabel: 'Split, Croatia',
        manualSelection: true,
      );

      final forecast = await TideService().getForecast();
      expect(forecast.locationLabel, 'Split, Croatia');
      expect(forecast.manualSelection, isTrue);
    });

    test('a position-based download is not marked manual', () async {
      await seedCache();

      final forecast = await TideService().getForecast();
      expect(forecast.manualSelection, isFalse);
      expect(forecast.locationLabel, isNull);
    });
  });

  group('TideForecast', () {
    test('expires once now passes the last stored sample', () async {
      await seedCache();
      final forecast = await TideService().getForecast();

      expect(forecast.isExpiredAt(start.add(const Duration(hours: 1))), isFalse);
      expect(forecast.isExpiredAt(start.add(const Duration(days: 1))), isTrue);
    });

    test('measures distance from where it was downloaded', () async {
      await seedCache();
      final forecast = await TideService().getForecast();

      expect(forecast.distanceKmFrom(43.5, 16.44), closeTo(0, 1));
      // Split → Saint-Malo is roughly 1600 km as the crow flies.
      expect(forecast.distanceKmFrom(48.65, -2.15), closeTo(1600, 150));
    });

    test('an empty forecast has no distance and counts as expired', () {
      expect(TideForecast.empty.distanceKmFrom(43.5, 16.44), isNull);
      expect(TideForecast.empty.isExpiredAt(DateTime.utc(2026)), isTrue);
    });

    test('next extreme skips the ones already past', () async {
      await seedCache();
      final forecast = await TideService().getForecast();

      expect(forecast.nextExtremeAfter(start)?.isHigh, isTrue);
      expect(
        forecast.nextExtremeAfter(start.add(const Duration(hours: 5))),
        isNull,
      );
    });
  });
}
