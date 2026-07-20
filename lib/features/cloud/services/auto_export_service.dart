import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/skipper_profile.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/skipper_profile_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../../../core/providers/sync_settings_provider.dart';
import '../../../core/utils/gpx_exporter.dart';
import '../../../main.dart';
import '../../../sync/sync_entity_types.dart';
import '../../export/services/export_service.dart';
import '../../export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Builds a day's PDF + GPX without any `BuildContext` and queues both for
/// cloud upload — the headless counterpart to `ExportService.exportDay`
/// (`docs/plan_cloud_export.md` §3). Reuses the exact same builders
/// (`PdfExportService.buildDayPdfBytes`, `GpxExporter.buildDayGpxBytes`) and
/// the same structured save location (`ExportService.saveBytesLocally`) as
/// the manual export, so an auto-uploaded day looks identical to one the
/// skipper exported by hand.
///
/// [mapScreenshot] is captured by the caller, not here — this class has no
/// `BuildContext` to capture from (see day_map_view.dart / §3: the capture
/// needs a `View`/`MediaQuery` ancestor). `handleStopTap`
/// (`tracking_control_dialogs.dart`) is where that context lives.
class AutoExportService {
  Future<void> exportAndEnqueueDay({
    required Ref ref,
    required int dayLogId,
    Uint8List? mapScreenshot,
  }) async {
    final db = ref.read(databaseProvider);
    final day = await db.getDayLogById(dayLogId);
    if (day == null) return;
    final charter = await db.getCharterById(day.charterId);
    if (charter == null) return;

    final entries = await db.getEntriesForDay(dayLogId);
    final sessions = await db.getSessionsForDay(dayLogId);
    final pointsBySession = <String, List<TrackPoint>>{};
    for (final s in sessions) {
      pointsBySession[s.sessionId] = await db.getTrackPointsForSession(s.sessionId);
    }
    final dayStart = DateTime(day.date.year, day.date.month, day.date.day);
    final duties = await db.getDutiesOverlapping(
      charter.id,
      dayStart.toUtc(),
      dayStart.add(const Duration(days: 1)).toUtc(),
    );

    final l10n = await AppLocalizations.delegate.load(ref.read(localeProvider));
    final skipperProfile = await ref
        .read(skipperProfileProvider.future)
        .catchError((_) => const SkipperProfile());

    final pdfBytes = await PdfExportService.buildDayPdfBytes(
      charter: charter,
      day: day,
      entries: entries,
      l10n: l10n,
      duties: duties,
      mapScreenshot: mapScreenshot,
      skipperProfile: skipperProfile,
    );
    final gpxBytes = await GpxExporter.buildDayGpxBytes(day, sessions, pointsBySession);

    // Same structured, persistent folder as a manual export — not temp, so
    // the files survive until the next app launch even if upload is
    // delayed (offline, sync disabled, etc.).
    final exportSvc = ExportService();
    final pdfFile = await exportSvc.saveBytesLocally(
      pdfBytes,
      'day_$dayLogId',
      'pdf',
      charterTitle: charter.title,
      dayDate: day.date,
    );
    final gpxFile = await exportSvc.saveBytesLocally(
      gpxBytes,
      'day_$dayLogId',
      'gpx',
      charterTitle: charter.title,
      dayDate: day.date,
    );

    // Gate at the write site, same lesson as bod 1/2 (docs/HANDOVER.md,
    // sync fixy 20. 7.): an outbox row must never be created while the
    // feature is off, or it queues forever with nothing to send it.
    // Awaits the provider's own future rather than `.valueOrNull` — this
    // can run before syncSettingsProvider has ever resolved elsewhere in
    // the app, and `.valueOrNull` would silently read as "disabled" during
    // that race, dropping a real cloud-export-enabled day on the floor.
    final cloudEnabled = (await ref.read(syncSettingsProvider.future)).cloudEnabled;
    if (!cloudEnabled) return;

    final engine = ref.read(syncEngineProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(day.date);
    final folder = ['HMB_Sailing_Log_DATA', charter.title, 'Day_$dateStr'];

    await engine.enqueue(
      entityType: SyncEntityType.cloudExport,
      entityId: 'day-$dayLogId-pdf',
      payload: {'kind': 'day_pdf', 'dayLogId': dayLogId, 'folder': folder},
      attachments: [
        Attachment(
          localPath: pdfFile.path,
          field: 'file',
          mimeType: 'application/pdf',
          sizeBytes: await pdfFile.length(),
        ),
      ],
    );
    await engine.enqueue(
      entityType: SyncEntityType.cloudExport,
      entityId: 'day-$dayLogId-gpx',
      payload: {'kind': 'day_gpx', 'dayLogId': dayLogId, 'folder': folder},
      attachments: [
        Attachment(
          localPath: gpxFile.path,
          field: 'file',
          mimeType: 'application/gpx+xml',
          sizeBytes: await gpxFile.length(),
        ),
      ],
    );
  }
}
