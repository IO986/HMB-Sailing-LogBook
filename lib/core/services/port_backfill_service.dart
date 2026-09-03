import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import 'geocoding_service.dart';

/// Dopĺňa prístavy odchodu/príchodu dodatočne, keď ich nestihol vyplniť
/// geocoding počas plavby.
///
/// Prístavy sa plnia reverzným geokódovaním v momente odchodu a príchodu.
/// To sú dve chvíle, ktoré na lodi zlyhávajú najčastejšie: pri odchode
/// z odľahlej zátoky nie je signál a pri príchode appku často zabije systém
/// skôr, než skiper stihne plavbu ukončiť. Deň potom má v exporte „? → ?"
/// natrvalo, hoci polohy má uložené.
///
/// Táto služba to opravuje spätne: vezme prvý a posledný známy fix dňa
/// a doplní chýbajúci názov, keď je sieť. Bez siete sa ticho vzdá a skúsi to
/// nabudúce — zápis dát na sieti nikdy nezávisí.
class PortBackfillService {
  static final PortBackfillService _i = PortBackfillService._();
  factory PortBackfillService() => _i;
  PortBackfillService._();

  /// Polohy, pre ktoré geocoding naposledy zlyhal, a kedy. Bez toho by sa
  /// každé otvorenie exportu znovu dobýjalo do nedostupného servera — a to je
  /// na lodi bežný stav: telefón visí na Wi-Fi plotra, ktorá nikam nevedie,
  /// takže sa nerozlíši od siete, ktorá funguje.
  ///
  /// Zákaz je dočasný schválne: skiper sa počas tej istej relácie prepne na
  /// mobilné dáta alebo dorazí do prístavu a doplnenie musí prejsť.
  final _failedAt = <String, DateTime>{};
  static const _retryAfter = Duration(minutes: 5);

  static String _key(double lat, double lon) =>
      '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';

  /// Doplní, čo sa dá, pre jeden deň. Vráti `true`, ak sa niečo zapísalo.
  Future<bool> backfillDay(AppDatabase db, DayLog day) async {
    final needFrom = (day.portFrom ?? '').trim().isEmpty;
    final needTo = (day.portTo ?? '').trim().isEmpty;
    if (!needFrom && !needTo) return false;

    String? from;
    String? to;
    if (needFrom) from = await _nameFor(await db.firstFixForDay(day.id));
    if (needTo) to = await _nameFor(await db.lastFixForDay(day.id));
    if (from == null && to == null) return false;

    await db.updateDayLog(DayLogsCompanion(
      id: drift.Value(day.id),
      portFrom: from == null ? const drift.Value.absent() : drift.Value(from),
      portTo: to == null ? const drift.Value.absent() : drift.Value(to),
    ));
    debugPrint('[GEO] Backfill day ${day.id}: from=$from to=$to');
    return true;
  }

  /// Doplní všetky dni naraz. Chyba jedného dňa nezhodí ostatné.
  Future<bool> backfillDays(AppDatabase db, List<DayLog> days) async {
    var changed = false;
    for (final day in days) {
      try {
        if (await backfillDay(db, day)) changed = true;
      } catch (e) {
        debugPrint('[GEO] Backfill day ${day.id} failed: $e');
      }
    }
    return changed;
  }

  /// Dokedy sa neoplatí skúšať vôbec nič.
  ///
  /// Keď zlyhá jedno volanie, zlyhajú aj ostatné — je to tá istá sieť. Bez
  /// tohto by sa export siedmich dní offline modlil štrnásťkrát po osem
  /// sekúnd, kým by vôbec začal tlačiť.
  DateTime? _offlineUntil;
  static const _offlineBackoff = Duration(minutes: 1);

  Future<String?> _nameFor(({double lat, double lon})? fix) async {
    final off = _offlineUntil;
    if (off != null && DateTime.now().isBefore(off)) return null;
    if (fix == null) return null;
    final key = _key(fix.lat, fix.lon);
    final failed = _failedAt[key];
    if (failed != null && DateTime.now().difference(failed) < _retryAfter) {
      return null;
    }
    final name = await GeocodingService().reverseGeocode(fix.lat, fix.lon);
    if (name == null || name.trim().isEmpty) {
      _failedAt[key] = DateTime.now();
      _offlineUntil = DateTime.now().add(_offlineBackoff);
      return null;
    }
    _failedAt.remove(key);
    _offlineUntil = null;
    return name;
  }
}
