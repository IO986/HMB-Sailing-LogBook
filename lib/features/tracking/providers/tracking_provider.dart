import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/gps_tracking_service.dart';
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

  Future<void> startTracking(String? name, {int? dayLogId, String? skipperName, int logIntervalSeconds = 3600}) async {
    debugPrint('[TRACKING] startTracking name=$name dayLogId=$dayLogId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await GpsTrackingService().startTracking(
          sessionName: name, dayLogId: dayLogId, skipperName: skipperName,
          logIntervalSeconds: logIntervalSeconds);
      await BackgroundService.start();
      ref.read(isTrackingProvider.notifier).state = true;
      state = state.copyWith(isLoading: false, isTracking: true);
    } catch (e, st) {
      debugPrint('[TRACKING] ERROR: $e\n$st');
      state = state.copyWith(isLoading: false, error: _friendly(e.toString()));
    }
  }

  Future<void> stopTracking() async {
    state = state.copyWith(isLoading: true);
    try {
      await GpsTrackingService().stopTracking();
      await BackgroundService.stop();
    } catch (e) { debugPrint('[TRACKING] Stop err: $e'); }
    ref.read(isTrackingProvider.notifier).state = false;
    state = state.copyWith(isLoading: false, isTracking: false);
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
