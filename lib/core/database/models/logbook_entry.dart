class LogbookEntry {
  late DateTime timestamp;

  // Navigation data
  double? latitude;
  double? longitude;
  double? sog; // Speed Over Ground (knots)
  double? cog; // Course Over Ground (degrees)
  double? heading;
  double? depth;

  // Engine
  double? engineHours;
  double? fuelConsumed; // litres

  // Weather at time of entry
  double? windSpeed;
  double? windDirection;
  double? waveHeight;
  double? airPressure;
  double? airTemp;
  double? waterTemp;
  String? weatherNote;

  // Crew
  String? skipperNote;
  List<String> photos = [];

  // Meta
  String? sessionId;
  bool isAutoEntry = false;
  String deviceId = '';

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
