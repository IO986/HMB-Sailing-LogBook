/// Núdzové kontakty pre plavebné oblasti — generické popisky a názvy
/// krajín lokalizované do všetkých 5 jazykov appky; vlastné mená
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

/// Prekladateľný text v 5 jazykoch appky.
class _T {
  final String sk, en, de, es, uk;
  const _T(this.sk, this.en, this.de, this.es, this.uk);
  String of(String l) => switch (l) {
        'sk' => sk,
        'de' => de,
        'es' => es,
        'uk' => uk,
        _ => en,
      };
}

const _tVhf16 = _T('VHF kanál 16', 'VHF channel 16', 'UKW-Kanal 16',
    'Canal VHF 16', 'Канал VHF 16');
const _tVhfIntl = _T(
    'Medzinárodný tiesňový kanál',
    'International distress channel',
    'Internationaler Notrufkanal',
    'Canal internacional de socorro',
    'Міжнародний аварійний канал');
const _tEmergencyEu = _T('Tiesňové volanie (EU)', 'Emergency call (EU)',
    'Notruf (EU)', 'Llamada de emergencia (UE)', 'Екстрений виклик (ЄС)');
const _tAmbulance = _T('Záchranná služba', 'Emergency medical service',
    'Rettungsdienst', 'Servicio de emergencias', 'Швидка допомога');
const _tPolice = _T('Polícia', 'Police', 'Polizei', 'Policía', 'Поліція');
const _tEmergencyLine = _T('Tiesňová linka', 'Emergency line', 'Notrufnummer',
    'Línea de emergencia', 'Лінія екстреної допомоги');
const _tCross = _T(
    'CROSS (záchrana na mori)',
    'CROSS (sea rescue)',
    'CROSS (Seenotrettung)',
    'CROSS (salvamento marítimo)',
    'CROSS (морський порятунок)');

const Map<String, _T> _countryNames = {
  'HR': _T('Chorvátsko', 'Croatia', 'Kroatien', 'Croacia', 'Хорватія'),
  'ME': _T('Čierna Hora', 'Montenegro', 'Montenegro', 'Montenegro', 'Чорногорія'),
  'SI': _T('Slovinsko', 'Slovenia', 'Slowenien', 'Eslovenia', 'Словенія'),
  'IT': _T('Taliansko', 'Italy', 'Italien', 'Italia', 'Італія'),
  'GR': _T('Grécko', 'Greece', 'Griechenland', 'Grecia', 'Греція'),
  'TR': _T('Turecko', 'Türkiye', 'Türkei', 'Turquía', 'Туреччина'),
  'ES': _T('Španielsko', 'Spain', 'Spanien', 'España', 'Іспанія'),
  'PT': _T('Portugalsko', 'Portugal', 'Portugal', 'Portugal', 'Португалія'),
  'FR': _T('Francúzsko', 'France', 'Frankreich', 'Francia', 'Франція'),
  'MT': _T('Malta', 'Malta', 'Malta', 'Malta', 'Мальта'),
  'AL': _T('Albánsko', 'Albania', 'Albanien', 'Albania', 'Албанія'),
  'NO': _T('Nórsko', 'Norway', 'Norwegen', 'Noruega', 'Норвегія'),
  'GB': _T('Veľká Británia', 'United Kingdom', 'Großbritannien',
      'Reino Unido', 'Велика Британія'),
  'SK': _T('Slovensko', 'Slovakia', 'Slowakei', 'Eslovaquia', 'Словаччина'),
  'OFFSHORE': _T('Offshore / oceán', 'Offshore / ocean', 'Offshore / Ozean',
      'Alta mar / océano', 'Відкрите море / океан'),
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

  /// Vráti kód krajiny podľa GPS súradníc (aproximácia podľa bounding boxov)
  static String detectCountry(double lat, double lon) {
    // Jadranské more – detailnejšia detekcia
    if (lat >= 40.0 && lat <= 46.5 && lon >= 13.0 && lon <= 20.0) {
      if (lon <= 14.0) return 'IT';           // Taliansko (Friuli)
      if (lat >= 45.0 && lon <= 15.0) return 'SI';  // Slovinsko
      if (lat >= 42.0 && lat <= 46.5 && lon >= 13.5 && lon <= 19.5) return 'HR'; // Chorvátsko
      if (lat >= 40.0 && lat < 42.5 && lon >= 18.5) return 'ME'; // Čierna Hora
      if (lat >= 39.5 && lat < 42.0 && lon >= 19.0) return 'AL'; // Albánsko
      return 'HR'; // default Jadran = Chorvátsko
    }

    // Stredozemné more - bounding boxy
    if (lat >= 35.0 && lat <= 42.0 && lon >= 2.0 && lon <= 18.0) return 'IT';
    if (lat >= 36.0 && lat <= 42.0 && lon >= -9.5 && lon <= 3.5) return 'ES';
    if (lat >= 36.5 && lat <= 47.5 && lon >= -9.5 && lon <= -6.0) return 'PT';
    if (lat >= 43.0 && lat <= 51.5 && lon >= -5.0 && lon <= 8.5) return 'FR';
    if (lat >= 35.0 && lat <= 42.5 && lon >= 19.0 && lon <= 28.5) return 'GR';
    if (lat >= 35.5 && lat <= 42.5 && lon >= 25.5 && lon <= 36.5) return 'TR';
    if (lat >= 35.5 && lat <= 36.5 && lon >= 14.0 && lon <= 14.8) return 'MT';

    // Atlantik / severná Európa
    if (lat >= 50.0 && lat <= 61.5 && lon >= -8.5 && lon <= 2.0) return 'GB';
    if (lat >= 57.5 && lat <= 71.5 && lon >= 4.0 && lon <= 32.0) return 'NO';

    // Slovensko (vnútrozemie)
    if (lat >= 47.7 && lat <= 49.6 && lon >= 16.8 && lon <= 22.6) return 'SK';

    // Otvorený oceán
    if ((lon < -10.0) || (lat < 30.0 && lon > 0)) return 'OFFSHORE';

    return 'OFFSHORE';
  }

  static EmergencyRegion? getRegion(String countryCode, String locale) =>
      _regions[countryCode]?.build(locale);

  static EmergencyRegion? getRegionForLocation(
          double lat, double lon, String locale) =>
      _regions[detectCountry(lat, lon)]?.build(locale);
}
