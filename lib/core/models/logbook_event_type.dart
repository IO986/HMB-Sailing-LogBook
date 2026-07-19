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
  voyageEnd('voyage_end');

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
}
