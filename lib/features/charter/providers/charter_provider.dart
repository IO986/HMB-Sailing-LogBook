import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/database/app_database.dart';
import '../../safety/presentation/screens/safety_screen.dart';
import '../../../main.dart';

final chartersProvider = FutureProvider<List<Charter>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllCharters();
});

/// Most recent charter still awaiting checkout, or null if none / first-ever use.
/// Drives the "Pokračovať v poslednej plavbe? / Nový záznam?" choice at Start.
/// GPX-imported voyages are never offered — they're read-only history
/// (map preview + Kniha míľ), tracking can't continue them.
final openVoyageProvider = FutureProvider<Charter?>((ref) async {
  final open = await ref.watch(openVoyagesProvider.future);
  return open.isEmpty ? null : open.first;
});

/// Všetky rozostavané plavby, najnovšia prvá.
///
/// Pri výcviku beží niekoľko plavieb naraz (jedna na žiaka) a skiper sa po
/// prerušení potrebuje vrátiť do TEJ SPRÁVNEJ — nie nutne do poslednej.
/// Ponuka pri štarte z toho robí tretiu možnosť vedľa „pokračovať" a „nová".
final openVoyagesProvider = FutureProvider<List<Charter>>((ref) async {
  final charters = await ref.watch(chartersProvider.future);
  return charters.where((c) => !c.checkOutDone && c.source != 'gpx').toList()
    ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
});

/// Silently creates a minimal charter for the "Nový záznam" / first-ever-use
/// path — no form shown, title defaults to today's date, everything else
/// (vessel, crew, check-in, briefing) is filled in later via reminder chips.
Future<Charter> createQuickCharter(WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final today = DateTime.now();
  final charter = await db.insertCharter(ChartersCompanion.insert(
    title: DateFormat('d. M. yyyy', 'sk').format(today),
    dateFrom: today,
    dateTo: today,
    createdAt: today,
  ));
  ref.invalidate(chartersProvider);
  return charter;
}

final selectedCharterProvider = StateProvider<Charter?>((ref) => null);

/// The charter the app should act on right now: whatever the user has open,
/// otherwise the voyage still awaiting checkout.
///
/// Exists so that features which can be reached from more than one place —
/// the duty card in Safety and the duty inspection screen, for instance —
/// cannot end up showing different charters.
final activeCharterProvider = FutureProvider<Charter?>((ref) async {
  final selected = ref.watch(selectedCharterProvider);
  if (selected != null) return selected;
  return ref.watch(openVoyageProvider.future);
});

final dayLogsProvider = FutureProvider.family<List<DayLog>, int>((ref, charterId) async {
  final db = ref.watch(databaseProvider);
  // Bez vedľajších účinkov: čítanie zoznamu dní nesmie chodiť na sieť.
  // Chýbajúce mená prístavov dopĺňa PortBackfillService z troch miest, kde
  // to dáva zmysel — štart appky, začiatok plavby a otvorenie exportu
  // (GpsTrackingService.retryMissingPortNames, ExportScreen._loadData).
  return db.getDayLogs(charterId);
});

final logbookEntriesForDayProvider = StreamProvider.family<List<LogbookEntry>, int>((ref, dayLogId) {
  final db = ref.watch(databaseProvider);
  return db.watchEntriesForDay(dayLogId);
});

/// Záznamy mimo plavby — MOB alebo kotva zapísané bez založenej plavby.
///
/// Patria do zoznamu plavieb medzi ostatné riadky, nie do vlastnej sekcie:
/// pre skipera je to jeden chronologický záznam toho, čo sa na vode dialo.
final unassignedEntriesProvider =
    StreamProvider<List<LogbookEntry>>((ref) =>
        ref.watch(databaseProvider).watchUnassignedEntries());

/// Čoho sa nezaradená udalosť týka — určuje ikonu a názov karty.
enum UnassignedEventKind { mob, anchor, other }

UnassignedEventKind unassignedKindOf(String? eventType) => switch (eventType) {
      'mob' || 'mob_cancelled' => UnassignedEventKind.mob,
      'anchor_dropped' ||
      'anchor_raised' ||
      'drift_out' ||
      'drift_in' =>
        UnassignedEventKind.anchor,
      _ => UnassignedEventKind.other,
    };

/// Súhrn kotvovej stráže za jeden deň.
///
/// Stráž beží mimo trasovania a jej body sú zámerne mimo míľ aj mimo
/// vzdialenosti dňa, takže o nej doteraz v denníku nebolo vidieť nič — hoci
/// appka celú noc zapisovala, kde loď na reťazi stála. Toto je ten chýbajúci
/// riadok: odkedy dokedy sa strážilo a ako ďaleko sa loď od kotvy dostala.
class AnchorWatchSummary {
  final DateTime from;

  /// Koniec stráže, alebo `null`, kým stráž ešte beží.
  final DateTime? to;
  final int pointCount;

  /// Najväčší výkyv od kotvy v metroch. Kotva je prvý zapísaný bod úseku —
  /// nie je to presne miesto, kde padla, ale je to miesto, kde loď stála,
  /// keď stráž začala, a o to pri výkyve ide.
  final double maxSwingM;

  const AnchorWatchSummary({
    required this.from,
    required this.to,
    required this.pointCount,
    required this.maxSwingM,
  });
}

final anchorWatchForDayProvider =
    FutureProvider.family<List<AnchorWatchSummary>, int>((ref, dayLogId) async {
  final db = ref.watch(databaseProvider);
  final sessions = await db.getSessionsForDay(dayLogId, includeAnchorWatch: true);
  final watches = sessions.where((s) => s.isAnchorWatch).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final out = <AnchorWatchSummary>[];
  for (final s in watches) {
    final points = await db.getTrackPointsForSession(s.sessionId);
    var maxSwing = 0.0;
    if (points.isNotEmpty) {
      final origin = LatLng(points.first.latitude, points.first.longitude);
      for (final p in points) {
        final d = anchorDistanceM(origin, LatLng(p.latitude, p.longitude));
        if (d > maxSwing) maxSwing = d;
      }
    }
    out.add(AnchorWatchSummary(
      from: s.startTime,
      to: s.isActive ? null : s.endTime,
      pointCount: points.length,
      maxSwingM: maxSwing,
    ));
  }
  return out;
});

/// Returns today's [DayLog] for [charter], creating one if it doesn't exist yet.
Future<DayLog> ensureTodayDayLog(WidgetRef ref, Charter charter) async {
  final db = ref.read(databaseProvider);
  final today = DateTime.now();
  final days = await db.getDayLogs(charter.id);
  final todayLog = days.where((d) =>
      d.date.year == today.year &&
      d.date.month == today.month &&
      d.date.day == today.day).toList();
  if (todayLog.isNotEmpty) return todayLog.first;

  final dayLog = await db.insertDayLog(DayLogsCompanion.insert(
    charterId: charter.id,
    date: today,
  ));
  ref.invalidate(dayLogsProvider(charter.id));
  return dayLog;
}
