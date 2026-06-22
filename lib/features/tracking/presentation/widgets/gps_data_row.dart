import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsDataRow extends StatelessWidget {
  final Position position;
  const GpsDataRow({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final lat = position.latitude;
    final lon = position.longitude;
    final course = position.heading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GPS Dáta', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _DataRow(
              icon: Icons.location_on,
              label: 'Poloha',
              value: '${_formatDeg(lat, true)}  ${_formatDeg(lon, false)}',
            ),
            _DataRow(
              icon: Icons.explore,
              label: 'Kurz (COG)',
              value: '${course.toStringAsFixed(0)}°',
            ),
            _DataRow(
              icon: Icons.height,
              label: 'Výška',
              value: '${position.altitude.toStringAsFixed(0)} m',
            ),
            _DataRow(
              icon: Icons.gps_fixed,
              label: 'Presnosť',
              value: '± ${position.accuracy.toStringAsFixed(0)} m',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeg(double deg, bool isLat) {
    final dir = isLat ? (deg >= 0 ? 'N' : 'S') : (deg >= 0 ? 'E' : 'W');
    final abs = deg.abs();
    final d = abs.floor();
    final m = ((abs - d) * 60).toStringAsFixed(3);
    return '$d° ${m}\'$dir';
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
