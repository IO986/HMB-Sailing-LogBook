import 'dart:convert';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_codec.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_record.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_schema.dart';
import 'package:hmb_sailing_log/features/voyage_csv/services/voyage_csv_exporter.dart';
import 'package:hmb_sailing_log/features/voyage_csv/services/voyage_csv_importer.dart';

import 'voyage_fixture.dart';

void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    target = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  final fixedNow = DateTime.utc(2026, 10, 22, 12);

  Future<String> exportText(AppDatabase db, int charterId,
      {bool track = true}) async {
    final sb = StringBuffer();
    await VoyageCsvExporter.write(db, charterId, sb,
        includeTrack: track, appVersion: '1.41.0+83', now: fixedNow);
    return sb.toString();
  }

  Future<VoyageCsvImportResult> importText(AppDatabase db, String text) =>
      VoyageCsvImporter.importInto(db, VoyageCsvReader.read(text), now: fixedNow);

  /// A hand-written file: header, then the given rows, cells by column name.
  String file(List<Map<String, String>> rows) {
    final header = VoyageCsvSchema.header;
    final lines = [
      header.join(','),
      for (final r in rows) header.map((c) => r[c] ?? '').join(','),
    ];
    return '${lines.join('\r\n')}\r\n';
  }

  final meta = {
    'record_type': 'meta',
    'format': 'hmb-voyage',
    'version': '1',
    'includes_track': 'true',
  };
  Map<String, String> row(String type, Map<String, String> cells,
          {String? id, String? parent}) =>
      {
        'record_type': type,
        if (id != null) 'id': id,
        if (parent != null) 'parent_id': parent,
        ...cells,
      };

  group('round trip', () {
    test('export, import into an empty database, export again: identical',
        () async {
      final sourceId = await buildFullVoyage(source);
      final first = await exportText(source, sourceId);

      final result = await importText(target, first);
      final second = await exportText(target, result.charterId);

      final a = VoyageCsvReader.read(first);
      final b = VoyageCsvReader.read(second);
      expect(b.records.length, a.records.length);
      for (var i = 0; i < a.records.length; i++) {
        final x = a.records[i];
        final y = b.records[i];
        expect(y.type, x.type, reason: 'record $i');
        expect((y.id, y.parentId), (x.id, x.parentId), reason: 'record $i');
        final xc = Map.of(x.cells);
        final yc = Map.of(y.cells);
        // The only thing that is meant to differ: the copy knows it is one.
        if (x.type == 'charter') {
          expect(yc.remove('source'), CharterSource.csv);
          xc.remove('source');
        }
        expect(yc, xc, reason: 'record $i (${x.type})');
      }
    });

    test('the copy is a voyage of its own with the same identity', () async {
      final sourceId = await buildFullVoyage(source);
      final text = await exportText(source, sourceId);
      final result = await importText(target, text);

      final c = (await target.getCharterById(result.charterId))!;
      expect(c.source, CharterSource.csv);
      expect(c.title, 'Kornati "máj", 2026');
      expect(c.syncUuid, (await source.getCharterById(sourceId))!.syncUuid);
      expect(c.vesselName, 'Ružena');
      expect(c.skipperName, 'Ján Novák');
      expect(c.crewNames, 'Eva Malá');
      expect(c.captainQualification, 'Kapitán jachty');
      expect(c.dateFrom.toUtc(), DateTime.utc(2026, 5, 2, 8));
      expect(CharterSource.isRetrospective(c.source), isTrue);
    });

    test('skipper and crew keep their papers', () async {
      final sourceId = await buildFullVoyage(source);
      final result = await importText(target, await exportText(source, sourceId));

      final crew = jsonDecode((await target.getCharterById(result.charterId))!
          .crewJson!) as List;
      final skipper = crew.first as Map;
      expect(skipper['qualification'], 'RYA Yachtmaster Offshore');
      expect(skipper['boatLicence'], 'SK-12345');
      expect(skipper['radioLicence'], 'SRC-777');
      expect(skipper['otherCerts'], 'First aid, =weird');
    });

    test('days, entries and the track land where they belong', () async {
      final sourceId = await buildFullVoyage(source);
      final result = await importText(target, await exportText(source, sourceId));

      final days = await target.getDayLogs(result.charterId);
      expect(days.length, 2);
      expect(days[0].portFrom, 'Biograd');
      expect(days[0].nightHoursManual, 1.5);
      final entries = await target.getEntriesForDay(days[0].id);
      expect(entries.single.skipperNote, '=SUM(A1), vietor "silný"');
      expect(entries.single.sailMode, 'main,genoa');
      // The entry is tied to the session it was made in.
      final sessions = await target.getSessionsForDay(days[0].id,
          includeAnchorWatch: true);
      expect(entries.single.sessionId, sessions.first.sessionId);
      expect(sessions.where((s) => s.isAnchorWatch).length, 1);
      expect(
          (await target.getTrackPointsForSession(sessions.first.sessionId))
              .length,
          5);
    });

    test('a long track, past the batch size, comes through whole', () async {
      final sourceId = await buildFullVoyage(source);
      await source.insertTrackPointsBatch([
        for (var i = 0; i < 5000; i++)
          TrackPointsCompanion.insert(
            sessionId: const Value('sess-1'),
            timestamp: DateTime.utc(2026, 5, 2, 9).add(Duration(seconds: i)),
            latitude: 43.0 + i * 1e-6,
            longitude: 15.0,
          ),
      ]);
      final result = await importText(target, await exportText(source, sourceId));
      expect(result.imported['track'], 5005 + 1);
      expect(await VoyageCsvExporter.trackPointCount(target, result.charterId),
          5006);
    });

    test('handover, assessment, signature and bearing come through',
        () async {
      final sourceId = await buildFullVoyage(source);
      final result = await importText(target, await exportText(source, sourceId));
      final id = result.charterId;

      final h = (await target.getHandoverProtocol(id, 'checkIn'))!;
      expect(h.location, 'Marina Kornati');
      expect(h.skipperSignedAt!.toUtc(), DateTime.utc(2026, 5, 2, 7, 30));
      final items = jsonDecode(h.checklistJson) as List;
      expect(items.length, 3);
      expect((items[1] as Map)['note'], 'prasknutý ventil');
      expect((items[2] as Map)['customLabel'], 'Gril');
      // No signature image comes with the file.
      expect(h.skipperSignaturePath, isNull);

      expect((await target.getCrewAssessments(id)).single.helming, 4);
      final sig = (await target.getSignaturesForCharter(id)).single;
      expect(sig.signedAt!.toUtc(), DateTime.utc(2026, 5, 2, 7, 31));
      expect(sig.signaturePath, isNull);
      expect((await target.getBearingsForCharter(id)).single.label, 'Maják');
    });

    test('without the track the rest still round-trips', () async {
      final sourceId = await buildFullVoyage(source);
      final text = await exportText(source, sourceId, track: false);
      final result = await importText(target, text);
      expect(result.imported.containsKey('track'), isFalse);
      expect(await VoyageCsvExporter.trackPointCount(target, result.charterId),
          0);
      expect((await target.getDayLogs(result.charterId)).length, 2);
    });
  });

  group('safety', () {
    test('the same voyage is not read in twice', () async {
      final sourceId = await buildFullVoyage(source);
      final text = await exportText(source, sourceId);
      final first = await importText(target, text);

      await expectLater(
        importText(target, text),
        throwsA(isA<VoyageAlreadyImportedException>()
            .having((e) => e.charterId, 'charterId', first.charterId)),
      );
      expect((await target.getAllCharters()).length, 1);
    });

    test('importing back into the database it came from is refused', () async {
      final sourceId = await buildFullVoyage(source);
      final text = await exportText(source, sourceId);
      await expectLater(importText(source, text),
          throwsA(isA<VoyageAlreadyImportedException>()));
      expect((await source.getAllCharters()).length, 1);
    });

    test('nothing that exists is changed', () async {
      final otherId = await buildFullVoyage(target);
      final before = await exportText(target, otherId);

      final sourceId = await buildFullVoyage(source);
      await source.updateCharter(
          ChartersCompanion(id: Value(sourceId), syncUuid: const Value('other')));
      await importText(target, await exportText(source, sourceId));

      expect(await exportText(target, otherId), before);
      expect((await target.getAllCharters()).length, 2);
    });

    test('a file without a voyage in it is refused', () async {
      final text = file([meta, row('day', {'date': '2026-07-10'}, id: '1')]);
      await expectLater(
        importText(target, text),
        throwsA(isA<VoyageCsvFormatException>()
            .having((e) => e.problem, 'problem', VoyageCsvProblem.noVoyage)),
      );
      expect(await target.getAllCharters(), isEmpty);
    });
  });

  group('damaged and partial files', () {
    test('the smallest file: a title is enough', () async {
      final text = file([meta, row('charter', {'title': 'Len názov'}, id: '1')]);
      final result = await importText(target, text);
      final c = (await target.getCharterById(result.charterId))!;
      expect(c.title, 'Len názov');
      expect(c.source, CharterSource.csv);
      expect(c.syncUuid, isNotEmpty); // one is made up
    });

    test('dates the file lacks come from its days', () async {
      final text = file([
        meta,
        row('charter', {'title': 'X'}, id: '1'),
        row('day', {'date': '2026-07-12'}, id: '2'),
        row('day', {'date': '2026-07-10'}, id: '1'),
      ]);
      final result = await importText(target, text);
      final c = (await target.getCharterById(result.charterId))!;
      expect(c.dateFrom.toLocal(), DateTime(2026, 7, 10));
      expect(c.dateTo.toLocal(), DateTime(2026, 7, 12));
    });

    test('records that cannot be placed are skipped and counted', () async {
      final text = file([
        meta,
        row('charter', {'title': 'X'}, id: '1'),
        row('day', {'date': '2026-07-10'}, id: '1'),
        row('day', {'port_from': 'no date'}, id: '2'),
        row('entry', {'time_utc': '2026-07-10T08:00:00Z'}, id: '1', parent: '1'),
        row('entry', {'time_utc': '2026-07-10T09:00:00Z'}, id: '2', parent: '9'),
        row('entry', {'time_utc': '2026-07-10T10:00:00Z'}, id: '3', parent: '9'),
        row('entry', {'lat': '43.9'}, id: '4', parent: '1'),
        row('track', {'time_utc': '2026-07-10T08:00:00Z', 'lat': '1', 'lon': '2'},
            id: '1', parent: '7'),
        row('session', {'from_utc': '2026-07-10T08:00:00Z'}, id: '1', parent: '99'),
        row('signature', {'role': 'crew'}, id: '1'),
        row('duty', {'name': 'Eva'}, id: '1'),
        row('crew', {'role': 'crew'}, id: '1'),
      ]);
      final result = await importText(target, text);

      expect(result.imported['day'], 1);
      expect(result.imported['entry'], 1);
      expect(result.imported.containsKey('track'), isFalse);
      final kinds = {
        for (final w in result.warnings) '${w.kind.name}:${w.detail}',
      };
      expect(kinds, containsAll([
        'invalid:day',
        'orphan:entry ×2',
        'invalid:entry',
        'orphan:track',
        'orphan:session',
        'invalid:signature',
        'invalid:duty',
        'invalid:crew',
      ]));
      final days = await target.getDayLogs(result.charterId);
      expect((await target.getEntriesForDay(days.single.id)).length, 1);
    });

    test('bearings that would break the table are skipped, not fatal',
        () async {
      final base = {
        'magnetic_bearing_deg': '10',
        'declination_deg': '4',
        'true_bearing_deg': '14',
        'time_utc': '2026-07-10T08:00:00Z',
      };
      final text = file([
        meta,
        row('charter', {'title': 'X'}, id: '1'),
        // resection without a target
        row('bearing', {...base, 'bearing_kind': 'resection'}, id: '1'),
        // intersection without a sight group
        row('bearing',
            {...base, 'bearing_kind': 'intersection', 'lat': '1', 'lon': '2'},
            id: '2'),
        // a valid resection
        row('bearing',
            {...base, 'bearing_kind': 'resection', 'target_lat': '1', 'target_lon': '2'},
            id: '3'),
        // a valid intersection
        row('bearing',
            {
              ...base,
              'bearing_kind': 'intersection',
              'lat': '1',
              'lon': '2',
              'sight_group': 'g1',
            },
            id: '4'),
        // missing a number
        row('bearing', {'bearing_kind': 'resection'}, id: '5'),
      ]);
      final result = await importText(target, text);
      expect(result.imported['bearing'], 2);
      expect(
          result.warnings.where((w) => w.kind == VoyageCsvWarningKind.invalid).single.detail,
          'bearing ×3');
      final saved = await target.getBearingsForCharter(result.charterId);
      expect(saved.length, 2);
      // The group got a new name; it is the same for bearings that share it.
      expect(saved.firstWhere((b) => b.kind == 'intersection').sightGroupId,
          isNot('g1'));
    });

    test('a second protocol of the same kind is skipped', () async {
      final h = {
        'handover_type': 'checkIn',
        'time_utc': '2026-07-10T08:00:00Z',
      };
      final text = file([
        meta,
        row('charter', {'title': 'X'}, id: '1'),
        row('handover', {...h, 'location': 'first'}, id: '1'),
        row('handover', {...h, 'location': 'second'}, id: '2'),
        row('handover', {'handover_type': 'odd', 'time_utc': h['time_utc']!}, id: '3'),
        row('checklist', {'item_key': 'anchor', 'status': 'damaged'},
            id: '1', parent: '1'),
        row('checklist', {'item_key': 'lost'}, id: '2', parent: '2'),
      ]);
      final result = await importText(target, text);
      expect(result.imported['handover'], 1);
      expect(
          (await target.getHandoverProtocol(result.charterId, 'checkIn'))!.location,
          'first');
      final kinds = result.warnings.map((w) => w.kind).toSet();
      expect(kinds, containsAll([
        VoyageCsvWarningKind.duplicate,
        VoyageCsvWarningKind.invalid,
        VoyageCsvWarningKind.orphan,
      ]));
    });

    test('an unknown checklist status falls back to ok', () async {
      final text = file([
        meta,
        row('charter', {'title': 'X'}, id: '1'),
        row('handover',
            {'handover_type': 'checkOut', 'time_utc': '2026-07-10T08:00:00Z'},
            id: '1'),
        row('checklist', {'item_key': 'anchor', 'status': 'on fire'},
            id: '1', parent: '1'),
      ]);
      final result = await importText(target, text);
      final items = jsonDecode(
          (await target.getHandoverProtocol(result.charterId, 'checkOut'))!
              .checklistJson) as List;
      expect((items.single as Map)['status'], 'ok');
    });
  });

  group('preview', () {
    test('counts what is in the file, without writing anything', () async {
      final sourceId = await buildFullVoyage(source);
      final doc = VoyageCsvReader.read(await exportText(source, sourceId));
      final p = VoyageCsvImporter.preview(doc);

      expect(p.title, 'Kornati "máj", 2026');
      expect(p.vesselName, 'Ružena');
      expect(p.from, DateTime.utc(2026, 5, 2, 8));
      expect(p.includesTrack, isTrue);
      expect(p.count('day'), 2);
      expect(p.count('entry'), 2);
      expect(p.count('track'), 6);
      expect(p.count('crew'), 2);
      expect(p.count('charter'), 0);
      expect(p.count('spaceship'), 0);
      expect(await target.getAllCharters(), isEmpty);
    });

    test('knows a voyage that is already in the database', () async {
      final sourceId = await buildFullVoyage(source);
      final doc = VoyageCsvReader.read(await exportText(source, sourceId));

      expect(await VoyageCsvImporter.findExisting(target, doc), isNull);
      expect((await VoyageCsvImporter.findExisting(source, doc))!.id, sourceId);
    });
  });
}
