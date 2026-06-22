
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

class EmergencyContacts {
  // Všeobecné kontakty – vždy zobrazené
  static const List<EmergencyContact> universal = [
    EmergencyContact(name: 'VHF kanál 16', display: 'Medzinárodný tiesňový kanál', isVhf: true),
    EmergencyContact(name: 'Tiesňové volanie (EU)', number: '112', display: '112'),
  ];

  static const Map<String, EmergencyRegion> _regions = {
    'HR': EmergencyRegion(
      country: 'Chorvátsko', flag: '🇭🇷',
      contacts: [
        EmergencyContact(name: 'MRCC Rijeka', number: '+38551195', display: '+385 51 195'),
        EmergencyContact(name: 'MRCC Split', number: '+38521195', display: '+385 21 195'),
        EmergencyContact(name: 'MRCC Dubrovnik', number: '+38520195', display: '+385 20 195'),
        EmergencyContact(name: 'Záchranná služba HR', number: '+38594195', display: '+385 94 195'),
      ],
    ),
    'ME': EmergencyRegion(
      country: 'Čierna Hora', flag: '🇲🇪',
      contacts: [
        EmergencyContact(name: 'MRCC Bar', number: '+38230343800', display: '+382 30 343 800'),
        EmergencyContact(name: 'Záchranná služba ME', number: '124', display: '124'),
      ],
    ),
    'SI': EmergencyRegion(
      country: 'Slovinsko', flag: '🇸🇮',
      contacts: [
        EmergencyContact(name: 'MRCC Koper', number: '+38656177000', display: '+386 56 177 000'),
        EmergencyContact(name: 'Záchranná služba SI', number: '112', display: '112'),
      ],
    ),
    'IT': EmergencyRegion(
      country: 'Taliansko', flag: '🇮🇹',
      contacts: [
        EmergencyContact(name: 'Guardia Costiera', number: '1530', display: '1530'),
        EmergencyContact(name: 'MRCC Roma', number: '+390659084', display: '+39 06 5908 4'),
        EmergencyContact(name: 'Záchranná služba IT', number: '118', display: '118'),
      ],
    ),
    'GR': EmergencyRegion(
      country: 'Grécko', flag: '🇬🇷',
      contacts: [
        EmergencyContact(name: 'Hellenic Coast Guard', number: '108', display: '108'),
        EmergencyContact(name: 'JRCC Piraeus', number: '+302104112500', display: '+30 210 411 2500'),
        EmergencyContact(name: 'Záchranná služba GR', number: '166', display: '166'),
      ],
    ),
    'TR': EmergencyRegion(
      country: 'Turecko', flag: '🇹🇷',
      contacts: [
        EmergencyContact(name: 'Turkish Coast Guard', number: '158', display: '158'),
        EmergencyContact(name: 'Záchranná služba TR', number: '112', display: '112'),
      ],
    ),
    'ES': EmergencyRegion(
      country: 'Španielsko', flag: '🇪🇸',
      contacts: [
        EmergencyContact(name: 'Salvamento Marítimo', number: '900202202', display: '900 20 22 02'),
        EmergencyContact(name: 'MRCC Madrid', number: '+34913597605', display: '+34 913 597 605'),
        EmergencyContact(name: 'Záchranná služba ES', number: '112', display: '112'),
      ],
    ),
    'PT': EmergencyRegion(
      country: 'Portugalsko', flag: '🇵🇹',
      contacts: [
        EmergencyContact(name: 'MRCC Lisboa', number: '+351214401919', display: '+351 214 401 919'),
        EmergencyContact(name: 'Záchranná služba PT', number: '112', display: '112'),
      ],
    ),
    'FR': EmergencyRegion(
      country: 'Francúzsko', flag: '🇫🇷',
      contacts: [
        EmergencyContact(name: 'CROSS (záchrana na mori)', number: '196', display: '196'),
        EmergencyContact(name: 'Záchranná služba FR', number: '15', display: '15 / 112'),
      ],
    ),
    'MT': EmergencyRegion(
      country: 'Malta', flag: '🇲🇹',
      contacts: [
        EmergencyContact(name: 'MRCC Malta', number: '+35621250360', display: '+356 2125 0360'),
        EmergencyContact(name: 'Záchranná služba MT', number: '112', display: '112'),
      ],
    ),
    'AL': EmergencyRegion(
      country: 'Albánsko', flag: '🇦🇱',
      contacts: [
        EmergencyContact(name: 'Albanian Coast Guard', number: '+35542229517', display: '+355 42 229 517'),
        EmergencyContact(name: 'Záchranná služba AL', number: '127', display: '127'),
      ],
    ),
    'NO': EmergencyRegion(
      country: 'Nórsko', flag: '🇳🇴',
      contacts: [
        EmergencyContact(name: 'JRCC Norway', number: '+4751517000', display: '+47 51 51 70 00'),
        EmergencyContact(name: 'Záchranná služba NO', number: '113', display: '113'),
      ],
    ),
    'GB': EmergencyRegion(
      country: 'Veľká Británia', flag: '🇬🇧',
      contacts: [
        EmergencyContact(name: 'HM Coastguard', number: '+441304224800', display: '+44 1304 224 800'),
        EmergencyContact(name: 'Záchranná služba UK', number: '999', display: '999 / 112'),
      ],
    ),
    'SK': EmergencyRegion(
      country: 'Slovensko', flag: '🇸🇰',
      contacts: [
        EmergencyContact(name: 'Záchranná služba SR', number: '155', display: '155'),
        EmergencyContact(name: 'Polícia SR', number: '158', display: '158'),
        EmergencyContact(name: 'Tiesňová linka', number: '112', display: '112'),
      ],
    ),
    // Atlantik / oceány
    'OFFSHORE': EmergencyRegion(
      country: 'Offshore / oceán', flag: '🌊',
      contacts: [
        EmergencyContact(name: 'MRCC Falmouth (UK)', number: '+441326317575', display: '+44 1326 317 575'),
        EmergencyContact(name: 'CROSS Gris-Nez (FR)', number: '+33321872187', display: '+33 3 21 87 21 87'),
      ],
    ),
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

  static EmergencyRegion? getRegion(String countryCode) =>
      _regions[countryCode];

  static EmergencyRegion? getRegionForLocation(double lat, double lon) =>
      _regions[detectCountry(lat, lon)];
}
