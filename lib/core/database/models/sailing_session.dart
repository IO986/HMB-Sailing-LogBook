class SailingSession {
  late String sessionId;

  late DateTime startTime;
  DateTime? endTime;

  String? name;
  String? departurePort;
  String? arrivalPort;

  // Aggregated stats (computed at end)
  double totalDistanceNm = 0;
  double maxSpeedKnots = 0;
  double avgSpeedKnots = 0;
  double fuelConsumedTotal = 0;
  double engineHoursTotal = 0;

  bool isActive = true;
  String? gpxFilePath;

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
}
