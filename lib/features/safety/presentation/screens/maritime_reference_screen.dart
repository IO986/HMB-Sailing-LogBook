import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';

class MaritimeReferenceScreen extends StatelessWidget {
  const MaritimeReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.maritimeReference),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l.phonetic),
              Tab(text: l.flagAlphabet),
              Tab(text: l.dayShapes),
              Tab(text: 'Morse'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PhoneticTab(),
            _FlagTab(),
            _DayShapesTab(),
            _MorseTab(),
          ],
        ),
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────

const _alphabet = [
  (letter: 'A', nato: 'Alpha',    morse: '·−',     flagColors: [Colors.white, Colors.blue],     flagDesc: 'Diver down – keep clear'),
  (letter: 'B', nato: 'Bravo',    morse: '−···',   flagColors: [Colors.red],                    flagDesc: 'Dangerous goods on board'),
  (letter: 'C', nato: 'Charlie',  morse: '−·−·',   flagColors: [Colors.blue, Colors.white, Colors.red, Colors.white, Colors.blue], flagDesc: 'Yes / Affirmative'),
  (letter: 'D', nato: 'Delta',    morse: '−··',    flagColors: [Colors.blue, Colors.yellow, Colors.red], flagDesc: 'Keep clear – maneuvering with difficulty'),
  (letter: 'E', nato: 'Echo',     morse: '·',      flagColors: [Colors.blue],                   flagDesc: 'Altering course to starboard'),
  (letter: 'F', nato: 'Foxtrot',  morse: '··−·',   flagColors: [Colors.white, Colors.red, Colors.white], flagDesc: 'I am disabled – communicate with me'),
  (letter: 'G', nato: 'Golf',     morse: '−−·',    flagColors: [Colors.yellow, Colors.blue],    flagDesc: 'I require a pilot'),
  (letter: 'H', nato: 'Hotel',    morse: '····',   flagColors: [Colors.white, Colors.red],      flagDesc: 'Pilot on board'),
  (letter: 'I', nato: 'India',    morse: '··',     flagColors: [Colors.yellow, Colors.black],   flagDesc: 'Altering course to port'),
  (letter: 'J', nato: 'Juliet',   morse: '·−−−',   flagColors: [Colors.blue, Colors.white],     flagDesc: 'Fire & dangerous cargo – keep clear'),
  (letter: 'K', nato: 'Kilo',     morse: '−·−',    flagColors: [Colors.blue, Colors.yellow],    flagDesc: 'I wish to communicate'),
  (letter: 'L', nato: 'Lima',     morse: '·−··',   flagColors: [Colors.yellow, Colors.black],   flagDesc: 'Stop your vessel instantly'),
  (letter: 'M', nato: 'Mike',     morse: '−−',     flagColors: [Colors.white, Colors.blue],     flagDesc: 'My vessel is stopped'),
  (letter: 'N', nato: 'November', morse: '−·',     flagColors: [Colors.blue, Colors.white],     flagDesc: 'No / Negative'),
  (letter: 'O', nato: 'Oscar',    morse: '−−−',    flagColors: [Colors.red, Colors.yellow],     flagDesc: 'Man overboard'),
  (letter: 'P', nato: 'Papa',     morse: '·−−·',   flagColors: [Colors.blue, Colors.white],     flagDesc: 'All aboard – departing to sea'),
  (letter: 'Q', nato: 'Quebec',   morse: '−−·−',   flagColors: [Colors.yellow],                 flagDesc: 'Vessel healthy – free pratique requested'),
  (letter: 'R', nato: 'Romeo',    morse: '·−·',    flagColors: [Colors.red, Colors.yellow, Colors.red], flagDesc: '(No standard ICS meaning)'),
  (letter: 'S', nato: 'Sierra',   morse: '···',    flagColors: [Colors.white, Colors.blue],     flagDesc: 'Engines full astern'),
  (letter: 'T', nato: 'Tango',    morse: '−',      flagColors: [Colors.red, Colors.white, Colors.red], flagDesc: 'Engaged in pair trawling – keep clear'),
  (letter: 'U', nato: 'Uniform',  morse: '··−',    flagColors: [Colors.red, Colors.white],      flagDesc: 'You are running into danger'),
  (letter: 'V', nato: 'Victor',   morse: '···−',   flagColors: [Colors.white, Colors.red],      flagDesc: 'I require assistance'),
  (letter: 'W', nato: 'Whiskey',  morse: '·−−',    flagColors: [Colors.red, Colors.white],      flagDesc: 'I require medical assistance'),
  (letter: 'X', nato: 'X-ray',    morse: '−··−',   flagColors: [Colors.blue, Colors.white],     flagDesc: 'Stop – watch for my signals'),
  (letter: 'Y', nato: 'Yankee',   morse: '−·−−',   flagColors: [Colors.yellow, Colors.red],     flagDesc: 'Dragging anchor'),
  (letter: 'Z', nato: 'Zulu',     morse: '−−··',   flagColors: [Colors.black, Colors.yellow],   flagDesc: 'I require a tug'),
];

