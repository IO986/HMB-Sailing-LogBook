import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Guards the bundled PDF font.
///
/// The charter PDF is the artefact handed to other people, and until Noto Sans
/// was bundled it transliterated crew names ("Ján Novák" printed as "Jan
/// Novak") and could not render Cyrillic at all. A wrong asset path or a
/// pubspec entry lost in a merge would bring that back silently — nothing else
/// in the suite touches PDF generation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both font assets are bundled and parse as TTF', () async {
    for (final path in [
      'assets/fonts/NotoSans-Regular.ttf',
      'assets/fonts/NotoSans-Bold.ttf',
    ]) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(50000),
          reason: '$path looks truncated');
      // TTF magic number 0x00010000.
      expect(data.getUint32(0), 0x00010000, reason: '$path is not a TTF');
      expect(pw.Font.ttf(data), isNotNull);
    }
  });

  test('the font actually contains the glyphs, not just blanks', () async {
    // Rendering without throwing proves nothing: a missing glyph is silently
    // drawn as .notdef. Check the character map directly.
    final cmap =
        TtfParser(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))
            .charToGlyphIndexMap;

    final required = {
      'č': 0x010D, 'š': 0x0161, 'ž': 0x017E, 'ť': 0x0165,
      'ď': 0x010F, 'ľ': 0x013E, 'ň': 0x0148, 'ŕ': 0x0155,
      'ô': 0x00F4, 'ä': 0x00E4, 'ü': 0x00FC, 'ñ': 0x00F1,
      'А (cyr)': 0x0410, 'я (cyr)': 0x044F, 'і (ukr)': 0x0456,
      'ї (ukr)': 0x0457, 'є (ukr)': 0x0454, 'ґ (ukr)': 0x0491,
    };

    for (final entry in required.entries) {
      expect(cmap[entry.value], isNotNull,
          reason: 'font is missing ${entry.key} (U+${entry.value.toRadixString(16)})');
    }
  });

  test('a document with the font renders Slovak and Cyrillic without throwing',
      () async {
    final base =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final bold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));

    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: base, bold: bold))
      ..addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(children: [
          // The exact characters Helvetica could not draw.
          pw.Text('Ján Novák — kotva spustená, ľuď ťažko ŕôžď'),
          pw.Text('Якір віддано, судно повернулось у радіус'),
          pw.Text('Anker gefallen — ¡Ancla fondeada!'),
        ]),
      ));

    final bytes = await pdf.save();
    expect(bytes.length, greaterThan(1000));
  });
}
