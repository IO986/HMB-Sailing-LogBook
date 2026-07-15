import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'core/database/app_database.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/night_mode_provider.dart';
import 'core/services/background_service.dart';
import 'core/services/gps_tracking_service.dart';
import 'core/services/location_service.dart';
import 'core/services/raymarine_connection_service.dart';
import 'core/services/udp_receiver_service.dart';
import 'core/services/weather_repository.dart';
import 'core/services/weather_service.dart';
import 'core/services/account_service.dart';
import 'core/services/sync_service.dart';
import 'features/export/services/export_service.dart';
import 'l10n/app_localizations.dart';
import 'shared/theme/app_theme.dart';

AppDatabase _currentDb = AppDatabase();

/// [databaseProvider] číta z [_currentDb] namiesto pevnej hodnoty, aby po
/// obnove zo zálohy (viď BackupService) stačilo vymeniť [_currentDb] a
/// zavolať `ref.invalidate(databaseProvider)` – všetci `watch` odberatelia
/// (napr. charter_provider.dart) sa prekreslia s novou inštanciou.
final databaseProvider = Provider<AppDatabase>((ref) => _currentDb);

/// Nastaví DB inštanciu, ktorú vracia [databaseProvider]. Volajúci musí po
/// tomto zavolať `ref.invalidate(databaseProvider)`.
void replaceCurrentDatabase(AppDatabase db) => _currentDb = db;

/// Prepojí DB inštanciu do singleton služieb, ktoré si ju držia mimo
/// Riverpod (nemajú providery). Volané pri štarte aj po obnove zo zálohy.
void wireDatabaseSingletons(AppDatabase db) {
  GpsTrackingService().setDatabase(db);
  WeatherService().setDatabase(db);
  WeatherRepository().setDatabase(db);
  ExportService().setDatabase(db);
  SyncService().setDatabase(db);
}

/// True, ak ešte nikdy neboli nastavené žiadne Raymarine pripojenie -
/// použije sa na zobrazenie jednorazovej výzvy na splash/map obrazovke.
final raymarineNeverConfiguredProvider = Provider<bool>((ref) => true);

/// Naplnené raz pri štarte (pred `runApp`) — pozri `main()`. Rovnaký vzor
/// ako `_currentDb`/`databaseProvider`: appka číta verziu synchrónne
/// (napr. do sync envelope), bez opakovaného `PackageInfo.fromPlatform()`.
String _appVersion = 'unknown';
final appVersionProvider = Provider<String>((ref) => _appVersion);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Celoobrazovkový režim: skryje status bar aj navigačnú lištu telefónu.
  // Sticky = swipe od okraja ich dočasne zobrazí, potom sa samy schovajú.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  for (final locale in ['sk', 'en', 'de', 'es', 'uk']) {
    await initializeDateFormatting(locale, null);
  }

  final packageInfo = await PackageInfo.fromPlatform();
  _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

  final db = _currentDb;
  await db.fixOrphanedSessions();

  // Spusti GPS vždy - nezávisle od trackingu.
  // LocationService interne prioritizuje Raymarine dáta (ak sú pripojené
  // a fresh), inak používa Android GPS.
  await LocationService().init();
  wireDatabaseSingletons(db);
  await AccountService().init();

  await BackgroundService.init();

  // Ihneď po štarte synchrónizuj počasie pre aktuálnu polohu.
  // Fire-and-forget: neblokuje štart UI.
  _syncWeatherOnStartup();

  // Ak má používateľ uložené nastavenia lodných inštrumentov s auto-connect,
  // skús sa pripojiť na pozadí. Toto nesmie blokovať štart appky - ak
  // gateway nie je dostupný, appka normálne pokračuje s GPS telefónu.
  _tryAutoConnectRaymarine();

  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('app_locale');
  final isFirstLaunch = savedLocale == null;

  String initialLocale;
  if (savedLocale != null) {
    initialLocale = savedLocale;
  } else {
    // Auto-detect from system locale, fallback to EN
    final systemLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    const supported = ['sk', 'en', 'de', 'es', 'uk'];
    initialLocale = supported.contains(systemLang) ? systemLang : 'en';
  }

  if (isFirstLaunch) {
    await prefs.setBool('first_launch', true);
  }

  runApp(ProviderScope(
    overrides: [
      localeProvider.overrideWith(() => LocaleNotifier()..initialCode = initialLocale),
    ],
    child: const HmbSailingLogApp(),
  ));
}

Future<void> _tryAutoConnectRaymarine() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final autoConnect = prefs.getBool('raymarine_auto_connect') ?? false;
    if (!autoConnect) return;

    final typeStr = prefs.getString('nmea_connection_type') ?? 'tcp';

    if (typeStr == 'udp') {
      final udpPort = prefs.getInt('nmea_udp_port') ?? 10110;
      UdpReceiverService().start(port: udpPort);
    } else {
      final host = prefs.getString('raymarine_host') ?? '';
      if (host.isEmpty) return;
      final port = prefs.getInt('raymarine_port') ?? 2000;
      RaymarineConnectionService().connect(
        host: host,
        port: port,
        autoReconnect: true,
      );
    }
  } catch (e) {
    debugPrint('[MAIN] NMEA auto-connect skipped: $e');
  }
}

/// Synchrónizuje počasie hneď pri štarte apky, bez čakania na spustenie
/// GPS trackingu. Ak máme last-known polohu, použijeme ju okamžite.
/// Inak čakáme max 30 sekúnd na prvý GPS fix zo streamu.
void _syncWeatherOnStartup() {
  final loc = LocationService();
  final repo = WeatherRepository();

  Future<void> doSync(double lat, double lon) async {
    try {
      await repo.syncWeather(lat: lat, lon: lon);
      debugPrint('[MAIN] Pocasie synced pri starte: $lat, $lon');
    } catch (e) {
      debugPrint('[MAIN] Weather sync zlyhal: $e');
    }
  }

  final last = loc.lastPosition;
  if (last != null) {
    doSync(last.latitude, last.longitude);
    return;
  }

  // Počkaj na prvú polohu zo streamu (max 30 s).
  StreamSubscription? sub;
  final timeout = Timer(const Duration(seconds: 30), () => sub?.cancel());
  sub = loc.stream.listen((pos) {
    sub?.cancel();
    timeout.cancel();
    doSync(pos.latitude, pos.longitude);
  });
}

class HmbSailingLogApp extends ConsumerWidget {
  const HmbSailingLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final nightMode = ref.watch(nightModeProvider);
    return MaterialApp.router(
      title: 'HMB Sailing Log',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        if (!nightMode || child == null) return child ?? const SizedBox();
        // Red filter: preserves night vision by removing green/blue channels.
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.7, 0, 0, 0, 0,
            0,   0, 0, 0, 0,
            0,   0, 0, 0, 0,
            0,   0, 0, 1, 0,
          ]),
          child: child,
        );
      },
    );
  }
}
