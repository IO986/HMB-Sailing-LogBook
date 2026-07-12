import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/config/hmb_handbook.dart';
import '../../../../l10n/app_localizations.dart';

class GearListScreen extends StatefulWidget {
  const GearListScreen({super.key});

  @override
  State<GearListScreen> createState() => _GearListScreenState();
}

class _GearListScreenState extends State<GearListScreen> {
  // Zabalené položky
  Map<String, bool> _packed = {};
  // Editovateľné kategórie – kópia z handbook + možnosť pridať
  Map<String, List<String>> _categories = {};
  bool _loading = true;

  static const _stateKey = 'gear_packed_state';
  static const _itemsKey = 'gear_custom_items';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Prekladová mapa: text (kategórie/položky) v KTOROMKOĽVEK jazyku →
  /// text v aktuálnom jazyku. Defaultný zoznam má vo všetkých jazykoch
  /// rovnakú štruktúru, takže sa mapuje podľa pozície.
  static (Map<String, String>, Map<String, String>) _translationMaps(
      String currentLocale) {
    final current = IndividualGearContent.categoriesFor(currentLocale)
        .entries
        .toList();
    final catMap = <String, String>{};
    final itemMap = <String, String>{};
    for (final loc in ['sk', 'en', 'de', 'es', 'uk']) {
      final cats = IndividualGearContent.categoriesFor(loc).entries.toList();
      for (var c = 0; c < cats.length && c < current.length; c++) {
        catMap[cats[c].key] = current[c].key;
        for (var i = 0;
            i < cats[c].value.length && i < current[c].value.length;
            i++) {
          itemMap[cats[c].value[i]] = current[c].value[i];
        }
      }
    }
    return (catMap, itemMap);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final locale =
        mounted ? Localizations.localeOf(context).languageCode : 'sk';

    // Načítaj vlastné položky (ak existujú)
    final savedItems = prefs.getString(_itemsKey);
    if (savedItems != null) {
      final decoded = Map<String, dynamic>.from(jsonDecode(savedItems));
      final saved = decoded.map((k, v) =>
          MapEntry(k, List<String>.from(v as List)));
      // Uložený zoznam vznikol v jazyku, v akom bol vtedy nastavený —
      // defaultné položky premapuj na aktuálny jazyk, vlastné nechaj.
      final (catMap, itemMap) = _translationMaps(locale);
      _categories = {
        for (final e in saved.entries)
          catMap[e.key] ?? e.key: [
            for (final item in e.value) itemMap[item] ?? item
          ],
      };
    } else {
      _categories = Map<String, List<String>>.from(
          IndividualGearContent.categoriesFor(locale).map(
              (k, v) => MapEntry(k, List<String>.from(v))));
    }

    // Načítaj stav zabalenia — kľúče premapuj na aktuálny jazyk a drž len
    // tie, ktoré existujú v zozname (inak by počítadlo rástlo o kľúče
    // zo starého jazyka).
    final savedPacked = prefs.getString(_stateKey);
    _packed = {
      for (final cat in _categories.entries)
        for (final item in cat.value) item: false,
    };
    if (savedPacked != null) {
      final (_, itemMap) = _translationMaps(locale);
      final decoded = (jsonDecode(savedPacked) as Map)
          .map((k, v) => MapEntry(itemMap[k] ?? k as String, v as bool));
      for (final e in decoded.entries) {
        if (_packed.containsKey(e.key)) _packed[e.key] = e.value;
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, jsonEncode(_packed));
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemsKey, jsonEncode(_categories));
  }

