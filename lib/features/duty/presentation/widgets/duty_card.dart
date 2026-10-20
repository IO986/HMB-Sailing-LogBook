import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../providers/duty_provider.dart';
import '../screens/duty_inspection_screen.dart';
import '../screens/duty_roster_screen.dart';
import '../../domain/crew_member.dart';

/// Crew-on-duty card in the Safety tab.
class DutyCard extends ConsumerWidget {
  const DutyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charterAsync = ref.watch(activeCharterProvider);

    return charterAsync.maybeWhen(
      data: (charter) =>
          charter == null ? const SizedBox.shrink() : _Card(charter: charter),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Card extends ConsumerStatefulWidget {
  final Charter charter;
  const _Card({required this.charter});

  @override
  ConsumerState<_Card> createState() => _CardState();
}

class _CardState extends ConsumerState<_Card> {
  /// Names with a toggle in flight. A second tap before the write lands would
  /// otherwise start (or end) the same duty twice.
  final _busy = <String>{};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final charter = widget.charter;
    final crew = ref.watch(dutyCrewProvider(charter));
    final running = ref.watch(runningDutiesProvider(charter.id)).valueOrNull ??
        const <DutyPeriod>[];
    final runningByName = {for (final d in running) d.crewName: d};
    // Someone renamed in the crew list after coming on duty still has a
    // running row; without this it could never be ended from here.
    final orphans = running
        .where((d) => !crew.any((m) => m.name == d.crewName))
        .map((d) => CrewMember(name: d.crewName, role: d.role))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.visibility, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l.dutyRoster,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            if (running.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${l.dutyRunningChip} ${running.length}',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700)),
              ),
          ]),
          const SizedBox(height: 4),

          if (crew.isEmpty && orphans.isEmpty)
            _NoCrew(charterId: charter.id)
          else ...[
            Text(l.dutyAutoHint,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            for (final m in [...crew, ...orphans])
              _CrewRow(
                member: m,
                duty: runningByName[m.name],
                busy: _busy.contains(m.name),
                onChanged: (on) => _toggle(m, runningByName[m.name], on),
              ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              DutyInspectionScreen(charter: charter))),
                  icon: const Icon(Icons.badge_outlined, size: 18),
                  label: Text(l.dutyInspectionView,
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DutyRosterScreen(charter: charter))),
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: Text(l.dutyRosterHistory,
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  /// Manual on/off for one person. Unlike the automatic start and end with
  /// tracking, these are exceptions worth a line in the logbook, so they go
  /// through the controller methods that write one.
  Future<void> _toggle(CrewMember m, DutyPeriod? duty, bool on) async {
    if (_busy.contains(m.name)) return;
    setState(() => _busy.add(m.name));
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(dutyControllerProvider);
    try {
      if (on && duty == null) {
        await controller.startDuties(
            charterId: widget.charter.id, members: [m]);
      } else if (!on && duty != null) {
        await controller.endDuty(duty);
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy.remove(m.name));
    }
  }
}

class _CrewRow extends StatelessWidget {
  final CrewMember member;
  final DutyPeriod? duty;
  final bool busy;
  final ValueChanged<bool> onChanged;

  const _CrewRow({
    required this.member,
    required this.duty,
    required this.busy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final d = duty;
    final status = d == null
        ? l.dutyOffDuty
        : l.dutySince(
            TimeOfDay.fromDateTime(d.fromUtc.toLocal()).format(context));

    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: d != null,
      onChanged: busy ? null : onChanged,
      title: Text(member.name,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: d == null ? cs.onSurfaceVariant : null)),
      subtitle: Text(
        member.isSkipper ? 'Skipper · $status' : status,
        style: TextStyle(
            fontSize: 12,
            color: d == null ? cs.onSurfaceVariant : Colors.green.shade700),
      ),
    );
  }
}

class _NoCrew extends StatelessWidget {
  final int charterId;
  const _NoCrew({required this.charterId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Names come only from the charter crew, never free text, so without a
    // crew list there is nothing to put on duty.
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.dutyNoCrewDefined,
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 6),
      OutlinedButton.icon(
        // Safety is a tab, not a pushed route, so popping here would do
        // nothing useful — go to the charter's crew form instead.
        onPressed: () => context.push('/logbook/$charterId/edit'),
        icon: const Icon(Icons.group_add, size: 18),
        label: Text(l.dutyDefineCrew),
      ),
    ]);
  }
}
