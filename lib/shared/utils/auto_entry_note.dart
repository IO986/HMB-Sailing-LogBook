import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Poznámka, ktorú si appka písala sama: `Auto [MODEL]`, `Automaticky [NMEA]`.
///
/// Nikdy to nebola veta pre človeka — bola to značka pre appku, navyše po
/// slovensky, takže Chorvát v exporte čítal slovenské slovo a k nemu kód
/// zdroja, ktorý mu nič nehovoril. Zdroj počasia má od schémy v27 vlastný
/// stĺpec (`weatherSource`) a zobrazuje sa preložený; tu ostáva len rozpoznanie
/// starých riadkov, aby sa tá značka nedostala na oči.
bool isMachineAutoNote(String? note) {
  if (note == null) return false;
  final n = note.trimLeft();
  return n.startsWith('Auto [') ||
      n.startsWith('Automaticky [') ||
      n.startsWith('Automatický [') ||
      n == 'Auto' ||
      n.isEmpty;
}

/// Čo sa v denníku ukáže namiesto strojovej značky.
///
/// Vracia `null`, keď poznámka patrí človeku — tú netreba prekladať ani
/// nahrádzať.
String? autoEntryNoteLabel(
    {required bool isAutoEntry,
    required String? note,
    required AppLocalizations l}) {
  if (!isAutoEntry) return null;
  return isMachineAutoNote(note) ? l.autoEntryNote : null;
}
