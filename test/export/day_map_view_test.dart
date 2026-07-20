import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/export/presentation/widgets/day_map_view.dart';
import 'package:screenshot/screenshot.dart';

/// A 1x1 transparent PNG, served synchronously — no network at all. A real
/// `TileProvider` (even the disk-cached one) still falls back to fetching
/// over HTTP on a cache miss, and `testWidgets` has no network; the real
/// provider just hangs until the test times out (confirmed the hard way —
/// see docs/HANDOVER.md, bod 3).
const _blankPngBytes = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _FakeTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(Uint8List.fromList(_blankPngBytes));
}

/// Doesn't prove real map tiles end up in the PNG — that needs a real
/// device with cached tiles, and this test deliberately fakes the tile
/// provider to avoid the network entirely. What it does catch is off-tree
/// rendering breaking altogether (missing MediaQuery, missing
/// Directionality, an exception during build) — that's a real regression
/// this caught once already: `captureFromWidget` without `context:` throws
/// "No MediaQuery widget ancestor found" for `ScaffoldMessenger`.
void main() {
  TrackPoint point({required double lat, required double lon, String? sessionId}) =>
      TrackPoint(
        id: 0,
        sessionId: sessionId,
        timestamp: DateTime.utc(2026, 1, 1),
        latitude: lat,
        longitude: lon,
      );

  Future<Uint8List> captureDayMap(WidgetTester tester, List<TrackPoint> trackPoints) async {
    await tester.pumpWidget(const SizedBox());
    final context = tester.element(find.byType(SizedBox));
    // testWidgets runs on a fake clock — a raw `delay:` Future inside
    // captureFromWidget never elapses under it and just hangs forever
    // (confirmed the hard way: a 10-minute timeout, twice). runAsync() steps
    // outside the fake zone so real Timers/Futures actually complete.
    final bytes = await tester.runAsync(() => ScreenshotController().captureFromWidget(
          MaterialApp(
            home: DayMapView(
              trackPoints: trackPoints,
              tileProviderBuilder: (_) => _FakeTileProvider(),
            ),
          ),
          delay: const Duration(milliseconds: 100),
          context: context,
        ));
    return bytes!;
  }

  testWidgets('captureFromWidget over DayMapView returns a non-empty PNG', (tester) async {
    final trackPoints = [
      point(lat: 43.50, lon: 16.40, sessionId: 's1'),
      point(lat: 43.52, lon: 16.42, sessionId: 's1'),
      point(lat: 43.55, lon: 16.45, sessionId: 's1'),
    ];

    final bytes = await captureDayMap(tester, trackPoints);

    expect(bytes, isNotEmpty);
  });

  testWidgets('renders with no track points at all (fresh/empty day)', (tester) async {
    final bytes = await captureDayMap(tester, const []);

    expect(bytes, isNotEmpty);
  });
}
