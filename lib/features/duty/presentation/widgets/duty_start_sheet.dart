import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/duty_provider.dart';

/// Puts one or more crew members on duty.
///
/// Several people may come on duty at the same moment, which writes one row
/// each — they can then go off independently.
Future<void> showDutyStartSheet(
    BuildContext context, WidgetRef ref, Charter charter) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DutyStartSheet(charter: charter),
  );
}

class _DutyStartSheet extends ConsumerStatefulWidget {
  final Charter charter;
  const _DutyStartSheet({required this.charter});

  @override
  ConsumerState<_DutyStartSheet> createState() => _DutyStartSheetState();
}

class _DutyStartSheetState extends ConsumerState<_DutyStartSheet> {
  final _selected = <String>{};
  TimeOfDay? _startTime;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final crew = ref.watch(dutyCrewProvider(widget.charter));
    final running =
        ref.watch(runningDutiesProvider(widget.charter.id)).valueOrNull ??
            const <DutyPeriod>[];
    final onDuty = running.map((d) => d.crewName).toSet();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l.dutyStartTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: crew.map((m) {
                final already = onDuty.contains(m.name);
                return CheckboxListTile(
                  dense: true,
                  // Somebody already on duty cannot be started again; the
                  // overlap rule would reject it anyway.
                  value: already || _selected.contains(m.name),
                  onChanged: already
                      ? null
                      : (v) => setState(() => v == true
                          ? _selected.add(m.name)
                          : _selected.remove(m.name)),
                  title: Text(m.name),
                  subtitle: already
                      ? Text(l.dutyRunningChip,
                          style: const TextStyle(fontSize: 11))
                      : (m.isSkipper
                          ? const Text('Skipper',
                              style: TextStyle(fontSize: 11))
                          : null),
                );
              }).toList(),
            ),
          ),

          const Divider(),
          // Defaults to now, adjustable for "I meant to press this 20 min ago".
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(l.dutyFrom),
            trailing: Text(
                (_startTime ?? TimeOfDay.now()).format(context),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            onTap: () async {
              final picked = await showTimePicker(
                  context: context, initialTime: _startTime ?? TimeOfDay.now());
              if (picked != null) setState(() => _startTime = picked);
            },
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              // Disabled while saving: a double tap would otherwise write two
              // rows for one person and slip past the overlap check.
              onPressed: _selected.isEmpty || _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.dutyStartAction),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final crew = ref.read(dutyCrewProvider(widget.charter));
    final members =
        crew.where((m) => _selected.contains(m.name)).toList(growable: false);

    DateTime? at;
    if (_startTime != null) {
      final now = DateTime.now();
      at = DateTime(
          now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
      // A time later than now means the user meant yesterday evening.
      if (at.isAfter(now)) at = at.subtract(const Duration(days: 1));
    }

    await ref.read(dutyControllerProvider).startDuties(
          charterId: widget.charter.id,
          members: members,
          at: at,
        );
    if (mounted) Navigator.of(context).pop();
  }
}
