import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/tracking_interval_selector.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../providers/tracking_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Zero-prerequisite Start: never blocks on check-in/briefing/vessel details.
/// Only decision it ever asks is whether to continue the last open voyage or
/// start a brand-new one — everything else is filled in later via reminder
/// chips in the Denník.
Future<void> handleStartTap(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final interval = await _pickLogInterval(context);
  if (interval == null || !context.mounted) return;
  final open = await ref.read(openVoyageProvider.future);
  if (!context.mounted) return;
  if (open == null) {
    await _startNew(context, ref, interval);
    return;
  }

  final fmt = DateFormat('d.M.yyyy', 'sk');
  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.continueLastVoyageTitle),
      content: Text('${open.title}  ·  ${fmt.format(open.dateFrom)}'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, 'new'),
          child: Text(l.newRecordAction),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, 'continue'),
          child: Text(l.continueVoyageAction),
        ),
      ],
    ),
  );

  if (!context.mounted || choice == null) return;
  if (choice == 'continue') {
    await _continueVoyage(context, ref, open, interval);
  } else if (choice == 'new') {
    // `open` is left untouched — checkOutDone stays false, so its
    // "missing check-out" reminder chip surfaces on its own in the Denník.
    await _startNew(context, ref, interval);
  }
}

/// Popup hneď po ťuknutí na Start: výber frekvencie zápisov do denníka.
/// Zrušenie dialógu zruší celý štart (nič sa nevytvorí). Zvolená hodnota
/// sa uloží ako predvolená pre nabudúce.
Future<int?> _pickLogInterval(BuildContext context) async {
  final l = AppLocalizations.of(context);
  var selected = await _defaultLogInterval();
  if (!context.mounted) return null;
  final result = await showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        content: TrackingIntervalSelector(
          value: selected,
          onChanged: (v) => setState(() => selected = v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, selected),
            child: Text(l.startTracking),
          ),
        ],
      ),
    ),
  );
  if (result != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pending_log_interval', result);
  }
  return result;
}

Future<void> _continueVoyage(
    BuildContext context, WidgetRef ref, Charter charter, int intervalSeconds) async {
  final db = ref.read(databaseProvider);
  final today = DateTime.now();
  if (today.isAfter(charter.dateTo)) {
    await db.updateCharter(ChartersCompanion(
      id: Value(charter.id),
      dateTo: Value(today),
    ));
    ref.invalidate(chartersProvider);
  }
  final dayLog = await ensureTodayDayLog(ref, charter);
  if (!context.mounted) return;
  await _beginTracking(context, ref, charter, dayLog, intervalSeconds);
}

Future<void> _startNew(BuildContext context, WidgetRef ref, int intervalSeconds) async {
  final charter = await createQuickCharter(ref);
  final dayLog = await ensureTodayDayLog(ref, charter);
  if (!context.mounted) return;
  await _beginTracking(context, ref, charter, dayLog, intervalSeconds);
}

Future<void> _beginTracking(BuildContext context, WidgetRef ref, Charter charter,
    DayLog dayLog, int intervalSeconds) async {
  final dayFmt = DateFormat('EEE d.M.', 'sk');
  await ref.read(trackingNotifierProvider.notifier).startTracking(
        '${dayFmt.format(DateTime.now())}: ${dayLog.portFrom ?? charter.title}',
        dayLogId: dayLog.id,
        logIntervalSeconds: intervalSeconds,
      );
  if (context.mounted) context.go('/map');
}

Future<int> _defaultLogInterval() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('pending_log_interval') ?? 60;
}

/// Stop always confirms first — no more "continue tomorrow / end voyage"
/// branching here; that decision moved to the next Start tap instead.
///
/// Deliberately does **not** auto-export: the day lands in the Denník so
/// the skipper can still fix/finish entries first (weather, crew notes,
/// duty periods) before anything gets built into a PDF or queued to
/// Google Drive. `docs/plan_cloud_export.md` §5/§6 — the actual PDF/GPX
/// build + cloud enqueue happens in `export_screen.dart`'s `_doExport`,
/// triggered by the skipper explicitly opening the day's export (the PDF
/// icon on this Denník screen), never automatically right after Stop.
/// `dayLogId` is read **before** `stopTracking()` —
/// `GpsTrackingService.stopTracking()` nulls `activeDayLogId`
/// (gps_tracking_service.dart), so reading it after would always be null.
Future<void> handleStopTap(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.stopTrackingDay),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.stop),
            ),
          ],
        ),
      ) ??
      false;
  if (!ok) return;

  final dayLogId = GpsTrackingService().activeDayLogId;
  await ref.read(trackingNotifierProvider.notifier).stopTracking();
  if (dayLogId == null || !context.mounted) return;

  final day = await ref.read(databaseProvider).getDayLogById(dayLogId);
  if (day == null || !context.mounted) return;
  context.go('/logbook/${day.charterId}/day/$dayLogId');
}
