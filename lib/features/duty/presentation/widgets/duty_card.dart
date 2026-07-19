import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../charter/providers/charter_provider.dart';
import '../../providers/duty_provider.dart';
import '../screens/duty_inspection_screen.dart';
import '../screens/duty_roster_screen.dart';
import 'duty_start_sheet.dart';

/// A duty running for longer than this is probably one somebody forgot to end.
/// Warning only — the app never closes a duty on a timer, because an end time
/// the skipper did not observe is a fabricated record.
const _longDuty = Duration(hours: 12);

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

class _Card extends ConsumerWidget {
  final Charter charter;
  const _Card({required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final crew = ref.watch(dutyCrewProvider(charter));
    final running = ref.watch(runningDutiesProvider(charter.id)).valueOrNull ??
        const <DutyPeriod>[];

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
                child: Text(l.dutyRunningChip,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700)),
              ),
          ]),
          const SizedBox(height: 10),

          if (crew.isEmpty)
            _NoCrew(charterId: charter.id)
          else ...[
            if (running.isEmpty)
              Text(l.dutyNobodyOnDuty,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant))
            else
              ...running.map((d) => _RunningRow(duty: d)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => showDutyStartSheet(context, ref, charter),
                  icon: const Icon(Icons.login, size: 18),
                  label: Text(l.dutyStartAction),
                ),
              ),
            ]),
            const SizedBox(height: 6),
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
}

class _RunningRow extends ConsumerWidget {
  final DutyPeriod duty;
  const _RunningRow({required this.duty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // No ticking clock here: the card is a record of when someone came on
    // duty, not a stopwatch. The long-duty warning is evaluated whenever the
    // card rebuilds, which is often enough for a 12-hour threshold and costs
    // no timer at all.
    final elapsed = DateTime.now().toUtc().difference(duty.fromUtc.toUtc());
    final tooLong = elapsed > _longDuty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(duty.crewName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              l.dutySince(TimeOfDay.fromDateTime(duty.fromUtc.toLocal())
                  .format(context)),
              style: TextStyle(
                  fontSize: 12,
                  color: tooLong
                      ? Colors.orange.shade800
                      : Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            if (tooLong)
              Text(l.dutyLongRunningWarning(elapsed.inHours),
                  style: TextStyle(
                      fontSize: 11, color: Colors.orange.shade800)),
          ]),
        ),
        TextButton(
          // Awaited and caught: an un-awaited future here failed into nothing,
          // so a duty that would not end looked like a dead button.
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await ref.read(dutyControllerProvider).endDuty(duty);
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text('$e')));
            }
          },
          child: Text(l.dutyEndAction),
        ),
      ]),
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
