/// Stav a zápis zameraní z námerového kompasu.
///
/// Dva režimy, dve odlišné pravidlá zoskupovania — podrobne v `BearingKind`:
///
/// * resekcia (hľadám seba) zbiera námery na rôzne ZNÁME body, takmer súčasne,
///   a dá jednu polohu — moju. GPS nepotrebuje.
/// * hľadanie objektu (reverzná triangulácia) zbiera námery na jeden NEZNÁMY
///   objekt z rôznych mojich polôh, zámerne s odstupom, a dá polohu objektu.
///   Takých pátraní môže bežať viac naraz, preto sa každé drží vo svojej
///   skupine.
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/bearing_kind.dart';
import '../../../core/services/gps_tracking_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/magnetic_declination.dart';
import '../../../main.dart';
import '../../map/providers/map_provider.dart' show waypointsProvider;
import '../services/bearing_geometry.dart';

/// Ako ďaleko sa čiara zamerania kreslí na mapu, v námorných míľach.
///
/// Zameranie samo o sebe vzdialenosť nedáva — je to polpriamka, ktorá musí
/// niekde skončiť. Desať míľ bolo stále primálo: maják na hranici
/// viditeľnosti z výšky je aj cez tridsať míľ ďaleko a čiara k nemu vôbec
/// nedosiahla, takže sa priesečník nedal ani odhadnúť okom.
///
/// Kužeľ neistoty sa kreslí po celej dĺžke, hoci na päťdesiatich míľach
/// narastie na vyše štrnásť míľ šírky. Je to nepekné, ale pravdivé: presne
/// taká je neistota ±8° na tú vzdialenosť a skracovať kužeľ by o nej klamalo.
const double kBearingLineLengthNm = 50;

/// Predvolená neistota telefónového kompasu na lodi (± stupňov).
///
/// Magnetometer v telefóne ruší všetko od kotvového reťazca po reproduktor
/// a rám kormidla. ±8° je opatrný, ale realistický odhad; presnejšie čísla
/// by predstierali kvalitu, ktorú meranie na palube nemá.
const double kDefaultBearingUncertaintyDeg = 8;

/// Časové okno, v ktorom námery na známe body patria k jednej resekcii.
///
/// Resekcia predpokladá, že loď medzi odčítaniami stojí. Pôvodných desať minút
/// bolo priveľa: pri 5 uzloch je to 0,8 NM, teda viac než chyba samotného
/// výsledku, takže by okno tichom pridávalo chybu, ktorú výpočet nevidí. Päť
/// minút je kompromis medzi tým a tempom, akým sa dá na palube odčítať tri
/// námery. Skutočný strážca pohybu je [kMinResectionDriftMeters] — čas je len
/// náhrada za pohyb, keď GPS chýba.
///
/// Na hľadanie neznámeho objektu sa toto okno zámerne NEPOUŽÍVA: tam je odstup
/// v čase to, čo vytvorí základnicu, bez ktorej sa priamky pretínajú pod
/// ostrým uhlom.
const Duration kResectionWindow = Duration(minutes: 5);

/// Ako ďaleko sa loď smie medzi námermi jednej resekcie posunúť (m).
///
/// Kontroluje sa len keď GPS beží — vtedy je zadarmo. Keď GPS nie je, ostáva
/// časové okno.
const double kMinResectionDriftMeters = 100;

/// Najkratšia základnica, pri ktorej má hľadanie objektu zmysel (m).
///
/// Dva námery z miesta pár metrov od seba dajú priamky takmer rovnobežné a
/// priesečník sa rozmaže na kilometre. Nie je to chyba výpočtu, len fyzika:
/// bez posunu lode niet z čoho triangulovať.
const double kMinBaselineMeters = 100;

const _uuid = Uuid();
const _distance = Distance();

/// Všetky uložené zamerania, najnovšie prvé. Sleduje databázu, takže nová
/// čiara sa objaví na mape hneď po uložení.
final bearingsProvider = StreamProvider<List<Bearing>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBearings();
});

