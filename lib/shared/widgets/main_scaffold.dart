import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/tracking/providers/tracking_provider.dart';
import '../../features/logbook/presentation/widgets/quick_photo_log_sheet.dart';
import 'tracking_control_bar.dart';
import '../../core/models/skipper_profile.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/nav_prefs_provider.dart';
import '../../core/providers/skipper_profile_provider.dart';
import '../../core/providers/sync_provider.dart';
import '../../core/providers/sync_settings_provider.dart';
import '../../core/services/gps_tracking_service.dart';
import '../../core/models/marine_instrument_data.dart';
import '../../core/services/raymarine_connection_service.dart';
import '../../core/services/udp_receiver_service.dart';
import '../../core/providers/raymarine_providers.dart';
import '../../features/cloud/providers/cloud_provider.dart';
import '../../features/cloud/services/auto_export_service.dart';
import '../../features/help/presentation/screens/user_guide_screen.dart';
import '../../main.dart';
import 'sync_queue_badge.dart';
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
      await _maybePromptNotifications();
      await _maybePromptRaymarineSetup();
    });
  }

  /// First-run only: vysvetlí, prečo appka chce notifikácie (upozornenie
  /// v lište a na zamknutej obrazovke počas sledovania plavby) a vyžiada
  /// povolenie POST_NOTIFICATIONS. Android 13+ ho inak nikdy nezobrazí sám
  /// a foreground-service notifikácia by bola potichu skrytá.
  Future<void> _maybePromptNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('notifications_prompted') ?? false) return;

    // Ak už je povolené (napr. z predošlej verzie), len si to poznač a mlč.
    if (await Permission.notification.isGranted) {
      await prefs.setBool('notifications_prompted', true);
      return;
    }
    await prefs.setBool('notifications_prompted', true);
    if (!mounted) return;

    final l = AppLocalizations.of(context);
    final allow = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined, size: 32),
        title: Text(l.notifPromptTitle),
        content: Text(l.notifPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.notifPromptAllow),
          ),
        ],
      ),
    );
    if (allow == true) {
      await Permission.notification.request();
    }
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

  /// Ponúkne pripojenie lodných inštrumentov — jediný raz za inštaláciu.
  ///
  /// Pôvodne sa pýtala pri každom štarte, kým používateľ niečo nepripojil.
  /// Väčšina plavieb ale beží na GPS telefónu zámerne, takže to bola otázka,
  /// ktorú tí istí ľudia odklikávali stále dokola. Nastavenia → Lodné
  /// inštrumenty ostávajú dostupné kedykoľvek.
  Future<void> _maybePromptRaymarineSetup() async {
    if (_checkedRaymarinePrompt) return;
    _checkedRaymarinePrompt = true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('raymarine_prompted') ?? false) return;

    // Daj existujúcemu auto-connect pokusu (spustenému v main.dart) chvíľu
    // na dokončenie, nech neprerušujeme prebiehajúce pripojenie zbytočnou otázkou.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final tcpState = RaymarineConnectionService().state;
    final alreadyHandled = tcpState == RaymarineConnectionState.connected ||
        tcpState == RaymarineConnectionState.connecting ||
        UdpReceiverService().isListening;
    // Flag padá aj keď spojenie beží: nadviazané spojenie je odpoveď na otázku,
    // takže sa nemá čo pýtať ani neskôr, keď loď zrovna nie je v dosahu.
    await prefs.setBool('raymarine_prompted', true);
    if (alreadyHandled) return;

    final l = AppLocalizations.of(context);
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.marineInstrumentsTitle),
        // Scrollovateľné: prompt je niekoľko odstavcov a s pridanou
        // poznámkou sa na nižších displejoch nezmestí.
        content: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.marineInstrumentsPrompt),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.wifi, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.marineInstrumentsWifiNote,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        )),
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

  static String _labelForPath(AppLocalizations l, String path) => switch (path) {
        '/map' => l.navMap,
        '/logbook' => l.navLogbook,
        '/weather' => l.navWeather,
        '/instruments' => l.navInstruments,
        '/safety' => l.navSafety,
        '/compass' => l.navCompass,
        kSettingsPath => l.navSettings,
        _ => '',
      };

  String _currentPath(BuildContext ctx) {
    try {
      return GoRouterState.of(ctx).uri.path;
    } catch (_) {
      return '/map';
    }
  }

  /// Index aktuálnej cesty v zozname viditeľných kariet [visiblePaths].
  /// Keď je aktuálna obrazovka skrytá karta (otvorená cez Nastavenia) alebo
  /// podstránka, zvýrazni Nastavenia (posledná, fixná) — tá je vstupom k nim.
  int _idxIn(List<String> visiblePaths, BuildContext ctx) {
    final loc = _currentPath(ctx);
    final i = visiblePaths.indexWhere((p) => loc.startsWith(p));
    if (i >= 0) return i;
    return visiblePaths.length - 1; // /settings
  }

  void _handleBack(BuildContext context) {
    try {
      final loc = GoRouterState.of(context).uri.path;
      final isMainTab = kNavTabs.any((t) => t.path == loc);

      if (!isMainTab) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/logbook');
        }
        return;
      }

      // Z hociktorej karty späť vedie najprv na mapu; z mapy dvojklik = exit.
      if (loc != '/map') {
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
              // Captured before stopTracking() nulls it (same trap as
              // handleStopTap, docs/plan_cloud_export.md §5).
              final dayLogId = GpsTrackingService().activeDayLogId;
              await ref.read(trackingNotifierProvider.notifier).stopTracking();
              // No map screenshot here on purpose — this path kills the
              // process right after, no BuildContext-driven off-tree
              // capture can finish in time. The enqueue itself is awaited
              // (it's local: PDF/GPX build + file write + outbox insert,
              // no network) so the day isn't lost; only the upload is what
              // waits for the next launch.
              if (dayLogId != null) {
                // Gated on the actual signed-in session — see the same
                // comment in tracking_control_dialogs.dart's handleStopTap.
                final cloudEnabled =
                    (await ref.read(syncSettingsProvider.future)).cloudEnabled &&
                        ref.read(cloudStorageProviderProvider).isSignedInNow;
                final skipperProfile = await ref
                    .read(skipperProfileProvider.future)
                    .catchError((_) => const SkipperProfile());
                await AutoExportService().exportAndEnqueueDay(
                  db: ref.read(databaseProvider),
                  engine: ref.read(syncEngineProvider),
                  cloudEnabled: cloudEnabled,
                  locale: ref.read(localeProvider),
                  skipperProfile: skipperProfile,
                  dayLogId: dayLogId,
                );
              }
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

  Future<void> _quickPhotoLog(BuildContext context) async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1920);
    if (file == null || !context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickPhotoLogSheet(photoPath: file.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isTracking = ref.watch(isTrackingProvider);
    final navPrefs = ref.watch(navPrefsProvider);
    // Viditeľné karty: user-usporiadané a neskryté presúvateľné + fixné
    // Nastavenia vždy posledné. Nastavenia sa nedajú skryť ani presunúť,
    // takže cez ne je vždy prístup k skrytým kartám.
    final visiblePaths = [...navPrefs.visibleOrdered, kSettingsPath];
    final currentIndex = _idxIn(visiblePaths, context);
    // Map, Denník, Lodné prístroje — the control bar lives there regardless
    // of tracking state, so Start is always one tap away where sailing
    // happens. Path-based (aktuálna cesta), takže preusporiadanie kariet
    // to nerozbije.
    final showControlBar = const {'/map', '/logbook', '/instruments'}
        .contains(_currentPath(context));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBack(context),
      child: Scaffold(
        body: Column(children: [
          SafeArea(
            bottom: false,
            child: Column(children: [
              const SyncQueueBadge(),
              if (showControlBar) const TrackingControlBar(),
            ]),
          ),
          Expanded(child: widget.child),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: isTracking
            ? FloatingActionButton(
                heroTag: 'quickPhotoLog',
                tooltip: l.quickPhotoLogTitle,
                onPressed: () => _quickPhotoLog(context),
                child: const Icon(Icons.add_a_photo),
              )
            : null,
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              TextStyle(fontSize: navPrefs.iconSize.labelFont, height: 1.1)),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => context.go(visiblePaths[i]),
            destinations: [
              for (final path in visiblePaths)
                NavigationDestination(
                  icon: Icon(navTabForPath(path).icon,
                      size: navPrefs.iconSize.iconDim),
                  selectedIcon: Icon(navTabForPath(path).activeIcon,
                      size: navPrefs.iconSize.iconDim),
                  label: _labelForPath(l, path),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
