import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/safety/presentation/screens/maritime_reference_screen.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Day shapes are read off the screen and acted on, so a shape paired with the
/// wrong COLREG rule is worse than no reference at all. Build 55 shipped with
/// ball-diamond-ball labelled "constrained by her draught" (that is Rule 28,
/// the cylinder) and the cylinder labelled "pilot vessel" (which has no day
/// shape at all), so these pairings are pinned down here.
void main() {
  Widget harness(Locale locale) => MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MaritimeReferenceScreen(),
      );

  /// A window tall enough to hold every card, so nothing hides below the fold.
  void tallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// Opens the day shapes tab and returns the text of the card carrying [rule].
  Future<String> cardFor(WidgetTester tester, String rule) async {
    tallWindow(tester);
    await tester.pumpWidget(harness(const Locale('en')));
    await tester.tap(find.text('Day Shapes'));
    await tester.pumpAndSettle();

    final card = find.ancestor(of: find.text(rule), matching: find.byType(Card));
    expect(card, findsOneWidget, reason: 'exactly one card for $rule');
    return tester
        .widgetList<Text>(find.descendant(of: card, matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .join(' | ');
  }

  testWidgets('ball-diamond-ball is Rule 27(b), restricted in manoeuvring',
      (tester) async {
    final text = await cardFor(tester, 'Rule 27(b)');
    expect(text, contains('Ball'));
    expect(text, contains('Diamond'));
    expect(text, contains('restricted in her ability to manoeuvre'));
    expect(text, isNot(contains('draught')));
  });

  testWidgets('the cylinder is Rule 28, constrained by draught - not a pilot',
      (tester) async {
    final text = await cardFor(tester, 'Rule 28');
    expect(text, contains('Cylinder'));
    expect(text, contains('constrained by her draught'));
    expect(text.toLowerCase(), isNot(contains('pilot')));
  });

  testWidgets('two cones apex together mean fishing, not a 150 m gear marker',
      (tester) async {
    final text = await cardFor(tester, 'Rule 26');
    expect(text, contains('cones apex together'));
    expect(text, contains('engaged in fishing'));
    // The 150 m case is a different shape (a single cone, apex up), so it may
    // only appear as the note that says exactly that.
    expect(text, contains('apex up'));
  });

  testWidgets('anchor, NUC, towing and aground keep their rules',
      (tester) async {
    expect(await cardFor(tester, 'Rule 30'), contains('at anchor'));
    expect(await cardFor(tester, 'Rule 27(a)'), contains('Not Under Command'));
    expect(await cardFor(tester, 'Rule 24'), contains('200 m'));
    expect(await cardFor(tester, 'Rule 30(d)'), contains('aground'));
  });

  testWidgets('the motorsailing cone points apex down (Rule 25)',
      (tester) async {
    final text = await cardFor(tester, 'Rule 25');
    expect(text, contains('apex'));
    expect(text, contains('down'));
  });

  testWidgets('Czech calls the shape a balon, not a koule', (tester) async {
    tallWindow(tester);
    await tester.pumpWidget(harness(const Locale('cs')));
    await tester.tap(find.text('Denní znaky'));
    await tester.pumpAndSettle();

    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' | ');
    expect(texts, contains('balón'));
    expect(texts.toLowerCase(), isNot(contains('koule')));
  });
}
