import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../tracking/providers/tracking_provider.dart';
import '../../../safety/presentation/screens/safety_screen.dart';
import '../../../../core/services/location_service.dart';
import '../../providers/map_provider.dart';
import '../widgets/waypoint_dialog.dart';
import '../widgets/map_layer_toggle.dart';

enum BaseMap { osm, satellite }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  bool _showSeamarks = true;
  bool _followGps = false;
  BaseMap _baseMap = BaseMap.osm;
  LatLng? _lastCentered;
  String? _lastMobFocus;

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionStreamProvider);
    final waypoints = ref.watch(waypointsProvider);
    final trackPoints = ref.watch(currentTrackProvider);
    final isTracking = ref.watch(isTrackingProvider);
    final mob = ref.watch(mobProvider);

    // Centrovanie na MOB pozíciu pri navigácii z MOB karty
    final qp = GoRouterState.of(context).uri.queryParameters;
    final mobLatStr = qp['mob_lat'];
    final mobLonStr = qp['mob_lon'];
    final mobKey = '$mobLatStr,$mobLonStr';
    if (mobLatStr != null && mobLonStr != null && mobKey != _lastMobFocus) {
      _lastMobFocus = mobKey;
      final lat = double.tryParse(mobLatStr);
      final lon = double.tryParse(mobLonStr);
      if (lat != null && lon != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _followGps = false);
            _mapController.move(LatLng(lat, lon), 16);
          }
        });
      }
    }

