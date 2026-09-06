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
/// navonok nestalo nič: appka si skipera nezapamätala a pri novej plavbe nemala
/// čo ponúknuť. Nahlásené z testovacieho Honoru.
///
/// Preto dva stupne: najprv šifrované úložisko, a keď zlyhá, súkromné úložisko
/// appky (`SharedPreferences`). Aj to je v sandboxe aplikácie — iná appka doň
/// nevidí a zo zálohovania je vyňaté — len nie je šifrované navyše.
///
/// **Ktorá hodnota je novšia:** záložná. Zápis do zálohy sa robí jedine vtedy,
/// keď šifrovaný zápis zlyhal, a maže sa hneď, ako šifrovaný zápis prejde.
/// Existencia záložnej hodnoty teda znamená, že tá šifrovaná je zastaraná —
/// čítanie preto pozerá najprv do zálohy a keď ju nájde, pokúsi sa ju vrátiť
/// do šifrovaného úložiska (uzdravenie po tom, čo sa keystore spamätá).
class ResilientKeyValueStore {
  /// Prefix záložných kľúčov, aby sa nezrazili s ostatnými nastaveniami.
  static const _fallbackPrefix = 'fallback_';

  /// Funkcie sa dajú podstrčiť, aby sa dalo otestovať aj zlyhanie keystoru —
  /// bez toho by táto trieda mala testy len na tú vetvu, ktorá funguje.
  const ResilientKeyValueStore({
    Future<String?> Function(String key)? secureRead,
    Future<void> Function(String key, String value)? secureWrite,
  })  : _secureRead = secureRead,
        _secureWrite = secureWrite;

  final Future<String?> Function(String key)? _secureRead;
  final Future<void> Function(String key, String value)? _secureWrite;

  /// True, keď v tomto behu appky niektorá hodnota reálne prešla nešifrovanou
  /// zálohou. Diagnostika — appka sa podľa toho nerozhoduje.
  ///
  /// Nestavia sa pri obyčajnom zlyhaní čítania: to samo o sebe neznamená, že
  /// sa niečo uložilo inam, a v hlásení z terénu by to bola falošná stopa.
  static bool get usedFallback => _usedFallback;
  static bool _usedFallback = false;

  @visibleForTesting
  static void resetFallbackFlag() => _usedFallback = false;

  Future<String?> read(String key) async {
    // Najprv záloha: keď existuje, je z definície novšia než šifrovaná kópia.
    final fallback = await _readFallback(key);
    if (fallback != null) {
      _usedFallback = true;
      // Pokus o uzdravenie — keystore sa mohol medzitým spamätať.
      if (await _writeSecure(key, fallback)) {
        await _removeFallback(key);
        _usedFallback = false;
      }
      return fallback;
    }

    try {
      return _secureRead != null
          ? await _secureRead(key)
          : await _defaultSecure.read(key: key);
    } catch (e) {
      debugPrint('[STORE] secure read $key failed: $e');
      return null;
    }
  }

  /// Vráti `true`, keď hodnotu prijalo aspoň jedno z úložísk.
  ///
  /// Návratová hodnota nie je ozdoba: keď zlyhajú obe, volajúci to má vedieť.
  /// Presne toto v builde 69 chýbalo — zápis „prešiel" a neuložil nič.
  Future<bool> write(String key, String value) async {
    if (await _writeSecure(key, value)) {
      await _removeFallback(key);
      _usedFallback = false;
      return true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_fallbackPrefix$key', value);
      _usedFallback = true;
      return true;
    } catch (e) {
      debugPrint('[STORE] fallback write $key failed: $e');
      return false;
    }
  }

  Future<bool> _writeSecure(String key, String value) async {
    try {
      if (_secureWrite != null) {
        await _secureWrite(key, value);
      } else {
        await _defaultSecure.write(key: key, value: value);
      }
      return true;
    } catch (e) {
      debugPrint('[STORE] secure write $key failed: $e');
      return false;
    }
  }

  Future<String?> _readFallback(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_fallbackPrefix$key');
    } catch (e) {
      debugPrint('[STORE] fallback read $key failed: $e');
      return null;
    }
  }

  Future<void> _removeFallback(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_fallbackPrefix$key');
    } catch (e) {
      debugPrint('[STORE] fallback remove $key failed: $e');
    }
  }
}
