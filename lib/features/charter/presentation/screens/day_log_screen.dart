import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/logbook_event_type.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../main.dart';
import '../../../../core/models/bearing_kind.dart';
import '../../../bearing/providers/bearing_provider.dart';
import '../../providers/charter_provider.dart';
import '../../../tracking/providers/tracking_provider.dart';
import '../../../tracking/presentation/widgets/tracking_control_dialogs.dart';
import '../../../../shared/utils/weather_condition_lookup.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import '../../../../core/services/units_service.dart';
import '../../../../core/models/sail_mode.dart';
import '../../../../core/models/point_of_sail.dart';
import '../../../../shared/utils/sail_direction_labels.dart';
import '../../../../shared/utils/auto_entry_note.dart';
import '../../../../core/utils/localized_date.dart';

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
    final dayName = AppDate.of(context, ref).long(_day!.date);

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
            date: _day!.date,
          ),
    );
  }

}

// ── Zamerania dňa ─────────────────────────────────────────────

class _BearingsSection extends ConsumerWidget {
  final int dayLogId;
  const _BearingsSection({required this.dayLogId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final bearings =
        ref.watch(bearingsForDayProvider(dayLogId)).valueOrNull ??
            const <Bearing>[];
    if (bearings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.architecture,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text('${l.bearingsTitle} (${bearings.length})',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
          ]),
          const SizedBox(height: 6),
          for (final b in bearings)
            _BearingRow(
              bearing: b,
              onDelete: () async {
                await ref.read(bearingRepositoryProvider).delete(b.id);
                ref.invalidate(bearingsForDayProvider(dayLogId));
              },
            ),
        ],
      ),
    );
  }
}

class _BearingRow extends StatelessWidget {
  final Bearing bearing;
  final Future<void> Function() onDelete;
  const _BearingRow({required this.bearing, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = bearing.targetName ?? bearing.label;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        // Ikona odlíši, či sa hľadala vlastná poloha, alebo neznámy bod.
        Icon(
          BearingKind.fromCode(bearing.kind) == BearingKind.resection
              ? Icons.person_pin_circle
              : Icons.push_pin_outlined,
          size: 15,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 44,
          child: Text(DateFormat('HH:mm').format(bearing.takenAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '${(bearing.trueBearing.round() % 360).toString().padLeft(3, '0')}°',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            label == null || label.isEmpty ? '—' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.close, size: 16),
          visualDensity: VisualDensity.compact,
          tooltip: l.delete,
        ),
      ]),
    );
  }
}

// ── Tab 1: Záznamy ────────────────────────────────────────────

class _EntriesTab extends ConsumerWidget {
  final int dayLogId, charterId;
  final bool isTracking;
  final int? activeDayLogId;
  final DateTime date;

