import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../providers/tracking_provider.dart';
import '../../../charter/providers/charter_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

// ── Start Tracking Sheet ──────────────────────────────────────

class TrackingStartSheet extends ConsumerStatefulWidget {
  const TrackingStartSheet({super.key});
  @override
  ConsumerState<TrackingStartSheet> createState() => _TrackingStartSheetState();
}

class _TrackingStartSheetState extends ConsumerState<TrackingStartSheet> {
  // 'existing' | 'new'
  String _mode = 'existing';
  Charter? _selectedCharter;
  int _logInterval = 60;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          Text(l.startVoyage, style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'existing',
                icon: const Icon(Icons.directions_boat),
                label: Text(l.existingVoyage),
              ),
              ButtonSegment(
                value: 'new',
                icon: const Icon(Icons.add),
                label: Text(l.newVoyageForm),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _selectedCharter = null;
            }),
          ),
          const SizedBox(height: 20),

          if (_mode == 'existing') _buildExistingSection(l),
          if (_mode == 'new') _buildNewSection(context, l),

          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _buildExistingSection(AppLocalizations l) {
    final chartersAsync = ref.watch(chartersProvider);
    return chartersAsync.when(
      data: (charters) {
        // Only show charters with SB done for 2nd+ day
        final eligible = charters.where((c) => c.safetyBriefingDone).toList();
        if (eligible.isEmpty) {
          return Column(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  l.firstVoyageHint,
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                )),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/logbook/new');
                },
                icon: const Icon(Icons.add),
                label: Text(l.newVoyageForm),
              ),
            ),
            const SizedBox(height: 8),
          ]);
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DropdownButtonFormField<Charter>(
            decoration: InputDecoration(
              labelText: l.selectExistingVoyage,
              prefixIcon: const Icon(Icons.directions_boat),
            ),
            value: _selectedCharter,
            items: eligible.map((c) => DropdownMenuItem(
              value: c,
              child: Text(
                '${c.title}  '
                '(${DateFormat('d.M.', 'sk').format(c.dateFrom)}–'
                '${DateFormat('d.M.yy', 'sk').format(c.dateTo)})',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            )).toList(),
            onChanged: (c) => setState(() => _selectedCharter = c),
          ),
          if (_selectedCharter != null) ...[
            const SizedBox(height: 12),
            TrackingActiveDayInfo(charter: _selectedCharter!),
          ],
          const SizedBox(height: 16),
          TrackingIntervalSelector(
            value: _logInterval,
            onChanged: (v) => setState(() => _logInterval = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedCharter != null ? () => _startExisting(context) : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(l.startTracking),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 8),
        ]);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
    );
  }

  Widget _buildNewSection(BuildContext context, AppLocalizations l) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.checklist_rtl, color: Colors.blue.shade700),
            const SizedBox(width: 10),
            Expanded(child: Text(
              l.fillFormAndBriefing,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )),
          ]),
          const SizedBox(height: 8),
          Text(
            '• ${l.basicInfo}\n'
            '• ${l.vessel} — MMSI, ${l.callsign}, ${l.vesselLengthM}\n'
            '• ${l.crew}\n'
            '• Safety Briefing + podpisy',
            style: TextStyle(color: Colors.blue.shade700, fontSize: 12, height: 1.6),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            context.go('/logbook/new');
          },
          icon: const Icon(Icons.arrow_forward),
          label: Text(l.newVoyageForm),
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
      ),
      const SizedBox(height: 8),
    ]);
  }

  Future<void> _startExisting(BuildContext context) async {
    final charter = _selectedCharter!;
    final db = ref.read(databaseProvider);

    Navigator.pop(context);

    final today = DateTime.now();
    final days = await db.getDayLogs(charter.id);

    DayLog dayLog;
    final todayLog = days.where((d) =>
        d.date.year == today.year &&
        d.date.month == today.month &&
        d.date.day == today.day).toList();

    if (todayLog.isNotEmpty) {
      dayLog = todayLog.first;
    } else {
      dayLog = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: charter.id,
        date: today,
      ));
      ref.invalidate(dayLogsProvider(charter.id));
    }

    final dayFmt = DateFormat('EEE d.M.', 'sk');
    await ref.read(trackingNotifierProvider.notifier).startTracking(
      '${dayFmt.format(today)}: ${dayLog.portFrom ?? charter.title}',
      dayLogId: dayLog.id,
      logIntervalSeconds: _logInterval,
    );
  }
}

// ── Active Day Info ───────────────────────────────────────────

class TrackingActiveDayInfo extends ConsumerWidget {
  final Charter charter;
  const TrackingActiveDayInfo({super.key, required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(dayLogsProvider(charter.id));
    final today = DateTime.now();
    final l = AppLocalizations.of(context);

    return daysAsync.when(
      data: (days) {
        final totalDays = charter.dateTo.difference(charter.dateFrom).inDays + 1;
        final dayNumber = today.difference(
          DateTime(charter.dateFrom.year, charter.dateFrom.month, charter.dateFrom.day)
        ).inDays + 1;
        final clampedDay = dayNumber.clamp(1, totalDays);

        final todayExists = days.any((d) =>
            d.date.year == today.year &&
            d.date.month == today.month &&
            d.date.day == today.day);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(children: [
            Icon(Icons.today, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(
              '${l.dayNofTotal(clampedDay, totalDays)}  ·  '
              '${DateFormat('EEEE d. MMMM', 'sk').format(today)}'
              '${todayExists ? "" : "  ${l.newDay}"}',
              style: TextStyle(color: Colors.green.shade800,
                  fontWeight: FontWeight.w600, fontSize: 13),
            )),
          ]),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

// ── Interval Selector ─────────────────────────────────────────

class TrackingIntervalSelector extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  const TrackingIntervalSelector({super.key, required this.value, required this.onChanged});

  static const _options = [
    (label: '30 sek', seconds: 30),
    (label: '1 min',  seconds: 60),
    (label: '15 min', seconds: 900),
    (label: '30 min', seconds: 1800),
    (label: '1 hod',  seconds: 3600),
    (label: '2 hod',  seconds: 7200),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.timer, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(l.logFrequency,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ]),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _options.map((opt) {
              final sel = opt.seconds == value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(opt.label),
                  selected: sel,
                  onSelected: (_) => onChanged(opt.seconds),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── End Voyage Dialog ─────────────────────────────────────────

void showTrackingEndVoyageDialog(BuildContext context, WidgetRef ref, int charterId) {
  final l = AppLocalizations.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Row(children: [
        const Icon(Icons.anchor, color: Colors.blue),
        const SizedBox(width: 8),
        Flexible(child: Text(l.endVoyageTitle)),
      ]),
      content: Text(l.endVoyageContent),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(trackingNotifierProvider.notifier).clearEndVoyageDialog();
          },
          child: Text(l.decideLayer),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(trackingNotifierProvider.notifier).extendVoyage(charterId);
          },
          icon: const Icon(Icons.arrow_forward),
          label: Text(l.continuesTomorrow),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(trackingNotifierProvider.notifier).endVoyage(charterId);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          icon: const Icon(Icons.check),
          label: Text(l.endVoyage),
        ),
      ],
    ),
  );
}
