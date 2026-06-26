import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../../providers/tracking_provider.dart';
import '../widgets/speed_gauge.dart';
import '../widgets/session_stats_card.dart';
import '../widgets/gps_data_row.dart';
import '../widgets/tracking_start_sheet.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingNotifierProvider);
    final positionAsync = ref.watch(positionStreamProvider);
    final elapsedAsync = ref.watch(elapsedTimeProvider);
    final l = AppLocalizations.of(context);

    ref.listen<TrackingState>(trackingNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.errorMsg(next.error!)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l.ok, textColor: Colors.white,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ));
      }
      if (next.showEndVoyageDialog && !(prev?.showEndVoyageDialog ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showTrackingEndVoyageDialog(context, ref, next.endedCharterId!);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          if (trackingState.isTracking)
            Container(
              width: 10, height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                  color: Colors.greenAccent, shape: BoxShape.circle),
            ),
          Text(trackingState.isTracking ? l.trackingActiveTitle : l.trackingTitle),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          positionAsync.when(
            data: (pos) => SpeedGauge(speedKnots: pos.speed * 1.94384),
            loading: () => const SpeedGauge(speedKnots: 0),
            error: (_, __) => const SpeedGauge(speedKnots: 0),
          ),
          const SizedBox(height: 16),
          elapsedAsync.when(
            data: (e) => _ElapsedCard(elapsed: e),
            loading: () => const _ElapsedCard(elapsed: Duration.zero),
            error: (_, __) => const _ElapsedCard(elapsed: Duration.zero),
          ),
          const SizedBox(height: 16),
          _GpsCard(positionAsync: positionAsync),
          const SizedBox(height: 16),
          const SessionStatsCard(),
          const SizedBox(height: 100),
        ]),
      ),
      bottomSheet: _TrackingControls(trackingState: trackingState),
    );
  }
}

// ── Elapsed ───────────────────────────────────────────────────

class _ElapsedCard extends StatelessWidget {
  final Duration elapsed;
  const _ElapsedCard({required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final h = elapsed.inHours.toString().padLeft(2, '0');
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.timer_outlined),
          const SizedBox(width: 12),
          Text('$h:$m:$s', style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// ── GPS Card ──────────────────────────────────────────────────

class _GpsCard extends StatefulWidget {
  final AsyncValue positionAsync;
  const _GpsCard({required this.positionAsync});
  @override
  State<_GpsCard> createState() => _GpsCardState();
}

class _GpsCardState extends State<_GpsCard> {
  geo.Position? _lastKnown;

  @override
  void initState() {
    super.initState();
    _fetchLastKnown();
  }

  Future<void> _fetchLastKnown() async {
    try {
      final pos = await geo.Geolocator.getLastKnownPosition();
      if (pos != null && mounted) { setState(() => _lastKnown = pos); return; }
      final cur = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.low,
            timeLimit: Duration(seconds: 10)));
      if (mounted) setState(() => _lastKnown = cur);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return widget.positionAsync.when(
      data: (pos) => GpsDataRow(position: pos),
      loading: () => _lastKnown != null
          ? _LastKnownCard(pos: _lastKnown!)
          : Card(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(l.waitingForGps, style: TextStyle(color: Colors.grey.shade600)),
              ]))),
      error: (_, __) => _lastKnown != null
          ? _LastKnownCard(pos: _lastKnown!)
          : Card(color: Colors.orange.shade50, child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.gps_off, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(child: Text(l.gpsUnavailable,
                    style: const TextStyle(color: Colors.orange))),
                TextButton(onPressed: _fetchLastKnown, child: Text(l.retry)),
              ]))),
    );
  }
}

class _LastKnownCard extends StatelessWidget {
  final geo.Position pos;
  const _LastKnownCard({required this.pos});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Icon(Icons.gps_fixed, color: Colors.blue.shade700, size: 18),
            const SizedBox(width: 8),
            Text(l.lastKnownPosition,
                style: TextStyle(color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Coord('Lat', pos.latitude.toStringAsFixed(5)),
            _Coord('Lon', pos.longitude.toStringAsFixed(5)),
            _Coord(l.accuracy, '±${pos.accuracy.toStringAsFixed(0)} m'),
          ]),
        ]),
      ),
    );
  }
}

class _Coord extends StatelessWidget {
  final String label, value;
  const _Coord(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  ]);
}

// ── Controls ──────────────────────────────────────────────────

class _TrackingControls extends ConsumerWidget {
  final TrackingState trackingState;
  const _TrackingControls({required this.trackingState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
            blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: trackingState.isTracking
          ? Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => context.go('/logbook'),
                icon: const Icon(Icons.note_add),
                label: Text(l.logbookBtn),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: trackingState.isLoading ? null
                    : () => ref.read(trackingNotifierProvider.notifier).stopTracking(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                icon: const Icon(Icons.stop),
                label: Text(l.stop),
              )),
            ])
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: trackingState.isLoading ? null
                    : () => _showStartSheet(context, ref),
                icon: trackingState.isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.play_arrow),
                label: Text(trackingState.isLoading ? l.starting : l.startVoyage),
              ),
            ),
    );
  }

  void _showStartSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const TrackingStartSheet(),
    );
  }
}

