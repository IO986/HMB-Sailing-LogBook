import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final nightModeProvider =
    StateNotifierProvider<NightModeNotifier, bool>((ref) => NightModeNotifier());

class NightModeNotifier extends StateNotifier<bool> {
  static const _key = 'night_mode';

  NightModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}
