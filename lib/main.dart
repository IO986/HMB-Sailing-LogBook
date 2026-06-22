import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'core/database/app_database.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/background_service.dart';
import 'core/services/gps_tracking_service.dart';
import 'core/services/location_service.dart';
import 'core/services/raymarine_connection_service.dart';
import 'core/services/weather_repository.dart';
import 'core/services/weather_service.dart';
import 'features/export/services/export_service.dart';
import 'l10n/app_localizations.dart';
import 'shared/theme/app_theme.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  return db;
});

/// True, ak ešte nikdy neboli nastavené žiadne Raymarine pripojenie -
/// použije sa na zobrazenie jednorazovej výzvy na splash/map obrazovke.
final raymarineNeverConfiguredProvider = Provider<bool>((ref) => true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  for (final locale in ['sk', 'en', 'de', 'es', 'uk']) {
    await initializeDateFormatting(locale, null);
  }

  final db = AppDatabase();
  await db.fixOrphanedSessions();

  // Spusti GPS vždy - nezávisle od trackingu.
  // LocationService interne prioritizuje Raymarine dáta (ak sú pripojené
  // a fresh), inak používa Android GPS.
  await LocationService().init();
  GpsTrackingService().setDatabase(db);
  WeatherService().setDatabase(db);
  WeatherRepository().setDatabase(db);
  ExportService().setDatabase(db);

  await BackgroundService.init();

  // Ak má používateľ uložené nastavenia lodných inštrumentov s auto-connect,
  // skús sa pripojiť na pozadí. Toto nesmie blokovať štart appky - ak
  // gateway nie je dostupný, appka normálne pokračuje s GPS telefónu.
  _tryAutoConnectRaymarine();

  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('app_locale') ?? 'sk';

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      localeProvider.overrideWith(() => LocaleNotifier()..initialCode = savedLocale),
    ],
    child: const HmbSailingLogApp(),
  ));
}

Future<void> _tryAutoConnectRaymarine() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final autoConnect = prefs.getBool('raymarine_auto_connect') ?? false;
    final host = prefs.getString('raymarine_host') ?? '';
    if (!autoConnect || host.isEmpty) return;

    final port = prefs.getInt('raymarine_port') ?? 2000;
    // Nečakáme na výsledok - pripájanie beží na pozadí, appka štartuje hneď.
    RaymarineConnectionService().connect(
      host: host,
      port: port,
      autoReconnect: true,
    );
  } catch (e) {
    print('[MAIN] Raymarine auto-connect skipped: $e');
  }
}

class HmbSailingLogApp extends ConsumerWidget {
  const HmbSailingLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
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
    );
  }
}
