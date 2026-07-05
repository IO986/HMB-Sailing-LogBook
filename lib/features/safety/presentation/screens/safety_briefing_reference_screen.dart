import 'package:flutter/material.dart';
import '../../../../core/config/hmb_handbook.dart';
import '../../../../l10n/app_localizations.dart';

/// Čisto informačný (read-only) prehľad bezpečnostného brífingu z HMB
/// príručky – dostupný mimo konkrétnej plavby/dňa, na rozdiel od
/// interaktívneho brífingu so zberom podpisov posádky v detaile chartera.
class SafetyBriefingReferenceScreen extends StatelessWidget {
  const SafetyBriefingReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).safetyBriefingRefTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in SafetyBriefingContent.sections)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    for (final item in section.items)
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
      ),
    );
  }
}
