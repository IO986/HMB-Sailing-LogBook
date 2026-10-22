import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/charter_source.dart';
import '../../charter/services/handover_checklist.dart';
import '../format/voyage_csv_record.dart';

/// What a file holds, for showing before anything is written.
class VoyageCsvPreview {
  final String? title;
  final DateTime? from;
  final DateTime? to;
  final String? vesselName;
  final String? uuid;
  final bool includesTrack;

  /// Records by type, `meta` and `charter` left out.
  final Map<String, int> counts;

  /// What the reader already had to leave out.
  final List<VoyageCsvWarning> warnings;

  const VoyageCsvPreview({
    required this.title,
    required this.from,
    required this.to,
    required this.vesselName,
    required this.uuid,
    required this.includesTrack,
    required this.counts,
    required this.warnings,
  });

  int count(String type) => counts[type] ?? 0;
}

class VoyageCsvImportResult {
  final int charterId;

  /// Records written, by type.
  final Map<String, int> imported;

  /// What was left out, from reading and from writing.
  final List<VoyageCsvWarning> warnings;

  const VoyageCsvImportResult(this.charterId, this.imported, this.warnings);
}

/// The voyage in the file is already in the app.
class VoyageAlreadyImportedException implements Exception {
  final int charterId;
  final String title;
  const VoyageAlreadyImportedException(this.charterId, this.title);

  @override
  String toString() => 'Voyage "$title" is already in the app.';
}

/// Reads a voyage CSV into the database as a new voyage.
///
/// Nothing that exists is changed. The voyage arrives as a finished copy
/// (`CharterSource.csv`), with its own database ids; the numbers in the file
/// only say which record belongs to which. It keeps the `uuid` of the file, so
/// the same file read twice is recognised and refused, and a voyage that
/// travelled to another phone stays the same voyage.
///
/// Records that cannot be used (no time, no parent) are skipped and counted in
/// the result, not allowed to stop the rest. The whole write is one
/// transaction: it is all there, or none of it is.
abstract final class VoyageCsvImporter {
  static VoyageCsvPreview preview(VoyageCsvDocument doc) {
    final charter = doc.ofType('charter').firstOrNull;
    final counts = <String, int>{};
    for (final r in doc.records) {
      if (r.type == 'meta' || r.type == 'charter') continue;
      counts.update(r.type, (n) => n + 1, ifAbsent: () => 1);
    }
    return VoyageCsvPreview(
      title: charter?.text('title'),
      from: charter?.instant('date_from_utc'),
      to: charter?.instant('date_to_utc'),
      vesselName: charter?.text('vessel_name'),
      uuid: charter?.text('uuid'),
      includesTrack: doc.meta.flag('includes_track') ?? false,
      counts: counts,
      warnings: doc.warnings,
    );
  }

  /// The voyage already in the database that this file describes, if any.
  static Future<Charter?> findExisting(
      AppDatabase db, VoyageCsvDocument doc) async {
    final uuid = doc.ofType('charter').firstOrNull?.text('uuid');
    if (uuid == null || uuid.isEmpty) return null;
    return (db.select(db.charters)..where((c) => c.syncUuid.equals(uuid)))
        .getSingleOrNull();
  }

