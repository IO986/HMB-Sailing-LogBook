import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../database/app_database.dart';
import 'weather_repository.dart';

@pragma('vm:entry-point')
class BackgroundService {
  static Future<void> init() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sailing_tracking',
      'GPS Tracking',
      description: 'Aktívne GPS sledovanie plavby',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'sailing_tracking',
        initialNotificationTitle: 'SAILLOG',
        initialNotificationContent: 'Tracking plavby beží',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    Timer? weatherTimer;

    Position? lastWeatherSyncPosition;
    DateTime? lastWeatherSyncTime;

    // Tento callback beží vo vlastnom izolate (flutter_background_service),
    // kde `WeatherRepository()` je iná inštancia singletonu než tá, ktorú si
    // `main.dart` naviazal na databázu — bez tohto by `syncWeather()` nižšie
    // vždy skončila na `if (db == null) return`, potichu a bez chyby. Presne
    // preto sa vietor z modelu do automatického záznamu nikdy nedostal, keď
    // anemometer mlčal: keš predpovede sa v skutočnosti nikdy neobnovovala.
    final db = AppDatabase();
    WeatherRepository().setDatabase(db);

    // Weather sync každých 15 min kontrola
    weatherTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) async {
        try {
          // Zámerne last-known, nie getCurrentPosition(): tá by rozbehla
          // vlastný GNSS fix v tomto izoláte, hoci appka v popredí má živý
          // stream a poloha je teda čerstvá. Na rozhodnutie "posunuli sme sa
          // o 25 km?" stačí posledná známa poloha aj keby bola staršia.
          final pos = await Geolocator.getLastKnownPosition();
          if (pos == null) return;

          final shouldSync = lastWeatherSyncPosition == null ||
              Geolocator.distanceBetween(
                    lastWeatherSyncPosition!.latitude,
                    lastWeatherSyncPosition!.longitude,
                    pos.latitude,
                    pos.longitude,
                  ) >
                  25000 ||
              lastWeatherSyncTime == null ||
              DateTime.now().difference(lastWeatherSyncTime!) >
                  const Duration(hours: 6);

          if (shouldSync) {
            await WeatherRepository().syncWeather(
              lat: pos.latitude,
              lon: pos.longitude,
            );

            lastWeatherSyncPosition = pos;
            lastWeatherSyncTime = DateTime.now();
          }
        } catch (_) {}
      },
    );

    // Automatický lodný denník tu ŽIADNY timer nemá — zapisuje ho
    // GpsTrackingService vlastným timerom v hlavnom izoláte. Predtým tu stála
    // hodinová Timer.periodic s prázdnym telom, ktorá len budila zariadenie.

    service.on('stopService').listen((event) {
      weatherTimer?.cancel();
      db.close();
      service.stopSelf();
    });
  }

  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  /// Zastaví službu a počká, kým naozaj zhasne.
  ///
  /// `invoke('stopService')` je fire-and-forget: keď izolát služby práve
  /// štartuje alebo prežil pád appky, správa sa stratí a systémová
  /// notifikácia "tracking aktívny" ostane visieť aj dávno po zastavení
  /// plavby (hlásené z terénu na OUKITELi). Preto sa výsledok overuje a
  /// pokus sa raz zopakuje.
  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    for (var attempt = 0; attempt < 2; attempt++) {
      if (!await service.isRunning()) return;
      service.invoke('stopService');
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (!await service.isRunning()) return;
      }
    }
  }

  /// Upratovanie po štarte appky: služba beží, ale nič sa netrasuje.
  ///
  /// Stane sa to, keď appku zabije systém — foreground service ju prežije aj
  /// s notifikáciou, no tracking už nikto neriadi. [trackingActive] sa podáva
  /// zvonka, aby táto trieda nemusela poznať GPS službu.
  static Future<void> stopIfOrphaned({required bool trackingActive}) async {
    if (trackingActive) return;
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) return;
    await stop();
  }
}
