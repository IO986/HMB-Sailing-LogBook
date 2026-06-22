import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MaydayCardScreen extends StatefulWidget {
  const MaydayCardScreen({super.key});

  @override
  State<MaydayCardScreen> createState() => _MaydayCardScreenState();
}

class _MaydayCardScreenState extends State<MaydayCardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  // Polia pre vyplnenie
  final _vesselName = TextEditingController();
  final _callSign = TextEditingController();
  final _mmsi = TextEditingController();
  final _position = TextEditingController();
  final _distress = TextEditingController(text: 'SINKING');
  final _persons = TextEditingController();
  final _otherInfo = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mayday Card'),
        backgroundColor: Colors.red.shade800,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'DSC POSTUP', icon: Icon(Icons.radio)),
            Tab(text: 'HLAS SKRIPT', icon: Icon(Icons.record_voice_over)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _DscProcedure(),
          _VoiceScript(
            vesselName: _vesselName,
            callSign: _callSign,
            mmsi: _mmsi,
            position: _position,
            distress: _distress,
            persons: _persons,
            otherInfo: _otherInfo,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _vesselName.dispose(); _callSign.dispose(); _mmsi.dispose();
    _position.dispose(); _distress.dispose(); _persons.dispose();
    _otherInfo.dispose();
    super.dispose();
  }
}

// ── DSC Postup ────────────────────────────────────────────────

class _DscProcedure extends StatefulWidget {
  @override
  State<_DscProcedure> createState() => _DscProcedureState();
}

class _DscProcedureState extends State<_DscProcedure> {
  final Set<int> _done = {};