// GPS follow riadi StreamBuilder vyššie

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(43.5, 16.4),
              initialZoom: 10,
              onTap: (_, ll) => _onMapTap(ll),
            ),
            children: [

              // ── Base layer ───────────────────────────────────
              if (_baseMap == BaseMap.osm)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                ),

              if (_baseMap == BaseMap.satellite) ...[
                // ESRI satelitné snímky
                TileLayer(
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                ),
                // CartoDB labels navrch - free, bez API kľúča
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                ),
              ],

              // ── OpenSeaMap seamarky (nad satelitom aj OSM) ───
              if (_showSeamarks)
                TileLayer(
                  urlTemplate:
                      'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 18,
                ),

              // ── GPS track ────────────────────────────────────
              if (trackPoints.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                    points: trackPoints,
                    color: Colors.blue.shade400,
                    strokeWidth: 3,
                  ),
                ]),

              // ── Waypoints ────────────────────────────────────
              waypoints.when(
                data: (wps) => MarkerLayer(
                  markers: wps.map((wp) => Marker(
                    point: LatLng(wp.latitude, wp.longitude),
                    width: 40, height: 40,
                    child: GestureDetector(
                      onTap: () => _showWaypointInfo(wp.name),
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 36),
                    ),
                  )).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),

              // ── MOB marker ──────────────────────────────────────────
              if (mob.isActive && mob.mobLat != null && mob.mobLon != null)
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(mob.mobLat!, mob.mobLon!),
                    width: 56, height: 56,
                    child: const _MobMarker(),
                  ),
                ]),

              // ── GPS pozícia ──────────────────────────────────
              // GPS marker - vždy aktívny cez LocationService
              StreamBuilder<Position>(
                stream: LocationService().stream,
                builder: (ctx, snap) {
                  final pos = snap.data ?? LocationService().lastPosition;
                  if (pos == null) return const MarkerLayer(markers: []);
                  // Follow GPS ak je zapnuté
                  if (_followGps) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      try {
                        _mapController.move(
                          LatLng(pos.latitude, pos.longitude),
                          _mapController.camera.zoom,
                        );
                      } catch (_) {}
                    });
                  }
                  return MarkerLayer(markers: [
                    Marker(
                      point: LatLng(pos.latitude, pos.longitude),
                      width: 50, height: 50,
                      child: _GpsMarker(heading: pos.heading, isTracking: isTracking),
                    ),
                  ]);
                },
              ),
            ],
          ),

          // ── Ovládacie prvky ──────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Column(children: [
              // Prepínač mapa / satelit
              _MapTypeButton(
                current: _baseMap,
                onChanged: (v) => setState(() => _baseMap = v),
              ),
              const SizedBox(height: 8),
              MapLayerToggle(
                icon: Icons.anchor,
                label: 'Seamarky',
                isActive: _showSeamarks,
                onToggle: () => setState(() => _showSeamarks = !_showSeamarks),
              ),
              const SizedBox(height: 8),
              MapLayerToggle(
                icon: Icons.gps_fixed,
                label: 'GPS',
                isActive: _followGps,
                onToggle: () => setState(() => _followGps = !_followGps),
              ),
            ]),
          ),

          // ── Zoom + Current position ───────────────────────────
          Positioned(
            bottom: 100,
            right: 12,
            child: Column(children: [
              FloatingActionButton.small(
                heroTag: 'zi',
                onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zo',
                onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1),
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 16),
              FloatingActionButton.small(
                heroTag: 'cp',
                onPressed: () {
                  if (_followGps) {
                    setState(() => _followGps = false);
                    return;
                  }
                  final pos = LocationService().lastPosition;
                  if (pos == null) return;
                  setState(() => _followGps = true);
                  _mapController.move(
                    LatLng(pos.latitude, pos.longitude),
                    _mapController.camera.zoom,
                  );
                },
                backgroundColor: _followGps
                    ? Theme.of(context).colorScheme.primary
                    : null,
                child: Icon(
                  Icons.my_location,
                  color: _followGps ? Colors.white : null,
                ),
              ),
            ]),
          ),

          // ── Attribution ──────────────────────────────────────
          if (_baseMap == BaseMap.satellite)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white.withOpacity(0.7),
                child: const Text(
                  'Tiles © Esri — Esri, DigitalGlobe, GeoEye, i-cubed, USDA FSA, USGS, '
                  'AEX, Getmapping, Aerogrid, IGN, IGP, swisstopo',
                  style: TextStyle(fontSize: 8, color: Colors.black54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTap(LatLng ll) {
    showModalBottomSheet(
      context: context,
      builder: (_) => WaypointDialog(latLng: ll),
    );
  }

  void _showWaypointInfo(String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Waypoint: $name')));
  }
}

// ── Map Type Button ───────────────────────────────────────────

class _MapTypeButton extends StatelessWidget {
  final BaseMap current;
  final Function(BaseMap) onChanged;
  const _MapTypeButton({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        children: [
          _Btn(
            icon: Icons.map,
            label: 'Mapa',
            active: current == BaseMap.osm,
            onTap: () => onChanged(BaseMap.osm),
            top: true,
          ),
          const Divider(height: 1),
          _Btn(
            icon: Icons.satellite_alt,
            label: 'Satelit',
            active: current == BaseMap.satellite,
            onTap: () => onChanged(BaseMap.satellite),
            top: false,
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool top;
  const _Btn({required this.icon, required this.label,
      required this.active, required this.onTap, required this.top});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.vertical(
        top: top ? const Radius.circular(8) : Radius.zero,
        bottom: !top ? const Radius.circular(8) : Radius.zero),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.white,
        borderRadius: BorderRadius.vertical(
            top: top ? const Radius.circular(8) : Radius.zero,
            bottom: !top ? const Radius.circular(8) : Radius.zero),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 20,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600),
        Text(label, style: TextStyle(
            fontSize: 10,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600)),
      ]),
    ),
  );
}

// ── MOB Marker ───────────────────────────────────────────────

class _MobMarker extends StatefulWidget {
  const _MobMarker();
  @override
  State<_MobMarker> createState() => _MobMarkerState();
}

class _MobMarkerState extends State<_MobMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Stack(alignment: Alignment.center, children: [
        Container(
          width: 56 * _pulse.value,
          height: 56 * _pulse.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.25 * _pulse.value),
          ),
        ),
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
          ),
          child: const Icon(Icons.person_off, color: Colors.white, size: 14),
        ),
      ]),
    );
  }
}

// ── GPS Marker ────────────────────────────────────────────────

class _GpsMarker extends StatelessWidget {
  final double heading;
  final bool isTracking;
  const _GpsMarker({required this.heading, required this.isTracking});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: heading * 3.14159 / 180,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isTracking ? Colors.green : Colors.blue).withOpacity(0.3),
          border: Border.all(
              color: isTracking ? Colors.green : Colors.blue, width: 2),
        ),
        child: Icon(Icons.navigation,
            color: isTracking ? Colors.green : Colors.blue, size: 28),
      ),
    );
  }
}
