import 'package:dio/dio.dart';

class GeocodingService {
  static final GeocodingService _i = GeocodingService._();
  factory GeocodingService() => _i;
  GeocodingService._();

  final _dio = Dio(BaseOptions(
    baseUrl: 'https://nominatim.openstreetmap.org',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'User-Agent': 'HMBSailingLog/1.0 (steclaco@gmail.com)'},
  ));

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
          // For bays/anchorages, append the nearest town for context
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
      print('[GEO] Reverse geocode failed: $e');
      return null;
    }
  }
}
