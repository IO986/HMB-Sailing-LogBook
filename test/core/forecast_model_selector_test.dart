import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/forecast_model_selector.dart';

void main() {
  String modelAt(double lat, double lon) =>
      ForecastModelSelector.forPosition(lat, lon).id;

  test('Jadran berie taliansky model, nie stredoeurópsky', () {
    // Obe pokrytia sem siahajú; domáci je ten, ktorý počíta more.
    expect(modelAt(44.1, 15.2), 'italia_meteo_arpae_icon_2i');
    expect(modelAt(43.5, 16.3), 'italia_meteo_arpae_icon_2i');
  });

  test('národné modely podľa polohy', () {
    expect(modelAt(51.5, -0.1), 'ukmo_seamless', reason: 'Londýn');
    expect(modelAt(55.9, -4.3), 'ukmo_seamless', reason: 'Glasgow');
    expect(modelAt(59.3, 18.1), 'metno_seamless', reason: 'Štokholm');
    expect(modelAt(55.7, 12.6), 'dmi_harmonie_arome_europe', reason: 'Kodaň');
    expect(modelAt(52.4, 4.9), 'knmi_harmonie_arome_europe', reason: 'Amsterdam');
    expect(modelAt(43.3, 5.4), 'meteofrance_arome_france_hd', reason: 'Marseille');
    expect(modelAt(48.2, 17.1), 'icon_d2', reason: 'Bratislava');
  });

  test('mimo pokrytia regionálnych modelov ostáva globálny', () {
    expect(modelAt(37.5, 24.0), 'ecmwf_ifs025', reason: 'Egejské more');
    expect(modelAt(25.0, -71.0), 'ecmwf_ifs025', reason: 'Karibik');
    expect(modelAt(-33.9, 151.2), 'ecmwf_ifs025', reason: 'Sydney');
  });

  test('model sa vie pomenovať aj s prevádzkovateľom', () {
    final m = ForecastModelSelector.forPosition(44.1, 15.2);
    expect(m.attribution, 'ARPAE ICON-2I · ItaliaMeteo');
    expect(ForecastModelSelector.global.attribution, 'ECMWF IFS · ECMWF');
  });
}
