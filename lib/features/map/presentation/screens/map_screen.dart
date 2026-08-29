import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import '../../../../core/providers/night_mode_provider.dart';
import '../../../tracking/providers/tracking_provider.dart';
import '../../../safety/presentation/screens/safety_screen.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/marine_poi_service.dart';
import '../../../../core/services/depth_probe_service.dart';
import '../../../../core/services/tile_cache.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/models/bearing_kind.dart';
import '../../../bearing/presentation/widgets/bearing_layers.dart';
import '../../../bearing/providers/bearing_provider.dart';
import '../../providers/map_provider.dart';
import '../widgets/marine_poi_sheet.dart';
import '../widgets/waypoint_dialog.dart';

// Explicit imports needed for CircleLayer
import 'package:flutter_map/flutter_map.dart'
    show CircleLayer, CircleMarker, Polygon, PolygonLayer;
import '../../../../core/services/units_service.dart';
import '../../../../core/utils/geo_polygon.dart';
import '../../../../core/utils/localized_date.dart';
import '../widgets/playback_bar.dart';
import '../../providers/playback_provider.dart';
import '../../services/track_playback.dart';

/// Ktorá skupina tlačidiel je rozbalená v pravom paneli. Dvanásť tlačidiel
/// naraz sa na displej nezmestilo, takže sú v dvoch skupinách a rozbalená
/// môže byť vždy len jedna.
enum _MapPanel { none, layers, tools }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  String? _lastMobFocus;
  bool _mapReady = false;
  int _tileKey = 0;
  final List<Timer> _tileReloadTimers = [];
  Timer? _poiDebounce;

  // Pod týmto zoomom POI nesťahujeme — bbox by bol príliš veľký.
  static const _poiMinZoom = 9.0;

  // Pravítko / plánovanie trasy: body ťukané na mapu (so snapom na
  // existujúce waypointy), súčet NM, kurz poslednej nohy, ETA pri SOG.
  bool _rulerActive = false;

  /// Beží dotaz na hĺbku — druhé ťuknutie sa ignoruje, kým sa nevráti.
  bool _depthProbing = false;
  final List<LatLng> _rulerPoints = [];

  // Kreslenie kotevnej plochy: rohy ťukané na mapu, bez snapu na waypointy
  // (na rozdiel od pravítka — plocha, kam smie loď zatáčať, nemá dôvod
  // prichytiť sa na uložený bod o tridsať pixelov vedľa).
  bool _zoneActive = false;
  final List<LatLng> _zonePoints = [];

  /// Viac rohov už nie je presnosť, ale neprehľadnosť — a `contains` beží
  /// pri každom GPS fixe.
  static const _zoneMaxPoints = 20;

  _MapPanel _openPanel = _MapPanel.none;

  // Rotácia mapy (dvoma prstami) — kompas hore ju resetne späť na north-up.
  //
  // ValueNotifier, nie plain double + setState: `onPositionChanged` volá
  // toto pri takmer každom framey posunu/zoomu — pri štípaní dvoma prstami
  // takmer vždy zachytí aj nepatrnú rotáciu. `setState` na celej
  // `_MapScreenState` (dlaždice, markery, FAB stĺpce, playback bar) pri
  // KAŽDOM takom frame bolo presne to, čo appku pri zoome sekalo.
  // ValueNotifier prekreslí len tie dva widgety nižšie, čo naň naozaj
  // počúvajú (kompas a šípka lode pri prehrávaní).
  final _mapRotation = ValueNotifier<double>(0);

  /// Programový posun mapy práve prebieha (sledovanie GPS, alebo vynútené
  /// prekreslenie dlaždíc po vstupe na obrazovku).
  ///
  /// Čisto obranné: `MapController.move()` v tejto verzii flutter_map vždy
  /// posiela `hasGesture: false`, takže tento posun by `followGps` sám
  /// nemal vypnúť. Skutočná príčina hláseného "pri prepnutí sa pozícia
  /// nedrží" bola inde — `initState` nižšie, kde sa `/map` pri každom
  /// prekliku z inej karty vytvára úplne odznova (obyčajná `ShellRoute`,
  /// nedrží stav) a dovtedy štartoval natvrdo v Splite. Táto vlajka
  /// zostáva ako lacná poistka pre prípad, že sa správanie flutter_map
  /// niekedy zmení.
  bool _programmaticMoveInFlight = false;

  void _moveMapProgrammatically(LatLng target, double zoom) {
    _programmaticMoveInFlight = true;
    try {
      _mapController.move(target, zoom);
    } finally {
      // onPositionChanged z tohto move() prichádza synchrónne v rámci
      // move() samotného; mikroúloha po ňom nechá vlajku padnúť skôr, než
      // príde ĎALŠIE, tentoraz skutočné gesto.
      scheduleMicrotask(() => _programmaticMoveInFlight = false);
    }
  }
  // Lock na sever (podržanie ružice vypne gesto rotácie) je teraz uchovaný
  // user setting v mapNotifierProvider (`northLocked`), nie lokálny stav —
  // prežije reštart appky aj odchod z obrazovky mapy.

  /// Stred a zoom, s ktorými sa mapa prvýkrát vykreslí.
  ///
  /// `/map` je obyčajná `ShellRoute`, nie `StatefulShellRoute` — pri
  /// prepnutí na inú kartu a späť sa `MapScreen` zakaždým vytvorí nanovo,
  /// nedrží si stav. Bez tohto by `initialCenter` bol napevno Split a mapa
  /// by sa tam na chvíľu (kým nedobehne `_onMapReady`) vrátila pri KAŽDOM
  /// prekliku — presne to bolo hlásené ako "pri prepnutí sa pozícia
  /// nedrží". Namiesto čakania na dobehnutie časovača sa rovno štartuje
  /// tam, kde appka vie, že loď naposledy bola.
  late final LatLng _initialCenter;
  late final double _initialZoom;

  @override
  void initState() {
    super.initState();
    // Kým je mapa otvorená, marker vlastnej lode sa hýbe pred očami —
    // idle režim (50 m / 15 s) by ho viditeľne trhal.
    LocationService().requestPrecise(this);
    // Nezávisle od `followGps`: ten prepínač rozhoduje, či mapa BEŽÍ za
    // GPS, kým je otvorená (obnovuje stred pri každom novom bode). O tom,
    // ODKIAĽ mapa pri otvorení štartuje, sa nemá čo starať — nikto
    // nečaká, že mu appka po vypnutí sledovania začne ukazovať Split
    // namiesto toho, kde skutočne je.
    final pos = LocationService().lastPosition;
    debugPrint(
        '[MAP] initState: lastPosition=${pos == null ? 'null' : '${pos.latitude},${pos.longitude}'} '
        'followGps=${ref.read(mapNotifierProvider).followGps}');
    if (pos != null) {
      _initialCenter = LatLng(pos.latitude, pos.longitude);
      _initialZoom = 13;
    } else {
      _initialCenter = const LatLng(43.5, 16.4);
      _initialZoom = 10;
    }
  }

  @override
  void dispose() {
    LocationService().releasePrecise(this);
    for (final t in _tileReloadTimers) {
      t.cancel();
    }
    _poiDebounce?.cancel();
    _mapRotation.dispose();
    super.dispose();
  }

  /// Debounced aktualizácia viditeľného výrezu pre POI vrstvu — až keď sa
  /// mapa na chvíľu ustáli, nie počas každého frame posunu.
  void _schedulePoiRefresh() {
    final st = ref.read(mapNotifierProvider);
    if (!st.showMarinePois) return;
    _poiDebounce?.cancel();
    _poiDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted || !_mapReady) return;
      final camera = _mapController.camera;
      // Pod minimálnym zoomom sa POI neťahajú — služba kešuje po bunkách a
      // pri pohľade na pol Európy by ich bolo treba tisíce.
      if (camera.zoom < _poiMinZoom) return;
      ref.read(mapViewBoundsProvider.notifier).state = camera.visibleBounds;
    });
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
            _moveMapProgrammatically(
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
    debugPrint('[MAP] _centerIfFollowing: mapReady=$_mapReady follow=$follow '
        'lastPosition=${LocationService().lastPosition == null ? 'null' : 'set'}');
    if (!follow) return;
    final pos = LocationService().lastPosition;
    if (pos == null) return;
    try {
      _moveMapProgrammatically(
          LatLng(pos.latitude, pos.longitude), _mapController.camera.zoom);
    } catch (_) {}
  }

  void _showBearingSheet(Bearing bearing) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final photo = bearing.photoPath;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bearing.targetName?.isNotEmpty == true
                      ? bearing.targetName!
                      : (bearing.label?.isNotEmpty == true
                          ? bearing.label!
                          : l.bearingsTitle),
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                Text(
                  BearingKind.fromCode(bearing.kind) == BearingKind.resection
                      ? l.bearingResectionSection
                      : l.bearingObjectSection,
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                if (photo != null && File(photo).existsSync()) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(photo),
                        height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                ],
                _bearingDetailRow(
                    l.bearingPdfBearing,
                    '${_formatDegrees(bearing.trueBearing)} '
                    '(${l.bearingTrueLabel})'),
                _bearingDetailRow(l.bearingMagneticLabel,
                    _formatDegrees(bearing.magneticBearing)),
                _bearingDetailRow(
                    l.bearingDeclinationApplied(
                        _formatSignedDegrees(bearing.declination)),
                    ''),
                _bearingDetailRow(l.timeCol,
                    AppDate.of(context, ref).shortWithTime(bearing.takenAt)),
                // Pri resekcii bez GPS poloha pozorovateľa neexistuje —
                // je to práve to hľadané, nie chýbajúci údaj.
                if (bearing.observerLat != null && bearing.observerLon != null)
                  _bearingDetailRow(
                      l.gpsPosition,
                      '${bearing.observerLat!.toStringAsFixed(5)}, '
                      '${bearing.observerLon!.toStringAsFixed(5)}'),
                if (bearing.targetLat != null && bearing.targetLon != null)
                  _bearingDetailRow(
                      l.bearingPdfMark,
                      '${bearing.targetLat!.toStringAsFixed(5)}, '
                      '${bearing.targetLon!.toStringAsFixed(5)}'),
                const SizedBox(height: 4),
                Text(
                  l.bearingUncertaintyNote(
                      '${bearing.uncertaintyDeg.round()}°'),
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                if (bearing.declinationSource == 'target')
                  Text(
                    l.bearingDeclinationFromTarget,
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      // Skryje z mapy, nezmaže: záznam zostáva v denníku a
                      // v PDF. Skutočné zmazanie je len tam.
                      await ref
                          .read(bearingRepositoryProvider)
                          .hideFromMap(bearing.id);
                    },
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: Text(l.bearingHideFromMap),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bearingDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
            if (value.isNotEmpty) Text(value),
          ],
        ),
      );

  /// Detail vytriangulovaného neznámeho bodu — a hlavne cesta, ako z neho
  /// urobiť waypoint. Bez toho by celé pátranie skončilo čiarou na mape.
  void _showSightGroupSheet(SightGroup group) {
    final l = AppLocalizations.of(context);
    final fix = group.fix;
    if (fix == null) return;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name.isEmpty ? l.bearingObjectFix : group.name,
                  style: Theme.of(sheetContext).textTheme.titleMedium),
              Text(l.bearingObjectSection,
                  style: Theme.of(sheetContext).textTheme.bodySmall),
              const SizedBox(height: 12),
              _bearingDetailRow(
                  l.gpsPosition,
                  '${fix.position.latitude.toStringAsFixed(5)}, '
                  '${fix.position.longitude.toStringAsFixed(5)}'),
              _bearingDetailRow(l.bearingSightCount(group.bearings.length),
                  '±${fix.errorRadiusMeters.round()} m'),
              if (fix.isWeak)
                _bearingDetailRow(
                    l.bearingFixWeak('${fix.cutAngleDeg.round()}°'), ''),
              if (group.baselineTooShort)
                Text(l.bearingShortBaselineHint,
                    style: Theme.of(sheetContext).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      final name =
                          group.name.isEmpty ? l.bearingObjectFix : group.name;
                      await ref
                          .read(bearingRepositoryProvider)
                          .saveFixAsWaypoint(
                            name: name,
                            position: fix.position,
                            description: l.bearingObjectSection,
                          );
                      ref.invalidate(waypointsProvider);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.bearingObjectSaved(name))));
                    },
                    icon: const Icon(Icons.add_location_alt),
                    label: Text(l.bearingSaveObjectAsWaypoint),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    // Skryje z mapy, nezmaže — rovnaký dôvod ako pri
                    // jednotlivom zameraní.
                    await ref
                        .read(bearingRepositoryProvider)
                        .hideGroupFromMap(group.id);
                  },
                  icon: const Icon(Icons.visibility_off_outlined),
                  tooltip: l.bearingHideFromMap,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDegrees(double value) =>
      '${(value.round() % 360).toString().padLeft(3, '0')}°';

  static String _formatSignedDegrees(double value) =>
      '${value >= 0 ? '+' : '-'}${value.abs().toStringAsFixed(1)}°';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mapState = ref.watch(mapNotifierProvider);
    final followGps = mapState.followGps;
    final baseMap = mapState.baseMap;
    final showSeamarks = mapState.showSeamarks;
    final showBathymetry = mapState.showBathymetry;
    final previewDayLogId = mapState.previewDayLogId;
    final previewCharterId = mapState.previewCharterId;
    final isPreviewing = previewDayLogId != null || previewCharterId != null;

    ref.watch(positionStreamProvider);
    final waypoints = ref.watch(waypointsProvider);
    final liveTrackPoints = ref.watch(currentTrackProvider);
    final isTracking = ref.watch(isTrackingProvider);
    final mob = ref.watch(mobProvider);
    final anchor = ref.watch(anchorProvider);
    // Pokyn z karty Kotva: otvor mapu rovno v kreslení plochy. Spotrebuje sa
    // hneď, aby prepnutie záložky režim nespustilo druhýkrát.
    if (ref.watch(pendingAnchorZoneDrawProvider) && !_zoneActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pendingAnchorZoneDrawProvider.notifier).state = false;
        if (mounted && !_zoneActive) _toggleZoneDrawing();
      });
    }
    final dayEntries = ref.watch(dayEntryMarkersProvider).valueOrNull ?? [];
    final showMarinePois = mapState.showMarinePois;
    // marinePois/stationWinds sú NARÁMERNE nie tu, ale vo vlastných
    // Consumer widgetoch nižšie (marker vrstvy + počítadlo staníc) — watch
    // priamo tu by pri každom sieťovom dotiahnutí prekreslil celú obrazovku
    // mapy, čo bola príčina trhania pri posune/zoome so zapnutou vrstvou.

    // Nový tracking vždy vyhráva nad prezeraním starej plavby.
    ref.listen<bool>(isTrackingProvider, (prev, next) {
      if (next &&
          (mapState.previewDayLogId != null ||
              mapState.previewCharterId != null)) {
        ref.read(mapNotifierProvider.notifier).clearPreview();
      }
    });

    // Prehrávanie: poloha lode vo zvolenom okamihu a už prejdená časť trasy.
    // Pri živom trackingu ostáva prázdne — prehráva sa len uložená plavba.
    final playbackPoints = ref.watch(playbackTrackProvider);
    final playbackTime = ref.watch(playbackProvider).time;
    PlaybackFix? playbackFix;
    var playbackPassed = const <LatLng>[];
    if (playbackTime != null && playbackPoints.isNotEmpty) {
      final track = TrackPlayback(playbackPoints);
      playbackFix = track.fixAt(playbackTime);
      final passed = track.passedIndex(playbackTime);
      if (passed > 0) {
        playbackPassed = [
          for (var i = 0; i <= passed; i++)
            LatLng(playbackPoints[i].latitude, playbackPoints[i].longitude),
        ];
      }
    }

    final List<LatLng> trackPoints;
    if (previewDayLogId != null) {
      trackPoints =
          ref.watch(dayTrackPreviewProvider(previewDayLogId)).valueOrNull ??
              const [];
    } else if (previewCharterId != null) {
      trackPoints = ref
              .watch(charterTrackPreviewProvider(previewCharterId))
              .valueOrNull ??
          const [];
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
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              maxZoom: 19,
              onMapReady: _onMapReady,
              // Uprostred kreslenia plochy by podržanie, ktoré skiper
              // mienil ako roh, vyskočilo dialóg waypointu cez jeho
              // rozkreslený tvar.
              onLongPress: (_, ll) {
                if (_zoneActive) return;
                _onMapTap(ll);
              },
              onTap: (_, ll) => _onMapShortTap(ll),
              // Lock na sever (dlhé podržanie ružice) vypne gesto rotácie —
              // mapa ostane north-up, kým používateľ zámok znova neuvoľní.
              interactionOptions: InteractionOptions(
                flags: mapState.northLocked
                    ? InteractiveFlag.all & ~InteractiveFlag.rotate
                    : InteractiveFlag.all,
              ),
              onPositionChanged: (camera, hasGesture) {
                // Ručný posun mapy vypne GPS follow — inak ju každý GPS
                // update strhne späť. GPS tlačidlo follow znova zapne.
                // `!_programmaticMoveInFlight` je len obranná poistka, viď
                // komentár pri poli — reálny fix je initState nižšie.
                if (hasGesture &&
                    !_programmaticMoveInFlight &&
                    ref.read(mapNotifierProvider).followGps) {
                  debugPrint('[MAP] onPositionChanged: hasGesture=true, '
                      'programmaticMoveInFlight=$_programmaticMoveInFlight -> '
                      'setFollowGps(false)');
                  ref.read(mapNotifierProvider.notifier).setFollowGps(false);
                }
                _mapRotation.value = camera.rotation;
                _schedulePoiRefresh();
              },
            ),
            children: [
              // ── Base layer ───────────────────────────────────
              // V nočnom režime tmavé dlaždice — svetlá OSM mapa by cez
              // červený filter oslepovala; tmavý podklad zachová kontrast.
              if (baseMap == BaseMap.osm)
                if (ref.watch(nightModeProvider))
                  TileLayer(
                    key: ValueKey('osm_dark_$_tileKey'),
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.hmb.sailinglog',
                    maxZoom: 19,
                    tileProvider: CachingTileProvider('dark'),
                    // Predsťahuje prstenec dlaždíc okolo výrezu a podrží viac
                    // mimo neho: pri posune a zoome sa tak ukáže načítaná dlaždica
                    // namiesto prázdneho miesta.
                    panBuffer: 2,
                    keepBuffer: 4,
                  )
                else
                  TileLayer(
                    key: ValueKey('osm_$_tileKey'),
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.hmb.sailinglog',
                    maxZoom: 19,
                    tileProvider: CachingTileProvider('osm'),
                    // Predsťahuje prstenec dlaždíc okolo výrezu a podrží viac
                    // mimo neho: pri posune a zoome sa tak ukáže načítaná dlaždica
                    // namiesto prázdneho miesta.
                    panBuffer: 2,
                    keepBuffer: 4,
                  ),

              if (baseMap == BaseMap.satellite) ...[
                // ESRI satelitné snímky
                TileLayer(
                  key: ValueKey('sat_$_tileKey'),
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                  tileProvider: CachingTileProvider('satellite'),
                  // Predsťahuje prstenec dlaždíc okolo výrezu a podrží viac
                  // mimo neho: pri posune a zoome sa tak ukáže načítaná dlaždica
                  // namiesto prázdneho miesta.
                  panBuffer: 2,
                  keepBuffer: 4,
                ),
                // Popisky navrch. Predtým to boli labely z CartoDB, ktoré
                // nad Zadarom ukázali jediné meno mesta a nič viac — dediny,
                // zátoky ani mestské časti nie. Referenčná vrstva Esri je od
                // toho istého poskytovateľa ako samotné snímky, pomenuje aj
                // menšie sídla a má tmavý lem, takže sa dá čítať aj nad
                // svetlým pobrežím.
                TileLayer(
                  key: ValueKey('sat_labels_$_tileKey'),
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'Reference/World_Boundaries_and_Places/MapServer/'
                      'tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 19,
                  // Kešuje sa rovnako ako snímky: bez toho by satelit offline
                  // ostal nemý presne v tej chvíli, keď na názve zátoky záleží.
                  tileProvider: CachingTileProvider('sat_labels'),
                  panBuffer: 2,
                  keepBuffer: 4,
                ),
              ],

              // ── Izobaty (EMODnet) ────────────────────────────
              // Pod seamarkami zámerne: bóje a svetlá sú navigačné značky a
              // musia ostať navrchu, hĺbnice sú podklad pod nimi.
              //
              // WMS, nie XYZ — EMODnet dlaždicová služba dáva len nepriehľadný
              // podklad, ktorý by prekryl mapu. Vrstva `emodnet:contours`
              // cez WMS vracia priehľadné PNG so samotnými čiarami a
              // popiskami hĺbky, takže sa dá položiť na OSM aj na satelit.
              if (showBathymetry)
                TileLayer(
                  key: ValueKey('bathy_$_tileKey'),
                  wmsOptions: WMSTileLayerOptions(
                    baseUrl: 'https://ows.emodnet-bathymetry.eu/wms?',
                    layers: const ['emodnet:contours'],
                    version: '1.3.0',
                  ),
                  userAgentPackageName: 'com.hmb.sailinglog',
                  // Nad z12 EMODnet vracia prázdnu dlaždicu — nie preto, že
                  // by vrstva mala limit mierky, ale preto, že hustejšie
                  // izobaty proste nemá. Bez maxNativeZoom by hĺbnice pri
                  // priblížení ticho zmizli; takto sa posledná skutočná
                  // úroveň roztiahne a čiara na mape ostane.
                  maxNativeZoom: 12,
                  tileProvider: CachingTileProvider('bathymetry'),
                  panBuffer: 2,
                  keepBuffer: 4,
                ),

              // ── OpenSeaMap seamarky (nad satelitom aj OSM) ───
              if (showSeamarks)
                TileLayer(
                  key: ValueKey('seamark_$_tileKey'),
                  urlTemplate:
                      'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hmb.sailinglog',
                  maxZoom: 18,
                  tileProvider: CachingTileProvider('seamark'),
                  // Predsťahuje prstenec dlaždíc okolo výrezu a podrží viac
                  // mimo neho: pri posune a zoome sa tak ukáže načítaná dlaždica
                  // namiesto prázdneho miesta.
                  panBuffer: 2,
                  keepBuffer: 4,
                ),

              // ── Kotviská / maríny / prístavy (OSM, klikateľné) ──
              //
              // Vlastný Consumer namiesto watch na začiatku build(): tieto
              // markery sa menia s každým posunom mapy (POI dotiahnuté pre
              // nový výrez), a top-level watch by pri každej zmene
              // prekresľoval CELÚ obrazovku mapy — všetky dlaždicové vrstvy,
              // FAB stĺpce aj playback bar — nielen tieto značky. Presne to
              // bolo príčinou trhania pri posune/zoome, keď je vrstva zapnutá.
              if (showMarinePois)
                Consumer(builder: (context, ref, _) {
                  final pois = ref.watch(marinePoisProvider).valueOrNull ??
                      const <MarinePoi>[];
                  return MarkerLayer(markers: [
                    for (final poi in pois)
                      Marker(
                        point: LatLng(poi.lat, poi.lon),
                        width: 32,
                        height: 32,
                        child: GestureDetector(
                          onTap: () => _showPoiDetail(poi),
                          child: _MarinePoiMarker(type: poi.type),
                        ),
                      ),
                  ]);
                }),

              // ── Pravítko / trasa ─────────────────────────────
              if (_rulerPoints.isNotEmpty) ...[
                PolylineLayer(polylines: [
                  Polyline(
                    points: _rulerPoints,
                    color: Colors.purple.shade400,
                    strokeWidth: 3,
                    pattern: const StrokePattern.dotted(),
                  ),
                ]),
                MarkerLayer(markers: [
                  for (var i = 0; i < _rulerPoints.length; i++)
                    Marker(
                      point: _rulerPoints[i],
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ]),
              ],

              // ── Rozkreslená kotevná plocha ───────────────────
              // Bodkovaný obrys je vyhradený návrhu: spustená stráž kreslí
              // plnou čiarou, takže sa nedá zameniť za nepotvrdený tvar.
              if (_zonePoints.length >= 3)
                PolygonLayer(polygons: [
                  Polygon(
                    points: _zonePoints,
                    color: Colors.teal.withValues(alpha: 0.10),
                    borderColor: Colors.teal.shade600,
                    borderStrokeWidth: 2,
                    pattern: const StrokePattern.dotted(),
                  ),
                ]),
              // Dva body ešte nie sú plocha, ale skiperovi nesmú zmiznúť.
              if (_zonePoints.length == 2)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _zonePoints,
                    color: Colors.teal.shade600,
                    strokeWidth: 2,
                    pattern: const StrokePattern.dotted(),
                  ),
                ]),
              if (_zonePoints.isNotEmpty)
                MarkerLayer(markers: [
                  for (var i = 0; i < _zonePoints.length; i++)
                    Marker(
                      point: _zonePoints[i],
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ]),

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
                  // Prejdená časť pri prehrávaní — sýtejšia, aby bolo vidno,
                  // kde loď v zvolenom okamihu bola a čo má ešte pred sebou.
                  if (playbackPassed.length > 1)
                    Polyline(
                      points: playbackPassed,
                      color: Colors.deepOrange.shade900,
                      strokeWidth: 4,
                    ),
                ]),

              // ── Loď v prehrávanom okamihu ────────────────────
              if (playbackFix case final fix?)
                MarkerLayer(markers: [
                  Marker(
                    point: fix.position,
                    width: 26,
                    height: 26,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _mapRotation,
                      builder: (context, rotationDeg, _) => Transform.rotate(
                        angle: ((fix.cog ?? 0) - rotationDeg) *
                            math.pi /
                            180,
                        child: Icon(Icons.navigation,
                            color: Colors.deepOrange.shade900, size: 26),
                      ),
                    ),
                  ),
                ]),

              // ── Waypoints ────────────────────────────────────
              waypoints.when(
                data: (wps) => MarkerLayer(
                  markers: wps
                      .map((wp) => Marker(
                            point: LatLng(wp.latitude, wp.longitude),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _editWaypoint(wp),
                              child: const Icon(Icons.location_pin,
                                  color: Colors.red, size: 36),
                            ),
                          ))
                      .toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),

              // ── Zamerania: kužele, osi a krížový fix ─────────────────
              // Pod kotvou a značkou lode zámerne — čiary sú pracovná
              // pomôcka, nesmú prekryť to, kde loď práve je.
              if (mapState.showBearings)
                ...buildBearingLayers(
                  // mapVisibleBearingsProvider, nie bearingsProvider:
                  // "skryť z mapy" zapisuje príznak do databázy, ale kým sa
                  // kreslilo z nefiltrovanej verzie, zápis sa na mape nikdy
                  // neprejavil a zameranie ostalo visieť.
                  bearings: ref.watch(mapVisibleBearingsProvider),
                  resectionFix: ref.watch(resectionFixProvider),
                  sightGroups: ref.watch(sightGroupsProvider),
                  l: l,
                  onTapBearing: _showBearingSheet,
                  onTapSightGroup: _showSightGroupSheet,
                  // Kým GPS beží, kreslí sa odchýlka resekcie od nej —
                  // jediná príležitosť zistiť, nakoľko sa dá kompasu veriť,
                  // kým naň bude skiper raz odkázaný.
                  gpsPosition: () {
                    final gps = LocationService().lastPosition;
                    return gps == null
                        ? null
                        : LatLng(gps.latitude, gps.longitude);
                  }(),
                ),

              // ── Kotva: polomer + ikona ───────────────────────────────
              if (anchor.isActive &&
                  anchor.anchorLat != null &&
                  anchor.anchorLon != null) ...[
                if (anchor.hasZone)
                  PolygonLayer(polygons: [
                    Polygon(
                      points: anchor.zonePolygon,
                      color: (anchor.isDrifting ? Colors.red : Colors.blue)
                          .withValues(alpha: 0.08),
                      borderColor: anchor.isDrifting
                          ? Colors.red.shade700
                          : Colors.blue.shade600,
                      borderStrokeWidth: 2,
                    ),
                  ])
                else
                  CircleLayer(circles: [
                    CircleMarker(
                      point: LatLng(anchor.anchorLat!, anchor.anchorLon!),
                      radius: anchor.radiusMeters,
                      useRadiusInMeter: true,
                      color: (anchor.isDrifting ? Colors.red : Colors.blue)
                          .withValues(alpha: 0.08),
                      borderColor: anchor.isDrifting
                          ? Colors.red.shade700
                          : Colors.blue.shade600,
                      borderStrokeWidth: 2,
                    ),
                  ]),
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(anchor.anchorLat!, anchor.anchorLon!),
                    width: 36,
                    height: 36,
                    child: Icon(Icons.anchor,
                        color: anchor.isDrifting
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                        size: 30,
                        shadows: const [
                          Shadow(color: Colors.white, blurRadius: 4)
                        ]),
                  ),
                ]),
              ],

              // ── MOB marker ──────────────────────────────────────────
              if (mob.isActive && mob.mobLat != null && mob.mobLon != null)
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(mob.mobLat!, mob.mobLon!),
                    width: 56,
                    height: 56,
                    child: const _MobMarker(),
                  ),
                ]),

              // ── Denníkové záznamy (s fotkou aj bez) ──────────────────
              if (dayEntries.isNotEmpty)
                MarkerLayer(markers: [
                  for (final e in dayEntries)
                    if (e.latitude != null && e.longitude != null)
                      Marker(
                        point: LatLng(e.latitude!, e.longitude!),
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.skipperNote ??
                                  (e.photoPath != null
                                      ? l.mapEntryPhoto
                                      : l.mapEntryNote)),
                              duration: const Duration(seconds: 2),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: e.photoPath != null
                                  ? Colors.amber.shade700
                                  : Colors.indigo.shade400,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Icon(
                              e.photoPath != null
                                  ? Icons.camera_alt
                                  : Icons.edit_note,
                              color: Colors.white,
                              size: 16,
                            ),
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
                        _moveMapProgrammatically(
                          LatLng(pos.latitude, pos.longitude),
                          _mapController.camera.zoom,
                        );
                      } catch (_) {}
                    });
                  }
                  return MarkerLayer(markers: [
                    Marker(
                      point: LatLng(pos.latitude, pos.longitude),
                      width: 50,
                      height: 50,
                      child: _GpsMarker(
                          heading: pos.heading, isTracking: isTracking),
                    ),
                  ]);
                },
              ),
            ],
          ),

          // ── Kompas: vždy viditeľný, ihla ukazuje sever ────────
          // Ťuknutím sa mapa (ak je pootočená dvoma prstami) vráti na
          // north-up. Podržaním sa rotácia zamkne/odomkne na sever.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: ValueListenableBuilder<double>(
              valueListenable: _mapRotation,
              builder: (context, rotationDeg, _) => _NorthResetButton(
                rotationDeg: rotationDeg,
                locked: mapState.northLocked,
                onTap: () {
                  _mapController.rotate(0);
                  _mapRotation.value = 0;
                },
                onLongPress: () {
                  final nowLocked = !mapState.northLocked;
                  ref
                      .read(mapNotifierProvider.notifier)
                      .setNorthLocked(nowLocked);
                  if (nowLocked) {
                    _mapController.rotate(0);
                    _mapRotation.value = 0;
                  }
                },
              ),
            ),
          ),

          // ── Ovládacie prvky ──────────────────────────────────
          // Stĺpec je ohraničený aj zdola (rovnaké odsadenie ako GPS/zoom
          // vľavo), aby posledné tlačidlá nezaliezali pod spodnú lištu.
          // Keď sa na nízky displej nezmestia, dá sa v ňom rolovať.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            // Menšia rezerva než pri ľavom stĺpci (GPS/zoom): tam sú tri
            // tlačidlá a miesta dosť, tu ich je dvanásť a pri bottom: 100
            // sa posledné tri orezali, hoci pod nimi zostávala prázdna mapa.
            bottom: 16,
            right: 12,
            child: SingleChildScrollView(
              // Odsadenie zdola, nech posledné tlačidlo nekončí zarovno s
              // okrajom výrezu, keď sa odroluje nadol.
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Základná mapa je jeden prepínač namiesto dvoch tlačidiel —
                // ikona ukazuje, na čo sa prepne.
                _layerFab(
                  heroTag: 'baseMap',
                  tooltip: baseMap == BaseMap.osm
                      ? l.mapLayerSatellite
                      : l.mapLayerMap,
                  icon:
                      baseMap == BaseMap.osm ? Icons.satellite_alt : Icons.map,
                  active: baseMap == BaseMap.satellite,
                  onPressed: () =>
                      ref.read(mapNotifierProvider.notifier).toggleBaseMap(),
                ),
                const SizedBox(height: 8),

                // ── Vrstvy ───────────────────────────────────────
                _layerFab(
                  heroTag: 'layersGroup',
                  tooltip: l.mapLayers,
                  icon: _openPanel == _MapPanel.layers
                      ? Icons.close
                      : Icons.layers,
                  // Zvýraznené aj po zbalení, keď je nejaká vrstva zapnutá —
                  // inak by sa nedalo poznať, že je niečo aktívne.
                  active: _openPanel == _MapPanel.layers ||
                      showSeamarks ||
                      showBathymetry ||
                      showMarinePois,
                  onPressed: () => setState(() => _openPanel =
                      _openPanel == _MapPanel.layers
                          ? _MapPanel.none
                          : _MapPanel.layers),
                ),
                if (_openPanel == _MapPanel.layers) ...[
                  const SizedBox(height: 8),
                  _layerFab(
                    heroTag: 'seamarks',
                    tooltip: l.mapSeamarks,
                    icon: Icons.anchor,
                    active: showSeamarks,
                    onPressed: () =>
                        ref.read(mapNotifierProvider.notifier).toggleSeamarks(),
                  ),
                  const SizedBox(height: 8),
                  _layerFab(
                    heroTag: 'bathymetry',
                    tooltip: l.mapDepths,
                    icon: Icons.waves,
                    active: showBathymetry,
                    onPressed: () => ref
                        .read(mapNotifierProvider.notifier)
                        .toggleBathymetry(),
                  ),
                  const SizedBox(height: 8),
                  _layerFab(
                    heroTag: 'pois',
                    tooltip: l.mapHarbours,
                    icon: Icons.directions_boat,
                    active: showMarinePois,
                    onPressed: () {
                      ref.read(mapNotifierProvider.notifier).toggleMarinePois();
                      final nowOn =
                          ref.read(mapNotifierProvider).showMarinePois;
                      if (nowOn && _mapReady) {
                        if (_mapController.camera.zoom < _poiMinZoom) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(l.mapZoomInForPois),
                            duration: const Duration(seconds: 3),
                          ));
                        } else {
                          ref.read(mapViewBoundsProvider.notifier).state =
                              _mapController.camera.visibleBounds;
                        }
                      }
                    },
                  ),
                ],

                // ── Nástroje ─────────────────────────────────────
                const SizedBox(height: 8),
                _layerFab(
                  heroTag: 'toolsGroup',
                  tooltip: l.mapTools,
                  icon: _openPanel == _MapPanel.tools
                      ? Icons.close
                      : Icons.handyman_outlined,
                  active: _openPanel == _MapPanel.tools ||
                      _rulerActive ||
                      _zoneActive ||
                      isPreviewing ||
                      !mapState.showBearings,
                  onPressed: () => setState(() => _openPanel =
                      _openPanel == _MapPanel.tools
                          ? _MapPanel.none
                          : _MapPanel.tools),
                ),
                if (_openPanel == _MapPanel.tools) ...[
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'voyagePreview',
                    tooltip: l.mapVoyageOverview,
                    onPressed: () => _openVoyagePicker(context),
                    backgroundColor:
                        isPreviewing ? Colors.orange.shade700 : null,
                    child: Icon(Icons.route,
                        color: isPreviewing ? Colors.white : null),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'gpxImport',
                    tooltip: l.gpxImportTitle,
                    onPressed: () => context.push('/gpx-import'),
                    child: const Icon(Icons.file_upload_outlined),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'ruler',
                    tooltip: l.mapRuler,
                    onPressed: () => setState(() {
                      _rulerActive = !_rulerActive;
                      if (!_rulerActive) _rulerPoints.clear();
                    }),
                    backgroundColor:
                        _rulerActive ? Colors.purple.shade400 : null,
                    child: Icon(Icons.straighten,
                        color: _rulerActive ? Colors.white : null),
                  ),
                  const SizedBox(height: 8),
                  // Kreslenie kotevnej plochy. Zablokované, kým stráž beží:
                  // activate() neuzatvára predošlú session, takže spustenie
                  // cez bežiacu stráž by osirelo riadok v databáze.
                  FloatingActionButton.small(
                    heroTag: 'anchorZone',
                    tooltip: l.anchorZoneTool,
                    onPressed: anchor.isActive ? null : _toggleZoneDrawing,
                    backgroundColor: _zoneActive ? Colors.teal.shade600 : null,
                    child: Icon(Icons.pentagon_outlined,
                        color: _zoneActive ? Colors.white : null),
                  ),
                  const SizedBox(height: 8),
                  // Kružidlo patrí k pravítku, nie medzi vrstvy počasia: oboje sú
                  // meracie pomôcky, ktoré si skiper berie do ruky, keď niečo
                  // odmeriava. Medzi zrážkami a vetrom sa strácalo.
                  //
                  // Nie my_location: tú má na tej istej mape tlačidlo
                  // "Sleduj GPS" a obe sa pletú. Kružidlo sa s GPS nezamieňa.
                  _layerFab(
                    heroTag: 'bearings',
                    tooltip: l.bearingsLayer,
                    icon: Icons.architecture,
                    active: mapState.showBearings,
                    onPressed: () =>
                        ref.read(mapNotifierProvider.notifier).toggleBearings(),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'offlineDl',
                    tooltip: l.mapDownloadOffline,
                    onPressed: () => _openOfflineDownload(context),
                    child: const Icon(Icons.download_for_offline_outlined),
                  ),
                ],
              ]),
            ),
          ),

          // ── Panel pravítka / trasy ────────────────────────────
          if (_rulerActive)
            Positioned(
              bottom: 280,
              left: 12,
              child: _RulerPanel(
                points: _rulerPoints,
                onUndo: _rulerPoints.isEmpty
                    ? null
                    : () => setState(() => _rulerPoints.removeLast()),
                onClear: _rulerPoints.isEmpty
                    ? null
                    : () => setState(() => _rulerPoints.clear()),
              ),
            ),

          // ── Panel kotevnej plochy ─────────────────────────────
          if (_zoneActive)
            Positioned(
              bottom: 280,
              left: 12,
              child: _ZonePanel(
                points: _zonePoints,
                onUndo: _zonePoints.isEmpty
                    ? null
                    : () => setState(() => _zonePoints.removeLast()),
                onClear: _zonePoints.isEmpty
                    ? null
                    : () => setState(() => _zonePoints.clear()),
                onCancel: _toggleZoneDrawing,
                onArm: _armZoneWatch,
              ),
            ),

          // ── Banner: poloha nepovolená / GPS vypnuté ───────────
          ValueListenableBuilder<LocationAvailability?>(
            valueListenable: LocationService().availability,
            builder: (context, avail, _) {
              if (avail == null || avail.usable) return const SizedBox();
              final serviceOff = !avail.serviceEnabled;
              return Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                right: 72,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.red.shade700,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.location_off,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          serviceOff ? l.mapGpsDisabled : l.mapLocationDenied,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      InkWell(
                        onTap: () => serviceOff
                            ? AppSettings.openAppSettings(
                                type: AppSettingsType.location)
                            : (avail.canRequest
                                ? LocationService().retryPermission()
                                : AppSettings.openAppSettings(
                                    type: AppSettingsType.location)),
                        child: Text(
                          serviceOff || !avail.canRequest
                              ? l.navSettings
                              : l.notifPromptAllow,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            },
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.route, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(mapState.previewLabel ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                    InkWell(
                      onTap: () =>
                          ref.read(mapNotifierProvider.notifier).clearPreview(),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ]),
                ),
              ),
            ),

          // ── Prehrávanie plavby ────────────────────────────────
          // Len pri zapnutej prehliadke: pri živom trackingu sa prehráva
          // to, čo práve beží, a posuvník by nemal čo posúvať.
          if (mapState.previewLabel != null)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(top: false, child: PlaybackBar()),
            ),

          // ── GPS + zoom (vľavo dole, GPS zarovnané nad +) ──────
          Positioned(
            bottom: 100,
            left: 12,
            child: Column(children: [
              _layerFab(
                heroTag: 'cp',
                tooltip: l.mapFollowGps,
                icon: Icons.my_location,
                active: followGps,
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
              ),
              const SizedBox(height: 8),
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
            ]),
          ),

          // ── Atribúcia zdrojov ────────────────────────────────
          // Podklad aj počasie na jednom riadku. Nie je to zdvorilosť:
          // OpenStreetMap aj Open-Meteo uvedenie zdroja vyžadujú, a keď na
          // mape ležia dáta z modelu, používateľ má vidieť, čí model to je.
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Row(children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.white.withValues(alpha: 0.7),
                  child: Text(
                    baseMap == BaseMap.satellite
                        ? 'Tiles © Esri — Esri, DigitalGlobe, GeoEye, i-cubed, '
                            'USDA FSA, USGS, AEX, Getmapping, Aerogrid, IGN, '
                            'IGP, swisstopo'
                        : '© OpenStreetMap',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8, color: Colors.black54),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// Jednotné okrúhle tlačidlo vrstvy/prepínača — bez popisu, aktívne má
  /// plnú primary farbu, identifikáciu nesie ikona + tooltip.
  Widget _layerFab({
    required String heroTag,
    required String tooltip,
    required IconData icon,
    required bool active,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
  }) {
    final fab = FloatingActionButton.small(
      heroTag: heroTag,
      // FloatingActionButton balí seba do Tooltip, kedykoľvek je `tooltip`
      // zadaný, a Tooltip má na mobile predvolený spúšťač PRÁVE dlhé
      // podržanie -- zožerie ho skôr, než sa dostane k GestureDetectoru
      // nižšie. Tlačidlo s dlhým podržaním preto tooltip nesmie mať, inak
      // sa dlhé podržanie prejaví len ako bublina s názvom a nič viac.
      tooltip: onLongPress == null ? tooltip : null,
      onPressed: onPressed,
      backgroundColor: active ? Theme.of(context).colorScheme.primary : null,
      child: Icon(icon,
          color: active ? Theme.of(context).colorScheme.onPrimary : null),
    );
    return onLongPress == null
        ? fab
        : GestureDetector(onLongPress: onLongPress, child: fab);
  }

  void _onMapTap(LatLng ll) {
    showModalBottomSheet(
      context: context,
      builder: (_) => WaypointDialog(latLng: ll),
    );
  }

  /// Ťuknutie v režime pravítka: pridá bod, so snapom na blízky waypoint
  /// (do ~30 px), aby sa dala trasa plánovať presne cez uložené ciele.
  /// Krátke ťuknutie do mapy.
  ///
  /// Kreslenie kotevnej plochy má prednosť pred pravítkom, pravítko pred
  /// meraním hĺbky. Inak, a len
  /// keď má skiper zapnutú vrstvu hĺbok, sa ťuknutím odmeria hĺbka dna.
  /// Bez tej podmienky by každé zablúdené ťuknutie do mapy znamenalo dotaz
  /// do siete, čo je na lodi bez signálu zbytočné a inde len drahé.
  void _onMapShortTap(LatLng ll) {
    if (_zoneActive) {
      _onZoneTap(ll);
      return;
    }
    if (_rulerActive) {
      _onRulerTap(ll);
      return;
    }
    if (ref.read(mapNotifierProvider).showBathymetry) _probeDepth(ll);
  }

  /// Odmeria hĺbku v bode a ukáže ju. Null sa hlási ako „bez údaja" —
  /// mlčať by sa dalo zameniť za nulovú hĺbku.
  Future<void> _probeDepth(LatLng ll) async {
    if (_depthProbing) return;
    setState(() => _depthProbing = true);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final metres = await DepthProbeService().depthAt(ll);
      if (!mounted) return;
      final units = ref.read(unitsSyncProvider);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(
        content: Text(metres == null
            ? l.mapDepthNoData
            : l.mapDepthHere(units.formatDepth(metres))),
        duration: const Duration(seconds: 4),
      ));
    } finally {
      if (mounted) setState(() => _depthProbing = false);
    }
  }

  void _onRulerTap(LatLng ll) {
    if (!_rulerActive) return;
    final wps = ref.read(waypointsProvider).valueOrNull ?? const <Waypoint>[];
    LatLng snapped = ll;
    final zoom = _mapController.camera.zoom;
    // ~30 px v stupňoch: 360° / (256 * 2^zoom) px-na-stupeň
    final snapDeg = 30 * 360 / (256 * math.pow(2, zoom));
    for (final wp in wps) {
      if ((wp.latitude - ll.latitude).abs() < snapDeg &&
          (wp.longitude - ll.longitude).abs() < snapDeg) {
        snapped = LatLng(wp.latitude, wp.longitude);
        break;
      }
    }
    setState(() => _rulerPoints.add(snapped));
  }

  void _onZoneTap(LatLng ll) {
    if (_zonePoints.length >= _zoneMaxPoints) return;
    setState(() => _zonePoints.add(ll));
  }

  /// Zapne alebo vypne kreslenie plochy. Pravítko sa pritom vypína: oba
  /// panely visia na tom istom mieste a obom by patrilo to isté ťuknutie.
  void _toggleZoneDrawing() => setState(() {
        _zoneActive = !_zoneActive;
        _zonePoints.clear();
        if (_zoneActive) {
          _rulerActive = false;
          _rulerPoints.clear();
        }
      });

  /// Spustí kotvovú stráž nad nakreslenou plochou.
  ///
  /// Bod kotvy je aktuálny GPS fix, nie ťažisko plochy: tie dve čísla idú do
  /// záznamu „Kotva spustená" a označujú kotvu na mape, takže musia povedať,
  /// kde kotva naozaj padla. Bez fixu sa vezme ťažisko — stráž sa spustiť
  /// musí aj bez signálu — a skiper sa to dozvie.
  Future<void> _armZoneWatch() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ring = List<LatLng>.of(_zonePoints);
    if (!GeoPolygon.isUsable(ring)) {
      messenger.showSnackBar(
          SnackBar(content: Text(l.anchorZoneNeedsPoints)));
      return;
    }
    if (GeoPolygon.hasSelfIntersection(ring)) {
      messenger.showSnackBar(
          SnackBar(content: Text(l.anchorZoneSelfIntersects)));
      return;
    }

    final pos =
        GpsTrackingService().lastPosition ?? LocationService().lastPosition;
    LatLng anchorPoint;
    if (pos == null) {
      anchorPoint = GeoPolygon.centroid(ring);
      messenger.showSnackBar(SnackBar(content: Text(l.anchorZoneNoFix)));
    } else {
      anchorPoint = LatLng(pos.latitude, pos.longitude);
      // Spustiť stráž zvonku plochy znamená alarm v tej istej sekunde.
      if (!GeoPolygon.contains(ring, anchorPoint)) {
        messenger
            .showSnackBar(SnackBar(content: Text(l.anchorZoneNotInside)));
        return;
      }
      // Tesná hrana plus šum GPS = striedavé alarmy celú noc. Povolí sa,
      // ale skiper má vedieť, do čoho ide.
      final clearance = GeoPolygon.distanceToEdgeM(ring, anchorPoint);
      if (pos.accuracy > 0 && clearance < pos.accuracy) {
        messenger.showSnackBar(SnackBar(content: Text(l.anchorZoneTooTight)));
      }
    }

    await ref.read(anchorProvider.notifier).activate(
        anchorPoint.latitude, anchorPoint.longitude, 50,
        zone: ring);
    if (!mounted) return;
    setState(() {
      _zoneActive = false;
      _zonePoints.clear();
    });
  }

  void _showPoiDetail(MarinePoi poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarinePoiSheet(poi: poi),
    );
  }

  /// Stiahne dlaždice aktuálne viditeľnej oblasti pre offline použitie:
  /// od aktuálneho zoomu po +3 úrovne hlbšie.
  ///
  /// Mapa a seamarky vždy; satelitné snímky aj s popiskami len vtedy, keď je
  /// satelit zapnutý ako podklad — sú niekoľkonásobne väčšie a tomu, kto ich
  /// nepoužíva, by len zabrali miesto.
  void _openOfflineDownload(BuildContext context) {
    if (!_mapReady) return;
    final l = AppLocalizations.of(context);
    final bounds = _mapController.camera.visibleBounds;
    final minZ = _mapController.camera.zoom.floor();
    final maxZ = (minZ + 3).clamp(minZ, 17);
    final satellite = ref.read(mapNotifierProvider).baseMap == BaseMap.satellite;
    final perLayer = TileRegionDownloader.countTiles(bounds, minZ, maxZ);
    final total = perLayer *
        TileRegionDownloader.layersFor(satellite: satellite).length;

    if (total > TileRegionDownloader.maxTiles) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.mapAreaTooLarge(total)),
        duration: const Duration(seconds: 4),
      ));
      return;
    }

    final downloader = TileRegionDownloader();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetCtx) => _OfflineDownloadSheet(
        downloader: downloader,
        bounds: bounds,
        minZ: minZ,
        maxZ: maxZ,
        total: total,
        satellite: satellite,
      ),
    );
  }

  void _editWaypoint(Waypoint wp) {
    showModalBottomSheet(
      context: context,
      builder: (_) => WaypointDialog(
        latLng: LatLng(wp.latitude, wp.longitude),
        existing: wp,
      ),
    );
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
        // Bez tohto CameraFit.bounds vie pre tesne zhlukované body (napr.
        // krátky deň pri móle) dopočítať zoom ďaleko za maxZoom dlaždíc —
        // mapa potom zmizne (žiadne dlaždice na danej úrovni), zostane
        // viditeľná len trasa/vektorová vrstva. Prepínanie mapa/satelit
        // nepomôže, obe majú rovnaký strop.
        maxZoom: 17,
      ));
    } catch (_) {}
  }

  Future<void> _selectDay(
      int dayLogId, String label, BuildContext sheetContext) async {
    ref.read(mapNotifierProvider.notifier).previewDay(dayLogId, label);
    ref.read(mapNotifierProvider.notifier).setFollowGps(false);
    Navigator.pop(sheetContext);
    final points = await ref.read(dayTrackPreviewProvider(dayLogId).future);
    if (mounted) _focusOnPoints(points);
  }

  Future<void> _selectCharter(
      int charterId, String label, BuildContext sheetContext) async {
    ref.read(mapNotifierProvider.notifier).previewCharter(charterId, label);
    ref.read(mapNotifierProvider.notifier).setFollowGps(false);
    Navigator.pop(sheetContext);
    final points =
        await ref.read(charterTrackPreviewProvider(charterId).future);
    if (mounted) _focusOnPoints(points);
  }

  void _openVoyagePicker(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                  Text(l.mapVoyageOverview,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.gps_fixed, color: Colors.blue),
                  title: Text(l.mapLivePreview),
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
                        final daysAsync =
                            dayRef.watch(dayLogsProvider(charter.id));
                        return daysAsync.when(
                          data: (days) => days.isEmpty
                              ? const SizedBox()
                              : ExpansionTile(
                                  title: Text(charter.title),
                                  subtitle: Text(
                                      '${days.fold<double>(0, (s, d) => s + d.distanceNm).toStringAsFixed(1)} NM · ${l.daysCount(days.length)}'),
                                  children: [
                                    ListTile(
                                      dense: true,
                                      leading:
                                          const Icon(Icons.route, size: 20),
                                      title: Text(l.mapWholeVoyage,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onTap: () => _selectCharter(
                                          charter.id, charter.title, sheetCtx),
                                    ),
                                    const Divider(height: 1),
                                    for (final day in days)
                                      ListTile(
                                        dense: true,
                                        title: Text(AppDate.of(context, ref)
                                            .long(day.date)),
                                        subtitle: Text(ref
                                            .watch(unitsSyncProvider)
                                            .formatDistance(day.distanceNm,
                                                decimals: 1)),
                                        onTap: () => _selectDay(
                                            day.id,
                                            '${charter.title} · ${AppDate.of(context, ref).short(day.date)}',
                                            sheetCtx),
                                      ),
                                  ],
                                ),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        );
                      }),
                  ]),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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

