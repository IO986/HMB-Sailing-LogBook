import 'voyage_csv_record.dart';
import 'voyage_csv_schema.dart';

/// Writes records as the voyage CSV: UTF-8 text with a byte order mark (so a
/// spreadsheet opens it as UTF-8), CRLF line ends, fields quoted per RFC 4180.
abstract final class VoyageCsvWriter {
  static const bom = '﻿';

  /// The whole file as one string. For a long track, prefer [writeTo] with a
  /// file sink and a lazily built [records] iterable.
  static String write(Iterable<VoyageCsvRecord> records) {
    final sb = StringBuffer();
    writeTo(sb, records);
    return sb.toString();
  }

  /// Writes to [sink] as [records] are produced. The first record must be the
  /// `meta` record: a reader needs it to know what it is looking at.
  static void writeTo(StringSink sink, Iterable<VoyageCsvRecord> records) {
    final out = VoyageCsvSink(sink);
    for (final r in records) {
      out.add(r);
    }
    out.finish();
  }

  static String cell(VoyageCsvRecord r, String column) {
    switch (column) {
      case VoyageCsvSchema.recordType:
        return r.type;
      case VoyageCsvSchema.id:
        return r.id?.toString() ?? '';
      case VoyageCsvSchema.parentId:
        return r.parentId?.toString() ?? '';
      default:
        return r.cells[column] ?? '';
    }
  }

  static void line(StringSink sink, List<String> cells) {
    for (var i = 0; i < cells.length; i++) {
      if (i > 0) sink.write(',');
      sink.write(_quote(cells[i]));
    }
    sink.write('\r\n');
  }

  static String _quote(String v) {
    final needs = v.contains(',') ||
        v.contains('"') ||
        v.contains('\n') ||
        v.contains('\r') ||
        v.startsWith(' ') ||
        v.endsWith(' ');
    return needs ? '"${v.replaceAll('"', '""')}"' : v;
  }
}

/// Writes records one at a time, for an export that reads its data
/// asynchronously and is too large to hold as a list (a long track).
///
/// The byte order mark and the header go out on construction; the first record
/// added must be `meta`; [finish] checks that something was written.
class VoyageCsvSink {
  final StringSink _sink;
  final List<String> _header = VoyageCsvSchema.header;
  var _count = 0;

  VoyageCsvSink(this._sink) {
    _sink.write(VoyageCsvWriter.bom);
    VoyageCsvWriter.line(_sink, _header);
  }

  int get count => _count;

  void add(VoyageCsvRecord r) {
    if (_count == 0 && r.type != 'meta') {
      throw ArgumentError('the first record must be "meta", not "${r.type}"');
    }
    VoyageCsvWriter.line(_sink, [
      for (final col in _header) VoyageCsvWriter.cell(r, col),
    ]);
    _count++;
  }

  void finish() {
    if (_count == 0) throw ArgumentError('no records');
  }
}

