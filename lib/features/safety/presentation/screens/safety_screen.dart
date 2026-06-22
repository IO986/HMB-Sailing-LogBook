import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/emergency_contacts.dart';
import 'safety_briefing_screen.dart';
import 'mayday_card_screen.dart';
import 'gear_list_screen.dart';
import 'yacht_handover_screen.dart';
import 'colreg_screen.dart';
import '../../../../core/services/gps_tracking_service.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/services/location_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';

// ── Emergency region provider ─────────────────────────────────

final emergencyRegionProvider = FutureProvider<EmergencyRegion?>((ref) async {
  final pos = GpsTrackingService().lastPosition;
  if (pos != null) {
    return EmergencyContacts.getRegionForLocation(pos.latitude, pos.longitude);
  }
  // Skús získať polohu priamo
  try {
    final p = await Geolocator.getLastKnownPosition();
    if (p != null) {
      return EmergencyContacts.getRegionForLocation(p.latitude, p.longitude);
    }
  } catch (_) {}
  return null;
});

// ── MOB ───────────────────────────────────────────────────────

class MobState {
  final bool isActive;
  final double? mobLat, mobLon;
  final DateTime? activatedAt;
  final double? distanceM, bearingDeg;
  const MobState({this.isActive = false, this.mobLat, this.mobLon,
      this.activatedAt, this.distanceM, this.bearingDeg});
  MobState copyWith({bool? isActive, double? mobLat, double? mobLon,
      DateTime? activatedAt, double? distanceM, double? bearingDeg}) =>
      MobState(isActive: isActive ?? this.isActive,
          mobLat: mobLat ?? this.mobLat, mobLon: mobLon ?? this.mobLon,
          activatedAt: activatedAt ?? this.activatedAt,
          distanceM: distanceM, bearingDeg: bearingDeg);
}

class MobNotifier extends Notifier<MobState> {
  StreamSubscription<Position>? _sub;
  @override
  MobState build() => const MobState();

  Future<void> activate(double lat, double lon) async {
    state = MobState(isActive: true, mobLat: lat, mobLon: lon, activatedAt: DateTime.now());
    try {
      final db = ref.read(databaseProvider);
      final session = await db.getActiveSession();
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: drift.Value(GpsTrackingService().activeDayLogId),
        sessionId: drift.Value(session?.sessionId),
        timestamp: DateTime.now(),
        latitude: drift.Value(lat),
        longitude: drift.Value(lon),
        skipperNote: const drift.Value('Človek cez palubu'),
        isAutoEntry: const drift.Value(true),
      ));
      print('[MOB] Logged MOB activation');
    } catch (e) { print('[MOB] Log error: $e'); }
    _sub = (GpsTrackingService().isTracking
        ? GpsTrackingService().positionStream
        : LocationService().stream).listen((pos) {
      state = state.copyWith(
        distanceM: _haversine(lat, lon, pos.latitude, pos.longitude),
        bearingDeg: _bearing(pos.latitude, pos.longitude, lat, lon),
      );
    });
  }

  void deactivate() { _sub?.cancel(); state = const MobState(); }

  double _haversine(double la1, double lo1, double la2, double lo2) {
    const r = 6371000.0;
    final dLat = _r(la2 - la1), dLon = _r(lo2 - lo1);
    final a = sin(dLat/2)*sin(dLat/2) +
        cos(_r(la1))*cos(_r(la2))*sin(dLon/2)*sin(dLon/2);
    return r * 2 * atan2(sqrt(a), sqrt(1-a));
  }

  double _bearing(double la1, double lo1, double la2, double lo2) {
    final dLon = _r(lo2 - lo1);
    final y = sin(dLon)*cos(_r(la2));
    final x = cos(_r(la1))*sin(_r(la2)) - sin(_r(la1))*cos(_r(la2))*cos(dLon);
    return (_d(atan2(y, x)) + 360) % 360;
  }

  double _r(double d) => d * pi / 180;
  double _d(double r) => r * 180 / pi;
}

final mobProvider = NotifierProvider<MobNotifier, MobState>(MobNotifier.new);

// ── Anchor Alarm ──────────────────────────────────────────────

