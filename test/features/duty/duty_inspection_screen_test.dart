import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/duty/presentation/screens/duty_inspection_screen.dart';
import 'package:hmb_sailing_log/features/duty/providers/duty_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// The inspection screen is the one handed to somebody boarding the vessel, so
/// "it compiled" is not enough — it has to actually render, and it must never
/// show a blank screen when nobody is on duty.
void main() {
  final charter = Charter(
    id: 1,
    title: 'Plavba',
    dateFrom: DateTime(2026, 7, 10),
    dateTo: DateTime(2026, 7, 14),
    vesselName: 'Bavaria 41',
    skipperName: 'Ján Novák',
    mmsi: '256123456',
    safetyBriefingDone: true,
    checkInDone: true,
    checkOutDone: false,
    createdAt: DateTime(2026, 7, 10),
    pdfRevision: 0,
    source: 'live',
  );

  DutyPeriod running(String name, DateTime from) => DutyPeriod(
        id: 1,
        charterId: 1,
        crewName: name,
        role: 'crew',
        fromUtc: from,
        isAutoClosed: false,
        createdAt: from,
      );

  Widget harness(List<DutyPeriod> duties) => ProviderScope(
        overrides: [
          runningDutiesProvider.overrideWith((ref, id) => Stream.value(duties)),
          // The real one ticks every second and would leave a pending timer
          // after the tree is torn down.
          dutyClockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
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
          home: DutyInspectionScreen(charter: charter),
        ),
      );

  testWidgets('shows who is on duty, since when, and the vessel', (t) async {
    await t.pumpWidget(harness([
      running('Peter Kováč', DateTime.now().toUtc().subtract(const Duration(hours: 2))),
    ]));
    await t.pump();

    expect(find.text('Peter Kováč'), findsOneWidget);
    expect(find.text('Bavaria 41'), findsOneWidget);
    expect(find.textContaining('MMSI 256123456'), findsOneWidget);
    expect(find.textContaining('Ján Novák'), findsOneWidget);
  });

  testWidgets('states plainly that nobody is on duty rather than showing blank',
      (t) async {
    await t.pumpWidget(harness(const []));
    await t.pump();

    final l = await AppLocalizations.delegate.load(const Locale('sk'));
    expect(find.text(l.dutyNobodyOnDuty), findsOneWidget);
  });

  testWidgets('offers no way to change a record while an inspector holds it',
      (t) async {
    await t.pumpWidget(harness([
      running('Peter Kováč', DateTime.now().toUtc().subtract(const Duration(hours: 1))),
    ]));
    await t.pump();

    // Only the close button — no edit, delete or end-duty affordance.
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
