import 'package:xml/xml.dart';

/// Jedno meranie z pozemnej stanice DHMZ.
///
/// Zámerne oddelené od predpovede: toto je hodnota, ktorú niekto naozaj nameral,
/// a v lodnom denníku má inú váhu než výstup modelu.
class DhmzStationReading {
  const DhmzStationReading({
    required this.station,
    required this.latitude,
    required this.longitude,
    required this.observedAt,
    this.airTemp,
    this.airPressure,
    this.pressureTendency,
    this.windSpeedKnots,
    this.windDirectionDeg,
    this.waterTemp,
  });

  final String station;
  final double latitude;
  final double longitude;

  /// Čas merania (lokálny čas Chorvátska prepočítaný na UTC).
  final DateTime observedAt;

  final double? airTemp;
  final double? airPressure;

  /// Zmena tlaku za posledné 3 h (hPa). Model túto hodnotu nedáva vôbec a pre
  /// skipera je to klasická predzvesť zmeny počasia.
  final double? pressureTendency;

  final double? windSpeedKnots;

  /// Smer, odkiaľ vietor fúka. `null` znamená bezvetrie (`C` vo feede) alebo
  /// chýbajúci údaj — obe sú stav, v ktorom smer neexistuje.
  final double? windDirectionDeg;

  final double? waterTemp;

  /// Má zmysel niečo z tohto merania vôbec použiť?
  bool get hasAnyValue =>
      airTemp != null ||
      airPressure != null ||
      windSpeedKnots != null ||
      waterTemp != null;

  DhmzStationReading copyWithWaterTemp(double? value) => DhmzStationReading(
        station: station,
        latitude: latitude,
        longitude: longitude,
        observedAt: observedAt,
        airTemp: airTemp,
        airPressure: airPressure,
        pressureTendency: pressureTendency,
        windSpeedKnots: windSpeedKnots,
        windDirectionDeg: windDirectionDeg,
        waterTemp: value,
      );
}

/// Prevod feedov DHMZ (meteo.hr) na merania.
///
/// Vlastná trieda bez siete a bez databázy, aby sa dala testovať na uloženom
/// XML. Feed je cudzí a môže sa kedykoľvek zmeniť alebo prestať chodiť, takže
/// každý prevod je obranný: chýbajúca hodnota je `null`, nie výnimka a nie nula.
class DhmzObservationParser {
  /// Rýchlosť vetra je vo feede v m/s, nie v uzloch — overené na živých dátach
  /// (rozsah 0,0–10,8 pri priemere 2,1 naprieč 60 stanicami).
  static const _msToKnots = 1.94384;

  /// Chorvátsko je celoročne UTC+1 / UTC+2. Feed čas pásma neuvádza, takže sa
  /// odvodzuje z dátumu — bez toho by meranie vyzeralo o hodinu-dve staršie,
  /// než je, a kontrola čerstvosti by ho zbytočne zahodila.
  static Duration _croatiaOffset(DateTime localDate) {
    final year = localDate.year;
    final dstStart = _lastSundayOfMarch(year);
    final dstEnd = _lastSundayOfOctober(year);
    final isDst = !localDate.isBefore(dstStart) && localDate.isBefore(dstEnd);
    return Duration(hours: isDst ? 2 : 1);
  }

