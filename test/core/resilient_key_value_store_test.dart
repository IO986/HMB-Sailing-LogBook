import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/resilient_key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nahlásené z testovacieho Honoru: appka si nepamätá skipera, takže pri novej
/// plavbe nemá čo ponúknuť. Profil žil iba vo FlutterSecureStorage, ktoré na
/// Honor a Huawei hádže výnimku — a tá sa ticho zhltla, takže zápis „prešiel"
/// a nič sa neuložilo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ResilientKeyValueStore.resetFallbackFlag();
  });

  ResilientKeyValueStore broken() => ResilientKeyValueStore(
        secureRead: (_) async => throw Exception('keystore unavailable'),
        secureWrite: (_, __) async => throw Exception('keystore unavailable'),
        secureDelete: (_) async => throw Exception('keystore unavailable'),
      );

  ResilientKeyValueStore working(Map<String, String> box) =>
      ResilientKeyValueStore(
        secureRead: (k) async => box[k],
        secureWrite: (k, v) async => box[k] = v,
        secureDelete: (k) async => box.remove(k),
      );

  test('s rozbitým keystorom sa údaj aj tak uloží a prečíta', () async {
    final store = broken();

    await store.write('skipper_full_name', 'Vladimír Plodek');

    expect(await store.read('skipper_full_name'), 'Vladimír Plodek');
    expect(ResilientKeyValueStore.usedFallback, isTrue);
  });

  test('funkčný keystore zálohu nepoužije', () async {
    final box = <String, String>{};
    final store = working(box);

    await store.write('skipper_full_name', 'Ján Novák');

    expect(box['skipper_full_name'], 'Ján Novák');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('fallback_skipper_full_name'), isNull,
        reason: 'nešifrovaná kópia nemá prečo ostať');
  });

  /// Keystore sa môže rozbiť aj opraviť (reinštalácia, aktualizácia systému).
  /// Vtedy sa musí čítať to novšie, nie stará šifrovaná hodnota.
  test('po oprave keystoru sa záloha zahodí, aby sa nečítalo staré', () async {
    final box = <String, String>{};
    await working(box).write('skipper_license_number', 'staré číslo');

    // Keystore vypadne, skiper zapíše nové číslo — ide do zálohy.
    await broken().write('skipper_license_number', 'nové číslo');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('fallback_skipper_license_number'), 'nové číslo');

    // Keystore sa vráti a skiper uloží znova: záloha zmizne.
    await working(box).write('skipper_license_number', 'nové číslo');
    expect(prefs.getString('fallback_skipper_license_number'), isNull);
    expect(box['skipper_license_number'], 'nové číslo');
  });

  test('nezapísaný kľúč vracia null, nie výnimku', () async {
    expect(await broken().read('nikdy_nezapisane'), isNull);
  });

  test('mazanie vezme šifrovanú hodnotu aj zálohu', () async {
    final box = <String, String>{};
    await working(box).write('skipper_vhf_number', 'SRC 123');
    await broken().write('skipper_id_number', 'AB123456');

    await working(box).delete('skipper_vhf_number');
    await broken().delete('skipper_id_number');

    expect(box, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('fallback_skipper_id_number'), isNull);
  });
}
