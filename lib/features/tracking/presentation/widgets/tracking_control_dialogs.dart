import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/skipper_profile.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/skipper_profile_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/providers/sync_settings_provider.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/tracking_interval_selector.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../../cloud/services/auto_export_service.dart';
import '../../../export/presentation/widgets/day_map_view.dart';
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
/// Also the trigger for cloud auto-export (`docs/plan_cloud_export.md` §5):
/// captures the day's map off-tree, stops tracking, then builds + queues
/// the day's PDF/GPX. `dayLogId` is read **before** `stopTracking()` —
/// `GpsTrackingService.stopTracking()` nulls `activeDayLogId`
/// (gps_tracking_service.dart), so capturing it after would always be null.
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

  if (dayLogId == null) {
    // No active day to export (shouldn't normally happen while tracking).
    await ref.read(trackingNotifierProvider.notifier).stopTracking();
    return;
  }

  BuildContext? dialogCtx;
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogCtx = ctx;
        return AlertDialog(
          content: Row(children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(l.finishingDayExport)),
          ]),
        );
      },
    );
  }

  final mapScreenshot = await _captureDayMap(ref, dayLogId, context);
  // Resolved before stopTracking()/export runs — none of this needs
  // BuildContext, just whatever WidgetRef.read gives us.
  final cloudEnabled = (await ref.read(syncSettingsProvider.future)).cloudEnabled;
  final skipperProfile = await ref
      .read(skipperProfileProvider.future)
      .catchError((_) => const SkipperProfile());

  await ref.read(trackingNotifierProvider.notifier).stopTracking();
  await AutoExportService().exportAndEnqueueDay(
    db: ref.read(databaseProvider),
    engine: ref.read(syncEngineProvider),
    cloudEnabled: cloudEnabled,
    locale: ref.read(localeProvider),
    skipperProfile: skipperProfile,
    dayLogId: dayLogId,
    mapScreenshot: mapScreenshot,
  );

  if (dialogCtx != null && dialogCtx!.mounted) {
    Navigator.of(dialogCtx!).pop();
  }
  if (mapScreenshot == null && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.pdfMapUnavailable)));
  }
}

/// Off-tree map capture for the day being closed — never lets a capture
/// failure (unrendered tiles, missing context) stop the day from being
/// saved; the PDF just gets built without a map and the caller tells the
/// user so (`docs/plan_cloud_export.md` §3: "nikdy nie potichu").
Future<Uint8List?> _captureDayMap(WidgetRef ref, int dayLogId, BuildContext context) async {
  try {
    final db = ref.read(databaseProvider);
    final sessions = await db.getSessionsForDay(dayLogId);
    final trackPoints = <TrackPoint>[];
    for (final s in sessions) {
      trackPoints.addAll(await db.getTrackPointsForSession(s.sessionId));
    }
    if (!context.mounted) return null;
    return await ScreenshotController().captureFromWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 360, height: 240, child: DayMapView(trackPoints: trackPoints)),
        ),
      ),
      delay: const Duration(seconds: 2),
      context: context,
    );
  } catch (_) {
    return null;
  }
}
