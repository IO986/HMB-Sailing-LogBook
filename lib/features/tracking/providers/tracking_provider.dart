import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/gps_tracking_service.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../../../core/services/background_service.dart';

final isTrackingProvider = StateProvider<bool>((ref) => false);

final positionStreamProvider = StreamProvider<Position>((ref) =>
    GpsTrackingService().positionStream);

final elapsedTimeProvider = StreamProvider<Duration>((ref) {
  if (!ref.watch(isTrackingProvider)) return Stream.value(Duration.zero);
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final s = GpsTrackingService().currentSession;
    return s == null ? Duration.zero : DateTime.now().difference(s.startTime);
  });
});

class TrackingState {
  final bool isTracking;
  final bool isLoading;
  final String? error;
  final bool showEndVoyageDialog; // zobraziť dialog po ukončení posledného dňa
  final int? endedCharterId;
  const TrackingState({
    this.isTracking = false,
    this.isLoading = false,
    this.error,
    this.showEndVoyageDialog = false,
    this.endedCharterId,
  });
  TrackingState copyWith({bool? isTracking, bool? isLoading, String? error,
      bool? showEndVoyageDialog, int? endedCharterId}) =>
      TrackingState(
        isTracking: isTracking ?? this.isTracking,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        showEndVoyageDialog: showEndVoyageDialog ?? this.showEndVoyageDialog,
        endedCharterId: endedCharterId ?? this.endedCharterId,
      );
}

class TrackingNotifier extends Notifier<TrackingState> {
  @override
  TrackingState build() => const TrackingState();

  Future<void> startTracking(String? name, {int? dayLogId, String? skipperName, int logIntervalSeconds = 3600}) async {
    print('[TRACKING] startTracking name=$name dayLogId=$dayLogId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await GpsTrackingService().startTracking(
          sessionName: name, dayLogId: dayLogId, skipperName: skipperName,
          logIntervalSeconds: logIntervalSeconds);
      await BackgroundService.start();
      ref.read(isTrackingProvider.notifier).state = true;
      state = state.copyWith(isLoading: false, isTracking: true);
    } catch (e, st) {
      print('[TRACKING] ERROR: $e\n$st');
      state = state.copyWith(isLoading: false, error: _friendly(e.toString()));
    }
  }

  Future<void> stopTracking() async {
    state = state.copyWith(isLoading: true);

    final activeDayLogId = GpsTrackingService().activeDayLogId;

    try {
      await GpsTrackingService().stopTracking();
      await BackgroundService.stop();
    } catch (e) { print('[TRACKING] Stop err: $e'); }

    ref.read(isTrackingProvider.notifier).state = false;

    // Skontroluj či je koniec posledného plánovaného dňa
    bool showDialog = false;
    int? charterId;
    if (activeDayLogId != null) {
      try {
        final db = ref.read(databaseProvider);
        final allDays = await _getDayLogById(db, activeDayLogId);
        if (allDays != null) {
          charterId = allDays.charterId;
          final charters = await db.getAllCharters();
          final charter = charters.firstWhere((c) => c.id == charterId);
          final today = DateTime.now();
          // Je dnes posledný plánovaný deň?
          final isLastDay = !charter.dateTo.isAfter(
            DateTime(today.year, today.month, today.day, 23, 59));
          if (isLastDay) showDialog = true;
        }
      } catch (_) {}
    }

    state = state.copyWith(
      isLoading: false,
      isTracking: false,
      showEndVoyageDialog: showDialog,
      endedCharterId: charterId,
    );
  }

  Future<DayLog?> _getDayLogById(AppDatabase db, int dayLogId) async {
    try {
      final charters = await db.getAllCharters();
      for (final c in charters) {
        final days = await db.getDayLogs(c.id);
        for (final d in days) {
          if (d.id == dayLogId) return d;
        }
      }
    } catch (_) {}
    return null;
  }

  void clearEndVoyageDialog() {
    state = state.copyWith(showEndVoyageDialog: false, endedCharterId: null);
  }

  Future<void> extendVoyage(int charterId) async {
    // Predĺž plavbu o 1 deň
    final db = ref.read(databaseProvider);
    final charters = await db.getAllCharters();
    final charter = charters.firstWhere((c) => c.id == charterId);
    await db.updateCharter(ChartersCompanion(
      id: Value(charter.id),
      title: Value(charter.title),
      dateFrom: Value(charter.dateFrom),
      dateTo: Value(charter.dateTo.add(const Duration(days: 1))),
      createdAt: Value(charter.createdAt),
    ));
    clearEndVoyageDialog();
  }

  Future<void> endVoyage(int charterId) async {
    // Označ plavbu ako ukončenú (checkOut)
    final db = ref.read(databaseProvider);
    final charters = await db.getAllCharters();
    final charter = charters.firstWhere((c) => c.id == charterId);
    await db.updateCharter(ChartersCompanion(
      id: Value(charter.id),
      title: Value(charter.title),
      dateFrom: Value(charter.dateFrom),
      dateTo: Value(charter.dateTo),
      createdAt: Value(charter.createdAt),
      checkOutDone: const Value(true),
    ));
    clearEndVoyageDialog();
  }

  String _friendly(String e) {
    if (e.contains('permission') || e.contains('Permission'))
      return 'GPS permission denied. Enable location in phone settings.';
    if (e.contains('service'))
      return 'GPS is not enabled. Enable Location in settings.';
    return 'Error: $e';
  }
}

final trackingNotifierProvider =
    NotifierProvider<TrackingNotifier, TrackingState>(TrackingNotifier.new);
