import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skipper_profile.dart';

final skipperProfileProvider =
    AsyncNotifierProvider<SkipperProfileNotifier, SkipperProfile>(
  SkipperProfileNotifier.new,
);

class SkipperProfileNotifier extends AsyncNotifier<SkipperProfile> {
  @override
  Future<SkipperProfile> build() async {
    final prefs = await SharedPreferences.getInstance();
    return _fromPrefs(prefs);
  }

  static SkipperProfile _fromPrefs(SharedPreferences p) => SkipperProfile(
        fullName: p.getString('skipper_full_name') ?? '',
        licenseType: p.getString('skipper_license_type') ?? '',
        licenseNumber: p.getString('skipper_license_number') ?? '',
        licenseAuthority: p.getString('skipper_license_authority') ?? '',
        licenseExpiry: p.getString('skipper_license_expiry') ?? '',
        vhfNumber: p.getString('skipper_vhf_number') ?? '',
        vhfExpiry: p.getString('skipper_vhf_expiry') ?? '',
        otherCerts: p.getString('skipper_other_certs') ?? '',
      );

  Future<void> save(SkipperProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('skipper_full_name', profile.fullName);
    await prefs.setString('skipper_license_type', profile.licenseType);
    await prefs.setString('skipper_license_number', profile.licenseNumber);
    await prefs.setString('skipper_license_authority', profile.licenseAuthority);
    await prefs.setString('skipper_license_expiry', profile.licenseExpiry);
    await prefs.setString('skipper_vhf_number', profile.vhfNumber);
    await prefs.setString('skipper_vhf_expiry', profile.vhfExpiry);
    await prefs.setString('skipper_other_certs', profile.otherCerts);
    state = AsyncData(_fromPrefs(prefs));
  }
}
