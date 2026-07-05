import 'package:xml/xml.dart';

/// Chyba pri parsovaní GPX súboru so zrozumiteľnou slovenskou hláškou
/// pre používateľa.
class GpxParseException implements Exception {
  final String message;
  const GpxParseException(this.message);
  @override
  String toString() => message;
}

class GpxTrackPoint {
  final double lat;
  final double lon;
  final double? ele;
  final DateTime? time;
  const GpxTrackPoint({required this.lat, required this.lon, this.ele, this.time});
}

class GpxTrack {
  final String? name;
  final List<GpxTrackPoint> points;
  const GpxTrack({required this.name, required this.points});
}

/// Bod z `<wpt>` (isRoutePoint: false) alebo `<rtept>` (isRoutePoint: true).
class GpxWaypoint {
  final String? name;
  final double lat;
  final double lon;
  final DateTime? time;
  final bool isRoutePoint;
  const GpxWaypoint({
    required this.name,
    required this.lat,
    required this.lon,
    this.time,
    required this.isRoutePoint,
  });
}

class GpxParseResult {
  /// Názov z `<metadata><name>` – ak gpx obsahuje viac `<trk>` (viacdňová
  /// plavba naexportovaná napr. Garmin Explore), toto je názov celej cesty,
  /// nie jednotlivého dňa.
  final String? tripName;
  final List<GpxTrack> tracks;
  final List<GpxWaypoint> waypoints;
  const GpxParseResult({required this.tripName, required this.tracks, required this.waypoints});
}

/// Parsuje GPX 1.1 XML obsah (`<trk>/<trkseg>/<trkpt>`, `<rte>/<rtept>`,
/// `<wpt>`) na štruktúrované dáta. Čistý Dart, žiadne DB/Flutter závislosti.
class GpxImporter {
  static GpxParseResult parse(String xmlContent) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(xmlContent);
    } on XmlException {
      throw const GpxParseException('Súbor nie je platný GPX (chybný XML formát).');
    }

    final root = document.rootElement;
    if (root.name.local.toLowerCase() != 'gpx') {
      throw const GpxParseException('Súbor neobsahuje značku <gpx>.');
    }

    final metadata = root.findElements('metadata').firstOrNull;
    final tripName = metadata == null ? null : _text(metadata, 'name');

    final tracks = <GpxTrack>[];
    for (final trk in root.findAllElements('trk')) {
      final name = _text(trk, 'name');
      final points = <GpxTrackPoint>[];
      for (final trkseg in trk.findElements('trkseg')) {
        for (final trkpt in trkseg.findElements('trkpt')) {
          final point = _parsePoint(trkpt);
          if (point != null) points.add(point);
        }
      }
      tracks.add(GpxTrack(name: name, points: points));
    }

    final waypoints = <GpxWaypoint>[];
    for (final rte in root.findAllElements('rte')) {
      for (final rtept in rte.findElements('rtept')) {
        final wpt = _parseWaypoint(rtept, isRoutePoint: true);
        if (wpt != null) waypoints.add(wpt);
      }
    }
    for (final wpt in root.findAllElements('wpt')) {
      final parsed = _parseWaypoint(wpt, isRoutePoint: false);
      if (parsed != null) waypoints.add(parsed);
    }

    return GpxParseResult(tripName: tripName, tracks: tracks, waypoints: waypoints);
  }

  static GpxTrackPoint? _parsePoint(XmlElement el) {
    final lat = double.tryParse(el.getAttribute('lat') ?? '');
    final lon = double.tryParse(el.getAttribute('lon') ?? '');
    if (lat == null || lon == null) return null;
    return GpxTrackPoint(
      lat: lat,
      lon: lon,
      ele: double.tryParse(_text(el, 'ele') ?? ''),
      time: DateTime.tryParse(_text(el, 'time') ?? ''),
    );
  }

  static GpxWaypoint? _parseWaypoint(XmlElement el, {required bool isRoutePoint}) {
    final lat = double.tryParse(el.getAttribute('lat') ?? '');
    final lon = double.tryParse(el.getAttribute('lon') ?? '');
    if (lat == null || lon == null) return null;
    return GpxWaypoint(
      name: _text(el, 'name'),
      lat: lat,
      lon: lon,
      time: DateTime.tryParse(_text(el, 'time') ?? ''),
      isRoutePoint: isRoutePoint,
    );
  }

  static String? _text(XmlElement el, String childName) {
    final child = el.findElements(childName).firstOrNull;
    final text = child?.innerText.trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
