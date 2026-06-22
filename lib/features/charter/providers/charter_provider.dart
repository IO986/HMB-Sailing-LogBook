import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../main.dart';

final chartersProvider = FutureProvider<List<Charter>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllCharters();
});

final selectedCharterProvider = StateProvider<Charter?>((ref) => null);

final dayLogsProvider = FutureProvider.family<List<DayLog>, int>((ref, charterId) async {
  final db = ref.watch(databaseProvider);
  return db.getDayLogs(charterId);
});

final logbookEntriesForDayProvider = StreamProvider.family<List<LogbookEntry>, int>((ref, dayLogId) {
  final db = ref.watch(databaseProvider);
  return db.watchEntriesForDay(dayLogId);
});
