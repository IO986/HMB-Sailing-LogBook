import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';
import 'package:hmb_sailing_log/features/miles/presentation/screens/miles_book_screen.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/main.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Deleting from the mile book, by tapping, the way a person does it.
void main() {
  late AppDatabase db;
  late AppLocalizations l;

  setUpAll(() => initializeDateFormatting('sk'));
  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    l = await AppLocalizations.delegate.load(const Locale('sk'));
  });
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(800, 1600);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (c, s) => const MilesBookScreen()),
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
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
  }

  Future<void> deleteFirstRow(WidgetTester t) async {
    await t.tap(find.byType(PopupMenuButton<String>).first);
    await t.pumpAndSettle();
    await t.tap(find.text(l.delete).last);
    await t.pumpAndSettle();
  }

  testWidgets('a manual historical voyage is deleted after confirming',
      (t) async {
    await db.into(db.historicalVoyages).insert(
          HistoricalVoyagesCompanion.insert(
            dateFrom: DateTime(2020, 7, 1),
            dateTo: DateTime(2020, 7, 8),
            vesselName: 'Stará loď',
            distanceNm: const Value(100),
            createdAt: DateTime(2026, 7, 1),
          ),
        );
    await pump(t);
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);

    await deleteFirstRow(t);
    // The confirmation dialog.
    expect(find.text(l.deleteHistoricalVoyageConfirm), findsOneWidget);
    await t.tap(find.widgetWithText(ElevatedButton, l.delete));
    await t.pumpAndSettle();

    expect(await db.getAllHistoricalVoyages(), isEmpty);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('a transcribed voyage is deleted with its days', (t) async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Z papiera',
      dateFrom: DateTime(2026, 7, 10),
      dateTo: DateTime(2026, 7, 10),
      vesselName: const Value('Papierová'),
      createdAt: DateTime(2026, 7, 10),
      source: const Value(CharterSource.paper),
    ));
    await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 7, 10),
      distanceNm: const Value(12),
    ));
    await pump(t);
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);

    await deleteFirstRow(t);
    expect(find.text(l.deleteCharterContent), findsOneWidget);
    await t.tap(find.widgetWithText(ElevatedButton, l.delete));
    await t.pumpAndSettle();

    expect(await db.getCharterById(c.id), equals(null));
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('cancelling leaves the voyage alone', (t) async {
    await db.into(db.historicalVoyages).insert(
          HistoricalVoyagesCompanion.insert(
            dateFrom: DateTime(2020, 7, 1),
            dateTo: DateTime(2020, 7, 8),
            vesselName: 'Stará loď',
            createdAt: DateTime(2026, 7, 1),
          ),
        );
    await pump(t);

    await deleteFirstRow(t);
    await t.tap(find.text(l.cancel));
    await t.pumpAndSettle();

    expect((await db.getAllHistoricalVoyages()).length, 1);
  });
}
