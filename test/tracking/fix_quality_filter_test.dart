import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/utils/fix_quality_filter.dart';
import 'package:latlong2/latlong.dart';

/// Z plavby 23.–27. 8. 2026: do trasy sa zapisovalo všetko, čo platforma
/// poslala. Fix z bunky (presnosť 500–700 m) spravil v denníku skok o kilometer
/// a späť, a striedanie polohy z NMEA s primrznutou polohou telefónu nafúklo
/// prejdené míle na trojnásobok. Tento test drží obe pravidlá.
void main() {
  const start = LatLng(43.6, 15.9);

  /// Bod posunutý na sever o [meters].
  LatLng north(double meters) =>
      LatLng(start.latitude + meters / 111320.0, start.longitude);

  late DateTime now;
  setUp(() => now = DateTime.utc(2026, 8, 24, 10));

  test('prvý fix sa vždy prijme, ale bez vzdialenosti', () {
    final f = FixQualityFilter();
    final r = f.check(start, accuracyM: 3, at: now);
    expect(r.verdict, FixVerdict.resynced);
    expect(r.distanceM, 0);
  });

  test('nepresný fix sa zahodí a trasu neposunie', () {
    final f = FixQualityFilter()
      ..check(start, accuracyM: 3, at: now);

    final r = f.check(north(900), accuracyM: 700,
        at: now.add(const Duration(seconds: 5)));

    expect(r.verdict, FixVerdict.rejectedAccuracy);
    expect(r.distanceM, 0);
    expect(f.lastAccepted, start, reason: 'zahodený fix nesmie prepísať bod');
  });

  test('teleport tam a späť sa nezapočíta ani raz', () {
    final f = FixQualityFilter()..check(start, accuracyM: 3, at: now);

    // 1,8 km za 11 s = 319 kn — presne skok z 27. 8. o 15:39.
    final out = f.check(north(1800), accuracyM: 0,
        at: now.add(const Duration(seconds: 11)));
    expect(out.verdict, FixVerdict.rejectedJump);

    final back = f.check(north(5), accuracyM: 0,
        at: now.add(const Duration(seconds: 22)));
    expect(back.verdict, FixVerdict.accepted);
    expect(back.distanceM, closeTo(5, 1));
  });

  test('šum na kotve sa do vzdialenosti nerátá', () {
    final f = FixQualityFilter()..check(start, accuracyM: 3, at: now);
    var total = 0.0;
    for (var i = 1; i <= 100; i++) {
      final r = f.check(north(i.isEven ? 2 : 0), accuracyM: 3,
          at: now.add(Duration(seconds: 5 * i)));
      total += r.distanceM;
    }
    expect(total, 0);
  });

  test('normálna plavba sa počíta celá', () {
    final f = FixQualityFilter()..check(start, accuracyM: 3, at: now);
    var total = 0.0;
    for (var i = 1; i <= 10; i++) {
      final r = f.check(north(15.0 * i), accuracyM: 3,
          at: now.add(Duration(seconds: 5 * i)));
      expect(r.verdict, FixVerdict.accepted);
      total += r.distanceM;
    }
    expect(total, closeTo(150, 2));
  });

  test('po dlhej diere sa nadviaže, ale vzdialenosť sa nedopočítava', () {
    final f = FixQualityFilter()..check(start, accuracyM: 3, at: now);

    final r = f.check(north(5000), accuracyM: 3,
        at: now.add(const Duration(minutes: 30)));

    expect(r.verdict, FixVerdict.resynced);
    expect(r.distanceM, 0);
    expect(f.lastAccepted, north(5000));
  });

  test('pomalá plavba pod minMoveM sa kumuluje, nie zaokrúhľuje na 0', () {
    // Z terénu 1.9.2026: 18,8 NM skutočne, appka narátala 4,2 NM. Pri hustom
    // 1 Hz NMEA feede a rýchlosti pod ~6 uzlami je krok medzi dvoma fixmi
    // pod 3 m (minMoveM) — bez kumulácie voči poslednému NARÁTANÉMU bodu by
    // sa každý krok zaokrúhlil na 0 a reálny posun by sa nikdy nespočítal.
    final f = FixQualityFilter()..check(start, accuracyM: 3, at: now);
    var total = 0.0;
    // 2 m/s (~3,9 kn) po 1 s, 60 krokov = 120 m skutočne prejdených.
    for (var i = 1; i <= 60; i++) {
      final r = f.check(north(2.0 * i), accuracyM: 3,
          at: now.add(Duration(seconds: i)));
      expect(r.verdict, FixVerdict.accepted);
      total += r.distanceM;
    }
    expect(total, closeTo(120, 2));
  });

  test('keď presnejšie fixy neprichádzajú, filter sa nezasekne', () {
    final f = FixQualityFilter(maxConsecutiveRejects: 3)
      ..check(start, accuracyM: 3, at: now);

    late FixCheck last;
    for (var i = 1; i <= 4; i++) {
      last = f.check(north(300.0 * i), accuracyM: 400,
          at: now.add(Duration(seconds: 5 * i)));
    }
    expect(last.verdict, FixVerdict.resynced,
        reason: 'inak by tracking od tej chvíle nezapísal už nič');
  });
}
