/// Spôsob plavby uložený pri zázname denníka.
///
/// Do schémy v21 sa ukladal ako prefix `[motor,main]` v poznámke skipera. Od
/// v22 má vlastný stĺpec; prefix sa číta už len ako záloha pre riadky, ktoré
/// migráciou neprešli — napríklad záznam stiahnutý zo servera.
({Set<String> modes, String note}) parseSailMode(
    String? sailMode, String? rawNote) {
  final note = rawNote ?? '';
  if (sailMode != null && sailMode.isNotEmpty) {
    return (modes: _split(sailMode), note: _stripPrefix(note).note);
  }
  return _stripPrefix(note);
}

({Set<String> modes, String note}) _stripPrefix(String note) {
  final match = RegExp(r'^\[([^\]]*)\]\s*').firstMatch(note);
  if (match == null) return (modes: <String>{}, note: note);
  return (modes: _split(match.group(1)!), note: note.substring(match.end));
}

Set<String> _split(String value) => value
    .split(',')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toSet();
