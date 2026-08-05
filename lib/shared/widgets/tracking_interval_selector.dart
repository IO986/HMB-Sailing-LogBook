import 'package:flutter/material.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class TrackingIntervalSelector extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  const TrackingIntervalSelector({super.key, required this.value, required this.onChanged});

  static const _options = [30, 60, 900, 1800, 3600, 7200];

  /// Labels used to be hard-coded Slovak ('30 sek', '1 hod'), which every
  /// other language got to see as well. Derived from the value instead, so a
  /// new interval needs no new string.
  static String _label(AppLocalizations l, int seconds) => switch (seconds) {
        < 60 => l.intervalSeconds(seconds),
        < 3600 => l.intervalMinutes(seconds ~/ 60),
        _ => l.intervalHours(seconds ~/ 3600),
      };

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
        // Časy pod seba (nie v horizontálnom scrolle vedľa seba) — všetky
        // možnosti sú tak viditeľné naraz, netreba rolovať.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _options.map((seconds) {
            final sel = seconds == value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ChoiceChip(
                label: Text(_label(l, seconds)),
                selected: sel,
                onSelected: (_) => onChanged(seconds),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
