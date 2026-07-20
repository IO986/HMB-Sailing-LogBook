import 'dart:io';

/// A signed-in cloud account, enough to show the user who they're uploading
/// as — nothing more travels through this layer.
class CloudAccount {
  const CloudAccount({required this.email, this.displayName});

  final String email;
  final String? displayName;
}

/// Uploads day exports to a cloud backend, decoupled from any specific
/// vendor. `google_drive` is the first implementation; the shape exists so
/// a WebDAV or Proton Drive provider can be added later without touching
/// call sites (see `docs/plan_cloud_export.md`).
abstract class CloudStorageProvider {
  /// Stable id, e.g. `'google_drive'` — persisted in settings to remember
  /// which provider the user picked.
  String get id;

  /// User-facing name, e.g. `'Google Drive'`.
  String get displayName;

  /// The signed-in account, restored silently if a session already exists
  /// (e.g. after an app restart) — `null` if no account is signed in.
  /// Deviates from the plan's original `Future<bool> get isSignedIn`: the
  /// settings UI needs the email to show "signed in as ...", and a bare
  /// bool would have meant re-running the interactive flow just to display
  /// it. Callers that only need the boolean can check `!= null`.
  Future<CloudAccount?> get currentAccount;

  /// Cheap, synchronous, in-memory-only check — never touches the
  /// platform SDK, never shows UI. `true` only once a real session is
  /// cached from a completed [signIn] (or an already-restored
  /// [currentAccount]) this process. Background upload code (`
  /// CloudUploadTransport`) must gate on this, not on [currentAccount]:
  /// on this app's Android/Credential Manager combination, even the
  /// "silent" restore path can surface an account-picker sheet when no
  /// in-memory session exists (see docs/HANDOVER.md, 20. 7.) — acceptable
  /// when the user just triggered it (opening settings, tapping a button),
  /// completely unacceptable from a periodic background sync tick.
  bool get isSignedInNow;

  /// Runs the interactive sign-in flow. Returns `null` if the user cancels
  /// rather than throwing — cancellation isn't an error.
  Future<CloudAccount?> signIn();

  Future<void> signOut();

  /// Uploads [file] as [fileName] under [folderPath] (created if missing,
  /// e.g. `['HMB_Sailing_Log_DATA', 'Plavba 2026', 'Day_2026-07-20']`). Returns
  /// the provider's id for the uploaded file.
  Future<String> upload({
    required File file,
    required String fileName,
    required List<String> folderPath,
    required String mimeType,
  });
}
