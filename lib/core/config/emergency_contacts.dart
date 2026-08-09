/// Núdzové kontakty pre plavebné oblasti — generické popisky a názvy
/// krajín lokalizované do všetkých jazykov appky; vlastné mená
/// inštitúcií (MRCC Rijeka, Guardia Costiera...) ostávajú v origináli.

class EmergencyContact {
  final String name;
  final String? number;
  final String display;
  final bool isVhf;

  const EmergencyContact({
    required this.name,
    this.number,
    required this.display,
    this.isVhf = false,
  });
}

class EmergencyRegion {
  final String country;
  final String flag;
  final List<EmergencyContact> contacts;

  const EmergencyRegion({
    required this.country,
    required this.flag,
    required this.contacts,
  });
}

/// Prekladateľný text vo všetkých jazykoch appky.
///
/// Jazyky pridané po pôvodnej pätici sú pomenované, nie pozičné: pri desiatich
/// reťazcoch za sebou by zle zoradený argument prešiel typovou kontrolou a
/// prejavil by sa až chorvátskym textom v gréckom rozhraní.
class _T {
  final String sk, en, de, es, uk, cs, pl, el;
  final String? hr;
  final String? sl;
  final String? it;
  const _T(this.sk, this.en, this.de, this.es, this.uk, this.cs, this.pl,
      this.el,
      {this.hr, this.sl, this.it});
  String of(String l) => switch (l) {
        'sk' => sk,
        'de' => de,
        'es' => es,
        'uk' => uk,
        'cs' => cs,
        'pl' => pl,
        'el' => el,
        'hr' => hr ?? en,
        'sl' => sl ?? en,
        'it' => it ?? en,
        _ => en,
      };
}

const _tVhf16 = _T('VHF kanál 16', 'VHF channel 16', 'UKW-Kanal 16',
    'Canal VHF 16', 'Канал VHF 16', 'VHF kanál 16', 'Kanał VHF 16',
    'Κανάλι VHF 16',
    hr: 'VHF kanal 16', sl: 'VHF kanal 16', it: 'Canale VHF 16');
const _tVhfIntl = _T(
    'Medzinárodný tiesňový kanál',
    'International distress channel',
    'Internationaler Notrufkanal',
    'Canal internacional de socorro',
    'Міжнародний аварійний канал',
    'Mezinárodní tísňový kanál',
    'Międzynarodowy kanał alarmowy',
    'Διεθνές κανάλι κινδύνου',
    hr: 'Međunarodni kanal za pogibelj', sl: 'Mednarodni kanal za klic v sili', it: 'Canale internazionale di soccorso');
const _tEmergencyEu = _T('Tiesňové volanie (EU)', 'Emergency call (EU)',
    'Notruf (EU)', 'Llamada de emergencia (UE)', 'Екстрений виклик (ЄС)',
    'Tísňové volání (EU)', 'Telefon alarmowy (UE)',
    'Κλήση έκτακτης ανάγκης (ΕΕ)',
    hr: 'Hitni poziv (EU)', sl: 'Klic v sili (EU)', it: 'Chiamata di emergenza (UE)');
const _tAmbulance = _T('Záchranná služba', 'Emergency medical service',
    'Rettungsdienst', 'Servicio de emergencias', 'Швидка допомога',
    'Záchranná služba', 'Pogotowie ratunkowe', 'Επείγουσα ιατρική βοήθεια',
    hr: 'Hitna medicinska pomoć', sl: 'Nujna medicinska pomoč', it: 'Servizio medico di emergenza');
const _tPolice = _T('Polícia', 'Police', 'Polizei', 'Policía', 'Поліція',
    'Policie', 'Policja', 'Αστυνομία',
    hr: 'Policija', sl: 'Policija', it: 'Polizia');