/// Reads a voyage CSV. Strict about what the file is, lenient about what is in
/// it: a file that is not ours, or from a newer format, is refused with a
/// reason; an unknown column, an unknown record type or a damaged cell is
/// skipped and reported.
abstract final class VoyageCsvReader {
  static VoyageCsvDocument read(String text) {
    final rows = _rows(text);
    if (rows.isEmpty) {
      throw const VoyageCsvFormatException('Súbor je prázdny.');
    }

    final header = [for (final h in rows.first) h.trim().toLowerCase()];
    final typeCol = header.indexOf(VoyageCsvSchema.recordType);
    if (typeCol < 0) {
      throw const VoyageCsvFormatException(
          'Toto nie je súbor HMB voyage CSV (chýba stĺpec record_type).');
    }
    final idCol = header.indexOf(VoyageCsvSchema.id);
    final parentCol = header.indexOf(VoyageCsvSchema.parentId);

    final warnings = <String>[];
    final unknownColumns = <String>{
      for (final h in header)
        if (h.isNotEmpty &&
            h != VoyageCsvSchema.recordType &&
            h != VoyageCsvSchema.id &&
            h != VoyageCsvSchema.parentId &&
            !VoyageCsvSchema.columns.containsKey(h))
          h,
    };
    if (unknownColumns.isNotEmpty) {
      warnings.add('Ignorované stĺpce: ${(unknownColumns.toList()..sort()).join(', ')}.');
    }

    String cellAt(List<String> row, int i) =>
        (i >= 0 && i < row.length) ? row[i] : '';

    final records = <VoyageCsvRecord>[];
    final skippedTypes = <String, int>{};
    final seen = <String>{};
    var metaSeen = false;
    var version = 0;

    for (var n = 1; n < rows.length; n++) {
      final row = rows[n];
      if (row.every((c) => c.trim().isEmpty)) continue;
      final line = n + 1;

      final type = cellAt(row, typeCol).trim().toLowerCase();

      if (!metaSeen) {
        if (type != 'meta') {
          throw const VoyageCsvFormatException(
              'Toto nie je súbor HMB voyage CSV (prvý záznam nie je meta).');
        }
        metaSeen = true;
      } else if (type == 'meta') {
        warnings.add('Riadok $line: ďalší záznam meta, preskočený.');
        continue;
      }

      if (!VoyageCsvSchema.isKnownType(type)) {
        skippedTypes.update(type.isEmpty ? '(prázdny)' : type, (c) => c + 1,
            ifAbsent: () => 1);
        continue;
      }

      final cells = <String, String>{};
      for (var c = 0; c < header.length && c < row.length; c++) {
        final name = header[c];
        final value = row[c];
        if (value.isEmpty) continue;
        if (name == VoyageCsvSchema.recordType ||
            name == VoyageCsvSchema.id ||
            name == VoyageCsvSchema.parentId) {
          continue;
        }
        if (VoyageCsvSchema.types[type]!.contains(name)) {
          cells.putIfAbsent(name, () => value);
        }
      }

      int? number(int col, String what) {
        final v = cellAt(row, col).trim();
        if (v.isEmpty) return null;
        final parsed = int.tryParse(v);
        if (parsed == null) {
          warnings.add('Riadok $line: $what "$v" nie je číslo.');
        }
        return parsed;
      }

      final id = number(idCol, 'id');
      final parentId = number(parentCol, 'parent_id');
      if (id != null && !seen.add('$type#$id')) {
        warnings.add('Riadok $line: $type s id $id sa opakuje.');
      }

      final record = VoyageCsvRecord.raw(type, id, parentId, cells);
      records.add(record);

      if (type == 'meta') {
        final format = record.text('format');
        if (format != VoyageCsvSchema.formatName) {
          throw const VoyageCsvFormatException(
              'Toto nie je súbor HMB voyage CSV (iný formát).');
        }
        final v = record.integer('version');
        if (v == null || v < 1) {
          throw const VoyageCsvFormatException(
              'V súbore chýba platná verzia formátu.');
        }
        if (v > VoyageCsvSchema.version) {
          throw VoyageCsvFormatException(
              'Súbor je vo verzii $v formátu, táto appka číta najviac verziu '
              '${VoyageCsvSchema.version}. Aktualizuj appku.');
        }
        version = v;
      }
    }

    if (!metaSeen) {
      throw const VoyageCsvFormatException('Súbor nemá žiadne záznamy.');
    }

    for (final e in skippedTypes.entries) {
      warnings.add('Preskočené záznamy neznámeho typu "${e.key}": ${e.value}.');
    }
    return VoyageCsvDocument(version, records, warnings);
  }

  /// RFC 4180 tokenizer: comma separated, `"` quotes a field, `""` is a quote
  /// inside it, CR, LF and CRLF all end a record, a leading BOM is dropped.
  static List<List<String>> _rows(String text) {
    final src = text.startsWith('﻿') ? text.substring(1) : text;
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;
    var sawAnything = false;

    void endField() {
      row.add(field.toString());
      field.clear();
    }

    void endRow() {
      endField();
      rows.add(row);
      row = <String>[];
      sawAnything = false;
    }

    for (var i = 0; i < src.length; i++) {
      final c = src[i];
      sawAnything = true;
      if (quoted) {
        if (c == '"') {
          if (i + 1 < src.length && src[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            quoted = false;
          }
        } else {
          field.write(c);
        }
        continue;
      }
      switch (c) {
        case '"':
          quoted = true;
        case ',':
          endField();
        case '\r':
          if (i + 1 < src.length && src[i + 1] == '\n') i++;
          endRow();
        case '\n':
          endRow();
        default:
          field.write(c);
      }
    }
    if (sawAnything) endRow();
    return rows;
  }
}
