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

class SkipperProfileNotifier extends AsyncNotifier<SkipperProfile> {
  @override
  Future<SkipperProfile> build() => _load();

  Future<SkipperProfile> _load() async => SkipperProfile(
        fullName:         await _storage.read(key: _kFullName)   ?? '',
        licenseType:      await _storage.read(key: _kLicType)    ?? '',
        licenseNumber:    await _storage.read(key: _kLicNum)     ?? '',
        licenseAuthority: await _storage.read(key: _kLicAuth)    ?? '',
        licenseExpiry:    await _storage.read(key: _kLicExpiry)  ?? '',
        vhfNumber:        await _storage.read(key: _kVhfNum)     ?? '',
        vhfExpiry:        await _storage.read(key: _kVhfExpiry)  ?? '',
        otherCerts:       await _storage.read(key: _kOtherCerts) ?? '',
      );

  Future<void> save(SkipperProfile profile) async {
    await _storage.write(key: _kFullName,   value: profile.fullName);
    await _storage.write(key: _kLicType,    value: profile.licenseType);
    await _storage.write(key: _kLicNum,     value: profile.licenseNumber);
    await _storage.write(key: _kLicAuth,    value: profile.licenseAuthority);
    await _storage.write(key: _kLicExpiry,  value: profile.licenseExpiry);
    await _storage.write(key: _kVhfNum,     value: profile.vhfNumber);
    await _storage.write(key: _kVhfExpiry,  value: profile.vhfExpiry);
    await _storage.write(key: _kOtherCerts, value: profile.otherCerts);
    state = AsyncData(profile);
  }
}
