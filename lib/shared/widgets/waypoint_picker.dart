/// Výber waypointu, ktorý svoj výsledok VRÁTI.
///
/// V projekte taký komponent nebol: `_showWpPicker` v prístrojovej doske je
/// privátny, natvrdo v tmavých farbách panela, hlási výber callbackom a jeho
/// `Column` nemá scroll, takže pri dlhšom zozname preteká. Námerový kompas
/// potrebuje bod vo svojom `await`-e (kurz sa musí odčítať až po výbere), a
/// nad kamerou potrebuje tmavú variantu — preto samostatný, znovupoužiteľný
/// widget.
///
/// `_showWpPicker` je kandidát na neskoršie zjednotenie s týmto; nechal som ho
/// zámerne na pokoji, aby zmena kompasu nesiahala do prístrojov.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/database/app_database.dart';
import '../../features/map/providers/map_provider.dart' show waypointsProvider;
import '../../l10n/app_localizations.dart';

/// Nechá používateľa vybrať waypoint. Vracia vybraný bod, alebo null pri
/// zrušení.
///
/// [sortFrom] zoradí zoznam od najbližšieho bodu. Na palube je hľadaný maják
/// takmer vždy ten najbližší, takže to ušetrí scrollovanie práve vtedy, keď je
/// na to najmenej času.
Future<Waypoint?> pickWaypoint(
  BuildContext context, {
  bool dark = false,
  int? highlightId,
  String? title,
  LatLng? sortFrom,
}) =>
    showModalBottomSheet<Waypoint>(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? const Color(0xFF0D1B2A) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _WaypointPickerSheet(
        dark: dark,
        highlightId: highlightId,
        title: title,
        sortFrom: sortFrom,
      ),
    );

class _WaypointPickerSheet extends ConsumerWidget {
  final bool dark;
  final int? highlightId;
  final String? title;
  final LatLng? sortFrom;

  const _WaypointPickerSheet({
    required this.dark,
    this.highlightId,
    this.title,
    this.sortFrom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final onDark = dark ? Colors.white : null;
    final waypoints = ref.watch(waypointsProvider).valueOrNull;

    final sorted = waypoints == null ? null : [...waypoints];
    if (sorted != null && sortFrom != null) {
      const distance = Distance();
      sorted.sort((a, b) => distance
          .distance(sortFrom!, LatLng(a.latitude, a.longitude))
          .compareTo(
              distance.distance(sortFrom!, LatLng(b.latitude, b.longitude))));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Icon(Icons.place, size: 18, color: onDark ?? Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title ?? l.selectTargetWaypoint,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: onDark),
                  ),
                ),
              ]),
            ),
            Divider(color: dark ? Colors.white24 : null, height: 20),
            if (sorted == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(children: [
                  Text(l.noWaypoints,
                      style: TextStyle(color: onDark ?? Colors.grey)),
                  const SizedBox(height: 12),
                  Text(l.waypointNameHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white38 : Colors.grey)),
                ]),
              )
            else
              // Scroll, a ohraničená výška: štyridsať waypointov nesmie
              // vytlačiť zoznam z obrazovky, ako to robí verzia v prístrojoch.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sorted.length,
                  itemBuilder: (context, i) {
                    final w = sorted[i];
                    final selected = w.id == highlightId;
                    return ListTile(
                      leading: Icon(
                        selected ? Icons.my_location : Icons.place,
                        color: selected
                            ? Colors.amber
                            : (dark ? Colors.white54 : null),
                      ),
                      title: Text(w.name, style: TextStyle(color: onDark)),
                      subtitle: Text(
                        '${w.latitude.toStringAsFixed(4)}, '
                        '${w.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                            fontSize: 11,
                            color: dark ? Colors.white38 : Colors.grey),
                      ),
                      onTap: () => Navigator.pop(context, w),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
