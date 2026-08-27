import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../models/marine_instrument_data.dart';
import 'raymarine_connection_service.dart';
import 'udp_receiver_service.dart';

/// Ako draho sa má práve teraz čítať poloha z telefónu.
///
/// Rozdiel medzi [idle] a [precise] je celý zmysel tejto triedy z pohľadu
/// batérie: GNSS prijímač na plný výkon je najdrahšia vec, ktorú appka robí,
/// a drvivú väčšinu času ju nikto nepotrebuje presnú na meter.
enum LocationPowerProfile {
  /// Stream úplne vypnutý — appka je na pozadí bez trackingu, alebo polohu
  /// dodávajú lodné inštrumenty.
  off,

  /// Poloha "kde približne sme" — dosť na mapový marker, počasie, prílivy.
  idle,

  /// Plná presnosť — tracking plavby, zameriavanie, kotvová stráž.
  precise,
}

/// Singleton GPS service - vždy aktívny, nezávislý od trackingu.
///
/// Zdroj polohy má dve úrovne priority:
/// 1. Lodné inštrumenty (Raymarine NMEA GPS fix) - ak sú pripojené a dáta
///    sú "fresh" (prišli v posledných 8s), použijú sa tieto dáta.
/// 2. Android GPS (geolocator) - fallback, keď Raymarine nie je pripojený
///    alebo jeho dáta vypadli.
///
/// Ostatné časti appky (GpsTrackingService, weather sync, logbook) nemusia
/// vedieť o Raymarine vôbec - dostávajú jednotný Position stream a vždy
/// majú najlepší dostupný zdroj.
class LocationService {
  static final LocationService _i = LocationService._();
  factory LocationService() => _i;
  LocationService._();

  final _gps = GeolocatorLocationService();

  /// Tracking, zameriavanie, kotvová stráž — poloha musí byť presná a hustá.
  ///
  /// 5 s je zámerne to isté, čo si geolocator pýtal doteraz sám od seba
  /// (jeho Android default; overené na zariadení cez `dumpsys location`,
  /// build 59 žiadal `@+5s0ms`). Kratší interval by presný režim urobil
  /// DRAHŠÍM než pred optimalizáciou — a nič by nepriniesol, lebo bod do
  /// trasy sa aj tak zapisuje najviac raz za 5 s (TrackPointThrottle).
  static const _preciseConfig = LocationConfig(
    streamDistanceFilterM: 5,
    streamInterval: Duration(seconds: 5),
  );

  /// Bežná obrazovka appky: marker na mape, počasie, prílivy. 50 m a 15 s je
  /// pre tieto účely nerozoznateľné od plnej presnosti a stojí zlomok energie.
  static const _idleConfig = LocationConfig(
    streamPrecision: LocationPrecision.balanced,
    streamDistanceFilterM: 50,
    streamInterval: Duration(seconds: 15),
  );

  /// Ako dlho musia lodné inštrumenty dodávať čerstvý fix, kým sa GPS telefónu
  /// vypne. Krátke výpadky NMEA sa tak neprejavia neustálym vypínaním
  /// a zapínaním prijímača (každý štart stojí studený fix).
  static const _instrumentHandoverDelay = Duration(seconds: 30);

  /// Ako staré smie byť posledné hlásenie polohy z NMEA, aby sa ešte smelo
  /// vydávať za aktuálnu polohu.
  ///
  /// Zámerne sa pozerá na [MarineInstrumentData.gpsLastUpdate], nie na
  /// `hasFreshData`: to sa hýbe pri každej vete, takže loď, ktorej vypadol
  /// GPS prijímač, ale ďalej hlási vietor a hĺbku, by donekonečna vydávala
  /// polohu spred hodiny.
  static const _nmeaFixMaxAge = Duration(seconds: 8);

  /// Ako starý smie byť fix z telefónu, keď sú v hre lodné inštrumenty.
  ///
  /// Po handovere ([_instrumentHandoverDelay]) je GNSS telefónu vypnuté,
  /// takže `_lastAndroidPosition` zamrzne na mieste, kde sa handover stal.
  /// Bez tejto kontroly stačí jediná chýbajúca NMEA veta a do streamu sa
  /// vypustí tá zamrznutá poloha — z terénu to vyzerá ako teleport na
  /// staré miesto a hneď späť, a rovnaký skok sa naráta aj do najazdených
  /// míľ. Bez pripojených inštrumentov je telefón jediný zdroj a žiadny
  /// vekový strop nedáva zmysel (v idle režime chodia fixy raz za 15 s).
  static const _androidFixMaxAgeWithInstruments = Duration(seconds: 20);

