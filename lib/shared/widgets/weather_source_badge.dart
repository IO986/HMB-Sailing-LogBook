import 'package:flutter/material.dart';

import '../../core/services/entry_conditions.dart';
import '../../l10n/app_localizations.dart';

/// Odkiaľ pochádzajú hodnoty počasia v zázname.
///
/// Rovnaký zámer ako [LocationQualityBadge] pri polohe: lodný denník je
/// dokladovateľný záznam a musí byť vidno, či hodnota bola nameraná alebo
/// vypočítaná. Bez toho vyzerá výstup modelu rovnako smerodajne ako údaj
/// z prístroja na lodi.
///
/// Staré záznamy spred schémy v27 majú `weatherSource` NULL a nezobrazí sa
/// nič — tvrdiť o nich čokoľvek by bolo vymýšľanie.
class WeatherSourceBadge extends StatelessWidget {
  const WeatherSourceBadge({
    super.key,
    required this.weatherSource,
    required this.station,
    required this.stationDistanceM,
  });

  final String? weatherSource;
  final String? station;
  final double? stationDistanceM;

  @override
  Widget build(BuildContext context) {
    final source = weatherSource;
    if (source == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final String text;
    if (source == WeatherSource.nmea.code) {
      text = l.weatherSourceInstruments;
    } else if (source == WeatherSource.dhmz.code) {
      final name = station;
      if (name == null) {
        text = l.weatherSourceStationUnknown;
      } else {
        final km = stationDistanceM == null
            ? null
            : (stationDistanceM! / 1000).toStringAsFixed(1);
        // Vzdialenosť sa uvádza vždy, keď je známa: vietor z majáka, pri
        // ktorom loď stojí, a vietor spoza kopca 20 km ďaleko sú dva rôzne
        // údaje a skiper musí vedieť, ktorý číta.
        text = km == null
            ? l.weatherSourceStation(name)
            : l.weatherSourceStationAt(name, km);
      }
    } else {
      text = l.weatherSourceModel;
    }

    return Text(
      text,
      style: theme.textTheme.bodySmall
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
