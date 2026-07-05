import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../tracking/providers/tracking_provider.dart';
import '../../../safety/presentation/screens/safety_screen.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../../../core/services/location_service.dart';
import '../../providers/map_provider.dart';
import '../widgets/waypoint_dialog.dart';
import '../widgets/map_layer_toggle.dart';

// Explicit imports needed for CircleLayer
import 'package:flutter_map/flutter_map.dart' show CircleLayer, CircleMarker;

enum BaseMap { osm, satellite }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  BaseMap _baseMap = BaseMap.osm;
  String? _lastMobFocus;
  bool _mapReady = false;
  int _tileKey = 0;
  final List<Timer> _tileReloadTimers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final t in _tileReloadTimers) {
      t.cancel();
    }
    super.dispose();
  }

  void _onMapReady() {
    _mapReady = true;
    // Force a fresh TileLayer (all layers, not just the active base map) so
    // tiles load with the final, correct viewport size after the GoRouter
    // enter animation settles. A single fixed delay proved unreliable on
    // slower devices (500ms then 800ms both still left blank tiles on some
    // phones) – retry twice instead of tuning one magic number forever.
    for (final delayMs in [800, 2000]) {
      _tileReloadTimers.add(Timer(Duration(milliseconds: delayMs), () {
        if (!mounted) return;
        setState(() => _tileKey++);
        // Force a camera move so flutter_map actually fires tile requests
        // on devices where the initial layout finishes after onMapReady.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom,
            );
          } catch (_) {}
        });
        _centerIfFollowing();
      }));
    }
  }

  void _centerIfFollowing() {
    if (!_mapReady || !mounted) return;
    final follow = ref.read(mapNotifierProvider).followGps;
    if (!follow) return;
    final pos = LocationService().lastPosition;
    if (pos == null) return;
    try {
      _mapController.move(LatLng(pos.latitude, pos.longitude), _mapController.camera.zoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final followGps = mapState.followGps;
    final showSeamarks = mapState.showSeamarks;
    final previewDayLogId = mapState.previewDayLogId;
    final previewCharterId = mapState.previewCharterId;
    final isPreviewing = previewDayLogId != null || previewCharterId != null;

    ref.watch(positionStreamProvider);
    final waypoints = ref.watch(waypointsProvider);
    final liveTrackPoints = ref.watch(currentTrackProvider);
    final isTracking = ref.watch(isTrackingProvider);
    final mob = ref.watch(mobProvider);
    final anchor = ref.watch(anchorProvider);
    final photoEntries = ref.watch(photoEntryMarkersProvider).valueOrNull ?? [];

    // Nový tracking vždy vyhráva nad prezeraním starej plavby.
    ref.listen<bool>(isTrackingProvider, (prev, next) {
      if (next && (mapState.previewDayLogId != null || mapState.previewCharterId != null)) {
        ref.read(mapNotifierProvider.notifier).clearPreview();
      }
    });

    final List<LatLng> trackPoints;
    if (previewDayLogId != null) {
      trackPoints = ref.watch(dayTrackPreviewProvider(previewDayLogId)).valueOrNull ?? const [];
    } else if (previewCharterId != null) {
      trackPoints = ref.watch(charterTrackPreviewProvider(previewCharterId)).valueOrNull ?? const [];
    } else {
      trackPoints = liveTrackPoints;
    }

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
            ref.read(mapNotifierProvider.notifier).setFollowGps(false);
            _mapController.move(LatLng(lat, lon), 16);
          }
        });
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(43.5, 16.4),
              initialZoom: 10,
              onMapReady: _onMapReady,
              onTap: (_, ll) => _onMapTap(ll),
            ),
            children: [

              // ── Base layer ───────────────────────────────────
              if (_baseMap == BaseMap.osm)
                TileLayer(
                  key: ValueKey('osm_$_tileKey'),
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                ),

              if (_baseMap == BaseMap.satellite) ...[
                // ESRI satelitné snímky
                TileLayer(
                  key: ValueKey('sat_$_tileKey'),
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                ),
                // CartoDB labels navrch - free, bez API kľúča
                TileLayer(
                  key: ValueKey('sat_labels_$_tileKey'),
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                ),
              ],

              // ── OpenSeaMap seamarky (nad satelitom aj OSM) ───
              if (showSeamarks)
                TileLayer(
                  key: ValueKey('seamark_$_tileKey'),
                  urlTemplate:
                      'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 18,
                ),

              // ── GPS track (živý tracking, alebo náhľad zvolenej plavby) ──
              if (trackPoints.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                    points: trackPoints,
                    color: isPreviewing
                        ? Colors.orange.shade700
                        : Colors.blue.shade400,
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

              // ── Kotva: polomer + ikona ───────────────────────────────
              if (anchor.isActive && anchor.anchorLat != null && anchor.anchorLon != null) ...[
                CircleLayer(circles: [
                  CircleMarker(
                    point: LatLng(anchor.anchorLat!, anchor.anchorLon!),
                    radius: anchor.radiusMeters,
                    useRadiusInMeter: true,
                    color: (anchor.isDrifting ? Colors.red : Colors.blue)
                        .withOpacity(0.08),
                    borderColor: anchor.isDrifting
                        ? Colors.red.shade700
                        : Colors.blue.shade600,
                    borderStrokeWidth: 2,
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(anchor.anchorLat!, anchor.anchorLon!),
                    width: 36, height: 36,
                    child: Icon(Icons.anchor,
                        color: anchor.isDrifting
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                        size: 30,
                        shadows: const [Shadow(color: Colors.white, blurRadius: 4)]),
                  ),
                ]),
              ],

              // ── MOB marker ──────────────────────────────────────────
              if (mob.isActive && mob.mobLat != null && mob.mobLon != null)
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(mob.mobLat!, mob.mobLon!),
                    width: 56, height: 56,
                    child: const _MobMarker(),
                  ),
                ]),

              // ── Foto záznamy ─────────────────────────────────────────
              if (photoEntries.isNotEmpty)
                MarkerLayer(markers: [
                  for (final e in photoEntries)
                    if (e.latitude != null && e.longitude != null)
                      Marker(
                        point: LatLng(e.latitude!, e.longitude!),
                        width: 30, height: 30,
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.skipperNote ?? 'Foto záznam'),
                              duration: const Duration(seconds: 2),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
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
                  if (followGps) {
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
                isActive: showSeamarks,
                onToggle: () =>
                    ref.read(mapNotifierProvider.notifier).toggleSeamarks(),
              ),
              const SizedBox(height: 8),
              MapLayerToggle(
                icon: Icons.gps_fixed,
                label: 'GPS',
                isActive: followGps,
                onToggle: () =>
                    ref.read(mapNotifierProvider.notifier).toggleFollowGps(),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'voyagePreview',
                tooltip: 'Prehľad plavby',
                onPressed: () => _openVoyagePicker(context),
                backgroundColor: isPreviewing ? Colors.orange.shade700 : null,
                child: Icon(Icons.route,
                    color: isPreviewing ? Colors.white : null),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'gpxImport',
                tooltip: 'Import GPX',
                onPressed: () => context.push('/gpx-import'),
                child: const Icon(Icons.file_upload_outlined),
              ),
            ]),
          ),

          // ── Banner: prezeranie inej plavby ────────────────────
          if (isPreviewing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 72,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(20),
                color: Colors.orange.shade700,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.route, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(mapState.previewLabel ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    InkWell(
                      onTap: () => ref.read(mapNotifierProvider.notifier).clearPreview(),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ]),
                ),
              ),
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
                  final notifier = ref.read(mapNotifierProvider.notifier);
                  if (followGps) {
                    notifier.setFollowGps(false);
                    return;
                  }
                  final pos = LocationService().lastPosition;
                  if (pos == null) return;
                  notifier.setFollowGps(true);
                  _mapController.move(
                    LatLng(pos.latitude, pos.longitude),
                    _mapController.camera.zoom,
                  );
                },
                backgroundColor: followGps
                    ? Theme.of(context).colorScheme.primary
                    : null,
                child: Icon(
                  Icons.my_location,
                  color: followGps ? Colors.white : null,
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

  void _focusOnPoints(List<LatLng> points) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 14);
      return;
    }
    try {
      _mapController.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(40),
      ));
    } catch (_) {}
  }

  Future<void> _selectDay(int dayLogId, String label, BuildContext sheetContext) async {
    ref.read(mapNotifierProvider.notifier).previewDay(dayLogId, label);
    ref.read(mapNotifierProvider.notifier).setFollowGps(false);
    Navigator.pop(sheetContext);
    final points = await ref.read(dayTrackPreviewProvider(dayLogId).future);
    if (mounted) _focusOnPoints(points);
  }

  Future<void> _selectCharter(int charterId, String label, BuildContext sheetContext) async {
    ref.read(mapNotifierProvider.notifier).previewCharter(charterId, label);
    ref.read(mapNotifierProvider.notifier).setFollowGps(false);
    Navigator.pop(sheetContext);
    final points = await ref.read(charterTrackPreviewProvider(charterId).future);
    if (mounted) _focusOnPoints(points);
  }

  void _openVoyagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scrollCtrl) => Consumer(
          builder: (consumerCtx, sheetRef, __) {
            final chartersAsync = sheetRef.watch(chartersProvider);
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [
                  const Icon(Icons.route),
                  const SizedBox(width: 8),
                  const Text('Prehľad plavby',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.gps_fixed, color: Colors.blue),
                  title: const Text('Naživo (aktuálny tracking)'),
                  onTap: () {
                    ref.read(mapNotifierProvider.notifier).clearPreview();
                    Navigator.pop(sheetCtx);
                  },
                ),
                const Divider(),
                chartersAsync.when(
                  data: (charters) => Column(children: [
                    for (final charter in charters)
                      Consumer(builder: (_, dayRef, __) {
                        final daysAsync = dayRef.watch(dayLogsProvider(charter.id));
                        return daysAsync.when(
                          data: (days) => days.isEmpty
                              ? const SizedBox()
                              : ExpansionTile(
                                  title: Text(charter.title),
                                  subtitle: Text(
                                      '${days.fold<double>(0, (s, d) => s + d.distanceNm).toStringAsFixed(1)} NM · ${days.length} dní'),
                                  children: [
                                    ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.route, size: 20),
                                      title: const Text('Celá plavba',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      onTap: () => _selectCharter(
                                          charter.id, charter.title, sheetCtx),
                                    ),
                                    const Divider(height: 1),
                                    for (final day in days)
                                      ListTile(
                                        dense: true,
                                        title: Text(DateFormat('EEEE d. MMM yyyy', 'sk').format(day.date)),
                                        subtitle: Text('${day.distanceNm.toStringAsFixed(1)} NM'),
                                        onTap: () => _selectDay(
                                            day.id,
                                            '${charter.title} · ${DateFormat('d.M.yyyy').format(day.date)}',
                                            sheetCtx),
                                      ),
                                  ],
                                ),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        );
                      }),
                  ]),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                ),
              ],
            );
          },
        ),
      ),
    );
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