// ── Offline download sheet ────────────────────────────────────

class _OfflineDownloadSheet extends StatefulWidget {
  final TileRegionDownloader downloader;
  final LatLngBounds bounds;
  final int minZ, maxZ, total;

  /// Berú sa aj satelitné snímky a ich popisky?
  final bool satellite;

  const _OfflineDownloadSheet({
    required this.downloader,
    required this.bounds,
    required this.satellite,
    required this.minZ,
    required this.maxZ,
    required this.total,
  });

  @override
  State<_OfflineDownloadSheet> createState() => _OfflineDownloadSheetState();
}

class _OfflineDownloadSheetState extends State<_OfflineDownloadSheet> {
  int _done = 0;
  bool _running = false;
  bool _finished = false;
  int _errors = 0;

  Future<void> _start() async {
    setState(() => _running = true);
    final errors = await widget.downloader.download(
      widget.bounds,
      widget.minZ,
      widget.maxZ,
      (done, total) {
        if (mounted) setState(() => _done = done);
      },
      satellite: widget.satellite,
    );
    if (mounted) {
      setState(() {
        _running = false;
        _finished = true;
        _errors = errors;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Icon(Icons.download_for_offline_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l.offlineSheetTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            l.offlineSheetDesc(widget.minZ, widget.maxZ, widget.total,
                (widget.total * 15 / 1024).toStringAsFixed(0)),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (_running || _finished) ...[
            LinearProgressIndicator(
                value: widget.total == 0 ? 1 : _done / widget.total),
            const SizedBox(height: 8),
            Text(_finished
                ? (_errors == 0
                    ? l.offlineDone(_done)
                    : l.offlineDoneErrors(_errors))
                : '$_done / ${widget.total}'),
            const SizedBox(height: 12),
          ],
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () {
                widget.downloader.cancel();
                Navigator.pop(context);
              },
              child: Text(_finished ? l.close : l.cancel),
            ),
            const SizedBox(width: 8),
            if (!_running && !_finished)
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.download),
                label: Text(l.downloadAction),
              ),
          ]),
        ]),
      ),
    );
  }
}