class AnchorState {
  final bool isActive;
  final double? anchorLat, anchorLon;
  final double radiusMeters;
  final double? currentDistanceM;
  final bool isDrifting;
  final List<LatLng> trackPoints;
  const AnchorState({this.isActive = false, this.anchorLat, this.anchorLon,
      this.radiusMeters = 50, this.currentDistanceM, this.isDrifting = false,
      this.trackPoints = const []});
  AnchorState copyWith({bool? isActive, double? anchorLat, double? anchorLon,
      double? radiusMeters, double? currentDistanceM, bool? isDrifting,
      List<LatLng>? trackPoints}) =>
      AnchorState(isActive: isActive ?? this.isActive,
          anchorLat: anchorLat ?? this.anchorLat, anchorLon: anchorLon ?? this.anchorLon,
          radiusMeters: radiusMeters ?? this.radiusMeters,
          currentDistanceM: currentDistanceM, isDrifting: isDrifting ?? this.isDrifting,
          trackPoints: trackPoints ?? this.trackPoints);
}

class AnchorNotifier extends Notifier<AnchorState> {
  StreamSubscription<Position>? _sub;
  @override
  AnchorState build() => const AnchorState();

  Future<void> activate(double lat, double lon, double radius) async {
    state = state.copyWith(
      isActive: true, anchorLat: lat, anchorLon: lon,
      radiusMeters: radius, trackPoints: [],
    );

    try {
      final db = ref.read(databaseProvider);
      final activeSession = await db.getActiveSession();
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: drift.Value(GpsTrackingService().activeDayLogId),
        sessionId: drift.Value(activeSession?.sessionId),
        timestamp: DateTime.now(),
        latitude: drift.Value(lat),
        longitude: drift.Value(lon),
        skipperNote: const drift.Value('Kotva spustená'),
        isAutoEntry: const drift.Value(true),
      ));
      print('[ANCHOR] Logged anchor drop');
    } catch (e) { print('[ANCHOR] Log error: $e'); }

    _sub = LocationService().stream.listen((pos) {
      final dist = _haversine(lat, lon, pos.latitude, pos.longitude);
      final pts = [...state.trackPoints, LatLng(pos.latitude, pos.longitude)];
      // Max 500 bodov
      if (pts.length > 500) pts.removeAt(0);
      final wasDrifting = state.isDrifting;
      final nowDrifting = dist > state.radiusMeters;
      state = state.copyWith(
        currentDistanceM: dist,
        isDrifting: nowDrifting,
        trackPoints: pts,
      );
      // Zápis pri začiatku/konci driftu
      if (!wasDrifting && nowDrifting) {
        _logDrift(pos, 'Drift - prekročený perimeter!');
      } else if (wasDrifting && !nowDrifting) {
        _logDrift(pos, 'Drift - loď späť v perimetri');
      }
    });
  }

  Future<void> _logDrift(Position pos, String note) async {
    try {
      final db = ref.read(databaseProvider);
      final session = await db.getActiveSession();
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: drift.Value(GpsTrackingService().activeDayLogId),
        sessionId: drift.Value(session?.sessionId),
        timestamp: DateTime.now(),
        latitude: drift.Value(pos.latitude),
        longitude: drift.Value(pos.longitude),
        skipperNote: drift.Value(note),
        isAutoEntry: const drift.Value(true),
      ));
    } catch (e) { print('[ANCHOR] Drift log error: $e'); }
  }

  Future<void> deactivate() async {
    if (state.isActive) {
      try {
        final db = ref.read(databaseProvider);
        final pos = LocationService().lastPosition;
        final session = await db.getActiveSession();
        await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
          dayLogId: drift.Value(GpsTrackingService().activeDayLogId),
          sessionId: drift.Value(session?.sessionId),
          timestamp: DateTime.now(),
          latitude: drift.Value(pos?.latitude),
          longitude: drift.Value(pos?.longitude),
          skipperNote: const drift.Value('Kotva zdvihnutá'),
          isAutoEntry: const drift.Value(true),
        ));
      } catch (_) {}
    }
    _sub?.cancel();
    state = const AnchorState();
  }

  double _haversine(double la1, double lo1, double la2, double lo2) {
    const r = 6371000.0;
    final dLat = (la2-la1)*pi/180, dLon = (lo2-lo1)*pi/180;
    final a = sin(dLat/2)*sin(dLat/2) +
        cos(la1*pi/180)*cos(la2*pi/180)*sin(dLon/2)*sin(dLon/2);
    return r * 2 * atan2(sqrt(a), sqrt(1-a));
  }
}

final anchorProvider = NotifierProvider<AnchorNotifier, AnchorState>(AnchorNotifier.new);

// ── Safety Screen ─────────────────────────────────────────────

