import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/database/app_database.dart';
import '../../../core/models/skipper_profile.dart';
import '../../miles/services/miles_calculator.dart';
import '../../charter/services/handover_checklist.dart';

class PdfExportService {
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
      title: _ascii(charter.title),
      author: _ascii(charter.skipperName ?? 'HMB Sailing Log'),
      creator: 'HMB Sailing Log',
    );
    final vesselPhoto = await _loadVesselPhoto(charter);
    pdf.addPage(_titlePage(
        charter, days, entriesByDay, skipperProfile, docId, rev, vesselPhoto));
    for (final day in days) {
      final entries = entriesByDay[day.id] ?? [];
      final photos = await _loadPhotos(entries);
      for (final page in _dayPages(charter, day, entries, mapScreenshots[day.id], photos, docId, rev)) {
        pdf.addPage(page);
      }
    }
    pdf.addPage(_summaryPage(charter, days, entriesByDay, docId, rev));
    final sbPage = await _safetyBriefingPage(charter, crewSignatures, docId, rev);
    pdf.addPage(sbPage);

    if (checkInProtocol != null && checkInChecklist != null) {
      pdf.addPage(await _handoverProtocolPage(
          charter: charter, protocol: checkInProtocol, checklist: checkInChecklist,
          docId: docId, revision: rev));
    }
    if (checkOutProtocol != null && checkOutChecklist != null) {
      pdf.addPage(await _handoverProtocolPage(
          charter: charter, protocol: checkOutProtocol, checklist: checkOutChecklist,
          docId: docId, revision: rev));
    }

    if (signatureImage != null) {
      final canonical = _buildCanonical(
          charter: charter, days: days, entriesByDay: entriesByDay,
          docId: docId, revision: rev);
      final hash = sha256.convert(utf8.encode(canonical)).toString();
      pdf.addPage(_signaturePage(
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
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
  }) async {
    final docId = 'HMBSL-${charter.id}-${charter.dateFrom.year}';
    const rev = 0;
    final pdf = pw.Document();
    final photos = await _loadPhotos(entries);
    for (final page in _dayPages(charter, day, entries, mapScreenshot, photos, docId, rev)) {
      pdf.addPage(page);
    }
    if (signatureImage != null) {
      final canonical = _buildCanonical(
        charter: charter, days: [day], entriesByDay: {day.id: entries},
        docId: docId, revision: rev);
      final hash = sha256.convert(utf8.encode(canonical)).toString();
      pdf.addPage(_signaturePage(
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
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
    SkipperProfile? skipperProfile,
  }) async {
    final bytes = await buildDayPdfBytes(
      charter: charter, day: day, entries: entries,
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

  /// Prvá fotka lode z karty lode (Charters.photosJson), ak je nahratá.
  static Future<pw.MemoryImage?> _loadVesselPhoto(Charter charter) async {
    final json = charter.photosJson;
    if (json == null || json.isEmpty) return null;
    try {
      final paths =
          (jsonDecode(json) as List).map((e) => e.toString()).toList();
      if (paths.isEmpty) return null;
      final file = File(paths.first);
      if (!await file.exists()) return null;
      return pw.MemoryImage(await file.readAsBytes());
    } catch (_) {
      return null;
    }
  }

  static pw.Page _titlePage(Charter charter, List<DayLog> days,
      Map<int, List<LogbookEntry>> entriesByDay, SkipperProfile? skipper,
      String docId, int revision, pw.MemoryImage? vesselPhoto) {
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
                pw.Text(_ascii(charter.title), style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 3),
                pw.Text('${fmt.format(charter.dateFrom)} - ${fmt.format(charter.dateTo)}',
                    style: pw.TextStyle(color: PdfColors.grey200, fontSize: 12)),
              ]),
            ),
            if (vesselPhoto != null) ...[
              pw.SizedBox(width: 12),
              pw.ClipRRect(
                horizontalRadius: 4,
                verticalRadius: 4,
                child: pw.Image(vesselPhoto,
                    width: 110, height: 74, fit: pw.BoxFit.cover),
              ),
            ],
          ]),
        ),
        pw.SizedBox(height: 14),

        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _infoBox('LOD', [
            _ascii(charter.vesselName ?? '-'),
            if (charter.vesselType != null) _ascii(charter.vesselType!),
            if (charter.homePort != null) 'Domovsky pristav: ${_ascii(charter.homePort!)}',
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
          pw.Expanded(child: _infoBox('POSADKA', [
            if (charter.skipperName != null) 'Kapitan: ${_ascii(charter.skipperName!)}',
            ...crew.map((c) => '- ${_ascii(c)}'),
            if (crew.isEmpty && charter.skipperName == null) '-',
          ])),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _infoBox('PREHLAD', [
            '${days.length} dni plavby',
            '${totalNm.toStringAsFixed(1)} NM celkom',
            if (charter.notes != null) _ascii(charter.notes!),
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
              pw.Text('SKIPPER – LICENCIE', style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                if (skipper.fullName.isNotEmpty) ...[
                  pw.Expanded(child: _wRow('Meno', _ascii(skipper.fullName))),
                ],
                if (skipper.licenseType.isNotEmpty || skipper.licenseNumber.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    'Licencia',
                    _ascii('${skipper.licenseType} ${skipper.licenseNumber}'.trim()),
                  )),
                ],
                if (skipper.licenseAuthority.isNotEmpty || skipper.licenseExpiry.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    'Vydal / Plat.',
                    _ascii('${skipper.licenseAuthority}  ${skipper.licenseExpiry}'.trim()),
                  )),
                ],
                if (skipper.vhfNumber.isNotEmpty || skipper.vhfExpiry.isNotEmpty) ...[
                  pw.Expanded(child: _wRow(
                    'VHF/SRC',
                    _ascii('${skipper.vhfNumber}  ${skipper.vhfExpiry}'.trim()),
                  )),
                ],
              ]),
              if (skipper.otherCerts.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                _wRow('Ine cert.', _ascii(skipper.otherCerts)),
              ],
            ]),
          ),
          pw.SizedBox(height: 10),
        ],

        pw.Text('PREHLAD DNI', style: pw.TextStyle(color: _navy,
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
              ['Datum', 'Odkial', 'Kam', 'NM', 'Bft', 'Zazn.'].map((h) =>
                _hcell(h)).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              return pw.TableRow(decoration: pw.BoxDecoration(
                  color: e.key.isEven ? _lgrey : PdfColors.white), children: [
                _cell(DateFormat('EEE d.M.').format(d.date)),
                _cell(_ascii(d.portFrom ?? '-')),
                _cell(_ascii(d.portTo ?? '-')),
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
        _footer(_ascii(charter.title), docId: docId, revision: revision),
      ]),
    );
  }

  // ── Day Pages ─────────────────────────────────────────────────

  static List<pw.Page> _dayPages(Charter charter, DayLog day,
      List<LogbookEntry> entries, Uint8List? screenshot, Map<int, Uint8List> photos,
      String docId, int revision) {
    final pages = <pw.Page>[];
    final dayName = DateFormat('EEEE d. MMMM yyyy').format(day.date);
    final crew = (charter.crewNames ?? '').split('|').where((s) => s.isNotEmpty).toList();

    // Sort entries by time
    final sorted = [...entries]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Voyage start/end entries
    final voyageStart = sorted.where((e) {
      final n = e.skipperNote ?? '';
      return n.contains('voyageStart') || n.contains('Začiatok plavby') || n.contains('Start voyage');
    }).toList();
    final voyageEnd = sorted.where((e) {
      final n = e.skipperNote ?? '';
      return n.contains('voyageEnd') || n.contains('Koniec plavby') || n.contains('End voyage');
    }).toList();

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
              pw.Text(_ascii(dayName), style: pw.TextStyle(
                  color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 13)),
              pw.SizedBox(height: 2),
              pw.Text('${_ascii(day.portFrom ?? "?")} → ${_ascii(day.portTo ?? "?")}',
                  style: pw.TextStyle(color: PdfColors.grey200, fontSize: 10)),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              if (day.distanceNm > 0)
                pw.Text('${day.distanceNm.toStringAsFixed(1)} NM', style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              if (voyageStart.isNotEmpty)
                pw.Text('ODCHOD ${DateFormat('HH:mm').format(voyageStart.first.timestamp.toUtc())} UTC',
                    style: pw.TextStyle(color: PdfColors.green200, fontSize: 8)),
              if (voyageEnd.isNotEmpty)
                pw.Text('PRICHOD ${DateFormat('HH:mm').format(voyageEnd.last.timestamp.toUtc())} UTC',
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
              pw.Text('Lod: ', style: pw.TextStyle(color: _dgrey, fontSize: 8)),
              pw.Text(_ascii(charter.vesselName!),
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 12),
            ],
            if (charter.skipperName != null) ...[
              pw.Text('Kapitan: ', style: pw.TextStyle(color: _dgrey, fontSize: 8)),
              pw.Text(_ascii(charter.skipperName!),
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 12),
            ],
            if (crew.isNotEmpty) ...[
              pw.Text('Posadka: ', style: pw.TextStyle(color: _dgrey, fontSize: 8)),
              pw.Text(crew.map(_ascii).join(', '),
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
                : pw.Center(child: pw.Text('GPS mapa nedostupna',
                    style: pw.TextStyle(color: _dgrey, fontSize: 9))),
          )),
          pw.SizedBox(width: 8),
          pw.Expanded(flex: 2, child: _weatherBox(day, sorted)),
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
              pw.Text('SPRAVA SKIPPERA', style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
              pw.SizedBox(height: 3),
              pw.Text(_ascii(day.skipperNote!), style: const pw.TextStyle(fontSize: 9)),
            ]),
          ),
          pw.SizedBox(height: 6),
        ],

        // ── Záznamy ──
        if (sorted.isNotEmpty) ...[
          pw.Text('ZAZNAMY DENNIKA', style: pw.TextStyle(
              color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
          pw.SizedBox(height: 3),
          _entriesTable(sorted.take(18).toList(), photos),
        ],

        pw.Spacer(),
        _footer('${_ascii(charter.title)}  |  ${DateFormat('d.M.yyyy').format(day.date)}', docId: docId, revision: revision),
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
            pw.Text('${_ascii(dayName)} – pokracovanie',
                style: pw.TextStyle(color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.SizedBox(height: 8),
            _entriesTable(chunk, photos),
            pw.Spacer(),
            _footer('${_ascii(charter.title)}  |  ${DateFormat('d.M.yyyy').format(day.date)}', docId: docId, revision: revision),
          ]),
        ));
      }
    }
    return pages;
  }

  // ── Entries Table (rozšírená) ─────────────────────────────────

  static pw.Widget _entriesTable(List<LogbookEntry> entries, Map<int, Uint8List> photos) {
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
          ['Cas UTC', 'GPS', 'SOG', 'COG', 'Vietor', 'hPa', 'T/°C', 'Pohon', 'Poc.', 'Poznamka']
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
                  pw.Text(_ascii(sailMode), maxLines: 1, overflow: pw.TextOverflow.clip,
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
                      pw.Text(_ascii(noteText),
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
      Map<int, List<LogbookEntry>> entriesByDay, String docId, int revision) {
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
          child: pw.Text('ZAVERECNY PREHLAD PLAVBY', style: pw.TextStyle(
              color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 14),

        pw.Row(children: [
          _statBox('CELKOVA\nVZDIALENOST', '${totalNm.toStringAsFixed(1)} NM', _blue),
          pw.SizedBox(width: 6),
          _statBox('POCET DNI', '${days.length}', _green),
          pw.SizedBox(width: 6),
          _statBox('ZAZNAMY\nDENNIKA', '$totalEntries', _dgrey),
          pw.SizedBox(width: 6),
          _statBox('MAX\nBEAUFORT', maxBft > 0 ? 'Bft $maxBft' : '-', _navy),
        ]),
        pw.SizedBox(height: 14),

        pw.Text('DENNY PREHLAD', style: pw.TextStyle(
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
              ['Den', 'Odkial', 'Kam', 'NM (GPS)', 'Bft', 'Zaz.'].map((h) => _hcell(h)).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              final cnt = entriesByDay[d.id]?.length ?? 0;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: e.key.isEven ? _lgrey : PdfColors.white),
                children: [
                  _cell(DateFormat('EEE d.M.').format(d.date)),
                  _cell(_ascii(d.portFrom ?? '-')),
                  _cell(_ascii(d.portTo ?? '-')),
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
              _cell('SPOLU', bold: true), _cell(''), _cell(''),
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

  static const _sbItems = [
    'Zachranne vesty – umiestnenie a pouzitie',
    'Zachranny kruh a MOB postup',
    'Svetlice – typy a pouzitie',
    'EPIRB / PLB – aktivacia',
    'VHF radio – kanal 16, Mayday postup',
    'Hasiaci pristroj – umiestnenie a pouzitie',
    'Lekarnička – umiestnenie',
    'Nuzove vypnutie motora',
    'Uniky – voda, plyn',
    'Kotva a retaz – postup kotvenia',
    'Pravidla na palube',
    'Nuzove kontakty a VHF 16',
  ];

  static Future<pw.Page> _safetyBriefingPage(
      Charter charter, List<CrewSignature> sigs, String docId, int revision) async {
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
            pw.Text('BEZPECNOSTNY BRIEFING', style: pw.TextStyle(
                color: PdfColors.white, fontSize: 9, letterSpacing: 2,
                fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 3),
            pw.Text(_ascii(charter.title),
                style: pw.TextStyle(color: PdfColors.grey200, fontSize: 11)),
          ]),
        ),
        pw.SizedBox(height: 12),

        // Checklist in 2 columns
        pw.Text('CHECKLIST', style: pw.TextStyle(
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
              (_sbItems.length / 2).ceil(),
              (row) {
                final left = _sbItems[row * 2];
                final rightIdx = row * 2 + 1;
                final right = rightIdx < _sbItems.length ? _sbItems[rightIdx] : null;
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
        pw.Text('PODPISY POSADKY', style: pw.TextStyle(
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
            'Vsetci clenovia posadky boli oboznameni a porozumeli bezpecnostnym '
            'pravidlam. Potvrdzuju to podpisom.',
            style: pw.TextStyle(fontSize: 8.5, fontStyle: pw.FontStyle.italic),
          ),
        ),
        pw.SizedBox(height: 10),

        if (sigs.isEmpty)
          pw.Text('Ziadne podpisy', style: pw.TextStyle(color: _dgrey, fontSize: 9))
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
                  pw.Text(_ascii(sigs[i].crewName),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  pw.Text(sigs[i].role == 'skipper' ? 'Kapitan' : 'Posadka',
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
                        : pw.Center(child: pw.Text('Nepodpisane',
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
        _footer('${_ascii(charter.title)}  |  Bezpecnostny briefing', docId: docId, revision: revision),
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
        pw.Expanded(child: pw.Text(_ascii(text), style: const pw.TextStyle(fontSize: 8))),
      ]),
    );
  }

  // ── Signature Page ────────────────────────────────────────────

  static pw.Page _signaturePage({
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
        '|signer:${_ascii(signerName ?? "Skipper")}'
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
            pw.Text('PODPIS SKIPPERA', style: pw.TextStyle(
                color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
            pw.SizedBox(height: 3),
            pw.Text(_ascii(docTitle), style: pw.TextStyle(color: PdfColors.grey200, fontSize: 12)),
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
          pw.Text(_ascii(signerName), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.Text('Podpisane: $timeStr UTC', style: pw.TextStyle(color: _dgrey, fontSize: 9)),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 12),
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('OVERENIE INTEGRITY DOKUMENTU', style: pw.TextStyle(
                color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 8, letterSpacing: 1)),
            pw.SizedBox(height: 6),
            pw.Text('SHA-256 odtlacok dat dennika:',
                style: pw.TextStyle(color: _dgrey, fontSize: 7.5)),
            pw.SizedBox(height: 3),
            pw.Text(hash.substring(0, 32), style: pw.TextStyle(
                fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C3E50'))),
            pw.Text(hash.substring(32), style: pw.TextStyle(
                fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C3E50'))),
            pw.SizedBox(height: 8),
            pw.Text('Odtlacok pokryva nazov plavby, lod, posadku a vsetky '
                'zaznamy (cas UTC, GPS, rychlost, kurz). Akakolvek zmena dat zmeni odtlacok.',
                style: pw.TextStyle(color: _dgrey, fontSize: 7)),
          ])),
          pw.SizedBox(width: 20),
          pw.Column(children: [
            pw.BarcodeWidget(
              barcode: Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium),
              data: qrData, width: 90, height: 90,
            ),
            pw.SizedBox(height: 4),
            pw.Text('Overovaci QR', style: pw.TextStyle(color: _dgrey, fontSize: 7)),
          ]),
        ]),
        pw.Spacer(),
        _footer('${_ascii(docTitle)}  |  Podpisany $timeStr UTC', docId: docId, revision: revision),
      ]),
    );
  }

  // ── Weather Box ───────────────────────────────────────────────

  static pw.Widget _weatherBox(DayLog day, List<LogbookEntry> entries) {
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
      rows.add(_wRow('Smer', _ascii(day.windDirection!)));
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

    if (day.seaState != null) rows.add(_wRow('More', _ascii(day.seaState!)));
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

    if (rows.isEmpty) rows.add(pw.Text('Bez udajov', style: pw.TextStyle(color: _dgrey, fontSize: 8)));

    return pw.Container(
      height: 120,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(color: _lblue,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('POCASIE', style: pw.TextStyle(color: _navy,
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
      title: 'Odovzdavaci protokol $typeLabel',
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
                pw.Text('ODOVZDAVACI PROTOKOL - $typeLabel', style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(_ascii('${charter.title}  |  ${charter.vesselName ?? "-"}'
                    '  |  ${charter.callsign ?? charter.mmsi ?? ""}'),
                    style: pw.TextStyle(color: PdfColors.grey200, fontSize: 9)),
              ]),
            )
          : pw.SizedBox(),
      footer: (ctx) => _footer(
        'Datum/miesto: ${fmt.format(protocol.dateTimeUtc.toLocal())}'
        '${protocol.location != null ? "  |  ${_ascii(protocol.location!)}" : ""}',
        docId: docId, revision: 0,
      ),
      build: (ctx) => _handoverProtocolContent(
        protocol: protocol, checklist: checklist, thumbnails: thumbnails,
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
    required HandoverProtocol protocol,
    required List<ChecklistItem> checklist,
    required Map<String, Uint8List> thumbnails,
    required Uint8List? skipperSig,
    required Uint8List? companySig,
    required DateFormat fmt,
  }) {
    return [
      pw.Row(children: [
        _statBox('MOTOHODINY', protocol.engineHours?.toStringAsFixed(1) ?? '-', _navy),
        pw.SizedBox(width: 6),
        _statBox('PALIVO', protocol.fuelLevel != null ? '${protocol.fuelLevel}%' : '-', _blue),
        pw.SizedBox(width: 6),
        _statBox('VODA', protocol.waterLevel != null ? '${protocol.waterLevel}%' : '-', _green),
      ]),
      pw.SizedBox(height: 16),

      pw.Text('KONTROLNY ZOZNAM', style: pw.TextStyle(
          color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 10, letterSpacing: 1)),
      pw.SizedBox(height: 6),
      _handoverChecklistTable(checklist, thumbnails),

      if (protocol.extraNotes != null && protocol.extraNotes!.isNotEmpty) ...[
        pw.SizedBox(height: 12),
        pw.Text('DALSIE POZNAMKY', style: pw.TextStyle(
            color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 9, letterSpacing: 1)),
        pw.SizedBox(height: 4),
        pw.Text(_ascii(protocol.extraNotes!), style: const pw.TextStyle(fontSize: 9)),
      ],

      pw.SizedBox(height: 32),
      pw.Text('PODPISY', style: pw.TextStyle(
          color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 10, letterSpacing: 1)),
      pw.SizedBox(height: 8),
      pw.Row(children: [
        pw.Expanded(child: _handoverSignatureBlock(
          title: 'Skipper', name: protocol.skipperName, signature: skipperSig,
          signedAt: protocol.skipperSignedAt, fmt: fmt,
        )),
        pw.SizedBox(width: 16),
        pw.Expanded(child: _handoverSignatureBlock(
          title: 'Za charterovu spolocnost',
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
              child: pw.Text('ODOVZDAVACI PROTOKOL - $typeLabel', style: pw.TextStyle(
                  color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            )
          : pw.SizedBox(),
      footer: (ctx) => _footer(_ascii(charter.title), docId: docId, revision: revision),
      build: (ctx) => _handoverProtocolContent(
        protocol: protocol, checklist: checklist, thumbnails: thumbnails,
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
  static pw.Widget _handoverChecklistTable(
      List<ChecklistItem> checklist, Map<String, Uint8List> thumbnails) {
    final byKey = {for (final i in checklist) i.itemKey: i};
    final rows = <pw.TableRow>[
      pw.TableRow(decoration: pw.BoxDecoration(color: _navy), children:
        ['Polozka', 'Stav', 'Poznamka / poloha', 'Foto'].map((h) => _hcell(h)).toList()),
    ];

    for (final category in [...checkInCategories, ...checkOutCategories]) {
      final items = category.items.map((d) => byKey[d.key]).whereType<ChecklistItem>().toList();
      if (items.isEmpty) continue;

      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue50),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: pw.Text(_ascii(category.labelSk),
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
            _cell(_ascii(label)),
            _cell(_handoverStatusLabel(item.status), bold: item.status != ChecklistStatus.ok),
            _cell(_ascii(noteParts.join(' '))),
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
      pw.Text(_ascii(title), style: pw.TextStyle(fontSize: 8, color: _dgrey, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      if (signature != null)
        pw.Image(pw.MemoryImage(signature), height: 50, fit: pw.BoxFit.contain, alignment: pw.Alignment.centerLeft)
      else
        pw.Container(height: 50, alignment: pw.Alignment.centerLeft,
            child: pw.Text('-', style: const pw.TextStyle(fontSize: 8))),
      pw.Container(decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.5)))),
      pw.SizedBox(height: 4),
      pw.Text(_ascii(name ?? '-'), style: const pw.TextStyle(fontSize: 8.5)),
      if (signedAt != null)
        pw.Text('Podpisane: ${fmt.format(signedAt.toLocal())}',
            style: pw.TextStyle(fontSize: 7, color: _dgrey)),
    ]);
  }

  // ── Kniha míľ – Potvrdenie o najazdených míľach ──────────────

  static Future<Uint8List> exportMilesCertificate({
    required MilesAggregate aggregate,
    String? signerName,
  }) async {
    final docId = 'HMBSL-MILES-${DateTime.now().year}';
    final fmt = DateFormat('d.M.yyyy');

    final pdf = pw.Document(
      title: 'Potvrdenie o najazdenych miliach',
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
              child: pw.Text('POTVRDENIE O NAJAZDENYCH MILIACH', style: pw.TextStyle(
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
              ['Datum od-do', 'Lod', 'Oblast', 'NM', 'Rola'].map((h) => _hcell(h)).toList()),
            ...aggregate.voyages.map((v) => pw.TableRow(
              children: [
                _cell('${v.isManualEntry ? "* " : ""}${fmt.format(v.dateFrom)}-${fmt.format(v.dateTo)}'),
                _cell(_ascii(v.vesselName)),
                _cell(_ascii(v.area ?? '-')),
                _cell(v.distanceNm.toStringAsFixed(1)),
                _cell(_ascii(v.role ?? '-')),
              ],
            )),
            pw.TableRow(decoration: pw.BoxDecoration(color: _lblue), children: [
              _cell('SPOLU', bold: true), _cell(''), _cell(''),
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
            pw.Text(_ascii('Podpis: ${signerName ?? ""}'), style: const pw.TextStyle(fontSize: 8.5)),
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
  static String _ascii(String s) => s
    .replaceAll('á','a').replaceAll('ä','a').replaceAll('č','c').replaceAll('ď','d')
    .replaceAll('é','e').replaceAll('í','i').replaceAll('ĺ','l').replaceAll('ľ','l')
    .replaceAll('ň','n').replaceAll('ó','o').replaceAll('ô','o').replaceAll('ŕ','r')
    .replaceAll('š','s').replaceAll('ť','t').replaceAll('ú','u').replaceAll('ý','y')
    .replaceAll('ž','z').replaceAll('Á','A').replaceAll('Č','C').replaceAll('Ď','D')
    .replaceAll('É','E').replaceAll('Í','I').replaceAll('Ľ','L').replaceAll('Ň','N')
    .replaceAll('Ó','O').replaceAll('Š','S').replaceAll('Ť','T').replaceAll('Ú','U')
    .replaceAll('Ý','Y').replaceAll('Ž','Z').replaceAll('→','->').replaceAll('·','.')
    .replaceAll('©','(c)').replaceAll('–','-').replaceAll('°','°');
}
