import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/bearing/providers/bearing_provider.dart';
import 'package:hmb_sailing_log/features/export/presentation/export_hub_screen.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/main.dart';
import 'package:intl/date_symbol_data_local.dart';

/// The hub is now the only way to reach an export — the icons and menu items
/// that used to live on six other screens are gone. If it renders empty or
/// throws, the app can no longer produce a single document, so "it compiled"
/// is not enough here.
void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('sk'));

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Widget harness() => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // The real one is fed by a drift stream, whose teardown leaves a
          // timer pending after the tree is disposed — nothing to do with
          // what this screen is being tested for.
          orphanBearingSessionsProvider
              .overrideWithValue(const <BearingSession>[]),
        ],
        child: MaterialApp(
          locale: const Locale('sk'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ExportHubScreen(),
        ),
      );

  /// Celá ponuka exportov sa na telefónnu obrazovku v teste nezmestí a
  /// ListView nepostavené riadky vôbec nevytvorí — plátno je preto vysoké.
  Future<void> pumpHub(WidgetTester t) async {
    t.view.physicalSize = const Size(1200, 3000);
    t.view.devicePixelRatio = 1.0;
    addTearDown(() {
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    });
    await t.pumpWidget(harness());
    // Not pumpAndSettle: a collapsed section keeps a progress indicator alive
    // while its data loads, and that animation never settles.
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
  }

  Future<Charter> makeCharter({
    required String title,
    required DateTime from,
    bool checkedOut = false,
  }) =>
      db.insertCharter(ChartersCompanion.insert(
        title: title,
        dateFrom: from,
        dateTo: from.add(const Duration(days: 5)),
        createdAt: from,
        checkOutDone: Value(checkedOut),
      ));

  testWidgets('every export is offered from the one screen', (t) async {
    await makeCharter(title: 'Kornati', from: DateTime(2026, 5, 2));
    await pumpHub(t);

    final l = await AppLocalizations.delegate.load(const Locale('sk'));
    for (final label in [
      l.exportsWholeVoyage,
      l.exportsDay,
      l.handoverMenuTitle,
      l.crewCertTitle,
      l.milesExportTitle,
      l.bearingsTitle,
      l.exportsCloudTitle,
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'missing row: $label');
    }
  });

  /// The voyage still awaiting checkout is the one exported from, and it is
  /// exported from right after anchoring — not the newest record on file.
  testWidgets('the running voyage is preselected over a newer finished one',
      (t) async {
    await makeCharter(title: 'Beží', from: DateTime(2026, 5, 2));
    await makeCharter(
        title: 'Odovzdaná', from: DateTime(2026, 8, 1), checkedOut: true);

    await pumpHub(t);

    expect(find.text('Beží'), findsOneWidget);
    expect(find.text('Odovzdaná'), findsNothing);
  });

  testWidgets('with no voyage at all it still renders and says so', (t) async {
    await pumpHub(t);

    final l = await AppLocalizations.delegate.load(const Locale('sk'));
    expect(find.text(l.exportsNoVoyages), findsWidgets);
    // Cross-voyage exports do not depend on a voyage existing.
    expect(find.text(l.milesExportTitle), findsOneWidget);
  });
}
