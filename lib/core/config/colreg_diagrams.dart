import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Label baked into a diagram. Slovak has a full translation, every other
/// locale falls back to English — the same rule as ColregContent.chaptersFor.
String _t(BuildContext context, String sk, String en) =>
    Localizations.localeOf(context).languageCode == 'sk' ? sk : en;

/// Mapuje diagramKey na widget. Vracia null ak diagram neexistuje.
Widget? buildColregDiagram(String key, {double height = 180}) {
  switch (key) {
    case 'blind_spots': return _BlindSpotsDiagram(height: height);
    case 'bearing_test': return _BearingTestDiagram(height: height);
    case 'positive_action': return _PositiveActionDiagram(height: height);
    case 'narrow_channel': return _NarrowChannelDiagram(height: height);
    case 'tss_diagram': return _TssDiagram(height: height);
    case 'sailboat_opposite_tack': return _SailboatOppositeTackDiagram(height: height);
    case 'sailboat_same_tack': return _SailboatSameTackDiagram(height: height);
    case 'overtaking_sector': return _OvertakingSectorDiagram(height: height);
    case 'head_on_situation': return _HeadOnDiagram(height: height);
    case 'crossing_situation': return _CrossingDiagram(height: height);
    case 'fog_radar_avoidance': return _FogRadarDiagram(height: height);
    case 'light_sectors': return _LightSectorsDiagram(height: height);
    case 'masthead_light': return _MastheadLightDiagram(height: height);
    case 'power_vessel_lights': return _PowerVesselLightsDiagram(height: height);
    case 'sailboat_lights': return _SailboatLightsDiagram(height: height);
    case 'trawler_lights': return _TrawlerLightsDiagram(height: height);
    case 'fishing_lights': return _FishingLightsDiagram(height: height);
    case 'not_under_command': return _NotUnderCommandDiagram(height: height);
    case 'restricted_maneuverability': return _RestrictedManeuverDiagram(height: height);
    case 'draft_constrained': return _DraftConstrainedDiagram(height: height);
    case 'anchored_vessel': return _AnchoredVesselDiagram(height: height);
    case 'towing_lights': return _TowingLightsDiagram(height: height);
    default: return null;
  }
}

// ── Helper: jednoduchá loď zhora (top-down) ─────────────────────

class _BoatShape extends StatelessWidget {
  final double angle; // rotácia v radiánoch, 0 = smer nahor
  final Color color;
  final double size;
  const _BoatShape({this.angle = 0, this.color = Colors.blueGrey, this.size = 40});

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: CustomPaint(
      size: Size(size, size * 1.6),
      painter: _BoatPainter(color: color),
    ),
  );
}

class _BoatPainter extends CustomPainter {
  final Color color;
  _BoatPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.35)
      ..lineTo(size.width * 0.85, size.height)
      ..lineTo(size.width * 0.15, size.height)
      ..lineTo(0, size.height * 0.35)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_BoatPainter old) => old.color != color;
}

class _DiagramFrame extends StatelessWidget {
  final double height;
  final Widget child;
  const _DiagramFrame({required this.height, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFE8F2F8),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFB8D4E8)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _WaterPainter())),
      child,
    ]),
  );
}

class _WaterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A5276).withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double y = 10; y < size.height; y += 14) {
      final path = Path();
      for (double x = 0; x <= size.width; x += 20) {
        path.lineTo(x, y + math.sin(x / 20) * 3);
      }
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(_WaterPainter old) => false;
}

// ── Slepé uhly ────────────────────────────────────────────────

class _BlindSpotsDiagram extends StatelessWidget {
  final double height;
  const _BlindSpotsDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(alignment: Alignment.center, children: [
          // Slepý uhol kužeľ
          CustomPaint(
            size: const Size(160, 100),
            painter: _ConePainter(
              angleDeg: 50,
              direction: -math.pi / 2,
              color: Colors.red.withOpacity(0.25),
              length: 90,
            ),
          ),
          Positioned(top: 50, child: _BoatShape(color: Colors.blueGrey.shade700, size: 36)),
        ]),
        const SizedBox(height: 8),
        Text(_t(context, 'Slepý uhol za prednou plachtou',
                'Blind spot behind the headsail'),
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ]),
    ),
  );
}

