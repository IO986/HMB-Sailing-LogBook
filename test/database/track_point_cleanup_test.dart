import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';

/// Body trasy nemajú cudzí kľúč na session, takže zmazanie dňa ich so sebou
/// nestrhlo. Záloha z októbrovej plavby mala 25 759 takých bodov — viac ako
/// polovicu celej tabuľky.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await db.getAllWaypoints();
  });
  tearDown(() async => db.close());

  final noon = DateTime.utc(2026, 8, 19, 12);

  Future<int> addDay() async {
    final charter = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: noon,
      dateTo: noon,
      createdAt: noon,
    ));
    final day = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: charter.id, date: noon));
    return day.id;
  }

  Future<void> addSession(String sessionId, int? dayLogId) =>
      db.upsertSession(SailingSessionsCompanion.insert(
        sessionId: sessionId,
        startTime: noon,
        dayLogId: Value(dayLogId),
        isActive: const Value(false),
      ));

  Future<void> addPoint(String? sessionId, DateTime at) =>
      db.insertTrackPoint(TrackPointsCompanion.insert(
        sessionId: Value(sessionId),
        timestamp: at,
        latitude: 43.5,
        longitude: 16.2,
      ));

  Future<int> pointCount() async =>
      (await db.select(db.trackPoints).get()).length;

  test('zmazanie dňa zmaže aj body jeho plavieb, cudzie nechá', () async {
    final day = await addDay();
    final other = await addDay();
    await addSession('a', day);
    await addSession('b', other);
    await addPoint('a', noon);
    await addPoint('a', noon.add(const Duration(seconds: 10)));
    await addPoint('b', noon);

    await db.deleteDayLog(day);

    final left = await db.select(db.trackPoints).get();
    expect(left.map((p) => p.sessionId), ['b']);
  });

  test('upratovanie zmaže staré siroty, čerstvé a živé nechá', () async {
    final old = DateTime.now().toUtc().subtract(const Duration(days: 30));
    final fresh = DateTime.now().toUtc();
    await addSession('live', await addDay());
    await addPoint('live', old);
    await addPoint('gone', old);
    await addPoint(null, old);
    // Bod z druhého telefónu, ktorého session ešte nedorazila.
    await addPoint('pending', fresh);

    final deleted = await db.deleteOrphanTrackPoints();

    expect(deleted, 2);
    expect(await pointCount(), 2);
  });
}
