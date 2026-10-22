import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/shared/widgets/coordinate_input.dart';

void main() {
  CoordinateEdit? last;
  var edits = 0;

  Widget app(Widget body) => MaterialApp(
        locale: const Locale('sk'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: body),
      );

  CoordinateInput input({
    required CoordFormat format,
    bool isLatitude = true,
    double? initial,
  }) =>
      CoordinateInput(
        keyPrefix: 'c',
        isLatitude: isLatitude,
        initial: initial,
        format: format,
        label: 'Šírka',
        onEdited: (e) {
          last = e;
          edits++;
        },
      );

  Future<void> pump(
    WidgetTester t, {
    required CoordFormat format,
    bool isLatitude = true,
    double? initial,
  }) async {
    last = null;
    edits = 0;
    await t.pumpWidget(app(
        input(format: format, isLatitude: isLatitude, initial: initial)));
  }

  Finder cell(String k) => find.byKey(ValueKey('c-$k'));
  String text(WidgetTester t, String k) =>
      t.widget<TextField>(cell(k)).controller!.text;
  Finder hemisphere(String letter) =>
      find.descendant(of: cell('hem'), matching: find.text(letter));

  group('degrees and decimal minutes', () {
    testWidgets('two cells combine into decimal degrees', (t) async {
      await pump(t, format: CoordFormat.dmm);
      await t.enterText(cell('deg'), '43');
      await t.enterText(cell('min'), '30,738');
      expect(last!.value, closeTo(43 + 30.738 / 60, 1e-9));
      expect(last!.invalid, isFalse);
    });

    testWidgets('the hemisphere toggle makes it negative', (t) async {
      await pump(t, format: CoordFormat.dmm);
      await t.enterText(cell('deg'), '43');
      await t.enterText(cell('min'), '30');
      await t.tap(hemisphere('S'));
      await t.pump();
      expect(last!.value, closeTo(-43.5, 1e-9));
    });

    testWidgets('a longitude toggles between E and W', (t) async {
      await pump(t, format: CoordFormat.dmm, isLatitude: false);
      expect(hemisphere('E'), findsOneWidget);
      expect(hemisphere('W'), findsOneWidget);
      expect(hemisphere('N'), findsNothing);
    });

    testWidgets('minutes only, and 60 or more minutes, are invalid',
        (t) async {
      await pump(t, format: CoordFormat.dmm);
      await t.enterText(cell('min'), '30');
      expect(last!.invalid, isTrue);

      await t.enterText(cell('deg'), '43');
      await t.enterText(cell('min'), '60');
      expect(last!.invalid, isTrue);
      await t.pump();
      final l = await AppLocalizations.delegate.load(const Locale('sk'));
      expect(find.text(l.coordinateInvalid), findsOneWidget);
    });

    testWidgets('degrees alone are fine, minutes count as zero', (t) async {
      await pump(t, format: CoordFormat.dmm);
      await t.enterText(cell('deg'), '43');
      expect(last!.value, 43);
    });

    testWidgets('cleared cells mean nothing recorded, not an error',
        (t) async {
      await pump(t, format: CoordFormat.dmm);
      await t.enterText(cell('deg'), '43');
      await t.enterText(cell('deg'), '');
      expect(last!.value, isNull);
      expect(last!.invalid, isFalse);
    });

    testWidgets('fills the cells from a stored value', (t) async {
      await pump(t, format: CoordFormat.dmm, initial: 43 + 30.738 / 60);
      expect(text(t, 'deg'), '43');
      expect(text(t, 'min'), '30.738');
      expect(edits, 0); // filling is not an edit
    });

    testWidgets('a stored west value selects the other hemisphere',
        (t) async {
      await pump(t, format: CoordFormat.dmm, isLatitude: false, initial: -15.5);
      expect(text(t, 'deg'), '15');
      expect(text(t, 'min'), '30.000');
      final toggle = t.widget<ToggleButtons>(cell('hem'));
      expect(toggle.isSelected, [false, true]); // W
    });

    testWidgets('59.9996 minutes rounds up into the next degree', (t) async {
      await pump(t, format: CoordFormat.dmm, initial: 43 + 59.9996 / 60);
      expect(text(t, 'deg'), '44');
      expect(text(t, 'min'), '0.000');
    });
  });

  group('decimal degrees', () {
    testWidgets('one cell, comma or dot', (t) async {
      await pump(t, format: CoordFormat.decimal);
      expect(cell('min'), findsNothing);
      await t.enterText(cell('deg'), '43,5123');
      expect(last!.value, closeTo(43.5123, 1e-9));
    });

    testWidgets('hemisphere toggle and range check', (t) async {
      await pump(t, format: CoordFormat.decimal, isLatitude: false);
      await t.enterText(cell('deg'), '15.441');
      await t.tap(hemisphere('W'));
      await t.pump();
      expect(last!.value, closeTo(-15.441, 1e-9));

      await t.enterText(cell('deg'), '181');
      expect(last!.invalid, isTrue);
    });

    testWidgets('fills the one cell from a stored value', (t) async {
      await pump(t, format: CoordFormat.decimal, initial: 43.5123);
      expect(text(t, 'deg'), '43.51230');
    });
  });

  testWidgets('a value that arrives late fills untouched cells, not typed ones',
      (t) async {
    await t.pumpWidget(app(input(format: CoordFormat.dmm)));
    await t.pumpWidget(app(input(format: CoordFormat.dmm, initial: 43.5)));
    expect(text(t, 'deg'), '43');

    await t.enterText(cell('deg'), '12');
    await t.pumpWidget(app(input(format: CoordFormat.dmm, initial: 50.0)));
    expect(text(t, 'deg'), '12'); // the person's typing wins
  });
}
