import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

import '../../../../core/services/ocean_current_service.dart';

/// Prúd pre aktuálnu polohu. Rodič prekreslí kartu zmenou súradníc.
final oceanCurrentProvider = FutureProvider.autoDispose
    .family<List<SeaCurrentPoint>, ({double lat, double lon})>((ref, pos) {
  return OceanCurrentService()
      .fetchForecast(lat: pos.lat, lon: pos.lon)
      .catchError((_) => <SeaCurrentPoint>[]);
});

/// Karta morského prúdu — reálna predpoveď pre polohu (Open-Meteo Marine),
/// na rozdiel od curated globálnych prúdov v referenčnej obrazovke.
/// Rýchlosti sú v uzloch, smer je oceánografický (KAM prúd tečie).
class OceanCurrentCard extends ConsumerWidget {
  final double? lat;
  final double? lon;
  const OceanCurrentCard({super.key, required this.lat, required this.lon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.moving, size: 18, color: Colors.teal),
              const SizedBox(width: 6),
              Text(l.oceanCurrentCardTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            if (lat == null || lon == null)
              _hint(l.noSunMoonGps)
            else
              ref.watch(oceanCurrentProvider((lat: lat!, lon: lon!))).when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => _hint(l.oceanCurrentUnavailable),
                    data: (points) => points.isEmpty
                        ? _hint(l.oceanCurrentNoCoverage)
                        : _Body(points: points),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child:
            Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      );
}

class _Body extends StatelessWidget {
  final List<SeaCurrentPoint> points;
  const _Body({required this.points});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final current = OceanCurrentService.nearestTo(points, now);
    if (current == null) return const SizedBox.shrink();

    // Niekoľko nasledujúcich hodín — prúd sa v úžinách mení dosť na to,
    // aby to stálo za pohľad pri plánovaní odchodu.
    final upcoming = points
        .where((p) => p.time != null && p.time!.isAfter(now.toUtc()))
        .take(6)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(children: [
          _CurrentArrow(dirDeg: current.dirDeg, speedKn: current.speedKn),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${current.speedKn.toStringAsFixed(1)} kt  '
                  '${_compass(current.dirDeg)} ${current.dirDeg.round()}°',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(l.oceanCurrentSetsToward,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ]),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final p = upcoming[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(DateFormat.Hm().format(p.time!.toLocal()),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Transform.rotate(
                      angle: p.dirDeg * math.pi / 180,
                      child: Icon(Icons.navigation,
                          size: 16, color: _speedColor(p.speedKn)),
                    ),
                    const SizedBox(height: 2),
                    Text(p.speedKn.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _speedColor(p.speedKn))),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Prúdy sú rádovo slabšie než vietor, takže prahy sú v desatinách uzla.
Color _speedColor(double kn) => kn < 0.5
    ? Colors.green.shade600
    : kn < 1.5
        ? Colors.teal.shade600
        : kn < 3
            ? Colors.orange.shade800
            : Colors.red.shade700;

String _compass(double deg) {
  const names = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return names[(((deg % 360) + 22.5) ~/ 45) % 8];
}

class _CurrentArrow extends StatelessWidget {
  final double dirDeg;
  final double speedKn;
  const _CurrentArrow({required this.dirDeg, required this.speedKn});

  @override
  Widget build(BuildContext context) {
    final color = _speedColor(speedKn);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      // Oceánografická konvencia: smer je KAM prúd tečie, takže sa šípka
      // (ktorá v 0° mieri hore/na sever) otáča priamo o dirDeg.
      child: Transform.rotate(
        angle: dirDeg * math.pi / 180,
        child: Icon(Icons.navigation, color: color, size: 24),
      ),
    );
  }
}
