import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/models/marine_instrument_data.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/raymarine_providers.dart';
import '../../../../core/services/raymarine_connection_service.dart';
import '../../../../core/services/units_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavenia')),
      body: unitsAsync.when(
        data: (units) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section('Jednotky merania'),
            Card(child: Column(children: [
              ListTile(
                leading: const Icon(Icons.thermostat),
                title: const Text('Teplota'),
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
                title: const Text('Hĺbka / vlny'),
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
                title: const Text('Vietor'),
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

            _Section('Lodné inštrumenty'),
            const _RaymarineSection(),
            const SizedBox(height: 16),

            _Section('Jazyk'),
            Card(child: ListTile(
              leading: const Text('🌐', style: TextStyle(fontSize: 22)),
              title: const Text('Jazyk aplikácie'),
              subtitle: Text(_currentLangName(ref.watch(localeProvider).languageCode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, ref),
            )),
            const SizedBox(height: 16),

            _Section('O aplikácii'),
            Card(child: Column(children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('O aplikácii'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context),
              ),
            ])),
          ],
        ),
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
        title: const Text('Jazyk / Language'),
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
        applicationLegalese: '© 2025 Lacoste\nVšetky práva vyhradené',
        children: [
          const SizedBox(height: 16),
          const Text('Profesionálny lodný denník pre jachtárov.',
              style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          const _AboutRow(Icons.gps_fixed, 'GPS tracking s auto-zápismi'),
          const _AboutRow(Icons.book, 'Viacdenný charterový denník'),
          const _AboutRow(Icons.map, 'Offline nautické mapy (OpenSeaMap)'),
          const _AboutRow(Icons.cloud, 'Morské počasie (Open-Meteo)'),
          const _AboutRow(Icons.picture_as_pdf, 'Export PDF + GPX'),
          const _AboutRow(Icons.shield, 'Safety briefing & Mayday Card'),
          const SizedBox(height: 16),
          const Text('Autor: Lacoste',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Verzia: ${info.version} (${info.buildNumber})',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Platform: Flutter / Android',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
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

  String _stateLabel(RaymarineConnectionState s) {
    switch (s) {
      case RaymarineConnectionState.connected:
        return 'Pripojené';
      case RaymarineConnectionState.connecting:
        return 'Pripájam sa...';
      case RaymarineConnectionState.error:
        return 'Chyba pripojenia';
      case RaymarineConnectionState.disconnected:
        return 'Nepripojené (používa sa telefón GPS / predpoveď)';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(_stateLabel(connState),
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
                    const _LiveTag('Vietor'),
                  if (marineData.hasDepth)
                    const _LiveTag('Hĺbka'),
                  if (marineData.waterTempCelsius != null)
                    const _LiveTag('Teplota vody'),
                  if (marineData.headingDegrees != null)
                    const _LiveTag('Kompas'),
                  if (marineData.engineRpm != null)
                    const _LiveTag('Motor'),
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
              decoration: const InputDecoration(
                labelText: 'IP adresa gateway',
                hintText: 'napr. 10.0.0.1',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portCtrl,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '2000',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Automaticky pripojiť pri spustení'),
              value: _autoConnect,
              onChanged: (v) => setState(() => _autoConnect = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.link_off),
                    label: const Text('Odpojiť'),
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
                    label: const Text('Pripojiť'),
                    onPressed: _connecting
                        ? null
                        : () => _connect(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pripoj telefón na WiFi sieť lodného gateway (Raymarine WiFi-1, '
              'RayNet a podobné typicky bežia na 10.0.0.1, port 2000). '
              'Bez pripojenia aplikácia automaticky používa GPS telefónu '
              'a predpoveď počasia z internetu.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect(BuildContext context) async {
    final host = _hostCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 2000;
    if (host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zadajte IP adresu gateway')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Pripojené na $host:$port'
              : 'Nepodarilo sa pripojiť: ${RaymarineConnectionService().lastError ?? ""}'),
        ),
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
