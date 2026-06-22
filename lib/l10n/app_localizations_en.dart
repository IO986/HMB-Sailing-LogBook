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
  String get wind24h => 'Wind – 24h';

  @override
  String get waves24h => 'Waves – 24h';

  @override
  String get hourlyForecast => 'Hourly forecast';

  @override
  String get timeCol => 'Time';

  @override
  String get windCol => 'Wind';

  @override
  String get wavesCol => 'Waves';

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
}
