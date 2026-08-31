import 'package:flutter/material.dart';

import '../../core/models/crew_member_ref.dart';

/// Kormidelník — rolovací (horizontálne scrollovateľný) výber z posádky.
///
/// Zdieľané medzi ručným záznamom (`logbook_entry_screen`) a rýchlym
/// tlačidlom na mape (`quick_helmsman_sheet`), aby oba miesta vyzerali aj
/// fungovali rovnako.
class HelmsmanPicker extends StatelessWidget {
  final List<CrewMemberRef> crew;
  final String? selected;
  final ValueChanged<String?> onChanged;
  const HelmsmanPicker({
    super.key,
    required this.crew,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: crew.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final member = crew[i];
        final sel = member.name == selected;
        return ChoiceChip(
          avatar: member.isSkipper
              ? const Icon(Icons.stars, size: 16)
              : null,
          label: Text(member.name),
          selected: sel,
          onSelected: (_) => onChanged(sel ? null : member.name),
        );
      },
    ),
  );
}