/// Zamerania patriace k jednému dňu plavby — pre denník a PDF.
///
/// Sleduje [bearingsProvider], takže zmazanie zamerania z mapy sa prejaví aj
/// v dennom zázname bez ručného obnovovania.
final bearingsForDayProvider =
    FutureProvider.family<List<Bearing>, int>((ref, dayLogId) async {
  ref.watch(bearingsProvider);
  final db = ref.watch(databaseProvider);
  return db.getBearingsForDay(dayLogId);
});

// ── Resekcia: hľadám vlastnú polohu ─────────────────────────────────────

/// Námery na známe body, ktoré tvoria aktuálnu resekciu.
///
/// Okno sa počíta od NAJNOVŠIEHO námeru, nie od aktuálneho času: resekcia
/// spred týždňa je stále platný, vnútorne konzistentný záznam a má sa dať
/// prezrieť na mape. Z každého známeho bodu sa berie len ten najnovší námer —
/// druhé odčítanie toho istého majáka je oprava prvého, nie ďalšia priamka.
final resectionBearingsProvider = Provider<List<Bearing>>((ref) {
  final all = ref.watch(bearingsProvider).valueOrNull ?? const <Bearing>[];
  return latestResectionCluster(all);
});

/// Zhluk resekčných zameraní okolo najnovšieho, po jednom na každý zameraný
/// bod — logika [resectionBearingsProvider] vytiahnutá do funkcie, aby ju
/// vedel zavolať aj spätný pohľad na jeden deň (denník, PDF), kde vstupom
/// nie je celá databáza, ale len zamerania toho dňa.
List<Bearing> latestResectionCluster(List<Bearing> allBearings) {
  final resections = allBearings
      .where((b) => BearingKind.fromCode(b.kind) == BearingKind.resection)
      .toList()
    ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  if (resections.isEmpty) return const [];

  final newest = resections.first.takenAt;
  final inWindow = resections
      .where((b) => newest.difference(b.takenAt).abs() <= kResectionWindow);

  final newestPerTarget = <String, Bearing>{};
  for (final b in inWindow) {
    // `resections` je zoradené od najnovšieho, takže prvý zápis vyhráva.
    newestPerTarget.putIfAbsent(_targetKey(b), () => b);
  }
  return newestPerTarget.values.toList();
}

/// Kľúč zameraného známeho bodu — id waypointu, alebo jeho súradnice, keď bol
/// waypoint medzitým zmazaný a zostal len odpis.
String _targetKey(Bearing b) =>
    b.targetWaypointId?.toString() ??
    '${b.targetLat?.toStringAsFixed(5)},${b.targetLon?.toStringAsFixed(5)}';

/// Koľko RÔZNYCH známych bodov je v aktuálnej resekcii zameraných.
///
/// Dva námery na ten istý maják polohu nedajú, aj keby boli akokoľvek presné,
/// preto sa počítajú rozdielne body, nie riadky.
final resectionTargetCountProvider = Provider<int>(
    (ref) => ref.watch(resectionBearingsProvider).length);

/// Moja poloha vypočítaná z resekcie, alebo null, keď na ňu nie je dosť
/// námerov na rôzne známe body. **Nepotrebuje GPS** — to je celý zmysel.
final resectionFixProvider = Provider<BearingFix?>((ref) {
  final lines = ref
      .watch(resectionBearingsProvider)
      .map(bearingLineOf)
      .whereType<BearingLine>()
      .toList();
  if (lines.length < 2) return null;
  return BearingGeometry.fix(lines, kind: BearingKind.resection);
});

/// Ako ďaleko od GPS polohy leží resekčný fix, alebo null, keď jedno z nich
/// chýba.
///
/// Nie je to kontrola správnosti, je to kalibračná pomôcka: keď GPS beží,
/// tento rozdiel povie skiperovi, nakoľko sa dá jeho telefónovému kompasu
/// veriť, kým naň bude raz odkázaný.
final resectionOffGpsMetersProvider = Provider<double?>((ref) {
  final fix = ref.watch(resectionFixProvider);
  if (fix == null) return null;
  final gps = GpsTrackingService().lastPosition ??
      LocationService().lastPosition;
  if (gps == null) return null;
  return _distance.distance(
      fix.position, LatLng(gps.latitude, gps.longitude));
});

// ── Hľadanie neznámeho objektu (reverzná triangulácia) ──────────────────

/// Jedno pátranie po neznámom objekte: pomenovaný cieľ a námery na neho.
class SightGroup {
  final String id;

