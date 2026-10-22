import 'dart:convert';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/crew_member_ref.dart';
import '../../charter/services/handover_checklist.dart';
import '../format/voyage_csv_codec.dart';
import '../format/voyage_csv_record.dart';

class VoyageCsvExportResult {
  /// Records written, `meta` included.
  final int records;
  final int trackPoints;
  const VoyageCsvExportResult(this.records, this.trackPoints);
}

/// Writes one voyage, with everything the app knows about it, as a voyage CSV
/// (see `docs/CSV_FORMAT.md`).
///
/// Records go out in the order of the format's catalog, each with a running
/// number of its own type; links between them (a day's entries, a session's
/// points) use those numbers, not database ids. The track is read one session
/// at a time and written as it is read, so a long voyage is never held whole.
///
/// Not in the file, because they are not text: photos and the images of
/// signatures. A signature goes out as a name and a time.
abstract final class VoyageCsvExporter {
  /// How many track points a voyage has. Shown before exporting, because they
  /// are what makes the file large.
  static Future<int> trackPointCount(AppDatabase db, int charterId) async {
    final row = await db.customSelect(
      'SELECT COUNT(*) AS n FROM track_points WHERE session_id IN ('
      'SELECT session_id FROM sailing_sessions WHERE day_log_id IN ('
      'SELECT id FROM day_logs WHERE charter_id = ?))',
      variables: [Variable.withInt(charterId)],
    ).getSingle();
    return row.read<int>('n');
  }

  static Future<VoyageCsvExportResult> write(
    AppDatabase db,
    int charterId,
    StringSink sink, {
    required bool includeTrack,
    required String appVersion,
    DateTime? now,
  }) async {
    final charter = await db.getCharterById(charterId);
    if (charter == null) {
      throw ArgumentError.value(charterId, 'charterId', 'no such voyage');
    }

    // The voyage's identity, kept the same across exports. It is handed out
    // lazily, so an older voyage may not have one yet.
    var uuid = charter.syncUuid;
    if (uuid == null || uuid.isEmpty) {
      uuid = const Uuid().v4();
      await db.updateCharter(
          ChartersCompanion(id: Value(charterId), syncUuid: Value(uuid)));
    }

    // ── Read everything but the track points ──────────────────────
    final days = await db.getDayLogs(charterId);
    final dayIds = <int, int>{}; // database id → number in the file
    for (var i = 0; i < days.length; i++) {
      dayIds[days[i].id] = i + 1;
    }

    final sessions = <(int dayId, SailingSession session)>[];
    final sessionNumbers = <String, int>{}; // GPS session id → number
    final entries = <(int dayId, LogbookEntry entry)>[];
    for (final d in days) {
      for (final s in await db.getSessionsForDay(d.id, includeAnchorWatch: true)) {
        sessions.add((d.id, s));
        sessionNumbers[s.sessionId] = sessions.length;
      }
      for (final e in await db.getEntriesForDay(d.id)) {
        entries.add((d.id, e));
      }
    }

    final duties = await db.getDutiesForCharter(charterId);
    final protocols = <HandoverProtocol>[
      for (final type in ['checkIn', 'checkOut'])
        if (await db.getHandoverProtocol(charterId, type)
            case final p?)
          p,
    ];
    final assessments = await db.getCrewAssessments(charterId);
    final signatures = await db.getSignaturesForCharter(charterId);

    final bearingById = <int, Bearing>{
      for (final b in await db.getBearingsForCharter(charterId)) b.id: b,
      for (final d in days)
        for (final b in await db.getBearingsForDay(d.id)) b.id: b,
    };
    final bearings = bearingById.values.toList()
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    // ── Write ─────────────────────────────────────────────────────
    final out = VoyageCsvSink(sink);
    out.add(VoyageCsvRecord.meta(
      exportedAt: now ?? DateTime.now(),
      appVersion: appVersion,
      schemaVersion: db.schemaVersion,
      includesTrack: includeTrack,
    ));

    out.add(_charter(charter, uuid));
    _crew(out, charter);
    _lists(out, charter);

    for (final d in days) {
      out.add(_day(d, dayIds[d.id]!));
    }
    var n = 0;
    for (final (dayId, s) in sessions) {
      out.add(_session(s, ++n, dayIds[dayId]!));
    }
    n = 0;
    for (final (dayId, e) in entries) {
      out.add(_entry(e, ++n, dayIds[dayId]!, sessionNumbers[e.sessionId]));
    }

    var trackPoints = 0;
    if (includeTrack) {
      for (final (_, s) in sessions) {
        final sessionNo = sessionNumbers[s.sessionId]!;
        for (final p in await db.getTrackPointsForSession(s.sessionId)) {
          out.add(_trackPoint(p, ++trackPoints, sessionNo));
        }
      }
    }

    n = 0;
    for (final d in duties) {
      out.add(_duty(d, ++n, d.dayLogId == null ? null : dayIds[d.dayLogId]));
    }

    n = 0;
    var checklistNo = 0;
    for (final p in protocols) {
      out.add(_handover(p, ++n));
      for (final item in _checklist(p)) {
        out.add(_checklistItem(item, ++checklistNo, n));
      }
    }

    n = 0;
    for (final a in assessments) {
      out.add(_assessment(a, ++n));
    }
    n = 0;
    for (final s in signatures) {
      out.add(_signature(s, ++n));
    }
    n = 0;
    for (final b in bearings) {
      out.add(_bearing(b, ++n, b.dayLogId == null ? null : dayIds[b.dayLogId]));
    }

    out.finish();
    return VoyageCsvExportResult(out.count, trackPoints);
  }

