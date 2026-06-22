class TrackPoint {
  late DateTime timestamp;

  late double latitude;
  late double longitude;
  double? altitude;
  double? speed; // knots
  double? course; // degrees
  double? accuracy;
  String? sessionId;

  bool get isValid => accuracy != null && accuracy! < 50;
}
