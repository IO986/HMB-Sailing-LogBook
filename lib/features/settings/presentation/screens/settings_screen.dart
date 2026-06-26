import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/marine_instrument_data.dart';
import '../../../../core/providers/account_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/raymarine_providers.dart';
import '../../../../core/services/raymarine_connection_service.dart';
import '../../../../core/services/units_service.dart';
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

            _Section(l.vesselIdTitle),
            const _VesselIdSection(),
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
        applicationLegalese: '© 2025 Lacoste\n© All rights reserved',
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
          const Text('Author: Lacoste',
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
  bool _autoConnect = false;
  bool _controllersInit = false;
  bool _connecting = false;

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  void _initControllersOnce(RaymarineSettings settings) {
    if (_controllersInit) return;
    _controllersInit = true;
    _hostCtrl = TextEditingController(text: settings.host);
    _portCtrl = TextEditingController(text: settings.port.toString());
    _autoConnect = settings.autoConnect;
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

    final connState = ref.watch(raymarineConnectionStateProvider)
            .valueOrNull ??
        RaymarineConnectionState.disconnected;
    final marineData = ref.watch(marineDataProvider).valueOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  if (marineData.hasGpsFix)
                    const _LiveTag('GPS fix'),
                  if (marineData.hasWind)
                    _LiveTag(l.liveWind),
                  if (marineData.hasDepth)
                    _LiveTag(l.liveDepth),
                  if (marineData.waterTempCelsius != null)
                    _LiveTag(l.liveWaterTemp),
                  if (marineData.headingDegrees != null)
                    _LiveTag(l.liveCompass),
                  if (marineData.engineRpm != null)
                    _LiveTag(l.liveEngine),
                ],
              ),
            ],
            if (connState == RaymarineConnectionState.error &&
                RaymarineConnectionService().lastError != null) ...[
              const SizedBox(height: 4),
              Text(
                RaymarineConnectionService().lastError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const Divider(height: 24),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.link_off),
                    label: Text(l.disconnect),
                    onPressed: connState == RaymarineConnectionState.connected
                        ? () async {
                            await RaymarineConnectionService().disconnect();
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
                        : const Icon(Icons.link),
                    label: Text(l.connect),
                    onPressed: _connecting
                        ? null
                        : () => _connect(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.gatewayHint,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect(BuildContext ctx) async {
    final l = AppLocalizations.of(ctx);
    final host = _hostCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 2000;
    final emptyMsg = l.enterIpAddress;
    if (host.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(emptyMsg)),
      );
      return;
    }

    setState(() => _connecting = true);
    await ref.read(raymarineSettingsProvider.notifier).save(
          host: host,
          port: port,
          autoConnect: _autoConnect,
        );

    final ok = await RaymarineConnectionService().connect(
      host: host,
      port: port,
      autoReconnect: true,
    );

    if (mounted) {
      setState(() => _connecting = false);
      final ll = AppLocalizations.of(context);
      final msg = ok
          ? ll.connectedToHost(host, port)
          : ll.connectionFailed(RaymarineConnectionService().lastError ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
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

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(accountProvider);
    final l = AppLocalizations.of(context);

    if (user != null) {
      return Card(child: Column(children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.email),
          trailing: const Icon(Icons.cloud_done, color: Colors.green),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(l.logout, style: const TextStyle(color: Colors.red)),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l.logout),
                content: Text(l.logoutConfirm),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l.logout),
                  ),
                ],
              ),
            ) ?? false;
            if (ok) await ref.read(accountProvider.notifier).logout();
          },
        ),
      ]));
    }

    // Neprihlásený
    return Card(child: Column(children: [
      ListTile(
        leading: const Icon(Icons.cloud_off_outlined),
        title: Text(l.notLoggedIn),
        subtitle: Text(l.onlineAccountDesc),
      ),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.person_add_outlined),
        title: Text(l.register),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showAuthDialog(context, ref, isRegister: true),
      ),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.login),
        title: Text(l.login),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showAuthDialog(context, ref, isRegister: false),
      ),
    ]));
  }

  Future<void> _showAuthDialog(BuildContext context, WidgetRef ref,
      {required bool isRegister}) async {
    final l = AppLocalizations.of(context);
    final emailCtrl = TextEditingController();
    final nameCtrl  = TextEditingController();
    final passCtrl  = TextEditingController();
    String? error;
    bool loading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isRegister ? l.register : l.login),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (isRegister) ...[
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l.fullName),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passCtrl,
              decoration: InputDecoration(labelText: l.password),
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
          ])),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            ElevatedButton(
              onPressed: loading ? null : () async {
                setState(() { loading = true; error = null; });
                try {
                  if (isRegister) {
                    await ref.read(accountProvider.notifier).register(
                      email: emailCtrl.text,
                      name: nameCtrl.text,
                      password: passCtrl.text,
                    );
                  } else {
                    await ref.read(accountProvider.notifier).login(
                      email: emailCtrl.text,
                      password: passCtrl.text,
                    );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setState(() {
                    loading = false;
                    error = _friendlyError(e);
                  });
                }
              },
              child: loading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isRegister ? l.register : l.login),
            ),
          ],
        ),
      ),
    );
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('email') && msg.contains('exist')) return 'Email je už registrovaný.';
    if (msg.contains('invalid') || msg.contains('credentials') || msg.contains('401')) {
      return 'Nesprávny email alebo heslo.';
    }
    if (msg.contains('connection') || msg.contains('timeout') || msg.contains('network')) {
      return 'Chyba siete. Skontroluj pripojenie.';
    }
    return 'Chyba: $e';
  }
}
