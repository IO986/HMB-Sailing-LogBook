import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/crew_member_ref.dart';
import '../../../../core/models/logbook_event_type.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/helmsman_picker.dart';

/// Rýchly záznam „kto drží kormidlo" počas plavby.
///
/// Rovnaký vzor ako `QuickSailChangeSheet`: jedno ťuknutie namiesto
/// otvárania plného formulára záznamu. Posádka sa berie z charteru
/// aktívneho dňa, rovnako ako v `logbook_entry_screen`.
class QuickHelmsmanSheet extends ConsumerStatefulWidget {
  const QuickHelmsmanSheet({super.key});

  @override
  ConsumerState<QuickHelmsmanSheet> createState() =>
      _QuickHelmsmanSheetState();
}

class _QuickHelmsmanSheetState extends ConsumerState<QuickHelmsmanSheet> {
  List<CrewMemberRef> _crew = [];
  String? _selected;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCrew();
  }

  Future<void> _loadCrew() async {
    final dayLogId = GpsTrackingService().activeDayLogId;
    if (dayLogId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final db = ref.read(databaseProvider);
    final dayLog = await db.getDayLogById(dayLogId);
    if (dayLog == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final charter = await db.getCharterById(dayLog.charterId);
    if (!mounted) return;
    final crew = charter == null
        ? const <CrewMemberRef>[]
        : CrewMemberRef.parse(
            charter.crewJson,
            skipperName: charter.skipperName,
            crewNames: charter.crewNames,
          );
    setState(() {
      _crew = crew;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    await GpsTrackingService().createAutomaticLogbookEntry(
      note: '',
      event: LogbookEventType.helmsmanChange,
      skipperName: _selected,
      isAutoEntry: false,
    );
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
          Text(l.helmsmanLabel, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ))
          else if (_crew.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l.crewListEmpty,
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            HelmsmanPicker(
              crew: _crew,
              selected: _selected,
              onChanged: (v) => setState(() => _selected = v),
            ),
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
                onPressed: (_saving || _selected == null) ? null : _save,
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
