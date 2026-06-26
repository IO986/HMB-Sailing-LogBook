import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;

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
  String _mode = 'multiday';
  Charter? _selectedCharter;
  bool _creatingNew = false;
  int _logInterval = 60;

  final _newNameCtrl = TextEditingController(
      text: 'Plavba ${DateFormat('MMMM yyyy', 'sk').format(DateTime.now())}');
  int _newDays = 7;

  final _standaloneNameCtrl = TextEditingController();

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

          Text(l.newVoyage, style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'multiday', icon: const Icon(Icons.directions_boat),
                  label: Text(l.multiday)),
              ButtonSegment(value: 'standalone', icon: const Icon(Icons.gps_fixed),
                  label: Text(l.standalone)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _selectedCharter = null;
              _creatingNew = false;
            }),
          ),
          const SizedBox(height: 16),

          if (_mode == 'multiday') _buildMultidaySection(l),

          if (_mode == 'standalone') ...[
            TextField(
              controller: _standaloneNameCtrl,
              decoration: InputDecoration(
                labelText: l.voyageNameOptional,
                hintText: l.voyageNameHint,
                prefixIcon: const Icon(Icons.label),
              ),
            ),
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
              onPressed: _canStart() ? () => _start(context) : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(l.startTracking),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _buildMultidaySection(AppLocalizations l) {
    final chartersAsync = ref.watch(chartersProvider);

    return chartersAsync.when(
      data: (charters) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (charters.isNotEmpty && !_creatingNew) ...[
            DropdownButtonFormField<Charter?>(
              decoration: InputDecoration(
                labelText: l.existingVoyage,
                prefixIcon: const Icon(Icons.directions_boat),
              ),
              value: _selectedCharter,
              items: [
                DropdownMenuItem<Charter?>(
                  value: null,
                  child: Text(l.newVoyageDropdown,
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                ),
                ...charters.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    '${c.title}  '
                    '(${DateFormat('d.M.', 'sk').format(c.dateFrom)}–'
                    '${DateFormat('d.M.yy', 'sk').format(c.dateTo)})',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
              ],
              onChanged: (c) => setState(() {
                _selectedCharter = c;
                _creatingNew = c == null && charters.isNotEmpty;
              }),
            ),
            const SizedBox(height: 12),
          ],

          if (_selectedCharter == null) ...[
            if (charters.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(l.firstVoyageHint,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ),
            TextField(
              controller: _newNameCtrl,
              decoration: InputDecoration(
                labelText: l.voyageName,
                prefixIcon: const Icon(Icons.sailing),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(l.estimatedDays,
                  style: TextStyle(color: Colors.grey.shade700)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _newDays > 2 ? () => setState(() => _newDays--) : null,
              ),
              Text('$_newDays', style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _newDays++),
              ),
            ]),
          ],

          if (_selectedCharter != null) TrackingActiveDayInfo(charter: _selectedCharter!),
        ]);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
    );
  }

  bool _canStart() => true;

  Future<void> _start(BuildContext context) async {
    Navigator.pop(context);
    final db = ref.read(databaseProvider);

    if (_mode == 'standalone') {
      final today = DateTime.now();
      final name = _standaloneNameCtrl.text.trim().isEmpty
          ? 'Plavba ${DateFormat('d.M.yyyy', 'sk').format(today)}'
          : _standaloneNameCtrl.text.trim();
      final charter = await db.insertCharter(ChartersCompanion.insert(
        title: name,
        dateFrom: today,
        dateTo: today,
        createdAt: today,
      ));
      final dayLog = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: charter.id,
        date: today,
      ));
      ref.invalidate(chartersProvider);
      await ref.read(trackingNotifierProvider.notifier).startTracking(
          name, dayLogId: dayLog.id, logIntervalSeconds: _logInterval);
      return;
    }

    Charter charter;

    if (_selectedCharter != null) {
      charter = _selectedCharter!;
    } else {
      final today = DateTime.now();
      charter = await db.insertCharter(ChartersCompanion.insert(
        title: _newNameCtrl.text.trim().isEmpty
            ? 'Plavba ${DateFormat('MMMM yyyy', 'sk').format(today)}'
            : _newNameCtrl.text.trim(),
        dateFrom: today,
        dateTo: today.add(Duration(days: _newDays - 1)),
        createdAt: today,
      ));
      ref.invalidate(chartersProvider);
    }

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

  @override
  void dispose() {
    _newNameCtrl.dispose();
    _standaloneNameCtrl.dispose();
    super.dispose();
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
          margin: const EdgeInsets.only(top: 8),
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
