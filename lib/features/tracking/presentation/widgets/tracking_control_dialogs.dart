import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../providers/tracking_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Zero-prerequisite Start: never blocks on check-in/briefing/vessel details.
/// Only decision it ever asks is whether to continue the last open voyage or
/// start a brand-new one — everything else is filled in later via reminder
/// chips in the Denník.
Future<void> handleStartTap(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final open = await ref.read(openVoyageProvider.future);
  if (!context.mounted) return;
  if (open == null) {
    await _startNew(context, ref);
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
    await _continueVoyage(context, ref, open);
  } else if (choice == 'new') {
    // `open` is left untouched — checkOutDone stays false, so its
    // "missing check-out" reminder chip surfaces on its own in the Denník.
    await _startNew(context, ref);
  }
}

Future<void> _continueVoyage(BuildContext context, WidgetRef ref, Charter charter) async {
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
  await _beginTracking(context, ref, charter, dayLog);
}

Future<void> _startNew(BuildContext context, WidgetRef ref) async {
  final charter = await createQuickCharter(ref);
  final dayLog = await ensureTodayDayLog(ref, charter);
  if (!context.mounted) return;
  await _beginTracking(context, ref, charter, dayLog);
}

Future<void> _beginTracking(
    BuildContext context, WidgetRef ref, Charter charter, DayLog dayLog) async {
  final dayFmt = DateFormat('EEE d.M.', 'sk');
  final interval = await _defaultLogInterval();
  await ref.read(trackingNotifierProvider.notifier).startTracking(
        '${dayFmt.format(DateTime.now())}: ${dayLog.portFrom ?? charter.title}',
        dayLogId: dayLog.id,
        logIntervalSeconds: interval,
      );
  if (context.mounted) context.go('/map');
}

Future<int> _defaultLogInterval() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('pending_log_interval') ?? 60;
}

/// Stop always confirms first — no more "continue tomorrow / end voyage"
/// branching here; that decision moved to the next Start tap instead.
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
  if (ok) {
    await ref.read(trackingNotifierProvider.notifier).stopTracking();
  }
}
