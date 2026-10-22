import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_codec.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_record.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_schema.dart';

void main() {
  VoyageCsvRecord meta({bool track = true}) => VoyageCsvRecord.meta(
        exportedAt: DateTime.utc(2026, 10, 22, 12, 30, 5),
        appVersion: '1.41.0+83',
        schemaVersion: 37,
        includesTrack: track,
      );

  VoyageCsvDocument roundTrip(List<VoyageCsvRecord> records) =>
      VoyageCsvReader.read(VoyageCsvWriter.write(records));

  group('writing', () {
    test('the header is the catalog header, behind a byte order mark', () {
      final out = VoyageCsvWriter.write([meta()]);
      expect(out.startsWith('﻿'), isTrue);
      final firstLine = out.substring(1).split('\r\n').first;
      expect(firstLine, VoyageCsvSchema.header.join(','));
    });

    test('lines end in CRLF and every row has as many cells as the header', () {
      final out = VoyageCsvWriter.write([
        meta(),
        VoyageCsvRecord('crew', id: 1)..set('name', 'Ján Novák'),
      ]);
      final lines = out.substring(1).split('\r\n')..removeLast();
      expect(lines.length, 3);
      for (final l in lines) {
        expect(l.split(',').length, VoyageCsvSchema.header.length);
      }
    });

    test('the first record must be meta, and there must be one', () {
      expect(() => VoyageCsvWriter.write([VoyageCsvRecord('crew')]),
          throwsArgumentError);
      expect(() => VoyageCsvWriter.write(const []), throwsArgumentError);
    });

    test('a mistake in the export is caught where it is made', () {
      final r = VoyageCsvRecord('entry');
      expect(() => r.set('title', 'x'), throwsArgumentError); // charter column
      expect(() => r.set('no_such_column', 'x'), throwsArgumentError);
      expect(() => r.set('lat', 'not a number'), throwsArgumentError);
      expect(() => r.set('auto_entry', 1), throwsArgumentError);
      expect(() => r.set('time_utc', '2026-01-01'), throwsArgumentError);
      expect(() => r.set('berths', 1.5), throwsArgumentError);
      expect(() => VoyageCsvRecord('no_such_type'), throwsArgumentError);
    });

    test('null and empty leave the cell empty', () {
      final r = VoyageCsvRecord('entry')
        ..set('lat', null)
        ..set('note', '')
        ..set('sog_kn', 4.5)
        ..set('sog_kn', null);
      expect(r.cells, isEmpty);
    });

    test('streams to a sink without building a list first', () {
      final sb = StringBuffer();
      Iterable<VoyageCsvRecord> lazy() sync* {
        yield meta();
        for (var i = 0; i < 2000; i++) {
          yield VoyageCsvRecord('track', id: i, parentId: 1)
            ..set('time_utc', DateTime.utc(2026, 10, 6).add(Duration(seconds: i)))
            ..set('lat', 43.0 + i * 1e-5)
            ..set('lon', 15.0);
        }
      }

      VoyageCsvWriter.writeTo(sb, lazy());
      final doc = VoyageCsvReader.read(sb.toString());
      expect(doc.ofType('track').length, 2000);
    });
  });

  group('values survive a round trip', () {
    test('every kind of value', () {
      final t = DateTime.utc(2026, 10, 6, 2, 5, 30);
      final out = roundTrip([
        meta(),
        VoyageCsvRecord('entry', id: 7, parentId: 3)
          ..set('time_utc', t)
          ..set('lat', 43.51230000000001)
          ..set('lon', -19.12621)
          ..set('sog_kn', 5.0)
          ..set('fuel_level_pct', 80)
          ..set('auto_entry', false)
          ..set('mocked', true)
          ..set('note', 'Kotva, "Žut"')
          ..set('session_ref', 2),
      ]);
      final e = out.ofType('entry').single;
      expect((e.id, e.parentId), (7, 3));
      expect(e.instant('time_utc'), t);
      expect(e.real('lat'), 43.51230000000001); // exactly
      expect(e.real('lon'), -19.12621);
      expect(e.real('sog_kn'), 5.0);
      expect(e.integer('fuel_level_pct'), 80);
      expect(e.flag('auto_entry'), isFalse);
      expect(e.flag('mocked'), isTrue);
      expect(e.text('note'), 'Kotva, "Žut"');
      expect(e.integer('session_ref'), 2);
      expect(e.real('depth_m'), isNull); // never set
    });

    test('numbers at the edges read back exactly', () {
      for (final v in [0.0, -0.5, 1e-7, 123456789.123456789, 1e21, -1e-300]) {
        final out = roundTrip([
          meta(),
          VoyageCsvRecord('track')..set('lat', v),
        ]);
        expect(out.ofType('track').single.real('lat'), v, reason: '$v');
      }
    });

    test('NaN and infinity are left empty, not written as words', () {
      final r = VoyageCsvRecord('track')
        ..set('lat', double.nan)
        ..set('lon', double.infinity);
      expect(r.cells, isEmpty);
    });

    test('a moment keeps fractions of a second, and drops them when zero', () {
      final whole = VoyageCsvRecord('track')
        ..set('time_utc', DateTime.utc(2026, 10, 6, 2, 5, 30));
      final frac = VoyageCsvRecord('track')
        ..set('time_utc', DateTime.utc(2026, 10, 6, 2, 5, 30, 250));
      expect(whole.cells['time_utc'], '2026-10-06T02:05:30Z');
      expect(frac.cells['time_utc'], '2026-10-06T02:05:30.250Z');
      expect(frac.instant('time_utc'), DateTime.utc(2026, 10, 6, 2, 5, 30, 250));
    });

    test('a moment given in another zone is written in UTC', () {
      final r = VoyageCsvRecord('track')
        ..set('time_utc', DateTime.parse('2026-10-06T04:05:30+02:00'));
      expect(r.cells['time_utc'], '2026-10-06T02:05:30Z');
    });

    test('a day is a plain date, whatever the time zone', () {
      final r = VoyageCsvRecord('day')..set('date', DateTime(2026, 7, 10));
      expect(r.cells['date'], '2026-07-10');
      expect(r.date('date'), DateTime(2026, 7, 10));
    });
  });

  group('text', () {
    const tricky = [
      'plain',
      'with, comma',
      'with "quotes"',
      'two\nlines',
      'windows\r\nlines',
      ' leading space',
      'trailing space ',
      'Žltá ponorka — 中文 — ü',
      '=1+1',
      '+421 900 000 000',
      '-5 stupňov',
      '@SUM(A1)',
      "'=already quoted",
      "''+two apostrophes",
      "'just an apostrophe",
      "it's fine",
      '=HYPERLINK("http://x","y")',
      '\t=tab first',
    ];

    test('all of it comes back exactly', () {
      for (final s in tricky) {
        final out = roundTrip([
          meta(),
          VoyageCsvRecord('entry')..set('note', s),
        ]);
        expect(out.ofType('entry').single.text('note'), s, reason: s);
      }
    });

    test('text a spreadsheet would run as a formula is neutralised', () {
      for (final s in ['=1+1', '+421 900', '-2+3', '@A1']) {
        final r = VoyageCsvRecord('entry')..set('note', s);
        expect(r.cells['note'], "'$s", reason: s);
      }
    });

    test('numbers are not touched by it', () {
      final r = VoyageCsvRecord('entry')..set('lon', -19.5);
      expect(r.cells['lon'], '-19.5');
    });

    test('text that merely contains such a character is left alone', () {
      final r = VoyageCsvRecord('entry')..set('note', 'a=b, c+d, e-f, g@h');
      expect(r.cells['note'], 'a=b, c+d, e-f, g@h');
    });
  });

  group('reading', () {
    String file(List<String> rows) =>
        '﻿${VoyageCsvSchema.header.join(',')}\r\n${rows.join('\r\n')}\r\n';


    /// A row for the standard header, with [cells] by column name.
    String row(String type, Map<String, String> cells,
        {String id = '', String parent = ''}) {
      return VoyageCsvSchema.header.map((c) {
        if (c == 'record_type') return type;
        if (c == 'id') return id;
        if (c == 'parent_id') return parent;
        return cells[c] ?? '';
      }).join(',');
    }

    final metaFull = row('meta', {
      'format': 'hmb-voyage',
      'version': '1',
      'exported_at_utc': '2026-10-22T12:30:05Z',
    });

    test('reads records in file order with their numbers', () {
      final doc = VoyageCsvReader.read(file([
        metaFull,
        row('day', {'date': '2026-07-10', 'port_from': 'Biograd'}, id: '1'),
        row('entry', {'time_utc': '2026-07-10T08:00:00Z', 'lat': '43.9'},
            id: '1', parent: '1'),
      ]));
      expect(doc.records.map((r) => r.type), ['meta', 'day', 'entry']);
      expect(doc.version, 1);
      expect(doc.warnings, isEmpty);
      final entry = doc.ofType('entry').single;
      expect(entry.parentId, 1);
      expect(doc.childrenOf('entry', 1).length, 1);
      expect(doc.childrenOf('entry', 2), isEmpty);
    });

    test('LF line ends, no byte order mark and a different column order', () {
      const text = 'lat,record_type,id,parent_id,format,version\n'
          ',meta,,,hmb-voyage,1\n'
          '43.9,track,5,2,,\n';
      final doc = VoyageCsvReader.read(text);
      final t = doc.ofType('track').single;
      expect((t.id, t.parentId, t.real('lat')), (5, 2, 43.9));
    });

    test('a file that is not ours is refused with a reason', () {
      void refuses(String text, VoyageCsvProblem problem) {
        expect(
          () => VoyageCsvReader.read(text),
          throwsA(isA<VoyageCsvFormatException>()
              .having((e) => e.problem, 'problem', problem)),
          reason: text,
        );
      }

      refuses('', VoyageCsvProblem.empty);
      refuses('a,b,c\n1,2,3\n', VoyageCsvProblem.notOurs);
      refuses('record_type,format,version\nday,,\n', VoyageCsvProblem.notOurs);
      refuses('record_type,format,version\nmeta,something-else,1\n',
          VoyageCsvProblem.otherFormat);
      refuses('record_type,format,version\nmeta,hmb-voyage,\n',
          VoyageCsvProblem.noVersion);
      refuses('record_type,format,version\nmeta,hmb-voyage,0\n',
          VoyageCsvProblem.noVersion);
      refuses('record_type,format,version\nmeta,hmb-voyage,2\n',
          VoyageCsvProblem.newerVersion);
      refuses('record_type,format,version\n', VoyageCsvProblem.noRecords);
    });

    test('unknown columns are ignored and named once', () {
      final doc = VoyageCsvReader.read(
          '${VoyageCsvSchema.header.join(',')},zeta,alpha\r\n'
          '${metaFull.replaceFirst('meta', 'meta')},x,y\r\n');
      expect(doc.warnings.single.kind, VoyageCsvWarningKind.unknownColumns);
      expect(doc.warnings.single.detail, 'alpha, zeta');
    });

    test('unknown record types are skipped and counted', () {
      final doc = VoyageCsvReader.read(file([
        metaFull,
        row('spaceship', {}, id: '1'),
        row('spaceship', {}, id: '2'),
        row('day', {'date': '2026-07-10'}, id: '1'),
      ]));
      expect(doc.records.map((r) => r.type), ['meta', 'day']);
      expect(doc.warnings.single.kind, VoyageCsvWarningKind.unknownType);
      expect(doc.warnings.single.detail, 'spaceship ×2');
    });

    test('a second meta is skipped, a repeated id is reported', () {
      final doc = VoyageCsvReader.read(file([
        metaFull,
        metaFull,
        row('day', {'date': '2026-07-10'}, id: '1'),
        row('day', {'date': '2026-07-11'}, id: '1'),
      ]));
      expect(doc.ofType('meta').length, 1);
      expect(doc.warnings.map((w) => w.kind), [
        VoyageCsvWarningKind.extraMeta,
        VoyageCsvWarningKind.repeatedId,
      ]);
    });

    test('a value in a column the type does not use is ignored', () {
      final doc = VoyageCsvReader.read(file([
        metaFull,
        row('crew', {'name': 'Eva', 'lat': '43.9'}, id: '1'),
      ]));
      final crew = doc.ofType('crew').single;
      expect(crew.text('name'), 'Eva');
      expect(crew.real('lat'), isNull);
    });

    test('a damaged number or date costs one value, not the file', () {
      final doc = VoyageCsvReader.read(file([
        metaFull,
        row('day', {'date': '2026-02-31', 'distance_nm': 'far'}, id: 'one'),
      ]));
      final day = doc.ofType('day').single;
      expect(day.date('date'), isNull);
      expect(day.real('distance_nm'), isNull);
      expect(day.id, isNull);
      expect(doc.warnings.single.kind, VoyageCsvWarningKind.badNumber);
      expect(doc.warnings.single.detail, contains('one'));
    });

    test('rows shorter than the header and blank lines are fine', () {
      final doc = VoyageCsvReader.read(
          '${VoyageCsvSchema.header.join(',')}\r\n'
          '$metaFull\r\n'
          '\r\n'
          'crew,1\r\n');
      expect(doc.ofType('crew').single.id, 1);
    });

    test('a time without a zone is UTC, and garbage is nothing', () {
      final doc = VoyageCsvReader.read(file([
        metaFull,
        row('entry', {'time_utc': '2026-07-10T08:00:00'}, id: '1'),
        row('entry', {'time_utc': 'yesterday'}, id: '2'),
      ]));
      final entries = doc.ofType('entry').toList();
      expect(entries[0].instant('time_utc'), DateTime.utc(2026, 7, 10, 8));
      expect(entries[1].instant('time_utc'), isNull);
    });

    test('booleans are read whatever the case, anything else is nothing', () {
      final doc = VoyageCsvReader.read(file([
        metaFull,
        row('entry', {'mocked': 'TRUE', 'auto_entry': 'yes'}, id: '1'),
      ]));
      final e = doc.ofType('entry').single;
      expect(e.flag('mocked'), isTrue);
      expect(e.flag('auto_entry'), isNull);
    });
  });

  test('the meta record carries what a reader needs to know', () {
    final doc = roundTrip([meta(track: false)]);
    final m = doc.meta;
    expect(m.text('format'), 'hmb-voyage');
    expect(m.integer('version'), VoyageCsvSchema.version);
    expect(m.instant('exported_at_utc'), DateTime.utc(2026, 10, 22, 12, 30, 5));
    expect(m.text('app_version'), '1.41.0+83');
    expect(m.integer('schema_version'), 37);
    expect(m.flag('includes_track'), isFalse);
  });
}
