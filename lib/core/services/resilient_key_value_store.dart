import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _defaultSecure = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

/// Úložisko, ktoré prežije rozbitý keystore.
///
/// Profil skipera (meno, preukazy, VHF, číslo dokladu) sedel iba vo
/// `FlutterSecureStorage`. Na Honor a Huawei však jeho `EncryptedSharedPreferences`
/// hádže výnimku — keystore je tam vlastný a po reinštalácii alebo aktualizácii
/// systému sa kľúč stratí. Zápis aj čítanie boli obalené `catch`, takže sa
/// navonok nestalo nič: appka si skipera nezapamätala a pri novej plavbe
/// nemala čo ponúknuť. Nahlásené z testovacieho Honoru.
///
/// Preto dva stupne: najprv šifrované úložisko, a keď zlyhá, súkromné
/// úložisko appky (`SharedPreferences`). Aj to je v sandboxe aplikácie — iná
/// appka doň nevidí — len nie je šifrované navyše. Lepšie než údaje, ktoré sa
/// strácajú.
///
/// Keď šifrovaný zápis prejde, záložná kópia sa maže: dva zdroje pravdy by sa
/// raz rozišli a čítal by sa ten starší.
class ResilientKeyValueStore {
  /// Prefix záložných kľúčov, aby sa nezrazili s ostatnými nastaveniami.
  static const _fallbackPrefix = 'fallback_';

  /// Funkcie sa dajú podstrčiť, aby sa dalo otestovať aj zlyhanie keystoru —
  /// bez toho by táto trieda mala testy len na tú vetvu, ktorá funguje.
  const ResilientKeyValueStore({
    Future<String?> Function(String key)? secureRead,
    Future<void> Function(String key, String value)? secureWrite,
    Future<void> Function(String key)? secureDelete,
  })  : _secureRead = secureRead,
        _secureWrite = secureWrite,
        _secureDelete = secureDelete;

  final Future<String?> Function(String key)? _secureRead;
  final Future<void> Function(String key, String value)? _secureWrite;
  final Future<void> Function(String key)? _secureDelete;

  /// True, keď sa niekedy v tomto behu appky muselo siahnuť po nešifrovanej
  /// zálohe. Na diagnostiku — appka sa podľa toho nerozhoduje.
  static bool get usedFallback => _usedFallback;
  static bool _usedFallback = false;

  @visibleForTesting
  static void resetFallbackFlag() => _usedFallback = false;

  Future<String?> read(String key) async {
    try {
      final value = _secureRead != null
          ? await _secureRead(key)
          : await _defaultSecure.read(key: key);
      if (value != null) return value;
    } catch (e) {
      _usedFallback = true;
      debugPrint('[STORE] secure read $key failed: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_fallbackPrefix$key');
    } catch (e) {
      debugPrint('[STORE] fallback read $key failed: $e');
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    var secureOk = false;
    try {
      if (_secureWrite != null) {
        await _secureWrite(key, value);
      } else {
        await _defaultSecure.write(key: key, value: value);
      }
      secureOk = true;
    } catch (e) {
      _usedFallback = true;
      debugPrint('[STORE] secure write $key failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (secureOk) {
        await prefs.remove('$_fallbackPrefix$key');
      } else {
        await prefs.setString('$_fallbackPrefix$key', value);
      }
    } catch (e) {
      debugPrint('[STORE] fallback write $key failed: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      if (_secureDelete != null) {
        await _secureDelete(key);
      } else {
        await _defaultSecure.delete(key: key);
      }
    } catch (e) {
      debugPrint('[STORE] secure delete $key failed: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_fallbackPrefix$key');
    } catch (e) {
      debugPrint('[STORE] fallback delete $key failed: $e');
    }
  }
}
