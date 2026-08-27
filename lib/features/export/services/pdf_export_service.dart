import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' show Locale;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/database/app_database.dart';
import '../../../core/models/bearing_kind.dart';
import '../../../core/models/logbook_event_type.dart';
import '../../../core/models/sail_mode.dart';
import '../../../core/models/point_of_sail.dart';
import '../../../shared/utils/sail_direction_labels.dart';
import '../../../shared/utils/auto_entry_note.dart';
import '../../bearing/providers/bearing_provider.dart'
    show bearingLineOf, knownPointOf, latestResectionCluster, sightGroupsFrom;
import '../../bearing/services/bearing_geometry.dart';
import '../../miles/services/voyage_miles_summary.dart';
import '../../../core/models/crew_member_ref.dart';
import '../../../core/services/units_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/skipper_profile.dart';
import '../../../core/services/moon_calculator.dart';
import '../../miles/services/miles_calculator.dart';
import '../../miles/services/solar_calculator.dart';
import '../../charter/services/handover_checklist.dart';
import '../../duty/domain/duty_rules.dart';
import '../../duty/providers/duty_provider.dart' show DutyPeriodRules;
import '../../../core/utils/localized_date.dart';

class PdfExportService {
  /// Formátovač dátumu pre práve stavaný dokument.
  ///
  /// Statické pole, nie parameter každej súkromnej pomôcky: dokument sa stavia
  /// jednorazovo a sekvenčne z jedného volania, a pretiahnuť formátovač cez
  /// pätnásť pomocných metód by pridalo šum bez úžitku. Verejné vstupy ho
  /// VYŽADUJÚ, takže sa nedá zabudnúť nastaviť.
  ///
  /// Netýka sa kanonických reťazcov, z ktorých sa počíta sha256 podpis
  /// dokumentu — tie používajú ISO zápis a voľba používateľa ich nesmie
  /// ovplyvniť, inak by sa už vydané dokumenty nedali overiť.
  static AppDate _date = const AppDate.raw('en', DateStyle.appLanguage);

  /// Bundled Unicode font, loaded once per process.
  ///
  /// The PDF format's built-in Helvetica covers Latin-1 only: no Latin
  /// Extended-A (č š ž ť ď ľ ň ŕ) and no Cyrillic. That is why every string
  /// used to be transliterated before printing, so a crew member named
  /// "Ján Novák" appeared in the charter PDF as "Jan Novak" — wrong in a
  /// document meant to serve as evidence — and why Ukrainian could not be
  /// rendered at all.
  ///
  /// Bundled as an asset rather than fetched through PdfGoogleFonts: the PDF
  /// has to be exportable at sea, with no connection.
  static pw.ThemeData? _themeCache;

  static Future<pw.ThemeData> _theme() async {
    if (_themeCache != null) return _themeCache!;
    final base =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final bold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    return _themeCache = pw.ThemeData.withFont(base: base, bold: bold);
  }

  static final _navy  = PdfColor.fromHex('#0A2342');
  static final _blue  = PdfColor.fromHex('#1A5276');
  static final _lgrey = PdfColor.fromHex('#F2F3F4');
  static final _dgrey = PdfColor.fromHex('#7F8C8D');
  static final _green = PdfColor.fromHex('#1E8449');
  static final _lblue = PdfColor.fromHex('#D6EAF8');

  /// Beaufort stupnica podľa rýchlosti vetra v uzloch.
  static int _beaufortFromKnots(double kts) {
    if (kts < 1) return 0;
    if (kts < 4) return 1;
    if (kts < 7) return 2;
    if (kts < 11) return 3;
    if (kts < 17) return 4;
    if (kts < 22) return 5;
    if (kts < 28) return 6;
    if (kts < 34) return 7;
    if (kts < 41) return 8;
    if (kts < 48) return 9;
    if (kts < 56) return 10;
    if (kts < 64) return 11;
    return 12;
  }

  /// Vypočíta Beaufort pre deň z wind speed záznamu ak nie je manuálne nastavený.
  static int? _beaufortForDay(DayLog day, List<LogbookEntry> entries) {
    if (day.beaufortNoon != null) return day.beaufortNoon;
    final windSpeeds = entries
        .where((e) => e.windSpeed != null)
        .map((e) => e.windSpeed!)
        .toList();
    if (windSpeeds.isEmpty) return null;
    final avg = windSpeeds.reduce((a, b) => a + b) / windSpeeds.length;
    // windSpeed v záznamy je v uzloch (prenáša sa zo SOG / NMEA)
    return _beaufortFromKnots(avg);
  }

  // ── Public builders ───────────────────────────────────────────

