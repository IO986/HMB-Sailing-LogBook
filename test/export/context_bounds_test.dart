import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/export/presentation/widgets/day_map_view.dart';
import 'package:latlong2/latlong.dart';

/// Výrez mapy v PDF sa skladal presne cez krajné body trasy. Deň, keď loď
/// takmer nikam nešla, tak v dokumente vyšiel ako pár desiatok metrov —
/// z terénu prišiel záber, na ktorom vidno strechy domov a nie, kde loď bola.
void main() {
  const km = 1 / 110.574; // stupeň zemepisnej šírky na kilometer

  test('dlhá trasa dostane pätinu navyše na každú stranu', () {
    final bounds = contextBounds([
      const LatLng(43.00, 16.00),
      const LatLng(43.10, 16.00),
    ]);

    final span = bounds.north - bounds.south;
    expect(span, closeTo(0.10 * 1.2, 1e-6));
    // Trasa ostáva v strede.
    expect((bounds.north + bounds.south) / 2, closeTo(43.05, 1e-9));
  });

  test('deň na jednom mieste dostane okno aspoň kilometer', () {
    final bounds = contextBounds([const LatLng(48.7557, 16.8858)]);

    final latSpanKm = (bounds.north - bounds.south) / km;
    expect(latSpanKm, closeTo(1.0, 0.01));
    expect(bounds.north, greaterThan(48.7557));
    expect(bounds.south, lessThan(48.7557));
  });

  /// Stupeň zemepisnej dĺžky je pri 48° severnej šírky asi o tretinu kratší
  /// než pri rovníku. Bez prepočtu by okno vyšlo v kilometroch užšie.
  test('okno je kilometer aj na šírku, nie len na výšku', () {
    final bounds = contextBounds([const LatLng(48.7557, 16.8858)]);

    final lonSpanKm = (bounds.east - bounds.west) *
        111.320 *
        // cos(48.7557°)
        0.6594;
    expect(lonSpanKm, closeTo(1.0, 0.05));
  });

  test('krátka, ale nie nulová trasa sa neroztiahne pod minimum', () {
    // Pol kilometra severojužne — minimum vyhráva.
    final bounds = contextBounds([
      const LatLng(43.000, 16.000),
      LatLng(43.000 + 0.5 * km, 16.000),
    ]);
    expect((bounds.north - bounds.south) / km, closeTo(1.0, 0.01));
  });

  test('dlhá trasa minimum ignoruje', () {
    final bounds = contextBounds([
      const LatLng(43.000, 16.000),
      const LatLng(43.500, 16.400),
    ]);
    expect((bounds.north - bounds.south) / km, greaterThan(50));
  });
}
