import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/tracking/providers/tracking_provider.dart';
import '../../core/services/gps_tracking_service.dart';
import '../../core/models/marine_instrument_data.dart';
import '../../core/services/raymarine_connection_service.dart';
import '../../core/services/udp_receiver_service.dart';
import '../../core/providers/raymarine_providers.dart';
import '../../features/help/presentation/screens/user_guide_screen.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  DateTime? _lastBackPress;
  bool _checkedRaymarinePrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybePromptUserGuide();
      await _maybePromptRaymarineSetup();
    });
  }

  Future<void> _maybePromptUserGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool('user_guide_prompted') ?? false;
    if (alreadyAsked) return;

    await prefs.setBool('user_guide_prompted', true);
    if (!mounted) return;

    final l = AppLocalizations.of(context);
    final showGuide = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.menu_book_outlined, size: 32),
        title: Text(l.guidePromptTitle),
        content: Text(l.guidePromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.guidePromptAction),
          ),
        ],
      ),
    );

    if (showGuide == true && mounted) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => const UserGuideScreen()));
    }
  }

  /// Pýta sa na pripojenie lodných inštrumentov pri každom štarte appky,
  /// pokiaľ ešte nie je nadviazané NMEA spojenie (TCP ani UDP). Netrvalý
  /// flag ako pri sprievodcovi — toto sa má opakovať každé spustenie, kým
  /// používateľ niečo nepripojí.
  Future<void> _maybePromptRaymarineSetup() async {
    if (_checkedRaymarinePrompt) return;
    _checkedRaymarinePrompt = true;

    // Daj existujúcemu auto-connect pokusu (spustenému v main.dart) chvíľu
    // na dokončenie, nech neprerušujeme prebiehajúce pripojenie zbytočnou otázkou.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final tcpState = RaymarineConnectionService().state;
    final alreadyHandled = tcpState == RaymarineConnectionState.connected ||
        tcpState == RaymarineConnectionState.connecting ||
        UdpReceiverService().isListening;
    if (alreadyHandled) return;

    final l = AppLocalizations.of(context);
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.marineInstrumentsTitle),
        content: Text(l.marineInstrumentsPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'later'),
            child: Text(l.notNow),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'manual'),
            child: Text(l.setupConnection),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, 'auto'),
            icon: const Icon(Icons.wifi_find, size: 18),
            label: Text(l.autoDetectAction),
          ),
        ],
      ),
    );

    if (!mounted || action == null || action == 'later') return;

    if (action == 'manual') {
      context.go('/settings');
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.wifi, size: 32),
        title: Text(l.autoDetectWifiHintTitle),
        content: Text(l.autoDetectWifiHintBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.notNow),
          ),
          OutlinedButton.icon(
            onPressed: () =>
                AppSettings.openAppSettings(type: AppSettingsType.wifi),
            icon: const Icon(Icons.wifi, size: 18),
            label: Text(l.openWifiSettings),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.continueAction),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;

    await _runAutoDetect();
  }

  Future<void> _runAutoDetect() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Row(children: [
        const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 12),
        Expanded(child: Text(l.autoDetecting)),
      ]),
      duration: const Duration(seconds: 10),
    ));

    final host = await RaymarineConnectionService().autoDetectHost();
    if (!mounted) return;
    messenger.hideCurrentSnackBar();

    if (host == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.autoDetectFailed)));
      return;
    }

    final ok = await RaymarineConnectionService().connect(host: host, port: 2000);
    if (!mounted) return;

    if (ok) {
      final udpPort = ref.read(raymarineSettingsProvider).udpListenPort;
      await ref.read(raymarineSettingsProvider.notifier).save(
            host: host,
            port: 2000,
            autoConnect: true,
            connectionType: NmeaConnectionType.tcp,
            udpListenPort: udpPort,
          );
      messenger.showSnackBar(SnackBar(content: Text(l.autoDetectSuccess(host))));
    } else {
      // connect() naplánoval reconnect loop (autoReconnect defaultne true) -
      // zruš ho, inak by appka donekonečna skúšala pripojiť sa na hosta,
      // ktorý sa ukázal ako falošný pozitív (otvorený port, žiadne NMEA dáta).
      await RaymarineConnectionService().disconnect();
      messenger.showSnackBar(SnackBar(content: Text(l.autoDetectFailed)));
    }
  }

  static const _tabData = [
    (icon: Icons.map_outlined,        activeIcon: Icons.map,          path: '/map'),
    (icon: Icons.speed_outlined,      activeIcon: Icons.speed,        path: '/instruments'),
    (icon: Icons.book_outlined,       activeIcon: Icons.book,         path: '/logbook'),
    (icon: Icons.cloud_outlined,      activeIcon: Icons.cloud,        path: '/weather'),
    (icon: Icons.shield_outlined,     activeIcon: Icons.shield,       path: '/safety'),
    (icon: Icons.explore_outlined,    activeIcon: Icons.explore,      path: '/compass'),
    (icon: Icons.settings_outlined,   activeIcon: Icons.settings,     path: '/settings'),
  ];

  List<String> _labels(AppLocalizations l) => [
    l.navMap, l.navInstruments, l.navLogbook, l.navWeather, l.navSafety, l.navCompass, l.navSettings,
  ];

  int _idx(BuildContext ctx) {
    try {
      final loc = GoRouterState.of(ctx).uri.path;
      final i = _tabData.indexWhere((t) => loc.startsWith(t.path));
      return i < 0 ? 0 : i;
    } catch (_) { return 0; }
  }

  void _handleBack(BuildContext context) {
    try {
      final loc = GoRouterState.of(context).uri.path;
      final isMainTab = _tabData.any((t) => t.path == loc);
      final currentIndex = _idx(context);

      if (!isMainTab) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/logbook');
        }
        return;
      }

      if (currentIndex != 0) {
        context.go('/map');
        return;
      }

      final now = DateTime.now();
      final isDouble = _lastBackPress != null &&
          now.difference(_lastBackPress!) < const Duration(seconds: 2);

      if (!isDouble) {
        _lastBackPress = now;
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.pressBackToExit),
          duration: const Duration(seconds: 2),
        ));
        return;
      }

      if (GpsTrackingService().isTracking) {
        _showExitDialog(context);
      } else {
        SystemNavigator.pop(animated: true);
      }
    } catch (e) {
      debugPrint('[BACK] error: $e');
    }
  }

  void _showExitDialog(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.trackingRunningTitle),
        content: Text(l.trackingRunningContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(trackingNotifierProvider.notifier).stopTracking();
              SystemNavigator.pop(animated: true);
            },
            icon: const Icon(Icons.stop, color: Colors.red),
            label: Text(l.stopAndExit, style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop(animated: true);
            },
            icon: const Icon(Icons.minimize),
            label: Text(l.keepRunning),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _idx(context);
    final l = AppLocalizations.of(context);
    final labels = _labels(l);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBack(context),
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              const TextStyle(fontSize: 10, height: 1.1)),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => context.go(_tabData[i].path),
            destinations: _tabData.map((t) => NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.activeIcon),
              label: labels[_tabData.indexOf(t)],
            )).toList(),
          ),
        ),
      ),
    );
  }
}
