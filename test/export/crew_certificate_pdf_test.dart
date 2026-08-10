import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/crew_member_ref.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/features/miles/services/voyage_miles_summary.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// The certificate is generated on a phone, in the skipper's language, for a
/// crew member who may have no ratings at all. Every one of those paths has to
/// produce a file rather than throw during the export.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime(2026, 7, 15);

  Charter charter() => Charter(
        id: 7,
        title: 'Stredná Dalmácia 2026',
        dateFrom: start,
        dateTo: start.add(const Duration(days: 7)),
        vesselName: 'Bavaria 46',
        skipperName: 'Ján Novák',
        cruisingArea: 'Stredná Dalmácia',
        captainQualification: 'RYA Yachtmaster',
        safetyBriefingDone: true,
        checkInDone: true,
        checkOutDone: true,
        createdAt: start,
        pdfRevision: 0,
        source: 'live',
      );

  const summary = VoyageMilesSummary(
    daysAtSea: 7,
    dayNm: 128.4,
    nightNm: 41.6,
    nightHours: 8.25,
    area: 'Stredná Dalmácia',
    dateFrom: null,
    dateTo: null,
  );

  CrewAssessment assessment() => CrewAssessment(
        id: 1,
        charterId: 7,
        crewName: 'Eva Malá',
        helming: 4,
        navigation: 3,
        harbourManoeuvres: null,
        teamwork: 5,
        nightSailing: 2,
        note: 'Samostatná pri kormidle, na noc si vypýtala dvojicu.',
        updatedAt: start,
      );

  const crew = CrewMemberRef(
    name: 'Eva Malá',
    role: 'crew',
    boatLicence: 'VMP C',
    radioLicence: 'SRC',
  );

  Future<AppLocalizations> l10n(String code) =>
      AppLocalizations.delegate.load(Locale(code));

  test('produces a PDF for a rated crew member', () async {
    final bytes = await PdfExportService.buildCrewMilesCertificate(
      l: await l10n('sk'),
      charter: charter(),
      crew: crew,
      summary: summary,
      assessment: assessment(),
    );

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('an unrated crew member still gets a certificate', () async {
    // Skipping the ratings is allowed - the miles are the point of the paper.
    final bytes = await PdfExportService.buildCrewMilesCertificate(
      l: await l10n('sk'),
      charter: charter(),
      crew: const CrewMemberRef(name: 'Peter Bez Licencie', role: 'crew'),
      summary: summary,
    );

    expect(bytes.length, greaterThan(1000));
  });

  test('every UI language renders', () async {
    // Greek and Ukrainian need the bundled font; Helvetica cannot draw them.
    for (final code in ['sk', 'en', 'de', 'es', 'uk', 'cs', 'pl', 'el', 'hr',
      'sl', 'it']) {
      final bytes = await PdfExportService.buildCrewMilesCertificate(
        l: await l10n(code),
        charter: charter(),
        crew: crew,
        summary: summary,
        assessment: assessment(),
      );
      expect(bytes.length, greaterThan(1000), reason: code);
    }
  });

  test('a voyage with no miles at all does not break the layout', () async {
    final bytes = await PdfExportService.buildCrewMilesCertificate(
      l: await l10n('en'),
      charter: charter(),
      crew: crew,
      summary: VoyageMilesSummary.empty,
    );

    expect(bytes.length, greaterThan(1000));
  });
}
