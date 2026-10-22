import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';
import 'package:hmb_sailing_log/features/logbook/presentation/screens/logbook_entry_screen.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/main.dart';
import 'package:intl/date_symbol_data_local.dart';

/// A day with a measured track (a GPX import) already knows where the boat was
/// at any time. Typing the time of a paper entry should fill the position from
/// it, and never override what the skipper typed.
void main() {
  late AppDatabase db;
  late AppLocalizations l;

  setUpAll(() => initializeDateFormatting('sk'));
  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    l = await AppLocalizations.delegate.load(const Locale('sk'));
  });
  tearDown(() async => db.close());

  Future<int> makeDay({required bool withTrack, bool estimated = false}) async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Z papiera',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 10),
      createdAt: DateTime(2026, 7, 10),
      source: const Value(CharterSource.paper),
    ));
    final day = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: c.id, date: DateTime(2026, 7, 10)));
    if (withTrack) {
      await db.upsertSession(SailingSessionsCompanion.insert(
        sessionId: 's1',
        dayLogId: Value(day.id),
        startTime: DateTime(2026, 7, 10, 10),
        isEstimated: Value(estimated),
      ));
      await db.insertTrackPointsBatch([
        TrackPointsCompanion.insert(
          sessionId: const Value('s1'),
          timestamp: DateTime(2026, 7, 10, 10, 0),
          latitude: 43.0,
          longitude: 15.0,
        ),
        TrackPointsCompanion.insert(
          sessionId: const Value('s1'),
          timestamp: DateTime(2026, 7, 10, 10, 10),
          latitude: 43.1,
          longitude: 15.2,
        ),
      ]);
    }
    return day.id;
  }

  Future<void> pumpEntry(WidgetTester t, int dayLogId) async {
    t.view.physicalSize = const Size(1200, 3600);
    t.view.devicePixelRatio = 1.0;
    addTearDown(() {
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    });
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (c, s) => const Scaffold()),
      GoRoute(
          path: '/entry',
          builder: (c, s) => LogbookEntryScreen(dayLogId: dayLogId)),
    ]);
    await t.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        routerConfig: router,
        // The test environment defaults to a 12-hour dial, where "10" typed
        // into the hour field means 10 PM.
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        locale: const Locale('sk'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    router.push('/entry');
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
  }

  Finder cell(String key) => find.byKey(ValueKey(key));
  String cellText(WidgetTester t, String key) =>
      t.widget<TextField>(cell(key)).controller!.text;

  /// Picks [hour]:[minute] in the time dialog through its keyboard mode.
  Future<void> pickTime(WidgetTester t, int hour, int minute) async {
    await t.tap(find.text(l.entryTimeLabel));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.keyboard_outlined));
    await t.pumpAndSettle();
    final fields = find.descendant(
        of: find.byType(Dialog), matching: find.byType(TextField));
    await t.enterText(fields.at(0), '$hour');
    await t.enterText(fields.at(1), '$minute');
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
  }

  Future<void> save(WidgetTester t) async {
    await t.tap(find.text(l.save));
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('picking a time fills the position from the track', (t) async {
    final dayId = await makeDay(withTrack: true);
    await pumpEntry(t, dayId);

    await pickTime(t, 10, 5);
    expect(find.textContaining('10:05'), findsOneWidget);

    expect(find.byKey(const ValueKey('position-from-track')), findsOneWidget);
    expect(cellText(t, 'lat-deg'), '43');
    expect(cellText(t, 'lat-min'), '3.000'); // 43.05° = 43° 3.000'

    await save(t);
    final entry = (await db.getEntriesForDay(dayId)).single;
    expect(entry.latitude, closeTo(43.05, 1e-9));
    expect(entry.longitude, closeTo(15.10, 1e-9));
    expect(entry.locationSource, 'track');
  });

  testWidgets('a position the skipper typed is never replaced by the track',
      (t) async {
    final dayId = await makeDay(withTrack: true);
    await pumpEntry(t, dayId);

    await t.enterText(cell('lat-deg'), '44');
    await t.enterText(cell('lat-min'), '30');
    await t.enterText(cell('lon-deg'), '16');
    await t.enterText(cell('lon-min'), '0');
    await pickTime(t, 10, 5);

    expect(find.byKey(const ValueKey('position-from-track')), findsNothing);
    await save(t);

    final entry = (await db.getEntriesForDay(dayId)).single;
    expect(entry.latitude, closeTo(44.5, 1e-9));
    expect(entry.longitude, closeTo(16.0, 1e-9));
    expect(entry.locationSource, equals(null));
  });

  testWidgets('typing over a filled-in position drops the track label',
      (t) async {
    final dayId = await makeDay(withTrack: true);
    await pumpEntry(t, dayId);

    await pickTime(t, 10, 5);
    expect(find.byKey(const ValueKey('position-from-track')), findsOneWidget);

    await t.enterText(cell('lat-min'), '45');
    await t.pump();
    expect(find.byKey(const ValueKey('position-from-track')), findsNothing);
  });

  testWidgets('a time outside the recording leaves the position empty',
      (t) async {
    final dayId = await makeDay(withTrack: true);
    await pumpEntry(t, dayId);

    await pickTime(t, 15, 0); // the track ends at 10:10

    expect(find.byKey(const ValueKey('position-from-track')), findsNothing);
    expect(cellText(t, 'lat-deg'), '');
    await save(t);
    final entry = (await db.getEntriesForDay(dayId)).single;
    expect(entry.latitude, equals(null));
  });

  testWidgets('a day without a track offers no position from a track',
      (t) async {
    final dayId = await makeDay(withTrack: false);
    await pumpEntry(t, dayId);

    await pickTime(t, 10, 5);

    expect(find.byKey(const ValueKey('position-from-track')), findsNothing);
    expect(cellText(t, 'lat-deg'), '');
  });

  testWidgets('a line drawn through the entries is not a measurement',
      (t) async {
    final dayId = await makeDay(withTrack: true, estimated: true);
    await pumpEntry(t, dayId);

    await pickTime(t, 10, 5);

    expect(find.byKey(const ValueKey('position-from-track')), findsNothing);
    expect(cellText(t, 'lat-deg'), '');
  });
}
