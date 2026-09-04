import 'package:flutter/material.dart';
import '../../../../core/config/hmb_handbook.dart';
import '../../../../l10n/app_localizations.dart';
import '../../services/custom_safety_items.dart';

/// Prehľad bezpečnostného brífingu z HMB príručky — dostupný mimo konkrétnej
/// plavby, na rozdiel od interaktívneho brífingu so zberom podpisov posádky
/// v detaile plavby.
///
/// Obsah je ten istý, aký sa zaškrtáva v plavbe, vrátane vlastných bodov:
/// dva rôzne zoznamy pre tú istú vec boli chyba, ktorú skiper nahlásil.
/// Vlastné body sa dajú pridať aj odtiaľto.
class SafetyBriefingReferenceScreen extends StatefulWidget {
  const SafetyBriefingReferenceScreen({super.key});

  @override
  State<SafetyBriefingReferenceScreen> createState() =>
      _SafetyBriefingReferenceScreenState();
}

class _SafetyBriefingReferenceScreenState
    extends State<SafetyBriefingReferenceScreen> {
  List<String> _own = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final points = await CustomSafetyItems.briefingPoints();
    if (mounted) setState(() => _own = points);
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.briefingAddOwnItem),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l.briefingOwnItemHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(l.add)),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    final points = await CustomSafetyItems.addBriefingPoint(text);
    if (mounted) setState(() => _own = points);
  }

  Future<void> _remove(int index) async {
    final points = await CustomSafetyItems.removeBriefingPoint(index);
    if (mounted) setState(() => _own = points);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.safetyBriefingRefTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in SafetyBriefingContent.sectionsFor(locale))
            _SectionCard(
              title: section.title,
              children: [
                for (final item in section.items) _Bullet(text: item),
              ],
            ),
          _SectionCard(
            title: l.safetyOwnPoints,
            children: [
              if (_own.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(l.briefingOwnItemHint,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              for (final e in _own.asMap().entries)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _Bullet(text: e.value)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    tooltip: l.delete,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _remove(e.key),
                  ),
                ]),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l.briefingAddOwnItem),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('•  '),
          Expanded(child: Text(text, style: const TextStyle(height: 1.3))),
        ]),
      );
}
