import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/sync/sync_envelope.dart';

void main() {
  group('buildSyncEnvelope', () {
    test('produces exactly the documented shape', () {
      final item = OutboxItem(
        id: 'uuid-1',
        entityType: 'log_entry',
        operation: SyncOperation.update,
        payload: const {'note': 'hi'},
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final envelope = buildSyncEnvelope(
        item: item,
        appVersion: '1.21.0+42',
        attachments: const [
          {'field': 'photo', 'remoteRef': '7'},
        ],
      );

      expect(envelope.keys.toSet(), {
        'clientId',
        'entityType',
        'operation',
        'timestamp',
        'appVersion',
        'payload',
        'attachments',
      });
      expect(envelope['clientId'], 'uuid-1');
      expect(envelope['entityType'], 'log_entry');
      expect(envelope['operation'], 'update');
      expect(envelope['appVersion'], '1.21.0+42');
      expect(envelope['payload'], {'note': 'hi'});
      expect(envelope['attachments'], [
        {'field': 'photo', 'remoteRef': '7'},
      ]);
    });
  });

  group('isoWithOffset', () {
    test('appends a numeric offset, not Z, even for a UTC instant', () {
      final s = isoWithOffset(DateTime.utc(2026, 7, 14, 9, 12, 3));
      expect(s, isNot(contains('Z')));
      expect(s, matches(RegExp(r'[+-]\d{2}:\d{2}$')));
    });

    test('offset sign and magnitude match the local timezone offset', () {
      final dt = DateTime.utc(2026, 7, 14, 9, 12, 3);
      final s = isoWithOffset(dt);
      final offset = dt.toLocal().timeZoneOffset;
      final sign = offset.isNegative ? '-' : '+';
      final h = offset.abs().inHours.toString().padLeft(2, '0');
      final m = offset.abs().inMinutes.remainder(60).toString().padLeft(2, '0');
      expect(s, endsWith('$sign$h:$m'));
    });
  });
}