  /// Názov, ktorý objektu dal skiper ("neznáma skala").
  final String name;

  /// Námery na tento objekt, od najstaršieho.
  final List<Bearing> bearings;

  /// Vypočítaná poloha objektu, alebo null, kým na ňu nie je dosť námerov.
  final BearingFix? fix;

  /// Najväčšia vzdialenosť medzi polohami, z ktorých sa zameriavalo (m).
  ///
  /// Toto, nie čas, rozhoduje o kvalite: bez posunu lode niet základnice.
  final double baselineMeters;

  const SightGroup({
    required this.id,
    required this.name,
    required this.bearings,
    required this.fix,
    required this.baselineMeters,
  });

  /// Základnica je prikrátka na dôveryhodný výsledok — treba sa presunúť.
  bool get baselineTooShort => baselineMeters < kMinBaselineMeters;
}

/// Pátrania po neznámych objektoch, od naposledy zameraného.
///
/// Na rozdiel od resekcie tu žiadne časové okno nie je: námery s hodinovým
/// odstupom sú presne to, čo dá základnicu.
final sightGroupsProvider = Provider<List<SightGroup>>((ref) {
  final all = ref.watch(bearingsProvider).valueOrNull ?? const <Bearing>[];
  return sightGroupsFrom(all);
});

/// Zoskupí zamerania na neznáme objekty podľa [Bearing.sightGroupId] —
/// logika [sightGroupsProvider] vytiahnutá do funkcie, aby ju vedel zavolať
/// aj spätný pohľad na jeden deň, kde vstupom je len tá dňová podmnožina.
List<SightGroup> sightGroupsFrom(List<Bearing> allBearings) {
  final grouped = <String, List<Bearing>>{};
  for (final b in allBearings) {
    if (BearingKind.fromCode(b.kind) != BearingKind.intersection) continue;
    final groupId = b.sightGroupId;
    if (groupId == null) continue;
    grouped.putIfAbsent(groupId, () => []).add(b);
  }

  final groups = <SightGroup>[];
  for (final entry in grouped.entries) {
    final rows = entry.value..sort((a, b) => a.takenAt.compareTo(b.takenAt));
    final lines = rows.map(bearingLineOf).whereType<BearingLine>().toList();
    groups.add(SightGroup(
      id: entry.key,
      // Názov nesie každý riadok skupiny; ber ten najnovší, aby sa dal
      // opraviť preklep bez prepisovania starých riadkov.
      name: rows.last.label ?? '',
      bearings: rows,
      fix: lines.length < 2
          ? null
          : BearingGeometry.fix(lines, kind: BearingKind.intersection),
      baselineMeters: widestObserverSeparation(rows),
    ));
  }
  groups.sort(
      (a, b) => b.bearings.last.takenAt.compareTo(a.bearings.last.takenAt));
  return groups;
}

/// Najväčšia vzdialenosť medzi ktorýmikoľvek dvoma polohami pozorovateľa (m).
double widestObserverSeparation(List<Bearing> rows) {
  final points = <LatLng>[
    for (final b in rows)
      if (b.observerLat != null && b.observerLon != null)
        LatLng(b.observerLat!, b.observerLon!),
  ];
  var widest = 0.0;
  for (var i = 0; i < points.length; i++) {
    for (var j = i + 1; j < points.length; j++) {
      widest = math.max(widest, _distance.distance(points[i], points[j]));
    }
  }
  return widest;
}

/// Zámerná priamka pre daný riadok, alebo null, keď riadku chýba to, čo jeho
/// druh vyžaduje. (Databázový CHECK to nepustí, ale čítanie sa nemá spoliehať
/// na to, že zápis bol v poriadku.)
BearingLine? bearingLineOf(Bearing b) {
  final kind = BearingKind.fromCode(b.kind);
  if (kind == null) return null;

  final double? lat;
  final double? lon;
  switch (kind) {
    case BearingKind.resection:
      lat = b.targetLat;
      lon = b.targetLon;
    case BearingKind.intersection:
      lat = b.observerLat;
      lon = b.observerLon;
  }
  if (lat == null || lon == null) return null;

  return BearingGeometry.lineFor(
    kind: kind,
    knownPoint: LatLng(lat, lon),
    measuredTrueBearing: b.trueBearing,
    uncertaintyDeg: b.uncertaintyDeg,
    id: b.id,
  );
}

