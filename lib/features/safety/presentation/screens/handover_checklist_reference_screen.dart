import 'package:flutter/material.dart';
import '../../../charter/services/handover_checklist.dart';
import '../../../../l10n/app_localizations.dart';

/// Čisto informačný (read-only) prehľad check-in/check-out checklistu
/// z HMB príručky – dostupný mimo konkrétnej plavby, na rozdiel od
/// interaktívneho odovzdávacieho protokolu so zberom podpisov v detaile
/// chartera.
class HandoverChecklistReferenceScreen extends StatefulWidget {
  const HandoverChecklistReferenceScreen({super.key});

  @override
  State<HandoverChecklistReferenceScreen> createState() =>
      _HandoverChecklistReferenceScreenState();
}

class _HandoverChecklistReferenceScreenState
    extends State<HandoverChecklistReferenceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Rovnaké definície ako interaktívny protokol — SK plne, ostatné
    // jazyky zatiaľ anglicky (itemLabel fallback).
    final code = Localizations.localeOf(context).languageCode;
    Map<String, List<String>> asMap(List<HandoverCategoryDef> cats) => {
          for (final c in cats)
            categoryLabel(code, c): [
              for (final i in c.items) itemLabel(code, i)
            ],
        };
    return Scaffold(
      appBar: AppBar(
        title: Text(l.handoverChecklistRefTitle),
        bottom: TabBar(controller: _tabCtrl, tabs: [
          Tab(text: l.checkInProtocol),
          Tab(text: l.checkOutProtocol),
        ]),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _ChecklistList(categories: asMap(checkInCategories)),
        _ChecklistList(categories: asMap(checkOutCategories)),
      ]),
    );
  }
}

class _ChecklistList extends StatelessWidget {
  final Map<String, List<String>> categories;
  const _ChecklistList({required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in categories.entries)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  for (final item in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(item, style: const TextStyle(height: 1.3))),
                        ],
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
