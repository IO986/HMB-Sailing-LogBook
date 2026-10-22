import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/charter/presentation/widgets/voyage_days_header.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// The line above the list of days holds the title, "Add day" and, with more
/// than one day, the bulk delete. On a phone that row overflowed by tens of
/// pixels (the red text and the yellow-black stripe the tester saw).
void main() {
  var added = 0;
  var deleted = 0;

  Future<void> pump(WidgetTester t, String locale,
      {required int days, bool canAddDay = true, double width = 360}) async {
    t.view.physicalSize = Size(width, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    added = 0;
    deleted = 0;
    await t.pumpWidget(MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VoyageDaysHeader(
          dayCount: days,
          canAddDay: canAddDay,
          onAddDay: () => added++,
          onBulkDelete: () => deleted++,
        ),
      ),
    ));
  }

  // Every shipped language, because the labels differ a lot in length.
  for (final locale in AppLocalizations.supportedLocales
      .map((l) => l.languageCode)
      .toSet()) {
    testWidgets('fits a 320 dp phone with five days in "$locale"', (t) async {
      await pump(t, locale, days: 5, width: 320);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('both actions work', (t) async {
    await pump(t, 'sk', days: 5);
    final l = await AppLocalizations.delegate.load(const Locale('sk'));

    await t.tap(find.text(l.addDay));
    await t.tap(find.byTooltip(l.bulkDelete));

    expect(added, 1);
    expect(deleted, 1);
  });

  testWidgets('a recorded voyage has no add day, one day no bulk delete',
      (t) async {
    await pump(t, 'sk', days: 1, canAddDay: false);
    final l = await AppLocalizations.delegate.load(const Locale('sk'));

    expect(find.text(l.addDay), findsNothing);
    expect(find.byTooltip(l.bulkDelete), findsNothing);
  });
}
