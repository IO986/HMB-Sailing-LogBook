import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/config/hmb_handbook.dart';
import '../../../../l10n/app_localizations.dart';

class YachtHandoverScreen extends StatefulWidget {
  final bool isCheckIn;
  const YachtHandoverScreen({super.key, required this.isCheckIn});

  @override
  State<YachtHandoverScreen> createState() => _YachtHandoverScreenState();
}

class _YachtHandoverScreenState extends State<YachtHandoverScreen> {
  Map<String, bool> _checked = {};
  bool _loading = true;

  Map<String, List<String>> get _data => widget.isCheckIn
      ? YachtHandoverChecklist.checkIn
      : YachtHandoverChecklist.checkOut;

  String get _storageKey =>
      widget.isCheckIn ? 'checkin_state' : 'checkout_state';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    final allItems = {
      for (final cat in _data.entries)
        for (final item in cat.value) item: false,
    };
    if (saved != null) {
      final decoded = Map<String, bool>.from(
          (jsonDecode(saved) as Map).map((k, v) => MapEntry(k, v as bool)));
      allItems.addAll(decoded);
    }
    setState(() { _checked = allItems; _loading = false; });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_checked));
  }

  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetChecklistTitle),
        content: Text(l.resetChecklistContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.no)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.reset),
          ),
        ],
      ),
    ) ?? false;
    if (!ok) return;
    setState(() => _checked.updateAll((k, v) => false));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final total = _checked.length;
    final done = _checked.values.where((v) => v).length;
    final allDone = done == total;
    final color = widget.isCheckIn ? Colors.blue : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCheckIn ? AppLocalizations.of(context).checkInReceivingTitle : AppLocalizations.of(context).checkOutHandoverTitle),
        backgroundColor: color,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('$done/$total',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allDone ? Colors.greenAccent : Colors.white70,
                    fontSize: 16))),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: done / total, minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
                allDone ? Colors.green : color),
          ),
          if (allDone)
            Container(
              width: double.infinity, color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  widget.isCheckIn
                      ? AppLocalizations.of(context).checkInCompletedMsg
                      : AppLocalizations.of(context).checkOutCompletedMsg,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ..._data.entries.map((cat) => _CategoryCard(
                  category: cat.key,
                  items: cat.value,
                  checked: _checked,
                  color: color,
                  onToggle: (item, val) async {
                    setState(() => _checked[item] = val);
                    await _save();
                  },
                )),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).reset),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String category;
  final List<String> items;
  final Map<String, bool> checked;
  final Color color;
  final Function(String, bool) onToggle;
  const _CategoryCard({required this.category, required this.items,
      required this.checked, required this.color, required this.onToggle});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final done = widget.items.where((i) => widget.checked[i] ?? false).length;
    final total = widget.items.length;
    final allDone = done == total;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: allDone ? Colors.green.shade50 : null,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Icon(
                  allDone ? Icons.check_circle : Icons.circle_outlined,
                  color: allDone ? Colors.green : widget.color, size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.category,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14,
                        color: allDone ? Colors.green.shade800 : null))),
                // Mini progress
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: allDone ? Colors.green : widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$done/$total',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: allDone ? Colors.white : widget.color)),
                ),
                const SizedBox(width: 4),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20),
              ]),
            ),
          ),
          if (_expanded)
            ...widget.items.map((item) {
              final isDone = widget.checked[item] ?? false;
              return CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                value: isDone,
                activeColor: Colors.green,
                title: Text(item,
                    style: TextStyle(
                        fontSize: 13,
                        color: isDone ? Colors.grey : null,
                        decoration: isDone ? TextDecoration.lineThrough : null)),
                onChanged: (v) => widget.onToggle(item, v ?? false),
              );
            }),
        ],
      ),
    );
  }
}