  static Future<VoyageCsvImportResult> importInto(
    AppDatabase db,
    VoyageCsvDocument doc, {
    DateTime? now,
  }) async {
    final charter = doc.ofType('charter').firstOrNull;
    if (charter == null) {
      throw const VoyageCsvFormatException(VoyageCsvProblem.noVoyage);
    }
    final existing = await findExisting(db, doc);
    if (existing != null) {
      throw VoyageAlreadyImportedException(existing.id, existing.title);
    }

    final at = now ?? DateTime.now();
    final w = _Skipped();
    final imported = <String, int>{};
    void count(String type) =>
        imported.update(type, (n) => n + 1, ifAbsent: () => 1);

    late final int charterId;
    await db.transaction(() async {
      charterId = await _charter(db, doc, charter, at, w);
      count('charter');

      // Numbers in the file → ids made here.
      final dayIds = <int, int>{};
      final sessionIds = <int, String>{};
      final handoverIds = <int, int>{};

      for (final r in doc.ofType('day')) {
        final date = r.date('date');
        if (date == null || r.id == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'day');
          continue;
        }
        final day = await db.insertDayLog(DayLogsCompanion.insert(
          charterId: charterId,
          date: date,
          portFrom: Value(r.text('port_from')),
          portTo: Value(r.text('port_to')),
          vesselForDay: Value(r.text('vessel_for_day')),
          distanceNm: Value(r.real('distance_nm') ?? 0),
          beaufortMorning: Value(r.integer('beaufort_morning')),
          beaufortNoon: Value(r.integer('beaufort_noon')),
          beaufortEvening: Value(r.integer('beaufort_evening')),
          seaState: Value(r.text('sea_state')),
          waveHeightM: Value(r.real('wave_height_m')),
          windDirection: Value(r.text('wind_direction')),
          airTempC: Value(r.real('air_temp_c')),
          waterTempC: Value(r.real('water_temp_c')),
          skipperNote: Value(r.text('note')),
          isComplete: Value(r.flag('complete') ?? false),
          engineHours: Value(r.real('engine_hours')),
          nightHoursManual: Value(r.real('night_hours_manual')),
        ));
        dayIds[r.id!] = day.id;
        count('day');
      }

      for (final r in doc.ofType('session')) {
        final dayId = dayIds[r.parentId];
        final start = r.instant('from_utc');
        if (r.id == null || dayId == null) {
          w.skip(VoyageCsvWarningKind.orphan, 'session');
          continue;
        }
        if (start == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'session');
          continue;
        }
        final sessionId = const Uuid().v4();
        await db.upsertSession(SailingSessionsCompanion.insert(
          sessionId: sessionId,
          dayLogId: Value(dayId),
          startTime: start,
          endTime: Value(r.instant('to_utc')),
          name: Value(r.text('name')),
          totalDistanceNm: Value(r.real('distance_nm') ?? 0),
          maxSpeedKnots: Value(r.real('max_speed_kn') ?? 0),
          avgSpeedKnots: Value(r.real('avg_speed_kn') ?? 0),
          isActive: const Value(false),
          isAnchorWatch: Value(r.flag('anchor_watch') ?? false),
          isEstimated: Value(r.flag('estimated') ?? false),
        ));
        sessionIds[r.id!] = sessionId;
        count('session');
      }

      for (final r in doc.ofType('entry')) {
        final dayId = dayIds[r.parentId];
        final time = r.instant('time_utc');
        if (dayId == null) {
          w.skip(VoyageCsvWarningKind.orphan, 'entry');
          continue;
        }
        if (time == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'entry');
          continue;
        }
        await db.insertLogbookEntry(LogbookEntriesCompanion.insert(
          dayLogId: Value(dayId),
          sessionId: Value(sessionIds[r.integer('session_ref')]),
          timestamp: time,
          latitude: Value(r.real('lat')),
          longitude: Value(r.real('lon')),
          sog: Value(r.real('sog_kn')),
          cog: Value(r.real('cog_deg')),
          heading: Value(r.real('heading_deg')),
          windSpeed: Value(r.real('wind_kn')),
          windDirection: Value(r.real('wind_dir_deg')),
          waveHeight: Value(r.real('wave_m')),
          airPressure: Value(r.real('pressure_hpa')),
          airTemp: Value(r.real('air_temp_c')),
          waterTemp: Value(r.real('water_temp_c')),
          engineHours: Value(r.real('engine_hours')),
          fuelConsumed: Value(r.real('fuel_consumed_l')),
          fuelLevel: Value(r.integer('fuel_level_pct')),
          waterLevel: Value(r.integer('water_level_pct')),
          skipperName: Value(r.text('helmsman')),
          crewNames: Value(r.text('crew_names')),
          skipperNote: Value(r.text('note')),
          isAutoEntry: Value(r.flag('auto_entry') ?? false),
          eventType: Value(r.text('event_type')),
          sailMode: Value(r.text('sail_mode')),
          pointOfSail: Value(r.text('point_of_sail')),
          tack: Value(r.text('tack')),
          depthMeters: Value(r.real('depth_m')),
          weatherCondition: Value(r.text('weather_condition')),
          accuracyMeters: Value(r.real('accuracy_m')),
          locationSource: Value(r.text('location_source')),
          isMocked: Value(r.flag('mocked')),
          weatherSource: Value(r.text('weather_source')),
          weatherStation: Value(r.text('weather_station')),
          weatherStationDistanceM: Value(r.real('weather_station_distance_m')),
        ));
        count('entry');
      }

