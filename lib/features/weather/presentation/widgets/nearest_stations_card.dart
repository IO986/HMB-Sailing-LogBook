import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import '../../../../core/services/dhmz_observation_service.dart';
import '../../../../core/services/metar_observation_service.dart';
import '../../../../core/services/station_observation.dart';
import '../../../../core/services/units_service.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/utils/localized_date.dart';
import '../../../../core/utils/wind_scale.dart';
import '../../../../main.dart';

/// Najbližšie merané stanice k danej polohe, od najbližšej.
final nearestStationsProvider = FutureProvider.autoDispose
    .family<List<StationObservation>, ({double lat, double lon})>(
        (ref, pos) async {
  final db = ref.watch(databaseProvider);

  // Rovnaký vzor ako na mape: obe siete naraz, žiadna z nich nie je podmienka.
  // Zhruba stupeň na každú stranu — pri väčšom okolí by už stanica o polohe
  // lode nehovorila nič.
  final bounds = LatLngBounds(
    LatLng(pos.lat - 1.0, pos.lon - 1.0),
    LatLng(pos.lat + 1.0, pos.lon + 1.0),
  );
  final metarFuture = MetarObservationService().fetchForBounds(bounds);
  final dhmzSync = DhmzObservationService().sync();

  var cached = await db.getDhmzObservations();
  if (cached.isEmpty) {
    await dhmzSync;
    cached = await db.getDhmzObservations();
  }

  final merged = mergeObservations(
    primary: [
      for (final o in cached)
        if (o.windSpeedKnots != null) StationObservation.fromDhmz(o),
    ],
    secondary: [
      for (final o in await metarFuture)
        if (o.windSpeedKnots != null) o,
    ],
    maxAge: DhmzObservationService.maxAge,
  );

  merged.sort((a, b) => DistanceCalculator.distanceM(
          pos.lat, pos.lon, a.latitude, a.longitude)
      .compareTo(DistanceCalculator.distanceM(
          pos.lat, pos.lon, b.latitude, b.longitude)));
  return merged.take(4).toList();
});

/// Čo naozaj niekto nameral, na rozdiel od zvyšku tabu.
///
/// Stojí hneď pod aktuálnym počasím zámerne: model a meranie sa vedia líšiť aj
/// o polovicu (pri Biograde model 14 kt proti nameraným 6–10) a jediný spôsob,
/// ako to skiper zistí, je vidieť oboje vedľa seba.
///
/// Vzdialenosť a čas merania sú súčasťou údaja, nie ozdobou: stanica meria
/// presne, ale inde a vtedy.
class NearestStationsCard extends ConsumerWidget {
  const NearestStationsCard({super.key, required this.lat, required this.lon});

  final double? lat;
  final double? lon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (lat == null || lon == null) return const SizedBox.shrink();

    final stations =
        ref.watch(nearestStationsProvider((lat: lat!, lon: lon!))).valueOrNull;
    if (stations == null || stations.isEmpty) return const SizedBox.shrink();

    final units = ref.watch(unitsSyncProvider);
    final date = AppDate.of(context, ref);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.sensors, size: 18),
              const SizedBox(width: 6),
              Text(l.mapStationWindLayer,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            for (final s in stations) ...[
              _StationRow(
                station: s,
                distanceNm: DistanceCalculator.distanceNm(
                    lat!, lon!, s.latitude, s.longitude),
                units: units,
                date: date,
              ),
              if (s != stations.last) const Divider(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({
    required this.station,
    required this.distanceNm,
    required this.units,
    required this.date,
  });

  final StationObservation station;
  final double distanceNm;
  final UnitsSettings units;
  final AppDate date;

  @override
  Widget build(BuildContext context) {
    final kn = station.windSpeedKnots ?? 0;
    final gust = station.gustKnots;
    final hint = Theme.of(context).hintColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.circle, size: 10, color: windColor(kn)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(station.station,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${units.formatDistance(distanceNm, decimals: 1)} · '
                '${date.shortWithTime(station.observedAt.toLocal())} · '
                '${station.source.label}',
                style: TextStyle(fontSize: 11, color: hint),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              gust == null
                  ? units.formatSpeed(kn, decimals: 0)
                  : '${units.speedValue(kn).toStringAsFixed(0)}/'
                      '${units.formatSpeed(gust, decimals: 0)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: windColor(kn)),
            ),
            if (station.windDirectionDeg != null)
              Text('${station.windDirectionDeg!.round()}°',
                  style: TextStyle(fontSize: 11, color: hint)),
          ],
        ),
      ],
    );
  }
}
