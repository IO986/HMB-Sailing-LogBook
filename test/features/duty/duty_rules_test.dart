import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/duty/domain/duty_rules.dart';

DateTime _utc(int day, int hour, [int minute = 0]) =>
    DateTime.utc(2026, 7, day, hour, minute);

DutyInterval _duty(
  String name,
  DateTime from, {
  DateTime? to,
  int? id,
}) =>
    DutyInterval(id: id, crewName: name, fromUtc: from, toUtc: to);

void main() {
  final now = _utc(10, 12);

  group('dutiesOverlap', () {
    test('touching periods do not overlap — 04:00 handover is not a clash', () {
      final a = _duty('Jano', _utc(10, 0), to: _utc(10, 4));
      final b = _duty('Jano', _utc(10, 4), to: _utc(10, 8));
      expect(dutiesOverlap(a, b, now), isFalse);
    });

    test('partially covering periods overlap', () {
      final a = _duty('Jano', _utc(10, 0), to: _utc(10, 5));
      final b = _duty('Jano', _utc(10, 4), to: _utc(10, 8));
      expect(dutiesOverlap(a, b, now), isTrue);
    });

    test('a running duty collides with anything starting after it began', () {
      final running = _duty('Jano', _utc(10, 0));
      final later = _duty('Jano', _utc(11, 6), to: _utc(11, 10));
      expect(dutiesOverlap(running, later, now), isTrue);
    });

    test('a running duty does not collide with a period that ended before it',
        () {
      final running = _duty('Jano', _utc(10, 8));
      final earlier = _duty('Jano', _utc(10, 0), to: _utc(10, 4));
      expect(dutiesOverlap(running, earlier, now), isFalse);
    });
  });

  group('validateDuty', () {
    test('end at or before start is rejected', () {
      expect(
        validateDuty(
          candidate: _duty('Jano', _utc(10, 8), to: _utc(10, 8)),
          existing: const [],
          nowUtc: now,
        ),
        DutyValidationError.endBeforeStart,
      );
    });

    test('a start in the future is rejected', () {
      expect(
        validateDuty(
          candidate: _duty('Jano', _utc(11, 8)),
          existing: const [],
          nowUtc: now,
        ),
        DutyValidationError.futureStart,
      );
    });

    test('overlap for the same person is rejected', () {
      final existing = [_duty('Jano', _utc(10, 0), to: _utc(10, 6), id: 1)];
      expect(
        validateDuty(
          candidate: _duty('Jano', _utc(10, 4), to: _utc(10, 8)),
          existing: existing,
          nowUtc: now,
        ),
        DutyValidationError.overlapSamePerson,
      );
    });

    test('two different people on duty at once is normal, not an error', () {
      final existing = [_duty('Jano', _utc(10, 0), to: _utc(10, 6), id: 1)];
      expect(
        validateDuty(
          candidate: _duty('Peter', _utc(10, 0), to: _utc(10, 6)),
          existing: existing,
          nowUtc: now,
        ),
        isNull,
      );
    });

    test('editing a period does not clash with itself', () {
      final existing = [_duty('Jano', _utc(10, 0), to: _utc(10, 6), id: 7)];
      expect(
        validateDuty(
          candidate: _duty('Jano', _utc(10, 0), to: _utc(10, 7), id: 7),
          existing: existing,
          nowUtc: now,
        ),
        isNull,
      );
    });

    test('a valid retrospective period passes', () {
      expect(
        validateDuty(
          candidate: _duty('Jano', _utc(10, 0), to: _utc(10, 4)),
          existing: const [],
          nowUtc: now,
        ),
        isNull,
      );
    });
  });

  group('dutiesForDay / clipToDay', () {
    // Local midnight, so the day window follows the crew's clock, not UTC.
    DateTime localMidnight(int day) => DateTime(2026, 7, day);

    test('a duty across midnight appears on BOTH days', () {
      // 22:00 local on the 10th until 02:00 local on the 11th.
      final duty = _duty(
        'Jano',
        DateTime(2026, 7, 10, 22).toUtc(),
        to: DateTime(2026, 7, 11, 2).toUtc(),
      );

      expect(dutiesForDay([duty], localMidnight(10), now), hasLength(1),
          reason: 'must show on the day it started');
      expect(dutiesForDay([duty], localMidnight(11), now), hasLength(1),
          reason: 'must show on the day it ended');
    });

    test('a duty inside one day is not clipped', () {
      final duty = _duty(
        'Jano',
        DateTime(2026, 7, 10, 8).toUtc(),
        to: DateTime(2026, 7, 10, 12).toUtc(),
      );
      final clipped = clipToDay(duty, localMidnight(10), now);

      expect(clipped.clippedStart, isFalse);
      expect(clipped.clippedEnd, isFalse);
      expect(clipped.fromUtc, duty.fromUtc);
      expect(clipped.toUtc, duty.toUtc);
    });

    test('the second day of a night duty is marked as continuing from before',
        () {
      final duty = _duty(
        'Jano',
        DateTime(2026, 7, 10, 22).toUtc(),
        to: DateTime(2026, 7, 11, 2).toUtc(),
      );
      final clipped = clipToDay(duty, localMidnight(11), now);

      expect(clipped.clippedStart, isTrue);
      expect(clipped.clippedEnd, isFalse);
      expect(clipped.fromUtc, DateTime(2026, 7, 11).toUtc());
    });

    test('the first day of a night duty is marked as continuing after', () {
      final duty = _duty(
        'Jano',
        DateTime(2026, 7, 10, 22).toUtc(),
        to: DateTime(2026, 7, 11, 2).toUtc(),
      );
      final clipped = clipToDay(duty, localMidnight(10), now);

      expect(clipped.clippedStart, isFalse);
      expect(clipped.clippedEnd, isTrue);
      expect(clipped.toUtc, DateTime(2026, 7, 11).toUtc());
    });

    test('a running duty is always marked as continuing', () {
      final duty = _duty('Jano', DateTime(2026, 7, 10, 8).toUtc());
      final clipped =
          clipToDay(duty, localMidnight(10), DateTime(2026, 7, 10, 12).toUtc());

      expect(clipped.clippedEnd, isTrue);
    });

    test('a duty that ended before the day does not appear on it', () {
      final duty = _duty(
        'Jano',
        DateTime(2026, 7, 9, 8).toUtc(),
        to: DateTime(2026, 7, 9, 12).toUtc(),
      );
      expect(dutiesForDay([duty], localMidnight(10), now), isEmpty);
    });
  });

  group('elapsed / sorting', () {
    test('a running duty measures up to now', () {
      final duty = _duty('Jano', _utc(10, 8));
      expect(duty.elapsed(_utc(10, 12)), const Duration(hours: 4));
    });

    test('a closed duty measures its own span, not up to now', () {
      final duty = _duty('Jano', _utc(10, 0), to: _utc(10, 4));
      expect(duty.elapsed(_utc(10, 23)), const Duration(hours: 4));
    });

    test('elapsed handles a duty left running for more than a day', () {
      final duty = _duty('Jano', _utc(9, 8));
      expect(duty.elapsed(_utc(10, 12)), const Duration(hours: 28));
    });

    test('running duties sort first, then newest start first', () {
      final old = _duty('A', _utc(10, 0), to: _utc(10, 4));
      final newer = _duty('B', _utc(10, 6), to: _utc(10, 10));
      final running = _duty('C', _utc(10, 2));

      final sorted = sortForDisplay([old, newer, running]);
      expect(sorted.map((d) => d.crewName), ['C', 'B', 'A']);
    });

    test('runningDuties picks out only the open ones', () {
      final duties = [
        _duty('A', _utc(10, 0), to: _utc(10, 4)),
        _duty('B', _utc(10, 6)),
      ];
      expect(runningDuties(duties).map((d) => d.crewName), ['B']);
    });
  });
}
