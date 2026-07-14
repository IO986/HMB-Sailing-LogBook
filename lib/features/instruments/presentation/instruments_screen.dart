import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/marine_instrument_data.dart';
import '../../../core/models/weather_data.dart';
import '../../../core/providers/raymarine_providers.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/weather_service.dart';
import '../../map/providers/map_provider.dart';
import '../../../l10n/app_localizations.dart';

// ── Providers ─────────────────────────────────────────────────

final _gpsProvider = StreamProvider<Position>((ref) => LocationService().stream);

final _weatherProvider = FutureProvider<WeatherData?>(
    (ref) => WeatherService().getCurrentWeather());

final _activeWpProvider = StateProvider<Waypoint?>((ref) => null);

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────

class InstrumentsScreen extends ConsumerWidget {
  const InstrumentsScreen({super.key});

  static const _bg = Color(0xFF080F1A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(_gpsProvider).valueOrNull
        ?? LocationService().lastPosition;
    final settings = ref.watch(raymarineSettingsProvider);
    final isUdp = settings.connectionType == NmeaConnectionType.udp;
    final tcpMarine = ref.watch(marineDataProvider).valueOrNull;
    final tcpState = ref.watch(raymarineConnectionStateProvider).valueOrNull;
    final udpMarine = ref.watch(udpDataProvider).valueOrNull;
    final udpState = ref.watch(udpConnectionStateProvider).valueOrNull;
    final marine = isUdp ? udpMarine : tcpMarine;
    final rayState = isUdp ? udpState : tcpState;
    final weather = ref.watch(_weatherProvider).valueOrNull;
    final waypoints = ref.watch(waypointsProvider).valueOrNull ?? [];
    final activeWp = ref.watch(_activeWpProvider);

    const _fieldStale = Duration(seconds: 10);
    bool _freshField(DateTime? t) =>
        t != null && DateTime.now().difference(t) < _fieldStale;

    final rayOk = rayState == RaymarineConnectionState.connected
        && marine?.lastUpdate != null
        && DateTime.now().difference(marine!.lastUpdate!) < const Duration(seconds: 8);
    final windOk = rayOk && _freshField(marine.windLastUpdate);
    final depthOk = rayOk && _freshField(marine.depthLastUpdate);

    // --- Hodnoty ---
    final sogKn = rayOk
        ? (marine.sogKnots ?? _ms2kn(pos?.speed))
        : _ms2kn(pos?.speed);

    // heading: Raymarine kompas > GPS heading
    final hdgDeg = rayOk
        ? (marine.headingDegrees ?? marine.cogDegrees ?? pos?.heading ?? 0.0)
        : (pos?.heading ?? 0.0);

    // TWS – true wind speed
    final twsKn = windOk ? marine.windSpeedKnots : weather?.windSpeed;

    // TWA – true wind angle (0–180, P/S)
    // Raymarine môže dávať apparent angle; z weather vypočítame z rozdielu smerov
    double? twaVal;
    bool? twaStarboard;
    if (windOk && marine.windAngleDegrees != null) {
      final raw = marine.windAngleDegrees!;
      // Normalizuj na -180..180
      final norm = ((raw + 180) % 360) - 180;
      twaVal = norm.abs();
      twaStarboard = norm >= 0;
    } else if (!windOk && weather?.windDirection != null) {
      // windDirection je meteorologický smer (odkiaľ fúka) → na kurz lode
      final windFrom = weather!.windDirection;
      final raw = ((windFrom - hdgDeg) + 360) % 360;
      final norm = raw > 180 ? raw - 360 : raw;
      twaVal = norm.abs();
      twaStarboard = norm >= 0;
    }

    final depthM = depthOk ? marine.depthMeters : null;

    // --- VMG WP ---
    double? vmgWp, distWpNm, brgWp;
    if (activeWp != null && pos != null) {
      brgWp = _bearing(pos.latitude, pos.longitude, activeWp.latitude, activeWp.longitude);
      distWpNm = _haversineNm(pos.latitude, pos.longitude, activeWp.latitude, activeWp.longitude);
      final cogDeg2 = rayOk ? (marine.cogDegrees ?? pos.heading) : pos.heading;
      final angleDiff = ((cogDeg2 - brgWp) + 360) % 360;
      vmgWp = sogKn * cos(angleDiff * pi / 180);
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        titleSpacing: 16,
        title: const Text('INSTRUMENTS',
            style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w300)),
        actions: [
          _SourceBadge(rayConnected: rayOk),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(children: [
        // ── GPS pozícia ───────────────────────────────────────
        _GpsPositionRow(pos: pos, fromNmea: rayOk && marine.hasGpsFix),
        // ── 2 × 2 digitálne displeje ──────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(children: [
            Expanded(child: _DigitBox(
              label: 'SOG',
              value: sogKn.toStringAsFixed(1),
              unit: 'kn',
              color: const Color(0xFF27AE60),
              source: (rayOk && marine.sogKnots != null) ? 'NMEA' : 'GPS',
            )),
            const SizedBox(width: 10),
            Expanded(child: _DigitBox(
              label: 'TWS',
              value: twsKn != null ? twsKn.toStringAsFixed(1) : '--.-',
              unit: 'kn',
              color: const Color(0xFF3498DB),
              source: (windOk && marine.windSpeedKnots != null) ? 'NMEA' : (twsKn != null ? 'METEO' : null),
            )),
          ]),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: Row(children: [
            Expanded(child: _DigitBox(
              label: 'TWA',
              value: twaVal != null ? twaVal.toStringAsFixed(0) : '---',
              unit: '°',
              color: twaStarboard == true
                  ? const Color(0xFF27AE60)
                  : twaStarboard == false
                      ? const Color(0xFFE74C3C)
                      : Colors.white38,
              source: (windOk && marine.windAngleDegrees != null) ? 'NMEA' : (twaVal != null ? 'METEO' : null),
            )),
            const SizedBox(width: 10),
            Expanded(child: _DigitBox(
              label: 'DEPTH',
              value: depthM != null ? depthM.toStringAsFixed(1) : '--.-',
              unit: 'm',
              color: depthM != null && depthM < 5
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF3EB1C8),
              alert: depthM != null && depthM < 5,
              source: depthOk ? 'NMEA' : null,
            )),
          ]),
        ),

