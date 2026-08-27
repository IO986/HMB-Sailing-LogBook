import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gps_tracking_service.dart';

/// Ako často sa appka smie pýtať Play, či je novšia verzia.
const _checkInterval = Duration(days: 1);

const _lastCheckKey = 'update_last_check';

/// Rozhodne, či sa má vôbec ísť pýtať Play.
///
/// Čistá funkcia zámerne: samotné volanie Play API sa v teste spustiť nedá,
/// ale toto rozhodovanie je práve tá časť, ktorú treba mať istú — kontrola
/// uprostred plavby je horšia než žiadna kontrola.
bool shouldCheckForUpdate({
  required DateTime now,
  required DateTime? lastCheck,
  required bool isTracking,
  Duration interval = _checkInterval,
}) {
  // Počas plavby nie. Skiper má ruky na kormidle a Play by mu cez appku
  // vyhodilo súhlasový dialóg; navyše sťahovanie na mori ide cez dáta,
  // ktoré tam bývajú drahé alebo žiadne.
  if (isTracking) return false;
  if (lastCheck == null) return true;
  // Hodiny na telefóne sa dajú prestaviť dozadu — potom by lastCheck ostal
  // v budúcnosti a kontrola by sa už nikdy nespustila.
  if (lastCheck.isAfter(now)) return true;
  return now.difference(lastCheck) >= interval;
}

/// Upozornenie na novú verziu z Google Play.
///
/// Používa sa flexible režim: Play si vyžiada súhlas, stiahne aktualizáciu na
/// pozadí a appka medzitým normálne funguje. Immediate režim by prekryl
/// obrazovku celoobrazovkovým dialógom — pri appke, ktorá môže mať práve
/// rozbehnutý záznam plavby, to nechceme.
///
/// Všetko zlyháva ticho. Aktualizácia je bonus; appka musí naštartovať
/// a zapisovať aj v režime lietadlo, bez signálu a bez Play služieb.
class AppUpdateService {
  static final AppUpdateService _i = AppUpdateService._();
  factory AppUpdateService() => _i;
  AppUpdateService._();

  StreamSubscription<InstallStatus>? _sub;

  /// Spustí sa, keď je stiahnutá aktualizácia pripravená na inštaláciu.
  /// Volajúci (UI) na to ponúkne reštart.
  void Function()? onDownloaded;

  @visibleForTesting
  bool debugSkipPlatformCheck = false;

  bool get _supported =>
      debugSkipPlatformCheck ||
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  /// Pozrie sa, či Play ponúka novšiu verziu, a ak áno, spustí sťahovanie na
  /// pozadí. Vracia true, len keď sa sťahovanie naozaj rozbehlo.
  ///
  /// Mimo Androidu, pri appke nainštalovanej mimo Play (sideload, náš vlastný
  /// APK z `flutter build apk`) a bez siete jednoducho neurobí nič.
  Future<bool> checkAndStart() async {
    if (!_supported) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getInt(_lastCheckKey);
      final lastCheck =
          raw == null ? null : DateTime.fromMillisecondsSinceEpoch(raw);

      if (!shouldCheckForUpdate(
        now: DateTime.now(),
        lastCheck: lastCheck,
        isTracking: GpsTrackingService().isTracking,
      )) {
        return false;
      }
      await prefs.setInt(
          _lastCheckKey, DateTime.now().millisecondsSinceEpoch);

      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable ||
          !info.flexibleUpdateAllowed) {
        return false;
      }

      _listen();
      await InAppUpdate.startFlexibleUpdate();
      return true;
    } catch (e) {
      debugPrint('[UPDATE] check failed: $e');
      return false;
    }
  }

  void _listen() {
    _sub ??= InAppUpdate.installUpdateListener.listen(
      (status) {
        if (status == InstallStatus.downloaded) onDownloaded?.call();
      },
      onError: (e) => debugPrint('[UPDATE] listener error: $e'),
    );
  }

  /// Dokončí inštaláciu stiahnutej aktualizácie — appka sa pritom reštartuje.
  Future<void> install() async {
    if (!_supported) return;
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('[UPDATE] install failed: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
