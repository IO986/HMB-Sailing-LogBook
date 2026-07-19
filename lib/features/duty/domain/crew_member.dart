import 'dart:convert';

/// One person who can be put on duty.
///
/// Deliberately free of drift and Flutter imports: the charter's raw fields are
/// passed in as strings, so this can be unit-tested without a database and
/// without a widget tree.
class CrewMember {
  final String name;
  final String role; // 'skipper' | 'crew'

  const CrewMember({required this.name, this.role = 'crew'});

  bool get isSkipper => role == 'skipper';

  /// Crew of a charter, in the order it should be offered when starting a duty.
  ///
  /// Primary source is `Charters.crewJson`; [skipperName] and the
  /// pipe-separated [crewNames] are the legacy fallback for charters created
  /// before crewJson existed (same precedence as charter_edit_screen).
  ///
  /// The skipper is always included — they stand watches like anyone else, and
  /// on a short-handed boat may be the only person ever on duty.
  static List<CrewMember> decode({
    String? crewJson,
    String? skipperName,
    String? crewNames,
  }) {
    final fromJson = _decodeJson(crewJson);
    final members = fromJson.isNotEmpty
        ? fromJson
        : _decodeLegacy(skipperName: skipperName, crewNames: crewNames);

    // A charter may name the skipper only in skipperName while crewJson lists
    // the rest of the crew; without this the skipper could not be put on duty.
    if (members.isNotEmpty && !members.any((m) => m.isSkipper)) {
      final name = skipperName?.trim() ?? '';
      if (name.isNotEmpty && !members.any((m) => m.name == name)) {
        return [CrewMember(name: name, role: 'skipper'), ...members];
      }
    }
    return members;
  }

  static List<CrewMember> _decodeJson(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map((m) => CrewMember(
                name: (m['name'] as String? ?? '').trim(),
                role: m['role'] as String? ?? 'crew',
              ))
          .where((m) => m.name.isNotEmpty)
          .toList();
    } catch (_) {
      // A malformed crewJson must not make the duty screen unusable.
      return const [];
    }
  }

  static List<CrewMember> _decodeLegacy({
    String? skipperName,
    String? crewNames,
  }) {
    final members = <CrewMember>[];
    final skipper = skipperName?.trim() ?? '';
    if (skipper.isNotEmpty) {
      members.add(CrewMember(name: skipper, role: 'skipper'));
    }
    for (final n in (crewNames ?? '')
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)) {
      members.add(CrewMember(name: n));
    }
    return members;
  }

  @override
  bool operator ==(Object other) =>
      other is CrewMember && other.name == name && other.role == role;

  @override
  int get hashCode => Object.hash(name, role);

  @override
  String toString() => 'CrewMember($name, $role)';
}
