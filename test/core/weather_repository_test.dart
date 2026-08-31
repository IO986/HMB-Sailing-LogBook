import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/services/marine_weather_service.dart';
import 'package:hmb_sailing_log/core/services/weather_forecast_service.dart';
import 'package:hmb_sailing_log/core/services/weather_repository.dart';

/// Stojí za sieťou: buď vráti pripravenú odpoveď, alebo spadne.
class _StubForecast implements WeatherForecastService {
  _StubForecast.returning(this._body) : _error = null;
  _StubForecast.failingFor(this._failingModel, this._body, {Object? error})
      : _error = null,
        _modelError = error ?? const FormatException('Unexpected character (nan)');
  _StubForecast.failing(Object error)
      : _body = const {},
        _error = error;

  final Map<String, dynamic> _body;
  final Object? _error;
  String? _failingModel;
  Object? _modelError;

  final List<String?> modelsAsked = [];

  @override
  Future<Map<String, dynamic>> fetchForecast({
    required double lat,
    required double lon,
    String? model,
  }) async {
    modelsAsked.add(model);
    final error = _error;
    if (error != null) throw error;
    if (_failingModel != null && model == _failingModel) {
      // Mimo pokrytia vracia Open-Meteo buď `latitude: nan` (parser to zbalí
      // do FormatException), alebo rovno HTTP 400 — obe simuluje _modelError.
      throw _modelError!;
    }
    return _body;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubMarine implements MarineWeatherService {
  _StubMarine(this._body) : _error = null;
  _StubMarine.failing(Object error)
      : _body = const {},
        _error = error;

  final Map<String, dynamic> _body;
  final Object? _error;

  @override
  Future<Map<String, dynamic>> fetchMarine({
    required double lat,
    required double lon,
  }) async {
    final error = _error;
    if (error != null) throw error;
    return _body;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _forecastBody({double wind = 12}) => {
      'hourly': {
        'time': ['2026-08-24T10:00', '2026-08-24T11:00'],
        'wind_speed_10m': [wind, wind + 1],
        'wind_direction_10m': [280, 285],
        'surface_pressure': [1016.0, 1015.5],
        'temperature_2m': [24.0, 25.0],
        'cloud_cover': [10.0, 20.0],
        'weather_code': [1, 2],
        'precipitation_probability': [0, 5],
        'precipitation': [0.0, 0.1],
      },
    };

Map<String, dynamic> _marineBody() => {
      'hourly': {
        'time': ['2026-08-24T10:00', '2026-08-24T11:00'],
        'wave_height': [0.4, 0.5],
        'wave_period': [3.0, 3.2],
        'sea_surface_temperature': [25.0, 25.1],
      },
    };

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async => db.close());

  test('neúspešné sťahovanie nezmaže poslednú predpoveď', () async {
    // Toto je celý dôvod prepisu: keš sa mazala PRED sťahovaním, takže
    // obnovenie bez signálu nechalo prázdnu obrazovku.
    final ok = WeatherRepository.forTesting(
      db: db,
      forecast: _StubForecast.returning(_forecastBody()),
      marine: _StubMarine(_marineBody()),
    );
    await ok.syncWeather(lat: 44.1, lon: 15.2);
    expect(await db.getWeatherSnapshots(), hasLength(2));

    final offline = WeatherRepository.forTesting(
      db: db,
      forecast: _StubForecast.failing(DioException.connectionError(
          requestOptions: RequestOptions(path: ''), reason: 'no network')),
      marine: _StubMarine(_marineBody()),
    );
    await expectLater(
      offline.syncWeather(lat: 44.1, lon: 15.2),
      throwsA(isA<DioException>()),
    );

    final kept = await db.getWeatherSnapshots();
    expect(kept, hasLength(2), reason: 'stará predpoveď musí prežiť');
  });

  test('výpadok siete neskúša druhý model', () async {
    // Na kolísavom spojení by záskok len zdvojil každý neúspešný dotaz.
    final forecast = _StubForecast.failing(DioException.connectionError(
        requestOptions: RequestOptions(path: ''), reason: 'no network'));
    final repo = WeatherRepository.forTesting(
      db: db,
      forecast: forecast,
      marine: _StubMarine(_marineBody()),
    );

    await expectLater(
      repo.syncWeather(lat: 44.1, lon: 15.2),
      throwsA(isA<DioException>()),
    );
    expect(forecast.modelsAsked, ['italia_meteo_arpae_icon_2i']);
  });

  test('predpoveď sa pýta národného modelu a uloží jeho meno', () async {
    final forecast = _StubForecast.returning(_forecastBody());
    final repo = WeatherRepository.forTesting(
      db: db,
      forecast: forecast,
      marine: _StubMarine(_marineBody()),
    );

    await repo.syncWeather(lat: 44.1, lon: 15.2);

    expect(forecast.modelsAsked, ['italia_meteo_arpae_icon_2i']);
    final rows = await db.getWeatherSnapshots();
    expect(rows.first.modelName, 'ARPAE ICON-2I · ItaliaMeteo');
  });

  test('mimo pokrytia sa padne na automatický výber a meno ostane prázdne',
      () async {
    final forecast = _StubForecast.failingFor(
        'italia_meteo_arpae_icon_2i', _forecastBody());
    final repo = WeatherRepository.forTesting(
      db: db,
      forecast: forecast,
      marine: _StubMarine(_marineBody()),
    );

    await repo.syncWeather(lat: 44.1, lon: 15.2);

    expect(forecast.modelsAsked, ['italia_meteo_arpae_icon_2i', null]);
    final rows = await db.getWeatherSnapshots();
    expect(rows, hasLength(2));
    // Prázdne meno je poctivé: nevieme, ktorý model Open-Meteo vybralo.
    expect(rows.first.modelName, isNull);
  });

  test('prázdna odpoveď keš nevymaže', () async {
    final ok = WeatherRepository.forTesting(
      db: db,
      forecast: _StubForecast.returning(_forecastBody()),
      marine: _StubMarine(_marineBody()),
    );
    await ok.syncWeather(lat: 44.1, lon: 15.2);

    final empty = WeatherRepository.forTesting(
      db: db,
      forecast: _StubForecast.returning({
        'hourly': {
          'time': <String>[],
          'wind_speed_10m': <double>[],
          'wind_direction_10m': <double>[],
          'surface_pressure': <double>[],
          'temperature_2m': <double>[],
          'cloud_cover': <double>[],
          'weather_code': <int>[],
        }
      }),
      marine: _StubMarine(_marineBody()),
    );
    await empty.syncWeather(lat: 44.1, lon: 15.2);

    expect(await db.getWeatherSnapshots(), hasLength(2));
  });

  test('regionálny model s HTTP 400 "no data" skúsi automatický výber',
      () async {
    // Open-Meteo vie na nepokrytú polohu odpovedať priamo HTTP 400
    // s `{"reason":"No data is available for this location"}`, nie len
    // `nan` odpoveďou — overené na ICON-D2 pre Zvolen.
    final forecast = _StubForecast.failingFor(
      'icon_d2',
      _forecastBody(),
      error: DioException.badResponse(
        statusCode: 400,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'error': true, 'reason': 'No data is available for this location'},
        ),
      ),
    );
    final repo = WeatherRepository.forTesting(
      db: db,
      forecast: forecast,
      marine: _StubMarine(_marineBody()),
    );

    await repo.syncWeather(lat: 48.5731, lon: 19.1274);

    expect(forecast.modelsAsked, ['icon_d2', null]);
    final rows = await db.getWeatherSnapshots();
    expect(rows, hasLength(2));
  });

  test('vnútrozemie bez morských dát neblokuje predpoveď počasia', () async {
    // marine-api.open-meteo.com na súradnice mimo mora vráti HTTP 400
    // (napr. Zvolen). To nesmie zahodiť predpoveď, ktorú sme už stiahli.
    final repo = WeatherRepository.forTesting(
      db: db,
      forecast: _StubForecast.returning(_forecastBody()),
      marine: _StubMarine.failing(DioException.badResponse(
        statusCode: 400,
        requestOptions: RequestOptions(path: ''),
        response: Response(requestOptions: RequestOptions(path: '')),
      )),
    );

    await repo.syncWeather(lat: 48.5731, lon: 19.1274);

    final rows = await db.getWeatherSnapshots();
    expect(rows, hasLength(2));
    expect(rows.first.waveHeight, isNull);
    expect(rows.first.windSpeed, isNotNull);
  });
}
