import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/crew_member.dart';
import '../../domain/duty_rules.dart';
import '../../providers/duty_provider.dart';

/// Full duty roster: what has been recorded, plus the way to fill in a duty
/// after the fact.
class DutyRosterScreen extends ConsumerWidget {
  final Charter charter;
  const DutyRosterScreen({super.key, required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final dutiesAsync = ref.watch(charterDutiesProvider(charter.id));

    return Scaffold(
      appBar: AppBar(title: Text(l.dutyRosterHistory)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.dutyAddRetrospective),
      ),
      body: dutiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (duties) {
          if (duties.isEmpty) {
            return Center(child: Text(l.dutyNoRecords));
          }
          final sorted = sortForDisplay(
              duties.map((d) => d.toInterval()).toList());
          final byId = {for (final d in duties) d.id: d};

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: sorted.length,
            itemBuilder: (_, i) => _DutyTile(
              duty: byId[sorted[i].id]!,
              charter: charter,
            ),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {DutyPeriod? existing}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DutyForm(charter: charter, existing: existing),
    );
  }
}

class _DutyTile extends ConsumerWidget {
  final DutyPeriod duty;
  final Charter charter;
  const _DutyTile({required this.duty, required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmtDay = DateFormat('E d.M.');
    final fmtTime = DateFormat('HH:mm');
    final from = duty.fromUtc.toLocal();
    final to = duty.toUtc?.toLocal();

    return ListTile(
      leading: Icon(
        duty.toUtc == null ? Icons.play_circle : Icons.check_circle_outline,
        color: duty.toUtc == null ? Colors.green : Colors.grey,
      ),
      title: Text(duty.crewName),
      subtitle: Text(
        '${fmtDay.format(from)}  ${fmtTime.format(from)} – '
        '${to == null ? l.dutyToOngoing : fmtTime.format(to)}'
        '${duty.isAutoClosed ? '  ·  auto' : ''}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          if (v == 'edit') {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => _DutyForm(charter: charter, existing: duty),
            );
          } else if (v == 'delete') {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l.dutyDeleteTitle),
                content: Text(l.dutyDeleteConfirm(duty.crewName)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l.no)),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l.delete)),
                ],
              ),
            );
            if (ok == true) {
              await ref.read(dutyControllerProvider).deleteDuty(duty.id);
            }
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(l.edit)),
          PopupMenuItem(value: 'delete', child: Text(l.delete)),
        ],
      ),
    );
  }
}

/// Add or edit a duty period.
class _DutyForm extends ConsumerStatefulWidget {
  final Charter charter;
  final DutyPeriod? existing;
  const _DutyForm({required this.charter, this.existing});

  @override
  ConsumerState<_DutyForm> createState() => _DutyFormState();
}

class _DutyFormState extends ConsumerState<_DutyForm> {
  CrewMember? _member;
  late DateTime _day;
  late TimeOfDay _from;
  TimeOfDay? _to;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final from = (e?.fromUtc ?? DateTime.now().toUtc()).toLocal();
    _day = DateTime(from.year, from.month, from.day);
    _from = TimeOfDay.fromDateTime(from);
    _to = e?.toUtc == null ? null : TimeOfDay.fromDateTime(e!.toUtc!.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final crew = ref.watch(dutyCrewProvider(widget.charter));
    final editing = widget.existing != null;
    _member ??= editing
        ? crew.firstWhere((m) => m.name == widget.existing!.crewName,
            orElse: () => CrewMember(name: widget.existing!.crewName))
        : null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(editing ? l.dutyEditTitle : l.dutyAddRetrospective,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Names come only from the charter crew — never free text.
          DropdownButtonFormField<CrewMember>(
            initialValue: _member,
            decoration: InputDecoration(labelText: l.dutySelectPerson),
            items: crew
                .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                .toList(),
            onChanged: (m) => setState(() => _member = m),
          ),
          const SizedBox(height: 8),

          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(DateFormat('EEEE d. M. yyyy').format(_day)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _day,
                firstDate: widget.charter.dateFrom
                    .subtract(const Duration(days: 1)),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _day = picked);
            },
          ),
          Row(children: [
            Expanded(
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(l.dutyFrom),
                subtitle: Text(_from.format(context)),
                onTap: () async {
                  final p = await showTimePicker(
                      context: context, initialTime: _from);
                  if (p != null) setState(() => _from = p);
                },
              ),
            ),
            Expanded(
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(l.dutyTo),
                // No end time deliberately creates a running duty — the
                // "I came on watch an hour ago" case.
                subtitle: Text(_to?.format(context) ?? l.dutyToOngoing),
                onTap: () async {
                  final p = await showTimePicker(
                      context: context, initialTime: _to ?? TimeOfDay.now());
                  if (p != null) setState(() => _to = p);
                },
                trailing: _to == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _to = null),
                      ),
              ),
            ),
          ]),

          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 13)),
          ],
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _member == null || _saving ? null : _submit,
              child: Text(l.save),
            ),
          ),
        ]),
      ),
    );
  }

  DateTime _combine(TimeOfDay t) =>
      DateTime(_day.year, _day.month, _day.day, t.hour, t.minute);

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });

    final fromUtc = _combine(_from).toUtc();
    // An end earlier on the clock than the start means the duty ran past
    // midnight, which is the normal night watch.
    var toUtc = _to == null ? null : _combine(_to!).toUtc();
    if (toUtc != null && !toUtc.isAfter(fromUtc)) {
      toUtc = toUtc.add(const Duration(days: 1));
    }

    final controller = ref.read(dutyControllerProvider);
    final error = await controller.validate(
      charterId: widget.charter.id,
      candidate: DutyInterval(
        id: widget.existing?.id,
        crewName: _member!.name,
        fromUtc: fromUtc,
        toUtc: toUtc,
      ),
    );

    if (error != null) {
      setState(() {
        _saving = false;
        _error = switch (error) {
          DutyValidationError.endBeforeStart => l.dutyErrorEndBeforeStart,
          DutyValidationError.futureStart => l.dutyErrorFutureStart,
          DutyValidationError.overlapSamePerson =>
            l.dutyErrorOverlap(_member!.name),
        };
      });
      return;
    }

    if (widget.existing != null) {
      await controller.editDuty(
          id: widget.existing!.id, fromUtc: fromUtc, toUtc: toUtc);
    } else {
      await controller.addRetrospective(
        charterId: widget.charter.id,
        member: _member!,
        fromUtc: fromUtc,
        toUtc: toUtc,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}
