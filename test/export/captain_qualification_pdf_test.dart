import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/skipper_profile.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';
import 'package:hmb_sailing_log/core/utils/localized_date.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

/// The captain's highest qualification is printed in the "skipper licences"
/// box of the logbook header. The PDF streams are compressed, so the text
/// itself cannot be read back here; the document growing is the observable
/// difference, as in the map tests next to this one.
void main() {
  setUpAll(() async => initializeDateFormatting());
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime(2026, 7, 10);

  Charter charter({String? crewJson, String? recorded}) => Charter(
        id: 1,
        title: 'Plavba júl 2026',
        dateFrom: start,
        dateTo: start.add(const Duration(days: 3)),
        skipperName: 'Ján Novák',
        crewNames: 'Peter Kováč',
        safetyBriefingDone: true,
        checkInDone: true,
        checkOutDone: false,
        archived: false,
        createdAt: start,
        pdfRevision: 0,
        source: 'live',
      ).copyWith(
        crewJson: Value(crewJson),
        captainQualification: Value(recorded),
      );

  final skipperWith = jsonEncode([
    {
      'name': 'Ján Novák',
      'role': 'skipper',
      'qualification': 'RYA Yachtmaster Offshore with a long name',
    },
  ]);
  final skipperWithout = jsonEncode([
    {'name': 'Ján Novák', 'role': 'skipper'},
  ]);

  Future<Uint8List> build(Charter c, {SkipperProfile? profile}) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('sk'));
    return PdfExportService.buildCharterPdfBytes(
      dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
      charter: c,
      days: const [],
      entriesByDay: const {},
      mapScreenshots: const {},
      skipperProfile: profile,
      l10n: l10n,
    );
  }

  test('a qualification on the skipper card is printed', () async {
    final with_ = await build(charter(crewJson: skipperWith));
    final without = await build(charter(crewJson: skipperWithout));
    expect(with_.length, greaterThan(without.length));
  });

  test('the one from the mile book record is printed too', () async {
    final with_ = await build(
        charter(crewJson: skipperWithout, recorded: 'Kapitán jachty'));
    final without = await build(charter(crewJson: skipperWithout));
    expect(with_.length, greaterThan(without.length));
  });

  test("the phone owner's remembered one is the fallback", () async {
    final with_ = await build(charter(crewJson: skipperWithout),
        profile: const SkipperProfile(licenseType: 'Kapitán jachty'));
    final without = await build(charter(crewJson: skipperWithout));
    expect(with_.length, greaterThan(without.length));
  });

  test('a voyage with no qualification anywhere still exports', () async {
    await expectLater(build(charter(crewJson: skipperWithout)), completes);
    await expectLater(build(charter()), completes);
  });
}
