import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/gpx_exporter.dart';
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
  }) async {
    final db = _db;
    if (db == null) return;

    _showProgress(context, 'Generujem export...');

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

      // PDF
      final pdf = await PdfExportService.exportCharter(
        charter: charter,
        days: days,
        entriesByDay: entriesByDay,
        mapScreenshots: mapScreenshots ?? {},
      );

      // GPX
      final gpx = await GpxExporter.exportCharter(
          charter, days, sessionsByDay, pointsBySession);

      if (context.mounted) Navigator.of(context).pop();

      await Share.shareXFiles(
        [XFile(pdf.path), XFile(gpx.path)],
        subject: 'HMB Sailing Log – ${charter.title}',
        text: '${charter.title}\nExportované z HMB Sailing Log',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba exportu: $e'),
              backgroundColor: Colors.red));
      }
    }
  }

  /// Export jedného dňa – PDF + GPX
  Future<void> exportDay(
    BuildContext context,
    Charter charter,
    DayLog day, {
    Uint8List? mapScreenshot,
  }) async {
    final db = _db;
    if (db == null) return;

    _showProgress(context, 'Generujem export dňa...');

    try {
      final entries = await db.getEntriesForDay(day.id);
      final sessions = await db.getSessionsForDay(day.id);
      final pointsBySession = <String, List<TrackPoint>>{};
      for (final s in sessions) {
        pointsBySession[s.sessionId] =
            await db.getTrackPointsForSession(s.sessionId);
      }

      // PDF
      final pdf = await PdfExportService.exportDay(
        charter: charter,
        day: day,
        entries: entries,
        mapScreenshot: mapScreenshot,
      );

      // GPX – všetky sessions dňa
      final files = <XFile>[XFile(pdf.path)];
      for (final s in sessions) {
        final pts = pointsBySession[s.sessionId] ?? [];
        if (pts.isNotEmpty) {
          final gpx = await GpxExporter.exportSession(s, pts);
          files.add(XFile(gpx.path));
        }
      }

      if (context.mounted) Navigator.of(context).pop();

      final dateStr =
          '${day.date.day}.${day.date.month}.${day.date.year}';
      await Share.shareXFiles(
        files,
        subject: 'HMB Sailing Log – $dateStr: ${day.portFrom ?? ""} → ${day.portTo ?? ""}',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba exportu: $e'),
              backgroundColor: Colors.red));
      }
    }
  }

  void _showProgress(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(child: Text(message)),
        ]),
      ),
    );
  }
}
