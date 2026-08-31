import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/skipper_profile.dart';

final skipperProfileProvider =
    AsyncNotifierProvider<SkipperProfileNotifier, SkipperProfile>(
  SkipperProfileNotifier.new,
);

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

const _kFullName   = 'skipper_full_name';
const _kLicType    = 'skipper_license_type';
const _kLicNum     = 'skipper_license_number';
const _kLicAuth    = 'skipper_license_authority';
const _kLicExpiry  = 'skipper_license_expiry';
const _kVhfNum     = 'skipper_vhf_number';
const _kVhfExpiry  = 'skipper_vhf_expiry';
const _kOtherCerts = 'skipper_other_certs';

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
        fullName:         await _storage.read(key: _kFullName)   ?? '',
        licenseType:      await _storage.read(key: _kLicType)    ?? '',
        licenseNumber:    await _storage.read(key: _kLicNum)     ?? '',
        licenseAuthority: await _storage.read(key: _kLicAuth)    ?? '',
        licenseExpiry:    await _storage.read(key: _kLicExpiry)  ?? '',
        vhfNumber:        await _storage.read(key: _kVhfNum)     ?? '',
        vhfExpiry:        await _storage.read(key: _kVhfExpiry)  ?? '',
        otherCerts:       await _storage.read(key: _kOtherCerts) ?? '',
      );
    } catch (_) {
      return const SkipperProfile();
    }
  }

  Future<void> save(SkipperProfile profile) async {
    await _storage.write(key: _kFullName,   value: profile.fullName);
    await _storage.write(key: _kLicType,    value: profile.licenseType);
    await _storage.write(key: _kLicNum,     value: profile.licenseNumber);
    await _storage.write(key: _kLicAuth,    value: profile.licenseAuthority);
    await _storage.write(key: _kLicExpiry,  value: profile.licenseExpiry);
    await _storage.write(key: _kVhfNum,     value: profile.vhfNumber);
    await _storage.write(key: _kVhfExpiry,  value: profile.vhfExpiry);
    await _storage.write(key: _kOtherCerts, value: profile.otherCerts);
    if (profile.fullName.trim().isNotEmpty) await _upsertIntoList(profile);
    state = AsyncData(profile);
  }

  /// Všetky doteraz uložené profily, najnovšie použitý prvý.
  ///
  /// Degraduje na prázdny zoznam pri chybe keystoru alebo poškodenom JSON —
  /// rovnaká opatrnosť ako pri [_load]: uloženie profilov je pohodlie, nikdy
  /// nesmie appku zablokovať.
  Future<List<SkipperProfile>> listSaved() async {
    try {
      final raw = await _storage.read(key: _kProfilesList);
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
      final list = await listSaved();
      list.removeWhere((p) =>
          p.fullName.trim().toLowerCase() == profile.fullName.trim().toLowerCase());
      list.insert(0, profile);
      await _storage.write(
        key: _kProfilesList,
        value: jsonEncode(list.map((p) => p.toJson()).toList()),
      );
    } catch (_) {
      // Zoznam je pohodlie navyše — keď zápis zlyhá, "posledný použitý"
      // profil vyššie sa aj tak uložil.
    }
  }
}
