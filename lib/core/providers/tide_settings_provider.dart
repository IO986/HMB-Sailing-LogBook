import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

// WorldTides API key — secure storage only, never SharedPreferences.
const _kTideApiKey = 'tide_api_key';

Future<String?> readTideApiKey() => _storage.read(key: _kTideApiKey);

Future<void> writeTideApiKey(String key) =>
    _storage.write(key: _kTideApiKey, value: key);

Future<void> deleteTideApiKey() => _storage.delete(key: _kTideApiKey);

/// Re-read fresh whenever invalidated (after save/clear).
final tideApiKeyProvider = FutureProvider<String?>((ref) => readTideApiKey());