class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bezpečnosť')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MobSection(),
          const SizedBox(height: 16),
          _AnchorCard(),
          const SizedBox(height: 16),
          const _SafetyBriefingCard(),
          const SizedBox(height: 16),
          const _CharterCheckCard(),
          const SizedBox(height: 16),
          const _HmbHandbookCard(),
          const SizedBox(height: 16),
          const _EmergencyCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── MOB ───────────────────────────────────────────────────────

class _MobSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mob = ref.watch(mobProvider);
    return mob.isActive ? _MobActiveCard(state: mob) : _MobButton();
  }
}

class _MobButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () {
        final pos = GpsTrackingService().lastPosition;
        if (pos == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('GPS pozícia nie je dostupná!'),
              backgroundColor: Colors.red));
          return;
        }
        ref.read(mobProvider.notifier).activate(pos.latitude, pos.longitude);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)],
        ),
        child: const Column(children: [
          Icon(Icons.person_off, color: Colors.white, size: 48),
          SizedBox(height: 8),
          Text('MOB', style: TextStyle(color: Colors.white, fontSize: 32,
              fontWeight: FontWeight.bold, letterSpacing: 4)),
          Text('Man Overboard', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          Text('Podržte pre aktiváciu', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _MobActiveCard extends ConsumerWidget {
  final MobState state;
  const _MobActiveCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = state.activatedAt != null
        ? DateTime.now().difference(state.activatedAt!) : Duration.zero;
    final et = '${elapsed.inMinutes.toString().padLeft(2,'0')}:'
               '${(elapsed.inSeconds%60).toString().padLeft(2,'0')}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Text('⚠️ MOB AKTÍVNY',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _MobStat('Čas', et, Icons.timer),
          _MobStat('Vzdialenosť',
              state.distanceM != null ? '${state.distanceM!.toStringAsFixed(0)} m' : '-',
              Icons.straighten),
          _MobStat('Smer',
              state.bearingDeg != null ? '${state.bearingDeg!.toStringAsFixed(0)}°' : '-',
              Icons.navigation),
        ]),
        if (state.mobLat != null) ...[
          const SizedBox(height: 8),
          Text('${state.mobLat!.toStringAsFixed(5)}°N  ${state.mobLon!.toStringAsFixed(5)}°E',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black),
            onPressed: () => context.go('/map?mob_lat=${state.mobLat}&mob_lon=${state.mobLon}'),
            icon: const Icon(Icons.navigation), label: const Text('Naviguj k MOB'),
          )),
          const SizedBox(width: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white30)),
            onPressed: () => ref.read(mobProvider.notifier).deactivate(),
            child: const Text('Zrušiť'),
          ),
        ]),
      ]),
    );
  }
}

class _MobStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _MobStat(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: Colors.white70, size: 20),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
  ]);
}

// ── Anchor Alarm ──────────────────────────────────────────────

class _AnchorCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AnchorCard> createState() => _AnchorCardState();
}

class _AnchorCardState extends ConsumerState<_AnchorCard> {
  double _radius = 15.0;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(anchorProvider);
    return Card(
      color: s.isDrifting ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.anchor, color: s.isDrifting ? Colors.red : null),
            const SizedBox(width: 8),
            Text('Anchor Alarm', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (s.isDrifting)
              const Chip(label: Text('DRIFTUJE', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red),
          ]),
          if (s.isActive && s.currentDistanceM != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (s.currentDistanceM! / s.radiusMeters).clamp(0, 1.2),
              color: s.isDrifting ? Colors.red : Colors.green,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 4),
            Text('${s.currentDistanceM!.toStringAsFixed(0)} m / ${s.radiusMeters.toStringAsFixed(0)} m',
                style: TextStyle(color: s.isDrifting ? Colors.red : Colors.green)),
          ],
          if (!s.isActive) ...[
            const SizedBox(height: 8),
            Text('Polomer: ${_radius.toStringAsFixed(0)} m'),
            Slider(value: _radius, min: 5, max: 30, divisions: 25,
                label: '${_radius.toStringAsFixed(0)} m',
                onChanged: (v) => setState(() => _radius = v)),
          ],
          const SizedBox(height: 8),
          SizedBox(width: double.infinity,
            child: s.isActive
              ? OutlinedButton.icon(
                  onPressed: () => ref.read(anchorProvider.notifier).deactivate(),
                  icon: const Icon(Icons.stop), label: const Text('Vypnúť'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red))
              : ElevatedButton.icon(
                  onPressed: () {
                    final pos = GpsTrackingService().lastPosition;
                    if (pos == null) return;
                    ref.read(anchorProvider.notifier).activate(pos.latitude, pos.longitude, _radius);
                  },
                  icon: const Icon(Icons.anchor), label: const Text('Aktivovať anchor alarm')),
          ),
        ]),
      ),
    );
  }
}

