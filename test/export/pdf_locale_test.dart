import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/logbook_event_type.dart';
import 'package:hmb_sailing_log/features/export/services/pdf_export_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/core/utils/localized_date.dart';
import 'package:hmb_sailing_log/core/services/units_service.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Exercises PDF generation end to end for the localised path.
///
/// Nothing else in the suite builds a PDF, so a null l10n lookup, a missing
/// duty clip or a font that cannot draw the text would only surface on a phone
/// during an export — which is exactly when it matters.
void main() {
  // Rovnako ako main() v aplikácii: bez toho DateFormat s konkrétnym jazykom
  // vyhodí LocaleDataException.
  setUpAll(() async => initializeDateFormatting());

  TestWidgetsFlutterBinding.ensureInitialized();

  final day = DateTime(2026, 7, 10);

  Charter charter() => Charter(
        id: 1,
        title: 'Plavba máj 2026',
        dateFrom: day,
        dateTo: day.add(const Duration(days: 3)),
        skipperName: 'Ján Novák',
        safetyBriefingDone: true,
        checkInDone: true,
        checkOutDone: false,
        createdAt: day,
        pdfRevision: 0,
        source: 'live',
      );

  DayLog dayLog() => DayLog(
        id: 10,
        charterId: 1,
        date: day,
        distanceNm: 24.5,
        isComplete: false,
      );

  LogbookEntry entry(String? note, String? eventType, int hour) => LogbookEntry(
        id: hour,
        dayLogId: 10,
        timestamp: DateTime.utc(2026, 7, 10, hour),
        latitude: 43.5,
        longitude: 16.4,
        isAutoEntry: eventType != null,
        skipperNote: note,
        eventType: eventType,
      );

  DutyPeriod duty(String name, int fromHour, int? toHour) => DutyPeriod(
        id: fromHour,
        charterId: 1,
        crewName: name,
        role: 'crew',
        fromUtc: DateTime.utc(2026, 7, 10, fromHour),
        toUtc: toHour == null ? null : DateTime.utc(2026, 7, 10, toHour),
        isAutoClosed: false,
        createdAt: day,
      );

  Future<int> buildLength(Locale locale) async {
    final l10n = await AppLocalizations.delegate.load(locale);
    final bytes = await PdfExportService.buildDayPdfBytes(
      dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
      charter: charter(),
      day: dayLog(),
      l10n: l10n,
      entries: [
        entry('Anchor dropped', LogbookEventType.anchorDropped.code, 8),
        entry('Duty start: Ján Novák', LogbookEventType.dutyStart.code, 9),
        // A pre-v21 row: no eventType, recognised from the note alone.
        entry('Voyage start', null, 7),
        entry('Pekné počasie, delfíny', null, 12),
      ],
      duties: [
        duty('Ján Novák', 9, 13),
        duty('Peter Kováč', 9, null), // still running
      ],
    );
    return bytes.length;
  }

  /// The charter PDF exercises the title page, the summary page and the
  /// safety-briefing page — none of which the day PDF touches.
  Future<int> buildCharterLength(Locale locale) async {
    final l10n = await AppLocalizations.delegate.load(locale);
    final bytes = await PdfExportService.buildCharterPdfBytes(
      dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
      charter: charter(),
      days: [dayLog()],
      entriesByDay: {
        10: [
          entry('Anchor dropped', LogbookEventType.anchorDropped.code, 8),
          entry('Duty start: Ján Novák', LogbookEventType.dutyStart.code, 9),
        ]
      },
      mapScreenshots: const {},
      l10n: l10n,
      dutiesByDay: {
        10: [duty('Ján Novák', 9, 13), duty('Peter Kováč', 22, null)]
      },
      crewSignatures: [
        CrewSignature(
            id: 1, charterId: 1, crewName: 'Ján Novák', role: 'skipper'),
        CrewSignature(id: 2, charterId: 1, crewName: 'Peter Kováč', role: 'crew'),
      ],
    );
    return bytes.length;
  }

  test('builds a charter PDF in every supported locale', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      expect(await buildCharterLength(locale), greaterThan(1000),
          reason: 'charter export failed for ${locale.languageCode}');
    }
  });

  test('builds a day PDF in Slovak', () async {
    expect(await buildLength(const Locale('sk')), greaterThan(1000));
  });

  /// The propulsion column used to print `Hlavná+` for `Hlavná+Genova` and
  /// `Bočný` for `Bočný S`, because both cells clipped at one line in a 34 pt
  /// column — the side the boat was sailing on vanished from the document.
  ///
  /// A unit test cannot read glyphs off a page, so this asserts the next best
  /// thing: the row that carries the full propulsion, the point of sail and a
  /// long note must produce a MEASURABLY larger document than the same row
  /// without them. Text that never reaches the page adds no bytes.
  test('a full propulsion, point of sail and a long note reach the page',
      () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('sk'));

    Future<int> lengthWith(LogbookEntry e) async {
      final bytes = await PdfExportService.buildDayPdfBytes(
        dateFormat: const AppDate.raw('sk', DateStyle.appLanguage),
        charter: charter(),
        day: dayLog(),
        l10n: l10n,
        entries: [e],
      );
      return bytes.length;
    }

    final bare = entry(null, null, 11);
    final rich = bare.copyWith(
      sailMode: const Value('main,genoa'),
      pointOfSail: const Value('beam_reach'),
      tack: const Value('S'),
      skipperNote: const Value(
          'Vietor sa stočil na severozápad a zosilnel, refovali sme hlavnú '
          'a stiahli genovu na polovicu; posádka v záveternej kajute, '
          'kurz sme držali na Šoltu.'),
    );

    expect(await lengthWith(rich), greaterThan(await lengthWith(bare)),
        reason: 'the propulsion, the tack or the note never made it onto the '
            'page');
  });

  test('builds a day PDF in Ukrainian — Cyrillic must not break rendering',
      () async {
    expect(await buildLength(const Locale('uk')), greaterThan(1000));
  });

  test('builds a day PDF in every supported locale', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      expect(await buildLength(locale), greaterThan(1000),
          reason: 'export failed for ${locale.languageCode}');
    }
  });
}
