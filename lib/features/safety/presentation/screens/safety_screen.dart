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
import 'maritime_reference_screen.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/anchor_alarm_service.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/services/location_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

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
      final dayLogId = GpsTrackingService().activeDayLogId ?? await db.getLatestDayLogId();
      final session = await db.getActiveSession();
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: drift.Value(dayLogId),
        sessionId: drift.Value(session?.sessionId),
        timestamp: DateTime.now().toUtc(),
        latitude: drift.Value(lat),
        longitude: drift.Value(lon),
        skipperNote: const drift.Value('Man overboard'),
        isAutoEntry: const drift.Value(true),
      ));
      debugPrint('[MOB] Logged MOB activation');
    } catch (e) { debugPrint('[MOB] Log error: $e'); }
    _sub = (GpsTrackingService().isTracking
        ? GpsTrackingService().positionStream
        : LocationService().stream).listen((pos) {
      state = state.copyWith(
        distanceM: _haversine(lat, lon, pos.latitude, pos.longitude),
        bearingDeg: _bearing(pos.latitude, pos.longitude, lat, lon),
      );
    });
  }

  Future<void> deactivate() async {
    _sub?.cancel();
    final lat = state.mobLat;
    final lon = state.mobLon;
    state = const MobState();
    try {
      final db = ref.read(databaseProvider);
      final dayLogId = GpsTrackingService().activeDayLogId ?? await db.getLatestDayLogId();
      final pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
      final session = await db.getActiveSession();
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: drift.Value(dayLogId),
        sessionId: drift.Value(session?.sessionId),
        timestamp: DateTime.now().toUtc(),
        latitude: drift.Value(pos?.latitude ?? lat),
        longitude: drift.Value(pos?.longitude ?? lon),
        skipperNote: const drift.Value('MOB cancelled'),
        isAutoEntry: const drift.Value(true),
      ));
      debugPrint('[MOB] Logged MOB deactivation');
    } catch (e) { debugPrint('[MOB] Deactivate log error: $e'); }
  }

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
      final dayLogId = GpsTrackingService().activeDayLogId ?? await db.getLatestDayLogId();
      final activeSession = await db.getActiveSession();
      await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
        dayLogId: drift.Value(dayLogId),
        sessionId: drift.Value(activeSession?.sessionId),
        timestamp: DateTime.now().toUtc(),
        latitude: drift.Value(lat),
        longitude: drift.Value(lon),
        skipperNote: const drift.Value('Anchor dropped'),
        isAutoEntry: const drift.Value(true),
      ));
      debugPrint('[ANCHOR] Logged anchor drop');
    } catch (e) { debugPrint('[ANCHOR] Log error: $e'); }

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
      // Zápis pri začiatku/konci driftu + zvukový alarm
      if (!wasDrifting && nowDrifting) {
        _logDrift(pos, 'Drift - perimeter exceeded');
        AnchorAlarmService().startAlarm();
      } else if (wasDrifting && !nowDrifting) {
        _logDrift(pos, 'Drift - vessel back in perimeter');
        AnchorAlarmService().stopAlarm();
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
        timestamp: DateTime.now().toUtc(),
        latitude: drift.Value(pos.latitude),
        longitude: drift.Value(pos.longitude),
        skipperNote: drift.Value(note),
        isAutoEntry: const drift.Value(true),
      ));
    } catch (e) { debugPrint('[ANCHOR] Drift log error: $e'); }
  }

  Future<void> deactivate() async {
    AnchorAlarmService().stopAlarm();
    if (state.isActive) {
      try {
        final db = ref.read(databaseProvider);
        final dayLogId = GpsTrackingService().activeDayLogId ?? await db.getLatestDayLogId();
        final pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
        final session = await db.getActiveSession();
        await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
          dayLogId: drift.Value(dayLogId),
          sessionId: drift.Value(session?.sessionId),
          timestamp: DateTime.now().toUtc(),
          latitude: drift.Value(pos?.latitude),
          longitude: drift.Value(pos?.longitude),
          skipperNote: const drift.Value('Anchor raised'),
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
      appBar: AppBar(title: Text(AppLocalizations.of(context).safety)),
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
        final pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
        if (pos == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context).gpsPositionNotAvailable),
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
        child: Column(children: [
          const Icon(Icons.person_off, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          const Text('MOB', style: TextStyle(color: Colors.white, fontSize: 32,
              fontWeight: FontWeight.bold, letterSpacing: 4)),
          const Text('Man Overboard', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).mobHoldToActivate,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
        Text(AppLocalizations.of(context).mobActive,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Builder(builder: (ctx) {
          final l = AppLocalizations.of(ctx);
          return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _MobStat(l.mobTime, et, Icons.timer),
            _MobStat(l.mobDistance,
                state.distanceM != null ? '${state.distanceM!.toStringAsFixed(0)} m' : '-',
                Icons.straighten),
            _MobStat(l.mobDirection,
                state.bearingDeg != null ? '${state.bearingDeg!.toStringAsFixed(0)}°' : '-',
                Icons.navigation),
          ]);
        }),
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
            icon: const Icon(Icons.navigation),
            label: Text(AppLocalizations.of(context).navigateToMob),
          )),
          const SizedBox(width: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white30)),
            onPressed: () => ref.read(mobProvider.notifier).deactivate(),
            child: Text(AppLocalizations.of(context).cancel),
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

class _AnchorCardState extends ConsumerState<_AnchorCard>
    with SingleTickerProviderStateMixin {
  double _radius = 15.0;
  late AnimationController _blinkCtrl;
  late Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_blinkCtrl);
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(anchorProvider);

    // Zobraziť alarm dialog hneď ako začne drift
    ref.listen<AnchorState>(anchorProvider, (prev, next) {
      if (prev?.isDrifting == false && next.isDrifting) {
        _showDriftAlarmDialog(context);
      }
    });

    return Card(
      color: s.isDrifting ? Colors.red.shade50 : null,
      shape: s.isDrifting
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.red, width: 2))
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (s.isDrifting)
              AnimatedBuilder(
                animation: _blinkAnim,
                builder: (_, __) => Icon(Icons.anchor,
                    color: Colors.red.withValues(alpha: _blinkAnim.value), size: 26),
              )
            else
              const Icon(Icons.anchor),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).anchorAlarm,
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (s.isDrifting)
              AnimatedBuilder(
                animation: _blinkAnim,
                builder: (_, __) => Chip(
                  label: Text(AppLocalizations.of(context).drifting,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  backgroundColor:
                      Colors.red.withValues(alpha: 0.5 + _blinkAnim.value * 0.5),
                ),
              ),
          ]),
          if (s.isActive && s.currentDistanceM != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (s.currentDistanceM! / s.radiusMeters).clamp(0.0, 1.2),
              color: s.isDrifting ? Colors.red : Colors.green,
              backgroundColor: Colors.grey.shade200,
              minHeight: s.isDrifting ? 8 : 4,
            ),
            const SizedBox(height: 4),
            Text('${s.currentDistanceM!.toStringAsFixed(0)} m / '
                '${s.radiusMeters.toStringAsFixed(0)} m',
                style: TextStyle(
                    color: s.isDrifting ? Colors.red : Colors.green,
                    fontWeight:
                        s.isDrifting ? FontWeight.bold : FontWeight.normal)),
          ],
          if (!s.isActive) ...[
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context).anchorRadiusLabel}: '
                '${_radius.toStringAsFixed(0)} m'),
            Slider(
                value: _radius, min: 5, max: 30, divisions: 25,
                label: '${_radius.toStringAsFixed(0)} m',
                onChanged: (v) => setState(() => _radius = v)),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: s.isActive
                ? OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(anchorProvider.notifier).deactivate(),
                    icon: const Icon(Icons.stop),
                    label: Text(AppLocalizations.of(context).deactivate),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red))
                : ElevatedButton.icon(
                    onPressed: () {
                      final pos = GpsTrackingService().lastPosition ??
                          LocationService().lastPosition;
                      if (pos == null) return;
                      ref
                          .read(anchorProvider.notifier)
                          .activate(pos.latitude, pos.longitude, _radius);
                    },
                    icon: const Icon(Icons.anchor),
                    label: Text(
                        '${AppLocalizations.of(context).activate} '
                        '${AppLocalizations.of(context).anchorAlarm}')),
          ),
        ]),
      ),
    );
  }

  void _showDriftAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.red.withValues(alpha: 0.5),
      builder: (ctx) => _DriftAlarmDialog(
        onStop: () {
          AnchorAlarmService().stopAlarm();
          Navigator.of(ctx).pop();
        },
        onDeactivate: () {
          ref.read(anchorProvider.notifier).deactivate();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

// ── Drift Alarm Dialog ────────────────────────────────────────

class _DriftAlarmDialog extends StatefulWidget {
  final VoidCallback onStop;
  final VoidCallback onDeactivate;
  const _DriftAlarmDialog({required this.onStop, required this.onDeactivate});

  @override
  State<_DriftAlarmDialog> createState() => _DriftAlarmDialogState();
}

class _DriftAlarmDialogState extends State<_DriftAlarmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _colorAnim = ColorTween(begin: Colors.red.shade700, end: Colors.red.shade300)
        .animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (_, __) => AlertDialog(
        backgroundColor: _colorAnim.value,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Text(l.anchorDriftTitle,
                style: const TextStyle(color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ]),
        content: Text(
          l.anchorDriftContent,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: widget.onDeactivate,
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: Text(l.cancelAnchor),
          ),
          ElevatedButton.icon(
            onPressed: widget.onStop,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            icon: const Icon(Icons.notifications_off, size: 20),
            label: Text(l.stopAlarm,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
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
  final List<bool> _checked = List.filled(12, false);
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      l.briefingItem1, l.briefingItem2, l.briefingItem3, l.briefingItem4,
      l.briefingItem5, l.briefingItem6, l.briefingItem7, l.briefingItem8,
      l.briefingItem9, l.briefingItem10, l.briefingItem11, l.briefingItem12,
    ];
    final checked = _checked.where((v) => v).length;
    final total = items.length;
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
              Expanded(child: Text(l.safetyBriefingCard,
                  style: Theme.of(context).textTheme.titleMedium)),
              Text('$checked/$total', style: TextStyle(
                  color: allDone ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ]),
          ),
          if (allDone)
            Padding(padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(l.briefingComplete, style: const TextStyle(color: Colors.green)),
              ])),
          if (_expanded) ...[
            const Divider(),
            ...items.asMap().entries.map((e) => CheckboxListTile(
              title: Text(e.value, style: const TextStyle(fontSize: 14)),
              value: _checked[e.key], dense: true, contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _checked[e.key] = v ?? false),
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
  final List<bool> _checkInChecked = List.filled(11, false);
  final List<bool> _checkOutChecked = List.filled(7, false);
  bool _inExp = false, _outExp = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final checkInItems = [
      l.checkInItem1, l.checkInItem2, l.checkInItem3, l.checkInItem4,
      l.checkInItem5, l.checkInItem6, l.checkInItem7, l.checkInItem8,
      l.checkInItem9, l.checkInItem10, l.checkInItem11,
    ];
    final checkOutItems = [
      l.checkOutItem1, l.checkOutItem2, l.checkOutItem3, l.checkOutItem4,
      l.checkOutItem5, l.checkOutItem6, l.checkOutItem7,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.charterCheckCard, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _CheckSection(
            title: l.checkInLabel, icon: Icons.login,
            items: checkInItems, checked: _checkInChecked, expanded: _inExp,
            onToggle: () => setState(() => _inExp = !_inExp),
            onChanged: (i, v) => setState(() => _checkInChecked[i] = v),
          ),
          const SizedBox(height: 8),
          _CheckSection(
            title: l.checkOutLabel, icon: Icons.logout,
            items: checkOutItems, checked: _checkOutChecked, expanded: _outExp,
            onToggle: () => setState(() => _outExp = !_outExp),
            onChanged: (i, v) => setState(() => _checkOutChecked[i] = v),
          ),
        ]),
      ),
    );
  }
}

