/// Canonical `entityType` strings used across the outbox — see
/// docs/SYNC_API.md for the full payload contract per type.
class SyncEntityType {
  static const voyage = 'voyage';
  static const logEntry = 'log_entry';
  static const trackPoint = 'track_point';
  static const instrumentSample = 'instrument_sample';
  static const photo = 'photo';
  static const vessel = 'vessel';

  /// PDF/GPX day exports uploaded to a [CloudStorageProvider] — a purely
  /// app-level type, never seen by `hmb_core` or `StrapiTransport`/
  /// `RestTransport`. `RoutingTransport` routes this one to the cloud
  /// branch, everything else to the existing backend transport.
  static const cloudExport = 'cloud_export';
}

/// Default Strapi collection name per `entityType`, for
/// `StrapiTransport.collectionByEntityType`. Only `log_entry` is actually
/// enqueued by the app today (KROK "enqueue wiring") — the rest are part of
/// the documented contract for entities not wired up yet.
const kDefaultStrapiCollections = {
  SyncEntityType.voyage: 'voyages',
  SyncEntityType.logEntry: 'log-entries',
  SyncEntityType.trackPoint: 'track-points',
  SyncEntityType.instrumentSample: 'instrument-samples',
  SyncEntityType.photo: 'photos',
  SyncEntityType.vessel: 'vessels',
};
