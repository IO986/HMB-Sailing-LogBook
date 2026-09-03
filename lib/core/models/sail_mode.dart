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

/// Pohon, ktorý platí, kým skiper nepovie inak.
///
/// Z prístavu sa vypláva na motor — vždy. Prázdny stĺpec Pohon na prvých
/// zápisoch dňa nebol pravdivejší než motor, len nečitateľnejší: kto číta
/// denník, nevie, či motor nešiel, alebo to nikto nezapísal.
const defaultSailMode = 'motor';

/// Pohon pre nový automatický záznam.
///
/// Poradie je zámerné: čo podal volajúci (rýchle tlačidlo pohonu), potom čo
/// naposledy zapísal skiper v ten deň, a až nakoniec motor. Prvá zmena pohonu
/// tak prebije predvolbu a ďalšie automatické zápisy pokračujú v nej.
String resolveAutoSailMode({String? explicit, String? lastOfDay}) {
  final chosen = explicit ?? lastOfDay;
  return (chosen == null || chosen.trim().isEmpty) ? defaultSailMode : chosen;
}
