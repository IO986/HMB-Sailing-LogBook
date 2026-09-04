import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import '../../../../core/database/app_database.dart';
import '../../../../core/services/tile_cache.dart';

/// Ohraničenie výrezu s okolím, nie tesne cez trasu.
///
/// Výrez presne cez krajné body trasy je pri celodennej plavbe v poriadku, ale
/// deň strávený na jednom mieste vyjde ako pár desiatok metrov — z terénu
/// prišiel záber, kde v PDF vidno strechy a nie, kde loď bola. Preto:
///
/// * rozpätie sa rozšíri o pätinu na každú stranu, aby bolo vidieť, čo je
///   okolo trasy;
/// * a vynúti sa minimálne okno [minSpanKm], ktoré rieši bodovú trasu — bez
///   neho by z nej ani dvadsať percent z nuly nespravilo nič.
///
/// Zemepisná dĺžka sa škáluje cez `cos(lat)`, inak by okno na severe bolo
/// v kilometroch užšie, než sa žiada.
LatLngBounds contextBounds(List<LatLng> points, {double minSpanKm = 1.0}) {
  final minLat = points.map((p) => p.latitude).reduce(min);
  final maxLat = points.map((p) => p.latitude).reduce(max);
  final minLon = points.map((p) => p.longitude).reduce(min);
  final maxLon = points.map((p) => p.longitude).reduce(max);

  const kmPerDegreeLat = 110.574;
  final midLat = (minLat + maxLat) / 2;
  final kmPerDegreeLon = 111.320 * cos(midLat * pi / 180);

  final minLatSpan = minSpanKm / kmPerDegreeLat;
  final minLonSpan =
      kmPerDegreeLon.abs() < 1e-6 ? minLatSpan : minSpanKm / kmPerDegreeLon;

  final latSpan = max((maxLat - minLat) * 1.2, minLatSpan);
  final lonSpan = max((maxLon - minLon) * 1.2, minLonSpan);
  final midLon = (minLon + maxLon) / 2;

  return LatLngBounds(
    LatLng(midLat - latSpan / 2, midLon - lonSpan / 2),
    LatLng(midLat + latSpan / 2, midLon + lonSpan / 2),
  );
}

/// The day's track rendered as a map — pulled out of `export_screen.dart`'s
/// `_DayMapPreview` (`docs/plan_cloud_export.md` §3) so the foreground
/// export screen and a future headless auto-export path render the exact
/// same widget. The foreground path wraps this in a `Screenshot` ancestor
/// and calls `.capture()`; the headless path renders it off the widget tree
/// via `ScreenshotController.captureFromWidget(...)` — this widget itself
/// doesn't know or care which.
class DayMapView extends StatelessWidget {
  const DayMapView({
    super.key,
    required this.trackPoints,
    this.satellite = true,
    this.tileProviderBuilder = CachingTileProvider.new,
  });

  final List<TrackPoint> trackPoints;

  /// Podklad výrezu: satelitná snímka, alebo bežná mapa.
  ///
  /// Satelit ukazuje, ako to na mieste vyzerá; mapa ukazuje mená, cesty
  /// a hĺbky. Ktorý z nich patrí do dokladu, vie len ten, kto ho odovzdáva,
  /// takže si vyberá pred exportom.
  final bool satellite;

  /// Builds the `TileProvider` for a given layer id — defaults to the real
  /// disk-cached provider. Tests override this with a fake that never
  /// touches the network, since `captureFromWidget` in a `testWidgets`
  /// sandbox has none and a real `TileProvider` just hangs forever waiting
  /// on it (see test/export/day_map_view_test.dart).
  final TileProvider Function(String layerId) tileProviderBuilder;

  @override
  Widget build(BuildContext context) {
    // Grouped by session to avoid a phantom line joining two separate
    // sailing sessions on the same day.
    final bySession = <String, List<LatLng>>{};
    for (final tp in trackPoints) {
      final sid = tp.sessionId ?? '_';
      bySession.putIfAbsent(sid, () => []).add(LatLng(tp.latitude, tp.longitude));
    }

    final allPoints = trackPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

    var center = const LatLng(43.5, 16.4);
    CameraFit? cameraFit;
    if (allPoints.isNotEmpty) {
      final avgLat = allPoints.map((p) => p.latitude).reduce((a, b) => a + b) / allPoints.length;
      final avgLon = allPoints.map((p) => p.longitude).reduce((a, b) => a + b) / allPoints.length;
      center = LatLng(avgLat, avgLon);

      cameraFit = CameraFit.bounds(
        bounds: contextBounds(allPoints),
        padding: const EdgeInsets.all(28),
        maxZoom: 14,
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 10.0,
        initialCameraFit: cameraFit,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: satellite
              ? 'https://server.arcgisonline.com/ArcGIS/rest/services/'
                  'World_Imagery/MapServer/tile/{z}/{y}/{x}'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.hmb.sailinglog',
          // Same layerIds as the interactive map's layers (map_screen.dart) —
          // a day's tiles are very likely already cached from ordinary map
          // browsing during the sail, and any area viewed there benefits this
          // preview too.
          tileProvider: tileProviderBuilder(satellite ? 'satellite' : 'osm'),
          // This widget only ever exists to be screenshotted (foreground
          // preview or headless captureFromWidget) — a fade-in animation
          // has nothing to animate towards. It also left dangling
          // AnimationControllers past widget disposal in
          // captureFromWidget's off-tree render, which the scheduler flags
          // as a leak (see test/export/day_map_view_test.dart).
          tileDisplay: const TileDisplay.instantaneous(),
        ),
        TileLayer(
          urlTemplate: 'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.hmb.sailinglog',
          tileProvider: tileProviderBuilder('seamark'),
          tileDisplay: const TileDisplay.instantaneous(),
        ),
        if (bySession.isNotEmpty)
          PolylineLayer(polylines: [
            for (final pts in bySession.values)
              if (pts.length >= 2) Polyline(points: pts, color: Colors.yellow, strokeWidth: 3),
          ]),
        if (allPoints.isNotEmpty)
          MarkerLayer(markers: [
            Marker(
              point: allPoints.first,
              width: 20,
              height: 20,
              child: Container(
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 14),
              ),
            ),
            Marker(
              point: allPoints.last,
              width: 20,
              height: 20,
              child: Container(
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.stop, color: Colors.white, size: 14),
              ),
            ),
          ]),
      ],
    );
  }
}
