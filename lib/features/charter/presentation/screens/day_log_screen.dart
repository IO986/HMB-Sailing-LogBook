import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/units_service.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/port_autocomplete.dart';
import '../../providers/charter_provider.dart';
import '../../../tracking/providers/tracking_provider.dart';
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

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _vesselCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _distCtrl = TextEditingController();
  final _waveCtrl = TextEditingController();
  final _airTempCtrl = TextEditingController();
  final _waterTempCtrl = TextEditingController();
  int? _bftMorn, _bftNoon, _bftEve;
  String? _seaState, _windDir;


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
        _fromCtrl.text = d.portFrom ?? '';
        _toCtrl.text = d.portTo ?? '';
        _vesselCtrl.text = d.vesselForDay ?? '';
        _noteCtrl.text = d.skipperNote ?? '';
        _distCtrl.text = d.distanceNm > 0 ? d.distanceNm.toStringAsFixed(1) : '';
        _waveCtrl.text = d.waveHeightM?.toStringAsFixed(1) ?? '';
        _airTempCtrl.text = d.airTempC?.toStringAsFixed(1) ?? '';
        _waterTempCtrl.text = d.waterTempC?.toStringAsFixed(1) ?? '';
        _bftMorn = d.beaufortMorning;
        _bftNoon = d.beaufortNoon;
        _bftEve = d.beaufortEvening;
        _seaState = d.seaState;
        _windDir = d.windDirection;
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
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
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

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    await db.updateDayLog(DayLogsCompanion(
      id: Value(_day!.id),
      charterId: Value(_day!.charterId),
      date: Value(_day!.date),
      portFrom: Value(_fromCtrl.text.trim().isEmpty ? null : _fromCtrl.text.trim()),
      portTo: Value(_toCtrl.text.trim().isEmpty ? null : _toCtrl.text.trim()),
      vesselForDay: Value(_vesselCtrl.text.trim().isEmpty ? null : _vesselCtrl.text.trim()),
      distanceNm: Value(double.tryParse(_distCtrl.text) ?? 0),
      beaufortMorning: Value(_bftMorn),
      beaufortNoon: Value(_bftNoon),
      beaufortEvening: Value(_bftEve),
      windDirection: Value(_windDir),
      seaState: Value(_seaState),
      waveHeightM: Value(double.tryParse(_waveCtrl.text)),
      airTempC: Value(double.tryParse(_airTempCtrl.text)),
      waterTempC: Value(double.tryParse(_waterTempCtrl.text)),
      skipperNote: Value(_noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()),
    ));
    ref.invalidate(dayLogsProvider(widget.charterId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).saved), duration: const Duration(seconds: 1)));
    }
  }

  @override
  void dispose() {
    _fromCtrl.dispose(); _toCtrl.dispose(); _vesselCtrl.dispose();
    _noteCtrl.dispose(); _distCtrl.dispose(); _waveCtrl.dispose();
    _airTempCtrl.dispose(); _waterTempCtrl.dispose();
    super.dispose();
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
              onPressed: () => ref.read(trackingNotifierProvider.notifier).stopTracking(),
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

class _EntryTile extends StatelessWidget {
  final LogbookEntry entry;
  final VoidCallback onDelete, onTap;
  const _EntryTile({required this.entry, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    final isFirst = entry.skipperNote == 'Začiatok plavby';
    final isLast = entry.skipperNote == 'Koniec plavby';
    final isAuto = entry.isAutoEntry;

    Color? bgColor;
    IconData noteIcon = Icons.radio_button_unchecked;
    if (isFirst) {
      bgColor = Colors.green.shade800.withOpacity(0.2);
      noteIcon = Icons.play_arrow;
    } else if (isLast) {
      bgColor = Colors.red.shade800.withOpacity(0.2);
      noteIcon = Icons.stop;
    }

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
        final l = AppLocalizations.of(context);
        return await showDialog<bool>(
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
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        tileColor: bgColor,
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isFirst ? Colors.green.shade700
              : isLast ? Colors.red.shade700
              : isAuto ? Theme.of(context).colorScheme.surfaceVariant
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(noteIcon, size: 16,
              color: (isFirst || isLast) ? Colors.white
                  : Theme.of(context).colorScheme.onSurface),
        ),
        title: Row(children: [
          Text(fmt.format(entry.timestamp),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (entry.sog != null)
            Text('${entry.sog!.toStringAsFixed(1)} kn',
                style: const TextStyle(fontSize: 13)),
          if (entry.cog != null)
            Text('  ${entry.cog!.toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ]),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (entry.windSpeed != null)
            Text('💨 ${entry.windSpeed!.toStringAsFixed(0)} kn'
                '${entry.waveHeight != null ? "  🌊 ${entry.waveHeight!.toStringAsFixed(1)} m" : ""}',
                style: const TextStyle(fontSize: 12)),
          if (entry.skipperNote != null && entry.skipperNote!.isNotEmpty)
            Text(entry.skipperNote!,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
        ]),
        trailing: isAuto
            ? Tooltip(message: AppLocalizations.of(context).autoRecord,
                child: const Icon(Icons.autorenew, size: 16, color: Colors.grey))
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ── Tab 2: Detail dňa ─────────────────────────────────────────

class _DetailTab extends StatelessWidget {
  static const _windDirs = ['N','NE','E','SE','S','SW','W','NW'];

  final DayLog day;
  final TextEditingController fromCtrl, toCtrl, vesselCtrl, noteCtrl;
  final TextEditingController distCtrl, waveCtrl, airTempCtrl, waterTempCtrl;
  final int? bftMorn, bftNoon, bftEve;
  final String? seaState, windDir;
  final Function(int?) onBftMornChanged, onBftNoonChanged, onBftEveChanged;
  final Function(String?) onSeaStateChanged, onWindDirChanged;

  const _DetailTab({
    required this.day,
    required this.fromCtrl, required this.toCtrl, required this.vesselCtrl,
    required this.noteCtrl, required this.distCtrl, required this.waveCtrl,
    required this.airTempCtrl, required this.waterTempCtrl,
    required this.bftMorn, required this.bftNoon, required this.bftEve,
    required this.seaState, required this.windDir,
    required this.onBftMornChanged, required this.onBftNoonChanged,
    required this.onBftEveChanged, required this.onSeaStateChanged,
    required this.onWindDirChanged,
  });


  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final seaStates = [
      ('Pokojné', l.seaCalm), ('Mierne', l.seaLight), ('Stredné', l.seaModerate),
      ('Rozbúrené', l.seaRough), ('Búrlivé', l.seaStormy),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Sec(l.routeSection),
        PortAutocomplete(controller: fromCtrl, label: l.fromPort),
        const SizedBox(height: 12),
        PortAutocomplete(controller: toCtrl, label: l.toPort),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: distCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.distance, suffixText: 'NM'),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: vesselCtrl,
            decoration: InputDecoration(labelText: l.vessel),
          )),
        ]),
        const SizedBox(height: 16),

        _Sec(l.weatherSection),
        Row(children: [
          Expanded(child: _BftPicker(l.morning, bftMorn, onBftMornChanged)),
          const SizedBox(width: 8),
          Expanded(child: _BftPicker(l.noon, bftNoon, onBftNoonChanged)),
          const SizedBox(width: 8),
          Expanded(child: _BftPicker(l.evening, bftEve, onBftEveChanged)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(
            value: windDir,
            decoration: InputDecoration(labelText: l.windDir),
            items: _windDirs.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => onWindDirChanged(v),
          )),
          const SizedBox(width: 12),
          Expanded(child: DropdownButtonFormField<String>(
            value: seaState,
            decoration: InputDecoration(labelText: l.seaState),
            items: seaStates.map((s) => DropdownMenuItem(value: s.$1, child: Text(s.$2))).toList(),
            onChanged: (v) => onSeaStateChanged(v),
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: waveCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.waveHeight, suffixText: 'm'),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: airTempCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(labelText: l.airTempLabel, suffixText: '°C'),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: waterTempCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.waterLabel, suffixText: '°C'),
          )),
        ]),
        const SizedBox(height: 16),

        _Sec(l.dailyNote),
        TextField(
          controller: noteCtrl,
          maxLines: 5,
          decoration: InputDecoration(hintText: l.dailyNoteHint),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _Sec extends StatelessWidget {
  final String t;
  const _Sec(this.t);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold)),
  );
}

class _BftPicker extends StatelessWidget {
  final String label;
  final int? value;
  final Function(int?) onChanged;
  const _BftPicker(this.label, this.value, this.onChanged);

  Color _color(int b) {
    if (b <= 3) return Colors.green;
    if (b <= 5) return Colors.orange;
    if (b <= 7) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      DropdownButtonFormField<int>(
        value: value,
        decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
        items: List.generate(13, (i) => DropdownMenuItem(
          value: i,
          child: Text('Bft $i',
              style: TextStyle(color: _color(i), fontWeight: FontWeight.bold)),
        )),
        onChanged: (v) => onChanged(v),
      ),
    ],
  );
}
