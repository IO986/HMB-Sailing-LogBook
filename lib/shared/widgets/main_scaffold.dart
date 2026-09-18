import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/tracking/providers/tracking_provider.dart';
import '../../features/logbook/presentation/widgets/quick_photo_log_sheet.dart';
import '../../features/logbook/presentation/widgets/quick_sail_change_sheet.dart';
import '../../features/logbook/presentation/widgets/quick_helmsman_sheet.dart';
import 'main_nav_bar.dart';
import 'tracking_control_bar.dart';
import '../../features/tracking/presentation/widgets/tracking_control_dialogs.dart';
import '../../core/models/skipper_profile.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/nav_prefs_provider.dart';
import '../../core/providers/skipper_profile_provider.dart';
import '../../core/providers/sync_provider.dart';
import '../../core/providers/sync_settings_provider.dart';
import '../../core/services/app_update_service.dart';
import '../../core/services/background_service.dart';
import '../../core/services/gps_tracking_service.dart';
import '../../core/services/location_service.dart';
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
import '../../features/map/providers/map_provider.dart';
import '../../features/safety/presentation/screens/safety_screen.dart';
import '../../features/tracking/presentation/widgets/tracking_stalled_banner.dart';

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
      await BackgroundService.stopIfOrphaned(
          trackingActive: GpsTrackingService().isTracking);
      if (mounted) await maybePromptInterruptedVoyage(context, ref);
      // Kotva je stále dole aj vtedy, keď appku medzitým zabil systém.
      // Stráž sa ticho rozbehne ďalej — inak by skiper spal v presvedčení,
      // že mu niekto sleduje kotvu, a nesledoval by ju nikto.
      await ref.read(anchorProvider.notifier).restore();
      _watchForUpdate();
    });
  }

  /// Novšia verzia z Google Play sa stiahne na pozadí a keď je hotová,
  /// ponúkne sa reštart. Až po prompt-och vyššie a nikdy počas plavby —
  /// pozri [shouldCheckForUpdate].
  void _watchForUpdate() {
    final service = AppUpdateService()
      ..onDownloaded = () {
        if (!mounted) return;
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.updateDownloaded),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: l.updateRestart,
            onPressed: AppUpdateService().install,
          ),
        ));
      };
    unawaited(service.checkAndStart());
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
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1920);
    if (picked == null) return;
    // image_picker uklada zmenšenú kópiu do CACHE priečinka appky (súbor
    // "scaled_..."), ktorý systém smie kedykoľvek vymazať — bez tejto kópie
    // do trvalého úložiska fotka z denníka zmizne (nahlásené z terénu:
    // "nezapisalo ani jednu fotku").
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/logbook_photos');
    await dir.create(recursive: true);
    final file = File(
        '${dir.path}/log_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await File(picked.path).copy(file.path);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickPhotoLogSheet(photoPath: file.path),
    );
  }

  void _quickSailChange(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const QuickSailChangeSheet(),
      );

  void _quickHelmsman(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const QuickHelmsmanSheet(),
      );

  /// Rad rýchlych akcií počas plavby.
  ///
  /// Rozostup sa pri piatich tlačidlách sťahuje na 8 px — päť 56 px tlačidiel
  /// s dvanástkovými medzerami sa na 360 px širokú obrazovku (bežný odolný
  /// telefón) nezmestí.
  Widget _quickActions(BuildContext context, AppLocalizations l,
      {required bool isTracking}) {
    // Len príznaky, nie celý stav: kotvová stráž prepisuje vzdialenosť pri
    // každom fixe a celý scaffold by sa prekresľoval každú sekundu.
    final anchorActive =
        ref.watch(anchorProvider.select((s) => s.isActive));
    final mobActive = ref.watch(mobProvider.select((s) => s.isActive));
    // Osem, nie dvanásť: päť 56 px tlačidiel s dvanástkovými medzerami sa na
    // 360 px širokú obrazovku (bežný odolný telefón) nezmestí.
    const gap = SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Kormidelník, obrat a fotka zapisujú do bežiacej plavby — bez nej
        // nemajú kam, takže sa bez trasovania nezobrazujú.
        if (isTracking) ...[
          FloatingActionButton(
            heroTag: 'quickHelmsman',
            tooltip: l.helmsmanLabel,
            onPressed: () => _quickHelmsman(context),
            child: const Icon(Icons.badge),
          ),
          gap,
          FloatingActionButton(
            heroTag: 'quickSailChange',
            tooltip: l.logEventSailChange,
            onPressed: () => _quickSailChange(context),
            child: const Icon(Icons.sailing),
          ),
          gap,
          FloatingActionButton(
            heroTag: 'quickPhotoLog',
            tooltip: l.quickPhotoLogTitle,
            onPressed: () => _quickPhotoLog(context),
            child: const Icon(Icons.add_a_photo),
          ),
          gap,
        ],
        // Ťuknutie = kruh s naposledy použitým polomerom. Podržanie = plocha:
        // úzka zátoka, pontón pozdĺž móla ani kotvisko medzi skalami sa
        // kruhom obkresliť nedá a doteraz k tomu viedla cesta len cez
        // Bezpečnosť a panel Nástroje.
        //
        // Bez tooltipu: FloatingActionButton sa pri ňom zabalí do Tooltip,
        // ktorý na mobile zožerie práve dlhé podržanie. Tá istá pasca ako
        // pri MOB nižšie a pri _layerFab v map_screen.dart.
        GestureDetector(
          onLongPress: anchorActive ? null : () => _drawAnchorZone(context),
          child: FloatingActionButton(
            heroTag: 'quickAnchor',
            backgroundColor: anchorActive ? Colors.blue.shade700 : null,
            foregroundColor: anchorActive ? Colors.white : null,
            onPressed: () => anchorActive
                ? _confirmStopAnchor(context)
                : _quickAnchor(context),
            child: const Icon(Icons.anchor),
          ),
        ),
        gap,
        // Jediné červené tlačidlo v appke. Za chodu sa nehľadá podľa ikony
        // ani podľa popisu, ale podľa farby.
        //
        // Rovnako ako kotva nezávisí od trasovania: človek padá cez palubu aj
        // vtedy, keď sa plavba práve nezapisuje, a bod pádu sleduje poloha
        // z GPS, nie bežiaca plavba.
        GestureDetector(
          onLongPress: () =>
              mobActive ? _confirmCancelMob(context) : _quickMob(context),
          child: FloatingActionButton(
            heroTag: 'quickMob',
            // Bez tooltipu zámerne: FloatingActionButton sa pri zadanom
            // tooltipe zabalí do Tooltip, a ten má na mobile spúšťač práve
            // dlhé podržanie — zožral by ho skôr, než sa dostane ku
            // GestureDetectoru nižšie, a MOB by sa nedal aktivovať.
            // Rovnaká pasca ako pri _layerFab v map_screen.dart.
            backgroundColor:
                mobActive ? Colors.red.shade900 : Colors.red.shade700,
            foregroundColor: Colors.white,
            // Ťuknutie MOB nespúšťa — len povie, ako sa spúšťa. Poplach,
            // ktorý sa dá vyvolať zavadením rukávom, je poplach, ktorému
            // posádka po treťom raze prestane veriť.
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.mobHoldToActivate)),
            ),
            child: const Icon(Icons.person_off),
          ),
        ),
      ],
    );
  }

  /// Kotva jedným ťuknutím, s naposledy použitým polomerom.
  ///
  /// Kotvenie je manéver: kotva ide dole, loď sa ťahá na reťazi a skiper má
  /// obe ruky plné. Preklikať sa v tej chvíli cez Bezpečnosť a posuvník je
  /// presne to, čo sa odloží na neskôr a už sa neurobí. Polomer sa dá doladiť
  /// na karte Bezpečnosť, tu ide o to, aby stráž vôbec začala strážiť.
  Future<void> _quickAnchor(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
    if (pos == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.anchorNoFix)));
      return;
    }
    final radius = await AnchorNotifier.lastRadius();
    await ref
        .read(anchorProvider.notifier)
        .activate(pos.latitude, pos.longitude, radius);
    // Hláška až podľa skutočného stavu, nie podľa toho, že sme o spustenie
    // požiadali. Keď sa stráž z akéhokoľvek dôvodu nechytí, nesmie na
    // obrazovke svietiť, že beží — hlásené z terénu: „kotva neaktívna, ale
    // vidím Kotvová stráž beží 15 m".
    if (!ref.read(anchorProvider).isActive) return;
    messenger.showSnackBar(SnackBar(
      content: Text(l.anchorQuickStarted(radius.toStringAsFixed(0))),
      action: SnackBarAction(
        label: l.cancel,
        onPressed: () => ref.read(anchorProvider.notifier).deactivate(),
      ),
    ));
  }

  /// Prepne mapu do kreslenia kotevnej plochy.
  ///
  /// Ten istý pokyn, aký posiela karta Kotva v Bezpečnosti — mapa si ho
  /// vyzdvihne a zapne nástroj. Odtiaľ už ide všetko po starom: ťukaním sa
  /// kladú rohy a panel plochu spustí.
  void _drawAnchorZone(BuildContext context) {
    HapticFeedback.selectionClick();
    ref.read(pendingAnchorZoneDrawProvider.notifier).state = true;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).anchorZoneTool),
      duration: const Duration(seconds: 2),
    ));
  }

  /// Vypnutie stráže vždy cez otázku.
  ///
  /// Ťuknutie vedľa pri zdvihnutej kotve je len zbytočný záznam v denníku;
  /// ťuknutie vedľa o tretej ráno vypne to jediné, čo loď stráži.
  Future<void> _confirmStopAnchor(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final stop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.anchorQuickStopTitle),
        content: Text(l.anchorQuickStopBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.deactivate)),
        ],
      ),
    );
    if (stop ?? false) await ref.read(anchorProvider.notifier).deactivate();
  }

  /// MOB sa aktivuje podržaním, nie ťuknutím.
  ///
  /// Rovnako ako na karte Bezpečnosť: tlačidlo sedí medzi ostatnými rýchlymi
  /// akciami a náhodné ťuknutie by spustilo poplach aj s vysielaním polohy.
  /// Podržanie je o sekundu pomalšie a o poplach menej.
  void _quickMob(BuildContext context) {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
    if (pos == null) {
      messenger.showSnackBar(SnackBar(
          content: Text(l.gpsPositionNotAvailable),
          backgroundColor: Colors.red));
      return;
    }
    ref.read(mobProvider.notifier).activate(pos.latitude, pos.longitude);
    HapticFeedback.heavyImpact();
    // Bez prepnutia na Bezpečnosť: kto stlačil MOB, díva sa na mapu a na
    // vodu okolo lode, nie na kartu s číslami. Mapa v tej chvíli už kreslí
    // značku bodu pádu a tlačidlo ostáva tmavočervené, takže je z čoho
    // vidieť, že poplach beží. Na kartu sa dá prejsť spodným menu.
    messenger.showSnackBar(SnackBar(
      content: Text(l.mobActive),
      backgroundColor: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    ));
  }

  /// Zrušenie MOB tiež podržaním — a až po otázke.
  ///
  /// Kým sa človek nevytiahne z vody, vypnutý MOB znamená stratený bod pádu.
  Future<void> _confirmCancelMob(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final stop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.mobCancelTitle),
        content: Text(l.mobCancelBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.deactivate)),
        ],
      ),
    );
    if (stop ?? false) await ref.read(mobProvider.notifier).deactivate();
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
    final onMap = _currentPath(context) == '/map';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBack(context),
      child: Scaffold(
        body: Column(children: [
          SafeArea(
            bottom: false,
            child: Column(children: [
              const SyncQueueBadge(),
              // Na každej karte, nie len tam, kde je ovládanie plavby:
              // otvorená plavba, ktorá nezapisuje, je najhorší stav appky
              // a skiper sa o ňom má dozvedieť, nech je kdekoľvek.
              const TrackingStalledBanner(),
              if (showControlBar) const TrackingControlBar(),
            ]),
          ),
          Expanded(child: widget.child),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        // Počas plavby rýchle akcie vedľa seba: kormidelník, obrat, fotka.
        // Všetky zapisujú do denníka bez otvárania formulára — na kormidle
        // je na vyplňovanie polí neskoro. Vedľa seba, nie nad sebou: nad
        // sebou horné tlačidlo prekrývalo obsah.
        //
        // Na mape pribudnú kotva a MOB. Nie na ostatných kartách: päť
        // tlačidiel je maximum, ktoré sa na úzky telefón zmestí do riadku,
        // a mapa je jediná karta, kde ich má skiper v ruke v tej chvíli, keď
        // ich potrebuje — kotva pri vplávaní do zátoky, MOB pri pohľade na
        // vodu okolo lode.
        //
        // Kotva je výnimka z „počas plavby": kotví sa aj vtedy, keď sa žiadna
        // plavba nezapisuje — zastávka na obed, noc v zátoke po skončení
        // plavby, loď na bóji. Stráž si na to zakladá vlastný nezávislý úsek,
        // takže na trasovaní nezávisí a čakať s ňou na spustenie plavby by
        // bolo presne naopak.
        floatingActionButton: onMap
            ? _quickActions(context, l, isTracking: isTracking)
            : null,
        bottomNavigationBar: MainNavBar(
          paths: visiblePaths,
          currentIndex: currentIndex,
          onSelected: (i) => context.go(visiblePaths[i]),
          iconSize: navPrefs.iconSize,
        ),
      ),
    );
  }
}
