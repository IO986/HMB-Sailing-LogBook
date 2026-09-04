import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/safety/presentation/screens/safety_screen.dart';

/// Nahlásené z lode: po aktivácii MOB stopky „sekali" — čas sa počítal až pri
/// prekreslení karty, a tá sa prekresľovala len keď dorazil nový GPS fix.
/// Bez signálu teda stáli úplne, s ním skákali o niekoľko sekúnd.
class _FixedMob extends MobNotifier {
  _FixedMob(this._initial);
  final MobState _initial;

  @override
  MobState build() => _initial;
}

void main() {
  group('formatMobElapsed', () {
    test('do hodiny mm:ss', () {
      expect(formatMobElapsed(Duration.zero), '00:00');
      expect(formatMobElapsed(const Duration(seconds: 7)), '00:07');
      expect(formatMobElapsed(const Duration(minutes: 12, seconds: 5)), '12:05');
      expect(formatMobElapsed(const Duration(minutes: 59, seconds: 59)), '59:59');
    });

    /// Hľadanie človeka vo vode môže trvať aj cez hodinu; „87:13" sa v takej
    /// chvíli číta zle.
    test('nad hodinu h:mm:ss', () {
      expect(formatMobElapsed(const Duration(hours: 1, minutes: 27, seconds: 13)),
          '1:27:13');
      expect(formatMobElapsed(const Duration(hours: 2)), '2:00:00');
    });
  });

  group('MobState.copyWith', () {
    test('vzdialenosť a smer prežijú zmenu, o ktorú nikto nežiadal', () {
      const state = MobState(
        isActive: true,
        mobLat: 43.5,
        mobLon: 16.4,
        distanceM: 120,
        bearingDeg: 275,
      );

      final same = state.copyWith(isActive: true);

      expect(same.distanceM, 120);
      expect(same.bearingDeg, 275);
    });

    test('nový fix ich prepíše', () {
      const state = MobState(distanceM: 120, bearingDeg: 275);
      final moved = state.copyWith(distanceM: 95, bearingDeg: 280);
      expect(moved.distanceM, 95);
      expect(moved.bearingDeg, 280);
    });
  });

  group('mobElapsedProvider', () {
    test('bez aktívneho MOB stojí na nule', () async {
      final container = ProviderContainer(overrides: [
        mobProvider.overrideWith(() => _FixedMob(const MobState())),
      ]);
      addTearDown(container.dispose);

      expect(await container.read(mobElapsedProvider.future), Duration.zero);
    });

    test('pri aktívnom MOB tiká sám, bez ohľadu na GPS', () async {
      final activatedAt = DateTime.now().subtract(const Duration(minutes: 3));
      final container = ProviderContainer(overrides: [
        mobProvider.overrideWith(() => _FixedMob(
              MobState(isActive: true, mobLat: 43.5, mobLon: 16.4,
                  activatedAt: activatedAt),
            )),
      ]);
      addTearDown(container.dispose);

      final seen = <Duration>[];
      final sub = container.listen(
        mobElapsedProvider,
        (_, next) {
          final value = next.valueOrNull;
          if (value != null) seen.add(value);
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);

      // Prvá hodnota príde hneď, ďalšia po sekunde — nič z toho nečaká na fix.
      await Future<void>.delayed(const Duration(milliseconds: 1300));

      expect(seen.length, greaterThanOrEqualTo(2),
          reason: 'stopky musia tikať samy');
      expect(seen.first.inMinutes, 3);
      expect(seen.last, greaterThan(seen.first));
    });
  });
}
