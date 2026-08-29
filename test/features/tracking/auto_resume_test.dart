import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/tracking/presentation/widgets/tracking_control_dialogs.dart';

/// The app gets killed by the system mid-voyage — on Honor and Huawei this is
/// routine. A dialog is the wrong answer to that: nobody answers a dialog in a
/// pocket, and the log stays empty until someone notices. Reported from the
/// water: 45 minutes of sailing missing and five "voyage start" entries in one
/// day.
///
/// So the app resumes on its own, but only within a window. Past it, silence
/// no longer means "the app died mid-passage" — it means the voyage is
/// probably over, and resuming would quietly log the drive to the hotel.
void main() {
  group('shouldAutoResume', () {
    test('a hole of minutes is the app being killed, not a finished voyage',
        () {
      expect(shouldAutoResume(const Duration(minutes: 1)), isTrue);
      // The real one from 27 August.
      expect(shouldAutoResume(const Duration(minutes: 45)), isTrue);
      expect(shouldAutoResume(const Duration(hours: 2, minutes: 59)), isTrue);
    });

    test('past the window the app asks instead of assuming', () {
      expect(shouldAutoResume(const Duration(hours: 3, minutes: 1)), isFalse);
      expect(shouldAutoResume(const Duration(hours: 14)), isFalse);
    });

    test('exactly on the window still resumes', () {
      expect(shouldAutoResume(const Duration(hours: 3)), isTrue);
    });

    test('a clock jumped backwards does not resume on a negative gap', () {
      // A phone whose clock is corrected by the network mid-voyage can make
      // the last point look like it is in the future.
      expect(shouldAutoResume(const Duration(minutes: -5)), isFalse);
    });
  });
}
