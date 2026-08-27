import 'dart:convert';
import 'dart:io' show zlib;
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
/// z 23.–27. 8. 2026 ostalo 13 prázdnych strán z 25. Tento test drží dve
/// pravidlá: každá strana denného exportu musí niesť obsah a na každej
/// strane pokračovania musí stáť hlavička tabuľky.
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

  /// Obsahové streamy jednotlivých strán, rozbalené.
  List<String> pageContents(Uint8List bytes) {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final objects = <int, String>{};
    for (final m in RegExp(r'(\d+) 0 obj\n(.*?)\nendobj', dotAll: true)
        .allMatches(raw)) {
      objects[int.parse(m.group(1)!)] = m.group(2)!;
    }
    final kids =
        RegExp(r'/Kids\[(.*?)\]', dotAll: true).firstMatch(raw)!.group(1)!;
    final out = <String>[];
    for (final m in RegExp(r'(\d+) 0 R').allMatches(kids)) {
      final page = objects[int.parse(m.group(1)!)]!;
      final contents = RegExp(r'/Contents (\d+) 0 R').firstMatch(page);
      if (contents == null) {
        out.add('');
        continue;
      }
      final stream = objects[int.parse(contents.group(1)!)]!;
      final from = stream.indexOf('stream') + 'stream'.length + 1;
      final to = stream.lastIndexOf('endstream');
      final data = latin1.encode(stream.substring(from, to));
      out.add(latin1.decode(zlib.decode(data), allowInvalid: true));
    }
    return out;
  }

  /// Čitateľný text strany. Písmo je subset s vlastným kódovaním, takže sa
  /// glyfy prekladajú cez ToUnicode CMap dokumentu — inak sa v obsahu nedá
  /// hľadať slovo, len hexadecimálne behy.
  String pageText(Uint8List bytes, String content) {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final map = <int, String>{};
    for (final m in RegExp(r'beginbfchar(.*?)endbfchar', dotAll: true)
        .allMatches(raw)) {
      for (final c
          in RegExp(r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>').allMatches(m.group(1)!)) {
        map[int.parse(c.group(1)!, radix: 16)] =
            String.fromCharCode(int.parse(c.group(2)!, radix: 16));
      }
    }
    // Mapy sú v dokumente komprimované, takže hľadanie v surových bajtoch
    // nič nenájde — treba rozbaliť streamy, na ktoré ukazuje /ToUnicode
    // pri jednotlivých písmach.
    for (final ref in RegExp(r'/ToUnicode (\d+) 0 R').allMatches(raw)) {
      final obj = RegExp('${ref.group(1)} 0 obj(.*?)endobj', dotAll: true)
          .firstMatch(raw);
      if (obj == null) continue;
      final body = obj.group(1)!;
      final from = body.indexOf('stream') + 'stream'.length + 1;
      final to = body.lastIndexOf('endstream');
      if (from <= 0 || to <= from) continue;
      String text;
      try {
        text = latin1.decode(
            zlib.decode(latin1.encode(body.substring(from, to))),
            allowInvalid: true);
      } catch (_) {
        continue;
      }
      for (final b in RegExp(r'beginbfchar(.*?)endbfchar', dotAll: true)
          .allMatches(text)) {
        for (final c in RegExp(r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')
            .allMatches(b.group(1)!)) {
          map[int.parse(c.group(1)!, radix: 16)] =
              String.fromCharCode(int.parse(c.group(2)!, radix: 16));
        }
      }
    }

    final out = StringBuffer();
    for (final m in RegExp(r'\[<([0-9A-Fa-f]+)>\]TJ').allMatches(content)) {
      final hex = m.group(1)!;
      for (var i = 0; i + 4 <= hex.length; i += 4) {
        out.write(map[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '?');
      }
      out.write(' ');
    }
    return out.toString();
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
    final pages = pageContents(await dayPdf(150));

    expect(pages.length, greaterThan(1),
        reason: 'tabuľka sa musí rozliať na viac strán');
    for (var i = 0; i < pages.length; i++) {
      // Prázdna strana (len nadpis) mala v chybnom exporte ~560 bajtov
      // skomprimovaného obsahu.
      expect(pages[i].length, greaterThan(2000),
          reason: 'strana ${i + 1} z ${pages.length} je prázdna '
              '(${pages[i].length} B obsahu)');
    }
  });

  test('hlavička tabuľky stojí na každej strane pokračovania', () async {
    final bytes = await dayPdf(150);
    final pages = pageContents(bytes);
    expect(pages.length, greaterThan(2));

    for (var i = 0; i < pages.length; i++) {
      final text = pageText(bytes, pages[i]);
      // COG a hPa sú v hlavičke rovnaké vo všetkých jazykoch, takže sa na ne
      // dá spoľahnúť bez ohľadu na locale exportu.
      expect(text, contains('COG'),
          reason: 'strane ${i + 1} z ${pages.length} chýba hlavička tabuľky');
      expect(text, contains('hPa'),
          reason: 'strane ${i + 1} z ${pages.length} chýba hlavička tabuľky');
    }
  });

  test('deň s pár záznamami ostane na jednej strane', () async {
    expect(pageContents(await dayPdf(6)).length, 1);
  });
}
