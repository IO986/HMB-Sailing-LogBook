import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import 'account_service.dart';

// ── API kontrakt (backend musí implementovať) ─────────────────
//
// POST https://api.logbook.hmba.boats/v1/charters
//   Headers:  Authorization: Bearer {token}
//   Body:     viz _buildPayload()
//   Response: { "id": "uuid", "synced_at": "2026-06-26T12:00:00Z" }
//
// PUT https://api.logbook.hmba.boats/v1/charters/{remoteId}
//   Headers:  Authorization: Bearer {token}
//   Body:     viz _buildPayload()
//   Response: { "id": "uuid", "synced_at": "2026-06-26T12:00:00Z" }
//
// Štruktúra tela (JSON):
// {
//   "charter": {
//     "title": "...", "vessel_name": "...", "vessel_type": "...",
//     "skipper_name": "...", "crew_names": ["..."],
//     "date_from": "YYYY-MM-DD", "date_to": "YYYY-MM-DD",
//     "home_port": "...", "notes": "..."
//   },
//   "days": [
//     {
//       "date": "YYYY-MM-DD", "port_from": "...", "port_to": "...",
//       "vessel_for_day": "...", "distance_nm": 0.0,
//       "beaufort_morning": null, "beaufort_noon": null, "beaufort_evening": null,
//       "sea_state": "...", "wave_height_m": null,
//       "wind_direction": "...", "air_temp_c": null, "water_temp_c": null,
//       "skipper_note": "...", "is_complete": false,
//       "entries": [
//         {
//           "timestamp": "ISO8601 UTC",
//           "latitude": null, "longitude": null,
//           "sog": null, "cog": null, "heading": null,
//           "wind_speed": null, "wind_direction": null, "wave_height": null,
//           "air_pressure": null, "air_temp": null, "water_temp": null,
//           "engine_hours": null, "fuel_consumed": null,
//           "skipper_note": "...", "is_auto_entry": false,
//           "weather_condition": "...", "photo_url": null
//         }
//       ]
//     }
//   ]
// }

const _kApiBase = 'https://api.logbook.hmba.boats';

enum SyncResult { ok, notLoggedIn, networkError, serverError }

class SyncService {
  static final SyncService _i = SyncService._();
  factory SyncService() => _i;
  SyncService._();

  final _dio = Dio(BaseOptions(
    baseUrl: _kApiBase,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  AppDatabase? _db;
  void setDatabase(AppDatabase db) => _db = db;

  /// Synchronizuje charter na server. Vracia [SyncResult] a voliteľne remote ID.
  Future<({SyncResult result, String? remoteId, DateTime? syncedAt})> syncCharter({
    required Charter charter,
    required List<DayLog> days,
    required Map<int, List<LogbookEntry>> entriesByDay,
  }) async {
    final account = AccountService();
    if (!account.isLoggedIn) {
      return (result: SyncResult.notLoggedIn, remoteId: null, syncedAt: null);
    }

    final payload = _buildPayload(charter, days, entriesByDay);
    final headers = {
      ...account.authHeaders,
      'Content-Type': 'application/json',
    };

    try {
      final Response<dynamic> resp;
      if (charter.remoteId != null) {
        resp = await _dio.put(
          '/v1/charters/${charter.remoteId}',
          data: payload,
          options: Options(headers: headers),
        );
      } else {
        resp = await _dio.post(
          '/v1/charters',
          data: payload,
          options: Options(headers: headers),
        );
      }

      final data = resp.data as Map<String, dynamic>;
      final remoteId  = data['id'] as String?;
      final syncedAt  = data['synced_at'] != null
          ? DateTime.parse(data['synced_at'] as String)
          : DateTime.now().toUtc();

      // Uložíme remoteId a syncedAt do lokálnej DB
      if (_db != null && remoteId != null) {
        await _db!.updateCharterSync(charter.id,
            remoteId: remoteId, syncedAt: syncedAt);
      }

      return (result: SyncResult.ok, remoteId: remoteId, syncedAt: syncedAt);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return (result: SyncResult.networkError, remoteId: null, syncedAt: null);
      }
      return (result: SyncResult.serverError, remoteId: null, syncedAt: null);
    }
  }

  Map<String, dynamic> _buildPayload(
    Charter charter,
    List<DayLog> days,
    Map<int, List<LogbookEntry>> entriesByDay,
  ) {
    final fmt = DateFormat('yyyy-MM-dd');
    return {
      'charter': {
        'title': charter.title,
        'vessel_name': charter.vesselName,
        'vessel_type': charter.vesselType,
        'skipper_name': charter.skipperName,
        'crew_names': charter.crewNames?.split('|')
            .where((s) => s.isNotEmpty).toList() ?? [],
        'date_from': fmt.format(charter.dateFrom),
        'date_to': fmt.format(charter.dateTo),
        'home_port': charter.homePort,
        'notes': charter.notes,
      },
      'days': days.map((day) {
        final entries = entriesByDay[day.id] ?? [];
        return {
          'date': fmt.format(day.date),
          'port_from': day.portFrom,
          'port_to': day.portTo,
          'vessel_for_day': day.vesselForDay,
          'distance_nm': day.distanceNm,
          'beaufort_morning': day.beaufortMorning,
          'beaufort_noon': day.beaufortNoon,
          'beaufort_evening': day.beaufortEvening,
          'sea_state': day.seaState,
          'wave_height_m': day.waveHeightM,
          'wind_direction': day.windDirection,
          'air_temp_c': day.airTempC,
          'water_temp_c': day.waterTempC,
          'skipper_note': day.skipperNote,
          'is_complete': day.isComplete,
          'entries': entries.map((e) => {
            'timestamp': e.timestamp.toUtc().toIso8601String(),
            'latitude': e.latitude,
            'longitude': e.longitude,
            'sog': e.sog,
            'cog': e.cog,
            'heading': e.heading,
            'wind_speed': e.windSpeed,
            'wind_direction': e.windDirection,
            'wave_height': e.waveHeight,
            'air_pressure': e.airPressure,
            'air_temp': e.airTemp,
            'water_temp': e.waterTemp,
            'engine_hours': e.engineHours,
            'fuel_consumed': e.fuelConsumed,
            'skipper_note': e.skipperNote,
            'is_auto_entry': e.isAutoEntry,
            'weather_condition': e.weatherCondition,
          }).toList(),
        };
      }).toList(),
    };
  }
}
