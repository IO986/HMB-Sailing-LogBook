import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/units_service.dart';

class GpsDataRow extends ConsumerWidget {
  final Position position;
  const GpsDataRow({super.key, required this.position});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lat = position.latitude;
    final lon = position.longitude;
    final course = position.heading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).gpsData, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _DataRow(
              icon: Icons.location_on,
              label: AppLocalizations.of(context).gpsPosition,
              value: ref.watch(unitsSyncProvider).formatCoords(lat, lon),
            ),
            _DataRow(
              icon: Icons.explore,
              label: AppLocalizations.of(context).courseCog,
              value: '${course.toStringAsFixed(0)}°',
            ),
            _DataRow(
              icon: Icons.height,
              label: AppLocalizations.of(context).altitudeLabel,
              value: '${position.altitude.toStringAsFixed(0)} m',
            ),
            _DataRow(
              icon: Icons.gps_fixed,
              label: AppLocalizations.of(context).accuracy,
              value: '± ${position.accuracy.toStringAsFixed(0)} m',
            ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
