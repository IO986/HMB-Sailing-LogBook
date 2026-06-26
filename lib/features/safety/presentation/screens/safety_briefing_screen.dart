import 'package:flutter/material.dart';
import '../../../../core/config/hmb_handbook.dart';
import '../../../../l10n/app_localizations.dart';

class SafetyBriefingScreen extends StatefulWidget {
  const SafetyBriefingScreen({super.key});

  @override
  State<SafetyBriefingScreen> createState() => _SafetyBriefingScreenState();
}

class _SafetyBriefingScreenState extends State<SafetyBriefingScreen> {
  // Každá sekcia má vlastný checkbox "Prebriefovaná"
  final Map<String, bool> _confirmed = {
    for (final s in SafetyBriefingContent.sections) s.title: false,
  };
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final total = _confirmed.length;
    final done = _confirmed.values.where((v) => v).length;
    final allDone = done == total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Briefing'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('$done/$total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allDone ? Colors.greenAccent : Colors.white70,
                    fontSize: 16,
                  )),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: done / total,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
                allDone ? Colors.green : Theme.of(context).colorScheme.primary),
          ),

          if (allDone)
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).briefingDoneMsg,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ]),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: SafetyBriefingContent.sections.length,
              itemBuilder: (ctx, i) {
                final section = SafetyBriefingContent.sections[i];
                final isExpanded = _expanded.contains(section.title);
                final isConfirmed = _confirmed[section.title] ?? false;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: isConfirmed ? Colors.green.shade50 : null,
                  child: Column(
                    children: [
                      // Header sekcie
                      InkWell(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        onTap: () => setState(() {
                          if (isExpanded) _expanded.remove(section.title);
                          else _expanded.add(section.title);
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(children: [
                            Icon(
                              isConfirmed ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isConfirmed ? Colors.green : Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(section.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isConfirmed ? Colors.green.shade800 : null,
                                  )),
                            ),
                            Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                          ]),
                        ),
                      ),

                      // Obsah sekcie
                      if (isExpanded) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: section.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                                  Expanded(child: Text(item,
                                      style: const TextStyle(fontSize: 14, height: 1.4))),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                        // Potvrdenie sekcie
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: CheckboxListTile(
                            title: Text(
                              isConfirmed ? AppLocalizations.of(context).sectionBriefed : AppLocalizations.of(context).confirmSection,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isConfirmed ? Colors.green : null),
                            ),
                            value: isConfirmed,
                            dense: true,
                            activeColor: Colors.green,
                            onChanged: (v) => setState(() =>
                                _confirmed[section.title] = v ?? false),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
