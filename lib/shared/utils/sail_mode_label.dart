import '../../l10n/app_localizations.dart';

/// Čitateľný zoznam vytiahnutých plachiet, napr. „Motor+Genoa".
///
/// Motor, Genoa a refy sú na lodi rovnaké slovo vo všetkých jazykoch, ktoré
/// appka pozná — prekladá sa len hlavná plachta. Rovnaké pravidlo drží aj
/// PDF export, aby denník na obrazovke a v exporte nehovoril inak.
String sailModeSummary(Iterable<String> modes, AppLocalizations l) {
  String label(String mode) {
    switch (mode.trim()) {
      case 'motor':
        return 'Motor';
      case 'main':
        return l.sailMain;
      case 'genoa':
        return 'Genoa';
      case 'reef1':
        return 'Reef 1';
      case 'reef2':
        return 'Reef 2';
      default:
        return mode;
    }
  }

  return modes.map(label).join('+');
}