const _tEmergencyLine = _T('Tiesňová linka', 'Emergency line', 'Notrufnummer',
    'Línea de emergencia', 'Лінія екстреної допомоги', 'Tísňová linka',
    'Linia alarmowa', 'Γραμμή έκτακτης ανάγκης',
    hr: 'Linija za hitne slučajeve', sl: 'Klicna linija v sili', it: 'Linea di emergenza');
const _tCross = _T(
    'CROSS (záchrana na mori)',
    'CROSS (sea rescue)',
    'CROSS (Seenotrettung)',
    'CROSS (salvamento marítimo)',
    'CROSS (морський порятунок)',
    'CROSS (záchrana na moři)',
    'CROSS (ratownictwo morskie)',
    'CROSS (θαλάσσια διάσωση)',
    hr: 'CROSS (spašavanje na moru)', sl: 'CROSS (reševanje na morju)', it: 'CROSS (soccorso in mare)');

const Map<String, _T> _countryNames = {
  'HR': _T('Chorvátsko', 'Croatia', 'Kroatien', 'Croacia', 'Хорватія',
      'Chorvatsko', 'Chorwacja', 'Κροατία',
      hr: 'Hrvatska', sl: 'Hrvaška', it: 'Croazia'),
  'ME': _T('Čierna Hora', 'Montenegro', 'Montenegro', 'Montenegro', 'Чорногорія',
      'Černá Hora', 'Czarnogóra', 'Μαυροβούνιο',
      hr: 'Crna Gora', sl: 'Črna gora', it: 'Montenegro'),
  'SI': _T('Slovinsko', 'Slovenia', 'Slowenien', 'Eslovenia', 'Словенія',
      'Slovinsko', 'Słowenia', 'Σλοβενία',
      hr: 'Slovenija', sl: 'Slovenija', it: 'Slovenia'),
  'IT': _T('Taliansko', 'Italy', 'Italien', 'Italia', 'Італія',
      'Itálie', 'Włochy', 'Ιταλία',
      hr: 'Italija', sl: 'Italija', it: 'Italia'),
  'GR': _T('Grécko', 'Greece', 'Griechenland', 'Grecia', 'Греція',
      'Řecko', 'Grecja', 'Ελλάδα',
      hr: 'Grčka', sl: 'Grčija', it: 'Grecia'),
  'TR': _T('Turecko', 'Türkiye', 'Türkei', 'Turquía', 'Туреччина',
      'Turecko', 'Turcja', 'Τουρκία',
      hr: 'Turska', sl: 'Turčija', it: 'Turchia'),
  'ES': _T('Španielsko', 'Spain', 'Spanien', 'España', 'Іспанія',
      'Španělsko', 'Hiszpania', 'Ισπανία',
      hr: 'Španjolska', sl: 'Španija', it: 'Spagna'),
  'PT': _T('Portugalsko', 'Portugal', 'Portugal', 'Portugal', 'Португалія',
      'Portugalsko', 'Portugalia', 'Πορτογαλία',
      hr: 'Portugal', sl: 'Portugalska', it: 'Portogallo'),
  'FR': _T('Francúzsko', 'France', 'Frankreich', 'Francia', 'Франція',
      'Francie', 'Francja', 'Γαλλία',
      hr: 'Francuska', sl: 'Francija', it: 'Francia'),
  'MT': _T('Malta', 'Malta', 'Malta', 'Malta', 'Мальта',
      'Malta', 'Malta', 'Μάλτα',
      hr: 'Malta', sl: 'Malta', it: 'Malta'),
  'AL': _T('Albánsko', 'Albania', 'Albanien', 'Albania', 'Албанія',
      'Albánie', 'Albania', 'Αλβανία',
      hr: 'Albanija', sl: 'Albanija', it: 'Albania'),
  'NO': _T('Nórsko', 'Norway', 'Norwegen', 'Noruega', 'Норвегія',
      'Norsko', 'Norwegia', 'Νορβηγία',
      hr: 'Norveška', sl: 'Norveška', it: 'Norvegia'),
  'GB': _T('Veľká Británia', 'United Kingdom', 'Großbritannien',
      'Reino Unido', 'Велика Британія', 'Velká Británie', 'Wielka Brytania',
      'Ηνωμένο Βασίλειο',
      hr: 'Ujedinjeno Kraljevstvo', sl: 'Združeno kraljestvo', it: 'Regno Unito'),
  'SK': _T('Slovensko', 'Slovakia', 'Slowakei', 'Eslovaquia', 'Словаччина',
      'Slovensko', 'Słowacja', 'Σλοβακία',
      hr: 'Slovačka', sl: 'Slovaška', it: 'Slovacchia'),
  'OFFSHORE': _T('Offshore / oceán', 'Offshore / ocean', 'Offshore / Ozean',
      'Alta mar / océano', 'Відкрите море / океан', 'Offshore / oceán',
      'Pełne morze / ocean', 'Ανοιχτή θάλασσα / ωκεανός',
      hr: 'Otvoreno more / ocean', sl: 'Odprto morje / ocean', it: 'Alto mare / oceano'),
};

