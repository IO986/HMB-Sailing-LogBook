import 'voyage_csv_schema.dart';

/// The file is not a voyage CSV this app can read.
class VoyageCsvFormatException implements Exception {
  final String message;
  const VoyageCsvFormatException(this.message);
  @override
  String toString() => message;
}

/// One row of the file: a record type, its numbers and its cells.
///
/// Cells are held as the text that stands in the file. [set] encodes a value
/// into that text according to the column's kind; the typed getters decode it.
/// A getter returns `null` for an empty cell and for text that does not parse,
/// so a damaged cell costs one value and not the whole import.
class VoyageCsvRecord {
  final String type;
  int? id;
  int? parentId;
  final Map<String, String> _cells;

  VoyageCsvRecord(this.type, {this.id, this.parentId})
      : _cells = <String, String>{} {
    if (!VoyageCsvSchema.isKnownType(type)) {
      throw ArgumentError.value(type, 'type', 'unknown record type');
    }
  }

  /// A record whose cells are already text, as the reader builds it.
  VoyageCsvRecord.raw(this.type, this.id, this.parentId, Map<String, String> cells)
      : _cells = cells;

  /// The `meta` record that opens every file.
  factory VoyageCsvRecord.meta({
    required DateTime exportedAt,
    required String appVersion,
    required int schemaVersion,
    required bool includesTrack,
  }) =>
      VoyageCsvRecord('meta')
        ..set('format', VoyageCsvSchema.formatName)
        ..set('version', VoyageCsvSchema.version)
        ..set('exported_at_utc', exportedAt)
        ..set('app_version', appVersion)
        ..set('schema_version', schemaVersion)
        ..set('includes_track', includesTrack);

  /// Columns that hold a value, with the text that stands in the file.
  Map<String, String> get cells => Map.unmodifiable(_cells);

  /// Puts [value] into [column]. `null` leaves the cell empty. Throws when the
  /// column does not belong to this record type or [value] is not of the
  /// column's kind: both are mistakes in the export, and finding them there is
  /// better than a file that cannot be read back.
  void set(String column, Object? value) {
    if (!VoyageCsvSchema.types[type]!.contains(column)) {
      throw ArgumentError.value(column, 'column', 'not a column of "$type"');
    }
    final kind = VoyageCsvSchema.kindOf(column)!;
    final text = encode(kind, value);
    if (text == null) {
      _cells.remove(column);
    } else {
      _cells[column] = text;
    }
  }

  String? text(String column) => decodeText(_cells[column]);

  int? integer(String column) {
    final v = _cells[column];
    return v == null ? null : int.tryParse(v.trim());
  }

  double? real(String column) {
    final v = _cells[column];
    if (v == null) return null;
    final d = double.tryParse(v.trim());
    return (d == null || d.isNaN || d.isInfinite) ? null : d;
  }

  bool? flag(String column) {
    switch (_cells[column]?.trim().toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
    return null;
  }

  /// A moment, always UTC.
  DateTime? instant(String column) {
    final v = _cells[column]?.trim();
    if (v == null || v.isEmpty) return null;
    // A time without a zone is read as UTC: the column says so by its name.
    final hasZone = RegExp(r'(Z|[+-]\d\d:?\d\d)$').hasMatch(v);
    return DateTime.tryParse(hasZone ? v : '${v}Z')?.toUtc();
  }

  /// A calendar day, as local midnight of that date (the way days are stored).
  DateTime? date(String column) {
    final v = _cells[column]?.trim();
    if (v == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(v);
    if (m == null) return null;
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final out = DateTime(y, mo, d);
    // 31 February would roll over into March.
    return (out.month == mo && out.day == d) ? out : null;
  }

  // ── Encoding ───────────────────────────────────────────────────────

  static String? encode(CsvKind kind, Object? value) {
    if (value == null) return null;
    switch (kind) {
      case CsvKind.text:
        final s = value.toString();
        return s.isEmpty ? null : protectText(s);
      case CsvKind.integer:
        if (value is! int) {
          throw ArgumentError.value(value, 'value', 'expected int');
        }
        return value.toString();
      case CsvKind.real:
        if (value is! num) {
          throw ArgumentError.value(value, 'value', 'expected number');
        }
        final d = value.toDouble();
        // NaN and infinity have no meaning in a log; leave the cell empty.
        return (d.isNaN || d.isInfinite) ? null : d.toString();
      case CsvKind.boolean:
        if (value is! bool) {
          throw ArgumentError.value(value, 'value', 'expected bool');
        }
        return value ? 'true' : 'false';
      case CsvKind.instant:
        if (value is! DateTime) {
          throw ArgumentError.value(value, 'value', 'expected DateTime');
        }
        return _isoUtc(value);
      case CsvKind.date:
        if (value is! DateTime) {
          throw ArgumentError.value(value, 'value', 'expected DateTime');
        }
        String two(int n) => n.toString().padLeft(2, '0');
        return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}';
    }
  }

  /// `2026-10-06T02:05:30Z`; fractions of a second only when there are some.
  static String _isoUtc(DateTime t) {
    final u = t.toUtc();
    final s = u.toIso8601String();
    if (u.millisecond == 0 && u.microsecond == 0) {
      return s.replaceFirst('.000Z', 'Z');
    }
    return s;
  }

  static final _formulaStart = RegExp(r"^'*[=+\-@\t\r]");

  /// A spreadsheet runs a cell that starts with `=`, `+`, `-` or `@` as a
  /// formula, and a voyage log holds text typed by anyone. Such text gets a
  /// leading apostrophe, which spreadsheets show as nothing. Text that already
  /// starts with apostrophes before such a character gets one more, so that
  /// [decodeText] can take exactly one off and give back the original.
  static String protectText(String s) =>
      _formulaStart.hasMatch(s) ? "'$s" : s;

  static String? decodeText(String? v) {
    if (v == null || v.isEmpty) return null;
    return _formulaStart.hasMatch(v) && v.startsWith("'") ? v.substring(1) : v;
  }
}

/// A file read in: the records in file order, plus what was left out.
class VoyageCsvDocument {
  final int version;
  final List<VoyageCsvRecord> records;

  /// Things the reader skipped or could not use. Shown before an import.
  final List<String> warnings;

  const VoyageCsvDocument(this.version, this.records, this.warnings);

  VoyageCsvRecord get meta => records.first;

  Iterable<VoyageCsvRecord> ofType(String type) =>
      records.where((r) => r.type == type);

  Iterable<VoyageCsvRecord> childrenOf(String type, int? parentId) =>
      records.where((r) => r.type == type && r.parentId == parentId);
}
