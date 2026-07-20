import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/google_drive_storage.dart';
import '../domain/cloud_storage_provider.dart';

/// The active [CloudStorageProvider] instance.
///
/// Deliberately built once for the app's lifetime (watches nothing, so
/// Riverpod never rebuilds it) rather than switched per `settings.
/// cloudProvider` — `GoogleDriveStorage` wraps `GoogleSignIn.instance`, a
/// process-wide singleton whose `initialize()` the plugin documents as
/// undefined behavior if called more than once. A second provider (WebDAV,
/// Proton Drive) can be selected here once one exists, but must not cause a
/// second `GoogleDriveStorage` to be constructed while one is already live.
final cloudStorageProviderProvider =
    Provider<CloudStorageProvider>((ref) => GoogleDriveStorage());
