import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/utils/distance_calculator.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/logbook_event_type.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/tracking_interval_selector.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../providers/tracking_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import '../../../../core/utils/localized_date.dart';

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

  final fmt = AppDate.of(context, ref);
  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.continueLastVoyageTitle),
      content: Text('${open.title}  ·  ${fmt.short(open.dateFrom)}'),
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

/// Ponuka po neúmyselnom vypnutí appky počas trasovania.
///
/// Prerušenú session pozná podľa chýbajúceho endTime — ten zapisuje jedine
/// stopTracking(), takže jeho absencia znamená, že plavbu nikto neukončil.
/// Žiadny časový limit na to netreba: vypnutie appky po riadnom ukončení
/// plavby sa takto nikdy neoznačí ako prerušenie.
///
/// Ak je poloha pri obnovení inde než posledný zaznamenaný bod, ponúkne aj
/// dopočítanie tejto medzery — po priamke, lebo o trase medzitým nič nevieme.
/// Prerušená plavba aj s tým, čo o nej treba vedieť pri obnovení.
class InterruptedVoyage {
  const InterruptedVoyage({
    required this.session,
    required this.lastPoint,
    required this.dayLog,
    required this.charter,
    required this.gapNm,
    required this.silentFor,
  });

  final SailingSession session;
  final TrackPoint lastPoint;
  final DayLog dayLog;
  final Charter charter;

  /// Vzdušná čiara medzi posledným zaznamenaným bodom a polohou teraz.
  final double gapNm;

  /// Ako dlho sa nič nezapisovalo.
  final Duration silentFor;

  /// Pod 0,1 NM je to GPS šum, nie prejdená vzdialenosť.
  bool get offersGap => gapNm >= 0.1;
}

/// Do akej diery sa plavba obnoví sama.
///
/// Za týmto oknom sa appka radšej spýta: plavba, ktorú nikto neukončil a
/// telefón ju nevidel pol dňa, je pravdepodobne dávno skončená a ticho
/// rozbehnuté trasovanie by k nej pripísalo cestu autom do hotela.
const _autoResumeWindow = Duration(hours: 3);

/// Rozbehne sa plavba po tomto tichu sama?
///
/// Vytiahnuté zo [maybePromptInterruptedVoyage], ktoré potrebuje
/// `BuildContext` a testovať sa nedá; samotná hranica áno, a je to tá vec,
/// ktorá rozhoduje medzi „doplň mi tých 45 minút" a „pripíš mi cestu autom
/// do hotela".
@visibleForTesting
bool shouldAutoResume(Duration silentFor) =>
    silentFor >= Duration.zero && silentFor <= _autoResumeWindow;

/// Nájde prerušenú plavbu, alebo `null`. Po ceste upratuje session, ktoré sa
/// obnoviť nedajú — bez bodov alebo bez dňa nie je čo obnovovať.
Future<InterruptedVoyage?> findInterruptedVoyage(AppDatabase db) async {
  final interrupted = await db.getInterruptedSession();
  if (interrupted == null) return null;

  final lastPoint = await db.getLastTrackPoint(interrupted.sessionId);
  final dayLogId = interrupted.dayLogId;
  if (lastPoint == null || dayLogId == null) {
    await db.closeInterruptedSession(interrupted);
    return null;
  }

  final dayLog = await db.getDayLogById(dayLogId);
  final charter =
      dayLog == null ? null : await db.getCharterById(dayLog.charterId);
  if (dayLog == null || charter == null) {
    await db.closeInterruptedSession(interrupted);
    return null;
  }

  final position = await LocationService().currentFix();
  var gapNm = 0.0;
  if (position != null) {
    gapNm = DistanceCalculator.distanceM(
          lastPoint.latitude, lastPoint.longitude,
          position.latitude, position.longitude,
        ) /
        1852;
  }

  return InterruptedVoyage(
    session: interrupted,
    lastPoint: lastPoint,
    dayLog: dayLog,
    charter: charter,
    gapNm: gapNm,
    silentFor: DateTime.now().toUtc().difference(lastPoint.timestamp.toUtc()),
  );
}

/// Rozbehne trasovanie prerušenej plavby ďalej.
///
/// Medzera sa dopočítava len na výslovné želanie: je to priamka medzi dvoma
/// bodmi, teda odhad, a odhad sa do denníka nepridáva sám od seba.
Future<void> resumeInterruptedVoyage(
    BuildContext context, WidgetRef ref, InterruptedVoyage voyage,
    {bool bridgeGap = false}) async {
  final db = ref.read(databaseProvider);
  await db.closeInterruptedSession(voyage.session);
  final interval = await _defaultLogInterval();
  if (!context.mounted) return;
  await _beginTracking(context, ref, voyage.charter, voyage.dayLog, interval,
      bridgedDistanceNm: bridgeGap ? voyage.gapNm : 0, isResume: true);
}