      // Track points go in batches: a long voyage has hundreds of thousands.
      final batch = <TrackPointsCompanion>[];
      Future<void> flush() async {
        if (batch.isEmpty) return;
        await db.insertTrackPointsBatch(List.of(batch));
        batch.clear();
      }

      for (final r in doc.ofType('track')) {
        final sessionId = sessionIds[r.parentId];
        final time = r.instant('time_utc');
        final lat = r.real('lat');
        final lon = r.real('lon');
        if (sessionId == null) {
          w.skip(VoyageCsvWarningKind.orphan, 'track');
          continue;
        }
        if (time == null || lat == null || lon == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'track');
          continue;
        }
        batch.add(TrackPointsCompanion.insert(
          sessionId: Value(sessionId),
          timestamp: time,
          latitude: lat,
          longitude: lon,
          altitude: Value(r.real('altitude_m')),
          speed: Value(r.real('speed_kn')),
          course: Value(r.real('course_deg')),
          accuracyMeters: Value(r.real('accuracy_m')),
          locationSource: Value(r.text('location_source')),
          isMocked: Value(r.flag('mocked')),
        ));
        count('track');
        if (batch.length >= 2000) await flush();
      }
      await flush();

      for (final r in doc.ofType('duty')) {
        final name = r.text('name');
        final from = r.instant('from_utc');
        if (name == null || from == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'duty');
          continue;
        }
        await db.insertDutyPeriod(DutyPeriodsCompanion.insert(
          charterId: charterId,
          dayLogId: Value(dayIds[r.parentId]),
          crewName: name,
          role: Value(r.text('role') ?? 'crew'),
          fromUtc: from,
          toUtc: Value(r.instant('to_utc')),
          note: Value(r.text('note')),
          isAutoClosed: Value(r.flag('auto_closed') ?? false),
          createdAt: at,
        ));
        count('duty');
      }

      final seenProtocols = <String>{};
      for (final r in doc.ofType('handover')) {
        final type = r.text('handover_type');
        final time = r.instant('time_utc');
        if (r.id == null || (type != 'checkIn' && type != 'checkOut') || time == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'handover');
          continue;
        }
        if (!seenProtocols.add(type!)) {
          w.skip(VoyageCsvWarningKind.duplicate, type);
          continue;
        }
        final items = <Map<String, dynamic>>[];
        for (final c in doc.childrenOf('checklist', r.id)) {
          final key = c.text('item_key');
          if (key == null) {
            w.skip(VoyageCsvWarningKind.invalid, 'checklist');
            continue;
          }
          items.add(ChecklistItem(
            itemKey: key,
            status: ChecklistStatus.values.firstWhere(
              (s) => s.name == c.text('status'),
              orElse: () => ChecklistStatus.ok,
            ),
            note: c.text('note'),
            position: c.text('position'),
            customLabel: c.text('custom_label'),
            categoryKey: c.text('category_key'),
          ).toJson());
          count('checklist');
        }
        await db.upsertHandoverProtocol(HandoverProtocolsCompanion.insert(
          charterId: charterId,
          type: type,
          dateTimeUtc: time,
          createdAt: at,
          location: Value(r.text('location')),
          fuelLevel: Value(r.integer('fuel_level_pct')),
          waterLevel: Value(r.integer('water_level_pct')),
          engineHours: Value(r.real('engine_hours')),
          checklistJson: Value(jsonEncode(items)),
          skipperName: Value(r.text('skipper_name')),
          skipperSignedAt: Value(r.instant('skipper_signed_utc')),
          companyRepName: Value(r.text('company_rep')),
          companyName: Value(r.text('company_name')),
          companySignedAt: Value(r.instant('company_signed_utc')),
          extraNotes: Value(r.text('note')),
        ));
        handoverIds[r.id!] = 0;
        count('handover');
      }
      // Checklist items whose protocol is not in the file or was skipped.
      for (final c in doc.ofType('checklist')) {
        if (!handoverIds.containsKey(c.parentId)) {
          w.skip(VoyageCsvWarningKind.orphan, 'checklist');
        }
      }

      for (final r in doc.ofType('assessment')) {
        final name = r.text('name');
        if (name == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'assessment');
          continue;
        }
        await db.upsertCrewAssessment(CrewAssessmentsCompanion.insert(
          charterId: charterId,
          crewName: name,
          updatedAt: at,
          helming: Value(r.integer('helming')),
          navigation: Value(r.integer('navigation')),
          harbourManoeuvres: Value(r.integer('harbour_manoeuvres')),
          teamwork: Value(r.integer('teamwork')),
          nightSailing: Value(r.integer('night_sailing')),
          note: Value(r.text('note')),
        ));
        count('assessment');
      }

      for (final r in doc.ofType('signature')) {
        final name = r.text('name');
        if (name == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'signature');
          continue;
        }
        // The image is not in the file: the person is recorded as having
        // signed, and the image has to be drawn again.
        await db.upsertCrewSignature(CrewSignaturesCompanion.insert(
          charterId: charterId,
          crewName: name,
          role: Value(r.text('role') ?? 'crew'),
          signedAt: Value(r.instant('signed_utc')),
        ));
        count('signature');
      }

      // Bearings that belong together share a sight group; the group gets a
      // new name here so it cannot collide with one already in the database.
      final groups = <String, String>{};
      for (final r in doc.ofType('bearing')) {
        final kind = r.text('bearing_kind');
        final magnetic = r.real('magnetic_bearing_deg');
        final declination = r.real('declination_deg');
        final trueBearing = r.real('true_bearing_deg');
        final taken = r.instant('time_utc');
        final group = r.text('sight_group');
        final lat = r.real('lat');
        final lon = r.real('lon');
        final tLat = r.real('target_lat');
        final tLon = r.real('target_lon');
        if (magnetic == null || declination == null || trueBearing == null || taken == null) {
          w.skip(VoyageCsvWarningKind.invalid, 'bearing');
          continue;
        }
        // The same rule the table enforces; a row that breaks it would abort
        // the whole import.
        final ok = (kind == 'resection' && tLat != null && tLon != null && group == null) ||
            (kind == 'intersection' && lat != null && lon != null && group != null);
        if (!ok) {
          w.skip(VoyageCsvWarningKind.invalid, 'bearing');
          continue;
        }
        await db.insertBearing(BearingsCompanion.insert(
          kind: kind!,
          magneticBearing: magnetic,
          declination: declination,
          trueBearing: trueBearing,
          takenAt: taken,
          observerLat: Value(lat),
          observerLon: Value(lon),
          accuracyMeters: Value(r.real('accuracy_m')),
          targetLat: Value(tLat),
          targetLon: Value(tLon),
          targetName: Value(r.text('target_name')),
          declinationSource: Value(r.text('declination_source')),
          // A column with a default: an empty cell leaves the default.
          uncertaintyDeg: r.real('uncertainty_deg') == null
              ? const Value.absent()
              : Value(r.real('uncertainty_deg')!),
          sightGroupId: Value(group == null
              ? null
              : groups.putIfAbsent(group, () => const Uuid().v4())),
          label: Value(r.text('label')),
          dayLogId: Value(dayIds[r.parentId]),
          charterId: Value(charterId),
          hiddenFromMap: Value(r.flag('hidden_from_map') ?? false),
        ));
        count('bearing');
      }
    });

    return VoyageCsvImportResult(
        charterId, imported, [...doc.warnings, ...w.toWarnings()]);
  }

  static Future<int> _charter(
    AppDatabase db,
    VoyageCsvDocument doc,
    VoyageCsvRecord r,
    DateTime now,
    _Skipped w,
  ) async {
    // Dates are required by the table. A file that lacks them gets the span of
    // its days, and failing that, today.
    final days = [for (final d in doc.ofType('day')) d.date('date')]
        .whereType<DateTime>()
        .toList()
      ..sort();
    final from = r.instant('date_from_utc') ?? (days.isEmpty ? now : days.first);
    final to = r.instant('date_to_utc') ?? (days.isEmpty ? from : days.last);

    final crew = <Map<String, Object?>>[];
    String? skipperName;
    final others = <String>[];
    for (final c in doc.ofType('crew')) {
      final name = c.text('name');
      if (name == null) {
        w.skip(VoyageCsvWarningKind.invalid, 'crew');
        continue;
      }
      final role = c.text('role') == 'skipper' ? 'skipper' : 'crew';
      crew.add({
        'name': name,
        'role': role,
        if (c.text('qualification') != null) 'qualification': c.text('qualification'),
        if (c.text('boat_licence') != null) 'boatLicence': c.text('boat_licence'),
        if (c.text('radio_licence') != null) 'radioLicence': c.text('radio_licence'),
        if (c.text('other_certs') != null) 'otherCerts': c.text('other_certs'),
      });
      if (role == 'skipper' && skipperName == null) {
        skipperName = name;
      } else {
        others.add(name);
      }
    }

    final contacts = [
      for (final c in doc.ofType('contact'))
        if (c.text('value') != null) c.text('value'),
    ];
    final costs = [
      for (final c in doc.ofType('cost'))
        if (c.text('name') != null || c.real('amount') != null)
          {'label': c.text('name'), 'amount': c.real('amount')},
    ];
    final briefing = [
      for (final c in doc.ofType('briefing'))
        if (c.text('value') != null) c.text('value'),
    ];

    final c = await db.insertCharter(ChartersCompanion.insert(
      title: r.text('title') ?? 'Import CSV',
      dateFrom: from,
      dateTo: to,
      createdAt: r.instant('created_utc') ?? now,
      vesselName: Value(r.text('vessel_name')),
      vesselType: Value(r.text('vessel_type')),
      vesselModel: Value(r.text('vessel_model')),
      vesselFlag: Value(r.text('vessel_flag')),
      homePort: Value(r.text('home_port')),
      charterCompany: Value(r.text('charter_company')),
      country: Value(r.text('country')),
      cruisingArea: Value(r.text('cruising_area')),
      route: Value(r.text('route')),
      callsign: Value(r.text('callsign')),
      mmsi: Value(r.text('mmsi')),
      vesselLengthM: Value(r.real('length_m')),
      vesselBeamM: Value(r.real('beam_m')),
      vesselDraftM: Value(r.real('draft_m')),
      berths: Value(r.integer('berths')),
      yearBuilt: Value(r.integer('year_built')),
      engine: Value(r.text('engine')),
      waterTankL: Value(r.real('water_tank_l')),
      fuelTankL: Value(r.real('fuel_tank_l')),
      engineHoursStart: Value(r.real('engine_hours_start')),
      engineHoursEnd: Value(r.real('engine_hours_end')),
      costCurrency: Value(r.text('cost_currency')),
      myRole: Value(r.text('my_role')),
      tidalWaters: Value(r.flag('tidal_waters')),
      captainFirstName: Value(r.text('captain_first_name')),
      captainLastName: Value(r.text('captain_last_name')),
      captainQualification: Value(r.text('captain_qualification')),
      safetyBriefingDone: Value(r.flag('safety_briefing_done') ?? false),
      checkInDone: Value(r.flag('check_in_done') ?? false),
      checkOutDone: Value(r.flag('check_out_done') ?? false),
      archived: Value(r.flag('archived') ?? false),
      notes: Value(r.text('note')),
      skipperName: Value(skipperName),
      crewNames: Value(others.isEmpty ? null : others.join('|')),
      crewJson: Value(crew.isEmpty ? null : jsonEncode(crew)),
      contactsJson: Value(contacts.isEmpty ? null : jsonEncode(contacts)),
      costsJson: Value(costs.isEmpty ? null : jsonEncode(costs)),
      briefingCheckedJson: Value(briefing.isEmpty ? null : jsonEncode(briefing)),
      source: const Value(CharterSource.csv),
      syncUuid: Value(r.text('uuid') ?? const Uuid().v4()),
      updatedAt: Value(now),
    ));
    return c.id;
  }
}

/// Counts of records left out while writing, one warning per kind and type.
class _Skipped {
  final _counts = <(VoyageCsvWarningKind, String), int>{};

  void skip(VoyageCsvWarningKind kind, String what) =>
      _counts.update((kind, what), (n) => n + 1, ifAbsent: () => 1);

  List<VoyageCsvWarning> toWarnings() => [
        for (final e in _counts.entries)
          VoyageCsvWarning(
              e.key.$1, e.value == 1 ? e.key.$2 : '${e.key.$2} ×${e.value}'),
      ];
}
