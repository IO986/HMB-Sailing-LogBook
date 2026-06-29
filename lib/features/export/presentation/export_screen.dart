import 'dart:math';
import 'dart:typed_data';
import 'package:drift/drift.dart' as drift show Value;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide DistanceCalculator;
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../core/utils/gpx_exporter.dart';
import '../../../main.dart';
import '../services/export_service.dart';
import '../services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'signature_pad_dialog.dart';
import 'pdf_preview_screen.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final int charterId;
  final int? dayLogId;
  const ExportScreen({super.key, required this.charterId, this.dayLogId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  Charter? _charter;
  DayLog? _day;
  List<DayLog> _days = [];
  Map<int, List<LogbookEntry>> _entriesByDay = {};
  Map<int, List<TrackPoint>> _tracksByDay = {};
  Map<int, List<SailingSession>> _sessionsByDay = {};
  bool _loading = true;
  final Map<int, ScreenshotController> _screenshotControllers = {};
  final Map<int, Uint8List?> _mapScreenshots = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    final charters = await db.getAllCharters();
    try {
      _charter = charters.firstWhere((c) => c.id == widget.charterId);
    } catch (_) { return; }

    if (widget.dayLogId != null) {
      final allDays = await db.getDayLogs(widget.charterId);
      try { _day = allDays.firstWhere((d) => d.id == widget.dayLogId); } catch (_) {}
      _days = _day != null ? [_day!] : [];
    } else {
      _days = await db.getDayLogs(widget.charterId);
    }

    for (final day in _days) {
      _entriesByDay[day.id] = await db.getEntriesForDay(day.id);
      final sessions = await db.getSessionsForDay(day.id);
      _sessionsByDay[day.id] = sessions;
      final pts = <TrackPoint>[];
      for (final s in sessions) {
        pts.addAll(await db.getTrackPointsForSession(s.sessionId));
      }
      _tracksByDay[day.id] = pts;
      _screenshotControllers[day.id] = ScreenshotController();
    }

    setState(() => _loading = false);

    // Screenshot máp po renderovaní – 4s aby sa stihli načítať dlaždice.
    await Future.delayed(const Duration(milliseconds: 4000));
    for (final day in _days) {
      try {
        final img = await _screenshotControllers[day.id]?.capture(pixelRatio: 2.0);
        if (mounted) setState(() => _mapScreenshots[day.id] = img);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_loading) return Scaffold(
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(l.loadingData),
      ])));

    final screenshotsDone = _days.isNotEmpty &&
        _mapScreenshots.length == _days.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayLogId != null ? l.exportDayTitle : l.exportCharterTitle),
        actions: [
          if (screenshotsDone)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _doExport,
              tooltip: l.share,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_charter?.title ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (_day != null)
                  Text(DateFormat('EEEE d. MMMM yyyy', 'sk').format(_day!.date),
                      style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                const Row(children: [
                  Icon(Icons.picture_as_pdf, size: 16),
                  SizedBox(width: 4), Text('PDF  ', style: TextStyle(fontSize: 13)),
                  Icon(Icons.gps_fixed, size: 16),
                  SizedBox(width: 4), Text('GPX', style: TextStyle(fontSize: 13)),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: screenshotsDone ? Colors.green.shade50 : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                screenshotsDone
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Expanded(child: Text(screenshotsDone
                    ? l.mapsReady
                    : l.generatingMaps(_mapScreenshots.length, _days.length))),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          ..._days.map((day) => _DayMapPreview(
            day: day,
            entries: _entriesByDay[day.id] ?? [],
            trackPoints: _tracksByDay[day.id] ?? [],
            screenshotController: _screenshotControllers[day.id]!,
            screenshot: _mapScreenshots[day.id],
          )),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: screenshotsDone ? _doExport : null,
        icon: const Icon(Icons.share),
        label: Text(widget.dayLogId != null ? l.exportDayBtn : l.exportCharterBtn),
        backgroundColor: screenshotsDone ? null : Colors.grey,
      ),
    );
  }

  /// Vypočíta NM zo zoznamu track pointov pomocou haversine.
  static double _calcNm(List<TrackPoint> pts) {
    if (pts.length < 2) return 0;
    double nm = 0;
    for (int i = 1; i < pts.length; i++) {
      final d = DistanceCalculator.distanceNm(
        pts[i - 1].latitude, pts[i - 1].longitude,
        pts[i].latitude, pts[i].longitude,
      );
      if (d < 10) nm += d; // ignoruj GPS skoky > 10 NM
    }
    return nm;
  }

  /// Ak má deň distanceNm == 0, dopočíta z track pointov a zapíše do DB.
  Future<void> _ensureDayNm(DayLog day) async {
    if (day.distanceNm > 0) return;
    final pts = _tracksByDay[day.id] ?? [];
    final nm = _calcNm(pts);
    if (nm > 0) {
      await ref.read(databaseProvider).updateDayLog(DayLogsCompanion(
        id: drift.Value(day.id),
        distanceNm: drift.Value(nm),
      ));
    }
  }

  Future<void> _doExport() async {
    if (_charter == null) return;

    // 1. Podpis skippera
    final signatureImage = await showSignaturePadDialog(
      context, signerName: _charter!.skipperName);
    if (signatureImage == null || !mounted) return;

    // 2. Generovanie PDF bajtov (zobraz progress)
    BuildContext? dialogCtx;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogCtx = ctx;
        return AlertDialog(
          content: Row(children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(AppLocalizations.of(ctx).generatingPdfPreview)),
          ]),
        );
      },
    );

    Uint8List? pdfBytes;
    Uint8List? gpxBytes;
    String previewTitle = _charter!.title;
    String suggestedFileName = 'saillog_export';

    final vessel = (_charter!.vesselName?.isNotEmpty == true
            ? _charter!.vesselName!
            : _charter!.title)
        .replaceAll(RegExp(r'[^\wÀ-žа-яА-Я]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    try {
      if (widget.dayLogId != null && _day != null) {
        // Prepočítaj NM ak chýba
        await _ensureDayNm(_day!);
        // Reload day (NM mohlo byť práve zapísané)
        final freshDay = await ref.read(databaseProvider).getDayLogById(_day!.id) ?? _day!;

        final entries = _entriesByDay[freshDay.id] ?? [];
        pdfBytes = await PdfExportService.buildDayPdfBytes(
          charter: _charter!,
          day: freshDay,
          entries: entries,
          mapScreenshot: _mapScreenshots[freshDay.id],
          signatureImage: signatureImage,
        );
        previewTitle = '${_day!.portFrom ?? "?"} → ${_day!.portTo ?? "?"}';
        final dateStr = DateFormat('yyyy-MM-dd').format(_day!.date);
        suggestedFileName = 'saillog_${vessel}_$dateStr';

        final sessions = _sessionsByDay[_day!.id] ?? [];
        final pointsBySession = <String, List<TrackPoint>>{};
        for (final s in sessions) {
          pointsBySession[s.sessionId] =
              await ref.read(databaseProvider).getTrackPointsForSession(s.sessionId);
        }
        gpxBytes = await GpxExporter.buildDayGpxBytes(
            _day!, sessions, pointsBySession);
      } else {
        // Prepočítaj NM pre každý deň ak chýba
        final freshDays = <DayLog>[];
        for (final day in _days) {
          await _ensureDayNm(day);
          freshDays.add(await ref.read(databaseProvider).getDayLogById(day.id) ?? day);
        }
        pdfBytes = await PdfExportService.buildCharterPdfBytes(
          charter: _charter!,
          days: freshDays,
          entriesByDay: _entriesByDay,
          mapScreenshots: _mapScreenshots,
          signatureImage: signatureImage,
        );
        previewTitle = _charter!.title;
        final dateStr = DateFormat('yyyy-MM-dd').format(_charter!.dateFrom);
        suggestedFileName = 'saillog_${vessel}_$dateStr';

        final sessionsByDay = <int, List<SailingSession>>{};
        final pointsBySession = <String, List<TrackPoint>>{};
        for (final day in _days) {
          final sessions = _sessionsByDay[day.id] ?? [];
          sessionsByDay[day.id] = sessions;
          for (final s in sessions) {
            pointsBySession[s.sessionId] =
                await ref.read(databaseProvider).getTrackPointsForSession(s.sessionId);
          }
        }
        gpxBytes = await GpxExporter.buildCharterGpxBytes(
            _charter!, _days, sessionsByDay, pointsBySession);
      }
    } catch (e) {
      if (dialogCtx != null && dialogCtx!.mounted) {
        Navigator.of(dialogCtx!).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).generationError(e.toString())),
              backgroundColor: Colors.red));
      }
      return;
    }

    if (dialogCtx != null && dialogCtx!.mounted) {
      Navigator.of(dialogCtx!).pop();
    }
    if (!mounted) return;

    // 3. Náhľad PDF
    final svc = ExportService();
    svc.setDatabase(ref.read(databaseProvider));

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: previewTitle,
        pdfBytes: pdfBytes!,
        suggestedFileName: suggestedFileName,
        gpxBytes: gpxBytes,
        onSave: () {
          Navigator.of(context).pop();
          if (widget.dayLogId != null && _day != null) {
            svc.exportDayFromBytes(
              context, _charter!, _day!, pdfBytes!,
              signatureImage: signatureImage,
            );
          } else {
            svc.exportCharterFromBytes(
              context, _charter!, pdfBytes!,
              days: _days,
              signatureImage: signatureImage,
            );
          }
        },
      ),
    ));
  }
}

