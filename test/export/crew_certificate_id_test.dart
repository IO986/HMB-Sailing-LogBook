import 'dart:convert';
import 'dart:io' show zlib;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/crew_member_ref.dart';
import 'package:hmb_sailing_log/core/models/skipper_profile.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';
import 'package:hmb_sailing_log/core/utils/localized_date.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/features/miles/services/voyage_miles_summary.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Potvrdenie o naplávaných míľach má riadok „Číslo pasu / OP", ale zadať sa
/// nedalo nikde — skiper ho nahlásil z terénu. Číslo posádky sa zadáva až pri
/// vystavovaní a neukladá sa; svoje má držiteľ telefónu v profile.
void main() {
  setUpAll(() async => initializeDateFormatting());
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime.utc(2026, 5, 2, 8);

  Charter charter() => Charter(
        id: 7,
        title: 'Kornati 2026',
        dateFrom: start,
        dateTo: start.add(const Duration(days: 5)),
        vesselName: 'Bavaria 46',
        skipperName: 'Vladimír Plodek',
        tidalWaters: false,
        safetyBriefingDone: true,
        checkInDone: true,
        checkOutDone: true,
        createdAt: start,
        pdfRevision: 0,
        source: 'live',
      );

  const summary = VoyageMilesSummary(
    daysAtSea: 5,
    dayNm: 120,
    nightNm: 30,
    nightHours: 6,
    area: 'Jadran',
    dateFrom: null,
    dateTo: null,
    routeStops: ['Biograd', 'Žut', 'Biograd'],
  );

  Future<Uint8List> certificate({String? idNumber}) async =>
      PdfExportService.buildCrewMilesCertificate(
        l: await AppLocalizations.delegate.load(const Locale('sk')),
        charter: charter(),
        crew: const CrewMemberRef(name: 'Martin Plodek', role: 'crew'),
        summary: summary,
        idNumber: idNumber,
        dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
      );

  /// Text dokumentu cez ToUnicode CMap — písmo je subset s vlastným kódovaním.
  String pdfText(Uint8List bytes) {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final map = <int, String>{};
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
    for (final m in RegExp(r'(\d+) 0 obj\n(.*?)\nendobj', dotAll: true)
        .allMatches(raw)) {
      final body = m.group(2)!;
      if (!body.contains('stream')) continue;
      final from = body.indexOf('stream') + 'stream'.length + 1;
      final to = body.lastIndexOf('endstream');
      if (from <= 0 || to <= from) continue;
      String content;
      try {
        content = latin1.decode(
            zlib.decode(latin1.encode(body.substring(from, to))),
            allowInvalid: true);
      } catch (_) {
        continue;
      }
      for (final t in RegExp(r'\[<([0-9A-Fa-f]+)>\]TJ').allMatches(content)) {
        final hex = t.group(1)!;
        for (var i = 0; i + 4 <= hex.length; i += 4) {
          out.write(map[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '?');
        }
        out.write(' ');
      }
    }
    return out.toString();
  }

  test('zadané číslo dokladu je na potvrdení vytlačené', () async {
    final text = pdfText(await certificate(idNumber: 'AB1234567'));
    expect(text, contains('AB1234567'));
  });

  test('bez čísla sa potvrdenie vyrobí a číslo tam nie je', () async {
    final bytes = await certificate();
    // Dokument vznikne aj bez čísla — na riadku ostane linka na dopísanie
    // rukou, presne ako doteraz.
    expect(bytes, isNotEmpty);
    expect(pdfText(bytes), isNot(contains('AB1234567')));
  });

  test('číslo mení odtlačok dokumentu, nedá sa dopísať dodatočne', () async {
    String hashOf(String text) {
      final m = RegExp(r'\b[0-9a-f]{32}\b').firstMatch(text);
      return m?.group(0) ?? '';
    }

    final withId = hashOf(pdfText(await certificate(idNumber: 'AB1234567')));
    final without = hashOf(pdfText(await certificate()));
    expect(withId, isNotEmpty);
    expect(withId, isNot(without));
  });

  test('profil skipera si číslo pamätá cez uloženie a načítanie', () {
    const profile = SkipperProfile(fullName: 'Vladimír Plodek', idNumber: 'ID99');
    final restored = SkipperProfile.fromJson(profile.toJson());
    expect(restored.idNumber, 'ID99');
    expect(const SkipperProfile().idNumber, '');
  });
}
