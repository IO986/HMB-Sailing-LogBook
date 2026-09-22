import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A stable id for this install, used to tell "my own sync changeset" apart
/// from "one another device on the same account wrote" — never a hardware
/// id (those need extra Android permissions and survive a factory reset,
/// which this shouldn't).
///
/// Generated once and cached in memory: [id] is called on every sync tick,
/// and re-reading SharedPreferences each time would be needless I/O for a
/// value that never changes within a process lifetime.
class DeviceIdentity {
  static const _key = 'device_identity_id';
  static String? _cached;

  static Future<String> id() async {
    final cached = _cached;
    if (cached != null) return cached;

    final prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(_key);
    if (value == null || value.isEmpty) {
      value = const Uuid().v4();
      await prefs.setString(_key, value);
    }
    _cached = value;
    return value;
  }
}
