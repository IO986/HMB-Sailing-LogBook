/// Kind of an automatic logbook entry.
///
/// Stored in `LogbookEntries.eventType` as a stable [code] that never gets
/// translated, so the note text beside it is free to be written in the user's
/// language. Before v21 there was no column and consumers matched on the note,
/// which is how three spellings of "voyage start" — and one raw l10n key —
/// ended up in production data.
///
/// Pure Dart on purpose: no drift, no Flutter, so the legacy parsing below can
/// be tested directly.
library;

enum LogbookEventType {
  dutyStart('duty_start'),
  dutyEnd('duty_end'),
  anchorDropped('anchor_dropped'),
  anchorRaised('anchor_raised'),
  driftOut('drift_out'),
  driftIn('drift_in'),
  mob('mob'),
  mobCancelled('mob_cancelled'),
  voyageStart('voyage_start'),
  voyageEnd('voyage_end'),

  /// Prehodenie plachiet — obrat alebo halza. Zapisuje ho človek, nie
  /// automatika: appka nevie rozlíšiť zámerný obrat od zmeny kurzu.
  sailChange('sail_change'),

  /// Autopilot prevzal kormidlo / bol vypnutý. Hlásia to prístroje
  /// (HTC/HTD, APB, SeaTalk 0x84), zapisuje sa automaticky — v denníku je
  /// to rovnako podstatný údaj ako v palubnom denníku lietadla: kto v tej
  /// chvíli riadil loď.
  autopilotOn('autopilot_on'),
  autopilotOff('autopilot_off'),

  /// Motor naštartoval / zhasol. Rovnako ako autopilot to hlásia prístroje
  /// (otáčky cez RPM vetu) a z toho istého dôvodu: v denníku musí byť vidno,
  /// kedy loď šla na plachty a kedy na motor — a z toho sa počítajú
  /// motohodiny.
  engineStart('engine_start'),
  engineStop('engine_stop'),

  /// Zmena kurzu, ktorú appka rozpoznala sama: kurz sa odklonil o 30° a viac
  /// a v novom smere vydržal aspoň minútu. Kľučkovanie na vlne ani jeden
  /// zákmit GPS to teda nezapíše, zmena plánu áno — presne to, čo do
  /// papierového denníka zapíše kormidelník.
  ///
  /// Nezamieňať so [sailChange]: ten hlási prehodenie plachiet a zapisuje ho
  /// človek, lebo zámerný obrat od zmeny kurzu appka nerozlíši.
  courseChange('course_change'),

  /// Zmena kormidelníka počas plavby — kto v danej chvíli držal kormidlo.
  /// Zapisuje sa rovnako ako [sailChange]: rýchlym tlačidlom, nie
  /// automaticky, lebo appka sama nevie, kto sedí za kormidlom.
  helmsmanChange('helmsman_change');

  final String code;
  const LogbookEventType(this.code);

  static LogbookEventType? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final v in values) {
      if (v.code == code) return v;
    }
    return null;
  }

  /// Best-effort recovery of the event kind from a pre-v21 note.
  ///
  /// Deliberately covers the exact strings that were ever written to the
  /// database, including the Slovak variants and the leaked `voyageStart` key.
  /// Do not add new spellings here — new entries carry [eventType].
  static LogbookEventType? fromLegacyNote(String? note) {
    if (note == null || note.isEmpty) return null;
    if (note.contains('Anchor dropped')) return anchorDropped;
    if (note.contains('Anchor raised')) return anchorRaised;
    if (note.contains('Drift - perimeter exceeded')) return driftOut;
    if (note.contains('Drift - vessel back')) return driftIn;
    if (note.contains('Man overboard')) return mob;
    // 'Zmena kurzu' sa zapisovalo ako slovenský text v poznámke, kým
    // zmena kurzu nedostala vlastný typ udalosti.
    if (note.contains('Zmena kurzu')) return courseChange;
    if (note.contains('MOB cancelled')) return mobCancelled;
    if (note.contains('Voyage start') ||
        note.contains('Začiatok plavby') ||
        note.contains('Start voyage') ||
        note.contains('voyageStart')) {
      return voyageStart;
    }
    if (note.contains('Voyage end') ||
        note.contains('Koniec plavby') ||
        note.contains('End voyage') ||
        note.contains('voyageEnd')) {
      return voyageEnd;
    }
    return null;
  }

  /// The event kind of an entry: the stored column when present, otherwise
  /// parsed from the note for rows written before v21.
  static LogbookEventType? resolve(String? eventType, String? note) =>
      fromCode(eventType) ?? fromLegacyNote(note);

  bool get isAnchorEvent =>
      this == anchorDropped ||
      this == anchorRaised ||
      this == driftOut ||
      this == driftIn;

  bool get isDutyEvent => this == dutyStart || this == dutyEnd;

  bool get isAutopilotEvent => this == autopilotOn || this == autopilotOff;

  bool get isEngineEvent => this == engineStart || this == engineStop;
}