  static DateTime _lastSundayOfMarch(int year) {
    var d = DateTime(year, 3, 31);
    while (d.weekday != DateTime.sunday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  static DateTime _lastSundayOfOctober(int year) {
    var d = DateTime(year, 10, 31);
    while (d.weekday != DateTime.sunday) {
      d = d.subtract(const Duration(days: 1));
    }
    return d;
  }

  /// Písmenový smer vetra na stupne. `C` (calm) a neznáme hodnoty vracajú
  /// `null` — bezvetrie nemá smer a vymyslieť mu nejaký by bola lož v zázname.
  static double? windDirectionToDegrees(String? raw) {
    final v = raw?.trim().toUpperCase();
    if (v == null || v.isEmpty || v == '-' || v == 'C') return null;
    const table = {
      'N': 0.0, 'NNE': 22.5, 'NE': 45.0, 'ENE': 67.5,
      'E': 90.0, 'ESE': 112.5, 'SE': 135.0, 'SSE': 157.5,
      'S': 180.0, 'SSW': 202.5, 'SW': 225.0, 'WSW': 247.5,
      'W': 270.0, 'WNW': 292.5, 'NW': 315.0, 'NNW': 337.5,
    };
    return table[v];
  }

  /// Číslo z uzla feedu. `-`, prázdny reťazec aj nečíselný text sú `null`.
  static double? parseNumber(String? raw) {
    final v = raw?.trim();
    if (v == null || v.isEmpty || v == '-') return null;
    // Feed občas píše tendenciu s vedúcim plusom (`+0.5`), ktorý double.parse
    // v Darte zvládne, aj desatinnú čiarku, ktorý nezvládne.
    return double.tryParse(v.replaceAll(',', '.'));
  }

  /// `<Datum>23.08.2026</Datum>` + `<Termin>06</Termin>` na UTC.
  static DateTime? parseObservedAt(String? datum, String? termin) {
    final d = datum?.trim();
    if (d == null) return null;
    final parts = d.split('.').where((p) => p.trim().isNotEmpty).toList();
    if (parts.length < 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    final hour = int.tryParse(termin?.trim() ?? '') ?? 0;

    // Nástenný čas feedu sa najprv postaví AKO KEBY bol UTC a až potom sa
    // posunie o chorvátsky offset. `DateTime(...)` by ho vyrobil v pásme
    // telefónu a posun by sa započítal dvakrát — na zariadení v CEST vyšlo
    // 06:00 miestneho ako 02:00 UTC namiesto 04:00.
    final wallClock = DateTime.utc(year, month, day, hour);
    return wallClock.subtract(_croatiaOffset(wallClock));
  }

  /// Rozparsuje `hrvatska_n.xml` — pozemné stanice so súradnicami.
  ///
  /// Stanice bez použiteľnej hodnoty sa zahadzujú: prázdna stanica by mohla
  /// vyhrať výber "najbližšia" a pripraviť záznam aj o modelové dáta.
  static List<DhmzStationReading> parseLandStations(String xmlBody) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(xmlBody);
    } on XmlException {
      return const [];
    }

    final root = doc.rootElement;
    final observedAt = parseObservedAt(
      _text(root, 'Datum'),
      _text(root, 'Termin'),
    );
    if (observedAt == null) return const [];

    final out = <DhmzStationReading>[];
    for (final grad in root.findAllElements('Grad')) {
      final name = _text(grad, 'GradIme')?.trim();
      final lat = parseNumber(_text(grad, 'Lat'));
      final lon = parseNumber(_text(grad, 'Lon'));
      if (name == null || name.isEmpty || lat == null || lon == null) continue;

      final windMs = parseNumber(_text(grad, 'VjetarBrzina'));
      final reading = DhmzStationReading(
        station: name,
        latitude: lat,
        longitude: lon,
        observedAt: observedAt,
        airTemp: parseNumber(_text(grad, 'Temp')),
        airPressure: parseNumber(_text(grad, 'Tlak')),
        pressureTendency: parseNumber(_text(grad, 'TlakTend')),
        windSpeedKnots: windMs == null ? null : windMs * _msToKnots,
        windDirectionDeg: windDirectionToDegrees(_text(grad, 'VjetarSmjer')),
      );
      if (reading.hasAnyValue) out.add(reading);
    }
    return out;
  }

  /// Rozparsuje `more_n.xml` — teplotu mora po staniciach.
  ///
  /// Feed nedáva súradnice, len názvy, a menom sa dá na pozemné stanice
  /// spárovať menej než polovica. Zvyšok dodáva [seaStationCoordinates].
  /// Vracia poslednú nameranú hodnotu dňa: riadok má viac terminov a tie
  /// neskoršie bývajú prázdne.
  static Map<String, double> parseSeaTemperatures(String xmlBody) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(xmlBody);
    } on XmlException {
      return const {};
    }

    final out = <String, double>{};
    for (final podatci in doc.rootElement.findAllElements('Podatci')) {
      final station = podatci.getElement('Postaja')?.innerText.trim();
      if (station == null || station.isEmpty) continue;
      // Hlavičkový riadok feedu, nie stanica.
      if (station.contains('\\')) continue;

      double? last;
      for (final t in podatci.findElements('Termin')) {
        final v = parseNumber(t.innerText);
        if (v != null) last = v;
      }
      if (last != null) out[station] = last;
    }
    return out;
  }

  static String? _text(XmlElement parent, String name) =>
      parent.findAllElements(name).firstOrNull?.innerText;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
