// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get languageName => 'English';

  @override
  String get navMap => 'Map';

  @override
  String get navTracking => 'Tracking';

  @override
  String get navLogbook => 'Logbook';

  @override
  String get navWeather => 'Weather';

  @override
  String get navSafety => 'Safety';

  @override
  String get navCompass => 'Compass';

  @override
  String get navSettings => 'Settings';

  @override
  String get cameraPermissionDenied =>
      'Camera access was denied. Enable it in device settings.';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get compassCalibrationNote =>
      'Magnetic compass. Accuracy may be affected by nearby metal or electronics. If uncalibrated, move the device in a figure-eight pattern.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get share => 'Share';

  @override
  String get selectAll => 'Select all';

  @override
  String get error => 'Error';

  @override
  String errorMsg(String msg) {
    return 'Error: $msg';
  }

  @override
  String get pressBackToExit => 'Press Back again to exit';

  @override
  String get trackingRunningTitle => 'Tracking running';

  @override
  String get trackingRunningContent =>
      'Tracking is active. What would you like to do?';

  @override
  String get stopAndExit => 'Stop and exit';

  @override
  String get keepRunning => 'Keep running';

  @override
  String get marineInstrumentsTitle => 'Marine instruments';

  @override
  String get marineInstrumentsPrompt =>
      'Would you like to connect the app to marine instruments (e.g. Raymarine via WiFi gateway)? The app will then read GPS, wind, depth and other data directly from the boat.\n\nWithout connection, the phone GPS and internet weather forecast will be used – you can change this anytime in Settings.';

  @override
  String get notNow => 'Not now';

  @override
  String get setupConnection => 'Set up connection';

  @override
  String get autoDetectAction => 'Auto-detect';

  @override
  String get autoDetectWifiHintTitle => 'Connect to the boat\'s WiFi first';

  @override
  String get autoDetectWifiHintBody =>
      'Check in your phone\'s Settings → WiFi that you\'re connected to the marine instruments network (e.g. RayNet, WiFi-1). Then the app will try to find the gateway on that network automatically.';

  @override
  String get openWifiSettings => 'WiFi settings';

  @override
  String get continueAction => 'Continue';

  @override
  String get autoDetecting => 'Searching for instruments on the WiFi network…';

  @override
  String get autoDetectFailed =>
      'No gateway found nearby. Check you\'re on the boat\'s WiFi network, or enter the IP manually in Settings.';

  @override
  String autoDetectSuccess(String host) {
    return 'Connected to $host';
  }

  @override
  String get guidePromptTitle => 'New here? Quick guide';

  @override
  String get guidePromptBody =>
      'This app includes a short user guide – map, logbook, weather, safety checklist and more. Want a quick look now? You\'ll always find it later under Settings → User Guide.';

  @override
  String get guidePromptAction => 'Show me the guide';

  @override
  String get trackingActiveTitle => 'Tracking active';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get waitingForGps => 'Waiting for GPS...';

  @override
  String get gpsUnavailable => 'GPS unavailable';

  @override
  String get lastKnownPosition => 'Last known position';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get logbookBtn => 'Logbook';

  @override
  String get stop => 'Stop';

  @override
  String get stopTrackingDay => 'Stop tracking for today?';

  @override
  String get startVoyage => 'Start voyage';

  @override
  String get starting => 'Starting...';

  @override
  String get newVoyage => 'New voyage';

  @override
  String get multiday => 'Multi-day';

  @override
  String get standalone => 'Standalone';

  @override
  String get voyageName => 'Voyage name';

  @override
  String get voyageNameOptional => 'Name (optional)';

  @override
  String get voyageNameHint => 'e.g. Bay trip';

  @override
  String get existingVoyage => 'Continue existing voyage';

  @override
  String get newVoyageDropdown => '— New voyage —';

  @override
  String get firstVoyageHint => 'First voyage – fill in the basic info:';

  @override
  String get estimatedDays => 'Estimated number of days:';

  @override
  String get logFrequency => 'Log entry frequency';

  @override
  String get startTracking => 'Start tracking';

  @override
  String get trackingInProgress => 'Track your voyage';

  @override
  String dayNofTotal(int n, int total) {
    return 'Day $n of $total';
  }

  @override
  String get newDay => '(new day)';

  @override
  String get endVoyageTitle => 'End voyage?';

  @override
  String get endVoyageContent =>
      'You have reached the last planned day of the voyage.\n\nWill the voyage continue tomorrow?';

  @override
  String get decideLayer => 'Decide later';

  @override
  String get continuesTomorrow => 'Continues tomorrow';

  @override
  String get endVoyage => 'End voyage';

  @override
  String get newMultidayVoyage => 'New multi-day voyage';

  @override
  String get deleteCharterTitle => 'Delete charter?';

  @override
  String get deleteCharterContent => 'All days and entries will be deleted.';

  @override
  String get cannotDeleteWhileTracking =>
      'Cannot delete a voyage while tracking is active.';

  @override
  String get noVoyages => 'No voyages';

  @override
  String get createFirstCharter => 'Create your first charter';

  @override
  String get briefingDone => 'Briefing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Voyage not found';

  @override
  String get unknownVessel => 'Unknown vessel';

  @override
  String get captain => 'Captain';

  @override
  String get crew => 'Crew';

  @override
  String get total => 'Total';

  @override
  String voyageDaysCount(int n) {
    return 'Voyage days ($n)';
  }

  @override
  String get bulkDelete => 'Bulk delete';

  @override
  String get noDays =>
      'No days.\nStart tracking and the first day will be created automatically.';

  @override
  String get deleteDayTitle => 'Delete day?';

  @override
  String deleteDayContent(String day) {
    return 'All entries for $day will be deleted.';
  }

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get selectDaysTitle => 'Select days to delete';

  @override
  String deleteCount(int n) {
    return 'Delete ($n)';
  }

  @override
  String get safety => 'Safety';

  @override
  String get mobHoldToActivate => 'Hold to activate';

  @override
  String get mobActive => '⚠️ MOB ACTIVE';

  @override
  String get mobTime => 'Time';

  @override
  String get mobDistance => 'Distance';

  @override
  String get mobDirection => 'Direction';

  @override
  String get navigateToMob => 'Navigate to MOB';

  @override
  String get gpsPositionNotAvailable => 'GPS position not available!';

  @override
  String get anchorAlarm => 'Anchor Alarm';

  @override
  String get drifting => 'DRIFTING';

  @override
  String get anchorRadiusLabel => 'Anchor radius';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get safetyBriefingCard => 'Safety Briefing';

  @override
  String get maydayCard => 'Mayday Card';

  @override
  String get yachtHandover => 'Yacht handover';

  @override
  String get gearList => 'Gear list';

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Emergency contacts';

  @override
  String get backToToc => 'Back to contents';

  @override
  String get briefingComplete => 'Briefing complete';

  @override
  String get updateByPosition => 'Update by location';

  @override
  String get detectedByGps => 'detected by GPS';

  @override
  String get locationUnavailable =>
      '📍 Location unavailable – global contacts shown';

  @override
  String get detectingLocation => 'Detecting location...';

  @override
  String get tapToCall => 'Tap to call';

  @override
  String cannotCall(String name) {
    return 'Cannot call: $name';
  }

  @override
  String get vhfChannel16 => 'VHF channel 16 – use the ship\'s radio';

  @override
  String get hmbHandbook => 'HMB Handbook';

  @override
  String get checkInLabel => 'Check-in (receiving the boat)';

  @override
  String get checkOutLabel => 'Check-out (handing over the boat)';

  @override
  String get charterCheckCard => 'Charter';

  @override
  String get weatherTitle => 'Weather & Sea';

  @override
  String get updateForecast => 'Update forecast';

  @override
  String get gpsNotAvailableTracking => 'GPS not available – enable tracking';

  @override
  String get downloadingForecast => 'Downloading forecast...';

  @override
  String get loadingForecast => 'Loading forecast...';

  @override
  String get noConnection => 'No connection available';

  @override
  String get pressRefreshWhenOnline => 'Press refresh when online';

  @override
  String get noWeatherData => 'No weather data';

  @override
  String get forecastAutoDownload =>
      'Forecast will download automatically when tracking starts, or press Refresh.';

  @override
  String get enableGpsFirst => 'Enable GPS / tracking first';

  @override
  String get downloadForecast => 'Download forecast';

  @override
  String downloadError(String error) {
    return 'Download error: $error';
  }

  @override
  String get liveInstrumentData => 'Live marine instrument data';

  @override
  String get windRelative => 'Wind (rel.)';

  @override
  String get windTrue => 'Wind (true)';

  @override
  String get depthLabel => 'Depth';

  @override
  String get waterTempLabel => 'Water temp';

  @override
  String get courseTrue => 'Course (true)';

  @override
  String get courseMag => 'Course (mag.)';

  @override
  String get engineLabel => 'Engine';

  @override
  String get wavesLabel => 'Waves';

  @override
  String get pressureLabel => 'Pressure';

  @override
  String get airTempLabel => 'Air';

  @override
  String get waterLabel => 'Water';

  @override
  String get wind24h => 'Wind – 3 days';

  @override
  String get waves24h => 'Waves – 3 days';

  @override
  String get hourlyForecast => '3-Day Forecast';

  @override
  String get dailyForecast => 'Daily temperature';

  @override
  String get timeCol => 'Time';

  @override
  String get windCol => 'Wind';

  @override
  String get wavesCol => 'Waves';

  @override
  String get rainCol => 'Rain';

  @override
  String get beaufort0 => 'Calm';

  @override
  String get beaufort1 => 'Light air';

  @override
  String get beaufort2 => 'Light breeze';

  @override
  String get beaufort3 => 'Gentle breeze';

  @override
  String get beaufort4 => 'Moderate breeze';

  @override
  String get beaufort5 => 'Fresh breeze';

  @override
  String get beaufort6 => 'Strong breeze';

  @override
  String get beaufort7 => 'Near gale';

  @override
  String get beaufort8 => 'Gale';

  @override
  String get beaufort9 => 'Strong gale';

  @override
  String get beaufort10 => 'Storm';

  @override
  String get beaufort11 => 'Violent storm';

  @override
  String get beaufort12 => 'Hurricane';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get measurementUnits => 'Measurement units';

  @override
  String get temperature => 'Temperature';

  @override
  String get depthWaves => 'Depth / waves';

  @override
  String get wind => 'Wind';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get displaySettings => 'Display';

  @override
  String get nightMode => 'Night mode';

  @override
  String get nightModeDesc => 'Red filter to preserve night vision';

  @override
  String get aboutApp => 'About';

  @override
  String get backupSection => 'Data backup';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupDesc =>
      'Saves the whole logbook (voyages, entries, settings) into a single file';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String get restoreBackupDesc =>
      'Replaces current data with the contents of a selected backup file';

  @override
  String get restoreBlockedTrackingTitle => 'GPS tracking is running';

  @override
  String get restoreBlockedTrackingBody =>
      'Stop the active voyage tracking before restoring a backup.';

  @override
  String get restoreSchemaTooNewTitle => 'Backup is from a newer version';

  @override
  String get restoreSchemaTooNewBody =>
      'This backup was created by a newer app version than the one currently installed. Update the app first.';

  @override
  String get restoreConfirmTitle => 'Restore from backup?';

  @override
  String get restoreConfirmBody =>
      'Current data will be replaced with the backup\'s contents. A safety backup of the current state will be created automatically first.';

  @override
  String get restoreSuccess => 'Data was successfully restored from backup.';

  @override
  String get restoreInvalidFile =>
      'The selected file is not a valid HMB Sailing Log backup.';

  @override
  String get milesBookTitle => 'Mile logbook';

  @override
  String get totalNm => 'Total NM';

  @override
  String get daysAtSea => 'Days at sea';

  @override
  String get voyageCount => 'Voyage count';

  @override
  String get nightHoursLabel => 'Night hours';

  @override
  String get byYear => 'By year';

  @override
  String get byVessel => 'By vessel';

  @override
  String get addHistoricalVoyage => 'Add historical voyage';

  @override
  String get editHistoricalVoyage => 'Edit historical voyage';

  @override
  String get deleteHistoricalVoyageConfirm => 'Delete this historical voyage?';

  @override
  String get manualEntryExplanation => '* manual entry (entered by hand)';

  @override
  String get roleLabel => 'Role on board';

  @override
  String get roleSkipper => 'Skipper';

  @override
  String get roleCoSkipper => 'Co-skipper';

  @override
  String get roleCrew => 'Crew';

  @override
  String get areaLabel => 'Area / route';

  @override
  String get distanceNmLabel => 'Distance (NM)';

  @override
  String get daysCountLabel => 'Number of days';

  @override
  String get milesCertificateTitle => 'Certificate of miles sailed';

  @override
  String get logbookRecordTitle => 'Logbook record';

  @override
  String get logbookTrackedHint =>
      'Dates, miles, area and role are calculated from tracking/import.';

  @override
  String get vesselFlag => 'Flag of registration';

  @override
  String get captainFirstName => 'Captain\'s first name';

  @override
  String get captainLastName => 'Captain\'s last name';

  @override
  String get captainQualification => 'Highest qualification held';

  @override
  String get logbookSignatureSection => 'Signature confirming the miles';

  @override
  String get addSignature => 'Add signature';

  @override
  String get filterAllYears => 'All years';

  @override
  String get filterCustomRange => 'Custom range';

  @override
  String get handoverMenuTitle => 'Handover protocol';

  @override
  String get checkInProtocol => 'Check-in protocol';

  @override
  String get checkOutProtocol => 'Check-out protocol';

  @override
  String get safetyBriefingShort => 'Safety\nBriefing';

  @override
  String get handoverChecklistShort => 'Handover\nChecklist';

  @override
  String get safetyBriefingRefTitle => 'Safety briefing';

  @override
  String get handoverChecklistRefTitle => 'Handover checklist';

  @override
  String get handoverDateTime => 'Date and time';

  @override
  String get handoverLocation => 'Location (marina)';

  @override
  String get checklistItemOk => 'OK';

  @override
  String get checklistItemDamaged => 'Damaged';

  @override
  String get checklistItemMissing => 'Missing';

  @override
  String get damagePosition => 'Position on boat';

  @override
  String get newDamageBadge => 'NEW DAMAGE';

  @override
  String get companySignatureSection =>
      'Charter company representative signature';

  @override
  String get companyRepName => 'Representative name';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get protocolClosedNotice =>
      'The protocol is closed (both parties signed) – read only.';

  @override
  String get handoverCertTitle => 'Vessel handover protocol';

  @override
  String get itemSails => 'Sails';

  @override
  String get itemRigging => 'Rigging';

  @override
  String get itemAnchorChain => 'Anchor and chain';

  @override
  String get itemNavInstruments => 'Navigation instruments';

  @override
  String get itemLifeJackets => 'Life jackets';

  @override
  String get itemRaft => 'Life raft';

  @override
  String get itemFirstAidKit => 'First aid kit';

  @override
  String get itemDinghyMotor => 'Dinghy and outboard motor';

  @override
  String get itemLights => 'Lights';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Additional notes';

  @override
  String get gpxImportTitle => 'GPX import';

  @override
  String get gpxImportPickFile => 'Choose GPX file';

  @override
  String get gpxTracksFound => 'Tracks found';

  @override
  String get gpxWaypointsFound => 'Waypoints found';

  @override
  String get gpxAssignTarget => 'Assign to voyage';

  @override
  String get gpxNewVoyage => 'New voyage';

  @override
  String get gpxImportButton => 'Import';

  @override
  String get gpxImportSuccess => 'GPX imported successfully.';

  @override
  String get connectionConnected => 'Connected';

  @override
  String get connectionConnecting => 'Connecting...';

  @override
  String get connectionError => 'Connection error';

  @override
  String get connectionDisconnected =>
      'Disconnected (using phone GPS / forecast)';

  @override
  String get ipAddressLabel => 'Gateway IP address';

  @override
  String get portLabel => 'Port';

  @override
  String get autoConnectLabel => 'Auto-connect on startup';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connect => 'Connect';

  @override
  String get gatewayHint =>
      'Connect your phone to the Raymarine WiFi network (e.g. WiFi-1, RayNet). The IP to enter is NOT the IP shown in Raymarine settings — it is the gateway IP of that WiFi network. Find it on your phone: Settings → WiFi → network details → Gateway. Port 2000 (TCP) is standard. Without connection the app uses phone GPS automatically.';

  @override
  String connectedToHost(String host, int port) {
    return 'Connected to $host:$port';
  }

  @override
  String get enterIpAddress => 'Enter gateway IP address';

  @override
  String connectionFailed(String error) {
    return 'Failed to connect: $error';
  }

  @override
  String get liveWind => 'Wind';

  @override
  String get liveDepth => 'Depth';

  @override
  String get liveWaterTemp => 'Water temp';

  @override
  String get liveCompass => 'Compass';

  @override
  String get liveEngine => 'Engine';

  @override
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Listen port';

  @override
  String get startListening => 'Start';

  @override
  String get stopListening => 'Stop';

  @override
  String connectionListening(String port) {
    return 'Listening UDP on port $port';
  }

  @override
  String udpHint(String port) {
    return 'Set simulator/gateway to send UDP to this phone\'s IP, port $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Listening on UDP port $port';
  }

  @override
  String get dayNotFound => 'Day not found';

  @override
  String get saved => 'Saved';

  @override
  String get trackingThisDay => 'Tracking running for this day';

  @override
  String get trackingOtherDay => 'Tracking running for another day';

  @override
  String recordCount(int n) {
    return '$n entries';
  }

  @override
  String get addManual => 'Add manual';

  @override
  String get noEntries => 'No entries';

  @override
  String get entriesAutoAdded =>
      'Entries are added automatically during tracking';

  @override
  String get deleteEntryTitle => 'Delete entry?';

  @override
  String get autoRecord => 'Automatic entry';

  @override
  String get routeSection => 'Route';

  @override
  String get fromPort => 'From';

  @override
  String get toPort => 'To';

  @override
  String get distance => 'Distance';

  @override
  String get vessel => 'Vessel';

  @override
  String get weatherSection => 'Weather';

  @override
  String get morning => 'Morning';

  @override
  String get noon => 'Noon';

  @override
  String get evening => 'Evening';

  @override
  String get windDir => 'Wind direction';

  @override
  String get seaState => 'Sea state';

  @override
  String get waveHeight => 'Wave height';

  @override
  String get dailyNote => 'Daily log';

  @override
  String get dailyNoteHint =>
      'Description of voyage, highlights, events of the day...';

  @override
  String get seaCalm => 'Calm';

  @override
  String get seaLight => 'Light';

  @override
  String get seaModerate => 'Moderate';

  @override
  String get seaRough => 'Rough';

  @override
  String get seaStormy => 'Stormy';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get newEntry => 'New entry';

  @override
  String get sailMode => 'Sail mode';

  @override
  String get sailMain => 'Main';

  @override
  String get navigationSection => 'Navigation';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get weatherSeaSection => 'Weather & sea';

  @override
  String get windSpeed => 'Wind';

  @override
  String get windDirection => 'Direction';

  @override
  String get waveHeight2 => 'Wave height';

  @override
  String get engineSection => 'Engine & tanks';

  @override
  String get engineHours => 'Engine hours';

  @override
  String get fuel => 'Fuel';

  @override
  String get fuelLevel => 'Fuel level';

  @override
  String get waterLevel => 'Water level';

  @override
  String get noteSection => 'Note';

  @override
  String get noteHint => 'Sailing conditions, events, crew change...';

  @override
  String get exportDayTitle => 'Day export';

  @override
  String get exportCharterTitle => 'Charter export';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get mapsReady => 'Maps ready – you can export';

  @override
  String generatingMaps(int current, int total) {
    return 'Generating map previews ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Export day';

  @override
  String get exportCharterBtn => 'Export charter';

  @override
  String get entriesLabel => 'Entries';

  @override
  String get routePoints => 'Route points';

  @override
  String get anchorDriftTitle => '⚓ ANCHOR DRIFTING!';

  @override
  String get anchorDriftContent =>
      'Vessel has exceeded anchor perimeter.\nCheck position immediately!';

  @override
  String get cancelAnchor => 'Cancel anchor';

  @override
  String get stopAlarm => 'Stop alarm';

  @override
  String get briefingItem1 => 'Life jackets – location and use';

  @override
  String get briefingItem2 => 'Life ring and MOB procedure';

  @override
  String get briefingItem3 => 'Flares – types and use';

  @override
  String get briefingItem4 => 'EPIRB / PLB – activation';

  @override
  String get briefingItem5 => 'VHF radio – channel 16, Mayday procedure';

  @override
  String get briefingItem6 => 'Fire extinguisher – location and use';

  @override
  String get briefingItem7 => 'First aid kit – location';

  @override
  String get briefingItem8 => 'Emergency engine stop';

  @override
  String get briefingItem9 => 'Leaks – water, gas';

  @override
  String get briefingItem10 => 'Anchor and chain – anchoring procedure';

  @override
  String get briefingItem11 => 'On-board rules';

  @override
  String get briefingItem12 => 'Emergency contacts and VHF 16';

  @override
  String get checkInItem1 => 'Boat documents (registration, insurance)';

  @override
  String get checkInItem2 => 'Safety equipment – complete';

  @override
  String get checkInItem3 => 'Fuel supplies';

  @override
  String get checkInItem4 => 'Water supplies';

  @override
  String get checkInItem5 => 'Anchor and chain – check';

  @override
  String get checkInItem6 => 'Engine – test run';

  @override
  String get checkInItem7 => 'Navigation instruments';

  @override
  String get checkInItem8 => 'Rigging – ropes and sails';

  @override
  String get checkInItem9 => 'Galley – gas, stove';

  @override
  String get checkInItem10 => 'Toilet – functionality';

  @override
  String get checkInItem11 => 'Existing damage – photo documentation';

  @override
  String get checkOutItem1 => 'Boat cleaned – exterior';

  @override
  String get checkOutItem2 => 'Boat cleaned – interior';

  @override
  String get checkOutItem3 => 'Fuel refilled';

  @override
  String get checkOutItem4 => 'Water refilled';

  @override
  String get checkOutItem5 => 'Rubbish removed';

  @override
  String get checkOutItem6 => 'Damage reported';

  @override
  String get checkOutItem7 => 'Keys handed over';

  @override
  String get gearListShort => 'Personal\nGear';

  @override
  String get colregRules => 'COLREG\nRules';

  @override
  String get checkInShort => 'Check-in\nReceiving';

  @override
  String get checkOutShort => 'Check-out\nHandover';

  @override
  String get appTagline => 'Your reliable ship\'s logbook';

  @override
  String exportSavedMsg(String path) {
    return 'Saved: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Saved: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Export error: $error';
  }

  @override
  String get generatingPdf => 'Generating PDF...';

  @override
  String get colregTitle => 'COLREG – Rules of the Road';

  @override
  String get tableOfContents => 'TABLE OF CONTENTS';

  @override
  String get inThisChapter => 'In this chapter:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Rule $n';
  }

  @override
  String get resetChecklistTitle => 'Reset checklist?';

  @override
  String get resetChecklistContent => 'All checkmarks will be erased.';

  @override
  String get reset => 'Reset';

  @override
  String get checkInReceivingTitle => 'Check-in – Receiving the boat';

  @override
  String get checkOutHandoverTitle => 'Check-out – Handing over the boat';

  @override
  String get checkInCompletedMsg => 'Boat received – all checked ✓';

  @override
  String get checkOutCompletedMsg => 'Boat returned – all in order ✓';

  @override
  String get briefingDoneMsg => 'Briefing complete – crew informed';

  @override
  String get sectionBriefed => 'Section briefed ✓';

  @override
  String get confirmSection => 'Confirm section';

  @override
  String get gearListTitle => 'Personal gear';

  @override
  String get newCategory => 'New category';

  @override
  String get add => 'Add';

  @override
  String get deleteItemTitle => 'Delete item?';

  @override
  String get allPackedMsg => 'All packed, ready to sail! 🎉';

  @override
  String get addItemLabel => 'Add item';

  @override
  String addToCategoryTitle(String category) {
    return 'Add to: $category';
  }

  @override
  String get newItemHint => 'New item...';

  @override
  String get addWaypoint => 'Add waypoint';

  @override
  String get waypointNameLabel => 'Name';

  @override
  String get skipperSignature => 'Skipper\'s signature';

  @override
  String get signWithFinger => 'Sign with your finger';

  @override
  String get clear => 'Clear';

  @override
  String get signAndExport => 'Sign & export';

  @override
  String get pleaseSign => 'Please sign before exporting';

  @override
  String get generatingPdfPreview => 'Generating PDF preview...';

  @override
  String generationError(String error) {
    return 'Generation error: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Saving and generating GPX...';

  @override
  String get editCharter => 'Edit charter';

  @override
  String get basicInfo => 'Basic information';

  @override
  String get voyageNameRequired => 'Voyage name *';

  @override
  String get dateFrom => 'Date from';

  @override
  String get dateTo => 'Date to';

  @override
  String get vesselName => 'Vessel name';

  @override
  String get vesselType => 'Vessel type';

  @override
  String get homePort => 'Home port';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Call sign';

  @override
  String get vesselLengthM => 'Length (m)';

  @override
  String get vesselBeamM => 'Beam (m)';

  @override
  String get vesselDraftM => 'Draft (m)';

  @override
  String get selectExistingVoyage => 'Select existing voyage';

  @override
  String get newVoyageForm => 'New voyage';

  @override
  String get fillFormAndBriefing => 'Fill form & sign safety briefing';

  @override
  String get notesLabel => 'Notes';

  @override
  String get statusLabel => 'Status';

  @override
  String get safetyBriefingDoneLabel => 'Safety briefing completed';

  @override
  String get checkInDoneLabel => 'Check-in completed';

  @override
  String get checkOutDoneLabel => 'Check-out completed';

  @override
  String get enterVoyageName => 'Enter voyage name';

  @override
  String daysCount(int n) {
    return '$n days';
  }

  @override
  String get selectTargetWaypoint => 'Select target waypoint';

  @override
  String get noWaypoints => 'No waypoints.';

  @override
  String get goToMap => 'Go to map';

  @override
  String get noTarget => 'No target';

  @override
  String get selectWaypointHint => 'Select waypoint...';

  @override
  String get sessionStats => 'Voyage statistics';

  @override
  String get maxSpeed => 'Max speed';

  @override
  String get avgSpeed => 'Avg. speed';

  @override
  String get sailingTime => 'Sailing time';

  @override
  String get gpsData => 'GPS Data';

  @override
  String get gpsPosition => 'Position';

  @override
  String get courseCog => 'Course (COG)';

  @override
  String get altitudeLabel => 'Altitude';

  @override
  String get dscProcedure => 'DSC PROCEDURE';

  @override
  String get voiceScript => 'VOICE SCRIPT';

  @override
  String get dscWarningUseOnly => '⚠️ USE ONLY IN CASE OF';

  @override
  String get dscWarningDanger => 'SERIOUS AND IMMINENT DANGER';

  @override
  String get dscWarningTypes => 'Fire · Sinking · Man overboard';

  @override
  String get dscProcedureSubtitle => 'Keep this procedure at VHF DSC radio';

  @override
  String get fillBeforeSailing => 'Fill in before sailing:';

  @override
  String get copyTooltip => 'Copy';

  @override
  String get scriptCopied => 'Script copied';

  @override
  String get sendOnCh16 =>
      '📻 Send on Channel 16 · High power · Repeat every 2 minutes if no response';

  @override
  String get enterAbove => '[enter in field above]';

  @override
  String get distressNature => 'Nature of distress';

  @override
  String get vesselNameLabel => 'Vessel name';

  @override
  String get numberOfPersons => 'No. of persons';

  @override
  String get additionalInfo => 'Additional info';

  @override
  String get voiceScriptTitle => 'VOICE MAYDAY SCRIPT';

  @override
  String get dscStep1 => 'Make sure the radio is switched on.';

  @override
  String get dscStep2 => 'Open the cover above the RED distress button.';

  @override
  String get dscStep3 => 'Press the RED button ONCE and release.';

  @override
  String get dscStep4 =>
      'Select the nature of distress.\n(Fire, Sinking, MOB etc.)\nIf skipped, Undesignated distress will be sent.';

  @override
  String get dscStep5 =>
      'Press and HOLD the RED button for 5 seconds to send the call.';

  @override
  String get dscStep6 =>
      'Wait up to 15 seconds for acknowledgement (shown on screen), then send voice message on Channel 16 at HIGH power.';

  @override
  String get appDescription => 'Professional sailor\'s logbook.';

  @override
  String get vesselIdTitle => 'Vessel identification';

  @override
  String get vesselIdHint =>
      'Call sign and MMSI are auto-filled in the Mayday Card.';

  @override
  String get maritimeReference => 'Maritime Reference';

  @override
  String get phonetic => 'Phonetic';

  @override
  String get flagAlphabet => 'Signal Flags';

  @override
  String get dayShapes => 'Day Shapes';

  @override
  String get marineReferenceTile => 'Signals & Alphabet';

  @override
  String get navInstruments => 'Instruments';

  @override
  String get enterPort => 'Enter port...';

  @override
  String get closeWithoutSaving => 'Close without saving';

  @override
  String get saveToDevice => 'Save to device';

  @override
  String get saveAndShare => 'Save & share';

  @override
  String get timestampCannotBeChanged => 'Entry time cannot be changed';

  @override
  String entriesShort(int n) {
    return '$n entries';
  }

  @override
  String get mainsail => 'Main';

  @override
  String get weatherConditionTitle => 'Weather condition';

  @override
  String get weatherConditionLabel => 'Condition';

  @override
  String get wcSunny => 'Sunny';

  @override
  String get wcPartlyCloudy => 'Partly cloudy';

  @override
  String get wcOvercast => 'Overcast';

  @override
  String get wcLightRain => 'Light rain';

  @override
  String get wcRain => 'Rain';

  @override
  String get wcHeavyRain => 'Heavy rain';

  @override
  String get wcDrizzle => 'Drizzle';

  @override
  String get wcThunderstorm => 'Thunderstorms';

  @override
  String get wcIsoThunderstorm => 'Isolated thunderstorms';

  @override
  String get wcHail => 'Hail';

  @override
  String get wcDust => 'Dust';

  @override
  String get wcFoggy => 'Foggy';

  @override
  String get wcWindy => 'Windy';

  @override
  String get wcCold => 'Cold';

  @override
  String get photoSection => 'Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get photoAddedToEntry => 'Photo attached';

  @override
  String get voyageStart => 'Voyage start';

  @override
  String get voyageEnd => 'Voyage end';

  @override
  String get onlineAccount => 'Online account';

  @override
  String get onlineAccountDesc => 'Online logbook sync — coming soon';

  @override
  String get register => 'Register';

  @override
  String get login => 'Log in';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm =>
      'You will be logged out. Data saved on the device will remain.';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get fullName => 'Full name';

  @override
  String get password => 'Password';

  @override
  String get userGuide => 'User Guide';

  @override
  String get guideQuickStart => 'Quick Start – 5 Steps';

  @override
  String get guideQuickStartBody =>
      '1. Open Logbook → tap + → select \"New voyage\"\n2. Enter boat name and estimated number of days\n3. Tracking starts automatically – put the phone in your pocket\n4. Add log entries during the day: time, position, note\n5. At the end of the voyage open Settings → Export PDF';

  @override
  String get guideMapTitle => 'Map';

  @override
  String get guideMapBody =>
      'The Map tab shows your current position and voyage track.\n\n• Blue dot = current position\n• Blue line = the track currently being recorded\n• Route icon – pick any voyage or day to preview its track on the map (in orange), no PDF export needed\n• Switch between satellite and map view\n• Seamarks – toggle nautical marks (wrecks, shallows, buoys)\n• Anchor icon = anchoring position (only when anchor alarm is active)\n• Import icon – load tracks and waypoints from a .gpx file (see \"GPX import\")';

  @override
  String get guideInstrTitle => 'Marine Instruments';

  @override
  String get guideInstrBody =>
      'The Instruments tab shows navigation data in real time.\n\n• SOG – speed over ground (knots)\n• TWS – true wind speed\n• TWA – true wind angle relative to the boat (green = starboard, red = port)\n• DEPTH – water depth (red = less than 5 m)\n• VMG WP – speed toward waypoint\n\nData source: phone GPS or Raymarine (TCP or UDP WiFi gateway).\nConnection settings (including the TCP/UDP choice) are in Settings → Instruments.';

  @override
  String get guideLogbookTitle => 'Voyage Logbook';

  @override
  String get guideLogbookBody =>
      'The Logbook is the main tab for managing voyages.\n\n• Tap + (FAB) → \"New voyage\" to create a charter\n• Tracking starts from this dialog – position is recorded automatically\n• Each voyage day is shown separately\n• Log entries can be added manually during the day, including engine hours, fuel and water in the \"Engine & tanks\" section\n• The logbook can be exported to PDF via the day menu\n• The handshake icon in the voyage detail opens the handover protocol (check-in/check-out)';

  @override
  String get guideMilesTitle => 'Mile Logbook';

  @override
  String get guideMilesBody =>
      'A summary of all your voyages in one place (icon in the Logbook tab).\n\n• Total nautical miles, days at sea, voyage count and night hours\n• Breakdown by year and by vessel\n• Filter by year\n• Tap a voyage (including a tracked/imported one) to fill in its logbook record – route, vessel flag, captain\'s name and qualification, signature confirming the miles\n• + button – add a historical voyage from before you started using the app (counts fully into the summaries, shown with an asterisk in the list)\n• PDF export of a certificate of miles sailed with a place to sign';

  @override
  String get guideHandoverTitle => 'Handover Protocol (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'A formal record of taking over and returning the boat on a charter – handshake icon in the voyage detail.\n\n• Equipment checklist (sails, rigging, anchor, navigation, life jackets, raft, first aid kit, dinghy, lights, bimini...) – OK / damaged / missing, with a note, position on board and a photo\n• Fuel, water and engine hours state\n• Signature of both the skipper and the charter company representative\n• The protocol becomes read-only once both have signed\n• Check-out pre-fills data from the check-in protocol and highlights new damage\n• PDF export with both signatures side by side';

  @override
  String get guideGpxImportTitle => 'GPX Import';

  @override
  String get guideGpxImportBody =>
      'Import tracks and waypoints from other navigation apps or GPS devices (icon on the Map).\n\n• Choose a .gpx file from your device\n• A multi-day export (several tracks in one file, e.g. from Garmin Explore) is merged automatically into a single voyage with one day per calendar day\n• Found tracks can also be assigned manually to an existing voyage\n• Waypoints (including from routes) are added straight to the map\n• A clear error message is shown for a corrupted file';

  @override
  String get guideWeatherTitle => 'Weather';

  @override
  String get guideWeatherBody =>
      'The Weather tab shows the forecast based on your current position.\n\n• Updates automatically when your position changes\n• Shows wind, waves, temperature and conditions for the coming hours\n• If offline, the last saved forecast is displayed';

  @override
  String get guideSafetyMobTitle => 'MOB & Anchor';

  @override
  String get guideSafetyMobBody =>
      'The Safety tab contains emergency functions.\n\nMOB (Man Overboard):\n• Hold the red MOB button to activate\n• The app records GPS position and tracks time and distance\n• Navigate back to the point of entry\n\nAnchor alarm:\n• Set the anchor radius (recommended: 2× chain/rope length)\n• Alarm vibrates if the boat drifts outside the allowed radius';

  @override
  String get guideSafetyBriefingTitle => 'Safety Briefing & MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'The Safety tab also contains reference cards.\n\n• Safety Briefing – crew checklist before departure\n• Each crew member signs with their own on-screen signature\n• Signatures are saved and automatically included in the charter PDF export\n• Handover Checklist – overview of check-in/check-out items, available even without an open voyage\n• MAYDAY card – procedure for distress call on VHF channel 16\n• COLREG – collision regulations at sea\n• Contacts – emergency numbers and contacts';

  @override
  String get guideCompassTitle => 'Sighting Compass';

  @override
  String get guideCompassBody =>
      'The Compass tab shows your magnetic bearing using the phone sensors, with the rear camera as background for taking bearings on objects.\n\n• Yellow crosshair – direction you are pointing\n• Compass strip at top – N / NE / E / SE / S / SW / W / NW\n• Numeric readout – degrees and cardinal point\n• Green dot = stable reading  ·  Orange dot = calibrating\n\nIf the reading is unstable, slowly move the phone in a figure-eight pattern to calibrate the magnetometer.\n\nAccuracy may be reduced near metal structures, speakers or electronic equipment.';

  @override
  String get guideSettingsTitle => 'Settings';

  @override
  String get guideSettingsBody =>
      '• Language – change the app language\n• Instruments – set the Raymarine WiFi gateway IP address (TCP or UDP)\n• GPS source – phone or Raymarine\n• Units – knots/km/h, metres/feet\n• Log entry frequency\n• Display – Night mode (red filter to preserve night vision)\n• Online account – sync coming soon (v2.0)\n• Data backup – see \"Data backup and restore\"\n• About – version and contact';

  @override
  String get guideBackupTitle => 'Data backup and restore';

  @override
  String get guideBackupBody =>
      'In Settings → Data backup.\n\n• Export backup – saves the whole logbook (voyages, entries, settings) into a single file (.hmbbackup) you can share by email, to the cloud, or save locally\n• Restore from backup – replaces current data with the contents of the selected backup; a safety backup of the current state is created automatically first\n• Restore is blocked while GPS voyage tracking is active\n• A backup with a newer schema than the app supports is rejected with an explanation';

  @override
  String get guideExportTitle => 'Logbook Export';

  @override
  String get guideExportBody =>
      'The logbook can be exported as a professional PDF document.\n\n1. Open Logbook → select a charter\n2. Tap the export icon or three dots → Export PDF\n3. Sign as skipper → PDF is generated\n4. PDF includes: track, log entries, photos, safety briefing with crew signatures\n5. Share via email, print or save to phone\n\nEach PDF receives a unique document ID (e.g. HMBSL-5-2026) and a revision number (Rev. 1, Rev. 2...) visible in the footer of every page. Each new export automatically increments the number — making it visible how many times the document was generated.\n\nThe QR code on the signature page contains the ID, revision and a cryptographic fingerprint of the content. Any change to the data changes the QR code.';

  @override
  String get safetyBriefingScreenTitle => 'Safety Briefing';

  @override
  String get briefingCrewSignaturesSection => 'Crew Signatures';

  @override
  String get briefingSignHere => 'Sign here';

  @override
  String get briefingClear => 'Clear';

  @override
  String get briefingSigned => 'Signed';

  @override
  String get briefingSave => 'Save Signatures';

  @override
  String get briefingSavedOk => 'Signatures saved';

  @override
  String get briefingOpenBriefing => 'Safety Briefing';

  @override
  String get briefingSkipper => 'Skipper';

  @override
  String get briefingCrew => 'Crew';

  @override
  String get briefingNoCrew =>
      'No crew defined. Add crew members in the voyage settings.';

  @override
  String get briefingDate => 'Date';

  @override
  String get briefingLocation => 'Location';

  @override
  String get briefingDoneLabel => 'Safety Briefing completed';

  @override
  String get briefingDoneSubtitle =>
      'All crew signatures are saved. No need to redo.';

  @override
  String get briefingEditSignature => 'Change signature';

  @override
  String get briefingRequiredTitle => 'Safety Briefing required';

  @override
  String get briefingRequiredBody =>
      'Complete the Safety Briefing and collect crew signatures before starting the first tracking session.';

  @override
  String get goToBriefing => 'Go to Briefing';

  @override
  String get skipperProfile => 'Skipper Profile';

  @override
  String get skipperProfileHint =>
      'These details appear in the PDF voyage export.';

  @override
  String get skipperFullName => 'Skipper Name';

  @override
  String get skipperLicenseSection => 'Skipper License';

  @override
  String get skipperLicenseType => 'License Type';

  @override
  String get skipperLicenseNumber => 'License Number';

  @override
  String get skipperLicenseAuthority => 'Issuing Authority';

  @override
  String get skipperLicenseExpiry => 'Valid Until';

  @override
  String get skipperVhfSection => 'VHF / SRC License';

  @override
  String get skipperVhfNumber => 'VHF/SRC Number';

  @override
  String get skipperVhfExpiry => 'VHF Valid Until';

  @override
  String get skipperOtherCerts => 'Other Certificates / Licenses';

  @override
  String get skipperOtherCertsHint =>
      'e.g. Yachtmaster, RYA, STCW, rescue courses...';
}