  static Future<Uint8List> buildCharterPdfBytes({
    required Charter charter,
    required List<DayLog> days,
    required Map<int, List<LogbookEntry>> entriesByDay,
    required Map<int, Uint8List?> mapScreenshots,
    required AppLocalizations l10n,
    Map<int, List<DutyPeriod>> dutiesByDay = const {},
    Map<int, List<Bearing>> bearingsByDay = const {},
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
    List<CrewSignature> crewSignatures = const [],
    int pdfRevision = 0,
    HandoverProtocol? checkInProtocol,
    List<ChecklistItem>? checkInChecklist,
    HandoverProtocol? checkOutProtocol,
    List<ChecklistItem>? checkOutChecklist,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    final docId  = 'HMBSL-${charter.id}-${charter.dateFrom.year}';
    final rev    = pdfRevision;

    final pdf = pw.Document(
      theme: await _theme(),
      title: _pdfText(charter.title),
      author: _pdfText(charter.skipperName ?? 'HMB Sailing Log'),
      creator: 'HMB Sailing Log',
    );
    final vesselPhotos = await _loadVesselPhotos(charter);
    pdf.addPage(_titlePage(
      l10n,
        charter, days, entriesByDay, skipperProfile, docId, rev, vesselPhotos));
    for (final day in days) {
      final entries = entriesByDay[day.id] ?? [];
      final photos = await _loadPhotos(entries);
      for (final page in _dayPages(charter, day, entries, mapScreenshots[day.id], photos,
          docId, rev, l10n, dutiesByDay[day.id] ?? const [],
          bearingsByDay[day.id] ?? const [])) {
        pdf.addPage(page);
      }
    }
    pdf.addPage(_summaryPage(charter, days, entriesByDay, docId, rev, l10n));
    final sbPage = await _safetyBriefingPage(charter, crewSignatures, docId, rev, l10n);
    pdf.addPage(sbPage);

    if (checkInProtocol != null && checkInChecklist != null) {
      pdf.addPage(await _handoverProtocolPage(
          l: l10n, charter: charter, protocol: checkInProtocol, checklist: checkInChecklist,
          docId: docId, revision: rev));
    }
    if (checkOutProtocol != null && checkOutChecklist != null) {
      pdf.addPage(await _handoverProtocolPage(
          l: l10n, charter: charter, protocol: checkOutProtocol, checklist: checkOutChecklist,
          docId: docId, revision: rev));
    }

    if (signatureImage != null) {
      final canonical = _buildCanonical(
          charter: charter, days: days, entriesByDay: entriesByDay,
          docId: docId, revision: rev);
      final hash = sha256.convert(utf8.encode(canonical)).toString();
      pdf.addPage(_signaturePage(
        l: l10n,
        signatureImage: signatureImage,
        signerName: charter.skipperName,
        signedAt: DateTime.now().toUtc(),
        hash: hash,
        docTitle: charter.title,
        docId: docId,
        revision: rev,
      ));
    }
    return pdf.save();
  }

  static Future<Uint8List> buildDayPdfBytes({
    required Charter charter,
    required DayLog day,
    required List<LogbookEntry> entries,
    required AppLocalizations l10n,
    List<DutyPeriod> duties = const [],
    List<Bearing> bearings = const [],
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    final docId = 'HMBSL-${charter.id}-${charter.dateFrom.year}';
    const rev = 0;
    final pdf = pw.Document(theme: await _theme());
    final photos = await _loadPhotos(entries);
    for (final page in _dayPages(charter, day, entries, mapScreenshot, photos, docId, rev,
        l10n, duties, bearings)) {
      pdf.addPage(page);
    }
    if (signatureImage != null) {
      final canonical = _buildCanonical(
        charter: charter, days: [day], entriesByDay: {day.id: entries},
        docId: docId, revision: rev);
      final hash = sha256.convert(utf8.encode(canonical)).toString();
      pdf.addPage(_signaturePage(
        l: l10n,
        signatureImage: signatureImage,
        signerName: charter.skipperName,
        signedAt: DateTime.now().toUtc(),
        hash: hash,
        docTitle: '${charter.title} – ${_date.short(day.date)}',
      ));
    }
    return pdf.save();
  }

  /// Jednotky pre celý dokument.
  ///
  /// Nastavuje ho volajúci pred generovaním. Zámerne statické: jednotky
  /// potrebuje asi dvadsať vnorených builderov strán a pretiahnuť parameter
  /// cez všetky by bola väčšia zmena než samotná funkcia. Export beží vždy
  /// jeden naraz a nastavenie je globálne pre appku.
  static UnitsSettings units = const UnitsSettings();

  static Future<File> saveBytesToFile(Uint8List bytes, String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<File> exportCharter({
    required Charter charter,
    required List<DayLog> days,
    required Map<int, List<LogbookEntry>> entriesByDay,
    required Map<int, Uint8List?> mapScreenshots,
    required AppLocalizations l10n,
    Map<int, List<DutyPeriod>> dutiesByDay = const {},
    Map<int, List<Bearing>> bearingsByDay = const {},
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
    HandoverProtocol? checkInProtocol,
    List<ChecklistItem>? checkInChecklist,
    HandoverProtocol? checkOutProtocol,
    List<ChecklistItem>? checkOutChecklist,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    final bytes = await buildCharterPdfBytes(
      dateFormat: dateFormat,
      charter: charter, days: days, entriesByDay: entriesByDay,
      mapScreenshots: mapScreenshots, signatureImage: signatureImage,
      l10n: l10n, dutiesByDay: dutiesByDay, bearingsByDay: bearingsByDay,
      skipperProfile: skipperProfile,
      checkInProtocol: checkInProtocol, checkInChecklist: checkInChecklist,
      checkOutProtocol: checkOutProtocol, checkOutChecklist: checkOutChecklist,
    );
    return saveBytesToFile(bytes, 'charter_${charter.id}');
  }

  static Future<File> exportDay({
    required Charter charter,
    required DayLog day,
    required List<LogbookEntry> entries,
    required AppLocalizations l10n,
    List<DutyPeriod> duties = const [],
    List<Bearing> bearings = const [],
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    final bytes = await buildDayPdfBytes(
      dateFormat: dateFormat,
      charter: charter, day: day, entries: entries,
      l10n: l10n, duties: duties, bearings: bearings,
      mapScreenshot: mapScreenshot, signatureImage: signatureImage,
      skipperProfile: skipperProfile);
    return saveBytesToFile(bytes, 'day_${day.id}');
  }

  // ── Foto preload ──────────────────────────────────────────────

  static Future<Map<int, Uint8List>> _loadPhotos(List<LogbookEntry> entries) async {
    final result = <int, Uint8List>{};
    for (final e in entries) {
      if (e.photoPath != null) {
        try {
          final f = File(e.photoPath!);
          if (await f.exists()) result[e.id] = await f.readAsBytes();
        } catch (_) {}
      }
    }
    return result;
  }

  // ── Canonical hash ────────────────────────────────────────────

  static String _buildCanonical({
    required Charter charter,
    required List<DayLog> days,
    required Map<int, List<LogbookEntry>> entriesByDay,
    String docId = '',
    int revision = 0,
  }) {
    final sb = StringBuffer()
      ..writeln('HMB-SAILING-LOG:v2')
      ..writeln('docId:$docId')
      ..writeln('rev:$revision')
      ..writeln('title:${charter.title}')
      ..writeln('vessel:${charter.vesselName ?? ""}')
      ..writeln('mmsi:${charter.mmsi ?? ""}')
      ..writeln('skipper:${charter.skipperName ?? ""}')
      ..writeln('from:${charter.dateFrom.toUtc().toIso8601String()}')
      ..writeln('to:${charter.dateTo.toUtc().toIso8601String()}');
    for (final day in days) {
      sb
        ..writeln('---')
        ..writeln('day:${day.date.toUtc().toIso8601String().substring(0, 10)}')
        ..writeln('port_from:${day.portFrom ?? ""}')
        ..writeln('port_to:${day.portTo ?? ""}')
        ..writeln('nm:${day.distanceNm.toStringAsFixed(3)}');
      for (final e in entriesByDay[day.id] ?? []) {
        sb.writeln('entry:${e.timestamp.toUtc().toIso8601String()}'
            '|lat:${e.latitude?.toStringAsFixed(6) ?? ""}'
            '|lon:${e.longitude?.toStringAsFixed(6) ?? ""}'
            '|sog:${e.sog?.toStringAsFixed(2) ?? ""}'
            '|cog:${e.cog?.toStringAsFixed(1) ?? ""}');
      }
    }
    return sb.toString();
  }

  // ── Title Page ────────────────────────────────────────────────

  /// Všetky fotky lode z karty lode (Charters.photosJson, max 3).
  static Future<List<pw.MemoryImage>> _loadVesselPhotos(Charter charter) async {
    final json = charter.photosJson;
    if (json == null || json.isEmpty) return const [];
    try {
      final paths =
          (jsonDecode(json) as List).map((e) => e.toString()).toList();
      final images = <pw.MemoryImage>[];
      for (final p in paths) {
        final file = File(p);
        if (await file.exists()) {
          images.add(pw.MemoryImage(await file.readAsBytes()));
        }
      }
      return images;
    } catch (_) {
      return const [];
    }
  }

  static pw.Page _titlePage(AppLocalizations l, Charter charter, List<DayLog> days,
      Map<int, List<LogbookEntry>> entriesByDay, SkipperProfile? skipper,
      String docId, int revision, List<pw.MemoryImage> vesselPhotos) {
    final fmt = _date;
    final crew = (charter.crewNames ?? '').split('|').where((s) => s.isNotEmpty).toList();
    final totalNm = days.fold<double>(0, (s, d) => s + d.distanceNm);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // Header: vľavo názov + dátum, vpravo fotka lode (ak je nahratá)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: pw.BoxDecoration(color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('HMB SAILING LOG', style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 9, letterSpacing: 3)),
                pw.SizedBox(height: 6),
                pw.Text(_pdfText(charter.title), style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 3),
                pw.Text('${fmt.medium(charter.dateFrom)} - ${fmt.medium(charter.dateTo)}',
                    style: pw.TextStyle(color: PdfColors.grey200, fontSize: 12)),
              ]),
            ),
            if (vesselPhotos.isNotEmpty) ...[
              pw.SizedBox(width: 12),
              pw.ClipRRect(
                horizontalRadius: 4,
                verticalRadius: 4,
                child: pw.Image(vesselPhotos.first,
                    width: 110, height: 74, fit: pw.BoxFit.cover),
              ),
            ],
          ]),
        ),
        // Ďalšie fotky lode (2. a 3.) pod hlavičkou vedľa seba
        if (vesselPhotos.length > 1) ...[
          pw.SizedBox(height: 8),
          pw.Row(children: [
            for (final img in vesselPhotos.skip(1)) ...[
              pw.ClipRRect(
                horizontalRadius: 4,
                verticalRadius: 4,
                child: pw.Image(img,
                    width: 160, height: 100, fit: pw.BoxFit.cover),
              ),
              pw.SizedBox(width: 8),
            ],
          ]),
        ],
        pw.SizedBox(height: 14),

        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _infoBox(l.pdfVesselLabel.toUpperCase(), [
            _pdfText(charter.vesselName ?? '-'),
            if (charter.vesselType != null) _pdfText(charter.vesselType!),
            if (charter.homePort != null) '${l.homePort}: ${_pdfText(charter.homePort!)}',
            if (charter.mmsi != null) 'MMSI: ${charter.mmsi!}',
            if (charter.callsign != null) '${l.callsign}: ${charter.callsign!}',
            // Rozmery lode nesú jednotku už v popiske ("Dĺžka (m)").
            if (charter.vesselLengthM != null)
              '${l.vesselLengthM}: ${charter.vesselLengthM!.toStringAsFixed(1)}',
            if (charter.vesselBeamM != null)
              '${l.vesselBeamM}: ${charter.vesselBeamM!.toStringAsFixed(1)}',
            if (charter.vesselDraftM != null)
              '${l.vesselDraftM}: ${charter.vesselDraftM!.toStringAsFixed(1)}',
          ])),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _infoBox(l.pdfCrewSection.toUpperCase(), [
            if (charter.skipperName != null) '${l.pdfSkipperLabel}: ${_pdfText(charter.skipperName!)}',
            ...crew.map((c) => '- ${_pdfText(c)}'),
            if (crew.isEmpty && charter.skipperName == null) '-',
          ])),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _infoBox(l.pdfVoyageSummary.toUpperCase(), [
            '${l.pdfDayCount}: ${days.length}',
            '${l.pdfTotalLabel}: ${units.formatDistance(totalNm, decimals: 1)}',
            if (charter.notes != null) _pdfText(charter.notes!),
          ])),
        ]),
        pw.SizedBox(height: 10),

        // ── Skipper credentials (only if provided) ──
        if (skipper != null && !skipper.isEmpty) ...[
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: pw.BoxDecoration(
              color: _lblue,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(l.pdfSkipperLicences.toUpperCase(), style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (skipper.fullName.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(l.pdfNameLabel, _pdfText(skipper.fullName))),
                ],
                if (skipper.licenseType.isNotEmpty || skipper.licenseNumber.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    l.pdfLicenceLabel,
                    _pdfText('${skipper.licenseType} ${skipper.licenseNumber}'.trim()),
                  )),
                ],
                if (skipper.licenseAuthority.isNotEmpty || skipper.licenseExpiry.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    l.pdfIssuedValidLabel,
                    _pdfText('${skipper.licenseAuthority}  ${skipper.licenseExpiry}'.trim()),
                  )),
                ],
                if (skipper.vhfNumber.isNotEmpty || skipper.vhfExpiry.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    'VHF/SRC',
                    _pdfText('${skipper.vhfNumber}  ${skipper.vhfExpiry}'.trim()),
                  )),
                ],
              ]),
              if (skipper.otherCerts.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                _wRow(l.pdfOtherCertsLabel, _pdfText(skipper.otherCerts)),
              ],
            ]),
          ),
          pw.SizedBox(height: 10),
        ],

        pw.Text(l.pdfDaysOverview.toUpperCase(), style: pw.TextStyle(color: _navy,
            fontWeight: pw.FontWeight.bold, fontSize: 10, letterSpacing: 1)),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(decoration: pw.BoxDecoration(color: _navy), children:
              [l.pdfDateLabel, l.pdfColFrom, l.pdfColTo, units.distanceLabel, 'Bft', l.pdfColEntriesShort].map((h) =>
                _hcell(h)).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              return pw.TableRow(decoration: pw.BoxDecoration(
                  color: e.key.isEven ? _lgrey : PdfColors.white), children: [
                _cell(_date.shortWithWeekday(d.date)),
                _cell(_pdfText(d.portFrom ?? '-')),
                _cell(_pdfText(d.portTo ?? '-')),
                _cell(d.distanceNm.toStringAsFixed(1)),
                _cell(() {
                  final bft = _beaufortForDay(d, entriesByDay[d.id] ?? []);
                  return bft != null ? 'Bft $bft' : '-';
                }()),
                _cell('-'),
              ]);
            }),
          ],
        ),
        pw.Spacer(),
        _footer(_pdfText(charter.title), docId: docId, revision: revision),
      ]),
    );
  }

  // ── Day Pages ─────────────────────────────────────────────────

  static List<pw.Page> _dayPages(Charter charter, DayLog day,
      List<LogbookEntry> entries, Uint8List? screenshot, Map<int, Uint8List> photos,
      String docId, int revision, AppLocalizations l,
      List<DutyPeriod> duties, [List<Bearing> bearings = const []]) {
    final pages = <pw.Page>[];
    final dayName = _date.long(day.date);
    final crew = (charter.crewNames ?? '').split('|').where((s) => s.isNotEmpty).toList();

    // Sort entries by time
    final sorted = [...entries]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Voyage start/end entries
    // Recognised by the stored event type, with the old note matching kept only
    // as a fallback for rows written before v21 — see LogbookEventType.
    final voyageStart = sorted
        .where((e) =>
            LogbookEventType.resolve(e.eventType, e.skipperNote) ==
            LogbookEventType.voyageStart)
        .toList();
    final voyageEnd = sorted
        .where((e) =>
            LogbookEventType.resolve(e.eventType, e.skipperNote) ==
            LogbookEventType.voyageEnd)
        .toList();

    // Denná strana je MultiPage, nie Page: obsah dňa (mapa, počasie, služby,
    // tabuľka záznamov) sa na jednu A4 nezmestí vždy a pevná strana nemá kam
    // pretiecť — dart_pdf v takom prípade tabuľku ani pätičku nevykreslí
    // vôbec. Tu sa obsah prirodzene rozlije na ďalšiu stranu.
    int? firstPageNumber;
    pages.add(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
      header: (ctx) {
        firstPageNumber ??= ctx.pageNumber;
        if (ctx.pageNumber == firstPageNumber) return pw.SizedBox();
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text('${_pdfText(dayName)} – ${l.pdfContinued}',
              style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 12)),
        );
      },
      footer: (ctx) => _footer(
          '${_pdfText(charter.title)}  |  ${_date.short(day.date)}',
          docId: docId, revision: revision),
      build: (ctx) => [

        // ── Compact header ──
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(color: _blue,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(_pdfText(dayName), style: pw.TextStyle(
                  color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 13)),
              pw.SizedBox(height: 2),
              pw.Text(_pdfText('${day.portFrom ?? "?"} → ${day.portTo ?? "?"}'),
                  style: pw.TextStyle(color: PdfColors.grey200, fontSize: 10)),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              if (day.distanceNm > 0)
                pw.Text(units.formatDistance(day.distanceNm, decimals: 1), style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              if (voyageStart.isNotEmpty)
                pw.Text('${l.pdfDeparture.toUpperCase()} ${DateFormat('HH:mm').format(voyageStart.first.timestamp.toUtc())} UTC',
                    style: pw.TextStyle(color: PdfColors.green200, fontSize: 8)),
              if (voyageEnd.isNotEmpty)
                pw.Text('${l.pdfArrival.toUpperCase()} ${DateFormat('HH:mm').format(voyageEnd.last.timestamp.toUtc())} UTC',
                    style: pw.TextStyle(color: PdfColors.orange200, fontSize: 8)),
            ]),
          ]),
        ),
        pw.SizedBox(height: 4),

        // ── Info bar ──
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(color: _lgrey,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
          child: pw.Row(children: [
            if (charter.vesselName != null) ...[
              pw.Text('${l.pdfVesselLabel}: ', style: pw.TextStyle(color: _dgrey, fontSize: 8)),
              pw.Text(_pdfText(charter.vesselName!),
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 12),
            ],
            if (charter.skipperName != null) ...[
              pw.Text('${l.pdfSkipperLabel}: ', style: pw.TextStyle(color: _dgrey, fontSize: 8)),
              pw.Text(_pdfText(charter.skipperName!),
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 12),
            ],
            if (crew.isNotEmpty) ...[
              pw.Text('${l.pdfCrewSection}: ', style: pw.TextStyle(color: _dgrey, fontSize: 8)),
              pw.Text(crew.map(_pdfText).join(', '),
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ],
            // Motohodiny za deň — charterová firma ich pýta pri odovzdaní
            // lode a appka ich vie narátať z otáčok, keď ich motor hlási.
            if (day.engineHours != null) ...[
              pw.SizedBox(width: 12),
              pw.Text('${l.engineHours}: ',
                  style: pw.TextStyle(color: _dgrey, fontSize: 8)),
              pw.Text('${day.engineHours!.toStringAsFixed(1)} h',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ],
          ]),
        ),
        pw.SizedBox(height: 6),

        // ── Mapa + Počasie (kompaktné) ──
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(flex: 3, child: pw.Container(
            height: 120,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: screenshot != null
                ? pw.ClipRRect(horizontalRadius: 4, verticalRadius: 4,
                    child: pw.Image(pw.MemoryImage(screenshot), fit: pw.BoxFit.cover))
                : pw.Center(child: pw.Text(l.pdfMapUnavailable,
                    style: pw.TextStyle(color: _dgrey, fontSize: 9))),
          )),
          pw.SizedBox(width: 8),
          pw.Expanded(flex: 2, child: _weatherBox(day, sorted, l)),
        ]),
        pw.SizedBox(height: 6),

        // ── Správa skippera ──
        if (day.skipperNote != null && day.skipperNote!.isNotEmpty) ...[
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(color: _lblue,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(l.pdfSkipperMessage.toUpperCase(), style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
              pw.SizedBox(height: 3),
              pw.Text(_pdfText(day.skipperNote!), style: const pw.TextStyle(fontSize: 9)),
            ]),
          ),
          pw.SizedBox(height: 6),
        ],

        // ── Slnko a mesiac ──
        if (_sunMoonBand(day.date, sorted, l) != null) ...[
          _sunMoonBand(day.date, sorted, l)!,
          pw.SizedBox(height: 8),
        ],

        // ── Službukonajúca posádka ──
        if (duties.isNotEmpty) ...[
          pw.Text(l.logDutySection.toUpperCase(), style: pw.TextStyle(
              color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
          pw.SizedBox(height: 3),
          _dutyBand(duties, day.date, l),
          pw.SizedBox(height: 8),
        ],

        // ── Záznamy ──
        //
        // Celá tabuľka naraz; MultiPage si ju rozdelí podľa skutočnej výšky
        // riadkov. Predtým sa krájala na 18 + po 30 riadkov na vlastné
        // strany a keď sa taký blok na stranu nezmestil, ostala prázdna.
        if (sorted.isNotEmpty) ...[
          pw.Text(l.pdfEntriesSection.toUpperCase(), style: pw.TextStyle(
              color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
          pw.SizedBox(height: 3),
          _entriesTable(sorted, photos, l),
        ],
      ],
    ));

    // ── Zamerania ──
    // Vlastná strana, nie stĺpec v tabuľke záznamov: zameranie nie je
    // hodinový záznam, robí sa ich za manéver niekoľko po sebe a do
    // desaťstĺpcovej tabuľky by sa aj tak nezmestili súradnice pozorovateľa.
    if (bearings.isNotEmpty) {
      final sortedBearings = [...bearings]
        ..sort((a, b) => a.takenAt.compareTo(b.takenAt));
      // Rovnaký dôvod pre MultiPage ako pri záznamoch vyššie: pevných
      // 26 riadkov na stranu bola stávka, ktorú stačilo prehrať jedným
      // vyšším riadkom, a strana ostala prázdna.
      pages.add(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        header: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
              '${_pdfText(dayName)} – ${_pdfText(l.bearingPdfSection)}',
              style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ),
        footer: (ctx) => _footer(
            '${_pdfText(charter.title)}  |  ${_date.short(day.date)}',
            docId: docId, revision: revision),
        build: (ctx) => [
          _bearingsTable(sortedBearings, l),
          pw.SizedBox(height: 6),
          pw.Text(
              _pdfText(l.bearingUncertaintyNote(
                  '${sortedBearings.first.uncertaintyDeg.round()}°')),
              style: pw.TextStyle(color: _dgrey, fontSize: 7)),
          if (sortedBearings.any((b) => b.declinationSource == 'target'))
            pw.Text(_pdfText(l.bearingDeclinationFromTarget),
                style: pw.TextStyle(color: _dgrey, fontSize: 7)),
        ],
      ));
    }
    return pages;
  }

  // ── Samostatná relácia zameraní (mimo plavby) ───────────────────

  /// Jednoduchý PDF pre zamerania zapísané bez aktívneho trackingu — mapka
  /// s kužeľmi a fixom plus tabuľky, presne ako denná stránka v plavbe, len
  /// bez charteru a dňa okolo, ktoré taká relácia nemá.
  static Future<Uint8List> buildBearingSessionPdfBytes({
    required DateTime date,
    required List<Bearing> bearings,
    required AppLocalizations l,
    Uint8List? mapScreenshot,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    final pdf = pw.Document(theme: await _theme());
    final resections = latestResectionCluster(bearings);
    final resectionLines =
        resections.map(bearingLineOf).whereType<BearingLine>().toList();
    final resectionFix = resectionLines.length < 2
        ? null
        : BearingGeometry.fix(resectionLines, kind: BearingKind.resection);

    final objectGroups = sightGroupsFrom(bearings);

    final dayName = _date.long(date);
    final docId = 'HMBSL-BEARINGS-${DateFormat('yyyyMMdd').format(date)}';

    pw.Widget header() => pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
              color: _blue,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_pdfText('${l.bearingsTitle} – $dayName'),
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13)),
                pw.Text('${bearings.length}',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
              ]),
        );

    // Mapa na vlastnej strane, takmer celá A4: na malej vložke uprostred
    // tabuľkovej strany by značky a popisky boli nečitateľné. Zvyšok
    // (tabuľky, výsledky) je na druhej strane, kde má miesto rásť.
    if (mapScreenshot != null) {
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            header(),
            pw.SizedBox(height: 8),
            pw.Expanded(
              child: pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4))),
                child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(pw.MemoryImage(mapScreenshot),
                        fit: pw.BoxFit.cover)),
              ),
            ),
            pw.SizedBox(height: 6),
            _footer(_pdfText(dayName), docId: docId, revision: 0),
          ],
        ),
      ));
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (mapScreenshot == null) ...[header(), pw.SizedBox(height: 8)],

          if (resections.isNotEmpty) ...[
            pw.Text(_pdfText(l.bearingResectionSection.toUpperCase()),
                style: pw.TextStyle(
                    color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 9)),
            pw.SizedBox(height: 3),
            _bearingsTable(
              resections,
              l,
              resultLabel: resectionFix == null
                  ? null
                  : '${l.bearingMyPositionFix}'
                      '  ±${resectionFix.errorRadiusMeters.round()} m'
                      '${resectionFix.isWeak ? '  ·  ${l.bearingFixWeak('${resectionFix.cutAngleDeg.round()}°')}' : ''}',
              resultPosition: resectionFix == null
                  ? null
                  : '${_latStr(resectionFix.position.latitude)}  '
                      '${_lonStr(resectionFix.position.longitude)}',
            ),
            pw.SizedBox(height: 10),
          ],

          if (objectGroups.isNotEmpty) ...[
            pw.Text(_pdfText(l.bearingObjectSection.toUpperCase()),
                style: pw.TextStyle(
                    color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 9)),
            pw.SizedBox(height: 3),
            for (final group in objectGroups) ...[
              _bearingsTable(
                group.bearings,
                l,
                resultLabel: group.fix == null
                    ? null
                    : '${group.name.isEmpty ? l.bearingObjectFix : group.name}'
                        '  ±${group.fix!.errorRadiusMeters.round()} m'
                        '${group.fix!.isWeak ? '  ·  ${l.bearingFixWeak('${group.fix!.cutAngleDeg.round()}°')}' : ''}',
                resultPosition: group.fix == null
                    ? null
                    : '${_latStr(group.fix!.position.latitude)}  '
                        '${_lonStr(group.fix!.position.longitude)}',
              ),
              pw.SizedBox(height: 8),
            ],
          ],

          if (bearings.any((b) => b.declinationSource == 'target'))
            pw.Text(_pdfText(l.bearingDeclinationFromTarget),
                style: pw.TextStyle(color: _dgrey, fontSize: 7)),

          pw.Spacer(),
          _footer(_pdfText(dayName), docId: docId, revision: 0),
        ],
      ),
    ));
    return pdf.save();
  }

  // ── Bearings table ────────────────────────────────────────────

  static pw.Widget _bearingsTable(List<Bearing> bearings, AppLocalizations l,
      {String? resultLabel, String? resultPosition}) {
    pw.Widget head(String text) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: pw.Text(_pdfText(text.toUpperCase()),
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 6.5,
                  color: _navy)),
        );
    pw.Widget cell(String text, {bool bold = false}) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: pw.Text(_pdfText(text),
              style: pw.TextStyle(
                  fontSize: 7,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(34), // Čas UTC
        1: const pw.FlexColumnWidth(1), // Objekt
        2: const pw.FixedColumnWidth(44), // Pravý kurz
        3: const pw.FixedColumnWidth(44), // Magnetický
        4: const pw.FixedColumnWidth(40), // Deklinácia
        5: const pw.FixedColumnWidth(96), // Poloha
      },
      children: [
        pw.TableRow(
          repeat: true,
          decoration: pw.BoxDecoration(color: _lgrey),
          children: [
            head(l.timeCol),
            head(l.bearingPdfObject),
            head(l.bearingPdfBearing),
            head(l.bearingMagneticLabel),
            head(l.bearingDeclinationApplied('').trim()),
            head(l.gpsPosition),
          ],
        ),
        for (final b in bearings)
          pw.TableRow(children: [
            cell(DateFormat('HH:mm').format(b.takenAt.toUtc())),
            // Pri resekcii je podstatné, ČO sa zameriavalo — názov bodu má
            // prednosť pred voľnou poznámkou.
            cell(b.targetName ?? b.label ?? '—'),
            cell(_bearingDeg(b.trueBearing), bold: true),
            cell(_bearingDeg(b.magneticBearing)),
            cell(_signedDeg(b.declination)),
            // Stĺpec je poloha ZNÁMEHO BODU (knownPointOf), nie
            // pozorovateľa — pri resekcii sa nesmie prepnúť na polohu lode
            // len preto, že GPS v okamihu zamerania náhodou bežalo.
            cell(() {
              final (lat, lon) = knownPointOf(b);
              return '${_latStr(lat)}  ${_lonStr(lon)}';
            }()),
          ]),
        // Vypočítaný výsledok ako posledný riadok tej istej tabuľky, nie
        // samostatný text pod ňou — čitateľ ho tak prečíta priamo vedľa
        // riadkov, z ktorých vznikol, namiesto hľadania súvislosti o kus
        // nižšie.
        if (resultLabel != null && resultPosition != null)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: _lblue),
            children: [
              cell(''),
              cell(resultLabel, bold: true),
              cell(''),
              cell(''),
              cell(''),
              cell(resultPosition, bold: true),
            ],
          ),
      ],
    );
  }

  static String _bearingDeg(double value) =>
      '${(value.round() % 360).toString().padLeft(3, '0')}°';

  static String _signedDeg(double value) =>
      '${value >= 0 ? '+' : '-'}${value.abs().toStringAsFixed(1)}°';

  // ── Entries Table (rozšírená) ─────────────────────────────────

  /// Krátky popis pôvodu hodnôt počasia, alebo `null` pri starých záznamoch
  /// spred schémy v27, kde zdroj nikto nezaznamenal.
  static String? _weatherSourceLabel(LogbookEntry e, AppLocalizations l) {
    final source = e.weatherSource;
    if (source == null) return null;
    if (source == 'nmea') return l.weatherSourceInstruments;
    if (source != 'dhmz') return l.weatherSourceModel;
    final name = e.weatherStation;
    if (name == null) return l.weatherSourceStationUnknown;
    final d = e.weatherStationDistanceM;
    return d == null
        ? l.weatherSourceStation(name)
        : l.weatherSourceStationAt(name, (d / 1000).toStringAsFixed(1));
  }

  static pw.Widget _entriesTable(List<LogbookEntry> entries,
      Map<int, Uint8List> photos, AppLocalizations l) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),   // Čas UTC
        1: const pw.FixedColumnWidth(50),   // GPS lat+lon (2 riadky)
        2: const pw.FixedColumnWidth(28),   // SOG + jednotka v hlavičke
        3: const pw.FixedColumnWidth(22),   // COG °
        4: const pw.FixedColumnWidth(24),   // Hĺbka pod kýlom
        5: const pw.FixedColumnWidth(34),   // Vietor spd+dir+vlny
        6: const pw.FixedColumnWidth(26),   // hPa
        7: const pw.FixedColumnWidth(24),   // Teplota vzd/voda
        8: const pw.FixedColumnWidth(34),   // Pohon + motor/nadrze
        9: const pw.FixedColumnWidth(40),   // Počasie – plný názov, 2 riadky
        10: const pw.FlexColumnWidth(1),    // Poznámka
      },
      children: [
        // repeat: hlavička sa zopakuje na každej strane, na ktorú tabuľka
        // pretečie. Bez toho je pokračovanie dňa stĺpec čísel bez názvov a
        // čitateľ musí listovať späť, aby vedel, čo je čo.
        pw.TableRow(repeat: true, decoration: pw.BoxDecoration(color: _blue), children:
          // Rýchlosť a teplota nesú jednotku v hlavičke, nie pri každej
          // hodnote — v stĺpci širokom 28 px sa jednotka k číslu nezmestí.
          [l.pdfColTimeUtc, 'GPS', 'SOG ${units.speedLabel}', 'COG',
              // Hĺbka zo sondy — v papierovom denníku stojí hneď pri polohe
              // a tu tiež: patrí k tomu, kde loď bola, nie k počasiu.
              '${l.depthLabel} m',
              l.pdfColWind, 'hPa', 'T ${units.tempLabel}',
              l.pdfColPropulsion, l.pdfColWeatherShort, l.pdfColNote]
              .map((h) => _hcell(h)).toList()),
        ...entries.asMap().entries.map((e) {
          final entry = e.value;
          final time = DateFormat('HH:mm').format(entry.timestamp.toUtc());
          final parsedMode = parseSailMode(entry.sailMode, entry.skipperNote);
          final sailMode = parsedMode.modes.isEmpty
              ? '-'
              : _sailModeLabel(parsedMode.modes.join(','), l);
          // Kurz voči vetru ide do toho istého stĺpca ako pohon: papierový
          // denník ho má tiež pri plachtách, nie ako vlastnú kolónku.
          final sailDir = SailDirection.fromCodes(entry.pointOfSail, entry.tack);
          String noteText = parsedMode.note;
          // An automatic entry is printed from its event type, so the reader
          // gets it in their own language instead of the stored English.
          final eventLabel = _eventLabel(
              LogbookEventType.resolve(entry.eventType, entry.skipperNote),
              noteText,
              l);
          if (eventLabel != null) noteText = eventLabel;
          // Zmena plachiet nesie v poznámke celý kurz — kto číta export,
          // nemá stĺpec so siluetou, takže „Zmena plachiet" samo o sebe
          // nehovorí nič.
          if (LogbookEventType.resolve(entry.eventType, entry.skipperNote) ==
                  LogbookEventType.sailChange &&
              sailDir != null) {
            noteText = l.logEventSailChangeTo(sailDirectionPhrase(sailDir, l));
          }
          // Strojová značka ('Auto [MODEL]') sa netlačí. Zdroj počasia stojí
          // preložený vo vlastnom stĺpci vedľa — skratka NMEA/MODEL v
          // poznámke ho len duplikovala, a to po slovensky.
          if (eventLabel == null && isMachineAutoNote(noteText)) {
            noteText = entry.isAutoEntry ? l.autoEntryNote : '';
          }

          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: e.key.isEven ? PdfColor.fromHex('#F7F9FC') : PdfColors.white),
            children: [
              // Čas
              _dcell(time, fontSize: 7.5),
              // GPS lat/lon
              pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(_latStr(entry.latitude),
                      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  pw.Text(_lonStr(entry.longitude),
                      style: pw.TextStyle(fontSize: 7, color: _dgrey)),
                ])),
              // SOG
              _dcell(entry.sog != null
                  ? units.speedValue(entry.sog!).toStringAsFixed(1)
                  : '-'),
              // COG
              _dcell(entry.cog != null ? '${entry.cog!.toStringAsFixed(0)}°' : '-'),
              // Hĺbka
              _dcell(entry.depthMeters != null
                  ? entry.depthMeters!.toStringAsFixed(1)
                  : '-'),
              // Vietor + smer + vlny
              pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  if (entry.windSpeed != null)
                    pw.Text(units.formatWind(entry.windSpeed),
                        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  if (entry.windDirection != null)
                    pw.Text(_degToCompass(entry.windDirection!),
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.waveHeight != null)
                    pw.Text('~${entry.waveHeight!.toStringAsFixed(1)}m',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.windSpeed == null)
                    pw.Text('-', style: const pw.TextStyle(fontSize: 7)),
                ])),
              // Barometer
              _dcell(entry.airPressure != null
                  ? '${entry.airPressure!.toStringAsFixed(0)}' : '-'),
              // Teplota vzduch / voda
              pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  if (entry.airTemp != null)
                    pw.Text('${units.tempValue(entry.airTemp!).toStringAsFixed(0)}°',
                        style: const pw.TextStyle(fontSize: 7)),
                  if (entry.waterTemp != null)
                    pw.Text('~${units.tempValue(entry.waterTemp!).toStringAsFixed(0)}°',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.airTemp == null && entry.waterTemp == null)
                    pw.Text('-', style: const pw.TextStyle(fontSize: 7)),
                ])),
              // Pohon + motor/nadrze
              pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(_pdfText(sailMode), maxLines: 1, overflow: pw.TextOverflow.clip,
                      style: const pw.TextStyle(fontSize: 7.5)),
                  if (sailDir != null)
                    pw.Text(_pdfText(sailDirectionShort(sailDir, l)),
                        maxLines: 1, overflow: pw.TextOverflow.clip,
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.engineHours != null)
                    pw.Text('${entry.engineHours!.toStringAsFixed(1)}h',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  // P:/V: boli palivo/voda po slovensky - jednopísmenová
                  // skratka ide z prekladu, aby sedela aj inde.
                  if (entry.fuelLevel != null)
                    pw.Text('${l.pdfFuelShort}:${entry.fuelLevel}%',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.waterLevel != null)
                    pw.Text('${l.pdfWaterShort}:${entry.waterLevel}%',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                ])),
              // Počasie + odkiaľ hodnoty sú.
              //
              // Zdroj patrí do dokumentu, nie len na obrazovku: denník sa
              // predkladá ako doklad a rozdiel medzi "namerané prístrojom na
              // lodi" a "spočítané modelom" je preň podstatný.
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_pdfText(_wcLabel(entry.weatherCondition, l)),
                        maxLines: 2, style: const pw.TextStyle(fontSize: 6.5)),
                    if (_weatherSourceLabel(entry, l) case final src?)
                      pw.Text(_pdfText(src),
                          maxLines: 2,
                          style: pw.TextStyle(fontSize: 5.5, color: _dgrey)),
                  ],
                ),
              ),
              // Poznámka + foto priamo v riadku
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (photos.containsKey(entry.id))
                      pw.Container(
                        width: 65, height: 52,
                        margin: const pw.EdgeInsets.only(bottom: 3),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                        ),
                        child: pw.ClipRRect(horizontalRadius: 2, verticalRadius: 2,
                          child: pw.Image(pw.MemoryImage(photos[entry.id]!),
                              fit: pw.BoxFit.cover)),
                      ),
                    if (noteText.isNotEmpty)
                      pw.Text(_pdfText(noteText),
                          style: const pw.TextStyle(fontSize: 7.5),
                          maxLines: 3, overflow: pw.TextOverflow.clip),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── Summary Page ──────────────────────────────────────────────

  static pw.Page _summaryPage(Charter charter, List<DayLog> days,
      Map<int, List<LogbookEntry>> entriesByDay, String docId, int revision,
      AppLocalizations l) {
    final totalNm = days.fold<double>(0, (s, d) => s + d.distanceNm);
    final totalEntries = entriesByDay.values.fold<int>(0, (s, e) => s + e.length);
    final maxBft = days.fold<int>(0, (s, d) {
      final bft = _beaufortForDay(d, entriesByDay[d.id] ?? []);
      return (bft ?? 0) > s ? (bft ?? 0) : s;
    });

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Text(l.pdfVoyageSummary.toUpperCase(), style: pw.TextStyle(
              color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 14),

        pw.Row(children: [
          _statBox(l.pdfStatTotalDistance.toUpperCase(),
              units.formatDistance(totalNm, decimals: 1), _blue),
          pw.SizedBox(width: 6),
          _statBox(l.pdfDayCount.toUpperCase(), '${days.length}', _green),
          pw.SizedBox(width: 6),
          _statBox(l.pdfStatLogEntries.toUpperCase(), '$totalEntries', _dgrey),
          pw.SizedBox(width: 6),
          _statBox(l.pdfStatMaxBeaufort.toUpperCase(),
              maxBft > 0 ? 'Bft $maxBft' : '-', _navy),
        ]),
        pw.SizedBox(height: 14),

        pw.Text(l.pdfDaySummary.toUpperCase(), style: pw.TextStyle(
            color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 10, letterSpacing: 1)),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(decoration: pw.BoxDecoration(color: _navy), children:
              [l.pdfColDay, l.pdfColFrom, l.pdfColTo, '${units.distanceLabel} (GPS)', 'Bft', l.pdfColEntriesShort].map((h) => _hcell(h)).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              final cnt = entriesByDay[d.id]?.length ?? 0;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: e.key.isEven ? _lgrey : PdfColors.white),
                children: [
                  _cell(_date.shortWithWeekday(d.date)),
                  _cell(_pdfText(d.portFrom ?? '-')),
                  _cell(_pdfText(d.portTo ?? '-')),
                  _cell(units.formatDistance(d.distanceNm, decimals: 1)),
                  _cell(() {
                    final bft = _beaufortForDay(d, entriesByDay[d.id] ?? []);
                    return bft != null ? 'Bft $bft' : '-';
                  }()),
                  _cell('$cnt'),
                ],
              );
            }),
            pw.TableRow(decoration: pw.BoxDecoration(color: _lblue), children: [
              _cell(l.pdfTotalLabel.toUpperCase(), bold: true), _cell(''), _cell(''),
              _cell(units.formatDistance(totalNm, decimals: 1), bold: true),
              _cell(''), _cell('$totalEntries', bold: true),
            ]),
          ],
        ),
        pw.Spacer(),
        _footer(
          '${l.pdfExportedAt}: ${_date.shortWithTime(DateTime.now().toUtc())} UTC',
          docId: docId, revision: revision,
        ),
      ]),
    );
  }

  // ── Safety Briefing Page ─────────────────────────────────────

  static List<String> _sbItems(AppLocalizations l) => [
        l.pdfSbLifejackets,
        l.pdfSbLifebuoy,
        l.pdfSbFlares,
        l.pdfSbEpirb,
        l.pdfSbVhf,
        l.pdfSbExtinguisher,
        l.pdfSbFirstAid,
        l.pdfSbEngineStop,
        l.pdfSbLeaks,
        l.pdfSbAnchor,
        l.pdfSbRules,
        l.pdfSbEmergencyContacts,
      ];

  static Future<pw.Page> _safetyBriefingPage(
      Charter charter, List<CrewSignature> sigs, String docId, int revision,
      AppLocalizations l) async {
    // Load signature images
    final sigImages = <int, pw.MemoryImage>{};
    for (var i = 0; i < sigs.length; i++) {
      final path = sigs[i].signaturePath;
      if (path != null) {
        try {
          final f = File(path);
          if (await f.exists()) {
            sigImages[i] = pw.MemoryImage(await f.readAsBytes());
          }
        } catch (_) {}
      }
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: pw.BoxDecoration(color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(l.pdfSafetyBriefing.toUpperCase(), style: pw.TextStyle(
                color: PdfColors.white, fontSize: 9, letterSpacing: 2,
                fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 3),
            pw.Text(_pdfText(charter.title),
                style: pw.TextStyle(color: PdfColors.grey200, fontSize: 11)),
          ]),
        ),
        pw.SizedBox(height: 12),

        // Checklist in 2 columns
        pw.Text(l.pdfChecklistSection.toUpperCase(), style: pw.TextStyle(
            color: _navy, fontWeight: pw.FontWeight.bold,
            fontSize: 8, letterSpacing: 1)),
        pw.SizedBox(height: 6),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: List.generate(
              (_sbItems(l).length / 2).ceil(),
              (row) {
                final left = _sbItems(l)[row * 2];
                final rightIdx = row * 2 + 1;
                final right = rightIdx < _sbItems(l).length ? _sbItems(l)[rightIdx] : null;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: row.isEven ? _lgrey : PdfColors.white),
                  children: [
                    _sbCell('${row * 2 + 1}. $left'),
                    _sbCell(right != null ? '${rightIdx + 1}. $right' : ''),
                  ],
                );
              },
            ),
          ),
        ),
        pw.SizedBox(height: 14),

        // Crew signatures
        pw.Text(l.pdfCrewSignatures.toUpperCase(), style: pw.TextStyle(
            color: _navy, fontWeight: pw.FontWeight.bold,
            fontSize: 8, letterSpacing: 1)),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
            color: _lblue,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            l.pdfBriefingDeclaration,
            // Kurzíva zámerne nie: ThemeData.withFont nenastavuje italic rez,
            // takže by text spadol na Helvetica-Oblique, ktorá nevie Unicode.
            style: pw.TextStyle(fontSize: 8.5, color: _dgrey),
          ),
        ),
        pw.SizedBox(height: 10),

        if (sigs.isEmpty)
          pw.Text(l.pdfNoSignatures, style: pw.TextStyle(color: _dgrey, fontSize: 9))
        else
          pw.Wrap(spacing: 10, runSpacing: 10, children: [
            for (var i = 0; i < sigs.length; i++)
              pw.Container(
                width: 150,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(_pdfText(sigs[i].crewName),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  pw.Text(sigs[i].role == 'skipper' ? l.pdfSkipperLabel : l.pdfCrewSection,
                      style: pw.TextStyle(color: _dgrey, fontSize: 7.5)),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: double.infinity,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                    ),
                    child: sigImages.containsKey(i)
                        ? pw.Padding(padding: const pw.EdgeInsets.all(3),
                            child: pw.Image(sigImages[i]!, fit: pw.BoxFit.contain))
                        : pw.Center(child: pw.Text(l.pdfUnsigned,
                            style: pw.TextStyle(color: _dgrey, fontSize: 7))),
                  ),
                  if (sigs[i].signedAt != null) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(_date.shortWithTime(sigs[i].signedAt!.toLocal()),
                        style: pw.TextStyle(color: _dgrey, fontSize: 6.5)),
                  ],
                ]),
              ),
          ]),

        pw.Spacer(),
        _footer('${_pdfText(charter.title)}  |  ${l.pdfSafetyBriefing}', docId: docId, revision: revision),
      ]),
    );
  }

  static pw.Widget _sbCell(String text) {
    if (text.isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          width: 10, height: 10,
          margin: const pw.EdgeInsets.only(right: 5, top: 1),
          decoration: pw.BoxDecoration(
            color: _green,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.Expanded(child: pw.Text(_pdfText(text), style: const pw.TextStyle(fontSize: 8))),
      ]),
    );
  }

  // ── Signature Page ────────────────────────────────────────────

  static pw.Page _signaturePage({
    required AppLocalizations l,
    required Uint8List signatureImage,
    required String? signerName,
    required DateTime signedAt,
    required String hash,
    required String docTitle,
    String docId = '',
    int revision = 0,
  }) {
    final timeStr = _date.shortWithSeconds(signedAt);
    final shortHash = hash.substring(0, 12);
    final qrData = 'HMB-LOG:v2'
        '|id:$docId'
        '|rev:$revision'
        '|signer:${_pdfText(signerName ?? "Skipper")}'
        '|ts:${signedAt.toIso8601String()}'
        '|sha256:$shortHash';

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(l.pdfSkipperSignature.toUpperCase(), style: pw.TextStyle(
                color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
            pw.SizedBox(height: 3),
            pw.Text(_pdfText(docTitle), style: pw.TextStyle(color: PdfColors.grey200, fontSize: 12)),
          ]),
        ),
        pw.SizedBox(height: 20),
        pw.Container(width: double.infinity, height: 120,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              color: PdfColors.white),
          child: pw.Padding(padding: const pw.EdgeInsets.all(8),
            child: pw.Image(pw.MemoryImage(signatureImage), fit: pw.BoxFit.contain)),
        ),
        pw.SizedBox(height: 6),
        if (signerName != null)
          pw.Text(_pdfText(signerName), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.Text('${l.pdfSignedAt}: $timeStr UTC', style: pw.TextStyle(color: _dgrey, fontSize: 9)),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 12),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(l.pdfIntegrityCheck.toUpperCase(), style: pw.TextStyle(
                color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
            pw.SizedBox(height: 6),
            pw.Text(l.pdfSha256Label,
                style: pw.TextStyle(color: _dgrey, fontSize: 7.5)),
            pw.SizedBox(height: 3),
            pw.Text(hash.substring(0, 32), style: pw.TextStyle(
                fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C3E50'))),
            pw.Text(hash.substring(32), style: pw.TextStyle(
                fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C3E50'))),
            pw.SizedBox(height: 8),
            pw.Text(l.pdfHashCoverage,
                style: pw.TextStyle(color: _dgrey, fontSize: 7)),
          ])),
          pw.SizedBox(width: 20),
          pw.Column(children: [
            pw.BarcodeWidget(
              barcode: Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium),
              data: qrData, width: 90, height: 90,
            ),
            pw.SizedBox(height: 4),
            pw.Text(l.pdfVerifyQr, style: pw.TextStyle(color: _dgrey, fontSize: 7)),
          ]),
        ]),
        pw.Spacer(),
        _footer('${_pdfText(docTitle)}  |  ${l.pdfSignedAt} $timeStr UTC', docId: docId, revision: revision),
      ]),
    );
  }

  // ── Weather Box ───────────────────────────────────────────────

  static pw.Widget _weatherBox(
      DayLog day, List<LogbookEntry> entries, AppLocalizations l) {
    final rows = <pw.Widget>[];
    if (day.beaufortMorning != null) rows.add(_wRow(l.morning, 'Bft ${day.beaufortMorning}'));
    if (day.beaufortNoon != null) rows.add(_wRow(l.noon, 'Bft ${day.beaufortNoon}'));
    if (day.beaufortEvening != null) rows.add(_wRow(l.evening, 'Bft ${day.beaufortEvening}'));

    if (day.beaufortMorning == null && day.beaufortNoon == null && day.beaufortEvening == null) {
      final withWind = entries.where((e) => e.windSpeed != null).toList();
      if (withWind.isNotEmpty) {
        final avg = withWind.map((e) => e.windSpeed!).reduce((a, b) => a + b) / withWind.length;
        // formatWindFull už Bft dopĺňa samo, aj keď je vietor v uzloch či m/s.
        rows.add(_wRow(l.wind, units.formatWindFull(avg)));
      }
    }
    if (day.windDirection != null) {
      rows.add(_wRow(l.windDir, _pdfText(day.windDirection!)));
    } else {
      final withDir = entries.where((e) => e.windDirection != null).toList();
      if (withDir.isNotEmpty) {
        final avg = withDir.map((e) => e.windDirection!).reduce((a, b) => a + b) / withDir.length;
        rows.add(_wRow(l.windDir, _degToCompass(avg)));
      }
    }

    // Tlak – z entries
    final withPressure = entries.where((e) => e.airPressure != null).toList();
    if (withPressure.isNotEmpty) {
      final avg = withPressure.map((e) => e.airPressure!).reduce((a, b) => a + b) / withPressure.length;
      rows.add(_wRow(l.pressureLabel, units.formatPressure(avg)));
    }

    if (day.seaState != null) rows.add(_wRow(l.seaState, _pdfText(day.seaState!)));
    if (day.waveHeightM != null) {
      rows.add(_wRow(l.waveHeight, '${day.waveHeightM!.toStringAsFixed(1)} m'));
    } else {
      final withWave = entries.where((e) => e.waveHeight != null).toList();
      if (withWave.isNotEmpty) {
        final avg = withWave.map((e) => e.waveHeight!).reduce((a, b) => a + b) / withWave.length;
        rows.add(_wRow(l.waveHeight, '${avg.toStringAsFixed(1)} m'));
      }
    }

    if (day.airTempC != null) {
      rows.add(_wRow(l.airTempLabel, units.formatTemp(day.airTempC, decimals: 0)));
    } else {
      final withTemp = entries.where((e) => e.airTemp != null).toList();
      if (withTemp.isNotEmpty) {
        final avg = withTemp.map((e) => e.airTemp!).reduce((a, b) => a + b) / withTemp.length;
        rows.add(_wRow(l.airTempLabel, units.formatTemp(avg, decimals: 0)));
      }
    }

    if (day.waterTempC != null) {
      rows.add(_wRow(l.waterLabel, units.formatTemp(day.waterTempC, decimals: 0)));
    } else {
      final withWater = entries.where((e) => e.waterTemp != null).toList();
      if (withWater.isNotEmpty) {
        final avg = withWater.map((e) => e.waterTemp!).reduce((a, b) => a + b) / withWater.length;
        rows.add(_wRow(l.waterLabel, units.formatTemp(avg, decimals: 0)));
      }
    }

    if (rows.isEmpty) rows.add(pw.Text(l.pdfNoData, style: pw.TextStyle(color: _dgrey, fontSize: 8)));

    return pw.Container(
      height: 120,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(color: _lblue,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(l.pdfWeatherSection.toUpperCase(), style: pw.TextStyle(color: _navy,
            fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
        pw.SizedBox(height: 4),
        ...rows,
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// Stupne + decimálne minúty – štandard v námornej navigácii
  static String _latStr(double? lat) {
    if (lat == null) return '-';
    final dir = lat >= 0 ? 'N' : 'S';
    final abs = lat.abs();
    final deg = abs.truncate();
    final min = (abs - deg) * 60;
    return "$deg°${min.toStringAsFixed(2)}'$dir";
  }

  static String _lonStr(double? lon) {
    if (lon == null) return '-';
    final dir = lon >= 0 ? 'E' : 'W';
    final abs = lon.abs();
    final deg = abs.truncate();
    final min = (abs - deg) * 60;
    return "${deg.toString().padLeft(3, '0')}°${min.toStringAsFixed(2)}'$dir";
  }

  /// Počasie v tabuľke záznamov.
  ///
  /// Boli tu slovenské skratky (Slnk, Zamr, Mrh...), ktoré v nemeckom PDF
  /// nedávali zmysel. Teraz sa berie plný lokalizovaný názov a stĺpec je
  /// širší — vymýšľať skratky pre jedenásť jazykov nemá zmysel.
  static String _wcLabel(String? key, AppLocalizations l) => switch (key) {
        null => '',
        'sunny' => l.wcSunny,
        'partly_cloudy' => l.wcPartlyCloudy,
        'overcast' => l.wcOvercast,
        'light_rain' => l.wcLightRain,
        'rain' => l.wcRain,
        'heavy_rain' => l.wcHeavyRain,
        'drizzle' => l.wcDrizzle,
        'thunderstorm' => l.wcThunderstorm,
        'iso_thunder' => l.wcIsoThunderstorm,
        'hail' => l.wcHail,
        'dust' => l.wcDust,
        'foggy' => l.wcFoggy,
        'windy' => l.wcWindy,
        'cold' => l.wcCold,
        _ => key,
      };

  /// Plachty. Motor/Genoa/Reef sú medzinárodné a appka ich neprekladá ani
  /// v editore záznamu — preklad má len hlavná plachta.
  static String _sailModeLabel(String modes, AppLocalizations l) {
    final map = {
      'motor': 'Motor', 'main': l.sailMain, 'genoa': 'Genoa',
      'reef1': 'Reef1', 'reef2': 'Reef2',
    };
    return modes.split(',').map((m) => map[m.trim()] ?? m).join('+');
  }

  static String _degToCompass(double deg) {
    const dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE',
                  'S','SSW','SW','WSW','W','WNW','NW','NNW'];
    return dirs[((deg % 360) / 22.5).round() % 16];
  }

  static pw.Widget _wRow(String l, String v) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
    child: pw.Row(children: [
      pw.SizedBox(width: 50, child: pw.Text(l, style: pw.TextStyle(color: _dgrey, fontSize: 8))),
      pw.Text(v, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
    ]),
  );

  static pw.Widget _infoBox(String title, List<String> lines) => pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(color: _lgrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(color: _navy,
          fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
      pw.SizedBox(height: 4),
      ...lines.map((l) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text(l, style: const pw.TextStyle(fontSize: 9)))),
    ]),
  );

  // ── Handover protokol (check-in/check-out) ───────────────────

  static Future<Uint8List> exportHandoverProtocol({
    required AppLocalizations l,
    required Charter charter,
    required HandoverProtocol protocol,
    required List<ChecklistItem> checklist,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    final docId = 'HMBSL-HANDOVER-${charter.id}-${protocol.type}';
    final fmt = _date;
    final typeLabel = protocol.type == 'checkOut' ? 'CHECK-OUT' : 'CHECK-IN';

    final thumbnails = await _loadHandoverThumbnails(checklist);
    final skipperSig = await _loadHandoverSignature(protocol.skipperSignaturePath);
    final companySig = await _loadHandoverSignature(protocol.companySignaturePath);

    final pdf = pw.Document(
      theme: await _theme(),
      title: '${l.pdfHandoverTitle} $typeLabel',
      creator: 'HMB Sailing Log',
    );

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              margin: const pw.EdgeInsets.only(bottom: 14),
              decoration: pw.BoxDecoration(color: _navy,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('${l.pdfHandoverTitle.toUpperCase()} - $typeLabel', style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(_pdfText('${charter.title}  |  ${charter.vesselName ?? "-"}'
                    '  |  ${charter.callsign ?? charter.mmsi ?? ""}'),
                    style: pw.TextStyle(color: PdfColors.grey200, fontSize: 9)),
              ]),
            )
          : pw.SizedBox(),
      footer: (ctx) => _footer(
        '${l.pdfDatePlaceLabel}: ${fmt.shortWithTime(protocol.dateTimeUtc.toLocal())}'
        '${protocol.location != null ? "  |  ${_pdfText(protocol.location!)}" : ""}',
        docId: docId, revision: 0,
      ),
      build: (ctx) => _handoverProtocolContent(
        l: l, protocol: protocol, checklist: checklist, thumbnails: thumbnails,
        skipperSig: skipperSig, companySig: companySig, fmt: fmt,
      ),
    ));

    return pdf.save();
  }

  /// Zdieľaný obsah odovzdávacieho protokolu (stat riadok, checklist podľa
  /// kategórií s fotkami, oba podpisy) – používaný aj samostatným
  /// `exportHandoverProtocol`, aj vloženým do hlavného PDF denníka plavby
  /// (`buildCharterPdfBytes`).
  static List<pw.Widget> _handoverProtocolContent({
    required AppLocalizations l,
    required HandoverProtocol protocol,
    required List<ChecklistItem> checklist,
    required Map<String, Uint8List> thumbnails,
    required Uint8List? skipperSig,
    required Uint8List? companySig,
    required AppDate fmt,
  }) {
    return [
      pw.Row(children: [
        _statBox(l.pdfEngineHours.toUpperCase(), protocol.engineHours?.toStringAsFixed(1) ?? '-', _navy),
        pw.SizedBox(width: 6),
        _statBox(l.pdfFuelLabel.toUpperCase(), protocol.fuelLevel != null ? '${protocol.fuelLevel}%' : '-', _blue),
        pw.SizedBox(width: 6),
        _statBox(l.pdfWaterLabel.toUpperCase(), protocol.waterLevel != null ? '${protocol.waterLevel}%' : '-', _green),
      ]),
      pw.SizedBox(height: 16),

      pw.Text(l.pdfChecklistSection.toUpperCase(), style: pw.TextStyle(
          color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 10, letterSpacing: 1)),
      pw.SizedBox(height: 6),
      _handoverChecklistTable(checklist, thumbnails, l),

      if (protocol.extraNotes != null && protocol.extraNotes!.isNotEmpty) ...[
        pw.SizedBox(height: 12),
        pw.Text(l.pdfMoreNotes.toUpperCase(), style: pw.TextStyle(
            color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 9, letterSpacing: 1)),
        pw.SizedBox(height: 4),
        pw.Text(_pdfText(protocol.extraNotes!), style: const pw.TextStyle(fontSize: 9)),
      ],

      pw.SizedBox(height: 32),
      pw.Text(l.pdfSignatures.toUpperCase(), style: pw.TextStyle(
          color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 10, letterSpacing: 1)),
      pw.SizedBox(height: 8),
      pw.Row(children: [
        pw.Expanded(child: _handoverSignatureBlock(
          title: l.pdfSkipperLabel, name: protocol.skipperName,
          signature: skipperSig,
          signedAt: protocol.skipperSignedAt, fmt: fmt, l: l,
        )),
        pw.SizedBox(width: 16),
        pw.Expanded(child: _handoverSignatureBlock(
          title: l.pdfForCharterCompany,
          name: protocol.companyRepName != null
              ? '${protocol.companyRepName}${protocol.companyName != null ? " (${protocol.companyName})" : ""}'
              : null,
          signature: companySig, signedAt: protocol.companySignedAt, fmt: fmt,
          l: l,
        )),
      ]),
    ];
  }

  /// Sekcia odovzdávacieho protokolu (check-in alebo check-out) vložená do
  /// hlavného PDF denníka plavby – rovnaký obsah ako samostatný
  /// `exportHandoverProtocol`, len ako ďalšia MultiPage v existujúcom
  /// dokumente namiesto vlastného `pw.Document`.
  static Future<pw.Page> _handoverProtocolPage({
    required AppLocalizations l,
    required Charter charter,
    required HandoverProtocol protocol,
    required List<ChecklistItem> checklist,
    required String docId,
    required int revision,
  }) async {
    final fmt = _date;
    final typeLabel = protocol.type == 'checkOut' ? 'CHECK-OUT' : 'CHECK-IN';
    final thumbnails = await _loadHandoverThumbnails(checklist);
    final skipperSig = await _loadHandoverSignature(protocol.skipperSignaturePath);
    final companySig = await _loadHandoverSignature(protocol.companySignaturePath);

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              margin: const pw.EdgeInsets.only(bottom: 14),
              decoration: pw.BoxDecoration(color: _navy,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
              child: pw.Text('${l.pdfHandoverTitle.toUpperCase()} - $typeLabel', style: pw.TextStyle(
                  color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            )
          : pw.SizedBox(),
      footer: (ctx) => _footer(_pdfText(charter.title), docId: docId, revision: revision),
      build: (ctx) => _handoverProtocolContent(
        l: l, protocol: protocol, checklist: checklist, thumbnails: thumbnails,
        skipperSig: skipperSig, companySig: companySig, fmt: fmt,
      ),
    );
  }

  static Future<Map<String, Uint8List>> _loadHandoverThumbnails(List<ChecklistItem> checklist) async {
    final thumbnails = <String, Uint8List>{};
    for (final item in checklist) {
      if (item.photoPath == null) continue;
      try {
        final f = File(item.photoPath!);
        if (await f.exists()) thumbnails[item.itemKey] = await f.readAsBytes();
      } catch (_) {}
    }
    return thumbnails;
  }

  static Future<Uint8List?> _loadHandoverSignature(String? path) async {
    if (path == null) return null;
    final f = File(path);
    if (await f.exists()) return f.readAsBytes();
    return null;
  }

  static String _handoverStatusLabel(ChecklistStatus s, AppLocalizations l) =>
      switch (s) {
        ChecklistStatus.ok => l.checklistItemOk,
        ChecklistStatus.damaged => l.checklistItemDamaged,
        ChecklistStatus.missing => l.checklistItemMissing,
      };

  /// Tabuľka checklistu zoskupená podľa kategórií (rovnaké kategórie ako v
  /// `handover_checklist.dart`) – funguje pre check-in aj check-out
  /// zoznam, keďže kľúče položiek sú medzi oboma naprieč unikátne.
  static pw.Widget _handoverChecklistTable(List<ChecklistItem> checklist,
      Map<String, Uint8List> thumbnails, AppLocalizations l) {
    final byKey = {for (final i in checklist) i.itemKey: i};
    final rows = <pw.TableRow>[
      pw.TableRow(decoration: pw.BoxDecoration(color: _navy), children:
        [l.pdfColItem, l.pdfColStatus, l.pdfColNotePosition, l.pdfColPhoto].map((h) => _hcell(h)).toList()),
    ];

    for (final category in [...checkInCategories, ...checkOutCategories]) {
      final items = category.items.map((d) => byKey[d.key]).whereType<ChecklistItem>().toList();
      if (items.isEmpty) continue;

      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue50),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: pw.Text(_pdfText(category.labelSk),
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _navy)),
          ),
          _cell(''), _cell(''), _cell(''),
        ],
      ));

      for (final item in items) {
        final label = findItemDef(item.itemKey)?.labelSk ?? item.itemKey;
        final noteParts = [
          if (item.note != null && item.note!.isNotEmpty) item.note!,
          if (item.position != null && item.position!.isNotEmpty) '(${item.position})',
        ];
        rows.add(pw.TableRow(
          decoration: pw.BoxDecoration(
              color: item.status == ChecklistStatus.ok ? PdfColors.white : PdfColor.fromHex('#FDEBD0')),
          children: [
            _cell(_pdfText(label)),
            _cell(_handoverStatusLabel(item.status, l), bold: item.status != ChecklistStatus.ok),
            _cell(_pdfText(noteParts.join(' '))),
            thumbnails.containsKey(item.itemKey)
                ? pw.Container(
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Image(pw.MemoryImage(thumbnails[item.itemKey]!),
                        height: 40, fit: pw.BoxFit.cover))
                : _cell('-'),
          ],
        ));
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.6),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: rows,
    );
  }

  static pw.Widget _handoverSignatureBlock({
    required String title,
    required String? name,
    required Uint8List? signature,
    required DateTime? signedAt,
    required AppDate fmt,
    required AppLocalizations l,
  }) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(_pdfText(title), style: pw.TextStyle(fontSize: 8, color: _dgrey, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      if (signature != null)
        pw.Image(pw.MemoryImage(signature), height: 50, fit: pw.BoxFit.contain, alignment: pw.Alignment.centerLeft)
      else
        pw.Container(height: 50, alignment: pw.Alignment.centerLeft,
            child: pw.Text('-', style: const pw.TextStyle(fontSize: 8))),
      pw.Container(decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5)))),
      pw.SizedBox(height: 4),
      pw.Text(_pdfText(name ?? '-'), style: const pw.TextStyle(fontSize: 8.5)),
      if (signedAt != null)
        pw.Text('${l.pdfSignedAt}: ${fmt.shortWithTime(signedAt.toLocal())}',
            style: pw.TextStyle(fontSize: 7, color: _dgrey)),
    ]);
  }

  // ── Kniha míľ – Potvrdenie o najazdených míľach ──────────────

  /// "12,4 x 4,0 m, ponor 1,9 m" — vynechá, čo nie je vyplnené.
  static String? _vesselDimensions(Charter charter) {
    final parts = <String>[];
    if (charter.vesselLengthM != null && charter.vesselBeamM != null) {
      parts.add('${charter.vesselLengthM!.toStringAsFixed(1)} x '
          '${charter.vesselBeamM!.toStringAsFixed(1)} m');
    } else if (charter.vesselLengthM != null) {
      parts.add('${charter.vesselLengthM!.toStringAsFixed(1)} m');
    }
    if (charter.vesselDraftM != null) {
      parts.add('${charter.vesselDraftM!.toStringAsFixed(1)} m');
    }
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Registrácia lode tak, ako ju karta plavby pozná: vlajka, volací znak,
  /// MMSI. Ak nie je nič, riadok sa netlačí.
  static String? _vesselRegistration(Charter charter) {
    final parts = [
      if (charter.vesselFlag != null) charter.vesselFlag!,
      if (charter.callsign != null) charter.callsign!,
      if (charter.mmsi != null) 'MMSI ${charter.mmsi}',
    ];
    return parts.isEmpty ? null : parts.join('  ·  ');
  }

  /// Potvrdenie o naplávaných míľach pre jedného člena posádky.
  ///
  /// Jeden súbor na človeka: potvrdenie sa posiela jemu, nie celej posádke.
  /// Nesie rovnaký integritný blok ako ostatné exporty (sha256 + QR), aby sa
  /// dalo overiť, že s ním nikto nehýbal — to je celý zmysel dokumentu, ktorý
  /// niekto predloží škole alebo charterovej firme.
  static Future<Uint8List> buildCrewMilesCertificate({
    required AppLocalizations l,
    required Charter charter,
    required CrewMemberRef crew,
    required VoyageMilesSummary summary,
    CrewAssessment? assessment,
    Uint8List? skipperSignature,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    // Potvrdenie často putuje do zahraničia (škola, charterová firma, úrad),
     // preto je dvojjazyčné. V anglickom rozhraní by bol druhý riadok ten
     // istý text, tak sa vynechá.
    final lEn = await AppLocalizations.delegate.load(const Locale('en'));
    String bi(String Function(AppLocalizations) pick) {
      final local = _pdfText(pick(l));
      final english = _pdfText(pick(lEn));
      return local == english ? local : '$local / $english';
    }

    /// Dvojriadková podoba pre úzke štatistické boxy.
    String biLines(String Function(AppLocalizations) pick) {
      final local = _pdfText(pick(l)).toUpperCase();
      final english = _pdfText(pick(lEn)).toUpperCase();
      return local == english ? local : '$local\n$english';
    }

    final docId = 'HMBSL-CREW-${charter.id}-${_pdfText(crew.name).replaceAll(' ', '')}';
    const rev = 0;
    final fmt = _date;
    final period = summary.dateFrom == null
        ? fmt.short(charter.dateFrom)
        : '${fmt.short(summary.dateFrom!)} – ${fmt.short(summary.dateTo ?? summary.dateFrom!)}';

    final canonical = StringBuffer()
      ..writeln('docId:$docId')
      ..writeln('rev:$rev')
      ..writeln('charter:${charter.id}')
      ..writeln('crew:${crew.name}')
      ..writeln('role:${crew.role}')
      ..writeln('days:${summary.daysAtSea}')
      ..writeln('dayNm:${summary.dayNm.toStringAsFixed(2)}')
      ..writeln('nightNm:${summary.nightNm.toStringAsFixed(2)}')
      ..writeln('nightHours:${summary.nightHours.toStringAsFixed(2)}')
      ..writeln('area:${summary.area ?? ''}')
      ..writeln('tidal:${charter.tidalWaters ?? ''}')
      ..writeln('vessel:${charter.vesselName ?? ''}')
      ..writeln('vesselSize:${_vesselDimensions(charter) ?? ''}')
      ..writeln('skills:${assessment == null ? '' : [
            assessment.helming,
            assessment.navigation,
            assessment.harbourManoeuvres,
            assessment.teamwork,
            assessment.nightSailing,
          ].join(',')}')
      ..writeln('note:${assessment?.note ?? ''}');
    final hash = sha256.convert(utf8.encode(canonical.toString())).toString();
    final qrData = 'HMB-LOG:v2'
        '|id:$docId'
        '|rev:$rev'
        '|crew:${_pdfText(crew.name)}'
        '|nm:${summary.totalNm.toStringAsFixed(1)}'
        '|sha256:${hash.substring(0, 12)}';

    final pdf = pw.Document(
      theme: await _theme(),
      title: l.crewCertTitle,
      creator: 'HMB Sailing Log',
    );

    final skills = <(String, int?)>[
      (bi((x) => x.crewSkillHelming), assessment?.helming),
      (bi((x) => x.crewSkillNavigation), assessment?.navigation),
      (bi((x) => x.crewSkillHarbour), assessment?.harbourManoeuvres),
      (bi((x) => x.crewSkillTeamwork), assessment?.teamwork),
      (bi((x) => x.crewSkillNightSailing), assessment?.nightSailing),
    ];

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (ctx) => _footer(
        '${l.pdfExportedAt}: ${_date.shortWithTime(DateTime.now().toUtc())} UTC',
        docId: docId,
        revision: rev,
      ),
      build: (ctx) => [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
              color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(bi((x) => x.crewCertTitle).toUpperCase(),
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1)),
            pw.SizedBox(height: 4),
            pw.Text(_pdfText(crew.name),
                style: pw.TextStyle(color: PdfColors.white, fontSize: 18)),
            pw.Text(
                '${bi(crew.roleLabel)}  ·  ${_pdfText(charter.title)}  ·  $period',
                style: pw.TextStyle(color: PdfColors.grey300, fontSize: 10)),
          ]),
        ),
        pw.SizedBox(height: 14),

        // ── Súhrn plavby ──
        pw.Row(children: [
          _statBox(biLines((x) => x.crewCertDaysAtSea),
              '${summary.daysAtSea}', _green),
          pw.SizedBox(width: 6),
          _statBox(
              biLines((x) => x.crewCertDayMiles),
              '${units.distanceValue(summary.dayNm).toStringAsFixed(1)} '
                  '${units.distanceLabel}',
              _blue),
          pw.SizedBox(width: 6),
          _statBox(
              biLines((x) => x.crewCertNightMiles),
              '${units.distanceValue(summary.nightNm).toStringAsFixed(1)} '
                  '${units.distanceLabel}',
              _navy),
          pw.SizedBox(width: 6),
          _statBox(
              biLines((x) => x.crewCertTotal),
              '${units.distanceValue(summary.totalNm).toStringAsFixed(1)} '
                  '${units.distanceLabel}',
              _dgrey),
        ]),
        pw.SizedBox(height: 12),

        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _infoBox(bi((x) => x.crewCertVoyage).toUpperCase(), [
            '${bi((x) => x.pdfVesselLabel)}: ${_pdfText(charter.vesselName ?? '-')}',
            if (_vesselDimensions(charter) != null)
              '${bi((x) => x.crewCertVesselSize)}: ${_vesselDimensions(charter)}',
            if (_vesselRegistration(charter) != null)
              '${bi((x) => x.crewCertVesselRegistration)}: '
                  '${_pdfText(_vesselRegistration(charter)!)}',
            '${bi((x) => x.crewCertArea)}: ${_pdfText(summary.area ?? '-')}',
            '${bi((x) => x.crewCertWatersLabel)}: ${switch (charter.tidalWaters) {
              true => bi((x) => x.crewCertWatersTidal),
              false => bi((x) => x.crewCertWatersNonTidal),
              null => '-',
            }}',
            '${bi((x) => x.crewCertNightHours)}: ${summary.nightHours.toStringAsFixed(1)} h',
            if (charter.route != null) _pdfText(charter.route!),
          ])),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _infoBox(bi((x) => x.crewCertQualifications).toUpperCase(), [
            if (crew.boatLicence != null) _pdfText(crew.boatLicence!),
            if (crew.radioLicence != null) _pdfText(crew.radioLicence!),
            if (crew.otherCerts != null) _pdfText(crew.otherCerts!),
            if (crew.boatLicence == null &&
                crew.radioLicence == null &&
                crew.otherCerts == null)
              '-',
          ])),
        ]),
        pw.SizedBox(height: 10),

        // Doklad totožnosti sa v appke neuchováva — číslo dopíše držiteľ
        // potvrdenia rukou, keď ho niekam predkladá.
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text('${bi((x) => x.crewCertIdDocument)}: ',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(
            child: pw.Container(
              height: 14,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.7)),
              ),
            ),
          ),
        ]),
        pw.SizedBox(height: 14),

        // ── Hodnotenie skipera ──
        // Skiper hodnotí posádku, sám sa nehodnotí — na jeho potvrdení táto
        // sekcia nemá čo robiť.
        if (!crew.isSkipper)
          pw.Text(bi((x) => x.crewCertAssessment).toUpperCase(),
            style: pw.TextStyle(
                color: _navy, fontSize: 9, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
        if (!crew.isSkipper) pw.SizedBox(height: 6),
        if (!crew.isSkipper)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(2)},
            children: [
              for (final (label, value) in skills)
                pw.TableRow(children: [
                  _cell(_pdfText(label)),
                  _cell(value == null ? '-' : '$value / 5'),
                ]),
            ],
          ),
        if (assessment?.note != null && assessment!.note!.trim().isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F7F9FC'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Text(_pdfText(assessment.note!),
                style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
        pw.SizedBox(height: 18),

        // ── Podpis skipera ──
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Expanded(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (skipperSignature != null)
                pw.Container(
                  height: 70,
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Image(pw.MemoryImage(skipperSignature),
                      fit: pw.BoxFit.contain),
                )
              else
                pw.SizedBox(height: 70),
              pw.Container(width: 200, height: 0.7, color: PdfColors.grey600),
              pw.SizedBox(height: 3),
              pw.Text(_pdfText(charter.skipperName ?? bi((x) => x.pdfSkipperSignature)),
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              if (charter.captainQualification != null)
                pw.Text(_pdfText(charter.captainQualification!),
                    style: pw.TextStyle(color: _dgrey, fontSize: 8)),
            ]),
          ),
        ]),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey300),

        // ── Integrita ──
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(bi((x) => x.pdfIntegrityCheck).toUpperCase(),
                  style: pw.TextStyle(
                      color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
              pw.SizedBox(height: 5),
              pw.Text(bi((x) => x.pdfSha256Label),
                  style: pw.TextStyle(color: _dgrey, fontSize: 7.5)),
              pw.SizedBox(height: 3),
              pw.Text(hash.substring(0, 32),
                  style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
              pw.Text(hash.substring(32),
                  style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(bi((x) => x.crewCertHashCoverage),
                  style: pw.TextStyle(color: _dgrey, fontSize: 7)),
            ]),
          ),
          pw.SizedBox(width: 16),
          pw.Column(children: [
            pw.BarcodeWidget(
              barcode: Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium),
              data: qrData,
              width: 80,
              height: 80,
            ),
            pw.SizedBox(height: 3),
            pw.Text(bi((x) => x.pdfVerifyQr),
                style: pw.TextStyle(color: _dgrey, fontSize: 7)),
          ]),
        ]),
      ],
    ));

    return pdf.save();
  }

  static Future<Uint8List> exportMilesCertificate({
    required AppLocalizations l,
    required MilesAggregate aggregate,
    String? signerName,
    required AppDate dateFormat,
  }) async {
    _date = dateFormat;
    final docId = 'HMBSL-MILES-${DateTime.now().year}';
    final fmt = _date;

    final pdf = pw.Document(
      theme: await _theme(),
      title: l.pdfMilesTitle,
      creator: 'HMB Sailing Log',
    );

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              margin: const pw.EdgeInsets.only(bottom: 14),
              decoration: pw.BoxDecoration(color: _navy,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
              child: pw.Text(l.pdfMilesTitle.toUpperCase(), style: pw.TextStyle(
                  color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            )
          : pw.SizedBox(),
      footer: (ctx) => _footer(
        '${l.pdfExportedAt}: ${_date.shortWithTime(DateTime.now().toUtc())} UTC',
        docId: docId, revision: 0,
      ),
      build: (ctx) => [
        pw.Row(children: [
          _statBox(
              '${l.pdfTotalLabel.toUpperCase()} ${units.distanceLabel.toUpperCase()}',
              units.distanceValue(aggregate.totalNm).toStringAsFixed(1), _blue),
          pw.SizedBox(width: 6),
          _statBox(l.pdfStatDaysAtSea.toUpperCase(),
              '${aggregate.daysAtSea}', _green),
          pw.SizedBox(width: 6),
          _statBox(l.pdfStatVoyages.toUpperCase(),
              '${aggregate.voyageCount}', _dgrey),
          pw.SizedBox(width: 6),
          _statBox(l.pdfStatNightHours.toUpperCase(),
              aggregate.nightHours.toStringAsFixed(1), _navy),
        ]),
        pw.SizedBox(height: 16),

        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.8),
            1: const pw.FlexColumnWidth(1.6),
            2: const pw.FlexColumnWidth(1.8),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1.2),
          },
          children: [
            pw.TableRow(decoration: pw.BoxDecoration(color: _navy), children:
              [l.pdfColDateRange, l.pdfVesselLabel, l.pdfColArea, units.distanceLabel, l.pdfColRole].map((h) => _hcell(h)).toList()),
            ...aggregate.voyages.map((v) => pw.TableRow(
              children: [
                _cell('${v.isManualEntry ? "* " : ""}${fmt.short(v.dateFrom)}-${fmt.short(v.dateTo)}'),
                _cell(_pdfText(v.vesselName)),
                _cell(_pdfText(v.area ?? '-')),
                _cell(v.distanceNm.toStringAsFixed(1)),
                _cell(_pdfText(v.role ?? '-')),
              ],
            )),
            pw.TableRow(decoration: pw.BoxDecoration(color: _lblue), children: [
              _cell(l.pdfTotalLabel.toUpperCase(), bold: true), _cell(''), _cell(''),
              _cell(aggregate.totalNm.toStringAsFixed(1), bold: true), _cell(''),
            ]),
          ],
        ),

        if (aggregate.voyages.any((v) => v.isManualEntry)) ...[
          pw.SizedBox(height: 8),
          pw.Text(l.pdfManualEntryNote,
              style: pw.TextStyle(fontSize: 7.5, color: _dgrey)),
        ],

        pw.SizedBox(height: 32),
        pw.Row(children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(width: 200, decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5)))),
            pw.SizedBox(height: 4),
            pw.Text(_pdfText('${l.pdfSignatureLabel}: ${signerName ?? ""}'), style: const pw.TextStyle(fontSize: 8.5)),
          ])),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(width: 150, decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5)))),
            pw.SizedBox(height: 4),
            pw.Text('${l.pdfDateLabel}: ${fmt.short(DateTime.now())}', style: const pw.TextStyle(fontSize: 8.5)),
          ])),
        ]),
      ],
    ));

    return pdf.save();
  }

  static pw.Widget _statBox(String label, String value, PdfColor color) =>
    pw.Expanded(child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Text(value, style: pw.TextStyle(color: PdfColors.white,
            fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Text(label, textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.grey200, fontSize: 7.5)),
      ]),
    ));

  // Hlavičkový cell tabuľky
  static pw.Widget _hcell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
    child: pw.Text(text, style: pw.TextStyle(
        color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 7.5)));

  // Bežný cell (kompaktný)
  static pw.Widget _cell(String text, {bool bold = false, int maxLines = 1}) =>
    pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: pw.Text(text, maxLines: maxLines, overflow: pw.TextOverflow.clip,
          style: pw.TextStyle(fontSize: 8.5,
              fontWeight: bold ? pw.FontWeight.bold : null)));

  // Data cell (menší font pre hutné dáta)
  static pw.Widget _dcell(String text, {double fontSize = 7.5, int maxLines = 1, pw.TextStyle? style}) =>
    pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: pw.Text(text, maxLines: maxLines, overflow: pw.TextOverflow.clip,
          style: style ?? pw.TextStyle(fontSize: fontSize)));

  static pw.Widget _footer(String text, {String? docId, int? revision}) {
    final right = [
      if (docId != null && revision != null) '$docId  |  Rev.$revision',
      'HMB Sailing Log  |  ${_date.short(DateTime.now())}',
    ].join('  |  ');
    return pw.Column(children: [
      pw.Divider(color: _dgrey, thickness: 0.3),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(text, style: pw.TextStyle(color: _dgrey, fontSize: 7)),
        pw.Text(right, style: pw.TextStyle(color: _dgrey, fontSize: 7)),
      ]),
    ]);
  }

  /// Diakritika → ASCII pre PDF
  /// Sunrise, sunset and moon phase for the day, derived from the first entry
  /// that has a position.
  ///
  /// Lives in the export rather than on the day-log screen: it is part of the
  /// record of the day, not something to check while sailing — for that there
  /// is the Weather tab.
  static pw.Widget? _sunMoonBand(
      DateTime day, List<LogbookEntry> entries, AppLocalizations l) {
    final withPos =
        entries.where((e) => e.latitude != null && e.longitude != null);
    if (withPos.isEmpty) return null;
    final first = withPos.first;

    final times = SolarCalculator.sunriseSunsetUtc(
        day, first.latitude!, first.longitude!);
    final phaseNames = [
      l.moonPhaseNew, l.moonPhaseWaxingCrescent, l.moonPhaseFirstQuarter,
      l.moonPhaseWaxingGibbous, l.moonPhaseFull, l.moonPhaseWaningGibbous,
      l.moonPhaseLastQuarter, l.moonPhaseWaningCrescent,
    ];
    final phase = phaseNames[MoonCalculator.phaseIndex(day)];
    final illum = (MoonCalculator.illumination(day) * 100).round();
    final fmt = DateFormat('HH:mm');

    String utc(DateTime? t) => t == null ? '-' : '${fmt.format(t.toUtc())} UTC';

    return pw.Row(children: [
      _wRow('${l.sunriseLabel}:', utc(times.sunrise)),
      pw.SizedBox(width: 14),
      _wRow('${l.sunsetLabel}:', utc(times.sunset)),
      pw.SizedBox(width: 14),
      _wRow('${l.moonPhaseLabel}:', '${_pdfText(phase)}  $illum%'),
    ]);
  }

  /// Who was on duty on this day, one line per person.
  ///
  /// Periods are clipped to the day and marked with arrows when they run past
  /// it, because a duty is stored as a single row even when it crosses
  /// midnight — splitting it would turn one real event into two records.
  static pw.Widget _dutyBand(
      List<DutyPeriod> duties, DateTime day, AppLocalizations l) {
    final localMidnight = DateTime(day.year, day.month, day.day);
    final now = DateTime.now().toUtc();
    final fmt = DateFormat('HH:mm');

    final rows = duties
        .map((d) => clipToDay(d.toInterval(), localMidnight, now))
        .toList()
      ..sort((a, b) => a.fromUtc.compareTo(b.fromUtc));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows.map((c) {
        // UTC, matching the entries table on the same page. .toUtc() is not
        // redundant — drift hands back DateTime objects flagged local, so
        // formatting them directly would print local time as UTC.
        final from = '${c.clippedStart ? '<- ' : ''}'
            '${fmt.format(c.fromUtc.toUtc())}';
        final to = c.duty.isRunning
            ? l.logDutyStillRunning
            : '${fmt.format(c.toUtc.toUtc())}${c.clippedEnd ? ' ->' : ''}';
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 1.5),
          child: pw.Row(children: [
            pw.SizedBox(
              width: 120,
              child: pw.Text(_pdfText(c.duty.crewName),
                  style: const pw.TextStyle(fontSize: 8)),
            ),
            pw.Text('$from - $to',
                style: pw.TextStyle(fontSize: 8, color: _dgrey)),
          ]),
        );
      }).toList(),
    );
  }

  /// Translated label for an automatic entry, or null if it has none.
  ///
  /// Mirrors the day-log screen so the PDF and the app never disagree about
  /// what an entry says. MOB is left as stored — the same word at sea in every
  /// language covered here.
  static String? _eventLabel(
      LogbookEventType? event, String? note, AppLocalizations l) {
    switch (event) {
      case LogbookEventType.voyageStart:
        return l.voyageStart;
      case LogbookEventType.voyageEnd:
        return l.voyageEnd;
      case LogbookEventType.sailChange:
        return l.logEventSailChange;
      case LogbookEventType.anchorDropped:
        return l.logEventAnchorDropped;
      case LogbookEventType.anchorRaised:
        return l.logEventAnchorRaised;
      case LogbookEventType.driftOut:
        return l.logEventDriftOut;
      case LogbookEventType.driftIn:
        return l.logEventDriftIn;
      case LogbookEventType.dutyStart:
        return l.logEventDutyStart(_crewFromNote(note));
      case LogbookEventType.dutyEnd:
        return l.logEventDutyEnd(_crewFromNote(note));
      case LogbookEventType.autopilotOn:
        return l.logEventAutopilotOn(_autopilotModeLabel(note, l));
      case LogbookEventType.autopilotOff:
        return l.logEventAutopilotOff;
      case LogbookEventType.engineStart:
        return l.logEventEngineStart;
      case LogbookEventType.engineStop:
        return l.logEventEngineStop;
      default:
        return null;
    }
  }

  /// Preklad režimu autopilota. V poznámke záznamu stojí strojový kód
  /// ('auto', 'wind', 'track', …), aby sa dal preložiť aj v cudzom jazyku
  /// a v exporte — presne z toho istého dôvodu ako [LogbookEventType].
  static String _autopilotModeLabel(String? mode, AppLocalizations l) {
    switch (mode?.trim()) {
      case 'wind':
        return l.autopilotModeWind;
      case 'track':
        return l.autopilotModeTrack;
      case 'heading':
        return l.autopilotModeHeading;
      case 'rudder':
        return l.autopilotModeRudder;
      case 'standby':
        return l.autopilotModeStandby;
      default:
        return l.autopilotModeAuto;
    }
  }

  /// The crew name carried in a duty note ('Duty start: Ján Novák').
  static String _crewFromNote(String? note) {
    if (note == null) return '';
    final i = note.indexOf(':');
    return i == -1 ? '' : note.substring(i + 1).trim();
  }

  /// Text on its way into the PDF.
  ///
  /// This used to strip diacritics, because the built-in Helvetica could not
  /// draw them. With Noto Sans bundled (see [_theme]) that is no longer true,
  /// so letters, diacritics and Cyrillic now print as written. Do NOT
  /// reintroduce transliteration of letters here.
  ///
  /// Arrows are the exception: Noto Sans has no U+2192/U+2190, and the pdf
  /// package only *warns* about a missing glyph before dropping it, so the
  /// port-to-port heading would have lost the arrow silently. Kept as a single
  /// funnel rather than inlined at 53 call sites.
  static String _pdfText(String s) =>
      s.replaceAll('→', '->').replaceAll('←', '<-');
}
