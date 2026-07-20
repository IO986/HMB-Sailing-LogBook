import 'dart:io';

import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../core/database/app_database.dart';

/// Queues logbook entries that exist locally but were never enqueued —
/// entries written while sync was off (see `docs/HANDOVER.md` / the
/// `enqueue()` call sites in `logbook_entry_screen.dart`,
/// `quick_photo_log_sheet.dart`, `gps_tracking_service.dart`) never get an
/// outbox row, so turning sync back on doesn't retroactively send them.
/// This is the manual "catch up" the user triggers from the sync settings
/// card.
///
/// Payload shape mirrors `logbook_entry_screen.dart`'s `_buildPayload` —
/// kept as a separate mapping (not shared code) because that one reads
/// live form-controller state, this one reads a persisted [LogbookEntry]
/// row; the two have no state in common beyond field names.
Future<int> backfillUnsyncedLogEntries({
  required AppDatabase db,
  required SyncEngine engine,
}) async {
  final outboxRows = await db.getAllOutboxRows();
  final alreadyQueued = outboxRows
      .where((r) => r.entityType == 'log_entry' && r.entityId != null)
      .map((r) => r.entityId!)
      .toSet();

  final entries = await db.getAllLogbookEntries();
  var queuedCount = 0;

  for (final entry in entries) {
    final entityId = entry.id.toString();
    if (alreadyQueued.contains(entityId)) continue;

    await engine.enqueue(
      entityType: 'log_entry',
      entityId: entityId,
      payload: _payloadFor(entry),
      attachments: await _attachmentsFor(entry),
    );
    queuedCount++;
  }

  return queuedCount;
}

Map<String, dynamic> _payloadFor(LogbookEntry entry) => {
      'dayLogId': entry.dayLogId,
      'timestamp': entry.timestamp.toUtc().toIso8601String(),
      'latitude': entry.latitude,
      'longitude': entry.longitude,
      'sog': entry.sog,
      'cog': entry.cog,
      'windSpeed': entry.windSpeed,
      'windDirection': entry.windDirection,
      'waveHeight': entry.waveHeight,
      'fuelConsumed': entry.fuelConsumed,
      'engineHours': entry.engineHours,
      'airTemp': entry.airTemp,
      'waterTemp': entry.waterTemp,
      'airPressure': entry.airPressure,
      'skipperNote': entry.skipperNote,
      'weatherCondition': entry.weatherCondition,
      'fuelLevel': entry.fuelLevel,
      'waterLevel': entry.waterLevel,
    };

Future<List<Attachment>> _attachmentsFor(LogbookEntry entry) async {
  final path = entry.photoPath;
  if (path == null) return const [];
  final file = File(path);
  if (!await file.exists()) return const [];
  return [
    Attachment(
      localPath: path,
      field: 'photo',
      mimeType: 'image/jpeg',
      sizeBytes: await file.length(),
    ),
  ];
}
