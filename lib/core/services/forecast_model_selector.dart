/// Predpovedný model aj s tým, kto ho počíta.
class ForecastModel {
  const ForecastModel(this.id, this.label, this.provider);

  /// Identifikátor pre parameter `models=` v Open-Meteo.
  final String id;

  /// Krátky názov do UI ("ARPAE ICON-2I").
  final String label;

  /// Kto model prevádzkuje ("ItaliaMeteo").
  final String provider;

  /// Meno zdroja tak, ako sa píše v appke.
  String get attribution => '$label · $provider';

  @override
  bool operator ==(Object other) => other is ForecastModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Vyberie národný model podľa toho, kde loď je.
///
/// Prečo nie automatický výber Open-Meteo: `best_match` síce sám siahne po
/// najjemnejšom dostupnom modeli, ale **nepovie, po ktorom**. Pre denník, ktorý
/// má byť dokladovateľný, je „nejaký model" slabé tvrdenie — kto číta záznam o
/// mesiac neskôr, má vedieť, čia predpoveď to bola.
///
/// Hranice sú hrubé obdĺžniky, nie skutočné hranice krajín, a to stačí:
/// keď model pre dané miesto dáta nemá, Open-Meteo to povie a volajúci padne
/// na globálny ECMWF. Overené na Egejskom mori, kde taliansky ICON-2I vráti
/// odpoveď so `latitude: nan` a bez hodnôt.
abstract final class ForecastModelSelector {
  /// Globálny záskok. Európsky model s celosvetovým pokrytím — keď nič
  /// bližšie neplatí, stále je to lepšie než mlčať.
  static const global =
      ForecastModel('ecmwf_ifs025', 'ECMWF IFS', 'ECMWF');

  /// Poradie je poradím jemnosti: prvý, ktorého obdĺžnik obsahuje polohu,
  /// vyhráva. Preto tu Jadran stojí pred strednou Európou — obe ho pokrývajú,
  /// ale taliansky model je preň ten domáci.
  static const _regional = <(ForecastModel, double, double, double, double)>[
    // (model, juh, západ, sever, východ)
    (
      ForecastModel('ukmo_seamless', 'UKMO UKV', 'Met Office'),
      48.0,
      -12.0,
      62.0,
      3.0
    ),
    (
      ForecastModel(
          'dmi_harmonie_arome_europe', 'HARMONIE AROME', 'DMI'),
      54.0,
      7.0,
      58.0,
      13.0
    ),
    (
      ForecastModel('metno_seamless', 'MET Nordic', 'MET Norway'),
      54.0,
      3.0,
      72.0,
      33.0
    ),
    (
      ForecastModel(
          'knmi_harmonie_arome_europe', 'HARMONIE AROME', 'KNMI'),
      49.5,
      2.0,
      54.5,
      8.0
    ),
    (
      ForecastModel(
          'meteofrance_arome_france_hd', 'AROME HD', 'Météo-France'),
      41.0,
      -6.0,
      52.0,
      10.0
    ),
    (
      ForecastModel(
          'italia_meteo_arpae_icon_2i', 'ARPAE ICON-2I', 'ItaliaMeteo'),
      36.0,
      6.0,
      47.0,
      20.0
    ),
    (
      ForecastModel('icon_d2', 'ICON-D2', 'DWD'),
      43.2,
      -4.0,
      58.0,
      20.0
    ),
  ];

  /// Model pre danú polohu. Nikdy nevráti `null` — v najhoršom globálny.
  static ForecastModel forPosition(double lat, double lon) {
    for (final (model, south, west, north, east) in _regional) {
      if (lat >= south && lat <= north && lon >= west && lon <= east) {
        return model;
      }
    }
    return global;
  }
}
