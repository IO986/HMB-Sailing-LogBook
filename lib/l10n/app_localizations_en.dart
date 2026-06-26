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
  String get navSettings => 'Settings';

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
  String get existingVoyage => 'Existing voyage';

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
  String get aboutApp => 'About';

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
      'Connect your phone to the boat\'s gateway WiFi network (Raymarine WiFi-1, RayNet and similar typically run on 10.0.0.1, port 2000). Without connection, the app automatically uses phone GPS and internet weather forecast.';

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
  String get engineSection => 'Engine';

  @override
  String get engineHours => 'Engine hours';

  @override
  String get fuel => 'Fuel';

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
  String get onlineAccountDesc => 'Sync your logbook to logbook.hmba.boats';

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
      'The Map tab shows your current position and voyage track.\n\n• Blue dot = current position\n• Red line = track sailed\n• Switch between satellite and map view\n• Anchor icon = anchoring position (only when anchor alarm is active)';

  @override
  String get guideInstrTitle => 'Marine Instruments';

  @override
  String get guideInstrBody =>
      'The Instruments tab shows navigation data in real time.\n\n• SOG – speed over ground (knots)\n• TWS – true wind speed\n• TWA – true wind angle relative to the boat (green = starboard, red = port)\n• DEPTH – water depth (red = less than 5 m)\n• VMG WP – speed toward waypoint\n\nData source: phone GPS or Raymarine (WiFi gateway).\nConnection settings are in Settings → Instruments.';

  @override
  String get guideLogbookTitle => 'Voyage Logbook';

  @override
  String get guideLogbookBody =>
      'The Logbook is the main tab for managing voyages.\n\n• Tap + (FAB) → \"New voyage\" to create a charter\n• Tracking starts from this dialog – position is recorded automatically\n• Each voyage day is shown separately\n• Log entries can be added manually during the day\n• The logbook can be exported to PDF via the day menu';

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
      'The Safety tab also contains reference cards.\n\n• Safety Briefing – crew checklist before departure\n• MAYDAY card – procedure for distress call on VHF channel 16\n• COLREG – collision regulations at sea\n• Contacts – emergency numbers and contacts';

  @override
  String get guideSettingsTitle => 'Settings';

  @override
  String get guideSettingsBody =>
      '• Language – change the app language\n• Instruments – set the Raymarine WiFi gateway IP address\n• GPS source – phone or Raymarine\n• Units – knots/km/h, metres/feet\n• Log entry frequency\n• Export – PDF or CSV\n• About – version and contact';

  @override
  String get guideExportTitle => 'Logbook Export';

  @override
  String get guideExportBody =>
      'The logbook can be exported as a professional PDF document.\n\n1. Open Logbook → select a charter\n2. Tap the export icon or three dots → Export PDF\n3. Choose which days to include\n4. PDF includes: track, log entries, photos and signatures\n5. Share via email, print or save to phone';
}
