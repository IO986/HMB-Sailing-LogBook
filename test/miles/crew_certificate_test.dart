import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/crew_member_ref.dart';
import 'package:hmb_sailing_log/features/miles/services/voyage_miles_summary.dart';

/// The crew certificate is a document somebody hands to a sailing school or a
/// charter company, so the numbers on it have to come from the track, not from
/// a guess: days at sea, miles split into day and night, and the hours that go
/// with the night miles.
void main() {
  /// A leg of [count] points a minute apart, each 0.01 degrees further north.
  List<TrackPoint> leg({
    required DateTime startUtc,
    required int count,
    double startLat = 43.5,
    double lon = 16.4,
  }) =>
      [
        for (var i = 0; i < count; i++)
          TrackPoint(
            id: i,
            timestamp: startUtc.add(Duration(minutes: i)),
            latitude: startLat + i * 0.01,
            longitude: lon,
          ),
      ];

  DayLog day(int id, DateTime date, {double nm = 0}) => DayLog(
        id: id,
        charterId: 1,
        date: date,
        distanceNm: nm,
        isComplete: true,
      );

  group('day and night split', () {
    test('a midday leg is all day miles', () {
      // 10:00-10:10 UTC in July off Split: the sun is well up.
      final summary = summariseVoyage(
        days: [day(1, DateTime(2026, 7, 15))],
        points: leg(startUtc: DateTime.utc(2026, 7, 15, 10), count: 11),
      );

      expect(summary.nightNm, 0);
      expect(summary.dayNm, closeTo(6.0, 0.2));
      expect(summary.nightHours, 0);
    });

    test('a leg after midnight is all night miles, with the hours', () {
      final summary = summariseVoyage(
        days: [day(1, DateTime(2026, 7, 15))],
        points: leg(startUtc: DateTime.utc(2026, 7, 15, 1), count: 61),
      );

      expect(summary.dayNm, 0);
      expect(summary.nightNm, greaterThan(30));
      expect(summary.nightHours, closeTo(1.0, 0.05));
    });

    test('total is day plus night', () {
      final summary = summariseVoyage(
        days: [day(1, DateTime(2026, 7, 15))],
        points: [
          ...leg(startUtc: DateTime.utc(2026, 7, 15, 1), count: 11),
          ...leg(
              startUtc: DateTime.utc(2026, 7, 15, 10),
              count: 11,
              startLat: 44.0),
        ],
      );

      expect(summary.dayNm, greaterThan(0));
      expect(summary.nightNm, greaterThan(0));
      expect(summary.totalNm, closeTo(summary.dayNm + summary.nightNm, 0.001));
    });

    test('a gap longer than half an hour is not sailed distance', () {
      // The app was off, or the boat was on the hard - either way we do not
      // know what happened, so the jump must not become miles.
      final summary = summariseVoyage(
        days: [day(1, DateTime(2026, 7, 15))],
        points: [
          ...leg(startUtc: DateTime.utc(2026, 7, 15, 10), count: 3),
          ...leg(
              startUtc: DateTime.utc(2026, 7, 15, 14),
              count: 3,
              startLat: 45.0),
        ],
      );

      expect(summary.totalNm, closeTo(2.4, 0.2), reason: 'two short legs only');
    });

    test('a voyage without a track falls back to the day log distance', () {
      // Imported or hand-written voyages have no points; the miles still count,
      // and claiming night miles we cannot see would be worse than none.
      final summary = summariseVoyage(
        days: [
          day(1, DateTime(2026, 7, 15), nm: 22.5),
          day(2, DateTime(2026, 7, 16), nm: 17.5),
        ],
        points: const [],
      );

      expect(summary.totalNm, 40);
      expect(summary.nightNm, 0);
      expect(summary.daysAtSea, 2);
    });

    test('days at sea counts logged days, not the calendar span', () {
      final summary = summariseVoyage(
        days: [
          day(1, DateTime(2026, 7, 15)),
          day(2, DateTime(2026, 7, 18)),
        ],
        points: const [],
      );

      expect(summary.daysAtSea, 2);
      expect(summary.dateFrom, DateTime(2026, 7, 15));
      expect(summary.dateTo, DateTime(2026, 7, 18));
    });
  });

  group('crew from the voyage card', () {
    test('reads name, role and licences from crewJson', () {
      final crew = CrewMemberRef.parse(
          '[{"name":"Jan Novak","role":"skipper","boatLicence":"RYA Day Skipper"},'
          '{"name":"Eva Mala","role":"crew","radioLicence":"SRC"}]');

      expect(crew, hasLength(2));
      expect(crew.first.isSkipper, isTrue);
      expect(crew.first.boatLicence, 'RYA Day Skipper');
      expect(crew.last.role, 'crew');
      expect(crew.last.radioLicence, 'SRC');
    });

    test('falls back to the old skipperName + crewNames pair', () {
      final crew = CrewMemberRef.parse(null,
          skipperName: 'Jan Novak', crewNames: 'Eva|Peter|');

      expect(crew.map((c) => c.name), ['Jan Novak', 'Eva', 'Peter']);
      expect(crew.first.isSkipper, isTrue);
      expect(crew.skip(1).every((c) => !c.isSkipper), isTrue);
    });

    test('broken JSON does not take the screen down', () {
      expect(CrewMemberRef.parse('{not json', skipperName: 'Jan'),
          hasLength(1));
      expect(CrewMemberRef.parse('[]'), isEmpty);
    });
  });

  group('assessments', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    });
    tearDown(() async => db.close());

    Future<int> makeCharter() async {
      final c = await db.insertCharter(ChartersCompanion.insert(
        title: 'Plavba',
        dateFrom: DateTime(2026, 7, 15),
        dateTo: DateTime(2026, 7, 22),
        createdAt: DateTime(2026, 7, 15),
      ));
      return c.id;
    }

    CrewAssessmentsCompanion entry(int charterId, String name,
            {int? helming, String? note}) =>
        CrewAssessmentsCompanion.insert(
          charterId: charterId,
          crewName: name,
          helming: Value(helming),
          note: Value(note),
          updatedAt: DateTime.utc(2026, 7, 22),
        );

    test('an assessment is stored once per crew member and updated in place',
        () async {
      final charterId = await makeCharter();
      await db.upsertCrewAssessment(entry(charterId, 'Eva', helming: 3));
      await db.upsertCrewAssessment(
          entry(charterId, 'Eva', helming: 5, note: 'Zlepsila sa'));

      final all = await db.getCrewAssessments(charterId);
      expect(all, hasLength(1), reason: 'no duplicate row per crew member');
      expect(all.single.helming, 5);
      expect(all.single.note, 'Zlepsila sa');
    });

    test('skills left alone stay null - not rated is not zero', () async {
      final charterId = await makeCharter();
      await db.upsertCrewAssessment(entry(charterId, 'Peter', helming: 4));

      final stored = await db.getCrewAssessment(charterId, 'Peter');
      expect(stored!.helming, 4);
      expect(stored.navigation, null);
      expect(stored.teamwork, null);
    });

    test('two crew members of the same voyage do not collide', () async {
      final charterId = await makeCharter();
      await db.upsertCrewAssessment(entry(charterId, 'Eva', helming: 5));
      await db.upsertCrewAssessment(entry(charterId, 'Peter', helming: 2));

      expect(await db.getCrewAssessments(charterId), hasLength(2));
      expect((await db.getCrewAssessment(charterId, 'Eva'))!.helming, 5);
      expect((await db.getCrewAssessment(charterId, 'Peter'))!.helming, 2);
    });

    test('deleting the voyage takes its assessments with it', () async {
      // Without the cleanup the foreign key would block the delete.
      final charterId = await makeCharter();
      await db.upsertCrewAssessment(entry(charterId, 'Eva', helming: 5));

      await db.deleteCharter(charterId);

      expect(await db.getCrewAssessments(charterId), isEmpty);
    });
  });
}
