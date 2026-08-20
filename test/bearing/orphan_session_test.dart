import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/bearing/providers/bearing_provider.dart';
import 'package:hmb_sailing_log/main.dart' show databaseProvider;

/// Zamerania zapísané bez aktívneho trackingu (dayLogId aj charterId sú
/// null) musia byť dohľadateľné inak než len na mape — zoskupené po dňoch
/// pre samostatný riadok v zozname plavieb.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> addOrphan({
    required DateTime takenAt,
    int? dayLogId,
    int? charterId,
  }) =>
      db.insertBearing(BearingsCompanion.insert(
        kind: BearingKind.intersection.code,
        magneticBearing: 90,
        declination: 4,
        declinationSource: const Value('gps'),
        trueBearing: 94,
        observerLat: const Value(43.5),
        observerLon: const Value(16.4),
        sightGroupId: const Value('g1'),
        label: const Value('skala'),
        takenAt: takenAt,
        dayLogId: Value(dayLogId),
        charterId: Value(charterId),
      ));

  Future<void> settle(int expected) async {
    await container.read(bearingsProvider.future);
    for (var i = 0; i < 50; i++) {
      final rows = container.read(bearingsProvider).valueOrNull;
      if (rows != null && rows.length == expected) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('stream nedal $expected zameraní');
  }

  test('zameranie priradené k plavbe do relácie nespadne', () async {
    final charter = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 8, 20),
      dateTo: DateTime(2026, 8, 20),
      createdAt: DateTime(2026, 8, 20),
    ));
    final day = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: charter.id, date: DateTime(2026, 8, 20)));

    await addOrphan(
        takenAt: DateTime(2026, 8, 20, 10),
        dayLogId: day.id,
        charterId: charter.id);
    await settle(1);

    expect(container.read(orphanBearingSessionsProvider), isEmpty);
  });

  test('zameranie bez plavby vytvorí reláciu pre svoj deň', () async {
    await addOrphan(takenAt: DateTime(2026, 8, 20, 10));
    await settle(1);

    final sessions = container.read(orphanBearingSessionsProvider);
    expect(sessions, hasLength(1));
    expect(sessions.single.date, DateTime(2026, 8, 20));
    expect(sessions.single.bearings, hasLength(1));
  });

  test('viac zameraní z toho istého dňa padne do jednej relácie', () async {
    await addOrphan(takenAt: DateTime(2026, 8, 20, 9));
    await addOrphan(takenAt: DateTime(2026, 8, 20, 17));
    await settle(2);

    final sessions = container.read(orphanBearingSessionsProvider);
    expect(sessions, hasLength(1));
    expect(sessions.single.bearings, hasLength(2));
    // Zoradené od najstaršieho v rámci dňa.
    expect(sessions.single.bearings.first.takenAt.hour, 9);
  });

  test('rôzne dni dajú rôzne relácie, zoradené od najnovšej', () async {
    await addOrphan(takenAt: DateTime(2026, 8, 18, 10));
    await addOrphan(takenAt: DateTime(2026, 8, 20, 10));
    await settle(2);

    final sessions = container.read(orphanBearingSessionsProvider);
    expect(sessions, hasLength(2));
    expect(sessions.first.date, DateTime(2026, 8, 20));
    expect(sessions.last.date, DateTime(2026, 8, 18));
  });

  test('bearingSessionForDateProvider vráti presne ten deň', () async {
    await addOrphan(takenAt: DateTime(2026, 8, 18, 10));
    await addOrphan(takenAt: DateTime(2026, 8, 20, 10));
    await settle(2);

    final found = container
        .read(bearingSessionForDateProvider(DateTime(2026, 8, 18)));
    expect(found, isNotNull);
    expect(found!.bearings, hasLength(1));

    final missing = container
        .read(bearingSessionForDateProvider(DateTime(2026, 8, 19)));
    expect(missing, isNull);
  });

  test('po zmazaní posledného zamerania relácia zmizne', () async {
    await addOrphan(takenAt: DateTime(2026, 8, 20, 10));
    await settle(1);
    expect(container.read(orphanBearingSessionsProvider), hasLength(1));

    await db.deleteAllBearings();
    await settle(0);

    expect(container.read(orphanBearingSessionsProvider), isEmpty);
  });
}