// ── Zamerania mimo plavby ────────────────────────────────────────────────

/// Zamerania jedného dňa zapísané BEZ aktívneho trackingu — deň a plavba sú
/// obe null (`BearingRepository._voyage()`), takže inak by boli viditeľné
/// len na mape a nikde inde. Skiper si na tomto zamerá aj bez toho, aby
/// stlačil Spustiť tracking — napríklad na kotve, keď si len chce overiť
/// polohu, alebo pri chôdzi po brehu.
class BearingSession {
  /// Kalendárny deň zameraní (lokálny čas zariadenia, nie UTC — merania sa
  /// robia v čase a mieste, kde skiper stojí).
  final DateTime date;

  /// Zamerania toho dňa, od najstaršieho.
  final List<Bearing> bearings;

  const BearingSession({required this.date, required this.bearings});
}

/// Zamerania mimo plavby, zoskupené po dňoch, od najnovšieho.
///
/// Deň, nie hodina či týždeň: rovnaká zrnitosť ako denníkový záznam, s
/// ktorým sa táto relácia zobrazuje bok po boku v zozname plavieb.
final orphanBearingSessionsProvider = Provider<List<BearingSession>>((ref) {
  final all = ref.watch(bearingsProvider).valueOrNull ?? const <Bearing>[];
  final orphans =
      all.where((b) => b.dayLogId == null && b.charterId == null);

  final byDate = <DateTime, List<Bearing>>{};
  for (final b in orphans) {
    final local = b.takenAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    byDate.putIfAbsent(day, () => []).add(b);
  }

  final sessions = byDate.entries
      .map((e) => BearingSession(
          date: e.key,
          bearings: e.value..sort((a, b) => a.takenAt.compareTo(b.takenAt))))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return sessions;
});

/// Zamerania z [orphanBearingSessionsProvider] pre presne jeden kalendárny
/// deň, alebo prázdny zoznam, keď sa medzitým zmazali.
final bearingSessionForDateProvider =
    Provider.family<BearingSession?, DateTime>((ref, date) {
  final sessions = ref.watch(orphanBearingSessionsProvider);
  for (final s in sessions) {
    if (s.date.year == date.year &&
        s.date.month == date.month &&
        s.date.day == date.day) {
      return s;
    }
  }
  return null;
});

// ── Voľba na obrazovke kompasu ──────────────────────────────────────────

/// Práve zvolený režim zameriavania.
///
/// Predvolene hľadanie objektu: je to režim bez podmienok, stačí GPS a jedno
/// ťuknutie. Resekcia bez vybraného bodu zapísať nič nemôže a obrazovka, ktorá
/// odmietne prvé ťuknutie, je zlé privítanie.
final bearingModeProvider =
    StateProvider<BearingKind>((ref) => BearingKind.intersection);

/// Zameriavaný známy bod pri resekcii — drží sa len id.
///
/// Zámerne rovnako ako `navTargetIdProvider`: keď waypoint zmizne, voľba sa má
/// vyprázdniť. Opačne než ULOŽENÉ zameranie, ktoré si nesie odpis polohy —
/// tam ide o archív merania, tu len o to, na čo práve mierim.
final resectionTargetIdProvider = StateProvider<int?>((ref) => null);

final resectionTargetProvider = Provider<Waypoint?>((ref) {
  final id = ref.watch(resectionTargetIdProvider);
  if (id == null) return null;
  final waypoints = ref.watch(waypointsProvider).valueOrNull;
  if (waypoints == null) return null;
  for (final w in waypoints) {
    if (w.id == id) return w;
  }
  return null;
});

/// Skupina, do ktorej padne ďalší námer na neznámy objekt.
final activeSightGroupIdProvider = StateProvider<String?>((ref) => null);

final activeSightGroupProvider = Provider<SightGroup?>((ref) {
  final id = ref.watch(activeSightGroupIdProvider);
  if (id == null) return null;
  for (final g in ref.watch(sightGroupsProvider)) {
    if (g.id == id) return g;
  }
  return null;
});

// ── Výsledok zápisu ─────────────────────────────────────────────────────

