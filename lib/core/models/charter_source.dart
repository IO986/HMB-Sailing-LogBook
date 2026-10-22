/// Where a charter's data came from (`Charters.source`).
///
/// Pure Dart, no drift: the values are persisted, so they must never be
/// renamed.
abstract final class CharterSource {
  /// Tracked or written live in the app.
  static const live = 'live';

  /// Reconstructed afterwards from a GPX file.
  static const gpx = 'gpx';

  /// Transcribed afterwards from a paper logbook.
  static const paper = 'paper';

  /// Sources that describe a finished voyage written after the fact.
  static const retrospective = [gpx, paper];

  /// A retrospective voyage exists for the map and the mile book only:
  /// check-in, safety briefing and check-out will never happen for it, it is
  /// not offered for resuming tracking, and new events are never appended
  /// to it.
  static bool isRetrospective(String source) => retrospective.contains(source);
}
