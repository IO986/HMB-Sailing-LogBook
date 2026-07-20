import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

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
class GoogleDriveStorage implements CloudStorageProvider {
  GoogleDriveStorage({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  Future<void>? _initialized;
  GoogleSignInAccount? _account;

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

  @override
  Future<CloudAccount?> get currentAccount async {
    _account ??= await _attemptSilentSignIn();
    final account = _account;
    if (account == null) return null;
    return CloudAccount(email: account.email, displayName: account.displayName);
  }

  @override
  bool get isSignedInNow => _account != null;

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
    return CloudAccount(email: account.email, displayName: account.displayName);
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    _account = null;
  }

  Future<drive.DriveApi> _driveApi() async {
    await _ensureInitialized();
    final account = _account ?? await _attemptSilentSignIn();
    if (account == null) {
      throw StateError('Google Drive: not signed in');
    }
    _account = account;

    final authClient = account.authorizationClient;
    // Silent first — only prompts if the user hasn't already granted
    // drive.file (typically the first upload ever, or after revoking access).
    final authorization = await authClient.authorizationForScopes(_scopes) ??
        await authClient.authorizeScopes(_scopes);
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
  final escapedName = name.replaceAll(r"'", r"\'");
  final parentClause = parentId != null ? "'$parentId' in parents" : "'root' in parents";
  final query = "mimeType = 'application/vnd.google-apps.folder' "
      "and name = '$escapedName' and trashed = false and $parentClause";

  final result = await api.files.list(q: query, spaces: 'drive', $fields: 'files(id, name)');
  final existingId = result.files?.firstOrNull?.id;
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

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
