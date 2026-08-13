import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/database/app_database.dart';
import '../../providers/map_provider.dart';
import '../../../../l10n/app_localizations.dart';

class WaypointDialog extends ConsumerStatefulWidget {
  final LatLng latLng;
  final Waypoint? existing;
  const WaypointDialog({super.key, required this.latLng, this.existing});

  @override
  ConsumerState<WaypointDialog> createState() => _WaypointDialogState();
}

class _WaypointDialogState extends ConsumerState<WaypointDialog> {
  late final _nameCtrl =
      TextEditingController(text: widget.existing?.name ?? '');

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              isEdit
                  ? AppLocalizations.of(context).editWaypoint
                  : AppLocalizations.of(context).addWaypoint,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '${widget.latLng.latitude.toStringAsFixed(5)}°, ${widget.latLng.longitude.toStringAsFixed(5)}°',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).waypointNameLabel,
              hintText: AppLocalizations.of(context).waypointNameHint,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isEdit)
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(AppLocalizations.of(context).delete,
                      style: const TextStyle(color: Colors.red)),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(AppLocalizations.of(context).save),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _save() {
    final now = DateTime.now();
    // Padded, or an unnamed waypoint saved at 12:05 came out as "12:5".
    final stamp = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    final name = _nameCtrl.text.trim().isEmpty
        ? AppLocalizations.of(context).waypointDefaultName(stamp)
        : _nameCtrl.text.trim();
    final existing = widget.existing;
    if (existing != null) {
      ref.read(mapNotifierProvider.notifier).renameWaypoint(existing.id, name);
    } else {
      ref.read(mapNotifierProvider.notifier).addWaypoint(
            name,
            widget.latLng.latitude,
            widget.latLng.longitude,
          );
    }
    Navigator.pop(context);
  }

  /// Zmazanie bodu, ku ktorému beží navigácia, sa najprv opýta.
  ///
  /// Bez toho sa navigácia po zmazaní ticho vypla a tester ju hľadal ako
  /// zaseknutú — mazanie bodu je jediné miesto, kde ju vypne niečo iné než
  /// on sám, tak nech to vidí.
  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) {
      Navigator.pop(context);
      return;
    }

    if (ref.read(navTargetIdProvider) == existing.id) {
      final l = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.deleteWaypointTitle),
          content: Text(l.deleteWaypointNavActive(existing.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await ref.read(mapNotifierProvider.notifier).deleteWaypoint(existing.id);
    if (mounted) Navigator.pop(context);
  }
}
