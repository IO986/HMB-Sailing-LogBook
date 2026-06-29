import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';

class GpxExporter {
  /// Export GPS trasy jednej session
  static Future<File> exportSession(
      SailingSession session, List<TrackPoint> points) async {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln('<gpx version="1.1" creator="HMB Sailing Log" '
        'xmlns="http://www.topografix.com/GPX/1/1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
        'http://www.topografix.com/GPX/1/1/gpx.xsd">');
    sb.writeln('  <metadata>');
    sb.writeln('    <name>${_esc(session.name ?? session.sessionId)}</name>');
    sb.writeln('    <time>${session.startTime.toUtc().toIso8601String()}</time>');
    sb.writeln('  </metadata>');
    sb.writeln('  <trk>');
    sb.writeln('    <name>${_esc(session.name ?? "Track")}</name>');
    sb.writeln('    <trkseg>');
    for (final p in points) {
      sb.write('      <trkpt lat="${p.latitude}" lon="${p.longitude}">');
      if (p.altitude != null)
        sb.write('<ele>${p.altitude!.toStringAsFixed(1)}</ele>');
      sb.write('<time>${p.timestamp.toUtc().toIso8601String()}</time>');
      if (p.speed != null)
        sb.write('<extensions><speed>${(p.speed! * 0.514444).toStringAsFixed(2)}'
            '</speed></extensions>');
      sb.writeln('</trkpt>');
    }
    sb.writeln('    </trkseg>');
    sb.writeln('  </trk>');
    sb.writeln('</gpx>');

    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/track_${session.sessionId.substring(0, 8)}'
        '_${DateTime.now().millisecondsSinceEpoch}.gpx');
    await f.writeAsString(sb.toString());
    return f;
  }

  /// Export celého chartera ako GPX s viacerými trackami (1 per deň)
  static Future<File> exportCharter(
    Charter charter,
    List<DayLog> days,
    Map<int, List<SailingSession>> sessionsByDay,
    Map<String, List<TrackPoint>> pointsBySession,
  ) async {
    final sb = StringBuffer();
    final fmt = DateFormat('d.M.yyyy', 'sk');
    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln('<gpx version="1.1" creator="HMB Sailing Log" '
        'xmlns="http://www.topografix.com/GPX/1/1">');
    sb.writeln('  <metadata>');
    sb.writeln('    <name>${_esc(charter.title)}</name>');
    sb.writeln('    <desc>${_esc(charter.vesselName ?? "")} '
        '${fmt.format(charter.dateFrom)}–${fmt.format(charter.dateTo)}</desc>');
    sb.writeln('    <time>${charter.dateFrom.toUtc().toIso8601String()}</time>');
    sb.writeln('  </metadata>');

    for (final day in days) {
      final sessions = sessionsByDay[day.id] ?? [];
      final dayName = DateFormat('EEEE d.M.', 'sk').format(day.date);
      final route = '${day.portFrom ?? "?"} → ${day.portTo ?? "?"}';

      for (final session in sessions) {
        final points = pointsBySession[session.sessionId] ?? [];
        if (points.isEmpty) continue;

        sb.writeln('  <trk>');
        sb.writeln('    <name>${_esc("$dayName: $route")}</name>');
        sb.writeln('    <trkseg>');
        for (final p in points) {
          sb.write('      <trkpt lat="${p.latitude}" lon="${p.longitude}">');
          if (p.altitude != null)
            sb.write('<ele>${p.altitude!.toStringAsFixed(1)}</ele>');
          sb.write('<time>${p.timestamp.toUtc().toIso8601String()}</time>');
          if (p.speed != null)
            sb.write('<extensions><speed>${(p.speed! * 0.514444).toStringAsFixed(2)}'
                '</speed></extensions>');
          sb.writeln('</trkpt>');
        }
        sb.writeln('    </trkseg>');
        sb.writeln('  </trk>');
      }
    }

    sb.writeln('</gpx>');

    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/charter_${charter.id}'
        '_${DateTime.now().millisecondsSinceEpoch}.gpx');
    await f.writeAsString(sb.toString());
    return f;
  }

  /// GPX obsah dňa (všetky sessions) ako bajty – bez ukladania na disk.
  static Future<Uint8List> buildDayGpxBytes(
    DayLog day,
    List<SailingSession> sessions,
    Map<String, List<TrackPoint>> pointsBySession,
  ) async {
    final sb = StringBuffer();
    final fmt = DateFormat('d.M.yyyy', 'sk');
    final dayName = fmt.format(day.date);
    final route = '${day.portFrom ?? "?"} → ${day.portTo ?? "?"}';

    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln('<gpx version="1.1" creator="HMB Sailing Log" '
        'xmlns="http://www.topografix.com/GPX/1/1">');
    sb.writeln('  <metadata>');
    sb.writeln('    <name>${_esc("$dayName: $route")}</name>');
    sb.writeln('    <time>${day.date.toUtc().toIso8601String()}</time>');
    sb.writeln('  </metadata>');

    for (final s in sessions) {
      final pts = pointsBySession[s.sessionId] ?? [];
      if (pts.isEmpty) continue;
      sb.writeln('  <trk>');
      sb.writeln('    <name>${_esc(s.name ?? "Track")}</name>');
      sb.writeln('    <trkseg>');
      for (final p in pts) {
        sb.write('      <trkpt lat="${p.latitude}" lon="${p.longitude}">');
        if (p.altitude != null)
          sb.write('<ele>${p.altitude!.toStringAsFixed(1)}</ele>');
        sb.write('<time>${p.timestamp.toUtc().toIso8601String()}</time>');
        if (p.speed != null)
          sb.write('<extensions><speed>${(p.speed! * 0.514444).toStringAsFixed(2)}</speed></extensions>');
        sb.writeln('</trkpt>');
      }
      sb.writeln('    </trkseg>');
      sb.writeln('  </trk>');
    }
    sb.writeln('</gpx>');
    return Uint8List.fromList(utf8.encode(sb.toString()));
  }

  /// GPX obsah celého chartera ako bajty – bez ukladania na disk.
  static Future<Uint8List> buildCharterGpxBytes(
    Charter charter,
    List<DayLog> days,
    Map<int, List<SailingSession>> sessionsByDay,
    Map<String, List<TrackPoint>> pointsBySession,
  ) async {
    final sb = StringBuffer();
    final fmt = DateFormat('d.M.yyyy', 'sk');
    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln('<gpx version="1.1" creator="HMB Sailing Log" '
        'xmlns="http://www.topografix.com/GPX/1/1">');
    sb.writeln('  <metadata>');
    sb.writeln('    <name>${_esc(charter.title)}</name>');
    sb.writeln('    <desc>${_esc(charter.vesselName ?? "")} '
        '${fmt.format(charter.dateFrom)}–${fmt.format(charter.dateTo)}</desc>');
    sb.writeln('    <time>${charter.dateFrom.toUtc().toIso8601String()}</time>');
    sb.writeln('  </metadata>');

    for (final day in days) {
      final sessions = sessionsByDay[day.id] ?? [];
      final dayName = DateFormat('EEEE d.M.', 'sk').format(day.date);
      final route = '${day.portFrom ?? "?"} → ${day.portTo ?? "?"}';
      for (final s in sessions) {
        final pts = pointsBySession[s.sessionId] ?? [];
        if (pts.isEmpty) continue;
        sb.writeln('  <trk>');
        sb.writeln('    <name>${_esc("$dayName: $route")}</name>');
        sb.writeln('    <trkseg>');
        for (final p in pts) {
          sb.write('      <trkpt lat="${p.latitude}" lon="${p.longitude}">');
          if (p.altitude != null)
            sb.write('<ele>${p.altitude!.toStringAsFixed(1)}</ele>');
          sb.write('<time>${p.timestamp.toUtc().toIso8601String()}</time>');
          if (p.speed != null)
            sb.write('<extensions><speed>${(p.speed! * 0.514444).toStringAsFixed(2)}</speed></extensions>');
          sb.writeln('</trkpt>');
        }
        sb.writeln('    </trkseg>');
        sb.writeln('  </trk>');
      }
    }
    sb.writeln('</gpx>');
    return Uint8List.fromList(utf8.encode(sb.toString()));
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;').replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;').replaceAll('"', '&quot;');
}