/// Interná definícia kontaktu: buď pevné meno (proper noun), alebo
/// prekladateľné meno (+ voliteľný suffix kódu krajiny).
class _ContactDef {
  final String? fixedName;
  final _T? nameT;
  final String? suffix; // napr. 'HR' za "Záchranná služba"
  final String? number;
  final String? fixedDisplay;
  final _T? displayT;
  final bool isVhf;
  const _ContactDef({
    this.fixedName,
    this.nameT,
    this.suffix,
    this.number,
    this.fixedDisplay,
    this.displayT,
    this.isVhf = false,
  });

  EmergencyContact build(String locale) => EmergencyContact(
        name: fixedName ??
            '${nameT!.of(locale)}${suffix != null ? ' $suffix' : ''}',
        number: number,
        display: fixedDisplay ?? displayT?.of(locale) ?? number ?? '',
        isVhf: isVhf,
      );
}

class _RegionDef {
  final String code;
  final String flag;
  final List<_ContactDef> contacts;
  const _RegionDef(this.code, this.flag, this.contacts);

  EmergencyRegion build(String locale) => EmergencyRegion(
        country: _countryNames[code]!.of(locale),
        flag: flag,
        contacts: [for (final c in contacts) c.build(locale)],
      );
}

class EmergencyContacts {
  // Všeobecné kontakty – vždy zobrazené
  static const List<_ContactDef> _universal = [
    _ContactDef(nameT: _tVhf16, displayT: _tVhfIntl, isVhf: true),
    _ContactDef(nameT: _tEmergencyEu, number: '112', fixedDisplay: '112'),
  ];

  static List<EmergencyContact> universalFor(String locale) =>
      [for (final c in _universal) c.build(locale)];

