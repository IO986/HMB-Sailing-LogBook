import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// PDF pre zamerania zapísané mimo plavby — bez charteru, bez dňa, len
/// dátum a riadky. Musí vzniknúť súbor rovnako spoľahlivo ako pri
/// bežnom dennom exporte.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final date = DateTime(2026, 8, 20);

  Bearing resection({
    int id = 1,
    String markName = 'Maják Stončica',
    double magnetic = 90,
    int minute = 0,
  }) =>
      Bearing(
        hiddenFromMap: false,
        id: id,
        kind: BearingKind.resection.code,
        magneticBearing: magnetic,
        declination: 4.2,
        declinationSource: 'target',
        trueBearing: (magnetic + 4.2) % 360,
        uncertaintyDeg: 8,
        targetWaypointId: 5,
        targetLat: 43.06,
        targetLon: 16.25,
        targetName: markName,
        takenAt: date.add(Duration(hours: 10, minutes: minute)),
      );

  Bearing intersection({
    int id = 10,
    String groupId = 'g1',
    String label = 'neznáma skala',
    double magnetic = 90,
    int minute = 0,
  }) =>
      Bearing(
        hiddenFromMap: false,
        id: id,
        kind: BearingKind.intersection.code,
        observerLat: 43.5081,
        observerLon: 16.4402,
        magneticBearing: magnetic,
        declination: 4.2,
        declinationSource: 'gps',
        trueBearing: (magnetic + 4.2) % 360,
        uncertaintyDeg: 8,
        sightGroupId: groupId,
        label: label,
        takenAt: date.add(Duration(hours: 10, minutes: minute)),
      );

  Future<AppLocalizations> l10n(String code) =>
      AppLocalizations.delegate.load(Locale(code));

  test('relácia len s resekciou vyrobí PDF', () async {
    final bytes = await PdfExportService.buildBearingSessionPdfBytes(
      date: date,
      bearings: [
        resection(id: 1, markName: 'Maják Stončica'),
        resection(id: 2, markName: 'Mys Rt Stupišće', magnetic: 300, minute: 4),
      ],
      l: await l10n('sk'),
    );
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('relácia len s hľadaním objektu vyrobí PDF', () async {
    final bytes = await PdfExportService.buildBearingSessionPdfBytes(
      date: date,
      bearings: [
        intersection(id: 10, minute: 0),
        intersection(id: 11, minute: 40, magnetic: 120),
      ],
      l: await l10n('sk'),
    );
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('relácia s oboma režimami je väčšia než každý zvlášť', () async {
    Future<int> len(List<Bearing> bearings) async =>
        (await PdfExportService.buildBearingSessionPdfBytes(
                date: date, bearings: bearings, l: await l10n('sk')))
            .length;

    final onlyResection = await len([resection()]);
    final both = await len([resection(), intersection()]);
    expect(both, greaterThan(onlyResection));
  });

  test('mapová snímka sa vloží, keď je k dispozícii', () async {
    // Najmenší platný 1x1 PNG — pdf balík obrázok naozaj dekóduje, takže
    // vymyslené bajty by tu spadli.
    const onePixelPng =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42'
        'YAAAAASUVORK5CYII=';
    final withoutMap = await PdfExportService.buildBearingSessionPdfBytes(
        date: date, bearings: [resection()], l: await l10n('sk'));
    final withMap = await PdfExportService.buildBearingSessionPdfBytes(
      date: date,
      bearings: [resection()],
      l: await l10n('sk'),
      mapScreenshot: base64Decode(onePixelPng),
    );
    expect(withMap.length, greaterThan(withoutMap.length));
  });

  test('jediné zameranie bez fixu export nezhodí', () async {
    final bytes = await PdfExportService.buildBearingSessionPdfBytes(
      date: date,
      bearings: [resection()],
      l: await l10n('sk'),
    );
    expect(bytes.length, greaterThan(500));
  });

  test('deklinácia z cieľa sa poznamená', () async {
    final bytes = await PdfExportService.buildBearingSessionPdfBytes(
      date: date,
      bearings: [resection(), resection(id: 2, magnetic: 300, minute: 3)],
      l: await l10n('sk'),
    );
    expect(bytes.length, greaterThan(500));
  });

  test('každý jazyk vykreslí reláciu s oboma režimami', () async {
    for (final code in [
      'sk', 'en', 'de', 'es', 'uk', 'cs', 'pl', 'el', 'hr', 'sl', 'it'
    ]) {
      final bytes = await PdfExportService.buildBearingSessionPdfBytes(
        date: date,
        bearings: [resection(), intersection()],
        l: await l10n(code),
      );
      expect(String.fromCharCodes(bytes.take(4)), '%PDF', reason: code);
    }
  });
}