  static const _steps = [
    (num: '1', text: 'Uistite sa, že rádio je zapnuté.'),
    (num: '2', text: 'Otvorte kryt nad ČERVENÝM tlačidlom tiesne.'),
    (num: '3', text: 'Stlačte ČERVENÉ tlačidlo RAZ a uvoľnite.'),
    (num: '4', text: 'Vyberte povahu tiesne.\n(Požiar, Potápanie, MOB a pod.)\nAk vynecháte, odošle sa Neoznačená tieseň.'),
    (num: '5', text: 'Stlačte a PODRŽTE ČERVENÉ tlačidlo po dobu 5 sekúnd na odoslanie výzvy.'),
    (num: '6', text: 'Čakajte max. 15 sekúnd na potvrdenie (zobrazí sa na obrazovke), potom pošlite hlasovú správu na Kanáli 16 na VYSOKÝ výkon.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚠️ POUŽÍVAŤ IBA V PRÍPADE',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('VÁŽNEHO A BEZPROSTREDNÉHO NEBEZPEČENSTVA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text('Požiar · Potápanie · Muž cez palubu',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('DSC POSTUP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text('Uchovajte tento postup pri VHF DSC rádiu',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),

        ..._steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          final isDone = _done.contains(i);
          return GestureDetector(
            onTap: () => setState(() {
              if (isDone) _done.remove(i); else _done.add(i);
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDone ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDone ? Colors.green.shade300 : Colors.red.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? Colors.green : Colors.red.shade700,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(step.num,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(step.text,
                          style: TextStyle(
                            fontSize: 14, height: 1.4,
                            color: isDone ? Colors.green.shade800 : Colors.red.shade900,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() => _done.clear()),
          icon: const Icon(Icons.refresh),
          label: const Text('Resetovať'),
        ),
      ],
    );
  }
}

// ── Hlasový skript ────────────────────────────────────────────

class _VoiceScript extends StatelessWidget {
  final TextEditingController vesselName, callSign, mmsi;
  final TextEditingController position, distress, persons, otherInfo;

  const _VoiceScript({
    required this.vesselName, required this.callSign, required this.mmsi,
    required this.position, required this.distress, required this.persons,
    required this.otherInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vstupné polia
        const Text('Vyplňte pred plavbou:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(child: _Field(ctrl: vesselName, label: 'Názov lode', hint: 'napr. ALEGRIA')),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: callSign, label: 'Call Sign', hint: '9A...')),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Field(ctrl: mmsi, label: 'MMSI', hint: '9 číslic', keyboard: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: persons, label: 'Počet osôb', hint: 'napr. 6', keyboard: TextInputType.number)),
        ]),
        const SizedBox(height: 8),
        _Field(ctrl: distress, label: 'Povaha tiesne', hint: 'SINKING / FIRE / MOB'),
        const SizedBox(height: 8),
        _Field(ctrl: otherInfo, label: 'Ďalšie info', hint: 'Typ lode, farba trupu...'),
        const SizedBox(height: 16),

        // Skript
        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                  child: Text('HLASOVÝ MAYDAY SKRIPT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                          fontSize: 15, letterSpacing: 1)),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                  tooltip: 'Kopírovať',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _buildScript()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Skript skopírovaný')));
                  },
                ),
              ]),
              const Divider(color: Colors.white30),
              const SizedBox(height: 8),
              _ScriptLine('MAYDAY, MAYDAY, MAYDAY'),
              const SizedBox(height: 8),
              _ScriptLine('THIS IS  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}'),
              const SizedBox(height: 4),
              _ScriptLine('CALL SIGN: ${callSign.text.isNotEmpty ? callSign.text.toUpperCase() : "____________"}  '
                  '·  MMSI: ${mmsi.text.isNotEmpty ? mmsi.text : "___________"}'),
              const SizedBox(height: 8),
              _ScriptLine('MAYDAY  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}'),
              const SizedBox(height: 4),
              _ScriptLine('CALL SIGN: ${callSign.text.isNotEmpty ? callSign.text.toUpperCase() : "____________"}  '
                  '·  MMSI: ${mmsi.text.isNotEmpty ? mmsi.text : "___________"}'),
              const SizedBox(height: 8),
              _ScriptLine('MY POSITION IS:'),
              _PositionLine(ctrl: position),
              const SizedBox(height: 8),
              _ScriptLine('WE ARE  ${distress.text.isNotEmpty ? distress.text.toUpperCase() : "[POVAHA TIESNE]"}'),
              const SizedBox(height: 4),
              _ScriptLine('I REQUIRE IMMEDIATE ASSISTANCE'),
              const SizedBox(height: 8),
              _ScriptLine('WE HAVE  ${persons.text.isNotEmpty ? persons.text : "___"}  PERSONS ON BOARD'),
              const SizedBox(height: 4),
              if (otherInfo.text.isNotEmpty)
                _ScriptLine(otherInfo.text.toUpperCase()),
              const SizedBox(height: 8),
              const _ScriptLine('OVER'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '📻 Odoslať na Kanáli 16 · Vysoký výkon · Opakovať každé 2 minúty ak bez odpovede',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _buildScript() {
    final v = vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : '___________';
    final cs = callSign.text.isNotEmpty ? callSign.text.toUpperCase() : '____________';
    final m = mmsi.text.isNotEmpty ? mmsi.text : '___________';
    final pos = position.text.isNotEmpty ? position.text : '[POLOHA]';
    final d = distress.text.isNotEmpty ? distress.text.toUpperCase() : '[POVAHA TIESNE]';
    final p = persons.text.isNotEmpty ? persons.text : '___';
    return 'MAYDAY, MAYDAY, MAYDAY\n\n'
        'THIS IS $v, $v, $v\n'
        'CALL SIGN: $cs  ·  MMSI: $m\n\n'
        'MAYDAY $v\n'
        'CALL SIGN: $cs  ·  MMSI: $m\n\n'
        'MY POSITION IS: $pos\n\n'
        'WE ARE $d\n'
        'I REQUIRE IMMEDIATE ASSISTANCE\n\n'
        'WE HAVE $p PERSONS ON BOARD\n'
        '${otherInfo.text.isNotEmpty ? otherInfo.text.toUpperCase() + "\n" : ""}\n'
        'OVER';
  }
}

class _ScriptLine extends StatelessWidget {
  final String text;
  const _ScriptLine(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: Colors.white, fontSize: 14,
          fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 0.3));
}

class _PositionLine extends StatefulWidget {
  final TextEditingController ctrl;
  const _PositionLine({required this.ctrl});
  @override
  State<_PositionLine> createState() => _PositionLineState();
}

class _PositionLineState extends State<_PositionLine> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(() => setState(() {}));
  }
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      widget.ctrl.text.isNotEmpty ? widget.ctrl.text.toUpperCase() : '[zadaj v polí vyššie]',
      style: TextStyle(
          color: widget.ctrl.text.isNotEmpty ? Colors.yellow : Colors.white38,
          fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

class _Field extends StatefulWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final TextInputType? keyboard;
  const _Field({required this.ctrl, required this.label,
      required this.hint, this.keyboard});
  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(() => setState(() {}));
  }
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.ctrl,
    keyboardType: widget.keyboard,
    textCapitalization: TextCapitalization.characters,
    decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
  );
}