        // ── VMG WP ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: _VmgWpTile(
            vmg: vmgWp,
            distNm: distWpNm,
            brg: brgWp,
            wp: activeWp,
            waypoints: waypoints,
            onSelect: (wp) => ref.read(_activeWpProvider.notifier).state = wp,
          ),
        ),

        // ── Heading kompas ────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _HeadingCompass(
              heading: hdgDeg,
              twa: twaVal,
              twaStarboard: twaStarboard,
              brgWp: brgWp,
            ),
          ),
        ),
      ]),
    );
  }

  static double _ms2kn(double? ms) => (ms ?? 0.0) * 1.94384;

  static double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * pi / 180;
    final y = sin(dLon) * cos(lat2 * pi / 180);
    final x = cos(lat1 * pi / 180) * sin(lat2 * pi / 180) -
        sin(lat1 * pi / 180) * cos(lat2 * pi / 180) * cos(dLon);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  static double _haversineNm(double lat1, double lon1, double lat2, double lon2) {
    const r = 3440.065; // NM
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

// ─────────────────────────────────────────────────────────────
// GPS pozícia — riadok na vrchu
// ─────────────────────────────────────────────────────────────

class _GpsPositionRow extends StatelessWidget {
  final Position? pos;
  final bool fromNmea;

  const _GpsPositionRow({required this.pos, required this.fromNmea});

  String _fmt(double deg, bool isLat) {
    final d = deg.abs().floor();
    final m = (deg.abs() - d) * 60;
    final hem = isLat ? (deg >= 0 ? 'N' : 'S') : (deg >= 0 ? 'E' : 'W');
    return '$d° ${m.toStringAsFixed(3)}\' $hem';
  }

  @override
  Widget build(BuildContext context) {
    final lat = pos?.latitude;
    final lon = pos?.longitude;
    final src = fromNmea ? 'NMEA' : 'GPS';
    final srcColor = fromNmea
        ? const Color(0xFF27AE60)
        : Colors.white38;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: const Color(0xFF0A1520),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 11, color: srcColor),
          const SizedBox(width: 5),
          Text(
            lat != null && lon != null
                ? '${_fmt(lat, true)}   ${_fmt(lon, false)}'
                : '--° --\' -   --° --\' -',
            style: TextStyle(
              color: lat != null ? Colors.white70 : Colors.white24,
              fontSize: 12,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: srcColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(src,
                style: TextStyle(
                    color: srcColor,
                    fontSize: 7,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Digitálny displej
// ─────────────────────────────────────────────────────────────

class _DigitBox extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final bool alert;
  final String? source; // 'NMEA', 'GPS', 'METEO' — null = skryté

  const _DigitBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.alert = false,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: alert ? color.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.07),
          width: alert ? 1.5 : 0.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, letterSpacing: 2,
                  fontWeight: FontWeight.w500)),
          if (source != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(source!,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 7,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w100,
                  height: 1.0,
                  fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(unit,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w400)),
          ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// VMG WP tile
// ─────────────────────────────────────────────────────────────

class _VmgWpTile extends StatelessWidget {
  final double? vmg, distNm, brg;
  final Waypoint? wp;
  final List<Waypoint> waypoints;
  final ValueChanged<Waypoint?> onSelect;

  const _VmgWpTile({
    required this.vmg,
    required this.distNm,
    required this.brg,
    required this.wp,
    required this.waypoints,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = wp != null;
    return GestureDetector(
      onTap: () => _showWpPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasData
                ? const Color(0xFFFFAA00).withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.07),
            width: 0.5,
          ),
        ),
        child: Row(children: [
          // VMG hodnota
          Expanded(
            flex: 3,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.navigation, color: Color(0xFFFFAA00), size: 10),
                const SizedBox(width: 4),
                const Text('VMG WP',
                    style: TextStyle(
                        color: Color(0xFFFFAA00),
                        fontSize: 10, letterSpacing: 2,
                        fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  vmg != null ? vmg!.toStringAsFixed(1) : '--.-',
                  style: TextStyle(
                    color: vmg != null
                        ? (vmg! >= 0 ? Colors.white : Colors.red.shade300)
                        : Colors.white38,
                    fontSize: 34,
                    fontWeight: FontWeight.w100,
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('kn',
                      style: TextStyle(
                          color: Color(0xFFFFAA00), fontSize: 12)),
                ),
              ]),
            ]),
          ),
          // Oddeľovač
          Container(width: 0.5, height: 48,
              color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(width: 12),
          // Dist + BRG + WP name
          Expanded(
            flex: 4,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // WP name; bez vybraného waypointu výrazné oranžové tlačidlo,
              // nie nenápadný sivý hint (užívatelia ho prehliadali).
              Container(
                padding: hasData
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: hasData
                    ? null
                    : BoxDecoration(
                        color: const Color(0xFFFFAA00).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFFAA00)
                                .withValues(alpha: 0.7)),
                      ),
                child: Row(children: [
                  Icon(hasData ? Icons.place : Icons.near_me,
                      size: hasData ? 11 : 13,
                      color: const Color(0xFFFFAA00)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      wp?.name ?? AppLocalizations.of(context).selectWaypointHint,
                      style: TextStyle(
                        color: hasData
                            ? Colors.white70
                            : const Color(0xFFFFAA00),
                        fontSize: 11,
                        fontWeight: hasData ? FontWeight.normal : FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 14,
                      color: hasData
                          ? Colors.white24
                          : const Color(0xFFFFAA00)),
                ]),
              ),
              const SizedBox(height: 6),
              Row(children: [
                _WpStat('DIST',
                    distNm != null ? '${distNm!.toStringAsFixed(1)} NM' : '--'),
                const SizedBox(width: 16),
                _WpStat('BRG',
                    brg != null ? '${brg!.toStringAsFixed(0)}°' : '--'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showWpPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context).selectTargetWaypoint,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ),
        const Divider(color: Colors.white12, height: 1),
        if (waypoints.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(AppLocalizations.of(context).noWaypoints,
                  style: const TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/map');
                },
                icon: const Icon(Icons.map_outlined, size: 16),
                label: Text(AppLocalizations.of(context).goToMap),
              ),
            ]),
          )
        else ...[
          if (wp != null)
            ListTile(
              leading: const Icon(Icons.close, color: Colors.white38, size: 18),
              title: Text(AppLocalizations.of(context).noTarget,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
              onTap: () { onSelect(null); Navigator.pop(context); },
            ),
          ...waypoints.map((w) => ListTile(
            leading: Icon(Icons.place,
                color: w.id == wp?.id
                    ? const Color(0xFFFFAA00)
                    : Colors.white38,
                size: 18),
            title: Text(w.name,
                style: TextStyle(
                    color: w.id == wp?.id ? const Color(0xFFFFAA00) : Colors.white,
                    fontSize: 14)),
            subtitle: Text(
                '${w.latitude.toStringAsFixed(4)}°  ${w.longitude.toStringAsFixed(4)}°',
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            onTap: () { onSelect(w); Navigator.pop(context); },
          )),
        ],
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _WpStat extends StatelessWidget {
  final String label, value;
  const _WpStat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 1.5)),
      const SizedBox(height: 1),
      Text(value,
          style: const TextStyle(
              color: Colors.white70, fontSize: 13,
              fontFeatures: [FontFeature.tabularFigures()])),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// Heading kompas
// ─────────────────────────────────────────────────────────────

class _HeadingCompass extends StatelessWidget {
  final double heading;
  final double? twa;
  final bool? twaStarboard;
  final double? brgWp;
  const _HeadingCompass({
    required this.heading,
    this.twa,
    this.twaStarboard,
    this.brgWp,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, box) {
      final size = min(box.maxWidth, box.maxHeight);
      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CompassPainter(
              heading: heading,
              twa: twa,
              twaStarboard: twaStarboard,
              brgWp: brgWp,
            ),
          ),
        ),
      );
    });
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final double? twa;
  final bool? twaStarboard;
  final double? brgWp;
  const _CompassPainter({
    required this.heading,
    this.twa,
    this.twaStarboard,
    this.brgWp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 4;

    // --- Pozadie kruhu ---
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = const Color(0xFF0A1520));
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // --- Otáčajúca sa karta ---
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-heading * pi / 180);

    // Rysky a čísla (každých 10°, označenie každých 30°)
    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final isMajor = i % 90 == 0;   // N E S W
      final isMid = i % 30 == 0;     // každých 30° číslo
      final cos_ = cos(angle - pi / 2);
      final sin_ = sin(angle - pi / 2);

      // Dĺžka rysky
      final tickLen = isMajor ? r * 0.14 : (isMid ? r * 0.09 : r * 0.055);
      final outerR = r * 0.96;
      final innerR = outerR - tickLen;

      canvas.drawLine(
        Offset(cos_ * innerR, sin_ * innerR),
        Offset(cos_ * outerR, sin_ * outerR),
        Paint()
          ..color = isMajor
              ? Colors.white
              : (isMid ? Colors.white70 : Colors.white30)
          ..strokeWidth = isMajor ? 2.5 : (isMid ? 1.5 : 0.8),
      );

      // Čísla / svetové strany každých 30°
      if (isMid) {
        final labelR = innerR - r * 0.07;
        String label;
        Color labelColor;
        double fontSize;

        if (i == 0) {
          label = 'N';
          labelColor = const Color(0xFFE74C3C);
          fontSize = r * 0.13;
        } else if (i == 90) {
          label = 'E';
          labelColor = Colors.white;
          fontSize = r * 0.11;
        } else if (i == 180) {
          label = 'S';
          labelColor = Colors.white;
          fontSize = r * 0.11;
        } else if (i == 270) {
          label = 'W';
          labelColor = Colors.white;
          fontSize = r * 0.11;
        } else {
          label = '$i';
          labelColor = Colors.white60;
          fontSize = r * 0.08;
        }

        final tp = TextPainter(
          text: TextSpan(
              text: label,
              style: TextStyle(
                  color: labelColor,
                  fontSize: fontSize,
                  fontWeight: isMajor ? FontWeight.bold : FontWeight.w300,
                  letterSpacing: 0)),
          textDirection: ui.TextDirection.ltr,
        )..layout();

        // Rotujeme text naspäť aby bol vždy čitateľný
        canvas.save();
        canvas.translate(cos_ * labelR, sin_ * labelR);
        canvas.rotate(heading * pi / 180); // counter-rotate
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }

    canvas.restore();

    // --- Pevná lubberlina (trojuholník navrchu) ---
    final lubberPath = Path()
      ..moveTo(cx, cy - r * 0.96)
      ..lineTo(cx - r * 0.04, cy - r * 0.82)
      ..lineTo(cx + r * 0.04, cy - r * 0.82)
      ..close();
    canvas.drawPath(lubberPath,
        Paint()..color = const Color(0xFFFFAA00));

    // --- TWA šípka (fixná – relatívna k osi lode) ---
    if (twa != null && twaStarboard != null) {
      final twaColor = twaStarboard!
          ? const Color(0xFF27AE60)   // zelená – SB
          : const Color(0xFFE74C3C);  // červená – PS
      final signedRad = (twaStarboard! ? twa! : -twa!) * pi / 180;
      final dx = sin(signedRad);
      final dy = -cos(signedRad);

      final innerR = r * 0.32;
      final outerR = r * 0.80;
      final tipX = cx + dx * outerR;
      final tipY = cy + dy * outerR;

      // Čiara šípky
      canvas.drawLine(
        Offset(cx + dx * innerR, cy + dy * innerR),
        Offset(tipX, tipY),
        Paint()
          ..color = twaColor
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );

      // Hrot šípky
      final headLen = r * 0.065;
      final perpX = cos(signedRad);
      final perpY = sin(signedRad);
      final baseX = tipX - dx * headLen;
      final baseY = tipY - dy * headLen;
      canvas.drawPath(
        Path()
          ..moveTo(tipX, tipY)
          ..lineTo(baseX + perpX * headLen * 0.45, baseY + perpY * headLen * 0.45)
          ..lineTo(baseX - perpX * headLen * 0.45, baseY - perpY * headLen * 0.45)
          ..close(),
        Paint()..color = twaColor,
      );
    }

    // --- WP šípka (priamy kurz na vybraný waypoint) ---
    if (brgWp != null) {
      const wpColor = Color(0xFFFFAA00);
      final relRad = ((brgWp! - heading + 360) % 360) * pi / 180;
      final dx = sin(relRad);
      final dy = -cos(relRad);

      final innerR = r * 0.20;
      final outerR = r * 0.92;
      final tipX = cx + dx * outerR;
      final tipY = cy + dy * outerR;

      canvas.drawLine(
        Offset(cx + dx * innerR, cy + dy * innerR),
        Offset(tipX, tipY),
        Paint()
          ..color = wpColor
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );

      final headLen = r * 0.075;
      final perpX = cos(relRad);
      final perpY = sin(relRad);
      final baseX = tipX - dx * headLen;
      final baseY = tipY - dy * headLen;
      canvas.drawPath(
        Path()
          ..moveTo(tipX, tipY)
          ..lineTo(baseX + perpX * headLen * 0.5, baseY + perpY * headLen * 0.5)
          ..lineTo(baseX - perpX * headLen * 0.5, baseY - perpY * headLen * 0.5)
          ..close(),
        Paint()..color = wpColor,
      );
    }

    // --- Kruh v strede s aktuálnym heading ---
    final centerR = r * 0.28;
    canvas.drawCircle(Offset(cx, cy), centerR,
        Paint()..color = const Color(0xFF0D1B2A));
    canvas.drawCircle(Offset(cx, cy), centerR,
        Paint()
          ..color = const Color(0xFFFFAA00).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);

    final hdgStr = heading.toStringAsFixed(0).padLeft(3, '0') + '°';
    final tp = TextPainter(
      text: TextSpan(
          text: hdgStr,
          style: TextStyle(
              color: Colors.white,
              fontSize: r * 0.14,
              fontWeight: FontWeight.w200,
              letterSpacing: 1,
              fontFeatures: const [FontFeature.tabularFigures()])),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    // --- Vonkajší dekoratívny kruh ---
    canvas.drawCircle(Offset(cx, cy), r * 0.985,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.04)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.04);
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.heading != heading ||
      old.twa != twa ||
      old.twaStarboard != twaStarboard ||
      old.brgWp != brgWp;
}

// ─────────────────────────────────────────────────────────────
// Source badge
// ─────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  final bool rayConnected;
  const _SourceBadge({required this.rayConnected});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: rayConnected
          ? const Color(0xFF1A6B3C).withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
          color: rayConnected
              ? const Color(0xFF27AE60).withValues(alpha: 0.6)
              : Colors.white24,
          width: 0.5),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(rayConnected ? Icons.sensors : Icons.smartphone,
          size: 10,
          color: rayConnected ? const Color(0xFF27AE60) : Colors.white38),
      const SizedBox(width: 4),
      Text(rayConnected ? 'NMEA' : 'GPS',
          style: TextStyle(
              color: rayConnected ? const Color(0xFF27AE60) : Colors.white38,
              fontSize: 9,
              letterSpacing: 1)),
    ]),
  );
}