class _CheckSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final List<bool> checked;
  final bool expanded;
  final VoidCallback onToggle;
  final Function(int, bool) onChanged;
  const _CheckSection({required this.title, required this.icon, required this.items,
      required this.checked, required this.expanded, required this.onToggle,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final checkedCount = checked.where((v) => v).length;
    final total = items.length;
    final allDone = checkedCount == total;
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
              Text('$checkedCount/$total', style: TextStyle(
                  color: allDone ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 20),
            ]),
          ),
        ),
        if (expanded)
          ...items.asMap().entries.map((e) => CheckboxListTile(
            title: Text(e.value, style: const TextStyle(fontSize: 13)),
            value: checked[e.key], dense: true,
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
            Expanded(child: Text(AppLocalizations.of(context).emergencyContacts,
                style: Theme.of(context).textTheme.titleMedium)),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: AppLocalizations.of(context).updateByPosition,
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
                    Text(AppLocalizations.of(context).detectedByGps,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(AppLocalizations.of(context).locationUnavailable,
                      style: const TextStyle(fontSize: 12, color: Colors.grey))),
            loading: () => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).detectingLocation,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ])),
            error: (_, __) => const SizedBox(),
          ),

          Text(AppLocalizations.of(context).tapToCall,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        SnackBar(content: Text(AppLocalizations.of(context).vhfChannel16)));
      return;
    }
    if (contact.number == null) return;
    final uri = Uri(scheme: 'tel', path: contact.number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).cannotCall(contact.display))));
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
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.menu_book, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(l.hmbHandbook, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 12),
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
                label: l.gearListShort,
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const GearListScreen())),
              )),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _HandbookButton(
                icon: Icons.login,
                label: l.checkInShort,
                color: Colors.blue.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const YachtHandoverScreen(isCheckIn: true))),
              )),
              const SizedBox(width: 8),
              Expanded(child: _HandbookButton(
                icon: Icons.logout,
                label: l.checkOutShort,
                color: Colors.orange.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const YachtHandoverScreen(isCheckIn: false))),
              )),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _HandbookButton(
                icon: Icons.gavel,
                label: l.colregRules,
                color: Colors.indigo.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ColregScreen())),
              )),
              const SizedBox(width: 8),
              Expanded(child: _HandbookButton(
                icon: Icons.flag,
                label: l.marineReferenceTile,
                color: Colors.teal.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const MaritimeReferenceScreen())),
              )),
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
