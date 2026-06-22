// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get languageName => 'Español';

  @override
  String get navMap => 'Mapa';

  @override
  String get navTracking => 'Rastreo';

  @override
  String get navLogbook => 'Diario';

  @override
  String get navWeather => 'Tiempo';

  @override
  String get navSafety => 'Seguridad';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'Reintentar';

  @override
  String get share => 'Compartir';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get error => 'Error';

  @override
  String errorMsg(String msg) {
    return 'Error: $msg';
  }

  @override
  String get pressBackToExit => 'Pulsar Atrás de nuevo para salir';

  @override
  String get trackingRunningTitle => 'Rastreo activo';

  @override
  String get trackingRunningContent =>
      'El rastreo está activo. ¿Qué desea hacer?';

  @override
  String get stopAndExit => 'Detener y salir';

  @override
  String get keepRunning => 'Mantener activo';

  @override
  String get marineInstrumentsTitle => 'Instrumentos marinos';

  @override
  String get marineInstrumentsPrompt =>
      '¿Desea conectar la aplicación a instrumentos marinos (p.ej. Raymarine vía gateway WiFi)? La app leerá GPS, viento, profundidad y otros datos directamente del barco.\n\nSin conexión se usará el GPS del teléfono y la previsión meteorológica de internet – puede cambiarlo en cualquier momento en Ajustes.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get setupConnection => 'Configurar conexión';

  @override
  String get trackingActiveTitle => 'Rastreo activo';

  @override
  String get trackingTitle => 'Rastreo';

  @override
  String get waitingForGps => 'Esperando GPS...';

  @override
  String get gpsUnavailable => 'GPS no disponible';

  @override
  String get lastKnownPosition => 'Última posición conocida';

  @override
  String get accuracy => 'Precisión';

  @override
  String get logbookBtn => 'Diario';

  @override
  String get stop => 'Detener';

  @override
  String get startVoyage => 'Iniciar travesía';

  @override
  String get starting => 'Iniciando...';

  @override
  String get newVoyage => 'Nueva travesía';

  @override
  String get multiday => 'Varios días';

  @override
  String get standalone => 'Individual';

  @override
  String get voyageName => 'Nombre de travesía';

  @override
  String get voyageNameOptional => 'Nombre (opcional)';

  @override
  String get voyageNameHint => 'p.ej. Viaje a la bahía';

  @override
  String get existingVoyage => 'Travesía existente';

  @override
  String get newVoyageDropdown => '— Nueva travesía —';

  @override
  String get firstVoyageHint => 'Primera travesía – rellene los datos básicos:';

  @override
  String get estimatedDays => 'Número estimado de días:';

  @override
  String get logFrequency => 'Frecuencia de entradas en el diario';

  @override
  String get startTracking => 'Iniciar rastreo';

  @override
  String dayNofTotal(int n, int total) {
    return 'Día $n de $total';
  }

  @override
  String get newDay => '(nuevo día)';

  @override
  String get endVoyageTitle => '¿Finalizar travesía?';

  @override
  String get endVoyageContent =>
      'Ha alcanzado el último día planificado de la travesía.\n\n¿Continuará la travesía mañana?';

  @override
  String get decideLayer => 'Decidir más tarde';

  @override
  String get continuesTomorrow => 'Continúa mañana';

  @override
  String get endVoyage => 'Finalizar travesía';

  @override
  String get newMultidayVoyage => 'Nueva travesía de varios días';

  @override
  String get deleteCharterTitle => '¿Eliminar charter?';

  @override
  String get deleteCharterContent => 'Se eliminarán todos los días y entradas.';

  @override
  String get noVoyages => 'Sin travesías';

  @override
  String get createFirstCharter => 'Crear su primer charter';

  @override
  String get briefingDone => 'Briefing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Travesía no encontrada';

  @override
  String get unknownVessel => 'Embarcación desconocida';

  @override
  String get captain => 'Capitán';

  @override
  String get crew => 'Tripulación';

  @override
  String get total => 'Total';

  @override
  String voyageDaysCount(int n) {
    return 'Días de travesía ($n)';
  }

  @override
  String get bulkDelete => 'Eliminación masiva';

  @override
  String get noDays =>
      'Sin días.\nInicie el rastreo y el primer día se creará automáticamente.';

  @override
  String get deleteDayTitle => '¿Eliminar día?';

  @override
  String deleteDayContent(String day) {
    return 'Se eliminarán todas las entradas de $day.';
  }

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get selectDaysTitle => 'Seleccionar días a eliminar';

  @override
  String deleteCount(int n) {
    return 'Eliminar ($n)';
  }

  @override
  String get safety => 'Seguridad';

  @override
  String get mobHoldToActivate => 'Mantener para activar';

  @override
  String get mobActive => '⚠️ MOB ACTIVO';

  @override
  String get mobTime => 'Tiempo';

  @override
  String get mobDistance => 'Distancia';

  @override
  String get mobDirection => 'Dirección';

  @override
  String get navigateToMob => 'Navegar al MOB';

  @override
  String get gpsPositionNotAvailable => '¡Posición GPS no disponible!';

  @override
  String get anchorAlarm => 'Alarma de ancla';

  @override
  String get drifting => 'A LA DERIVA';

  @override
  String get anchorRadiusLabel => 'Radio de anclaje';

  @override
  String get activate => 'Activar';

  @override
  String get deactivate => 'Desactivar';

  @override
  String get safetyBriefingCard => 'Briefing de seguridad';

  @override
  String get maydayCard => 'Tarjeta Mayday';

  @override
  String get yachtHandover => 'Entrega del yate';

  @override
  String get gearList => 'Lista de equipos';

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Contactos de emergencia';

  @override
  String get backToToc => 'Volver al índice';

  @override
  String get weatherTitle => 'Tiempo y mar';

  @override
  String get updateForecast => 'Actualizar previsión';

  @override
  String get gpsNotAvailableTracking => 'GPS no disponible – activar rastreo';

  @override
  String get downloadingForecast => 'Descargando previsión...';

  @override
  String get loadingForecast => 'Cargando previsión...';

  @override
  String get noConnection => 'Sin conexión disponible';

  @override
  String get pressRefreshWhenOnline => 'Pulse actualizar cuando esté en línea';

  @override
  String get noWeatherData => 'Sin datos meteorológicos';

  @override
  String get forecastAutoDownload =>
      'La previsión se descargará automáticamente al iniciar el rastreo, o pulse Actualizar.';

  @override
  String get enableGpsFirst => 'Activar GPS / rastreo primero';

  @override
  String get downloadForecast => 'Descargar previsión';

  @override
  String downloadError(String error) {
    return 'Error de descarga: $error';
  }

  @override
  String get liveInstrumentData => 'Datos en vivo de instrumentos marinos';

  @override
  String get windRelative => 'Viento (rel.)';

  @override
  String get windTrue => 'Viento (real)';

  @override
  String get depthLabel => 'Profundidad';

  @override
  String get waterTempLabel => 'Temp. agua';

  @override
  String get courseTrue => 'Rumbo (real)';

  @override
  String get courseMag => 'Rumbo (magn.)';

  @override
  String get engineLabel => 'Motor';

  @override
  String get wavesLabel => 'Olas';

  @override
  String get pressureLabel => 'Presión';

  @override
  String get airTempLabel => 'Aire';

  @override
  String get waterLabel => 'Agua';

  @override
  String get wind24h => 'Viento – 24h';

  @override
  String get waves24h => 'Olas – 24h';

  @override
  String get hourlyForecast => 'Previsión horaria';

  @override
  String get timeCol => 'Hora';

  @override
  String get windCol => 'Viento';

  @override
  String get wavesCol => 'Olas';

  @override
  String get beaufort0 => 'Calma';

  @override
  String get beaufort1 => 'Ventolina';

  @override
  String get beaufort2 => 'Brisa muy débil';

  @override
  String get beaufort3 => 'Flojito';

  @override
  String get beaufort4 => 'Flojo';

  @override
  String get beaufort5 => 'Bonancible';

  @override
  String get beaufort6 => 'Fresco';

  @override
  String get beaufort7 => 'Frescachón';

  @override
  String get beaufort8 => 'Temporal';

  @override
  String get beaufort9 => 'Temporal fuerte';

  @override
  String get beaufort10 => 'Temporal muy fuerte';

  @override
  String get beaufort11 => 'Borrasca';

  @override
  String get beaufort12 => 'Huracán';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get measurementUnits => 'Unidades de medida';

  @override
  String get temperature => 'Temperatura';

  @override
  String get depthWaves => 'Profundidad / olas';

  @override
  String get wind => 'Viento';

  @override
  String get language => 'Idioma';

  @override
  String get appLanguage => 'Idioma de la app';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get aboutApp => 'Acerca de';

  @override
  String get connectionConnected => 'Conectado';

  @override
  String get connectionConnecting => 'Conectando...';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get connectionDisconnected =>
      'Desconectado (usando GPS del teléfono / previsión)';

  @override
  String get ipAddressLabel => 'Dirección IP del gateway';

  @override
  String get portLabel => 'Puerto';

  @override
  String get autoConnectLabel => 'Conectar automáticamente al inicio';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get connect => 'Conectar';

  @override
  String get gatewayHint =>
      'Conecte el teléfono a la red WiFi del gateway del barco (Raymarine WiFi-1, RayNet y similares suelen funcionar en 10.0.0.1, puerto 2000). Sin conexión, la app usa automáticamente el GPS del teléfono y la previsión meteorológica de internet.';

  @override
  String connectedToHost(String host, int port) {
    return 'Conectado a $host:$port';
  }

  @override
  String get enterIpAddress => 'Ingrese la dirección IP del gateway';

  @override
  String connectionFailed(String error) {
    return 'Error al conectar: $error';
  }

  @override
  String get liveWind => 'Viento';

  @override
  String get liveDepth => 'Profundidad';

  @override
  String get liveWaterTemp => 'Temp. agua';

  @override
  String get liveCompass => 'Brújula';

  @override
  String get liveEngine => 'Motor';

  @override
  String get dayNotFound => 'Día no encontrado';

  @override
  String get saved => 'Guardado';

  @override
  String get trackingThisDay => 'Rastreo activo para este día';

  @override
  String get trackingOtherDay => 'Rastreo activo para otro día';

  @override
  String recordCount(int n) {
    return '$n entradas';
  }

  @override
  String get addManual => 'Añadir manual';

  @override
  String get noEntries => 'Sin entradas';

  @override
  String get entriesAutoAdded =>
      'Las entradas se añaden automáticamente durante el rastreo';

  @override
  String get deleteEntryTitle => '¿Eliminar entrada?';

  @override
  String get autoRecord => 'Entrada automática';

  @override
  String get routeSection => 'Ruta';

  @override
  String get fromPort => 'Desde';

  @override
  String get toPort => 'Hasta';

  @override
  String get distance => 'Distancia';

  @override
  String get vessel => 'Embarcación';

  @override
  String get weatherSection => 'Tiempo';

  @override
  String get morning => 'Mañana';

  @override
  String get noon => 'Mediodía';

  @override
  String get evening => 'Tarde';

  @override
  String get windDir => 'Dirección del viento';

  @override
  String get seaState => 'Estado del mar';

  @override
  String get waveHeight => 'Altura de olas';

  @override
  String get dailyNote => 'Diario del día';

  @override
  String get dailyNoteHint =>
      'Descripción de la travesía, momentos destacados, eventos del día...';

  @override
  String get seaCalm => 'Calmado';

  @override
  String get seaLight => 'Leve';

  @override
  String get seaModerate => 'Moderado';

  @override
  String get seaRough => 'Agitado';

  @override
  String get seaStormy => 'Tempestuoso';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get newEntry => 'Nueva entrada';

  @override
  String get sailMode => 'Modo de vela';

  @override
  String get sailMain => 'Principal';

  @override
  String get navigationSection => 'Navegación';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get weatherSeaSection => 'Tiempo y mar';

  @override
  String get windSpeed => 'Viento';

  @override
  String get windDirection => 'Dirección';

  @override
  String get waveHeight2 => 'Altura de olas';

  @override
  String get engineSection => 'Motor';

  @override
  String get engineHours => 'Horas de motor';

  @override
  String get fuel => 'Combustible';

  @override
  String get noteSection => 'Nota';

  @override
  String get noteHint =>
      'Condiciones de navegación, eventos, cambio de tripulación...';

  @override
  String get exportDayTitle => 'Exportar día';

  @override
  String get exportCharterTitle => 'Exportar charter';

  @override
  String get loadingData => 'Cargando datos...';

  @override
  String get mapsReady => 'Mapas listos – puede exportar';

  @override
  String generatingMaps(int current, int total) {
    return 'Generando vistas previas de mapas ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Exportar día';

  @override
  String get exportCharterBtn => 'Exportar charter';

  @override
  String get entriesLabel => 'Entradas';

  @override
  String get routePoints => 'Puntos de ruta';
}