  StreamSubscription<LocationFix>? _androidSub;
  StreamSubscription<MarineInstrumentData>? _raymarineSub;
  StreamSubscription<MarineInstrumentData>? _udpSub;
  Timer? _fallbackCheckTimer;
  AppLifecycleListener? _lifecycleListener;

  /// Kto práve potrebuje presnú polohu. Kľúčom je token volajúceho, takže
  /// dvakrát pridaný ten istý konzument profil nezasekne.
  final Set<Object> _preciseConsumers = {};

  /// Podmnožina [_preciseConsumers], ktorá má nárok na presnú polohu aj keď
  /// je appka na pozadí — pozri [requestPrecise].
  final Set<Object> _backgroundCapableConsumers = {};
  bool _foreground = true;
  DateTime? _instrumentFixSince;
  LocationPowerProfile _profile = LocationPowerProfile.off;
  LocationConfig? _activeStreamConfig;
  Duration? _fallbackTimerPeriod;

  final _ctrl = StreamController<Position>.broadcast();
  final ValueNotifier<LocationAvailability?> availability = ValueNotifier(null);
  Position? _lastPosition;
  // Posledný fix, ktorý sa reálne poslal do streamu — _reEvaluateSource() sa
  // volá aj z 4s fallback timeru bez ohľadu na to, či prišiel nový fix;
  // bez dedupe by tak do streamu tieklo to isté staré position donekonečna
  // (potvrdené v teréne: GPX export mal desiatky identických duplicitných
  // bodov na tú istú sekundu a periodické auto-záznamy denníka z nich brali
  // zastaraný SOG/COG).
  Position? _lastEmittedPosition;
  Position? _lastAndroidPosition;
  /// Kedy fix z telefónu dorazil (nie čas fixu — ten môže byť z cache).
  DateTime? _lastAndroidAt;
  LocationSource? _lastAndroidSource;
  bool _lastAndroidIsMocked = false;
  LocationSource? _lastSource;
  bool _lastIsMocked = false;
  bool _initialized = false;
  bool _usingRaymarine = false;

  Stream<Position> get stream => _ctrl.stream;
  Position? get lastPosition => _lastPosition;

  /// Zdroj poslednej emitovanej polohy (gnss/network/cached/unknown), na
  /// ukladanie kvality fixu spolu so záznamom (denník, quick-photo).
  LocationSource? get lastSource => _lastSource;

  /// True, ak platforma poslednú emitovanú polohu nahlásila ako mockovanú.
  bool get lastIsMocked => _lastIsMocked;

  /// True, ak posledná emitovaná poloha pochádza z lodných inštrumentov.
  bool get isUsingInstrumentGps => _usingRaymarine;

  /// Aktuálny režim odberu GPS. Na diagnostiku a testy.
  LocationPowerProfile get powerProfile => _profile;

  /// Prihlási konzumenta, ktorý potrebuje presnú a hustú polohu (tracking,
  /// zameriavanie, kotvová stráž, mapa). Kým je prihlásený aspoň jeden,
  /// beží GPS na plný výkon; inak stačí lacný idle režim.
  ///
  /// [token] je ľubovoľný objekt volajúceho (napr. `this` obrazovky) — ten
  /// istý token treba podať do [releasePrecise].
  ///
  /// [survivesBackground] rozlišuje dva druhy konzumentov a je to dôležité:
  /// obrazovka (mapa, kompas, prístroje) polohu potrebuje len kým sa na ňu
  /// niekto pozerá, takže po odchode appky na pozadie sa jej nárok ignoruje.
  /// Tracking, kotvová stráž a MOB bežia ďalej aj so zhasnutou obrazovkou —
  /// drží ich foreground service a ich zmyslom je práve to.
  ///
  /// Bez tohto rozlíšenia by stačilo nechať otvorenú mapu a odísť z appky,
  /// aby GNSS ostal na plný výkon. Android síce polohu aplikáciám na pozadí
  /// sám potláča (overené na zariadení), ale spoliehať sa na to znamená mať
  /// v kóde invariant, ktorý kód nedodržiava.
  void requestPrecise(Object token, {bool survivesBackground = false}) {
    if (!_preciseConsumers.add(token)) return;
    if (survivesBackground) _backgroundCapableConsumers.add(token);
    _applyProfile();
  }

