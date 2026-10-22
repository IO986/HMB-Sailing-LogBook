import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_schema.dart';

/// The catalog in code and `docs/CSV_FORMAT.md` describe the same format.
/// When one changes without the other, this says which column differs.
void main() {
  final doc = File('docs/CSV_FORMAT.md').readAsStringSync();

  /// The text of the `### \`type\`` section, up to the next heading.
  String section(String type) {
    final start = doc.indexOf('### `$type`');
    expect(start, greaterThanOrEqualTo(0), reason: 'no section for "$type"');
    final next = doc.indexOf(RegExp(r'\n#{2,3} '), start + 5);
    return doc.substring(start, next < 0 ? doc.length : next);
  }

  Set<String> backticked(String text) =>
      RegExp(r'`([a-z0-9_]+)`').allMatches(text).map((m) => m.group(1)!).toSet();

  group('catalog', () {
    test('every column of a record type is defined', () {
      for (final e in VoyageCsvSchema.types.entries) {
        for (final c in e.value) {
          expect(VoyageCsvSchema.columns.containsKey(c), isTrue,
              reason: '"$c" of "${e.key}" has no definition');
        }
      }
    });

    test('every defined column is used by some record type', () {
      final used = {for (final cols in VoyageCsvSchema.types.values) ...cols};
      for (final c in VoyageCsvSchema.columns.keys) {
        expect(used.contains(c), isTrue, reason: '"$c" is used by no type');
      }
    });

    test('a column is named the same in its definition and in the map', () {
      VoyageCsvSchema.columns.forEach((key, col) => expect(col.name, key));
    });

    test('a type lists a column at most once', () {
      for (final e in VoyageCsvSchema.types.entries) {
        expect(e.value.toSet().length, e.value.length, reason: e.key);
      }
    });

    test('the header holds every column exactly once, common ones first', () {
      final h = VoyageCsvSchema.header;
      expect(h.take(3), ['record_type', 'id', 'parent_id']);
      expect(h.toSet().length, h.length);
      expect(h.length, VoyageCsvSchema.columns.length + 3);
    });

    test('meta comes first among the types', () {
      expect(VoyageCsvSchema.types.keys.first, 'meta');
    });
  });

  group('documentation', () {
    test('every record type has a section', () {
      for (final type in VoyageCsvSchema.types.keys) {
        section(type);
      }
    });

    test('each section names every column of its type', () {
      for (final e in VoyageCsvSchema.types.entries) {
        final named = backticked(section(e.key));
        for (final c in e.value) {
          expect(named.contains(c), isTrue,
              reason: 'column "$c" is missing in the "${e.key}" section');
        }
      }
    });

    test('a section does not describe a column its type does not have', () {
      for (final e in VoyageCsvSchema.types.entries) {
        final named = backticked(section(e.key));
        for (final c in named) {
          if (!VoyageCsvSchema.columns.containsKey(c)) continue;
          expect(e.value.contains(c), isTrue,
              reason: '"$c" is in the "${e.key}" section but not in its type');
        }
      }
    });

    test('the common columns are documented', () {
      final named = backticked(doc);
      for (final c in ['record_type', 'id', 'parent_id']) {
        expect(named.contains(c), isTrue, reason: c);
      }
    });

    test('the version in the text is the version in the code', () {
      expect(doc, contains('(verzia ${VoyageCsvSchema.version})'));
    });
  });
}