/// Rada k úspešnému zápisu — nie chyba, len to, čo treba urobiť inak, aby
/// z námerov nakoniec vyšla poloha.
enum BearingCaptureHint {
  /// Ten istý známy bod ako predtým; na resekciu treba ďalší, iný.
  sameTargetAsPrevious,

  /// Loď sa medzi námermi objektu neposunula dosť — priamky budú rovnobežné.
  shortBaseline,

  /// Loď sa medzi námermi resekcie posunula priveľa, aby to bol jeden fix.
  movedDuringResection,

  /// Deklinácia sa nevyhodnotila v polohe lode (nebola známa).
  declinationEstimated,

  /// Zatiaľ je len jeden použiteľný námer; poloha ešte nevyjde.
  needsSecondSight,
}

/// Spočítaný, ale ešte NEZAPÍSANÝ námer.
///
/// Existuje preto, aby sa skiper mohol na výsledok pozrieť skôr, než sa uloží.
/// Kurz je v ňom už zmrazený z okamihu ťuknutia, takže potvrdzovanie meranie
/// nijako nepokazí — čas, ktorý si skiper vezme na rozhodnutie, sa do čísla
/// nepremietne. Presne preto sa dá potvrdenie pridať zadarmo.
class BearingDraft {
  final BearingKind kind;
  final double magneticBearing;
  final double trueBearing;
  final double declination;
  final String declinationSource;
  final bool declinationTrustworthy;
  final double uncertaintyDeg;
  final DateTime takenAt;
  final Set<BearingCaptureHint> hints;

  /// Poloha pozorovateľa, ak bola známa. Pri resekcii bez GPS je null.
  final double? observerLat;
  final double? observerLon;
  final double? accuracyMeters;

  /// Zameraný známy bod (resekcia).
  final int? targetWaypointId;
  final double? targetLat;
  final double? targetLon;
  final String? targetName;

  /// Pátranie po neznámom objekte (intersection).
  final String? sightGroupId;
  final String? label;

  /// Fotka už presunutá do trvalého adresára. Pri zahodení sa musí zmazať,
  /// inak by po zrušených námeroch zostávali osirotené súbory.
  final String? photoPath;

  const BearingDraft({
    required this.kind,
    required this.magneticBearing,
    required this.trueBearing,
    required this.declination,
    required this.declinationSource,
    required this.declinationTrustworthy,
    required this.uncertaintyDeg,
    required this.takenAt,
    required this.hints,
    this.observerLat,
    this.observerLon,
    this.accuracyMeters,
    this.targetWaypointId,
    this.targetLat,
    this.targetLon,
    this.targetName,
    this.sightGroupId,
    this.label,
    this.photoPath,
  });
}

/// Výsledok pokusu o zameranie — buď riadok, alebo dôvod, prečo nie.
sealed class BearingCaptureResult {
  const BearingCaptureResult();
}

/// Námer je spočítaný a čaká na potvrdenie.
class BearingPrepared extends BearingCaptureResult {
  final BearingDraft draft;
  const BearingPrepared(this.draft);
}

class BearingCaptured extends BearingCaptureResult {
  final int id;
  final BearingKind kind;
  final double trueBearing;
  final double declination;

  /// Odkiaľ bola poloha na výpočet deklinácie: `gps`, `target`, `lastKnown`.
  final String declinationSource;

  /// False, keď dátum leží mimo platnosti WMM koeficientov a deklinácia je
  /// už len extrapolácia.
  final bool declinationTrustworthy;

  /// Skupina, do ktorej námer padol (len pri hľadaní objektu).
  final String? sightGroupId;

  final Set<BearingCaptureHint> hints;

  const BearingCaptured({
    required this.id,
    required this.kind,
    required this.trueBearing,
    required this.declination,
    required this.declinationSource,
    required this.declinationTrustworthy,
    this.sightGroupId,
    this.hints = const {},
  });
}

/// Hľadanie neznámeho objektu bez známej polohy pozorovateľa.
///
/// Nie je to obíditeľné: priamka musí začínať v známej polohe, a tá pri tomto
/// režime môže prísť jedine z GPS. Používateľa treba odkázať na resekciu.
class BearingNeedsObserverPosition extends BearingCaptureResult {
  const BearingNeedsObserverPosition();
}