class _ConePainter extends CustomPainter {
  final double angleDeg;
  final double direction;
  final Color color;
  final double length;
  _ConePainter({required this.angleDeg, required this.direction, required this.color, required this.length});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final halfAngle = angleDeg * math.pi / 180 / 2;
    final path = Path()..moveTo(center.dx, center.dy);
    path.lineTo(
      center.dx + length * math.cos(direction - halfAngle),
      center.dy + length * math.sin(direction - halfAngle),
    );
    path.lineTo(
      center.dx + length * math.cos(direction + halfAngle),
      center.dy + length * math.sin(direction + halfAngle),
    );
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_ConePainter old) => false;
}

// ── Test nemenného náměru ────────────────────────────────────

class _BearingTestDiagram extends StatelessWidget {
  final double height;
  const _BearingTestDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Row(children: [
      Expanded(child: _bearingFrame('T1', 0.62)),
      Container(width: 1, color: Colors.black12),
      Expanded(child: _bearingFrame(
          _t(context, 'T2 (o 5 min)', 'T2 (5 min later)'), 0.38)),
    ]),
  );

  Widget _bearingFrame(String label, double distFactor) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: Stack(alignment: Alignment.center, children: [
          // Zábradlie - referenčný bod
          Positioned(bottom: 20, child: Container(width: 2, height: 40, color: Colors.black54)),
          Positioned(top: 20 + (60 * distFactor), child: _BoatShape(
            angle: math.pi, color: Colors.red.shade700, size: 28 + 14 * (1 - distFactor))),
          Positioned(bottom: 0, child: _BoatShape(color: Colors.blueGrey.shade700, size: 26)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ),
    ],
  );
}

// ── Pozitívna akcia ───────────────────────────────────────────

class _PositiveActionDiagram extends StatelessWidget {
  final double height;
  const _PositiveActionDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Row(children: [
      _scenario(_t(context, 'A: Pôvodný kurz', 'A: Original course'), 0),
      _scenario(_t(context, 'B: Malá zmena\n(nezreteľné)',
          'B: Small alteration\n(not apparent)'), 0.18),
      _scenario(_t(context, 'C: Výrazná zmena\n(zreteľné)',
          'C: Large alteration\n(readily apparent)'), 0.55),
    ].map((w) => Expanded(child: w)).toList()),
  );

  Widget _scenario(String label, double turnFactor) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(child: Center(
        child: _BoatShape(angle: -turnFactor, color: Colors.blueGrey.shade700, size: 34))),
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ),
    ],
  );
}

// ── Úzky kanál ────────────────────────────────────────────────

class _NarrowChannelDiagram extends StatelessWidget {
  final double height;
  const _NarrowChannelDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Stack(children: [
        // Kanál
        Positioned.fill(child: CustomPaint(painter: _ChannelPainter())),
        Positioned(left: 8, top: 8, child: Text(_t(context, '✗ stred', '✗ mid-channel'),
            style: const TextStyle(fontSize: 10, color: Colors.red))),
        Positioned(right: 8, top: 8, child: Text(_t(context, '✓ pravobok', '✓ starboard side'),
            style: const TextStyle(fontSize: 10, color: Colors.green))),
      ]),
    ),
  );
}

