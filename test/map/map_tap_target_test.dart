import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/map/presentation/screens/map_screen.dart';

/// Nahlásené z lode: „mám spustenú kotvu, plochu nakreslenú, a potrebujem
/// niečo odmerať — pravítko sa zapne, ale body pridáva do kotevného polygónu
/// a rozbije mi stráženú plochu."
void main() {
  MapTapTool target({
    bool ruler = false,
    bool zone = false,
    MapTapTool focus = MapTapTool.none,
  }) =>
      mapTapTarget(rulerActive: ruler, zoneActive: zone, focus: focus);

  test('bez zapnutého nástroja ťuknutie nepatrí ani jednému', () {
    expect(target(), MapTapTool.none);
  });

  test('jediný zapnutý nástroj berie ťuknutia aj bez zaostrenia', () {
    expect(target(ruler: true), MapTapTool.ruler);
    expect(target(zone: true), MapTapTool.zone);
  });

  test('oba zapnuté: rozhoduje ten, ktorý bol zvolený naposledy', () {
    expect(target(ruler: true, zone: true, focus: MapTapTool.ruler),
        MapTapTool.ruler);
    expect(target(ruler: true, zone: true, focus: MapTapTool.zone),
        MapTapTool.zone);
  });

  /// Presne ten prípad z lode: meranie zapnuté nad nakreslenou plochou.
  test('zapnuté meranie nad rozkreslenou plochou nepridáva body do plochy', () {
    expect(target(ruler: true, zone: true, focus: MapTapTool.ruler),
        isNot(MapTapTool.zone));
  });

  test('vypnutie zaostreného nástroja odovzdá ťuknutia tomu druhému', () {
    // Skiper vypol plochu, focus na ňu ostal — ťuknutie musí ísť pravítku.
    expect(target(ruler: true, focus: MapTapTool.zone), MapTapTool.ruler);
    expect(target(zone: true, focus: MapTapTool.ruler), MapTapTool.zone);
  });
}
