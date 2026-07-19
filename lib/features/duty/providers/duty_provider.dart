import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/logbook_event_type.dart';
import '../../../core/services/gps_tracking_service.dart';
import '../../../core/services/location_service.dart';
import '../../../main.dart';
import '../domain/crew_member.dart';
import '../domain/duty_rules.dart';

/// Duties currently running for a charter.
///
/// A drift `.watch()` stream rather than a FutureProvider on purpose: the
/// inspection screen must stay correct if a duty is started or ended from
/// another screen while it is open, without anyone remembering to invalidate.
final runningDutiesProvider =
    StreamProvider.family<List<DutyPeriod>, int>((ref, charterId) {
  final db = ref.watch(databaseProvider);
  return db.watchRunningDuties(charterId);
});

/// Every duty of a charter, newest start first.
final charterDutiesProvider =
    StreamProvider.family<List<DutyPeriod>, int>((ref, charterId) {
  final db = ref.watch(databaseProvider);
  return db.watchDutiesForCharter(charterId);
});

/// Crew that can be put on duty. Names come only from here — never free text,
/// so a duty record can always be tied back to someone on the crew list.
final dutyCrewProvider =
    Provider.family<List<CrewMember>, Charter>((ref, charter) {
  return CrewMember.decode(
    crewJson: charter.crewJson,
    skipperName: charter.skipperName,
    crewNames: charter.crewNames,
  );
});

/// One-second tick driving the "on duty for 1 h 34 m" text.
///
/// autoDispose so the timer stops when no screen is showing elapsed time —
/// this runs on a phone that may be on battery for a week.
final dutyClockProvider = StreamProvider.autoDispose<DateTime>((ref) =>
    Stream<DateTime>.periodic(
        const Duration(seconds: 1), (_) => DateTime.now()));

/// Bridges drift rows to the pure rules in duty_rules.dart.
extension DutyPeriodRules on DutyPeriod {
  DutyInterval toInterval() => DutyInterval(
        id: id,
        crewName: crewName,
        fromUtc: fromUtc,
        toUtc: toUtc,
      );
}

/// Fallback note text for a duty entry.
///
/// The machine-readable kind lives in `LogbookEntries.eventType`, so this text
/// is only what a reader sees; the UI and the PDF translate from the event type
/// instead of parsing it. The crew name is carried here because it is the one
/// part that cannot be reconstructed from the event type alone.
String dutyStartNote(String crewName) => 'Duty start: $crewName';
String dutyEndNote(String crewName) => 'Duty end: $crewName';

/// Mutations for duty periods.
///
/// Reads are drift streams, so nothing here needs `ref.invalidate` — the UI
/// updates because the database changed.
class DutyController {
  final Ref _ref;
  const DutyController(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  /// Puts [members] on duty from [at] (default now).
  ///
  /// One row per person: they may come on duty together but go off
  /// independently, so a joint start is only a shortcut for several rows.
  Future<void> startDuties({
    required int charterId,
    required List<CrewMember> members,
    DateTime? at,
  }) async {
    if (members.isEmpty) return;
    final fromUtc = (at ?? DateTime.now()).toUtc();
    final dayLogId = await _resolveDayLogId();
    final now = DateTime.now();

    for (final m in members) {
      await _db.insertDutyPeriod(DutyPeriodsCompanion.insert(
        charterId: charterId,
        dayLogId: drift.Value(dayLogId),
        crewName: m.name,
        role: drift.Value(m.role),
        fromUtc: fromUtc,
        createdAt: now,
      ));
      await _writeLogEntry(dutyStartNote(m.name), LogbookEventType.dutyStart);
    }
  }

  /// Ends one person's duty. Independent per row by construction.
  Future<void> endDuty(DutyPeriod duty, {DateTime? at}) async {
    await _db.closeDutyPeriod(duty.id, (at ?? DateTime.now()).toUtc());
    await _writeLogEntry(dutyEndNote(duty.crewName), LogbookEventType.dutyEnd);
  }

  /// Records a duty after the fact. [toUtc] may be null, which starts a duty
  /// that is still running — the case of "I came on watch an hour ago".
  Future<void> addRetrospective({
    required int charterId,
    required CrewMember member,
    required DateTime fromUtc,
    DateTime? toUtc,
    String? note,
  }) async {
    await _db.insertDutyPeriod(DutyPeriodsCompanion.insert(
      charterId: charterId,
      dayLogId: drift.Value(await _resolveDayLogId()),
      crewName: member.name,
      role: drift.Value(member.role),
      fromUtc: fromUtc.toUtc(),
      toUtc: drift.Value(toUtc?.toUtc()),
      note: drift.Value(note),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> editDuty({
    required int id,
    required DateTime fromUtc,
    DateTime? toUtc,
    String? note,
  }) =>
      _db.updateDutyPeriod(
        id,
        DutyPeriodsCompanion(
          fromUtc: drift.Value(fromUtc.toUtc()),
          toUtc: drift.Value(toUtc?.toUtc()),
          note: drift.Value(note),
        ),
      );

  Future<void> deleteDuty(int id) => _db.deleteDutyPeriod(id);

  /// Closes everything still running — for check-out or end of voyage.
  ///
  /// Never call this from a timer: a duty end the skipper never observed is a
  /// fabricated record. Rows closed this way carry isAutoClosed.
  Future<void> closeAll(int charterId, {DateTime? at}) =>
      _db.closeAllRunningDuties(charterId, (at ?? DateTime.now()).toUtc());

  /// Checks a duty against the ones already recorded for the charter.
  Future<DutyValidationError?> validate({
    required int charterId,
    required DutyInterval candidate,
  }) async {
    final existing = await _db.getDutiesOverlapping(
      charterId,
      candidate.fromUtc,
      candidate.toUtc ?? DateTime.utc(9999),
    );
    return validateDuty(
      candidate: candidate,
      existing: existing.map((d) => d.toInterval()).toList(),
      nowUtc: DateTime.now().toUtc(),
    );
  }

  Future<int?> _resolveDayLogId() async =>
      GpsTrackingService().activeDayLogId ?? await _db.getLatestDayLogId();

  /// Mirrors a duty change into the logbook so it shows up in the day log and
  /// in the existing PDF entries table. Same shape as MobNotifier.activate.
  ///
  /// Failure is swallowed: the duty record itself is the evidence, and losing
  /// the narrative entry must never take the duty down with it.
  Future<void> _writeLogEntry(String note, LogbookEventType event) async {
    try {
      final dayLogId = await _resolveDayLogId();
      final session = await _db.getActiveSession();
      final pos =
          GpsTrackingService().lastPosition ?? LocationService().lastPosition;
      await _db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: drift.Value(dayLogId),
        sessionId: drift.Value(session?.sessionId),
        timestamp: DateTime.now().toUtc(),
        latitude: drift.Value(pos?.latitude),
        longitude: drift.Value(pos?.longitude),
        skipperNote: drift.Value(note),
        eventType: drift.Value(event.code),
        isAutoEntry: const drift.Value(true),
      ));
    } catch (_) {
      // Intentionally ignored — see doc comment.
    }
  }
}

final dutyControllerProvider =
    Provider<DutyController>((ref) => DutyController(ref));
