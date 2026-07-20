/// Which backend a sync cycle pushes to.
enum SyncTarget { hmbAcademy, custom }

/// When an item with an attachment is allowed to actually upload it.
/// Items without attachments are never affected by this — it's purely
/// about the connection cost of photos.
enum AttachmentSyncPolicy { never, wifiOnly, always }

/// Which cloud backend the auto-export feature uploads to. Only
/// [googleDrive] exists so far — see `docs/plan_cloud_export.md` §2 for why
/// the interface is shaped to add others (WebDAV, Proton Drive) later.
enum CloudProvider { googleDrive }

class SyncSettings {
  const SyncSettings({
    this.enabled = false,
    this.target = SyncTarget.hmbAcademy,
    this.customUrl = '',
    this.intervalMinutes = 15,
    this.attachmentPolicy = AttachmentSyncPolicy.wifiOnly,
    this.cloudEnabled = false,
    this.cloudProvider = CloudProvider.googleDrive,
  });

  final bool enabled;
  final SyncTarget target;
  final String customUrl;
  final int intervalMinutes;
  final AttachmentSyncPolicy attachmentPolicy;
  final bool cloudEnabled;
  final CloudProvider cloudProvider;

  SyncSettings copyWith({
    bool? enabled,
    SyncTarget? target,
    String? customUrl,
    int? intervalMinutes,
    AttachmentSyncPolicy? attachmentPolicy,
    bool? cloudEnabled,
    CloudProvider? cloudProvider,
  }) =>
      SyncSettings(
        enabled: enabled ?? this.enabled,
        target: target ?? this.target,
        customUrl: customUrl ?? this.customUrl,
        intervalMinutes: intervalMinutes ?? this.intervalMinutes,
        attachmentPolicy: attachmentPolicy ?? this.attachmentPolicy,
        cloudEnabled: cloudEnabled ?? this.cloudEnabled,
        cloudProvider: cloudProvider ?? this.cloudProvider,
      );
}

enum SyncUrlError { empty, invalid, httpsRequired }

/// `null` when [url] is an acceptable custom sync server URL; otherwise
/// which way it's rejected. HTTPS is mandatory — the auth token travels in
/// an `Authorization` header, plain HTTP would leak it in transit.
SyncUrlError? validateSyncServerUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return SyncUrlError.empty;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return SyncUrlError.invalid;
  if (uri.scheme != 'https') return SyncUrlError.httpsRequired;
  return null;
}
