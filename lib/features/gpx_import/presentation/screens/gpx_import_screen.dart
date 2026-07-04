import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../../map/providers/map_provider.dart';
import '../../services/gpx_importer.dart';

class GpxImportScreen extends ConsumerStatefulWidget {
  const GpxImportScreen({super.key});
  @override
  ConsumerState<GpxImportScreen> createState() => _GpxImportScreenState();
}

class _GpxImportScreenState extends ConsumerState<GpxImportScreen> {
  GpxParseResult? _result;
  List<Charter> _charters = [];
  Map<int, List<DayLog>> _dayLogsByCharter = {};
  final Map<int, int?> _targetDayLogId = {}; // trackIndex -> dayLogId (null = nová plavba)
  bool _loading = false;

  Future<void> _pickAndParse() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gpx'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    setState(() => _loading = true);
    try {
      final content = await File(path).readAsString();
      final result = GpxImporter.parse(content);
      final db = ref.read(databaseProvider);
      final charters = await db.getAllCharters();
      final dayLogsByCharter = <int, List<DayLog>>{};
      for (final c in charters) {
        dayLogsByCharter[c.id] = await db.getDayLogs(c.id);
      }
      setState(() {
        _result = result;
        _charters = charters;
        _dayLogsByCharter = dayLogsByCharter;
        _targetDayLogId.clear();
      });
    } on GpxParseException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context).errorMsg(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.error),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.ok))],
      ),
    );
  }

  Future<void> _import() async {
    final result = _result;
    if (result == null) return;
    setState(() => _loading = true);
    final db = ref.read(databaseProvider);

    for (final wpt in result.waypoints) {
      await db.insertWaypoint(WaypointsCompanion.insert(
        name: wpt.name ?? (wpt.isRoutePoint ? 'Route point' : 'Waypoint'),
        latitude: wpt.lat,
        longitude: wpt.lon,
        createdAt: wpt.time ?? DateTime.now(),
        type: Value(wpt.isRoutePoint ? 'route' : null),
      ));
    }
    ref.invalidate(waypointsProvider);

    final touchedCharterIds = <int>{};

    for (var i = 0; i < result.tracks.length; i++) {
      final track = result.tracks[i];
      if (track.points.isEmpty) continue;

      int dayLogId;
      final chosen = _targetDayLogId[i];
      if (chosen != null) {
        dayLogId = chosen;
        final charterId = _dayLogsByCharter.entries
            .firstWhere((e) => e.value.any((d) => d.id == chosen))
            .key;
        touchedCharterIds.add(charterId);
      } else {
        final firstTime = track.points.first.time ?? DateTime.now();
        final lastTime = track.points.last.time ?? firstTime;
        final charter = await db.insertCharter(ChartersCompanion.insert(
          title: track.name ?? 'Import GPX ${DateFormat('d.M.yyyy').format(firstTime)}',
          dateFrom: firstTime,
          dateTo: lastTime,
          createdAt: DateTime.now(),
        ));
        final dayLog = await db.insertDayLog(DayLogsCompanion.insert(
          charterId: charter.id,
          date: firstTime,
        ));
        dayLogId = dayLog.id;
        touchedCharterIds.add(charter.id);
      }

      var nm = 0.0;
      for (var p = 1; p < track.points.length; p++) {
        nm += DistanceCalculator.distanceNm(
          track.points[p - 1].lat, track.points[p - 1].lon,
          track.points[p].lat, track.points[p].lon,
        );
      }

      final sessionId = const Uuid().v4();
      await db.upsertSession(SailingSessionsCompanion.insert(
        sessionId: sessionId,
        dayLogId: Value(dayLogId),
        startTime: track.points.first.time ?? DateTime.now(),
        endTime: Value(track.points.last.time),
        name: Value(track.name),
        totalDistanceNm: Value(nm),
        isActive: const Value(false),
      ));
      for (final p in track.points) {
        await db.insertTrackPoint(TrackPointsCompanion.insert(
          sessionId: Value(sessionId),
          timestamp: p.time ?? DateTime.now(),
          latitude: p.lat,
          longitude: p.lon,
          altitude: Value(p.ele),
        ));
      }
    }

    ref.invalidate(chartersProvider);
    for (final id in touchedCharterIds) {
      ref.invalidate(dayLogsProvider(id));
    }

    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).gpxImportSuccess)));
      context.pop();
    }
  }

  String _targetLabel(AppLocalizations l, int? dayLogId) {
    if (dayLogId == null) return l.gpxNewVoyage;
    for (final entry in _dayLogsByCharter.entries) {
      final day = entry.value.where((d) => d.id == dayLogId).firstOrNull;
      if (day == null) continue;
      final charter = _charters.firstWhere((c) => c.id == entry.key);
      return '${charter.title} · ${DateFormat('d.M.yyyy').format(day.date)}';
    }
    return l.gpxNewVoyage;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: Text(l.gpxImportTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (result == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: ElevatedButton.icon(
                      onPressed: _pickAndParse,
                      icon: const Icon(Icons.file_open_outlined),
                      label: Text(l.gpxImportPickFile),
                    ),
                  ),
                )
              else ...[
                Text('${l.gpxTracksFound}: ${result.tracks.length}'),
                Text('${l.gpxWaypointsFound}: ${result.waypoints.length}'),
                const SizedBox(height: 16),

                for (var i = 0; i < result.tracks.length; i++)
                  Card(
                    child: ListTile(
                      title: Text(result.tracks[i].name ?? 'Track ${i + 1}'),
                      subtitle: Text(
                          '${result.tracks[i].points.length} bodov  ·  ${l.gpxAssignTarget}'),
                      trailing: DropdownButton<int?>(
                        value: _targetDayLogId[i],
                        hint: Text(l.gpxNewVoyage, style: const TextStyle(fontSize: 12)),
                        items: [
                          DropdownMenuItem<int?>(value: null, child: Text(l.gpxNewVoyage)),
                          for (final entry in _dayLogsByCharter.entries)
                            for (final day in entry.value)
                              DropdownMenuItem<int?>(
                                value: day.id,
                                child: Text(_targetLabel(l, day.id), overflow: TextOverflow.ellipsis),
                              ),
                        ],
                        onChanged: (v) => setState(() => _targetDayLogId[i] = v),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _import, child: Text(l.gpxImportButton)),
              ],
            ]),
    );
  }
}