class _ChannelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()..color = const Color(0xFFD4E8C4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.18), landPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.18), landPaint);

    final centerLine = Paint()..color = Colors.red.withOpacity(0.4)..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dashPath = Path();
    double y = size.height * 0.18;
    while (y < size.height * 0.82) {
      dashPath.moveTo(0, y);
      dashPath.lineTo(size.width, y);
      y += 1000; // single dashed center line simplified
    }
    canvas.drawLine(
      Offset(0, size.height / 2), Offset(size.width, size.height / 2), centerLine);

    // Loď bližšie k pravoboku (hore na obrázku = vpredu)
    final boatPaint = Paint()..color = Colors.blueGrey.shade700;
    final bx = size.width * 0.72;
    final by = size.height * 0.45;
    final path = Path()
      ..moveTo(bx, by - 14)
      ..lineTo(bx + 9, by + 6)
      ..lineTo(bx - 9, by + 6)
      ..close();
    canvas.drawPath(path, boatPaint);
  }
  @override
  bool shouldRepaint(_ChannelPainter old) => false;
}

// ── TSS diagram ───────────────────────────────────────────────

class _TssDiagram extends StatelessWidget {
  final double height;
  const _TssDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(painter: _TssPainter(), child: Container()),
    ),
  );
}

class _TssPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lane1 = Rect.fromLTWH(size.width * 0.15, 0, size.width * 0.25, size.height);
    final lane2 = Rect.fromLTWH(size.width * 0.6, 0, size.width * 0.25, size.height);
    final lanePaint = Paint()..color = const Color(0xFFD7BFE8).withOpacity(0.5);
    canvas.drawRect(lane1, lanePaint);
    canvas.drawRect(lane2, lanePaint);

    // separation zone
    final sepPaint = Paint()..color = Colors.purple.withOpacity(0.15);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.2, size.height), sepPaint);

    // arrows
    _drawArrow(canvas, Offset(size.width * 0.27, size.height * 0.8), Offset(size.width * 0.27, size.height * 0.2));
    _drawArrow(canvas, Offset(size.width * 0.72, size.height * 0.2), Offset(size.width * 0.72, size.height * 0.8));

    // crossing vessel at right angle
    final crossPaint = Paint()..color = Colors.orange.shade800..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), crossPaint);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()..color = Colors.deepPurple..strokeWidth = 3;
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowSize = 8.0;
    canvas.drawLine(to, Offset(
      to.dx - arrowSize * math.cos(angle - math.pi / 6),
      to.dy - arrowSize * math.sin(angle - math.pi / 6)), paint);
    canvas.drawLine(to, Offset(
      to.dx - arrowSize * math.cos(angle + math.pi / 6),
      to.dy - arrowSize * math.sin(angle + math.pi / 6)), paint);
  }

  @override
  bool shouldRepaint(_TssPainter old) => false;
}

// ── Plachetnice na rôznych/rovnakých vetroch ────────────────────

class _SailboatOppositeTackDiagram extends StatelessWidget {
  final double height;
  const _SailboatOppositeTackDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Stack(children: [
      Positioned(left: 30, top: 50, child: Column(children: [
        _BoatShape(angle: math.pi * 0.15, color: Colors.red.shade700, size: 36),
        const SizedBox(height: 4),
        Text(_t(context, 'Vietr ľavobok\n→ uvoľní cestu',
                'Port tack\n→ gives way'),
            style: const TextStyle(fontSize: 9), textAlign: TextAlign.center),
      ])),
      Positioned(right: 30, top: 50, child: Column(children: [
        _BoatShape(angle: -math.pi * 0.15, color: Colors.green.shade700, size: 36),
        const SizedBox(height: 4),
        Text(_t(context, 'Vietr pravobok\n→ drzí kurz',
                'Starboard tack\n→ stands on'),
            style: const TextStyle(fontSize: 9), textAlign: TextAlign.center),
      ])),
      Positioned(top: 8, left: 0, right: 0, child: Center(
        child: Icon(Icons.air, color: Colors.blue.shade300, size: 20))),
    ]),
  );
}

