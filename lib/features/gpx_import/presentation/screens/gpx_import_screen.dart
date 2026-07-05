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
import '../../../charter/presentation/screens/charter_edit_screen.dart' show CharterPrefill;
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
    String? path;
    try {
      // FileType.custom + allowedExtensions zlyháva na niektorých Android
      // zariadeniach (SAF/OEM file manager nevie namapovať príponu na MIME
      // typ, hoci ide o bežnú príponu ako "gpx") – rovnaký problém ako pri
      // obnove zálohy. FileType.any funguje všade, obsah sa validuje nižšie.
      final picked = await FilePicker.platform.pickFiles(type: FileType.any);
      path = picked?.files.single.path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).errorMsg(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }
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
    final l = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
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

      // Tracky bez explicitného cieľa ("nová plavba", default) patria pod
      // JEDNU novú plavbu, aj keď ich je viac – bežný prípad viacdňového
      // GPX exportu (napr. Garmin Explore), kde je každý deň samostatný
      // <trk>. Explicitne priradené tracky (existujúci deň) sa importujú
      // rovno, mimo tohto zoskupenia.
      final newVoyageTracks = <GpxTrack>[];
      for (var i = 0; i < result.tracks.length; i++) {
        final track = result.tracks[i];
        if (track.points.isEmpty) continue;

        final chosen = _targetDayLogId[i];
        if (chosen != null) {
          final entry = _dayLogsByCharter.entries
              .where((e) => e.value.any((d) => d.id == chosen))
              .firstOrNull;
          if (entry == null) continue; // stale selection, skip defensively
          touchedCharterIds.add(entry.key);
          await _importPointsIntoDayLog(db, chosen, track.points, track.name);
        } else {
          newVoyageTracks.add(track);
        }
      }

      if (newVoyageTracks.isNotEmpty) {
        final firstTime = newVoyageTracks
            .map((t) => t.points.first.time ?? DateTime.now())
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final lastTime = newVoyageTracks
            .map((t) => t.points.last.time ?? firstTime)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        final prefill = CharterPrefill(
          title: result.tripName ??
              (newVoyageTracks.length == 1 ? newVoyageTracks.first.name : null) ??
              'Import GPX ${DateFormat('d.M.yyyy').format(firstTime)}',
          dateFrom: firstTime,
          dateTo: lastTime,
        );
        if (mounted) {
          // Otvor skutočný formulár novej plavby a čakaj na výsledok – GPX
          // import tak nikdy ticho nevytvára charter na pozadí. Jeden
          // formulár pre celý batch, nie jeden na track.
          final charter = await context.push<Charter>('/logbook/new', extra: prefill);
          if (charter != null) {
            touchedCharterIds.add(charter.id);

            // Zoskup body naprieč VŠETKÝMI tracks v batchi podľa kalendárneho
            // dňa (jeden track môže aj sám prekročiť polnoc) – jeden DayLog
            // na deň, s jednou SailingSession na pôvodný track v ten deň.
            final byDay = <DateTime, List<(String?, List<GpxTrackPoint>)>>{};
            for (final track in newVoyageTracks) {
              final perTrackDay = <DateTime, List<GpxTrackPoint>>{};
              for (final p in track.points) {
                final t = (p.time ?? DateTime.now()).toLocal();
                final dayKey = DateTime(t.year, t.month, t.day);
                perTrackDay.putIfAbsent(dayKey, () => []).add(p);
              }
              perTrackDay.forEach((dayKey, points) {
                byDay.putIfAbsent(dayKey, () => []).add((track.name, points));
              });
            }

            final sortedDays = byDay.keys.toList()..sort();
            for (final dayKey in sortedDays) {
              final dayLog = await db.insertDayLog(DayLogsCompanion.insert(
                charterId: charter.id,
                date: dayKey,
              ));
              for (final (trackName, points) in byDay[dayKey]!) {
                await _importPointsIntoDayLog(db, dayLog.id, points, trackName);
              }
            }
          }
        }
      }

      ref.invalidate(chartersProvider);
      for (final id in touchedCharterIds) {
        ref.invalidate(dayLogsProvider(id));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.gpxImportSuccess)));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.errorMsg(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _importPointsIntoDayLog(
    AppDatabase db, int dayLogId, List<GpxTrackPoint> points, String? trackName,
  ) async {
    if (points.isEmpty) return;
    var nm = 0.0;
    for (var p = 1; p < points.length; p++) {
      nm += DistanceCalculator.distanceNm(
        points[p - 1].lat, points[p - 1].lon,
        points[p].lat, points[p].lon,
      );
    }

    final sessionId = const Uuid().v4();
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: sessionId,
      dayLogId: Value(dayLogId),
      startTime: points.first.time ?? DateTime.now(),
      endTime: Value(points.last.time),
      name: Value(trackName),
      totalDistanceNm: Value(nm),
      isActive: const Value(false),
    ));
    await db.insertTrackPointsBatch([
      for (final p in points)
        TrackPointsCompanion.insert(
          sessionId: Value(sessionId),
          timestamp: p.time ?? DateTime.now(),
          latitude: p.lat,
          longitude: p.lon,
          altitude: Value(p.ele),
        ),
    ]);

    // DayLogs.distanceNm sa inak dopočíta len pri exporte (fallback) –
    // zapíš ju rovno, nech sa nová plavba prejaví okamžite v Knihe míľ.
    final day = await db.getDayLogById(dayLogId);
    if (day != null && day.distanceNm == 0) {
      await db.updateDayLog(DayLogsCompanion(
        id: Value(dayLogId),
        distanceNm: Value(nm),
      ));
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