// ── Safety Briefing ───────────────────────────────────────────

class _SafetyBriefingCard extends StatefulWidget {
  const _SafetyBriefingCard();
  @override
  State<_SafetyBriefingCard> createState() => _SafetyBriefingCardState();
}

class _SafetyBriefingCardState extends State<_SafetyBriefingCard> {
  final _items = {
    'Záchranné vesty – umiestnenie a použitie': false,
    'Záchranný kruh a MOB postup': false,
    'Svetlice – typy a použitie': false,
    'EPIRB / PLB – aktivácia': false,
    'VHF rádio – kanál 16, Mayday postup': false,
    'Hasiaci prístroj – umiestnenie a použitie': false,
    'Lekárnička – umiestnenie': false,
    'Núdzové vypnutie motora': false,
    'Úniky – voda, plyn': false,
    'Kotva a reťaz – postup kotvenia': false,
    'Pravidlá na palube': false,
    'Núdzové kontakty a VHF 16': false,
  };
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final checked = _items.values.where((v) => v).length;
    final total = _items.length;
    final allDone = checked == total;
    return Card(
      color: allDone ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(children: [
              Icon(Icons.checklist, color: allDone ? Colors.green : null),
              const SizedBox(width: 8),
              Expanded(child: Text('Safety Briefing',
                  style: Theme.of(context).textTheme.titleMedium)),
              Text('$checked/$total', style: TextStyle(
                  color: allDone ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ]),
          ),
          if (allDone)
            const Padding(padding: EdgeInsets.only(top: 8),
              child: Row(children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('Briefing dokončený', style: TextStyle(color: Colors.green)),
              ])),
          if (_expanded) ...[
            const Divider(),
            ..._items.entries.map((e) => CheckboxListTile(
              title: Text(e.key, style: const TextStyle(fontSize: 14)),
              value: e.value, dense: true, contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _items[e.key] = v ?? false),
            )),
          ],
        ]),
      ),
    );
  }
}

// ── Charter Check ─────────────────────────────────────────────

class _CharterCheckCard extends StatefulWidget {
  const _CharterCheckCard();
  @override
  State<_CharterCheckCard> createState() => _CharterCheckCardState();
}

class _CharterCheckCardState extends State<_CharterCheckCard> {
  final _checkIn = {
    'Doklady lode (registrácia, poistenie)': false,
    'Záchranné vybavenie – komplet': false,
    'Zásoby paliva': false, 'Zásoby vody': false,
    'Kotva a reťaz – kontrola': false,
    'Motor – skúšobná prevádzka': false,
    'Navigačné prístroje': false, 'Lezenie – lana a plachty': false,
    'Kuchyňa – plyn, sporák': false, 'WC – funkčnosť': false,
    'Existujúce poškodenia – fotodokumentácia': false,
  };
  final _checkOut = {
    'Loď vyčistená – exteriér': false, 'Loď vyčistená – interiér': false,
    'Palivo doplnené': false, 'Voda doplnená': false,
    'Odpadky odstránené': false, 'Poškodenia hlásené': false,
    'Kľúče odovzdané': false,
  };
  bool _inExp = false, _outExp = false;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Charter', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _CheckSection(title: 'Check-in (prevzatie lode)', icon: Icons.login,
            items: _checkIn, expanded: _inExp,
            onToggle: () => setState(() => _inExp = !_inExp),
            onChanged: (k, v) => setState(() => _checkIn[k] = v)),
        const SizedBox(height: 8),
        _CheckSection(title: 'Check-out (odovzdanie lode)', icon: Icons.logout,
            items: _checkOut, expanded: _outExp,
            onToggle: () => setState(() => _outExp = !_outExp),
            onChanged: (k, v) => setState(() => _checkOut[k] = v)),
      ]),
    ),
  );
}

class _CheckSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, bool> items;
  final bool expanded;
  final VoidCallback onToggle;
  final Function(String, bool) onChanged;
  const _CheckSection({required this.title, required this.icon, required this.items,
      required this.expanded, required this.onToggle, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final checked = items.values.where((v) => v).length;
    final total = items.length;
    final allDone = checked == total;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: allDone ? Colors.green.shade300 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Icon(icon, size: 20, color: allDone ? Colors.green : null),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
              Text('$checked/$total', style: TextStyle(
                  color: allDone ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 20),
            ]),
          ),
        ),
        if (expanded)
          ...items.entries.map((e) => CheckboxListTile(
            title: Text(e.key, style: const TextStyle(fontSize: 13)),
            value: e.value, dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            onChanged: (v) => onChanged(e.key, v ?? false),
          )),
      ]),
    );
  }
}

