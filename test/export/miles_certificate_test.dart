import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';
import 'package:hmb_sailing_log/core/utils/localized_date.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/features/miles/services/miles_calculator.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

/// The mile certificate is handed to an authority, so the questions it must
/// answer are: whose miles, in what capacity, on whose boat, and who vouches
/// for them. It used to answer none of them.
void main() {
  setUpAll(() async => initializeDateFormatting());
  TestWidgetsFlutterBinding.ensureInitialized();

  VoyageRow voyage({
    required String role,
    String? skipper,
    bool? tidal,
    double nm = 120,
  }) =>
      VoyageRow(
        dateFrom: DateTime(2026, 7, 1),
        dateTo: DateTime(2026, 7, 8),
        vesselName: 'Chingy Lingy',
        area: 'Central Dalmatia',
        distanceNm: nm,
        days: 8,
        nightHours: 6,
        role: role,
        isManualEntry: false,
        skipperName: skipper,
        tidalWaters: tidal,
        charterId: 1,
      );

  MilesAggregate aggregateOf(List<VoyageRow> voyages) =>
      MilesCalculator.restrictTo(MilesAggregate.empty, voyages);

  Future<int> build(
    List<VoyageRow> voyages, {
    required bool forSelf,
    String? recipient,
  }) async {
    final l = await AppLocalizations.delegate.load(const Locale('sk'));
    final bytes = await PdfExportService.exportMilesCertificate(
      dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
      l: l,
      aggregate: aggregateOf(voyages),
      signerName: 'Miroslav Golias',
      issuerQualification: 'Skipper A',
      recipientName: recipient,
      forSelf: forSelf,
    );
    return bytes.length;
  }

  test('restrictTo recomputes the totals from the chosen voyages only', () {
    final agg = aggregateOf([
      voyage(role: 'skipper', nm: 100),
      voyage(role: 'crew', nm: 50),
    ]);
    expect(agg.totalNm, 150);
    expect(agg.voyageCount, 2);
    // A certificate whose total does not match the rows under it is worse
    // than no certificate.
    expect(agg.nmByRole['skipper'], 100);
    expect(agg.nmByRole['crew'], 50);
  });

  test('a voyage with no recorded capacity is not silently a skipper voyage',
      () {
    final agg = aggregateOf([voyage(role: '', nm: 40)]);
    expect(agg.nmByRole['unknown'], 40);
    expect(agg.nmByRole.containsKey('skipper'), isFalse);
  });

  test('builds for myself and for a crew member', () async {
    final voyages = [
      voyage(role: 'skipper', skipper: 'Miroslav Golias', tidal: false),
      voyage(role: 'crew', skipper: 'Peter Kováč', tidal: true),
    ];
    expect(await build(voyages, forSelf: true), greaterThan(1000));
    expect(
        await build(voyages, forSelf: false, recipient: 'Jozef Knop'),
        greaterThan(1000));
  });

  test('crew voyages add the skipper\'s signature block', () async {
    // The holder cannot vouch for miles sailed under someone else's command,
    // so the document has to leave that person a line to sign.
    final withoutCrew = await build(
        [voyage(role: 'skipper', skipper: 'Miroslav Golias')],
        forSelf: true);
    final withCrew = await build([
      voyage(role: 'skipper', skipper: 'Miroslav Golias'),
      voyage(role: 'crew', skipper: 'Peter Kováč'),
    ], forSelf: true);
    expect(withCrew, greaterThan(withoutCrew));
  });

  test('builds in every supported locale', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = await AppLocalizations.delegate.load(locale);
      final bytes = await PdfExportService.exportMilesCertificate(
        dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
        l: l,
        aggregate: aggregateOf([
          voyage(role: 'crew', skipper: 'Peter Kováč', tidal: true),
        ]),
        signerName: 'Miroslav Golias',
        forSelf: false,
        recipientName: 'Jozef Knop',
      );
      expect(bytes.length, greaterThan(1000),
          reason: 'miles certificate failed for ${locale.languageCode}');
    }
  });
}
