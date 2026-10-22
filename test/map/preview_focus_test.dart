import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/map/services/preview_focus.dart';

void main() {
  test('centres once per preview, as soon as its points are there', () {
    final t = PreviewFocusTracker();

    // The preview is set first and the points load a moment later.
    expect(t.shouldFocus('c1', hasPoints: false), isFalse);
    expect(t.shouldFocus('c1', hasPoints: true), isTrue);
    // Every following rebuild leaves the camera to the person.
    expect(t.shouldFocus('c1', hasPoints: true), isFalse);
    expect(t.shouldFocus('c1', hasPoints: true), isFalse);
  });

  test('another voyage or day is centred again', () {
    final t = PreviewFocusTracker();
    expect(t.shouldFocus('c1', hasPoints: true), isTrue);
    expect(t.shouldFocus('d7', hasPoints: true), isTrue);
    expect(t.shouldFocus('c1', hasPoints: true), isTrue);
  });

  test('leaving the preview forgets it, so the same one centres again', () {
    final t = PreviewFocusTracker();
    expect(t.shouldFocus('c1', hasPoints: true), isTrue);
    expect(t.shouldFocus(null, hasPoints: false), isFalse);
    expect(t.shouldFocus('c1', hasPoints: true), isTrue);
  });

  test('no preview never centres', () {
    final t = PreviewFocusTracker();
    expect(t.shouldFocus(null, hasPoints: true), isFalse);
  });
}
