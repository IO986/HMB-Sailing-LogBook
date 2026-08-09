// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get poiTypeAnchorage => 'Ancoraggio';

  @override
  String get poiTypeMarina => 'Marina';

  @override
  String get poiTypeFuel => 'Stazione di rifornimento';

  @override
  String get poiTypeHarbour => 'Porto';

  @override
  String get poiVhfChannel => 'Canale VHF';

  @override
  String get poiPhone => 'Telefono';

  @override
  String get poiWebsite => 'Sito web';

  @override
  String get poiEmail => 'E-mail';

  @override
  String get poiCapacity => 'Capienza';

  @override
  String get poiServices => 'Servizi';

  @override
  String get poiSaveAsWaypoint => 'Salva come waypoint';

  @override
  String poiWaypointSaved(String name) {
    return 'Waypoint \"$name\" salvato';
  }

  @override
  String get poiSource => 'Fonte: OpenStreetMap';

  @override
  String get mapLayerSatellite => 'Satellite';

  @override
  String get mapLayerMap => 'Mappa';

  @override
  String get mapLayers => 'Livelli';

  @override
  String get mapSeamarks => 'Segnalamenti marittimi';

  @override
  String get mapHarbours => 'Porti e ancoraggi';

  @override
  String get mapZoomInForPois => 'Ingrandisci per caricare porti e ancoraggi';

  @override
  String get mapRainRadar => 'Radar delle precipitazioni';

  @override
  String get mapOceanCurrentsTooltip =>
      'Correnti oceaniche (tieni premuto per l\'elenco)';

  @override
  String get mapCurrentForecast => 'Corrente marina — previsione (nodi)';

  @override
  String get mapTools => 'Strumenti';

  @override
  String get mapVoyageOverview => 'Panoramica della navigazione';

  @override
  String get mapRuler => 'Righello / rotta';

  @override
  String get mapDownloadOffline => 'Scarica l\'area offline';

  @override
  String get mapGpsDisabled => 'Il GPS è disattivato';

  @override
  String get mapLocationDenied => 'Posizione non consentita';

  @override
  String get mapFollowGps => 'Segui GPS';

  @override
  String mapAreaTooLarge(int count) {
    return 'L\'area è troppo grande ($count tessere). Ingrandisci e riprova.';
  }

  @override
  String get mapLivePreview => 'In diretta (tracciamento in corso)';

  @override
  String get mapWholeVoyage => 'Intera navigazione';

  @override
  String get offlineSheetTitle => 'Mappa offline dell\'area visibile';

  @override
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb) {
    return 'Mappa + segnalamenti marittimi, zoom $minZ–$maxZ, $tiles tessere (~$mb MB). Le aree scaricate funzionano in mare senza segnale.';
  }

  @override
  String offlineDone(int n) {
    return 'Fatto — $n tessere salvate';
  }

  @override
  String offlineDoneErrors(int n) {
    return 'Completato con errori: $n tessere non scaricate';
  }

  @override
  String get downloadAction => 'Scarica';

  @override
  String get rulerTapHint => 'Tocca i punti sulla mappa';

  @override
  String get mapEntryPhoto => 'Registrazione fotografica';

  @override
  String get mapEntryNote => 'Annotazione di bordo';

  @override
  String get openSettingsAction => 'Apri impostazioni';

  @override
  String get morseConverter => 'Convertitore testo → Morse';

  @override
  String saveError(String error) {
    return 'Errore durante il salvataggio: $error';
  }

  @override
  String get languageName => 'Italiano';

  @override
  String get navMap => 'Mappa';

  @override
  String get navTracking => 'Tracciamento';

  @override
  String get navLogbook => 'Giornale';

  @override
  String get navWeather => 'Meteo';

  @override
  String get navSafety => 'Sicurezza';

  @override
  String get navCompass => 'Bussola';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navCustomizeTitle => 'Menu inferiore';

  @override
  String get navCustomizeHint =>
      'Premi e trascina per riordinare le icone. Usa l\'interruttore per nascondere una scheda dal menu inferiore — Impostazioni è sempre visibile.';

  @override
  String get navAlwaysShown => 'Sempre visibile';

  @override
  String get navIconSizeLabel => 'Dimensione delle icone';

  @override
  String get navOpenHiddenTitle => 'Apri le schede nascoste';

  @override
  String get cameraPermissionDenied =>
      'Accesso alla fotocamera negato. Abilitalo nelle impostazioni del dispositivo.';

  @override
  String get cameraUnavailable => 'Fotocamera non disponibile';

  @override
  String get compassCalibrationNote =>
      'Bussola magnetica. La precisione può risentire di metalli o dispositivi elettronici vicini. Se non è calibrata, muovi il dispositivo a forma di otto.';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get save => 'Salva';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Chiudi';

  @override
  String get retry => 'Riprova';

  @override
  String get share => 'Condividi';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get error => 'Errore';

  @override
  String errorMsg(String msg) {
    return 'Errore: $msg';
  }

  @override
  String get pressBackToExit => 'Premi di nuovo Indietro per uscire';

  @override
  String get trackingRunningTitle => 'Tracciamento in corso';

  @override
  String get trackingRunningContent =>
      'Il tracciamento è attivo. Cosa vuoi fare?';

  @override
  String get stopAndExit => 'Ferma ed esci';

  @override
  String get keepRunning => 'Continua il tracciamento';

  @override
  String get marineInstrumentsTitle => 'Strumenti di bordo';

  @override
  String get marineInstrumentsPrompt =>
      'Vuoi collegare l\'app agli strumenti di bordo (ad es. Raymarine tramite gateway WiFi)? L\'app leggerà allora GPS, vento, profondità e altri dati direttamente dalla barca.\n\nSenza collegamento verranno usati il GPS del telefono e le previsioni meteo da internet – puoi cambiarlo in qualsiasi momento nelle Impostazioni.';

  @override
  String get notNow => 'Non ora';

  @override
  String get setupConnection => 'Configura la connessione';

  @override
  String get autoDetectAction => 'Rilevamento automatico';

  @override
  String get autoDetectWifiHintTitle => 'Collegati prima al WiFi della barca';

  @override
  String get autoDetectWifiHintBody =>
      'Verifica nelle Impostazioni del telefono → WiFi di essere collegato alla rete degli strumenti di bordo (ad es. RayNet, WiFi-1). L\'app proverà poi a trovare automaticamente il gateway su quella rete.';

  @override
  String get openWifiSettings => 'Impostazioni WiFi';

  @override
  String get continueAction => 'Continua';

  @override
  String get autoDetecting => 'Ricerca degli strumenti sulla rete WiFi…';

  @override
  String get autoDetectFailed =>
      'Nessun gateway trovato nelle vicinanze. Verifica di essere sulla rete WiFi della barca, oppure inserisci l\'IP manualmente nelle Impostazioni.';

  @override
  String autoDetectSuccess(String host) {
    return 'Collegato a $host';
  }

  @override
  String get guidePromptTitle => 'Sei nuovo? Guida rapida';

  @override
  String get guidePromptBody =>
      'L\'app contiene una breve guida per l\'utente – mappa, giornale di bordo, meteo, lista di sicurezza e altro. Vuoi darle un\'occhiata ora? La ritrovi sempre in Impostazioni → Guida per l\'utente.';

  @override
  String get guidePromptAction => 'Mostra la guida';

  @override
  String get notifPromptTitle => 'Consentire le notifiche?';

  @override
  String get notifPromptBody =>
      'Durante il tracciamento di una navigazione, una notifica resta nella barra di stato e sulla schermata di blocco — così vedi che il tracciamento è attivo e vi accedi rapidamente. Senza autorizzazione il sistema può limitare il tracciamento in background.';

  @override
  String get notifPromptAllow => 'Consenti';

  @override
  String get trackingActiveTitle => 'Tracciamento attivo';

  @override
  String get trackingTitle => 'Tracciamento';

  @override
  String get waitingForGps => 'In attesa del GPS...';

  @override
  String get gpsUnavailable => 'GPS non disponibile';

  @override
  String get lastKnownPosition => 'Ultima posizione nota';

  @override
  String get accuracy => 'Precisione';

  @override
  String get logbookBtn => 'Giornale';

  @override
  String get stop => 'Ferma';

  @override
  String get stopTrackingDay => 'Fermare il tracciamento?';

  @override
  String get startVoyage => 'Inizia la navigazione';

  @override
  String get starting => 'Avvio in corso...';

  @override
  String get newVoyage => 'Nuova navigazione';

  @override
  String get multiday => 'Più giorni';

  @override
  String get standalone => 'Singola';

  @override
  String get voyageName => 'Nome della navigazione';

  @override
  String get voyageNameOptional => 'Nome (facoltativo)';

  @override
  String get voyageNameHint => 'ad es. Giro in baia';

  @override
  String get existingVoyage => 'Continua una navigazione esistente';

  @override
  String get newVoyageDropdown => '— Nuova navigazione —';

  @override
  String get firstVoyageHint => 'Prima navigazione – compila i dati di base:';

  @override
  String get briefingRequiredHint =>
      'Il tracciamento può essere avviato solo una volta completato il Briefing di sicurezza per questa navigazione.';

  @override
  String get briefingPending => 'BS richiesto';

  @override
  String get briefingPendingListWarning =>
      'Briefing di sicurezza non completato – il tracciamento non può ancora partire';

  @override
  String get estimatedDays => 'Numero previsto di giorni:';

  @override
  String get logFrequency => 'Frequenza delle annotazioni';

  @override
  String get startTracking => 'Avvia il tracciamento';

  @override
  String get trackingInProgress => 'Traccia la tua navigazione';

  @override
  String dayNofTotal(int n, int total) {
    return 'Giorno $n di $total';
  }

  @override
  String get newDay => '(nuovo giorno)';

  @override
  String get endVoyageTitle => 'Terminare la navigazione?';

  @override
  String get endVoyageContent =>
      'Hai raggiunto l\'ultimo giorno previsto della navigazione.\n\nLa navigazione proseguirà domani?';

  @override
  String get decideLayer => 'Decidi più tardi';

  @override
  String get continuesTomorrow => 'Prosegue domani';

  @override
  String get endVoyage => 'Termina la navigazione';

  @override
  String get newMultidayVoyage => 'Nuova navigazione di più giorni';

  @override
  String get deleteCharterTitle => 'Eliminare il charter?';

  @override
  String get deleteCharterContent =>
      'Tutti i giorni e le annotazioni saranno eliminati.';

  @override
  String get cannotDeleteWhileTracking =>
      'Non è possibile eliminare una navigazione mentre il tracciamento è attivo.';

  @override
  String get noVoyages => 'Nessuna navigazione';

  @override
  String get createFirstCharter => 'Crea il tuo primo charter';

  @override
  String get briefingDone => 'Briefing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Navigazione non trovata';

  @override
  String get unknownVessel => 'Imbarcazione sconosciuta';

  @override
  String get captain => 'Skipper';

  @override
  String get crew => 'Equipaggio';

  @override
  String get total => 'Totale';

  @override
  String voyageDaysCount(int n) {
    return 'Giorni di navigazione ($n)';
  }

  @override
  String get bulkDelete => 'Eliminazione multipla';

  @override
  String get noDays =>
      'Nessun giorno.\nAvvia il tracciamento e il primo giorno sarà creato automaticamente.';

  @override
  String get deleteDayTitle => 'Eliminare il giorno?';

  @override
  String deleteDayContent(String day) {
    return 'Tutte le annotazioni del $day saranno eliminate.';
  }

  @override
  String get exportPdf => 'Esporta PDF';

  @override
  String get selectDaysTitle => 'Seleziona i giorni da eliminare';

  @override
  String deleteCount(int n) {
    return 'Elimina ($n)';
  }

  @override
  String get safety => 'Sicurezza';

  @override
  String get mobHoldToActivate => 'Tieni premuto per attivare';

  @override
  String get mobActive => '⚠️ MOB ATTIVO';

  @override
  String get mobTime => 'Tempo';

  @override
  String get mobDistance => 'Distanza';

  @override
  String get mobDirection => 'Direzione';

  @override
  String get navigateToMob => 'Naviga verso il MOB';

  @override
  String get gpsPositionNotAvailable => 'Posizione GPS non disponibile!';

  @override
  String get anchorAlarm => 'Allarme ancora';

  @override
  String get drifting => 'ARA';

  @override
  String get anchorRadiusLabel => 'Raggio di ancoraggio';

  @override
  String get activate => 'Attiva';

  @override
  String get deactivate => 'Disattiva';

  @override
  String get safetyBriefingCard => 'Briefing di sicurezza';

  @override
  String get maydayCard => 'Scheda Mayday';

  @override
  String get yachtHandover => 'Riconsegna dello yacht';

  @override
  String get gearList => 'Lista dell\'attrezzatura';

  @override
  String get pdfEntriesSection => 'Annotazioni di bordo';

  @override
  String get pdfSkipperMessage => 'Relazione dello skipper';

  @override
  String get pdfWeatherSection => 'Meteo';

  @override
  String get pdfDaySummary => 'Riepilogo giornaliero';

  @override
  String get pdfDaysOverview => 'Panoramica dei giorni';

  @override
  String get pdfVoyageSummary => 'Riepilogo della navigazione';

  @override
  String get pdfCrewSection => 'Equipaggio';

  @override
  String get pdfSignatures => 'Firme';

  @override
  String get pdfCrewSignatures => 'Firme dell\'equipaggio';

  @override
  String get pdfSkipperSignature => 'Firma dello skipper';

  @override
  String get pdfSkipperLicences => 'Skipper – abilitazioni';

  @override
  String get pdfSafetyBriefing => 'Briefing di sicurezza';

  @override
  String get pdfChecklistSection => 'Lista di controllo';

  @override
  String get pdfMoreNotes => 'Note aggiuntive';

  @override
  String get pdfIntegrityCheck => 'Verifica di integrità del documento';

  @override
  String get pdfHandoverTitle => 'Verbale di riconsegna';

  @override
  String get pdfMilesTitle => 'Certificato delle miglia percorse';

  @override
  String get pdfDeparture => 'Partenza';

  @override
  String get pdfArrival => 'Arrivo';

  @override
  String get pdfTotalLabel => 'Totale';

  @override
  String get pdfDayCount => 'Giorni';

  @override
  String get pdfEngineHours => 'Ore motore';

  @override
  String get pdfFuelLabel => 'Carburante';

  @override
  String get pdfWaterLabel => 'Acqua';

  @override
  String get pdfVesselLabel => 'Imbarcazione';

  @override
  String get pdfSkipperLabel => 'Skipper';

  @override
  String get pdfDateLabel => 'Data';

  @override
  String get pdfColFrom => 'Da';

  @override
  String get pdfColTo => 'A';

  @override
  String get pdfColEntriesShort => 'Annotaz.';

  @override
  String get pdfColTimeUtc => 'Ora UTC';

  @override
  String get pdfColWind => 'Vento';

  @override
  String get pdfColPropulsion => 'Propulsione';

  @override
  String get pdfColWeatherShort => 'Meteo';

  @override
  String get pdfColNote => 'Nota';

  @override
  String get pdfColDay => 'Giorno';

  @override
  String get pdfColItem => 'Voce';

  @override
  String get pdfColStatus => 'Stato';

  @override
  String get pdfColNotePosition => 'Nota / posizione';

  @override
  String get pdfColPhoto => 'Foto';

  @override
  String get pdfColDateRange => 'Data da-a';

  @override
  String get pdfColArea => 'Zona';

  @override
  String get pdfColRole => 'Ruolo';

  @override
  String get pdfNoData => 'Nessun dato';

  @override
  String get pdfMapUnavailable => 'Mappa GPS non disponibile';

  @override
  String get pdfUnsigned => 'Non firmato';

  @override
  String get pdfNoSignatures => 'Nessuna firma';

  @override
  String get pdfSha256Label => 'Digest SHA-256 dei dati del giornale:';

  @override
  String get pdfVerifyQr => 'QR di verifica';

  @override
  String get pdfSbLifejackets => 'Giubbotti di salvataggio – posizione e uso';

  @override
  String get pdfSbLifebuoy => 'Salvagente anulare e procedura MOB';

  @override
  String get pdfSbFlares => 'Razzi di segnalazione – tipi e uso';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – attivazione';

  @override
  String get pdfSbVhf => 'Radio VHF – canale 16, procedura Mayday';

  @override
  String get pdfSbExtinguisher => 'Estintore – posizione e uso';

  @override
  String get pdfSbFirstAid => 'Cassetta di pronto soccorso – posizione';

  @override
  String get pdfSbEngineStop => 'Arresto di emergenza del motore';

  @override
  String get pdfSbLeaks => 'Perdite – acqua, gas';

  @override
  String get pdfSbAnchor => 'Ancora e catena – procedura di ancoraggio';

  @override
  String get pdfSbRules => 'Regole di bordo';

  @override
  String get pdfSbEmergencyContacts => 'Contatti di emergenza e VHF 16';

  @override
  String get pdfBriefingDeclaration =>
      'Tutti i membri dell\'equipaggio sono stati informati sulle regole di sicurezza, le hanno comprese e lo confermano con la firma.';

  @override
  String get pdfHashCoverage =>
      'Il digest copre il nome della navigazione, l\'imbarcazione, l\'equipaggio e ogni annotazione (ora UTC, GPS, velocità, rotta). Qualsiasi modifica dei dati cambia il digest.';

  @override
  String get pdfForCharterCompany => 'Per la società di charter';

  @override
  String get dutyRoster => 'Equipaggio di guardia';

  @override
  String get dutyStartAction => 'Monta di guardia';

  @override
  String get dutyEndAction => 'Termina';

  @override
  String get dutyStartTitle => 'Chi monta di guardia?';

  @override
  String get dutyRunningChip => 'DI GUARDIA';

  @override
  String dutySince(String time) {
    return 'dalle $time';
  }

  @override
  String dutyElapsed(int h, int m) {
    return '$h h $m min';
  }

  @override
  String get dutyNobodyOnDuty => 'Nessuno è di guardia';

  @override
  String get dutyInspectionView => 'Mostra per il controllo';

  @override
  String get dutyRosterHistory => 'Turni di guardia';

  @override
  String get dutyAddRetrospective => 'Aggiungi una guardia passata';

  @override
  String get dutyEditTitle => 'Modifica la guardia';

  @override
  String get dutyDeleteTitle => 'Eliminare la guardia?';

  @override
  String dutyDeleteConfirm(String name) {
    return 'La registrazione della guardia di $name sarà eliminata.';
  }

  @override
  String get dutyNoCrewDefined =>
      'Nessun equipaggio definito per questa navigazione';

  @override
  String get dutyDefineCrew => 'Aggiungi equipaggio';

  @override
  String get dutyErrorEndBeforeStart =>
      'La fine deve essere successiva all\'inizio.';

  @override
  String dutyErrorOverlap(String name) {
    return '$name è già di guardia in quell\'orario.';
  }

  @override
  String get dutyErrorFutureStart => 'L\'inizio non può essere nel futuro.';

  @override
  String get dutyNoteLabel => 'Nota';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'Di guardia da $hours h — è rimasta aperta?';
  }

  @override
  String get dutyFrom => 'Da';

  @override
  String get dutyTo => 'A';

  @override
  String get dutyToOngoing => '— ancora di guardia';

  @override
  String get dutySelectPerson => 'Seleziona un membro dell\'equipaggio';

  @override
  String get dutyNoRecords => 'Nessuna guardia registrata finora';

  @override
  String get logDutySection => 'Equipaggio di guardia';

  @override
  String get logDutyStillRunning => 'in corso';

  @override
  String get logEventAnchorDropped => 'Ancora data';

  @override
  String get logEventAnchorRaised => 'Ancora salpata';

  @override
  String get logEventDriftOut => 'Ancora che ara – perimetro superato';

  @override
  String get logEventDriftIn => 'Ancora che ara – imbarcazione rientrata';

  @override
  String logEventDutyStart(String name) {
    return 'Monta di guardia: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Smonta di guardia: $name';
  }

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Contatti di emergenza';

  @override
  String get backToToc => 'Torna all\'indice';

  @override
  String get briefingComplete => 'Briefing completato';

  @override
  String get updateByPosition => 'Aggiorna in base alla posizione';

  @override
  String get detectedByGps => 'rilevato tramite GPS';

  @override
  String get locationUnavailable =>
      '📍 Posizione non disponibile – mostrati i contatti globali';

  @override
  String get detectingLocation => 'Rilevamento della posizione...';

  @override
  String get tapToCall => 'Tocca per chiamare';

  @override
  String cannotCall(String name) {
    return 'Impossibile chiamare: $name';
  }

  @override
  String get vhfChannel16 => 'Canale VHF 16 – usa la radio di bordo';

  @override
  String get hmbHandbook => 'Manuale HMB';

  @override
  String get checkInLabel => 'Check-in (presa in consegna della barca)';

  @override
  String get checkOutLabel => 'Check-out (riconsegna della barca)';

  @override
  String get charterCheckCard => 'Charter';

  @override
  String get weatherTitle => 'Meteo e mare';

  @override
  String get updateForecast => 'Aggiorna le previsioni';

  @override
  String get gpsNotAvailableTracking =>
      'GPS non disponibile – attiva il tracciamento';

  @override
  String get downloadingForecast => 'Download delle previsioni...';

  @override
  String get loadingForecast => 'Caricamento delle previsioni...';

  @override
  String get noConnection => 'Nessuna connessione disponibile';

  @override
  String get pressRefreshWhenOnline => 'Premi aggiorna quando sei online';

  @override
  String get noWeatherData => 'Nessun dato meteo';

  @override
  String get forecastAutoDownload =>
      'Le previsioni verranno scaricate automaticamente all\'avvio del tracciamento, oppure premi Aggiorna.';

  @override
  String get enableGpsFirst => 'Attiva prima il GPS / il tracciamento';

  @override
  String get downloadForecast => 'Scarica le previsioni';

  @override
  String downloadError(String error) {
    return 'Errore di download: $error';
  }

  @override
  String get liveInstrumentData => 'Dati degli strumenti di bordo in diretta';

  @override
  String get windRelative => 'Vento (rel.)';

  @override
  String get windTrue => 'Vento (reale)';

  @override
  String get depthLabel => 'Profondità';

  @override
  String get waterTempLabel => 'Temp. dell\'acqua';

  @override
  String get courseTrue => 'Rotta (vera)';

  @override
  String get courseMag => 'Rotta (magn.)';

  @override
  String get engineLabel => 'Motore';

  @override
  String get wavesLabel => 'Onde';

  @override
  String get pressureLabel => 'Pressione';

  @override
  String get airTempLabel => 'Aria';

  @override
  String get waterLabel => 'Acqua';

  @override
  String get wind24h => 'Vento – 3 giorni';

  @override
  String get waves24h => 'Onde – 3 giorni';

  @override
  String get hourlyForecast => 'Previsioni per 3 giorni';

  @override
  String get dailyForecast => 'Temperatura giornaliera';

  @override
  String get timeCol => 'Ora';

  @override
  String get windCol => 'Vento';

  @override
  String get wavesCol => 'Onde';

  @override
  String get rainCol => 'Pioggia';

  @override
  String get beaufort0 => 'Calma';

  @override
  String get beaufort1 => 'Bava di vento';

  @override
  String get beaufort2 => 'Brezza leggera';

  @override
  String get beaufort3 => 'Brezza tesa';

  @override
  String get beaufort4 => 'Vento moderato';

  @override
  String get beaufort5 => 'Vento teso';

  @override
  String get beaufort6 => 'Vento fresco';

  @override
  String get beaufort7 => 'Vento forte';

  @override
  String get beaufort8 => 'Burrasca';

  @override
  String get beaufort9 => 'Burrasca forte';

  @override
  String get beaufort10 => 'Tempesta';

  @override
  String get beaufort11 => 'Tempesta violenta';

  @override
  String get beaufort12 => 'Uragano';

  @override
  String get sunAndMoonCard => 'Sole e Luna';

  @override
  String get sunriseLabel => 'Alba';

  @override
  String get sunsetLabel => 'Tramonto';

  @override
  String get moonPhaseLabel => 'Fase lunare';

  @override
  String get moonIlluminationLabel => 'Illuminata';

  @override
  String get moonPhaseNew => 'Luna nuova';

  @override
  String get moonPhaseWaxingCrescent => 'Luna crescente';

  @override
  String get moonPhaseFirstQuarter => 'Primo quarto';

  @override
  String get moonPhaseWaxingGibbous => 'Gibbosa crescente';

  @override
  String get moonPhaseFull => 'Luna piena';

  @override
  String get moonPhaseWaningGibbous => 'Gibbosa calante';

  @override
  String get moonPhaseLastQuarter => 'Ultimo quarto';

  @override
  String get moonPhaseWaningCrescent => 'Luna calante';

  @override
  String get noSunMoonGps =>
      'Per alba e tramonto è necessaria la posizione GPS';

  @override
  String get oceanCurrentsTitle => 'Correnti oceaniche';

  @override
  String get oceanCurrentsTooltip => 'Correnti oceaniche';

  @override
  String get oceanCurrentsDisclaimer =>
      'Dati puramente indicativi (direzione/velocità tipiche dalle carte pilota) — non adatti alla navigazione di precisione; le correnti variano con le stagioni.';

  @override
  String get tideCardTitle => 'Marea';

  @override
  String get nextHighTideLabel => 'Prossima alta marea';

  @override
  String get nextLowTideLabel => 'Prossima bassa marea';

  @override
  String get noTideData => 'Nessun dato di marea';

  @override
  String get downloadTides => 'Scarica le previsioni di marea';

  @override
  String get downloadingTides => 'Download delle previsioni di marea...';

  @override
  String get tideMslWarning =>
      'Le altezze sono riferite al livello medio del mare, non allo zero idrografico — non usarle mai per la profondità sotto la chiglia.';

  @override
  String get tideNoCoverage =>
      'Nessun dato di marea per questa posizione — è fuori dall\'area delle previsioni marine.';

  @override
  String get tideDownloadFailed =>
      'Non è stato possibile scaricare le previsioni di marea. Controlla la connessione e riprova.';

  @override
  String get tideForecastExpired =>
      'Le previsioni di marea salvate sono scadute.';

  @override
  String tideForecastFarAway(int km) {
    return 'Le previsioni sono state scaricate a $km km da qui — riscaricale per questa posizione.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Scaricate il $when — riscarica per le previsioni più recenti.';
  }

  @override
  String get oceanCurrentCardTitle => 'Corrente marina';

  @override
  String get oceanCurrentSetsToward => 'Diretta verso (velocità in nodi)';

  @override
  String get oceanCurrentNoCoverage =>
      'Nessun dato di corrente per questa posizione.';

  @override
  String get oceanCurrentUnavailable =>
      'Previsioni di corrente non disponibili — controlla la connessione.';

  @override
  String get tideOtherArea => 'Previsioni per un\'altra zona';

  @override
  String get tideAreaSearchLabel => 'Porto, città o baia';

  @override
  String get tideAreaSearchHint => 'ad es. Trieste';

  @override
  String get tideAreaNoResults => 'Nessun risultato — prova con un altro nome.';

  @override
  String tideForecastForArea(String place) {
    return 'Previsioni per $place';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get measurementUnits => 'Unità di misura';

  @override
  String get temperature => 'Temperatura';

  @override
  String get depthWaves => 'Profondità / onde';

  @override
  String get wind => 'Vento';

  @override
  String get language => 'Lingua';

  @override
  String get appLanguage => 'Lingua dell\'app';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get displaySettings => 'Visualizzazione';

  @override
  String get nightMode => 'Modalità notturna';

  @override
  String get nightModeDesc => 'Filtro rosso per preservare la visione notturna';

  @override
  String get aboutApp => 'Informazioni';

  @override
  String get backupSection => 'Backup dei dati';

  @override
  String get exportBackup => 'Esporta il backup';

  @override
  String get exportBackupDesc =>
      'Salva l\'intero giornale (navigazioni, annotazioni, impostazioni) in un unico file';

  @override
  String get restoreBackup => 'Ripristina da backup';

  @override
  String get restoreBackupDesc =>
      'Sostituisce i dati attuali con il contenuto del file di backup selezionato';

  @override
  String get restoreBlockedTrackingTitle => 'Il tracciamento GPS è in corso';

  @override
  String get restoreBlockedTrackingBody =>
      'Ferma il tracciamento della navigazione prima di ripristinare un backup.';

  @override
  String get restoreSchemaTooNewTitle =>
      'Il backup proviene da una versione più recente';

  @override
  String get restoreSchemaTooNewBody =>
      'Questo backup è stato creato con una versione dell\'app più recente di quella installata. Aggiorna prima l\'app.';

  @override
  String get restoreConfirmTitle => 'Ripristinare da backup?';

  @override
  String get restoreConfirmBody =>
      'I dati attuali saranno sostituiti dal contenuto del backup. Prima verrà creato automaticamente un backup di sicurezza dello stato attuale.';

  @override
  String get restoreSuccess =>
      'I dati sono stati ripristinati correttamente dal backup.';

  @override
  String get restoreInvalidFile =>
      'Il file selezionato non è un backup valido di HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Libretto delle miglia';

  @override
  String get totalNm => 'Totale NM';

  @override
  String get daysAtSea => 'Giorni in mare';

  @override
  String get voyageCount => 'Numero di navigazioni';

  @override
  String get nightHoursLabel => 'Ore notturne';

  @override
  String get byYear => 'Per anno';

  @override
  String get byVessel => 'Per imbarcazione';

  @override
  String get addHistoricalVoyage => 'Aggiungi una navigazione passata';

  @override
  String get editHistoricalVoyage => 'Modifica la navigazione passata';

  @override
  String get deleteHistoricalVoyageConfirm =>
      'Eliminare questa navigazione passata?';

  @override
  String get manualEntryExplanation =>
      '* inserimento manuale (inserito a mano)';

  @override
  String get roleLabel => 'Ruolo a bordo';

  @override
  String get roleSkipper => 'Skipper';

  @override
  String get roleCoSkipper => 'Co-skipper';

  @override
  String get roleCrew => 'Equipaggio';

  @override
  String get areaLabel => 'Zona / rotta';

  @override
  String get distanceNmLabel => 'Distanza (NM)';

  @override
  String get daysCountLabel => 'Numero di giorni';

  @override
  String get milesCertificateTitle => 'Certificato delle miglia percorse';

  @override
  String get logbookRecordTitle => 'Annotazione di bordo';

  @override
  String get logbookTrackedHint =>
      'Date, miglia, zona e ruolo sono calcolati dal tracciamento/importazione.';

  @override
  String get vesselFlag => 'Bandiera di immatricolazione';

  @override
  String get captainFirstName => 'Nome dello skipper';

  @override
  String get captainLastName => 'Cognome dello skipper';

  @override
  String get captainQualification => 'Massima abilitazione posseduta';

  @override
  String get logbookSignatureSection => 'Firma di conferma delle miglia';

  @override
  String get addSignature => 'Aggiungi la firma';

  @override
  String get filterAllYears => 'Tutti gli anni';

  @override
  String get filterCustomRange => 'Intervallo personalizzato';

  @override
  String get handoverMenuTitle => 'Verbale di riconsegna';

  @override
  String get checkInProtocol => 'Verbale di presa in consegna';

  @override
  String get checkOutProtocol => 'Verbale di riconsegna';

  @override
  String get nextStepLabel => 'Passo successivo';

  @override
  String get readyToTrackHint => 'Pronto per avviare il tracciamento';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Passo $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Briefing di\nsicurezza';

  @override
  String get handoverChecklistShort => 'Lista di\nriconsegna';

  @override
  String get safetyBriefingRefTitle => 'Briefing di sicurezza';

  @override
  String get handoverChecklistRefTitle => 'Lista di riconsegna';

  @override
  String get handoverDateTime => 'Data e ora';

  @override
  String get handoverLocation => 'Luogo (marina)';

  @override
  String get checklistItemOk => 'OK';

  @override
  String get checklistItemDamaged => 'Danneggiato';

  @override
  String get checklistItemMissing => 'Mancante';

  @override
  String get damagePosition => 'Posizione sulla barca';

  @override
  String get newDamageBadge => 'NUOVO DANNO';

  @override
  String get companySignatureSection =>
      'Firma del rappresentante della società di charter';

  @override
  String get companyRepName => 'Nome del rappresentante';

  @override
  String get companyNameLabel => 'Nome della società';

  @override
  String get protocolClosedNotice =>
      'Il verbale è chiuso (entrambe le parti hanno firmato) – sola lettura.';

  @override
  String get handoverCertTitle => 'Verbale di riconsegna dell\'imbarcazione';

  @override
  String get itemSails => 'Vele';

  @override
  String get itemRigging => 'Manovre';

  @override
  String get itemAnchorChain => 'Ancora e catena';

  @override
  String get itemNavInstruments => 'Strumenti di navigazione';

  @override
  String get itemLifeJackets => 'Giubbotti di salvataggio';

  @override
  String get itemRaft => 'Zattera di salvataggio';

  @override
  String get itemFirstAidKit => 'Cassetta di pronto soccorso';

  @override
  String get itemDinghyMotor => 'Tender e motore fuoribordo';

  @override
  String get itemLights => 'Luci';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Note aggiuntive';

  @override
  String get gpxImportTitle => 'Importazione GPX';

  @override
  String get gpxImportPickFile => 'Scegli il file GPX';

  @override
  String get gpxTracksFound => 'Tracce trovate';

  @override
  String get gpxWaypointsFound => 'Waypoint trovati';

  @override
  String get gpxAssignTarget => 'Assegna alla navigazione';

  @override
  String get gpxNewVoyage => 'Nuova navigazione';

  @override
  String get gpxImportButton => 'Importa';

  @override
  String get gpxImportSuccess => 'GPX importato correttamente.';

  @override
  String get connectionConnected => 'Collegato';

  @override
  String get connectionConnecting => 'Connessione in corso...';

  @override
  String get connectionError => 'Errore di connessione';

  @override
  String get connectionDisconnected =>
      'Disconnesso (si usa il GPS del telefono / le previsioni)';

  @override
  String get ipAddressLabel => 'Indirizzo IP del gateway';

  @override
  String get portLabel => 'Porta';

  @override
  String get autoConnectLabel => 'Connessione automatica all\'avvio';

  @override
  String get disconnect => 'Disconnetti';

  @override
  String get connect => 'Connetti';

  @override
  String get gatewayHint =>
      'Collega il telefono alla rete WiFi Raymarine (ad es. WiFi-1, RayNet). L\'IP da inserire NON è quello mostrato nelle impostazioni Raymarine — è l\'IP del gateway di quella rete WiFi. Lo trovi sul telefono: Impostazioni → WiFi → dettagli della rete → Gateway. La porta 2000 (TCP) è quella standard. Senza connessione l\'app usa automaticamente il GPS del telefono.';

  @override
  String connectedToHost(String host, int port) {
    return 'Collegato a $host:$port';
  }

  @override
  String get enterIpAddress => 'Inserisci l\'indirizzo IP del gateway';

  @override
  String connectionFailed(String error) {
    return 'Connessione non riuscita: $error';
  }

  @override
  String get liveWind => 'Vento';

  @override
  String get liveDepth => 'Profondità';

  @override
  String get liveWaterTemp => 'Temp. dell\'acqua';

  @override
  String get liveCompass => 'Bussola';

  @override
  String get liveEngine => 'Motore';

  @override
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Porta di ascolto';

  @override
  String get startListening => 'Avvia';

  @override
  String get stopListening => 'Ferma';

  @override
  String connectionListening(String port) {
    return 'In ascolto su UDP alla porta $port';
  }

  @override
  String udpHint(String port) {
    return 'Imposta il simulatore/gateway per inviare UDP all\'IP di questo telefono, porta $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'In ascolto sulla porta UDP $port';
  }

  @override
  String get dayNotFound => 'Giorno non trovato';

  @override
  String get saved => 'Salvato';

  @override
  String get trackingThisDay => 'Tracciamento in corso per questo giorno';

  @override
  String get trackingOtherDay => 'Tracciamento in corso per un altro giorno';

  @override
  String recordCount(int n) {
    return '$n annotazioni';
  }

  @override
  String get addManual => 'Aggiungi manualmente';

  @override
  String get noEntries => 'Nessuna annotazione';

  @override
  String get entriesAutoAdded =>
      'Le annotazioni vengono aggiunte automaticamente durante il tracciamento';

  @override
  String get deleteEntryTitle => 'Eliminare l\'annotazione?';

  @override
  String get autoRecord => 'Annotazione automatica';

  @override
  String get routeSection => 'Rotta';

  @override
  String get fromPort => 'Da';

  @override
  String get toPort => 'A';

  @override
  String get distance => 'Distanza';

  @override
  String get vessel => 'Imbarcazione';

  @override
  String get weatherSection => 'Meteo';

  @override
  String get morning => 'Mattina';

  @override
  String get noon => 'Mezzogiorno';

  @override
  String get evening => 'Sera';

  @override
  String get windDir => 'Direzione del vento';

  @override
  String get seaState => 'Stato del mare';

  @override
  String get waveHeight => 'Altezza delle onde';

  @override
  String get dailyNote => 'Diario giornaliero';

  @override
  String get dailyNoteHint =>
      'Descrizione della navigazione, momenti salienti, eventi della giornata...';

  @override
  String get seaCalm => 'Calmo';

  @override
  String get seaLight => 'Poco mosso';

  @override
  String get seaModerate => 'Mosso';

  @override
  String get seaRough => 'Agitato';

  @override
  String get seaStormy => 'Tempestoso';

  @override
  String get editEntry => 'Modifica l\'annotazione';

  @override
  String get newEntry => 'Nuova annotazione';

  @override
  String get sailMode => 'Modalità di navigazione';

  @override
  String get sailMain => 'Randa';

  @override
  String get navigationSection => 'Navigazione';

  @override
  String get latitude => 'Latitudine';

  @override
  String get longitude => 'Longitudine';

  @override
  String get weatherSeaSection => 'Meteo e mare';

  @override
  String get windSpeed => 'Vento';

  @override
  String get windDirection => 'Direzione';

  @override
  String get waveHeight2 => 'Altezza delle onde';

  @override
  String get engineSection => 'Motore e serbatoi';

  @override
  String get engineHours => 'Ore motore';

  @override
  String get fuel => 'Carburante';

  @override
  String get fuelLevel => 'Livello del carburante';

  @override
  String get waterLevel => 'Livello dell\'acqua';

  @override
  String get noteSection => 'Nota';

  @override
  String get noteHint =>
      'Condizioni di navigazione, eventi, cambio equipaggio...';

  @override
  String get quickPhotoLogTitle => 'Annotazione rapida';

  @override
  String get quickPhotoNoteHint => 'Che cos\'è? (facoltativo)';

  @override
  String get exportDayTitle => 'Esportazione del giorno';

  @override
  String get exportCharterTitle => 'Esportazione del charter';

  @override
  String get loadingData => 'Caricamento dei dati...';

  @override
  String get mapsReady => 'Mappe pronte – puoi esportare';

  @override
  String generatingMaps(int current, int total) {
    return 'Generazione delle anteprime delle mappe ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Esporta il giorno';

  @override
  String get exportCharterBtn => 'Esporta il charter';

  @override
  String get entriesLabel => 'Annotazioni';

  @override
  String get routePoints => 'Punti della rotta';

  @override
  String get anchorDriftTitle => '⚓ L\'ANCORA ARA!';

  @override
  String get anchorDriftContent =>
      'L\'imbarcazione ha superato il perimetro di ancoraggio.\nControlla subito la posizione!';

  @override
  String get cancelAnchor => 'Annulla l\'ancoraggio';

  @override
  String get stopAlarm => 'Ferma l\'allarme';

  @override
  String get briefingItem1 => 'Giubbotti di salvataggio – posizione e uso';

  @override
  String get briefingItem2 => 'Salvagente anulare e procedura MOB';

  @override
  String get briefingItem3 => 'Razzi di segnalazione – tipi e uso';

  @override
  String get briefingItem4 => 'EPIRB / PLB – attivazione';

  @override
  String get briefingItem5 => 'Radio VHF – canale 16, procedura Mayday';

  @override
  String get briefingItem6 => 'Estintore – posizione e uso';

  @override
  String get briefingItem7 => 'Cassetta di pronto soccorso – posizione';

  @override
  String get briefingItem8 => 'Arresto di emergenza del motore';

  @override
  String get briefingItem9 => 'Perdite – acqua, gas';

  @override
  String get briefingItem10 => 'Ancora e catena – procedura di ancoraggio';

  @override
  String get briefingItem11 => 'Regole di bordo';

  @override
  String get briefingItem12 => 'Contatti di emergenza e VHF 16';

  @override
  String get checkInItem1 =>
      'Documenti della barca (immatricolazione, assicurazione)';

  @override
  String get checkInItem2 => 'Dotazioni di sicurezza – complete';

  @override
  String get checkInItem3 => 'Scorte di carburante';

  @override
  String get checkInItem4 => 'Scorte d\'acqua';

  @override
  String get checkInItem5 => 'Ancora e catena – verifica';

  @override
  String get checkInItem6 => 'Motore – prova di avviamento';

  @override
  String get checkInItem7 => 'Strumenti di navigazione';

  @override
  String get checkInItem8 => 'Manovre – cime e vele';

  @override
  String get checkInItem9 => 'Cucina – gas, fornello';

  @override
  String get checkInItem10 => 'Bagno – funzionamento';

  @override
  String get checkInItem11 => 'Danni preesistenti – documentazione fotografica';

  @override
  String get checkOutItem1 => 'Barca pulita – esterno';

  @override
  String get checkOutItem2 => 'Barca pulita – interno';

  @override
  String get checkOutItem3 => 'Carburante rifornito';

  @override
  String get checkOutItem4 => 'Acqua rifornita';

  @override
  String get checkOutItem5 => 'Rifiuti rimossi';

  @override
  String get checkOutItem6 => 'Danni segnalati';

  @override
  String get checkOutItem7 => 'Chiavi consegnate';

  @override
  String get gearListShort => 'Attrezzatura\npersonale';

  @override
  String get colregRules => 'Regole\nCOLREG';

  @override
  String get checkInShort => 'Check-in\nPresa in consegna';

  @override
  String get checkOutShort => 'Check-out\nRiconsegna';

  @override
  String get appTagline => 'Il tuo affidabile giornale di bordo';

  @override
  String exportSavedMsg(String path) {
    return 'Salvato: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Salvato: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Errore di esportazione: $error';
  }

  @override
  String get generatingPdf => 'Generazione del PDF...';

  @override
  String get colregTitle => 'COLREG – Regole per prevenire gli abbordi in mare';

  @override
  String get tableOfContents => 'INDICE';

  @override
  String get inThisChapter => 'In questo capitolo:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Regola $n';
  }

  @override
  String get resetChecklistTitle => 'Azzerare la lista di controllo?';

  @override
  String get resetChecklistContent => 'Tutte le spunte saranno cancellate.';

  @override
  String get reset => 'Azzera';

  @override
  String get checkInReceivingTitle =>
      'Check-in – Presa in consegna della barca';

  @override
  String get checkOutHandoverTitle => 'Check-out – Riconsegna della barca';

  @override
  String get checkInCompletedMsg =>
      'Barca presa in consegna – tutto verificato ✓';

  @override
  String get checkOutCompletedMsg => 'Barca restituita – tutto in ordine ✓';

  @override
  String get briefingDoneMsg => 'Briefing completato – equipaggio informato';

  @override
  String get sectionBriefed => 'Sezione completata ✓';

  @override
  String get confirmSection => 'Conferma la sezione';

  @override
  String get gearListTitle => 'Attrezzatura personale';

  @override
  String get newCategory => 'Nuova categoria';

  @override
  String get add => 'Aggiungi';

  @override
  String get deleteItemTitle => 'Eliminare la voce?';

  @override
  String get allPackedMsg => 'Tutto pronto, si salpa! 🎉';

  @override
  String get addItemLabel => 'Aggiungi una voce';

  @override
  String addToCategoryTitle(String category) {
    return 'Aggiungi a: $category';
  }

  @override
  String get newItemHint => 'Nuova voce...';

  @override
  String get addWaypoint => 'Aggiungi un waypoint';

  @override
  String get editWaypoint => 'Modifica il waypoint';

  @override
  String get waypointNameLabel => 'Nome';

  @override
  String get skipperSignature => 'Firma dello skipper';

  @override
  String get skipperNameLabel => 'Nome dello skipper';

  @override
  String get signWithFinger => 'Firma con il dito';

  @override
  String get clear => 'Cancella';

  @override
  String get signAndExport => 'Firma ed esporta';

  @override
  String get pleaseSign => 'Firma prima di esportare';

  @override
  String get generatingPdfPreview => 'Generazione dell\'anteprima PDF...';

  @override
  String generationError(String error) {
    return 'Errore di generazione: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Salvataggio e generazione del GPX...';

  @override
  String get editCharter => 'Modifica il charter';

  @override
  String get basicInfo => 'Informazioni di base';

  @override
  String get voyageNameRequired => 'Nome della navigazione *';

  @override
  String get dateFrom => 'Data da';

  @override
  String get dateTo => 'Data a';

  @override
  String get vesselName => 'Nome dell\'imbarcazione';

  @override
  String get vesselType => 'Tipo di imbarcazione';

  @override
  String get homePort => 'Porto di armamento';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Nominativo';

  @override
  String get vesselLengthM => 'Lunghezza (m)';

  @override
  String get vesselBeamM => 'Larghezza (m)';

  @override
  String get vesselDraftM => 'Pescaggio (m)';

  @override
  String get selectExistingVoyage => 'Seleziona una navigazione esistente';

  @override
  String get newVoyageForm => 'Nuova navigazione';

  @override
  String get fillFormAndBriefing =>
      'Compila il modulo e firma il briefing di sicurezza';

  @override
  String get notesLabel => 'Note';

  @override
  String get statusLabel => 'Stato';

  @override
  String get safetyBriefingDoneLabel => 'Briefing di sicurezza completato';

  @override
  String get checkInDoneLabel => 'Check-in completato';

  @override
  String get checkOutDoneLabel => 'Check-out completato';

  @override
  String get enterVoyageName => 'Inserisci il nome della navigazione';

  @override
  String daysCount(int n) {
    return '$n giorni';
  }

  @override
  String get selectTargetWaypoint => 'Seleziona il waypoint di destinazione';

  @override
  String get noWaypoints => 'Nessun waypoint.';

  @override
  String get goToMap => 'Vai alla mappa';

  @override
  String get noTarget => 'Nessuna destinazione';

  @override
  String get selectWaypointHint => 'Naviga verso il waypoint';

  @override
  String get sessionStats => 'Statistiche della navigazione';

  @override
  String get maxSpeed => 'Velocità max';

  @override
  String get avgSpeed => 'Velocità media';

  @override
  String get sailingTime => 'Tempo di navigazione';

  @override
  String get gpsData => 'Dati GPS';

  @override
  String get gpsPosition => 'Posizione';

  @override
  String get courseCog => 'Rotta (COG)';

  @override
  String get altitudeLabel => 'Altitudine';

  @override
  String get dscProcedure => 'PROCEDURA DSC';

  @override
  String get voiceScript => 'TESTO VOCALE';

  @override
  String get dscWarningUseOnly => '⚠️ USARE SOLO IN CASO DI';

  @override
  String get dscWarningDanger => 'PERICOLO GRAVE E IMMINENTE';

  @override
  String get dscWarningTypes => 'Incendio · Affondamento · Uomo in mare';

  @override
  String get dscProcedureSubtitle =>
      'Tieni questa procedura vicino alla radio VHF DSC';

  @override
  String get fillBeforeSailing => 'Compila prima di salpare:';

  @override
  String get copyTooltip => 'Copia';

  @override
  String get scriptCopied => 'Testo copiato';

  @override
  String get sendOnCh16 =>
      '📻 Trasmetti sul canale 16 · Alta potenza · Ripeti ogni 2 minuti se non ricevi risposta';

  @override
  String get enterAbove => '[inserisci nel campo sopra]';

  @override
  String get distressNature => 'Natura del pericolo';

  @override
  String get vesselNameLabel => 'Nome dell\'imbarcazione';

  @override
  String get numberOfPersons => 'N. di persone';

  @override
  String get additionalInfo => 'Informazioni aggiuntive';

  @override
  String get voiceScriptTitle => 'TESTO VOCALE MAYDAY';

  @override
  String get dscStep1 => 'Assicurati che la radio sia accesa.';

  @override
  String get dscStep2 =>
      'Apri il coperchio sopra il pulsante ROSSO di soccorso.';

  @override
  String get dscStep3 => 'Premi il pulsante ROSSO UNA volta e rilascia.';

  @override
  String get dscStep4 =>
      'Seleziona la natura del pericolo.\n(Incendio, affondamento, MOB ecc.)\nSe la salti, verrà inviato un allarme di pericolo indeterminato.';

  @override
  String get dscStep5 =>
      'Premi e TIENI PREMUTO il pulsante ROSSO per 5 secondi per inviare la chiamata.';

  @override
  String get dscStep6 =>
      'Attendi fino a 15 secondi la conferma (mostrata sul display), poi invia il messaggio vocale sul canale 16 ad alta potenza.';

  @override
  String get appDescription => 'Giornale di bordo professionale per velisti.';

  @override
  String get vesselIdTitle => 'Identificazione dell\'imbarcazione';

  @override
  String get vesselIdHint =>
      'Nominativo e MMSI vengono compilati automaticamente nella scheda Mayday.';

  @override
  String get maritimeReference => 'Prontuario marittimo';

  @override
  String get phonetic => 'Alfabeto fonetico';

  @override
  String get flagAlphabet => 'Bandiere del codice';

  @override
  String get dayShapes => 'Segnali diurni';

  @override
  String get marineReferenceTile => 'Segnali e alfabeto';

  @override
  String get navInstruments => 'Strumenti di bordo';

  @override
  String get enterPort => 'Inserisci il porto...';

  @override
  String get closeWithoutSaving => 'Chiudi senza salvare';

  @override
  String get saveToDevice => 'Salva sul dispositivo';

  @override
  String get saveAndShare => 'Salva e condividi';

  @override
  String get timestampCannotBeChanged =>
      'L\'ora dell\'annotazione non può essere modificata';

  @override
  String entriesShort(int n) {
    return '$n annotazioni';
  }

  @override
  String get mainsail => 'Randa';

  @override
  String get weatherConditionTitle => 'Condizioni meteo';

  @override
  String get weatherConditionLabel => 'Condizione';

  @override
  String get wcSunny => 'Soleggiato';

  @override
  String get wcPartlyCloudy => 'Parzialmente nuvoloso';

  @override
  String get wcOvercast => 'Coperto';

  @override
  String get wcLightRain => 'Pioggia leggera';

  @override
  String get wcRain => 'Pioggia';

  @override
  String get wcHeavyRain => 'Pioggia intensa';

  @override
  String get wcDrizzle => 'Pioviggine';

  @override
  String get wcThunderstorm => 'Temporali';

  @override
  String get wcIsoThunderstorm => 'Temporali isolati';

  @override
  String get wcHail => 'Grandine';

  @override
  String get wcDust => 'Polvere';

  @override
  String get wcFoggy => 'Nebbioso';

  @override
  String get wcWindy => 'Ventoso';

  @override
  String get wcCold => 'Freddo';

  @override
  String get photoSection => 'Foto';

  @override
  String get camera => 'Fotocamera';

  @override
  String get gallery => 'Galleria';

  @override
  String get addPhoto => 'Aggiungi una foto';

  @override
  String get photoAddedToEntry => 'Foto allegata';

  @override
  String get voyageStart => 'Inizio della navigazione';

  @override
  String get voyageEnd => 'Fine della navigazione';

  @override
  String get onlineAccount => 'Account online';

  @override
  String get onlineAccountDesc =>
      'Sincronizzazione online del giornale — prossimamente';

  @override
  String get register => 'Registrati';

  @override
  String get login => 'Accedi';

  @override
  String get logout => 'Esci';

  @override
  String get logoutConfirm =>
      'Verrai disconnesso. I dati salvati sul dispositivo restano.';

  @override
  String get notLoggedIn => 'Non hai effettuato l\'accesso';

  @override
  String get fullName => 'Nome e cognome';

  @override
  String get password => 'Password';

  @override
  String get userGuide => 'Guida per l\'utente';

  @override
  String get guideQuickStart => 'Avvio rapido – 5 passi';

  @override
  String get guideQuickStartBody =>
      '1. Tocca il grande pulsante \"Inizia la navigazione\" in alto (su Mappa, Giornale o Strumenti) – scegli la frequenza delle annotazioni e il tracciamento parte, non serve compilare altro prima\n2. Se hai una navigazione aperta, l\'app chiede se continuarla o iniziare una nuova registrazione\n3. Compila i dati mancanti (check-in, briefing di sicurezza, scheda imbarcazione/equipaggio) quando vuoi – l\'app te lo ricorda con delle etichette nel Giornale\n4. Aggiungi annotazioni durante la giornata: ora, posizione, nota\n5. Alla fine della navigazione apri Impostazioni → Esporta PDF\n\nL\'app funziona a schermo intero – scorri dal bordo superiore o inferiore per mostrare temporaneamente le barre di sistema del telefono.';

  @override
  String get guideMapTitle => 'Mappa';

  @override
  String get guideMapBody =>
      'La scheda Mappa mostra la tua posizione attuale e la traccia della navigazione.\n\n• Punto blu = posizione attuale\n• Linea blu = traccia in registrazione\n• Icona della rotta – scegli una navigazione o un giorno qualsiasi per vederne la traccia sulla mappa (in arancione), senza esportare il PDF\n• Passa dalla vista satellitare a quella cartografica\n• Segnalamenti marittimi – attiva i segnali nautici (relitti, bassi fondali, boe)\n• Porti – livello toccabile di ancoraggi, marine e porti (dati OpenStreetMap): tocca un\'icona per vedere nome, canale VHF, telefono, sito web, profondità o capienza dove noti; salva il punto come waypoint con un tocco; il livello comprende anche i distributori di carburante (pompa arancione)\n• Radar – livello del radar delle precipitazioni (RainViewer), l\'immagine si aggiorna circa ogni 10 minuti\n• Vento – frecce di direzione/velocità del vento (nodi) in una griglia sull\'area visibile\n• Righello (icona viola) – tocca i punti sulla mappa: NM totali, rilevamento dell\'ultima tratta ed ETA alla velocità attuale; i punti si agganciano ai waypoint, così puoi misurare una rotta che passa per le tue destinazioni\n• Mappa offline (icona di download) – scarica l\'area visibile (mappa + segnalamenti marittimi, zoom attuale +3 livelli) per l\'uso senza segnale; ogni tessera consultata viene inoltre salvata automaticamente\n• In modalità notturna la mappa passa automaticamente alle tessere scure\n• Icona dell\'ancora = posizione di ancoraggio (solo quando l\'allarme ancora è attivo)\n• Icona di importazione – carica tracce e waypoint da un file .gpx (vedi \"Importazione GPX\")\n• Blocco del nord – tieni premuta la rosa dei venti (in alto a sinistra); la mappa smette di ruotare e resta con il nord in alto. Toccala in qualsiasi momento per tornare al nord.\n• I livelli scelti (satellite, segnalamenti marittimi, porti, radar, vento…), l\'inseguimento GPS e il blocco del nord vengono ricordati tra un avvio e l\'altro\n• Pressione prolungata sulla mappa = aggiungi un waypoint (una destinazione di navigazione); tocca un waypoint esistente per rinominarlo o eliminarlo';

  @override
  String get guideInstrTitle => 'Strumenti di bordo';

  @override
  String get guideInstrBody =>
      'La scheda Strumenti mostra i dati di navigazione in tempo reale.\n\n• SOG – velocità sul fondo (nodi)\n• TWS – velocità del vento reale\n• TWA – angolo del vento reale rispetto alla barca (verde = dritta, rosso = sinistra)\n• DEPTH – profondità dell\'acqua (rosso = meno di 5 m)\n• VMG WP – velocità verso un waypoint selezionato; scegline uno dal riquadro per vedere distanza/rilevamento e una freccia direttamente sulla rosa dei venti\n\nOrigine dei dati: GPS del telefono o Raymarine (gateway WiFi TCP o UDP).\nLe impostazioni della connessione (compresa la scelta TCP/UDP) sono in Impostazioni → Strumenti.\n\nCome si collega la barca: l\'app legge i dati NMEA via WiFi (TCP o UDP). L\'hotspot WiFi di un MFD Raymarine di solito non basta — è pensato per le app Raymarine e in genere non espone i dati NMEA grezzi a terze parti. Serve un gateway NMEA-WiFi (ad es. Digital Yacht, Yacht Devices, Actisense, Quark-elec) collegato al bus di bordo, che crei una propria rete o trasmetta NMEA sul WiFi. Collegati al WiFi di quel gateway e inserisci il suo IP e la porta nelle Impostazioni (oppure prova il Rilevamento automatico).';

  @override
  String get guideLogbookTitle => 'Giornale di bordo';

  @override
  String get guideLogbookBody =>
      'Il Giornale è la scheda principale per gestire le navigazioni.\n\n• Il grande pulsante \"Inizia la navigazione\" in alto avvia il tracciamento – chiede solo la frequenza delle annotazioni automatiche (modificabile a ogni avvio), senza moduli da compilare prima\n• Se una navigazione è già aperta, l\'app chiede se continuarla o iniziare una nuova registrazione\n• I dati mancanti (check-in, briefing di sicurezza, scheda imbarcazione/equipaggio) sono segnalati da etichette colorate direttamente sulla scheda della navigazione – tocca un\'etichetta per compilarli\n• Ogni giorno di navigazione è mostrato separatamente\n• Le annotazioni si possono aggiungere manualmente durante la giornata, comprese ore motore, carburante e acqua nella sezione \"Motore e serbatoi\"\n• Durante il tracciamento, il pulsante della fotocamera (in basso a sinistra) permette di fotografare un punto d\'interesse e salvarlo come annotazione rapida con posizione e ora\n• Il giornale si può esportare in PDF dal menu del giorno\n• L\'icona della stretta di mano nel dettaglio della navigazione apre il verbale di riconsegna (check-in/check-out)\n• Il modulo dettagliato della navigazione (icona della barca nel dettaglio) registra l\'imbarcazione e i suoi parametri, la zona di navigazione, l\'equipaggio con le abilitazioni dello skipper e le foto dell\'imbarcazione (max 3, riportate nel PDF)\n• Le schede incomplete (Briefing di sicurezza, check-in/out, scheda imbarcazione) lampeggiano in rosso nella barra superiore del dettaglio finché non vengono completate\n• Se l’app si chiude durante la navigazione senza fermare il tracciamento (la chiude il sistema, uno swipe involontario), al riavvio propone di continuare la stessa navigazione, inclusa la distanza percorsa mentre non era attiva\n• Al primo avvio di una navigazione l’app ricorda le impostazioni della batteria: senza di esse il sistema (soprattutto Honor/Huawei) può interrompere il tracciamento in background\n• L’icona rotta nell’intestazione della navigazione (accanto a briefing, protocollo e scheda barca) mostra l’intera traccia sulla mappa';

  @override
  String get guideMilesTitle => 'Libretto delle miglia';

  @override
  String get guideMilesBody =>
      'Un riepilogo di tutte le tue navigazioni in un unico posto (icona nella scheda Giornale).\n\n• Miglia nautiche totali, giorni in mare, numero di navigazioni e ore notturne\n• Suddivisione per anno e per imbarcazione\n• Filtro per anno\n• Tocca una navigazione (anche tracciata/importata) per compilarne l\'annotazione – rotta, bandiera dell\'imbarcazione, nome e abilitazione del comandante, firma di conferma delle miglia\n• Pulsante + – aggiungi una navigazione passata, precedente all\'uso dell\'app (conta pienamente nei riepiloghi, nell\'elenco è contrassegnata con un asterisco)\n• Esportazione in PDF di un certificato delle miglia percorse con lo spazio per la firma';

  @override
  String get guideHandoverTitle => 'Verbale di riconsegna (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Una registrazione formale della presa in consegna e della restituzione della barca a noleggio – icona della stretta di mano nel dettaglio della navigazione.\n\n• Lista di controllo dell\'attrezzatura (vele, manovre, ancora, navigazione, giubbotti di salvataggio, zattera, cassetta di pronto soccorso, tender, luci, bimini...) – OK / danneggiato / mancante, con nota, posizione a bordo e foto\n• Stato di carburante, acqua e ore motore\n• Firma dello skipper e del rappresentante della società di charter\n• Il verbale diventa di sola lettura una volta firmato da entrambi\n• Il check-out precompila i dati dal verbale di check-in ed evidenzia i nuovi danni\n• Esportazione in PDF con entrambe le firme affiancate';

  @override
  String get guideGpxImportTitle => 'Importazione GPX';

  @override
  String get guideGpxImportBody =>
      'Importa tracce e waypoint da altre app di navigazione o da dispositivi GPS (icona sulla Mappa).\n\n• Scegli un file .gpx dal dispositivo\n• Un\'esportazione di più giorni (più tracce in un unico file, ad es. da Garmin Explore) viene unita automaticamente in un\'unica navigazione con un giorno per giorno di calendario\n• Le tracce trovate si possono anche assegnare manualmente a una navigazione esistente\n• I waypoint (compresi quelli delle rotte) vengono aggiunti direttamente alla mappa\n• Per un file danneggiato viene mostrato un messaggio d\'errore chiaro';

  @override
  String get guideWeatherTitle => 'Meteo';

  @override
  String get guideWeatherBody =>
      'La scheda Meteo mostra le previsioni in base alla tua posizione attuale.\n\n• Si aggiorna automaticamente quando la posizione cambia\n• Mostra vento, onde, temperatura e condizioni per le ore successive\n• Senza connessione viene mostrata l\'ultima previsione salvata\n\nSole, luna e maree:\n• Alba, tramonto e fase lunare sono calcolati sul dispositivo — non serve connessione\n• Tocca aggiorna sulla scheda Marea per scaricare una previsione di marea di 7 giorni (gratuita, senza chiave API)\n• Le maree vengono memorizzate, così restano consultabili offline; la scheda ti avvisa quando la previsione è vecchia o è stata scaricata lontano da qui\n• ⚠ Le altezze di marea sono riferite al livello medio del mare, non allo zero idrografico — non usarle mai per calcolare la profondità sotto la chiglia\n\nCorrente marina:\n• La scheda Corrente marina mostra la previsione reale per la tua posizione in nodi e la direzione verso cui la corrente scorre\n• Sulla mappa, il pulsante con la doppia freccia disegna una griglia delle correnti per l\'area visibile; le frecce indicano dove si muove l\'acqua\n• Da non confondere con il livello Correnti oceaniche — quella è una carta di riferimento delle grandi correnti globali';

  @override
  String get guideSafetyMobTitle => 'MOB e ancora';

  @override
  String get guideSafetyMobBody =>
      'La scheda Sicurezza contiene le funzioni di emergenza.\n\nMOB (uomo in mare):\n• Tieni premuto il pulsante rosso MOB per attivarlo\n• L\'app registra la posizione GPS e tiene traccia di tempo e distanza\n• Naviga di nuovo verso il punto di caduta\n\nAllarme ancora:\n• Imposta il raggio di ancoraggio (consigliato: 2× la lunghezza di catena/cima)\n• L\'allarme vibra se la barca esce dal raggio consentito';

  @override
  String get guideSafetyBriefingTitle => 'Briefing di sicurezza e MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'La scheda Sicurezza contiene anche delle schede di consultazione.\n\n• Briefing di sicurezza – lista di controllo per l\'equipaggio prima della partenza\n• Ogni membro dell\'equipaggio firma con la propria firma sullo schermo\n• Le firme vengono salvate e incluse automaticamente nell\'esportazione PDF del charter\n• Lista di riconsegna – panoramica delle voci di check-in/check-out, disponibile anche senza una navigazione aperta\n• Scheda MAYDAY – procedura per la chiamata di soccorso sul canale VHF 16\n• COLREG – regole per prevenire gli abbordi in mare (disponibili in slovacco e inglese; le altre lingue mostrano il testo inglese)\n• Contatti – numeri e contatti di emergenza\n\nNota: il tracciamento si può avviare in qualsiasi momento, anche senza aver completato il briefing – l\'app si limita a ricordartelo con l\'etichetta \"Manca il briefing di sicurezza\" nel Giornale finché non è fatto. Il briefing richiede che la scheda imbarcazione ed equipaggio sia già compilata e può essere salvato solo quando ogni membro dell\'equipaggio ha firmato.';

  @override
  String get guideDutyTitle => 'Equipaggio di guardia';

  @override
  String get guideDutyBody =>
      'Una registrazione di chi era di guardia e quando — in Sicurezza, sopra l\'allarme ancora.\n\n• Monta di guardia — scegli una o più persone insieme; ciascuna smonta poi separatamente\n• I nomi provengono dall\'equipaggio della navigazione. Se non è impostato alcun equipaggio, il pulsante ti porta alla scheda della navigazione\n• L\'ora di inizio si può correggere se hai premuto il pulsante in ritardo\n• Mostra per il controllo — una scheda a schermo intero da presentare a bordo: chi è di guardia, da quando, ora locale e UTC. Da lì non si può modificare nulla\n• Turni di guardia — inserisci una guardia passata o modificane una. Lascia vuota l\'ora \"a\" e la guardia resta in corso\n• Una guardia notturna a cavallo della mezzanotte è una sola registrazione, non due. Nel PDF compare in entrambi i giorni, contrassegnata con una freccia\n• Montare e smontare di guardia vengono scritti sia nel giornale sia nell\'esportazione PDF\n\nNota: l\'app non termina mai una guardia da sola. Dopo 12 ore si limita ad avvisarti — un\'ora di fine che non hai osservato sarebbe un dato inventato.';

  @override
  String get guideCompassTitle => 'Bussola da rilevamento';

  @override
  String get guideCompassBody =>
      'La scheda Bussola mostra il rilevamento magnetico usando i sensori del telefono, con la fotocamera posteriore come sfondo per prendere rilevamenti su oggetti.\n\n• Mirino giallo – direzione verso cui punti\n• Striscia della bussola in alto – N / NE / E / SE / S / SO / O / NO\n• Lettura numerica – gradi e punto cardinale\n• Punto verde = lettura stabile  ·  Punto arancione = calibrazione in corso\n\nSe la lettura è instabile, muovi lentamente il telefono a forma di otto per calibrare il magnetometro.\n\nLa precisione può ridursi vicino a strutture metalliche, altoparlanti o apparecchiature elettroniche.';

  @override
  String get guideSettingsTitle => 'Impostazioni';

  @override
  String get guideSettingsBody =>
      '• Unità – distanza NM/km, velocità nodi/km/h, più temperatura, profondità e vento separatamente (in fiume vanno bene km + km/h)';

  @override
  String get guideBackupTitle => 'Backup e ripristino dei dati';

  @override
  String get guideBackupBody =>
      'In Impostazioni → Backup dei dati.\n\n• Esporta il backup – salva l\'intero giornale (navigazioni, annotazioni, impostazioni) in un unico file (.hmbbackup) che puoi condividere via e-mail, nel cloud o salvare in locale\n• Ripristina da backup – sostituisce i dati attuali con il contenuto del backup selezionato; prima viene creato automaticamente un backup di sicurezza dello stato attuale\n• Il ripristino è bloccato mentre il tracciamento GPS della navigazione è attivo\n• Un backup con uno schema più recente di quello supportato dall\'app viene rifiutato con una spiegazione';

  @override
  String get guideExportTitle => 'Esportazione del giornale';

  @override
  String get guideExportBody =>
      'Il giornale si può esportare come documento PDF professionale.\n\n1. Apri Giornale → seleziona un charter\n2. Tocca l\'icona di esportazione o i tre puntini → Esporta PDF\n3. Firma come skipper → il PDF viene generato\n4. Il PDF comprende: traccia, annotazioni, foto, briefing di sicurezza con le firme dell\'equipaggio; l\'intestazione della copertina mostra la foto dell\'imbarcazione dalla scheda imbarcazione (se caricata)\n5. Condividi via e-mail, stampa o salva sul telefono\n\nOgni PDF riceve un identificativo univoco (ad es. HMBSL-5-2026) e un numero di revisione (Rev. 1, Rev. 2...) visibile nel piè di pagina di ogni pagina. Ogni nuova esportazione incrementa automaticamente il numero — rendendo visibile quante volte il documento è stato generato.\n\nIl codice QR sulla pagina delle firme contiene l\'identificativo, la revisione e un\'impronta crittografica del contenuto. Qualsiasi modifica dei dati cambia il codice QR.\n\nIl PDF viene generato nella lingua dell\'app, nomi e segni diacritici compresi. Ogni pagina del giorno riporta anche una fascia con l\'equipaggio di guardia.';

  @override
  String get safetyBriefingScreenTitle => 'Briefing di sicurezza';

  @override
  String get briefingCrewSignaturesSection => 'Firme dell\'equipaggio';

  @override
  String get briefingSignHere => 'Firma qui';

  @override
  String get briefingClear => 'Cancella';

  @override
  String get briefingSigned => 'Firmato';

  @override
  String get briefingSave => 'Salva le firme';

  @override
  String get briefingSavedOk => 'Firme salvate';

  @override
  String get briefingOpenBriefing => 'Briefing di sicurezza';

  @override
  String get briefingSkipper => 'Skipper';

  @override
  String get briefingCrew => 'Equipaggio';

  @override
  String get briefingNoCrew =>
      'Nessun equipaggio definito. Aggiungi i membri dell\'equipaggio nelle impostazioni della navigazione.';

  @override
  String get briefingDate => 'Data';

  @override
  String get briefingLocation => 'Luogo';

  @override
  String get briefingDoneLabel => 'Briefing di sicurezza completato';

  @override
  String get briefingDoneSubtitle =>
      'Tutte le firme dell\'equipaggio sono salvate. Non serve rifarlo.';

  @override
  String get briefingEditSignature => 'Cambia la firma';

  @override
  String get briefingRequiredTitle => 'È necessario il briefing di sicurezza';

  @override
  String get briefingRequiredBody =>
      'Completa il briefing di sicurezza e raccogli le firme dell\'equipaggio prima di avviare il primo tracciamento.';

  @override
  String get goToBriefing => 'Vai al briefing';

  @override
  String get skipperProfile => 'Profilo dello skipper';

  @override
  String get skipperProfileHint =>
      'Questi dati compaiono nell\'esportazione PDF della navigazione.';

  @override
  String get skipperFullName => 'Nome dello skipper';

  @override
  String get skipperLicenseSection => 'Abilitazione dello skipper';

  @override
  String get skipperLicenseType => 'Tipo di abilitazione';

  @override
  String get skipperLicenseNumber => 'Numero di abilitazione';

  @override
  String get skipperLicenseAuthority => 'Ente di rilascio';

  @override
  String get skipperLicenseExpiry => 'Valida fino al';

  @override
  String get skipperVhfSection => 'Abilitazione VHF / SRC';

  @override
  String get skipperVhfNumber => 'Numero VHF/SRC';

  @override
  String get skipperVhfExpiry => 'VHF valida fino al';

  @override
  String get skipperOtherCerts => 'Altri certificati / abilitazioni';

  @override
  String get skipperOtherCertsHint =>
      'ad es. Yachtmaster, RYA, STCW, corsi di salvataggio...';

  @override
  String get continueLastVoyageTitle => 'Continuare l\'ultima navigazione?';

  @override
  String get continueVoyageAction => 'Continua';

  @override
  String get newRecordAction => 'Nuova registrazione';

  @override
  String get missingCheckInChip => 'Manca il check-in';

  @override
  String get missingBriefingChip => 'Manca il briefing di sicurezza';

  @override
  String get missingDetailsChip => 'Mancano i dati di imbarcazione/equipaggio';

  @override
  String get missingCheckOutChip => 'Manca il check-out';

  @override
  String get vesselModel => 'Modello';

  @override
  String get vesselTypeMonohull => 'Monoscafo';

  @override
  String get vesselTypeCatamaran => 'Catamarano';

  @override
  String get vesselTypeTrimaran => 'Trimarano';

  @override
  String get vesselTypeMotorYacht => 'Motoryacht';

  @override
  String get vesselTypeGulet => 'Caicco';

  @override
  String get vesselTypeDinghy => 'Deriva';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Altro';

  @override
  String get charterCompanyLabel => 'Società di charter';

  @override
  String get yachtParamsSection => 'Caratteristiche dello yacht';

  @override
  String get berthsLabel => 'Posti letto';

  @override
  String get yearBuiltLabel => 'Anno di costruzione';

  @override
  String get waterTankLabel => 'Serbatoio dell\'acqua';

  @override
  String get fuelTankLabel => 'Serbatoio del carburante';

  @override
  String get engineHoursStartLabel => 'Ore motore · inizio';

  @override
  String get engineHoursEndLabel => 'Ore motore · fine';

  @override
  String get whereWhenSection => 'Dove e quando';

  @override
  String get countryLabel => 'Paese';

  @override
  String get cruisingAreaLabel => 'Zona di navigazione';

  @override
  String get charterContactsSection => 'Contatti del charter';

  @override
  String get charterContactsHint =>
      'Fino a 3 numeri per chiamata / WhatsApp / SMS. Sempre con il prefisso internazionale (ad es. +39...).';

  @override
  String get addPhoneNumber => 'Aggiungi un numero di telefono';

  @override
  String get costsSection => 'Costi';

  @override
  String get charterPriceLabel => 'Prezzo del charter';

  @override
  String get currencyLabel => 'Valuta';

  @override
  String get addCostItem => 'Aggiungi un costo';

  @override
  String get costName => 'Nome del costo';

  @override
  String get crewSectionHint =>
      'Tocca l\'etichetta per indicare il comandante — gli altri sono equipaggio.';

  @override
  String get addCrewMember => 'Aggiungi un membro dell\'equipaggio';

  @override
  String get crewNameLabel => 'Nome';

  @override
  String get skipperBadge => 'SKIPPER';

  @override
  String get crewBadge => 'EQUIPAGGIO';

  @override
  String get vesselTypeSailboat => 'Barca a vela';

  @override
  String get vesselTypeMotorBoat => 'Barca a motore';

  @override
  String get sbNeedsVesselCard =>
      'Compila prima la scheda imbarcazione ed equipaggio — al Briefing di sicurezza serve l\'elenco dell\'equipaggio per le firme.';

  @override
  String get prefillSkipperTitle => 'Inserire i dati salvati dello skipper?';

  @override
  String get prefillSkipperFill => 'Inserisci';

  @override
  String get prefillSkipperNew => 'Nuovo skipper';

  @override
  String get boatLicenceLabel => 'N. patente nautica';

  @override
  String get radioLicenceLabel => 'N. licenza radio';

  @override
  String get vesselPhotosSection => 'Foto dell\'imbarcazione (max 3)';

  @override
  String get addPhotoLabel => 'Aggiungi';

  @override
  String get createVoyageButton => 'Crea la navigazione';

  @override
  String get saveVoyageButton => 'Salva la navigazione';

  @override
  String get costBaseCharter => 'Prezzo base del charter';

  @override
  String get costDeposit => 'Cauzione';

  @override
  String get costDinghyOutboard => 'Tender / fuoribordo';

  @override
  String get costOutboardFuel => 'Carburante per il fuoribordo';

  @override
  String get costTransitLog => 'Transit log';

  @override
  String get costTouristTax => 'Tassa di soggiorno';

  @override
  String get costFinalCleaning => 'Pulizia finale';

  @override
  String get costLinenTowels => 'Biancheria da letto e asciugamani';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / kayak';

  @override
  String get costSkipperFee => 'Compenso dello skipper';

  @override
  String get costHostessFee => 'Compenso della hostess';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m m';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Posizione approssimativa · ±$m m · localizzazione di rete';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Ultima posizione nota · $mins min fa';
  }

  @override
  String get locationQualityUnknown => 'Precisione sconosciuta';

  @override
  String get locationQualityMocked => '⚠️ Rilevata posizione simulata';

  @override
  String get syncQueueTitle => 'Coda di sincronizzazione';

  @override
  String get syncQueueEmpty => 'La coda è vuota';

  @override
  String get syncNowAction => 'Sincronizza ora';

  @override
  String get syncRetryFailedAction => 'Riprova i falliti';

  @override
  String get syncStatusPending => 'In attesa';

  @override
  String get syncStatusSending => 'Invio in corso';

  @override
  String get syncStatusSent => 'Inviato';

  @override
  String get syncStatusFailed => 'Fallito';

  @override
  String get syncStatusConflict => 'Conflitto';

  @override
  String get syncStatusDeferred => 'Rinviato';

  @override
  String syncRetryCount(int n) {
    return 'Tentativo $n';
  }

  @override
  String get syncOffline => 'offline';

  @override
  String syncPendingCount(int n) {
    return '$n in attesa';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n rinviati';
  }

  @override
  String syncFailedCount(int n) {
    return '$n falliti';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Allegato in attesa del Wi-Fi (in mare di solito non è disponibile).';

  @override
  String get syncWifiOverrideAction => 'Usa i dati mobili';

  @override
  String get syncWifiOverrideActive =>
      'Dati mobili consentiti per gli allegati';

  @override
  String get syncClearQueueAction => 'Svuota la coda';

  @override
  String get syncClearQueueConfirmTitle => 'Svuotare l\'intera coda?';

  @override
  String get syncClearQueueConfirmContent =>
      'Rimuove ogni elemento dalla coda di sincronizzazione, compresi quelli già inviati. L\'operazione non è reversibile.';

  @override
  String get syncClearQueueDone => 'Coda svuotata';

  @override
  String get syncEnableToggle => 'Sincronizza il giornale';

  @override
  String get syncEnableToggleDesc =>
      'Invia le annotazioni al server mentre l\'app è aperta e online';

  @override
  String get syncTargetLabel => 'Destinazione della sincronizzazione';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Server personalizzato';

  @override
  String get syncCustomUrlLabel => 'URL del server';

  @override
  String get syncCustomTokenLabel => 'Token';

  @override
  String get syncTestConnectionAction => 'Prova la connessione';

  @override
  String get syncTestSuccess => 'La connessione funziona';

  @override
  String syncTestFailure(String detail) {
    return 'Fallita: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Inserisci l\'URL del server';

  @override
  String get syncUrlErrorInvalid => 'URL non valido';

  @override
  String get syncUrlErrorHttps => 'L\'URL deve iniziare con https://';

  @override
  String get syncIntervalLabel => 'Intervallo di sincronizzazione';

  @override
  String syncIntervalMinutes(int n) {
    return '$n min';
  }

  @override
  String get syncIntervalNote =>
      'La sincronizzazione funziona solo mentre l\'app è aperta';

  @override
  String get syncAttachmentPolicyLabel => 'Allegati (foto)';

  @override
  String get syncAttachmentNever => 'Mai';

  @override
  String get syncAttachmentWifiOnly => 'Solo Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Sempre';

  @override
  String get syncBackfillAction => 'Accoda le annotazioni precedenti';

  @override
  String get syncBackfillDesc =>
      'Aggiunge alla coda di invio le annotazioni create mentre la sincronizzazione era disattivata';

  @override
  String syncBackfillResult(int n) {
    return '$n accodate';
  }

  @override
  String get syncBackfillNone =>
      'Nulla da accodare — è già tutto in coda o inviato';

  @override
  String get syncCloudEnableToggle => 'Esportazione nel cloud (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Una volta effettuato l\'accesso, il PDF e il GPX di ogni giornata conclusa vengono caricati automaticamente su Google Drive. Senza accesso tutto resta sul dispositivo.';

  @override
  String get syncCloudSignInAction => 'Accedi con Google';

  @override
  String get syncCloudSignOutAction => 'Esci';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Connesso come $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Non hai effettuato l\'accesso';

  @override
  String get waypointNameHint => 'ad es. Ancoraggio, Porto...';

  @override
  String waypointDefaultName(String time) {
    return 'Waypoint $time';
  }

  @override
  String get mobFullName => 'Uomo in mare';

  @override
  String get maydayCardShort => 'Scheda\nMayday';

  @override
  String get morseInputHint => 'Inserisci il testo...';

  @override
  String get morseSosTitle => 'SOS – SEGNALE DI SOCCORSO';

  @override
  String get morseSosCopied => 'SOS copiato';

  @override
  String intervalSeconds(int n) {
    return '$n sec';
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
  String get aboutFeatureGps => 'Tracciamento GPS con annotazioni automatiche';

  @override
  String get aboutFeatureLogbook =>
      'Giornale di bordo per charter di più giorni';

  @override
  String get aboutFeatureMaps => 'Carte nautiche offline (OpenSeaMap)';

  @override
  String get aboutFeatureWeather => 'Meteo marino (Open-Meteo)';

  @override
  String get aboutFeatureExport => 'Esportazione PDF + GPX';

  @override
  String get aboutFeatureSafety => 'Briefing di sicurezza e scheda Mayday';

  @override
  String get aboutAuthorLabel => 'Autore';

  @override
  String get aboutVersionLabel => 'Versione';

  @override
  String get aboutPlatformLabel => 'Piattaforma';

  @override
  String cloudSignInFailed(String error) {
    return 'Accesso non riuscito: $error';
  }

  @override
  String cloudSignOutFailed(String error) {
    return 'Disconnessione non riuscita: $error';
  }

  @override
  String get marineInstrumentsWifiNote =>
      'Funziona solo tramite la rete WiFi della barca: il telefono deve essere collegato a un gateway NMEA (Raymarine, Digital Yacht, Yacht Devices…). Senza WiFi l\'app usa il GPS del telefono e le previsioni meteo da internet.';

  @override
  String get interruptedVoyageTitle => 'Il tracciamento è stato interrotto';

  @override
  String interruptedVoyageBody(String time) {
    return 'L\'app si è chiusa alle $time senza terminare la navigazione. Continuare la stessa navigazione?';
  }

  @override
  String interruptedVoyageGap(String distance) {
    return 'La tua posizione è a $distance NM dall’ultimo punto registrato.';
  }

  @override
  String get interruptedVoyageAddGap =>
      'Aggiungere questa distanza alla navigazione';

  @override
  String get interruptedVoyageResume => 'Continua';

  @override
  String get batteryPromptTitle =>
      'Lascia l\'app attiva per tutta la navigazione';

  @override
  String get batteryPromptBody =>
      'Android — in particolare Honor, Huawei e Xiaomi — chiude le app in background, interrompendo il tracciamento a metà navigazione.\n\nNelle impostazioni della batteria consenti a quest\'app di funzionare senza restrizioni. Su Honor/Huawei aggiungila anche alle app protette e consenti l\'avvio automatico.';

  @override
  String get batteryPromptAction => 'Apri impostazioni';

  @override
  String get speed => 'Velocità';
}
