import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Zvuk a hlasitosť kotevného alarmu.
///
/// Na Androide beží prehrávanie natívne (kanál `hmb/alarm`) z dvoch dôvodov,
/// a oba sú o tretej ráno podstatné:
///
///  * Zvuk si vyberá skiper zo VŠETKÝCH zvukov v telefóne cez systémový
///    výber, nie z troch, ktoré ponúkal plugin. Zobudí ho ten, ktorý pozná.
///  * Hlasitosť v nastaveniach appky je skutočná hlasitosť, nie násobič
///    hlasitosti telefónu. Natívna strana na čas alarmu zdvihne alarmový
///    kanál na zvolenú úroveň a po skončení ho vráti tam, kde bol.
///
/// Mimo Androidu (desktop) ostáva pôvodný plugin so systémovým alarmom —
/// tam sa kotva nestráži, je to len poistka, aby sa kód dal preložiť.
class AnchorAlarmService {
  static final AnchorAlarmService _i = AnchorAlarmService._();
  factory AnchorAlarmService() => _i;
  AnchorAlarmService._();

  static const _channel = MethodChannel('hmb/alarm');

  Timer? _vibrationTimer;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _alarmActive = false;

  bool get isAlarmActive => _alarmActive;

  static bool get _native => !kIsWeb && Platform.isAndroid;

  static const _kSoundUri = 'anchor_alarm_sound_uri';
  static const _kSoundTitle = 'anchor_alarm_sound_title';
  static const _kVolume = 'anchor_alarm_volume';

  /// Predvolená hlasitosť: naplno. Kotvová stráž má zobudiť spiaceho
  /// človeka pod palubou.
  static const double defaultVolume = 1;

  /// URI vybraného zvuku, alebo `null` pre systémový alarm telefónu.
  static Future<String?> soundUri() async {
    try {
      final p = await SharedPreferences.getInstance();
      final uri = p.getString(_kSoundUri);
      return (uri == null || uri.isEmpty) ? null : uri;
    } catch (_) {
      // Nastavenia, ktoré sa nedajú prečítať, nesmú alarm umlčať.
      return null;
    }
  }

  /// Názov vybraného zvuku pre nastavenia. `null` znamená „systémový alarm".
  static Future<String?> soundTitle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final cached = p.getString(_kSoundTitle);
      if (cached != null && cached.isNotEmpty) return cached;
      final uri = p.getString(_kSoundUri);
      if (uri == null || uri.isEmpty || !_native) return null;
      return await _channel.invokeMethod<String>('soundTitle', {'uri': uri});
    } catch (_) {
      return null;
    }
  }

  /// Hlasitosť 0–1. Nula sa nepripúšťa: stráž, ktorá zvoní ticho, je stráž,
  /// ktorá nestráži. Kto ju nechce počuť, stráž nezapne.
  static Future<double> volume() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getDouble(_kVolume) ?? defaultVolume;
      return v.clamp(0.1, 1.0);
    } catch (_) {
      return defaultVolume;
    }
  }

  static Future<void> setVolume(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kVolume, v.clamp(0.1, 1.0));
  }

  /// Systémový výber zvuku — všetky budíky a zvonenia v telefóne.
  ///
  /// Vracia názov vybraného zvuku, alebo `null`, keď skiper výber zrušil.
  static Future<String?> pickSound() async {
    if (!_native) return null;
    final current = await soundUri();
    final picked = await _channel
        .invokeMapMethod<String, dynamic>('pickSound', {'uri': current});
    if (picked == null) return null;
    final uri = picked['uri'] as String?;
    if (uri == null || uri.isEmpty) return null;
    final title = picked['title'] as String?;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSoundUri, uri);
    await p.setString(_kSoundTitle, title ?? '');
    return title;
  }

  /// Je alarm počuteľný aj v režime Nerušiť?
  ///
  /// Zdvihnutie hlasitosti alarmového kanála pri zapnutom Nerušiť vyžaduje
  /// prístup k pravidlám upozornení, ktorý udeľuje jedine používateľ v
  /// systémových nastaveniach. Bez neho alarm zaznie, len takou hlasitosťou,
  /// akú má telefón nastavenú.
  static Future<bool> canOverrideDnd() async {
    if (!_native) return true;
    try {
      return await _channel.invokeMethod<bool>('canOverrideDnd') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openDndSettings() async {
    if (!_native) return;
    try {
      await _channel.invokeMethod<void>('openDndSettings');
    } catch (_) {
      // Niektoré telefóny tú obrazovku nemajú.
    }
  }

  /// Ukážka nastaveného zvuku — jedno prehratie, bez slučky.
  ///
  /// Zvuk, ktorý skiper nikdy nepočul, si o tretej ráno nespojí s kotvou.
  /// Nesiaha na [_alarmActive]: ukážka nie je poplach a nesmie sa s ním
  /// pomiešať, ani keď si ju niekto pustí počas driftu.
  Future<void> preview(double v) async {
    if (_alarmActive) return;
    await _play(await soundUri(), v, looping: false);
    // Bez slučky skončí sám, ale hlasitosť alarmového kanála treba vrátiť
    // späť — to robí `stop` na natívnej strane.
    Timer(const Duration(seconds: 5), () {
      if (!_alarmActive) _stopSound();
    });
  }

  static Future<void> _play(String? uri, double v, {required bool looping}) async {
    final vol = v.clamp(0.1, 1.0);
    if (_native) {
      try {
        await _channel.invokeMethod<void>('play', {
          'uri': uri,
          'volume': vol,
          'looping': looping,
        });
        return;
      } catch (e) {
        debugPrint('[ANCHOR ALARM] Native play failed: $e');
      }
    }
    // Poistka: keď natívna strana zlyhá, alarm musí zaznieť aspoň takto.
    await FlutterRingtonePlayer().play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: looping,
      asAlarm: true,
      volume: vol,
    );
  }

  static Future<void> _stopSound() async {
    if (_native) {
      try {
        await _channel.invokeMethod<void>('stop');
      } catch (e) {
        debugPrint('[ANCHOR ALARM] Native stop failed: $e');
      }
    }
    // Vždy aj plugin: keď hral on (poistka vyššie), natívne stop ho nevypne.
    await FlutterRingtonePlayer().stop();
  }

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
          playSound: false, // zvuk riadi natívny kanál hmb/alarm
          enableVibration: false,
        ));
    _initialized = true;
  }

  Future<void> startAlarm() async {
    if (_alarmActive) return;
    _alarmActive = true;
    await _ensureInit();

    // Zvuk aj hlasitosť sa načítavajú až tu, nie pri štarte appky, aby zmena
    // v nastaveniach platila hneď od najbližšieho driftu.
    await _play(await soundUri(), await volume(), looping: true);

    // Heads-up notifikácia – viditeľná aj so zamknutou obrazovkou (bez zvuku,
    // zvuk beží samostatne)
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
    // Nie skorý návrat na `!_alarmActive`: keď systém appku medzi driftom a
    // zdvihnutím kotvy zabije (Honor, Huawei), tento flag sa v pamäti
    // vynuluje, ale notifikácia z predošlého driftu ostáva v shade —
    // `deactivate()` by ju bez zrušenia guardu nikdy nezmazal.
    final wasActive = _alarmActive;
    _alarmActive = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    if (wasActive) await _stopSound();
    await _ensureInit();
    await _plugin.cancel(999);
  }
}
