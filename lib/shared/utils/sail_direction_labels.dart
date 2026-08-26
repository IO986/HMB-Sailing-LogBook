import 'package:hmb_sailing_log/l10n/app_localizations.dart';

import '../../core/models/point_of_sail.dart';

/// Translated names for the points of sail and the two tacks.
///
/// Kept out of both the picker and the PDF service on purpose: the screen and
/// the export must name the same course the same way, or a skipper comparing
/// the phone with the printed logbook would think they are two records.
String pointOfSailLabel(PointOfSail p, AppLocalizations l) {
  switch (p) {
    case PointOfSail.closeHauled:
      return l.pointOfSailCloseHauled;
    case PointOfSail.closeReach:
      return l.pointOfSailCloseReach;
    case PointOfSail.beamReach:
      return l.pointOfSailBeamReach;
    case PointOfSail.broadReach:
      return l.pointOfSailBroadReach;
    case PointOfSail.running:
      return l.pointOfSailRunning;
  }
}

String tackLabel(Tack t, AppLocalizations l) =>
    t == Tack.starboard ? l.tackStarboard : l.tackPort;

/// One line for a list or a PDF cell: "Beam reach · Starboard".
String sailDirectionSummary(SailDirection d, AppLocalizations l) {
  final t = d.tack;
  if (t == null) return pointOfSailLabel(d.pointOfSail, l);
  return '${pointOfSailLabel(d.pointOfSail, l)} · ${tackLabel(t, l)}';
}

/// The paper form's own shorthand — `S-` / `P-` next to the position — for
/// cells too narrow to carry the full name.
String sailDirectionShort(SailDirection d, AppLocalizations l) {
  final t = d.tack;
  final pos = pointOfSailLabel(d.pointOfSail, l);
  return t == null ? pos : '$pos ${t.code}';
}

/// Kurz ako veta do poznámky: „Bočný vietor, Pravoboku".
///
/// Skladá sa z prekladov, nie z uloženého textu — zápis nesie len kódy, takže
/// ten istý záznam prečíta Chorvát chorvátsky a Nemec nemecky.
String sailDirectionPhrase(SailDirection d, AppLocalizations l) {
  final t = d.tack;
  final pos = pointOfSailLabel(d.pointOfSail, l);
  return t == null ? pos : '$pos, ${tackLabel(t, l)}';
}
