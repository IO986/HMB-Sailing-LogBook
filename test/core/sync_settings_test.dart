import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/sync_settings.dart';

void main() {
  group('validateSyncServerUrl', () {
    test('empty string is rejected as empty', () {
      expect(validateSyncServerUrl(''), SyncUrlError.empty);
      expect(validateSyncServerUrl('   '), SyncUrlError.empty);
    });

    test('unparsable / hostless input is rejected as invalid', () {
      expect(validateSyncServerUrl('not a url'), SyncUrlError.invalid);
      expect(validateSyncServerUrl('https://'), SyncUrlError.invalid);
    });

    test('plain HTTP is rejected as requiring HTTPS', () {
      expect(validateSyncServerUrl('http://example.com'), SyncUrlError.httpsRequired);
    });

    test('a valid HTTPS URL passes', () {
      expect(validateSyncServerUrl('https://example.com'), isNull);
      expect(validateSyncServerUrl('https://example.com/api'), isNull);
      expect(validateSyncServerUrl('  https://example.com  '), isNull);
    });
  });

  group('SyncSettings.copyWith', () {
    test('leaves unspecified fields untouched', () {
      const base = SyncSettings(
        enabled: true,
        target: SyncTarget.custom,
        customUrl: 'https://x.example',
        intervalMinutes: 30,
        attachmentPolicy: AttachmentSyncPolicy.never,
      );
      final updated = base.copyWith(enabled: false);
      expect(updated.enabled, isFalse);
      expect(updated.target, SyncTarget.custom);
      expect(updated.customUrl, 'https://x.example');
      expect(updated.intervalMinutes, 30);
      expect(updated.attachmentPolicy, AttachmentSyncPolicy.never);
    });

    test('defaults match the spec (off, HMB Academy, 15 min, Wi-Fi only)', () {
      const settings = SyncSettings();
      expect(settings.enabled, isFalse);
      expect(settings.target, SyncTarget.hmbAcademy);
      expect(settings.intervalMinutes, 15);
      expect(settings.attachmentPolicy, AttachmentSyncPolicy.wifiOnly);
    });
  });
}
