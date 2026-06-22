import 'package:flutter/material.dart';
import '../../core/config/adriatic_ports.dart';

class PortAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;

  const PortAutocomplete({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (v) => AdriaticPorts.search(v.text),
      onSelected: (s) => controller.text = s,
      fieldViewBuilder: (ctx, ctrl, focusNode, onSubmitted) {
        // Sync external controller
        ctrl.text = controller.text;
        ctrl.addListener(() => controller.text = ctrl.text);
        return TextFormField(
          controller: ctrl,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint ?? 'Zadaj prístav...',
            prefixIcon: const Icon(Icons.anchor),
          ),
        );
      },
      optionsViewBuilder: (ctx, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (ctx, i) {
                final opt = options.elementAt(i);
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, size: 16),
                  title: Text(opt),
                  onTap: () => onSelected(opt),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
