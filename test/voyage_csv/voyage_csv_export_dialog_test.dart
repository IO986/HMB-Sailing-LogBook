import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/voyage_csv/presentation/voyage_csv_export_dialog.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/main.dart';

void main() {
  late AppDatabase db;
  late AppLocalizations l;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    l = await AppLocalizations.delegate.load(const Locale('sk'));
  });
  tearDown(() async => db.close());

  Future<Charter> voyageWithTrack(int points) async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Kornati',
      dateFrom: DateTime(2026, 5, 2),
      dateTo: DateTime(2026, 5, 9),
      createdAt: DateTime(2026, 5, 2),
    ));
    final d = await db.insertDayLog(
        DayLogsCompanion.insert(charterId: c.id, date: DateTime(2026, 5, 2)));
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 's',
      dayLogId: Value(d.id),
      startTime: DateTime.utc(2026, 5, 2),
      isActive: const Value(false),
    ));
    await db.insertTrackPointsBatch([
      for (var i = 0; i < points; i++)
        TrackPointsCompanion.insert(
          sessionId: const Value('s'),
          timestamp: DateTime.utc(2026, 5, 2).add(Duration(seconds: i)),
          latitude: 43.9,
          longitude: 15.4,
        ),
    ]);
    return c;
  }

  Future<void> open(WidgetTester t, Charter c) async {
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showVoyageCsvExport(context, c),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }

  testWidgets('says what the file is and warns about the personal data',
      (t) async {
    await open(t, await voyageWithTrack(3));
    expect(find.text(l.exportsCsvTitle), findsOneWidget);
    expect(find.text(l.exportsCsvDesc), findsOneWidget);
    expect(find.text(l.csvExportPrivacy), findsOneWidget);
  });

  testWidgets('shows how many track points there are, and about how large',
      (t) async {
    await open(t, await voyageWithTrack(3));
    expect(find.textContaining('${l.csvExportTrackPoints}: 3'), findsOneWidget);
    expect(find.textContaining('< 0,1 MB'), findsOneWidget);
  });

  testWidgets('a large track is announced in megabytes', (t) async {
    await open(t, await voyageWithTrack(50000));
    expect(find.textContaining('${l.csvExportTrackPoints}: 50000'),
        findsOneWidget);
    expect(find.textContaining('≈ 3,8 MB'), findsOneWidget);
  });

  testWidgets('the track is included unless the person switches it off',
      (t) async {
    await open(t, await voyageWithTrack(3));
    final tile = find.byKey(const ValueKey('csv-include-track'));
    expect(t.widget<SwitchListTile>(tile).value, isTrue);

    await t.tap(tile);
    await t.pump();
    expect(t.widget<SwitchListTile>(tile).value, isFalse);
  });

  testWidgets('a voyage without a track has nothing to size', (t) async {
    await open(t, await voyageWithTrack(0));
    expect(find.textContaining('${l.csvExportTrackPoints}: 0'), findsOneWidget);
    expect(find.textContaining('MB'), findsNothing);
  });

  testWidgets('cancel closes it', (t) async {
    await open(t, await voyageWithTrack(3));
    await t.tap(find.text(l.cancel));
    await t.pumpAndSettle();
    expect(find.text(l.exportsCsvTitle), findsNothing);
  });
}
