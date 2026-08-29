import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';

/// The stored instant never changes — only the clock it is printed on.
void main() {
  // 2026-08-27 12:34:56 UTC, the shape drift hands back: a DateTime flagged
  // local that still points at the right instant.
  final instant = DateTime.utc(2026, 8, 27, 12, 34, 56).toLocal();

  test('UTC mode prints the UTC clock regardless of the device zone', () {
    const u = UnitsSettings(timeZone: TimeZoneMode.utc);
    expect(u.formatTime(instant), '12:34');
    expect(u.formatTime(instant, seconds: true), '12:34:56');
    expect(u.zoneLabel(instant), 'UTC');
    expect(u.formatTimeWithZone(instant), '12:34 UTC');
  });

  test('local mode prints the device clock and names its offset', () {
    const u = UnitsSettings();
    expect(u.timeZone, TimeZoneMode.local, reason: 'local is the default');
    expect(u.formatTime(instant), DateFormat('HH:mm').format(instant.toLocal()));
    expect(u.zoneLabel(instant), 'LT (${u.offsetLabel(instant)})');
  });

  test('the offset is written the way a reader expects', () {
    const u = UnitsSettings();
    expect(u.offsetLabel(instant), matches(r'^UTC[+-]\d{1,2}(:\d{2})?$'));
  });

  test('the offset belongs to the instant, not to today', () {
    const u = UnitsSettings();
    final january = DateTime.utc(2026, 1, 15, 12).toLocal();
    final july = DateTime.utc(2026, 7, 15, 12).toLocal();
    // In a zone without DST the two labels match; where summer time exists
    // they must differ, because each is read off its own timestamp.
    expect(u.offsetLabel(january), 'UTC${_sign(january)}${_hours(january)}');
    expect(u.offsetLabel(july), 'UTC${_sign(july)}${_hours(july)}');
  });
}

String _sign(DateTime t) => t.timeZoneOffset.isNegative ? '-' : '+';
String _hours(DateTime t) {
  final off = t.timeZoneOffset;
  final h = off.inHours.abs();
  final m = off.inMinutes.abs() % 60;
  return m == 0 ? '$h' : '$h:${m.toString().padLeft(2, '0')}';
}
