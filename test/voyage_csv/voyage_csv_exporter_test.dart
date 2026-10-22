import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_codec.dart';
import 'package:hmb_sailing_log/features/voyage_csv/format/voyage_csv_record.dart';
import 'package:hmb_sailing_log/features/voyage_csv/services/voyage_csv_exporter.dart';

/// Exports a voyage that has a little of everything and reads the file back.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  final crewJson = jsonEncode([
    {
      'name': 'Ján Novák',
      'role': 'skipper',
      'qualification': 'RYA Yachtmaster Offshore',
      'boatLicence': 'SK-12345',
      'radioLicence': 'SRC-777',
      'otherCerts': 'First aid, =weird',
    },
    {'name': 'Eva Malá', 'role': 'crew'},
  ]);

  /// A voyage of two days: entries, a measured session with points, a duty, a
  /// check-in with a checklist, an assessment, a signature and a bearing.
  Future<int> buildVoyage() async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Kornati "máj", 2026',
      dateFrom: DateTime.utc(2026, 5, 2, 8),
      dateTo: DateTime.utc(2026, 5, 9, 18),
      createdAt: DateTime.utc(2026, 4, 1),
      vesselName: const Value('Ružena'),
      vesselType: const Value('Plachetnica'),
      vesselLengthM: const Value(12.4),
      berths: const Value(8),
      mmsi: const Value('238123456'),
      tidalWaters: const Value(false),
      captainQualification: const Value('Kapitán jachty'),
      crewJson: Value(crewJson),
      skipperName: const Value('Ján Novák'),
      contactsJson: Value(jsonEncode(['+421 900 111 222', '+385 91 000 000'])),
      costsJson: Value(jsonEncode([
        {'label': 'Charter', 'amount': 1450.5},
        {'label': 'Palivo', 'amount': '85,20'},
      ])),
      costCurrency: const Value('EUR'),
      briefingCheckedJson: Value(jsonEncode(['Záchranné vesty', 'Rádio'])),
      notes: const Value('Prvá plavba,\nveľmi pekná.'),
      source: const Value('live'),
    ));

    final d1 = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 5, 2),
      portFrom: const Value('Biograd'),
      portTo: const Value('Žut'),
      distanceNm: const Value(24.5),
      beaufortNoon: const Value(4),
      windDirection: const Value('NW'),
      nightHoursManual: const Value(1.5),
      skipperNote: const Value('Pekný deň'),
    ));
    final d2 = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: c.id, date: DateTime(2026, 5, 3)));

    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 'sess-1',
      dayLogId: Value(d1.id),
      startTime: DateTime.utc(2026, 5, 2, 8),
      endTime: Value(DateTime.utc(2026, 5, 2, 12)),
      name: const Value('Ráno'),
      totalDistanceNm: const Value(24.5),
      isActive: const Value(false),
    ));
    await db.upsertSession(SailingSessionsCompanion.insert(
      sessionId: 'sess-2',
      dayLogId: Value(d1.id),
      startTime: DateTime.utc(2026, 5, 2, 22),
      isAnchorWatch: const Value(true),
      isActive: const Value(false),
    ));
    await db.insertTrackPointsBatch([
      for (var i = 0; i < 5; i++)
        TrackPointsCompanion.insert(
          sessionId: const Value('sess-1'),
          timestamp: DateTime.utc(2026, 5, 2, 8, i),
          latitude: 43.9 + i * 0.001,
          longitude: 15.4,
          speed: Value(5.0 + i),
          accuracyMeters: const Value(4.5),
        ),
      TrackPointsCompanion.insert(
        sessionId: const Value('sess-2'),
        timestamp: DateTime.utc(2026, 5, 2, 22),
        latitude: 43.95,
        longitude: 15.45,
      ),
    ]);

    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(d1.id),
      sessionId: const Value('sess-1'),
      timestamp: DateTime.utc(2026, 5, 2, 9, 30),
      latitude: const Value(43.91),
      longitude: const Value(15.4),
      sog: const Value(5.5),
      windSpeed: const Value(14),
      sailMode: const Value('main,genoa'),
      pointOfSail: const Value('beam_reach'),
      tack: const Value('S'),
      skipperNote: const Value('=SUM(A1), vietor "silný"'),
      weatherSource: const Value('model'),
      fuelLevel: const Value(80),
    ));
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(d2.id),
      timestamp: DateTime.utc(2026, 5, 3, 7),
      isAutoEntry: const Value(true),
      eventType: const Value('anchor_dropped'),
    ));
    // An entry that belongs to no day is not part of any voyage.
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      timestamp: DateTime.utc(2026, 5, 4),
      skipperNote: const Value('orphan'),
    ));

    await db.insertDutyPeriod(DutyPeriodsCompanion.insert(
      charterId: c.id,
      dayLogId: Value(d1.id),
      crewName: 'Eva Malá',
      fromUtc: DateTime.utc(2026, 5, 2, 8),
      toUtc: Value(DateTime.utc(2026, 5, 2, 12)),
      createdAt: DateTime.utc(2026, 5, 2),
    ));

    await db.upsertHandoverProtocol(HandoverProtocolsCompanion.insert(
      charterId: c.id,
      type: 'checkIn',
      dateTimeUtc: DateTime.utc(2026, 5, 2, 7),
      createdAt: DateTime.utc(2026, 5, 2),
      location: const Value('Marina Kornati'),
      fuelLevel: const Value(100),
      skipperName: const Value('Ján Novák'),
      skipperSignedAt: Value(DateTime.utc(2026, 5, 2, 7, 30)),
      checklistJson: Value(jsonEncode([
        {'itemKey': 'anchor', 'status': 'ok'},
        {'itemKey': 'dinghy', 'status': 'damaged', 'note': 'prasknutý ventil'},
        {'itemKey': 'x1', 'status': 'missing', 'customLabel': 'Gril'},
      ])),
    ));

    await db.upsertCrewAssessment(CrewAssessmentsCompanion.insert(
      charterId: c.id,
      crewName: 'Eva Malá',
      updatedAt: DateTime.utc(2026, 5, 9),
      helming: const Value(4),
      note: const Value('Šikovná'),
    ));
    await db.upsertCrewSignature(CrewSignaturesCompanion.insert(
      charterId: c.id,
      crewName: 'Ján Novák',
      role: const Value('skipper'),
      signaturePath: const Value('/data/sig.png'),
      signedAt: Value(DateTime.utc(2026, 5, 2, 7, 31)),
    ));

    await db.insertBearing(BearingsCompanion.insert(
      kind: 'resection',
      magneticBearing: 123.0,
      declination: 4.5,
      trueBearing: 127.5,
      takenAt: DateTime.utc(2026, 5, 2, 10),
      dayLogId: Value(d1.id),
      charterId: Value(c.id),
      targetLat: const Value(43.95),
      targetLon: const Value(15.45),
      targetName: const Value('Maják'),
      label: const Value('Maják'),
    ));

    return c.id;
  }

  Future<VoyageCsvDocument> export(int id, {bool track = true}) async {
    final sb = StringBuffer();
    await VoyageCsvExporter.write(db, id, sb,
        includeTrack: track,
        appVersion: '1.41.0+83',
        now: DateTime.utc(2026, 10, 22, 12));
    return VoyageCsvReader.read(sb.toString());
  }

  test('the file starts with meta and every record type is represented',
      () async {
    final doc = await export(await buildVoyage());
    expect(doc.warnings, isEmpty);
    expect(doc.records.first.type, 'meta');
    expect(doc.meta.text('app_version'), '1.41.0+83');
    expect(doc.meta.flag('includes_track'), isTrue);
    expect(doc.meta.integer('schema_version'), db.schemaVersion);

    final types = doc.records.map((r) => r.type).toSet();
    expect(types, {
      'meta', 'charter', 'crew', 'contact', 'cost', 'briefing', 'day',
      'session', 'entry', 'track', 'duty', 'handover', 'checklist',
      'assessment', 'signature', 'bearing',
    });
  });

  test('the voyage header carries the vessel, the captain and the notes',
      () async {
    final doc = await export(await buildVoyage());
    final c = doc.ofType('charter').single;
    expect(c.text('title'), 'Kornati "máj", 2026');
    expect(c.instant('date_from_utc'), DateTime.utc(2026, 5, 2, 8));
    expect(c.text('vessel_name'), 'Ružena');
    expect(c.real('length_m'), 12.4);
    expect(c.integer('berths'), 8);
    expect(c.text('mmsi'), '238123456');
    expect(c.flag('tidal_waters'), isFalse);
    expect(c.text('captain_qualification'), 'Kapitán jachty');
    expect(c.text('cost_currency'), 'EUR');
    expect(c.text('note'), 'Prvá plavba,\nveľmi pekná.');
    expect(c.flag('archived'), isFalse);
    expect(c.text('source'), 'live');
    expect(c.text('uuid'), isNotEmpty);
  });

  test('skipper and crew come out with their papers', () async {
    final doc = await export(await buildVoyage());
    final crew = doc.ofType('crew').toList();
    expect(crew.map((r) => r.text('name')), ['Ján Novák', 'Eva Malá']);
    final skipper = crew.first;
    expect(skipper.text('role'), 'skipper');
    expect(skipper.text('qualification'), 'RYA Yachtmaster Offshore');
    expect(skipper.text('boat_licence'), 'SK-12345');
    expect(skipper.text('radio_licence'), 'SRC-777');
    expect(skipper.text('other_certs'), 'First aid, =weird');
    expect(crew.last.text('qualification'), isNull);
  });

  test('contacts, costs and briefing points are listed', () async {
    final doc = await export(await buildVoyage());
    expect(doc.ofType('contact').map((r) => r.text('value')),
        ['+421 900 111 222', '+385 91 000 000']);
    final costs = doc.ofType('cost').toList();
    expect((costs[0].text('name'), costs[0].real('amount')), ('Charter', 1450.5));
    expect(costs[1].real('amount'), 85.2); // "85,20" typed with a comma
    expect(doc.ofType('briefing').map((r) => r.text('value')),
        ['Záchranné vesty', 'Rádio']);
  });

  test('days, sessions and entries are linked by number', () async {
    final doc = await export(await buildVoyage());
    final days = doc.ofType('day').toList();
    expect(days.length, 2);
    expect(days[0].date('date'), DateTime(2026, 5, 2));
    expect(days[0].text('port_from'), 'Biograd');
    expect(days[0].real('distance_nm'), 24.5);
    expect(days[0].integer('beaufort_noon'), 4);
    expect(days[0].real('night_hours_manual'), 1.5);
    expect(days[0].text('note'), 'Pekný deň');

    // Both sessions of day one, anchor watch included.
    final sessions = doc.ofType('session').toList();
    expect(sessions.length, 2);
    expect(sessions.every((s) => s.parentId == days[0].id), isTrue);
    expect(sessions[1].flag('anchor_watch'), isTrue);

    final entries = doc.ofType('entry').toList();
    expect(entries.length, 2, reason: 'the entry without a day is not included');
    final e = entries.first;
    expect(e.parentId, days[0].id);
    expect(e.integer('session_ref'), sessions[0].id);
    expect(e.real('sog_kn'), 5.5);
    expect(e.text('sail_mode'), 'main,genoa');
    expect(e.text('point_of_sail'), 'beam_reach');
    expect(e.text('note'), '=SUM(A1), vietor "silný"');
    expect(e.text('weather_source'), 'model');
    expect(e.integer('fuel_level_pct'), 80);
    expect(entries.last.parentId, days[1].id);
    expect(entries.last.flag('auto_entry'), isTrue);
    expect(entries.last.text('event_type'), 'anchor_dropped');
    expect(entries.last.integer('session_ref'), isNull);
  });

  test('the track goes out per session, in order', () async {
    final id = await buildVoyage();
    final doc = await export(id);
    final sessions = doc.ofType('session').toList();
    final points = doc.ofType('track').toList();
    expect(points.length, 6);
    expect(points.where((p) => p.parentId == sessions[0].id).length, 5);
    expect(points.where((p) => p.parentId == sessions[1].id).length, 1);
    final first = points.first;
    expect(first.real('lat'), 43.9);
    expect(first.real('speed_kn'), 5.0);
    expect(first.real('accuracy_m'), 4.5);
    expect(first.instant('time_utc'), DateTime.utc(2026, 5, 2, 8));
  });

  test('without the track there are no points and the meta says so',
      () async {
    final doc = await export(await buildVoyage(), track: false);
    expect(doc.ofType('track'), isEmpty);
    expect(doc.ofType('session').length, 2); // the sessions stay
    expect(doc.meta.flag('includes_track'), isFalse);
  });

  test('duty, handover with its checklist, assessment, signature, bearing',
      () async {
    final doc = await export(await buildVoyage());
    final days = doc.ofType('day').toList();

    final duty = doc.ofType('duty').single;
    expect(duty.text('name'), 'Eva Malá');
    expect(duty.parentId, days[0].id);
    expect(duty.instant('to_utc'), DateTime.utc(2026, 5, 2, 12));

    final h = doc.ofType('handover').single;
    expect(h.text('handover_type'), 'checkIn');
    expect(h.text('location'), 'Marina Kornati');
    expect(h.integer('fuel_level_pct'), 100);
    expect(h.instant('skipper_signed_utc'), DateTime.utc(2026, 5, 2, 7, 30));
    final items = doc.childrenOf('checklist', h.id).toList();
    expect(items.map((r) => r.text('item_key')), ['anchor', 'dinghy', 'x1']);
    expect(items[1].text('status'), 'damaged');
    expect(items[1].text('note'), 'prasknutý ventil');
    expect(items[2].text('custom_label'), 'Gril');

    final a = doc.ofType('assessment').single;
    expect((a.text('name'), a.integer('helming')), ('Eva Malá', 4));

    // A signature is a name and a time, not the image.
    final s = doc.ofType('signature').single;
    expect(s.text('name'), 'Ján Novák');
    expect(s.instant('signed_utc'), DateTime.utc(2026, 5, 2, 7, 31));
    expect(s.cells.values.any((v) => v.contains('sig.png')), isFalse);

    final b = doc.ofType('bearing').single;
    expect(b.parentId, days[0].id);
    expect(b.text('bearing_kind'), 'resection');
    expect(b.real('target_lat'), 43.95);
    expect(b.text('target_name'), 'Maják');
    expect(b.real('true_bearing_deg'), 127.5);
    expect(b.text('label'), 'Maják');
  });

  test('the voyage keeps one identity across exports', () async {
    final id = await buildVoyage();
    final first = (await export(id)).ofType('charter').single.text('uuid');
    final second = (await export(id)).ofType('charter').single.text('uuid');
    expect(first, second);
    expect((await db.getCharterById(id))!.syncUuid, first);
  });

  test('an existing identity is used, not replaced', () async {
    final id = await buildVoyage();
    await db.updateCharter(
        ChartersCompanion(id: Value(id), syncUuid: const Value('fixed-uuid')));
    expect((await export(id)).ofType('charter').single.text('uuid'),
        'fixed-uuid');
  });

  test('an empty voyage still exports', () async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Prázdna',
      dateFrom: DateTime.utc(2026, 1, 1),
      dateTo: DateTime.utc(2026, 1, 2),
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    final doc = await export(c.id);
    expect(doc.ofType('charter').single.text('title'), 'Prázdna');
    expect(doc.ofType('day'), isEmpty);
    expect(doc.warnings, isEmpty);
  });

  test('an unknown voyage is refused', () async {
    await expectLater(
      VoyageCsvExporter.write(db, 999, StringBuffer(),
          includeTrack: true, appVersion: 'x'),
      throwsArgumentError,
    );
  });

  test('the track point count matches what is exported', () async {
    final id = await buildVoyage();
    expect(await VoyageCsvExporter.trackPointCount(db, id), 6);
    final doc = await export(id);
    expect(doc.ofType('track').length, 6);
  });

  test('written to a file the way the export does, it is UTF-8 with a BOM',
      () async {
    final id = await buildVoyage();
    final dir = await Directory.systemTemp.createTemp('hmb_csv_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/voyage.csv');

    final sink = file.openWrite(encoding: utf8);
    try {
      await VoyageCsvExporter.write(db, id, sink,
          includeTrack: true, appVersion: 'x');
    } finally {
      await sink.flush();
      await sink.close();
    }

    final bytes = await file.readAsBytes();
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    final doc = VoyageCsvReader.read(utf8.decode(bytes));
    expect(doc.warnings, isEmpty);
    // Diacritics survive the encoding.
    expect(doc.ofType('charter').single.text('vessel_name'), 'Ružena');
    expect(doc.ofType('track').length, 6);
  });

  test('another voyage is not mixed in', () async {
    final id = await buildVoyage();
    final other = await db.insertCharter(ChartersCompanion.insert(
      title: 'Cudzia',
      dateFrom: DateTime.utc(2026, 6, 1),
      dateTo: DateTime.utc(2026, 6, 2),
      createdAt: DateTime.utc(2026, 6, 1),
    ));
    final otherDay = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: other.id, date: DateTime(2026, 6, 1)));
    await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
      dayLogId: Value(otherDay.id),
      timestamp: DateTime.utc(2026, 6, 1, 8),
      skipperNote: const Value('foreign'),
    ));

    final doc = await export(id);
    expect(doc.ofType('entry').any((e) => e.text('note') == 'foreign'), isFalse);
    expect(doc.ofType('day').length, 2);
  });
}
