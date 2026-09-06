import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/skipper_profile.dart';
import 'package:hmb_sailing_log/core/providers/skipper_profile_provider.dart';
import 'package:hmb_sailing_log/core/services/resilient_key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// V builde 69 sa profil skipera „uložil" a neuložil: zápis do šifrovaného
/// úložiska na Honore vyhodil výnimku, tá sa zhltla a appka sa tvárila, že je
/// hotovo. Uloženie teraz vracia, či sa dá načítať späť to isté.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ResilientKeyValueStore.resetFallbackFlag();
  });

  // Úložisko je knižnicová premenná — vrátiť ju treba, inak si ju ďalší test
  // v tom istom súbore zdedí aj s podstrčeným keystorom.
  tearDown(() => skipperProfileStore = const ResilientKeyValueStore());

  const profile = SkipperProfile(
    fullName: 'Vladimír Plodek',
    licenseType: 'Veliteľ námornej jachty',
    licenseNumber: 'SK-12345',
    vhfNumber: 'SRC-987',
    otherCerts: 'ISAF',
    idNumber: 'AB1234567',
  );

  ProviderContainer container() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('funkčné úložisko: uloží sa a načíta späť to isté', () async {
    final box = <String, String>{};
    skipperProfileStore = ResilientKeyValueStore(
      secureRead: (k) async => box[k],
      secureWrite: (k, v) async => box[k] = v,
    );

    final c = container();
    final saved = await c.read(skipperProfileProvider.notifier).save(profile);

    expect(saved, isTrue);
    final back = await c.read(skipperProfileProvider.future);
    expect(back.fullName, 'Vladimír Plodek');
    expect(back.idNumber, 'AB1234567');
  });

  /// Honor: keystore odmieta, ale nešifrovaná záloha zaberie — údaje sa
  /// zapamätajú a uloženie sa hlási ako úspešné, lebo naozaj úspešné je.
  test('rozbitý keystore: záloha zaberie a uloženie sa potvrdí', () async {
    skipperProfileStore = ResilientKeyValueStore(
      secureRead: (_) async => throw Exception('keystore'),
      secureWrite: (_, __) async => throw Exception('keystore'),
    );

    final c = container();
    final saved = await c.read(skipperProfileProvider.notifier).save(profile);

    expect(saved, isTrue);
    expect((await c.read(skipperProfileProvider.future)).licenseNumber,
        'SK-12345');
    // Bez tohto by test prešiel pri akomkoľvek úložisku a nedokazoval by, že
    // zabrala práve záloha.
    expect(ResilientKeyValueStore.usedFallback, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('fallback_skipper_full_name'), 'Vladimír Plodek');
  });

  /// Zoznam profilov (pre loď, kde sa strieda viac skiperov) dosiaľ nikdy
  /// nevznikol: prázdny sa vracal ako `const []` a `removeWhere` naň vyhodil
  /// výnimku, ktorú nikto nevidel.
  test('uložený profil sa objaví v zozname profilov', () async {
    final box = <String, String>{};
    skipperProfileStore = ResilientKeyValueStore(
      secureRead: (k) async => box[k],
      secureWrite: (k, v) async => box[k] = v,
    );

    final c = container();
    final notifier = c.read(skipperProfileProvider.notifier);
    await notifier.save(profile);
    expect((await notifier.listSaved()).map((p) => p.fullName),
        ['Vladimír Plodek']);

    // Druhý skiper sa pridá pred neho, ten istý sa nezduplikuje.
    await notifier.save(const SkipperProfile(fullName: 'Ján Novák'));
    await notifier.save(profile);
    final names = (await notifier.listSaved()).map((p) => p.fullName).toList();
    expect(names, ['Vladimír Plodek', 'Ján Novák']);
  });

  /// A keď zlyhá aj záloha, uloženie to prizná — presne to build 69 nevedel.
  test('keď neuloží nič, save vráti false', () async {
    skipperProfileStore = ResilientKeyValueStore(
      secureRead: (_) async => null,
      secureWrite: (_, __) async {}, // tvári sa, že zapísal
    );

    final c = container();
    final saved = await c.read(skipperProfileProvider.notifier).save(profile);

    expect(saved, isFalse, reason: 'spätné načítanie nevrátilo to isté');
  });
}
