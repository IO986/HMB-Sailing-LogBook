import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/point_of_sail.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/shared/utils/sail_direction_labels.dart';

/// The sail-change note is built from the stored codes at read time, never
/// stored as text — that is what lets the same entry read Slovak on the boat
/// and English in the exported PDF a charter company files.
void main() {
  test('the note carries course and tack, in the reader language', () async {
    const d = SailDirection(PointOfSail.closeReach, Tack.starboard);

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(en.logEventSailChangeTo(sailDirectionPhrase(d, en)),
        'Sail change: Close reach, Starboard');

    final sk = await AppLocalizations.delegate.load(const Locale('sk'));
    expect(sk.logEventSailChangeTo(sailDirectionPhrase(d, sk)),
        'Zmena plachiet: Predobočný, Pravobok');
  });

  test('running carries no tack — there is no side to name', () async {
    const d = SailDirection(PointOfSail.running, null);
    final en = await AppLocalizations.delegate.load(const Locale('en'));

    expect(sailDirectionPhrase(d, en), 'Running');
    expect(en.logEventSailChangeTo(sailDirectionPhrase(d, en)),
        'Sail change: Running');
  });

  test('every locale names all five points of sail and both tacks', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = await AppLocalizations.delegate.load(locale);
      for (final p in PointOfSail.values) {
        expect(pointOfSailLabel(p, l), isNotEmpty,
            reason: '${locale.languageCode}: ${p.code}');
      }
      for (final t in Tack.values) {
        expect(tackLabel(t, l), isNotEmpty,
            reason: '${locale.languageCode}: ${t.code}');
      }
    }
  });
}
