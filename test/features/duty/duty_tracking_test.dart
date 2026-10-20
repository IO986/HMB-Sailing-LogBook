import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/duty/domain/crew_member.dart';
import 'package:hmb_sailing_log/features/duty/providers/duty_provider.dart';
import 'package:hmb_sailing_log/main.dart' show databaseProvider;

/// The crew is on duty for as long as tracking runs (maritime law), and
/// taking someone off duty is the manual exception.
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

  DutyController duties() => container.read(dutyControllerProvider);

  Future<int> makeCharter() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 7, 19),
      dateTo: DateTime(2026, 7, 20),
      createdAt: DateTime(2026, 7, 19),
      crewJson: const Value('[{"name":"Skipper","role":"skipper"},'
          '{"name":"Ján","role":"crew"},{"name":"Eva","role":"crew"}]'),
    ));
    await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 7, 19),
    ));
    return c.id;
  }

  test('starting tracking puts the whole crew on duty, without log entries',
      () async {
    final charter = await makeCharter();
    final at = DateTime.utc(2026, 7, 19, 8);

    await duties().startWithTracking(charter, at: at);

    final running = await db.getRunningDuties(charter);
    expect(running.map((d) => d.crewName),
        unorderedEquals(['Skipper', 'Ján', 'Eva']));
    expect(running.every((d) => d.fromUtc.toUtc() == at), isTrue);
    expect(running.firstWhere((d) => d.crewName == 'Skipper').role, 'skipper');
    // One "duty start" per person per leg buried the logbook in noise.
    expect(await db.select(db.logbookEntries).get(), isEmpty);
  });

  test('starting again leaves people already on duty alone', () async {
    final charter = await makeCharter();
    final first = DateTime.utc(2026, 7, 19, 8);
    await duties().startWithTracking(charter, at: first);

    await duties().startWithTracking(charter, at: first.add(
        const Duration(hours: 1)));

    final running = await db.getRunningDuties(charter);
    expect(running, hasLength(3));
    expect(running.every((d) => d.fromUtc.toUtc() == first), isTrue);
  });

  test('stopping tracking ends every running duty as auto-closed', () async {
    final charter = await makeCharter();
    await duties().startWithTracking(charter,
        at: DateTime.utc(2026, 7, 19, 8));
    final stop = DateTime.utc(2026, 7, 19, 17);

    await duties().endWithTracking(charter, at: stop);

    expect(await db.getRunningDuties(charter), isEmpty);
    final all = await db.select(db.dutyPeriods).get();
    expect(all.every((d) => d.toUtc!.toUtc() == stop && d.isAutoClosed),
        isTrue);
  });

  test('someone taken off duty is not put back until the next start',
      () async {
    final charter = await makeCharter();
    await duties().startWithTracking(charter,
        at: DateTime.utc(2026, 7, 19, 8));
    final jan = (await db.getRunningDuties(charter))
        .firstWhere((d) => d.crewName == 'Ján');
    await duties().endDuty(jan, at: DateTime.utc(2026, 7, 19, 10));

    final running = await db.getRunningDuties(charter);
    expect(running.map((d) => d.crewName), unorderedEquals(['Skipper', 'Eva']));

    // Next morning's fresh start puts everyone back on.
    await duties().endWithTracking(charter, at: DateTime.utc(2026, 7, 19, 17));
    await duties().startWithTracking(charter,
        at: DateTime.utc(2026, 7, 20, 8));
    expect((await db.getRunningDuties(charter)).map((d) => d.crewName),
        unorderedEquals(['Skipper', 'Ján', 'Eva']));
  });

  test('an end before a duty began is clamped to its start', () async {
    // An interrupted voyage closes at its last track point, which can precede
    // a duty started by hand after the phone went quiet.
    final charter = await makeCharter();
    final start = DateTime.utc(2026, 7, 19, 12);
    await duties().startDuties(
        charterId: charter,
        members: const [CrewMember(name: 'Eva')],
        at: start);

    await duties().endWithTracking(charter,
        at: DateTime.utc(2026, 7, 19, 11));

    final d = (await db.select(db.dutyPeriods).get()).single;
    expect(d.toUtc!.toUtc(), start);
  });
}