// ── Phonetic Alphabet Tab ─────────────────────────────────────────

class _PhoneticTab extends StatelessWidget {
  const _PhoneticTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _alphabet.length,
      itemBuilder: (ctx, i) {
        final entry = _alphabet[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(entry.letter,
                      style: const TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry.nato, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(entry.morse, style: const TextStyle(fontSize: 13, color: Colors.grey, letterSpacing: 2)),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ── Flag Alphabet Tab ─────────────────────────────────────────────

class _FlagTab extends StatelessWidget {
  const _FlagTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _alphabet.length,
      itemBuilder: (ctx, i) {
        final entry = _alphabet[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              // Flag representation
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 52, height: 36,
                  child: _buildFlag(entry.flagColors),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.letter} – ${entry.nato}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(entry.flagDesc,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildFlag(List<Color> colors) {
    if (colors.length == 1) {
      return Container(color: colors[0]);
    }
    return Row(
      children: colors.map((c) => Expanded(child: Container(color: c))).toList(),
    );
  }
}

// ── Day Shapes Tab ─────────────────────────────────────────────────

const _dayShapes = [
  (
    shape: 'ball',
    title: 'Black ball (sphere)',
    rule: 'Rule 30',
    desc: 'Vessel at anchor.\nBall displayed at the bow.',
  ),
  (
    shape: 'ball-ball',
    title: 'Two balls vertical',
    rule: 'Rule 27(a)',
    desc: 'Not Under Command (NUC).\nUnable to maneuver due to exceptional circumstances.',
  ),
  (
    shape: 'ball-diamond-ball',
    title: 'Ball – Diamond – Ball',
    rule: 'Rule 28',
    desc: 'Vessel constrained by her draught.',
  ),
  (
    shape: 'diamond',
    title: 'Diamond',
    rule: 'Rule 24',
    desc: 'Tow longer than 200 m.\nDisplayed by both towing vessel and towed vessel.',
  ),
  (
    shape: 'cone-up',
    title: 'Cone apex downward',
    rule: 'Rule 25',
    desc: 'Sailing vessel also using engine.\nMust display cone with apex pointing down.',
  ),
  (
    shape: 'cones-apexes',
    title: 'Two cones apex together',
    rule: 'Rule 26',
    desc: 'Fishing vessel with nets, lines or trawls extending more than 150 m.',
  ),
  (
    shape: 'cylinder',
    title: 'Cylinder',
    rule: 'Rule 29',
    desc: 'Pilot vessel engaged on pilotage duty.',
  ),
  (
    shape: 'ball-ball-ball',
    title: 'Three balls vertical',
    rule: 'Rule 30(d)',
    desc: 'Vessel aground. Three balls displayed in a vertical line.',
  ),
];

class _DayShapesTab extends StatelessWidget {
  const _DayShapesTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _dayShapes.length,
      itemBuilder: (ctx, i) {
        final s = _dayShapes[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              SizedBox(
                width: 52, height: 68,
                child: _DayShapePainter(shapeCode: s.shape),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(s.rule, style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(s.desc, style: const TextStyle(fontSize: 12, height: 1.3)),
                ],
              )),
            ]),
          ),
        );
      },
    );
  }
}

