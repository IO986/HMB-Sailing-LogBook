import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Zamerania idú do PDF ako samostatná strana denného záznamu. Export sa robí
/// na telefóne, v jazyku skipera a často bez signálu — každá z tých ciest musí
/// vyrobiť súbor, nie vyhodiť výnimku.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime(2026, 8, 18);

  Charter charter() => Charter(
        id: 3,
        title: 'Stredná Dalmácia 2026',
        dateFrom: start,
        dateTo: start.add(const Duration(days: 6)),
        vesselName: 'Bavaria 46',
        skipperName: 'Ján Novák',
        tidalWaters: false,
        safetyBriefingDone: true,
        checkInDone: true,
        checkOutDone: true,
        createdAt: start,
        pdfRevision: 0,
        source: 'live',
      );

  DayLog day() => DayLog(
        id: 11,
        charterId: 3,
        date: start,
        portFrom: 'Split',
        portTo: 'Vis',
        distanceNm: 32.4,
        isComplete: false,
      );

  /// Námer na neznámy objekt zo známej polohy.
  Bearing bearing({
    int id = 1,
    String? label,
    double magnetic = 90,
    double declination = 4.2,
    int minute = 0,
  }) =>
      Bearing(
        hiddenFromMap: false,
        id: id,
        kind: BearingKind.intersection.code,
        observerLat: 43.5081,
        observerLon: 16.4402,
        magneticBearing: magnetic,
        declination: declination,
        declinationSource: 'gps',
        trueBearing: (magnetic + declination) % 360,
        uncertaintyDeg: 8,
        sightGroupId: 'skupina-1',
        label: label,
        takenAt: start.add(Duration(hours: 10, minutes: minute)),
        dayLogId: 11,
        charterId: 3,
      );

  /// Námer na známy bod bez GPS — poloha pozorovateľa je práve to hľadané.
  Bearing resection({
    int id = 100,
    String markName = 'Maják Stončica',
    double magnetic = 215,
    double declination = 4.2,
    int minute = 0,
  }) =>
      Bearing(
        hiddenFromMap: false,
        id: id,
        kind: BearingKind.resection.code,
        magneticBearing: magnetic,
        declination: declination,
        declinationSource: 'target',
        trueBearing: (magnetic + declination) % 360,
        uncertaintyDeg: 8,
        targetWaypointId: 5,
        targetLat: 43.06,
        targetLon: 16.25,
        targetName: markName,
        takenAt: start.add(Duration(hours: 10, minutes: minute)),
        dayLogId: 11,
        charterId: 3,
      );

  Future<AppLocalizations> l10n(String code) =>
      AppLocalizations.delegate.load(Locale(code));

  Future<int> dayPdfLength(List<Bearing> bearings, {String code = 'sk'}) async {
    final bytes = await PdfExportService.buildDayPdfBytes(
      charter: charter(),
      day: day(),
      entries: const [],
      l10n: await l10n(code),
      bearings: bearings,
    );
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    return bytes.length;
  }

  test('deň so zameraniami dá väčšie PDF než deň bez nich', () async {
    final without = await dayPdfLength(const []);
    final with_ = await dayPdfLength([
      bearing(id: 1, label: 'Maják Stončica'),
      bearing(id: 2, label: 'Mys Rt Stupišće', magnetic: 215, minute: 4),
    ]);
    expect(with_, greaterThan(without));
  });

  test('zameranie bez popisu export nezhodí', () async {
    expect(await dayPdfLength([bearing()]), greaterThan(1000));
  });

  test('západná deklinácia sa v tabuľke vykreslí', () async {
    expect(
        await dayPdfLength(
            [bearing(declination: -6.5, label: 'Škoj', magnetic: 3)]),
        greaterThan(1000));
  });

  test('viac zameraní než sa zmestí na stranu sa rozdelí', () async {
    final many = [
      for (var i = 0; i < 40; i++)
        bearing(id: i + 1, label: 'Bod $i', magnetic: (i * 9) % 360, minute: i),
    ];
    // Rozdelenie na dve strany nesmie skončiť výnimkou ani prázdnym súborom.
    expect(await dayPdfLength(many), greaterThan(2000));
  });

  test('každý jazyk rozhrania sa vykreslí', () async {
    // Gréčtina a ukrajinčina potrebujú pribalený font, Helvetica ich nenakreslí.
    for (final code in [
      'sk', 'en', 'de', 'es', 'uk', 'cs', 'pl', 'el', 'hr', 'sl', 'it'
    ]) {
      expect(
          await dayPdfLength([bearing(label: 'Maják')], code: code),
          greaterThan(1000),
          reason: code);
    }
  });

  test('resekcia bez GPS polohy export nezhodí', () async {
    // Riadok bez polohy pozorovateľa je pri resekcii normálny stav, nie
    // chýbajúci údaj — PDF ho musí zvládnuť vypísať.
    expect(await dayPdfLength([resection()]), greaterThan(1000));
  });

  test('deň s oboma režimami vypíše obe sekcie', () async {
    final both = await dayPdfLength([
      resection(id: 1, markName: 'Maják Stončica'),
      resection(id: 2, markName: 'Mys Rt Stupišće', magnetic: 300, minute: 2),
      bearing(id: 3, label: 'neznáma skala', minute: 5),
      bearing(id: 4, label: 'neznáma skala', magnetic: 120, minute: 40),
    ]);
    final onlyObjects = await dayPdfLength([
      bearing(id: 3, label: 'neznáma skala', minute: 5),
      bearing(id: 4, label: 'neznáma skala', magnetic: 120, minute: 40),
    ]);
    expect(both, greaterThan(onlyObjects));
  });

  test('každý jazyk vykreslí aj resekciu', () async {
    for (final code in [
      'sk', 'en', 'de', 'es', 'uk', 'cs', 'pl', 'el', 'hr', 'sl', 'it'
    ]) {
      expect(await dayPdfLength([resection()], code: code),
          greaterThan(1000),
          reason: code);
    }
  });

  test('celá plavba prevezme zamerania po dňoch', () async {
    final bytes = await PdfExportService.buildCharterPdfBytes(
      charter: charter(),
      days: [day()],
      entriesByDay: const {11: []},
      mapScreenshots: const {},
      l10n: await l10n('sk'),
      bearingsByDay: {
        11: [bearing(label: 'Maják Stončica')],
      },
    );
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');

    final withoutBearings = await PdfExportService.buildCharterPdfBytes(
      charter: charter(),
      days: [day()],
      entriesByDay: const {11: []},
      mapScreenshots: const {},
      l10n: await l10n('sk'),
    );
    expect(bytes.length, greaterThan(withoutBearings.length));
  });
}