  static const Map<String, _RegionDef> _regions = {
    'HR': _RegionDef('HR', '🇭🇷', [
      _ContactDef(fixedName: 'MRCC Rijeka', number: '+38551195', fixedDisplay: '+385 51 195'),
      _ContactDef(fixedName: 'MRCC Split', number: '+38521195', fixedDisplay: '+385 21 195'),
      _ContactDef(fixedName: 'MRCC Dubrovnik', number: '+38520195', fixedDisplay: '+385 20 195'),
      _ContactDef(nameT: _tAmbulance, suffix: 'HR', number: '+38594195', fixedDisplay: '+385 94 195'),
    ]),
    'ME': _RegionDef('ME', '🇲🇪', [
      _ContactDef(fixedName: 'MRCC Bar', number: '+38230343800', fixedDisplay: '+382 30 343 800'),
      _ContactDef(nameT: _tAmbulance, suffix: 'ME', number: '124', fixedDisplay: '124'),
    ]),
    'SI': _RegionDef('SI', '🇸🇮', [
      _ContactDef(fixedName: 'MRCC Koper', number: '+38656177000', fixedDisplay: '+386 56 177 000'),
      _ContactDef(nameT: _tAmbulance, suffix: 'SI', number: '112', fixedDisplay: '112'),
    ]),
    'IT': _RegionDef('IT', '🇮🇹', [
      _ContactDef(fixedName: 'Guardia Costiera', number: '1530', fixedDisplay: '1530'),
      _ContactDef(fixedName: 'MRCC Roma', number: '+390659084', fixedDisplay: '+39 06 5908 4'),
      _ContactDef(nameT: _tAmbulance, suffix: 'IT', number: '118', fixedDisplay: '118'),
    ]),
    'GR': _RegionDef('GR', '🇬🇷', [
      _ContactDef(fixedName: 'Hellenic Coast Guard', number: '108', fixedDisplay: '108'),
      _ContactDef(fixedName: 'JRCC Piraeus', number: '+302104112500', fixedDisplay: '+30 210 411 2500'),
      _ContactDef(nameT: _tAmbulance, suffix: 'GR', number: '166', fixedDisplay: '166'),
    ]),
    'TR': _RegionDef('TR', '🇹🇷', [
      _ContactDef(fixedName: 'Turkish Coast Guard', number: '158', fixedDisplay: '158'),
      _ContactDef(nameT: _tAmbulance, suffix: 'TR', number: '112', fixedDisplay: '112'),
    ]),
    'ES': _RegionDef('ES', '🇪🇸', [
      _ContactDef(fixedName: 'Salvamento Marítimo', number: '900202202', fixedDisplay: '900 20 22 02'),
      _ContactDef(fixedName: 'MRCC Madrid', number: '+34913597605', fixedDisplay: '+34 913 597 605'),
      _ContactDef(nameT: _tAmbulance, suffix: 'ES', number: '112', fixedDisplay: '112'),
    ]),
    'PT': _RegionDef('PT', '🇵🇹', [
      _ContactDef(fixedName: 'MRCC Lisboa', number: '+351214401919', fixedDisplay: '+351 214 401 919'),
      _ContactDef(nameT: _tAmbulance, suffix: 'PT', number: '112', fixedDisplay: '112'),
    ]),
    'FR': _RegionDef('FR', '🇫🇷', [
      _ContactDef(nameT: _tCross, number: '196', fixedDisplay: '196'),
      _ContactDef(nameT: _tAmbulance, suffix: 'FR', number: '15', fixedDisplay: '15 / 112'),
    ]),
    'MT': _RegionDef('MT', '🇲🇹', [
      _ContactDef(fixedName: 'MRCC Malta', number: '+35621250360', fixedDisplay: '+356 2125 0360'),
      _ContactDef(nameT: _tAmbulance, suffix: 'MT', number: '112', fixedDisplay: '112'),
    ]),
    'AL': _RegionDef('AL', '🇦🇱', [
      _ContactDef(fixedName: 'Albanian Coast Guard', number: '+35542229517', fixedDisplay: '+355 42 229 517'),
      _ContactDef(nameT: _tAmbulance, suffix: 'AL', number: '127', fixedDisplay: '127'),
    ]),
    'NO': _RegionDef('NO', '🇳🇴', [
      _ContactDef(fixedName: 'JRCC Norway', number: '+4751517000', fixedDisplay: '+47 51 51 70 00'),
      _ContactDef(nameT: _tAmbulance, suffix: 'NO', number: '113', fixedDisplay: '113'),
    ]),
    'GB': _RegionDef('GB', '🇬🇧', [
      _ContactDef(fixedName: 'HM Coastguard', number: '+441304224800', fixedDisplay: '+44 1304 224 800'),
      _ContactDef(nameT: _tAmbulance, suffix: 'UK', number: '999', fixedDisplay: '999 / 112'),
    ]),
    'SK': _RegionDef('SK', '🇸🇰', [
      _ContactDef(nameT: _tAmbulance, suffix: 'SR', number: '155', fixedDisplay: '155'),
      _ContactDef(nameT: _tPolice, suffix: 'SR', number: '158', fixedDisplay: '158'),
      _ContactDef(nameT: _tEmergencyLine, number: '112', fixedDisplay: '112'),
    ]),
    // Atlantik / oceány
    'OFFSHORE': _RegionDef('OFFSHORE', '🌊', [
      _ContactDef(fixedName: 'MRCC Falmouth (UK)', number: '+441326317575', fixedDisplay: '+44 1326 317 575'),
      _ContactDef(fixedName: 'CROSS Gris-Nez (FR)', number: '+33321872187', fixedDisplay: '+33 3 21 87 21 87'),
    ]),
  };

