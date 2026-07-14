import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/tracking/providers/tracking_provider.dart';
import '../../features/tracking/presentation/widgets/tracking_control_dialogs.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Global Start/Stop tracking control shown above the body on Map,
/// Instruments and Denník tabs — idle it's a prominent Start pill (zero
/// prerequisites, always tappable); once tracking it becomes the slim
/// elapsed-time + Stop strip.
class TrackingControlBar extends ConsumerWidget {
  const TrackingControlBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTracking = ref.watch(isTrackingProvider);
    return isTracking ? const _TrackingActiveStrip() : const _StartPill();
  }
}

class _StartPill extends ConsumerWidget {
  const _StartPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingNotifierProvider);
    final l = AppLocalizations.of(context);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: trackingState.isLoading ? null : () => handleStartTap(context, ref),
            icon: trackingState.isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow, size: 22),
            label: Text(
              trackingState.isLoading ? l.starting : l.startVoyage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackingActiveStrip extends ConsumerWidget {
  const _TrackingActiveStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingNotifierProvider);
    final elapsed = ref.watch(elapsedTimeProvider);
    final l = AppLocalizations.of(context);

    final dur = elapsed.valueOrNull ?? Duration.zero;
    final h = dur.inHours.toString().padLeft(2, '0');
    final m = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = dur.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Material(
      color: Colors.green.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const Icon(Icons.gps_fixed, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text('$h:$m:$s', style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 15)),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: trackingState.isLoading ? null : () => handleStopTap(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.stop, size: 14),
            label: Text(l.stop, style: const TextStyle(fontSize: 12)),
          ),
        ]),
      ),
    );
  }
}
