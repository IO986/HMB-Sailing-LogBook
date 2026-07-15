import 'package:hmb_core/hmb_core.dart' hide LocationService;

/// Unified wire envelope wrapping every outbox item — see docs/SYNC_API.md.
/// Shared by every transport (Strapi, generic REST) so the contract on the
/// wire is identical regardless of destination; only how it's delivered
/// (wrapped in `{"data": ...}`, endpoint shape, attachment upload) differs
/// per transport.
Map<String, dynamic> buildSyncEnvelope({
  required OutboxItem item,
  required String appVersion,
  required List<Map<String, dynamic>> attachments,
}) =>
    {
      'clientId': item.id,
      'entityType': item.entityType,
      'operation': item.operation.name,
      'timestamp': isoWithOffset(item.createdAt),
      'appVersion': appVersion,
      'payload': item.payload,
      'attachments': attachments,
    };

/// ISO-8601 with an explicit numeric UTC offset (e.g. `+02:00`), not `Z` —
/// the wire contract wants the device's local offset at creation time.
String isoWithOffset(DateTime dt) {
  final local = dt.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final h = offset.abs().inHours.toString().padLeft(2, '0');
  final m = offset.abs().inMinutes.remainder(60).toString().padLeft(2, '0');
  final base = local.toIso8601String().split('.').first;
  return '$base$sign$h:$m';
}