  // ── Records ────────────────────────────────────────────────────────

  static VoyageCsvRecord _charter(Charter c, String uuid) =>
      VoyageCsvRecord('charter', id: 1)
        ..set('uuid', uuid)
        ..set('title', c.title)
        ..set('date_from_utc', c.dateFrom)
        ..set('date_to_utc', c.dateTo)
        ..set('vessel_name', c.vesselName)
        ..set('vessel_type', c.vesselType)
        ..set('vessel_model', c.vesselModel)
        ..set('vessel_flag', c.vesselFlag)
        ..set('home_port', c.homePort)
        ..set('charter_company', c.charterCompany)
        ..set('country', c.country)
        ..set('cruising_area', c.cruisingArea)
        ..set('route', c.route)
        ..set('callsign', c.callsign)
        ..set('mmsi', c.mmsi)
        ..set('length_m', c.vesselLengthM)
        ..set('beam_m', c.vesselBeamM)
        ..set('draft_m', c.vesselDraftM)
        ..set('berths', c.berths)
        ..set('year_built', c.yearBuilt)
        ..set('engine', c.engine)
        ..set('water_tank_l', c.waterTankL)
        ..set('fuel_tank_l', c.fuelTankL)
        ..set('engine_hours_start', c.engineHoursStart)
        ..set('engine_hours_end', c.engineHoursEnd)
        ..set('cost_currency', c.costCurrency)
        ..set('my_role', c.myRole)
        ..set('tidal_waters', c.tidalWaters)
        ..set('captain_first_name', c.captainFirstName)
        ..set('captain_last_name', c.captainLastName)
        ..set('captain_qualification', c.captainQualification)
        ..set('safety_briefing_done', c.safetyBriefingDone)
        ..set('check_in_done', c.checkInDone)
        ..set('check_out_done', c.checkOutDone)
        ..set('archived', c.archived)
        ..set('source', c.source)
        ..set('created_utc', c.createdAt)
        ..set('note', c.notes);

  static void _crew(VoyageCsvSink out, Charter c) {
    var n = 0;
    for (final m in CrewMemberRef.parse(
      c.crewJson,
      skipperName: c.skipperName,
      crewNames: c.crewNames,
    )) {
      out.add(VoyageCsvRecord('crew', id: ++n)
        ..set('name', m.name)
        ..set('role', m.role)
        ..set('qualification', m.qualification)
        ..set('boat_licence', m.boatLicence)
        ..set('radio_licence', m.radioLicence)
        ..set('other_certs', m.otherCerts));
    }
  }

