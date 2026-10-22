import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/distance_calculator.dart';

enum EstimatedTrackOutcome {
  /// The track was (re)built from the entries of the day.
  built,

  /// Fewer than two entries have a position, so there is no line to draw.
  needsTwoEntries,

  /// The day already has a measured track; an estimate would sit on top of it.
  realTrackExists,
}

class EstimatedTrackResult {
  final EstimatedTrackOutcome outcome;

  /// Straight-line length through the entry positions, in nautical miles.
  final double distanceNm;

  const EstimatedTrackResult(this.outcome, {this.distanceNm = 0});
}

/// Draws a day's track through the positions of its log entries.
///
/// For a voyage transcribed from a paper logbook, where nothing was recorded
/// by GPS. The result is straight lines between the entries, which is what the
/// paper supports and no more: it exists for the map and for a GPX file, and
/// is marked [SailingSessions.isEstimated] so that it is never mistaken for a
/// measured track or counted into night hours.
class EstimatedTrackBuilder {
  const EstimatedTrackBuilder._();

  /// Track name in a GPX file. English: the file is read by other software.
  static const sessionName = 'Estimated from log entries';

  /// Entries that carry a position, oldest first.
  static List<LogbookEntry> _positioned(List<LogbookEntry> entries) {
    final list = [
      for (final e in entries)
        if (e.latitude != null && e.longitude != null) e,
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  static double _lengthNm(List<LogbookEntry> entries) {
    var nm = 0.0;
    for (var i = 1; i < entries.length; i++) {
      nm += DistanceCalculator.distanceNm(
        entries[i - 1].latitude!, entries[i - 1].longitude!,
        entries[i].latitude!, entries[i].longitude!,
      );
    }
    return nm;
  }

  /// Straight-line length of the day through its entries, for showing next to
  /// the miles the skipper copies from the paper. 0 with fewer than two
  /// positioned entries.
  static Future<double> straightLineNm(AppDatabase db, int dayLogId) async =>
      _lengthNm(_positioned(await db.getEntriesForDay(dayLogId)));

  /// Replaces the day's estimated track with one drawn through its entries.
  /// Safe to run again after entries change; a measured track is never touched.
  static Future<EstimatedTrackResult> rebuildForDay(
    AppDatabase db,
    int dayLogId,
  ) async {
    final sessions = await db.getSessionsForDay(dayLogId, includeAnchorWatch: true);
    if (sessions.any((s) => !s.isEstimated)) {
      return const EstimatedTrackResult(EstimatedTrackOutcome.realTrackExists);
    }

    final entries = _positioned(await db.getEntriesForDay(dayLogId));
    await db.deleteEstimatedSessionsForDay(dayLogId);
    if (entries.length < 2) {
      return const EstimatedTrackResult(EstimatedTrackOutcome.needsTwoEntries);
    }

    final nm = _lengthNm(entries);
    final sessionId = const Uuid().v4();
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: sessionId,
      dayLogId: Value(dayLogId),
      startTime: entries.first.timestamp,
      endTime: Value(entries.last.timestamp),
      name: const Value(sessionName),
      totalDistanceNm: Value(nm),
      isActive: const Value(false),
      isEstimated: const Value(true),
    ));
    await db.insertTrackPointsBatch([
      for (final e in entries)
        TrackPointsCompanion.insert(
          sessionId: Value(sessionId),
          timestamp: e.timestamp,
          latitude: e.latitude!,
          longitude: e.longitude!,
          speed: Value(e.sog),
          course: Value(e.cog),
        ),
    ]);
    return EstimatedTrackResult(EstimatedTrackOutcome.built, distanceNm: nm);
  }
}