// ── Wind arrow ────────────────────────────────────────────────

/// Ovládanie kreslenia kotevnej plochy.
///
/// Plocha v m² nie je ozdoba: je to jediná kontrola rozumnosti, ktorú skiper
/// pri ťukaní rohov má. Nakreslená plocha veľkosti prístavu by znamenala
/// stráž, ktorá sa neozve nikdy.
class _ZonePanel extends StatelessWidget {
  final List<LatLng> points;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;
  final VoidCallback onCancel;
  final VoidCallback onArm;

  const _ZonePanel({
    required this.points,
    required this.onCancel,
    required this.onArm,
    this.onUndo,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final usable = GeoPolygon.isUsable(points);
    final crosses = GeoPolygon.hasSelfIntersection(points);
    final areaM2 = GeoPolygon.areaM2(points);

    // Prekrížený tvar sa neopravuje: even-odd by z neho urobil laloky, ktoré
    // sa striedavo strážia a nestrážia, a skiper by o tom nevedel.
    final String hint;
    if (crosses) {
      hint = l.anchorZoneSelfIntersects;
    } else if (!usable) {
      hint = points.isEmpty ? l.anchorZoneDrawHint : l.anchorZoneNeedsPoints;
    } else {
      hint = '${areaM2.round()} m²';
    }

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Colors.teal.shade600,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.anchorZoneTool,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            Text(hint,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 6),
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                onPressed: onUndo,
                icon: const Icon(Icons.undo, color: Colors.white, size: 20),
                tooltip: l.undoLastPoint,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline,
                    color: Colors.white, size: 20),
                tooltip: l.delete,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                tooltip: l.cancel,
                visualDensity: VisualDensity.compact,
              ),
            ]),
            const SizedBox(height: 2),
            FilledButton.icon(
              onPressed: usable && !crosses ? onArm : null,
              icon: const Icon(Icons.anchor, size: 18),
              label: Text(l.anchorZoneArm),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade700,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulerPanel extends ConsumerWidget {
  final List<LatLng> points;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;
  const _RulerPanel({required this.points, this.onUndo, this.onClear});

  static double _bearingDeg(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final units = ref.watch(unitsSyncProvider);
    var totalNm = 0.0;
    for (var i = 1; i < points.length; i++) {
      totalNm += DistanceCalculator.distanceNm(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    final brg = points.length >= 2
        ? _bearingDeg(points[points.length - 2], points.last)
        : null;

    // ETA pri aktuálnej rýchlosti (GPS SOG) — len keď sa reálne hýbeme.
    final pos = LocationService().lastPosition;
    final sogKn = pos != null ? pos.speed * 1.94384 : 0.0;
    String? eta;
    if (totalNm > 0 && sogKn > 0.5) {
      final hours = totalNm / sogKn;
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      eta = '${h}h ${m}min @ ${units.formatSpeed(sogKn)}';
    }

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Colors.purple.shade400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.straighten, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                points.isEmpty
                    ? l.rulerTapHint
                    : '${units.formatDistance(totalNm, decimals: 1)}'
                        '${brg != null ? '  ·  ${brg.toStringAsFixed(0)}°' : ''}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              if (onUndo != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onUndo,
                  child: const Icon(Icons.undo, color: Colors.white, size: 18),
                ),
              ],
              if (onClear != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onClear,
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 18),
                ),
              ],
            ]),
            if (eta != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('ETA $eta',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Marine POI Marker ─────────────────────────────────────────

class _MarinePoiMarker extends StatelessWidget {
  final String type;
  const _MarinePoiMarker({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      'anchorage' => (Icons.anchor, Colors.teal.shade700),
      'marina' => (Icons.sailing, Colors.indigo.shade600),
      'fuel' => (Icons.local_gas_station, Colors.orange.shade800),
      _ => (Icons.directions_boat, Colors.blueGrey.shade700),
    };
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
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
    _pulse = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
          width: 26,
          height: 26,
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

// ── North reset button ─────────────────────────────────────────

class _NorthResetButton extends StatelessWidget {
  final double rotationDeg;
  final bool locked;

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _NorthResetButton({
    required this.rotationDeg,
    required this.locked,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: CircleBorder(
        side: locked
            ? BorderSide(color: Colors.blue.shade600, width: 2)
            : BorderSide.none,
      ),
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(children: [
            // Ružica otočená o -X° oproti rotácii mapy o X° — hrot N
            // ukazuje vždy na skutočný sever bez ohľadu na natočenie mapy.
            CustomPaint(
              size: const Size(44, 44),
              painter: _CompassRosePainter(rotationDeg: rotationDeg),
            ),
            if (locked)
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 9),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

/// Zjednodušená námorná ružica: 4 hlavné hroty (N červený, ostatné tmavé)
/// + 4 vedľajšie hroty, s popiskou "N".
class _CompassRosePainter extends CustomPainter {
  final double rotationDeg;

  _CompassRosePainter({required this.rotationDeg});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotationDeg * math.pi / 180);

    ui.Path spike(double angleDeg, double length, double halfWidth) {
      final rad = angleDeg * math.pi / 180;
      final tip = Offset(length * math.sin(rad), -length * math.cos(rad));
      final baseL = Offset(halfWidth * math.sin(rad + math.pi / 2),
          -halfWidth * math.cos(rad + math.pi / 2));
      final baseR = Offset(halfWidth * math.sin(rad - math.pi / 2),
          -halfWidth * math.cos(rad - math.pi / 2));
      return ui.Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(baseL.dx, baseL.dy)
        ..lineTo(0, 0)
        ..lineTo(baseR.dx, baseR.dy)
        ..close();
    }

    final darkPaint = Paint()..color = Colors.blueGrey.shade800;
    final lightPaint = Paint()..color = Colors.blueGrey.shade200;
    final northPaint = Paint()..color = Colors.red.shade700;
    final outline = Paint()
      ..color = Colors.blueGrey.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // Vedľajšie (kratšie) hroty NE/SE/SW/NW.
    for (final a in [45.0, 135.0, 225.0, 315.0]) {
      final p = spike(a, r * 0.62, r * 0.14);
      canvas.drawPath(p, lightPaint);
      canvas.drawPath(p, outline);
    }

    // Hlavné hroty E/S/W (tmavé) a N (červený).
    for (final a in [90.0, 180.0, 270.0]) {
      final p = spike(a, r * 0.92, r * 0.2);
      canvas.drawPath(p, darkPaint);
      canvas.drawPath(p, outline);
    }
    final northSpike = spike(0, r * 0.92, r * 0.2);
    canvas.drawPath(northSpike, northPaint);
    canvas.drawPath(northSpike, outline);

    // Stredový krúžok.
    canvas.drawCircle(Offset.zero, r * 0.16, Paint()..color = Colors.white);
    canvas.drawCircle(Offset.zero, r * 0.16, outline);

    // Popiska "N" nad severným hrotom.
    final tp = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -r - tp.height - 1));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassRosePainter oldDelegate) =>
      oldDelegate.rotationDeg != rotationDeg;
}

// ── Meraná stanica ────────────────────────────────────────────

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
