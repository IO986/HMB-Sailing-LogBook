import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/logbook_event_type.dart';
import '../../../../core/models/point_of_sail.dart';
import '../../../../core/models/sail_mode.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/sail_direction_picker.dart';
import '../../../../shared/widgets/sail_mode_picker.dart';

/// Rýchly záznam zmeny pohonu, obratu alebo halzy počas plavby.
///
/// Papierový denník má na prehodenie plachiet ten istý riadok ako na všetko
/// ostatné — skiper doň zapíše, na čom loď ide a nový kurz voči vetru. Tu je
/// to jedno ťuknutie: sheet ponúkne pohon aj siluetu s naposledy zapísanými
/// hodnotami a uloží záznam s GPS a časom, ktoré appka už pozná.
///
/// Pohon je tu z praktického dôvodu: dovtedy ho vedel zapísať len plný
/// formulár záznamu, takže pri plavbe zostával stĺpec „Pohon" prázdny a
/// automatické záznamy nemali čo preberať ďalej.
///
/// Zapisuje sa ako udalosť [LogbookEventType.sailChange], nie ako automatický
/// zápis: obrat rozpozná len človek, appka zmenu kurzu od zámerného obratu
/// nerozlíši.
class QuickSailChangeSheet extends ConsumerStatefulWidget {
  const QuickSailChangeSheet({super.key});

  @override
  ConsumerState<QuickSailChangeSheet> createState() =>
      _QuickSailChangeSheetState();
}

class _QuickSailChangeSheetState extends ConsumerState<QuickSailChangeSheet> {
  SailDirection? _direction;
  Set<String> _modes = {};
  // Stav pri otvorení sheetu — na rozoznanie „len autopilot cvakol" od
  // skutočného prehodenia plachiet, pozri _save().
  SailDirection? _initialDirection;
  Set<String> _initialModes = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadLast();
  }

  /// Predvyplní posledný zapísaný pohon a kurz dňa — pri obrate sa mení
  /// spravidla len bok a pohon vôbec, takže skiper má o ťuknutia menej.
  Future<void> _loadLast() async {
    final dayLogId = GpsTrackingService().activeDayLogId;
    if (dayLogId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final db = ref.read(databaseProvider);
    final last = await db.lastSailDirectionForDay(dayLogId);
    final mode = await db.lastSailModeForDay(dayLogId);
    if (!mounted) return;
    setState(() {
      _direction = last == null
          ? null
          : SailDirection.fromCodes(last.pointOfSail, last.tack);
      _modes = parseSailMode(mode, null).modes;
      _initialDirection = _direction;
      _initialModes = {..._modes};
      _loading = false;
    });
  }

  /// Zápis má zmysel, len keď je čo zapísať — prázdny záznam bez pohonu aj
  /// bez kurzu by v denníku nič nehovoril.
  bool get _canSave => _direction != null || _modes.isNotEmpty;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    // Autopilot nie je prehodenie plachiet — má vlastný typ udalosti, ten
    // istý ako pri automatickom rozpoznaní z NMEA. Rozpozná sa tak, že je to
    // JEDINÁ zmena oproti stavu pri otvorení sheetu (kurz aj ostatný pohon
    // ostali rovnaké); akákoľvek iná zmena popri tom sa naďalej zapíše ako
    // bežné prehodenie plachiet.
    final restCurrent = _modes.where((m) => m != 'autopilot').toSet();
    final restInitial = _initialModes.where((m) => m != 'autopilot').toSet();
    final onlyAutopilotToggled = _direction == _initialDirection &&
        restCurrent.length == restInitial.length &&
        restCurrent.containsAll(restInitial) &&
        _modes.contains('autopilot') != _initialModes.contains('autopilot');

    if (onlyAutopilotToggled) {
      final engaged = _modes.contains('autopilot');
      await GpsTrackingService().createAutomaticLogbookEntry(
        note: engaged ? 'auto' : '',
        event: engaged
            ? LogbookEventType.autopilotOn
            : LogbookEventType.autopilotOff,
        isAutoEntry: false,
      );
      // Zosúlaď automatické sledovanie z NMEA — bez toho by tá istá zmena
      // prijatá krátko nato z prístrojov zapísala duplicitný záznam.
      GpsTrackingService().syncAutopilotState(engaged);
    } else {
      // Autopilot nie je pohon — do stĺpca „Pohon" (sailMode) sa neukladá,
      // nech tam neostane navždy zaseknutý po jednom kombinovanom zápise
      // (samotné neskoršie vypnutie autopilota totiž ide vetvou vyššie,
      // ktorá sailMode vôbec nezapisuje).
      final propulsion = restCurrent;
      await GpsTrackingService().createAutomaticLogbookEntry(
        // Prázdna poznámka, nie 'Auto [...]' — zápis urobil človek a text mu
        // v denníku dopĺňa preložený názov udalosti.
        note: '',
        event: LogbookEventType.sailChange,
        sailDirection: _direction,
        sailMode: propulsion.isEmpty ? null : propulsion.join(','),
        isAutoEntry: false,
      );
    }
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
          Text(l.logEventSailChange,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l.sailDirection,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ))
          else ...[
            Text(l.sailMode, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SailModePicker(
              value: _modes,
              onChanged: (v) => setState(() => _modes = v),
            ),
            const SizedBox(height: 16),
            SailDirectionPicker(
              value: _direction,
              onChanged: (v) => setState(() => _direction = v),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: (_saving || !_canSave) ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(l.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
