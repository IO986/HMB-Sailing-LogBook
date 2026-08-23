import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/logbook_event_type.dart';
import '../../../../core/services/units_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/playback_provider.dart';
import '../../services/track_playback.dart';

/// Ovládanie prehrávania zaznamenanej plavby.
///
/// Zobrazí sa len pri zapnutej prehliadke dňa alebo plavby a len keď má
/// prehliadka zaznamenanú trasu — bez bodov nie je čo prehrávať.
class PlaybackBar extends ConsumerWidget {
  const PlaybackBar({super.key});

  /// Násobky, ktoré dávajú zmysel: skutočný čas, svižné prezretie a rýchly
  /// prelet celým dňom (8 h prebehne za 8 minút).
  static const _speeds = [1, 10, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(playbackTrackProvider);
    if (points.isEmpty) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final track = TrackPlayback(points);
    final start = track.start!;
    final end = track.end!;
    final state = ref.watch(playbackProvider);
    final now = state.time ?? start;

    final total = end.difference(start).inMilliseconds;
    final elapsed =
        now.difference(start).inMilliseconds.clamp(0, total == 0 ? 1 : total);

    final fix = track.fixAt(now);
    final entries = ref.watch(playbackEntriesProvider).valueOrNull ?? const [];
    final entry = _entryAt(entries, now);
    final units = ref.watch(unitsSyncProvider);

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            IconButton(
              icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
              tooltip: l.playbackTitle,
              onPressed: () => ref.read(playbackProvider.notifier).togglePlay(),
            ),
            Expanded(
              child: Stack(alignment: Alignment.center, children: [
                // Značky udalostí pod posuvníkom: doskočiť na okamih, keď sa
                // niečo stalo, je vlastne celý zmysel prehrávania v denníku.
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CustomPaint(
                      painter: _EventTicks(
                        events: _eventTimes(entries, start, end),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Slider(
                  value: elapsed.toDouble(),
                  max: (total == 0 ? 1 : total).toDouble(),
                  onChanged: (v) => ref
                      .read(playbackProvider.notifier)
                      .seek(start.add(Duration(milliseconds: v.round()))),
                ),
              ]),
            ),
            for (final s in _speeds)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: _SpeedChip(
                  speed: s,
                  selected: state.speed == s,
                  onTap: () =>
                      ref.read(playbackProvider.notifier).setSpeed(s),
                ),
              ),
          ]),
          const SizedBox(height: 2),
          DefaultTextStyle(
            style: theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
            child: Row(children: [
              Text(DateFormat('HH:mm:ss').format(now.toLocal()),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _readout(fix, entry, units, l),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  static String _readout(PlaybackFix? fix, LogbookEntry? entry,
      UnitsSettings units, AppLocalizations l) {
    final parts = <String>[];
    if (fix?.sog != null) parts.add(units.formatSpeed(fix!.sog));
    if (fix?.cog != null) {
      parts.add('${fix!.cog!.round().toString().padLeft(3, '0')}°');
    }
    if (entry?.windSpeed != null) {
      final dir = entry!.windDirection;
      parts.add(dir == null
          ? units.formatWind(entry.windSpeed)
          : '${units.formatWind(entry.windSpeed)} ${dir.round()}°');
    }
    if (entry?.airPressure != null) {
      parts.add('${entry!.airPressure!.round()} hPa');
    }
    return parts.join('  ·  ');
  }

  /// Záznam denníka platný pre daný okamih — posledný, ktorý mu predchádza.
  ///
  /// Nie najbližší v oboch smeroch: hodnoty zapísané o hodinu neskôr o tejto
  /// chvíli nič nehovoria a v dokladovateľnom zázname sa nemajú tváriť, že áno.
  static LogbookEntry? _entryAt(List<LogbookEntry> entries, DateTime t) {
    LogbookEntry? best;
    for (final e in entries) {
      if (e.timestamp.isAfter(t)) break;
      best = e;
    }
    return best;
  }

  static List<double> _eventTimes(
      List<LogbookEntry> entries, DateTime start, DateTime end) {
    final total = end.difference(start).inMilliseconds;
    if (total <= 0) return const [];
    return [
      for (final e in entries)
        if (e.eventType != null &&
            LogbookEventType.fromCode(e.eventType) != null &&
            !e.timestamp.isBefore(start) &&
            !e.timestamp.isAfter(end))
          e.timestamp.difference(start).inMilliseconds / total,
    ];
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip(
      {required this.speed, required this.selected, required this.onTap});

  final int speed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('${speed}×',
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.bold : null,
              color: selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            )),
      ),
    );
  }
}

/// Zvislé značky udalostí pod posuvníkom.
class _EventTicks extends CustomPainter {
  const _EventTicks({required this.events, required this.color});

  final List<double> events;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 2;
    for (final f in events) {
      final x = size.width * f;
      canvas.drawLine(
          Offset(x, size.height - 4), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_EventTicks old) =>
      old.events.length != events.length || old.color != color;
}
