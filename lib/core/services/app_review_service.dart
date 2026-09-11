import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a Play Store rating — rarely, and only after a finished voyage.
///
/// The prompt is Google's own sheet, shown inside the app; it cannot be
/// forced and Play silently drops it once its quota is used up. That makes
/// *when* we ask the only thing under our control, so the rules here are
/// deliberately strict: a skipper who has just closed a day at sea has a
/// reason to have an opinion, one who opened the app for the first time does
/// not. Asking at the wrong moment costs a one-star review.
///
/// The store listing is the other half ([openStoreListing]): it has no quota,
/// so the Settings button always works even when the sheet refuses.
class AppReviewService {
  AppReviewService({InAppReview? review})
      : _review = review ?? InAppReview.instance;

  final InAppReview _review;

  // Počítadlá v SharedPreferences: obyčajné nastavenie appky, nie tajomstvo
  // ani záznam plavby. Keď ich zálohovanie telefónu prenesie na nový
  // prístroj, nič sa nedeje; keď ich stratí, appka sa spýta o plavbu neskôr.
  static const _kVoyages = 'review_voyages_finished';
  static const _kLastPrompt = 'review_last_prompt_ms';
  static const _kPromptCount = 'review_prompt_count';

  /// Koľko ukončených plavieb musí mať skiper za sebou, kým sa vôbec pýtame.
  ///
  /// Prvá plavba je zoznamovanie sa s appkou a názor na ňu v tej chvíli nemá
  /// cenu — ani pre skipera, ani pre hodnotenie.
  static const _minVoyages = 2;

  /// Najkratší odstup medzi dvomi opýtaniami.
  static const _minGap = Duration(days: 90);

  /// Koľkokrát sa smie appka spýtať za celý svoj život v telefóne.
  ///
  /// Kto nechcel hodnotiť trikrát, nechce hodnotiť. Ďalšie pýtanie by už bolo
  /// otravovanie a Play za to platí hviezdičkami.
  static const _maxPrompts = 3;

  /// Zavolaj po tom, čo skiper ukončil plavbu (nie počas nej).
  ///
  /// Sama si rozhodne, či je čas — volajúci nemusí nič rátať.
  Future<void> onVoyageFinished() async {
    final prefs = await SharedPreferences.getInstance();
    final voyages = (prefs.getInt(_kVoyages) ?? 0) + 1;
    await prefs.setInt(_kVoyages, voyages);
    if (voyages < _minVoyages) return;

    final prompts = prefs.getInt(_kPromptCount) ?? 0;
    if (prompts >= _maxPrompts) return;

    final lastMs = prefs.getInt(_kLastPrompt);
    if (lastMs != null) {
      final since = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastMs));
      if (since < _minGap) return;
    }

    try {
      if (!await _review.isAvailable()) return;
      await _review.requestReview();
      // Zapíše sa aj keď Play sheet potichu nezobrazí: appka nemá ako zistiť,
      // či sa ukázal, a opakovať pokus zajtra by znamenalo pýtať sa denne.
      await prefs.setInt(_kLastPrompt, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_kPromptCount, prompts + 1);
    } catch (e) {
      // Bez Play služieb (sideload, Huawei) API neexistuje — hodnotenie je
      // bonus, nie funkcia denníka, takže sa to nikde nehlási.
      debugPrint('[REVIEW] request failed: $e');
    }
  }

  /// Otvorí kartu appky v obchode — bez kvóty, takže tlačidlo v Nastaveniach
  /// funguje vždy, aj keď sa vstavaný formulár už zobraziť odmieta.
  Future<void> openStoreListing() async {
    try {
      await _review.openStoreListing();
    } catch (e) {
      debugPrint('[REVIEW] store listing failed: $e');
    }
  }
}
