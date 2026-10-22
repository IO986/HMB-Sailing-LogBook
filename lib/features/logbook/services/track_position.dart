import '../../../core/database/app_database.dart';

/// Where a measured track says the boat was at a given moment.
class TrackPosition {
  final double lat;
  final double lon;
  const TrackPosition(this.lat, this.lon);

  /// Source tag stored on a log entry whose position came from a track.
  static const source = 'track';

  /// Longest stretch between two points that is still interpolated. Over a
  /// longer hole in the recording the boat could have been anywhere along or
  /// off the line, so no position is better than a drawn one.
  static const maxBracket = Duration(minutes: 10);

  /// Position at [when], interpolated linearly between the two points that
  /// enclose it. `null` before the first or after the last point, and across a
  /// hole longer than [maxBracket]; it never extrapolates.
  ///
  /// [sorted] must be ordered by time.
  static TrackPosition? at(List<TrackPoint> sorted, DateTime when) {
    if (sorted.isEmpty) return null;
    final t = when.toUtc();
    if (t.isBefore(sorted.first.timestamp.toUtc()) ||
        t.isAfter(sorted.last.timestamp.toUtc())) {
      return null;
    }

    // First point at or after t.
    var lo = 0;
    var hi = sorted.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (sorted[mid].timestamp.toUtc().isBefore(t)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final after = sorted[lo];
    if (lo == 0 || after.timestamp.toUtc().isAtSameMomentAs(t)) {
      return TrackPosition(after.latitude, after.longitude);
    }

    final before = sorted[lo - 1];
    final span = after.timestamp.difference(before.timestamp);
    if (span > maxBracket) return null;
    final f = t.difference(before.timestamp.toUtc()).inMilliseconds /
        span.inMilliseconds;
    return TrackPosition(
      before.latitude + (after.latitude - before.latitude) * f,
      before.longitude + (after.longitude - before.longitude) * f,
    );
  }
}
