import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/marine_instrument_data.dart';
import '../../../../core/models/skipper_profile.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/night_mode_provider.dart';
import '../../../../core/providers/raymarine_providers.dart';
import '../../../../core/providers/skipper_profile_provider.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/raymarine_connection_service.dart';
import '../../../../core/services/udp_receiver_service.dart';
import '../../../../core/services/units_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import '../../../help/presentation/screens/user_guide_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settingsTitle)),
      body: unitsAsync.when(
        data: (units) {
          final l = AppLocalizations.of(context);
          return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(l.onlineAccount),
            const _AccountSection(),
            const SizedBox(height: 16),

            _Section(l.measurementUnits),
            Card(child: Column(children: [
              ListTile(
                leading: const Icon(Icons.thermostat),
                title: Text(l.temperature),
                trailing: SegmentedButton<TempUnit>(
                  segments: const [
                    ButtonSegment(value: TempUnit.celsius, label: Text('°C')),
                    ButtonSegment(value: TempUnit.fahrenheit, label: Text('°F')),
                  ],
                  selected: {units.temp},
                  onSelectionChanged: (s) =>
                      ref.read(unitsProvider.notifier).setTemp(s.first),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.waves),
                title: Text(l.depthWaves),
                trailing: SegmentedButton<DepthUnit>(
                  segments: const [
                    ButtonSegment(value: DepthUnit.meters, label: Text('m')),
                    ButtonSegment(value: DepthUnit.feet, label: Text('ft')),
                  ],
                  selected: {units.depth},
                  onSelectionChanged: (s) =>
                      ref.read(unitsProvider.notifier).setDepth(s.first),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.air),
                title: Text(l.wind),
                trailing: SegmentedButton<WindUnit>(
                  segments: const [
                    ButtonSegment(value: WindUnit.knots, label: Text('kn')),
                    ButtonSegment(value: WindUnit.ms, label: Text('m/s')),
                    ButtonSegment(value: WindUnit.beaufort, label: Text('Bft')),
                  ],
                  selected: {units.wind},
                  onSelectionChanged: (s) =>
                      ref.read(unitsProvider.notifier).setWind(s.first),
                ),
              ),
            ])),
            const SizedBox(height: 16),

            _Section(l.marineInstrumentsTitle),
            const _RaymarineSection(),
            const SizedBox(height: 16),

            _Section(l.language),
            Card(child: ListTile(
              leading: const Text('🌐', style: TextStyle(fontSize: 22)),
              title: Text(l.appLanguage),
              subtitle: Text(_currentLangName(ref.watch(localeProvider).languageCode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, ref),
            )),
            const SizedBox(height: 16),

            _Section(l.displaySettings),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.nightlight_round),
                title: Text(l.nightMode),
                subtitle: Text(l.nightModeDesc),
                value: ref.watch(nightModeProvider),
                onChanged: (_) => ref.read(nightModeProvider.notifier).toggle(),
              ),
            ),
            const SizedBox(height: 16),

            _Section(l.skipperProfile),
            const _SkipperCardSection(),
            const SizedBox(height: 16),

            _Section(l.vesselIdTitle),
            const _VesselIdSection(),
            const SizedBox(height: 16),

            _Section(l.backupSection),
            const _BackupSection(),
            const SizedBox(height: 16),

            _Section(l.aboutApp),
            Card(child: Column(children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l.userGuide),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const UserGuideScreen())),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l.aboutApp),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context),
              ),
            ])),
          ],
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  static const _langs = [
    ('🇸🇰', 'Slovenčina', 'sk'),
    ('🇬🇧', 'English', 'en'),
    ('🇩🇪', 'Deutsch', 'de'),
    ('🇪🇸', 'Español', 'es'),
    ('🇺🇦', 'Українська', 'uk'),
  ];

  String _currentLangName(String code) {
    for (final l in _langs) {
      if (l.$3 == code) return l.$2;
    }
    return 'Slovenčina';
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final current = ref.read(localeProvider).languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).languageDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _langs.map((l) => ListTile(
            leading: Text(l.$1, style: const TextStyle(fontSize: 24)),
            title: Text(l.$2),
            trailing: l.$3 == current
                ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(l.$3);
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AboutDialog(
        applicationName: 'HMB Sailing Log',
        applicationVersion: 'v${info.version} (build ${info.buildNumber})',
        applicationIcon: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/icons/app_icon.png',
              width: 56, height: 56,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.sailing, size: 56)),
        ),
        applicationLegalese: '© 2026 LacoSte©\nAll rights reserved',
        children: [
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).appDescription,
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          const _AboutRow(Icons.gps_fixed, 'GPS tracking with auto-entries'),
          const _AboutRow(Icons.book, 'Multi-day charter logbook'),
          const _AboutRow(Icons.map, 'Offline nautical maps (OpenSeaMap)'),
          const _AboutRow(Icons.cloud, 'Marine weather (Open-Meteo)'),
          const _AboutRow(Icons.picture_as_pdf, 'Export PDF + GPX'),
          const _AboutRow(Icons.shield, 'Safety briefing & Mayday Card'),
          const SizedBox(height: 16),
          const Text('Author: LacoSte©',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Version: ${info.version} (${info.buildNumber})',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Platform: Flutter / Android',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Vessel ID Section ─────────────────────────────────────────

class _VesselIdSection extends StatefulWidget {
  const _VesselIdSection();
  @override
  State<_VesselIdSection> createState() => _VesselIdSectionState();
}

class _VesselIdSectionState extends State<_VesselIdSection> {
  final _callSignCtrl = TextEditingController();
  final _mmsiCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _callSignCtrl.text = prefs.getString('vessel_call_sign') ?? '';
      _mmsiCtrl.text = prefs.getString('vessel_mmsi') ?? '';
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vessel_call_sign', _callSignCtrl.text.trim());
    await prefs.setString('vessel_mmsi', _mmsiCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).saved)));
    }
  }

  @override
  void dispose() {
    _callSignCtrl.dispose();
    _mmsiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_loaded) return const Card(child: Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.vesselIdHint, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(
                controller: _callSignCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: 'Call Sign', hintText: '9A...', isDense: true),
              )),
              const SizedBox(width: 12),
              Expanded(child: TextField(
                controller: _mmsiCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'MMSI', hintText: '9 digits', isDense: true),
              )),
            ]),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _save,
                child: Text(l.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skipper Card Section ──────────────────────────────────────

class _SkipperCardSection extends ConsumerStatefulWidget {
  const _SkipperCardSection();
  @override
  ConsumerState<_SkipperCardSection> createState() => _SkipperCardSectionState();
}

class _SkipperCardSectionState extends ConsumerState<_SkipperCardSection> {
  final _nameCtrl = TextEditingController();
  final _licTypeCtrl = TextEditingController();
  final _licNumCtrl = TextEditingController();
  final _licAuthCtrl = TextEditingController();
  final _licExpiryCtrl = TextEditingController();
  final _vhfNumCtrl = TextEditingController();
  final _vhfExpiryCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ref.read(skipperProfileProvider.future);
    if (!mounted) return;
    setState(() {
      _nameCtrl.text = profile.fullName;
      _licTypeCtrl.text = profile.licenseType;
      _licNumCtrl.text = profile.licenseNumber;
      _licAuthCtrl.text = profile.licenseAuthority;
      _licExpiryCtrl.text = profile.licenseExpiry;
      _vhfNumCtrl.text = profile.vhfNumber;
      _vhfExpiryCtrl.text = profile.vhfExpiry;
      _otherCtrl.text = profile.otherCerts;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    await ref.read(skipperProfileProvider.notifier).save(SkipperProfile(
      fullName: _nameCtrl.text.trim(),
      licenseType: _licTypeCtrl.text.trim(),
      licenseNumber: _licNumCtrl.text.trim(),
      licenseAuthority: _licAuthCtrl.text.trim(),
      licenseExpiry: _licExpiryCtrl.text.trim(),
      vhfNumber: _vhfNumCtrl.text.trim(),
      vhfExpiry: _vhfExpiryCtrl.text.trim(),
      otherCerts: _otherCtrl.text.trim(),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).saved)));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _licTypeCtrl.dispose();
    _licNumCtrl.dispose();
    _licAuthCtrl.dispose();
    _licExpiryCtrl.dispose();
    _vhfNumCtrl.dispose();
    _vhfExpiryCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_loaded) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator()));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.skipperProfileHint,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),

          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
                labelText: l.skipperFullName, isDense: true),
          ),
          const SizedBox(height: 10),

          Text(l.skipperLicenseSection,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(
              controller: _licTypeCtrl,
              decoration: InputDecoration(
                  labelText: l.skipperLicenseType,
                  hintText: 'ICC / Yacht Master / Kapitán A',
                  isDense: true),
            )),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: _licNumCtrl,
              decoration: InputDecoration(
                  labelText: l.skipperLicenseNumber, isDense: true),
            )),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(
              controller: _licAuthCtrl,
              decoration: InputDecoration(
                  labelText: l.skipperLicenseAuthority, isDense: true),
            )),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: _licExpiryCtrl,
              decoration: InputDecoration(
                  labelText: l.skipperLicenseExpiry,
                  hintText: 'MM/YYYY',
                  isDense: true),
            )),
          ]),
          const SizedBox(height: 10),

          Text(l.skipperVhfSection,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(
              controller: _vhfNumCtrl,
              decoration: InputDecoration(
                  labelText: l.skipperVhfNumber, isDense: true),
            )),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: _vhfExpiryCtrl,
              decoration: InputDecoration(
                  labelText: l.skipperVhfExpiry,
                  hintText: 'MM/YYYY',
                  isDense: true),
            )),
          ]),
          const SizedBox(height: 10),

          TextField(
            controller: _otherCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l.skipperOtherCerts,
              hintText: l.skipperOtherCertsHint,
              isDense: true,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _save, child: Text(l.save)),
          ),
        ]),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AboutRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 13)),
    ]),
  );
}

