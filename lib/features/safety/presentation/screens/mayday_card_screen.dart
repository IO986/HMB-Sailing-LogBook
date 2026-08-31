import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';

class MaydayCardScreen extends ConsumerStatefulWidget {
  const MaydayCardScreen({super.key});

  @override
  ConsumerState<MaydayCardScreen> createState() => _MaydayCardScreenState();
}

class _MaydayCardScreenState extends ConsumerState<MaydayCardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
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
    _loadSavedData();
    _callSign.addListener(_saveCallSign);
    _mmsi.addListener(_saveMmsi);
    _vesselName.addListener(_saveVesselName);
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedCallSign = prefs.getString('vessel_call_sign') ?? '';
    final savedMmsi = prefs.getString('vessel_mmsi') ?? '';
    setState(() {
      _callSign.text = savedCallSign;
      _mmsi.text = savedMmsi;
    });
    // Load vessel name from most recent charter, fall back to prefs
    try {
      final db = ref.read(databaseProvider);
      final charters = await db.getAllCharters();
      if (charters.isNotEmpty && mounted) {
        final name = charters.first.vesselName ?? '';
        if (name.isNotEmpty) {
          setState(() => _vesselName.text = name);
          return;
        }
      }
    } catch (_) {}
    final savedName = prefs.getString('vessel_name') ?? '';
    if (savedName.isNotEmpty && mounted) {
      setState(() => _vesselName.text = savedName);
    }
  }

  Future<void> _saveCallSign() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vessel_call_sign', _callSign.text);
  }

  Future<void> _saveMmsi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vessel_mmsi', _mmsi.text);
  }

  Future<void> _saveVesselName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vessel_name', _vesselName.text);
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
          tabs: [
            Tab(text: AppLocalizations.of(context).dscProcedure, icon: const Icon(Icons.radio)),
            Tab(text: AppLocalizations.of(context).voiceScript, icon: const Icon(Icons.record_voice_over)),
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
    _callSign.removeListener(_saveCallSign);
    _mmsi.removeListener(_saveMmsi);
    _vesselName.removeListener(_saveVesselName);
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

  List<({String num, String text})> _buildSteps(AppLocalizations l) => [
    (num: '1', text: l.dscStep1),
    (num: '2', text: l.dscStep2),
    (num: '3', text: l.dscStep3),
    (num: '4', text: l.dscStep4),
    (num: '5', text: l.dscStep5),
    (num: '6', text: l.dscStep6),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = _buildSteps(l);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.dscWarningUseOnly,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(l.dscWarningDanger,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(l.dscWarningTypes,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(l.dscProcedure, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(l.dscProcedureSubtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),

        ...steps.asMap().entries.map((e) {
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
          label: Text(AppLocalizations.of(context).reset),
        ),
      ],
    );
  }
}

// ── Typ volania ───────────────────────────────────────────────

/// Tri stupne rádiovej komunikácie v tiesni — appka ich rozlišuje len
/// prefixom skriptu a vysvetľujúcou poznámkou, procedúra DSC (tab vyššie)
/// ostáva len pre MAYDAY.
enum DistressCallType {
  mayday('MAYDAY'),
  panPan('PAN PAN'),
  securite('SÉCURITÉ');

  final String word;
  const DistressCallType(this.word);

  /// Trojité zvolanie, ako sa vysiela na kanáli 16.
  String get repeated => '$word, $word, $word';

  String label(AppLocalizations l) => switch (this) {
        DistressCallType.mayday => l.distressCallMayday,
        DistressCallType.panPan => l.distressCallPanPan,
        DistressCallType.securite => l.distressCallSecurite,
      };

  String note(AppLocalizations l) => switch (this) {
        DistressCallType.mayday => l.distressNoteMayday,
        DistressCallType.panPan => l.distressNotePanPan,
        DistressCallType.securite => l.distressNoteSecurite,
      };

  /// "I REQUIRE IMMEDIATE ASSISTANCE" má zmysel len pri skutočnej tiesni.
  String? assistanceLine(AppLocalizations l) => switch (this) {
        DistressCallType.mayday => 'I REQUIRE IMMEDIATE ASSISTANCE',
        DistressCallType.panPan => 'I REQUIRE ASSISTANCE',
        DistressCallType.securite => null,
      };
}

// ── Hlasový skript ────────────────────────────────────────────

class _VoiceScript extends StatefulWidget {
  final TextEditingController vesselName, callSign, mmsi;
  final TextEditingController position, distress, persons, otherInfo;

  const _VoiceScript({
    required this.vesselName, required this.callSign, required this.mmsi,
    required this.position, required this.distress, required this.persons,
    required this.otherInfo,
  });

  @override
  State<_VoiceScript> createState() => _VoiceScriptState();
}

class _VoiceScriptState extends State<_VoiceScript> {
  DistressCallType _type = DistressCallType.mayday;

  TextEditingController get vesselName => widget.vesselName;
  TextEditingController get callSign => widget.callSign;
  TextEditingController get mmsi => widget.mmsi;
  TextEditingController get position => widget.position;
  TextEditingController get distress => widget.distress;
  TextEditingController get persons => widget.persons;
  TextEditingController get otherInfo => widget.otherInfo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<DistressCallType>(
          segments: [
            for (final t in DistressCallType.values)
              ButtonSegment(value: t, label: Text(t.label(l))),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),
        const SizedBox(height: 8),
        Text(_type.note(l),
            style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
        const SizedBox(height: 10),

        Text(l.fillBeforeSailing,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(child: _Field(ctrl: vesselName, label: l.vesselNameLabel, hint: 'e.g. ALEGRIA')),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: callSign, label: 'Call Sign', hint: '9A...')),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Field(ctrl: mmsi, label: 'MMSI', hint: '9 digits', keyboard: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _Field(ctrl: persons, label: l.numberOfPersons, hint: 'e.g. 6', keyboard: TextInputType.number)),
        ]),
        const SizedBox(height: 8),
        _Field(ctrl: distress, label: l.distressNature, hint: 'SINKING / FIRE / MOB'),
        const SizedBox(height: 8),
        _Field(ctrl: otherInfo, label: l.additionalInfo, hint: 'Vessel type, hull colour...'),
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
                Expanded(
                  child: Text(l.voiceScriptTitleFor(_type.word),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,
                          fontSize: 15, letterSpacing: 1)),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                  tooltip: l.copyTooltip,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _buildScript()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.scriptCopied)));
                  },
                ),
              ]),
              const Divider(color: Colors.white30),
              const SizedBox(height: 8),
              _ScriptLine(_type.repeated),
              const SizedBox(height: 8),
              _ScriptLine('THIS IS  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}'),
              const SizedBox(height: 4),
              _ScriptLine('CALL SIGN: ${callSign.text.isNotEmpty ? callSign.text.toUpperCase() : "____________"}  '
                  '·  MMSI: ${mmsi.text.isNotEmpty ? mmsi.text : "___________"}'),
              const SizedBox(height: 8),
              _ScriptLine('${_type.word}  ·  '
                  '${vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : "___________"}'),
              const SizedBox(height: 4),
              _ScriptLine('CALL SIGN: ${callSign.text.isNotEmpty ? callSign.text.toUpperCase() : "____________"}  '
                  '·  MMSI: ${mmsi.text.isNotEmpty ? mmsi.text : "___________"}'),
              const SizedBox(height: 8),
              _ScriptLine('MY POSITION IS:'),
              _PositionLine(ctrl: position, enterAbove: l.enterAbove),
              const SizedBox(height: 8),
              _ScriptLine('WE ARE  ${distress.text.isNotEmpty ? distress.text.toUpperCase() : "[DISTRESS]"}'),
              if (_type.assistanceLine(l) != null) ...[
                const SizedBox(height: 4),
                _ScriptLine(_type.assistanceLine(l)!),
              ],
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
        Text(
          l.sendOnCh16,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _buildScript() {
    final l = AppLocalizations.of(context);
    final v = vesselName.text.isNotEmpty ? vesselName.text.toUpperCase() : '___________';
    final cs = callSign.text.isNotEmpty ? callSign.text.toUpperCase() : '____________';
    final m = mmsi.text.isNotEmpty ? mmsi.text : '___________';
    final pos = position.text.isNotEmpty ? position.text : '[POSITION]';
    final d = distress.text.isNotEmpty ? distress.text.toUpperCase() : '[DISTRESS]';
    final p = persons.text.isNotEmpty ? persons.text : '___';
    final assistance = _type.assistanceLine(l);
    return '${_type.repeated}\n\n'
        'THIS IS $v, $v, $v\n'
        'CALL SIGN: $cs  ·  MMSI: $m\n\n'
        '${_type.word} $v\n'
        'CALL SIGN: $cs  ·  MMSI: $m\n\n'
        'MY POSITION IS: $pos\n\n'
        'WE ARE $d\n'
        '${assistance != null ? "$assistance\n\n" : ""}'
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
  final String enterAbove;
  const _PositionLine({required this.ctrl, required this.enterAbove});
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
      widget.ctrl.text.isNotEmpty ? widget.ctrl.text.toUpperCase() : widget.enterAbove,
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
