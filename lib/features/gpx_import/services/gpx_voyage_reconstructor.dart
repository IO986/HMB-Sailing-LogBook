import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/distance_calculator.dart';
import 'gpx_importer.dart';

/// What [GpxVoyageReconstructor.addTracksToCharter] did, for the summary
/// shown to the user.
class ReconstructionSummary {
  /// Days that did not exist on the voyage and were created.
  final int daysCreated;

  /// Days that already existed (typed in from the paper log, for example) and
  /// received the track.
  final int daysExtended;

  /// Track chunks skipped because the same chunk was imported before.
  final int duplicatesSkipped;

  /// Points without a time. A voyage reconstructed afterwards is placed on
  /// the calendar by time, so a point without one cannot be placed at all.
  final int untimedPointsSkipped;

  const ReconstructionSummary({
    required this.daysCreated,
    required this.daysExtended,
    required this.duplicatesSkipped,
    required this.untimedPointsSkipped,
  });

  int get daysTouched => daysCreated + daysExtended;
}

/// Rebuilds the days of a voyage from GPX tracks: one `DayLog` per calendar
/// day, one `SailingSession` per track chunk of that day, miles per day.
///
/// Night hours are not stored anywhere, they are derived from the track points
/// when read, so they come for free once the points are in.
///
/// Pure database work, no Flutter: the import screen only picks the file and
/// the target, which keeps this testable.
class GpxVoyageReconstructor {
  const GpxVoyageReconstructor._();

  /// Adds [tracks] to the voyage [charterId], splitting them by local calendar
  /// day. A day that already exists is extended, not duplicated, so a voyage
  /// transcribed from paper and a GPX of the same days end up as one.
  static Future<ReconstructionSummary> addTracksToCharter(
    AppDatabase db,
    int charterId,
    List<GpxTrack> tracks,
  ) async {
    var untimed = 0;
    // (track name, points) chunks per local calendar day.
    final byDay = <DateTime, List<(String?, List<GpxTrackPoint>)>>{};
    for (final track in tracks) {
      final perDay = <DateTime, List<GpxTrackPoint>>{};
      for (final p in track.points) {
        final time = p.time;
        if (time == null) {
          untimed++;
          continue;
        }
        final t = time.toLocal();
        perDay.putIfAbsent(DateTime(t.year, t.month, t.day), () => []).add(p);
      }
      perDay.forEach((day, points) {
        byDay.putIfAbsent(day, () => []).add((track.name, points));
      });
    }

    final existing = {
      for (final d in await db.getDayLogs(charterId)) _dayKey(d.date): d,
    };

    var created = 0;
    var extended = 0;
    var duplicates = 0;
    final sortedDays = byDay.keys.toList()..sort();

    for (final dayKey in sortedDays) {
      var day = existing[dayKey];
      final isNewDay = day == null;
      if (day == null) {
        day = await db.insertDayLog(
            DayLogsCompanion.insert(charterId: charterId, date: dayKey));
        created++;
      }

      var addedToDay = false;
      for (final (name, points) in byDay[dayKey]!) {
        final added = await addPointsToDay(db, day.id, points, name);
        if (added) {
          addedToDay = true;
        } else {
          duplicates++;
        }
      }
      if (!addedToDay) continue;
      if (!isNewDay) extended++;

      await _fillDay(db, day, isNewDay, byDay[dayKey]!.first.$1);
    }

    await widenCharterDates(db, charterId, sortedDays);

    return ReconstructionSummary(
      daysCreated: created,
      daysExtended: extended,
      duplicatesSkipped: duplicates,
      untimedPointsSkipped: untimed,
    );
  }

