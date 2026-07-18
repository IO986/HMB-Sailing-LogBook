import 'package:flutter/material.dart';
import '../../../../core/config/ocean_currents_content.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Referenčný zoznam hlavných oceánskych prúdov (orientačné dáta, pozri
/// [oceanCurrents]) – rovnaký vzor ako `MaritimeReferenceScreen`.
class OceanCurrentsScreen extends StatelessWidget {
  const OceanCurrentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(l.oceanCurrentsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: oceanCurrents.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l.oceanCurrentsDisclaimer,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            );
          }
          final c = oceanCurrents[i - 1];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.moving, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(c.name(lang),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    Text('${c.speedKtMin.toStringAsFixed(1)}–'
                        '${c.speedKtMax.toStringAsFixed(1)} kt',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.blue)),
                  ]),
                  const SizedBox(height: 6),
                  Text(c.note(lang), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
