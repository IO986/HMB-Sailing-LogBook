import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/models/skipper_profile.dart';
import '../../../../core/providers/skipper_profile_provider.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';
import '../../../../shared/widgets/tracking_interval_selector.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class CharterPrefill {
  final String title;
  final DateTime dateFrom;
  final DateTime dateTo;
  const CharterPrefill({required this.title, required this.dateFrom, required this.dateTo});
}

/// Jeden riadok posádky vo formulári. skipperName/crewNames v DB sa z tohto
/// zoznamu odvodzujú (SB obrazovka a PDF export ich čítajú po starom),
/// plný detail vrátane preukazov ide do Charters.crewJson.
class _CrewEntry {
  final nameCtrl = TextEditingController();
  final boatLicCtrl = TextEditingController();
  final radioLicCtrl = TextEditingController();
  final otherCertsCtrl = TextEditingController();
  bool isSkipper;
  _CrewEntry({this.isSkipper = false});
  void dispose() {
    nameCtrl.dispose();
    boatLicCtrl.dispose();
    radioLicCtrl.dispose();
    otherCertsCtrl.dispose();
  }
}

String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

class CharterEditScreen extends ConsumerStatefulWidget {
  final String? charterId;
  final CharterPrefill? prefill;
  final bool popOnCreate;
  const CharterEditScreen({super.key, this.charterId, this.prefill, this.popOnCreate = false});

  @override
  ConsumerState<CharterEditScreen> createState() => _CharterEditScreenState();
}

class _CharterEditScreenState extends ConsumerState<CharterEditScreen> {
  // ── Plavidlo ──
  final _titleCtrl = TextEditingController();
  final _vesselCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  String? _vesselType;
  bool _typeOther = false;
  final _vesselTypeCustomCtrl = TextEditingController();
  final _callsignCtrl = TextEditingController();
  final _mmsiCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  // ── Parametre jachty ──
  final _lengthCtrl = TextEditingController();
  final _beamCtrl = TextEditingController();
  final _draftCtrl = TextEditingController();
  final _berthsCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _waterTankCtrl = TextEditingController();
  final _fuelTankCtrl = TextEditingController();
  final _engineHoursStartCtrl = TextEditingController();
  final _engineHoursEndCtrl = TextEditingController();

  // ── Kde & kedy ──
  final _homePortCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now().add(const Duration(days: 7));

  // ── Posádka / fotky ──
  final List<_CrewEntry> _crew = [];
  final List<String> _photos = [];

  // ── Kontakty chartru (max 3, telefónne čísla) ──
  final List<TextEditingController> _contactCtrls = [];

  final _notesCtrl = TextEditingController();
  bool _loading = false;
  Charter? _existing;
  int _logInterval = 60;

  bool get _isNew => widget.charterId == null;

  @override
  void initState() {
    super.initState();
    _crew.add(_CrewEntry(isSkipper: true));
    if (!_isNew) {
      _loadCharter();
    } else {
      if (widget.prefill != null) {
        _titleCtrl.text = widget.prefill!.title;
        _dateFrom = widget.prefill!.dateFrom;
        _dateTo = widget.prefill!.dateTo;
      }
      _prefillSkipperFromProfile();
    }
  }

