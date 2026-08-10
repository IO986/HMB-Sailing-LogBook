import 'dart:convert';

import '../../l10n/app_localizations.dart';

/// Jeden člen posádky tak, ako je uložený v `Charters.crewJson`.
///
/// Posádka nemá vlastnú tabuľku — drží sa ako JSON v karte plavby, aby sa
/// dala editovať naraz s ňou. Tento typ je len pohodlný pohľad na ten JSON,
/// aby ho nemusela každá obrazovka parsovať po svojom.
class CrewMemberRef {
  const CrewMemberRef({
    required this.name,
    required this.role,
    this.boatLicence,
    this.radioLicence,
    this.otherCerts,
  });

  final String name;

  /// 'skipper' alebo 'crew'.
  final String role;
  final String? boatLicence;
  final String? radioLicence;
  final String? otherCerts;

  bool get isSkipper => role == 'skipper';

  String roleLabel(AppLocalizations l) => isSkipper ? l.roleSkipper : l.roleCrew;

  static String? _text(Object? value) {
    final s = value?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// Posádka z `crewJson`; pri prázdnom/poškodenom JSON padne späť na staré
  /// `skipperName` + `crewNames` (pipe-separated), ktoré appka písala predtým.
  static List<CrewMemberRef> parse(
    String? crewJson, {
    String? skipperName,
    String? crewNames,
  }) {
    final fromJson = <CrewMemberRef>[];
    if (crewJson != null && crewJson.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(crewJson);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;
            final name = _text(item['name']);
            if (name == null) continue;
            fromJson.add(CrewMemberRef(
              name: name,
              role: _text(item['role']) ?? 'crew',
              boatLicence: _text(item['boatLicence']),
              radioLicence: _text(item['radioLicence']),
              otherCerts: _text(item['otherCerts']),
            ));
          }
        }
      } catch (_) {
        // Poškodený JSON nesmie zhodiť obrazovku — použije sa fallback nižšie.
      }
    }
    if (fromJson.isNotEmpty) return fromJson;

    return [
      if (_text(skipperName) != null)
        CrewMemberRef(name: skipperName!.trim(), role: 'skipper'),
      for (final n in (crewNames ?? '').split('|'))
        if (n.trim().isNotEmpty) CrewMemberRef(name: n.trim(), role: 'crew'),
    ];
  }
}
