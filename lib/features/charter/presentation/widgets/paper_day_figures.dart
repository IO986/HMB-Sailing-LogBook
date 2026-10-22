import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../logbook/services/estimated_track_builder.dart';

/// Miles and night hours of a day as the paper logbook gives them, plus the
/// button that draws the day's track through its entries.
///
/// Shown only for voyages written after the fact. A paper log has a miles
/// figure per day and often night hours, but nothing the app could compute
/// them from, so the skipper types them in; a figure typed in always wins
/// over a computed one.
class PaperDayFigures extends ConsumerWidget {
  final DayLog day;

  /// Called after the figures or the track changed, so the screen reloads.
  final VoidCallback onChanged;

  const PaperDayFigures({super.key, required this.day, required this.onChanged});

  static double? _parse(String text) {
    final t = text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final estimate = await EstimatedTrackBuilder.straightLineNm(db, day.id);
    if (!context.mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _FiguresDialog(day: day, straightLineNm: estimate),
    );
    if (saved == true) onChanged();
  }

  Future<void> _buildTrack(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final result =
        await EstimatedTrackBuilder.rebuildForDay(ref.read(databaseProvider), day.id);
    if (!context.mounted) return;

    final message = switch (result.outcome) {
      EstimatedTrackOutcome.built => l.trackBuiltFromEntries,
      EstimatedTrackOutcome.needsTwoEntries => l.trackNeedsTwoEntries,
      EstimatedTrackOutcome.realTrackExists => l.trackRealExists,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    onChanged();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final miles =
        day.distanceNm > 0 ? '${day.distanceNm.toStringAsFixed(1)} NM' : '—';
    final night = day.nightHoursManual == null
        ? '—'
        : '${day.nightHoursManual!.toStringAsFixed(1)} h';

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.edit_note, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l.dayFiguresTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              key: const ValueKey('day-figures-edit'),
              icon: const Icon(Icons.edit, size: 18),
              tooltip: l.edit,
              onPressed: () => _edit(context, ref),
            ),
          ]),
          Text('${l.dayMilesLabel}: $miles   ·   ${l.nightHoursLabel}: $night'),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('day-figures-build-track'),
              onPressed: () => _buildTrack(context, ref),
              icon: const Icon(Icons.timeline, size: 18),
              label: Text(l.buildTrackFromEntries),
            ),
          ),
        ]),
      ),
    );
  }
}

class _FiguresDialog extends ConsumerStatefulWidget {
  final DayLog day;
  final double straightLineNm;
  const _FiguresDialog({required this.day, required this.straightLineNm});

  @override
  ConsumerState<_FiguresDialog> createState() => _FiguresDialogState();
}

class _FiguresDialogState extends ConsumerState<_FiguresDialog> {
  late final _miles = TextEditingController(
      text: widget.day.distanceNm > 0
          ? widget.day.distanceNm.toStringAsFixed(1)
          : '');
  late final _night = TextEditingController(
      text: widget.day.nightHoursManual?.toStringAsFixed(1) ?? '');
  String? _milesError, _nightError;

  @override
  void dispose() {
    _miles.dispose();
    _night.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final milesText = _miles.text.trim();
    final nightText = _night.text.trim();
    final miles = PaperDayFigures._parse(milesText);
    final night = PaperDayFigures._parse(nightText);

    final milesBad =
        milesText.isNotEmpty && (miles == null || miles < 0 || miles > 5000);
    final nightBad =
        nightText.isNotEmpty && (night == null || night < 0 || night > 24);
    setState(() {
      _milesError = milesBad ? l.numberInvalid : null;
      _nightError = nightBad ? l.numberInvalid : null;
    });
    if (milesBad || nightBad) return;

    await ref
        .read(databaseProvider)
        .setDayFigures(widget.day.id, distanceNm: miles ?? 0, nightHours: night);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const numeric = TextInputType.numberWithOptions(decimal: true);

    return AlertDialog(
      title: Text(l.dayFiguresTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            key: const ValueKey('day-figures-miles'),
            controller: _miles,
            keyboardType: numeric,
            decoration: InputDecoration(
              labelText: l.dayMilesLabel,
              suffixText: 'NM',
              errorText: _milesError,
              helperText: widget.straightLineNm > 0
                  ? '${l.straightLineLabel}: '
                      '${widget.straightLineNm.toStringAsFixed(1)} NM'
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('day-figures-night'),
            controller: _night,
            keyboardType: numeric,
            decoration: InputDecoration(
              labelText: l.nightHoursLabel,
              suffixText: 'h',
              errorText: _nightError,
              helperText: l.dayFiguresHint,
              helperMaxLines: 3,
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel)),
        ElevatedButton(onPressed: _save, child: Text(l.save)),
      ],
    );
  }
}
