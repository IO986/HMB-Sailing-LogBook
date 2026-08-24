import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

import '../database/app_database.dart';

/// Jedna výstraha tak, ako prišla z feedu.
class WeatherWarningItem {
  const WeatherWarningItem({
    required this.identifier,
    required this.areaDesc,
    required this.event,
    required this.awarenessLevel,
    required this.onset,
    required this.expires,
    this.capUrl,
  });

  final String identifier;
  final String areaDesc;
  final String event;

  /// 1 zelená, 2 žltá, 3 oranžová, 4 červená — stupnica MeteoAlarm.
  final int awarenessLevel;

  final DateTime onset;
  final DateTime expires;

  /// Odkaz na podrobný dokument CAP s popisom a pokynom vo viacerých jazykoch.
  final String? capUrl;
}

/// Text výstrahy v jednom konkrétnom jazyku.
class WarningDetail {
  const WarningDetail({
    this.description,
    this.instruction,
    this.language,
    this.sender,
  });

  final String? description;
  final String? instruction;

  /// Jazyk, v ktorom je text naozaj napísaný.
  final String? language;

  /// Národná služba, ktorá výstrahu vydala.
  final String? sender;
}

/// Úradné výstrahy pred nebezpečným počasím (MeteoAlarm).
///
/// Nie je to ďalší model. Výstrahy vydávajú **národné meteorologické služby** —
/// v Chorvátsku DHMZ, v Británii Met Office, vo Švédsku SMHI — a MeteoAlarm je
/// spoločná strecha, pod ktorou ich zverejňujú. Jedna integrácia teda pokrýva
/// 48 európskych krajín a v každej z nich hovorí domáci úrad, nie cudzí model.
///
/// Bez kľúča a bez registrácie. Licencia je podľa feedu „equivalent to
/// CC BY 4.0" s dodatočnými podmienkami pre ďalšie šírenie — preto sa vydavateľ
/// vždy menuje pri výstrahe.
class MeteoAlarmService {
  static final MeteoAlarmService _i = MeteoAlarmService._(Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 12),
  )));
  factory MeteoAlarmService() => _i;
  MeteoAlarmService._(this._dio);

  @visibleForTesting
  factory MeteoAlarmService.forTesting(Dio dio) => MeteoAlarmService._(dio);

  final Dio _dio;

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  static const _feedBase = 'https://feeds.meteoalarm.org/feeds/'
      'meteoalarm-legacy-atom-';

  /// Feed sa obnovuje po vydaní novej výstrahy; častejšie ťahanie nemá zmysel.
  static const _minSyncInterval = Duration(minutes: 30);

  DateTime? _lastSyncAt;
  String? _lastCountry;

  /// Kód krajiny → názov feedu.
  ///
  /// MeteoAlarm pomenúva feedy anglickým názvom krajiny, nie kódom. Krajina,
  /// ktorá tu nie je, jednoducho nemá výstrahy — nie je to chyba, len hranica
  /// pokrytia siete EUMETNET.
  static const feedSlugs = <String, String>{
    'at': 'austria',
    'ba': 'bosnia-herzegovina',
    'be': 'belgium',
    'bg': 'bulgaria',
    'ch': 'switzerland',
    'cy': 'cyprus',
    'cz': 'czechia',
    'de': 'germany',
    'dk': 'denmark',
    'ee': 'estonia',
    'es': 'spain',
    'fi': 'finland',
    'fr': 'france',
    'gb': 'united-kingdom',
    'gr': 'greece',
    'hr': 'croatia',
    'hu': 'hungary',
    'ie': 'ireland',
    'il': 'israel',
    'is': 'iceland',
    'it': 'italy',
    'lt': 'lithuania',
    'lu': 'luxembourg',
    'lv': 'latvia',
    'md': 'moldova',
    'me': 'montenegro',
    'mk': 'north-macedonia',
    'mt': 'malta',
    'nl': 'netherlands',
    'no': 'norway',
    'pl': 'poland',
    'pt': 'portugal',
    'ro': 'romania',
    'rs': 'serbia',
    'se': 'sweden',
    'si': 'slovenia',
    'sk': 'slovakia',
    'ua': 'ukraine',
  };

  /// Stiahne výstrahy pre krajinu a uloží ich.
  ///
  /// Nikdy nevyhadzuje výnimku a nikdy nie je podmienkou ničoho (pravidlo
  /// offline-first): keď sieť nie je, ostane posledná keš.
  Future<void> sync(String countryCode, {bool force = false}) async {
    final db = _db;
    if (db == null) return;

    final cc = countryCode.toLowerCase();
    final slug = feedSlugs[cc];
    if (slug == null) return;

    final last = _lastSyncAt;
    if (!force &&
        last != null &&
        _lastCountry == cc &&
        DateTime.now().difference(last) < _minSyncInterval) {
      return;
    }

    try {
      final resp = await _dio.get<String>('$_feedBase$slug');
      final items = parseFeed(resp.data ?? '');
      final now = DateTime.now();
      await db.replaceWeatherWarnings([
        for (final w in items)
          WeatherWarningsCompanion.insert(
            identifier: w.identifier,
            country: cc,
            areaDesc: w.areaDesc,
            event: w.event,
            awarenessLevel: w.awarenessLevel,
            onset: w.onset,
            expires: w.expires,
            downloadedAt: now,
            capUrl: drift.Value(w.capUrl),
          ),
      ]);
      _lastSyncAt = now;
      _lastCountry = cc;
      debugPrint('[ALARM] $slug: ${items.length} warnings');
    } catch (e) {
      debugPrint('[ALARM] sync failed: $e');
    }
  }

  /// Doťahá popis a pokyn k jednej výstrahe a uloží ich.
  ///
  /// Volá sa až keď o text niekto požiada. Dokument CAP nesie ten istý obsah
  /// vo viacerých jazykoch — vyberie sa jazyk appky, inak angličtina, inak
  /// prvý, ktorý tam je. Uloží sa aj to, v akom jazyku text NAOZAJ je:
  /// tvrdiť, že je po slovensky, keď je po chorvátsky, je horšie než
  /// nepovedať nič.
  Future<void> fetchDetail(WeatherWarning warning, String appLanguage) async {
    final db = _db;
    final url = warning.capUrl;
    if (db == null || url == null || warning.description != null) return;

    try {
      final resp = await _dio.get<String>(url);
      final detail = parseDetail(resp.data ?? '', appLanguage);
      if (detail == null) return;
      await db.updateWarningDetail(
        warning.id,
        description: detail.description,
        instruction: detail.instruction,
        language: detail.language,
        sender: detail.sender,
      );
    } catch (e) {
      debugPrint('[ALARM] detail failed: $e');
    }
  }

  /// Vyberie z dokumentu CAP blok v najvhodnejšom jazyku.
  @visibleForTesting
  static WarningDetail? parseDetail(String xmlBody, String appLanguage) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(xmlBody);
    } catch (_) {
      return null;
    }

    final infos = doc.findAllElements('info').toList();
    if (infos.isEmpty) return null;

    XmlElement? pick;
    for (final info in infos) {
      final lang = _text(info, 'language')?.toLowerCase() ?? '';
      if (lang.startsWith(appLanguage.toLowerCase())) {
        pick = info;
        break;
      }
    }
    pick ??= infos.firstWhere(
      (i) => (_text(i, 'language') ?? '').toLowerCase().startsWith('en'),
      orElse: () => infos.first,
    );

    return WarningDetail(
      description: _text(pick, 'description'),
      instruction: _text(pick, 'instruction'),
      language: _text(pick, 'language'),
      sender: _text(pick, 'senderName'),
    );
  }

  /// Rozparsuje Atom feed MeteoAlarm.
  ///
  /// Obranné: feed je cudzí a jedna pokazená položka nesmie vziať so sebou
  /// ostatné. Výstrahy bez času platnosti sa zahadzujú — výstraha, o ktorej
  /// sa nedá povedať, dokedy platí, je na mori nepoužiteľná.
  @visibleForTesting
  static List<WeatherWarningItem> parseFeed(String xmlBody) {
    final XmlDocument doc;
    try {
      doc = XmlDocument.parse(xmlBody);
    } catch (_) {
      return const [];
    }

    final out = <WeatherWarningItem>[];
    for (final entry in doc.findAllElements('entry')) {
      final identifier = _text(entry, 'identifier');
      final event = _text(entry, 'event');
      final expires = _time(_text(entry, 'expires'));
      final onset = _time(_text(entry, 'onset')) ??
          _time(_text(entry, 'effective')) ??
          _time(_text(entry, 'sent'));
      if (identifier == null || event == null || expires == null ||
          onset == null) {
        continue;
      }

      out.add(WeatherWarningItem(
        identifier: identifier,
        areaDesc: _text(entry, 'areaDesc') ?? '',
        event: event,
        awarenessLevel: awarenessLevelFor(event, _text(entry, 'severity')),
        onset: onset,
        expires: expires,
        capUrl: _capLink(entry),
      ));
    }
    return out;
  }

  /// Stupeň 1–4 z textu výstrahy, s vážnosťou ako záložným kľúčom.
  ///
  /// Farba je v anglickom názve udalosti ("Yellow thunderstorm warning") a je
  /// to tá istá stupnica, akú používajú národné služby na svojich stránkach.
  /// Keď farba chýba, rozhodne `cap:severity`.
  @visibleForTesting
  static int awarenessLevelFor(String event, String? severity) {
    final e = event.toLowerCase();
    if (e.contains('red')) return 4;
    if (e.contains('orange')) return 3;
    if (e.contains('yellow')) return 2;
    if (e.contains('green')) return 1;
    return switch (severity?.toLowerCase()) {
      'extreme' => 4,
      'severe' => 3,
      'moderate' => 2,
      'minor' => 1,
      _ => 2,
    };
  }

  static String? _capLink(XmlElement entry) {
    for (final link in entry.findElements('link')) {
      if (link.getAttribute('type') == 'application/cap+xml') {
        return link.getAttribute('href');
      }
    }
    return null;
  }

  static String? _text(XmlElement parent, String localName) {
    for (final e in parent.descendants.whereType<XmlElement>()) {
      if (e.name.local == localName) {
        final v = e.innerText.trim();
        return v.isEmpty ? null : v;
      }
    }
    return null;
  }

  static DateTime? _time(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw)?.toUtc();
}
