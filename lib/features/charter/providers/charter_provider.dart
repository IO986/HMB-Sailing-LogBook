import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
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
  final charters = await ref.watch(chartersProvider.future);
  final open = charters
      .where((c) => !c.checkOutDone && c.source != 'gpx')
      .toList()
    ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
  return open.isEmpty ? null : open.first;
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

final dayLogsProvider = FutureProvider.family<List<DayLog>, int>((ref, charterId) async {
  final db = ref.watch(databaseProvider);
  return db.getDayLogs(charterId);
});

final logbookEntriesForDayProvider = StreamProvider.family<List<LogbookEntry>, int>((ref, dayLogId) {
  final db = ref.watch(databaseProvider);
  return db.watchEntriesForDay(dayLogId);
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
