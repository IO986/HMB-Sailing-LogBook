import 'package:flutter/material.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class TrackingIntervalSelector extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  const TrackingIntervalSelector({super.key, required this.value, required this.onChanged});

  /// Ponúkané frekvencie zápisu do denníka.
  ///
  /// 30 s a 1 min tu boli pôvodne, ale na plavbe nedávajú zmysel: zapisovali
  /// by desiatky riadkov za hodinu státia na kotve a denník by sa stal
  /// nečitateľným. Najhustejšia rozumná voľba je 5 minút, na dlhé prechody
  /// pribudlo 6 hodín.
  static const options = [300, 900, 1800, 3600, 7200, 21600];

  /// Predvolená frekvencia, keď si používateľ ešte nevybral.
  static const defaultSeconds = 3600;

  /// Najbližšia platná voľba k [seconds].
  ///
  /// Uložené nastavenie môže obsahovať hodnotu, ktorá sa medzitým z ponuky
  /// vytratila (30 s, 1 min). Bez tohto by sa v dialógu nezvýraznila žiadna
  /// možnosť a používateľ by nevedel, čo je vlastne nastavené.
  static int normalize(int seconds) {
    if (options.contains(seconds)) return seconds;
    return options.reduce((a, b) =>
        (a - seconds).abs() <= (b - seconds).abs() ? a : b);
  }

  /// Labels used to be hard-coded Slovak ('30 sek', '1 hod'), which every
  /// other language got to see as well. Derived from the value instead, so a
  /// new interval needs no new string.
  static String _label(AppLocalizations l, int seconds) => switch (seconds) {
        < 60 => l.intervalSeconds(seconds),
        < 3600 => l.intervalMinutes(seconds ~/ 60),
        _ => l.intervalHours(seconds ~/ 3600),
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.timer, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(l.logFrequency,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ]),
        const SizedBox(height: 8),
        // Časy pod seba (nie v horizontálnom scrolle vedľa seba) — všetky
        // možnosti sú tak viditeľné naraz, netreba rolovať.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: options.map((seconds) {
            final sel = seconds == normalize(value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ChoiceChip(
                label: Text(_label(l, seconds)),
                selected: sel,
                onSelected: (_) => onChanged(seconds),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