  /// Stred Jadranu na danej zemepisnej šírke — západne od neho je Taliansko,
  /// východne Chorvátsko.
  ///
  /// More sa smerom na juh rozširuje a os sa stáča na východ, takže jedna
  /// hranica po zemepisnej dĺžke nestačí: pri Poreči je stred na 12,9°E,
  /// pri Dubrovníku už na 16,3°E.
  static double _adriaticMidline(double lat) => 13.0 + (45.0 - lat) * 1.37;

  /// Kotviace body pobrežia pre Egejské more a juhozápadné Turecko.
  ///
  /// Grécke ostrovy ležia tesne pri tureckom pobreží — Kos a Bodrum delí 15 km,
  /// Rodos a Marmaris 25 km — takže bounding boxy tu nedokážu obe krajiny
  /// oddeliť. Namiesto nich sa hľadá najbližší kotviaci bod.
  static const List<(double, double, String)> _aegeanAnchors = [
    (35.34, 25.14, 'GR'), // Kréta
    (35.50, 27.20, 'GR'), // Karpatos
    (36.44, 28.22, 'GR'), // Rodos
    (36.61, 27.84, 'GR'), // Symi
    (36.89, 27.29, 'GR'), // Kos
    (36.95, 26.98, 'GR'), // Kalymnos
    (37.75, 26.98, 'GR'), // Samos
    (37.94, 23.64, 'GR'), // Pireus
    (38.37, 26.14, 'GR'), // Chios
    (39.15, 26.35, 'GR'), // Lesbos
    (39.90, 25.25, 'GR'), // Limnos
    (40.63, 22.94, 'GR'), // Solún
    (36.20, 29.64, 'TR'), // Kaš
    (36.62, 29.10, 'TR'), // Fethiye
    (36.80, 34.63, 'TR'), // Mersin
    (36.85, 28.27, 'TR'), // Marmaris
    (36.88, 30.70, 'TR'), // Antalya
    (37.03, 27.43, 'TR'), // Bodrum
    (38.32, 26.30, 'TR'), // Česme
    (38.42, 27.14, 'TR'), // Izmir
    (39.31, 26.69, 'TR'), // Ayvalík
    (40.15, 26.41, 'TR'), // Canakkale
    (41.00, 28.98, 'TR'), // Istanbul
  ];