/// Po návrate appky: pokračuj v plavbe sám, alebo sa spýtaj.
///
/// Dialóg je zlá odpoveď na bežný prípad. Systém (na Honore a Huawei bežne)
/// zabije appku vo vrecku, na dialóg nemá kto odpovedať a trasovanie stojí,
/// kým si to niekto nevšimne — nahlásené z terénu: 45 minút plavby, ktoré
/// v denníku nie sú, a päť „začiatkov plavby" za jeden deň. Preto sa v okne
/// [_autoResumeWindow] plavba rozbehne ticho ďalej a používateľ sa to len
/// dozvie; pýtame sa až pri diere, pri ktorej je otázne, či plavba vôbec
/// ešte trvá.
Future<void> maybePromptInterruptedVoyage(
    BuildContext context, WidgetRef ref) async {
  if (GpsTrackingService().isTracking) return;

  final db = ref.read(databaseProvider);
  final voyage = await findInterruptedVoyage(db);
  if (voyage == null) return;
  if (!context.mounted) return;

  if (shouldAutoResume(voyage.silentFor)) {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final minutes = voyage.silentFor.inMinutes;
    await resumeInterruptedVoyage(context, ref, voyage);
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 8),
      content: Text(l.trackingResumedAuto('$minutes')),
      action: voyage.offersGap
          ? SnackBarAction(
              label: l.trackingResumedAddGap(voyage.gapNm.toStringAsFixed(1)),
              onPressed: () => unawaited(
                  db.addBridgedDistance(voyage.dayLog.id, voyage.gapNm)),
            )
          : null,
    ));
    return;
  }

  final interrupted = voyage.session;
  final lastPoint = voyage.lastPoint;
  final dayLog = voyage.dayLog;
  final charter = voyage.charter;
  final gapNm = voyage.gapNm;
  final offersGap = voyage.offersGap;

  final l = AppLocalizations.of(context);
  var addGap = offersGap;

  final resume = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        icon: const Icon(Icons.play_circle_outline, size: 32),
        title: Text(l.interruptedVoyageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.interruptedVoyageBody(
                DateFormat.Hm().format(lastPoint.timestamp.toLocal()))),
            if (offersGap) ...[
              const SizedBox(height: 12),
              Text(l.interruptedVoyageGap(gapNm.toStringAsFixed(1))),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: addGap,
                onChanged: (v) => setState(() => addGap = v ?? false),
                title: Text(l.interruptedVoyageAddGap),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.interruptedVoyageResume),
          ),
        ],
      ),
    ),
  );

  if (resume != true) {
    // Plavba pokračuje novou session, takže starú treba uzavrieť tak či tak.
    await db.closeInterruptedSession(interrupted);
    // Plavba, ktorú prerušilo vypnutie appky, by inak ostala v denníku bez
    // konca — a keď skiper neskôr spustí novú, deň by mal dva začiatky a
    // jeden koniec. Koniec sa zapíše časom a polohou POSLEDNÉHO
    // zaznamenaného bodu: to je pozorovaný údaj, nie dohad o tom, kedy sa
    // loď naozaj zastavila.
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayLog.id),
      sessionId: Value(interrupted.sessionId),
      timestamp: lastPoint.timestamp,
      latitude: Value(lastPoint.latitude),
      longitude: Value(lastPoint.longitude),
      skipperNote: const Value('Voyage end'),
      eventType: Value(LogbookEventType.voyageEnd.code),
      isAutoEntry: const Value(true),
    ));
    return;
  }

  if (!context.mounted) return;
  await resumeInterruptedVoyage(context, ref, voyage,
      bridgeGap: offersGap && addGap);
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

/// Jednorazová pripomienka nastavenia batérie pri prvom spustení plavby.
///
/// Foreground service samotný nestačí: Honor, Huawei a Xiaomi zabíjajú appky
/// na pozadí vlastnou správou napájania a trasovanie sa preruší uprostred
/// plavby. Zámerne sa nežiada REQUEST_IGNORE_BATTERY_OPTIMIZATIONS — tá je na
/// Play citlivá; stačí otvoriť systémové nastavenia batérie.
Future<void> _maybePromptBatterySettings(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('battery_prompted') ?? false) return;
  await prefs.setBool('battery_prompted', true);
  if (!context.mounted) return;

  final l = AppLocalizations.of(context);
  final open = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.battery_saver_outlined, size: 32),
      title: Text(l.batteryPromptTitle),
      content: SingleChildScrollView(child: Text(l.batteryPromptBody)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.notNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.batteryPromptAction),
        ),
      ],
    ),
  );
  if (open == true) {
    await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
  }
}

Future<void> _beginTracking(BuildContext context, WidgetRef ref, Charter charter,
    DayLog dayLog, int intervalSeconds,
    {double bridgedDistanceNm = 0, bool isResume = false}) async {
  await _maybePromptBatterySettings(context);
  if (!context.mounted) return;

  final dayFmt = AppDate.of(context, ref);
  await ref.read(trackingNotifierProvider.notifier).startTracking(
        '${dayFmt.shortWithWeekday(DateTime.now())}: ${dayLog.portFrom ?? charter.title}',
        dayLogId: dayLog.id,
        logIntervalSeconds: intervalSeconds,
        bridgedDistanceNm: bridgedDistanceNm,
        isResume: isResume,
      );
  if (context.mounted) context.go('/map');
}

Future<int> _defaultLogInterval() async {
  final prefs = await SharedPreferences.getInstance();
  // Cez normalize: staré uložené 30 s či 1 min sa už neponúkajú, ale niekomu
  // v nastaveniach stále leží.
  final stored = prefs.getInt('pending_log_interval');
  return stored == null
      ? TrackingIntervalSelector.defaultSeconds
      : TrackingIntervalSelector.normalize(stored);
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
