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
  (letter: 'A', nato: 'Alpha',    morse: '·−',     flagColors: [Colors.white, Colors.blue],
    flagDescEn: 'Diver down – keep clear',               flagDescSk: 'Potápač pod hladinou – nepribližujte sa',
    flagDescDe: 'Taucher im Wasser – Abstand halten',    flagDescEs: 'Buceador en el agua – manténgase alejado',
    flagDescUk: 'Водолаз під водою – тримайтесь осторонь'),
  (letter: 'B', nato: 'Bravo',    morse: '−···',   flagColors: [Colors.red],
    flagDescEn: 'Dangerous goods on board',              flagDescSk: 'Na palube nebezpečný náklad',
    flagDescDe: 'Gefährliche Güter an Bord',             flagDescEs: 'Mercancías peligrosas a bordo',
    flagDescUk: 'Небезпечний вантаж на борту'),
  (letter: 'C', nato: 'Charlie',  morse: '−·−·',   flagColors: [Colors.blue, Colors.white, Colors.red, Colors.white, Colors.blue],
    flagDescEn: 'Yes / Affirmative',                     flagDescSk: 'Áno / Súhlasím',
    flagDescDe: 'Ja / Affirmativ',                       flagDescEs: 'Sí / Afirmativo',
    flagDescUk: 'Так / Стверджую'),
  (letter: 'D', nato: 'Delta',    morse: '−··',    flagColors: [Colors.blue, Colors.yellow, Colors.red],
    flagDescEn: 'Keep clear – maneuvering with difficulty', flagDescSk: 'Drž sa ďalej – problémy s manévrovaním',
    flagDescDe: 'Abstand halten – Manövrierfähigkeit eingeschränkt', flagDescEs: 'Manténgase alejado – dificultades de maniobra',
    flagDescUk: 'Тримайтесь осторонь – труднощі з маневруванням'),
  (letter: 'E', nato: 'Echo',     morse: '·',      flagColors: [Colors.blue],
    flagDescEn: 'Altering course to starboard',          flagDescSk: 'Mením kurz doprava',
    flagDescDe: 'Kursänderung nach Steuerbord',          flagDescEs: 'Cambiando rumbo a estribor',
    flagDescUk: 'Змінюю курс на правий борт'),
  (letter: 'F', nato: 'Foxtrot',  morse: '··−·',   flagColors: [Colors.white, Colors.red, Colors.white],
    flagDescEn: 'I am disabled – communicate with me',   flagDescSk: 'Som imobilný – kontaktujte ma',
    flagDescDe: 'Manövrierunfähig – bitte Verbindung aufnehmen', flagDescEs: 'Estoy averiado – comuníquese conmigo',
    flagDescUk: 'Я нерухомий – зв\'яжіться зі мною'),
  (letter: 'G', nato: 'Golf',     morse: '−−·',    flagColors: [Colors.yellow, Colors.blue],
    flagDescEn: 'I require a pilot',                     flagDescSk: 'Potrebujem lodného pilota',
    flagDescDe: 'Lotse erforderlich',                    flagDescEs: 'Necesito práctico',
    flagDescUk: 'Потрібен лоцман'),
  (letter: 'H', nato: 'Hotel',    morse: '····',   flagColors: [Colors.white, Colors.red],
    flagDescEn: 'Pilot on board',                        flagDescSk: 'Lodný pilot na palube',
    flagDescDe: 'Lotse an Bord',                         flagDescEs: 'Práctico a bordo',
    flagDescUk: 'Лоцман на борту'),
  (letter: 'I', nato: 'India',    morse: '··',     flagColors: [Colors.yellow, Colors.black],
    flagDescEn: 'Altering course to port',               flagDescSk: 'Mením kurz doľava',
    flagDescDe: 'Kursänderung nach Backbord',            flagDescEs: 'Cambiando rumbo a babor',
    flagDescUk: 'Змінюю курс на лівий борт'),
  (letter: 'J', nato: 'Juliet',   morse: '·−−−',   flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'Fire & dangerous cargo – keep clear',   flagDescSk: 'Požiar a nebezpečný náklad – drž sa ďalej',
    flagDescDe: 'Feuer und gefährliche Ladung – Abstand halten', flagDescEs: 'Fuego y carga peligrosa – manténgase alejado',
    flagDescUk: 'Пожежа та небезпечний вантаж – тримайтесь осторонь'),
  (letter: 'K', nato: 'Kilo',     morse: '−·−',    flagColors: [Colors.blue, Colors.yellow],
    flagDescEn: 'I wish to communicate',                 flagDescSk: 'Chcem komunikovať',
    flagDescDe: 'Ich möchte kommunizieren',              flagDescEs: 'Deseo comunicarme',
    flagDescUk: 'Хочу зв\'язатися'),
  (letter: 'L', nato: 'Lima',     morse: '·−··',   flagColors: [Colors.yellow, Colors.black],
    flagDescEn: 'Stop your vessel instantly',             flagDescSk: 'Okamžite zastavte svoju loď',
    flagDescDe: 'Schiff sofort stoppen',                 flagDescEs: 'Detenga su barco inmediatamente',
    flagDescUk: 'Негайно зупиніть судно'),
  (letter: 'M', nato: 'Mike',     morse: '−−',     flagColors: [Colors.white, Colors.blue],
    flagDescEn: 'My vessel is stopped',                  flagDescSk: 'Moja loď stojí',
    flagDescDe: 'Mein Schiff liegt still',               flagDescEs: 'Mi barco está parado',
    flagDescUk: 'Моє судно стоїть'),
  (letter: 'N', nato: 'November', morse: '−·',     flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'No / Negative',                         flagDescSk: 'Nie / Nesúhlasím',
    flagDescDe: 'Nein / Negativ',                        flagDescEs: 'No / Negativo',
    flagDescUk: 'Ні / Негативно'),
  (letter: 'O', nato: 'Oscar',    morse: '−−−',    flagColors: [Colors.red, Colors.yellow],
    flagDescEn: 'Man overboard',                         flagDescSk: 'Muž cez palubu',
    flagDescDe: 'Mann über Bord',                        flagDescEs: 'Hombre al agua',
    flagDescUk: 'Людина за бортом'),
  (letter: 'P', nato: 'Papa',     morse: '·−−·',   flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'All aboard – departing to sea',          flagDescSk: 'Všetci na palube – odplávam na more',
    flagDescDe: 'Alle an Bord – Abfahrt auf See',        flagDescEs: 'Todos a bordo – zarpo al mar',
    flagDescUk: 'Всі на борту – відпливаю в море'),
  (letter: 'Q', nato: 'Quebec',   morse: '−−·−',   flagColors: [Colors.yellow],
    flagDescEn: 'Vessel healthy – free pratique requested', flagDescSk: 'Loď je zdravá – žiadam voľný prístup',
    flagDescDe: 'Schiff gesund – bitte freie Einfahrt',  flagDescEs: 'Barco sano – solicito libre plática',
    flagDescUk: 'Судно здорове – прошу вільного доступу'),
  (letter: 'R', nato: 'Romeo',    morse: '·−·',    flagColors: [Colors.red, Colors.yellow, Colors.red],
    flagDescEn: '(No standard ICS meaning)',              flagDescSk: '(Bez štandardného ICS významu)',
    flagDescDe: '(Keine ICS-Standardbedeutung)',          flagDescEs: '(Sin significado ICS estándar)',
    flagDescUk: '(Немає стандартного значення ICS)'),
  (letter: 'S', nato: 'Sierra',   morse: '···',    flagColors: [Colors.white, Colors.blue],
    flagDescEn: 'Engines full astern',                   flagDescSk: 'Motory plnou cúvaním',
    flagDescDe: 'Maschinen volle Kraft zurück',           flagDescEs: 'Máquinas a toda marcha atrás',
    flagDescUk: 'Машини на повний задній хід'),
  (letter: 'T', nato: 'Tango',    morse: '−',      flagColors: [Colors.red, Colors.white, Colors.red],
    flagDescEn: 'Engaged in pair trawling – keep clear', flagDescSk: 'Lovím sieťami – drž sa ďalej',
    flagDescDe: 'Schleppnetzfischerei – Abstand halten', flagDescEs: 'Pesca de arrastre – manténgase alejado',
    flagDescUk: 'Веду парне тралення – тримайтесь осторонь'),
  (letter: 'U', nato: 'Uniform',  morse: '··−',    flagColors: [Colors.red, Colors.white],
    flagDescEn: 'You are running into danger',            flagDescSk: 'Smerujete do nebezpečenstva',
    flagDescDe: 'Sie steuern in Gefahr',                 flagDescEs: 'Va en dirección al peligro',
    flagDescUk: 'Ви прямуєте в небезпеку'),
  (letter: 'V', nato: 'Victor',   morse: '···−',   flagColors: [Colors.white, Colors.red],
    flagDescEn: 'I require assistance',                  flagDescSk: 'Potrebujem pomoc',
    flagDescDe: 'Ich benötige Hilfe',                    flagDescEs: 'Necesito asistencia',
    flagDescUk: 'Потрібна допомога'),
  (letter: 'W', nato: 'Whiskey',  morse: '·−−',    flagColors: [Colors.red, Colors.white],
    flagDescEn: 'I require medical assistance',           flagDescSk: 'Potrebujem lekársku pomoc',
    flagDescDe: 'Ich benötige ärztliche Hilfe',          flagDescEs: 'Necesito asistencia médica',
    flagDescUk: 'Потрібна медична допомога'),
  (letter: 'X', nato: 'X-ray',    morse: '−··−',   flagColors: [Colors.blue, Colors.white],
    flagDescEn: 'Stop – watch for my signals',           flagDescSk: 'Zastavte – čakajte na moje signály',
    flagDescDe: 'Stopp – auf meine Signale warten',      flagDescEs: 'Pare – espere mis señales',
    flagDescUk: 'Стоп – чекайте моїх сигналів'),
  (letter: 'Y', nato: 'Yankee',   morse: '−·−−',   flagColors: [Colors.yellow, Colors.red],
    flagDescEn: 'Dragging anchor',                       flagDescSk: 'Kotva sa vlečie',
    flagDescDe: 'Anker schleppt',                        flagDescEs: 'Garreo de ancla',
    flagDescUk: 'Якір тягнеться'),
  (letter: 'Z', nato: 'Zulu',     morse: '−−··',   flagColors: [Colors.black, Colors.yellow],
    flagDescEn: 'I require a tug',                       flagDescSk: 'Potrebujem remorkér',
    flagDescDe: 'Schlepper erforderlich',                flagDescEs: 'Necesito remolcador',
    flagDescUk: 'Потрібен буксир'),
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
                  Text(
                    switch (Localizations.localeOf(context).languageCode) {
                      'sk' => entry.flagDescSk,
                      'de' => entry.flagDescDe,
                      'es' => entry.flagDescEs,
                      'uk' => entry.flagDescUk,
                      _    => entry.flagDescEn,
                    },
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
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
              Container(
                width: 52, height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E4F0),
                  borderRadius: BorderRadius.circular(6),
                ),
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

class _MorseTab extends StatefulWidget {
  const _MorseTab();
  @override
  State<_MorseTab> createState() => _MorseTabState();
}

class _MorseTabState extends State<_MorseTab> {
  final _ctrl = TextEditingController();
  String _morse = '';

  static final _morseMap = {
    for (final e in _alphabet) e.letter: e.morse,
    for (final e in _morseNumbers) e.char: e.morse,
  };

  void _convert(String text) {
    final result = text.toUpperCase().split('').map((c) {
      if (c == ' ') return '/';
      return _morseMap[c] ?? '?';
    }).join('  ');
    setState(() => _morse = result);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Prevodník ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Prevodník text → Morse',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 10),
                TextField(
                  controller: _ctrl,
                  onChanged: _convert,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Zadajte text...',
                    prefixIcon: Icon(Icons.keyboard),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _morse.isEmpty ? '· · ·' : _morse,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      letterSpacing: 2,
                      color: _morse.isEmpty ? Colors.white24 : Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),

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