  void _addItem(String category) {
    final ctrl = TextEditingController();
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addToCategoryTitle(category)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l.newItemHint),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() {
                  _categories[category]!.add(ctrl.text.trim());
                  _packed[ctrl.text.trim()] = false;
                });
                _saveItems();
                _saveState();
              }
              Navigator.pop(ctx);
            },
            child: Text(l.add),
          ),
        ],
      ),
    );
  }

  void _removeItem(String category, String item) {
    setState(() {
      _categories[category]!.remove(item);
      _packed.remove(item);
    });
    _saveItems();
    _saveState();
  }

  void _addCategory() {
    final ctrl = TextEditingController();
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.newCategory),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Diving'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _categories[ctrl.text.trim()] = []);
                _saveItems();
              }
              Navigator.pop(ctx);
            },
            child: Text(l.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final total = _packed.length;
    final done = _packed.values.where((v) => v).length;
    final allDone = total > 0 && done == total;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).gearListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).reset,
            onPressed: () async {
              setState(() => _packed.updateAll((k, v) => false));
              await _saveState();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('$done/$total',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allDone
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        icon: const Icon(Icons.create_new_folder),
        label: Text(AppLocalizations.of(context).newCategory),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: total > 0 ? done / total : 0,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
                allDone ? Colors.green : Theme.of(context).colorScheme.primary),
          ),
          if (allDone)
            Container(
              width: double.infinity, color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).allPackedMsg,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ]),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
              children: [
                ..._categories.entries.map((cat) => _GearCategory(
                  category: cat.key,
                  items: cat.value,
                  packed: _packed,
                  onToggle: (item, val) async {
                    setState(() => _packed[item] = val);
                    await _saveState();
                  },
                  onAddItem: () => _addItem(cat.key),
                  onRemoveItem: (item) => _removeItem(cat.key, item),
                  onDeleteCategory: _categories[cat.key]!.isEmpty
                      ? () {
                          setState(() => _categories.remove(cat.key));
                          _saveItems();
                        }
                      : null,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GearCategory extends StatefulWidget {
  final String category;
  final List<String> items;
  final Map<String, bool> packed;
  final Function(String, bool) onToggle;
  final VoidCallback onAddItem;
  final Function(String) onRemoveItem;
  final VoidCallback? onDeleteCategory;

  const _GearCategory({
    required this.category, required this.items, required this.packed,
    required this.onToggle, required this.onAddItem,
    required this.onRemoveItem, this.onDeleteCategory,
  });

  @override
  State<_GearCategory> createState() => _GearCategoryState();
}

class _GearCategoryState extends State<_GearCategory> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final done = widget.items.where((i) => widget.packed[i] ?? false).length;
    final total = widget.items.length;
    final allDone = total > 0 && done == total;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: allDone ? Colors.green.shade50 : null,
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Icon(allDone ? Icons.check_circle : Icons.circle_outlined,
                    color: allDone ? Colors.green : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.category,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                        color: allDone ? Colors.green.shade800 : null))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: allDone ? Colors.green : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$done/$total',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                          color: allDone ? Colors.white : Colors.grey.shade700)),
                ),
                const SizedBox(width: 4),
                // Pridať položku
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: widget.onAddItem,
                  color: Theme.of(context).colorScheme.primary,
                ),
                if (widget.onDeleteCategory != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: widget.onDeleteCategory,
                  ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20),
              ]),
            ),
          ),
          if (_expanded)
            ...widget.items.map((item) {
              final isDone = widget.packed[item] ?? false;
              final isWarning = item.startsWith('⚠️');
              return Dismissible(
                key: Key('gear_${widget.category}_$item'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: Colors.red.shade100,
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                confirmDismiss: (_) async {
                  final l = AppLocalizations.of(context);
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.deleteItemTitle),
                      content: Text(item),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l.delete),
                        ),
                      ],
                    ),
                  ) ?? false;
                },
                onDismissed: (_) => widget.onRemoveItem(item),
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 16, right: 8),
                  value: isDone,
                  activeColor: Colors.green,
                  title: Text(item,
                      style: TextStyle(
                          fontSize: 13,
                          color: isWarning ? Colors.orange.shade800 :
                                 isDone ? Colors.grey : null,
                          fontWeight: isWarning ? FontWeight.bold : null,
                          decoration: isDone ? TextDecoration.lineThrough : null)),
                  onChanged: (v) => widget.onToggle(item, v ?? false),
                ),
              );
            }),
          if (_expanded)
            // Pridať položku inline
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: InkWell(
                onTap: widget.onAddItem,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add, size: 16,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context).addItemLabel,
                        style: TextStyle(fontSize: 12,
                            color: Theme.of(context).colorScheme.primary)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
