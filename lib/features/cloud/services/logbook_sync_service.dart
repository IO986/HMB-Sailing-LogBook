import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/device_identity.dart';
import '../domain/cloud_storage_provider.dart';

/// Same root folder as the day PDF/GPX export (`auto_export_service.dart`),
/// separate subfolder — sync changesets are machine-readable JSON the
/// skipper never opens by hand, and must not clutter the folder they browse
/// for their documents.
const _syncFolder = ['HMB_Sailing_Log_DATA', 'sync'];

const _kLastPushAt = 'logbook_sync_last_push_at';
const _kLastPullAt = 'logbook_sync_last_pull_at';

/// Real cross-device sync of the logbook itself — distinct from
/// `AutoExportService`, which only ever ships finished PDF/GPX files one
/// way. This pushes changed rows as a JSON changeset and pulls the same
/// from every other device signed in to the same Drive account, so two
/// phones on the same boat (one wired to the instruments, one carried
/// around for photos) see each other's entries without waiting for either
/// one to restart.
///
/// Deliberately built for **one skipper's own devices**, not multi-user
/// collaboration: identity is a per-row `syncUuid`/`sessionId`, conflicts
/// resolve by "newest `updatedAt` wins" with no manual merge UI. That's
/// enough because writes are almost always additive (new entries, new
/// track points) — the rare edited field (e.g. a recomputed `distanceNm`)
/// self-heals next sync since it's derived, not authored.
class LogbookSyncService {
  const LogbookSyncService();

  /// Runs one push-then-pull cycle. Safe to call repeatedly — an empty
  /// changeset is never uploaded, and re-applying an already-seen file is a
  /// no-op (same `syncUuid` + same `updatedAt` just overwrites with
  /// identical data).
  ///
  /// [deviceId] defaults to this install's [DeviceIdentity.id]; overridable
  /// so a test can simulate two distinct devices sharing one fake Drive
  /// without the real id's process-wide cache getting in the way.
  Future<void> syncNow({
    required AppDatabase db,
    required CloudStorageProvider provider,
    String? deviceId,
  }) async {
    if (!provider.isSignedInNow) return;
    final id = deviceId ?? await DeviceIdentity.id();
    await _push(db: db, provider: provider, deviceId: id);
    await _pull(db: db, provider: provider, deviceId: id);
  }

  // ── Push ──────────────────────────────────────────────────────

