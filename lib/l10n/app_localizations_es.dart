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
  String get trackingInProgress => 'Rastrear travesía';

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
  String get briefingComplete => 'Briefing completado';

  @override
  String get updateByPosition => 'Actualizar por posición';

  @override
  String get detectedByGps => 'detectado por GPS';

  @override
  String get locationUnavailable =>
      '📍 Posición no disponible – contactos globales';

  @override
  String get detectingLocation => 'Detectando posición...';

  @override
  String get tapToCall => 'Toca para llamar';

  @override
  String cannotCall(String name) {
    return 'No se puede llamar: $name';
  }

  @override
  String get vhfChannel16 => 'Canal VHF 16 – usa la radio del barco';

  @override
  String get hmbHandbook => 'Manual HMB';

  @override
  String get checkInLabel => 'Check-in (recepción del barco)';

  @override
  String get checkOutLabel => 'Check-out (entrega del barco)';

  @override
  String get charterCheckCard => 'Chárter';

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
  String get wind24h => 'Viento – 3 días';

  @override
  String get waves24h => 'Olas – 3 días';

  @override
  String get hourlyForecast => 'Pronóstico 3 días';

  @override
  String get dailyForecast => 'Temperatura diaria';

  @override
  String get timeCol => 'Hora';

  @override
  String get windCol => 'Viento';

  @override
  String get wavesCol => 'Olas';

  @override
  String get rainCol => 'Lluvia';

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

  @override
  String get anchorDriftTitle => '⚓ ¡ANCLA A LA DERIVA!';

  @override
  String get anchorDriftContent =>
      'El barco ha superado el perímetro del ancla.\n¡Compruebe la posición inmediatamente!';

  @override
  String get cancelAnchor => 'Cancelar ancla';

  @override
  String get stopAlarm => 'Detener alarma';

  @override
  String get briefingItem1 => 'Chalecos salvavidas – ubicación y uso';

  @override
  String get briefingItem2 => 'Aro salvavidas y procedimiento MOB';

  @override
  String get briefingItem3 => 'Bengalas – tipos y uso';

  @override
  String get briefingItem4 => 'EPIRB / PLB – activación';

  @override
  String get briefingItem5 => 'Radio VHF – canal 16, procedimiento Mayday';

  @override
  String get briefingItem6 => 'Extintor – ubicación y uso';

  @override
  String get briefingItem7 => 'Botiquín de primeros auxilios – ubicación';

  @override
  String get briefingItem8 => 'Parada de emergencia del motor';

  @override
  String get briefingItem9 => 'Fugas – agua, gas';

  @override
  String get briefingItem10 => 'Ancla y cadena – procedimiento de fondeo';

  @override
  String get briefingItem11 => 'Reglas a bordo';

  @override
  String get briefingItem12 => 'Contactos de emergencia y VHF 16';

  @override
  String get checkInItem1 => 'Documentos del barco (registro, seguro)';

  @override
  String get checkInItem2 => 'Equipo de seguridad – completo';

  @override
  String get checkInItem3 => 'Suministros de combustible';

  @override
  String get checkInItem4 => 'Suministros de agua';

  @override
  String get checkInItem5 => 'Ancla y cadena – revisión';

  @override
  String get checkInItem6 => 'Motor – prueba de marcha';

  @override
  String get checkInItem7 => 'Instrumentos de navegación';

  @override
  String get checkInItem8 => 'Aparejo – cabos y velas';

  @override
  String get checkInItem9 => 'Cocina – gas, fogón';

  @override
  String get checkInItem10 => 'WC – funcionamiento';

  @override
  String get checkInItem11 => 'Daños existentes – documentación fotográfica';

  @override
  String get checkOutItem1 => 'Barco limpio – exterior';

  @override
  String get checkOutItem2 => 'Barco limpio – interior';

  @override
  String get checkOutItem3 => 'Combustible rellenado';

  @override
  String get checkOutItem4 => 'Agua rellenada';

  @override
  String get checkOutItem5 => 'Basura eliminada';

  @override
  String get checkOutItem6 => 'Daños reportados';

  @override
  String get checkOutItem7 => 'Llaves entregadas';

  @override
  String get gearListShort => 'Equipo\nPersonal';

  @override
  String get colregRules => 'COLREG\nReglas';

  @override
  String get checkInShort => 'Check-in\nRecepción';

  @override
  String get checkOutShort => 'Check-out\nEntrega';

  @override
  String get appTagline => 'Tu diario de a bordo de confianza';

  @override
  String exportSavedMsg(String path) {
    return 'Guardado: $path';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Error de exportación: $error';
  }

  @override
  String get generatingPdf => 'Generando PDF...';

  @override
  String get colregTitle => 'COLREG – Reglas de la vía';

  @override
  String get tableOfContents => 'ÍNDICE';

  @override
  String get inThisChapter => 'En este capítulo:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Regla $n';
  }

  @override
  String get resetChecklistTitle => '¿Reiniciar lista?';

  @override
  String get resetChecklistContent => 'Se borrarán todas las marcas.';

  @override
  String get reset => 'Reiniciar';

  @override
  String get checkInReceivingTitle => 'Check-in – Recibir el barco';

  @override
  String get checkOutHandoverTitle => 'Check-out – Entregar el barco';

  @override
  String get checkInCompletedMsg => 'Barco recibido – todo verificado ✓';

  @override
  String get checkOutCompletedMsg => 'Barco entregado – todo en orden ✓';

  @override
  String get briefingDoneMsg => 'Sesión completada – tripulación informada';

  @override
  String get sectionBriefed => 'Sección explicada ✓';

  @override
  String get confirmSection => 'Confirmar sección';

  @override
  String get gearListTitle => 'Equipo personal';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get add => 'Añadir';

  @override
  String get deleteItemTitle => '¿Eliminar elemento?';

  @override
  String get allPackedMsg => '¡Todo listo para navegar! 🎉';

  @override
  String get addItemLabel => 'Añadir elemento';

  @override
  String addToCategoryTitle(String category) {
    return 'Añadir a: $category';
  }

  @override
  String get newItemHint => 'Nuevo elemento...';

  @override
  String get addWaypoint => 'Añadir waypoint';

  @override
  String get waypointNameLabel => 'Nombre';

  @override
  String get skipperSignature => 'Firma del patrón';

  @override
  String get signWithFinger => 'Firme con el dedo';

  @override
  String get clear => 'Borrar';

  @override
  String get signAndExport => 'Firmar y exportar';

  @override
  String get pleaseSign => 'Por favor firme antes de exportar';

  @override
  String get generatingPdfPreview => 'Generando vista previa PDF...';

  @override
  String generationError(String error) {
    return 'Error de generación: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Guardando y generando GPX...';

  @override
  String get editCharter => 'Editar charter';

  @override
  String get basicInfo => 'Información básica';

  @override
  String get voyageNameRequired => 'Nombre del viaje *';

  @override
  String get dateFrom => 'Fecha desde';

  @override
  String get dateTo => 'Fecha hasta';

  @override
  String get vesselName => 'Nombre del barco';

  @override
  String get vesselType => 'Tipo de barco';

  @override
  String get homePort => 'Puerto base';

  @override
  String get notesLabel => 'Notas';

  @override
  String get statusLabel => 'Estado';

  @override
  String get safetyBriefingDoneLabel => 'Briefing de seguridad completado';

  @override
  String get checkInDoneLabel => 'Check-in completado';

  @override
  String get checkOutDoneLabel => 'Check-out completado';

  @override
  String get enterVoyageName => 'Introduce el nombre del viaje';

  @override
  String daysCount(int n) {
    return '$n días';
  }

  @override
  String get selectTargetWaypoint => 'Seleccionar waypoint destino';

  @override
  String get noWaypoints => 'Sin waypoints.';

  @override
  String get goToMap => 'Ir al mapa';

  @override
  String get noTarget => 'Sin destino';

  @override
  String get selectWaypointHint => 'Seleccionar waypoint...';

  @override
  String get sessionStats => 'Estadísticas de la travesía';

  @override
  String get maxSpeed => 'Velocidad máx.';

  @override
  String get avgSpeed => 'Velocidad prom.';

  @override
  String get sailingTime => 'Tiempo de navegación';

  @override
  String get gpsData => 'Datos GPS';

  @override
  String get gpsPosition => 'Posición';

  @override
  String get courseCog => 'Rumbo (COG)';

  @override
  String get altitudeLabel => 'Altitud';

  @override
  String get dscProcedure => 'PROCEDIMIENTO DSC';

  @override
  String get voiceScript => 'GUIÓN DE VOZ';

  @override
  String get dscWarningUseOnly => '⚠️ USAR SOLO EN CASO DE';

  @override
  String get dscWarningDanger => 'PELIGRO GRAVE E INMINENTE';

  @override
  String get dscWarningTypes => 'Incendio · Hundimiento · Hombre al agua';

  @override
  String get dscProcedureSubtitle =>
      'Conserve este procedimiento junto al radio VHF DSC';

  @override
  String get fillBeforeSailing => 'Completar antes de navegar:';

  @override
  String get copyTooltip => 'Copiar';

  @override
  String get scriptCopied => 'Guión copiado';

  @override
  String get sendOnCh16 =>
      '📻 Enviar en Canal 16 · Alta potencia · Repetir cada 2 minutos si no hay respuesta';

  @override
  String get enterAbove => '[introducir en campo superior]';

  @override
  String get distressNature => 'Naturaleza del peligro';

  @override
  String get vesselNameLabel => 'Nombre del barco';

  @override
  String get numberOfPersons => 'Número de personas';

  @override
  String get additionalInfo => 'Información adicional';

  @override
  String get voiceScriptTitle => 'GUIÓN MAYDAY DE VOZ';

  @override
  String get dscStep1 => 'Asegúrese de que la radio esté encendida.';

  @override
  String get dscStep2 => 'Abra la cubierta sobre el botón ROJO de socorro.';

  @override
  String get dscStep3 => 'Pulse el botón ROJO UNA VEZ y suéltelo.';

  @override
  String get dscStep4 =>
      'Seleccione la naturaleza del peligro.\n(Incendio, Hundimiento, MOB, etc.)\nSi omite, se enviará Peligro sin especificar.';

  @override
  String get dscStep5 =>
      'Pulse y MANTENGA el botón ROJO durante 5 segundos para enviar la llamada.';

  @override
  String get dscStep6 =>
      'Espere hasta 15 segundos para la confirmación (en pantalla), luego envíe mensaje de voz en Canal 16 a ALTA POTENCIA.';

  @override
  String get appDescription =>
      'Diario de navegación profesional para navegantes.';

  @override
  String get vesselIdTitle => 'Identificación del buque';

  @override
  String get vesselIdHint =>
      'La indicación de llamada y el MMSI se rellenan automáticamente en la Tarjeta Mayday.';

  @override
  String get maritimeReference => 'Referencia marítima';

  @override
  String get phonetic => 'Fonético';

  @override
  String get flagAlphabet => 'Banderas de señales';

  @override
  String get dayShapes => 'Marcas de día';

  @override
  String get marineReferenceTile => 'Señales & alfabeto';

  @override
  String get navInstruments => 'Instrumentos';

  @override
  String get enterPort => 'Ingrese puerto...';

  @override
  String get closeWithoutSaving => 'Cerrar sin guardar';

  @override
  String get saveToDevice => 'Guardar en dispositivo';

  @override
  String get saveAndShare => 'Guardar y compartir';

  @override
  String get timestampCannotBeChanged =>
      'La hora del registro no se puede cambiar';

  @override
  String entriesShort(int n) {
    return '$n entr.';
  }

  @override
  String get mainsail => 'Vela mayor';

  @override
  String get weatherConditionTitle => 'Condición meteorológica';

  @override
  String get weatherConditionLabel => 'Condición';

  @override
  String get wcSunny => 'Soleado';

  @override
  String get wcPartlyCloudy => 'Parcialmente nublado';

  @override
  String get wcOvercast => 'Nublado';

  @override
  String get wcLightRain => 'Lluvia ligera';

  @override
  String get wcRain => 'Lluvia';

  @override
  String get wcHeavyRain => 'Lluvia intensa';

  @override
  String get wcDrizzle => 'Llovizna';

  @override
  String get wcThunderstorm => 'Tormenta';

  @override
  String get wcIsoThunderstorm => 'Tormentas aisladas';

  @override
  String get wcHail => 'Granizo';

  @override
  String get wcDust => 'Polvo';

  @override
  String get wcFoggy => 'Niebla';

  @override
  String get wcWindy => 'Ventoso';

  @override
  String get wcCold => 'Frío';

  @override
  String get photoSection => 'Foto';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get photoAddedToEntry => 'Foto adjuntada';

  @override
  String get voyageStart => 'Inicio del viaje';

  @override
  String get voyageEnd => 'Fin del viaje';

  @override
  String get onlineAccount => 'Cuenta en línea';

  @override
  String get onlineAccountDesc => 'Sincroniza el diario con logbook.hmba.boats';

  @override
  String get register => 'Registrarse';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm =>
      'Cerrará sesión. Los datos del dispositivo permanecerán.';

  @override
  String get notLoggedIn => 'No conectado';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get password => 'Contraseña';

  @override
  String get userGuide => 'Guía del usuario';

  @override
  String get guideQuickStart => 'Inicio rápido – 5 pasos';

  @override
  String get guideQuickStartBody =>
      '1. Abrir Diario → pulsar + → seleccionar \"Nueva travesía\"\n2. Introducir nombre del barco y días estimados\n3. El rastreo se inicia automáticamente – guarda el teléfono en el bolsillo\n4. Añadir entradas durante el día: hora, posición, nota\n5. Al final de la travesía: Ajustes → Exportar PDF';

  @override
  String get guideMapTitle => 'Mapa';

  @override
  String get guideMapBody =>
      'La pestaña Mapa muestra tu posición actual y la ruta de la travesía.\n\n• Punto azul = posición actual\n• Línea roja = ruta recorrida\n• Cambiar entre vista satélite y mapa\n• Icono de ancla = posición de fondeo (solo con alarma de ancla activa)';

  @override
  String get guideInstrTitle => 'Instrumentos marinos';

  @override
  String get guideInstrBody =>
      'La pestaña Instrumentos muestra datos de navegación en tiempo real.\n\n• SOG – velocidad sobre el fondo (nudos)\n• TWS – velocidad del viento verdadero\n• TWA – ángulo del viento verdadero (verde = estribor, rojo = babor)\n• DEPTH – profundidad del agua (rojo = menos de 5 m)\n• VMG WP – velocidad hacia el waypoint\n\nFuente de datos: GPS del teléfono o Raymarine (pasarela WiFi).\nConfiguración de conexión en Ajustes → Instrumentos.';

  @override
  String get guideLogbookTitle => 'Diario de navegación';

  @override
  String get guideLogbookBody =>
      'El Diario es la pestaña principal para gestionar travesías.\n\n• Pulsar + (FAB) → \"Nueva travesía\" para crear un charter\n• El rastreo se inicia desde este diálogo – la posición se registra automáticamente\n• Cada día de travesía se muestra por separado\n• Se pueden añadir entradas manualmente durante el día\n• Exportar a PDF desde el menú del día';

  @override
  String get guideWeatherTitle => 'Tiempo';

  @override
  String get guideWeatherBody =>
      'La pestaña Tiempo muestra el pronóstico según tu posición actual.\n\n• Se actualiza automáticamente al cambiar de posición\n• Muestra viento, oleaje, temperatura y condiciones para las próximas horas\n• Sin conexión: se muestra el último pronóstico guardado';

  @override
  String get guideSafetyMobTitle => 'MOB y ancla';

  @override
  String get guideSafetyMobBody =>
      'La pestaña Seguridad contiene funciones de emergencia.\n\nMOB (Hombre al agua):\n• Mantener pulsado el botón rojo MOB para activar\n• La app guarda la posición GPS y mide tiempo y distancia\n• Navegar de vuelta al punto de caída\n\nAlarma de ancla:\n• Establecer el radio de fondeo (recomendado: 2× longitud de cadena)\n• La alarma vibra si el barco sale del radio permitido';

  @override
  String get guideSafetyBriefingTitle => 'Briefing de seguridad y MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'La pestaña Seguridad también contiene tarjetas de referencia.\n\n• Briefing de seguridad – checklist para la tripulación antes de zarpar\n• Tarjeta MAYDAY – procedimiento para llamada de socorro en canal 16 VHF\n• COLREG – reglamento de abordajes en la mar\n• Contactos de emergencia – números y contactos de emergencia';

  @override
  String get guideSettingsTitle => 'Ajustes';

  @override
  String get guideSettingsBody =>
      '• Idioma – cambiar el idioma de la app\n• Instrumentos – configurar la dirección IP de la pasarela WiFi Raymarine\n• Fuente GPS – teléfono o Raymarine\n• Unidades – nudos/km/h, metros/pies\n• Frecuencia de entradas en el diario\n• Exportar – PDF o CSV\n• Acerca de – versión y contacto';

  @override
  String get guideExportTitle => 'Exportar diario';

  @override
  String get guideExportBody =>
      'El diario se puede exportar como documento PDF profesional.\n\n1. Abrir Diario → seleccionar charter\n2. Pulsar icono de exportar o tres puntos → Exportar PDF\n3. Elegir los días a incluir\n4. El PDF incluye: ruta, entradas, fotos y firmas\n5. Compartir por email, imprimir o guardar en el teléfono';
}
