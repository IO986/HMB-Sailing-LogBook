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

/// A voyage transcribed from a paper logbook is typed in, not recorded: the
/// time and the position are what the paper says, and nothing may be filled in
/// from "now" — not the position, not the weather, not a running GPS session.
void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('sk'));

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<int> makeDay(String source) async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Z papiera',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 10),
      createdAt: DateTime(2026, 7, 10),
      source: Value(source),
    ));
    final d = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: c.id, date: DateTime(2026, 7, 10)));
    return d.id;
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

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('saves the typed time and position, and nothing from "now"',
      (t) async {
    final dayId = await makeDay(CharterSource.paper);
    await pumpEntry(t, dayId);

    await t.enterText(field('Šírka'), "43° 30.738' N");
    await t.enterText(field('Dĺžka'), '15,4410 E');
    await t.enterText(field('SOG (kn)'), '5,5');
    await t.enterText(field('COG (°)'), '270');

    final l = await AppLocalizations.delegate.load(const Locale('sk'));
    await t.tap(find.text(l.save));
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));

    final entry = (await db.getEntriesForDay(dayId)).single;
    expect(entry.latitude, closeTo(43 + 30.738 / 60, 1e-9));
    expect(entry.longitude, closeTo(15.441, 1e-9));
    expect(entry.sog, 5.5);
    expect(entry.cog, 270);

    // The entry sits on the day it was added to, at the default time.
    final local = entry.timestamp.toLocal();
    expect((local.year, local.month, local.day), (2026, 7, 10));

    // Not a recording: no GPS session, no weather source, no sail mode
    // guessed, not an automatic entry.
    expect(entry.sessionId, isNull);
    expect(entry.weatherSource, isNull);
    expect(entry.locationSource, isNull);
    expect(entry.accuracyMeters, isNull);
    expect(entry.sailMode, isNull);
    expect(entry.isAutoEntry, isFalse);
  });

  testWidgets('an unreadable coordinate blocks the save and says so',
      (t) async {
    final dayId = await makeDay(CharterSource.paper);
    await pumpEntry(t, dayId);

    await t.enterText(field('Šírka'), 'abc');
    await t.enterText(field('Dĺžka'), '15.4410 E');

    final l = await AppLocalizations.delegate.load(const Locale('sk'));
    await t.tap(find.text(l.save));
    await t.pump(const Duration(milliseconds: 300));

    expect(find.text(l.coordinateInvalid), findsOneWidget);
    expect(await db.getEntriesForDay(dayId), isEmpty);
  });

  testWidgets('half a position is refused rather than put on the equator',
      (t) async {
    final dayId = await makeDay(CharterSource.paper);
    await pumpEntry(t, dayId);

    await t.enterText(field('Šírka'), '43.5');

    final l = await AppLocalizations.delegate.load(const Locale('sk'));
    await t.tap(find.text(l.save));
    await t.pump(const Duration(milliseconds: 300));

    expect(find.text(l.coordinateInvalid), findsOneWidget);
    expect(await db.getEntriesForDay(dayId), isEmpty);
  });
}