  /// Stores [points] as one session of the day. Returns `false` when the same
  /// chunk (same name and start time) is already there, so importing a file
  /// twice does not double the miles.
  static Future<bool> addPointsToDay(
    AppDatabase db,
    int dayLogId,
    List<GpxTrackPoint> points,
    String? trackName,
  ) async {
    if (points.isEmpty) return false;

    final start = points.first.time ?? DateTime.now();
    final sessions = await db.getSessionsForDay(dayLogId, includeAnchorWatch: true);
    final duplicate = sessions.any((s) =>
        s.startTime.isAtSameMomentAs(start) && s.name == trackName);
    if (duplicate) return false;

    final nm = distanceNm(points);
    final sessionId = const Uuid().v4();
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: sessionId,
      dayLogId: Value(dayLogId),
      startTime: start,
      endTime: Value(points.last.time),
      name: Value(trackName),
      totalDistanceNm: Value(nm),
      isActive: const Value(false),
    ));
    await db.insertTrackPointsBatch([
      for (final p in points)
        TrackPointsCompanion.insert(
          sessionId: Value(sessionId),
          timestamp: p.time ?? DateTime.now(),
          latitude: p.lat,
          longitude: p.lon,
          altitude: Value(p.ele),
        ),
    ]);
    return true;
  }

  /// Sum of the legs between consecutive points, in nautical miles.
  static double distanceNm(List<GpxTrackPoint> points) {
    var nm = 0.0;
    for (var i = 1; i < points.length; i++) {
      nm += DistanceCalculator.distanceNm(
        points[i - 1].lat, points[i - 1].lon,
        points[i].lat, points[i].lon,
      );
    }
    return nm;
  }

  /// Day miles and ports after new sessions arrived.
  ///
  /// A figure typed in from the paper log wins over a computed one: the
  /// skipper's own number is what the paper says. Same for ports.
  static Future<void> _fillDay(
    AppDatabase db,
    DayLog day,
    bool isNewDay,
    String? firstTrackName,
  ) async {
    final sessions = await db.getSessionsForDay(day.id);
    final total = sessions.fold<double>(0, (sum, s) => sum + s.totalDistanceNm);
    final ports = portsFromTrackName(firstTrackName);

    await db.updateDayLog(DayLogsCompanion(
      id: Value(day.id),
      distanceNm: day.distanceNm == 0 ? Value(total) : const Value.absent(),
      portFrom: (day.portFrom == null && ports.$1 != null)
          ? Value(ports.$1)
          : const Value.absent(),
      portTo: (day.portTo == null && ports.$2 != null)
          ? Value(ports.$2)
          : const Value.absent(),
    ));
  }

  /// Stretches the voyage's from/to dates to cover [days] (sorted).
  static Future<void> widenCharterDates(
    AppDatabase db,
    int charterId,
    List<DateTime> days,
  ) async {
    if (days.isEmpty) return;
    final charter = await db.getCharterById(charterId);
    if (charter == null) return;
    final from = days.first.isBefore(charter.dateFrom) ? days.first : null;
    final last = days.last;
    final to = last.isAfter(charter.dateTo) ? last : null;
    if (from == null && to == null) return;
    await db.updateCharter(ChartersCompanion(
      id: Value(charterId),
      dateFrom: from == null ? const Value.absent() : Value(from),
      dateTo: to == null ? const Value.absent() : Value(to),
    ));
  }

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  static final _coordinates = RegExp(r'^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$');

  /// Ports from a track named like this app names them on export:
  /// `<day>: <from> → <to>`, where a side is a coordinate pair or `?` when no
  /// port was known. Anything else, including tracks from other apps, yields
  /// nothing rather than a guess.
  static (String?, String?) portsFromTrackName(String? name) {
    if (name == null) return (null, null);
    final colon = name.indexOf(': ');
    final route = colon < 0 ? name : name.substring(colon + 2);
    final arrow = route.split(' → ');
    if (arrow.length != 2) return (null, null);

    String? side(String s) {
      final v = s.trim();
      if (v.isEmpty || v == '?' || _coordinates.hasMatch(v)) return null;
      return v;
    }

    return (side(arrow[0]), side(arrow[1]));
  }
}
