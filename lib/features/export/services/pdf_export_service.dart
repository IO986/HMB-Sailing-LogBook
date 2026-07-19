import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/database/app_database.dart';
import '../../../core/models/logbook_event_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/skipper_profile.dart';
import '../../miles/services/miles_calculator.dart';
import '../../charter/services/handover_checklist.dart';
import '../../duty/domain/duty_rules.dart';
import '../../duty/providers/duty_provider.dart' show DutyPeriodRules;

class PdfExportService {
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
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
    List<CrewSignature> crewSignatures = const [],
    int pdfRevision = 0,
    HandoverProtocol? checkInProtocol,
    List<ChecklistItem>? checkInChecklist,
    HandoverProtocol? checkOutProtocol,
    List<ChecklistItem>? checkOutChecklist,
  }) async {
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
          docId, rev, l10n, dutiesByDay[day.id] ?? const [])) {
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
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
  }) async {
    final docId = 'HMBSL-${charter.id}-${charter.dateFrom.year}';
    const rev = 0;
    final pdf = pw.Document(theme: await _theme());
    final photos = await _loadPhotos(entries);
    for (final page in _dayPages(charter, day, entries, mapScreenshot, photos, docId, rev,
        l10n, duties)) {
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
        docTitle: '${charter.title} – ${DateFormat('d.M.yyyy').format(day.date)}',
      ));
    }
    return pdf.save();
  }

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
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
    HandoverProtocol? checkInProtocol,
    List<ChecklistItem>? checkInChecklist,
    HandoverProtocol? checkOutProtocol,
    List<ChecklistItem>? checkOutChecklist,
  }) async {
    final bytes = await buildCharterPdfBytes(
      charter: charter, days: days, entriesByDay: entriesByDay,
      mapScreenshots: mapScreenshots, signatureImage: signatureImage,
      l10n: l10n, dutiesByDay: dutiesByDay,
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
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
  }) async {
    final bytes = await buildDayPdfBytes(
      charter: charter, day: day, entries: entries,
      l10n: l10n, duties: duties,
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
    final fmt = DateFormat('d. MMM yyyy');
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
                pw.Text('${fmt.format(charter.dateFrom)} - ${fmt.format(charter.dateTo)}',
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
            if (charter.homePort != null) 'Domovsky pristav: ${_pdfText(charter.homePort!)}',
            if (charter.mmsi != null) 'MMSI: ${charter.mmsi!}',
            if (charter.callsign != null) 'Volaci znak: ${charter.callsign!}',
            if (charter.vesselLengthM != null)
              'Dlzka: ${charter.vesselLengthM!.toStringAsFixed(1)} m',
            if (charter.vesselBeamM != null)
              'Sirka: ${charter.vesselBeamM!.toStringAsFixed(1)} m',
            if (charter.vesselDraftM != null)
              'Ponor: ${charter.vesselDraftM!.toStringAsFixed(1)} m',
          ])),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _infoBox(l.pdfCrewSection.toUpperCase(), [
            if (charter.skipperName != null) '${l.pdfSkipperLabel}: ${_pdfText(charter.skipperName!)}',
            ...crew.map((c) => '- ${_pdfText(c)}'),
            if (crew.isEmpty && charter.skipperName == null) '-',
          ])),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _infoBox('PREHLAD', [
            '${days.length} dni plavby',
            '${totalNm.toStringAsFixed(1)} NM celkom',
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
                  pw.Expanded(child: _wRow('Meno', _pdfText(skipper.fullName))),
                ],
                if (skipper.licenseType.isNotEmpty || skipper.licenseNumber.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    'Licencia',
                    _pdfText('${skipper.licenseType} ${skipper.licenseNumber}'.trim()),
                  )),
                ],
                if (skipper.licenseAuthority.isNotEmpty || skipper.licenseExpiry.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    'Vydal / Plat.',
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
                _wRow('Ine cert.', _pdfText(skipper.otherCerts)),
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
              [l.pdfDateLabel, l.pdfColFrom, l.pdfColTo, 'NM', 'Bft', l.pdfColEntriesShort].map((h) =>
                _hcell(h)).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              return pw.TableRow(decoration: pw.BoxDecoration(
                  color: e.key.isEven ? _lgrey : PdfColors.white), children: [
                _cell(DateFormat('EEE d.M.').format(d.date)),
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
      List<DutyPeriod> duties) {
    final pages = <pw.Page>[];
    final dayName = DateFormat('EEEE d. MMMM yyyy').format(day.date);
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

    pages.add(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [

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
                pw.Text('${day.distanceNm.toStringAsFixed(1)} NM', style: pw.TextStyle(
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

        // ── Službukonajúca posádka ──
        if (duties.isNotEmpty) ...[
          pw.Text(l.logDutySection.toUpperCase(), style: pw.TextStyle(
              color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
          pw.SizedBox(height: 3),
          _dutyBand(duties, day.date, l),
          pw.SizedBox(height: 8),
        ],

        // ── Záznamy ──
        if (sorted.isNotEmpty) ...[
          pw.Text(l.pdfEntriesSection.toUpperCase(), style: pw.TextStyle(
              color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
          pw.SizedBox(height: 3),
          _entriesTable(sorted.take(18).toList(), photos, l),
        ],

        pw.Spacer(),
        _footer('${_pdfText(charter.title)}  |  ${DateFormat('d.M.yyyy').format(day.date)}', docId: docId, revision: revision),
      ]),
    ));

    // ── Pokračovanie ──
    if (sorted.length > 18) {
      final remaining = sorted.skip(18).toList();
      for (int i = 0; i < remaining.length; i += 30) {
        final chunk = remaining.skip(i).take(30).toList();
        pages.add(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
          build: (ctx) => pw.Column(children: [
            pw.Text('${_pdfText(dayName)} – pokracovanie',
                style: pw.TextStyle(color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.SizedBox(height: 8),
            _entriesTable(chunk, photos, l),
            pw.Spacer(),
            _footer('${_pdfText(charter.title)}  |  ${DateFormat('d.M.yyyy').format(day.date)}', docId: docId, revision: revision),
          ]),
        ));
      }
    }
    return pages;
  }

  // ── Entries Table (rozšírená) ─────────────────────────────────

  static pw.Widget _entriesTable(List<LogbookEntry> entries,
      Map<int, Uint8List> photos, AppLocalizations l) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),   // Čas UTC
        1: const pw.FixedColumnWidth(50),   // GPS lat+lon (2 riadky)
        2: const pw.FixedColumnWidth(24),   // SOG kn
        3: const pw.FixedColumnWidth(22),   // COG °
        4: const pw.FixedColumnWidth(34),   // Vietor spd+dir+vlny
        5: const pw.FixedColumnWidth(26),   // hPa
        6: const pw.FixedColumnWidth(24),   // Teplota vzd/voda
        7: const pw.FixedColumnWidth(34),   // Pohon + motor/nadrze
        8: const pw.FixedColumnWidth(22),   // Poč.
        9: const pw.FlexColumnWidth(1),     // Poznámka
      },
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: _blue), children:
          [l.pdfColTimeUtc, 'GPS', 'SOG', 'COG', l.pdfColWind, 'hPa', 'T/°C', l.pdfColPropulsion, l.pdfColWeatherShort, l.pdfColNote]
              .map((h) => _hcell(h)).toList()),
        ...entries.asMap().entries.map((e) {
          final entry = e.value;
          final time = DateFormat('HH:mm').format(entry.timestamp.toUtc());
          String sailMode = '-';
          String noteText = entry.skipperNote ?? '';
          final modeMatch = RegExp(r'^\[([^\]]+)\]\s*').firstMatch(noteText);
          if (modeMatch != null) {
            sailMode = _sailModeLabel(modeMatch.group(1)!);
            noteText = noteText.substring(modeMatch.end);
          }
          // An automatic entry is printed from its event type, so the reader
          // gets it in their own language instead of the stored English.
          final eventLabel = _eventLabel(
              LogbookEventType.resolve(entry.eventType, entry.skipperNote),
              noteText,
              l);
          if (eventLabel != null) noteText = eventLabel;
          // Extract data source tag before stripping auto entries
          String? srcLabel;
          if (noteText.startsWith('Auto') || noteText.startsWith('Automatick')) {
            final srcMatch = RegExp(r'\[([^\]]+)\]').firstMatch(noteText);
            srcLabel = srcMatch?.group(1)?.toUpperCase();
            noteText = '';
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
              _dcell(entry.sog != null ? '${entry.sog!.toStringAsFixed(1)}' : '-'),
              // COG
              _dcell(entry.cog != null ? '${entry.cog!.toStringAsFixed(0)}°' : '-'),
              // Vietor + smer + vlny
              pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  if (entry.windSpeed != null)
                    pw.Text('${entry.windSpeed!.toStringAsFixed(0)}kn',
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
                    pw.Text('${entry.airTemp!.toStringAsFixed(0)}°',
                        style: const pw.TextStyle(fontSize: 7)),
                  if (entry.waterTemp != null)
                    pw.Text('~${entry.waterTemp!.toStringAsFixed(0)}°',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.airTemp == null && entry.waterTemp == null)
                    pw.Text('-', style: const pw.TextStyle(fontSize: 7)),
                ])),
              // Pohon + motor/nadrze
              pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(_pdfText(sailMode), maxLines: 1, overflow: pw.TextOverflow.clip,
                      style: const pw.TextStyle(fontSize: 7.5)),
                  if (entry.engineHours != null)
                    pw.Text('${entry.engineHours!.toStringAsFixed(1)}h',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.fuelLevel != null)
                    pw.Text('P:${entry.fuelLevel}%',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                  if (entry.waterLevel != null)
                    pw.Text('V:${entry.waterLevel}%',
                        style: pw.TextStyle(fontSize: 6.5, color: _dgrey)),
                ])),
              // Počasie
              _dcell(_wcShort(entry.weatherCondition)),
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
                    if (srcLabel != null)
                      pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 2),
                        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: pw.BoxDecoration(
                          color: srcLabel == 'NMEA' ? _blue : _dgrey,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                        ),
                        child: pw.Text(srcLabel,
                            style: pw.TextStyle(color: PdfColors.white,
                                fontSize: 5.5, fontWeight: pw.FontWeight.bold)),
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
          _statBox('CELKOVA\nVZDIALENOST', '${totalNm.toStringAsFixed(1)} NM', _blue),
          pw.SizedBox(width: 6),
          _statBox(l.pdfDayCount.toUpperCase(), '${days.length}', _green),
          pw.SizedBox(width: 6),
          _statBox('ZAZNAMY\nDENNIKA', '$totalEntries', _dgrey),
          pw.SizedBox(width: 6),
          _statBox('MAX\nBEAUFORT', maxBft > 0 ? 'Bft $maxBft' : '-', _navy),
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
              [l.pdfColDay, l.pdfColFrom, l.pdfColTo, 'NM (GPS)', 'Bft', l.pdfColEntriesShort].map((h) => _hcell(h)).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              final cnt = entriesByDay[d.id]?.length ?? 0;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: e.key.isEven ? _lgrey : PdfColors.white),
                children: [
                  _cell(DateFormat('EEE d.M.').format(d.date)),
                  _cell(_pdfText(d.portFrom ?? '-')),
                  _cell(_pdfText(d.portTo ?? '-')),
                  _cell('${d.distanceNm.toStringAsFixed(1)} NM'),
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
              _cell('${totalNm.toStringAsFixed(1)} NM', bold: true),
              _cell(''), _cell('$totalEntries', bold: true),
            ]),
          ],
        ),
        pw.Spacer(),
        _footer(
          'Exportovane: ${DateFormat('d.M.yyyy HH:mm').format(DateTime.now().toUtc())} UTC',
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
                    pw.Text(DateFormat('d.M.yyyy HH:mm').format(sigs[i].signedAt!.toLocal()),
                        style: pw.TextStyle(color: _dgrey, fontSize: 6.5)),
                  ],
                ]),
              ),
          ]),

        pw.Spacer(),
        _footer('${_pdfText(charter.title)}  |  Bezpecnostny briefing', docId: docId, revision: revision),
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
    final timeStr = DateFormat('d.M.yyyy HH:mm:ss').format(signedAt);
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
        pw.Text('Podpisane: $timeStr UTC', style: pw.TextStyle(color: _dgrey, fontSize: 9)),
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
        _footer('${_pdfText(docTitle)}  |  Podpisany $timeStr UTC', docId: docId, revision: revision),
      ]),
    );
  }

  // ── Weather Box ───────────────────────────────────────────────

  static pw.Widget _weatherBox(
      DayLog day, List<LogbookEntry> entries, AppLocalizations l) {
    final rows = <pw.Widget>[];
    if (day.beaufortMorning != null) rows.add(_wRow('Rano', 'Bft ${day.beaufortMorning}'));
    if (day.beaufortNoon != null) rows.add(_wRow('Poludnie', 'Bft ${day.beaufortNoon}'));
    if (day.beaufortEvening != null) rows.add(_wRow('Vecer', 'Bft ${day.beaufortEvening}'));

    if (day.beaufortMorning == null && day.beaufortNoon == null && day.beaufortEvening == null) {
      final withWind = entries.where((e) => e.windSpeed != null).toList();
      if (withWind.isNotEmpty) {
        final avg = withWind.map((e) => e.windSpeed!).reduce((a, b) => a + b) / withWind.length;
        rows.add(_wRow('Vietor', '${avg.toStringAsFixed(1)} kn  Bft ${_windToBeaufort(avg)}'));
      }
    }
    if (day.windDirection != null) {
      rows.add(_wRow('Smer', _pdfText(day.windDirection!)));
    } else {
      final withDir = entries.where((e) => e.windDirection != null).toList();
      if (withDir.isNotEmpty) {
        final avg = withDir.map((e) => e.windDirection!).reduce((a, b) => a + b) / withDir.length;
        rows.add(_wRow('Smer vetra', _degToCompass(avg)));
      }
    }

    // Tlak – z entries
    final withPressure = entries.where((e) => e.airPressure != null).toList();
    if (withPressure.isNotEmpty) {
      final avg = withPressure.map((e) => e.airPressure!).reduce((a, b) => a + b) / withPressure.length;
      rows.add(_wRow('Tlak', '${avg.toStringAsFixed(0)} hPa'));
    }

    if (day.seaState != null) rows.add(_wRow('More', _pdfText(day.seaState!)));
    if (day.waveHeightM != null) {
      rows.add(_wRow('Vlny', '${day.waveHeightM!.toStringAsFixed(1)} m'));
    } else {
      final withWave = entries.where((e) => e.waveHeight != null).toList();
      if (withWave.isNotEmpty) {
        final avg = withWave.map((e) => e.waveHeight!).reduce((a, b) => a + b) / withWave.length;
        rows.add(_wRow('Vlny', '${avg.toStringAsFixed(1)} m'));
      }
    }

    if (day.airTempC != null) {
      rows.add(_wRow('Vzduch', '${day.airTempC!.toStringAsFixed(0)} C'));
    } else {
      final withTemp = entries.where((e) => e.airTemp != null).toList();
      if (withTemp.isNotEmpty) {
        final avg = withTemp.map((e) => e.airTemp!).reduce((a, b) => a + b) / withTemp.length;
        rows.add(_wRow('Vzduch', '${avg.toStringAsFixed(0)} C'));
      }
    }

    if (day.waterTempC != null) {
      rows.add(_wRow('Voda', '${day.waterTempC!.toStringAsFixed(0)} C'));
    } else {
      final withWater = entries.where((e) => e.waterTemp != null).toList();
      if (withWater.isNotEmpty) {
        final avg = withWater.map((e) => e.waterTemp!).reduce((a, b) => a + b) / withWater.length;
        rows.add(_wRow('Voda', '${avg.toStringAsFixed(0)} C'));
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

  static String _wcShort(String? key) {
    if (key == null) return '';
    const map = {
      'sunny': 'Slnk', 'partly_cloudy': 'P-Ob', 'overcast': 'Zamr',
      'light_rain': 'L-Dz', 'rain': 'Dazd', 'heavy_rain': 'H-Dz',
      'drizzle': 'Mrh', 'thunderstorm': 'Burk', 'iso_thunder': 'Bur',
      'hail': 'Krup', 'dust': 'Prac', 'foggy': 'Hmla',
      'windy': 'Vet', 'cold': 'Mraz',
    };
    return map[key] ?? key.substring(0, key.length.clamp(0, 5));
  }

  static String _sailModeLabel(String modes) {
    const map = {
      'motor': 'Motor', 'main': 'Hlavna', 'genoa': 'Genoa',
      'reef1': 'Reef1', 'reef2': 'Reef2',
    };
    return modes.split(',').map((m) => map[m.trim()] ?? m).join('+');
  }

  static int _windToBeaufort(double kn) {
    if (kn < 1) return 0; if (kn < 4) return 1; if (kn < 7) return 2;
    if (kn < 11) return 3; if (kn < 17) return 4; if (kn < 22) return 5;
    if (kn < 28) return 6; if (kn < 34) return 7; if (kn < 41) return 8;
    if (kn < 48) return 9; if (kn < 56) return 10; if (kn < 64) return 11;
    return 12;
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
  }) async {
    final docId = 'HMBSL-HANDOVER-${charter.id}-${protocol.type}';
    final fmt = DateFormat('d.M.yyyy HH:mm');
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
        'Datum/miesto: ${fmt.format(protocol.dateTimeUtc.toLocal())}'
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
    required DateFormat fmt,
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
          title: 'Skipper', name: protocol.skipperName, signature: skipperSig,
          signedAt: protocol.skipperSignedAt, fmt: fmt,
        )),
        pw.SizedBox(width: 16),
        pw.Expanded(child: _handoverSignatureBlock(
          title: l.pdfForCharterCompany,
          name: protocol.companyRepName != null
              ? '${protocol.companyRepName}${protocol.companyName != null ? " (${protocol.companyName})" : ""}'
              : null,
          signature: companySig, signedAt: protocol.companySignedAt, fmt: fmt,
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
    final fmt = DateFormat('d.M.yyyy HH:mm');
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

  static String _handoverStatusLabel(ChecklistStatus s) => switch (s) {
        ChecklistStatus.ok => 'OK',
        ChecklistStatus.damaged => 'Poskodene',
        ChecklistStatus.missing => 'Chyba',
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
            _cell(_handoverStatusLabel(item.status), bold: item.status != ChecklistStatus.ok),
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
    required DateFormat fmt,
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
        pw.Text('Podpisane: ${fmt.format(signedAt.toLocal())}',
            style: pw.TextStyle(fontSize: 7, color: _dgrey)),
    ]);
  }

  // ── Kniha míľ – Potvrdenie o najazdených míľach ──────────────

  static Future<Uint8List> exportMilesCertificate({
    required AppLocalizations l,
    required MilesAggregate aggregate,
    String? signerName,
  }) async {
    final docId = 'HMBSL-MILES-${DateTime.now().year}';
    final fmt = DateFormat('d.M.yyyy');

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
        'Exportovane: ${DateFormat('d.M.yyyy HH:mm').format(DateTime.now().toUtc())} UTC',
        docId: docId, revision: 0,
      ),
      build: (ctx) => [
        pw.Row(children: [
          _statBox('CELKOVE\nNM', aggregate.totalNm.toStringAsFixed(1), _blue),
          pw.SizedBox(width: 6),
          _statBox('DNI NA\nMORI', '${aggregate.daysAtSea}', _green),
          pw.SizedBox(width: 6),
          _statBox('POCET\nPLAVIEB', '${aggregate.voyageCount}', _dgrey),
          pw.SizedBox(width: 6),
          _statBox('NOCNE\nHODINY', aggregate.nightHours.toStringAsFixed(1), _navy),
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
              [l.pdfColDateRange, l.pdfVesselLabel, l.pdfColArea, 'NM', l.pdfColRole].map((h) => _hcell(h)).toList()),
            ...aggregate.voyages.map((v) => pw.TableRow(
              children: [
                _cell('${v.isManualEntry ? "* " : ""}${fmt.format(v.dateFrom)}-${fmt.format(v.dateTo)}'),
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
          pw.Text('* manualny zaznam (zadane rucne)',
              style: pw.TextStyle(fontSize: 7.5, color: _dgrey)),
        ],

        pw.SizedBox(height: 32),
        pw.Row(children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(width: 200, decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5)))),
            pw.SizedBox(height: 4),
            pw.Text(_pdfText('Podpis: ${signerName ?? ""}'), style: const pw.TextStyle(fontSize: 8.5)),
          ])),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(width: 150, decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5)))),
            pw.SizedBox(height: 4),
            pw.Text('Datum: ${fmt.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8.5)),
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
      'HMB Sailing Log  |  ${DateFormat('d.M.yyyy').format(DateTime.now())}',
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
        final from = '${c.clippedStart ? '<- ' : ''}'
            '${fmt.format(c.fromUtc.toLocal())}';
        final to = c.duty.isRunning
            ? l.logDutyStillRunning
            : '${fmt.format(c.toUtc.toLocal())}${c.clippedEnd ? ' ->' : ''}';
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
      default:
        return null;
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
