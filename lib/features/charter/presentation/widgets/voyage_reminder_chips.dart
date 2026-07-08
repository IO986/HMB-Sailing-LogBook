import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/voyage_progress.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Non-blocking "what's still missing" chips for a voyage — replaces the
/// old single "what's next" banner. Several can show at once (a voyage
/// started mid-sail may be missing check-in, briefing and vessel details
/// simultaneously); tapping one jumps straight to that form. Nothing here
/// ever blocks Start/Stop or using the logbook.
class VoyageReminderChips extends ConsumerWidget {
  final int charterId;
  const VoyageReminderChips({super.key, required this.charterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(voyageProgressProvider(charterId));
    final l = AppLocalizations.of(context);

    return progressAsync.when(
      data: (progress) {
        final reminders = progress.reminders;
        if (reminders.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: reminders.map((r) {
              final (label, path) = switch (r) {
                VoyageReminder.checkIn =>
                  (l.missingCheckInChip, '/logbook/$charterId/handover/checkIn'),
                VoyageReminder.briefing =>
                  (l.missingBriefingChip, '/logbook/$charterId/briefing'),
                VoyageReminder.details =>
                  (l.missingDetailsChip, '/logbook/$charterId/edit'),
                VoyageReminder.checkOut =>
                  (l.missingCheckOutChip, '/logbook/$charterId/handover/checkOut'),
              };
              return ActionChip(
                label: Text(label, style: const TextStyle(fontSize: 11)),
                avatar: Icon(Icons.info_outline, size: 14, color: Colors.orange.shade800),
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
                onPressed: () => context.go(path),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