/// Resekcia bez vybraného známeho bodu — nevedno, čo bolo zamerané.
class BearingNeedsTarget extends BearingCaptureResult {
  const BearingNeedsTarget();
}

/// Hľadanie objektu bez skupiny ani názvu — nevedno, k čomu námer patrí.
class BearingNeedsObject extends BearingCaptureResult {
  const BearingNeedsObject();
}

class BearingCaptureFailed extends BearingCaptureResult {
  final Object error;
  const BearingCaptureFailed(this.error);
}

// ── Zápis ───────────────────────────────────────────────────────────────

/// Poloha, na ktorej sa vyhodnotila deklinácia, a odkiaľ je.
class _DeclinationOrigin {
  final double lat;
  final double lon;

  /// `gps`, `target` alebo `lastKnown`.
  final String source;
  const _DeclinationOrigin(this.lat, this.lon, this.source);
}

/// Zápis zameraní: poloha, oprava o deklináciu, fotka, riadok v databáze.
///
/// Poloha a čas prichádzajú cez [positionSource] a [clock], nie priamo zo
/// singletonov: pôvodná verzia si ich brala sama, a preto sa `capture()`
/// nedalo otestovať vôbec — testy obchádzali repozitár a vkládali riadky
/// ručne, takže celá logika okolo deklinácie a chybových stavov bola nekrytá.
class BearingRepository {
  final AppDatabase _db;
  final Position? Function() _positionSource;
  final DateTime Function() _clock;

  BearingRepository(
    this._db, {
    Position? Function()? positionSource,
    DateTime Function()? clock,
  })  : _positionSource = positionSource ?? _lastKnownPosition,
        _clock = clock ?? DateTime.now;

  /// Naposledy známa poloha, bez aktívneho čakania na fix.
  ///
  /// Zámerne sa NEvolá `LocationService().currentFix()`: to si polohu vyžiada
  /// a čaká. Resekcia GPS nepotrebuje vôbec a pri hľadaní objektu je
  /// dôležitejšie zapísať kurz v okamihu ťuknutia než sekundy čakať na fix.
  static Position? _lastKnownPosition() =>
      GpsTrackingService().lastPosition ?? LocationService().lastPosition;

  /// Spočíta námer na ZNÁMY bod — hľadá sa vlastná poloha. GPS netreba.
  ///
  /// Do databázy zatiaľ nezapisuje; vracia [BearingPrepared] na potvrdenie.
  Future<BearingCaptureResult> prepareResection({
    required double magneticBearing,
    required Waypoint? target,
    String? photoPath,
    String? note,
    double uncertaintyDeg = kDefaultBearingUncertaintyDeg,
    DateTime? takenAt,
  }) async {
    if (target == null) return const BearingNeedsTarget();
    try {
      final when = takenAt ?? _clock();
      final position = _positionSource();

      // Poloha slúži len na vyhodnotenie deklinácie, nie ako začiatok
      // priamky — tou je zameraný waypoint. Preto sa dá bez problémov
      // nahradiť polohou toho waypointu: na pár míľ sa deklinácia zmení
      // o desatiny stupňa, kým samotný kužeľ je ±8°.
      final origin = position != null
          ? _DeclinationOrigin(position.latitude, position.longitude, 'gps')
          : _DeclinationOrigin(target.latitude, target.longitude, 'target');

      final field = MagneticDeclination.fieldAt(
        latitude: origin.lat,
        longitude: origin.lon,
        date: when,
      );
      final trueBearing =
          trueFromMagnetic(magneticBearing, field.declination);
      final storedPhoto =
          photoPath == null ? null : await _persistPhoto(photoPath);
      final hints = await _resectionHints(target, position, when);

      return BearingPrepared(BearingDraft(
        kind: BearingKind.resection,
        magneticBearing: magneticBearing,
        trueBearing: trueBearing,
        declination: field.declination,
        declinationSource: origin.source,
        declinationTrustworthy: field.withinValidity,
        uncertaintyDeg: uncertaintyDeg,
        takenAt: when,
        hints: hints,
        observerLat: position?.latitude,
        observerLon: position?.longitude,
        accuracyMeters: position?.accuracy,
        targetWaypointId: target.id,
        targetLat: target.latitude,
        targetLon: target.longitude,
        targetName: target.name,
        label: note,
        photoPath: storedPhoto,
      ));
    } catch (e) {
      return BearingCaptureFailed(e);
    }
  }

