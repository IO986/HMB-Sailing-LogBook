import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../utils/distance_calculator.dart';
import 'dhmz_observation_parser.dart';

/// Merania z pozemných staníc DHMZ (meteo.hr).
///
/// Prečo to v appke je: lodný denník je dokladovateľný záznam podmienok, ktoré
/// naozaj boli. Kto nemá lodné prístroje, mal doteraz v zázname čistý výstup
/// modelu. Najbližšia stanica je medzistupeň — nameraná hodnota, len z iného
/// miesta, a preto sa spolu s ňou zapisuje aj názov stanice a vzdialenosť.
///
/// Zámerne to NIE JE v `hmb_core`: knižnica nesmie poznať konkrétne backendy
/// okrem open-meteo a Nominatimu (pravidlo 3 v CLAUDE.md).
class DhmzObservationService {
  static final DhmzObservationService _i = DhmzObservationService._();
  factory DhmzObservationService() => _i;
  DhmzObservationService._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  static const _landUrl = 'https://vrijeme.hr/hrvatska_n.xml';
  static const _seaUrl = 'https://vrijeme.hr/more_n.xml';

  /// Feed má pokrytie len po Chorvátsko; ďalej sa použije model. Prah je
  /// zároveň poistka proti tomu, aby sa v strede Jadranu zapísal tlak zo
  /// stanice spať pol mora ďaleko.
  static const defaultMaxDistanceM = 25000.0;

  /// Meranie staršie než toto sa nepoužije. Feed sa môže ticho zastaviť —
  /// presne to sa stalo predpovednému feedu DHMZ, ktorý mesiace vracia
  /// syntakticky platné, ale dva mesiace staré dáta.
  static const maxAge = Duration(hours: 3);

