import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/api_constants.dart';
import '../domain/cloud_storage_provider.dart';

const _scopes = [drive.DriveApi.driveFileScope];

/// [CloudStorageProvider] backed by Google Drive, scoped to `drive.file` —
/// the app only ever sees files it created itself (see
/// `docs/plan_cloud_export.md` §7 for why this scope was chosen).
///
/// `google_sign_in` 7.x split what used to be one call (`signIn()`) into
/// separate identity (`authenticate()`) and authorization
/// (`account.authorizationClient.authorizeScopes(...)`) steps — Drive access
/// is an authorization, requested only when actually needed (first upload),
/// not at sign-in time.
///
/// Prihlásený účet sa pamätá v SharedPreferences. Session z `authenticate()`
/// žije len v pamäti procesu a jej obnova (`attemptLightweightAuthentication`)
/// na Honore ukazuje výber účtu, takže sa po reštarte appky nedala robiť na
/// pozadí — a po každom reštarte (na mori takmer denne) appka ticho prestala
/// nahrávať, kým skiper neotvoril Nastavenia (nahlásené z októbrovej plavby:
/// „tvári sa, že ma prihlásilo, no nič sa nedeje"). Token pre Drive sa preto
/// berie cez autorizáciu bez účtu (`authorizationForScopes`), ktorá na
/// Androide nikdy neukazuje UI: buď vráti token, alebo null.
class GoogleDriveStorage implements CloudStorageProvider {
  GoogleDriveStorage({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance {
    _rememberedLoad = _loadRemembered();
  }

  static const _kEmail = 'cloud_account_email';
  static const _kName = 'cloud_account_name';

  final GoogleSignIn _googleSignIn;
  Future<void>? _initialized;
  GoogleSignInAccount? _account;

  /// Účet z minulého prihlásenia — platí, kým sa skiper neodhlási.
  CloudAccount? _remembered;
  late final Future<void> _rememberedLoad;

  Future<void> _loadRemembered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_kEmail);
      if (email != null && email.isNotEmpty) {
        _remembered =
            CloudAccount(email: email, displayName: prefs.getString(_kName));
      }
    } catch (e) {
      debugPrint('[Cloud] remembered account load failed: $e');
    }
  }

  Future<void> _remember(GoogleSignInAccount? account) async {
    final prefs = await SharedPreferences.getInstance();
    if (account == null) {
      _remembered = null;
      await prefs.remove(_kEmail);
      await prefs.remove(_kName);
      return;
    }
    _remembered =
        CloudAccount(email: account.email, displayName: account.displayName);
    await prefs.setString(_kEmail, account.email);
    final name = account.displayName;
    if (name == null) {
      await prefs.remove(_kName);
    } else {
      await prefs.setString(_kName, name);
    }
  }

  /// `initialize()` may only be called once per process and must complete
  /// before any other method — cache the same future so concurrent callers
  /// (e.g. a settings screen checking `isSignedIn` while a background sync
  /// cycle also wants a `DriveApi`) share one initialization instead of
  /// racing a second call, which the plugin documents as undefined behavior.
  Future<void> _ensureInitialized() => _initialized ??= _googleSignIn.initialize(
        serverClientId: kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
      );

  @override
  String get id => 'google_drive';

  @override
  String get displayName => 'Google Drive';

  /// Bez volania SDK, kým je účet zapamätaný — obnova session cez SDK
  /// ukazovala na Honore výber účtu pri každom otvorení Nastavení.
  @override
  Future<CloudAccount?> get currentAccount async {
    final account = _account;
    if (account != null) {
      return CloudAccount(email: account.email, displayName: account.displayName);
    }
    await _rememberedLoad;
    if (_remembered != null) return _remembered;
    _account = await _attemptSilentSignIn();
    final restored = _account;
    if (restored == null) return null;
    await _remember(restored);
    return CloudAccount(email: restored.email, displayName: restored.displayName);
  }

  @override
  bool get isSignedInNow => _account != null || _remembered != null;

  Future<GoogleSignInAccount?> _attemptSilentSignIn() async {
    await _ensureInitialized();
    // Per the plugin docs, a null future here (rather than a null account)
    // means the platform can only report sign-in via `authenticationEvents`
    // — not the case on Android, but treat it the same as "not signed in"
    // rather than assuming a Future is always returned.
    return _googleSignIn.attemptLightweightAuthentication();
  }

  @override
  Future<CloudAccount?> signIn() async {
    await _ensureInitialized();
    try {
      _account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    final account = _account!;
    // Drive povolenie hneď pri prihlásení, kým je skiper pri telefóne —
    // inak by si ho prvý upload vypýtal až zo synchronizácie, kde sa pýtať
    // nesmie, a uploady by ticho čakali.
    try {
      await account.authorizationClient.authorizeScopes(_scopes);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _account = null;
        return null;
      }
      rethrow;
    }
    await _remember(account);
    return CloudAccount(email: account.email, displayName: account.displayName);
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    _account = null;
    await _remember(null);
  }

  /// Nikdy neukáže UI — volá sa zo synchronizácie na pozadí. Keď povolenie
  /// bez skipera získať nejde, hodí [StateError] a položka vo fronte počká
  /// (CloudUploadTransport ju odloží, nezahodí).
  Future<drive.DriveApi> _driveApi() async {
    await _ensureInitialized();
    await _rememberedLoad;
    final account = _account;
    if (account == null && _remembered == null) {
      throw StateError('Google Drive: not signed in');
    }
    final authClient =
        account?.authorizationClient ?? _googleSignIn.authorizationClient;
    final authorization = await authClient.authorizationForScopes(_scopes);
    if (authorization == null) {
      throw StateError('Google Drive: authorization needs the user');
    }
    return drive.DriveApi(authorization.authClient(scopes: _scopes));
  }

  @override
  Future<String> upload({
    required File file,
    required String fileName,
    required List<String> folderPath,
    required String mimeType,
  }) async {
    final api = await _driveApi();
    return uploadToDrive(
      api: api,
      file: file,
      fileName: fileName,
      folderPath: folderPath,
      mimeType: mimeType,
    );
  }

  @override
  Future<List<CloudFile>> listFiles(List<String> folderPath) async {
    final api = await _driveApi();
    return listDriveFiles(api: api, folderPath: folderPath);
  }

  @override
  Future<List<int>> downloadFile(String fileId) async {
    final api = await _driveApi();
    return downloadFromDrive(api: api, fileId: fileId);
  }
}

