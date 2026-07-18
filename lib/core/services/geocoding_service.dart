import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A place the user can pick to fetch a forecast for.
class GeocodedPlace {
  final String name;
  final double latitude;
  final double longitude;

  const GeocodedPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class GeocodingService {
  static final GeocodingService _i = GeocodingService._();
  factory GeocodingService() => _i;
  GeocodingService._();

  final _dio = Dio(BaseOptions(
    baseUrl: 'https://nominatim.openstreetmap.org',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'User-Agent': 'HMBSailingLogbook/1.0 (https://logbook.hmba.boats)'},
  ));

  /// Forward search: place name → candidate positions.
  ///
  /// Used to fetch a forecast for somewhere other than where you are —
  /// planning a Croatian trip from a landlocked home has to work.
  /// Returns an empty list on any failure.
  Future<List<GeocodedPlace>> searchPlaces(String query) async {
    if (query.trim().length < 2) return const [];
    try {
      final resp = await _dio.get('/search', queryParameters: {
        'format': 'json',
        'q': query.trim(),
        'limit': '8',
        'addressdetails': '1',
      });

      final data = resp.data as List?;
      if (data == null) return const [];

      return [
        for (final raw in data)
          if (raw is Map<String, dynamic>)
            GeocodedPlace(
              name: _shortName(raw),
              latitude: double.parse(raw['lat'] as String),
              longitude: double.parse(raw['lon'] as String),
            ),
      ];
    } catch (e) {
      debugPrint('[GEO] Place search failed: $e');
      return const [];
    }
  }

  /// "Split, Split-Dalmatia County, Croatia" → "Split, Croatia" — enough to
  /// tell two same-named places apart without filling the row.
  static String _shortName(Map<String, dynamic> raw) {
    final display = (raw['display_name'] as String?) ?? '';
    final parts = display.split(',').map((p) => p.trim()).toList();
    if (parts.isEmpty) return display;
    if (parts.length == 1) return parts.first;
    return '${parts.first}, ${parts.last}';
  }

  /// Reverse geocode GPS → human-readable port/marina/bay name.
  /// Returns null on any failure.
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final resp = await _dio.get('/reverse', queryParameters: {
        'format': 'json',
        'lat': lat.toStringAsFixed(6),
        'lon': lon.toStringAsFixed(6),
        'namedetails': '1',
        'addressdetails': '1',
        'zoom': '16',
      });

      final data = resp.data as Map<String, dynamic>?;
      if (data == null) return null;

      final name        = data['name'] as String?;
      final type        = data['type'] as String?;
      final address     = (data['address'] as Map<String, dynamic>?) ?? {};

      // 1. Named marine feature (marina, harbour, dock, port…)
      const marineTypes = {'marina', 'harbour', 'dock', 'port', 'ferry_terminal', 'anchorage'};
      if (type != null && marineTypes.contains(type) && name != null && name.isNotEmpty) {
        return name;
      }

      // 2. Address fields in priority order
      for (final key in ['marina', 'harbour', 'bay', 'beach', 'suburb', 'village', 'town', 'city']) {
        final v = address[key] as String?;
        if (v != null && v.isNotEmpty) {
          if (key == 'bay' || key == 'beach') {
            final town = address['village'] as String? ??
                         address['town']    as String? ??
                         address['city']    as String?;
            if (town != null && town.isNotEmpty && town != v) return '$v, $town';
          }
          return v;
        }
      }

      // 3. Fallback: first part of display_name
      final display = data['display_name'] as String?;
      if (display != null && display.isNotEmpty) {
        return display.split(',').first.trim();
      }

      return null;
    } catch (e) {
      debugPrint('[GEO] Reverse geocode failed: $e');
      return null;
    }
  }
}
