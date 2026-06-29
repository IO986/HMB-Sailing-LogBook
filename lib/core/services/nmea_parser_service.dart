/// Parser pre NMEA 0183 sentencie z lodných inštrumentov (Raymarine a iné).
///
/// Podporované sentencie:
/// - RMC (Recommended Minimum Navigation) – poloha, rýchlosť, kurz, čas
/// - GGA (Global Positioning Fix Data) – poloha, výška, presnosť
/// - VTG (Track Made Good and Ground Speed) – kurz a rýchlosť
/// - MWV (Wind Speed and Angle) – vietor (relatívny/skutočný)
/// - VWR (Relative Wind Speed and Angle) – starší formát vetra
/// - DBT (Depth Below Transducer) – hĺbka
/// - DPT (Depth) – hĺbka + offset
/// - MTW (Water Temperature) – teplota vody
/// - HDG / HDM / HDT (Heading) – kompas
/// - XDR (Transducer) – všeobecné dáta (napr. teplota motora, RPM cez výrobcom rozšírenia)
/// - RPM (Engine RPM) – otáčky motora
library;

class NmeaFix {
  final double? latitude;
  final double? longitude;
  final double? speedKnots;
  final double? courseDegrees;
  final DateTime? timestampUtc;
  final bool valid;

  const NmeaFix({
    this.latitude,
    this.longitude,
    this.speedKnots,
    this.courseDegrees,
    this.timestampUtc,
    this.valid = false,
  });
}

class NmeaWind {
  /// Smer vetra v stupňoch (0-359)
  final double angleDegrees;
  /// Rýchlosť vetra v uzloch
  final double speedKnots;
  /// true = relatívny (apparent) vietor, false = skutočný (true) vietor
  final bool isApparent;

  const NmeaWind({
    required this.angleDegrees,
    required this.speedKnots,
    required this.isApparent,
  });
}

class NmeaDepth {
  /// Hĺbka pod sondou v metroch
  final double depthMeters;
  const NmeaDepth(this.depthMeters);
}

class NmeaWaterTemp {
  final double celsius;
  const NmeaWaterTemp(this.celsius);
}

class NmeaHeading {
  final double degrees;
  /// true = skutočný kurz (HDT), false = magnetický (HDG/HDM)
  final bool isTrue;
  const NmeaHeading(this.degrees, {this.isTrue = false});
}

class NmeaEngine {
  final double rpm;
  const NmeaEngine(this.rpm);
}

/// Výsledok parsovania jednej NMEA vety - práve jedno z polí je nenull.
class NmeaParseResult {
  final NmeaFix? fix;
  final NmeaWind? wind;
  final NmeaDepth? depth;
  final NmeaWaterTemp? waterTemp;
  final NmeaHeading? heading;
  final NmeaEngine? engine;

  const NmeaParseResult({
    this.fix,
    this.wind,
    this.depth,
    this.waterTemp,
    this.heading,
    this.engine,
  });

  bool get isEmpty =>
      fix == null &&
      wind == null &&
      depth == null &&
      waterTemp == null &&
      heading == null &&
      engine == null;
}

class NmeaParserService {
  /// Parsuje jeden riadok NMEA 0183 (so $ alebo bez, s checksum alebo bez).
  /// Vracia null ak veta nie je rozpoznaná alebo je poškodená.
  NmeaParseResult? parseLine(String rawLine) {
    final line = rawLine.trim();
    if (line.isEmpty || !line.startsWith('\$')) return null;

    // Over checksum, ak je prítomný (za *)
    final starIdx = line.indexOf('*');
    final body = starIdx >= 0 ? line.substring(1, starIdx) : line.substring(1);
    if (starIdx >= 0 && starIdx + 2 < line.length) {
      final givenChecksum = line.substring(starIdx + 1, starIdx + 3);
      final calc = _checksum(body);
      if (calc.toUpperCase() != givenChecksum.toUpperCase()) {
        return null; // poškodený rámec, zahoď
      }
    }

    final fields = body.split(',');
    if (fields.isEmpty) return null;

    // Talker ID sú prvé 2 znaky (GP, II, WI, GN, ...), sentence type ďalšie 3
    final sentenceId = fields[0];
    if (sentenceId.length < 5) return null;
    final type = sentenceId.substring(sentenceId.length - 3);

    try {
      switch (type) {
        case 'RMC':
          return NmeaParseResult(fix: _parseRMC(fields));
        case 'GGA':
          return NmeaParseResult(fix: _parseGGA(fields));
        case 'VTG':
          return NmeaParseResult(fix: _parseVTG(fields));
        case 'MWV':
          return NmeaParseResult(wind: _parseMWV(fields));
        case 'VWR':
          return NmeaParseResult(wind: _parseVWR(fields));
        case 'DBT':
          return NmeaParseResult(depth: _parseDBT(fields));
        case 'DPT':
          return NmeaParseResult(depth: _parseDPT(fields));
        case 'MTW':
          return NmeaParseResult(waterTemp: _parseMTW(fields));
        case 'HDG':
          return NmeaParseResult(heading: _parseHDG(fields));
        case 'HDM':
          return NmeaParseResult(heading: _parseHDM(fields));
        case 'HDT':
          return NmeaParseResult(heading: _parseHDT(fields));
        case 'RPM':
          return NmeaParseResult(engine: _parseRPM(fields));
        default:
          return null;
      }
    } catch (_) {
      return null; // nekompletná/chybná veta, zahoď a čakaj na ďalšiu
    }
  }