  static String _nearestAegeanCoast(double lat, double lon) {
    var best = 'GR';
    var bestDistance = double.infinity;
    for (final (aLat, aLon, code) in _aegeanAnchors) {
      final dLat = lat - aLat;
      // Pri 38° šírke je stupeň dĺžky asi 0,79 stupňa šírky.
      final dLon = (lon - aLon) * 0.79;
      final distance = dLat * dLat + dLon * dLon;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = code;
      }
    }
    return best;
  }

  /// Vráti kód krajiny podľa GPS súradníc (aproximácia podľa bounding boxov).
  static String detectCountry(double lat, double lon) {
    // ── Jadran ──────────────────────────────────────────────────────
    if (lat >= 40.0 && lat <= 46.6 && lon >= 12.0 && lon <= 20.0) {
      // Terstský záliv: Taliansko siaha na východ až po 13,8°E, teda ďalej
      // než slovinské aj chorvátske pobrežie pod ním.
      if (lat >= 45.6 && lon <= 13.9) return 'IT';
      // Slovinsko má len úzky pás od Debelého rtiča po Piranský záliv.
      if (lat >= 45.45 && lat <= 45.6 && lon >= 13.35 && lon <= 13.95) {
        return 'SI';
      }
      // Boka Kotorská a čiernohorské pobrežie.
      if (lat >= 41.8 && lat < 42.65 && lon >= 18.4) return 'ME';
      if (lat >= 39.5 && lat < 41.9 && lon >= 19.0) return 'AL';
      return lon <= _adriaticMidline(lat) ? 'IT' : 'HR';
    }

    // ── Stredozemné more ────────────────────────────────────────────
    // Baleáry a Korzika ležia vnútri talianskeho boxu, takže musia ísť prvé.
    if (lat >= 38.5 && lat <= 40.2 && lon >= 1.0 && lon <= 4.5) return 'ES';
    if (lat >= 41.3 && lat <= 43.1 && lon >= 8.4 && lon <= 9.7) return 'FR';
    if (lat >= 35.5 && lat <= 36.5 && lon >= 14.0 && lon <= 14.8) return 'MT';
    // Španielske východné pobrežie od Gibraltáru po Cap de Creus leží vnútri
    // talianskeho boxu, takže ide pred ním.
    if (lat >= 36.0 && lat <= 42.4 && lon >= -1.0 && lon <= 3.35) return 'ES';
    if (lat >= 35.0 && lat <= 42.0 && lon >= 2.0 && lon <= 18.0) return 'IT';
    // Ligúrske a toskánske pobrežie je nad 42. rovnobežkou.
    if (lat >= 42.0 && lat <= 44.6 && lon >= 8.5 && lon <= 12.6) return 'IT';
    // Atlantické pobrežie: Portugalsko leží vnútri španielskeho boxu a
    // francúzske Baskicko tiež, takže oba idú pred ním.
    if (lat >= 36.9 && lat <= 42.2 && lon >= -9.7 && lon <= -7.4) return 'PT';
    if (lat >= 43.35 && lat <= 46.5 && lon >= -2.3 && lon <= 0.0) return 'FR';
    if (lat >= 36.0 && lat <= 43.9 && lon >= -9.5 && lon <= 3.5) return 'ES';
    if (lat >= 42.4 && lat <= 51.5 && lon >= -5.0 && lon <= 8.5) return 'FR';
    // Iónske more a pevninské Grécko.
    if (lat >= 34.0 && lat <= 42.5 && lon >= 19.0 && lon < 22.5) return 'GR';
    // Egejské more a juhozápadné Turecko — pozri _nearestAegeanCoast.
    if (lat >= 34.0 && lat <= 41.5 && lon >= 22.5 && lon <= 37.0) {
      return _nearestAegeanCoast(lat, lon);
    }

    // ── Atlantik / severná Európa ───────────────────────────────────
    if (lat >= 50.0 && lat <= 61.5 && lon >= -8.5 && lon <= 2.0) return 'GB';
    if (lat >= 57.5 && lat <= 71.5 && lon >= 4.0 && lon <= 32.0) return 'NO';

    // ── Slovensko (vnútrozemie) ─────────────────────────────────────
    if (lat >= 47.7 && lat <= 49.6 && lon >= 16.8 && lon <= 22.6) return 'SK';

    // ── Otvorený oceán ──────────────────────────────────────────────
    return 'OFFSHORE';
  }

  static EmergencyRegion? getRegion(String countryCode, String locale) =>
      _regions[countryCode]?.build(locale);

  static EmergencyRegion? getRegionForLocation(
          double lat, double lon, String locale) =>
      _regions[detectCountry(lat, lon)]?.build(locale);
}