  const _EntriesTab({
    required this.dayLogId, required this.charterId,
    required this.isTracking, required this.activeDayLogId,
    required this.date,
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

          // Slnko/mesiac tu zámerne nie je — patrí do PDF exportu dňa, kde je
          // súčasťou záznamu. Na obrazovke ho nájdeš v Počasí.

          // Zamerania z námerového kompasu. Nie sú to hodinové záznamy, preto
          // majú vlastnú sekciu a nemiešajú sa medzi riadky denníka.
          SliverToBoxAdapter(child: _BearingsSection(dayLogId: dayLogId)),

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

({Set<String> modes, String note}) _parseEntry(LogbookEntry e) =>
    parseSailMode(e.sailMode, e.skipperNote);

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

class _EntryTile extends ConsumerWidget {
  final LogbookEntry entry;
  final Future<void> Function() onDelete;
  final VoidCallback onTap;
  const _EntryTile({required this.entry, required this.onDelete, required this.onTap});

  /// Anchor events come from the stored event type, not from the note text —
  /// that is what lets the note itself be written in the user's language.
  static _AnchorKind _anchorKind(LogbookEventType? event) {
    switch (event) {
      case LogbookEventType.anchorDropped:
        return _AnchorKind.dropped;
      case LogbookEventType.anchorRaised:
        return _AnchorKind.raised;
      case LogbookEventType.driftOut:
        return _AnchorKind.driftOut;
      case LogbookEventType.driftIn:
        return _AnchorKind.driftIn;
      default:
        return _AnchorKind.none;
    }
  }

  /// Translated label for an automatic entry, or null if it has none.
  ///
  /// MOB is deliberately left as stored: it is the same word at sea in every
  /// language these locales cover.
  static String? _eventLabel(
      LogbookEventType? event, String? note, AppLocalizations l) {
    switch (event) {
      case LogbookEventType.voyageStart:
        return l.voyageStart;
      case LogbookEventType.voyageEnd:
        return l.voyageEnd;
      case LogbookEventType.sailChange:
        return l.logEventSailChange;
      case LogbookEventType.anchorDropped:
        return l.logEventAnchorDropped;
      case LogbookEventType.anchorRaised:
        return l.logEventAnchorRaised;
      case LogbookEventType.driftOut:
        return l.logEventDriftOut;
      case LogbookEventType.driftIn:
        return l.logEventDriftIn;
      case LogbookEventType.dutyStart:
        return l.logEventDutyStart(_crewFromNote(note));
      case LogbookEventType.dutyEnd:
        return l.logEventDutyEnd(_crewFromNote(note));
      case LogbookEventType.autopilotOn:
        return l.logEventAutopilotOn(_autopilotModeLabel(note, l));
      case LogbookEventType.autopilotOff:
        return l.logEventAutopilotOff;
      case LogbookEventType.engineStart:
        return l.logEventEngineStart;
      case LogbookEventType.engineStop:
        return l.logEventEngineStop;
      default:
        return null;
    }
  }

  static Color _eventColor(LogbookEventType? event) {
    switch (event) {
      case LogbookEventType.voyageStart:
        return Colors.green;
      case LogbookEventType.voyageEnd:
        return Colors.red;
      case LogbookEventType.sailChange:
        return Colors.indigo;
      case LogbookEventType.anchorDropped:
        return Colors.blue;
      case LogbookEventType.anchorRaised:
        return Colors.blueGrey;
      case LogbookEventType.driftOut:
        return Colors.red.shade700;
      case LogbookEventType.driftIn:
        return Colors.orange.shade700;
      case LogbookEventType.dutyStart:
        return Colors.teal.shade700;
      case LogbookEventType.dutyEnd:
        return Colors.teal.shade300;
      case LogbookEventType.autopilotOn:
        return Colors.deepPurple.shade400;
      case LogbookEventType.autopilotOff:
        return Colors.deepPurple.shade200;
      case LogbookEventType.engineStart:
        return Colors.brown.shade400;
      case LogbookEventType.engineStop:
        return Colors.brown.shade200;
      default:
        return Colors.grey;
    }
  }

  /// Preklad režimu autopilota. V poznámke záznamu stojí strojový kód
  /// ('auto', 'wind', 'track', …), aby sa dal preložiť aj v cudzom jazyku
  /// a v exporte — presne z toho istého dôvodu ako [LogbookEventType].
  static String _autopilotModeLabel(String? mode, AppLocalizations l) {
    switch (mode?.trim()) {
      case 'wind':
        return l.autopilotModeWind;
      case 'track':
        return l.autopilotModeTrack;
      case 'heading':
        return l.autopilotModeHeading;
      case 'rudder':
        return l.autopilotModeRudder;
      case 'standby':
        return l.autopilotModeStandby;
      default:
        return l.autopilotModeAuto;
    }
  }

  /// The crew name carried in a duty note ('Duty start: Ján Novák').
  static String _crewFromNote(String? note) {
    if (note == null) return '';
    final i = note.indexOf(':');
    return i == -1 ? '' : note.substring(i + 1).trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = DateFormat('HH:mm');
    final event   = LogbookEventType.resolve(entry.eventType, entry.skipperNote);
    final isFirst = event == LogbookEventType.voyageStart;
    final isLast  = event == LogbookEventType.voyageEnd;
    final isAuto  = entry.isAutoEntry;
    final anchor  = _anchorKind(event);
    var eventLabel = _eventLabel(event, entry.skipperNote, l);
    final parsed  = _parseEntry(entry);
    final sailDir = SailDirection.fromCodes(entry.pointOfSail, entry.tack);
    // Pri zmene plachiet je kurz samotnou udalosťou, nie doplnkom — nech
    // stojí rovno v štítku a neopakuje sa o riadok nižšie.
    if (event == LogbookEventType.sailChange && sailDir != null) {
      eventLabel = l.logEventSailChangeTo(sailDirectionPhrase(sailDir, l));
    }
    // Poradie: udalosť má vlastný štítok a poznámku nepotrebuje; strojová
    // značka ('Auto [MODEL]' zo starých záznamov, prázdny text z nových) sa
    // nahradí preloženým „Automatický záznam"; ostatné je text skipera.
    final String note;
    if (eventLabel != null || isFirst || isLast || anchor != _AnchorKind.none) {
      note = '';
    } else if (isMachineAutoNote(parsed.note)) {
      note = autoEntryNoteLabel(
              isAutoEntry: isAuto, note: parsed.note, l: l) ??
          '';
    } else {
      note = parsed.note;
    }

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
                else if (event == LogbookEventType.sailChange)
                  const _BigIcon(Icons.swap_horiz, Colors.indigo)
                // Spôsob plavby má prednosť pred ikonou "automatický
                // záznam" — práve tú informáciu skiper v prehľade hľadá.
                else if (parsed.modes.isNotEmpty)
                  _modeIcon(parsed.modes)
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
                      Text(ref.watch(unitsSyncProvider).formatSpeed(entry.sog),
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

                // Kurz voči vetru — jeden riadok, ako políčko so siluetou
                // v papierovom denníku
                if (sailDir != null && event != LogbookEventType.sailChange)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(children: [
                      Icon(Icons.sailing, size: 13,
                          color: sailDir.tack == Tack.port
                              ? Colors.red.shade700
                              : (sailDir.tack == Tack.starboard
                                  ? Colors.green.shade700
                                  : Colors.blueGrey)),
                      const SizedBox(width: 4),
                      Text(sailDirectionSummary(sailDir, l),
                          style: const TextStyle(fontSize: 12)),
                    ]),
                  ),

                // Weather icon row
                if (entry.windSpeed != null ||
                    entry.waveHeight != null ||
                    entry.depthMeters != null ||
                    entry.weatherCondition != null)
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
                        Text(ref.watch(unitsSyncProvider).formatWind(entry.windSpeed),
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                      ],
                      if (entry.waveHeight != null) ...[
                        const Text('🌊', style: TextStyle(fontSize: 12)),
                        Text(' ${entry.waveHeight!.toStringAsFixed(1)} m',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                      ],
                      // Hĺbka zo sondy — meranie z tej minúty, nie údaj z mapy.
                      if (entry.depthMeters != null) ...[
                        const Icon(Icons.waves, size: 13, color: Colors.teal),
                        const SizedBox(width: 2),
                        Text('${entry.depthMeters!.toStringAsFixed(1)} m',
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
                if (eventLabel != null)
                  Text(eventLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _eventColor(event))),
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

