import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/shared/utils/auto_entry_note.dart';

/// Automatic entries used to carry a Slovak machine tag in the note column
/// ('Auto [MODEL]'). A Croatian charter company reading the exported PDF got
/// a Slovak word and a source code that meant nothing to them. New entries
/// store no note at all and the label is translated at read time; old rows
/// still have to be recognised so the tag never reaches a reader.
void main() {
  test('recognises the machine tag, in every spelling that shipped', () {
    expect(isMachineAutoNote('Auto [MODEL]'), isTrue);
    expect(isMachineAutoNote('Auto [NMEA]'), isTrue);
    expect(isMachineAutoNote('Automaticky [DHMZ]'), isTrue);
    expect(isMachineAutoNote('Automatický [MODEL]'), isTrue);
    expect(isMachineAutoNote(''), isTrue);
    expect(isMachineAutoNote(null), isFalse);
  });

  test("a skipper's own note is never treated as a machine tag", () {
    expect(isMachineAutoNote('Autopilot zapnutý'), isFalse);
    expect(isMachineAutoNote('Motor na 2000 ot.'), isFalse);
  });

  test('the label is translated, and only for automatic entries', () async {
    final sk = await AppLocalizations.delegate.load(const Locale('sk'));
    final hr = await AppLocalizations.delegate.load(const Locale('hr'));

    expect(
        autoEntryNoteLabel(isAutoEntry: true, note: 'Auto [MODEL]', l: sk),
        'Automatický záznam');
    expect(
        autoEntryNoteLabel(isAutoEntry: true, note: 'Auto [MODEL]', l: hr),
        'Automatski zapis');
    // A manual entry with an empty note gets no label — it was a person who
    // wrote it and had nothing to add.
    expect(autoEntryNoteLabel(isAutoEntry: false, note: '', l: sk), isNull);
    // An automatic entry that carries a real note keeps it.
    expect(
        autoEntryNoteLabel(isAutoEntry: true, note: 'Zmena kurzu', l: sk),
        isNull);
  });
}
