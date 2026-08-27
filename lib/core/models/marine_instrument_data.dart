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

  /// Kedy naposledy prišli otáčky motora. Bez toho sa nedá odlíšiť „motor
  /// stojí" od „prístroje o motore prestali hovoriť".
  final DateTime? engineLastUpdate;

  /// True, keď autopilot kormidluje. `null` znamená „loď o autopilotovi
  /// nehlási nič" — to nie je to isté ako vypnutý pilot a v denníku sa
  /// z toho nesmie stať záznam.
  final bool? autopilotEngaged;

  /// Režim autopilota: `standby`, `auto`, `wind`, `track`, `heading`,
  /// `rudder`. Kód, nie preklad.
  final String? autopilotMode;
  final DateTime? autopilotLastUpdate;
  final DateTime? lastUpdate;
  final DateTime? gpsTimestampUtc;

  /// Kedy naposledy prišla veta s platnou polohou (RMC/GGA/GLL).
  ///
  /// Oddelené od [lastUpdate], ktoré sa hýbe pri KAŽDEJ vete: keď prestane
  /// chodiť GPS, ale vietor a hĺbka tečú ďalej, stará poloha by inak ostala
  /// „čerstvá" a appka by ju ďalej vydávala za aktuálnu.
  final DateTime? gpsLastUpdate;
  final DateTime? windLastUpdate;
  final DateTime? depthLastUpdate;

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
    this.engineLastUpdate,
    this.autopilotEngaged,
    this.autopilotMode,
    this.autopilotLastUpdate,
    this.lastUpdate,
    this.gpsTimestampUtc,
    this.gpsLastUpdate,
    this.windLastUpdate,
    this.depthLastUpdate,
  });

  bool get hasGpsFix => latitude != null && longitude != null;
  bool get hasWind => windSpeedKnots != null && windAngleDegrees != null;
  bool get hasDepth => depthMeters != null;

  /// True, keď prístroje o autopilotovi vôbec niečo hlásia.
  bool get hasAutopilot => autopilotEngaged != null;

  /// Otáčky, pod ktorými sa motor považuje za stojaci. Voľnobeh lodného
  /// dieselu je 600–900 ot./min, takže 50 spoľahlivo oddelí beh od nuly aj
  /// pri nepresnom snímači.
  static const double runningRpmThreshold = 50;

  /// True, keď prístroje hlásia bežiaci motor.
  bool get isEngineRunning =>
      engineRpm != null && engineRpm! >= runningRpmThreshold;

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
    DateTime? engineLastUpdate,
    bool? autopilotEngaged,
    String? autopilotMode,
    DateTime? autopilotLastUpdate,
    DateTime? lastUpdate,
    DateTime? gpsTimestampUtc,
    DateTime? gpsLastUpdate,
    DateTime? windLastUpdate,
    DateTime? depthLastUpdate,
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
      engineLastUpdate: engineLastUpdate ?? this.engineLastUpdate,
      autopilotEngaged: autopilotEngaged ?? this.autopilotEngaged,
      autopilotMode: autopilotMode ?? this.autopilotMode,
      autopilotLastUpdate: autopilotLastUpdate ?? this.autopilotLastUpdate,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      gpsTimestampUtc: gpsTimestampUtc ?? this.gpsTimestampUtc,
      gpsLastUpdate: gpsLastUpdate ?? this.gpsLastUpdate,
      windLastUpdate: windLastUpdate ?? this.windLastUpdate,
      depthLastUpdate: depthLastUpdate ?? this.depthLastUpdate,
    );
  }
}
