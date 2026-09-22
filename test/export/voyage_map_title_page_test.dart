import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/utils/localized_date.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

/// The whole-voyage map on the title page, and what happens when the day list
/// leaves it no room.
///
/// The title page is the one page of the export whose height is not under our
/// control: it grows with the number of days, the crew and the vessel photos.
/// A map laid out at a fixed height on a fixed-size page either overflows it
/// or gets silently clipped, and a map squeezed into whatever space is left
/// becomes an unreadable strip on a long voyage. Hence MultiPage — these tests
/// are what say it actually flows instead of vanishing.
void main() {
  setUpAll(() async => initializeDateFormatting());
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime(2026, 7, 10);

  Charter charter() => Charter(
        id: 1,
        title: 'Plavba júl 2026',
        dateFrom: start,
        dateTo: start.add(const Duration(days: 20)),
        skipperName: 'Ján Novák',
        crewNames: 'Peter Kováč|Eva Malá|Juraj Biely',
        safetyBriefingDone: true,
        checkInDone: true,
        checkOutDone: false,
        createdAt: start,
        pdfRevision: 0,
        source: 'live',
      );

  List<DayLog> days(int count) => [
        for (var i = 0; i < count; i++)
          DayLog(
            id: 100 + i,
            charterId: 1,
            date: start.add(Duration(days: i)),
            portFrom: 'Trogir',
            portTo: 'Vis',
            distanceNm: 24.5,
            isComplete: false,
          ),
      ];

  /// A 2x2 PNG. The map only has to be a decodable image; what it depicts
  /// makes no difference to the layout.
  final mapPng = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAD0lEQVR42mNgiFoAQhAKABjm'
      'A+kez2XhAAAAAElFTkSuQmCC');

  Future<Uint8List> build({required int dayCount, Uint8List? voyageMap}) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('sk'));
    return PdfExportService.buildCharterPdfBytes(
      dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
      charter: charter(),
      days: days(dayCount),
      entriesByDay: const {},
      mapScreenshots: const {},
      voyageMapScreenshot: voyageMap,
      l10n: l10n,
    );
  }

  test('a short voyage puts the map on the title page', () async {
    final withMap = await build(dayCount: 2, voyageMap: mapPng);
    final without = await build(dayCount: 2);
    // The map is in the document: the only difference between the two runs.
    expect(withMap.length, greaterThan(without.length));
  });

  test('a voyage whose day list fills the page still carries the map',
      () async {
    // Twenty-one days of table is more than one A4 holds alongside the
    // header, the vessel and crew boxes and a 260pt map. The export must
    // neither throw nor drop the map: the page count grows instead.
    final withMap = await build(dayCount: 21, voyageMap: mapPng);
    final without = await build(dayCount: 21);
    expect(withMap.length, greaterThan(without.length));
  });

  test('the map never overflows the page, at any length of voyage', () async {
    for (final count in [1, 5, 12, 21, 40]) {
      await expectLater(
        build(dayCount: count, voyageMap: mapPng),
        completes,
        reason: 'a $count-day voyage must still export',
      );
    }
  });
}
