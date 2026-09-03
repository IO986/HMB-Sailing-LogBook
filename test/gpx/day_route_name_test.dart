import 'dart:convert';

import 'package:intl/date_symbol_data_local.dart';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/utils/gpx_exporter.dart';

/// A track named "? → ?" is useless in any chart plotter the skipper opens the
/// file in — and empty ports are the normal outcome of a day spent on the
/// instruments' WiFi, which carries no internet for the geocoder. The position
/// is always known, so that is what the name falls back to.
void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('sk'));

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<DayLog> makeDay({String? from, String? to}) async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 8, 31),
      dateTo: DateTime(2026, 8, 31),
      createdAt: DateTime(2026, 8, 31),
    ));
    return db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 8, 31),
      portFrom: Value(from),
      portTo: Value(to),
    ));
  }

  Future<SailingSession> makeSession(int dayLogId) async {
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 'leg-1',
      startTime: DateTime.utc(2026, 8, 31, 6),
      dayLogId: Value(dayLogId),
    ));
    return (await db.getSessionsForDay(dayLogId)).first;
  }

  final points = [
    TrackPoint(
        id: 1,
        sessionId: 'leg-1',
        timestamp: DateTime.utc(2026, 8, 31, 7),
        latitude: 43.0445,
        longitude: 16.0868),
    TrackPoint(
        id: 2,
        sessionId: 'leg-1',
        timestamp: DateTime.utc(2026, 8, 31, 13),
        latitude: 43.1607,
        longitude: 16.3611),
  ];

  test('missing ports become positions, not question marks', () async {
    final day = await makeDay();
    final session = await makeSession(day.id);
    final gpx = utf8.decode(await GpxExporter.buildDayGpxBytes(
        day, [session], {'leg-1': points}));

    expect(gpx, contains('43.0445'));
    expect(gpx, contains('16.3611'));
    expect(gpx, isNot(contains('? →')));
  });

  test('a known port still wins over its position', () async {
    final day = await makeDay(from: 'Komiža');
    final session = await makeSession(day.id);
    final gpx = utf8.decode(await GpxExporter.buildDayGpxBytes(
        day, [session], {'leg-1': points}));

    expect(gpx, contains('Komiža'));
    expect(gpx, contains('16.3611'));
  });
}
