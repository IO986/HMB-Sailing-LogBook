import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_codec.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_record.dart';
import 'package:hmb_sailing_log/features/voyage_csv/presentation/voyage_csv_import_screen.dart';
import 'package:hmb_sailing_log/features/voyage_csv/services/voyage_csv_exporter.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/main.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'voyage_fixture.dart';

void main() {
  late AppDatabase source;
  late AppDatabase db;
  late AppLocalizations l;

  setUpAll(() => initializeDateFormatting('sk'));
  setUp(() async {
    source = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    l = await AppLocalizations.delegate.load(const Locale('sk'));
  });
  tearDown(() async {
    await source.close();
    await db.close();
  });

  Future<VoyageCsvDocument> exportedVoyage() async {
    final id = await buildFullVoyage(source);
    final sb = StringBuffer();
    await VoyageCsvExporter.write(source, id, sb,
        includeTrack: true, appVersion: 'x');
    return VoyageCsvReader.read(sb.toString());
  }

  String? openedLocation;

  Future<void> pump(WidgetTester t, {VoyageCsvDocument? doc}) async {
    t.view.physicalSize = const Size(800, 1800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    openedLocation = null;

    final router = GoRouter(initialLocation: '/import', routes: [
      GoRoute(
          path: '/import',
          builder: (c, s) => VoyageCsvImportScreen(initialDocument: doc)),
      GoRoute(
          path: '/logbook/:id',
          builder: (c, s) {
            openedLocation = s.uri.path;
            return const Scaffold(body: Text('detail'));
          }),
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
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('opens on the explanation and the pick button', (t) async {
    await pump(t);
    expect(find.text(l.importCsvIntro), findsOneWidget);
    expect(find.byKey(const ValueKey('csv-import-pick')), findsOneWidget);
    expect(find.byKey(const ValueKey('csv-import-go')), findsNothing);
  });

  testWidgets('shows what is in the file before anything is written',
      (t) async {
    await pump(t, doc: await exportedVoyage());
    expect(find.text('Kornati "máj", 2026'), findsOneWidget);
    expect(find.text('Ružena'), findsOneWidget);
    expect(find.text('${l.crew}: 2'), findsOneWidget);
    expect(find.text(l.voyageDaysCount(2)), findsOneWidget);
    expect(find.text(l.recordCount(2)), findsOneWidget);
    expect(find.text('${l.csvExportTrackPoints}: 6'), findsOneWidget);
    expect(find.byKey(const ValueKey('csv-import-go')), findsOneWidget);
    expect(await db.getAllCharters(), isEmpty);
  });

  testWidgets('says so when the file has no track', (t) async {
    final id = await buildFullVoyage(source);
    final sb = StringBuffer();
    await VoyageCsvExporter.write(source, id, sb,
        includeTrack: false, appVersion: 'x');
    await pump(t, doc: VoyageCsvReader.read(sb.toString()));
    expect(find.text(l.importCsvNoTrack), findsOneWidget);
  });

  testWidgets('import writes the voyage and opens it', (t) async {
    await pump(t, doc: await exportedVoyage());

    await t.tap(find.byKey(const ValueKey('csv-import-go')));
    await t.pumpAndSettle();

    final charters = await db.getAllCharters();
    expect(charters.length, 1);
    expect(charters.single.title, 'Kornati "máj", 2026');
    expect(openedLocation, '/logbook/${charters.single.id}');
    expect(find.text(l.importCsvDone), findsOneWidget);
  });

  testWidgets('a voyage that is already there is not offered again',
      (t) async {
    final doc = await exportedVoyage();
    // The same voyage is in the target database already.
    final sb = StringBuffer();
    final id = await buildFullVoyage(db);
    await VoyageCsvExporter.write(db, id, sb,
        includeTrack: true, appVersion: 'x');
    final sameVoyage = VoyageCsvReader.read(sb.toString());

    await pump(t, doc: sameVoyage);
    expect(find.byKey(const ValueKey('csv-import-already')), findsOneWidget);
    expect(find.text(l.importCsvAlready), findsOneWidget);
    expect(find.byKey(const ValueKey('csv-import-go')), findsNothing);
    expect(doc.records, isNotEmpty);
  });

  testWidgets('warnings are listed with their kind, not hidden', (t) async {
    final id = await buildFullVoyage(source);
    final sb = StringBuffer();
    await VoyageCsvExporter.write(source, id, sb,
        includeTrack: false, appVersion: 'x');
    // A column the reader does not know.
    final text = sb.toString().replaceFirst('record_type,', 'zeta,record_type,');
    final body = text.split('\r\n');
    final withZeta = [
      body.first,
      for (final line in body.skip(1))
        if (line.isNotEmpty) ',$line' else line,
    ].join('\r\n');
    await pump(t, doc: VoyageCsvReader.read(withZeta));

    expect(find.text(l.importCsvWarnings), findsOneWidget);
    expect(find.text('• ${l.csvWarnUnknownColumns}: zeta'), findsOneWidget);
  });
}