  /// Námer na NEZNÁMY objekt zo známej polohy — hľadá sa ten objekt.
  ///
  /// [sightGroupId] null zakladá nové pátranie (vtedy je [objectName]
  /// povinný), inak sa námer pridá k existujúcemu.
  Future<BearingCaptureResult> prepareIntersection({
    required double magneticBearing,
    String? sightGroupId,
    String? objectName,
    String? photoPath,
    double uncertaintyDeg = kDefaultBearingUncertaintyDeg,
    DateTime? takenAt,
  }) async {
    if (sightGroupId == null && (objectName == null || objectName.isEmpty)) {
      return const BearingNeedsObject();
    }
    // Bez známej polohy pozorovateľa tento režim principiálne nefunguje —
    // priamka by nemala odkiaľ vychádzať.
    final position = _positionSource();
    if (position == null) return const BearingNeedsObserverPosition();

    try {
      final when = takenAt ?? _clock();
      final field = MagneticDeclination.fieldAt(
        latitude: position.latitude,
        longitude: position.longitude,
        date: when,
      );
      final trueBearing =
          trueFromMagnetic(magneticBearing, field.declination);
      final storedPhoto =
          photoPath == null ? null : await _persistPhoto(photoPath);
      final groupId = sightGroupId ?? _uuid.v4();
      final existing = sightGroupId == null
          ? const <Bearing>[]
          : await _db.getBearingsInGroup(sightGroupId);
      final name = objectName ??
          (existing.isEmpty ? null : existing.last.label) ??
          '';

      return BearingPrepared(BearingDraft(
        kind: BearingKind.intersection,
        magneticBearing: magneticBearing,
        trueBearing: trueBearing,
        declination: field.declination,
        declinationSource: 'gps',
        declinationTrustworthy: field.withinValidity,
        uncertaintyDeg: uncertaintyDeg,
        takenAt: when,
        hints: _intersectionHints(existing, position),
        observerLat: position.latitude,
        observerLon: position.longitude,
        accuracyMeters: position.accuracy,
        sightGroupId: groupId,
        label: name,
        photoPath: storedPhoto,
      ));
    } catch (e) {
      return BearingCaptureFailed(e);
    }
  }

  /// Zapíše potvrdený námer.
  Future<BearingCaptureResult> commit(BearingDraft draft) async {
    try {
      final voyage = await _voyage();
      final id = await _db.insertBearing(BearingsCompanion.insert(
        kind: draft.kind.code,
        magneticBearing: draft.magneticBearing,
        declination: draft.declination,
        declinationSource: Value(draft.declinationSource),
        trueBearing: draft.trueBearing,
        uncertaintyDeg: Value(draft.uncertaintyDeg),
        observerLat: Value(draft.observerLat),
        observerLon: Value(draft.observerLon),
        accuracyMeters: Value(draft.accuracyMeters),
        targetWaypointId: Value(draft.targetWaypointId),
        targetLat: Value(draft.targetLat),
        targetLon: Value(draft.targetLon),
        targetName: Value(draft.targetName),
        sightGroupId: Value(draft.sightGroupId),
        label: Value(draft.label),
        photoPath: Value(draft.photoPath),
        takenAt: draft.takenAt,
        dayLogId: Value(voyage.dayLogId),
        charterId: Value(voyage.charterId),
      ));

      return BearingCaptured(
        id: id,
        kind: draft.kind,
        trueBearing: draft.trueBearing,
        declination: draft.declination,
        declinationSource: draft.declinationSource,
        declinationTrustworthy: draft.declinationTrustworthy,
        sightGroupId: draft.sightGroupId,
        hints: draft.hints,
      );
    } catch (e) {
      return BearingCaptureFailed(e);
    }
  }

