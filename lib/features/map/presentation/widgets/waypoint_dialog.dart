import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/map_provider.dart';
import '../../../../l10n/app_localizations.dart';

class WaypointDialog extends ConsumerStatefulWidget {
  final LatLng latLng;
  const WaypointDialog({super.key, required this.latLng});

  @override
  ConsumerState<WaypointDialog> createState() => _WaypointDialogState();
}

class _WaypointDialogState extends ConsumerState<WaypointDialog> {
  final _nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          Text(AppLocalizations.of(context).addWaypoint,
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
              hintText: 'e.g. Anchorage, Port...',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
    final name = _nameCtrl.text.trim().isEmpty
        ? 'Waypoint ${DateTime.now().hour}:${DateTime.now().minute}'
        : _nameCtrl.text.trim();
    ref.read(mapNotifierProvider.notifier).addWaypoint(
          name,
          widget.latLng.latitude,
          widget.latLng.longitude,
        );
    Navigator.pop(context);
  }
}
