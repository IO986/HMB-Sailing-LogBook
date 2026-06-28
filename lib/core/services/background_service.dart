import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import 'gps_tracking_service.dart';
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
        initialNotificationTitle: 'Sailing Logbook',
        initialNotificationContent: 'GPS tracking aktívny',
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
    Timer? logbookTimer;

    Position? lastWeatherSyncPosition;
    DateTime? lastWeatherSyncTime;

    // Weather sync každých 15 min kontrola
    weatherTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) async {
        try {
          final pos = await Geolocator.getCurrentPosition();

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

    // Automatický lodný denník každú hodinu
    logbookTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) async {
        try {
          // Auto entry sa vytvára automaticky v GPS service timerom
        } catch (_) {}
      },
    );

    service.on('stopService').listen((event) {
      weatherTimer?.cancel();
      logbookTimer?.cancel();
      service.stopSelf();
    });
  }

  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}
