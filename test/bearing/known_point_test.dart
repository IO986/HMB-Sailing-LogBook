import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/bearing/providers/bearing_provider.dart';

/// Stĺpec "Poloha" v PDF aj priamka na mape musia ukazovať ZNÁMY bod, nie
/// pozorovateľa. Pri resekcii je to zameraný waypoint — aj keby v okamihu
/// zamerania náhodou bežalo GPS a `observerLat` bolo tiež vyplnené, čo sa
/// deje zámerne (porovnanie fixu s GPS), nesmie to prepnúť, čo sa vypíše.
void main() {
  final noon = DateTime.utc(2026, 8, 20, 12);

  Bearing resection({double? observerLat, double? observerLon}) => Bearing(
        hiddenFromMap: false,
        id: 1,
        kind: BearingKind.resection.code,
        observerLat: observerLat,
        observerLon: observerLon,
        magneticBearing: 90,
        declination: 4.2,
        declinationSource: observerLat == null ? 'target' : 'gps',
        trueBearing: 94.2,
        uncertaintyDeg: 8,
        targetWaypointId: 5,
        targetLat: 43.06,
        targetLon: 16.25,
        targetName: 'Maják Stončica',
        takenAt: noon,
      );

  Bearing intersection() => Bearing(
        hiddenFromMap: false,
        id: 2,
        kind: BearingKind.intersection.code,
        observerLat: 43.5081,
        observerLon: 16.4402,
        magneticBearing: 200,
        declination: 4.2,
        declinationSource: 'gps',
        trueBearing: 204.2,
        uncertaintyDeg: 8,
        sightGroupId: 'g1',
        label: 'neznáma skala',
        takenAt: noon,
      );

  test('resekcia bez GPS ukáže polohu waypointu', () {
    final (lat, lon) = knownPointOf(resection());
    expect(lat, closeTo(43.06, 1e-9));
    expect(lon, closeTo(16.25, 1e-9));
  });

  test('resekcia s GPS stále ukáže polohu waypointu, nie lode', () {
    // Presne ten prípad, ktorý sa predtým pomýlil: GPS bolo k dispozícii,
    // takže observerLat/Lon sa zapísali (na porovnanie s fixom), ale
    // stĺpec "Poloha" v tabuľke aj tak patrí zameranému bodu.
    final (lat, lon) =
        knownPointOf(resection(observerLat: 43.51, observerLon: 16.40));
    expect(lat, closeTo(43.06, 1e-9));
    expect(lon, closeTo(16.25, 1e-9));
  });

  test('hľadanie objektu ukáže polohu pozorovateľa', () {
    final (lat, lon) = knownPointOf(intersection());
    expect(lat, closeTo(43.5081, 1e-9));
    expect(lon, closeTo(16.4402, 1e-9));
  });
}