  /// Ako často sa oplatí ťahať feed. Stanice hlásia po hodine.
  static const _minSyncInterval = Duration(minutes: 30);

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  ));

  DateTime? _lastSyncAt;

  /// Súradnice staníc teploty mora.
  ///
  /// Feed `more_n.xml` súradnice neuvádza a menom sa na pozemné stanice dá
  /// spárovať len 6 zo 16, takže zvyšok musí byť tu. Zoznam staníc DHMZ sa
  /// mení zriedka; keby pribudla nová, jednoducho sa nepoužije (nie je to
  /// chyba, len chýbajúca teplota mora).
  ///
  /// Hodnoty sú polohy prístavu či stanice na desatiny kilometra. Pri prahu
  /// 25 km je tá presnosť viac než dostatočná.
  static const seaStationCoordinates = <String, (double, double)>{
    'Božava': (44.138, 14.918),
    'Crikvenica': (45.173, 14.689),
    'Dubrovnik': (42.645, 18.085),
    'Komiža': (43.043, 16.092),
    'Mali Losinj': (44.533, 14.472),
    'Malinska': (45.126, 14.527),
    'Mljet-Malo jezero': (42.777, 17.360),
    'Mljet-Veliko jezero': (42.783, 17.348),
    'Mljet-otvoreno more': (42.745, 17.360),
    'Opatija': (45.336, 14.306),
    'Pula': (44.868, 13.845),
    'Rab': (44.756, 14.769),
    'Rovinj-Sv.Ivan n/p': (45.043, 13.614),
    'Split': (43.508, 16.426),
    'Šibenik': (43.728, 15.906),
    'Zadar': (44.130, 15.206),
  };

  /// Stiahne oba feedy a uloží merania.
  ///
  /// Nikdy nevyhadzuje výnimku a nikdy nie je podmienkou zápisu do denníka
  /// (pravidlo 4 — offline-first). Keď sieť nie je, ostane posledná cache;
  /// keď nie je ani tá, záznam sa spraví z modelu.
  Future<void> sync({bool force = false}) async {
    final db = _db;
    if (db == null) return;

    final last = _lastSyncAt;
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < _minSyncInterval) {
      return;
    }

    try {
      final land = await _fetch(_landUrl);
      if (land == null) return;

      var readings = DhmzObservationParser.parseLandStations(land);
      if (readings.isEmpty) return;

      final sea = await _fetch(_seaUrl);
      if (sea != null) {
        readings = _mergeSeaTemperatures(
          readings,
          DhmzObservationParser.parseSeaTemperatures(sea),
        );
      }

      await db.replaceDhmzObservations([
        for (final r in readings)
          DhmzObservationsCompanion.insert(
            station: r.station,
            latitude: r.latitude,
            longitude: r.longitude,
            observedAt: r.observedAt,
            downloadedAt: DateTime.now().toUtc(),
            airTemp: drift.Value(r.airTemp),
            airPressure: drift.Value(r.airPressure),
            pressureTendency: drift.Value(r.pressureTendency),
            windSpeedKnots: drift.Value(r.windSpeedKnots),
            windDirectionDeg: drift.Value(r.windDirectionDeg),
            waterTemp: drift.Value(r.waterTemp),
          ),
      ]);
      _lastSyncAt = DateTime.now();
      debugPrint('[DHMZ] ${readings.length} stations cached');
    } catch (e) {
      debugPrint('[DHMZ] sync failed: $e');
    }
  }

  /// Najbližšie použiteľné meranie k danej polohe, alebo `null`.
  ///
  /// `null` znamená "použi model" a je to úplne bežný výsledok: mimo
  /// Chorvátska, ďaleko od pobrežia, alebo keď feed zastaral.
  Future<DhmzNearestObservation?> nearest({
    required double latitude,
    required double longitude,
    double maxDistanceM = defaultMaxDistanceM,
    DateTime? now,
  }) async {
    final db = _db;
    if (db == null) return null;

    final at = (now ?? DateTime.now()).toUtc();
    final all = await db.getDhmzObservations();
    if (all.isEmpty) return null;

    DhmzObservation? best;
    var bestDistance = double.infinity;
    for (final o in all) {
      if (at.difference(o.observedAt.toUtc()).abs() > maxAge) continue;
      final d = DistanceCalculator.distanceM(
          latitude, longitude, o.latitude, o.longitude);
      if (d > maxDistanceM || d >= bestDistance) continue;
      best = o;
      bestDistance = d;
    }
    if (best == null) return null;
    return DhmzNearestObservation(observation: best, distanceM: bestDistance);
  }

  Future<String?> _fetch(String url) async {
    // Cache-buster: feedy sedia za medzipamäťou, ktorá vracia staré telo aj
    // keď zdroj medzitým zverejnil nový termín.
    final r = await _dio.get<String>(
      url,
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch},
      options: Options(responseType: ResponseType.plain),
    );
    return r.data;
  }

  /// Priradí teplotu mora k pozemnej stanici, keď je dosť blízko, inak pridá
  /// samostatné meranie iba s teplotou mora.
  ///
  /// Pozemná a morská stanica toho istého mesta nemajú vždy rovnaký názov
  /// (`Split` proti `Split-Marjan`), takže sa páruje polohou, nie menom.
  static List<DhmzStationReading> _mergeSeaTemperatures(
    List<DhmzStationReading> land,
    Map<String, double> seaTemps,
  ) {
    const pairingRadiusM = 5000.0;
    final out = [...land];

    seaTemps.forEach((station, temp) {
      final coords = seaStationCoordinates[station];
      if (coords == null) return;
      final (lat, lon) = coords;

      var bestIndex = -1;
      var bestDistance = pairingRadiusM;
      for (var i = 0; i < out.length; i++) {
        final d = DistanceCalculator.distanceM(
            lat, lon, out[i].latitude, out[i].longitude);
        if (d < bestDistance) {
          bestDistance = d;
          bestIndex = i;
        }
      }

      if (bestIndex >= 0) {
        out[bestIndex] = out[bestIndex].copyWithWaterTemp(temp);
      } else {
        out.add(DhmzStationReading(
          station: station,
          latitude: lat,
          longitude: lon,
          observedAt: land.first.observedAt,
          waterTemp: temp,
        ));
      }
    });

    return out;
  }
}

/// Meranie aj s tým, ako ďaleko od neho skiper bol.
///
/// Vzdialenosť sa nesie ďalej zámerne — zapisuje sa do záznamu, aby bolo
/// z denníka vidno, nakoľko sa dá hodnote veriť.
class DhmzNearestObservation {
  const DhmzNearestObservation({
    required this.observation,
    required this.distanceM,
  });

  final DhmzObservation observation;
  final double distanceM;
}