  String _checksum(String body) {
    int cs = 0;
    for (final code in body.codeUnits) {
      cs ^= code;
    }
    return cs.toRadixString(16).padLeft(2, '0');
  }

  double? _toDouble(String s) => s.isEmpty ? null : double.tryParse(s);

  /// NMEA lat/lon formát: ddmm.mmmm alebo dddmm.mmmm
  double? _parseLat(String value, String hemisphere) {
    if (value.isEmpty) return null;
    final deg = double.tryParse(value.substring(0, 2));
    final min = double.tryParse(value.substring(2));
    if (deg == null || min == null) return null;
    var result = deg + min / 60.0;
    if (hemisphere == 'S') result = -result;
    return result;
  }

  double? _parseLon(String value, String hemisphere) {
    if (value.isEmpty) return null;
    final deg = double.tryParse(value.substring(0, 3));
    final min = double.tryParse(value.substring(3));
    if (deg == null || min == null) return null;
    var result = deg + min / 60.0;
    if (hemisphere == 'W') result = -result;
    return result;
  }

  DateTime? _parseTimestamp(String timeStr, String dateStr) {
    if (timeStr.length < 6) return null;
    final hh = int.tryParse(timeStr.substring(0, 2)) ?? 0;
    final mm = int.tryParse(timeStr.substring(2, 4)) ?? 0;
    final ss = double.tryParse(timeStr.substring(4)) ?? 0;

    int day = DateTime.now().day, month = DateTime.now().month, year = DateTime.now().year;
    if (dateStr.length == 6) {
      day = int.tryParse(dateStr.substring(0, 2)) ?? day;
      month = int.tryParse(dateStr.substring(2, 4)) ?? month;
      final yy = int.tryParse(dateStr.substring(4, 6)) ?? 0;
      year = 2000 + yy;
    }
    return DateTime.utc(year, month, day, hh, mm, ss.floor());
  }

  // $--RMC,hhmmss.ss,A,llll.ll,a,yyyyy.yy,a,x.x,x.x,ddmmyy,x.x,a,m*hh
  NmeaFix _parseRMC(List<String> f) {
    if (f.length < 10) throw const FormatException('RMC incomplete');
    final status = f[2]; // A = valid, V = invalid
    final lat = _parseLat(f[3], f[4]);
    final lon = _parseLon(f[5], f[6]);
    final speedKnots = _toDouble(f[7]);
    final course = _toDouble(f[8]);
    final ts = _parseTimestamp(f[1], f[9]);
    return NmeaFix(
      latitude: lat,
      longitude: lon,
      speedKnots: speedKnots,
      courseDegrees: course,
      timestampUtc: ts,
      // 'A' = active fix; 'V' = void (simulátory často posielajú V aj keď majú platnú pozíciu)
      valid: lat != null && lon != null,
    );
  }

  // $--GGA,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx*hh
  NmeaFix _parseGGA(List<String> f) {
    if (f.length < 7) throw const FormatException('GGA incomplete');
    final fixQuality = int.tryParse(f[6]) ?? 0; // 0 = no fix
    final lat = _parseLat(f[2], f[3]);
    final lon = _parseLon(f[4], f[5]);
    final ts = _parseTimestamp(f[1], '');
    return NmeaFix(
      latitude: lat,
      longitude: lon,
      timestampUtc: ts,
      valid: fixQuality > 0 && lat != null && lon != null,
    );
  }

