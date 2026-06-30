import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_constants.dart';

// ── API kontrakt (backend musí implementovať) ─────────────────
//
// POST https://api.logbook.hmba.boats/auth/register
//   Body:     { "email": "...", "name": "...", "password": "..." }
//   Response: { "token": "eyJ...", "user": { "id": "uuid", "email": "...", "name": "..." } }
//
// POST https://api.logbook.hmba.boats/auth/login
//   Body:     { "email": "...", "password": "..." }
//   Response: { "token": "eyJ...", "user": { "id": "uuid", "email": "...", "name": "..." } }
//
// POST https://api.logbook.hmba.boats/auth/logout
//   Headers:  Authorization: Bearer {token}
//   Response: 200 OK
//
// GET https://api.logbook.hmba.boats/auth/me
//   Headers:  Authorization: Bearer {token}
//   Response: { "user": { "id": "uuid", "email": "...", "name": "..." } }

const _kSecToken  = 'account_token';
const _kSecUserId = 'account_user_id';
const _kSecEmail  = 'account_email';
const _kSecName   = 'account_name';

// Encrypted storage backed by Android Keystore / iOS Secure Enclave
const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

class AccountUser {
  final String id;
  final String email;
  final String name;
  const AccountUser({required this.id, required this.email, required this.name});
}

class AccountService {
  static final AccountService _i = AccountService._();
  factory AccountService() => _i;
  AccountService._();

  final _dio = Dio(BaseOptions(
    baseUrl: kApiBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  AccountUser? _user;
  String? _token;

  AccountUser? get currentUser => _user;
  String?      get token       => _token;
  bool         get isLoggedIn  => _token != null && _user != null;

  /// Načíta uložený stav pri štarte aplikácie.
  Future<void> init() async {
    _token        = await _storage.read(key: _kSecToken);
    final id      = await _storage.read(key: _kSecUserId);
    final email   = await _storage.read(key: _kSecEmail);
    final name    = await _storage.read(key: _kSecName);
    if (_token != null && id != null && email != null && name != null) {
      _user = AccountUser(id: id, email: email, name: name);
    }
  }

  Future<AccountUser> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final resp = await _dio.post('/auth/register', data: {
      'email': email.trim().toLowerCase(),
      'name': name.trim(),
      'password': password,
    });
    return _handleAuthResponse(resp.data as Map<String, dynamic>);
  }

  Future<AccountUser> login({
    required String email,
    required String password,
  }) async {
    final resp = await _dio.post('/auth/login', data: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    return _handleAuthResponse(resp.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await _dio.post('/auth/logout',
            options: Options(headers: {'Authorization': 'Bearer $_token'}));
      } catch (_) {}
    }
    _token = null;
    _user  = null;
    await _storage.delete(key: _kSecToken);
    await _storage.delete(key: _kSecUserId);
    await _storage.delete(key: _kSecEmail);
    await _storage.delete(key: _kSecName);
  }

  Future<AccountUser> _handleAuthResponse(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final u = data['user'] as Map<String, dynamic>;
    final user = AccountUser(
      id: u['id'] as String,
      email: u['email'] as String,
      name: u['name'] as String,
    );
    _token = token;
    _user  = user;
    await _storage.write(key: _kSecToken,  value: token);
    await _storage.write(key: _kSecUserId, value: user.id);
    await _storage.write(key: _kSecEmail,  value: user.email);
    await _storage.write(key: _kSecName,   value: user.name);
    return user;
  }

  /// Vráti http hlavičku pre autentifikované požiadavky.
  Map<String, String> get authHeaders =>
      isLoggedIn ? {'Authorization': 'Bearer $_token'} : {};
}
