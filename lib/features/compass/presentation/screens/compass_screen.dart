import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../l10n/app_localizations.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with WidgetsBindingObserver {
  CameraController? _camCtrl;
  bool _cameraReady = false;
  bool _cameraPermissionDenied = false;

  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<AccelerometerEvent>? _accSub;

  double _magX = 0, _magY = 0, _magZ = 0;
  double _accX = 0, _accY = 0, _accZ = 0;
  double _heading = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initCamera();
    _initSensors();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _camCtrl?.dispose();
      _camCtrl = null;
      if (mounted) setState(() => _cameraReady = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _cameraPermissionDenied = true);
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final ctrl = CameraController(back, ResolutionPreset.medium,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    try {
      await ctrl.initialize();
      if (mounted) setState(() { _camCtrl = ctrl; _cameraReady = true; });
    } catch (_) {
      ctrl.dispose();
    }
  }

  void _initSensors() {
    _magSub = magnetometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((e) { _magX = e.x; _magY = e.y; _magZ = e.z; _updateHeading(); });
    _accSub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((e) { _accX = e.x; _accY = e.y; _accZ = e.z; });
  }

  void _updateHeading() {
    // Tilt-compensated heading (Freescale AN4248)
    final norm = math.sqrt(_accX * _accX + _accY * _accY + _accZ * _accZ);
    if (norm == 0) return;
    final sinRoll  = _accX / norm;
    final cosRoll  = math.sqrt(1 - sinRoll * sinRoll);
    final sinPitch = _accY / norm;
    final cosPitch = math.sqrt(1 - sinPitch * sinPitch);

    final mx = _magX * cosPitch + _magZ * sinPitch;
    final my = _magX * sinRoll * sinPitch + _magY * cosRoll - _magZ * sinRoll * cosPitch;

    double h = math.atan2(my, -mx) * 180 / math.pi;
    if (h < 0) h += 360;
    if (mounted) setState(() => _heading = h);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _magSub?.cancel();
    _accSub?.cancel();
    _camCtrl?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera background ─────────────────────────────
          if (_cameraReady && _camCtrl != null)
            CameraPreview(_camCtrl!)
          else if (_cameraPermissionDenied)
            _NoCamera(label: l.cameraPermissionDenied)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // ── Top gradient ──────────────────────────────────
          if (_cameraReady)
            Positioned(
              top: 0, left: 0, right: 0,
              height: topPad + 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
              ),
            ),

          // ── Compass strip ─────────────────────────────────
          Positioned(
            top: topPad + 4,
            left: 0, right: 0,
            child: _CompassStrip(heading: _heading),
          ),

          // ── Screen label ──────────────────────────────────
          Positioned(
            top: topPad + 62,
            left: 0, right: 0,
            child: Center(
              child: Text(l.navCompass,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12, letterSpacing: 2)),
            ),
          ),

          // ── Crosshair + readout ───────────────────────────
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 60),
              const _Crosshair(),
              const SizedBox(height: 20),
              _BearingReadout(heading: _heading),
            ]),
          ),

          // ── Calibration note ──────────────────────────────
          Positioned(
            bottom: 88,
            left: 24, right: 24,
            child: Text(l.compassCalibrationNote,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white30, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ── Compass strip ─────────────────────────────────────────────

class _CompassStrip extends StatelessWidget {
  final double heading;
  const _CompassStrip({required this.heading});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: CustomPaint(painter: _StripPainter(heading: heading)),
      );
}

class _StripPainter extends CustomPainter {
  final double heading;
  static const _cardinals = {
    0: 'N', 45: 'NE', 90: 'E', 135: 'SE',
    180: 'S', 225: 'SW', 270: 'W', 315: 'NW',
  };

  const _StripPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    const visibleDeg = 90.0;
    final pxPerDeg = size.width / visibleDeg;
    final cx = size.width / 2;

    for (int d = -180; d <= 540; d++) {
      double delta = (d - heading) % 360;
      if (delta > 180) delta -= 360;
      if (delta < -180) delta += 360;
      if (delta.abs() > visibleDeg / 2 + 1) continue;

      final x = cx + delta * pxPerDeg;
      final norm = ((d % 360) + 360) % 360;
      final isCardinal = norm % 90 == 0;
      final isInterCardinal = norm % 45 == 0;
      final isNorth = norm == 0;
      final tickH = isCardinal ? 24.0 : (isInterCardinal ? 16.0 : 8.0);

      final paint = Paint()
        ..color = isNorth
            ? Colors.redAccent
            : (isCardinal ? Colors.white : Colors.white54)
        ..strokeWidth = isCardinal ? 2.0 : 1.2;
      canvas.drawLine(Offset(x, size.height - tickH), Offset(x, size.height), paint);

      final label = _cardinals[norm];
      if (label != null) {
        _drawText(canvas, label, x, size.height - tickH - 18,
            color: isNorth ? Colors.redAccent : Colors.white,
            fontSize: isCardinal ? 13 : 11,
            bold: isCardinal);
      } else if (norm % 30 == 0) {
        _drawText(canvas, '$norm°', x, size.height - 12 - 14,
            color: Colors.white38, fontSize: 9);
      }
    }

    // Centre marker
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height),
        Paint()..color = Colors.yellowAccent..strokeWidth = 1.5);
  }

  void _drawText(Canvas c, String text, double x, double y,
      {required Color color, required double fontSize, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(x - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(_StripPainter old) => old.heading != heading;
}

// ── Crosshair ─────────────────────────────────────────────────

class _Crosshair extends StatelessWidget {
  const _Crosshair();

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 80, height: 80, child: CustomPaint(painter: _CrossPainter()));
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.yellowAccent..strokeWidth = 1.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const g = 10.0;
    const a = 30.0;
    canvas.drawLine(Offset(cx, cy - g), Offset(cx, cy - a), p);
    canvas.drawLine(Offset(cx, cy + g), Offset(cx, cy + a), p);
    canvas.drawLine(Offset(cx - g, cy), Offset(cx - a, cy), p);
    canvas.drawLine(Offset(cx + g, cy), Offset(cx + a, cy), p);
    canvas.drawCircle(Offset(cx, cy), 3, p..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), g, p..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_CrossPainter old) => false;
}

// ── Bearing readout ───────────────────────────────────────────

class _BearingReadout extends StatelessWidget {
  final double heading;
  const _BearingReadout({required this.heading});

  String _cardinal(double h) {
    const dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE',
                   'S','SSW','SW','WSW','W','WNW','NW','NNW'];
    return dirs[((h + 11.25) / 22.5).floor() % 16];
  }

  @override
  Widget build(BuildContext context) {
    final deg = heading.round() % 360;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${deg.toString().padLeft(3, '0')}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w200,
              letterSpacing: 3,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            _cardinal(heading),
            style: const TextStyle(
                color: Colors.yellowAccent, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── No camera placeholder ─────────────────────────────────────

class _NoCamera extends StatelessWidget {
  final String label;
  const _NoCamera({required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white38, size: 56),
            const SizedBox(height: 16),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: openAppSettings,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('Otvoriť nastavenia'),
            ),
          ]),
        ),
      );
}