/// Folder-ensure-then-upload logic, split out from [GoogleDriveStorage] so it
/// can be unit tested against a fake [drive.DriveApi] without any real
/// sign-in — see `test/cloud/google_drive_storage_test.dart`.
Future<String> uploadToDrive({
  required drive.DriveApi api,
  required File file,
  required String fileName,
  required List<String> folderPath,
  required String mimeType,
}) async {
  String? parentId;
  for (final segment in folderPath) {
    parentId = await _ensureFolder(api, segment, parentId);
  }

  final driveFile = drive.File()
    ..name = fileName
    ..parents = parentId != null ? [parentId] : null;
  final media = drive.Media(file.openRead(), await file.length(), contentType: mimeType);

  final created = await api.files.create(driveFile, uploadMedia: media);
  final id = created.id;
  if (id == null) {
    throw StateError('Google Drive: upload of "$fileName" returned no file id');
  }
  return id;
}

/// Finds an existing folder named [name] under [parentId] (or the account
/// root drive, if `null`), or creates one. `drive.file` scope only exposes
/// folders this app itself created, so a stale id from a deleted folder
/// isn't a concern here — a fresh search always runs.
Future<String> _ensureFolder(drive.DriveApi api, String name, String? parentId) async {
  final existingId = await _findFolder(api, name, parentId);
  if (existingId != null) return existingId;

  final folder = drive.File()
    ..name = name
    ..mimeType = 'application/vnd.google-apps.folder'
    ..parents = parentId != null ? [parentId] : null;
  final created = await api.files.create(folder);
  final createdId = created.id;
  if (createdId == null) {
    throw StateError('Google Drive: folder creation for "$name" returned no id');
  }
  return createdId;
}

/// Same search as [_ensureFolder], without the create-if-missing side
/// effect — [listDriveFiles] must not conjure a folder into existence just
/// by checking whether anyone has ever synced to it.
Future<String?> _findFolder(drive.DriveApi api, String name, String? parentId) async {
  final escapedName = name.replaceAll(r"'", r"\'");
  final parentClause = parentId != null ? "'$parentId' in parents" : "'root' in parents";
  final query = "mimeType = 'application/vnd.google-apps.folder' "
      "and name = '$escapedName' and trashed = false and $parentClause";

  final result = await api.files.list(q: query, spaces: 'drive', $fields: 'files(id, name)');
  return result.files?.firstOrNull?.id;
}

/// Lists files directly under [folderPath], split out from
/// [GoogleDriveStorage] so it can be unit tested against a fake
/// [drive.DriveApi] without any real sign-in, like [uploadToDrive].
///
/// Walks the path with [_findFolder] (never creates): a folder that doesn't
/// exist yet means nothing has synced there, which is an empty list, not an
/// error.
Future<List<CloudFile>> listDriveFiles({
  required drive.DriveApi api,
  required List<String> folderPath,
}) async {
  String? parentId;
  for (final segment in folderPath) {
    final id = await _findFolder(api, segment, parentId);
    if (id == null) return const [];
    parentId = id;
  }

  final parentClause = parentId != null ? "'$parentId' in parents" : "'root' in parents";
  final query = "mimeType != 'application/vnd.google-apps.folder' "
      "and trashed = false and $parentClause";
  final result = await api.files.list(
    q: query,
    spaces: 'drive',
    $fields: 'files(id, name, modifiedTime)',
  );

  return [
    for (final f in result.files ?? const <drive.File>[])
      if (f.id != null && f.name != null)
        CloudFile(id: f.id!, name: f.name!, modifiedTime: f.modifiedTime),
  ];
}

/// Downloads the raw bytes of Drive file [fileId], split out from
/// [GoogleDriveStorage] for the same testability reason as [uploadToDrive].
Future<List<int>> downloadFromDrive({
  required drive.DriveApi api,
  required String fileId,
}) async {
  final media = await api.files.get(
    fileId,
    downloadOptions: drive.DownloadOptions.fullMedia,
  ) as drive.Media;
  final bytes = <int>[];
  await for (final chunk in media.stream) {
    bytes.addAll(chunk);
  }
  return bytes;
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
