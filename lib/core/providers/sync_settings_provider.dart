import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sync_settings.dart';

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

// Non-secret settings — SharedPreferences.
const _kEnabled = 'sync_enabled';
const _kTarget = 'sync_target';
const _kCustomUrl = 'sync_custom_url';
const _kIntervalMinutes = 'sync_interval_minutes';
const _kAttachmentPolicy = 'sync_attachment_policy';
const _kCloudEnabled = 'sync_cloud_enabled';
const _kCloudProvider = 'sync_cloud_provider';

// Custom-server token — secure storage only, never SharedPreferences,
// never logged.
const _kCustomToken = 'sync_custom_token';

Future<String?> readSyncCustomToken() => _storage.read(key: _kCustomToken);

Future<void> writeSyncCustomToken(String token) =>
    _storage.write(key: _kCustomToken, value: token);

Future<void> deleteSyncCustomToken() => _storage.delete(key: _kCustomToken);

class SyncSettingsNotifier extends AsyncNotifier<SyncSettings> {
  @override
  Future<SyncSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return SyncSettings(
      enabled: prefs.getBool(_kEnabled) ?? false,
      target: SyncTarget.values.firstWhere(
        (t) => t.name == prefs.getString(_kTarget),
        orElse: () => SyncTarget.hmbAcademy,
      ),
      customUrl: prefs.getString(_kCustomUrl) ?? '',
      intervalMinutes: prefs.getInt(_kIntervalMinutes) ?? 15,
      attachmentPolicy: AttachmentSyncPolicy.values.firstWhere(
        (p) => p.name == prefs.getString(_kAttachmentPolicy),
        orElse: () => AttachmentSyncPolicy.wifiOnly,
      ),
      cloudEnabled: prefs.getBool(_kCloudEnabled) ?? false,
      cloudProvider: CloudProvider.values.firstWhere(
        (p) => p.name == prefs.getString(_kCloudProvider),
        orElse: () => CloudProvider.googleDrive,
      ),
    );
  }

  Future<void> _persist(SyncSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, settings.enabled);
    await prefs.setString(_kTarget, settings.target.name);
    await prefs.setString(_kCustomUrl, settings.customUrl);
    await prefs.setInt(_kIntervalMinutes, settings.intervalMinutes);
    await prefs.setString(_kAttachmentPolicy, settings.attachmentPolicy.name);
    await prefs.setBool(_kCloudEnabled, settings.cloudEnabled);
    await prefs.setString(_kCloudProvider, settings.cloudProvider.name);
    state = AsyncData(settings);
  }

  Future<void> setEnabled(bool value) async {
    final current = state.valueOrNull ?? const SyncSettings();
    await _persist(current.copyWith(enabled: value));
  }

  Future<void> setTarget(SyncTarget target) async {
    final current = state.valueOrNull ?? const SyncSettings();
    await _persist(current.copyWith(target: target));
  }

  Future<void> setCustomUrl(String url) async {
    final current = state.valueOrNull ?? const SyncSettings();
    await _persist(current.copyWith(customUrl: url.trim()));
  }

  Future<void> setIntervalMinutes(int minutes) async {
    final current = state.valueOrNull ?? const SyncSettings();
    await _persist(current.copyWith(intervalMinutes: minutes));
  }

  Future<void> setAttachmentPolicy(AttachmentSyncPolicy policy) async {
    final current = state.valueOrNull ?? const SyncSettings();
    await _persist(current.copyWith(attachmentPolicy: policy));
  }

  Future<void> setCloudEnabled(bool value) async {
    final current = state.valueOrNull ?? const SyncSettings();
    await _persist(current.copyWith(cloudEnabled: value));
  }

  Future<void> setCloudProvider(CloudProvider provider) async {
    final current = state.valueOrNull ?? const SyncSettings();
    await _persist(current.copyWith(cloudProvider: provider));
  }
}

final syncSettingsProvider =
    AsyncNotifierProvider<SyncSettingsNotifier, SyncSettings>(
  SyncSettingsNotifier.new,
);

/// Re-read fresh whenever invalidated (after save/clear) rather than
/// cached — the token can change without the widget tree rebuilding on
/// its own otherwise.
final syncCustomTokenProvider =
    FutureProvider<String?>((ref) => readSyncCustomToken());