class _DayShapePainter extends StatelessWidget {
  final String shapeCode;
  const _DayShapePainter({required this.shapeCode});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapePainter(shapeCode),
      size: const Size(52, 68),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final String code;
  const _ShapePainter(this.code);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    switch (code) {
      case 'ball':
        canvas.drawCircle(Offset(cx, h / 2), 11, paint);
      case 'ball-ball':
        canvas.drawCircle(Offset(cx, h * 0.28), 10, paint);
        canvas.drawCircle(Offset(cx, h * 0.72), 10, paint);
      case 'ball-diamond-ball':
        canvas.drawCircle(Offset(cx, h * 0.12), 8, paint);
        _drawDiamond(canvas, cx, h * 0.5, 10, paint);
        canvas.drawCircle(Offset(cx, h * 0.88), 8, paint);
      case 'diamond':
        _drawDiamond(canvas, cx, h / 2, 12, paint);
      case 'cone-up':
        _drawConeDown(canvas, cx, h / 2, 13, paint);
      case 'cones-apexes':
        _drawConeDown(canvas, cx, h * 0.3, 10, paint);
        _drawConeUp(canvas, cx, h * 0.7, 10, paint);
      case 'cylinder':
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, h / 2), width: 22, height: 28), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, h / 2 - 14), width: 22, height: 8), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, h / 2 + 14), width: 22, height: 8), paint);
      case 'ball-ball-ball':
        canvas.drawCircle(Offset(cx, h * 0.18), 9, paint);
        canvas.drawCircle(Offset(cx, h * 0.5), 9, paint);
        canvas.drawCircle(Offset(cx, h * 0.82), 9, paint);
    }
  }

  void _drawDiamond(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 0.7, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r * 0.7, cy)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawConeDown(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path()
      ..moveTo(cx - r, cy - r * 0.8)
      ..lineTo(cx + r, cy - r * 0.8)
      ..lineTo(cx, cy + r * 0.8)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawConeUp(Canvas canvas, double cx, double cy, double r, Paint p) {
    final path = Path()
      ..moveTo(cx, cy - r * 0.8)
      ..lineTo(cx + r, cy + r * 0.8)
      ..lineTo(cx - r, cy + r * 0.8)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ShapePainter old) => old.code != code;
}

// ── Morse Code Tab ────────────────────────────────────────────────

const _morseNumbers = [
  (char: '0', morse: '−−−−−'),
  (char: '1', morse: '·−−−−'),
  (char: '2', morse: '··−−−'),
  (char: '3', morse: '···−−'),
  (char: '4', morse: '····−'),
  (char: '5', morse: '·····'),
  (char: '6', morse: '−····'),
  (char: '7', morse: '−−···'),
  (char: '8', morse: '−−−··'),
  (char: '9', morse: '−−−−·'),
];

class _MorseTab extends StatelessWidget {
  const _MorseTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOS highlight
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              const Text('SOS – DISTRESS SIGNAL',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: '... --- ...'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SOS copied')));
                },
                child: const Text('· · ·   − − −   · · ·',
                    style: TextStyle(color: Colors.yellow, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)),
              ),
              const SizedBox(height: 4),
              const Text('500 kHz  ·  2182 kHz  ·  VHF Ch 16',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ),

          // Letters
          _MorseSection(title: 'Letters', items: _alphabet.map((e) => (char: e.letter, morse: e.morse)).toList()),
          const SizedBox(height: 12),
          // Numbers
          _MorseSection(title: 'Numbers', items: _morseNumbers.map((e) => (char: e.char, morse: e.morse)).toList()),
        ],
      ),
    );
  }
}

class _MorseSection extends StatelessWidget {
  final String title;
  final List<({String char, String morse})> items;
  const _MorseSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(title, style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13,
              color: Theme.of(context).colorScheme.primary)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.8,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final e = items[i];
            return Card(
              elevation: 0.5,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(e.char, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(e.morse, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.5)),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}
