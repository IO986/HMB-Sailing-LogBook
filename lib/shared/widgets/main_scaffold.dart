import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/tracking/providers/tracking_provider.dart';
import '../../core/services/gps_tracking_service.dart';
import '../../core/services/raymarine_connection_service.dart';
import '../../core/providers/raymarine_providers.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePromptRaymarineSetup();
    });
  }

  Future<void> _maybePromptRaymarineSetup() async {
    if (_checkedRaymarinePrompt) return;
    _checkedRaymarinePrompt = true;

    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool('raymarine_setup_asked') ?? false;
    final host = prefs.getString('raymarine_host') ?? '';
    if (alreadyAsked || host.isNotEmpty) return;

    await prefs.setBool('raymarine_setup_asked', true);
    if (!mounted) return;

    final l = AppLocalizations.of(context);
    final connect = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.marineInstrumentsTitle),
        content: Text(l.marineInstrumentsPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.setupConnection),
          ),
        ],
      ),
    );

    if (connect == true && mounted) {
      context.go('/settings');
    }
  }

  static const _tabData = [
    (icon: Icons.map_outlined,        activeIcon: Icons.map,          path: '/map'),
    (icon: Icons.play_circle_outline, activeIcon: Icons.play_circle,  path: '/tracking'),
    (icon: Icons.book_outlined,       activeIcon: Icons.book,         path: '/logbook'),
    (icon: Icons.cloud_outlined,      activeIcon: Icons.cloud,        path: '/weather'),
    (icon: Icons.shield_outlined,     activeIcon: Icons.shield,       path: '/safety'),
    (icon: Icons.settings_outlined,   activeIcon: Icons.settings,     path: '/settings'),
  ];

  List<String> _labels(AppLocalizations l) => [
    l.navMap, l.navTracking, l.navLogbook, l.navWeather, l.navSafety, l.navSettings,
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
      print('[BACK] error: $e');
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
    final isTracking = ref.watch(isTrackingProvider);
    final currentIndex = _idx(context);
    final l = AppLocalizations.of(context);
    final labels = _labels(l);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBack(context),
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => context.go(_tabData[i].path),
          destinations: List.generate(_tabData.length, (i) {
            final t = _tabData[i];
            final isTrack = t.path == '/tracking';
            return NavigationDestination(
              icon: Badge(
                isLabelVisible: isTrack && isTracking,
                child: Icon(t.icon),
              ),
              selectedIcon: Icon(t.activeIcon),
              label: labels[i],
            );
          }),
        ),
      ),
    );
  }
}
