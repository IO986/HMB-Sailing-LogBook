/// Stav pripojenia k lodným inštrumentom.
enum RaymarineConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Agregované real-time dáta z lodných inštrumentov (Raymarine NMEA stream).
/// Polia sú null, ak daná veličina ešte nebola prijatá.
class MarineInstrumentData {
  final double? latitude;
  final double? longitude;
  final double? sogKnots; // speed over ground
  final double? cogDegrees; // course over ground
  final double? headingDegrees; // kompas (magnetic alebo true)
  final bool headingIsTrue;
  final double? windSpeedKnots;
  final double? windAngleDegrees;
  final bool windIsApparent;
  final double? depthMeters;
  final double? waterTempCelsius;
  final double? engineRpm;
  final DateTime? lastUpdate;
  final DateTime? gpsTimestampUtc;

  const MarineInstrumentData({
    this.latitude,
    this.longitude,
    this.sogKnots,
    this.cogDegrees,
    this.headingDegrees,
    this.headingIsTrue = false,
    this.windSpeedKnots,
    this.windAngleDegrees,
    this.windIsApparent = true,
    this.depthMeters,
    this.waterTempCelsius,
    this.engineRpm,
    this.lastUpdate,
    this.gpsTimestampUtc,
  });

  bool get hasGpsFix => latitude != null && longitude != null;
  bool get hasWind => windSpeedKnots != null && windAngleDegrees != null;
  bool get hasDepth => depthMeters != null;

  MarineInstrumentData copyWith({
    double? latitude,
    double? longitude,
    double? sogKnots,
    double? cogDegrees,
    double? headingDegrees,
    bool? headingIsTrue,
    double? windSpeedKnots,
    double? windAngleDegrees,
    bool? windIsApparent,
    double? depthMeters,
    double? waterTempCelsius,
    double? engineRpm,
    DateTime? lastUpdate,
    DateTime? gpsTimestampUtc,
  }) {
    return MarineInstrumentData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sogKnots: sogKnots ?? this.sogKnots,
      cogDegrees: cogDegrees ?? this.cogDegrees,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      headingIsTrue: headingIsTrue ?? this.headingIsTrue,
      windSpeedKnots: windSpeedKnots ?? this.windSpeedKnots,
      windAngleDegrees: windAngleDegrees ?? this.windAngleDegrees,
      windIsApparent: windIsApparent ?? this.windIsApparent,
      depthMeters: depthMeters ?? this.depthMeters,
      waterTempCelsius: waterTempCelsius ?? this.waterTempCelsius,
      engineRpm: engineRpm ?? this.engineRpm,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      gpsTimestampUtc: gpsTimestampUtc ?? this.gpsTimestampUtc,
    );
  }
}
