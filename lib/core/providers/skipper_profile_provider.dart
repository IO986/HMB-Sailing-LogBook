import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/skipper_profile.dart';
import '../services/resilient_key_value_store.dart';

final skipperProfileProvider =
    AsyncNotifierProvider<SkipperProfileNotifier, SkipperProfile>(
  SkipperProfileNotifier.new,
);

/// Šifrované úložisko so záložným súkromným úložiskom appky.
///
/// Samotné `FlutterSecureStorage` na Honor a Huawei hádže výnimku (vlastný
/// keystore), takže sa profil skipera na testovacom telefóne nikdy neuložil
/// ani nenačítal — appka pri novej plavbe nemala čo ponúknuť. Pozri
/// [ResilientKeyValueStore].
ResilientKeyValueStore _storage = const ResilientKeyValueStore();

/// Testy si sem podstrčia vlastné úložisko.
@visibleForTesting
set skipperProfileStore(ResilientKeyValueStore store) => _storage = store;

const _kFullName   = 'skipper_full_name';
const _kLicType    = 'skipper_license_type';
const _kLicNum     = 'skipper_license_number';
const _kLicAuth    = 'skipper_license_authority';
const _kLicExpiry  = 'skipper_license_expiry';
const _kVhfNum     = 'skipper_vhf_number';
const _kVhfExpiry  = 'skipper_vhf_expiry';
const _kOtherCerts = 'skipper_other_certs';
const _kIdNumber   = 'skipper_id_number';

/// Zoznam všetkých doteraz uložených profilov (JSON pole), pre loď, kde sa
/// pri kormidle strieda viac skiperov. Ploché kľúče vyššie ostávajú "posledný
/// použitý" profil — existujúci konzumenti (export, handover, ...) čítajú
/// naďalej len ich a o zoznam sa nemusia starať.
const _kProfilesList = 'skipper_profiles_list';

class SkipperProfileNotifier extends AsyncNotifier<SkipperProfile> {
  @override
  Future<SkipperProfile> build() => _load();

  Future<SkipperProfile> _load() async {
    // FlutterSecureStorage can throw on some devices (Honor/Huawei keystore
    // quirks, or a keystore reset after reinstall). A saved skipper profile is
    // a convenience, never critical — degrade to an empty profile instead of
    // leaving every consumer (handover, PDF export, profile screen) stuck on
    // an error/spinner.
    try {
      return SkipperProfile(
        fullName:         await _storage.read(_kFullName)   ?? '',
        licenseType:      await _storage.read(_kLicType)    ?? '',
        licenseNumber:    await _storage.read(_kLicNum)     ?? '',
        licenseAuthority: await _storage.read(_kLicAuth)    ?? '',
        licenseExpiry:    await _storage.read(_kLicExpiry)  ?? '',
        vhfNumber:        await _storage.read(_kVhfNum)     ?? '',
        vhfExpiry:        await _storage.read(_kVhfExpiry)  ?? '',
        otherCerts:       await _storage.read(_kOtherCerts) ?? '',
        idNumber:         await _storage.read(_kIdNumber)   ?? '',
      );
    } catch (_) {
      return const SkipperProfile();
    }
  }

  /// Uloží profil a **overí, že sa naozaj uložil**.
  ///
  /// Vráti `true`, keď sa dá načítať späť to isté. Presne toto v builde 69
  /// chýbalo: zápis do šifrovaného úložiska na Honore vyhodil výnimku, tá sa
  /// ticho zhltla, appka sa tvárila, že je uložené — a pri novej plavbe nemala
  /// čo ponúknuť. Volajúci má teraz z čoho poznať, že sa to nepodarilo, a
  /// môže to povedať človeku.
  Future<bool> save(SkipperProfile profile) async {
    await _storage.write(_kFullName,   profile.fullName);
    await _storage.write(_kLicType,    profile.licenseType);
    await _storage.write(_kLicNum,     profile.licenseNumber);
    await _storage.write(_kLicAuth,    profile.licenseAuthority);
    await _storage.write(_kLicExpiry,  profile.licenseExpiry);
    await _storage.write(_kVhfNum,     profile.vhfNumber);
    await _storage.write(_kVhfExpiry,  profile.vhfExpiry);
    await _storage.write(_kOtherCerts, profile.otherCerts);
    await _storage.write(_kIdNumber,   profile.idNumber);
    if (profile.fullName.trim().isNotEmpty) await _upsertIntoList(profile);
    // Stav sa nastavuje aj keď sa uloženie neskôr ukáže ako neúspešné:
    // v tomto behu appky sú platné tie údaje, ktoré skiper práve zadal, a
    // export či protokol majú pracovať s nimi. Že neprežijú reštart, povie
    // volajúcemu návratová hodnota.
    state = AsyncData(profile);

    if (ResilientKeyValueStore.usedFallback) {
      debugPrint('[PROFILE] saved through the unencrypted fallback — '
          'secure storage is unavailable on this device');
    }

    // Kontrola spätným načítaním, a to celého profilu: čiastočné zlyhanie
    // úložiska (jeden kľúč prejde, druhý nie) by pri kontrole vybraných polí
    // prešlo ako úspech.
    final readBack = await _load();
    final ok = readBack == profile;
    if (!ok) {
      debugPrint('[PROFILE] save did not stick — read-back differs');
    }
    return ok;
  }

  /// Všetky doteraz uložené profily, najnovšie použitý prvý.
  ///
  /// Degraduje na prázdny zoznam pri chybe keystoru alebo poškodenom JSON —
  /// rovnaká opatrnosť ako pri [_load]: uloženie profilov je pohodlie, nikdy
  /// nesmie appku zablokovať.
  Future<List<SkipperProfile>> listSaved() async {
    try {
      final raw = await _storage.read(_kProfilesList);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((m) => SkipperProfile.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _upsertIntoList(SkipperProfile profile) async {
    try {
      // Kópia, nie výsledok priamo: prázdny zoznam sa vracia ako `const []`
      // a `removeWhere` na ňom vyhodí výnimku. Tá sa dosiaľ zhltla, takže do
      // zoznamu profilov sa NIKDY nedostal prvý záznam — a ponuka „vyber si
      // skipera" pri viacerých profiloch tým pádom nemala čo ponúknuť.
      final list = [...await listSaved()];
      list.removeWhere((p) =>
          p.fullName.trim().toLowerCase() == profile.fullName.trim().toLowerCase());
      list.insert(0, profile);
      await _storage.write(
        _kProfilesList,
        jsonEncode(list.map((p) => p.toJson()).toList()),
      );
    } catch (e) {
      // Zoznam je pohodlie navyše — keď zápis zlyhá, "posledný použitý"
      // profil vyššie sa aj tak uložil. Nezhltnúť ho úplne ticho ale treba:
      // presne takto sa v builde 69 stratila celá pamäť skipera.
      debugPrint('[PROFILE] profile list write failed: $e');
    }
  }
}
