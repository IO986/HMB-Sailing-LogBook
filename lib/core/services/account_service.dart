import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

const _kApiBase = 'https://api.logbook.hmba.boats';

const _kPrefToken    = 'account_token';
const _kPrefUserId   = 'account_user_id';
const _kPrefEmail    = 'account_email';
const _kPrefName     = 'account_name';

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
    baseUrl: _kApiBase,
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
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kPrefToken);
    final id    = prefs.getString(_kPrefUserId);
    final email = prefs.getString(_kPrefEmail);
    final name  = prefs.getString(_kPrefName);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefToken);
    await prefs.remove(_kPrefUserId);
    await prefs.remove(_kPrefEmail);
    await prefs.remove(_kPrefName);
  }

  AccountUser _handleAuthResponse(Map<String, dynamic> data) {
    final token = data['token'] as String;
    final u = data['user'] as Map<String, dynamic>;
    final user = AccountUser(
      id: u['id'] as String,
      email: u['email'] as String,
      name: u['name'] as String,
    );
    _token = token;
    _user  = user;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_kPrefToken,  token);
      prefs.setString(_kPrefUserId, user.id);
      prefs.setString(_kPrefEmail,  user.email);
      prefs.setString(_kPrefName,   user.name);
    });
    return user;
  }

  /// Vráti http hlavičku pre autentifikované požiadavky.
  Map<String, String> get authHeaders =>
      isLoggedIn ? {'Authorization': 'Bearer $_token'} : {};
}
