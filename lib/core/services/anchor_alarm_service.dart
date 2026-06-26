import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class AnchorAlarmService {
  static final AnchorAlarmService _i = AnchorAlarmService._();
  factory AnchorAlarmService() => _i;
  AnchorAlarmService._();

  Timer? _vibrationTimer;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _alarmActive = false;

  bool get isAlarmActive => _alarmActive;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'anchor_alarm',
          'Kotva Alarm',
          description: 'Upozornenie pri driftovaní kotvy',
          importance: Importance.max,
          playSound: false, // zvuk riadi flutter_ringtone_player
          enableVibration: false,
        ));
    _initialized = true;
  }

  Future<void> startAlarm() async {
    if (_alarmActive) return;
    _alarmActive = true;
    await _ensureInit();

    // Systémový alarm zvuk na ALARM audio streame – hlasný, loopuje
    await FlutterRingtonePlayer().play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: true,
      asAlarm: true,
      volume: 1.0,
    );

    // Heads-up notifikácia – viditeľná aj so zamknutou obrazovkou (bez zvuku,
    // zvuk beží samostatne cez ringtone player)
    await _plugin.show(
      999,
      'KOTVA DRIFTUJE!',
      'Loď prekročila perimeter kotvy. Skontrolujte polohu!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'anchor_alarm',
          'Kotva Alarm',
          priority: Priority.max,
          importance: Importance.max,
          playSound: false,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 600, 300, 600, 300, 600]),
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
    );

    // Opakovaná vibrácia každé 2 s
    _vibrationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      HapticFeedback.heavyImpact();
    });
    HapticFeedback.heavyImpact();
  }

  Future<void> stopAlarm() async {
    if (!_alarmActive) return;
    _alarmActive = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    await FlutterRingtonePlayer().stop();
    await _plugin.cancel(999);
  }
}
