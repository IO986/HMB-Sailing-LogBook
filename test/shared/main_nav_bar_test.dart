import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/providers/nav_prefs_provider.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/shared/widgets/main_nav_bar.dart';

/// The bar carried a text label under every icon. Label length differs in
/// every one of the eight locales, so labels wrapped to two lines and pushed
/// the icons up and down — the same tab sat at a different height depending
/// on the language. The labels are hidden now, but they must stay in the
/// tree: they are what a screen reader announces and what the long-press
/// tooltip shows.
void main() {
  const paths = ['/map', '/logbook', '/weather', '/settings'];

  Widget harness(Locale locale, NavIconSize size, {int selected = 0}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: MainNavBar(
            paths: paths,
            currentIndex: selected,
            onSelected: (_) {},
            iconSize: size,
          ),
        ),
      );

  NavigationBar barOf(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar));

  testWidgets('labels are hidden, not removed', (tester) async {
    await tester.pumpWidget(harness(const Locale('sk'), NavIconSize.medium));

    final bar = barOf(tester);
    expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysHide);
    expect(bar.destinations, hasLength(paths.length));
    for (final d in bar.destinations.cast<NavigationDestination>()) {
      expect(d.label, isNotEmpty, reason: 'screen readers still need it');
    }
  });

  testWidgets('the bar is the same height in every language', (tester) async {
    final heights = <String, double>{};
    for (final code in ['sk', 'en', 'de', 'el', 'uk', 'it']) {
      await tester.pumpWidget(harness(Locale(code), NavIconSize.medium));
      heights[code] = tester.getSize(find.byType(NavigationBar)).height;
    }

    expect(heights.values.toSet(), hasLength(1),
        reason: 'a wrapped label used to make the bar taller: $heights');
  });

  testWidgets('icons keep their vertical position across languages',
      (tester) async {
    Offset firstIconCentre(WidgetTester t) =>
        t.getCenter(find.byIcon(Icons.map).first);

    await tester.pumpWidget(harness(const Locale('sk'), NavIconSize.medium));
    final sk = firstIconCentre(tester);
    // Greek and German have the longest labels of the set.
    await tester.pumpWidget(harness(const Locale('el'), NavIconSize.medium));
    final el = firstIconCentre(tester);
    await tester.pumpWidget(harness(const Locale('de'), NavIconSize.medium));
    final de = firstIconCentre(tester);

    expect(el.dy, sk.dy);
    expect(de.dy, sk.dy);
  });

  testWidgets('S/M/L change the icon size and the bar height together',
      (tester) async {
    for (final size in NavIconSize.values) {
      await tester.pumpWidget(harness(const Locale('sk'), size));
      await tester.pump();

      expect(barOf(tester).height, size.barHeight);
      final icon = tester.widget<Icon>(find.byIcon(Icons.map).first);
      expect(icon.size, size.iconDim, reason: size.name);
    }
  });

  testWidgets('the bar is shorter than the old labelled one', (tester) async {
    // The labelled bar used Material's default of 80 px.
    for (final size in NavIconSize.values) {
      await tester.pumpWidget(harness(const Locale('sk'), size));
      expect(tester.getSize(find.byType(NavigationBar)).height, lessThan(80));
    }
  });

  testWidgets('the selected tab uses the filled icon', (tester) async {
    await tester
        .pumpWidget(harness(const Locale('sk'), NavIconSize.medium, selected: 1));

    expect(find.byIcon(Icons.book), findsOneWidget, reason: 'logbook selected');
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
  });
}
