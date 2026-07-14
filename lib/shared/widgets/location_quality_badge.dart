import 'package:flutter/material.dart';
import 'package:hmb_core/hmb_core.dart';

import '../../l10n/app_localizations.dart';

/// Zobrazí kvalitu uloženého GPS fixu záznamu (denník, quick-photo).
///
/// Nikdy nezobrazuje polohu ako jednoducho potvrdenú bez presnosti – staré
/// záznamy spred v16 (LogbookEntries) / v15 (TrackPoints) majú tieto polia
/// NULL a zobrazia sa ako "Presnosť neznáma". Vek fixu sa vyhodnocuje voči
/// vlastnému timestampu fixu (nie voči aktuálnemu času pri prezeraní), aby
/// staršie záznamy nevychádzali ako "zastarané" len preto, že sa pozerajú
/// neskôr – `locationSource == cached` sa preto rieši ako samostatný bucket
/// nezávislý od veku.
class LocationQualityBadge extends StatelessWidget {
  const LocationQualityBadge({
    super.key,
    required this.accuracyMeters,
    required this.locationSource,
    required this.isMocked,
    required this.timestamp,
  });

  final double? accuracyMeters;
  final String? locationSource;
  final bool? isMocked;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lines = <(String, bool)>[];

    final accuracy = accuracyMeters;
    if (accuracy == null) {
      lines.add((l.locationQualityUnknown, false));
    } else {
      final source = LocationSource.values.firstWhere(
        (s) => s.name == locationSource,
        orElse: () => LocationSource.unknown,
      );
      final fix = LocationFix(
        latitude: 0,
        longitude: 0,
        accuracyMeters: accuracy,
        source: source,
        timestamp: timestamp,
      );
      // referenčný čas = vlastný timestamp fixu, aby vek fixu nerástol len
      // tým, že sa záznam prezerá neskôr (staré záznamy tak nevychádzajú
      // ako "unusable" len kvôli veku pri prezeraní).
      final quality = fix.qualityAt(timestamp);

      if (source == LocationSource.cached || quality == LocationQuality.coarse) {
        final mins = DateTime.now()
            .toUtc()
            .difference(timestamp.toUtc())
            .inMinutes
            .clamp(0, 1 << 30);
        lines.add((l.locationQualityCached(mins), true));
      } else if (quality == LocationQuality.approximate) {
        lines.add((l.locationQualityApproximate(accuracy.round()), true));
      } else {
        lines.add((l.locationQualityPrecise(accuracy.round()), false));
      }
    }

    if (isMocked == true) {
      lines.add((l.locationQualityMocked, true));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines
          .map((line) => Text(
                line.$1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: line.$2
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ))
          .toList(),
    );
  }
}
