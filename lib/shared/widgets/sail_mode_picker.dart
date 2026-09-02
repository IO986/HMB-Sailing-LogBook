import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Čím loď práve ide — motor, hlavná, genova, refy.
///
/// Viacnásobný výber, lebo na motor s vytiahnutou hlavnou sa pláva bežne
/// a papierový denník to tiež zapíše ako oboje.
///
/// Jeden widget pre ručný záznam aj pre rýchle tlačidlo na mape: kým bol
/// zoznam možností súkromný vo formulári záznamu, rýchly zápis pohon vôbec
/// nezapisoval a stĺpec „Pohon" v PDF ostával pri automatických záznamoch
/// prázdny.
class SailModePicker extends StatelessWidget {
  const SailModePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Set<String> value;
  final ValueChanged<Set<String>> onChanged;

  /// Motor, Genoa, Reef a Autopilot sú medzinárodné a neprekladajú sa;
  /// preklad má len hlavná plachta. Rovnaké kódy idú do stĺpca `sailMode`.
  static const options = <({String value, String label, IconData icon})>[
    (value: 'motor', label: 'Motor', icon: Icons.settings),
    (value: 'main', label: 'Main', icon: Icons.sailing),
    (value: 'genoa', label: 'Genoa', icon: Icons.air),
    (value: 'reef1', label: 'Reef 1', icon: Icons.arrow_downward),
    (value: 'reef2', label: 'Reef 2', icon: Icons.arrow_downward),
    (value: 'autopilot', label: 'Autopilot', icon: Icons.smart_toy),
  ];

  static String labelOf(
          ({String value, String label, IconData icon}) opt, AppLocalizations l) =>
      opt.value == 'main' ? l.sailMain : opt.label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = value.contains(opt.value);
        return FilterChip(
          avatar: Icon(opt.icon,
              size: 15,
              color: selected ? scheme.onPrimaryContainer : scheme.onSurface),
          label: Text(labelOf(opt, l)),
          selected: selected,
          onSelected: (on) {
            final next = {...value};
            if (on) {
              next.add(opt.value);
            } else {
              next.remove(opt.value);
            }
            onChanged(next);
          },
          selectedColor: scheme.primaryContainer,
        );
      }).toList(),
    );
  }
}
