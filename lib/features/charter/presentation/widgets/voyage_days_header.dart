import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// The line above the list of days: how many there are, add a day (voyages
/// written after the fact) and delete several at once.
///
/// Bulk delete is an icon with a tooltip, not a labelled button. With a label
/// the three items did not fit a narrow phone and the row overflowed by tens
/// of pixels; the title is shortened with an ellipsis instead of overflowing.
class VoyageDaysHeader extends StatelessWidget {
  final int dayCount;
  final bool canAddDay;
  final VoidCallback onAddDay;
  final VoidCallback onBulkDelete;

  const VoyageDaysHeader({
    super.key,
    required this.dayCount,
    required this.canAddDay,
    required this.onAddDay,
    required this.onBulkDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(children: [
        Expanded(
          child: Text(l.voyageDaysCount(dayCount),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        if (canAddDay)
          TextButton.icon(
            onPressed: onAddDay,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l.addDay),
            // Tesné odsadenie: v gréčtine a taliančine sa popisok na 320 dp
            // inak nezmestil o pár pixelov.
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        if (dayCount > 1)
          IconButton(
            onPressed: onBulkDelete,
            icon: const Icon(Icons.delete_sweep),
            tooltip: l.bulkDelete,
            color: Colors.red,
          ),
      ]),
    );
  }
}