class _SailboatSameTackDiagram extends StatelessWidget {
  final double height;
  const _SailboatSameTackDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Stack(children: [
      Positioned(left: 40, top: 30, child: Column(children: [
        _BoatShape(color: Colors.red.shade700, size: 32),
        const SizedBox(height: 4),
        Text(_t(context, 'Vetrná strana\n→ uvoľní cestu',
                'Windward boat\n→ gives way'),
            style: const TextStyle(fontSize: 9), textAlign: TextAlign.center),
      ])),
      Positioned(left: 40, bottom: 20, child: Column(children: [
        _BoatShape(color: Colors.green.shade700, size: 32),
        const SizedBox(height: 4),
        Text(_t(context, 'Záveterná strana\n→ drzí kurz',
                'Leeward boat\n→ stands on'),
            style: const TextStyle(fontSize: 9), textAlign: TextAlign.center),
      ])),
      Positioned(top: 8, right: 16, child: Icon(Icons.air, color: Colors.blue.shade300, size: 20)),
    ]),
  );
}

// ── Predbiehanie ─────────────────────────────────────────────

class _OvertakingSectorDiagram extends StatelessWidget {
  final double height;
  const _OvertakingSectorDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(
          size: const Size(220, 140),
          painter: _ConePainter(
            angleDeg: 135, // 2x 67.5
            direction: math.pi / 2,
            color: Colors.orange.withOpacity(0.25),
            length: 110,
          ),
        ),
        Positioned(top: 10, child: _BoatShape(color: Colors.blueGrey.shade700, size: 32)),
        Positioned(bottom: 6, child: Text(
            _t(context, 'Sektor predbiehania (67,5° + 67,5°)',
                'Overtaking sector (67.5° + 67.5°)'),
            style: const TextStyle(fontSize: 10, color: Colors.black54))),
      ]),
    ),
  );
}

// ── Stretnutie proti sobě ────────────────────────────────────

class _HeadOnDiagram extends StatelessWidget {
  final double height;
  const _HeadOnDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Stack(children: [
      Positioned(left: 0, right: 0, top: 16, child: Center(
        child: _BoatShape(angle: math.pi + 0.35, color: Colors.blueGrey.shade700, size: 34))),
      Positioned(left: 0, right: 0, bottom: 16, child: Center(
        child: _BoatShape(angle: -0.35, color: Colors.red.shade700, size: 34))),
      Positioned(left: 8, top: 0, bottom: 0, child: Center(
        child: Transform.rotate(angle: -math.pi/2, child: const Icon(Icons.arrow_forward, color: Colors.green, size: 18)))),
      Positioned(right: 8, top: 0, bottom: 0, child: Center(
        child: Transform.rotate(angle: math.pi/2, child: const Icon(Icons.arrow_forward, color: Colors.green, size: 18)))),
      Positioned(bottom: 4, left: 0, right: 0, child: Center(
        child: Text(_t(context, 'Obe odbočia DOPRAVA', 'Both alter to STARBOARD'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)))),
    ]),
  );
}

// ── Krížiace sa trasy ────────────────────────────────────────

class _CrossingDiagram extends StatelessWidget {
  final double height;
  const _CrossingDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Stack(children: [
      Positioned(left: 30, bottom: 30, child: _BoatShape(
          angle: -math.pi / 4, color: Colors.green.shade700, size: 32)),
      Positioned(right: 30, bottom: 60, child: _BoatShape(
          angle: math.pi * 0.85, color: Colors.red.shade700, size: 32)),
      Positioned(left: 12, bottom: 4, child: Text(
          _t(context, 'A: drzí kurz\n(stand-on)', 'A: stands on\n(stand-on)'),
          style: const TextStyle(fontSize: 9, color: Colors.green))),
      Positioned(right: 12, bottom: 4, child: Text(
          _t(context, 'B: uvoľní cestu\n(give-way)', 'B: keeps clear\n(give-way)'),
          style: const TextStyle(fontSize: 9, color: Colors.red))),
    ]),
  );
}

// ── Hmla / radar avoidance ────────────────────────────────────

