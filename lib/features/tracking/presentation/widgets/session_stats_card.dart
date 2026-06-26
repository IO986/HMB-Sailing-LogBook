import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/gps_tracking_service.dart';
import '../../../../l10n/app_localizations.dart';

String _elapsed(DateTime start) {
  final d = DateTime.now().difference(start);
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$h:$m';
}

class SessionStatsCard extends ConsumerWidget {
  const SessionStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = GpsTrackingService().currentSession;
    if (session == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).sessionStats,
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            Row(children: [
              Expanded(
                  child: _StatTile(
                label: AppLocalizations.of(context).maxSpeed,
                value: '${session.maxSpeedKnots.toStringAsFixed(1)} kn',
                icon: Icons.speed,
              )),
              Expanded(
                  child: _StatTile(
                label: AppLocalizations.of(context).distance,
                value: '${session.totalDistanceNm.toStringAsFixed(2)} NM',
                icon: Icons.straighten,
              )),
            ]),
            Row(children: [
              Expanded(
                  child: _StatTile(
                label: AppLocalizations.of(context).avgSpeed,
                value: '${session.avgSpeedKnots.toStringAsFixed(1)} kn',
                icon: Icons.analytics,
              )),
              Expanded(
                  child: _StatTile(
                label: AppLocalizations.of(context).sailingTime,
                value: _elapsed(session.startTime),
                icon: Icons.timer,
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatTile(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
