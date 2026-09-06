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
      );

  ResilientKeyValueStore working(Map<String, String> box) =>
      ResilientKeyValueStore(
        secureRead: (k) async => box[k],
        secureWrite: (k, v) async => box[k] = v,
      );

  Future<String?> fallbackOf(String key) async =>
      (await SharedPreferences.getInstance()).getString('fallback_$key');

  test('s rozbitým keystorom sa údaj aj tak uloží a prečíta', () async {
    final store = broken();

    expect(await store.write('skipper_full_name', 'Vladimír Plodek'), isTrue);

    expect(await store.read('skipper_full_name'), 'Vladimír Plodek');
    expect(await fallbackOf('skipper_full_name'), 'Vladimír Plodek',
        reason: 'hodnota musí ležať v zálohe, inak test nedokazuje nič');
    expect(ResilientKeyValueStore.usedFallback, isTrue);
  });

  test('funkčný keystore zálohu nepoužije', () async {
    final box = <String, String>{};
    final store = working(box);

    expect(await store.write('skipper_full_name', 'Ján Novák'), isTrue);

    expect(box['skipper_full_name'], 'Ján Novák');
    expect(await fallbackOf('skipper_full_name'), isNull,
        reason: 'nešifrovaná kópia nemá prečo ostať');
    expect(ResilientKeyValueStore.usedFallback, isFalse);
  });

  /// Toto je tá pasca: šifrovaná kópia ostala z čias, keď keystore fungoval,
  /// a novšia hodnota leží v zálohe. Čítanie musí vrátiť tú novšiu, inak sa
  /// zmeny urobené na rozbitom telefóne po reštarte ticho vrátia späť.
  test('záloha je novšia než šifrovaná kópia a vyhráva', () async {
    final box = <String, String>{};
    await working(box).write('skipper_license_number', 'staré číslo');

    // Keystore vypadol, skiper zapísal nové číslo — ide do zálohy.
    await ResilientKeyValueStore(
      secureRead: (k) async => box[k],
      secureWrite: (_, __) async => throw Exception('keystore'),
    ).write('skipper_license_number', 'nové číslo');

    final readWithBrokenWrite = await ResilientKeyValueStore(
      secureRead: (k) async => box[k],
      secureWrite: (_, __) async => throw Exception('keystore'),
    ).read('skipper_license_number');

    expect(readWithBrokenWrite, 'nové číslo');
    expect(box['skipper_license_number'], 'staré číslo',
        reason: 'zápis do šifrovaného úložiska stále zlyháva');
  });

  /// Keystore sa vie aj spamätať (reinštalácia, aktualizácia systému). Vtedy
  /// sa hodnota zo zálohy vráti späť do šifrovaného úložiska a záloha zmizne.
  test('po oprave keystoru sa hodnota uzdraví a záloha sa zmaže', () async {
    final box = <String, String>{};
    await broken().write('skipper_id_number', 'AB1234567');
    expect(await fallbackOf('skipper_id_number'), 'AB1234567');

    final healed = await working(box).read('skipper_id_number');

    expect(healed, 'AB1234567');
    expect(box['skipper_id_number'], 'AB1234567',
        reason: 'hodnota sa mala vrátiť do šifrovaného úložiska');
    expect(await fallbackOf('skipper_id_number'), isNull);
  });

  test('nezapísaný kľúč vracia null, nie výnimku', () async {
    expect(await broken().read('nikdy_nezapisane'), isNull);
  });
}
