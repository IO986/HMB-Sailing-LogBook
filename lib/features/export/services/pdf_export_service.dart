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

class PdfExportService {
  static final _navy   = PdfColor.fromHex('#0A2342');
  static final _blue   = PdfColor.fromHex('#1A5276');
  static final _lgrey  = PdfColor.fromHex('#F2F3F4');
  static final _dgrey  = PdfColor.fromHex('#7F8C8D');
  static final _green  = PdfColor.fromHex('#1E8449');
  static final _lblue  = PdfColor.fromHex('#D6EAF8');

  /// Vráti bajty PDF bez uloženia na disk – pre náhľad.
  static Future<Uint8List> buildCharterPdfBytes({
    required Charter charter,
    required List<DayLog> days,
    required Map<int, List<LogbookEntry>> entriesByDay,
    required Map<int, Uint8List?> mapScreenshots,
    Uint8List? signatureImage,
  }) async {
    final pdf = pw.Document(
      title: _ascii(charter.title),
      author: _ascii(charter.skipperName ?? 'HMB Sailing Log'),
      creator: 'HMB Sailing Log',
    );
    pdf.addPage(_titlePage(charter, days));
    for (final day in days) {
      final entries = entriesByDay[day.id] ?? [];
      final screenshot = mapScreenshots[day.id];
      for (final page in _dayPages(charter, day, entries, screenshot)) {
        pdf.addPage(page);
      }
    }
    pdf.addPage(_summaryPage(charter, days, entriesByDay));
    if (signatureImage != null) {
      final canonical = _buildCanonical(charter: charter, days: days, entriesByDay: entriesByDay);
      final hash = sha256.convert(utf8.encode(canonical)).toString();
      pdf.addPage(_signaturePage(
        signatureImage: signatureImage,
        signerName: charter.skipperName,
        signedAt: DateTime.now().toUtc(),
        hash: hash,
        docTitle: charter.title,
      ));
    }
    return pdf.save();
  }

  /// Vráti bajty PDF pre deň bez uloženia na disk – pre náhľad.
  static Future<Uint8List> buildDayPdfBytes({
    required Charter charter,
    required DayLog day,
    required List<LogbookEntry> entries,
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
  }) async {
    final pdf = pw.Document();
    for (final page in _dayPages(charter, day, entries, mapScreenshot)) {
      pdf.addPage(page);
    }
    if (signatureImage != null) {
      final canonical = _buildCanonical(
        charter: charter, days: [day], entriesByDay: {day.id: entries});
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

  /// Uloží bajty PDF na disk a vráti súbor.
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
  }) async {
    final bytes = await buildCharterPdfBytes(
      charter: charter, days: days, entriesByDay: entriesByDay,
      mapScreenshots: mapScreenshots, signatureImage: signatureImage);
    return saveBytesToFile(bytes, 'charter_${charter.id}');
  }

  static Future<File> exportDay({
    required Charter charter,
    required DayLog day,
    required List<LogbookEntry> entries,
    Uint8List? mapScreenshot,
    Uint8List? signatureImage,
  }) async {
    final bytes = await buildDayPdfBytes(
      charter: charter, day: day, entries: entries,
      mapScreenshot: mapScreenshot, signatureImage: signatureImage);
    return saveBytesToFile(bytes, 'day_${day.id}');
  }

  // ── Kanonické dáta pre hash ───────────────────────────────────