class _Section extends StatelessWidget {
  final String t;
  const _Section(this.t);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold)));
}

class _RaymarineSection extends ConsumerStatefulWidget {
  const _RaymarineSection();
  @override
  ConsumerState<_RaymarineSection> createState() => _RaymarineSectionState();
}

class _RaymarineSectionState extends ConsumerState<_RaymarineSection> {
  late TextEditingController _hostCtrl;
  late TextEditingController _portCtrl;
  late TextEditingController _udpPortCtrl;
  bool _autoConnect = false;
  NmeaConnectionType _connType = NmeaConnectionType.tcp;
  bool _controllersInit = false;
  bool _connecting = false;

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _udpPortCtrl.dispose();
    super.dispose();
  }

  void _initControllersOnce(RaymarineSettings settings) {
    if (_controllersInit) return;
    _controllersInit = true;
    _hostCtrl = TextEditingController(text: settings.host);
    _portCtrl = TextEditingController(text: settings.port.toString());
    _udpPortCtrl =
        TextEditingController(text: settings.udpListenPort.toString());
    _autoConnect = settings.autoConnect;
    _connType = settings.connectionType;
  }

  Color _stateColor(RaymarineConnectionState s) {
    switch (s) {
      case RaymarineConnectionState.connected:
        return Colors.green;
      case RaymarineConnectionState.connecting:
        return Colors.orange;
      case RaymarineConnectionState.error:
        return Colors.red;
      case RaymarineConnectionState.disconnected:
        return Colors.grey;
    }
  }

  String _stateLabel(RaymarineConnectionState s, AppLocalizations l) {
    if (_connType == NmeaConnectionType.udp &&
        s == RaymarineConnectionState.connected) {
      return l.connectionListening(_udpPortCtrl.text.trim());
    }
    switch (s) {
      case RaymarineConnectionState.connected:
        return l.connectionConnected;
      case RaymarineConnectionState.connecting:
        return l.connectionConnecting;
      case RaymarineConnectionState.error:
        return l.connectionError;
      case RaymarineConnectionState.disconnected:
        return l.connectionDisconnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(raymarineSettingsProvider);
    _initControllersOnce(settings);

    final isUdp = _connType == NmeaConnectionType.udp;

    final connState = isUdp
        ? (ref.watch(udpConnectionStateProvider).valueOrNull ??
            RaymarineConnectionState.disconnected)
        : (ref.watch(raymarineConnectionStateProvider).valueOrNull ??
            RaymarineConnectionState.disconnected);

    final marineData = isUdp
        ? ref.watch(udpDataProvider).valueOrNull
        : ref.watch(marineDataProvider).valueOrNull;

    final lastErr = isUdp
        ? UdpReceiverService().lastError
        : RaymarineConnectionService().lastError;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stav ──
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _stateColor(connState),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_stateLabel(connState, l),
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            if (connState == RaymarineConnectionState.connected &&
                marineData != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (marineData.hasGpsFix) const _LiveTag('GPS fix'),
                  if (marineData.hasWind) _LiveTag(l.liveWind),
                  if (marineData.hasDepth) _LiveTag(l.liveDepth),
                  if (marineData.waterTempCelsius != null)
                    _LiveTag(l.liveWaterTemp),
                  if (marineData.headingDegrees != null)
                    _LiveTag(l.liveCompass),
                  if (marineData.engineRpm != null) _LiveTag(l.liveEngine),
                ],
              ),
            ],
            if (connState == RaymarineConnectionState.error &&
                lastErr != null) ...[
              const SizedBox(height: 4),
              Text(lastErr,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            const Divider(height: 24),

            // ── TCP / UDP prepínač ──
            SegmentedButton<NmeaConnectionType>(
              segments: [
                ButtonSegment(
                  value: NmeaConnectionType.tcp,
                  label: Text(l.nmeaTcp),
                  icon: const Icon(Icons.cable, size: 16),
                ),
                ButtonSegment(
                  value: NmeaConnectionType.udp,
                  label: Text(l.nmeaUdp),
                  icon: const Icon(Icons.wifi_tethering, size: 16),
                ),
              ],
              selected: {_connType},
              onSelectionChanged: (s) => setState(() => _connType = s.first),
            ),
            const SizedBox(height: 12),

            // ── TCP polia ──
            if (!isUdp) ...[
              TextField(
                controller: _hostCtrl,
                decoration: InputDecoration(
                  labelText: l.ipAddressLabel,
                  hintText: '10.0.0.1',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _portCtrl,
                decoration: InputDecoration(
                  labelText: l.portLabel,
                  hintText: '2000',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(l.autoConnectLabel),
                value: _autoConnect,
                onChanged: (v) => setState(() => _autoConnect = v),
              ),
            ],

            // ── UDP pole ──
            if (isUdp) ...[
              TextField(
                controller: _udpPortCtrl,
                decoration: InputDecoration(
                  labelText: l.udpListenPort,
                  hintText: '10110',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Text(
                l.udpHint(_udpPortCtrl.text.trim().isEmpty
                    ? '10110'
                    : _udpPortCtrl.text.trim()),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],

            const SizedBox(height: 8),

            // ── Tlačidlá ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(isUdp ? Icons.stop : Icons.link_off),
                    label: Text(isUdp ? l.stopListening : l.disconnect),
                    onPressed: connState == RaymarineConnectionState.connected
                        ? () async {
                            if (isUdp) {
                              await UdpReceiverService().stop();
                            } else {
                              await RaymarineConnectionService().disconnect();
                            }
                            setState(() {});
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: _connecting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isUdp ? Icons.hearing : Icons.link),
                    label: Text(isUdp ? l.startListening : l.connect),
                    onPressed: _connecting ? null : () => _connect(context),
                  ),
                ),
              ],
            ),

            if (!isUdp) ...[
              const SizedBox(height: 8),
              Text(
                l.gatewayHint,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _connect(BuildContext ctx) async {
    final l = AppLocalizations.of(ctx);
    final isUdp = _connType == NmeaConnectionType.udp;

    if (isUdp) {
      final port = int.tryParse(_udpPortCtrl.text.trim()) ?? 10110;
      await ref.read(raymarineSettingsProvider.notifier).save(
            host: _hostCtrl.text.trim(),
            port: int.tryParse(_portCtrl.text.trim()) ?? 2000,
            autoConnect: _autoConnect,
            connectionType: NmeaConnectionType.udp,
            udpListenPort: port,
          );
      setState(() => _connecting = true);
      final ok = await UdpReceiverService().start(port: port);
      if (mounted) {
        setState(() => _connecting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? l.udpListeningOnPort(port)
              : l.connectionFailed(UdpReceiverService().lastError ?? '')),
        ));
      }
      return;
    }

    // TCP
    final host = _hostCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 2000;
    if (host.isEmpty) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(SnackBar(content: Text(l.enterIpAddress)));
      return;
    }

    setState(() => _connecting = true);
    await ref.read(raymarineSettingsProvider.notifier).save(
          host: host,
          port: port,
          autoConnect: _autoConnect,
          connectionType: NmeaConnectionType.tcp,
          udpListenPort: int.tryParse(_udpPortCtrl.text.trim()) ?? 10110,
        );

    final ok = await RaymarineConnectionService().connect(
      host: host,
      port: port,
      autoReconnect: true,
    );

    if (mounted) {
      setState(() => _connecting = false);
      final ll = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? ll.connectedToHost(host, port)
            : ll.connectionFailed(
                RaymarineConnectionService().lastError ?? '')),
      ));
    }
  }
}