  /// Zahodí nepotvrdený námer aj s odloženou fotkou.
  ///
  /// Bez tohto by po každom zrušenom zameraní zostal v adresári obrázok,
  /// na ktorý sa už nikto neodkazuje.
  Future<void> discardDraft(BearingDraft draft) async {
    final path = draft.photoPath;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Osirotená fotka je nepríjemnosť, nie dôvod hlásiť chybu.
    }
  }

  /// Rady k práve zapísanému resekčnému námeru.
  Future<Set<BearingCaptureHint>> _resectionHints(
      Waypoint target, Position? position, DateTime when) async {
    final hints = <BearingCaptureHint>{};
    if (position == null) hints.add(BearingCaptureHint.declinationEstimated);

    final recent = (await _db.getAllBearings())
        .where((b) => BearingKind.fromCode(b.kind) == BearingKind.resection)
        .where((b) => when.difference(b.takenAt).abs() <= kResectionWindow)
        .toList();

    if (recent.any((b) => b.targetWaypointId == target.id)) {
      // Nie je to chyba — prekontrolovať roztrasené odčítanie je správne
      // námorníctvo. Ale ďalšia priamka z toho nevznikne.
      hints.add(BearingCaptureHint.sameTargetAsPrevious);
    }

    final distinctTargets = {
      target.id.toString(),
      ...recent.map(_targetKey),
    }.length;
    if (distinctTargets < 2) hints.add(BearingCaptureHint.needsSecondSight);

    if (position != null) {
      final drifted = recent
          .where((b) => b.observerLat != null && b.observerLon != null)
          .map((b) => _distance.distance(
              LatLng(b.observerLat!, b.observerLon!),
              LatLng(position.latitude, position.longitude)))
          .fold<double>(0, math.max);
      if (drifted > kMinResectionDriftMeters) {
        hints.add(BearingCaptureHint.movedDuringResection);
      }
    }
    return hints;
  }

  Set<BearingCaptureHint> _intersectionHints(
      List<Bearing> existing, Position position) {
    final hints = <BearingCaptureHint>{};
    if (existing.isEmpty) {
      hints.add(BearingCaptureHint.needsSecondSight);
      return hints;
    }
    final here = LatLng(position.latitude, position.longitude);
    final widest = existing
        .where((b) => b.observerLat != null && b.observerLon != null)
        .map((b) => _distance.distance(
            LatLng(b.observerLat!, b.observerLon!), here))
        .fold<double>(0, math.max);
    if (widest < kMinBaselineMeters) {
      hints.add(BearingCaptureHint.shortBaseline);
    }
    return hints;
  }

  /// Uloží vytriangulovaný objekt ako waypoint.
  ///
  /// Námery sa zámerne nemažú: sú záznamom merania, ktoré sa naozaj stalo, a
  /// idú do PDF. Vyčistiť mapu je samostatné, vedomé rozhodnutie.
  Future<int> saveFixAsWaypoint({
    required String name,
    required LatLng position,
    String? description,
  }) =>
      _db.insertWaypoint(WaypointsCompanion.insert(
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
        description: Value(description),
        type: const Value('bearing_fix'),
        createdAt: _clock(),
      ));

  Future<({int? dayLogId, int? charterId})> _voyage() async {
    final dayLogId = GpsTrackingService().activeDayLogId;
    final charterId = dayLogId == null
        ? null
        : (await _db.getDayLogById(dayLogId))?.charterId;
    return (dayLogId: dayLogId, charterId: charterId);
  }

  /// Presunie fotku z dočasného úložiska kamery do adresára appky.
  Future<String?> _persistPhoto(String tempPath) async {
    try {
      final source = File(tempPath);
      if (!await source.exists()) return null;
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/bearing_photos');
      await dir.create(recursive: true);
      final target = File(
          '${dir.path}/bearing_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await source.copy(target.path);
      return target.path;
    } catch (_) {
      // Fotka je doplnok, nie podstata zamerania — keď sa nepodarí uložiť,
      // riadok aj tak vznikne.
      return null;
    }
  }

  Future<void> delete(int id) => _db.deleteBearing(id);

  Future<void> deleteGroup(String sightGroupId) =>
      _db.deleteBearingGroup(sightGroupId);

  Future<void> clearAll() => _db.deleteAllBearings();

  Future<void> rename(int id, String? label) =>
      _db.updateBearingLabel(id, label?.trim().isEmpty ?? true ? null : label);
}

final bearingRepositoryProvider = Provider<BearingRepository>(
    (ref) => BearingRepository(ref.watch(databaseProvider)));
