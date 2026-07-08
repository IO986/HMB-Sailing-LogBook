import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';
import '../../../tracking/providers/tracking_provider.dart';
import '../../../tracking/presentation/widgets/tracking_control_dialogs.dart';
import '../../../../shared/utils/weather_condition_lookup.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class DayLogScreen extends ConsumerStatefulWidget {
  final int charterId;
  final int dayLogId;
  const DayLogScreen({super.key, required this.charterId, required this.dayLogId});

  @override
  ConsumerState<DayLogScreen> createState() => _DayLogScreenState();
}

class _DayLogScreenState extends ConsumerState<DayLogScreen>
   {
  DayLog? _day;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDay();
  }

  Future<void> _loadDay() async {
    final db = ref.read(databaseProvider);
    final days = await db.getDayLogs(widget.charterId);
    try {
      final d = days.firstWhere((d) => d.id == widget.dayLogId);
      setState(() {
        _day = d;
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_day == null) return Scaffold(body: Center(child: Text(AppLocalizations.of(context).dayNotFound)));

    final isTracking = ref.watch(isTrackingProvider);
    final dayName = DateFormat('EEEE d. MMMM yyyy', 'sk').format(_day!.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(dayName, style: const TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => context.go(
                '/logbook/${widget.charterId}/day/${widget.dayLogId}/export'),
          ),
        ],

      ),
      body: _EntriesTab(
            dayLogId: widget.dayLogId,
            charterId: widget.charterId,
            isTracking: isTracking,
            activeDayLogId: GpsTrackingService().activeDayLogId,
          ),
    );
  }

}

// ── Tab 1: Záznamy ────────────────────────────────────────────

class _EntriesTab extends ConsumerWidget {
  final int dayLogId, charterId;
  final bool isTracking;
  final int? activeDayLogId;

  const _EntriesTab({
    required this.dayLogId, required this.charterId,
    required this.isTracking, required this.activeDayLogId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(logbookEntriesForDayProvider(dayLogId));
    final isThisDay = activeDayLogId == dayLogId;

    return entriesAsync.when(
      data: (entries) => CustomScrollView(
        slivers: [
          // Tracking status
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(12),
            child: _TrackingStatusCard(
              isTracking: isTracking,
              isThisDay: isThisDay,
              dayLogId: dayLogId,
            ),
          )),

          // Header záznamy
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Text(AppLocalizations.of(context).recordCount(entries.length),
                  style: TextStyle(fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    context.go('/logbook/$charterId/day/$dayLogId/entry/new'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context).addManual),
              ),
            ]),
          )),

          if (entries.isEmpty)
            SliverFillRemaining(
              child: Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list_alt, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).noEntries, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context).entriesAutoAdded, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )),
            )
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _EntryTile(
                entry: entries[i],
                onDelete: () async {
                  await ref.read(databaseProvider).deleteLogbookEntry(entries[i].id);
                  ref.invalidate(logbookEntriesForDayProvider(dayLogId));
                },
                onTap: () => context.go(
                    '/logbook/$charterId/day/$dayLogId/entry/${entries[i].id}'),
              ),
              childCount: entries.length,
            )),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}

class _TrackingStatusCard extends ConsumerWidget {
  final bool isTracking, isThisDay;
  final int dayLogId;
  const _TrackingStatusCard({
    required this.isTracking, required this.isThisDay, required this.dayLogId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isThisDay) {
      return Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            const Icon(Icons.gps_fixed, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(AppLocalizations.of(context).trackingThisDay,
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
            OutlinedButton.icon(
              onPressed: () => handleStopTap(context, ref),
              icon: const Icon(Icons.stop, size: 16, color: Colors.red),
              label: const Text('Stop', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            ),
          ]),
        ),
      );
    }
    if (isTracking) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Icon(Icons.gps_fixed, color: Colors.orange.shade700, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(AppLocalizations.of(context).trackingOtherDay,
                style: TextStyle(color: Colors.orange.shade700))),
          ]),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ── helpers ───────────────────────────────────────────────────

/// Parse [mode1,mode2] prefix from skipperNote, return (modes, cleanNote)
({Set<String> modes, String note}) _parseNote(String? raw) {
  if (raw == null) return (modes: {}, note: '');
  final m = RegExp(r'^\[([^\]]*)\]\s*').firstMatch(raw);
  if (m == null) return (modes: {}, note: raw);
  return (
    modes: m.group(1)!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet(),
    note: raw.substring(m.end),
  );
}

enum _AnchorKind { none, dropped, raised, driftOut, driftIn }

Widget _modeIcon(Set<String> modes) {
  if (modes.contains('motor') && modes.length == 1) {
    return const _BigIcon(Icons.settings, Colors.orange);
  }
  if (modes.contains('motor')) {
    return const _BigIcon(Icons.settings, Colors.deepOrange);
  }
  return const _BigIcon(Icons.sailing, Colors.blue);
}

class _BigIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _BigIcon(this.icon, this.color);
  @override
  Widget build(BuildContext context) => Icon(icon, size: 32, color: color);
}