class _LiveTag extends StatelessWidget {
  final String label;
  const _LiveTag(this.label);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.green),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      );
}

// ── Online účet ───────────────────────────────────────────────

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Icon(Icons.cloud_outlined, color: colorScheme.primary),
        title: Text(l.onlineAccount),
        subtitle: Text(l.onlineAccountDesc),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'v2.0',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Záloha dát ─────────────────────────────────────────────────

class _BackupSection extends ConsumerStatefulWidget {
  const _BackupSection();
  @override
  ConsumerState<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<_BackupSection> {
  bool _busy = false;

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      final zip = await BackupService().createSnapshotZip(db);
      await Share.shareXFiles([XFile(zip.path)], subject: l.exportBackup);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.errorMsg(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context);

    if (GpsTrackingService().isTracking) {
      await _showInfoDialog(l.restoreBlockedTrackingTitle, l.restoreBlockedTrackingBody);
      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['hmbbackup'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      BackupMetadata metadata;
      try {
        metadata = await BackupService().readMetadata(path);
      } on FormatException {
        setState(() => _busy = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l.restoreInvalidFile),
            backgroundColor: Colors.red,
          ));
        }
        return;
      }

      if (metadata.schemaVersion > db.schemaVersion) {
        setState(() => _busy = false);
        await _showInfoDialog(l.restoreSchemaTooNewTitle, l.restoreSchemaTooNewBody);
        return;
      }

