import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// The voyage header carries three status icons that blink while something is
/// missing. Everything else moved behind the overflow menu: with six actions
/// the AppBar squeezed the title until the voyage date was three dots, which
/// is what the tester saw.
void main() {
  const title = 'Plavba Split 8.–15.8.2026';

  Widget harness(List<Widget> actions, {int maxLines = 2}) => MaterialApp(
        locale: const Locale('sk'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(
            title: Text(title,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, height: 1.15)),
            actions: actions,
          ),
        ),
      );

  List<Widget> icons(int count) => [
        for (var i = 0; i < count; i++)
          IconButton(icon: const Icon(Icons.circle), onPressed: () {}),
      ];

  /// Width the title actually gets, which is what decides the ellipsis.
  double titleWidth(WidgetTester tester) =>
      tester.getSize(find.text(title)).width;

  testWidgets('the date fits with three icons and an overflow menu',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness([
      ...icons(3),
      PopupMenuButton<String>(
        itemBuilder: (_) => const [PopupMenuItem(value: 'a', child: Text('a'))],
      ),
    ]));
    final withMenu = titleWidth(tester);

    await tester.pumpWidget(harness(icons(6)));
    final withSixIcons = titleWidth(tester);

    expect(withMenu, greaterThan(withSixIcons),
        reason: 'the overflow menu gives the title its room back');

    // A narrow phone cannot fit this title on one line at all, so the header
    // wraps to a second line rather than cutting the date off.
    final twoLineHeight = tester.getSize(find.text(title)).height;
    await tester.pumpWidget(harness([
      ...icons(3),
      PopupMenuButton<String>(
        itemBuilder: (_) => const [PopupMenuItem(value: 'a', child: Text('a'))],
      ),
    ], maxLines: 1));
    final oneLineHeight = tester.getSize(find.text(title)).height;

    expect(twoLineHeight, greaterThan(oneLineHeight),
        reason: 'the second line is what shows the date');
  });
}