  /// Odhlási konzumenta pridaného cez [requestPrecise].
  void releasePrecise(Object token) {
    _backgroundCapableConsumers.remove(token);
    if (!_preciseConsumers.remove(token)) return;
    _applyProfile();
  }

  /// Ktorý režim by mal práve teraz bežať.
  ///
  /// Poradie rozhodovania:
  /// 1. Lodné inštrumenty dodávajú vlastný fix → GPS telefónu je zbytočné.
  /// 2. Appka je na pozadí: rozhodujú len konzumenti, ktorí tam majú čo
  ///    robiť (tracking, kotvová stráž, MOB). Ak žiadny nie je, vypni —
  ///    otvorená mapa za oknom appky nie je dôvod držať GNSS.
  /// 3. V popredí stačí ktorýkoľvek konzument na plný výkon.
  /// 4. Inak lacný idle režim, aby `lastPosition` neostalo zastarané.
  LocationPowerProfile get _desiredProfile {
    if (_instrumentGpsSettled) return LocationPowerProfile.off;

    if (!_foreground) {
      return _backgroundCapableConsumers.isEmpty
          ? LocationPowerProfile.off
          : LocationPowerProfile.precise;
    }
    return _preciseConsumers.isEmpty
        ? LocationPowerProfile.idle
        : LocationPowerProfile.precise;
  }

  /// True, keď inštrumenty dodávajú čerstvý fix už dosť dlho na to, aby sa
  /// dalo GPS telefónu bezpečne vypnúť — pozri [_instrumentHandoverDelay].
  bool get _instrumentGpsSettled {
    final since = _instrumentFixSince;
    return since != null &&
        DateTime.now().difference(since) >= _instrumentHandoverDelay;
  }

  /// Zosúladí bežiaci stream so [_desiredProfile]. Volá sa pri každej zmene
  /// vstupu (konzumenti, lifecycle, stav inštrumentov); ak sa nič nemení,
  /// nerobí nič, takže sa smie volať aj z timeru.
  void _applyProfile() {
    final desired = _desiredProfile;
    if (desired == _profile) return;
    _profile = desired;
    debugPrint('[LOC] Power profile -> ${desired.name}');

    if (desired == LocationPowerProfile.off) {
      _stopAndroidStream();
      return;
    }
    final config = desired == LocationPowerProfile.precise
        ? _preciseConfig
        : _idleConfig;
    if (_androidSub != null && _activeStreamConfig == config) return;
    _stopAndroidStream();
    unawaited(_startAndroidStream(config));
  }

