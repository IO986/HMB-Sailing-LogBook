import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/gps_tracking_service.dart';
import '../../../main.dart';
import '../../tracking/providers/tracking_provider.dart';
import '../providers/charter_provider.dart';

enum VoyageStep { needsCheckIn, needsBriefing, readyToTrack, tracking, needsCheckOut, closed }

/// Independent, simultaneous reminders for a voyage — unlike [VoyageStep]
/// (a single "next step"), several of these can be true at once (e.g. a
/// voyage started mid-sail with zero paperwork needs check-in AND briefing
/// AND vessel details all at the same time).
enum VoyageReminder { checkIn, briefing, details, checkOut }

class VoyageProgress {
  final VoyageStep step;
  final bool checkInClosed;
  final bool checkOutClosed;
  final bool briefingDone;
  final bool detailsComplete;
  final bool hasAnyDayLog;
  const VoyageProgress({
    required this.step,
    required this.checkInClosed,
    required this.checkOutClosed,
    required this.briefingDone,
    required this.detailsComplete,
    required this.hasAnyDayLog,
  });

  /// True for a voyage silently created by tapping Start with no prior
  /// setup — still awaiting its very first piece of paperwork.
  bool get isNew => !checkInClosed && !briefingDone && !hasAnyDayLog;

  List<VoyageReminder> get reminders => [
        if (!checkInClosed) VoyageReminder.checkIn,
        if (!briefingDone) VoyageReminder.briefing,
        if (!detailsComplete) VoyageReminder.details,
        if (!checkOutClosed && checkInClosed && hasAnyDayLog) VoyageReminder.checkOut,
      ];
}

bool _isProtocolClosed(HandoverProtocol? p) =>
    p != null && p.skipperSignedAt != null && p.companySignedAt != null;

/// Single source of truth for "what's next / what's missing" for a charter,
/// derived from the real handover-protocol signature state (not the legacy
/// checkInDone/checkOutDone flags, which can be stale) plus live tracking
/// state. Both the wizard-less Denník reminder chips and any remaining
/// "what's next" UI read from here — nothing else should re-derive this.
final voyageProgressProvider = FutureProvider.family<VoyageProgress, int>((ref, charterId) async {
  final db = ref.watch(databaseProvider);
  final charters = await ref.watch(chartersProvider.future);
  Charter? charter;
  try {
    charter = charters.firstWhere((c) => c.id == charterId);
  } catch (_) {}

  if (charter == null) {
    return const VoyageProgress(
      step: VoyageStep.closed,
      checkInClosed: false,
      checkOutClosed: false,
      briefingDone: false,
      detailsComplete: false,
      hasAnyDayLog: false,
    );
  }

  final checkIn = await db.getHandoverProtocol(charterId, 'checkIn');
  final checkOut = await db.getHandoverProtocol(charterId, 'checkOut');
  final checkInClosed = _isProtocolClosed(checkIn);
  final checkOutClosed = _isProtocolClosed(checkOut);
  final days = await ref.watch(dayLogsProvider(charterId).future);
  final hasAnyDayLog = days.isNotEmpty;
  final detailsComplete = (charter.vesselName?.isNotEmpty ?? false) &&
      (charter.skipperName?.isNotEmpty ?? false);

  final isTracking = ref.watch(isTrackingProvider);
  final activeDayLogId = GpsTrackingService().activeDayLogId;
  var trackingThisCharter = false;
  if (isTracking && activeDayLogId != null) {
    final dayLog = await db.getDayLogById(activeDayLogId);
    trackingThisCharter = dayLog?.charterId == charterId;
  }

  final today = DateTime.now();
  final overdueForCheckOut = today.isAfter(charter.dateTo) && !checkOutClosed;

  final VoyageStep step;
  if (trackingThisCharter) {
    step = VoyageStep.tracking;
  } else if (!checkInClosed) {
    step = VoyageStep.needsCheckIn;
  } else if (!charter.safetyBriefingDone) {
    step = VoyageStep.needsBriefing;
  } else if (checkOutClosed) {
    step = VoyageStep.closed;
  } else if (overdueForCheckOut) {
    step = VoyageStep.needsCheckOut;
  } else {
    step = VoyageStep.readyToTrack;
  }

  return VoyageProgress(
    step: step,
    checkInClosed: checkInClosed,
    checkOutClosed: checkOutClosed,
    briefingDone: charter.safetyBriefingDone,
    detailsComplete: detailsComplete,
    hasAnyDayLog: hasAnyDayLog,
  );
});