class _FogRadarDiagram extends StatelessWidget {
  final double height;
  const _FogRadarDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(
      child: Wrap(
        spacing: 16, runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _miniCase(_t(context, 'Spredu', 'From ahead'), math.pi, true),
          _miniCase(_t(context, 'Ľavobok/za\ntraversom vľavo',
              'Port side/abaft\nthe port beam'), math.pi * 0.75, true),
          _miniCase(_t(context, 'Pravobok/za\ntraversom vpravo',
              'Starboard side/abaft\nthe starboard beam'), -math.pi * 0.75, false),
        ],
      ),
    ),
  );

  Widget _miniCase(String label, double approachAngle, bool turnRight) => Column(
    children: [
      SizedBox(
        width: 70, height: 70,
        child: Stack(alignment: Alignment.center, children: [
          _BoatShape(color: Colors.blueGrey.shade700, size: 26),
          Positioned(
            left: 35 + 28 * math.cos(approachAngle) - 8,
            top: 35 + 28 * math.sin(approachAngle) - 8,
            child: const Icon(Icons.circle, size: 8, color: Colors.red),
          ),
          Positioned(
            bottom: 2,
            child: Icon(turnRight ? Icons.turn_right : Icons.turn_left,
                color: Colors.deepOrange, size: 16),
          ),
        ]),
      ),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9)),
    ],
  );
}

// ── Svetelné sektory ─────────────────────────────────────────

class _LightSectorsDiagram extends StatelessWidget {
  final double height;
  const _LightSectorsDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(
          size: const Size(200, 130),
          painter: _ConePainter(angleDeg: 112.5, direction: -math.pi/2 - (112.5*math.pi/180)/2,
              color: Colors.red.withOpacity(0.35), length: 100),
        ),
        CustomPaint(
          size: const Size(200, 130),
          painter: _ConePainter(angleDeg: 112.5, direction: -math.pi/2 + (112.5*math.pi/180)/2,
              color: Colors.green.withOpacity(0.35), length: 100),
        ),
        Positioned(top: 28, child: _BoatShape(color: Colors.blueGrey.shade700, size: 30)),
      ]),
    ),
  );
}

class _MastheadLightDiagram extends StatelessWidget {
  final double height;
  const _MastheadLightDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(
          size: const Size(220, 140),
          painter: _ConePainter(angleDeg: 225, direction: -math.pi/2,
              color: Colors.amber.withOpacity(0.35), length: 105),
        ),
        Positioned(top: 30, child: _BoatShape(color: Colors.blueGrey.shade700, size: 30)),
      ]),
    ),
  );
}

// ── Lode so svetlami (statické ikony) ───────────────────────

class _LightIconRow extends StatelessWidget {
  final List<({Color color, String label})> lights;
  const _LightIconRow({required this.lights});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: lights.map((l) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 14, height: 14,
          decoration: BoxDecoration(color: l.color, shape: BoxShape.circle,
              border: Border.all(color: Colors.black26))),
        const SizedBox(width: 6),
        Text(l.label, style: const TextStyle(fontSize: 11)),
      ]),
    )).toList(),
  );
}

class _PowerVesselLightsDiagram extends StatelessWidget {
  final double height;
  const _PowerVesselLightsDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.black54)))),
        const SizedBox(height: 30),
        _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      ]),
      const SizedBox(width: 20),
      _LightIconRow(lights: [
        (color: Colors.white, label: _t(context, 'Stožárové (vpredu)', 'Masthead (forward)')),
        (color: Colors.green, label: _t(context, 'Pravobok (zelené)', 'Starboard (green)')),
        (color: Colors.red, label: _t(context, 'Ľavobok (červené)', 'Port (red)')),
        (color: Colors.white, label: _t(context, 'Záďové (biele)', 'Stern (white)')),
      ]),
    ])),
  );
}