  /// Contacts, costs and the briefing points: three small JSON lists on the
  /// voyage. A damaged one is skipped rather than failing the export.
  static void _lists(VoyageCsvSink out, Charter c) {
    var n = 0;
    for (final v in _jsonList(c.contactsJson)) {
      final text = v?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      out.add(VoyageCsvRecord('contact', id: ++n)..set('value', text));
    }

    n = 0;
    for (final v in _jsonList(c.costsJson)) {
      if (v is! Map) continue;
      final label = (v['label'] ?? v['name'])?.toString();
      final amount = v['amount'] is num
          ? (v['amount'] as num).toDouble()
          : double.tryParse('${v['amount']}'.replaceAll(',', '.'));
      if (label == null && amount == null) continue;
      out.add(VoyageCsvRecord('cost', id: ++n)
        ..set('name', label)
        ..set('amount', amount));
    }

    n = 0;
    for (final v in _jsonList(c.briefingCheckedJson)) {
      final text = v?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      out.add(VoyageCsvRecord('briefing', id: ++n)..set('value', text));
    }
  }

  static List<Object?> _jsonList(String? json) {
    if (json == null || json.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      return decoded is List ? decoded : const [];
    } catch (_) {
      return const [];
    }
  }

  static VoyageCsvRecord _day(DayLog d, int id) =>
      VoyageCsvRecord('day', id: id)
        ..set('date', d.date)
        ..set('port_from', d.portFrom)
        ..set('port_to', d.portTo)
        ..set('vessel_for_day', d.vesselForDay)
        ..set('distance_nm', d.distanceNm)
        ..set('beaufort_morning', d.beaufortMorning)
        ..set('beaufort_noon', d.beaufortNoon)
        ..set('beaufort_evening', d.beaufortEvening)
        ..set('sea_state', d.seaState)
        ..set('wave_height_m', d.waveHeightM)
        ..set('wind_direction', d.windDirection)
        ..set('air_temp_c', d.airTempC)
        ..set('water_temp_c', d.waterTempC)
        ..set('engine_hours', d.engineHours)
        ..set('night_hours_manual', d.nightHoursManual)
        ..set('complete', d.isComplete)
        ..set('note', d.skipperNote);

  static VoyageCsvRecord _session(SailingSession s, int id, int dayNo) =>
      VoyageCsvRecord('session', id: id, parentId: dayNo)
        ..set('from_utc', s.startTime)
        ..set('to_utc', s.endTime)
        ..set('name', s.name)
        ..set('distance_nm', s.totalDistanceNm)
        ..set('max_speed_kn', s.maxSpeedKnots)
        ..set('avg_speed_kn', s.avgSpeedKnots)
        ..set('anchor_watch', s.isAnchorWatch)
        ..set('estimated', s.isEstimated);

  static VoyageCsvRecord _entry(
          LogbookEntry e, int id, int dayNo, int? sessionNo) =>
      VoyageCsvRecord('entry', id: id, parentId: dayNo)
        ..set('time_utc', e.timestamp)
        ..set('lat', e.latitude)
        ..set('lon', e.longitude)
        ..set('sog_kn', e.sog)
        ..set('cog_deg', e.cog)
        ..set('heading_deg', e.heading)
        ..set('wind_kn', e.windSpeed)
        ..set('wind_dir_deg', e.windDirection)
        ..set('wave_m', e.waveHeight)
        ..set('pressure_hpa', e.airPressure)
        ..set('air_temp_c', e.airTemp)
        ..set('water_temp_c', e.waterTemp)
        ..set('engine_hours', e.engineHours)
        ..set('fuel_consumed_l', e.fuelConsumed)
        ..set('fuel_level_pct', e.fuelLevel)
        ..set('water_level_pct', e.waterLevel)
        ..set('helmsman', e.skipperName)
        ..set('crew_names', e.crewNames)
        ..set('note', e.skipperNote)
        ..set('auto_entry', e.isAutoEntry)
        ..set('event_type', e.eventType)
        ..set('sail_mode', e.sailMode)
        ..set('point_of_sail', e.pointOfSail)
        ..set('tack', e.tack)
        ..set('depth_m', e.depthMeters)
        ..set('weather_condition', e.weatherCondition)
        ..set('accuracy_m', e.accuracyMeters)
        ..set('location_source', e.locationSource)
        ..set('mocked', e.isMocked)
        ..set('weather_source', e.weatherSource)
        ..set('weather_station', e.weatherStation)
        ..set('weather_station_distance_m', e.weatherStationDistanceM)
        ..set('session_ref', sessionNo);

