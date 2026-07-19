import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/logbook_event_type.dart';

void main() {
  group('LogbookEventType.resolve', () {
    test('prefers the stored column over the note', () {
      // A v21+ row: the note may say anything, the column decides.
      expect(
        LogbookEventType.resolve('anchor_dropped', 'Kotva spustená'),
        LogbookEventType.anchorDropped,
      );
    });

    test('falls back to the note for rows written before v21', () {
      expect(
        LogbookEventType.resolve(null, 'Anchor dropped'),
        LogbookEventType.anchorDropped,
      );
      expect(
        LogbookEventType.resolve(null, 'Drift - perimeter exceeded'),
        LogbookEventType.driftOut,
      );
      expect(
        LogbookEventType.resolve(null, 'Man overboard'),
        LogbookEventType.mob,
      );
    });

    test('recognises every voyage-start spelling ever written to the DB', () {
      // Including the raw l10n key that leaked into production data — the very
      // bug the eventType column exists to end.
      for (final note in [
        'Voyage start',
        'Začiatok plavby',
        'Start voyage',
        'voyageStart',
      ]) {
        expect(LogbookEventType.resolve(null, note), LogbookEventType.voyageStart,
            reason: 'legacy note "$note" must still be recognised');
      }
    });

    test('an ordinary manual entry resolves to no event', () {
      expect(LogbookEventType.resolve(null, 'Pekné počasie, delfíny'), isNull);
      expect(LogbookEventType.resolve(null, null), isNull);
      expect(LogbookEventType.resolve('', ''), isNull);
    });

    test('an unknown code does not fall back to guessing from the note', () {
      // A code written by a newer version must not be silently reinterpreted.
      expect(LogbookEventType.fromCode('something_new'), isNull);
    });

    test('codes are stable — changing one orphans existing rows', () {
      expect(LogbookEventType.dutyStart.code, 'duty_start');
      expect(LogbookEventType.dutyEnd.code, 'duty_end');
      expect(LogbookEventType.anchorDropped.code, 'anchor_dropped');
      expect(LogbookEventType.anchorRaised.code, 'anchor_raised');
      expect(LogbookEventType.driftOut.code, 'drift_out');
      expect(LogbookEventType.driftIn.code, 'drift_in');
      expect(LogbookEventType.mob.code, 'mob');
      expect(LogbookEventType.voyageStart.code, 'voyage_start');
      expect(LogbookEventType.voyageEnd.code, 'voyage_end');
    });

    test('grouping helpers', () {
      expect(LogbookEventType.driftIn.isAnchorEvent, isTrue);
      expect(LogbookEventType.dutyStart.isAnchorEvent, isFalse);
      expect(LogbookEventType.dutyEnd.isDutyEvent, isTrue);
      expect(LogbookEventType.mob.isDutyEvent, isFalse);
    });
  });
}