class _SailboatLightsDiagram extends StatelessWidget {
  final double height;
  const _SailboatLightsDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      const SizedBox(width: 20),
      _LightIconRow(lights: [
        (color: Colors.green, label: _t(context, 'Pravobok (zelené)', 'Starboard (green)')),
        (color: Colors.red, label: _t(context, 'Ľavobok (červené)', 'Port (red)')),
        (color: Colors.white, label: _t(context, 'Záďové (biele)', 'Stern (white)')),
      ]),
    ])),
  );
}

class _TrawlerLightsDiagram extends StatelessWidget {
  final double height;
  const _TrawlerLightsDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      const SizedBox(width: 20),
      _LightIconRow(lights: [
        (color: Colors.green, label: _t(context, 'Zelené (vrchné)', 'Green (upper)')),
        (color: Colors.white, label: _t(context, 'Biele (spodné)', 'White (lower)')),
        (color: Colors.green, label: _t(context, 'Pravobok', 'Starboard')),
        (color: Colors.red, label: _t(context, 'Ľavobok', 'Port')),
      ]),
    ])),
  );
}

class _FishingLightsDiagram extends StatelessWidget {
  final double height;
  const _FishingLightsDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      const SizedBox(width: 20),
      _LightIconRow(lights: [
        (color: Colors.red, label: _t(context, 'Červené (vrchné)', 'Red (upper)')),
        (color: Colors.white, label: _t(context, 'Biele (spodné)', 'White (lower)')),
        (color: Colors.green, label: _t(context, 'Pravobok', 'Starboard')),
        (color: Colors.red, label: _t(context, 'Ľavobok', 'Port')),
      ]),
    ])),
  );
}

class _NotUnderCommandDiagram extends StatelessWidget {
  final double height;
  const _NotUnderCommandDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      const SizedBox(width: 20),
      _LightIconRow(lights: [
        (color: Colors.red, label: _t(context, 'Červené (vrchné)', 'Red (upper)')),
        (color: Colors.red, label: _t(context, 'Červené (spodné)', 'Red (lower)')),
      ]),
    ])),
  );
}

class _RestrictedManeuverDiagram extends StatelessWidget {
  final double height;
  const _RestrictedManeuverDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      const SizedBox(width: 20),
      _LightIconRow(lights: [
        (color: Colors.red, label: _t(context, 'Červené', 'Red')),
        (color: Colors.white, label: _t(context, 'Biele', 'White')),
        (color: Colors.red, label: _t(context, 'Červené', 'Red')),
      ]),
    ])),
  );
}

class _DraftConstrainedDiagram extends StatelessWidget {
  final double height;
  const _DraftConstrainedDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      const SizedBox(width: 20),
      _LightIconRow(lights: [
        (color: Colors.red, label: _t(context, 'Červené (1)', 'Red (1)')),
        (color: Colors.red, label: _t(context, 'Červené (2)', 'Red (2)')),
        (color: Colors.red, label: _t(context, 'Červené (3)', 'Red (3)')),
      ]),
    ])),
  );
}

class _AnchoredVesselDiagram extends StatelessWidget {
  final double height;
  const _AnchoredVesselDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Stack(alignment: Alignment.center, children: [
      _BoatShape(color: Colors.blueGrey.shade800, size: 50),
      Positioned(top: 10, child: Container(width: 12, height: 12,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(color: Colors.black54))))),
      Positioned(bottom: 38, child: Container(width: 10, height: 10,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(color: Colors.black54))))),
    ])),
  );
}

class _TowingLightsDiagram extends StatelessWidget {
  final double height;
  const _TowingLightsDiagram({required this.height});
  @override
  Widget build(BuildContext context) => _DiagramFrame(
    height: height,
    child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Column(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const SizedBox(height: 3),
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const SizedBox(height: 16),
        _BoatShape(color: Colors.blueGrey.shade800, size: 40),
      ]),
      Container(width: 40, height: 1, color: Colors.black38,
          margin: const EdgeInsets.symmetric(horizontal: 4)),
      _BoatShape(color: Colors.blueGrey.shade400, size: 32),
    ])),
  );
}
