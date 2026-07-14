import 'package:flutter/material.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

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