  static String _buildCanonical({
    required Charter charter,
    required List<DayLog> days,
    required Map<int, List<LogbookEntry>> entriesByDay,
  }) {
    final sb = StringBuffer();
    sb.writeln('HMB-SAILING-LOG:v1');
    sb.writeln('title:${charter.title}');
    sb.writeln('vessel:${charter.vesselName ?? ""}');
    sb.writeln('skipper:${charter.skipperName ?? ""}');
    sb.writeln('from:${charter.dateFrom.toUtc().toIso8601String()}');
    sb.writeln('to:${charter.dateTo.toUtc().toIso8601String()}');
    for (final day in days) {
      sb.writeln('---');
      sb.writeln('day:${day.date.toUtc().toIso8601String().substring(0, 10)}');
      sb.writeln('port_from:${day.portFrom ?? ""}');
      sb.writeln('port_to:${day.portTo ?? ""}');
      sb.writeln('nm:${day.distanceNm.toStringAsFixed(3)}');
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

  static pw.Page _titlePage(Charter charter, List<DayLog> days) {
    final fmt = DateFormat('d. MMM yyyy');
    final crew = (charter.crewNames ?? '').split('|').where((s) => s.isNotEmpty).toList();
    final totalNm = days.fold<double>(0, (s, d) => s + d.distanceNm);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('HMB SAILING LOG', style: pw.TextStyle(
                color: PdfColors.white, fontSize: 11, letterSpacing: 3)),
            pw.SizedBox(height: 8),
            pw.Text(_ascii(charter.title), style: pw.TextStyle(
                color: PdfColors.white, fontSize: 26, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('${fmt.format(charter.dateFrom)} - ${fmt.format(charter.dateTo)}',
                style: pw.TextStyle(color: PdfColors.grey200, fontSize: 13)),
          ]),
        ),
        pw.SizedBox(height: 20),

        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: _infoBox('LODE', [
            _ascii(charter.vesselName ?? '-'),
            if (charter.vesselType != null) _ascii(charter.vesselType!),
            if (charter.homePort != null) 'Domovsky pristav: ${_ascii(charter.homePort!)}',
          ])),
          pw.SizedBox(width: 10),
          pw.Expanded(child: _infoBox('POSADKA', [
            if (charter.skipperName != null) 'Kapitan: ${_ascii(charter.skipperName!)}',
            ...crew.map((c) => '- ${_ascii(c)}'),
            if (crew.isEmpty && charter.skipperName == null) '-',
          ])),
          pw.SizedBox(width: 10),
          pw.Expanded(child: _infoBox('PREHLAD', [
            '${days.length} dni plavby',
            '${totalNm.toStringAsFixed(1)} NM celkom',
            if (charter.notes != null) _ascii(charter.notes!),
          ])),
        ]),
        pw.SizedBox(height: 20),

        pw.Text('PREHLAD DNI', style: pw.TextStyle(color: _navy,
            fontWeight: pw.FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(decoration: pw.BoxDecoration(color: _navy), children:
              ['Datum', 'Odkial', 'Kam', 'NM', 'Bft', 'Zazn.'].map((h) =>
                pw.Padding(padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(h, style: pw.TextStyle(
                      color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)))).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              final bg = e.key.isEven ? _lgrey : PdfColors.white;
              return pw.TableRow(decoration: pw.BoxDecoration(color: bg), children: [
                _cell(DateFormat('EEE d.M.').format(d.date), fontSize: 9),
                _cell(_ascii(d.portFrom ?? '-'), fontSize: 9),
                _cell(_ascii(d.portTo ?? '-'), fontSize: 9),
                _cell('${d.distanceNm.toStringAsFixed(1)}', fontSize: 9),
                _cell(d.beaufortNoon != null ? 'Bft ${d.beaufortNoon}' : '-', fontSize: 9),
                _cell('-', fontSize: 9),
              ]);
            }),
          ],
        ),
        pw.Spacer(),
        _footer(_ascii(charter.title)),
      ]),
    );
  }

  // ── Day Pages ─────────────────────────────────────────────────

  static List<pw.Page> _dayPages(Charter charter, DayLog day,
      List<LogbookEntry> entries, Uint8List? screenshot) {
    final pages = <pw.Page>[];
    final dayName = DateFormat('EEEE d. MMMM yyyy').format(day.date);
    final crew = (charter.crewNames ?? '').split('|').where((s) => s.isNotEmpty).toList();

    pages.add(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(color: _blue,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(_ascii(dayName), style: pw.TextStyle(
                  color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 15)),
              pw.SizedBox(height: 3),
              pw.Text('${_ascii(day.portFrom ?? "?")} - ${_ascii(day.portTo ?? "?")}',
                  style: pw.TextStyle(color: PdfColors.grey200, fontSize: 12)),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              if (day.distanceNm > 0)
                pw.Text('${day.distanceNm.toStringAsFixed(1)} NM', style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
              if (day.vesselForDay != null)
                pw.Text(_ascii(day.vesselForDay!),
                    style: pw.TextStyle(color: PdfColors.grey200, fontSize: 10)),
            ]),
          ]),
        ),
        pw.SizedBox(height: 6),

        // Vessel / skipper / crew info bar
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(color: _lgrey,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
          child: pw.Row(children: [
            if (charter.vesselName != null) ...[
              pw.Text('Lod: ', style: pw.TextStyle(color: _dgrey, fontSize: 9)),
              pw.Text(_ascii(charter.vesselName!),
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 14),
            ],
            if (charter.skipperName != null) ...[
              pw.Text('Kapitan: ', style: pw.TextStyle(color: _dgrey, fontSize: 9)),
              pw.Text(_ascii(charter.skipperName!),
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 14),
            ],
            if (crew.isNotEmpty) ...[
              pw.Text('Posadka: ', style: pw.TextStyle(color: _dgrey, fontSize: 9)),
              pw.Text(crew.map(_ascii).join(', '),
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ],
          ]),
        ),
        pw.SizedBox(height: 8),

        // Mapa + počasie
        pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(flex: 3, child: pw.Container(
            height: 180,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
            child: screenshot != null
                ? pw.ClipRRect(horizontalRadius: 6, verticalRadius: 6,
                    child: pw.Image(pw.MemoryImage(screenshot), fit: pw.BoxFit.cover))
                : pw.Center(child: pw.Text('Mapa nedostupna',
                    style: pw.TextStyle(color: _dgrey, fontSize: 10))),
          )),
          pw.SizedBox(width: 10),
          pw.Expanded(flex: 2, child: _weatherBox(day, entries)),
        ]),
        pw.SizedBox(height: 10),

        // Správa dňa
        if (day.skipperNote != null && day.skipperNote!.isNotEmpty) ...[
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: _lblue,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('SPRAVA SKIPPERA', style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 9, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Text(_ascii(day.skipperNote!), style: const pw.TextStyle(fontSize: 10)),
            ]),
          ),
          pw.SizedBox(height: 10),
        ],

        // Záznamy
        if (entries.isNotEmpty) ...[
          pw.Text('ZAZNAMY DENNIKA', style: pw.TextStyle(
              color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 9, letterSpacing: 1)),
          pw.SizedBox(height: 5),
          _entriesTable(entries.take(14).toList()),
        ],

        pw.Spacer(),
        _footer('${_ascii(charter.title)}  |  ${DateFormat('d.M.yyyy').format(day.date)}'),
      ]),
    ));

    // Ďalšie strany
    if (entries.length > 14) {
      final remaining = entries.skip(14).toList();
      for (int i = 0; i < remaining.length; i += 28) {
        final chunk = remaining.skip(i).take(28).toList();
        pages.add(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => pw.Column(children: [
            pw.Text('${_ascii(dayName)} - pokracovanie',
                style: pw.TextStyle(color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.SizedBox(height: 10),
            _entriesTable(chunk),
            pw.Spacer(),
            _footer('${_ascii(charter.title)}  |  ${DateFormat('d.M.yyyy').format(day.date)}'),
          ]),
        ));
      }
    }
    return pages;
  }

  // ── Summary Page ──────────────────────────────────────────────

  static pw.Page _summaryPage(Charter charter, List<DayLog> days,
      Map<int, List<LogbookEntry>> entriesByDay) {
    final totalNm = days.fold<double>(0, (s, d) => s + d.distanceNm);
    final totalEntries = entriesByDay.values.fold<int>(0, (s, e) => s + e.length);
    final maxBft = days.where((d) => d.beaufortNoon != null)
        .fold<int>(0, (s, d) => d.beaufortNoon! > s ? d.beaufortNoon! : s);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
          child: pw.Text('ZAVERECNY PREHLAD PLAVBY', style: pw.TextStyle(
              color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 20),

        pw.Row(children: [
          _statBox('CELKOVA\nVZDIALENOST', '${totalNm.toStringAsFixed(1)} NM', _blue),
          pw.SizedBox(width: 8),
          _statBox('POCET DNI', '${days.length}', _green),
          pw.SizedBox(width: 8),
          _statBox('ZAZNAMY\nDENNIKA', '$totalEntries', _dgrey),
          pw.SizedBox(width: 8),
          _statBox('MAX\nBEAUFORT', maxBft > 0 ? 'Bft $maxBft' : '-', _navy),
        ]),
        pw.SizedBox(height: 20),

        pw.Text('DENNÝ PREHLAD', style: pw.TextStyle(
            color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        pw.SizedBox(height: 8),
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
              ['Den', 'Odkial', 'Kam', 'NM (GPS)', 'Bft', 'Zaz.'].map((h) =>
                pw.Padding(padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(h, style: pw.TextStyle(
                      color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)))).toList()),
            ...days.asMap().entries.map((e) {
              final d = e.value;
              final cnt = entriesByDay[d.id]?.length ?? 0;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: e.key.isEven ? _lgrey : PdfColors.white),
                children: [
                  _cell(DateFormat('EEE d.M.').format(d.date), fontSize: 9),
                  _cell(_ascii(d.portFrom ?? '-'), fontSize: 9),
                  _cell(_ascii(d.portTo ?? '-'), fontSize: 9),
                  _cell('${d.distanceNm.toStringAsFixed(1)} NM', fontSize: 9),
                  _cell(d.beaufortNoon != null ? 'Bft ${d.beaufortNoon}' : '-', fontSize: 9),
                  _cell('$cnt', fontSize: 9),
                ],
              );
            }),
            pw.TableRow(decoration: pw.BoxDecoration(color: _lblue), children: [
              _cell('SPOLU', bold: true, fontSize: 9),
              _cell('', fontSize: 9), _cell('', fontSize: 9),
              _cell('${totalNm.toStringAsFixed(1)} NM', bold: true, fontSize: 9),
              _cell('', fontSize: 9),
              _cell('$totalEntries', bold: true, fontSize: 9),
            ]),
          ],
        ),

        pw.Spacer(),
        pw.Divider(),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Exportovane: ${DateFormat('d.M.yyyy HH:mm').format(DateTime.now().toUtc())} UTC',
              style: pw.TextStyle(color: _dgrey, fontSize: 9)),
          pw.Text('HMB Sailing Log  (c) Lacoste',
              style: pw.TextStyle(color: _dgrey, fontSize: 9)),
        ]),
      ]),
    );
  }

  // ── Podpisová strana ──────────────────────────────────────────

  static pw.Page _signaturePage({
    required Uint8List signatureImage,
    required String? signerName,
    required DateTime signedAt,
    required String hash,
    required String docTitle,
  }) {
    final timeStr = DateFormat('d.M.yyyy HH:mm:ss').format(signedAt);
    final qrData = 'HMB-LOG:v1'
        '|doc:${_ascii(docTitle)}'
        '|signer:${_ascii(signerName ?? "Skipper")}'
        '|ts:${signedAt.toIso8601String()}'
        '|sha256:$hash';

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Hlavička
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _navy,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PODPIS SKIPPERA', style: pw.TextStyle(
                    color: PdfColors.white, fontSize: 11,
                    fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                pw.SizedBox(height: 4),
                pw.Text(_ascii(docTitle), style: pw.TextStyle(
                    color: PdfColors.grey200, fontSize: 13)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Podpis
          pw.Container(
            width: double.infinity,
            height: 130,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              color: PdfColors.white,
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Image(pw.MemoryImage(signatureImage),
                  fit: pw.BoxFit.contain),
            ),
          ),
          pw.SizedBox(height: 8),
          if (signerName != null)
            pw.Text(_ascii(signerName), style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.Text('Podpisane: $timeStr UTC',
              style: pw.TextStyle(color: _dgrey, fontSize: 10)),
          pw.SizedBox(height: 24),

          // Hash + QR
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 14),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('OVERENIE INTEGRITY DOKUMENTU',
                        style: pw.TextStyle(
                            color: _navy, fontWeight: pw.FontWeight.bold,
                            fontSize: 9, letterSpacing: 1)),
                    pw.SizedBox(height: 8),
                    pw.Text('SHA-256 odtlacok dat dennnika:',
                        style: pw.TextStyle(color: _dgrey, fontSize: 8)),
                    pw.SizedBox(height: 4),
                    pw.Text(hash.substring(0, 32),
                        style: pw.TextStyle(
                            fontSize: 7.5, fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#2C3E50'))),
                    pw.Text(hash.substring(32),
                        style: pw.TextStyle(
                            fontSize: 7.5, fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#2C3E50'))),
                    pw.SizedBox(height: 10),
                    pw.Text(
                        'Odtlacok pokryva: nazov plavby, loď, posadku,\n'
                        'vsetky zaznamy dennika (cas UTC, GPS, rychlost, kurz).\n'
                        'Akakolvek zmena dat zmeni odtlacok.',
                        style: pw.TextStyle(color: _dgrey, fontSize: 7.5)),
                  ],
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Column(
                children: [
                  pw.BarcodeWidget(
                    barcode: Barcode.qrCode(
                      errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
                    ),
                    data: qrData,
                    width: 100,
                    height: 100,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('Overovaci QR kod',
                      style: pw.TextStyle(color: _dgrey, fontSize: 7)),
                ],
              ),
            ],
          ),

          pw.Spacer(),
          _footer('${_ascii(docTitle)}  |  Podpisany $timeStr UTC'),
        ],
      ),
    );
  }

  // ── Záznamy tabuľka ───────────────────────────────────────────

  static pw.Widget _entriesTable(List<LogbookEntry> entries) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(38),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.2),
        6: const pw.FlexColumnWidth(2.5),
      },
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: _blue), children:
          ['Cas (UTC)', 'SOG', 'COG', 'Vietor', 'Vlny', 'Pohon', 'Poznamka'].map((h) =>
            pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
              child: pw.Text(h, style: pw.TextStyle(
                  color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8)))).toList()),
        ...entries.asMap().entries.map((e) {
          final entry = e.value;
          final time = DateFormat('HH:mm').format(entry.timestamp.toUtc());
          // Extrahuj sailMode z poznámky
          String sailMode = '-';
          String noteText = entry.skipperNote ?? '';
          final modeMatch = RegExp(r'^\[([^\]]+)\]\s*').firstMatch(noteText);
          if (modeMatch != null) {
            sailMode = _sailModeLabel(modeMatch.group(1)!);
            noteText = noteText.substring(modeMatch.end);
          } else if (noteText == 'Auto entry' || noteText == 'Automaticky zaznam' || noteText == 'Automatický záznam') {
            noteText = '';
          }

          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: e.key.isEven ? PdfColor.fromHex('#F8F9FA') : PdfColors.white),
            children: [
              _cell(time, fontSize: 8),
              _cell(entry.sog != null ? '${entry.sog!.toStringAsFixed(1)} kn' : '-', fontSize: 8),
              _cell(entry.cog != null ? '${entry.cog!.toStringAsFixed(0)}' : '-', fontSize: 8),
              _cell(entry.windSpeed != null ? '${entry.windSpeed!.toStringAsFixed(0)} kn' : '-', fontSize: 8),
              _cell(entry.waveHeight != null ? '${entry.waveHeight!.toStringAsFixed(1)} m' : '-', fontSize: 8),
              _cell(sailMode, fontSize: 8),
              _cell(_ascii(noteText), fontSize: 8, maxLines: 2),
            ],
          );
        }),
      ],
    );
  }

  static String _sailModeLabel(String modes) {
    final map = {
      'motor': 'Motor', 'main': 'Hlavna', 'genoa': 'Genoa',
      'reef1': 'Reef1', 'reef2': 'Reef2',
    };
    return modes.split(',').map((m) => map[m.trim()] ?? m).join('+');
  }

  // ── Helpers ───────────────────────────────────────────────────

  static int _windToBeaufort(double kn) {
    if (kn < 1) return 0; if (kn < 4) return 1; if (kn < 7) return 2;
    if (kn < 11) return 3; if (kn < 17) return 4; if (kn < 22) return 5;
    if (kn < 28) return 6; if (kn < 34) return 7; if (kn < 41) return 8;
    if (kn < 48) return 9; if (kn < 56) return 10; if (kn < 64) return 11;
    return 12;
  }

  static String _degToCompass(double deg) {
    const dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'];
    return dirs[((deg % 360) / 22.5).round() % 16];
  }

  static pw.Widget _weatherBox(DayLog day, List<LogbookEntry> entries) {
    final rows = <pw.Widget>[];

    // Preferuj manuálne zadané hodnoty z DayLog; ak nie sú, odvod z entries
    if (day.beaufortMorning != null) {
      rows.add(_wRow('Rano', 'Bft ${day.beaufortMorning}'));
    }
    if (day.beaufortNoon != null) {
      rows.add(_wRow('Poludnie', 'Bft ${day.beaufortNoon}'));
    }
    if (day.beaufortEvening != null) {
      rows.add(_wRow('Vecer', 'Bft ${day.beaufortEvening}'));
    }

    // Ak nie sú Beaufort hodnoty, odvoď z entries (priemerná rýchlosť vetra)
    if (day.beaufortMorning == null && day.beaufortNoon == null && day.beaufortEvening == null) {
      final withWind = entries.where((e) => e.windSpeed != null).toList();
      if (withWind.isNotEmpty) {
        final avgWind = withWind.map((e) => e.windSpeed!).reduce((a, b) => a + b) / withWind.length;
        rows.add(_wRow('Vietor', '${avgWind.toStringAsFixed(1)} kn (Bft ${_windToBeaufort(avgWind)})'));
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

    if (rows.isEmpty) rows.add(pw.Text('Bez udajov', style: pw.TextStyle(color: _dgrey, fontSize: 9)));

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: _lblue,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('POCASIE', style: pw.TextStyle(color: _navy,
            fontWeight: pw.FontWeight.bold, fontSize: 9, letterSpacing: 1)),
        pw.SizedBox(height: 6),
        ...rows,
      ]),
    );
  }

  static pw.Widget _wRow(String l, String v) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(children: [
      pw.SizedBox(width: 55, child: pw.Text(l, style: pw.TextStyle(color: _dgrey, fontSize: 9))),
      pw.Text(v, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
    ]),
  );

  static pw.Widget _infoBox(String title, List<String> lines) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(color: _lgrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(color: _navy,
          fontWeight: pw.FontWeight.bold, fontSize: 9, letterSpacing: 1)),
      pw.SizedBox(height: 5),
      ...lines.map((l) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text(l, style: const pw.TextStyle(fontSize: 10)))),
    ]),
  );

  static pw.Widget _statBox(String label, String value, PdfColor color) =>
    pw.Expanded(child: pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Text(value, style: pw.TextStyle(color: PdfColors.white,
            fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(label, textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.grey200, fontSize: 8)),
      ]),
    ));

  static pw.Widget _cell(String text, {double fontSize = 10, bool bold = false, int maxLines = 1}) =>
    pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(text, maxLines: maxLines, overflow: pw.TextOverflow.clip,
          style: pw.TextStyle(fontSize: fontSize,
              fontWeight: bold ? pw.FontWeight.bold : null)));

  static pw.Widget _footer(String text) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(text, style: pw.TextStyle(color: _dgrey, fontSize: 8)),
      pw.Text('HMB Sailing Log  |  ${DateFormat('d.M.yyyy').format(DateTime.now())}',
          style: pw.TextStyle(color: _dgrey, fontSize: 8)),
    ]);

  /// Odstráň diakritiku pre PDF (pdf package neobsahuje slovenské fonty)
  static String _ascii(String s) => s
    .replaceAll('á','a').replaceAll('ä','a').replaceAll('č','c')
    .replaceAll('ď','d').replaceAll('é','e').replaceAll('í','i')
    .replaceAll('ĺ','l').replaceAll('ľ','l').replaceAll('ň','n')
    .replaceAll('ó','o').replaceAll('ô','o').replaceAll('ŕ','r')
    .replaceAll('š','s').replaceAll('ť','t').replaceAll('ú','u')
    .replaceAll('ý','y').replaceAll('ž','z')
    .replaceAll('Á','A').replaceAll('Č','C').replaceAll('Ď','D')
    .replaceAll('É','E').replaceAll('Í','I').replaceAll('Ľ','L')
    .replaceAll('Ň','N').replaceAll('Ó','O').replaceAll('Š','S')
    .replaceAll('Ť','T').replaceAll('Ú','U').replaceAll('Ý','Y')
    .replaceAll('Ž','Z').replaceAll('→','->').replaceAll('·','.')
    .replaceAll('©','(c)').replaceAll('–','-');
}