  static VoyageCsvRecord _trackPoint(TrackPoint p, int id, int sessionNo) =>
      VoyageCsvRecord('track', id: id, parentId: sessionNo)
        ..set('time_utc', p.timestamp)
        ..set('lat', p.latitude)
        ..set('lon', p.longitude)
        ..set('altitude_m', p.altitude)
        ..set('speed_kn', p.speed)
        ..set('course_deg', p.course)
        // Points from before the location metadata (schema v15) only have
        // the plain accuracy.
        ..set('accuracy_m', p.accuracyMeters ?? p.accuracy)
        ..set('location_source', p.locationSource)
        ..set('mocked', p.isMocked);

  static VoyageCsvRecord _duty(DutyPeriod d, int id, int? dayNo) =>
      VoyageCsvRecord('duty', id: id, parentId: dayNo)
        ..set('name', d.crewName)
        ..set('role', d.role)
        ..set('from_utc', d.fromUtc)
        ..set('to_utc', d.toUtc)
        ..set('note', d.note)
        ..set('auto_closed', d.isAutoClosed);

  static VoyageCsvRecord _handover(HandoverProtocol p, int id) =>
      VoyageCsvRecord('handover', id: id)
        ..set('handover_type', p.type)
        ..set('time_utc', p.dateTimeUtc)
        ..set('location', p.location)
        ..set('fuel_level_pct', p.fuelLevel)
        ..set('water_level_pct', p.waterLevel)
        ..set('engine_hours', p.engineHours)
        ..set('skipper_name', p.skipperName)
        ..set('skipper_signed_utc', p.skipperSignedAt)
        ..set('company_rep', p.companyRepName)
        ..set('company_name', p.companyName)
        ..set('company_signed_utc', p.companySignedAt)
        ..set('note', p.extraNotes);

  static List<ChecklistItem> _checklist(HandoverProtocol p) {
    try {
      return [
        for (final v in jsonDecode(p.checklistJson) as List)
          ChecklistItem.fromJson(Map<String, dynamic>.from(v as Map)),
      ];
    } catch (_) {
      return const [];
    }
  }

  static VoyageCsvRecord _checklistItem(
          ChecklistItem i, int id, int handoverNo) =>
      VoyageCsvRecord('checklist', id: id, parentId: handoverNo)
        ..set('item_key', i.itemKey)
        ..set('status', i.status.name)
        ..set('note', i.note)
        ..set('position', i.position)
        ..set('custom_label', i.customLabel)
        ..set('category_key', i.categoryKey);

  static VoyageCsvRecord _assessment(CrewAssessment a, int id) =>
      VoyageCsvRecord('assessment', id: id)
        ..set('name', a.crewName)
        ..set('helming', a.helming)
        ..set('navigation', a.navigation)
        ..set('harbour_manoeuvres', a.harbourManoeuvres)
        ..set('teamwork', a.teamwork)
        ..set('night_sailing', a.nightSailing)
        ..set('note', a.note);

  static VoyageCsvRecord _signature(CrewSignature s, int id) =>
      VoyageCsvRecord('signature', id: id)
        ..set('name', s.crewName)
        ..set('role', s.role)
        ..set('signed_utc', s.signedAt);

  static VoyageCsvRecord _bearing(Bearing b, int id, int? dayNo) =>
      VoyageCsvRecord('bearing', id: id, parentId: dayNo)
        ..set('bearing_kind', b.kind)
        ..set('lat', b.observerLat)
        ..set('lon', b.observerLon)
        ..set('accuracy_m', b.accuracyMeters)
        ..set('target_lat', b.targetLat)
        ..set('target_lon', b.targetLon)
        ..set('target_name', b.targetName)
        ..set('magnetic_bearing_deg', b.magneticBearing)
        ..set('declination_deg', b.declination)
        ..set('declination_source', b.declinationSource)
        ..set('true_bearing_deg', b.trueBearing)
        ..set('uncertainty_deg', b.uncertaintyDeg)
        ..set('sight_group', b.sightGroupId)
        ..set('label', b.label)
        ..set('time_utc', b.takenAt)
        ..set('hidden_from_map', b.hiddenFromMap);
}