  // $--VTG,x.x,T,x.x,M,x.x,N,x.x,K,a*hh
  NmeaFix _parseVTG(List<String> f) {
    if (f.length < 8) throw const FormatException('VTG incomplete');
    final courseTrue = _toDouble(f[1]);
    final speedKnots = _toDouble(f[5]);
    return NmeaFix(
      courseDegrees: courseTrue,
      speedKnots: speedKnots,
      valid: courseTrue != null || speedKnots != null,
    );
  }

  // $--MWV,x.x,a,x.x,a,A*hh  (angle, reference R/T, speed, unit, status)
  NmeaWind _parseMWV(List<String> f) {
    if (f.length < 6) throw const FormatException('MWV incomplete');
    final angle = _toDouble(f[1]) ?? 0;
    final reference = f[2]; // R = relative, T = true
    var speed = _toDouble(f[3]) ?? 0;
    final unit = f[4]; // N=knots, M=m/s, K=km/h
    if (unit == 'M') speed *= 1.94384;
    if (unit == 'K') speed *= 0.539957;
    return NmeaWind(
      angleDegrees: angle,
      speedKnots: speed,
      isApparent: reference == 'R',
    );
  }

  // $--VWR,x.x,a,x.x,N,x.x,M,x.x,K*hh (starší formát, vždy apparent)
  NmeaWind _parseVWR(List<String> f) {
    if (f.length < 4) throw const FormatException('VWR incomplete');
    final angle = _toDouble(f[1]) ?? 0;
    final side = f.length > 2 ? f[2] : 'R'; // L/R
    final speedKnots = _toDouble(f[3]) ?? 0;
    final signedAngle = side == 'L' ? 360 - angle : angle;
    return NmeaWind(
      angleDegrees: signedAngle % 360,
      speedKnots: speedKnots,
      isApparent: true,
    );
  }

  // $--DBT,x.x,f,x.x,M,x.x,F*hh (feet, metres, fathoms)
  NmeaDepth _parseDBT(List<String> f) {
    if (f.length < 4) throw const FormatException('DBT incomplete');
    final meters = _toDouble(f[3]);
    if (meters == null) throw const FormatException('DBT no depth');
    return NmeaDepth(meters);
  }

  // $--DPT,x.x,x.x,x.x*hh (depth, offset, max range)
  NmeaDepth _parseDPT(List<String> f) {
    if (f.length < 2) throw const FormatException('DPT incomplete');
    final depth = _toDouble(f[1]);
    final offset = f.length > 2 ? (_toDouble(f[2]) ?? 0) : 0;
    if (depth == null) throw const FormatException('DPT no depth');
    return NmeaDepth(depth + offset);
  }

  // $--MTW,x.x,C*hh
  NmeaWaterTemp _parseMTW(List<String> f) {
    if (f.length < 2) throw const FormatException('MTW incomplete');
    final temp = _toDouble(f[1]);
    if (temp == null) throw const FormatException('MTW no temp');
    return NmeaWaterTemp(temp);
  }

  // $--HDG,x.x,x.x,a,x.x,a*hh (magnetic heading, deviation, variation)
  NmeaHeading _parseHDG(List<String> f) {
    if (f.length < 2) throw const FormatException('HDG incomplete');
    final heading = _toDouble(f[1]);
    if (heading == null) throw const FormatException('HDG no heading');
    return NmeaHeading(heading, isTrue: false);
  }

  // $--HDM,x.x,M*hh
  NmeaHeading _parseHDM(List<String> f) {
    if (f.length < 2) throw const FormatException('HDM incomplete');
    final heading = _toDouble(f[1]);
    if (heading == null) throw const FormatException('HDM no heading');
    return NmeaHeading(heading, isTrue: false);
  }

  // $--HDT,x.x,T*hh
  NmeaHeading _parseHDT(List<String> f) {
    if (f.length < 2) throw const FormatException('HDT incomplete');
    final heading = _toDouble(f[1]);
    if (heading == null) throw const FormatException('HDT no heading');
    return NmeaHeading(heading, isTrue: true);
  }

  // $--RPM,a,x,x.x,x.x,A*hh (source E=engine/S=shaft, number, rpm, pitch, status)
  NmeaEngine _parseRPM(List<String> f) {
    if (f.length < 4) throw const FormatException('RPM incomplete');
    final rpm = _toDouble(f[3]);
    if (rpm == null) throw const FormatException('RPM no value');
    return NmeaEngine(rpm);
  }
}
