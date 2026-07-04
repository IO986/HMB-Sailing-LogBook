import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/gpx_import/services/gpx_importer.dart';

const _validGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Test" xmlns="http://www.topografix.com/GPX/1/1">
  <wpt lat="43.5081" lon="16.4402">
    <name>Marina Split</name>
    <time>2026-06-01T08:00:00Z</time>
  </wpt>
  <rte>
    <name>Trasa A</name>
    <rtept lat="43.1" lon="16.2"><name>Bod 1</name></rtept>
    <rtept lat="43.2" lon="16.3"><name>Bod 2</name></rtept>
  </rte>
  <trk>
    <name>Denny track</name>
    <trkseg>
      <trkpt lat="43.50" lon="16.44">
        <ele>1.5</ele>
        <time>2026-06-01T09:00:00Z</time>
      </trkpt>
      <trkpt lat="43.51" lon="16.45">
        <ele>2.0</ele>
        <time>2026-06-01T09:05:00Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
''';

void main() {
  group('valid GPX', () {
    late GpxParseResult result;
    setUp(() => result = GpxImporter.parse(_validGpx));

    test('parses one track with name and points including ele/time', () {
      expect(result.tracks, hasLength(1));
      final track = result.tracks.single;
      expect(track.name, 'Denny track');
      expect(track.points, hasLength(2));
      expect(track.points[0].lat, 43.50);
      expect(track.points[0].lon, 16.44);
      expect(track.points[0].ele, 1.5);
      expect(track.points[0].time, DateTime.parse('2026-06-01T09:00:00Z'));
    });

    test('parses route points as waypoints marked isRoutePoint=true', () {
      final routePoints = result.waypoints.where((w) => w.isRoutePoint).toList();
      expect(routePoints, hasLength(2));
      expect(routePoints[0].name, 'Bod 1');
      expect(routePoints[1].name, 'Bod 2');
    });

    test('parses standalone waypoints marked isRoutePoint=false, with name and time', () {
      final plain = result.waypoints.where((w) => !w.isRoutePoint).toList();
      expect(plain, hasLength(1));
      expect(plain.single.name, 'Marina Split');
      expect(plain.single.lat, 43.5081);
      expect(plain.single.lon, 16.4402);
      expect(plain.single.time, DateTime.parse('2026-06-01T08:00:00Z'));
    });
  });

  group('corrupted / invalid GPX', () {
    test('malformed XML throws GpxParseException with a Slovak message', () {
      expect(
        () => GpxImporter.parse('<gpx><trk><name>Unclosed'),
        throwsA(isA<GpxParseException>().having(
            (e) => e.message, 'message', contains('platný GPX'))),
      );
    });

    test('valid XML but missing <gpx> root throws GpxParseException', () {
      expect(
        () => GpxImporter.parse('<root><foo>bar</foo></root>'),
        throwsA(isA<GpxParseException>().having(
            (e) => e.message, 'message', contains('<gpx>'))),
      );
    });

    test('empty but valid GPX yields empty lists, not an error', () {
      final result = GpxImporter.parse(
          '<gpx version="1.1" xmlns="http://www.topografix.com/GPX/1/1"></gpx>');
      expect(result.tracks, isEmpty);
      expect(result.waypoints, isEmpty);
    });

    test('track point with missing lat/lon attribute is skipped, not crashed on', () {
      const gpx = '''
        <gpx xmlns="http://www.topografix.com/GPX/1/1">
          <trk><trkseg>
            <trkpt lat="43.5" lon="16.4"></trkpt>
            <trkpt lon="16.5"></trkpt>
          </trkseg></trk>
        </gpx>
      ''';
      final result = GpxImporter.parse(gpx);
      expect(result.tracks.single.points, hasLength(1));
    });
  });
}
