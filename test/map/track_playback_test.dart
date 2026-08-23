import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/map/services/track_playback.dart';

final _t0 = DateTime.utc(2026, 8, 23, 10);

TrackPoint _p(int minutes, double lat, double lon,
        {double? speed, double? course}) =>
    TrackPoint(
      id: minutes,
      sessionId: const Value('s1').value,
      timestamp: _t0.add(Duration(minutes: minutes)),
      latitude: lat,
      longitude: lon,
      altitude: null,
      speed: speed,
      course: course,
      accuracy: null,
    );

void main() {
  group('empty track', () {
    test('has no fix and no duration', () {
      final p = TrackPlayback(const []);
      expect(p.isEmpty, isTrue);
      expect(p.fixAt(_t0), isNull);
      expect(p.start, isNull);
      expect(p.duration, Duration.zero);
      expect(p.passedIndex(_t0), -1);
    });
  });

  group('outside the recorded range', () {
    final p = TrackPlayback([
      _p(0, 43.50, 16.40, speed: 5, course: 90),
      _p(10, 43.51, 16.42, speed: 6, course: 95),
    ]);

    test('before the first point clamps to the first', () {
      // Posuvník môže ísť po celom dni, aj keď trasa pokrýva len jeho časť —
      // značka nesmie zmiznúť.
      final f = p.fixAt(_t0.subtract(const Duration(hours: 2)))!;
      expect(f.position.latitude, 43.50);
      expect(f.interpolated, isFalse);
    });

    test('after the last point clamps to the last', () {
      final f = p.fixAt(_t0.add(const Duration(hours: 5)))!;
      expect(f.position.latitude, 43.51);
      expect(f.interpolated, isFalse);
    });

    test('passedIndex marks nothing before the start, all at the end', () {
      expect(p.passedIndex(_t0.subtract(const Duration(minutes: 1))), -1);
      expect(p.passedIndex(_t0.add(const Duration(hours: 1))), 1);
    });
  });

  group('between two points', () {
    final p = TrackPlayback([
      _p(0, 43.00, 16.00, speed: 5, course: 90),
      _p(10, 43.10, 16.20, speed: 7, course: 100),
    ]);

    test('interpolates the position halfway', () {
      final f = p.fixAt(_t0.add(const Duration(minutes: 5)))!;
      expect(f.interpolated, isTrue);
      expect(f.position.latitude, closeTo(43.05, 1e-9));
      expect(f.position.longitude, closeTo(16.10, 1e-9));
    });

    test('speed and course come from the earlier fix, not averaged', () {
      // Kurz sa cez sever priemeruje na opačnú stranu, a rýchlosť je hodnota
      // odčítaná v okamihu, nie spojitá veličina.
      final f = p.fixAt(_t0.add(const Duration(minutes: 5)))!;
      expect(f.sog, 5);
      expect(f.cog, 90);
    });

    test('lands exactly on a recorded point without interpolating', () {
      final f = p.fixAt(_t0)!;
      expect(f.interpolated, isFalse);
      expect(f.sog, 5);
    });
  });

  group('gap in the recording', () {
    // Tracking vypadol na hodinu — systém zabil appku, alebo skiper vypol
    // plavbu a o hodinu ju zapol inde.
    final p = TrackPlayback([
      _p(0, 43.00, 16.00, speed: 5),
      _p(60, 43.90, 17.00, speed: 6),
    ]);

    test('does not interpolate across the hole', () {
      // Bez tejto poistky by prehrávanie ukázalo loď plávať naprieč
      // polostrovom rovnomernou rýchlosťou.
      final f = p.fixAt(_t0.add(const Duration(minutes: 30)))!;
      expect(f.interpolated, isFalse);
      expect(f.position.latitude, 43.00);
      expect(f.position.longitude, 16.00);
    });

    test('picks up again at the far side of the hole', () {
      final f = p.fixAt(_t0.add(const Duration(minutes: 60)))!;
      expect(f.position.latitude, 43.90);
    });
  });

  group('a track without speed or course (imported GPX)', () {
    // Ten z HMB Academy má 22 512 bodov a ani jeden údaj o rýchlosti či kurze
    // — len poloha, výška a čas. Bez dopočtu by prehrávanie takých plavieb
    // neukázalo žiadne hodnoty a vyzeralo by pokazene.
    //
    // 0,01° zemepisnej šírky = ~1111 m; za 60 s to je ~36 uzlov, takže
    // výsledok musí byť rádovo tam.
    final p = TrackPlayback([
      _p(0, 43.00, 16.00),
      _p(1, 43.01, 16.00),
    ]);

    test('derives speed from the distance and the time between points', () {
      final f = p.fixAt(_t0.add(const Duration(seconds: 30)))!;
      expect(f.sog, isNotNull);
      expect(f.sog!, closeTo(36, 2));
    });

    test('derives course as the bearing between points', () {
      // Presne na sever.
      final f = p.fixAt(_t0.add(const Duration(seconds: 30)))!;
      expect(f.cog, isNotNull);
      expect(f.cog!, closeTo(0, 1));
    });

    test('a recorded speed always wins over the derived one', () {
      final withSpeed = TrackPlayback([
        _p(0, 43.00, 16.00, speed: 5.5, course: 123),
        _p(1, 43.01, 16.00, speed: 5.6, course: 124),
      ]);
      final f = withSpeed.fixAt(_t0.add(const Duration(seconds: 30)))!;
      expect(f.sog, 5.5);
      expect(f.cog, 123);
    });

    test('no course from two nearly identical points', () {
      // Loď stála; bearing by z šumu vyrobil náhodný smer a to je v zázname
      // horšie než prázdna hodnota.
      final still = TrackPlayback([
        _p(0, 43.000000, 16.000000),
        _p(1, 43.000010, 16.000000),
      ]);
      expect(still.fixAt(_t0.add(const Duration(seconds: 30)))!.cog, isNull);
    });

    test('nothing is derived across a gap in the recording', () {
      final gapped = TrackPlayback([
        _p(0, 43.00, 16.00),
        _p(60, 43.90, 17.00),
      ]);
      final f = gapped.fixAt(_t0.add(const Duration(minutes: 30)))!;
      expect(f.sog, isNull);
      expect(f.cog, isNull);
    });
  });

  group('a long track', () {
    // Staršie plavby spred TrackPointThrottle majú desaťtisíce bodov na deň.
    final points = [
      for (var i = 0; i < 30000; i++)
        _p(i, 43.0 + i * 0.00001, 16.0 + i * 0.00001, speed: 6),
    ];
    final p = TrackPlayback(points);

    test('finds the right segment anywhere in the track', () {
      final f = p.fixAt(_t0.add(const Duration(minutes: 15000)))!;
      expect(f.position.latitude, closeTo(43.0 + 15000 * 0.00001, 1e-9));
    });

    test('lookups stay fast enough to scrub', () {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 2000; i++) {
        p.fixAt(_t0.add(Duration(minutes: i * 13)));
      }
      sw.stop();
      // Lineárny prechod by tu robil 60 miliónov porovnaní. Binárne
      // vyhľadávanie to zvládne rádovo v milisekundách; strop je zámerne
      // voľný, aby test nepadal na pomalom CI.
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('passedIndex grows with time', () {
      expect(p.passedIndex(_t0), 0);
      expect(p.passedIndex(_t0.add(const Duration(minutes: 100))), 100);
    });
  });
}