  void _stopAndroidStream() {
    _androidSub?.cancel();
    _androidSub = null;
    _activeStreamConfig = null;
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Appka na pozadí bez trackingu polohu nikomu nezobrazuje ani nezapisuje,
    // takže GNSS prijímač tam nemá čo robiť. Počas trackingu ostáva bežať —
    // vtedy je zmyslom appky práve to, že zaznamenáva trasu so zhasnutou
    // obrazovkou (drží ju foreground service).
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        _foreground = state == AppLifecycleState.resumed ||
            state == AppLifecycleState.inactive;
        _applyProfile();
      },
    );

    await _initAndroidGps();
    _listenToNmea();
    _startFallbackTimer();

    debugPrint('[LOC] Location service started');
  }

  /// Periodicky overí, či treba prepnúť zdroj (napr. Raymarine vypadol
  /// a medzitým neprišla žiadna nová Android pozícia, ktorá by spustila
  /// prehodnotenie), a zachytí povolenie udelené mimo appky.
  ///
  /// Perióda sa riadi tým, či na NMEA vôbec čakáme: keď sú inštrumenty v hre,
  /// ich výpadok treba zachytiť do niekoľkých sekúnd, inak stačí občasná
  /// kontrola. Štvorsekundový timer bežiaci navždy je sám o sebe merateľný
  /// odber, keď appka celý deň leží v prístave.
  void _startFallbackTimer() {
    final watchingInstruments = RaymarineConnectionService().isConnected ||
        UdpReceiverService().isListening;
    final period =
        watchingInstruments ? const Duration(seconds: 4) : const Duration(seconds: 20);
    if (_fallbackCheckTimer != null && _fallbackTimerPeriod == period) return;

    _fallbackCheckTimer?.cancel();
    _fallbackTimerPeriod = period;
    _fallbackCheckTimer = Timer.periodic(period, (_) {
      _reEvaluateSource();
      // Len kontrola stavu, nepýta znova (to robí až explicitný
      // retryPermission() z UI).
      if (_androidSub == null && _desiredProfile != LocationPowerProfile.off) {
        _refreshAvailabilityAndMaybeStart();
      }
    });
  }

  Future<void> _initAndroidGps() async {
    var avail = await _gps.checkAvailability();
    if (avail.permission == LocationPermissionState.denied) {
      await _gps.requestPermission();
      avail = await _gps.checkAvailability();
    }
    availability.value = avail;
    if (!avail.usable) return;
    _applyProfile();
  }

  /// Kontrola stavu bez pýtania permission — zachytí povolenie/zapnutie GPS
  /// zmenené mimo appky (systémové nastavenia), kým appka beží.
  Future<void> _refreshAvailabilityAndMaybeStart() async {
    final avail = await _gps.checkAvailability();
    availability.value = avail;
    if (avail.usable) _applyProfile();
  }

  /// Explicitný retry z UI (napr. banner "Poloha nepovolená") — jediné
  /// miesto okrem prvého spustenia, ktoré smie zobraziť systémový dialóg.
  Future<bool> retryPermission() async {
    await _gps.requestPermission();
    final avail = await _gps.checkAvailability();
    availability.value = avail;
    if (avail.usable) _applyProfile();
    return avail.usable;
  }

  /// Najlepší fix, ktorý je práve teraz dostupný — pre jednorazových
  /// konzumentov, ktorí nemôžu čakať na zapnutý tracking (núdzové kontakty).
  ///
  /// Ak už polohu poznáme, vráti ju hneď. Inak si aktívne vyžiada fix; keď
  /// ani ten nepríde (napr. bez povolenia), skúsi poslednú známu polohu
  /// z platformy. Nikdy nevyhadzuje výnimku — volajúci dostane null.
  Future<Position?> currentFix({
    LocationConfig config = const LocationConfig(),
    Duration maxAge = const Duration(seconds: 30),
  }) async {
    // Cache sa smie použiť len kým je čerstvá. V idle režime chodia fixy raz
    // za 15 s a s vypnutým streamom vôbec, takže bez kontroly veku by sa do
    // záznamu (fotka, núdzový kontakt) dostala poloha spred hodín.
    final known = _lastPosition;
    if (known != null &&
        DateTime.now().difference(known.timestamp.toLocal()) <= maxAge) {
      return known;
    }

    try {
      final fix = await _gps.getBest(config: config);
      if (fix != null) {
        _lastAndroidPosition = _fixToPosition(fix);
        _lastAndroidAt = DateTime.now();
        _lastAndroidSource = fix.source;
        _lastAndroidIsMocked = fix.isMocked;
        _reEvaluateSource();
        return _lastPosition ?? _lastAndroidPosition;
      }
    } catch (e) {
      debugPrint('[LOC] currentFix failed: $e');
    }

    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> _startAndroidStream(LocationConfig config) async {
    if (_androidSub != null) return;
    _activeStreamConfig = config;

    // Načítaj poslednú known position okamžite (bez čakania na live fix)
    try {
      final last = await _gps.getBest(
        config: const LocationConfig(
          quickFixTimeout: Duration.zero,
          preciseFixTimeout: Duration.zero,
        ),
      );
      if (last != null) {
        _lastAndroidPosition = _fixToPosition(last);
        _lastAndroidAt = DateTime.now();
        _lastAndroidSource = last.source;
        _lastAndroidIsMocked = last.isMocked;
        _reEvaluateSource();
      }
    } catch (_) {}

    // Spusti stream
    _androidSub = _gps.watch(config: config).listen((fix) {
      _lastAndroidPosition = _fixToPosition(fix);
      _lastAndroidAt = DateTime.now();
      _lastAndroidSource = fix.source;
      _lastAndroidIsMocked = fix.isMocked;
      _reEvaluateSource();
    }, onError: (e) => debugPrint('[LOC] Android GPS error: $e'));
  }

  Position _fixToPosition(LocationFix fix) => Position(
        latitude: fix.latitude,
        longitude: fix.longitude,
        timestamp: fix.timestamp,
        accuracy: fix.accuracyMeters,
        altitude: fix.altitudeMeters ?? 0,
        altitudeAccuracy: 0,
        heading: fix.headingDegrees ?? 0,
        headingAccuracy: 0,
        speed: fix.speedMps ?? 0,
        speedAccuracy: 0,
      );

  void _listenToNmea() {
    _raymarineSub = RaymarineConnectionService().dataStream
        .listen((_) => _reEvaluateSource());
    _udpSub = UdpReceiverService().dataStream
        .listen((_) => _reEvaluateSource());
  }

  /// Rozhodne, ktorý zdroj polohy je aktuálne najlepší, a ak treba,
  /// emituje nový Position do spoločného streamu.
  /// Priorita: TCP NMEA → UDP NMEA → Android GPS.
  void _reEvaluateSource() {
    final tcp = RaymarineConnectionService();
    final udp = UdpReceiverService();

    MarineInstrumentData? nmea;
    if (tcp.isConnected && _hasFreshNmeaFix(tcp.current)) {
      nmea = tcp.current;
    } else if (udp.isListening && _hasFreshNmeaFix(udp.current)) {
      nmea = udp.current;
    }
    final instrumentsInPlay = tcp.isConnected || udp.isListening;

    // Sleduj, ako dlho inštrumenty dodávajú fix bez prerušenia — po
    // _instrumentHandoverDelay sa GPS telefónu vypne úplne (pozri
    // _desiredProfile). Výpadok NMEA počítadlo hneď vynuluje a telefónové
    // GPS sa vráti.
    if (nmea != null) {
      _instrumentFixSince ??= DateTime.now();
    } else if (_instrumentFixSince != null) {
      _instrumentFixSince = null;
    }
    _applyProfile();
    _startFallbackTimer();

    if (nmea != null) {
      final pos = Position(
        latitude: nmea.latitude!,
        longitude: nmea.longitude!,
        timestamp: nmea.gpsTimestampUtc ?? DateTime.now(),
        accuracy: 0,
        altitude: _lastAndroidPosition?.altitude ?? 0,
        altitudeAccuracy: 0,
        heading: nmea.cogDegrees ?? nmea.headingDegrees ?? 0,
        headingAccuracy: 0,
        speed: (nmea.sogKnots ?? 0) / 1.94384,
        speedAccuracy: 0,
      );
      _usingRaymarine = true;
      _lastPosition = pos;
      _lastSource = LocationSource.gnss;
      _lastIsMocked = false;
      _emit(pos);
      return;
    }

    // Fallback na Android GPS — len kým je fix z telefónu ešte použiteľný.
    final android = _lastAndroidPosition;
    if (android == null) return;
    if (instrumentsInPlay && _androidFixStale) {
      // Inštrumenty na chvíľu stíchli a telefón nemá nič čerstvé. Radšej
      // nevydať nič než vydať zamrznutú polohu: posledná známa poloha
      // ostáva v _lastPosition a mapa aj tracking na nej počkajú.
      return;
    }
    _usingRaymarine = false;
    _lastPosition = android;
    _lastSource = _lastAndroidSource;
    _lastIsMocked = _lastAndroidIsMocked;
    _emit(android);
  }

  /// True, keď inštrumenty hlásili polohu naposledy dávnejšie než
  /// [_nmeaFixMaxAge] — vtedy sa ich fix už nesmie použiť.
  bool _hasFreshNmeaFix(MarineInstrumentData d) {
    if (!d.hasGpsFix) return false;
    final at = d.gpsLastUpdate;
    if (at == null) return false;
    return DateTime.now().difference(at) < _nmeaFixMaxAge;
  }

  bool get _androidFixStale {
    final at = _lastAndroidAt;
    return at == null ||
        DateTime.now().difference(at) >= _androidFixMaxAgeWithInstruments;
  }

  /// Do streamu pošle fix len ak je od posledného odoslaného skutočne iný —
  /// pozri komentár pri _lastEmittedPosition.
  void _emit(Position pos) {
    final last = _lastEmittedPosition;
    final same = last != null &&
        last.timestamp == pos.timestamp &&
        last.latitude == pos.latitude &&
        last.longitude == pos.longitude;
    if (same) return;
    _lastEmittedPosition = pos;
    _ctrl.add(pos);
  }

  void dispose() {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _androidSub?.cancel();
    _raymarineSub?.cancel();
    _udpSub?.cancel();
    _fallbackCheckTimer?.cancel();
    _ctrl.close();
  }
}