// ── Entry tile ────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  final LogbookEntry entry;
  final Future<void> Function() onDelete;
  final VoidCallback onTap;
  const _EntryTile({required this.entry, required this.onDelete, required this.onTap});

  static _AnchorKind _anchorKind(String? note) {
    if (note == null) return _AnchorKind.none;
    if (note.contains('Anchor dropped')) return _AnchorKind.dropped;
    if (note.contains('Anchor raised'))  return _AnchorKind.raised;
    if (note.contains('Drift - perimeter exceeded')) return _AnchorKind.driftOut;
    if (note.contains('Drift - vessel back'))        return _AnchorKind.driftIn;
    return _AnchorKind.none;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = DateFormat('HH:mm');
    final isFirst = entry.skipperNote == 'Voyage start' || entry.skipperNote == 'Začiatok plavby';
    final isLast  = entry.skipperNote == 'Voyage end'   || entry.skipperNote == 'Koniec plavby';
    final isAuto  = entry.isAutoEntry;
    final anchor  = _anchorKind(entry.skipperNote);
    final parsed  = _parseNote(entry.skipperNote);
    final note    = isFirst ? '' : (isLast ? '' : (anchor != _AnchorKind.none ? '' : parsed.note));

    Color? bgColor;
    if (isFirst) bgColor = Colors.green.shade800.withValues(alpha: 0.12);
    if (isLast)  bgColor = Colors.red.shade800.withValues(alpha: 0.12);
    if (anchor == _AnchorKind.driftOut) bgColor = Colors.red.shade800.withValues(alpha: 0.10);
    if (anchor == _AnchorKind.dropped)  bgColor = Colors.blue.shade800.withValues(alpha: 0.08);

    // Photo thumbnail
    final hasPhoto = entry.photoPath != null && File(entry.photoPath!).existsSync();

    return Dismissible(
      key: Key('entry_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.deleteEntryTitle),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.delete),
              ),
            ],
          ),
        ) ?? false;
        if (!confirmed) return false;
        await onDelete();
        return true;
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Left: time + mode icon ──
            SizedBox(width: 52, child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(fmt.format(entry.timestamp.toLocal()),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                if (isFirst)
                  const _BigIcon(Icons.play_arrow, Colors.green)
                else if (isLast)
                  const _BigIcon(Icons.stop, Colors.red)
                else if (anchor == _AnchorKind.dropped)
                  const _BigIcon(Icons.anchor, Colors.blue)
                else if (anchor == _AnchorKind.raised)
                  const _BigIcon(Icons.anchor, Colors.blueGrey)
                else if (anchor == _AnchorKind.driftOut)
                  const _BigIcon(Icons.warning_amber, Colors.red)
                else if (anchor == _AnchorKind.driftIn)
                  const _BigIcon(Icons.check_circle_outline, Colors.orange)
                else if (isAuto)
                  const Icon(Icons.autorenew, size: 26, color: Colors.grey)
                else
                  _modeIcon(parsed.modes),
              ],
            )),

            const SizedBox(width: 10),

            // ── Centre: data ──
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SOG + COG row
                if (entry.sog != null || entry.cog != null)
                  Row(children: [
                    if (entry.sog != null) ...[
                      const Icon(Icons.speed, size: 13, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text('${entry.sog!.toStringAsFixed(1)} kn',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                    ],
                    if (entry.cog != null) ...[
                      const Icon(Icons.navigation, size: 13, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text('${entry.cog!.toStringAsFixed(0)}°',
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ]),

                // Weather icon row
                if (entry.windSpeed != null || entry.waveHeight != null || entry.weatherCondition != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(children: [
                      if (entry.weatherCondition != null) ...[
                        Text(wcEmoji(entry.weatherCondition) ?? '',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                      ],
                      if (entry.windSpeed != null) ...[
                        const Icon(Icons.air, size: 13, color: Colors.blueGrey),
                        const SizedBox(width: 2),
                        Text('${entry.windSpeed!.toStringAsFixed(0)} kn',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                      ],
                      if (entry.waveHeight != null) ...[
                        const Text('🌊', style: TextStyle(fontSize: 12)),
                        Text(' ${entry.waveHeight!.toStringAsFixed(1)} m',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ]),
                  ),

                // Motor + nádrže row
                if (entry.engineHours != null || entry.fuelLevel != null || entry.waterLevel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(children: [
                      if (entry.engineHours != null) ...[
                        const Icon(Icons.settings, size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text('${entry.engineHours!.toStringAsFixed(1)} h',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                      ],
                      if (entry.fuelLevel != null) ...[
                        const Icon(Icons.local_gas_station, size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text('${entry.fuelLevel}%', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                      ],
                      if (entry.waterLevel != null) ...[
                        const Icon(Icons.water_drop, size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text('${entry.waterLevel}%', style: const TextStyle(fontSize: 12)),
                      ],
                    ]),
                  ),

                // Note
                if (note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(note,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                  ),

                // Event labels
                if (isFirst)
                  Text(l.voyageStart, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green))
                else if (isLast)
                  Text(l.voyageEnd, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red))
                else if (anchor == _AnchorKind.dropped)
                  Text('Anchor dropped', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue))
                else if (anchor == _AnchorKind.raised)
                  Text('Anchor raised', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey))
                else if (anchor == _AnchorKind.driftOut)
                  Text('Drift – perimeter exceeded', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade700))
                else if (anchor == _AnchorKind.driftIn)
                  Text('Drift – vessel returned', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange.shade700)),
              ],
            )),

            const SizedBox(width: 8),

            // ── Right: photo thumbnail ──
            if (hasPhoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(File(entry.photoPath!),
                    width: 56, height: 56, fit: BoxFit.cover),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      ),
    );
  }
}

