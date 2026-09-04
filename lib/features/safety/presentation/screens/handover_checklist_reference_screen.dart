import 'package:flutter/material.dart';
import '../../../charter/services/handover_checklist.dart';
import '../../../../l10n/app_localizations.dart';
import '../../services/custom_safety_items.dart';

/// Prehľad check-in/check-out checklistu z HMB príručky — dostupný mimo
/// konkrétnej plavby, na rozdiel od interaktívneho odovzdávacieho protokolu
/// so zberom podpisov v detaile plavby.
///
/// Rovnaké definície ako protokol, vrátane vlastných položiek: čo si sem
/// skiper dopíše, dostane každý ďalší protokol.
class HandoverChecklistReferenceScreen extends StatefulWidget {
  const HandoverChecklistReferenceScreen({super.key});

  @override
  State<HandoverChecklistReferenceScreen> createState() =>
      _HandoverChecklistReferenceScreenState();
}

class _HandoverChecklistReferenceScreenState
    extends State<HandoverChecklistReferenceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  List<CustomChecklistItem> _own = const [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await CustomSafetyItems.checklistItems();
    if (mounted) setState(() => _own = items);
  }

  Future<void> _add(HandoverCategoryDef category) async {
    final l = AppLocalizations.of(context);
    final code = Localizations.localeOf(context).languageCode;
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.checklistAddOwnItem),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration:
              InputDecoration(hintText: categoryLabel(code, category)),
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
    final items = await CustomSafetyItems.addChecklistItem(category.key, text);
    if (mounted) setState(() => _own = items);
  }

  Future<void> _remove(CustomChecklistItem item) async {
    final items =
        await CustomSafetyItems.removeChecklistItem(item.categoryKey, item.label);
    if (mounted) setState(() => _own = items);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final code = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.handoverChecklistRefTitle),
        bottom: TabBar(controller: _tabCtrl, tabs: [
          Tab(text: l.checkInProtocol),
          Tab(text: l.checkOutProtocol),
        ]),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _ChecklistList(
          categories: checkInCategories,
          localeCode: code,
          own: _own,
          onAdd: _add,
          onRemove: _remove,
        ),
        _ChecklistList(
          categories: checkOutCategories,
          localeCode: code,
          own: _own,
          onAdd: _add,
          onRemove: _remove,
        ),
      ]),
    );
  }
}

class _ChecklistList extends StatelessWidget {
  final List<HandoverCategoryDef> categories;
  final String localeCode;
  final List<CustomChecklistItem> own;
  final void Function(HandoverCategoryDef category) onAdd;
  final void Function(CustomChecklistItem item) onRemove;

  const _ChecklistList({
    required this.categories,
    required this.localeCode,
    required this.own,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in categories)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryLabel(localeCode, category),
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  for (final item in category.items)
                    _Bullet(text: itemLabel(localeCode, item)),
                  // Vlastné položky tejto kategórie — tie isté, aké dostane
                  // každý nový protokol.
                  for (final item
                      in own.where((i) => i.categoryKey == category.key))
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: _Bullet(text: item.label)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        tooltip: l.delete,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onRemove(item),
                      ),
                    ]),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => onAdd(category),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.checklistAddOwnItem),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
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
