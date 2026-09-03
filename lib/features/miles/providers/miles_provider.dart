import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/crew_member_ref.dart';
import '../../../main.dart';
import '../services/miles_calculator.dart';

final milesFilterProvider = StateProvider<MilesFilter>((ref) => const MilesFilter());

/// `.autoDispose` – bez toho by súhrn ostal zacachovaný so starými dátami
/// aj po skončení plavby; takto sa pri každom otvorení Knihy míľ dáta
/// znova načítajú z DB.
final historicalVoyagesProvider =
    FutureProvider.autoDispose<List<HistoricalVoyage>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllHistoricalVoyages();
});

/// Mená všetkých ľudí, ktorí niekedy plavili — pre výber pri vystavovaní
/// potvrdenia.
///
/// Potvrdenie sa vystavuje konkrétnemu človeku a jeho meno je už v appke
/// zapísané pri plavbe, na ktorej bol. Prepisovať ho ručne (a preklepom
/// rozdvojiť jednu osobu na dve) nemá dôvod.
///
/// Zdroj je `crewJson` charterov, so starým `skipperName`/`crewNames` ako
/// zálohou — presne to, čo číta [CrewMemberRef.parse]. Duplicity sa hádžu
/// preč bez ohľadu na veľkosť písmen a poradie je abecedné.
final knownCrewNamesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final db = ref.watch(databaseProvider);
  final seen = <String, String>{};
  for (final charter in await db.getAllCharters()) {
    final crew = CrewMemberRef.parse(
      charter.crewJson,
      skipperName: charter.skipperName,
      crewNames: charter.crewNames,
    );
    for (final member in crew) {
      seen.putIfAbsent(member.name.toLowerCase(), () => member.name);
    }
  }
  final names = seen.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return names;
});

class _MilesRawData {
  final List<Charter> charters;
  final Map<int, List<DayLog>> dayLogsByCharter;
  final Map<int, List<TrackPoint>> trackPointsByDayLog;
  final List<HistoricalVoyage> historicalVoyages;

  const _MilesRawData({
    required this.charters,
    required this.dayLogsByCharter,
    required this.trackPointsByDayLog,
    required this.historicalVoyages,
  });
}

final _milesRawDataProvider = FutureProvider.autoDispose<_MilesRawData>((ref) async {
  final db = ref.watch(databaseProvider);

  final charters = await db.getAllCharters();
  final dayLogsByCharter = <int, List<DayLog>>{};
  final trackPointsByDayLog = <int, List<TrackPoint>>{};

  for (final charter in charters) {
    final dayLogs = await db.getDayLogs(charter.id);
    dayLogsByCharter[charter.id] = dayLogs;

    for (final day in dayLogs) {
      final sessions = await db.getSessionsForDay(day.id);
      final points = <TrackPoint>[];
      for (final session in sessions) {
        // Úseky kotvovej stráže sa do Knihy míľ nerátajú: sú to hodiny na
        // reťazi, nie odplávaná trasa. V GPX exporte zostávajú.
        if (session.isAnchorWatch) continue;
        points.addAll(await db.getTrackPointsForSession(session.sessionId));
      }
      trackPointsByDayLog[day.id] = points;
    }
  }

  final historicalVoyages = await db.getAllHistoricalVoyages();

  return _MilesRawData(
    charters: charters,
    dayLogsByCharter: dayLogsByCharter,
    trackPointsByDayLog: trackPointsByDayLog,
    historicalVoyages: historicalVoyages,
  );
});

/// Súhrn Knihy míľ pre aktuálne zvolený [milesFilterProvider].
final milesAggregateProvider = FutureProvider.autoDispose<MilesAggregate>((ref) async {
  final raw = await ref.watch(_milesRawDataProvider.future);
  final filter = ref.watch(milesFilterProvider);

  return MilesCalculator.aggregate(
    charters: raw.charters,
    dayLogsByCharter: raw.dayLogsByCharter,
    trackPointsByDayLog: raw.trackPointsByDayLog,
    historicalVoyages: raw.historicalVoyages,
    filter: filter,
  );
});

/// Zoznam rokov, v ktorých existuje aspoň jedna plavba – na filter chips
/// (nezávisí od aktuálne zvoleného filtra).
final milesAvailableYearsProvider = FutureProvider.autoDispose<List<int>>((ref) async {
  final raw = await ref.watch(_milesRawDataProvider.future);
  final years = <int>{};
  for (final charter in raw.charters) {
    final dayLogs = raw.dayLogsByCharter[charter.id] ?? const <DayLog>[];
    for (final day in dayLogs) {
      years.add(day.date.year);
    }
  }
  for (final v in raw.historicalVoyages) {
    years.add(v.dateFrom.year);
  }
  final sorted = years.toList()..sort((a, b) => b.compareTo(a));
  return sorted;
});
