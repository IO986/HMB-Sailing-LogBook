import 'package:flutter/material.dart';

import '../../../../core/services/gps_tracking_service.dart';
import '../../../../l10n/app_localizations.dart';

/// Rýchly manuálny zápis zapnutia/vypnutia autopilota — pre lode bez NMEA
/// dát (žiadny SeaTalk/HTC/APB feed pilota) alebo keď skiper prepne pilota
/// rýchlejšie, než ho stihne potvrdiť automatické sledovanie z prístrojov.
///
/// Rovnaký vzor ako `QuickSailChangeSheet`/`QuickHelmsmanSheet`: žiadny
/// formulár, jedno ťuknutie priamo zapíše záznam.
class QuickAutopilotSheet extends StatefulWidget {
  const QuickAutopilotSheet({super.key});

  @override
  State<QuickAutopilotSheet> createState() => _QuickAutopilotSheetState();
}

class _QuickAutopilotSheetState extends State<QuickAutopilotSheet> {
  bool _saving = false;

  Future<void> _log(bool engaged) async {
    setState(() => _saving = true);
    await GpsTrackingService().logAutopilotManual(engaged);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.autopilotLabel, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saving ? null : () => _log(true),
                icon: const Icon(Icons.smart_toy),
                label: Text(l.quickAutopilotOn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saving ? null : () => _log(false),
                icon: const Icon(Icons.smart_toy_outlined),
                label: Text(l.quickAutopilotOff),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
          ),
        ],
      ),
    );
  }
}