  /// Pri novej plavbe sa užívateľ rozhodne, či doplniť uložené údaje
  /// skippera (meno, preukazy, certifikácie — ukladajú sa pri každom
  /// uložení plavby), alebo začať s prázdnym skipperom.
  Future<void> _prefillSkipperFromProfile() async {
    final profile = await ref.read(skipperProfileProvider.future);
    if (!mounted) return;
    final hasSaved = profile.fullName.isNotEmpty ||
        profile.licenseNumber.isNotEmpty ||
        profile.vhfNumber.isNotEmpty ||
        profile.otherCerts.isNotEmpty;
    if (!hasSaved) return;

    final l = AppLocalizations.of(context);
    final fill = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.prefillSkipperTitle),
        content: Text(profile.fullName),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.prefillSkipperNew),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.prefillSkipperFill),
          ),
        ],
      ),
    );
    if (fill != true || !mounted) return;

    setState(() {
      final skipper = _crew.first;
      skipper.nameCtrl.text = profile.fullName;
      skipper.boatLicCtrl.text = [profile.licenseType, profile.licenseNumber]
          .where((s) => s.isNotEmpty)
          .join(' ');
      skipper.radioLicCtrl.text = profile.vhfNumber;
      skipper.otherCertsCtrl.text = profile.otherCerts;
    });
  }

  Future<void> _loadCharter() async {
    final db = ref.read(databaseProvider);
    final id = int.tryParse(widget.charterId!);
    if (id == null) return;
    final c = await db.getCharterById(id);
    if (c == null || !mounted) return;
    setState(() {
      _existing = c;
      _titleCtrl.text = c.title;
      _vesselCtrl.text = c.vesselName ?? '';
      _modelCtrl.text = c.vesselModel ?? '';
      _vesselType = c.vesselType;
      // Hodnota mimo štandardných chipov (aj legacy voľný text) → "Iné"
      final lNow = AppLocalizations.of(context);
      final standardTypes = {
        lNow.vesselTypeSailboat,
        lNow.vesselTypeCatamaran,
        lNow.vesselTypeMotorBoat,
      };
      if ((c.vesselType?.isNotEmpty ?? false) &&
          !standardTypes.contains(c.vesselType)) {
        _typeOther = true;
        _vesselTypeCustomCtrl.text = c.vesselType!;
      }
      _callsignCtrl.text = c.callsign ?? '';
      _mmsiCtrl.text = c.mmsi ?? '';
      _companyCtrl.text = c.charterCompany ?? '';
      _lengthCtrl.text = c.vesselLengthM?.toString() ?? '';
      _beamCtrl.text = c.vesselBeamM?.toString() ?? '';
      _draftCtrl.text = c.vesselDraftM?.toString() ?? '';
      _berthsCtrl.text = c.berths?.toString() ?? '';
      _yearCtrl.text = c.yearBuilt?.toString() ?? '';
      _engineCtrl.text = c.engine ?? '';
      _waterTankCtrl.text = c.waterTankL != null ? _fmtNum(c.waterTankL!) : '';
      _fuelTankCtrl.text = c.fuelTankL != null ? _fmtNum(c.fuelTankL!) : '';
      _engineHoursStartCtrl.text = c.engineHoursStart?.toString() ?? '';
      _engineHoursEndCtrl.text = c.engineHoursEnd?.toString() ?? '';
      _homePortCtrl.text = c.homePort ?? '';
      _countryCtrl.text = c.country ?? '';
      _areaCtrl.text = c.cruisingArea ?? '';
      _dateFrom = c.dateFrom;
      _dateTo = c.dateTo;
      _notesCtrl.text = c.notes ?? '';

      // Posádka: primárne crewJson, fallback na staré skipperName/crewNames
      for (final e in _crew) e.dispose();
      _crew.clear();
      final crewList = _decodeMapList(c.crewJson);
      if (crewList.isNotEmpty) {
        for (final m in crewList) {
          final e = _CrewEntry(isSkipper: m['role'] == 'skipper');
          e.nameCtrl.text = m['name'] as String? ?? '';
          e.boatLicCtrl.text = m['boatLicence'] as String? ?? '';
          e.radioLicCtrl.text = m['radioLicence'] as String? ?? '';
          e.otherCertsCtrl.text = m['otherCerts'] as String? ?? '';
          _crew.add(e);
        }
      } else {
        final skipper = _CrewEntry(isSkipper: true);
        skipper.nameCtrl.text = c.skipperName ?? '';
        _crew.add(skipper);
        for (final n in (c.crewNames ?? '')
            .split('|')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)) {
          final e = _CrewEntry();
          e.nameCtrl.text = n;
          _crew.add(e);
        }
      }
      if (_crew.isEmpty) _crew.add(_CrewEntry(isSkipper: true));
      if (!_crew.any((e) => e.isSkipper)) _crew.first.isSkipper = true;

      // Fotky
      _photos
        ..clear()
        ..addAll(_decodeStringList(c.photosJson));

      // Kontakty chartru
      for (final ctrl in _contactCtrls) ctrl.dispose();
      _contactCtrls
        ..clear()
        ..addAll(_decodeStringList(c.contactsJson)
            .map((s) => TextEditingController(text: s)));
    });
  }

  static List<String> _decodeStringList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return (jsonDecode(json) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static List<Map<String, dynamic>> _decodeMapList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return (jsonDecode(json) as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l.newMultidayVoyage : l.editCharter),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l.voyageNameRequired,
              prefixIcon: const Icon(Icons.sailing),
            ),
          ),
          const SizedBox(height: 20),

          // ── PLAVIDLO ─────────────────────────────────────────
          _Section(l.vessel),
          TextField(
            controller: _vesselCtrl,
            decoration: InputDecoration(
              labelText: '${l.vesselName} *',
              prefixIcon: const Icon(Icons.directions_boat),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelCtrl,
            decoration: InputDecoration(
              labelText: l.vesselModel,
              prefixIcon: const Icon(Icons.category),
            ),
          ),
          const SizedBox(height: 12),
          Text(l.vesselType,
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).hintColor)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in [
                l.vesselTypeSailboat,
                l.vesselTypeCatamaran,
                l.vesselTypeMotorBoat,
              ])
                ChoiceChip(
                  label: Text(t),
                  selected: !_typeOther && _vesselType == t,
                  onSelected: (_) => setState(() {
                    _typeOther = false;
                    _vesselType = t;
                  }),
                ),
              ChoiceChip(
                label: Text(l.vesselTypeOther),
                selected: _typeOther,
                onSelected: (_) => setState(() => _typeOther = true),
              ),
            ],
          ),
          if (_typeOther) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _vesselTypeCustomCtrl,
              decoration: InputDecoration(
                labelText: l.vesselType,
                isDense: true,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(
              controller: _callsignCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l.callsign,
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: _mmsiCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l.mmsi,
              ),
            )),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _companyCtrl,
            decoration: InputDecoration(
              labelText: l.charterCompanyLabel,
              prefixIcon: const Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 20),

          // ── KONTAKTY CHARTRU ─────────────────────────────────
          _Section(l.charterContactsSection),
          Text(l.charterContactsHint,
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
          ..._contactCtrls.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: e.value,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l.addPhoneNumber,
                        prefixIcon: const Icon(Icons.call),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      e.value.dispose();
                      _contactCtrls.removeAt(e.key);
                    }),
                  ),
                ]),
              )),
          if (_contactCtrls.length < 3)
            _DashedAddButton(
              label: l.addPhoneNumber,
              onTap: () => setState(
                  () => _contactCtrls.add(TextEditingController())),
            ),
          const SizedBox(height: 20),

          // ── PARAMETRE JACHTY ─────────────────────────────────
          _Section(l.yachtParamsSection),
          Row(children: [
            Expanded(child: _numField(_lengthCtrl, l.vesselLengthM, suffix: 'm')),
            const SizedBox(width: 12),
            Expanded(child: _numField(_beamCtrl, l.vesselBeamM, suffix: 'm')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _numField(_draftCtrl, l.vesselDraftM, suffix: 'm')),
            const SizedBox(width: 8),
            Expanded(child: _numField(_berthsCtrl, l.berthsLabel, integer: true)),
            const SizedBox(width: 8),
            Expanded(child: _numField(_yearCtrl, l.yearBuiltLabel, integer: true)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _engineCtrl,
            decoration: InputDecoration(
              labelText: l.engineLabel,
              prefixIcon: const Icon(Icons.settings),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _numField(
                _engineHoursStartCtrl, l.engineHoursStartLabel, suffix: 'h')),
            const SizedBox(width: 12),
            Expanded(child: _numField(
                _engineHoursEndCtrl, l.engineHoursEndLabel, suffix: 'h')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _numField(_waterTankCtrl, l.waterTankLabel, suffix: 'L')),
            const SizedBox(width: 12),
            Expanded(child: _numField(_fuelTankCtrl, l.fuelTankLabel, suffix: 'L')),
          ]),
          const SizedBox(height: 20),

          // ── KDE & KEDY ───────────────────────────────────────
          _Section(l.whereWhenSection),
          Row(children: [
            Expanded(child: TextField(
              controller: _homePortCtrl,
              decoration: InputDecoration(
                labelText: l.homePort,
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: _countryCtrl,
              decoration: InputDecoration(
                labelText: l.countryLabel,
              ),
            )),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _areaCtrl,
            decoration: InputDecoration(
              labelText: l.cruisingAreaLabel,
              prefixIcon: const Icon(Icons.map_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _dateField(l.dateFrom, _dateFrom, () => _pickDate(true))),
            const SizedBox(width: 12),
            Expanded(child: _dateField(l.dateTo, _dateTo, () => _pickDate(false))),
          ]),
          const SizedBox(height: 20),

          // ── POSÁDKA ──────────────────────────────────────────
          _Section(l.crew),
          Text(l.crewSectionHint,
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
          ..._crew.asMap().entries.map((e) => _crewCard(e.key, e.value, l)),
          _DashedAddButton(
            label: l.addCrewMember,
            onTap: () => setState(() => _crew.add(_CrewEntry())),
          ),
          const SizedBox(height: 20),

          // ── FOTKY PLAVIDLA ───────────────────────────────────
          _Section(l.vesselPhotosSection),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in _photos)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(p),
                            width: 110, height: 110, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () => setState(() => _photos.remove(p)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ]),
                  ),
                if (_photos.length < 3)
                  InkWell(
                    onTap: _addPhoto,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context).dividerColor,
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_camera_outlined, size: 28),
                          const SizedBox(height: 4),
                          Text(l.addPhotoLabel,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Log interval iba pri vytváraní nového chartera cez tracking flow
          if (_isNew) ...[
            _Section(l.logFrequency),
            TrackingIntervalSelector(
              value: _logInterval,
              onChanged: (v) => setState(() => _logInterval = v),
            ),
            const SizedBox(height: 20),
          ],

          _Section(l.notesLabel),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '${l.notesLabel}...',
              prefixIcon: const Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _save,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(
                _isNew ? l.createVoyageButton : l.saveVoyageButton,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label,
      {String? suffix, bool integer = false, bool dense = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: integer
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: integer ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: dense ? null : label,
        suffixText: suffix,
        isDense: dense,
      ),
    );
  }

  Widget _dateField(String label, DateTime value, VoidCallback onTap) {
    final fmt = DateFormat('d. M. yyyy');
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: label, prefixIcon: const Icon(Icons.calendar_today)),
        child: Text(fmt.format(value)),
      ),
    );
  }

  Widget _crewCard(int index, _CrewEntry entry, AppLocalizations l) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: entry.isSkipper
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: primary, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(
              controller: entry.nameCtrl,
              decoration: InputDecoration(
                labelText: l.crewNameLabel,
                isDense: true,
              ),
            )),
            const SizedBox(width: 8),
            // Odznak: ťuknutie spraví z člena skippera (ostatní -> crew)
            InkWell(
              onTap: () => setState(() {
                for (final e in _crew) {
                  e.isSkipper = false;
                }
                entry.isSkipper = true;
              }),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: entry.isSkipper ? primary : null,
                  border: entry.isSkipper
                      ? null
                      : Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    entry.isSkipper
                        ? Icons.directions_boat_filled
                        : Icons.person_outline,
                    size: 16,
                    color: entry.isSkipper
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.isSkipper ? l.skipperBadge : l.crewBadge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: entry.isSkipper
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                  ),
                ]),
              ),
            ),
            if (_crew.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => setState(() {
                  entry.dispose();
                  _crew.removeAt(index);
                  if (!_crew.any((e) => e.isSkipper) && _crew.isNotEmpty) {
                    _crew.first.isSkipper = true;
                  }
                }),
              ),
          ]),
          if (entry.isSkipper) ...[
            const SizedBox(height: 8),
            TextField(
              controller: entry.boatLicCtrl,
              decoration: InputDecoration(
                labelText: l.boatLicenceLabel,
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: entry.radioLicCtrl,
              decoration: InputDecoration(
                labelText: l.radioLicenceLabel,
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: entry.otherCertsCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l.skipperOtherCerts,
                isDense: true,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Foto'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galéria'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    try {
      final picked = await ImagePicker()
          .pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (picked == null) return;
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/vessel_photos');
      await dir.create(recursive: true);
      final file = File(
          '${dir.path}/vessel_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(picked.path).copy(file.path);
      if (mounted) setState(() => _photos.add(file.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isFrom ? _dateFrom : _dateTo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (d == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = d;
        if (_dateTo.isBefore(_dateFrom)) _dateTo = _dateFrom.add(const Duration(days: 7));
      } else {
        _dateTo = d;
      }
    });
  }

  double? _parseDouble(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.trim().replaceAll(',', '.'));
  int? _parseInt(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());
  String? _emptyNull(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_titleCtrl.text.trim().isEmpty && _vesselCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.enterVoyageName)));
      return;
    }
    // Názov plavby: keď je prázdny, odvoď z lode + dátumu
    final title = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : '${_vesselCtrl.text.trim()} ${DateFormat('d.M.yyyy').format(_dateFrom)}';

    setState(() => _loading = true);
    final db = ref.read(databaseProvider);

    final skipper = _crew.where((e) => e.isSkipper).firstOrNull;
    final others = _crew
        .where((e) => !e.isSkipper)
        .map((e) => e.nameCtrl.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final crewJson = jsonEncode([
      for (final e in _crew)
        if (e.nameCtrl.text.trim().isNotEmpty)
          {
            'name': e.nameCtrl.text.trim(),
            'role': e.isSkipper ? 'skipper' : 'crew',
            'boatLicence': _emptyNull(e.boatLicCtrl.text),
            'radioLicence': _emptyNull(e.radioLicCtrl.text),
            'otherCerts': _emptyNull(e.otherCertsCtrl.text),
          }
    ]);

    // Údaje skippera sa uložia ako predvoľba pre budúce plavby (nahrádza
    // zrušený Profil skippera v Nastaveniach). Best-effort: na niektorých
    // zariadeniach vie flutter_secure_storage (EncryptedSharedPreferences)
    // na read/write zamrznúť natrvalo — voyage save sa na tom nesmie zaseknúť.
    if (skipper != null && skipper.nameCtrl.text.trim().isNotEmpty) {
      try {
        final old = await ref
            .read(skipperProfileProvider.future)
            .timeout(const Duration(seconds: 5));
        await ref
            .read(skipperProfileProvider.notifier)
            .save(SkipperProfile(
              fullName: skipper.nameCtrl.text.trim(),
              licenseType: old.licenseType,
              licenseNumber: skipper.boatLicCtrl.text.trim(),
              licenseAuthority: old.licenseAuthority,
              licenseExpiry: old.licenseExpiry,
              vhfNumber: skipper.radioLicCtrl.text.trim(),
              vhfExpiry: old.vhfExpiry,
              otherCerts: skipper.otherCertsCtrl.text.trim(),
            ))
            .timeout(const Duration(seconds: 5));
      } on TimeoutException catch (_) {
        // skipper profile cache is best-effort; voyage data must still save
      }
    }

    final companion = ChartersCompanion(
      id: _existing != null ? Value(_existing!.id) : const Value.absent(),
      title: Value(title),
      dateFrom: Value(_dateFrom),
      dateTo: Value(_dateTo),
      vesselName: Value(_emptyNull(_vesselCtrl.text)),
      vesselModel: Value(_emptyNull(_modelCtrl.text)),
      vesselType: Value(
          _typeOther ? _emptyNull(_vesselTypeCustomCtrl.text) : _vesselType),
      callsign: Value(_emptyNull(_callsignCtrl.text)),
      mmsi: Value(_emptyNull(_mmsiCtrl.text)),
      charterCompany: Value(_emptyNull(_companyCtrl.text)),
      vesselLengthM: Value(_parseDouble(_lengthCtrl.text)),
      vesselBeamM: Value(_parseDouble(_beamCtrl.text)),
      vesselDraftM: Value(_parseDouble(_draftCtrl.text)),
      berths: Value(_parseInt(_berthsCtrl.text)),
      yearBuilt: Value(_parseInt(_yearCtrl.text)),
      engine: Value(_emptyNull(_engineCtrl.text)),
      waterTankL: Value(_parseDouble(_waterTankCtrl.text)),
      fuelTankL: Value(_parseDouble(_fuelTankCtrl.text)),
      engineHoursStart: Value(_parseDouble(_engineHoursStartCtrl.text)),
      engineHoursEnd: Value(_parseDouble(_engineHoursEndCtrl.text)),
      homePort: Value(_emptyNull(_homePortCtrl.text)),
      country: Value(_emptyNull(_countryCtrl.text)),
      cruisingArea: Value(_emptyNull(_areaCtrl.text)),
      photosJson: Value(_photos.isEmpty ? null : jsonEncode(_photos)),
      contactsJson: Value(_contactPhones.isEmpty ? null : jsonEncode(_contactPhones)),
      crewJson: Value(crewJson),
      skipperName: Value(_emptyNull(skipper?.nameCtrl.text ?? '')),
      crewNames: Value(others.isEmpty ? null : others.join('|')),
      notes: Value(_emptyNull(_notesCtrl.text)),
      safetyBriefingDone: _existing != null
          ? Value(_existing!.safetyBriefingDone)
          : const Value(false),
      createdAt: Value(_existing?.createdAt ?? DateTime.now()),
    );

    if (_existing != null) {
      await db.updateCharter(companion);
      ref.invalidate(chartersProvider);
      setState(() => _loading = false);
      if (mounted) context.go('/logbook/${_existing!.id}');
    } else {
      final charter = await db.insertCharter(companion);
      ref.invalidate(chartersProvider);
      // Ulož zvolený log interval pre briefing screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pending_log_interval', _logInterval);
      setState(() => _loading = false);
      if (widget.popOnCreate) {
        if (mounted) Navigator.pop(context, charter);
      } else {
        if (mounted) context.go('/logbook/${charter.id}');
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _vesselCtrl.dispose(); _modelCtrl.dispose();
    _callsignCtrl.dispose(); _mmsiCtrl.dispose(); _companyCtrl.dispose();
    _lengthCtrl.dispose(); _beamCtrl.dispose(); _draftCtrl.dispose();
    _berthsCtrl.dispose(); _yearCtrl.dispose(); _engineCtrl.dispose();
    _waterTankCtrl.dispose(); _fuelTankCtrl.dispose();
    _engineHoursStartCtrl.dispose(); _engineHoursEndCtrl.dispose();
    _homePortCtrl.dispose(); _countryCtrl.dispose(); _areaCtrl.dispose();
    _notesCtrl.dispose(); _vesselTypeCustomCtrl.dispose();
    for (final c in _crew) c.dispose();
    for (final c in _contactCtrls) c.dispose();
    super.dispose();
  }

  List<String> get _contactPhones => _contactCtrls
      .map((c) => c.text.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            )),
  );
}

/// Tlačidlo "+ Pridať ..." s čiarkovaným okrajom ako v predlohe.
class _DashedAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DashedAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, size: 18, color: primary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
