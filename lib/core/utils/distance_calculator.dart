import 'dart:math';

class DistanceCalculator {
  static const double _earthRadiusNm = 3440.065;
  static const double _earthRadiusM = 6371000;

  static double distanceNm(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return _earthRadiusNm * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double distanceM(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return _earthRadiusM * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double bearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _rad(lon2 - lon1);
    final y = sin(dLon) * cos(_rad(lat2));
    final x = cos(_rad(lat1)) * sin(_rad(lat2)) -
        sin(_rad(lat1)) * cos(_rad(lat2)) * cos(dLon);
    return (_deg(atan2(y, x)) + 360) % 360;
  }

  static double _rad(double deg) => deg * pi / 180;
  static double _deg(double rad) => rad * 180 / pi;
}
