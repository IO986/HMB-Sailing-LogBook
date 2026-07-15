/// Which backend a sync cycle pushes to.
enum SyncTarget { hmbAcademy, custom }

/// When an item with an attachment is allowed to actually upload it.
/// Items without attachments are never affected by this — it's purely
/// about the connection cost of photos.
enum AttachmentSyncPolicy { never, wifiOnly, always }

class SyncSettings {
  const SyncSettings({
    this.enabled = false,
    this.target = SyncTarget.hmbAcademy,
    this.customUrl = '',
    this.intervalMinutes = 15,
    this.attachmentPolicy = AttachmentSyncPolicy.wifiOnly,
  });

  final bool enabled;
  final SyncTarget target;
  final String customUrl;
  final int intervalMinutes;
  final AttachmentSyncPolicy attachmentPolicy;

  SyncSettings copyWith({
    bool? enabled,
    SyncTarget? target,
    String? customUrl,
    int? intervalMinutes,
    AttachmentSyncPolicy? attachmentPolicy,
  }) =>
      SyncSettings(
        enabled: enabled ?? this.enabled,
        target: target ?? this.target,
        customUrl: customUrl ?? this.customUrl,
        intervalMinutes: intervalMinutes ?? this.intervalMinutes,
        attachmentPolicy: attachmentPolicy ?? this.attachmentPolicy,
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
