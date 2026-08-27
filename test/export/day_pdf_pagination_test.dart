import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';
import 'package:hmb_sailing_log/core/utils/localized_date.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Denný export sa krájal na strany po pevnom počte riadkov (18 + po 30).
/// Keď sa taký blok na A4 nezmestil, `pw.Column` so `Spacer()` dostal zápornú
/// voľnú výšku a tabuľka ani pätička sa nevykreslili — v exporte plavby
/// z 23.–27. 8. 2026 ostalo 13 prázdnych strán z 25. Tento test drží
/// pravidlo: každá strana denného exportu musí niesť obsah.
void main() {
  setUpAll(() async => initializeDateFormatting());
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime.utc(2026, 8, 24, 6);

  Charter charter() => Charter(
        id: 1,
        title: 'Chingi Lingi 2026',
        dateFrom: start,
        dateTo: start.add(const Duration(days: 5)),
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
        id: 4,
        charterId: 1,
        date: start,
        portFrom: 'Biograd na Moru',
        portTo: 'Primošten',
        distanceNm: 24.4,
        isComplete: true,
      );

  /// Automatický záznam s dlhou poznámkou — presne ten prípad, ktorý pevné
  /// krájanie prehral: riadky sú vyššie, než sa čakalo.
  LogbookEntry entry(int i) => LogbookEntry(
        id: i,
        dayLogId: 4,
        timestamp: start.add(Duration(minutes: 5 * i)),
        latitude: 43.6 + i * 0.001,
        longitude: 15.9 - i * 0.001,
        sog: 5.4,
        cog: 312,
        windSpeed: 12,
        windDirection: 270,
        waveHeight: 0.5,
        airPressure: 1015,
        airTemp: 27,
        waterTemp: 24,
        depthMeters: 18.5,
        isAutoEntry: true,
        sailMode: 'motor,main,genoa',
        pointOfSail: 'beam_reach',
        tack: 'S',
        weatherSource: 'nmea',
        skipperNote: 'Záznam číslo $i — dlhšia poznámka skipera, ktorá zaberie '
            'v bunke niekoľko riadkov a tým zvýši celý riadok tabuľky.',
      );

  /// Dĺžky obsahových streamov jednotlivých strán. Prázdna strana (len
  /// nadpis) mala v chybnom exporte ~560 bajtov.
  List<int> pageContentSizes(Uint8List bytes) {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final objects = <int, String>{};
    for (final m in RegExp(r'(\d+) 0 obj\n(.*?)\nendobj', dotAll: true)
        .allMatches(raw)) {
      objects[int.parse(m.group(1)!)] = m.group(2)!;
    }
    final kids = RegExp(r'/Kids\[(.*?)\]', dotAll: true).firstMatch(raw)!.group(1)!;
    final sizes = <int>[];
    for (final m in RegExp(r'(\d+) 0 R').allMatches(kids)) {
      final page = objects[int.parse(m.group(1)!)]!;
      final contents = RegExp(r'/Contents (\d+) 0 R').firstMatch(page);
      if (contents == null) {
        sizes.add(0);
        continue;
      }
      final stream = objects[int.parse(contents.group(1)!)]!;
      final from = stream.indexOf('stream\n') + 7;
      final to = stream.lastIndexOf('endstream');
      final data = latin1.encode(stream.substring(from, to));
      // Nezaujíma nás text, len či strana vôbec niečo nesie: porovnávame
      // veľkosť skomprimovaného streamu, dekompresia tu nie je potrebná.
      sizes.add(data.length);
    }
    return sizes;
  }

  Future<Uint8List> dayPdf(int entryCount) async {
    return PdfExportService.buildDayPdfBytes(
      dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
      charter: charter(),
      day: day(),
      entries: [for (var i = 1; i <= entryCount; i++) entry(i)],
      l10n: await AppLocalizations.delegate.load(const Locale('sk')),
    );
  }

  test('deň so 150 záznamami nemá ani jednu prázdnu stranu', () async {
    final bytes = await dayPdf(150);
    final sizes = pageContentSizes(bytes);

    expect(sizes.length, greaterThan(1),
        reason: 'tabuľka sa musí rozliať na viac strán');
    for (var i = 0; i < sizes.length; i++) {
      expect(sizes[i], greaterThan(700),
          reason: 'strana ${i + 1} z ${sizes.length} je prázdna '
              '(${sizes[i]} B obsahu)');
    }
  });

  test('deň s pár záznamami ostane na jednej strane', () async {
    expect(pageContentSizes(await dayPdf(6)).length, 1);
  });
}