      setState(() => _busy = false);
      final confirmed = await _showConfirmDialog(l.restoreConfirmTitle, l.restoreConfirmBody);
      if (confirmed != true) return;
      setState(() => _busy = true);

      // Automatická bezpečnostná záloha aktuálneho stavu pred prepísaním.
      await BackupService().createSnapshotZip(db);

      await db.close();
      await BackupService().applyRestore(path);

      final newDb = AppDatabase();
      replaceCurrentDatabase(newDb);
      wireDatabaseSingletons(newDb);
      ref.invalidate(databaseProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.restoreSuccess),
          backgroundColor: Colors.green.shade700,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.errorMsg(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showInfoDialog(String title, String body) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(ctx).ok)),
          ],
        ),
      );

  Future<bool?> _showConfirmDialog(String title, String body) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx).cancel)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(ctx).restoreBackup),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(child: Column(children: [
      ListTile(
        leading: const Icon(Icons.upload_file_outlined),
        title: Text(l.exportBackup),
        subtitle: Text(l.exportBackupDesc),
        trailing: _busy ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)) : null,
        onTap: _busy ? null : _export,
      ),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.settings_backup_restore),
        title: Text(l.restoreBackup),
        subtitle: Text(l.restoreBackupDesc),
        trailing: _busy ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)) : null,
        onTap: _busy ? null : _restore,
      ),
    ]));
  }
}