  Future<void> _push({
    required AppDatabase db,
    required CloudStorageProvider provider,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sinceMs = prefs.getInt(_kLastPushAt);
    final since = sinceMs == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.fromMillisecondsSinceEpoch(sinceMs);
    final pushStartedAt = DateTime.now().toUtc();

    final changeset = await composeChangeset(db, since);
    if (_isEmpty(changeset)) {
      await prefs.setInt(_kLastPushAt, pushStartedAt.millisecondsSinceEpoch);
      return;
    }
    changeset['deviceId'] = deviceId;
    changeset['createdAt'] = pushStartedAt.toIso8601String();

    final tmpDir = await getTemporaryDirectory();
    final file = File(
        '${tmpDir.path}/sync-$deviceId-${pushStartedAt.millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(changeset));
    try {
      await provider.upload(
        file: file,
        fileName: '$deviceId-${pushStartedAt.millisecondsSinceEpoch}.json',
        folderPath: _syncFolder,
        mimeType: 'application/json',
      );
      await prefs.setInt(_kLastPushAt, pushStartedAt.millisecondsSinceEpoch);
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  bool _isEmpty(Map<String, dynamic> changeset) =>
      changeset.values.every((v) => v is List && v.isEmpty);

  // ── Pull ──────────────────────────────────────────────────────

  Future<void> _pull({
    required AppDatabase db,
    required CloudStorageProvider provider,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sinceMs = prefs.getInt(_kLastPullAt);
    final since = sinceMs == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.fromMillisecondsSinceEpoch(sinceMs);

    final files = await provider.listFiles(_syncFolder);
    // Never our own upload — a device applying its own changeset back onto
    // itself would be a no-op at best, and at worst races its own next push
    // if the merge logic ever stops being purely idempotent.
    final fromOthers = files.where((f) =>
        !f.name.startsWith('$deviceId-') &&
        f.modifiedTime != null &&
        f.modifiedTime!.isAfter(since));

    var latestSeen = since;
    final changesets = <Map<String, dynamic>>[];
    for (final f in fromOthers) {
      final bytes = await provider.downloadFile(f.id);
      try {
        changesets.add(jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>);
      } catch (_) {
        // A malformed/partial file from another device must not wedge this
        // device's sync forever — skip it, next push from that device
        // carries the same rows again anyway (they're still "changed since"
        // its own last successful push).
        continue;
      }
      if (f.modifiedTime!.isAfter(latestSeen)) latestSeen = f.modifiedTime!;
    }

    if (changesets.isNotEmpty) {
      await applyChangesets(db, changesets);
    }
    await prefs.setInt(_kLastPullAt, latestSeen.millisecondsSinceEpoch);
  }
}

// ─────────────────────────────────────────────────────────────
// Compose — DB rows → JSON
// ─────────────────────────────────────────────────────────────

/// Rows changed since [since], keyed by table name. Assigns `syncUuid` to
/// any row that doesn't have one yet (first sync after upgrading from a
/// pre-sync build) before reading — lazily, here, rather than at every
/// insert/update call site across the app.
Future<Map<String, dynamic>> composeChangeset(AppDatabase db, DateTime since) async {
  await _backfillMissingSyncUuids(db);

  final charters = await (db.select(db.charters)
        ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
      .get();
  final dayLogs = await (db.select(db.dayLogs)
        ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
      .get();
  final sessions = await (db.select(db.sailingSessions)
        ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
      .get();
  final entries = await (db.select(db.logbookEntries)
        ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
      .get();
  final waypoints = await (db.select(db.waypoints)
        ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
      .get();
  final trackPoints = await (db.select(db.trackPoints)
        ..where((t) => t.timestamp.isBiggerOrEqualValue(since)))
      .get();

  final charterUuidById = {for (final c in charters) c.id: c.syncUuid!};
  final dayLogUuidById = {for (final d in dayLogs) d.id: d.syncUuid!};

  // FK parents this batch didn't itself touch (e.g. a day log changed but
  // its charter didn't) still need their syncUuid looked up, or the child
  // row would ship with no way to find its parent on the other device.
  final missingCharterIds =
      dayLogs.map((d) => d.charterId).toSet().difference(charterUuidById.keys.toSet());
  if (missingCharterIds.isNotEmpty) {
    final extra =
        await (db.select(db.charters)..where((t) => t.id.isIn(missingCharterIds))).get();
    charterUuidById.addAll({for (final c in extra) c.id: c.syncUuid!});
  }
  final neededDayLogIds = {
    for (final e in entries)
      if (e.dayLogId != null) e.dayLogId!,
    for (final s in sessions)
      if (s.dayLogId != null) s.dayLogId!,
  }.difference(dayLogUuidById.keys.toSet());
  if (neededDayLogIds.isNotEmpty) {
    final extra =
        await (db.select(db.dayLogs)..where((t) => t.id.isIn(neededDayLogIds))).get();
    dayLogUuidById.addAll({for (final d in extra) d.id: d.syncUuid!});
  }

  return {
    'charters': [for (final c in charters) c.toJson()..remove('id')],
    'dayLogs': [
      for (final d in dayLogs)
        (d.toJson()..remove('id')..remove('charterId'))
          ..['charterSyncUuid'] = charterUuidById[d.charterId],
    ],
    'sailingSessions': [
      for (final s in sessions)
        (s.toJson()..remove('id')..remove('dayLogId'))
          ..['dayLogSyncUuid'] = s.dayLogId == null ? null : dayLogUuidById[s.dayLogId],
    ],
    'logbookEntries': [
      for (final e in entries)
        (e.toJson()..remove('id')..remove('dayLogId'))
          ..['dayLogSyncUuid'] = e.dayLogId == null ? null : dayLogUuidById[e.dayLogId],
    ],
    'waypoints': [for (final w in waypoints) w.toJson()..remove('id')],
    'trackPoints': [for (final t in trackPoints) t.toJson()..remove('id')],
  };
}

Future<void> _backfillMissingSyncUuids(AppDatabase db) async {
  const uuid = Uuid();
  final now = DateTime.now().toUtc();

  final charters = await (db.select(db.charters)
        ..where((t) => t.syncUuid.isNull()))
      .get();
  for (final c in charters) {
    await (db.update(db.charters)..where((t) => t.id.equals(c.id))).write(
      ChartersCompanion(syncUuid: Value(uuid.v4()), updatedAt: Value(c.updatedAt ?? now)),
    );
  }

  final dayLogs = await (db.select(db.dayLogs)..where((t) => t.syncUuid.isNull())).get();
  for (final d in dayLogs) {
    await (db.update(db.dayLogs)..where((t) => t.id.equals(d.id))).write(
      DayLogsCompanion(syncUuid: Value(uuid.v4()), updatedAt: Value(d.updatedAt ?? now)),
    );
  }

  final entries =
      await (db.select(db.logbookEntries)..where((t) => t.syncUuid.isNull())).get();
  for (final e in entries) {
    await (db.update(db.logbookEntries)..where((t) => t.id.equals(e.id))).write(
      LogbookEntriesCompanion(syncUuid: Value(uuid.v4()), updatedAt: Value(e.updatedAt ?? now)),
    );
  }

  final waypoints = await (db.select(db.waypoints)..where((t) => t.syncUuid.isNull())).get();
  for (final w in waypoints) {
    await (db.update(db.waypoints)..where((t) => t.id.equals(w.id))).write(
      WaypointsCompanion(syncUuid: Value(uuid.v4()), updatedAt: Value(w.updatedAt ?? now)),
    );
  }

  final sessions =
      await (db.select(db.sailingSessions)..where((t) => t.updatedAt.isNull())).get();
  for (final s in sessions) {
    await (db.update(db.sailingSessions)..where((t) => t.id.equals(s.id))).write(
      SailingSessionsCompanion(updatedAt: Value(s.startTime)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Apply — JSON → DB rows
// ─────────────────────────────────────────────────────────────

/// Merges one or more changesets (already parsed) into [db]. Order matters:
/// charters before day logs before sessions/entries before waypoints/track
/// points, so a parent that arrived in the same pull batch resolves before
/// its children are applied — see the class doc on why an unresolved
/// parent (arriving in a *later* pull instead) is an accepted gap in this
/// first version rather than a queued retry.
Future<void> applyChangesets(AppDatabase db, List<Map<String, dynamic>> changesets) async {
  for (final c in changesets) {
    for (final row in (c['charters'] as List? ?? const [])) {
      await _mergeCharter(db, row as Map<String, dynamic>);
    }
  }
  for (final c in changesets) {
    for (final row in (c['dayLogs'] as List? ?? const [])) {
      await _mergeDayLog(db, row as Map<String, dynamic>);
    }
  }
  for (final c in changesets) {
    for (final row in (c['sailingSessions'] as List? ?? const [])) {
      await _mergeSession(db, row as Map<String, dynamic>);
    }
    for (final row in (c['logbookEntries'] as List? ?? const [])) {
      await _mergeEntry(db, row as Map<String, dynamic>);
    }
    for (final row in (c['waypoints'] as List? ?? const [])) {
      await _mergeWaypoint(db, row as Map<String, dynamic>);
    }
    for (final row in (c['trackPoints'] as List? ?? const [])) {
      await _mergeTrackPoint(db, row as Map<String, dynamic>);
    }
  }
}

Future<void> _mergeCharter(AppDatabase db, Map<String, dynamic> json) async {
  final syncUuid = json['syncUuid'] as String?;
  if (syncUuid == null) return;
  final incoming = Charter.fromJson({...json, 'id': 0});
  final local = await (db.select(db.charters)..where((t) => t.syncUuid.equals(syncUuid)))
      .getSingleOrNull();
  if (local != null && !_isNewer(incoming.updatedAt, local.updatedAt)) return;

  final companion = incoming.toCompanion(false);
  if (local != null) {
    await (db.update(db.charters)..where((t) => t.id.equals(local.id)))
        .write(companion.copyWith(id: Value(local.id)));
  } else {
    await db.into(db.charters).insert(companion.copyWith(id: const Value.absent()));
  }
}

Future<void> _mergeDayLog(AppDatabase db, Map<String, dynamic> json) async {
  final syncUuid = json['syncUuid'] as String?;
  final charterSyncUuid = json['charterSyncUuid'] as String?;
  if (syncUuid == null || charterSyncUuid == null) return;
  final charter = await (db.select(db.charters)
        ..where((t) => t.syncUuid.equals(charterSyncUuid)))
      .getSingleOrNull();
  // Parent not here yet — see applyChangesets doc. Dropped, not queued.
  if (charter == null) return;

  final incoming = DayLog.fromJson({...json, 'id': 0, 'charterId': charter.id});
  final local = await (db.select(db.dayLogs)..where((t) => t.syncUuid.equals(syncUuid)))
      .getSingleOrNull();
  if (local != null && !_isNewer(incoming.updatedAt, local.updatedAt)) return;

  final companion = incoming.toCompanion(false).copyWith(charterId: Value(charter.id));
  if (local != null) {
    await (db.update(db.dayLogs)..where((t) => t.id.equals(local.id)))
        .write(companion.copyWith(id: Value(local.id)));
  } else {
    await db.into(db.dayLogs).insert(companion.copyWith(id: const Value.absent()));
  }
}

Future<void> _mergeSession(AppDatabase db, Map<String, dynamic> json) async {
  final sessionId = json['sessionId'] as String?;
  if (sessionId == null) return;
  final dayLogSyncUuid = json['dayLogSyncUuid'] as String?;
  int? dayLogId;
  if (dayLogSyncUuid != null) {
    final day = await (db.select(db.dayLogs)
          ..where((t) => t.syncUuid.equals(dayLogSyncUuid)))
        .getSingleOrNull();
    dayLogId = day?.id; // null stays null — the session just isn't linked yet.
  }

  final incoming = SailingSession.fromJson({...json, 'id': 0, 'dayLogId': dayLogId});
  final local = await (db.select(db.sailingSessions)
        ..where((t) => t.sessionId.equals(sessionId)))
      .getSingleOrNull();
  if (local != null && !_isNewer(incoming.updatedAt, local.updatedAt)) return;

  final companion = incoming.toCompanion(false).copyWith(dayLogId: Value(dayLogId));
  if (local != null) {
    await (db.update(db.sailingSessions)..where((t) => t.id.equals(local.id)))
        .write(companion.copyWith(id: Value(local.id)));
  } else {
    await db.into(db.sailingSessions).insert(companion.copyWith(id: const Value.absent()));
  }
}

Future<void> _mergeEntry(AppDatabase db, Map<String, dynamic> json) async {
  final syncUuid = json['syncUuid'] as String?;
  if (syncUuid == null) return;
  final dayLogSyncUuid = json['dayLogSyncUuid'] as String?;
  int? dayLogId;
  if (dayLogSyncUuid != null) {
    final day = await (db.select(db.dayLogs)
          ..where((t) => t.syncUuid.equals(dayLogSyncUuid)))
        .getSingleOrNull();
    if (day == null) return; // parent not here yet — see applyChangesets doc.
    dayLogId = day.id;
  }

  final incoming = LogbookEntry.fromJson({...json, 'id': 0, 'dayLogId': dayLogId});
  final local = await (db.select(db.logbookEntries)
        ..where((t) => t.syncUuid.equals(syncUuid)))
      .getSingleOrNull();
  if (local != null && !_isNewer(incoming.updatedAt, local.updatedAt)) return;

  final companion = incoming.toCompanion(false).copyWith(dayLogId: Value(dayLogId));
  if (local != null) {
    await (db.update(db.logbookEntries)..where((t) => t.id.equals(local.id)))
        .write(companion.copyWith(id: Value(local.id)));
  } else {
    await db.into(db.logbookEntries).insert(companion.copyWith(id: const Value.absent()));
  }
}

Future<void> _mergeWaypoint(AppDatabase db, Map<String, dynamic> json) async {
  final syncUuid = json['syncUuid'] as String?;
  if (syncUuid == null) return;
  final incoming = Waypoint.fromJson({...json, 'id': 0});
  final local = await (db.select(db.waypoints)..where((t) => t.syncUuid.equals(syncUuid)))
      .getSingleOrNull();
  if (local != null && !_isNewer(incoming.updatedAt, local.updatedAt)) return;

  final companion = incoming.toCompanion(false);
  if (local != null) {
    await (db.update(db.waypoints)..where((t) => t.id.equals(local.id)))
        .write(companion.copyWith(id: Value(local.id)));
  } else {
    await db.into(db.waypoints).insert(companion.copyWith(id: const Value.absent()));
  }
}

/// Track points are append-only — no `updatedAt`/`syncUuid`, dedup by the
/// natural key of session + moment in time (see schema v35's note on
/// `TrackPoints`).
Future<void> _mergeTrackPoint(AppDatabase db, Map<String, dynamic> json) async {
  final sessionId = json['sessionId'] as String?;
  final rawTimestamp = json['timestamp'];
  if (sessionId == null || rawTimestamp == null) return;
  // Drift's default JSON serializer writes DateTime as a unix-ms int, but
  // `fromJson` on the generated data classes accepts an ISO string too —
  // match that leniency here instead of assuming one shape.
  final ts = rawTimestamp is int
      ? DateTime.fromMillisecondsSinceEpoch(rawTimestamp)
      : DateTime.parse(rawTimestamp.toString());

  final exists = await (db.select(db.trackPoints)
        ..where((t) => t.sessionId.equals(sessionId) & t.timestamp.equals(ts))
        ..limit(1))
      .getSingleOrNull();
  if (exists != null) return;

  final incoming = TrackPoint.fromJson({...json, 'id': 0});
  await db.into(db.trackPoints).insert(incoming.toCompanion(false).copyWith(
        id: const Value.absent(),
      ));
}

bool _isNewer(DateTime? incoming, DateTime? local) {
  if (incoming == null) return false;
  if (local == null) return true;
  return incoming.isAfter(local);
}
