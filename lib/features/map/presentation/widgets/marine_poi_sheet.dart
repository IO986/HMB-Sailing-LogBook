import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/marine_poi_service.dart';
import '../../providers/map_provider.dart';

/// Detail kotviska / maríny / prístavu z OSM dát — otvára sa ťuknutím na
/// POI marker na mape. Zobrazí známe kontaktné/technické údaje a umožní
/// miesto uložiť ako waypoint.
class MarinePoiSheet extends ConsumerWidget {
  final MarinePoi poi;
  const MarinePoiSheet({super.key, required this.poi});

  /// Prvá neprázdna hodnota spomedzi zadaných OSM tagov.
  String? _tag(List<String> keys) {
    for (final k in keys) {
      final v = poi.tags[k];
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  /// Web adresy z OSM občas nemajú schému (`www.marina.hr` namiesto
  /// `https://www.marina.hr`) — `Uri.parse` by to bez nej nespustil.
  Uri _websiteUri(String v) =>
      v.contains('://') ? Uri.parse(v) : Uri.parse('https://$v');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final (icon, color, typeLabel) = switch (poi.type) {
      'anchorage' => (Icons.anchor, Colors.teal.shade700, l.poiTypeAnchorage),
      'marina' => (Icons.sailing, Colors.indigo.shade600, l.poiTypeMarina),
      'fuel' => (Icons.local_gas_station, Colors.orange.shade800,
          l.poiTypeFuel),
      _ => (Icons.directions_boat, Colors.blueGrey.shade700, l.poiTypeHarbour),
    };

    final rows = <(IconData, String, String, Uri?)>[
      if (_tag(['seamark:harbour:communication:vhf_channel',
                'communication:vhf', 'vhf_channel', 'vhf']) case final v?)
        (Icons.radio, l.poiVhfChannel, v, null),
      if (_tag(['phone', 'contact:phone']) case final v?)
        (Icons.phone, l.poiPhone, v, Uri(scheme: 'tel', path: v)),
      if (_tag(['website', 'contact:website']) case final v?)
        (Icons.language, l.poiWebsite, v, _websiteUri(v)),
      if (_tag(['email', 'contact:email']) case final v?)
        (Icons.email, l.poiEmail, v, Uri(scheme: 'mailto', path: v)),
      if (_tag(['seamark:anchorage:depth', 'depth']) case final v?)
        (Icons.waves, l.depthLabel, '$v m', null),
      if (_tag(['seamark:harbour:capacity', 'capacity']) case final v?)
        (Icons.dock, l.poiCapacity, v, null),
      if (_tag(['seamark:small_craft_facility:category']) case final v?)
        (Icons.build, l.poiServices, v.replaceAll(';', ', '), null),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(poi.name ?? typeLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    Text(typeLabel,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Text(
              '${poi.lat.toStringAsFixed(5)}, ${poi.lon.toStringAsFixed(5)}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            if (rows.isNotEmpty) ...[
              const Divider(height: 24),
              for (final (rIcon, label, value, uri) in rows)
                InkWell(
                  onTap: uri == null
                      ? null
                      : () async {
                          final ok = await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l.poiCannotOpen)));
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Icon(rIcon, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 10),
                      Text('$label: ',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                      Expanded(
                        child: uri == null
                            ? SelectableText(value,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500))
                            : Text(value,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline)),
                      ),
                    ]),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: Text(l.poiSaveAsWaypoint),
                onPressed: () async {
                  final name = poi.name ?? typeLabel;
                  await ref.read(mapNotifierProvider.notifier).addWaypoint(
                        name,
                        poi.lat,
                        poi.lon,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l.poiWaypointSaved(name)),
                      duration: const Duration(seconds: 2),
                    ));
                  }
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(l.poiSource,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
