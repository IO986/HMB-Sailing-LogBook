import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/location_quality_badge.dart';

/// Rýchla poznámka do denníka počas plavby.
///
/// To isté, čo rýchla fotka, len bez fotky: skiper napíše vetu a záznam sa
/// uloží so všetkým, čo appka v tej chvíli vie — poloha, čas, rýchlosť a kurz,
/// vietor, tlak, teploty, hĺbka, pohon a kurz voči vetru. Na kormidle nie je
/// čas otvárať plný formulár a písať to po jednom.
class QuickNoteSheet extends ConsumerStatefulWidget {
  const QuickNoteSheet({super.key});

  @override
  ConsumerState<QuickNoteSheet> createState() => _QuickNoteSheetState();
}

class _QuickNoteSheetState extends ConsumerState<QuickNoteSheet> {
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  /// Poloha sa ukáže z chvíle otvorenia sheetu — kým skiper píše, môže prísť
  /// čerstvejší aj horší fix, a badge má hovoriť o tom, čo videl.
  late final _pos =
      GpsTrackingService().lastPosition ?? LocationService().lastPosition;
  late final _locationSource =
      _pos != null ? LocationService().lastSource?.name : null;
  late final _isMocked = _pos != null ? LocationService().lastIsMocked : null;
  final _openedAt = DateTime.now().toUtc();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;
    setState(() => _saving = true);

    // Ten istý zápis, aký robí automatický záznam — vrátane počasia, hĺbky
    // a pohonu. `isAutoEntry: false`, lebo vetu napísal človek: v denníku aj
    // v exporte to má stáť ako záznam skipera, nie ako riadok od appky.
    await GpsTrackingService()
        .createAutomaticLogbookEntry(note: note, isAutoEntry: false);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.quickNoteTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          LocationQualityBadge(
            accuracyMeters:
                (_pos != null && _pos.accuracy > 0) ? _pos.accuracy : null,
            locationSource: _locationSource,
            isMocked: _isMocked,
            timestamp: _openedAt,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(hintText: l.quickNoteHint),
            autofocus: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: (_saving || _noteCtrl.text.trim().isEmpty) ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(l.save),
            ),
          ]),
        ],
      ),
    );
  }
}
