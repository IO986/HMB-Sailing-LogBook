import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:hmb_sailing_log/core/database/app_database.dart';

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
Future<int> buildFullVoyage(AppDatabase db) async {
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
