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
  String get poiTypeAnchorage => 'Fondeadero';

  @override
  String get poiTypeMarina => 'Puerto deportivo';

  @override
  String get poiTypeFuel => 'Estación de combustible';

  @override
  String get poiTypeHarbour => 'Puerto';

  @override
  String get poiVhfChannel => 'Canal VHF';

  @override
  String get poiPhone => 'Teléfono';

  @override
  String get poiWebsite => 'Web';

  @override
  String get poiEmail => 'Correo electrónico';

  @override
  String get poiCapacity => 'Capacidad';

  @override
  String get poiServices => 'Servicios';

  @override
  String get poiSaveAsWaypoint => 'Guardar como waypoint';

  @override
  String poiWaypointSaved(String name) {
    return 'Waypoint \"$name\" guardado';
  }

  @override
  String get poiSource => 'Fuente: OpenStreetMap';

  @override
  String get mapLayerSatellite => 'Satélite';

  @override
  String get mapLayerMap => 'Mapa';

  @override
  String get mapLayers => 'Capas';

  @override
  String get mapSeamarks => 'Marcas náuticas';

  @override
  String get mapHarbours => 'Puertos y fondeaderos';

  @override
  String get mapZoomInForPois =>
      'Acerca el mapa para cargar puertos y fondeaderos';

  @override
  String get mapRainRadar => 'Radar de lluvia';

  @override
  String get mapOceanCurrentsTooltip =>
      'Corrientes oceánicas (mantén pulsado para la lista)';

  @override
  String get mapCurrentForecast => 'Corriente marina — pronóstico (kt)';

  @override
  String get mapTools => 'Herramientas';

  @override
  String get mapVoyageOverview => 'Resumen de la travesía';

  @override
  String get mapRuler => 'Regla / ruta';

  @override
  String get mapDownloadOffline => 'Descargar zona sin conexión';

  @override
  String get mapGpsDisabled => 'El GPS está apagado';

  @override
  String get mapLocationDenied => 'Ubicación no permitida';

  @override
  String get mapFollowGps => 'Seguir GPS';

  @override
  String mapAreaTooLarge(int count) {
    return 'La zona es demasiado grande ($count teselas). Acerca el mapa e inténtalo de nuevo.';
  }

  @override
  String get mapLivePreview => 'En vivo (seguimiento actual)';

  @override
  String get mapWholeVoyage => 'Travesía completa';

  @override
  String get offlineSheetTitle => 'Mapa sin conexión de la zona visible';

  @override
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb) {
    return 'Mapa + marcas náuticas, zoom $minZ–$maxZ, $tiles teselas (~$mb MB). Las zonas descargadas funcionan en el mar sin cobertura.';
  }

  @override
  String offlineDone(int n) {
    return 'Listo — $n teselas guardadas';
  }

  @override
  String offlineDoneErrors(int n) {
    return 'Listo con errores: no se pudieron descargar $n teselas';
  }

  @override
  String get downloadAction => 'Descargar';

  @override
  String get rulerTapHint => 'Toca puntos en el mapa';

  @override
  String get mapEntryPhoto => 'Registro de foto';

  @override
  String get mapEntryNote => 'Registro del diario';

  @override
  String get openSettingsAction => 'Abrir ajustes';

  @override
  String get morseConverter => 'Conversor texto → Morse';

  @override
  String saveError(String error) {
    return 'Error al guardar: $error';
  }

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
  String get navCompass => 'Brújula';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navCustomizeTitle => 'Menú inferior';

  @override
  String get navCustomizeHint =>
      'Mantén y arrastra para reordenar los iconos. Usa el interruptor para ocultar una pestaña del menú inferior — Ajustes siempre se muestra.';

  @override
  String get navAlwaysShown => 'Siempre visible';

  @override
  String get navIconSizeLabel => 'Tamaño de iconos';

  @override
  String get navOpenHiddenTitle => 'Abrir pestañas ocultas';

  @override
  String get cameraPermissionDenied =>
      'Acceso a la cámara denegado. Actívalo en los ajustes del dispositivo.';

  @override
  String get cameraUnavailable => 'Cámara no disponible';

  @override
  String get compassCalibrationNote =>
      'Brújula magnética. La precisión puede verse afectada por metales o electrónica cercana. Si no está calibrada, mueve el dispositivo en forma de ocho.';

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
  String get autoDetectAction => 'Detección automática';

  @override
  String get autoDetectWifiHintTitle => 'Primero conéctate al WiFi del barco';

  @override
  String get autoDetectWifiHintBody =>
      'Comprueba en Ajustes del teléfono → WiFi que estás conectado a la red de los instrumentos marinos (p.ej. RayNet, WiFi-1). Luego la app intentará encontrar el gateway en esa red automáticamente.';

  @override
  String get openWifiSettings => 'Ajustes de WiFi';

  @override
  String get continueAction => 'Continuar';

  @override
  String get autoDetecting => 'Buscando instrumentos en la red WiFi…';

  @override
  String get autoDetectFailed =>
      'No se encontró ningún gateway. Comprueba que estás en la red WiFi del barco, o introduce la IP manualmente en Ajustes.';

  @override
  String autoDetectSuccess(String host) {
    return 'Conectado a $host';
  }

  @override
  String get guidePromptTitle => '¿Primera vez? Guía rápida';

  @override
  String get guidePromptBody =>
      'La app incluye una breve guía de usuario – mapa, cuaderno de bitácora, tiempo, lista de seguridad y más. ¿Quiere echarle un vistazo rápido ahora? Siempre la encontrará más tarde en Ajustes → Guía del usuario.';

  @override
  String get guidePromptAction => 'Mostrar guía';

  @override
  String get notifPromptTitle => '¿Permitir notificaciones?';

  @override
  String get notifPromptBody =>
      'Mientras se registra una travesía, una notificación permanece en la barra de estado y en la pantalla de bloqueo, para que veas que el seguimiento está activo y accedas rápido. Sin permiso, el sistema puede limitar el seguimiento en segundo plano.';

  @override
  String get notifPromptAllow => 'Permitir';

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
  String get stopTrackingDay => '¿Detener el seguimiento?';

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
  String get existingVoyage => 'Continuar travesía existente';

  @override
  String get newVoyageDropdown => '— Nueva travesía —';

  @override
  String get firstVoyageHint => 'Primera travesía – rellene los datos básicos:';

  @override
  String get briefingRequiredHint =>
      'El tracking solo se puede iniciar una vez completado el Safety Briefing de esta travesía.';

  @override
  String get briefingPending => 'SB requerido';

  @override
  String get briefingPendingListWarning =>
      'Safety Briefing sin completar – el tracking aún no se puede iniciar';

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
  String get deleteCharterTitle => '¿Eliminar travesía?';

  @override
  String get deleteCharterContent => 'Se eliminarán todos los días y entradas.';

  @override
  String get cannotDeleteWhileTracking =>
      'No se puede eliminar una travesía mientras el seguimiento está activo.';

  @override
  String get noVoyages => 'Sin travesías';

  @override
  String get createFirstCharter => 'Crea tu primera travesía';

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
  String get captain => 'Patrón';

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
  String get pdfEntriesSection => 'Registros del diario';

  @override
  String get pdfSkipperMessage => 'Informe del patrón';

  @override
  String get pdfWeatherSection => 'Meteorología';

  @override
  String get pdfDaySummary => 'Resumen diario';

  @override
  String get pdfDaysOverview => 'Resumen de días';

  @override
  String get pdfVoyageSummary => 'Resumen de la travesía';

  @override
  String get pdfCrewSection => 'Tripulación';

  @override
  String get pdfSignatures => 'Firmas';

  @override
  String get pdfCrewSignatures => 'Firmas de la tripulación';

  @override
  String get pdfSkipperSignature => 'Firma del patrón';

  @override
  String get pdfSkipperLicences => 'Patrón – titulaciones';

  @override
  String get pdfSafetyBriefing => 'Briefing de seguridad';

  @override
  String get pdfChecklistSection => 'Lista de control';

  @override
  String get pdfMoreNotes => 'Notas adicionales';

  @override
  String get pdfIntegrityCheck => 'Verificación de integridad del documento';

  @override
  String get pdfHandoverTitle => 'Acta de entrega';

  @override
  String get pdfMilesTitle => 'Certificado de millas navegadas';

  @override
  String get pdfDeparture => 'Salida';

  @override
  String get pdfArrival => 'Llegada';

  @override
  String get pdfTotalLabel => 'Total';

  @override
  String get pdfDayCount => 'Días';

  @override
  String get pdfEngineHours => 'Horas de motor';

  @override
  String get pdfFuelLabel => 'Combustible';

  @override
  String get pdfWaterLabel => 'Agua';

  @override
  String get pdfVesselLabel => 'Embarcación';

  @override
  String get pdfSkipperLabel => 'Patrón';

  @override
  String get pdfDateLabel => 'Fecha';

  @override
  String get pdfColFrom => 'Desde';

  @override
  String get pdfColTo => 'Hasta';

  @override
  String get pdfColEntriesShort => 'Reg.';

  @override
  String get pdfColTimeUtc => 'Hora UTC';

  @override
  String get pdfColWind => 'Viento';

  @override
  String get pdfColPropulsion => 'Propulsión';

  @override
  String get pdfColWeatherShort => 'Met.';

  @override
  String get pdfColNote => 'Nota';

  @override
  String get pdfColDay => 'Día';

  @override
  String get pdfColItem => 'Elemento';

  @override
  String get pdfColStatus => 'Estado';

  @override
  String get pdfColNotePosition => 'Nota / posición';

  @override
  String get pdfColPhoto => 'Foto';

  @override
  String get pdfColDateRange => 'Fecha desde-hasta';

  @override
  String get pdfColArea => 'Zona';

  @override
  String get pdfColRole => 'Rol';

  @override
  String get pdfNameLabel => 'Nombre';

  @override
  String get pdfLicenceLabel => 'Licencia';

  @override
  String get pdfIssuedValidLabel => 'Expedida / validez';

  @override
  String get pdfOtherCertsLabel => 'Otros cert.';

  @override
  String get pdfContinued => 'continuación';

  @override
  String get pdfExportedAt => 'Exportado';

  @override
  String get pdfSignedAt => 'Firmado';

  @override
  String get pdfSignatureLabel => 'Firma';

  @override
  String get pdfDatePlaceLabel => 'Fecha / lugar';

  @override
  String get pdfManualEntryNote => '* registro manual (introducido a mano)';

  @override
  String get pdfStatTotalDistance => 'Distancia total';

  @override
  String get pdfStatLogEntries => 'Entradas del diario';

  @override
  String get pdfStatMaxBeaufort => 'Beaufort máx.';

  @override
  String get pdfStatDaysAtSea => 'Días en el mar';

  @override
  String get pdfStatVoyages => 'Número de travesías';

  @override
  String get pdfStatNightHours => 'Horas nocturnas';

  @override
  String get pdfFuelShort => 'C';

  @override
  String get pdfWaterShort => 'A';

  @override
  String get pdfNoData => 'Sin datos';

  @override
  String get pdfMapUnavailable => 'Mapa GPS no disponible';

  @override
  String get pdfUnsigned => 'Sin firmar';

  @override
  String get pdfNoSignatures => 'Sin firmas';

  @override
  String get pdfSha256Label => 'Huella SHA-256 de los datos del diario:';

  @override
  String get pdfVerifyQr => 'QR de verificación';

  @override
  String get pdfSbLifejackets => 'Chalecos salvavidas – ubicación y uso';

  @override
  String get pdfSbLifebuoy => 'Aro salvavidas y procedimiento MOB';

  @override
  String get pdfSbFlares => 'Bengalas – tipos y uso';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – activación';

  @override
  String get pdfSbVhf => 'Radio VHF – canal 16, procedimiento Mayday';

  @override
  String get pdfSbExtinguisher => 'Extintor – ubicación y uso';

  @override
  String get pdfSbFirstAid => 'Botiquín – ubicación';

  @override
  String get pdfSbEngineStop => 'Parada de emergencia del motor';

  @override
  String get pdfSbLeaks => 'Fugas – agua, gas';

  @override
  String get pdfSbAnchor => 'Ancla y cadena – procedimiento de fondeo';

  @override
  String get pdfSbRules => 'Normas a bordo';

  @override
  String get pdfSbEmergencyContacts => 'Contactos de emergencia y VHF 16';

  @override
  String get pdfBriefingDeclaration =>
      'Todos los tripulantes han sido informados y han comprendido las normas de seguridad, y lo confirman con su firma.';

  @override
  String get pdfHashCoverage =>
      'La huella cubre el nombre de la travesía, la embarcación, la tripulación y todos los registros (hora UTC, GPS, velocidad, rumbo). Cualquier cambio en los datos altera la huella.';

  @override
  String get pdfForCharterCompany => 'Por la empresa de chárter';

  @override
  String get dutyRoster => 'Guardia';

  @override
  String get dutyStartAction => 'Entrar de guardia';

  @override
  String get dutyEndAction => 'Terminar';

  @override
  String get dutyStartTitle => '¿Quién entra de guardia?';

  @override
  String get dutyRunningChip => 'DE GUARDIA';

  @override
  String dutySince(String time) {
    return 'desde $time';
  }

  @override
  String dutyElapsed(int h, int m) {
    return '$h h $m min';
  }

  @override
  String get dutyNobodyOnDuty => 'Nadie está de guardia';

  @override
  String get dutyInspectionView => 'Mostrar para inspección';

  @override
  String get dutyRosterHistory => 'Rol de guardias';

  @override
  String get dutyAddRetrospective => 'Añadir guardia pasada';

  @override
  String get dutyEditTitle => 'Editar guardia';

  @override
  String get dutyDeleteTitle => '¿Eliminar guardia?';

  @override
  String dutyDeleteConfirm(String name) {
    return 'Se eliminará el registro de guardia de $name.';
  }

  @override
  String get dutyNoCrewDefined => 'Esta travesía no tiene tripulación';

  @override
  String get dutyDefineCrew => 'Añadir tripulación';

  @override
  String get dutyErrorEndBeforeStart => 'El fin debe ser posterior al inicio.';

  @override
  String dutyErrorOverlap(String name) {
    return '$name ya está de guardia en ese momento.';
  }

  @override
  String get dutyErrorFutureStart => 'El inicio no puede estar en el futuro.';

  @override
  String get dutyNoteLabel => 'Nota';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'De guardia $hours h — ¿quedó abierta?';
  }

  @override
  String get dutyFrom => 'Desde';

  @override
  String get dutyTo => 'Hasta';

  @override
  String get dutyToOngoing => '— sigue de guardia';

  @override
  String get dutySelectPerson => 'Selecciona un tripulante';

  @override
  String get dutyNoRecords => 'Aún no hay guardias';

  @override
  String get logDutySection => 'Guardia';

  @override
  String get logDutyStillRunning => 'en curso';

  @override
  String get logEventAnchorDropped => 'Ancla fondeada';

  @override
  String get logEventAnchorRaised => 'Ancla levada';

  @override
  String get logEventDriftOut => 'Garreo – radio excedido';

  @override
  String get logEventDriftIn => 'Garreo – barco de vuelta en el radio';

  @override
  String logEventDutyStart(String name) {
    return 'Entra de guardia: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Sale de guardia: $name';
  }

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
  String get charterCheckCard => 'Travesía';

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
  String get sunAndMoonCard => 'Sol y Luna';

  @override
  String get sunriseLabel => 'Amanecer';

  @override
  String get sunsetLabel => 'Atardecer';

  @override
  String get moonPhaseLabel => 'Fase lunar';

  @override
  String get moonIlluminationLabel => 'Iluminado';

  @override
  String get moonPhaseNew => 'Luna nueva';

  @override
  String get moonPhaseWaxingCrescent => 'Creciente';

  @override
  String get moonPhaseFirstQuarter => 'Cuarto creciente';

  @override
  String get moonPhaseWaxingGibbous => 'Gibosa creciente';

  @override
  String get moonPhaseFull => 'Luna llena';

  @override
  String get moonPhaseWaningGibbous => 'Gibosa menguante';

  @override
  String get moonPhaseLastQuarter => 'Cuarto menguante';

  @override
  String get moonPhaseWaningCrescent => 'Menguante';

  @override
  String get noSunMoonGps =>
      'Se necesita posición GPS para el amanecer/atardecer';

  @override
  String get oceanCurrentsTitle => 'Corrientes oceánicas';

  @override
  String get oceanCurrentsTooltip => 'Corrientes oceánicas';

  @override
  String get oceanCurrentsDisclaimer =>
      'Datos solo orientativos (dirección/velocidad típica según cartas de pilotaje) — no para navegación de precisión; las corrientes varían estacionalmente.';

  @override
  String get tideCardTitle => 'Marea';

  @override
  String get nextHighTideLabel => 'Próxima pleamar';

  @override
  String get nextLowTideLabel => 'Próxima bajamar';

  @override
  String get noTideData => 'Aún no hay datos de mareas';

  @override
  String get downloadTides => 'Descargar predicción de mareas';

  @override
  String get downloadingTides => 'Descargando predicción de mareas...';

  @override
  String get tideMslWarning =>
      'Las alturas son sobre el nivel medio del mar, no sobre el cero hidrográfico — nunca las uses para la profundidad bajo la quilla.';

  @override
  String get tideNoCoverage =>
      'No hay datos de mareas para esta posición — está fuera del área de predicción marina.';

  @override
  String get tideDownloadFailed =>
      'No se pudo descargar la predicción de mareas. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String get tideForecastExpired =>
      'La predicción de mareas guardada ha caducado.';

  @override
  String tideForecastFarAway(int km) {
    return 'La predicción se descargó a $km km de aquí — vuelve a descargarla para esta posición.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Descargada el $when — vuelve a descargarla para la predicción más reciente.';
  }

  @override
  String get oceanCurrentCardTitle => 'Corriente marina';

  @override
  String get oceanCurrentSetsToward => 'Va hacia (velocidad en nudos)';

  @override
  String get oceanCurrentNoCoverage =>
      'No hay datos de corriente para esta posición.';

  @override
  String get oceanCurrentUnavailable =>
      'Predicción de corriente no disponible — comprueba la conexión.';

  @override
  String get tideOtherArea => 'Predicción para otra zona';

  @override
  String get tideAreaSearchLabel => 'Puerto, población o bahía';

  @override
  String get tideAreaSearchHint => 'p. ej. Split';

  @override
  String get tideAreaNoResults =>
      'No se encontró nada — prueba con otro nombre.';

  @override
  String tideForecastForArea(String place) {
    return 'Predicción para $place';
  }

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
  String get displaySettings => 'Pantalla';

  @override
  String get nightMode => 'Modo nocturno';

  @override
  String get nightModeDesc => 'Filtro rojo para preservar la visión nocturna';

  @override
  String get aboutApp => 'Acerca de';

  @override
  String get backupSection => 'Copia de seguridad';

  @override
  String get exportBackup => 'Exportar copia de seguridad';

  @override
  String get exportBackupDesc =>
      'Guarda todo el diario (travesías, registros, ajustes) en un solo archivo';

  @override
  String get restoreBackup => 'Restaurar desde copia de seguridad';

  @override
  String get restoreBackupDesc =>
      'Reemplaza los datos actuales con el contenido de un archivo de copia de seguridad seleccionado';

  @override
  String get restoreBlockedTrackingTitle => 'El seguimiento GPS está activo';

  @override
  String get restoreBlockedTrackingBody =>
      'Detén el seguimiento activo de la travesía antes de restaurar una copia de seguridad.';

  @override
  String get restoreSchemaTooNewTitle => 'La copia es de una versión más nueva';

  @override
  String get restoreSchemaTooNewBody =>
      'Esta copia de seguridad fue creada con una versión de la app más reciente que la instalada. Actualiza la app primero.';

  @override
  String get restoreConfirmTitle => '¿Restaurar desde copia de seguridad?';

  @override
  String get restoreConfirmBody =>
      'Los datos actuales serán reemplazados por el contenido de la copia. Antes se creará automáticamente una copia de seguridad del estado actual.';

  @override
  String get restoreSuccess =>
      'Los datos se restauraron correctamente desde la copia de seguridad.';

  @override
  String get restoreInvalidFile =>
      'El archivo seleccionado no es una copia de seguridad válida de HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Libro de millas';

  @override
  String get totalNm => 'NM totales';

  @override
  String get daysAtSea => 'Días en el mar';

  @override
  String get voyageCount => 'Número de travesías';

  @override
  String get nightHoursLabel => 'Horas nocturnas';

  @override
  String get byYear => 'Por año';

  @override
  String get byVessel => 'Por embarcación';

  @override
  String get addHistoricalVoyage => 'Añadir travesía histórica';

  @override
  String get editHistoricalVoyage => 'Editar travesía histórica';

  @override
  String get deleteHistoricalVoyageConfirm =>
      '¿Eliminar esta travesía histórica?';

  @override
  String get manualEntryExplanation => '* entrada manual (introducida a mano)';

  @override
  String get roleLabel => 'Rol a bordo';

  @override
  String get roleSkipper => 'Patrón';

  @override
  String get roleCoSkipper => 'Copatrón';

  @override
  String get roleCrew => 'Tripulación';

  @override
  String get areaLabel => 'Zona / ruta';

  @override
  String get distanceNmLabel => 'Distancia (NM)';

  @override
  String get daysCountLabel => 'Número de días';

  @override
  String get milesCertificateTitle => 'Certificado de millas navegadas';

  @override
  String get logbookRecordTitle => 'Registro del cuaderno';

  @override
  String get logbookTrackedHint =>
      'Las fechas, millas, zona y rol se calculan a partir del seguimiento/importación.';

  @override
  String get vesselFlag => 'Bandera de matrícula';

  @override
  String get captainFirstName => 'Nombre del patrón';

  @override
  String get captainLastName => 'Apellido del patrón';

  @override
  String get captainQualification => 'Titulación náutica más alta';

  @override
  String get logbookSignatureSection => 'Firma que confirma las millas';

  @override
  String get addSignature => 'Añadir firma';

  @override
  String get filterAllYears => 'Todos los años';

  @override
  String get filterCustomRange => 'Rango personalizado';

  @override
  String get handoverMenuTitle => 'Protocolo de entrega';

  @override
  String get checkInProtocol => 'Protocolo de check-in';

  @override
  String get checkOutProtocol => 'Protocolo de check-out';

  @override
  String get nextStepLabel => 'Siguiente paso';

  @override
  String get readyToTrackHint => 'Listo para iniciar el tracking';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Paso $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Briefing de\nseguridad';

  @override
  String get handoverChecklistShort => 'Checklist de\nentrega';

  @override
  String get safetyBriefingRefTitle => 'Briefing de seguridad';

  @override
  String get handoverChecklistRefTitle => 'Checklist de entrega';

  @override
  String get handoverDateTime => 'Fecha y hora';

  @override
  String get handoverLocation => 'Lugar (puerto deportivo)';

  @override
  String get checklistItemOk => 'OK';

  @override
  String get checklistItemDamaged => 'Dañado';

  @override
  String get checklistItemMissing => 'Falta';

  @override
  String get damagePosition => 'Posición en el barco';

  @override
  String get newDamageBadge => 'DAÑO NUEVO';

  @override
  String get companySignatureSection =>
      'Firma del representante de la empresa de charter';

  @override
  String get companyRepName => 'Nombre del representante';

  @override
  String get companyNameLabel => 'Nombre de la empresa';

  @override
  String get protocolClosedNotice =>
      'El protocolo está cerrado (ambas partes firmaron) – solo lectura.';

  @override
  String get handoverCertTitle => 'Protocolo de entrega de la embarcación';

  @override
  String get itemSails => 'Velas';

  @override
  String get itemRigging => 'Jarcia';

  @override
  String get itemAnchorChain => 'Ancla y cadena';

  @override
  String get itemNavInstruments => 'Instrumentos de navegación';

  @override
  String get itemLifeJackets => 'Chalecos salvavidas';

  @override
  String get itemRaft => 'Balsa salvavidas';

  @override
  String get itemFirstAidKit => 'Botiquín';

  @override
  String get itemDinghyMotor => 'Bote auxiliar y motor fueraborda';

  @override
  String get itemLights => 'Luces';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Notas adicionales';

  @override
  String get gpxImportTitle => 'Importar GPX';

  @override
  String get gpxImportPickFile => 'Elegir archivo GPX';

  @override
  String get gpxTracksFound => 'Tracks encontrados';

  @override
  String get gpxWaypointsFound => 'Waypoints encontrados';

  @override
  String get gpxAssignTarget => 'Asignar a travesía';

  @override
  String get gpxNewVoyage => 'Nueva travesía';

  @override
  String get gpxImportButton => 'Importar';

  @override
  String get gpxImportSuccess => 'GPX importado correctamente.';

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
      'Conecte el teléfono a la red WiFi de Raymarine (p. ej. WiFi-1, RayNet). La IP a introducir NO es la que aparece en los ajustes de Raymarine — es la IP de puerta de enlace (gateway) de esa red WiFi. Encuéntrela en el teléfono: Ajustes → WiFi → detalles de red → Puerta de enlace. Puerto 2000 (TCP) es el estándar. Sin conexión, la app usa automáticamente el GPS del teléfono.';

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
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Puerto de escucha';

  @override
  String get startListening => 'Iniciar';

  @override
  String get stopListening => 'Detener';

  @override
  String connectionListening(String port) {
    return 'Escuchando UDP en puerto $port';
  }

  @override
  String udpHint(String port) {
    return 'Configura el simulador/gateway para enviar UDP a la IP de este teléfono, puerto $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Escuchando en puerto UDP $port';
  }

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
  String get engineSection => 'Motor y tanques';

  @override
  String get engineHours => 'Horas de motor';

  @override
  String get fuel => 'Combustible';

  @override
  String get fuelLevel => 'Nivel de combustible';

  @override
  String get waterLevel => 'Nivel de agua';

  @override
  String get noteSection => 'Nota';

  @override
  String get noteHint =>
      'Condiciones de navegación, eventos, cambio de tripulación...';

  @override
  String get quickPhotoLogTitle => 'Registro rápido';

  @override
  String get quickPhotoNoteHint => '¿Qué es esto? (opcional)';

  @override
  String get exportDayTitle => 'Exportar día';

  @override
  String get exportCharterTitle => 'Exportación de travesía';

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
  String get exportCharterBtn => 'Exportar travesía';

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
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Guardado: $pdf + $gpx';
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
  String get editWaypoint => 'Editar waypoint';

  @override
  String get deleteWaypointTitle => '¿Eliminar waypoint?';

  @override
  String deleteWaypointNavActive(String name) {
    return 'La navegación hacia $name está activa. Al eliminar el waypoint se desactivará.';
  }

  @override
  String get waypointNameLabel => 'Nombre';

  @override
  String get skipperSignature => 'Firma del patrón';

  @override
  String get skipperNameLabel => 'Nombre del patrón';

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
  String get editCharter => 'Editar travesía';

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
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Indicativo de llamada';

  @override
  String get vesselLengthM => 'Eslora (m)';

  @override
  String get vesselBeamM => 'Manga (m)';

  @override
  String get vesselDraftM => 'Calado (m)';

  @override
  String get selectExistingVoyage => 'Seleccionar viaje existente';

  @override
  String get newVoyageForm => 'Nuevo viaje';

  @override
  String get fillFormAndBriefing => 'Rellenar formulario y firmar briefing';

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
  String get selectWaypointHint => 'Navegar al waypoint';

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
  String get navInstruments => 'Instrumentos náuticos';

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
  String get onlineAccountDesc =>
      'Sincronización del diario en línea — próximamente';

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
      '1. Toca el botón grande \"Iniciar travesía\" arriba (en Mapa, Diario o Instrumentos) – elige la frecuencia de registro y el seguimiento arranca, no hay que rellenar nada más antes\n2. Si tienes una travesía abierta, la app pregunta: continuarla o crear un nuevo registro\n3. Completa los datos que falten (check-in, briefing de seguridad, ficha de barco/tripulación) cuando quieras – la app te lo recuerda con chips en el Diario\n4. Añade entradas durante el día: hora, posición, nota\n5. Al final de la travesía: Ajustes → Exportar PDF\n\nLa app funciona a pantalla completa – desliza desde el borde superior o inferior para mostrar temporalmente las barras del sistema del teléfono.';

  @override
  String get guideMapTitle => 'Mapa';

  @override
  String get guideMapBody =>
      'La pestaña Mapa muestra tu posición actual y la ruta de la travesía.\n\n• Punto azul = posición actual\n• Línea azul = ruta que se está grabando ahora\n• Icono de ruta – elige cualquier travesía o día para ver su ruta en el mapa (en naranja), sin exportar a PDF\n• Cambiar entre vista satélite y mapa\n• Marcas marinas – activa señales náuticas (naufragios, bajos, boyas)\n• Puertos – capa táctil de fondeaderos, marinas y puertos (datos de OpenStreetMap): toca un icono para ver nombre, canal VHF, teléfono, web, profundidad o capacidad si constan; guarda el lugar como waypoint con un toque; la capa incluye también gasolineras náuticas (surtidor naranja)\n• Radar – radar de lluvia (RainViewer), la imagen se actualiza ~cada 10 minutos\n• Viento – flechas de dirección/fuerza del viento (nudos) en una cuadrícula sobre el área visible\n• Regla (icono morado) – toca puntos en el mapa: NM totales, rumbo del último tramo y ETA a la velocidad actual; los puntos se ajustan a los waypoints\n• Mapa offline (icono de descarga) – descarga el área visible (mapa + marcas náuticas, zoom actual +3 niveles) para usar sin señal; cada tesela vista también se guarda automáticamente\n• En modo nocturno el mapa cambia automáticamente a teselas oscuras\n• Icono de ancla = posición de fondeo (solo con alarma de ancla activa)\n• Icono de importar – carga tracks y waypoints desde un archivo .gpx (ver \"Importar GPX\")\n• Bloqueo al norte – mantén pulsada la rosa de la brújula (arriba a la izquierda); el mapa deja de rotar y se mantiene con el norte arriba. Tócala para volver al norte.\n• Las capas elegidas (satélite, marcas náuticas, puertos, radar, viento…), el seguimiento GPS y el bloqueo al norte se recuerdan entre sesiones\n• Mantén pulsado el mapa = añade un waypoint (destino de navegación); toca un waypoint existente para renombrarlo o eliminarlo';

  @override
  String get guideInstrTitle => 'Instrumentos marinos';

  @override
  String get guideInstrBody =>
      'La pestaña Instrumentos muestra datos de navegación en tiempo real.\n\n• SOG – velocidad sobre el fondo (nudos)\n• TWS – velocidad del viento verdadero\n• TWA – ángulo del viento verdadero (verde = estribor, rojo = babor)\n• DEPTH – profundidad del agua (rojo = menos de 5 m)\n• VMG WP – velocidad hacia un waypoint seleccionado; al elegirlo verás distancia/rumbo y una flecha directamente en la rosa de los vientos. Para desactivar la navegación elige \"Sin destino\" en el mismo mosaico — también la desactiva eliminar el waypoint en el mapa\n\nFuente de datos: GPS del teléfono o Raymarine (pasarela WiFi TCP o UDP).\nConfiguración de conexión (incluida la elección TCP/UDP) en Ajustes → Instrumentos.\n\nCómo se conecta el barco: la app lee datos NMEA por WiFi (TCP o UDP). El propio hotspot WiFi de un MFD Raymarine normalmente no basta — está pensado para las apps de Raymarine y no suele exponer NMEA en bruto a terceros. Necesitas una pasarela NMEA-a-WiFi (p. ej. Digital Yacht, Yacht Devices, Actisense, Quark-elec) conectada al bus del barco, que crea su propio hotspot o difunde NMEA en la WiFi. Conéctate a la WiFi de esa pasarela e introduce su IP y puerto en Ajustes (o prueba Detección automática).';

  @override
  String get guideLogbookTitle => 'Diario de navegación';

  @override
  String get guideLogbookBody =>
      'El Diario es la pestaña principal para gestionar travesías.\n\n• El botón grande \"Iniciar travesía\" arriba inicia el seguimiento – solo pregunta la frecuencia de las entradas automáticas (modificable en cada reinicio), sin formularios previos\n• Si ya hay una travesía abierta, la app pregunta si continuarla o crear un nuevo registro\n• Los datos que falten (check-in, briefing de seguridad, ficha de barco/tripulación) se recuerdan con chips de color directamente en la tarjeta de la travesía – toca un chip para completarlo\n• Cada día de travesía se muestra por separado\n• Se pueden añadir entradas manualmente durante el día, incluidas horas de motor, combustible y agua en la sección \"Motor y tanques\"\n• Durante el rastreo aparece un botón de cámara (abajo a la izquierda) para fotografiar un punto de interés y guardarlo como entrada rápida con posición y hora\n• Exportar a PDF desde el menú del día\n• El icono de manos en el detalle de la travesía abre el protocolo de entrega (check-in/check-out)\n• El formulario detallado de la travesía (icono de barco en el detalle) registra el barco y sus parámetros, la zona de navegación, tripulación con las licencias del patrón y fotos del barco (máx. 3, se incluyen en el PDF)\n• Las tarjetas sin completar (briefing de seguridad, check-in/out, ficha del barco) parpadean en rojo en la barra superior del detalle hasta completarse\n• Si la aplicación se cierra durante la travesía sin detener el seguimiento (el sistema la cierra, un deslizamiento accidental), al abrirla de nuevo ofrece continuar la misma travesía, incluida la distancia recorrida mientras no estaba activa\n• La primera vez que inicias una travesía la aplicación recuerda los ajustes de batería: sin ellos el sistema (sobre todo Honor/Huawei) puede detener el seguimiento en segundo plano\n• El icono de ruta en la cabecera de la travesía (junto al briefing, el protocolo y la ficha del barco) muestra toda la derrota en el mapa\n• Tras la travesía puedes exportar un certificado de millas para cada tripulante: días en el mar, millas de día y de noche, zona de navegación, valoración del patrón y un QR de verificación\n• La propulsión (motor/velas) pasa también a las anotaciones automáticas: la marcas una vez y las siguientes la mantienen\n• El certificado es bilingüe (tu idioma + inglés) e incluye las dimensiones y la matrícula del barco, el tipo de aguas (con o sin marea) y una línea para el número de pasaporte o DNI; se puede compartir o guardar en el teléfono';

  @override
  String get guideMilesTitle => 'Libro de millas';

  @override
  String get guideMilesBody =>
      'Resumen de todas las travesías en un solo lugar (icono en el Diario).\n\n• Millas náuticas totales, días en el mar, número de travesías y horas nocturnas\n• Desglose por año y por embarcación\n• Filtro por año\n• Toca una travesía (incluida una rastreada/importada) para completar su registro del cuaderno – ruta, bandera del barco, nombre y titulación del patrón, firma que confirma las millas\n• Botón + – añade una travesía histórica de antes de usar la app (se cuenta plenamente en los resúmenes, marcada con asterisco en la lista)\n• Exportación PDF de un certificado de millas navegadas con espacio para firmar';

  @override
  String get guideHandoverTitle => 'Protocolo de entrega (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Registro formal de la entrega y devolución del barco en un charter – icono de manos en el detalle de la travesía.\n\n• Checklist de equipamiento (velas, jarcia, ancla, navegación, chalecos, balsa, botiquín, bote auxiliar, luces, bimini...) – OK / dañado / falta, con nota, posición en el barco y foto\n• Estado de combustible, agua y horas de motor\n• Firma del patrón y del representante de la empresa de charter\n• El protocolo pasa a ser de solo lectura cuando ambos han firmado\n• El check-out se rellena con los datos del check-in y resalta los daños nuevos\n• Exportación PDF con ambas firmas una junto a la otra';

  @override
  String get guideGpxImportTitle => 'Importar GPX';

  @override
  String get guideGpxImportBody =>
      'Importa tracks y waypoints desde otras apps de navegación o dispositivos GPS (icono en el Mapa).\n\n• Elige un archivo .gpx del dispositivo\n• Una exportación de varios días (varios tracks en un archivo, p. ej. de Garmin Explore) se combina automáticamente en una sola travesía con un día por cada día del calendario\n• Los tracks encontrados también se pueden asignar manualmente a una travesía existente\n• Los waypoints (también de rutas) se añaden directamente al mapa\n• Se muestra un mensaje de error claro si el archivo está dañado';

  @override
  String get guideWeatherTitle => 'Tiempo';

  @override
  String get guideWeatherBody =>
      'La pestaña Tiempo muestra el pronóstico según tu posición actual.\n\n• Se actualiza automáticamente al cambiar de posición\n• Muestra viento, oleaje, temperatura y condiciones para las próximas horas\n• Sin conexión: se muestra el último pronóstico guardado\n\nSol, luna y mareas:\n• El orto, el ocaso y la fase lunar se calculan en el dispositivo — sin conexión\n• Toca actualizar en la tarjeta de Marea para descargar una predicción de 7 días (gratis, sin clave API)\n• Las mareas se guardan en caché y siguen visibles sin conexión; la tarjeta avisa si la predicción es antigua o se descargó lejos de aquí\n• ⚠ Las alturas de marea son sobre el nivel medio del mar, no sobre el cero hidrográfico — nunca las uses para calcular la profundidad bajo la quilla\n\nCorriente marina:\n• La tarjeta Corriente marina muestra la predicción real para tu posición en nudos y la dirección hacia la que va la corriente\n• En el mapa, el botón de doble flecha dibuja una malla de corriente para el área visible; las flechas indican hacia dónde se mueve el agua\n• No confundir con la capa Corrientes oceánicas — esa es una carta de referencia de las grandes corrientes globales';

  @override
  String get guideSafetyMobTitle => 'MOB y ancla';

  @override
  String get guideSafetyMobBody =>
      'La pestaña Seguridad contiene funciones de emergencia.\n\nMOB (Hombre al agua):\n• Mantener pulsado el botón rojo MOB para activar\n• La app guarda la posición GPS y mide tiempo y distancia\n• Navegar de vuelta al punto de caída\n\nAlarma de ancla:\n• Establecer el radio de fondeo (recomendado: 2× longitud de cadena)\n• La alarma vibra si el barco sale del radio permitido';

  @override
  String get guideSafetyBriefingTitle => 'Briefing de seguridad y MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'La pestaña Seguridad también contiene tarjetas de referencia.\n\n• Briefing de seguridad – checklist para la tripulación antes de zarpar\n• Cada miembro firma con su propia firma en pantalla\n• Las firmas se guardan y se incluyen automáticamente en el PDF de la travesía\n• Checklist de entrega – resumen de los puntos de check-in/check-out, disponible incluso sin una travesía abierta\n• Tarjeta MAYDAY – procedimiento para llamada de socorro en canal 16 VHF\n• COLREG – reglamento de abordajes en la mar (disponible en eslovaco e inglés; los demás idiomas muestran el texto en inglés)\n• Contactos de emergencia – números y contactos de emergencia\n\nNota: el rastreo se puede iniciar en cualquier momento, incluso sin completar el briefing – la app solo lo recuerda con un chip \"Falta briefing de seguridad\" en el Diario hasta que lo completes. El briefing requiere tener antes la ficha de barco y tripulación rellenada y solo se guarda cuando todos los tripulantes han firmado.\n• Los contactos de emergencia siguen tu posición aunque el seguimiento esté apagado: la aplicación pide la posición y cambia los números al pasar a otro país';

  @override
  String get guideDutyTitle => 'Guardia de la tripulación';

  @override
  String get guideDutyBody =>
      'Un registro de quién estuvo de guardia y cuándo — en Seguridad, sobre la alarma de fondeo.\n\n• Entrar de guardia — elige a una o varias personas a la vez; cada una sale de guardia por separado\n• Los nombres salen de la tripulación de la travesía. Si no hay tripulación, el botón te lleva a la ficha de la travesía\n• La hora de inicio se puede corregir si pulsaste tarde\n• Mostrar para inspección — una tarjeta a pantalla completa para entregar a bordo: quién está de guardia, desde cuándo, hora local y UTC. No permite cambiar nada\n• Rol de guardias — añade una guardia pasada o edítala. Si dejas la hora \"hasta\" vacía, la guardia sigue en curso\n• Una guardia nocturna que cruza medianoche es un solo registro, no dos. En el PDF aparece en ambos días, marcada con una flecha\n• La entrada y la salida de guardia se escriben en el diario y en el PDF\n\nNota: la app nunca cierra una guardia por su cuenta. A las 12 horas solo avisa — una hora de fin que no presenciaste sería un dato inventado.';

  @override
  String get guideCompassTitle => 'Brújula de navegación';

  @override
  String get guideCompassBody =>
      'La pestaña Brújula muestra el rumbo magnético usando los sensores del teléfono, con la cámara trasera de fondo para tomar marcaciones de objetos.\n\n• Cruz amarilla – dirección a la que apuntas\n• Franja de brújula arriba – N / NE / E / SE / S / SW / W / NW\n• Lectura numérica – grados y punto cardinal\n• Punto verde = lectura estable  ·  Punto naranja = calibrando\n\nSi la lectura es inestable, mueve el teléfono despacio en forma de ocho para calibrar el magnetómetro.\n\nNota: la precisión puede reducirse cerca de estructuras metálicas, altavoces o equipos electrónicos.\n\nEl compás resuelve dos tareas distintas: encontrar MI PROPIA POSICIÓN cuando no sé dónde estoy, o determinar un PUNTO DESCONOCIDO cuando quiero llevar a la carta algo que todavía no tiene. El interruptor encima del botón Tomar demora elige cuál de las dos estás haciendo.\n\nMI SITUACIÓN — encuéntrate a ti mismo (no hace falta GPS)\n\n1. Comprueba en el mapa que conoces al menos dos puntos visibles (faro, cumbre, iglesia) guardados como waypoints. Añade el que falte con una pulsación larga en el mapa justo en su posición.\n2. En el compás, cambia a \"Mi situación\".\n3. Toca la etiqueta bajo el interruptor y elige el primer punto que vas a demorar.\n4. Alinea la retícula exactamente con él y pulsa Tomar demora.\n5. Comprueba la demora medida en el diálogo y pulsa Guardar (Cancelar descarta el borrador sin guardar).\n6. Elige un segundo punto, DISTINTO (la selección se vacía sola tras guardar) y repite.\n7. En el mapa verás dos líneas discontinuas que van de los puntos hacia ti. Donde se cruzan está tu situación: una cruz verde significa un buen corte, naranja un ángulo agudo y una situación incierta.\n8. Un tercer punto, mejor en otro ángulo, afina la estimación y dibuja el triángulo de error.\n\nHazlo rápido, en menos de 5 minutos: la situación por demoras supone que el barco está parado entre demoras.\n\nPUNTO DESCONOCIDO — determina un objeto (hace falta GPS)\n\n1. Cambia a \"Punto desconocido\".\n2. Toca la etiqueta, elige \"Nuevo punto…\" y nombra lo que estás demorando, por ejemplo \"roca desconocida\".\n3. Apunta, Tomar demora, confirma Guardar.\n4. Desplaza el barco al menos unos cientos de metros: cuanto más lejos, más fiable el resultado.\n5. Abre de nuevo el selector de objetivo, elige el MISMO objeto de la lista (no \"Nuevo punto\") y demóralo por segunda vez.\n6. En el mapa aparece una marca con la posición calculada. Tócala para guardarla como waypoint; desde ese momento también sirve para tomar demoras a un punto conocido.\n\nPrecisión\n\nUn compás de teléfono tiene un error real de unos ±8°, que a 10 millas son más de 2,5 millas de desviación lateral: por eso la app dibuja un cono de incertidumbre en vez de una línea fina. El mejor corte lo dan puntos separados cerca de 90°; si están casi alineados contigo, la intersección se difumina en cientos de metros o más.\n\nDemoras sin plavba (sin travesía activa)\n\nUna demora se guarda aunque el seguimiento esté apagado: fondeado, en tierra. La encontrarás en la lista de travesías como una fila propia con fecha, entre unas travesías y otras. Al abrirla verás las demoras de ese día con un pequeño mapa, y desde ahí puedes exportar un PDF sencillo con el mapa y la tabla de demoras.\n\nLimpiar la carta y borrar demoras\n\nTomar demoras con la carta limpia – en la Brújula, el icono de actualizar arriba a la derecha. Retira de la carta las demoras que ya tienes y borra la marca u objeto elegido, de modo que la siguiente demora empieza de cero. No se pierde nada: los registros siguen en la pestaña Cuaderno de bitácora y en la exportación a PDF.\n\nBorrar definitivamente – abre la fila con la fecha en la lista de travesías. La X junto a una línea elimina esa única demora (en un objeto, toda la serie de demoras sobre él). La papelera de la barra superior borra el día entero de una vez y te devuelve a la lista. El borrado es irreversible y esas demoras desaparecen también de la exportación a PDF.\n\nEn resumen: limpiar ordena la carta, borrar elimina el registro. Solo el borrado cambia lo que acaba en el PDF.';

  @override
  String get guideSettingsTitle => 'Ajustes';

  @override
  String get guideSettingsBody =>
      '• Idioma – cambiar el idioma de la app\n• Instrumentos – configurar la dirección IP de la pasarela WiFi Raymarine (TCP o UDP)\n• Fuente GPS – teléfono o Raymarine\n• Unidades – distancia NM/km, velocidad nudos/km/h, además temperatura, profundidad y viento por separado (km + km/h va bien en río)\n• Frecuencia de entradas en el diario\n• Pantalla – modo nocturno (filtro rojo para preservar la visión nocturna)\n• Menú inferior – personalízalo: mantén y arrastra un icono para reordenar, usa el interruptor para ocultar pestañas que no uses y ajusta el tamaño de los iconos (S/M/L). Las pestañas ocultas se abren aquí en Ajustes; Ajustes siempre se muestra. El orden y el tamaño se recuerdan. Las etiquetas bajo los iconos están ocultas para que los iconos queden igual en todos los idiomas; mantén pulsado un icono para ver su nombre.\n• Exportación a la nube (Google Drive) – con sesión iniciada, el PDF y GPX de cada día finalizado se suben automáticamente a tu propio Google Drive. Sin iniciar sesión, todo queda en el dispositivo.\n• Copia de seguridad – ver \"Copia de seguridad y restauración de datos\"\n• Acerca de – versión y contacto\n• Batería – El GPS funciona con precisión máxima solo donde importa la posición exacta (seguimiento de la travesía, carta, compás, instrumentos, guardia de fondeo, MOB); en el resto pasa a un modo de bajo consumo y en segundo plano, sin seguimiento activo, se apaga por completo. Con los instrumentos de a bordo conectados el GPS del teléfono permanece apagado y la posición llega por NMEA.';

  @override
  String get guideBackupTitle => 'Copia de seguridad y restauración de datos';

  @override
  String get guideBackupBody =>
      'En Ajustes → Copia de seguridad.\n\n• Exportar copia de seguridad – guarda todo el diario (travesías, registros, ajustes) en un solo archivo (.hmbbackup) que puedes compartir por email, en la nube o guardar localmente\n• Restaurar desde copia de seguridad – reemplaza los datos actuales con el contenido de la copia seleccionada; antes se crea automáticamente una copia de seguridad del estado actual\n• La restauración está bloqueada mientras el seguimiento GPS de una travesía está activo\n• Una copia con un esquema más nuevo del que soporta la app se rechaza con una explicación';

  @override
  String get guideExportTitle => 'Exportar diario';

  @override
  String get guideExportBody =>
      'El diario se puede exportar como documento PDF profesional.\n\n1. Abrir Diario → seleccionar travesía\n2. Pulsar icono de exportar o tres puntos → Exportar PDF\n3. Firmar como patrón → se genera el PDF\n4. El PDF incluye: ruta, entradas, fotos, portada con la foto del barco de la ficha del barco (si está subida), briefing de seguridad con firmas de tripulación\n5. Compartir por email, imprimir o guardar en el teléfono\n\nCada PDF recibe un ID único de documento (p.ej. HMBSL-5-2026) y un número de revisión (Rev. 1, Rev. 2...) visible en el pie de cada página. Cada nueva exportación incrementa automáticamente el número — es visible cuántas veces se generó el documento.\n\nEl código QR en la página de firma contiene el ID, revisión y una huella criptográfica del contenido. Cualquier cambio en los datos cambia el código QR.\n\nEl PDF se genera en el idioma de la app, con los nombres y su acentuación. Cada página diaria incluye además un resumen de las guardias.\n• Si el seguimiento se detuvo y se reanudó durante el día, cada tramo genera su propio archivo GPX\n• Las distancias, velocidades y temperaturas del PDF siguen las unidades definidas en Ajustes';

  @override
  String get safetyBriefingScreenTitle => 'Instrucción de seguridad';

  @override
  String get briefingCrewSignaturesSection => 'Firmas de la tripulación';

  @override
  String get briefingSignHere => 'Firmar aquí';

  @override
  String get briefingClear => 'Borrar';

  @override
  String get briefingSigned => 'Firmado';

  @override
  String get briefingSave => 'Guardar firmas';

  @override
  String get briefingSavedOk => 'Firmas guardadas';

  @override
  String get briefingOpenBriefing => 'Instrucción de seguridad';

  @override
  String get briefingSkipper => 'Patrón';

  @override
  String get briefingCrew => 'Tripulación';

  @override
  String get briefingNoCrew =>
      'Sin tripulación definida. Añade miembros en la configuración del viaje.';

  @override
  String get briefingDate => 'Fecha';

  @override
  String get briefingLocation => 'Lugar';

  @override
  String get briefingDoneLabel => 'Instrucción de seguridad completada';

  @override
  String get briefingDoneSubtitle =>
      'Todas las firmas guardadas. No es necesario repetir.';

  @override
  String get briefingEditSignature => 'Cambiar firma';

  @override
  String get briefingRequiredTitle => 'Se requiere instrucción de seguridad';

  @override
  String get briefingRequiredBody =>
      'Completa la instrucción de seguridad y recoge las firmas antes de iniciar el primer rastreo.';

  @override
  String get goToBriefing => 'Ir al briefing';

  @override
  String get skipperProfile => 'Perfil del patrón';

  @override
  String get skipperProfileHint =>
      'Estos datos aparecen en la exportación PDF del viaje.';

  @override
  String get skipperFullName => 'Nombre del patrón';

  @override
  String get skipperLicenseSection => 'Licencia de patrón';

  @override
  String get skipperLicenseType => 'Tipo de licencia';

  @override
  String get skipperLicenseNumber => 'Número de licencia';

  @override
  String get skipperLicenseAuthority => 'Autoridad emisora';

  @override
  String get skipperLicenseExpiry => 'Válido hasta';

  @override
  String get skipperVhfSection => 'Licencia VHF / SRC';

  @override
  String get skipperVhfNumber => 'Número VHF/SRC';

  @override
  String get skipperVhfExpiry => 'VHF válido hasta';

  @override
  String get skipperOtherCerts => 'Otros certificados / licencias';

  @override
  String get skipperOtherCertsHint =>
      'p.ej. Yachtmaster, RYA, STCW, cursos de rescate...';

  @override
  String get continueLastVoyageTitle => '¿Continuar la última travesía?';

  @override
  String get continueVoyageAction => 'Continuar';

  @override
  String get newRecordAction => 'Nuevo registro';

  @override
  String get missingCheckInChip => 'Falta check-in';

  @override
  String get missingBriefingChip => 'Falta briefing de seguridad';

  @override
  String get missingDetailsChip => 'Faltan datos de barco/tripulación';

  @override
  String get missingCheckOutChip => 'Falta check-out';

  @override
  String get vesselModel => 'Modelo';

  @override
  String get vesselTypeMonohull => 'Monocasco';

  @override
  String get vesselTypeCatamaran => 'Catamarán';

  @override
  String get vesselTypeTrimaran => 'Trimarán';

  @override
  String get vesselTypeMotorYacht => 'Yate a motor';

  @override
  String get vesselTypeGulet => 'Gulet';

  @override
  String get vesselTypeDinghy => 'Bote';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Otro';

  @override
  String get charterCompanyLabel => 'Compañía de chárter';

  @override
  String get yachtParamsSection => 'Parámetros del yate';

  @override
  String get berthsLabel => 'Literas';

  @override
  String get yearBuiltLabel => 'Año de construcción';

  @override
  String get waterTankLabel => 'Tanque de agua';

  @override
  String get fuelTankLabel => 'Tanque de combustible';

  @override
  String get engineHoursStartLabel => 'Horas de motor · inicio';

  @override
  String get engineHoursEndLabel => 'Horas de motor · fin';

  @override
  String get whereWhenSection => 'Dónde y cuándo';

  @override
  String get countryLabel => 'País';

  @override
  String get cruisingAreaLabel => 'Zona de navegación';

  @override
  String get charterContactsSection => 'Contactos del chárter';

  @override
  String get charterContactsHint =>
      'Hasta 3 números para llamada / WhatsApp / SMS. Siempre con prefijo internacional (p. ej. +385...).';

  @override
  String get addPhoneNumber => 'Añadir número de teléfono';

  @override
  String get costsSection => 'Costes';

  @override
  String get charterPriceLabel => 'Precio de la travesía';

  @override
  String get currencyLabel => 'Moneda';

  @override
  String get addCostItem => 'Añadir coste';

  @override
  String get costName => 'Nombre del coste';

  @override
  String get crewSectionHint =>
      'Toca la insignia para designar al patrón — el resto es tripulación.';

  @override
  String get addCrewMember => 'Añadir tripulante';

  @override
  String get crewNameLabel => 'Nombre';

  @override
  String get skipperBadge => 'SKIPPER';

  @override
  String get crewBadge => 'CREW';

  @override
  String get vesselTypeSailboat => 'Velero';

  @override
  String get vesselTypeMotorBoat => 'Lancha a motor';

  @override
  String get sbNeedsVesselCard =>
      'Completa primero la ficha del barco y la tripulación — el briefing de seguridad necesita la lista de tripulantes para las firmas.';

  @override
  String get prefillSkipperTitle => '¿Rellenar los datos guardados del patrón?';

  @override
  String get prefillSkipperFill => 'Rellenar';

  @override
  String get prefillSkipperNew => 'Nuevo patrón';

  @override
  String get boatLicenceLabel => 'N.º licencia náutica';

  @override
  String get radioLicenceLabel => 'N.º licencia de radio';

  @override
  String get vesselPhotosSection => 'Fotos del barco (máx. 3)';

  @override
  String get addPhotoLabel => 'Añadir';

  @override
  String get createVoyageButton => 'Crear travesía';

  @override
  String get saveVoyageButton => 'Guardar travesía';

  @override
  String get costBaseCharter => 'Precio base de la travesía';

  @override
  String get costDeposit => 'Fianza';

  @override
  String get costDinghyOutboard => 'Bote / fueraborda';

  @override
  String get costOutboardFuel => 'Combustible del fueraborda';

  @override
  String get costTransitLog => 'Transit log';

  @override
  String get costTouristTax => 'Tasa turística';

  @override
  String get costFinalCleaning => 'Limpieza final';

  @override
  String get costLinenTowels => 'Ropa de cama y toallas';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / kayak';

  @override
  String get costSkipperFee => 'Tarifa de patrón';

  @override
  String get costHostessFee => 'Tarifa de azafata';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m m';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Ubicación aproximada · ±$m m · localización por red';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Última ubicación conocida · hace $mins min';
  }

  @override
  String get locationQualityUnknown => 'Precisión desconocida';

  @override
  String get locationQualityMocked => '⚠️ Ubicación falsa detectada';

  @override
  String get syncQueueTitle => 'Cola de sincronización';

  @override
  String get syncQueueEmpty => 'La cola está vacía';

  @override
  String get syncNowAction => 'Sincronizar ahora';

  @override
  String get syncRetryFailedAction => 'Reintentar';

  @override
  String get syncStatusPending => 'Pendiente';

  @override
  String get syncStatusSending => 'Enviando';

  @override
  String get syncStatusSent => 'Enviado';

  @override
  String get syncStatusFailed => 'Fallido';

  @override
  String get syncStatusConflict => 'Conflicto';

  @override
  String get syncStatusDeferred => 'Aplazado';

  @override
  String syncRetryCount(int n) {
    return 'Intento $n';
  }

  @override
  String get syncOffline => 'sin conexión';

  @override
  String syncPendingCount(int n) {
    return '$n pendientes';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n aplazados';
  }

  @override
  String syncFailedCount(int n) {
    return '$n fallidos';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Adjunto esperando Wi-Fi (normalmente no disponible en el mar).';

  @override
  String get syncWifiOverrideAction => 'Usar datos móviles';

  @override
  String get syncWifiOverrideActive => 'Datos móviles permitidos para adjuntos';

  @override
  String get syncClearQueueAction => 'Vaciar cola';

  @override
  String get syncClearQueueConfirmTitle => '¿Vaciar toda la cola?';

  @override
  String get syncClearQueueConfirmContent =>
      'Elimina todos los elementos de la cola de sincronización, incluidos los ya enviados. Esta acción no se puede deshacer.';

  @override
  String get syncClearQueueDone => 'Cola vaciada';

  @override
  String get syncEnableToggle => 'Sincronizar diario';

  @override
  String get syncEnableToggleDesc =>
      'Enviar registros al servidor mientras la app esté abierta y en línea';

  @override
  String get syncTargetLabel => 'Destino de sincronización';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Servidor personalizado';

  @override
  String get syncCustomUrlLabel => 'URL del servidor';

  @override
  String get syncCustomTokenLabel => 'Token';

  @override
  String get syncTestConnectionAction => 'Probar conexión';

  @override
  String get syncTestSuccess => 'La conexión funciona';

  @override
  String syncTestFailure(String detail) {
    return 'Fallo: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Introduce la URL del servidor';

  @override
  String get syncUrlErrorInvalid => 'URL no válida';

  @override
  String get syncUrlErrorHttps => 'La URL debe empezar con https://';

  @override
  String get syncIntervalLabel => 'Intervalo de sincronización';

  @override
  String syncIntervalMinutes(int n) {
    return '$n min';
  }

  @override
  String get syncIntervalNote =>
      'La sincronización solo funciona con la app abierta';

  @override
  String get syncAttachmentPolicyLabel => 'Adjuntos (fotos)';

  @override
  String get syncAttachmentNever => 'Nunca';

  @override
  String get syncAttachmentWifiOnly => 'Solo con Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Siempre';

  @override
  String get syncBackfillAction => 'Encolar entradas anteriores';

  @override
  String get syncBackfillDesc =>
      'Añade a la cola las entradas creadas mientras la sincronización estaba desactivada';

  @override
  String syncBackfillResult(int n) {
    return '$n encoladas';
  }

  @override
  String get syncBackfillNone =>
      'Nada que encolar — todo ya está en cola o enviado';

  @override
  String get syncCloudEnableToggle => 'Exportación a la nube (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Con sesión iniciada, el PDF y GPX de cada día finalizado se suben automáticamente a Google Drive. Sin iniciar sesión, todo queda solo en el dispositivo.';

  @override
  String get syncCloudSignInAction => 'Iniciar sesión con Google';

  @override
  String get syncCloudSignOutAction => 'Cerrar sesión';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Sesión iniciada como $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Sesión no iniciada';

  @override
  String get waypointNameHint => 'p. ej. Fondeadero, Puerto...';

  @override
  String waypointDefaultName(String time) {
    return 'Waypoint $time';
  }

  @override
  String get mobFullName => 'Hombre al agua';

  @override
  String get maydayCardShort => 'Tarjeta\nMayday';

  @override
  String get morseInputHint => 'Introduzca el texto...';

  @override
  String get morseSosTitle => 'SOS – SEÑAL DE SOCORRO';

  @override
  String get morseSosCopied => 'SOS copiado';

  @override
  String intervalSeconds(int n) {
    return '$n s';
  }

  @override
  String intervalMinutes(int n) {
    return '$n min';
  }

  @override
  String intervalHours(int n) {
    return '$n h';
  }

  @override
  String get aboutFeatureGps => 'Seguimiento GPS con entradas automáticas';

  @override
  String get aboutFeatureLogbook =>
      'Cuaderno de bitácora para chárteres de varios días';

  @override
  String get aboutFeatureMaps => 'Cartas náuticas sin conexión (OpenSeaMap)';

  @override
  String get aboutFeatureWeather => 'Meteorología marina (Open-Meteo)';

  @override
  String get aboutFeatureExport => 'Exportar PDF + GPX';

  @override
  String get aboutFeatureSafety => 'Briefing de seguridad y tarjeta Mayday';

  @override
  String get aboutAuthorLabel => 'Autor';

  @override
  String get aboutVersionLabel => 'Versión';

  @override
  String get aboutPlatformLabel => 'Plataforma';

  @override
  String cloudSignInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String cloudSignOutFailed(String error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get marineInstrumentsWifiNote =>
      'Solo funciona a través de la red WiFi del barco: el teléfono debe estar conectado a un gateway NMEA (Raymarine, Digital Yacht, Yacht Devices…). Sin WiFi la app usa el GPS del teléfono y la previsión meteorológica de internet.';

  @override
  String get interruptedVoyageTitle => 'El seguimiento se interrumpió';

  @override
  String interruptedVoyageBody(String time) {
    return 'La aplicación se cerró a las $time sin finalizar la travesía. ¿Continuar la misma travesía?';
  }

  @override
  String interruptedVoyageGap(String distance) {
    return 'Tu posición está a $distance NM del último punto registrado.';
  }

  @override
  String get interruptedVoyageAddGap => 'Sumar esta distancia a la travesía';

  @override
  String get interruptedVoyageResume => 'Continuar';

  @override
  String get batteryPromptTitle =>
      'Mantén la aplicación activa toda la travesía';

  @override
  String get batteryPromptBody =>
      'Android —sobre todo Honor, Huawei y Xiaomi— cierra las aplicaciones en segundo plano, lo que interrumpe el seguimiento a mitad de travesía.\n\nEn los ajustes de batería, permite que esta aplicación funcione sin restricciones. En Honor/Huawei añádela además a las aplicaciones protegidas y permite el inicio automático.';

  @override
  String get batteryPromptAction => 'Abrir ajustes';

  @override
  String get speed => 'Velocidad';

  @override
  String get dateFormatLabel => 'Formato de fecha';

  @override
  String get dateFormatByLanguage => 'Según el idioma de la app';

  @override
  String get crewCertTitle => 'Certificado de millas navegadas';

  @override
  String get crewCertVoyage => 'Travesía';

  @override
  String get crewCertArea => 'Zona de navegación';

  @override
  String get crewCertDayMiles => 'Millas de día';

  @override
  String get crewCertNightMiles => 'Millas de noche';

  @override
  String get crewCertNightHours => 'Horas nocturnas';

  @override
  String get crewCertQualifications => 'Titulaciones';

  @override
  String get crewCertAssessment => 'Valoración del patrón';

  @override
  String get crewCertStamp => 'Sello';

  @override
  String get crewCertHashCoverage =>
      'La huella cubre el resumen de la travesía y la valoración de la tripulación.';

  @override
  String get crewSkillHelming => 'Timonear';

  @override
  String get crewSkillNavigation => 'Navegación';

  @override
  String get crewSkillHarbour => 'Maniobras en puerto';

  @override
  String get crewSkillTeamwork => 'Trabajo en equipo';

  @override
  String get crewSkillNightSailing => 'Navegación nocturna';

  @override
  String get crewCertExport => 'Exportar certificados';

  @override
  String get crewCertNoteHint => 'Valoración escrita (opcional)';

  @override
  String get crewCertNoCrew =>
      'Esta travesía no tiene tripulación. Añádela en la ficha de la travesía.';

  @override
  String get crewCertNotRated => 'sin valorar';

  @override
  String get crewCertShared => 'Certificados creados';

  @override
  String get more => 'Más';

  @override
  String get crewCertSkipperRates =>
      'El patrón valora a la tripulación y no es valorado. Aun así recibe su certificado de millas.';

  @override
  String get crewCertVesselSize => 'Dimensiones del barco';

  @override
  String get crewCertVesselRegistration => 'Matrícula';

  @override
  String get crewCertWaters => 'Aguas';

  @override
  String get crewCertWatersTidal => 'con marea';

  @override
  String get crewCertWatersNonTidal => 'sin marea';

  @override
  String get crewCertIdDocument => 'Número de pasaporte / DNI';

  @override
  String get crewCertDaysAtSea => 'Días en el mar';

  @override
  String get crewCertTotal => 'Total';

  @override
  String get crewCertWatersLabel => 'Tipo de aguas';

  @override
  String get bearingTakeSight => 'Tomar demora';

  @override
  String bearingSaved(String bearing) {
    return 'Demora $bearing guardada';
  }

  @override
  String get bearingNoPosition =>
      'Sin GPS no se puede determinar un punto desconocido. Cambia a «Mi situación»: la situación por demoras a puntos conocidos no necesita GPS.';

  @override
  String get bearingSaveFailed => 'No se pudo guardar la demora';

  @override
  String get bearingLabelHint => '¿Qué estás demorando? (opcional)';

  @override
  String bearingDeclinationApplied(String value) {
    return 'Declinación $value';
  }

  @override
  String get bearingDeclinationExpired =>
      'El modelo magnético ha caducado: la declinación es una estimación';

  @override
  String get bearingsLayer => 'Demoras';

  @override
  String get bearingsTitle => 'Demoras';

  @override
  String get bearingsClearAll => 'Ocultar todas del mapa';

  @override
  String get bearingsClearConfirm =>
      '¿Ocultar todas las demoras del mapa? Las líneas y la situación por demoras desaparecen del mapa, pero se quedan en el diario.';

  @override
  String get bearingsEmpty =>
      'Aún no hay demoras. Apunta el teléfono a un objeto y pulsa Tomar demora.';

  @override
  String get bearingsDeleteDayConfirm =>
      'Todas las demoras de este día se eliminarán definitivamente, también de la exportación a PDF. Esta acción no se puede deshacer.';

  @override
  String bearingFixFrom(int count) {
    return 'Situación a partir de $count demoras';
  }

  @override
  String bearingFixWeak(String angle) {
    return 'Situación débil: las líneas se cortan solo a $angle';
  }

  @override
  String bearingFixOffGps(String distance) {
    return 'Diferencia con el GPS: $distance';
  }

  @override
  String get bearingTrueLabel => 'verdadera';

  @override
  String get bearingMagneticLabel => 'magnética';

  @override
  String bearingUncertaintyNote(String deg) {
    return 'El cono muestra la incertidumbre de ±$deg de un compás de teléfono.';
  }

  @override
  String get bearingPdfSection => 'Demoras';

  @override
  String get bearingPdfObject => 'Objeto';

  @override
  String get bearingPdfBearing => 'Demora verdadera';

  @override
  String get bearingModeResection => 'Mi situación';

  @override
  String get bearingModeObject => 'Punto desconocido';

  @override
  String get bearingModeResectionHint =>
      'Toma demora a 2–3 puntos conocidos de la carta. No hace falta GPS.';

  @override
  String get bearingModeObjectHint =>
      'Toma demora al mismo punto desde 2–3 lugares distintos. Hace falta GPS.';

  @override
  String get bearingPickTarget => 'Elige el punto a demorar';

  @override
  String get bearingNeedsTarget =>
      'Elige primero un punto conocido, luego toma la demora';

  @override
  String get bearingNeedsObject =>
      'Primero nombra el punto que estás demorando';

  @override
  String get bearingNewObject => 'Nuevo punto…';

  @override
  String get bearingObjectName => 'Nombre del punto (p. ej. roca desconocida)';

  @override
  String get bearingOpenObjects => 'Puntos en determinación';

  @override
  String bearingSightCount(int count) {
    return '$count demoras';
  }

  @override
  String get bearingSameTargetHint =>
      'El mismo punto que antes: la situación por demoras necesita otro.';

  @override
  String get bearingShortBaselineHint =>
      'Base corta: desplázate y vuelve a demorar.';

  @override
  String get bearingMovedHint =>
      'El barco se movió entre demoras: la situación por demoras supone que está parado.';

  @override
  String get bearingNeedsSecondSight =>
      'Una demora más a otro punto y saldrá la situación.';

  @override
  String get bearingMyPositionFix => 'Mi situación';

  @override
  String get bearingObjectFix => 'Punto determinado';

  @override
  String get bearingSaveObjectAsWaypoint => 'Guardar como waypoint';

  @override
  String bearingObjectSaved(String name) {
    return '$name guardado como waypoint';
  }

  @override
  String get bearingDeclinationFromTarget =>
      'Declinación calculada en la posición del punto demorado';

  @override
  String get bearingResectionSection =>
      'Situación por demoras a puntos conocidos';

  @override
  String get bearingObjectSection => 'Determinación de puntos desconocidos';

  @override
  String get bearingPdfMark => 'Punto demorado';

  @override
  String get bearingPdfResult => 'Resultado';

  @override
  String get bearingStartNew => 'Empezar una demora nueva';

  @override
  String get bearingHideFromMap => 'Ocultar del mapa';
}
