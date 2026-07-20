import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/logbook_event_type.dart';
import 'package:hmb_sailing_log/features/duty/domain/crew_member.dart';
import 'package:hmb_sailing_log/features/duty/providers/duty_provider.dart';
import 'package:hmb_sailing_log/main.dart' show databaseProvider;

/// Every way of recording a duty must also leave a logbook entry.
///
/// Found on the boat: duties added through the roster screen produced no
/// logbook entry at all, so they reached the PDF only as a band and never as
/// an entry. Nothing here covered addRetrospective, and the failure was hidden
/// by a silent catch.
void main() {
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

  Future<int> makeCharter() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 7, 19),
      dateTo: DateTime(2026, 7, 20),
      createdAt: DateTime(2026, 7, 19),
    ));
    await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 7, 19),
    ));
    return c.id;
  }

  Future<List<LogbookEntry>> entries() =>
      db.select(db.logbookEntries).get();

  test('starting a duty writes a logbook entry stamped at the start time',
      () async {
    final charter = await makeCharter();
    final at = DateTime.utc(2026, 7, 19, 9);

    await container.read(dutyControllerProvider).startDuties(
      charterId: charter,
      members: const [CrewMember(name: 'Ján')],
      at: at,
    );

    final e = (await entries()).single;
    expect(e.eventType, LogbookEventType.dutyStart.code);
    expect(e.skipperNote, contains('Ján'));
    expect(e.timestamp.toUtc(), at);
  });

  test('a duty filled in afterwards writes both entries at the duty times',
      () async {
    // The case that failed on the boat.
    final charter = await makeCharter();
    final from = DateTime.utc(2026, 7, 19, 15, 58);
    final to = DateTime.utc(2026, 7, 19, 19, 30);

    await container.read(dutyControllerProvider).addRetrospective(
          charterId: charter,
          member: const CrewMember(name: 'Peter'),
          fromUtc: from,
          toUtc: to,
        );

    final all = await entries();
    expect(all, hasLength(2), reason: 'a start and an end entry');

    final start =
        all.firstWhere((e) => e.eventType == LogbookEventType.dutyStart.code);
    final end =
        all.firstWhere((e) => e.eventType == LogbookEventType.dutyEnd.code);

    // Stamped with the duty's own times, not "now" — otherwise a duty filled
    // in later lands at the wrong point of the day's timeline.
    expect(start.timestamp.toUtc(), from);
    expect(end.timestamp.toUtc(), to);
  });

  test('a retrospective duty left running writes only the start entry',
      () async {
    final charter = await makeCharter();

    await container.read(dutyControllerProvider).addRetrospective(
          charterId: charter,
          member: const CrewMember(name: 'Peter'),
          fromUtc: DateTime.utc(2026, 7, 19, 15, 58),
        );

    final all = await entries();
    expect(all, hasLength(1));
    expect(all.single.eventType, LogbookEventType.dutyStart.code);
  });

  test('ending a duty writes an entry stamped at the end time', () async {
    final charter = await makeCharter();
    await container.read(dutyControllerProvider).startDuties(
      charterId: charter,
      members: const [CrewMember(name: 'Ján')],
      at: DateTime.utc(2026, 7, 19, 9),
    );
    final duty = (await db.getRunningDuties(charter)).single;
    final endAt = DateTime.utc(2026, 7, 19, 13);

    await container.read(dutyControllerProvider).endDuty(duty, at: endAt);

    final end = (await entries())
        .firstWhere((e) => e.eventType == LogbookEventType.dutyEnd.code);
    expect(end.timestamp.toUtc(), endAt);
  });

  test('two people starting together each get their own entry', () async {
    final charter = await makeCharter();

    await container.read(dutyControllerProvider).startDuties(
      charterId: charter,
      members: const [CrewMember(name: 'Ján'), CrewMember(name: 'Peter')],
      at: DateTime.utc(2026, 7, 19, 9),
    );

    final all = await entries();
    expect(all, hasLength(2));
    expect(all.map((e) => e.skipperNote).join(), allOf(contains('Ján'), contains('Peter')));
  });
}