// ── Emergency Contacts ────────────────────────────────────────

class _EmergencyCard extends ConsumerWidget {
  const _EmergencyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionAsync = ref.watch(emergencyRegionProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.sos, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text('Tiesňové kontakty',
                style: Theme.of(context).textTheme.titleMedium)),
            // Refresh tlačidlo
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Aktualizovať podľa polohy',
              onPressed: () => ref.invalidate(emergencyRegionProvider),
            ),
          ]),

          // Aktuálna oblasť
          regionAsync.when(
            data: (region) => region != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Text('${region.flag} ${region.country}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const Text(' · ', style: TextStyle(color: Colors.grey)),
                    const Text('detekované podľa GPS',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                )
              : const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('📍 Poloha nedostupná – zobrazené globálne kontakty',
                      style: TextStyle(fontSize: 12, color: Colors.grey))),
            loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Zisťujem polohu...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ])),
            error: (_, __) => const SizedBox(),
          ),

          const Text('Klepni pre zavolanie',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),

          // Univerzálne kontakty
          ...EmergencyContacts.universal.map((c) => _ContactTile(contact: c)),

          // Regionálne kontakty
          regionAsync.when(
            data: (region) => region != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('${region.flag} ${region.country}',
                          style: TextStyle(fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                    ),
                    ...region.contacts.map((c) => _ContactTile(contact: c)),
                  ],
                )
              : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ]),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final EmergencyContact contact;
  const _ContactTile({required this.contact});

  Future<void> _call(BuildContext context) async {
    if (contact.isVhf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('VHF kanál 16 – použite rádio na palube')));
      return;
    }
    if (contact.number == null) return;
    final uri = Uri(scheme: 'tel', path: contact.number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nedá sa zavolať: ${contact.display}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVhf = contact.isVhf;
    final color = isVhf ? Colors.blue : Colors.red;

    return Card(
      color: color.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _call(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(isVhf ? Icons.radio : Icons.phone,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(contact.display,
                    style: TextStyle(color: color.shade700,
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            )),
            if (!isVhf)
              Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ]),
        ),
      ),
    );
  }
}

// ── HMB Príručka Shortcuts ────────────────────────────────────

class _HmbHandbookCard extends StatelessWidget {
  const _HmbHandbookCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.menu_book, color: Colors.indigo),
              const SizedBox(width: 8),
              Text('HMB Príručka',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 12),
            // Riadok 1: Briefing, Mayday, Výbava
            Row(children: [
              Expanded(child: _HandbookButton(
                icon: Icons.checklist,
                label: 'Safety\nBriefing',
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const SafetyBriefingScreen())),
              )),
              const SizedBox(width: 8),
              Expanded(child: _HandbookButton(
                icon: Icons.radio,
                label: 'Mayday\nCard',
                color: Colors.red,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const MaydayCardScreen())),
              )),
              const SizedBox(width: 8),
              Expanded(child: _HandbookButton(
                icon: Icons.backpack,
                label: 'Výbava\njednotlivca',
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const GearListScreen())),
              )),
            ]),
            const SizedBox(height: 8),
            // Riadok 2: Check-in, Check-out
            Row(children: [
              Expanded(child: _HandbookButton(
                icon: Icons.login,
                label: 'Check-in\nPrevzatie',
                color: Colors.blue.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const YachtHandoverScreen(isCheckIn: true))),
              )),
              const SizedBox(width: 8),
              Expanded(child: _HandbookButton(
                icon: Icons.logout,
                label: 'Check-out\nOdovzdanie',
                color: Colors.orange.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const YachtHandoverScreen(isCheckIn: false))),
              )),
            ]),
            const SizedBox(height: 8),
            // Riadok 3: COLREG
            Row(children: [
              Expanded(child: _HandbookButton(
                icon: Icons.gavel,
                label: 'COLREG\nPravidlá',
                color: Colors.indigo.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ColregScreen())),
              )),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ]),
          ],
        ),
      ),
    );
  }
}

class _HandbookButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _HandbookButton({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: color,
                fontWeight: FontWeight.w600, height: 1.2)),
      ]),
    ),
  );
}
