import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';
import 'package:hmb_sailing_log/features/charter/presentation/widgets/paper_day_figures.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/main.dart';

void main() {
  late AppDatabase db;
  late AppLocalizations l;
  var changed = 0;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    l = await AppLocalizations.delegate.load(const Locale('sk'));
    changed = 0;
  });
  tearDown(() async => db.close());

  Future<int> makeDay() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Z papiera',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 10),
      createdAt: DateTime(2026, 7, 10),
      source: const Value(CharterSource.paper),
    ));
    return (await db.insertDayLog(DayLogsCompanion.insert(
            charterId: c.id, date: DateTime(2026, 7, 10))))
        .id;
  }

  Future<void> pump(WidgetTester t, int dayId) async {
    final day = (await db.getDayLogById(dayId))!;
    await t.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('sk'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PaperDayFigures(day: day, onChanged: () => changed++),
        ),
      ),
    ));
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  testWidgets('saves the miles and night hours copied from the paper',
      (t) async {
    final dayId = await makeDay();
    await pump(t, dayId);

    await t.tap(key('day-figures-edit'));
    await t.pumpAndSettle();
    await t.enterText(key('day-figures-miles'), '12,5');
    await t.enterText(key('day-figures-night'), '3,5');
    await t.tap(find.text(l.save));
    await t.pumpAndSettle();

    final day = (await db.getDayLogById(dayId))!;
    expect(day.distanceNm, 12.5);
    expect(day.nightHoursManual, 3.5);
    expect(changed, 1);
  });

  testWidgets('empty night hours stay unset, not zero', (t) async {
    final dayId = await makeDay();
    await pump(t, dayId);

    await t.tap(key('day-figures-edit'));
    await t.pumpAndSettle();
    await t.enterText(key('day-figures-miles'), '8');
    await t.tap(find.text(l.save));
    await t.pumpAndSettle();

    final day = (await db.getDayLogById(dayId))!;
    expect(day.distanceNm, 8);
    expect(day.nightHoursManual, equals(null)); // drift also exports isNull
  });

  testWidgets('more than 24 night hours in a day is refused', (t) async {
    final dayId = await makeDay();
    await pump(t, dayId);

    await t.tap(key('day-figures-edit'));
    await t.pumpAndSettle();
    await t.enterText(key('day-figures-night'), '30');
    await t.tap(find.text(l.save));
    await t.pumpAndSettle();

    expect(find.text(l.numberInvalid), findsOneWidget);
    expect((await db.getDayLogById(dayId))!.nightHoursManual, equals(null));
    expect(changed, 0);
  });

  testWidgets('the straight line through the entries is offered as a hint',
      (t) async {
    final dayId = await makeDay();
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayId),
      timestamp: DateTime.utc(2026, 7, 10, 8),
      latitude: const Value(43.9),
      longitude: const Value(15.4),
    ));
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayId),
      timestamp: DateTime.utc(2026, 7, 10, 12),
      latitude: const Value(44.0),
      longitude: const Value(15.5),
    ));
    await pump(t, dayId);

    await t.tap(key('day-figures-edit'));
    await t.pumpAndSettle();

    expect(find.textContaining(l.straightLineLabel), findsOneWidget);
  });

  testWidgets('the track button builds an estimate and says so', (t) async {
    final dayId = await makeDay();
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayId),
      timestamp: DateTime.utc(2026, 7, 10, 8),
      latitude: const Value(43.9),
      longitude: const Value(15.4),
    ));
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(dayId),
      timestamp: DateTime.utc(2026, 7, 10, 12),
      latitude: const Value(44.0),
      longitude: const Value(15.5),
    ));
    await pump(t, dayId);

    await t.tap(key('day-figures-build-track'));
    await t.pumpAndSettle();

    expect(find.text(l.trackBuiltFromEntries), findsOneWidget);
    expect((await db.getSessionsForDay(dayId)).single.isEstimated, isTrue);
    expect(changed, 1);
  });

  testWidgets('without two positioned entries it explains instead of drawing',
      (t) async {
    final dayId = await makeDay();
    await pump(t, dayId);

    await t.tap(key('day-figures-build-track'));
    await t.pumpAndSettle();

    expect(find.text(l.trackNeedsTwoEntries), findsOneWidget);
    expect(await db.getSessionsForDay(dayId), isEmpty);
  });
}
