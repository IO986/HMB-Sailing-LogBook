/// Pure duty-period logic: overlap, day membership, validation, elapsed time.
///
/// No drift and no Flutter imports on purpose — this is where the fiddly parts
/// live (running duties with no end, periods crossing midnight), so it has to
/// be testable without a database.
///
/// All [DateTime]s handled here are UTC, matching the `fromUtc`/`toUtc` columns.
library;

/// A duty period reduced to what the rules care about.
class DutyInterval {
  /// Row id, or null for a period being created. Used so validation can ignore
  /// the row currently being edited when checking for overlaps.
  final int? id;
  final String crewName;
  final DateTime fromUtc;

  /// null = the duty is still running.
  final DateTime? toUtc;

  const DutyInterval({
    this.id,
    required this.crewName,
    required this.fromUtc,
    this.toUtc,
  });

  bool get isRunning => toUtc == null;

  /// End of the period for comparison purposes. A running duty has no end, so
  /// it is treated as extending indefinitely.
  DateTime effectiveEnd(DateTime now) => toUtc ?? _max(now, fromUtc);

  Duration elapsed(DateTime now) => effectiveEnd(now).difference(fromUtc);

  @override
  String toString() =>
      'DutyInterval($crewName, $fromUtc → ${toUtc ?? "running"})';
}

enum DutyValidationError {
  /// End is at or before the start.
  endBeforeStart,

  /// The duty starts in the future.
  futureStart,

  /// The same person already has a duty covering part of this period.
  overlapSamePerson,
}

/// Half-open interval overlap: `[from1, to1)` against `[from2, to2)`.
///
/// Half-open on purpose — a duty ending at 04:00 and the next starting at 04:00
/// is a normal handover, not an overlap.
bool intervalsOverlap(
  DateTime from1,
  DateTime to1,
  DateTime from2,
  DateTime to2,
) =>
    from1.isBefore(to2) && from2.isBefore(to1);

/// Whether two duty periods overlap in time, treating a running duty as
/// open-ended.
bool dutiesOverlap(DutyInterval a, DutyInterval b, DateTime now) {
  // A running duty has no end, so anything starting after it began collides
  // with it regardless of `now`.
  final endA = a.isRunning ? _farFuture : a.toUtc!;
  final endB = b.isRunning ? _farFuture : b.toUtc!;
  return intervalsOverlap(a.fromUtc, endA, b.fromUtc, endB);
}

/// Validates a duty about to be created or edited.
///
/// Overlap is only an error for the *same* person — two people on duty at the
/// same time is the normal case, not a mistake.
DutyValidationError? validateDuty({
  required DutyInterval candidate,
  required List<DutyInterval> existing,
  required DateTime nowUtc,
}) {
  final to = candidate.toUtc;
  if (to != null && !to.isAfter(candidate.fromUtc)) {
    return DutyValidationError.endBeforeStart;
  }
  if (candidate.fromUtc.isAfter(nowUtc)) {
    return DutyValidationError.futureStart;
  }
  for (final other in existing) {
    if (other.id != null && other.id == candidate.id) continue; // editing self
    if (other.crewName != candidate.crewName) continue;
    if (dutiesOverlap(candidate, other, nowUtc)) {
      return DutyValidationError.overlapSamePerson;
    }
  }
  return null;
}

/// A duty as it appears on one particular day, clipped to that day's window.
class ClippedDuty {
  final DutyInterval duty;
  final DateTime fromUtc;
  final DateTime toUtc;

  /// The duty began before this day started.
  final bool clippedStart;

  /// The duty continues past the end of this day (or is still running).
  final bool clippedEnd;

  const ClippedDuty({
    required this.duty,
    required this.fromUtc,
    required this.toUtc,
    required this.clippedStart,
    required this.clippedEnd,
  });
}

/// Duties that touch the local day starting at [localDayStart].
///
/// [localDayStart] is a local-time DateTime at 00:00. Converting local→UTC
/// here (rather than comparing UTC dates) is what makes a duty from 20:00 to
/// 04:00 appear on both days, which is the whole point of storing one row per
/// continuous duty instead of splitting at midnight.
List<DutyInterval> dutiesForDay(
  List<DutyInterval> duties,
  DateTime localDayStart,
  DateTime nowUtc,
) {
  final startUtc = localDayStart.toUtc();
  // Add on the local clock first, so a DST day is 23 or 25 hours, not always 24.
  final endUtc = DateTime(
    localDayStart.year,
    localDayStart.month,
    localDayStart.day + 1,
  ).toUtc();

  return duties.where((d) {
    final end = d.isRunning ? _farFuture : d.toUtc!;
    return intervalsOverlap(d.fromUtc, end, startUtc, endUtc);
  }).toList();
}

/// Clips a duty to the local day starting at [localDayStart] and reports which
/// ends were cut, so the UI and the PDF can mark continuation.
ClippedDuty clipToDay(
  DutyInterval duty,
  DateTime localDayStart,
  DateTime nowUtc,
) {
  final startUtc = localDayStart.toUtc();
  final endUtc = DateTime(
    localDayStart.year,
    localDayStart.month,
    localDayStart.day + 1,
  ).toUtc();

  final dutyEnd = duty.isRunning ? _max(nowUtc, duty.fromUtc) : duty.toUtc!;

  return ClippedDuty(
    duty: duty,
    fromUtc: duty.fromUtc.isBefore(startUtc) ? startUtc : duty.fromUtc,
    toUtc: dutyEnd.isAfter(endUtc) ? endUtc : dutyEnd,
    clippedStart: duty.fromUtc.isBefore(startUtc),
    clippedEnd: duty.isRunning || dutyEnd.isAfter(endUtc),
  );
}

/// Running duties first (that is what an inspection asks about), then most
/// recent start first.
List<DutyInterval> sortForDisplay(List<DutyInterval> duties) {
  final sorted = [...duties];
  sorted.sort((a, b) {
    if (a.isRunning != b.isRunning) return a.isRunning ? -1 : 1;
    return b.fromUtc.compareTo(a.fromUtc);
  });
  return sorted;
}

/// Duties with no end yet. Cheap in-memory counterpart to the `toUtc IS NULL`
/// query, for lists that are already loaded.
List<DutyInterval> runningDuties(List<DutyInterval> duties) =>
    duties.where((d) => d.isRunning).toList();

DateTime _max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

/// Stand-in for "no end yet". Far enough out that no real duty reaches it.
final DateTime _farFuture = DateTime.utc(9999);
