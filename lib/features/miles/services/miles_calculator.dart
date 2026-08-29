import '../../../core/database/app_database.dart';
import '../../../core/services/night_hours.dart';

class MilesFilter {
  final int? year;
  final DateTime? customFrom;
  final DateTime? customTo;
  const MilesFilter({this.year, this.customFrom, this.customTo});

  bool matchesYear(int y) {
    if (year != null) return y == year;
    return true;
  }

  bool matchesRange(DateTime date) {
    if (customFrom != null && date.isBefore(customFrom!)) return false;
    if (customTo != null && date.isAfter(customTo!)) return false;
    return true;
  }
}

class VoyageRow {
  final DateTime dateFrom;
  final DateTime dateTo;
  final String vesselName;
  final String? area;
  final double distanceNm;
  final int days;
  final double nightHours;
  final String? role;
  final bool isManualEntry;

  /// ID `HistoricalVoyages` riadku – vyplnené len ak [isManualEntry] je true
  /// (umožňuje priame prekliknutie na editáciu bez ďalšieho dohľadávania).
  final int? historicalVoyageId;

  /// ID `Charters` riadku – vyplnené len ak [isManualEntry] je false, na
  /// prekliknutie do záznamu Knihy míľ pre trackovanú/importovanú plavbu.
  final int? charterId;

  const VoyageRow({
    required this.dateFrom,
    required this.dateTo,
    required this.vesselName,
    required this.area,
    required this.distanceNm,
    required this.days,
    required this.nightHours,
    required this.role,
    required this.isManualEntry,
    this.historicalVoyageId,
    this.charterId,
  });
}

class MilesAggregate {
  final double totalNm;
  final int daysAtSea;
  final int voyageCount;
  final double nightHours;
  final Map<int, double> nmByYear;
  final Map<String, double> nmByVessel;
  final List<VoyageRow> voyages;

  const MilesAggregate({
    required this.totalNm,
    required this.daysAtSea,
    required this.voyageCount,
    required this.nightHours,
    required this.nmByYear,
    required this.nmByVessel,
    required this.voyages,
  });

  static const empty = MilesAggregate(
    totalNm: 0,
    daysAtSea: 0,
    voyageCount: 0,
    nightHours: 0,
    nmByYear: {},
    nmByVessel: {},
    voyages: [],
  );
}

/// Čistá agregačná logika Knihy míľ – žiadne DB/Flutter závislosti, ľahko
/// testovateľná. Vstupom sú už načítané riadky (viď [MilesGatheredData]).
class MilesCalculator {
  static MilesAggregate aggregate({
    required List<Charter> charters,
    required Map<int, List<DayLog>> dayLogsByCharter,
    required Map<int, List<TrackPoint>> trackPointsByDayLog,
    required List<HistoricalVoyage> historicalVoyages,
    MilesFilter filter = const MilesFilter(),
  }) {
    double totalNm = 0;
    int daysAtSea = 0;
    int voyageCount = 0;
    double nightHours = 0;
    final nmByYear = <int, double>{};
    final nmByVessel = <String, double>{};
    final voyages = <VoyageRow>[];

    for (final charter in charters) {
      final dayLogs = dayLogsByCharter[charter.id] ?? const <DayLog>[];
      final matchingDays = dayLogs
          .where((d) => filter.matchesYear(d.date.year) && filter.matchesRange(d.date))
          .toList();
      if (matchingDays.isEmpty) continue;

      final vessel = charter.vesselName ?? '-';
      double charterNm = 0;
      double charterNightHours = 0;
      for (final day in matchingDays) {
        charterNm += day.distanceNm;
        final points = trackPointsByDayLog[day.id] ?? const <TrackPoint>[];
        charterNightHours += nightHoursForPoints(points);
      }

      totalNm += charterNm;
      nightHours += charterNightHours;
      daysAtSea += matchingDays.length;
      voyageCount += 1;
      nmByYear.update(
          charter.dateFrom.year, (v) => v + charterNm, ifAbsent: () => charterNm);
      nmByVessel.update(vessel, (v) => v + charterNm, ifAbsent: () => charterNm);

      voyages.add(VoyageRow(
        dateFrom: matchingDays.map((d) => d.date).reduce((a, b) => a.isBefore(b) ? a : b),
        dateTo: matchingDays.map((d) => d.date).reduce((a, b) => a.isAfter(b) ? a : b),
        vesselName: vessel,
        area: charter.homePort,
        distanceNm: charterNm,
        days: matchingDays.length,
        nightHours: charterNightHours,
        role: charter.myRole,
        isManualEntry: false,
        charterId: charter.id,
      ));
    }

    for (final v in historicalVoyages) {
      if (!filter.matchesYear(v.dateFrom.year) || !filter.matchesRange(v.dateFrom)) {
        continue;
      }
      final days = v.daysCount ?? (v.dateTo.difference(v.dateFrom).inDays + 1);
      final vNightHours = v.nightHours ?? 0;

      totalNm += v.distanceNm;
      nightHours += vNightHours;
      daysAtSea += days;
      voyageCount += 1;
      nmByYear.update(v.dateFrom.year, (n) => n + v.distanceNm, ifAbsent: () => v.distanceNm);
      nmByVessel.update(v.vesselName, (n) => n + v.distanceNm, ifAbsent: () => v.distanceNm);

      voyages.add(VoyageRow(
        dateFrom: v.dateFrom,
        dateTo: v.dateTo,
        vesselName: v.vesselName,
        area: v.area,
        distanceNm: v.distanceNm,
        days: days,
        nightHours: vNightHours,
        role: v.role,
        isManualEntry: true,
        historicalVoyageId: v.id,
      ));
    }

    voyages.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));

    return MilesAggregate(
      totalNm: totalNm,
      daysAtSea: daysAtSea,
      voyageCount: voyageCount,
      nightHours: nightHours,
      nmByYear: nmByYear,
      nmByVessel: nmByVessel,
      voyages: voyages,
    );
  }

  /// Nočné hodiny cez to isté pravidlo, aké používa denník a jeho PDF.
  /// Vlastná slučka tu kedysi bola a rozišla sa s ním o prah medzery, takže
  /// tá istá plavba vykázala na dvoch dokladoch dve rôzne čísla. Verejné,
  /// aby sa tá zhoda dala otestovať.
  static double nightHoursForPoints(List<TrackPoint> points) =>
      NightHours.forSamples(points.map((p) => NightSample(
            timeUtc: p.timestamp,
            latitude: p.latitude,
            longitude: p.longitude,
          )));
}
