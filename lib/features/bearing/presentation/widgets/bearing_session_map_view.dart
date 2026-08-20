/// Statická mapka jednej relácie zameraní — pre PDF snímku aj náhľad pred
/// exportom.
///
/// Kreslí presne tie isté vrstvy ako interaktívna mapa (`buildBearingLayers`
/// z `bearing_layers.dart`), len bez ovládania: kamera je zarámovaná na
/// obsah, gestá vypnuté. To isté zarovnanie použil `DayMapView` pre trasu
/// dňa — táto trieda je jeho obdoba pre zamerania.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/tile_cache.dart';
import '../../../../l10n/app_localizations.dart';
import '../../services/bearing_geometry.dart';
import '../../providers/bearing_provider.dart'
    show SightGroup, bearingLineOf;
import 'bearing_layers.dart';

class BearingSessionMapView extends StatelessWidget {
  const BearingSessionMapView({
    super.key,
    required this.bearings,
    required this.resectionFix,
    required this.sightGroups,
    required this.l,
    this.tileProviderBuilder = CachingTileProvider.new,
  });

  final List<Bearing> bearings;
  final BearingFix? resectionFix;
  final List<SightGroup> sightGroups;
  final AppLocalizations l;

  /// Rovnaký dôvod ako v `DayMapView`: testy si sem podstrčia falošný
  /// poskytovateľ dlaždíc, aby `captureFromWidget` v sandboxe bez siete
  /// nečakalo naveky na skutočný.
  final TileProvider Function(String layerId) tileProviderBuilder;

  @override
  Widget build(BuildContext context) {
    // Zámerne LEN body a fixy, nie vzdialené konce kužeľov: kužeľ sa kreslí
    // na kBearingLineLengthNm (50 NM), a keby sa kamera naťahovala na jeho
    // celú dĺžku, výsek by bol skoro prázdny — zaujímavá časť je vždy len
    // okolo bodov a vypočítanej polohy. Kužele naďalej idú z bodov von, len
    // sa väčšinou orežú mimo viditeľný výsek, presne ako na papierovej mape.
    final points = <LatLng>[];
    for (final b in bearings) {
      final line = bearingLineOf(b);
      if (line == null) continue;
      points.add(line.origin);
    }
    if (resectionFix != null) points.add(resectionFix!.position);
    for (final g in sightGroups) {
      if (g.fix != null) points.add(g.fix!.position);
    }

    var center = const LatLng(43.5, 16.4);
    CameraFit? cameraFit;
    if (points.isNotEmpty) {
      final avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) /
          points.length;
      final avgLon = points.map((p) => p.longitude).reduce((a, b) => a + b) /
          points.length;
      center = LatLng(avgLat, avgLon);

      final minLat = points.map((p) => p.latitude).reduce(min);
      final maxLat = points.map((p) => p.latitude).reduce(max);
      final minLon = points.map((p) => p.longitude).reduce(min);
      final maxLon = points.map((p) => p.longitude).reduce(max);
      cameraFit = CameraFit.bounds(
        bounds: LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon)),
        padding: const EdgeInsets.all(28),
        maxZoom: 13,
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
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/'
              'World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.hmb.sailinglog',
          tileProvider: tileProviderBuilder('satellite'),
          tileDisplay: const TileDisplay.instantaneous(),
        ),
        // Satelitná snímka sama o sebe nenesie názvy — bez tejto vrstvy
        // mapka nemala žiadny opytný bod (mesto, obec), podľa ktorého by sa
        // dalo zorientovať. Tá istá vrstva ako na interaktívnej mape.
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.hmb.sailinglog',
          tileProvider: tileProviderBuilder('satellite_labels'),
          tileDisplay: const TileDisplay.instantaneous(),
        ),
        ...buildBearingLayers(
          bearings: bearings,
          resectionFix: resectionFix,
          sightGroups: sightGroups,
          l: l,
          onTapBearing: (_) {},
          onTapSightGroup: (_) {},
        ),
      ],
    );
  }
}