// ── Náhľad mapy pre deň ──────────────────────────────────────

class _DayMapPreview extends StatelessWidget {
  final DayLog day;
  final List<LogbookEntry> entries;
  final List<TrackPoint> trackPoints;
  final ScreenshotController screenshotController;
  final Uint8List? screenshot;

  const _DayMapPreview({
    required this.day, required this.entries, required this.trackPoints,
    required this.screenshotController, required this.screenshot,
  });

  @override
  Widget build(BuildContext context) {
    // Group points by session to avoid phantom lines between separate sessions
    final bySession = <String, List<LatLng>>{};
    for (final tp in trackPoints) {
      final sid = tp.sessionId ?? '_';
      bySession.putIfAbsent(sid, () => []).add(LatLng(tp.latitude, tp.longitude));
    }

    final allPoints = trackPoints
        .map((p) => LatLng(p.latitude, p.longitude)).toList();

    LatLng center = const LatLng(43.5, 16.4);
    CameraFit? cameraFit;
    if (allPoints.isNotEmpty) {
      final avgLat = allPoints.map((p) => p.latitude).reduce((a, b) => a + b) / allPoints.length;
      final avgLon = allPoints.map((p) => p.longitude).reduce((a, b) => a + b) / allPoints.length;
      center = LatLng(avgLat, avgLon);

      final minLat = allPoints.map((p) => p.latitude).reduce(min);
      final maxLat = allPoints.map((p) => p.latitude).reduce(max);
      final minLon = allPoints.map((p) => p.longitude).reduce(min);
      final maxLon = allPoints.map((p) => p.longitude).reduce(max);
      cameraFit = CameraFit.bounds(
        bounds: LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon)),
        padding: const EdgeInsets.all(28),
        maxZoom: 14,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('EEEE d. MMMM', 'sk').format(day.date),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${day.portFrom ?? "?"} → ${day.portTo ?? "?"}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ])),
            if (day.distanceNm > 0)
              Text('${day.distanceNm.toStringAsFixed(1)} NM',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),

          // Screenshot source
          Screenshot(
            controller: screenshotController,
            child: SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 10.0,
                    initialCameraFit: cameraFit,
                    interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://server.arcgisonline.com/ArcGIS/rest/services/'
                          'World_Imagery/MapServer/tile/{z}/{y}/{x}',
                      userAgentPackageName: 'com.hmb.sailinglog',
                    ),
                    TileLayer(
                      urlTemplate:
                          'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hmb.sailinglog',
                    ),
                    if (bySession.isNotEmpty)
                      PolylineLayer(polylines: [
                        for (final pts in bySession.values)
                          if (pts.length >= 2)
                            Polyline(points: pts, color: Colors.yellow, strokeWidth: 3),
                      ]),
                    if (allPoints.isNotEmpty)
                      MarkerLayer(markers: [
                        Marker(point: allPoints.first, width: 20, height: 20,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow,
                                color: Colors.white, size: 14))),
                        Marker(point: allPoints.last, width: 20, height: 20,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.stop,
                                color: Colors.white, size: 14))),
                      ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(children: [
            _Stat(AppLocalizations.of(context).entriesLabel, '${entries.length}', Icons.list_alt),
            _Stat(AppLocalizations.of(context).routePoints, '${trackPoints.length}', Icons.route),
            if (day.beaufortNoon != null)
              _Stat('Bft', '${day.beaufortNoon}', Icons.air),
            const Spacer(),
            screenshot != null
                ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
                : const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
          ]),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 14),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: Colors.grey),
      const SizedBox(width: 3),
      Text('$label: ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
      Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    ]));
}
