import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/gpx_exporter.dart';
import '../../../l10n/app_localizations.dart';
import '../../charter/services/handover_checklist.dart';
import 'pdf_export_service.dart';

class ExportService {
  static final ExportService _i = ExportService._();
  factory ExportService() => _i;
  ExportService._();

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  /// Export celého chartera – PDF + GPX
  Future<void> exportCharter(
    BuildContext context,
    Charter charter, {
    Map<int, Uint8List?>? mapScreenshots,
    Uint8List? signatureImage,
  }) async {
    final db = _db;
    if (db == null) return;
    // Captured before the first await - context must not be used across one.
    final l10n = AppLocalizations.of(context);

    BuildContext? dialogCtx;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogCtx = ctx;
          return AlertDialog(
            content: Row(children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(AppLocalizations.of(ctx).generatingPdf)),
            ]),
          );
        },
      );
    }

    try {
      final days = await db.getDayLogs(charter.id);
      final entriesByDay = <int, List<LogbookEntry>>{};
      final sessionsByDay = <int, List<SailingSession>>{};
      final pointsBySession = <String, List<TrackPoint>>{};

      for (final day in days) {
        entriesByDay[day.id] = await db.getEntriesForDay(day.id);
        sessionsByDay[day.id] = await db.getSessionsForDay(day.id);
        for (final s in sessionsByDay[day.id]!) {
          pointsBySession[s.sessionId] =
              await db.getTrackPointsForSession(s.sessionId);
        }
      }

      final checkInProtocol = await db.getHandoverProtocol(charter.id, 'checkIn');
      final checkOutProtocol = await db.getHandoverProtocol(charter.id, 'checkOut');

      final dutiesByDay = <int, List<DutyPeriod>>{};
      for (final day in days) {
        final start = DateTime(day.date.year, day.date.month, day.date.day);
        dutiesByDay[day.id] = await db.getDutiesOverlapping(
            charter.id, start.toUtc(), start.add(const Duration(days: 1)).toUtc());
      }

      final pdf = await PdfExportService.exportCharter(
        charter: charter,
        days: days,
        entriesByDay: entriesByDay,
        mapScreenshots: mapScreenshots ?? {},
        l10n: l10n,
        dutiesByDay: dutiesByDay,
        signatureImage: signatureImage,
        checkInProtocol: checkInProtocol,
        checkInChecklist:
            checkInProtocol != null ? checklistFromJson(checkInProtocol.checklistJson) : null,
        checkOutProtocol: checkOutProtocol,
        checkOutChecklist:
            checkOutProtocol != null ? checklistFromJson(checkOutProtocol.checklistJson) : null,
      );

      final gpx = await GpxExporter.exportCharter(
          charter, days, sessionsByDay, pointsBySession);

      final savedPdf = await _saveLocally(pdf, charter.title, charterTitle: charter.title);
      final savedGpx = await _saveLocally(gpx, charter.title, charterTitle: charter.title);

      _closeDialog(dialogCtx);
      await Share.shareXFiles(
        [XFile(savedPdf.path), XFile(savedGpx.path)],
        subject: 'HMB Sailing Log – ${charter.title}',
      );
    } catch (e) {
      _closeDialog(dialogCtx);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).exportErrorMsg(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  /// Export jedného dňa – PDF + GPX
  Future<void> exportDay(
    BuildContext context,
    Charter charter,
    DayLog day, {
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
  }) async {
    final db = _db;
    if (db == null) return;
    // Captured before the first await - context must not be used across one.
    final l10n = AppLocalizations.of(context);

    BuildContext? dialogCtx;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogCtx = ctx;
          return AlertDialog(
            content: Row(children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(AppLocalizations.of(ctx).generatingPdf)),
            ]),
          );
        },
      );
    }

    try {
      final entries = await db.getEntriesForDay(day.id);
      final sessions = await db.getSessionsForDay(day.id);
      final pointsBySession = <String, List<TrackPoint>>{};
      for (final s in sessions) {
        pointsBySession[s.sessionId] =
            await db.getTrackPointsForSession(s.sessionId);
      }

      final dayStart = DateTime(day.date.year, day.date.month, day.date.day);
      final duties = await db.getDutiesOverlapping(charter.id, dayStart.toUtc(),
          dayStart.add(const Duration(days: 1)).toUtc());

      final pdf = await PdfExportService.exportDay(
        charter: charter,
        day: day,
        entries: entries,
        l10n: l10n,
        duties: duties,
        mapScreenshot: mapScreenshot,
        signatureImage: signatureImage,
      );

      final dateStr = '${day.date.day}.${day.date.month}.${day.date.year}';
      final savedPdf = await _saveLocally(pdf, '${charter.title} $dateStr',
          charterTitle: charter.title, dayDate: day.date);

      final shareFiles = <XFile>[XFile(savedPdf.path)];
      for (final s in sessions) {
        final pts = pointsBySession[s.sessionId] ?? [];
        if (pts.isNotEmpty) {
          final gpx = await GpxExporter.exportSession(s, pts);
          final savedGpx = await _saveLocally(gpx, '${charter.title} $dateStr',
              charterTitle: charter.title, dayDate: day.date);
          shareFiles.add(XFile(savedGpx.path));
        }
      }

      _closeDialog(dialogCtx);
      await Share.shareXFiles(
        shareFiles,
        subject: 'HMB Sailing Log – $dateStr: ${day.portFrom ?? ""} → ${day.portTo ?? ""}',
      );
    } catch (e) {
      _closeDialog(dialogCtx);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).exportErrorMsg(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  /// Uloží predgenerované PDF bajty + GPX pre deň a zobrazí snackbar.
  Future<void> exportDayFromBytes(
    BuildContext context,
    Charter charter,
    DayLog day,
    Uint8List pdfBytes, {
    Uint8List? signatureImage,
  }) async {
    final db = _db;
    if (db == null) return;
    // Captured before the first await - context must not be used across one.
    final l10n = AppLocalizations.of(context);

    BuildContext? dialogCtx;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogCtx = ctx;
          return AlertDialog(
            content: Row(children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(AppLocalizations.of(ctx).savingAndGeneratingGpx)),
            ]),
          );
        },
      );
    }

    try {
      final dateStr = '${day.date.day}.${day.date.month}.${day.date.year}';
      final docName = '${charter.title} $dateStr';

      final pdfFile = await saveBytesLocally(pdfBytes, docName, 'pdf',
          charterTitle: charter.title, dayDate: day.date);
      final shareFiles = <XFile>[XFile(pdfFile.path)];

      final sessions = await db.getSessionsForDay(day.id);
      for (final s in sessions) {
        final pts = await db.getTrackPointsForSession(s.sessionId);
        if (pts.isNotEmpty) {
          final gpx = await GpxExporter.exportSession(s, pts);
          final gpxFile = await _saveLocally(gpx, docName,
              charterTitle: charter.title, dayDate: day.date);
          shareFiles.add(XFile(gpxFile.path));
        }
      }

      _closeDialog(dialogCtx);
      await Share.shareXFiles(
        shareFiles,
        subject: 'HMB Sailing Log – $dateStr: ${day.portFrom ?? ""} → ${day.portTo ?? ""}',
      );
    } catch (e) {
      _closeDialog(dialogCtx);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.exportErrorMsg(e.toString())),
          backgroundColor: Colors.red));
      }
    }
  }

  /// Uloží predgenerované PDF bajty + GPX pre charter a zobrazí snackbar.
  Future<void> exportCharterFromBytes(
    BuildContext context,
    Charter charter,
    Uint8List pdfBytes, {
    List<DayLog> days = const [],
    Uint8List? signatureImage,
  }) async {
    final db = _db;
    if (db == null) return;
    // Captured before the first await - context must not be used across one.
    final l10n = AppLocalizations.of(context);

    BuildContext? dialogCtx;
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogCtx = ctx;
          return AlertDialog(
            content: Row(children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(AppLocalizations.of(ctx).savingAndGeneratingGpx)),
            ]),
          );
        },
      );
    }

    try {
      final pdfFile = await saveBytesLocally(pdfBytes, charter.title, 'pdf',
          charterTitle: charter.title);
      final shareFiles = <XFile>[XFile(pdfFile.path)];

      final allDays = days.isNotEmpty ? days : await db.getDayLogs(charter.id);
      final sessionsByDay = <int, List<SailingSession>>{};
      final pointsBySession = <String, List<TrackPoint>>{};
      for (final day in allDays) {
        sessionsByDay[day.id] = await db.getSessionsForDay(day.id);
        for (final s in sessionsByDay[day.id]!) {
          pointsBySession[s.sessionId] = await db.getTrackPointsForSession(s.sessionId);
        }
      }
      final gpx = await GpxExporter.exportCharter(charter, allDays, sessionsByDay, pointsBySession);
      final gpxFile = await _saveLocally(gpx, charter.title, charterTitle: charter.title);
      shareFiles.add(XFile(gpxFile.path));

      _closeDialog(dialogCtx);
      await Share.shareXFiles(
        shareFiles,
        subject: 'HMB Sailing Log – ${charter.title}',
      );
    } catch (e) {
      _closeDialog(dialogCtx);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.exportErrorMsg(e.toString())),
          backgroundColor: Colors.red));
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  void _closeDialog(BuildContext? ctx) {
    if (ctx != null && ctx.mounted) Navigator.of(ctx).pop();
  }

  /// Builds the structured export directory:
  /// HMB_LOGBOOK/Sail_Logs/{voyage_slug}/[Day_{N}_{date}/]
  Future<Directory> _buildExportDir(String charterTitle, [DateTime? dayDate]) async {
    Directory? base;
    if (Platform.isAndroid) {
      try { base = await getExternalStorageDirectory(); } catch (_) {}
    }
    base ??= await getApplicationDocumentsDirectory();

    final voyageSlug = charterTitle
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    String subPath = 'HMB_LOGBOOK/Sail_Logs/$voyageSlug';
    if (dayDate != null) {
      final d = '${dayDate.year}-${dayDate.month.toString().padLeft(2,'0')}-${dayDate.day.toString().padLeft(2,'0')}';
      subPath += '/Day_$d';
    }

    final dir = Directory('${base.path}/$subPath');
    await dir.create(recursive: true);
    return dir;
  }

  /// Uloží bajty priamo do štruktúrovaného priečinka
  /// (`HMB_LOGBOOK/Sail_Logs/{plavba}/Day_{dátum}`, pretrváva reštart appky).
  /// Public — znovupoužíva ho aj `AutoExportService`
  /// (`lib/features/cloud/services/auto_export_service.dart`), aby headless
  /// export ukladal do rovnakej štruktúry ako ručný export.
  Future<File> saveBytesLocally(Uint8List bytes, String docName, String ext,
      {String? charterTitle, DateTime? dayDate}) async {
    final dir = await _buildExportDir(charterTitle ?? docName, dayDate);
    final safe = docName
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final dest = File('${dir.path}/$safe.$ext');
    await dest.writeAsBytes(bytes);
    return dest;
  }

  /// Uloží súbor do štruktúrovaného priečinka.
  Future<File> _saveLocally(File src, String docName,
      {String? charterTitle, DateTime? dayDate}) async {
    final dir = await _buildExportDir(charterTitle ?? docName, dayDate);
    final ext = src.path.split('.').last;
    final safe = docName
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final dest = File('${dir.path}/$safe.$ext');
    return src.copy(dest.path);
  }
}
