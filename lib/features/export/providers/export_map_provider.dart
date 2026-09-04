import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Podklad výrezu mapy v exporte: satelitná snímka, alebo bežná mapa.
///
/// Satelit ukazuje, ako to na mieste vyzerá — mólo, breh, kotvisko. Mapa
/// ukazuje mená, cesty a značky. Ktorý z nich patrí do dokladu, vie len ten,
/// kto ho odovzdáva, a spravidla to má rovnako pri každom exporte, takže sa
/// voľba pamätá.
///
/// Číta ju aj automatický cloud export, ktorý si obrázok kreslí sám na konci
/// dňa a nemá sa koho spýtať.
final exportSatelliteMapProvider =
    StateNotifierProvider<ExportSatelliteMapNotifier, bool>(
        (ref) => ExportSatelliteMapNotifier());

class ExportSatelliteMapNotifier extends StateNotifier<bool> {
  static const _key = 'export_map_satellite';

  /// Predvolene satelit — tak vyzerali všetky exporty, kým sa vyberať nedalo.
  ExportSatelliteMapNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> set(bool satellite) async {
    if (state == satellite) return;
    state = satellite;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, satellite);
  }

  /// Pre cesty mimo widget stromu (automatický export po ukončení dňa).
  static Future<bool> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }
}
