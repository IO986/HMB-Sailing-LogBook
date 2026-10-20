import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/gps_tracking_service.dart';
import '../../../core/services/background_service.dart';
import '../../../main.dart';
import '../../duty/providers/duty_provider.dart';

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
  const TrackingState({
    this.isTracking = false,
    this.isLoading = false,
    this.error,
  });
  TrackingState copyWith({bool? isTracking, bool? isLoading, String? error}) =>
      TrackingState(
        isTracking: isTracking ?? this.isTracking,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class TrackingNotifier extends Notifier<TrackingState> {
  @override
  TrackingState build() => const TrackingState();

  Future<void> startTracking(String? name,
      {int? dayLogId,
      String? skipperName,
      int logIntervalSeconds = 3600,
      double bridgedDistanceNm = 0,
      bool isResume = false}) async {
    debugPrint('[TRACKING] startTracking name=$name dayLogId=$dayLogId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await GpsTrackingService().startTracking(
          sessionName: name,
          dayLogId: dayLogId,
          skipperName: skipperName,
          logIntervalSeconds: logIntervalSeconds,
          bridgedDistanceNm: bridgedDistanceNm,
          isResume: isResume);
      await BackgroundService.start();
      ref.read(isTrackingProvider.notifier).state = true;
      state = state.copyWith(isLoading: false, isTracking: true);
      // A resumed voyage keeps the duty state it had: the duties were never
      // closed, and anyone taken off duty by hand must stay off.
      if (!isResume && dayLogId != null) {
        await _syncDuties(dayLogId, start: true);
      }
    } catch (e, st) {
      debugPrint('[TRACKING] ERROR: $e\n$st');
      state = state.copyWith(isLoading: false, error: _friendly(e.toString()));
    }
  }

  Future<void> stopTracking() async {
    state = state.copyWith(isLoading: true);
    // Read before stopTracking(), which nulls it.
    final dayLogId = GpsTrackingService().activeDayLogId;
    try {
      await GpsTrackingService().stopTracking();
      await BackgroundService.stop();
    } catch (e) { debugPrint('[TRACKING] Stop err: $e'); }
    if (dayLogId != null) await _syncDuties(dayLogId, start: false);
    ref.read(isTrackingProvider.notifier).state = false;
    state = state.copyWith(isLoading: false, isTracking: false);
  }

  /// Crew comes on duty with tracking and goes off with it. Failure is
  /// logged and swallowed — a duty record must never stop the GPS track.
  Future<void> _syncDuties(int dayLogId, {required bool start}) async {
    try {
      final day = await ref.read(databaseProvider).getDayLogById(dayLogId);
      if (day == null) return;
      final duties = ref.read(dutyControllerProvider);
      if (start) {
        await duties.startWithTracking(day.charterId);
      } else {
        await duties.endWithTracking(day.charterId);
      }
    } catch (e, st) {
      debugPrint('[TRACKING] duty sync failed: $e\n$st');
    }
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
