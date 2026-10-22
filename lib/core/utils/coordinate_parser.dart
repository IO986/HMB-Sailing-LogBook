/// Parses a latitude or longitude typed by a person, in the shapes a paper
/// logbook uses: decimal degrees, degrees and decimal minutes, or degrees,
/// minutes and seconds, with the hemisphere as a letter or a minus sign.
///
/// Pure Dart. Returns `null` for anything it cannot read with certainty;
/// guessing a position would put a boat on the wrong side of an island.
///
/// Accepted, for a latitude: `43.5123`, `43,5123`, `-43.5123`, `43.5123 N`,
/// `N 43.5123`, `43° 30.738' N`, `43 30.738 N`, `43°30'44" N`.
abstract final class CoordinateParser {
  static double? parseLatitude(String input) => _parse(input, 'NS', 90);

  static double? parseLongitude(String input) => _parse(input, 'EW', 180);

  static final _number = RegExp(r'\d+(?:\.\d+)?');
  static final _symbols = RegExp('[°º˚′\'’″"]');

  static double? _parse(String input, String hemispheres, double limit) {
    var s = input.trim().toUpperCase().replaceAll(',', '.');
    if (s.isEmpty) return null;

    // Hemisphere letter, at either end. Any other letter is a typo.
    final letters = RegExp(r'[A-Z]').allMatches(s).map((m) => m.group(0)!).toList();
    if (letters.length > 1) return null;
    var negative = false;
    if (letters.length == 1) {
      final letter = letters.single;
      if (!hemispheres.contains(letter)) return null;
      negative = letter == hemispheres[1];
      s = s.replaceAll(letter, ' ');
    }

    s = s.replaceAll(_symbols, ' ').trim();
    if (s.startsWith('-')) {
      negative = true;
      s = s.substring(1).trim();
    } else if (s.startsWith('+')) {
      s = s.substring(1).trim();
    }

    final numbers = _number.allMatches(s).toList();
    if (numbers.isEmpty || numbers.length > 3) return null;
    // Only numbers and spaces may remain; a stray sign or dot is an error.
    if (s.replaceAll(_number, '').trim().isNotEmpty) return null;

    final parts = [for (final m in numbers) double.parse(m.group(0)!)];
    final degrees = parts[0];
    final minutes = parts.length > 1 ? parts[1] : 0.0;
    final seconds = parts.length > 2 ? parts[2] : 0.0;

    if (minutes >= 60 || seconds >= 60) return null;
    // Minutes only make sense after whole degrees.
    if (parts.length > 1 && degrees != degrees.truncateToDouble()) return null;
    if (parts.length > 2 && minutes != minutes.truncateToDouble()) return null;

    final value = degrees + minutes / 60 + seconds / 3600;
    if (value > limit) return null;
    return negative ? -value : value;
  }
}
