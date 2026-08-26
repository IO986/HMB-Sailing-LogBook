// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get poiTypeAnchorage => 'Αγκυροβόλιο';

  @override
  String get poiTypeMarina => 'Μαρίνα';

  @override
  String get poiTypeFuel => 'Πρατήριο καυσίμων';

  @override
  String get poiTypeHarbour => 'Λιμάνι';

  @override
  String get poiVhfChannel => 'Κανάλι VHF';

  @override
  String get poiPhone => 'Τηλέφωνο';

  @override
  String get poiCannotOpen => 'Δεν είναι δυνατό το άνοιγμα';

  @override
  String get poiWebsite => 'Ιστότοπος';

  @override
  String get poiEmail => 'Email';

  @override
  String get poiCapacity => 'Χωρητικότητα';

  @override
  String get poiServices => 'Υπηρεσίες';

  @override
  String get poiSaveAsWaypoint => 'Αποθήκευση ως σημείο πορείας';

  @override
  String poiWaypointSaved(String name) {
    return 'Το σημείο πορείας \"$name\" αποθηκεύτηκε';
  }

  @override
  String get poiSource => 'Πηγή: OpenStreetMap';

  @override
  String get mapLayerSatellite => 'Δορυφόρος';

  @override
  String get mapLayerMap => 'Χάρτης';

  @override
  String get mapLayers => 'Επίπεδα';

  @override
  String get mapSeamarks => 'Ναυτικά σημάδια';

  @override
  String get mapDepths => 'Βάθη';

  @override
  String mapDepthHere(String depth) {
    return 'Βάθος εδώ: $depth';
  }

  @override
  String get mapDepthNoData =>
      'Δεν υπάρχουν δεδομένα βάθους για αυτό το σημείο';

  @override
  String get mapStationNone => 'Κανένας σταθμός δεν μετρά σε αυτή την περιοχή';

  @override
  String mapStationCount(int count) {
    return 'Σταθμοί: $count';
  }

  @override
  String weatherModelSource(String model) {
    return 'Μοντέλο: $model';
  }

  @override
  String get weatherOfflineNoAge =>
      'Χωρίς σήμα — τελευταία αποθηκευμένη πρόγνωση';

  @override
  String weatherOfflineSince(String when) {
    return 'Χωρίς σήμα — πρόγνωση από $when';
  }

  @override
  String weatherStaleSince(String when) {
    return 'Παλιά πρόγνωση — λήφθηκε $when';
  }

  @override
  String get warningNoDetail => 'Οι λεπτομέρειες δεν φορτώθηκαν.';

  @override
  String get warningSourceMeteoalarm => 'Πηγή: MeteoAlarm';

  @override
  String warningLanguageNote(String lang) {
    return 'Το κείμενο είναι στα: $lang';
  }

  @override
  String get mapHarbours => 'Λιμάνια & αγκυροβόλια';

  @override
  String get mapZoomInForPois =>
      'Μεγεθύνετε τον χάρτη για φόρτωση λιμανιών και αγκυροβολίων';

  @override
  String get mapRainRadar => 'Ραντάρ βροχής';

  @override
  String get mapTools => 'Εργαλεία';

  @override
  String get mapVoyageOverview => 'Επισκόπηση πλου';

  @override
  String get playbackTitle => 'Αναπαραγωγή πλου';

  @override
  String get playbackSpeed => 'Ταχύτητα';

  @override
  String get playbackNoTrack =>
      'Δεν έχει καταγραφεί διαδρομή γι\' αυτή την ημέρα';

  @override
  String playbackAtTime(String time) {
    return 'Κατάσταση στις $time';
  }

  @override
  String get mapRuler => 'Χάρακας / διαδρομή';

  @override
  String get mapDownloadOffline => 'Λήψη περιοχής εκτός σύνδεσης';

  @override
  String get mapGpsDisabled => 'Το GPS είναι απενεργοποιημένο';

  @override
  String get mapLocationDenied => 'Η τοποθεσία δεν επιτρέπεται';

  @override
  String get mapFollowGps => 'Παρακολούθηση GPS';

  @override
  String mapAreaTooLarge(int count) {
    return 'Η περιοχή είναι πολύ μεγάλη ($count πλακίδια). Μεγεθύνετε και δοκιμάστε ξανά.';
  }

  @override
  String get mapLivePreview => 'Ζωντανά (τρέχουσα καταγραφή)';

  @override
  String get mapWholeVoyage => 'Ολόκληρος ο πλους';

  @override
  String get offlineSheetTitle => 'Χάρτης εκτός σύνδεσης της ορατής περιοχής';

  @override
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb) {
    return 'Χάρτης + ναυτικά σημάδια, ζουμ $minZ–$maxZ, $tiles πλακίδια (~$mb MB). Οι ληφθείσες περιοχές λειτουργούν στη θάλασσα χωρίς σήμα.';
  }

  @override
  String offlineDone(int n) {
    return 'Ολοκληρώθηκε — αποθηκεύτηκαν $n πλακίδια';
  }

  @override
  String offlineDoneErrors(int n) {
    return 'Ολοκληρώθηκε με σφάλματα: απέτυχε η λήψη $n πλακιδίων';
  }

  @override
  String get downloadAction => 'Λήψη';

  @override
  String get rulerTapHint => 'Πατήστε σημεία στον χάρτη';

  @override
  String get mapEntryPhoto => 'Εγγραφή φωτογραφίας';

  @override
  String get mapEntryNote => 'Εγγραφή ημερολογίου';

  @override
  String get openSettingsAction => 'Άνοιγμα ρυθμίσεων';

  @override
  String get morseConverter => 'Μετατροπέας κειμένου → Μορς';

  @override
  String saveError(String error) {
    return 'Σφάλμα αποθήκευσης: $error';
  }

  @override
  String get languageName => 'Ελληνικά';

  @override
  String get navMap => 'Χάρτης';

  @override
  String get navTracking => 'Καταγραφή';

  @override
  String get navLogbook => 'Ημερολόγιο';

  @override
  String get navWeather => 'Καιρός';

  @override
  String get navSafety => 'Ασφάλεια';

  @override
  String get navCompass => 'Πυξίδα';

  @override
  String get navSettings => 'Ρυθμίσεις';

  @override
  String get navCustomizeTitle => 'Κάτω μενού';

  @override
  String get navCustomizeHint =>
      'Πατήστε και σύρετε για να αλλάξετε τη σειρά των εικονιδίων. Χρησιμοποιήστε τον διακόπτη για να κρύψετε μια καρτέλα από το κάτω μενού — οι Ρυθμίσεις εμφανίζονται πάντα.';

  @override
  String get navAlwaysShown => 'Πάντα ορατό';

  @override
  String get navIconSizeLabel => 'Μέγεθος εικονιδίων';

  @override
  String get navOpenHiddenTitle => 'Άνοιγμα κρυμμένων καρτελών';

  @override
  String get cameraPermissionDenied =>
      'Η πρόσβαση στην κάμερα απορρίφθηκε. Ενεργοποιήστε την στις ρυθμίσεις της συσκευής.';

  @override
  String get cameraUnavailable => 'Η κάμερα δεν είναι διαθέσιμη';

  @override
  String get compassCalibrationNote =>
      'Μαγνητική πυξίδα. Η ακρίβεια μπορεί να επηρεαστεί από κοντινά μέταλλα ή ηλεκτρονικά. Αν δεν είναι βαθμονομημένη, κινήστε τη συσκευή σχηματίζοντας ένα οκτάρι.';

  @override
  String get cancel => 'Άκυρο';

  @override
  String get delete => 'Διαγραφή';

  @override
  String get edit => 'Επεξεργασία';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get yes => 'Ναι';

  @override
  String get no => 'Όχι';

  @override
  String get ok => 'Εντάξει';

  @override
  String get close => 'Κλείσιμο';

  @override
  String get retry => 'Επανάληψη';

  @override
  String get share => 'Κοινοποίηση';

  @override
  String get selectAll => 'Επιλογή όλων';

  @override
  String get error => 'Σφάλμα';

  @override
  String errorMsg(String msg) {
    return 'Σφάλμα: $msg';
  }

  @override
  String get pressBackToExit => 'Πατήστε ξανά Πίσω για έξοδο';

  @override
  String get trackingRunningTitle => 'Η καταγραφή εκτελείται';

  @override
  String get trackingRunningContent =>
      'Η καταγραφή είναι ενεργή. Τι θέλετε να κάνετε;';

  @override
  String get stopAndExit => 'Διακοπή και έξοδος';

  @override
  String get keepRunning => 'Συνέχιση καταγραφής';

  @override
  String get marineInstrumentsTitle => 'Ναυτικά όργανα';

  @override
  String get marineInstrumentsPrompt =>
      'Θέλετε να συνδέσετε την εφαρμογή με ναυτικά όργανα (π.χ. Raymarine μέσω πύλης WiFi); Τότε η εφαρμογή θα διαβάζει GPS, άνεμο, βάθος και άλλα δεδομένα απευθείας από το σκάφος.\n\nΧωρίς σύνδεση θα χρησιμοποιηθεί το GPS του τηλεφώνου και η πρόγνωση καιρού από το διαδίκτυο – μπορείτε να το αλλάξετε ανά πάσα στιγμή στις Ρυθμίσεις.';

  @override
  String get notNow => 'Όχι τώρα';

  @override
  String get setupConnection => 'Ρύθμιση σύνδεσης';

  @override
  String get autoDetectAction => 'Αυτόματος εντοπισμός';

  @override
  String get autoDetectWifiHintTitle => 'Συνδεθείτε πρώτα στο WiFi του σκάφους';

  @override
  String get autoDetectWifiHintBody =>
      'Ελέγξτε στις Ρυθμίσεις → WiFi του τηλεφώνου ότι είστε συνδεδεμένοι στο δίκτυο των ναυτικών οργάνων (π.χ. RayNet, WiFi-1). Έπειτα η εφαρμογή θα προσπαθήσει να βρει την πύλη σε αυτό το δίκτυο αυτόματα.';

  @override
  String get openWifiSettings => 'Ρυθμίσεις WiFi';

  @override
  String get continueAction => 'Συνέχεια';

  @override
  String get autoDetecting => 'Αναζήτηση οργάνων στο δίκτυο WiFi…';

  @override
  String get autoDetectFailed =>
      'Δεν βρέθηκε πύλη κοντά. Βεβαιωθείτε ότι είστε στο δίκτυο WiFi του σκάφους ή εισάγετε την IP χειροκίνητα στις Ρυθμίσεις.';

  @override
  String autoDetectSuccess(String host) {
    return 'Συνδέθηκε με $host';
  }

  @override
  String get guidePromptTitle => 'Νέος εδώ; Γρήγορος οδηγός';

  @override
  String get guidePromptBody =>
      'Αυτή η εφαρμογή περιλαμβάνει έναν σύντομο οδηγό χρήσης – χάρτης, ημερολόγιο, καιρός, λίστα ελέγχου ασφαλείας και άλλα. Θέλετε μια γρήγορη ματιά τώρα; Θα τον βρίσκετε πάντα αργότερα στις Ρυθμίσεις → Οδηγός χρήσης.';

  @override
  String get guidePromptAction => 'Δείξε μου τον οδηγό';

  @override
  String get notifPromptTitle => 'Να επιτραπούν οι ειδοποιήσεις;';

  @override
  String get notifPromptBody =>
      'Όσο καταγράφεται ένας πλους, μια ειδοποίηση παραμένει στη γραμμή κατάστασης και στην οθόνη κλειδώματος — ώστε να βλέπετε ότι η καταγραφή είναι ενεργή και να την προσεγγίζετε γρήγορα. Χωρίς την άδεια, το σύστημα μπορεί να περιορίσει την καταγραφή στο παρασκήνιο.';

  @override
  String get notifPromptAllow => 'Να επιτραπεί';

  @override
  String get trackingActiveTitle => 'Καταγραφή ενεργή';

  @override
  String get trackingTitle => 'Καταγραφή';

  @override
  String get waitingForGps => 'Αναμονή για GPS...';

  @override
  String get gpsUnavailable => 'Το GPS δεν είναι διαθέσιμο';

  @override
  String get lastKnownPosition => 'Τελευταία γνωστή θέση';

  @override
  String get accuracy => 'Ακρίβεια';

  @override
  String get logbookBtn => 'Ημερολόγιο';

  @override
  String get stop => 'Διακοπή';

  @override
  String get stopTrackingDay => 'Διακοπή καταγραφής;';

  @override
  String get startVoyage => 'Έναρξη πλου';

  @override
  String get starting => 'Εκκίνηση...';

  @override
  String get newVoyage => 'Νέος πλους';

  @override
  String get multiday => 'Πολυήμερος';

  @override
  String get standalone => 'Μεμονωμένος';

  @override
  String get voyageName => 'Όνομα πλου';

  @override
  String get voyageNameOptional => 'Όνομα (προαιρετικό)';

  @override
  String get voyageNameHint => 'π.χ. Εκδρομή στον κόλπο';

  @override
  String get existingVoyage => 'Συνέχιση υπάρχοντος πλου';

  @override
  String get newVoyageDropdown => '— Νέος πλους —';

  @override
  String get firstVoyageHint =>
      'Πρώτος πλους – συμπληρώστε τα βασικά στοιχεία:';

  @override
  String get briefingRequiredHint =>
      'Η καταγραφή μπορεί να ξεκινήσει μόνο αφού ολοκληρωθεί η Ενημέρωση Ασφαλείας για αυτόν τον πλου.';

  @override
  String get briefingPending => 'Απαιτείται ΕΑ';

  @override
  String get briefingPendingListWarning =>
      'Η Ενημέρωση Ασφαλείας δεν ολοκληρώθηκε – η καταγραφή δεν μπορεί να ξεκινήσει ακόμη';

  @override
  String get estimatedDays => 'Εκτιμώμενος αριθμός ημερών:';

  @override
  String get logFrequency => 'Συχνότητα καταχωρήσεων';

  @override
  String get startTracking => 'Έναρξη καταγραφής';

  @override
  String get trackingInProgress => 'Καταγράψτε τον πλου σας';

  @override
  String dayNofTotal(int n, int total) {
    return 'Ημέρα $n από $total';
  }

  @override
  String get newDay => '(νέα ημέρα)';

  @override
  String get endVoyageTitle => 'Τερματισμός πλου;';

  @override
  String get endVoyageContent =>
      'Φτάσατε στην τελευταία προγραμματισμένη ημέρα του πλου.\n\nΘα συνεχιστεί ο πλους αύριο;';

  @override
  String get decideLayer => 'Απόφαση αργότερα';

  @override
  String get continuesTomorrow => 'Συνεχίζεται αύριο';

  @override
  String get endVoyage => 'Τερματισμός πλου';

  @override
  String get newMultidayVoyage => 'Νέος πολυήμερος πλους';

  @override
  String get deleteCharterTitle => 'Διαγραφή πλου;';

  @override
  String get deleteCharterContent =>
      'Όλες οι ημέρες και οι καταχωρήσεις θα διαγραφούν.';

  @override
  String get cannotDeleteWhileTracking =>
      'Δεν μπορείτε να διαγράψετε πλου όσο η καταγραφή είναι ενεργή.';

  @override
  String get noVoyages => 'Κανένας πλους';

  @override
  String get createFirstCharter => 'Δημιούργησε τον πρώτο σου πλου';

  @override
  String get briefingDone => 'Ενημέρωση ✓';

  @override
  String get checkInDone => 'Παραλαβή ✓';

  @override
  String get checkOutDone => 'Παράδοση ✓';

  @override
  String get voyageNotFound => 'Ο πλους δεν βρέθηκε';

  @override
  String get unknownVessel => 'Άγνωστο σκάφος';

  @override
  String get captain => 'Κυβερνήτης';

  @override
  String get crew => 'Πλήρωμα';

  @override
  String get total => 'Σύνολο';

  @override
  String voyageDaysCount(int n) {
    return 'Ημέρες πλου ($n)';
  }

  @override
  String get bulkDelete => 'Μαζική διαγραφή';

  @override
  String get noDays =>
      'Καμία ημέρα.\nΞεκινήστε την καταγραφή και η πρώτη ημέρα θα δημιουργηθεί αυτόματα.';

  @override
  String get deleteDayTitle => 'Διαγραφή ημέρας;';

  @override
  String deleteDayContent(String day) {
    return 'Όλες οι καταχωρήσεις για $day θα διαγραφούν.';
  }

  @override
  String get exportPdf => 'Εξαγωγή PDF';

  @override
  String get selectDaysTitle => 'Επιλέξτε ημέρες προς διαγραφή';

  @override
  String deleteCount(int n) {
    return 'Διαγραφή ($n)';
  }

  @override
  String get safety => 'Ασφάλεια';

  @override
  String get mobHoldToActivate => 'Κρατήστε για ενεργοποίηση';

  @override
  String get mobActive => '⚠️ MOB ΕΝΕΡΓΟ';

  @override
  String get mobTime => 'Χρόνος';

  @override
  String get mobDistance => 'Απόσταση';

  @override
  String get mobDirection => 'Κατεύθυνση';

  @override
  String get navigateToMob => 'Πλοήγηση προς MOB';

  @override
  String get gpsPositionNotAvailable => 'Η θέση GPS δεν είναι διαθέσιμη!';

  @override
  String get anchorAlarm => 'Συναγερμός άγκυρας';

  @override
  String get drifting => 'ΕΚΤΡΟΠΗ';

  @override
  String get anchorRadiusLabel => 'Ακτίνα άγκυρας';

  @override
  String get activate => 'Ενεργοποίηση';

  @override
  String get deactivate => 'Απενεργοποίηση';

  @override
  String get safetyBriefingCard => 'Ενημέρωση Ασφαλείας';

  @override
  String get maydayCard => 'Κάρτα Mayday';

  @override
  String get yachtHandover => 'Παράδοση σκάφους';

  @override
  String get gearList => 'Λίστα εξοπλισμού';

  @override
  String get pdfEntriesSection => 'Καταχωρήσεις ημερολογίου';

  @override
  String get pdfSkipperMessage => 'Αναφορά κυβερνήτη';

  @override
  String get pdfWeatherSection => 'Καιρός';

  @override
  String get pdfDaySummary => 'Ημερήσια σύνοψη';

  @override
  String get pdfDaysOverview => 'Επισκόπηση ημερών';

  @override
  String get pdfVoyageSummary => 'Σύνοψη πλου';

  @override
  String get pdfCrewSection => 'Πλήρωμα';

  @override
  String get pdfSignatures => 'Υπογραφές';

  @override
  String get pdfCrewSignatures => 'Υπογραφές πληρώματος';

  @override
  String get pdfSkipperSignature => 'Υπογραφή κυβερνήτη';

  @override
  String get pdfSkipperLicences => 'Κυβερνήτης – άδειες';

  @override
  String get pdfSafetyBriefing => 'Ενημέρωση ασφαλείας';

  @override
  String get pdfChecklistSection => 'Λίστα ελέγχου';

  @override
  String get pdfMoreNotes => 'Πρόσθετες σημειώσεις';

  @override
  String get pdfIntegrityCheck => 'Έλεγχος ακεραιότητας εγγράφου';

  @override
  String get pdfHandoverTitle => 'Πρωτόκολλο παράδοσης';

  @override
  String get pdfMilesTitle => 'Πιστοποιητικό ναυτικών μιλίων';

  @override
  String get pdfDeparture => 'Αναχώρηση';

  @override
  String get pdfArrival => 'Άφιξη';

  @override
  String get pdfTotalLabel => 'Σύνολο';

  @override
  String get pdfDayCount => 'Ημέρες';

  @override
  String get pdfEngineHours => 'Ώρες μηχανής';

  @override
  String get pdfFuelLabel => 'Καύσιμο';

  @override
  String get pdfWaterLabel => 'Νερό';

  @override
  String get pdfVesselLabel => 'Σκάφος';

  @override
  String get pdfSkipperLabel => 'Κυβερνήτης';

  @override
  String get pdfDateLabel => 'Ημερομηνία';

  @override
  String get pdfColFrom => 'Από';

  @override
  String get pdfColTo => 'Προς';

  @override
  String get pdfColEntriesShort => 'Καταχ.';

  @override
  String get pdfColTimeUtc => 'Ώρα UTC';

  @override
  String get pdfColWind => 'Άνεμος';

  @override
  String get pdfColPropulsion => 'Πρόωση';

  @override
  String get pdfColWeatherShort => 'Καιρ.';

  @override
  String get pdfColNote => 'Σημείωση';

  @override
  String get pdfColDay => 'Ημέρα';

  @override
  String get pdfColItem => 'Στοιχείο';

  @override
  String get pdfColStatus => 'Κατάσταση';

  @override
  String get pdfColNotePosition => 'Σημείωση / θέση';

  @override
  String get pdfColPhoto => 'Φωτογραφία';

  @override
  String get pdfColDateRange => 'Ημερομηνία από-έως';

  @override
  String get pdfColArea => 'Περιοχή';

  @override
  String get pdfColRole => 'Ρόλος';

  @override
  String get pdfNameLabel => 'Όνομα';

  @override
  String get pdfLicenceLabel => 'Άδεια';

  @override
  String get pdfIssuedValidLabel => 'Εκδόθηκε / ισχύει';

  @override
  String get pdfOtherCertsLabel => 'Άλλα πιστ.';

  @override
  String get pdfContinued => 'συνέχεια';

  @override
  String get pdfExportedAt => 'Εξήχθη';

  @override
  String get pdfSignedAt => 'Υπογράφηκε';

  @override
  String get pdfSignatureLabel => 'Υπογραφή';

  @override
  String get pdfDatePlaceLabel => 'Ημερομηνία / τόπος';

  @override
  String get pdfManualEntryNote =>
      '* χειροκίνητη καταχώρηση (εισήχθη με το χέρι)';

  @override
  String get pdfStatTotalDistance => 'Συνολική απόσταση';

  @override
  String get pdfStatLogEntries => 'Καταχωρήσεις ημερολογίου';

  @override
  String get pdfStatMaxBeaufort => 'Μέγ. Beaufort';

  @override
  String get pdfStatDaysAtSea => 'Ημέρες στη θάλασσα';

  @override
  String get pdfStatVoyages => 'Αριθμός πλόων';

  @override
  String get pdfStatNightHours => 'Νυχτερινές ώρες';

  @override
  String get pdfFuelShort => 'Κ';

  @override
  String get pdfWaterShort => 'Ν';

  @override
  String get pdfNoData => 'Χωρίς δεδομένα';

  @override
  String get pdfMapUnavailable => 'Ο χάρτης GPS δεν είναι διαθέσιμος';

  @override
  String get pdfUnsigned => 'Ανυπόγραφο';

  @override
  String get pdfNoSignatures => 'Χωρίς υπογραφές';

  @override
  String get pdfSha256Label => 'Σύνοψη SHA-256 των δεδομένων του ημερολογίου:';

  @override
  String get pdfVerifyQr => 'QR επαλήθευσης';

  @override
  String get pdfSbLifejackets => 'Σωσίβια – θέση και χρήση';

  @override
  String get pdfSbLifebuoy => 'Κυκλικό σωσίβιο και διαδικασία MOB';

  @override
  String get pdfSbFlares => 'Φωτοβολίδες – τύποι και χρήση';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – ενεργοποίηση';

  @override
  String get pdfSbVhf => 'Ασύρματος VHF – κανάλι 16, διαδικασία Mayday';

  @override
  String get pdfSbExtinguisher => 'Πυροσβεστήρας – θέση και χρήση';

  @override
  String get pdfSbFirstAid => 'Κιτ πρώτων βοηθειών – θέση';

  @override
  String get pdfSbEngineStop => 'Σβήσιμο μηχανής έκτακτης ανάγκης';

  @override
  String get pdfSbLeaks => 'Διαρροές – νερό, αέριο';

  @override
  String get pdfSbAnchor => 'Άγκυρα και αλυσίδα – διαδικασία αγκυροβολίας';

  @override
  String get pdfSbRules => 'Κανόνες εν πλω';

  @override
  String get pdfSbEmergencyContacts => 'Επαφές έκτακτης ανάγκης και VHF 16';

  @override
  String get pdfBriefingDeclaration =>
      'Όλα τα μέλη του πληρώματος ενημερώθηκαν και κατανόησαν τους κανόνες ασφαλείας και το επιβεβαιώνουν με την υπογραφή τους.';

  @override
  String get pdfHashCoverage =>
      'Η σύνοψη καλύπτει το όνομα του πλου, το σκάφος, το πλήρωμα και κάθε καταχώρηση (ώρα UTC, GPS, ταχύτητα, πορεία). Οποιαδήποτε αλλαγή στα δεδομένα αλλάζει τη σύνοψη.';

  @override
  String get pdfForCharterCompany => 'Για την εταιρεία ναύλωσης';

  @override
  String get dutyRoster => 'Πλήρωμα σε βάρδια';

  @override
  String get dutyStartAction => 'Ανάληψη βάρδιας';

  @override
  String get dutyEndAction => 'Λήξη';

  @override
  String get dutyStartTitle => 'Ποιος αναλαμβάνει βάρδια;';

  @override
  String get dutyRunningChip => 'ΣΕ ΒΑΡΔΙΑ';

  @override
  String dutySince(String time) {
    return 'από $time';
  }

  @override
  String dutyElapsed(int h, int m) {
    return '$h ώ $m λεπτά';
  }

  @override
  String get dutyNobodyOnDuty => 'Κανείς δεν είναι σε βάρδια';

  @override
  String get dutyInspectionView => 'Προβολή για έλεγχο';

  @override
  String get dutyRosterHistory => 'Πρόγραμμα βαρδιών';

  @override
  String get dutyAddRetrospective => 'Προσθήκη προηγούμενης βάρδιας';

  @override
  String get dutyEditTitle => 'Επεξεργασία βάρδιας';

  @override
  String get dutyDeleteTitle => 'Διαγραφή βάρδιας;';

  @override
  String dutyDeleteConfirm(String name) {
    return 'Η εγγραφή βάρδιας για $name θα διαγραφεί.';
  }

  @override
  String get dutyNoCrewDefined => 'Δεν έχει οριστεί πλήρωμα για αυτόν τον πλου';

  @override
  String get dutyDefineCrew => 'Προσθήκη πληρώματος';

  @override
  String get dutyErrorEndBeforeStart =>
      'Η λήξη πρέπει να είναι μετά την έναρξη.';

  @override
  String dutyErrorOverlap(String name) {
    return 'Ο/Η $name είναι ήδη σε βάρδια εκείνη την ώρα.';
  }

  @override
  String get dutyErrorFutureStart => 'Η έναρξη δεν μπορεί να είναι στο μέλλον.';

  @override
  String get dutyNoteLabel => 'Σημείωση';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'Σε βάρδια για $hours ώ — μήπως έμεινε ανοιχτή;';
  }

  @override
  String get dutyFrom => 'Από';

  @override
  String get dutyTo => 'Έως';

  @override
  String get dutyToOngoing => '— ακόμη σε βάρδια';

  @override
  String get dutySelectPerson => 'Επιλέξτε μέλος πληρώματος';

  @override
  String get dutyNoRecords => 'Δεν έχουν καταγραφεί ακόμη βάρδιες';

  @override
  String get logDutySection => 'Πλήρωμα σε βάρδια';

  @override
  String get logDutyStillRunning => 'σε εξέλιξη';

  @override
  String get logEventAnchorDropped => 'Άγκυρα ρίχτηκε';

  @override
  String get logEventAnchorRaised => 'Άγκυρα σηκώθηκε';

  @override
  String get logEventDriftOut => 'Εκτροπή – υπέρβαση ορίου';

  @override
  String get logEventDriftIn => 'Εκτροπή – το σκάφος επέστρεψε';

  @override
  String logEventDutyStart(String name) {
    return 'Σε βάρδια: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Εκτός βάρδιας: $name';
  }

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Επαφές έκτακτης ανάγκης';

  @override
  String get backToToc => 'Επιστροφή στα περιεχόμενα';

  @override
  String get briefingComplete => 'Η ενημέρωση ολοκληρώθηκε';

  @override
  String get updateByPosition => 'Ενημέρωση κατά θέση';

  @override
  String get detectedByGps => 'εντοπίστηκε μέσω GPS';

  @override
  String get locationUnavailable =>
      '📍 Η θέση δεν είναι διαθέσιμη – εμφανίζονται παγκόσμιες επαφές';

  @override
  String get detectingLocation => 'Εντοπισμός θέσης...';

  @override
  String get tapToCall => 'Πατήστε για κλήση';

  @override
  String cannotCall(String name) {
    return 'Αδυναμία κλήσης: $name';
  }

  @override
  String get vhfChannel16 =>
      'Κανάλι VHF 16 – χρησιμοποιήστε τον ασύρματο του σκάφους';

  @override
  String get hmbHandbook => 'Εγχειρίδιο HMB';

  @override
  String get checkInLabel => 'Παραλαβή (παραλαβή του σκάφους)';

  @override
  String get checkOutLabel => 'Παράδοση (παράδοση του σκάφους)';

  @override
  String get charterCheckCard => 'Πλους';

  @override
  String get weatherTitle => 'Καιρός & Θάλασσα';

  @override
  String get updateForecast => 'Ενημέρωση πρόγνωσης';

  @override
  String get gpsNotAvailableTracking =>
      'Το GPS δεν είναι διαθέσιμο – ενεργοποιήστε την καταγραφή';

  @override
  String get downloadingForecast => 'Λήψη πρόγνωσης...';

  @override
  String get loadingForecast => 'Φόρτωση πρόγνωσης...';

  @override
  String get noConnection => 'Δεν υπάρχει διαθέσιμη σύνδεση';

  @override
  String get pressRefreshWhenOnline => 'Πατήστε ανανέωση όταν είστε online';

  @override
  String get noWeatherData => 'Χωρίς δεδομένα καιρού';

  @override
  String get forecastAutoDownload =>
      'Η πρόγνωση θα ληφθεί αυτόματα όταν ξεκινήσει η καταγραφή ή πατήστε Ανανέωση.';

  @override
  String get enableGpsFirst => 'Ενεργοποιήστε πρώτα το GPS / την καταγραφή';

  @override
  String get downloadForecast => 'Λήψη πρόγνωσης';

  @override
  String downloadError(String error) {
    return 'Σφάλμα λήψης: $error';
  }

  @override
  String get liveInstrumentData => 'Ζωντανά δεδομένα ναυτικών οργάνων';

  @override
  String get windRelative => 'Άνεμος (σχετ.)';

  @override
  String get windTrue => 'Άνεμος (πραγμ.)';

  @override
  String get depthLabel => 'Βάθος';

  @override
  String get waterTempLabel => 'Θερμ. νερού';

  @override
  String get courseTrue => 'Πορεία (πραγμ.)';

  @override
  String get courseMag => 'Πορεία (μαγν.)';

  @override
  String get engineLabel => 'Μηχανή';

  @override
  String get wavesLabel => 'Κύματα';

  @override
  String get pressureLabel => 'Πίεση';

  @override
  String get airTempLabel => 'Αέρας';

  @override
  String get waterLabel => 'Νερό';

  @override
  String get wind24h => 'Άνεμος – 3 ημέρες';

  @override
  String get waves24h => 'Κύματα – 3 ημέρες';

  @override
  String get hourlyForecast => 'Πρόγνωση 3 ημερών';

  @override
  String get dailyForecast => 'Ημερήσια θερμοκρασία';

  @override
  String get timeCol => 'Ώρα';

  @override
  String get windCol => 'Άνεμος';

  @override
  String get wavesCol => 'Κύματα';

  @override
  String get rainCol => 'Βροχή';

  @override
  String get beaufort0 => 'Νηνεμία';

  @override
  String get beaufort1 => 'Σχεδόν άπνοια';

  @override
  String get beaufort2 => 'Ασθενής αύρα';

  @override
  String get beaufort3 => 'Ελαφρά αύρα';

  @override
  String get beaufort4 => 'Μέτριος άνεμος';

  @override
  String get beaufort5 => 'Ζωηρός άνεμος';

  @override
  String get beaufort6 => 'Ισχυρός άνεμος';

  @override
  String get beaufort7 => 'Σχεδόν θυελλώδης';

  @override
  String get beaufort8 => 'Θυελλώδης';

  @override
  String get beaufort9 => 'Πολύ θυελλώδης';

  @override
  String get beaufort10 => 'Θύελλα';

  @override
  String get beaufort11 => 'Σφοδρή θύελλα';

  @override
  String get beaufort12 => 'Τυφώνας';

  @override
  String get sunAndMoonCard => 'Ήλιος & Σελήνη';

  @override
  String get sunriseLabel => 'Ανατολή';

  @override
  String get sunsetLabel => 'Δύση';

  @override
  String get moonPhaseLabel => 'Φάση σελήνης';

  @override
  String get moonIlluminationLabel => 'Φωτισμένη';

  @override
  String get moonPhaseNew => 'Νέα Σελήνη';

  @override
  String get moonPhaseWaxingCrescent => 'Αύξουσα Μηνίσκος';

  @override
  String get moonPhaseFirstQuarter => 'Πρώτο Τέταρτο';

  @override
  String get moonPhaseWaxingGibbous => 'Αύξουσα Αμφίκυρτη';

  @override
  String get moonPhaseFull => 'Πανσέληνος';

  @override
  String get moonPhaseWaningGibbous => 'Φθίνουσα Αμφίκυρτη';

  @override
  String get moonPhaseLastQuarter => 'Τελευταίο Τέταρτο';

  @override
  String get moonPhaseWaningCrescent => 'Φθίνουσα Μηνίσκος';

  @override
  String get noSunMoonGps => 'Απαιτείται θέση GPS για ανατολή/δύση';

  @override
  String get oceanCurrentsTitle => 'Ωκεάνια Ρεύματα';

  @override
  String get oceanCurrentsTooltip => 'Ωκεάνια ρεύματα';

  @override
  String get oceanCurrentsDisclaimer =>
      'Μόνο δεδομένα αναφοράς (τυπική κατεύθυνση/ταχύτητα από πλοηγικούς χάρτες) — όχι για πλοήγηση ακριβείας· τα ρεύματα μεταβάλλονται εποχιακά.';

  @override
  String get tideCardTitle => 'Παλίρροια';

  @override
  String get nextHighTideLabel => 'Επόμενη πλημμυρίδα';

  @override
  String get nextLowTideLabel => 'Επόμενη άμπωτη';

  @override
  String get noTideData => 'Δεν υπάρχουν ακόμη δεδομένα παλίρροιας';

  @override
  String get downloadTides => 'Λήψη πρόγνωσης παλίρροιας';

  @override
  String get downloadingTides => 'Λήψη πρόγνωσης παλίρροιας...';

  @override
  String get tideMslWarning =>
      'Τα ύψη είναι πάνω από τη μέση στάθμη της θάλασσας, όχι από τη στάθμη χάρτη — μην τα χρησιμοποιείτε ποτέ για το βάθος κάτω από την καρίνα.';

  @override
  String get tideNoCoverage =>
      'Δεν υπάρχουν δεδομένα παλίρροιας για αυτή τη θέση — είναι εκτός της περιοχής θαλάσσιας πρόγνωσης.';

  @override
  String get tideDownloadFailed =>
      'Δεν ήταν δυνατή η λήψη της πρόγνωσης παλίρροιας. Ελέγξτε τη σύνδεσή σας και δοκιμάστε ξανά.';

  @override
  String get tideForecastExpired => 'Η αποθηκευμένη πρόγνωση παλίρροιας έληξε.';

  @override
  String tideForecastFarAway(int km) {
    return 'Η πρόγνωση λήφθηκε $km χλμ από εδώ — κάντε νέα λήψη για αυτή τη θέση.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Λήφθηκε $when — κάντε νέα λήψη για την πιο πρόσφατη πρόγνωση.';
  }

  @override
  String get oceanCurrentCardTitle => 'Θαλάσσιο ρεύμα';

  @override
  String get oceanCurrentSetsToward =>
      'Κατευθύνεται προς (ταχύτητα σε κόμβους)';

  @override
  String get oceanCurrentNoCoverage =>
      'Δεν υπάρχουν δεδομένα ρεύματος για αυτή τη θέση.';

  @override
  String get oceanCurrentUnavailable =>
      'Η πρόγνωση ρεύματος δεν είναι διαθέσιμη — ελέγξτε τη σύνδεσή σας.';

  @override
  String get tideOtherArea => 'Πρόγνωση για άλλη περιοχή';

  @override
  String get tideAreaSearchLabel => 'Λιμάνι, πόλη ή κόλπος';

  @override
  String get tideAreaSearchHint => 'π.χ. Σπλιτ';

  @override
  String get tideAreaNoResults => 'Δεν βρέθηκε τίποτα — δοκιμάστε άλλο όνομα.';

  @override
  String tideForecastForArea(String place) {
    return 'Πρόγνωση για $place';
  }

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get measurementUnits => 'Μονάδες μέτρησης';

  @override
  String get temperature => 'Θερμοκρασία';

  @override
  String get depthWaves => 'Βάθος / κύματα';

  @override
  String get wind => 'Άνεμος';

  @override
  String get language => 'Γλώσσα';

  @override
  String get appLanguage => 'Γλώσσα εφαρμογής';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get displaySettings => 'Οθόνη';

  @override
  String get nightMode => 'Νυχτερινή λειτουργία';

  @override
  String get nightModeDesc =>
      'Κόκκινο φίλτρο για διατήρηση της νυχτερινής όρασης';

  @override
  String get aboutApp => 'Σχετικά';

  @override
  String get backupSection => 'Αντίγραφο ασφαλείας δεδομένων';

  @override
  String get exportBackup => 'Εξαγωγή αντιγράφου';

  @override
  String get exportBackupDesc =>
      'Αποθηκεύει όλο το ημερολόγιο (πλόες, καταχωρήσεις, ρυθμίσεις) σε ένα αρχείο';

  @override
  String get restoreBackup => 'Επαναφορά από αντίγραφο';

  @override
  String get restoreBackupDesc =>
      'Αντικαθιστά τα τρέχοντα δεδομένα με το περιεχόμενο ενός επιλεγμένου αρχείου αντιγράφου';

  @override
  String get restoreBlockedTrackingTitle => 'Η καταγραφή GPS εκτελείται';

  @override
  String get restoreBlockedTrackingBody =>
      'Διακόψτε την ενεργή καταγραφή πλου πριν επαναφέρετε ένα αντίγραφο.';

  @override
  String get restoreSchemaTooNewTitle =>
      'Το αντίγραφο είναι από νεότερη έκδοση';

  @override
  String get restoreSchemaTooNewBody =>
      'Αυτό το αντίγραφο δημιουργήθηκε από νεότερη έκδοση της εφαρμογής από την εγκατεστημένη. Ενημερώστε πρώτα την εφαρμογή.';

  @override
  String get restoreConfirmTitle => 'Επαναφορά από αντίγραφο;';

  @override
  String get restoreConfirmBody =>
      'Τα τρέχοντα δεδομένα θα αντικατασταθούν με το περιεχόμενο του αντιγράφου. Θα δημιουργηθεί πρώτα αυτόματα ένα αντίγραφο ασφαλείας της τρέχουσας κατάστασης.';

  @override
  String get restoreSuccess =>
      'Τα δεδομένα επαναφέρθηκαν επιτυχώς από το αντίγραφο.';

  @override
  String get restoreInvalidFile =>
      'Το επιλεγμένο αρχείο δεν είναι έγκυρο αντίγραφο του HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Ημερολόγιο μιλίων';

  @override
  String get totalNm => 'Σύνολο ΝΜ';

  @override
  String get daysAtSea => 'Ημέρες στη θάλασσα';

  @override
  String get voyageCount => 'Αριθμός πλόων';

  @override
  String get nightHoursLabel => 'Νυχτερινές ώρες';

  @override
  String get byYear => 'Ανά έτος';

  @override
  String get byVessel => 'Ανά σκάφος';

  @override
  String get addHistoricalVoyage => 'Προσθήκη ιστορικού πλου';

  @override
  String get editHistoricalVoyage => 'Επεξεργασία ιστορικού πλου';

  @override
  String get deleteHistoricalVoyageConfirm =>
      'Διαγραφή αυτού του ιστορικού πλου;';

  @override
  String get manualEntryExplanation =>
      '* χειροκίνητη καταχώρηση (εισαγωγή με το χέρι)';

  @override
  String get roleLabel => 'Ρόλος επί του σκάφους';

  @override
  String get roleSkipper => 'Κυβερνήτης';

  @override
  String get roleCoSkipper => 'Υποκυβερνήτης';

  @override
  String get roleCrew => 'Πλήρωμα';

  @override
  String get areaLabel => 'Περιοχή / διαδρομή';

  @override
  String get distanceNmLabel => 'Απόσταση (ΝΜ)';

  @override
  String get daysCountLabel => 'Αριθμός ημερών';

  @override
  String get milesCertificateTitle => 'Πιστοποιητικό διανυθέντων μιλίων';

  @override
  String get logbookRecordTitle => 'Εγγραφή ημερολογίου';

  @override
  String get logbookTrackedHint =>
      'Οι ημερομηνίες, τα μίλια, η περιοχή και ο ρόλος υπολογίζονται από την καταγραφή/εισαγωγή.';

  @override
  String get vesselFlag => 'Σημαία νηολόγησης';

  @override
  String get captainFirstName => 'Όνομα κυβερνήτη';

  @override
  String get captainLastName => 'Επώνυμο κυβερνήτη';

  @override
  String get captainQualification => 'Ανώτατο πτυχίο που κατέχει';

  @override
  String get logbookSignatureSection => 'Υπογραφή επιβεβαίωσης των μιλίων';

  @override
  String get addSignature => 'Προσθήκη υπογραφής';

  @override
  String get filterAllYears => 'Όλα τα έτη';

  @override
  String get filterCustomRange => 'Προσαρμοσμένο εύρος';

  @override
  String get handoverMenuTitle => 'Πρωτόκολλο παράδοσης';

  @override
  String get checkInProtocol => 'Πρωτόκολλο παραλαβής';

  @override
  String get checkOutProtocol => 'Πρωτόκολλο παράδοσης';

  @override
  String get nextStepLabel => 'Επόμενο βήμα';

  @override
  String get readyToTrackHint => 'Έτοιμο για έναρξη καταγραφής';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Βήμα $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Ενημέρωση\nΑσφαλείας';

  @override
  String get handoverChecklistShort => 'Λίστα\nΠαράδοσης';

  @override
  String get safetyBriefingRefTitle => 'Ενημέρωση ασφαλείας';

  @override
  String get handoverChecklistRefTitle => 'Λίστα ελέγχου παράδοσης';

  @override
  String get handoverDateTime => 'Ημερομηνία και ώρα';

  @override
  String get handoverLocation => 'Τοποθεσία (μαρίνα)';

  @override
  String get checklistItemOk => 'Εντάξει';

  @override
  String get checklistItemDamaged => 'Κατεστραμμένο';

  @override
  String get checklistItemMissing => 'Λείπει';

  @override
  String get damagePosition => 'Θέση στο σκάφος';

  @override
  String get newDamageBadge => 'ΝΕΑ ΖΗΜΙΑ';

  @override
  String get companySignatureSection =>
      'Υπογραφή εκπροσώπου εταιρείας ναύλωσης';

  @override
  String get companyRepName => 'Όνομα εκπροσώπου';

  @override
  String get companyNameLabel => 'Όνομα εταιρείας';

  @override
  String get protocolClosedNotice =>
      'Το πρωτόκολλο έχει κλείσει (υπέγραψαν και τα δύο μέρη) – μόνο για ανάγνωση.';

  @override
  String get handoverCertTitle => 'Πρωτόκολλο παράδοσης σκάφους';

  @override
  String get itemSails => 'Πανιά';

  @override
  String get itemRigging => 'Εξάρτια';

  @override
  String get itemAnchorChain => 'Άγκυρα και αλυσίδα';

  @override
  String get itemNavInstruments => 'Όργανα πλοήγησης';

  @override
  String get itemLifeJackets => 'Σωσίβια';

  @override
  String get itemRaft => 'Σωσίβια σχεδία';

  @override
  String get itemFirstAidKit => 'Κιτ πρώτων βοηθειών';

  @override
  String get itemDinghyMotor => 'Βοηθητική λέμβος και εξωλέμβια μηχανή';

  @override
  String get itemLights => 'Φώτα';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Πρόσθετες σημειώσεις';

  @override
  String get gpxImportTitle => 'Εισαγωγή GPX';

  @override
  String get gpxImportPickFile => 'Επιλέξτε αρχείο GPX';

  @override
  String get gpxTracksFound => 'Ίχνη που βρέθηκαν';

  @override
  String get gpxWaypointsFound => 'Σημεία που βρέθηκαν';

  @override
  String get gpxAssignTarget => 'Ανάθεση σε πλου';

  @override
  String get gpxNewVoyage => 'Νέος πλους';

  @override
  String get gpxImportButton => 'Εισαγωγή';

  @override
  String get gpxImportSuccess => 'Το GPX εισήχθη επιτυχώς.';

  @override
  String get connectionConnected => 'Συνδεδεμένο';

  @override
  String get connectionConnecting => 'Σύνδεση...';

  @override
  String get connectionError => 'Σφάλμα σύνδεσης';

  @override
  String get connectionDisconnected =>
      'Αποσυνδεδεμένο (χρήση GPS / πρόγνωσης τηλεφώνου)';

  @override
  String get ipAddressLabel => 'Διεύθυνση IP πύλης';

  @override
  String get portLabel => 'Θύρα';

  @override
  String get autoConnectLabel => 'Αυτόματη σύνδεση κατά την εκκίνηση';

  @override
  String get disconnect => 'Αποσύνδεση';

  @override
  String get connect => 'Σύνδεση';

  @override
  String get gatewayHint =>
      'Συνδέστε το τηλέφωνό σας στο δίκτυο WiFi Raymarine (π.χ. WiFi-1, RayNet). Η IP που πρέπει να εισάγετε ΔΕΝ είναι η IP που φαίνεται στις ρυθμίσεις Raymarine — είναι η IP της πύλης αυτού του δικτύου WiFi. Βρείτε την στο τηλέφωνο: Ρυθμίσεις → WiFi → λεπτομέρειες δικτύου → Πύλη. Η θύρα 2000 (TCP) είναι η τυπική. Χωρίς σύνδεση η εφαρμογή χρησιμοποιεί αυτόματα το GPS του τηλεφώνου.';

  @override
  String connectedToHost(String host, int port) {
    return 'Συνδέθηκε με $host:$port';
  }

  @override
  String get enterIpAddress => 'Εισάγετε τη διεύθυνση IP της πύλης';

  @override
  String connectionFailed(String error) {
    return 'Αποτυχία σύνδεσης: $error';
  }

  @override
  String get liveWind => 'Άνεμος';

  @override
  String get liveDepth => 'Βάθος';

  @override
  String get liveWaterTemp => 'Θερμ. νερού';

  @override
  String get liveCompass => 'Πυξίδα';

  @override
  String get liveEngine => 'Μηχανή';

  @override
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Θύρα ακρόασης';

  @override
  String get startListening => 'Έναρξη';

  @override
  String get stopListening => 'Διακοπή';

  @override
  String connectionListening(String port) {
    return 'Ακρόαση UDP στη θύρα $port';
  }

  @override
  String udpHint(String port) {
    return 'Ρυθμίστε τον προσομοιωτή/πύλη να στέλνει UDP στην IP αυτού του τηλεφώνου, θύρα $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Ακρόαση στη θύρα UDP $port';
  }

  @override
  String get dayNotFound => 'Η ημέρα δεν βρέθηκε';

  @override
  String get saved => 'Αποθηκεύτηκε';

  @override
  String get trackingThisDay => 'Η καταγραφή εκτελείται για αυτή την ημέρα';

  @override
  String get trackingOtherDay => 'Η καταγραφή εκτελείται για άλλη ημέρα';

  @override
  String recordCount(int n) {
    return '$n καταχωρήσεις';
  }

  @override
  String get addManual => 'Χειροκίνητη προσθήκη';

  @override
  String get noEntries => 'Καμία καταχώρηση';

  @override
  String get entriesAutoAdded =>
      'Οι καταχωρήσεις προστίθενται αυτόματα κατά την καταγραφή';

  @override
  String get deleteEntryTitle => 'Διαγραφή καταχώρησης;';

  @override
  String get autoRecord => 'Αυτόματη καταχώρηση';

  @override
  String get routeSection => 'Διαδρομή';

  @override
  String get fromPort => 'Από';

  @override
  String get toPort => 'Προς';

  @override
  String get distance => 'Απόσταση';

  @override
  String get vessel => 'Σκάφος';

  @override
  String get weatherSection => 'Καιρός';

  @override
  String get morning => 'Πρωί';

  @override
  String get noon => 'Μεσημέρι';

  @override
  String get evening => 'Βράδυ';

  @override
  String get windDir => 'Κατεύθυνση ανέμου';

  @override
  String get seaState => 'Κατάσταση θάλασσας';

  @override
  String get waveHeight => 'Ύψος κύματος';

  @override
  String get dailyNote => 'Ημερήσιο ημερολόγιο';

  @override
  String get dailyNoteHint =>
      'Περιγραφή πλου, σημαντικά σημεία, γεγονότα της ημέρας...';

  @override
  String get seaCalm => 'Ήρεμη';

  @override
  String get seaLight => 'Ελαφριά';

  @override
  String get seaModerate => 'Μέτρια';

  @override
  String get seaRough => 'Ταραγμένη';

  @override
  String get seaStormy => 'Θυελλώδης';

  @override
  String get editEntry => 'Επεξεργασία καταχώρησης';

  @override
  String get newEntry => 'Νέα καταχώρηση';

  @override
  String get sailMode => 'Λειτουργία ιστίων';

  @override
  String get sailMain => 'Μαΐστρα';

  @override
  String get navigationSection => 'Πλοήγηση';

  @override
  String get latitude => 'Γεωγραφικό πλάτος';

  @override
  String get longitude => 'Γεωγραφικό μήκος';

  @override
  String get weatherSeaSection => 'Καιρός & θάλασσα';

  @override
  String get mapStationWindLayer => 'Σταθμοί – μετρημένα';

  @override
  String get mapStationDistance => 'Απόσταση από το σκάφος';

  @override
  String get windGust => 'Ριπή';

  @override
  String get mapStationSourceMetar =>
      'Πηγή: METAR – αναφορά αεροδρομίου (NOAA)';

  @override
  String get radarTitle => 'Ραντάρ βροχόπτωσης';

  @override
  String get radarRefresh => 'Ανανέωση εικόνας';

  @override
  String get radarUnavailable =>
      'Η εικόνα του ραντάρ δεν φορτώθηκε. Δοκίμασε ξανά όταν έχεις σήμα.';

  @override
  String get radarSourceDhmz => 'Πηγή: DHMZ – meteo.hr';

  @override
  String get weatherSourceInstruments => 'Μετρήθηκε από τα όργανα του σκάφους';

  @override
  String weatherSourceStation(String name) {
    return 'Μετρήθηκε στον σταθμό $name';
  }

  @override
  String weatherSourceStationAt(String name, String km) {
    return 'Μετρήθηκε στον σταθμό $name, $km km μακριά';
  }

  @override
  String get weatherSourceStationUnknown => 'Μετρήθηκε σε μετεωρολογικό σταθμό';

  @override
  String get weatherSourceModel => 'Μοντέλο πρόγνωσης, όχι μέτρηση';

  @override
  String get windSpeed => 'Άνεμος';

  @override
  String get windDirection => 'Κατεύθυνση';

  @override
  String get waveHeight2 => 'Ύψος κύματος';

  @override
  String get engineSection => 'Μηχανή & δεξαμενές';

  @override
  String get engineHours => 'Ώρες μηχανής';

  @override
  String get fuel => 'Καύσιμο';

  @override
  String get fuelLevel => 'Στάθμη καυσίμου';

  @override
  String get waterLevel => 'Στάθμη νερού';

  @override
  String get noteSection => 'Σημείωση';

  @override
  String get noteHint => 'Συνθήκες πλου, γεγονότα, αλλαγή πληρώματος...';

  @override
  String get quickPhotoLogTitle => 'Γρήγορη καταχώρηση';

  @override
  String get quickPhotoNoteHint => 'Τι είναι αυτό; (προαιρετικό)';

  @override
  String get exportDayTitle => 'Εξαγωγή ημέρας';

  @override
  String get exportCharterTitle => 'Εξαγωγή πλου';

  @override
  String get loadingData => 'Φόρτωση δεδομένων...';

  @override
  String get mapsReady => 'Οι χάρτες είναι έτοιμοι – μπορείτε να εξάγετε';

  @override
  String generatingMaps(int current, int total) {
    return 'Δημιουργία προεπισκοπήσεων χάρτη ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Εξαγωγή ημέρας';

  @override
  String get exportCharterBtn => 'Εξαγωγή πλου';

  @override
  String get entriesLabel => 'Καταχωρήσεις';

  @override
  String get routePoints => 'Σημεία διαδρομής';

  @override
  String get anchorDriftTitle => '⚓ ΕΚΤΡΟΠΗ ΑΓΚΥΡΑΣ!';

  @override
  String get anchorDriftContent =>
      'Το σκάφος υπερέβη το όριο της άγκυρας.\nΕλέγξτε τη θέση αμέσως!';

  @override
  String get cancelAnchor => 'Ακύρωση άγκυρας';

  @override
  String get stopAlarm => 'Διακοπή συναγερμού';

  @override
  String get briefingItem1 => 'Σωσίβια – θέση και χρήση';

  @override
  String get briefingItem2 => 'Κυκλικό σωσίβιο και διαδικασία MOB';

  @override
  String get briefingItem3 => 'Φωτοβολίδες – τύποι και χρήση';

  @override
  String get briefingItem4 => 'EPIRB / PLB – ενεργοποίηση';

  @override
  String get briefingItem5 => 'Ασύρματος VHF – κανάλι 16, διαδικασία Mayday';

  @override
  String get briefingItem6 => 'Πυροσβεστήρας – θέση και χρήση';

  @override
  String get briefingItem7 => 'Κιτ πρώτων βοηθειών – θέση';

  @override
  String get briefingItem8 => 'Σβήσιμο μηχανής έκτακτης ανάγκης';

  @override
  String get briefingItem9 => 'Διαρροές – νερό, αέριο';

  @override
  String get briefingItem10 => 'Άγκυρα και αλυσίδα – διαδικασία αγκυροβολίας';

  @override
  String get briefingItem11 => 'Κανόνες επί του σκάφους';

  @override
  String get briefingItem12 => 'Επαφές έκτακτης ανάγκης και VHF 16';

  @override
  String get checkInItem1 => 'Έγγραφα σκάφους (νηολόγηση, ασφάλεια)';

  @override
  String get checkInItem2 => 'Εξοπλισμός ασφαλείας – πλήρης';

  @override
  String get checkInItem3 => 'Αποθέματα καυσίμου';

  @override
  String get checkInItem4 => 'Αποθέματα νερού';

  @override
  String get checkInItem5 => 'Άγκυρα και αλυσίδα – έλεγχος';

  @override
  String get checkInItem6 => 'Μηχανή – δοκιμαστική λειτουργία';

  @override
  String get checkInItem7 => 'Όργανα πλοήγησης';

  @override
  String get checkInItem8 => 'Εξάρτια – σκοινιά και πανιά';

  @override
  String get checkInItem9 => 'Κουζίνα – αέριο, εστία';

  @override
  String get checkInItem10 => 'Τουαλέτα – λειτουργικότητα';

  @override
  String get checkInItem11 => 'Υπάρχουσες ζημιές – φωτογραφική τεκμηρίωση';

  @override
  String get checkOutItem1 => 'Σκάφος καθαρισμένο – εξωτερικά';

  @override
  String get checkOutItem2 => 'Σκάφος καθαρισμένο – εσωτερικά';

  @override
  String get checkOutItem3 => 'Καύσιμο ανεφοδιασμένο';

  @override
  String get checkOutItem4 => 'Νερό ανεφοδιασμένο';

  @override
  String get checkOutItem5 => 'Απορρίμματα αφαιρέθηκαν';

  @override
  String get checkOutItem6 => 'Ζημιές αναφέρθηκαν';

  @override
  String get checkOutItem7 => 'Κλειδιά παραδόθηκαν';

  @override
  String get gearListShort => 'Προσωπικός\nΕξοπλισμός';

  @override
  String get colregRules => 'Κανόνες\nCOLREG';

  @override
  String get checkInShort => 'Παραλαβή\nΠαραλαβή';

  @override
  String get checkOutShort => 'Παράδοση\nΠαράδοση';

  @override
  String get appTagline => 'Το αξιόπιστο ημερολόγιο του σκάφους σας';

  @override
  String exportSavedMsg(String path) {
    return 'Αποθηκεύτηκε: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Αποθηκεύτηκε: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Σφάλμα εξαγωγής: $error';
  }

  @override
  String get generatingPdf => 'Δημιουργία PDF...';

  @override
  String get colregTitle => 'COLREG – Κανόνες Αποφυγής Συγκρούσεων';

  @override
  String get tableOfContents => 'ΠΕΡΙΕΧΟΜΕΝΑ';

  @override
  String get inThisChapter => 'Σε αυτό το κεφάλαιο:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Κανόνας $n';
  }

  @override
  String get resetChecklistTitle => 'Επαναφορά λίστας ελέγχου;';

  @override
  String get resetChecklistContent => 'Όλα τα σημάδια επιλογής θα διαγραφούν.';

  @override
  String get reset => 'Επαναφορά';

  @override
  String get checkInReceivingTitle => 'Παραλαβή – Παραλαβή του σκάφους';

  @override
  String get checkOutHandoverTitle => 'Παράδοση – Παράδοση του σκάφους';

  @override
  String get checkInCompletedMsg => 'Σκάφος παρελήφθη – όλα ελέγχθηκαν ✓';

  @override
  String get checkOutCompletedMsg => 'Σκάφος επεστράφη – όλα εντάξει ✓';

  @override
  String get briefingDoneMsg =>
      'Η ενημέρωση ολοκληρώθηκε – το πλήρωμα ενημερώθηκε';

  @override
  String get sectionBriefed => 'Η ενότητα καλύφθηκε ✓';

  @override
  String get confirmSection => 'Επιβεβαίωση ενότητας';

  @override
  String get gearListTitle => 'Προσωπικός εξοπλισμός';

  @override
  String get newCategory => 'Νέα κατηγορία';

  @override
  String get add => 'Προσθήκη';

  @override
  String get deleteItemTitle => 'Διαγραφή στοιχείου;';

  @override
  String get allPackedMsg => 'Όλα ετοιμασμένα, έτοιμοι για απόπλου! 🎉';

  @override
  String get addItemLabel => 'Προσθήκη στοιχείου';

  @override
  String addToCategoryTitle(String category) {
    return 'Προσθήκη σε: $category';
  }

  @override
  String get newItemHint => 'Νέο στοιχείο...';

  @override
  String get addWaypoint => 'Προσθήκη σημείου πορείας';

  @override
  String get editWaypoint => 'Επεξεργασία σημείου πορείας';

  @override
  String get deleteWaypointTitle => 'Διαγραφή σημείου πορείας;';

  @override
  String deleteWaypointNavActive(String name) {
    return 'Η πλοήγηση προς $name είναι ενεργή. Η διαγραφή του σημείου θα την απενεργοποιήσει.';
  }

  @override
  String get waypointNameLabel => 'Όνομα';

  @override
  String get skipperSignature => 'Υπογραφή κυβερνήτη';

  @override
  String get skipperNameLabel => 'Όνομα κυβερνήτη';

  @override
  String get signWithFinger => 'Υπογράψτε με το δάχτυλό σας';

  @override
  String get clear => 'Καθαρισμός';

  @override
  String get signAndExport => 'Υπογραφή & εξαγωγή';

  @override
  String get pleaseSign => 'Υπογράψτε πριν την εξαγωγή';

  @override
  String get generatingPdfPreview => 'Δημιουργία προεπισκόπησης PDF...';

  @override
  String generationError(String error) {
    return 'Σφάλμα δημιουργίας: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Αποθήκευση και δημιουργία GPX...';

  @override
  String get editCharter => 'Επεξεργασία πλου';

  @override
  String get basicInfo => 'Βασικές πληροφορίες';

  @override
  String get voyageNameRequired => 'Όνομα πλου *';

  @override
  String get dateFrom => 'Ημερομηνία από';

  @override
  String get dateTo => 'Ημερομηνία έως';

  @override
  String get vesselName => 'Όνομα σκάφους';

  @override
  String get vesselType => 'Τύπος σκάφους';

  @override
  String get homePort => 'Λιμάνι νηολόγησης';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Διακριτικό κλήσης';

  @override
  String get vesselLengthM => 'Μήκος (μ)';

  @override
  String get vesselBeamM => 'Πλάτος (μ)';

  @override
  String get vesselDraftM => 'Βύθισμα (μ)';

  @override
  String get selectExistingVoyage => 'Επιλέξτε υπάρχοντα πλου';

  @override
  String get newVoyageForm => 'Νέος πλους';

  @override
  String get fillFormAndBriefing =>
      'Συμπληρώστε τη φόρμα & υπογράψτε την ενημέρωση ασφαλείας';

  @override
  String get notesLabel => 'Σημειώσεις';

  @override
  String get statusLabel => 'Κατάσταση';

  @override
  String get safetyBriefingDoneLabel => 'Η ενημέρωση ασφαλείας ολοκληρώθηκε';

  @override
  String get checkInDoneLabel => 'Η παραλαβή ολοκληρώθηκε';

  @override
  String get checkOutDoneLabel => 'Η παράδοση ολοκληρώθηκε';

  @override
  String get enterVoyageName => 'Εισάγετε όνομα πλου';

  @override
  String daysCount(int n) {
    return '$n ημέρες';
  }

  @override
  String get selectTargetWaypoint => 'Επιλέξτε σημείο-στόχο';

  @override
  String get noWaypoints => 'Κανένα σημείο πορείας.';

  @override
  String get goToMap => 'Μετάβαση στον χάρτη';

  @override
  String get noTarget => 'Χωρίς στόχο';

  @override
  String get selectWaypointHint => 'Πλοήγηση σε σημείο πορείας';

  @override
  String get sessionStats => 'Στατιστικά πλου';

  @override
  String get maxSpeed => 'Μέγιστη ταχύτητα';

  @override
  String get avgSpeed => 'Μέση ταχύτητα';

  @override
  String get sailingTime => 'Χρόνος πλου';

  @override
  String get gpsData => 'Δεδομένα GPS';

  @override
  String get gpsPosition => 'Θέση';

  @override
  String get courseCog => 'Πορεία (COG)';

  @override
  String get altitudeLabel => 'Υψόμετρο';

  @override
  String get dscProcedure => 'ΔΙΑΔΙΚΑΣΙΑ DSC';

  @override
  String get voiceScript => 'ΦΩΝΗΤΙΚΟ ΚΕΙΜΕΝΟ';

  @override
  String get dscWarningUseOnly => '⚠️ ΧΡΗΣΗ ΜΟΝΟ ΣΕ ΠΕΡΙΠΤΩΣΗ';

  @override
  String get dscWarningDanger => 'ΣΟΒΑΡΟΥ ΚΑΙ ΑΜΕΣΟΥ ΚΙΝΔΥΝΟΥ';

  @override
  String get dscWarningTypes => 'Φωτιά · Βύθιση · Άνθρωπος στη θάλασσα';

  @override
  String get dscProcedureSubtitle =>
      'Κρατήστε αυτή τη διαδικασία κοντά στον ασύρματο VHF DSC';

  @override
  String get fillBeforeSailing => 'Συμπληρώστε πριν τον απόπλου:';

  @override
  String get copyTooltip => 'Αντιγραφή';

  @override
  String get scriptCopied => 'Το κείμενο αντιγράφηκε';

  @override
  String get sendOnCh16 =>
      '📻 Εκπομπή στο Κανάλι 16 · Υψηλή ισχύς · Επαναλάβετε κάθε 2 λεπτά αν δεν υπάρχει απάντηση';

  @override
  String get enterAbove => '[εισάγετε στο παραπάνω πεδίο]';

  @override
  String get distressNature => 'Φύση του κινδύνου';

  @override
  String get vesselNameLabel => 'Όνομα σκάφους';

  @override
  String get numberOfPersons => 'Αρ. ατόμων';

  @override
  String get additionalInfo => 'Πρόσθετες πληροφορίες';

  @override
  String get voiceScriptTitle => 'ΦΩΝΗΤΙΚΟ ΚΕΙΜΕΝΟ MAYDAY';

  @override
  String get dscStep1 => 'Βεβαιωθείτε ότι ο ασύρματος είναι ενεργοποιημένος.';

  @override
  String get dscStep2 =>
      'Ανοίξτε το κάλυμμα πάνω από το ΚΟΚΚΙΝΟ κουμπί κινδύνου.';

  @override
  String get dscStep3 => 'Πατήστε το ΚΟΚΚΙΝΟ κουμπί ΜΙΑ φορά και αφήστε το.';

  @override
  String get dscStep4 =>
      'Επιλέξτε τη φύση του κινδύνου.\n(Φωτιά, Βύθιση, MOB κ.λπ.)\nΑν παραλειφθεί, θα σταλεί Απροσδιόριστος κίνδυνος.';

  @override
  String get dscStep5 =>
      'Πατήστε και ΚΡΑΤΗΣΤΕ το ΚΟΚΚΙΝΟ κουμπί για 5 δευτερόλεπτα για να στείλετε την κλήση.';

  @override
  String get dscStep6 =>
      'Περιμένετε έως 15 δευτερόλεπτα για επιβεβαίωση (εμφανίζεται στην οθόνη), έπειτα στείλτε φωνητικό μήνυμα στο Κανάλι 16 σε ΥΨΗΛΗ ισχύ.';

  @override
  String get appDescription => 'Επαγγελματικό ημερολόγιο ιστιοπλόου.';

  @override
  String get vesselIdTitle => 'Ταυτότητα σκάφους';

  @override
  String get vesselIdHint =>
      'Το διακριτικό κλήσης και το MMSI συμπληρώνονται αυτόματα στην Κάρτα Mayday.';

  @override
  String get maritimeReference => 'Ναυτική Αναφορά';

  @override
  String get phonetic => 'Φωνητικό';

  @override
  String get flagAlphabet => 'Σημαίες Σινιάλων';

  @override
  String get dayShapes => 'Ημερήσια Σχήματα';

  @override
  String get marineReferenceTile => 'Σινιάλα & Αλφάβητο';

  @override
  String get navInstruments => 'Όργανα σκάφους';

  @override
  String get enterPort => 'Εισάγετε λιμάνι...';

  @override
  String get closeWithoutSaving => 'Κλείσιμο χωρίς αποθήκευση';

  @override
  String get saveToDevice => 'Αποθήκευση στη συσκευή';

  @override
  String get saveAndShare => 'Αποθήκευση & κοινοποίηση';

  @override
  String get timestampCannotBeChanged =>
      'Η ώρα της καταχώρησης δεν μπορεί να αλλάξει';

  @override
  String entriesShort(int n) {
    return '$n καταχωρήσεις';
  }

  @override
  String get mainsail => 'Μαΐστρα';

  @override
  String get weatherConditionTitle => 'Καιρικές συνθήκες';

  @override
  String get weatherConditionLabel => 'Συνθήκη';

  @override
  String get wcSunny => 'Ηλιόλουστος';

  @override
  String get wcPartlyCloudy => 'Μερικώς νεφελώδης';

  @override
  String get wcOvercast => 'Συννεφιασμένος';

  @override
  String get wcLightRain => 'Ασθενής βροχή';

  @override
  String get wcRain => 'Βροχή';

  @override
  String get wcHeavyRain => 'Ισχυρή βροχή';

  @override
  String get wcDrizzle => 'Ψιχάλα';

  @override
  String get wcThunderstorm => 'Καταιγίδες';

  @override
  String get wcIsoThunderstorm => 'Μεμονωμένες καταιγίδες';

  @override
  String get wcHail => 'Χαλάζι';

  @override
  String get wcDust => 'Σκόνη';

  @override
  String get wcFoggy => 'Ομιχλώδης';

  @override
  String get wcWindy => 'Θυελλώδης';

  @override
  String get wcCold => 'Ψύχος';

  @override
  String get photoSection => 'Φωτογραφία';

  @override
  String get camera => 'Κάμερα';

  @override
  String get gallery => 'Συλλογή';

  @override
  String get addPhoto => 'Προσθήκη φωτογραφίας';

  @override
  String get photoAddedToEntry => 'Η φωτογραφία επισυνάφθηκε';

  @override
  String get voyageStart => 'Έναρξη πλου';

  @override
  String get voyageEnd => 'Λήξη πλου';

  @override
  String get onlineAccount => 'Διαδικτυακός λογαριασμός';

  @override
  String get onlineAccountDesc =>
      'Διαδικτυακός συγχρονισμός ημερολογίου — σύντομα διαθέσιμος';

  @override
  String get register => 'Εγγραφή';

  @override
  String get login => 'Σύνδεση';

  @override
  String get logout => 'Αποσύνδεση';

  @override
  String get logoutConfirm =>
      'Θα αποσυνδεθείτε. Τα δεδομένα που είναι αποθηκευμένα στη συσκευή θα παραμείνουν.';

  @override
  String get notLoggedIn => 'Δεν είστε συνδεδεμένος';

  @override
  String get fullName => 'Πλήρες όνομα';

  @override
  String get password => 'Κωδικός';

  @override
  String get userGuide => 'Οδηγός Χρήσης';

  @override
  String get guideQuickStart => 'Γρήγορη Εκκίνηση – 5 Βήματα';

  @override
  String get guideQuickStartBody =>
      '1. Πατήστε το μεγάλο κουμπί \"Έναρξη Πλου\" στην κορυφή (στον Χάρτη, το Ημερολόγιο ή τα Όργανα) – επιλέξτε τη συχνότητα καταγραφής και η καταγραφή ξεκινά, δεν χρειάζεται να συμπληρώσετε τίποτε άλλο πρώτα\n2. Αν έχετε ανοιχτό πλου, η εφαρμογή ρωτά αν θα τον συνεχίσετε ή θα ξεκινήσετε νέα εγγραφή\n3. Συμπληρώστε τα στοιχεία που λείπουν (παραλαβή, ενημέρωση ασφαλείας, κάρτα σκάφους/πληρώματος) όποτε θέλετε – η εφαρμογή σας υπενθυμίζει με ετικέτες στο Ημερολόγιο\n4. Προσθέστε καταχωρήσεις κατά τη διάρκεια της ημέρας: ώρα, θέση, σημείωση\n5. Στο τέλος του πλου ανοίξτε Ρυθμίσεις → Εξαγωγή PDF\n\nΗ εφαρμογή τρέχει σε πλήρη οθόνη – σύρετε από την πάνω ή κάτω άκρη για να εμφανίσετε προσωρινά τις γραμμές συστήματος του τηλεφώνου.';

  @override
  String get guideMapTitle => 'Χάρτης';

  @override
  String get guideMapBody =>
      'Η καρτέλα Χάρτης δείχνει την τρέχουσα θέση σας και το ίχνος του πλου.\n\n• Μπλε κουκκίδα = τρέχουσα θέση\n• Μπλε γραμμή = το ίχνος που καταγράφεται τώρα\n• Εικονίδιο διαδρομής – επιλέξτε οποιονδήποτε πλου ή ημέρα για προεπισκόπηση του ίχνους στον χάρτη (σε πορτοκαλί), χωρίς εξαγωγή PDF Κάτω εμφανίζεται η αναπαραγωγή: με τον ολισθητή περνάς τον πλου στον χρόνο και βλέπεις θέση, ταχύτητα, πορεία, άνεμο και πίεση σε κάθε στιγμή. Οι χαραγές είναι συμβάντα — αρχή και τέλος πλου, άγκυρα, παράσυρση, MOB.\n• Εναλλαγή μεταξύ δορυφορικής και προβολής χάρτη\n• Ναυτικά σημάδια – εναλλαγή ναυτικών σημαδιών (ναυάγια, ρηχά, σημαντήρες)\n• Βάθη – ισοβαθείς από το EMODnet, με το βάθος σε μέτρα. Μοντέλο βυθού από μετρήσεις, ΟΧΙ ναυτικός χάρτης: για τον σχεδιασμό πλου ναι, για την απόφαση αν περνάτε όχι. Ανενεργό από προεπιλογή· τα πλακίδια που βλέπετε αποθηκεύονται όπως όλα τα άλλα. Με ενεργό το επίπεδο, πατήστε στον χάρτη για να δείτε το βάθος στο σημείο (απαιτεί σήμα).\n• Λιμάνια – πατήσιμο επίπεδο αγκυροβολίων, μαρίνων και λιμανιών (δεδομένα OpenStreetMap): πατήστε ένα εικονίδιο για όνομα, κανάλι VHF, τηλέφωνο, ιστότοπο, βάθος ή χωρητικότητα όπου είναι γνωστά· αποθηκεύστε το σημείο ως σημείο πορείας με ένα πάτημα· το επίπεδο περιλαμβάνει και σταθμούς καυσίμων σκαφών (πορτοκαλί αντλία)\n• Σταθμοί – μετρημένα: τα βέλη σε λευκό δίσκο είναι τιμές που ΠΡΑΓΜΑΤΙΚΑ ΜΕΤΡΗΘΗΚΑΝ σε σταθμούς, όχι πρόγνωση. Μένουν στον σταθμό τους και δεν μεταφέρονται στη θέση σου — πάτησε για όνομα σταθμού, ώρα μέτρησης και απόσταση από το σκάφος. Πρόγνωση, κύματα και ρεύματα θα βρεις στην καρτέλα Καιρός· ο χάρτης μένει για πλοήγηση και καταγραφή.\n• Χάρακας (μοβ εικονίδιο) – πατήστε σημεία στον χάρτη: συνολικά ΝΜ, διόπτευση του τελευταίου σκέλους και εκτιμώμενος χρόνος άφιξης στην τρέχουσα ταχύτητα· τα σημεία κολλούν στα σημεία πορείας ώστε να μετράτε διαδρομή μέσα από τους στόχους σας\n• Χάρτης χωρίς σύνδεση (εικονίδιο λήψης) — κατεβάζει την ορατή περιοχή για χρήση χωρίς σήμα, από το τρέχον ζουμ τρία επίπεδα βαθύτερα. Πάντα χάρτη και ναυτικά σήματα· με ανοιχτό τον δορυφόρο, και τις εικόνες με τα ονόματα τόπων. Επιπλέον, κάθε πλακίδιο που βλέπεις αποθηκεύεται αυτόματα.\n• Στη νυχτερινή λειτουργία ο χάρτης μεταβαίνει αυτόματα σε σκούρα πλακίδια\n• Εικονίδιο άγκυρας = θέση αγκυροβολίας (μόνο όταν ο συναγερμός άγκυρας είναι ενεργός)\n• Εικονίδιο εισαγωγής – φορτώστε ίχνη και σημεία πορείας από αρχείο .gpx (βλ. \"Εισαγωγή GPX\")\n• Κλείδωμα βορρά – πατήστε παρατεταμένα τον ανεμολόγιο (πάνω αριστερά)· ο χάρτης σταματά να περιστρέφεται και παραμένει με τον βορρά πάνω. Πατήστε τον οποτεδήποτε για επαναφορά στον βορρά.\n• Τα επιλεγμένα επίπεδα (δορυφόρος, ναυτικά σημάδια, βάθη, λιμάνια, ραντάρ, άνεμος…), η παρακολούθηση GPS και το κλείδωμα βορρά διατηρούνται μεταξύ των εκκινήσεων\n• Παρατεταμένο πάτημα στον χάρτη = προσθήκη σημείου πορείας (στόχος πλοήγησης)· πατήστε ένα υπάρχον σημείο πορείας για μετονομασία ή διαγραφή';

  @override
  String get guideInstrTitle => 'Ναυτικά Όργανα';

  @override
  String get guideInstrBody =>
      'Η καρτέλα Όργανα δείχνει δεδομένα πλοήγησης σε πραγματικό χρόνο.\n\n• SOG – ταχύτητα ως προς το βυθό (κόμβοι)\n• TWS – πραγματική ταχύτητα ανέμου\n• TWA – πραγματική γωνία ανέμου ως προς το σκάφος (πράσινο = δεξιά, κόκκινο = αριστερά)\n• DEPTH – βάθος νερού (κόκκινο = λιγότερο από 5 μ)\n• VMG WP – ταχύτητα προς ένα επιλεγμένο σημείο πορείας· επιλέξτε ένα από το πλακίδιο για να δείτε απόσταση/διόπτευση και ένα βέλος απευθείας στον ανεμολόγιο. Για να απενεργοποιήσετε την πλοήγηση επιλέξτε \"Χωρίς στόχο\" στο ίδιο πλακίδιο — την απενεργοποιεί και η διαγραφή του σημείου στον χάρτη\n\nΠηγή δεδομένων: GPS τηλεφώνου ή Raymarine (πύλη WiFi TCP ή UDP).\nΟι ρυθμίσεις σύνδεσης (συμπεριλαμβανομένης της επιλογής TCP/UDP) βρίσκονται στις Ρυθμίσεις → Όργανα.\n\nΠώς συνδέεται το σκάφος: η εφαρμογή διαβάζει δεδομένα NMEA μέσω WiFi (TCP ή UDP). Το ίδιο το WiFi hotspot ενός MFD Raymarine συνήθως δεν αρκεί — προορίζεται για τις εφαρμογές της Raymarine και τυπικά δεν εκθέτει ακατέργαστα NMEA σε τρίτους. Χρειάζεστε μια πύλη NMEA-σε-WiFi (π.χ. Digital Yacht, Yacht Devices, Actisense, Quark-elec) συνδεδεμένη στο δίκτυο του σκάφους, η οποία είτε δημιουργεί δικό της hotspot είτε εκπέμπει NMEA στο WiFi. Συνδεθείτε σε αυτό το WiFi της πύλης και εισάγετε την IP και τη θύρα της στις Ρυθμίσεις (ή δοκιμάστε Αυτόματο εντοπισμό).';

  @override
  String get guideLogbookTitle => 'Ημερολόγιο Πλου';

  @override
  String get guideLogbookBody =>
      'Το Ημερολόγιο είναι η κύρια καρτέλα διαχείρισης πλόων.\n\n• Το μεγάλο κουμπί \"Έναρξη Πλου\" στην κορυφή ξεκινά την καταγραφή – ζητά μόνο τη συχνότητα αυτόματης καταγραφής (αλλάζει σε κάθε επανεκκίνηση), χωρίς φόρμα προς συμπλήρωση εκ των προτέρων\n• Αν υπάρχει ήδη ανοιχτός πλους, η εφαρμογή ρωτά αν θα τον συνεχίσετε ή θα ξεκινήσετε νέα εγγραφή\n• Τα στοιχεία που λείπουν (παραλαβή, ενημέρωση ασφαλείας, κάρτα σκάφους/πληρώματος) υπενθυμίζονται με χρωματιστές ετικέτες πάνω στην κάρτα του πλου – πατήστε μια ετικέτα για να τα συμπληρώσετε\n• Κάθε ημέρα του πλου εμφανίζεται ξεχωριστά\n• Οι καταχωρήσεις μπορούν να προστεθούν χειροκίνητα κατά τη διάρκεια της ημέρας, μαζί με ώρες μηχανής, καύσιμο και νερό στην ενότητα \"Μηχανή & δεξαμενές\"\n• Κατά την καταγραφή, ένα κουμπί κάμερας (κάτω αριστερά) επιτρέπει να βγάλετε φωτογραφία ενός σημείου ενδιαφέροντος και να την αποθηκεύσετε ως γρήγορη καταχώρηση με θέση και ώρα\n• Το ημερολόγιο μπορεί να εξαχθεί σε PDF μέσω του μενού της ημέρας\n• Το εικονίδιο χειραψίας στη λεπτομέρεια του πλου ανοίγει το πρωτόκολλο παράδοσης (παραλαβή/παράδοση)\n• Η αναλυτική φόρμα πλου (εικονίδιο σκάφους στη λεπτομέρεια) καταγράφει το σκάφος και τις παραμέτρους του, την περιοχή πλου, το πλήρωμα με τις άδειες του κυβερνήτη και φωτογραφίες σκάφους (μέγ. 3, μεταφέρονται στο PDF)\n• Οι ημιτελείς κάρτες (Ενημέρωση Ασφαλείας, παραλαβή/παράδοση, κάρτα σκάφους) αναβοσβήνουν κόκκινες στη λεπτομέρεια του πλου μέχρι να ολοκληρωθούν\n• Αν η εφαρμογή κλείσει στη μέση του ταξιδιού χωρίς να σταματήσει η καταγραφή (την τερματίσει το σύστημα, κατά λάθος swipe), στην επόμενη εκκίνηση προτείνει τη συνέχιση του ίδιου ταξιδιού – μαζί με την απόσταση που διανύθηκε όσο δεν έτρεχε\n• Την πρώτη φορά που ξεκινάς ταξίδι η εφαρμογή υπενθυμίζει τις ρυθμίσεις μπαταρίας – χωρίς αυτές το σύστημα (κυρίως Honor/Huawei) μπορεί να διακόψει την καταγραφή στο παρασκήνιο\n• Το εικονίδιο διαδρομής στην κεφαλίδα του ταξιδιού (δίπλα στο briefing, το πρωτόκολλο και την κάρτα σκάφους) δείχνει όλη τη διαδρομή στον χάρτη\n• Μετά το ταξίδι μπορείς να εξάγεις βεβαίωση μιλίων για κάθε μέλος του πληρώματος – ημέρες στη θάλασσα, ημερήσια και νυχτερινά μίλια, περιοχή, αξιολόγηση κυβερνήτη και QR για επαλήθευση\n• Ο τρόπος πρόωσης (μηχανή/πανιά) περνά και στις αυτόματες εγγραφές – τον ορίζεις μία φορά και οι επόμενες τον κρατούν\n• Η βεβαίωση είναι δίγλωσση (η γλώσσα σου + αγγλικά), περιέχει διαστάσεις και νηολόγηση σκάφους, τον τύπο υδάτων (παλιρροϊκά/μη) και πεδίο για αριθμό διαβατηρίου ή ταυτότητας· μπορείς να τη μοιραστείς ή να την αποθηκεύσεις στο τηλέφωνο';

  @override
  String get guideMilesTitle => 'Ημερολόγιο Μιλίων';

  @override
  String get guideMilesBody =>
      'Μια σύνοψη όλων των πλόων σας σε ένα μέρος (εικονίδιο στην καρτέλα Ημερολόγιο).\n\n• Συνολικά ναυτικά μίλια, ημέρες στη θάλασσα, αριθμός πλόων και νυχτερινές ώρες\n• Ανάλυση ανά έτος και ανά σκάφος\n• Φίλτρο ανά έτος\n• Πατήστε έναν πλου (ακόμη και καταγεγραμμένο/εισαγόμενο) για να συμπληρώσετε την εγγραφή ημερολογίου του – διαδρομή, σημαία σκάφους, όνομα και πτυχίο κυβερνήτη, υπογραφή επιβεβαίωσης των μιλίων\n• Κουμπί + – προσθέστε ιστορικό πλου από πριν αρχίσετε να χρησιμοποιείτε την εφαρμογή (μετρά πλήρως στις συνόψεις, εμφανίζεται με αστερίσκο στη λίστα)\n• Εξαγωγή PDF πιστοποιητικού διανυθέντων μιλίων με χώρο για υπογραφή';

  @override
  String get guideHandoverTitle => 'Πρωτόκολλο Παράδοσης (παραλαβή/παράδοση)';

  @override
  String get guideHandoverBody =>
      'Επίσημη καταγραφή παραλαβής και επιστροφής του σκάφους σε ναύλωση – εικονίδιο χειραψίας στη λεπτομέρεια του πλου.\n\n• Λίστα ελέγχου εξοπλισμού (πανιά, εξάρτια, άγκυρα, πλοήγηση, σωσίβια, σχεδία, κιτ πρώτων βοηθειών, βοηθητική λέμβος, φώτα, bimini...) – εντάξει / κατεστραμμένο / λείπει, με σημείωση, θέση στο σκάφος και φωτογραφία\n• Κατάσταση καυσίμου, νερού και ωρών μηχανής\n• Υπογραφή τόσο του κυβερνήτη όσο και του εκπροσώπου της εταιρείας ναύλωσης\n• Το πρωτόκολλο γίνεται μόνο για ανάγνωση μόλις υπογράψουν και οι δύο\n• Η παράδοση προσυμπληρώνει δεδομένα από το πρωτόκολλο παραλαβής και επισημαίνει νέες ζημιές\n• Εξαγωγή PDF με τις δύο υπογραφές δίπλα-δίπλα';

  @override
  String get guideGpxImportTitle => 'Εισαγωγή GPX';

  @override
  String get guideGpxImportBody =>
      'Εισαγωγή ιχνών και σημείων πορείας από άλλες εφαρμογές πλοήγησης ή συσκευές GPS (εικονίδιο στον Χάρτη).\n\n• Επιλέξτε ένα αρχείο .gpx από τη συσκευή σας\n• Μια πολυήμερη εξαγωγή (πολλά ίχνη σε ένα αρχείο, π.χ. από Garmin Explore) συγχωνεύεται αυτόματα σε έναν πλου με μία ημέρα ανά ημερολογιακή ημέρα\n• Τα ίχνη που βρέθηκαν μπορούν επίσης να ανατεθούν χειροκίνητα σε υπάρχοντα πλου\n• Τα σημεία πορείας (και από διαδρομές) προστίθενται απευθείας στον χάρτη\n• Εμφανίζεται σαφές μήνυμα σφάλματος για κατεστραμμένο αρχείο';

  @override
  String get guideWeatherTitle => 'Καιρός';

  @override
  String get guideWeatherBody =>
      'Η καρτέλα Καιρός δείχνει την πρόγνωση με βάση την τρέχουσα θέση σας.\n\n• Ενημερώνεται αυτόματα όταν αλλάζει η θέση σου\n• Στην κορυφή βρίσκονται οι ΕΠΙΣΗΜΕΣ ΠΡΟΕΙΔΟΠΟΙΗΣΕΙΣ (MeteoAlarm), αν ισχύουν για τη χώρα σου. Δεν τις εκδίδει μοντέλο αλλά η εθνική μετεωρολογική υπηρεσία — DHMZ στην Κροατία, Met Office στη Βρετανία, SMHI στη Σουηδία. Ανοίγοντάς τις βλέπεις περιγραφή και οδηγία· αν δεν υπάρχει κείμενο στη γλώσσα σου, η εφαρμογή λέει σε ποια γλώσσα το διαβάζεις.\n• Η πρόγνωση προέρχεται από το ΕΘΝΙΚΟ ΜΟΝΤΕΛΟ του τόπου σου — ARPAE ICON-2I για Αδριατική και Ιταλία, UKMO για Βρετανία, MET Norway για Σκανδιναβία, ICON-D2 για κεντρική Ευρώπη, αλλού ECMWF. Το όνομα του μοντέλου φαίνεται κάτω από τα τρέχοντα.\n• Η κάρτα Σταθμοί – μετρημένα δείχνει τι μέτρησε πραγματικά κάποιος, με απόσταση και ώρα μέτρησης. Μοντέλο και μέτρηση μπορεί να διαφέρουν και κατά το μισό.\n• Χωρίς σήμα εμφανίζεται η τελευταία αποθηκευμένη πρόγνωση, πάντα με την ώρα λήψης. Πάνω από έξι ώρες σημαίνεται πορτοκαλί.\n\nΉλιος, σελήνη και παλίρροιες:\n• Η ανατολή, η δύση και η φάση της σελήνης υπολογίζονται στη συσκευή — δεν χρειάζεται σύνδεση\n• Πατήστε ανανέωση στην κάρτα Παλίρροιας για λήψη πρόγνωσης παλίρροιας 7 ημερών (δωρεάν, χωρίς κλειδί API)\n• Οι παλίρροιες αποθηκεύονται στη μνήμη, ώστε να παραμένουν αναγνώσιμες εκτός σύνδεσης· η κάρτα σας προειδοποιεί όταν η πρόγνωση είναι παλιά ή λήφθηκε μακριά από εδώ\n• ⚠ Τα ύψη παλίρροιας είναι πάνω από τη μέση στάθμη της θάλασσας, όχι από τη στάθμη χάρτη — μην τα χρησιμοποιείτε ποτέ για τον υπολογισμό βάθους κάτω από την καρίνα\n\nΘαλάσσιο ρεύμα:\n• Η κάρτα Θαλάσσιου ρεύματος δείχνει την πραγματική πρόγνωση για τη θέση σας σε κόμβους και την κατεύθυνση προς την οποία κινείται το ρεύμα\n• Να μη συγχέεται με το επίπεδο Ωκεάνια ρεύματα — αυτό είναι χάρτης αναφοράς των μεγάλων παγκόσμιων ρευμάτων';

  @override
  String get guideSafetyMobTitle => 'MOB & Άγκυρα';

  @override
  String get guideSafetyMobBody =>
      'Η καρτέλα Ασφάλεια περιέχει λειτουργίες έκτακτης ανάγκης.\n\nMOB (Άνθρωπος στη θάλασσα):\n• Κρατήστε το κόκκινο κουμπί MOB για ενεργοποίηση\n• Η εφαρμογή καταγράφει τη θέση GPS και παρακολουθεί χρόνο και απόσταση\n• Πλοηγηθείτε πίσω στο σημείο πτώσης\n\nΣυναγερμός άγκυρας:\n• Ρυθμίστε την ακτίνα της άγκυρας (συνιστάται: 2× το μήκος αλυσίδας/σκοινιού)\n• Ο συναγερμός δονείται αν το σκάφος εκτραπεί εκτός της επιτρεπόμενης ακτίνας';

  @override
  String get guideSafetyBriefingTitle => 'Ενημέρωση Ασφαλείας & MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'Η καρτέλα Ασφάλεια περιέχει επίσης κάρτες αναφοράς.\n\n• Ενημέρωση Ασφαλείας – λίστα ελέγχου πληρώματος πριν τον απόπλου\n• Κάθε μέλος του πληρώματος υπογράφει με τη δική του υπογραφή στην οθόνη\n• Οι υπογραφές αποθηκεύονται και περιλαμβάνονται αυτόματα στην εξαγωγή PDF του πλου\n• Λίστα Ελέγχου Παράδοσης – επισκόπηση των στοιχείων παραλαβής/παράδοσης, διαθέσιμη ακόμη και χωρίς ανοιχτό πλου\n• Κάρτα MAYDAY – διαδικασία κλήσης κινδύνου στο κανάλι VHF 16\n• COLREG – κανονισμοί αποφυγής συγκρούσεων στη θάλασσα (διαθέσιμο στα σλοβακικά και αγγλικά· οι υπόλοιπες γλώσσες εμφανίζουν το αγγλικό κείμενο)\n• Επαφές – αριθμοί και επαφές έκτακτης ανάγκης\n\nΣημείωση: η καταγραφή μπορεί να ξεκινήσει οποτεδήποτε, ακόμη και χωρίς ολοκληρωμένη ενημέρωση – η εφαρμογή απλώς σας υπενθυμίζει με ετικέτα \"Λείπει η ενημέρωση ασφαλείας\" στο Ημερολόγιο μέχρι να ολοκληρωθεί. Η ενημέρωση απαιτεί να συμπληρωθεί πρώτα η κάρτα σκάφους & πληρώματος και μπορεί να αποθηκευτεί μόνο αφού υπογράψουν όλα τα μέλη του πληρώματος.\n• Οι επαφές έκτακτης ανάγκης ακολουθούν τη θέση σου ακόμη και χωρίς καταγραφή – η εφαρμογή ζητά η ίδια στίγμα και αλλάζει τους αριθμούς όταν περνάς σε άλλη χώρα';

  @override
  String get guideDutyTitle => 'Πλήρωμα σε βάρδια';

  @override
  String get guideDutyBody =>
      'Καταγραφή του ποιος ήταν σε βάρδια και πότε — στην Ασφάλεια, πάνω από τον συναγερμό άγκυρας.\n\n• Ανάληψη βάρδιας — επιλέξτε ένα ή περισσότερα άτομα ταυτόχρονα· καθένα βγαίνει από τη βάρδια ξεχωριστά\n• Τα ονόματα προέρχονται από το πλήρωμα του πλου. Αν δεν έχει οριστεί πλήρωμα, το κουμπί σας οδηγεί στην κάρτα του πλου\n• Η ώρα έναρξης μπορεί να διορθωθεί αν πατήσατε το κουμπί με καθυστέρηση\n• Προβολή για έλεγχο — μια κάρτα πλήρους οθόνης για παράδοση επί του σκάφους: ποιος είναι σε βάρδια, από πότε, τοπική ώρα και ώρα UTC. Τίποτε δεν μπορεί να αλλάξει από εκεί\n• Πρόγραμμα βαρδιών — συμπληρώστε μια προηγούμενη βάρδια ή επεξεργαστείτε μία. Αφήστε κενή την ώρα \"έως\" και η βάρδια συνεχίζεται\n• Μια νυχτερινή βάρδια που περνά τα μεσάνυχτα είναι μία εγγραφή, όχι δύο. Εμφανίζεται και στις δύο ημέρες στο PDF, με ένα βέλος\n• Η ανάληψη και η λήξη βάρδιας καταγράφονται και στο ημερολόγιο και στην εξαγωγή PDF\n\nΣημείωση: η εφαρμογή δεν τερματίζει ποτέ μια βάρδια από μόνη της. Μετά από 12 ώρες απλώς σας προειδοποιεί — μια ώρα λήξης που δεν παρατηρήσατε θα ήταν επινοημένα δεδομένα.';

  @override
  String get guideCompassTitle => 'Πυξίδα Διόπτευσης';

  @override
  String get guideCompassBody =>
      'Η καρτέλα Πυξίδα δείχνει τη μαγνητική διόπτευσή σας μέσω των αισθητήρων του τηλεφώνου, με την πίσω κάμερα ως φόντο για τη λήψη διοπτεύσεων σε αντικείμενα.\n\n• Κίτρινο σταυρόνημα – κατεύθυνση που στοχεύετε\n• Ταινία πυξίδας πάνω – N / NE / E / SE / S / SW / W / NW\n• Αριθμητική ένδειξη – μοίρες και σημείο ορίζοντα\n• Πράσινη κουκκίδα = σταθερή ένδειξη  ·  Πορτοκαλί κουκκίδα = βαθμονόμηση\n\nΑν η ένδειξη είναι ασταθής, κινήστε αργά το τηλέφωνο σχηματίζοντας ένα οκτάρι για να βαθμονομήσετε το μαγνητόμετρο.\n\nΗ ακρίβεια μπορεί να μειωθεί κοντά σε μεταλλικές κατασκευές, ηχεία ή ηλεκτρονικό εξοπλισμό.\n\nΗ πυξίδα λύνει δύο διαφορετικά προβλήματα — να βρεις τον ΕΑΥΤΟ ΣΟΥ όταν δεν ξέρεις πού είσαι, ή να προσδιορίσεις ένα ΑΓΝΩΣΤΟ ΣΗΜΕΙΟ όταν θέλεις να βάλεις στον χάρτη κάτι που δεν υπάρχει ακόμη εκεί. Ο διακόπτης πάνω από το κουμπί Λήψη διόπτευσης επιλέγει ποιο από τα δύο κάνεις.\n\nΗ ΘΕΣΗ ΜΟΥ — βρες τον εαυτό σου (δεν χρειάζεται GPS)\n\n1. Έλεγξε στον χάρτη ότι ξέρεις τουλάχιστον δύο ορατά σημεία (φάρο, κορυφή, εκκλησία) αποθηκευμένα ως waypoints. Το σημείο που λείπει το προσθέτεις με παρατεταμένο πάτημα στον χάρτη ακριβώς στη θέση του.\n2. Στην πυξίδα, άλλαξε σε \"Η θέση μου\".\n3. Άγγιξε την ετικέτα κάτω από τον διακόπτη και διάλεξε το πρώτο σημείο που διοπτεύεις.\n4. Στόχευσε το σταυρόνημα ακριβώς πάνω του και πάτησε Λήψη διόπτευσης.\n5. Έλεγξε τη μετρημένη διόπτευση στο παράθυρο και πάτησε Αποθήκευση (η Ακύρωση απορρίπτει το προσχέδιο χωρίς αποθήκευση).\n6. Διάλεξε ένα δεύτερο, ΔΙΑΦΟΡΕΤΙΚΟ σημείο (η επιλογή αδειάζει μόνη της μετά την αποθήκευση) και επανάλαβε.\n7. Στον χάρτη θα δεις δύο διακεκομμένες γραμμές από τα σημεία προς εσένα. Το σημείο τομής τους είναι η θέση σου — πράσινος σταυρός σημαίνει καλή τομή, πορτοκαλί οξεία γωνία και αβέβαιη θέση.\n8. Ένα τρίτο σημείο, ιδανικά υπό διαφορετική γωνία, βελτιώνει την εκτίμηση και σχεδιάζει το τρίγωνο σφάλματος.\n\nΚάν\' το γρήγορα, μέσα σε 5 λεπτά — το στίγμα από γνωστά σημεία προϋποθέτει ότι το σκάφος στέκεται μεταξύ των διοπτεύσεων.\n\nΑΓΝΩΣΤΟ ΣΗΜΕΙΟ — προσδιόρισε ένα αντικείμενο (χρειάζεται GPS)\n\n1. Άλλαξε σε \"Άγνωστο σημείο\".\n2. Άγγιξε την ετικέτα, διάλεξε \"Νέο σημείο…\" και ονόμασε αυτό που διοπτεύεις, π.χ. \"άγνωστη ξέρα\".\n3. Στόχευσε, Λήψη διόπτευσης, επιβεβαίωσε Αποθήκευση.\n4. Μετακίνησε το σκάφος τουλάχιστον μερικές εκατοντάδες μέτρα — όσο πιο μακριά, τόσο πιο αξιόπιστο το αποτέλεσμα.\n5. Άνοιξε ξανά την επιλογή στόχου, διάλεξε το ΙΔΙΟ αντικείμενο από τη λίστα (όχι \"Νέο σημείο\") και διόπτευσέ το δεύτερη φορά.\n6. Στον χάρτη εμφανίζεται ένας δείκτης με την υπολογισμένη θέση του αντικειμένου. Άγγιξέ τον για να τον αποθηκεύσεις ως waypoint — από εκείνη τη στιγμή μπορεί να χρησιμοποιηθεί και για στίγμα από γνωστά σημεία.\n\nΑκρίβεια\n\nΜια πυξίδα τηλεφώνου έχει πραγματικό σφάλμα γύρω στις ±8°, που σε 10 ν.μ. είναι πάνω από 2,5 ν.μ. πλευρικής απόκλισης — ακριβώς γι\' αυτό η εφαρμογή σχεδιάζει κώνο αβεβαιότητας αντί για λεπτή γραμμή. Η καλύτερη τομή προκύπτει από σημεία με γωνία κοντά στις 90°· όταν βρίσκονται σχεδόν στην ίδια ευθεία μαζί σου, η τομή θολώνει σε εκατοντάδες μέτρα ή περισσότερο.\n\nΔιοπτεύσεις χωρίς πλεύση\n\nΜια διόπτευση αποθηκεύεται ακόμη κι όταν το tracking είναι απενεργοποιημένο — στο αγκυροβόλιο, στη στεριά. Θα τη βρεις στη λίστα πλεύσεων ως δική της γραμμή με ημερομηνία, ανάμεσα στις επιμέρους πλεύσεις. Ανοίγοντάς τη βλέπεις τις διοπτεύσεις εκείνης της ημέρας με έναν μικρό χάρτη, και από εκεί εξάγεις ένα απλό PDF με τον χάρτη και τον πίνακα διοπτεύσεων.\n\nΚαθαρισμός χάρτη και διαγραφή διοπτεύσεων\n\nΔιόπτευση σε καθαρό χάρτη – στην Πυξίδα, το εικονίδιο ανανέωσης πάνω δεξιά. Αποσύρει από τον χάρτη τις διοπτεύσεις που ήδη έχεις και μηδενίζει το επιλεγμένο σημείο ή αντικείμενο, ώστε η επόμενη διόπτευση να ξεκινά από την αρχή. Τίποτα δεν χάνεται: οι εγγραφές μένουν στην καρτέλα Ημερολόγιο και στην εξαγωγή PDF.\n\nΟριστική διαγραφή – άνοιξε τη γραμμή με την ημερομηνία στη λίστα πλόων. Το X δίπλα σε μια γραμμή σβήνει μία διόπτευση (σε αντικείμενο, όλη τη σειρά διοπτεύσεων προς αυτό). Ο κάδος στην επάνω μπάρα σβήνει ολόκληρη την ημέρα μαζί και σε γυρίζει πίσω στη λίστα. Η διαγραφή είναι οριστική και οι διοπτεύσεις χάνονται και από την εξαγωγή PDF.\n\nΜε λίγα λόγια: ο καθαρισμός τακτοποιεί τον χάρτη, η διαγραφή αφαιρεί την εγγραφή. Μόνο η διαγραφή αλλάζει το περιεχόμενο του PDF.';

  @override
  String get guideSettingsTitle => 'Ρυθμίσεις';

  @override
  String get guideSettingsBody =>
      '• Γλώσσα – αλλαγή της γλώσσας της εφαρμογής\n• Όργανα – ρύθμιση της διεύθυνσης IP της πύλης WiFi Raymarine (TCP ή UDP)\n• Πηγή GPS – τηλέφωνο ή Raymarine\n• Μονάδες – απόσταση ν.μ./χλμ., ταχύτητα κόμβοι/χλμ.ώ., χωριστά θερμοκρασία, βάθος και άνεμος (σε ποτάμι ταιριάζουν χλμ.)\n• Συχνότητα καταχωρήσεων\n• Κάτω μενού – προσαρμόστε το: πατήστε και σύρετε ένα εικονίδιο για αναδιάταξη, χρησιμοποιήστε τον διακόπτη για να κρύψετε καρτέλες που δεν χρησιμοποιείτε και ορίστε το μέγεθος εικονιδίων (S/M/L). Οι κρυμμένες καρτέλες ανοίγουν εδώ στις Ρυθμίσεις· οι Ρυθμίσεις εμφανίζονται πάντα. Η σειρά και το μέγεθος διατηρούνται. Οι ετικέτες κάτω από τα εικονίδια είναι κρυμμένες ώστε τα εικονίδια να κάθονται ίδια σε κάθε γλώσσα· κράτα πατημένο ένα εικονίδιο για το όνομά του.\n• Οθόνη – Νυχτερινή λειτουργία (κόκκινο φίλτρο για διατήρηση της νυχτερινής όρασης)\n• Εξαγωγή στο cloud (Google Drive) – μόλις συνδεθείτε, το PDF και το GPX κάθε ολοκληρωμένης ημέρας ανεβαίνουν αυτόματα στο δικό σας Google Drive. Χωρίς σύνδεση, όλα παραμένουν στη συσκευή.\n• Αντίγραφο ασφαλείας δεδομένων – βλ. \"Αντίγραφο ασφαλείας και επαναφορά\"\n• Σχετικά – έκδοση και επικοινωνία\n• Μπαταρία – Το GPS λειτουργεί με πλήρη ακρίβεια μόνο εκεί που χρειάζεται ακριβής θέση (καταγραφή πλού, χάρτης, πυξίδα, όργανα, φύλαξη αγκυροβολίου, MOB)· αλλού περνά σε λειτουργία χαμηλής κατανάλωσης και στο παρασκήνιο χωρίς καταγραφή σβήνει εντελώς. Με συνδεδεμένα τα όργανα του σκάφους το GPS του τηλεφώνου παραμένει κλειστό και η θέση έρχεται από NMEA.\n\nΛογαριασμός Google και εξαγωγή στο cloud\n\nΗ σύνδεση με λογαριασμό Google είναι προαιρετική. Χωρίς αυτή η εφαρμογή λειτουργεί πλήρως και όλες οι εγγραφές μένουν μόνο στο τηλέφωνο.\n\nΤι ανεβαίνει – με το κλείσιμο μιας ημέρας πλου, το PDF του ημερολογίου και το ίχνος GPX εκείνης της ημέρας. Τίποτα άλλο: ούτε φωτογραφίες, ούτε επαφές πληρώματος, ούτε θέσεις σε πραγματικό χρόνο.\n\nΠού – στο δικό σου Google Drive, στον φάκελο HMB_Sailing_Log_DATA / όνομα πλου / Day_ημερομηνία. Όχι σε διακομιστή της εφαρμογής – δεν υπάρχει.\n\nΤι βλέπει η εφαρμογή στο Drive – μόνο τα αρχεία που δημιούργησε η ίδια. Χρησιμοποιεί το στενότερο δικαίωμα που προσφέρει η Google (drive.file). Το ζητά μάλιστα στην πρώτη αποστολή, όχι στη σύνδεση.\n\nΠώς το ακυρώνεις – αποσυνδέσου στις Ρυθμίσεις. Τα αρχεία που ήδη ανέβηκαν παραμένουν δικά σου – η εφαρμογή δεν τα σβήνει.';

  @override
  String get guideBackupTitle => 'Αντίγραφο ασφαλείας και επαναφορά';

  @override
  String get guideBackupBody =>
      'Στις Ρυθμίσεις → Αντίγραφο ασφαλείας δεδομένων.\n\n• Εξαγωγή αντιγράφου – αποθηκεύει όλο το ημερολόγιο (πλόες, καταχωρήσεις, ρυθμίσεις) σε ένα αρχείο (.hmbbackup) που μπορείτε να μοιραστείτε μέσω email, στο cloud ή να αποθηκεύσετε τοπικά\n• Επαναφορά από αντίγραφο – αντικαθιστά τα τρέχοντα δεδομένα με το περιεχόμενο του επιλεγμένου αντιγράφου· δημιουργείται πρώτα αυτόματα ένα αντίγραφο ασφαλείας της τρέχουσας κατάστασης\n• Η επαναφορά αποκλείεται όσο η καταγραφή πλου GPS είναι ενεργή\n• Ένα αντίγραφο με νεότερο σχήμα από αυτό που υποστηρίζει η εφαρμογή απορρίπτεται με επεξήγηση';

  @override
  String get guideExportTitle => 'Εξαγωγή Ημερολογίου';

  @override
  String get guideExportBody =>
      'Το ημερολόγιο μπορεί να εξαχθεί ως επαγγελματικό έγγραφο PDF.\n\n1. Ανοίξτε Ημερολόγιο → επιλέξτε έναν πλου\n2. Πατήστε το εικονίδιο εξαγωγής ή τις τρεις τελείες → Εξαγωγή PDF\n3. Υπογράψτε ως κυβερνήτης → δημιουργείται το PDF\n4. Το PDF περιλαμβάνει: ίχνος, καταχωρήσεις ημερολογίου, φωτογραφίες, ενημέρωση ασφαλείας με υπογραφές πληρώματος· η κεφαλίδα της σελίδας τίτλου δείχνει τη φωτογραφία του σκάφους από την κάρτα σκάφους (αν έχει ανέβει)\n5. Μοιραστείτε μέσω email, εκτυπώστε ή αποθηκεύστε στο τηλέφωνο\n\nΚάθε PDF λαμβάνει μοναδικό αναγνωριστικό εγγράφου (π.χ. HMBSL-5-2026) και αριθμό αναθεώρησης (Rev. 1, Rev. 2...) ορατό στο υποσέλιδο κάθε σελίδας. Κάθε νέα εξαγωγή αυξάνει αυτόματα τον αριθμό — καθιστώντας ορατό πόσες φορές δημιουργήθηκε το έγγραφο.\n\nΟ κωδικός QR στη σελίδα υπογραφών περιέχει το αναγνωριστικό, την αναθεώρηση και ένα κρυπτογραφικό αποτύπωμα του περιεχομένου. Οποιαδήποτε αλλαγή στα δεδομένα αλλάζει τον κωδικό QR.\n\nΤο PDF δημιουργείται στη γλώσσα της εφαρμογής, με ονόματα και τόνους. Κάθε σελίδα ημέρας φέρει επίσης μια λωρίδα πληρώματος σε βάρδια.\n• Αν η καταγραφή διακόπηκε και ξεκίνησε ξανά μέσα στην ημέρα, κάθε σκέλος παίρνει δικό του αρχείο GPX\n• Οι αποστάσεις, οι ταχύτητες και οι θερμοκρασίες στο PDF ακολουθούν τις μονάδες που έχουν οριστεί στις Ρυθμίσεις';

  @override
  String get safetyBriefingScreenTitle => 'Ενημέρωση Ασφαλείας';

  @override
  String get briefingCrewSignaturesSection => 'Υπογραφές Πληρώματος';

  @override
  String get briefingSignHere => 'Υπογράψτε εδώ';

  @override
  String get briefingClear => 'Καθαρισμός';

  @override
  String get briefingSigned => 'Υπογεγραμμένο';

  @override
  String get briefingSave => 'Αποθήκευση Υπογραφών';

  @override
  String get briefingSavedOk => 'Οι υπογραφές αποθηκεύτηκαν';

  @override
  String get briefingOpenBriefing => 'Ενημέρωση Ασφαλείας';

  @override
  String get briefingSkipper => 'Κυβερνήτης';

  @override
  String get briefingCrew => 'Πλήρωμα';

  @override
  String get briefingNoCrew =>
      'Δεν έχει οριστεί πλήρωμα. Προσθέστε μέλη πληρώματος στις ρυθμίσεις του πλου.';

  @override
  String get briefingDate => 'Ημερομηνία';

  @override
  String get briefingLocation => 'Τοποθεσία';

  @override
  String get briefingDoneLabel => 'Η Ενημέρωση Ασφαλείας ολοκληρώθηκε';

  @override
  String get briefingDoneSubtitle =>
      'Όλες οι υπογραφές πληρώματος αποθηκεύτηκαν. Δεν χρειάζεται επανάληψη.';

  @override
  String get briefingEditSignature => 'Αλλαγή υπογραφής';

  @override
  String get briefingRequiredTitle => 'Απαιτείται Ενημέρωση Ασφαλείας';

  @override
  String get briefingRequiredBody =>
      'Ολοκληρώστε την Ενημέρωση Ασφαλείας και συγκεντρώστε τις υπογραφές του πληρώματος πριν ξεκινήσετε την πρώτη συνεδρία καταγραφής.';

  @override
  String get goToBriefing => 'Μετάβαση στην Ενημέρωση';

  @override
  String get skipperProfile => 'Προφίλ Κυβερνήτη';

  @override
  String get skipperProfileHint =>
      'Αυτά τα στοιχεία εμφανίζονται στην εξαγωγή PDF του πλου.';

  @override
  String get skipperFullName => 'Όνομα Κυβερνήτη';

  @override
  String get skipperLicenseSection => 'Άδεια Κυβερνήτη';

  @override
  String get skipperLicenseType => 'Τύπος Άδειας';

  @override
  String get skipperLicenseNumber => 'Αριθμός Άδειας';

  @override
  String get skipperLicenseAuthority => 'Εκδούσα Αρχή';

  @override
  String get skipperLicenseExpiry => 'Ισχύει Έως';

  @override
  String get skipperVhfSection => 'Άδεια VHF / SRC';

  @override
  String get skipperVhfNumber => 'Αριθμός VHF/SRC';

  @override
  String get skipperVhfExpiry => 'VHF Ισχύει Έως';

  @override
  String get skipperOtherCerts => 'Άλλα Πιστοποιητικά / Άδειες';

  @override
  String get skipperOtherCertsHint =>
      'π.χ. Yachtmaster, RYA, STCW, μαθήματα διάσωσης...';

  @override
  String get continueLastVoyageTitle => 'Συνέχιση του τελευταίου πλου;';

  @override
  String get continueVoyageAction => 'Συνέχεια';

  @override
  String get newRecordAction => 'Νέα εγγραφή';

  @override
  String get missingCheckInChip => 'Λείπει η παραλαβή';

  @override
  String get missingBriefingChip => 'Λείπει η ενημέρωση ασφαλείας';

  @override
  String get missingDetailsChip => 'Λείπουν στοιχεία σκάφους/πληρώματος';

  @override
  String get missingCheckOutChip => 'Λείπει η παράδοση';

  @override
  String get vesselModel => 'Μοντέλο';

  @override
  String get vesselTypeMonohull => 'Μονόγαστρο';

  @override
  String get vesselTypeCatamaran => 'Καταμαράν';

  @override
  String get vesselTypeTrimaran => 'Τριμαράν';

  @override
  String get vesselTypeMotorYacht => 'Θαλαμηγός μηχανής';

  @override
  String get vesselTypeGulet => 'Gulet';

  @override
  String get vesselTypeDinghy => 'Βαρκάκι';

  @override
  String get vesselTypeRib => 'Φουσκωτό (RIB)';

  @override
  String get vesselTypeOther => 'Άλλο';

  @override
  String get charterCompanyLabel => 'Εταιρεία ναύλωσης';

  @override
  String get yachtParamsSection => 'Παράμετροι σκάφους';

  @override
  String get berthsLabel => 'Κλίνες';

  @override
  String get yearBuiltLabel => 'Έτος κατασκευής';

  @override
  String get waterTankLabel => 'Δεξαμενή νερού';

  @override
  String get fuelTankLabel => 'Δεξαμενή καυσίμου';

  @override
  String get engineHoursStartLabel => 'Ώρες μηχανής · έναρξη';

  @override
  String get engineHoursEndLabel => 'Ώρες μηχανής · λήξη';

  @override
  String get whereWhenSection => 'Πού & πότε';

  @override
  String get countryLabel => 'Χώρα';

  @override
  String get cruisingAreaLabel => 'Περιοχή πλου';

  @override
  String get charterContactsSection => 'Επαφές ναύλωσης';

  @override
  String get charterContactsHint =>
      'Έως 3 αριθμοί για κλήση / WhatsApp / SMS. Πάντα με τον διεθνή κωδικό (π.χ. +385...).';

  @override
  String get addPhoneNumber => 'Προσθήκη αριθμού τηλεφώνου';

  @override
  String get costsSection => 'Κόστη';

  @override
  String get charterPriceLabel => 'Τιμή πλου';

  @override
  String get currencyLabel => 'Νόμισμα';

  @override
  String get addCostItem => 'Προσθήκη κόστους';

  @override
  String get costName => 'Όνομα κόστους';

  @override
  String get crewSectionHint =>
      'Πατήστε το σήμα για να ορίσετε τον κυβερνήτη — οι υπόλοιποι είναι πλήρωμα.';

  @override
  String get addCrewMember => 'Προσθήκη μέλους πληρώματος';

  @override
  String get crewNameLabel => 'Όνομα';

  @override
  String get skipperBadge => 'ΚΥΒΕΡΝΗΤΗΣ';

  @override
  String get crewBadge => 'ΠΛΗΡΩΜΑ';

  @override
  String get vesselTypeSailboat => 'Ιστιοφόρο';

  @override
  String get vesselTypeMotorBoat => 'Μηχανοκίνητο';

  @override
  String get sbNeedsVesselCard =>
      'Συμπληρώστε πρώτα την κάρτα σκάφους και πληρώματος — η Ενημέρωση Ασφαλείας χρειάζεται τη λίστα πληρώματος για τις υπογραφές.';

  @override
  String get prefillSkipperTitle =>
      'Συμπλήρωση αποθηκευμένων στοιχείων κυβερνήτη;';

  @override
  String get prefillSkipperFill => 'Συμπλήρωση';

  @override
  String get prefillSkipperNew => 'Νέος κυβερνήτης';

  @override
  String get boatLicenceLabel => 'Αρ. άδειας σκάφους';

  @override
  String get radioLicenceLabel => 'Αρ. άδειας ασυρμάτου';

  @override
  String get vesselPhotosSection => 'Φωτογραφίες σκάφους (μέγ. 3)';

  @override
  String get addPhotoLabel => 'Προσθήκη';

  @override
  String get createVoyageButton => 'Δημιουργία πλου';

  @override
  String get saveVoyageButton => 'Αποθήκευση πλου';

  @override
  String get costBaseCharter => 'Βασική τιμή πλου';

  @override
  String get costDeposit => 'Εγγύηση';

  @override
  String get costDinghyOutboard => 'Βοηθητική λέμβος / εξωλέμβια';

  @override
  String get costOutboardFuel => 'Καύσιμο εξωλέμβιας';

  @override
  String get costTransitLog => 'Transit log';

  @override
  String get costTouristTax => 'Τουριστικός φόρος';

  @override
  String get costFinalCleaning => 'Τελικός καθαρισμός';

  @override
  String get costLinenTowels => 'Κλινοσκεπάσματα και πετσέτες';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / καγιάκ';

  @override
  String get costSkipperFee => 'Αμοιβή κυβερνήτη';

  @override
  String get costHostessFee => 'Αμοιβή hostess';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m μ';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Κατά προσέγγιση θέση · ±$m μ · εντοπισμός δικτύου';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Τελευταία γνωστή θέση · πριν $mins λεπτά';
  }

  @override
  String get locationQualityUnknown => 'Άγνωστη ακρίβεια';

  @override
  String get locationQualityMocked => '⚠️ Εντοπίστηκε πλαστή θέση';

  @override
  String get syncQueueTitle => 'Ουρά συγχρονισμού';

  @override
  String get syncQueueEmpty => 'Η ουρά είναι άδεια';

  @override
  String get syncNowAction => 'Συγχρονισμός τώρα';

  @override
  String get syncRetryFailedAction => 'Επανάληψη αποτυχημένων';

  @override
  String get syncStatusPending => 'Σε εκκρεμότητα';

  @override
  String get syncStatusSending => 'Αποστολή';

  @override
  String get syncStatusSent => 'Στάλθηκε';

  @override
  String get syncStatusFailed => 'Απέτυχε';

  @override
  String get syncStatusConflict => 'Διένεξη';

  @override
  String get syncStatusDeferred => 'Αναβλήθηκε';

  @override
  String syncRetryCount(int n) {
    return 'Προσπάθεια $n';
  }

  @override
  String get syncOffline => 'εκτός σύνδεσης';

  @override
  String syncPendingCount(int n) {
    return '$n σε εκκρεμότητα';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n αναβλήθηκαν';
  }

  @override
  String syncFailedCount(int n) {
    return '$n απέτυχαν';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Το συνημμένο αναμένει Wi-Fi (συνήθως μη διαθέσιμο στη θάλασσα).';

  @override
  String get syncWifiOverrideAction => 'Χρήση δεδομένων κινητής';

  @override
  String get syncWifiOverrideActive =>
      'Επιτρέπονται δεδομένα κινητής για συνημμένα';

  @override
  String get syncClearQueueAction => 'Εκκαθάριση ουράς';

  @override
  String get syncClearQueueConfirmTitle => 'Εκκαθάριση όλης της ουράς;';

  @override
  String get syncClearQueueConfirmContent =>
      'Αφαιρεί κάθε στοιχείο από την ουρά συγχρονισμού, ακόμη και τα ήδη σταλμένα. Δεν μπορεί να αναιρεθεί.';

  @override
  String get syncClearQueueDone => 'Η ουρά εκκαθαρίστηκε';

  @override
  String get syncEnableToggle => 'Συγχρονισμός ημερολογίου';

  @override
  String get syncEnableToggleDesc =>
      'Αποστολή καταχωρήσεων στον διακομιστή όσο η εφαρμογή είναι ανοιχτή και online';

  @override
  String get syncTargetLabel => 'Στόχος συγχρονισμού';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Προσαρμοσμένος διακομιστής';

  @override
  String get syncCustomUrlLabel => 'URL διακομιστή';

  @override
  String get syncCustomTokenLabel => 'Token';

  @override
  String get syncTestConnectionAction => 'Δοκιμή σύνδεσης';

  @override
  String get syncTestSuccess => 'Η σύνδεση λειτουργεί';

  @override
  String syncTestFailure(String detail) {
    return 'Απέτυχε: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Εισάγετε URL διακομιστή';

  @override
  String get syncUrlErrorInvalid => 'Μη έγκυρο URL';

  @override
  String get syncUrlErrorHttps => 'Το URL πρέπει να ξεκινά με https://';

  @override
  String get syncIntervalLabel => 'Διάστημα συγχρονισμού';

  @override
  String syncIntervalMinutes(int n) {
    return '$n λεπτά';
  }

  @override
  String get syncIntervalNote =>
      'Ο συγχρονισμός εκτελείται μόνο όσο η εφαρμογή είναι ανοιχτή';

  @override
  String get syncAttachmentPolicyLabel => 'Συνημμένα (φωτογραφίες)';

  @override
  String get syncAttachmentNever => 'Ποτέ';

  @override
  String get syncAttachmentWifiOnly => 'Μόνο Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Πάντα';

  @override
  String get syncBackfillAction =>
      'Προσθήκη παλαιότερων καταχωρήσεων στην ουρά';

  @override
  String get syncBackfillDesc =>
      'Προσθέτει στην ουρά αποστολής καταχωρήσεις που δημιουργήθηκαν όσο ο συγχρονισμός ήταν κλειστός';

  @override
  String syncBackfillResult(int n) {
    return '$n στην ουρά';
  }

  @override
  String get syncBackfillNone =>
      'Τίποτε προς προσθήκη — όλα είναι ήδη στην ουρά ή στάλθηκαν';

  @override
  String get syncCloudEnableToggle => 'Εξαγωγή στο cloud (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Μόλις συνδεθείτε, το PDF και το GPX κάθε ολοκληρωμένης ημέρας ανεβαίνουν αυτόματα στο Google Drive. Χωρίς σύνδεση, όλα παραμένουν στη συσκευή.';

  @override
  String get syncCloudSignInAction => 'Σύνδεση με Google';

  @override
  String get syncCloudSignOutAction => 'Αποσύνδεση';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Συνδεδεμένος ως $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Δεν είστε συνδεδεμένος';

  @override
  String get waypointNameHint => 'π.χ. Αγκυροβόλιο, Λιμάνι...';

  @override
  String waypointDefaultName(String time) {
    return 'Σημείο $time';
  }

  @override
  String get mobFullName => 'Άνθρωπος στη θάλασσα';

  @override
  String get maydayCardShort => 'Κάρτα\nMayday';

  @override
  String get morseInputHint => 'Εισαγάγετε κείμενο...';

  @override
  String get morseSosTitle => 'SOS – ΣΗΜΑ ΚΙΝΔΥΝΟΥ';

  @override
  String get morseSosCopied => 'Το SOS αντιγράφηκε';

  @override
  String intervalSeconds(int n) {
    return '$n δευτ';
  }

  @override
  String intervalMinutes(int n) {
    return '$n λεπ';
  }

  @override
  String intervalHours(int n) {
    return '$n ώρ';
  }

  @override
  String get aboutFeatureGps => 'Παρακολούθηση GPS με αυτόματες καταχωρήσεις';

  @override
  String get aboutFeatureLogbook => 'Ημερολόγιο πολυήμερων ναυλώσεων';

  @override
  String get aboutFeatureMaps => 'Ναυτικοί χάρτες εκτός σύνδεσης (OpenSeaMap)';

  @override
  String get aboutFeatureWeather => 'Θαλάσσιος καιρός (Open-Meteo)';

  @override
  String get aboutFeatureExport => 'Εξαγωγή PDF + GPX';

  @override
  String get aboutFeatureSafety => 'Ενημέρωση ασφαλείας και κάρτα Mayday';

  @override
  String get aboutAuthorLabel => 'Συγγραφέας';

  @override
  String get aboutVersionLabel => 'Έκδοση';

  @override
  String get aboutPlatformLabel => 'Πλατφόρμα';

  @override
  String cloudSignInFailed(String error) {
    return 'Η σύνδεση απέτυχε: $error';
  }

  @override
  String cloudSignOutFailed(String error) {
    return 'Η αποσύνδεση απέτυχε: $error';
  }

  @override
  String get marineInstrumentsWifiNote =>
      'Λειτουργεί μόνο μέσω του δικτύου WiFi του σκάφους – το τηλέφωνο πρέπει να είναι συνδεδεμένο σε πύλη NMEA (Raymarine, Digital Yacht, Yacht Devices…). Χωρίς WiFi η εφαρμογή χρησιμοποιεί το GPS του τηλεφώνου και την πρόγνωση καιρού από το διαδίκτυο.';

  @override
  String get interruptedVoyageTitle => 'Η καταγραφή διακόπηκε';

  @override
  String interruptedVoyageBody(String time) {
    return 'Η εφαρμογή έκλεισε στις $time χωρίς να ολοκληρωθεί το ταξίδι. Συνέχεια του ίδιου ταξιδιού;';
  }

  @override
  String interruptedVoyageGap(String distance) {
    return 'Η θέση σας απέχει $distance ν.μ. από το τελευταίο καταγεγραμμένο σημείο.';
  }

  @override
  String get interruptedVoyageAddGap =>
      'Προσθήκη αυτής της απόστασης στο ταξίδι';

  @override
  String get interruptedVoyageResume => 'Συνέχεια';

  @override
  String get batteryPromptTitle =>
      'Άφησε την εφαρμογή να τρέχει σε όλο το ταξίδι';

  @override
  String get batteryPromptBody =>
      'Το Android — ιδίως Honor, Huawei και Xiaomi — τερματίζει εφαρμογές που τρέχουν στο παρασκήνιο, οπότε η καταγραφή διακόπτεται στη μέση του ταξιδιού.\n\nΣτις ρυθμίσεις μπαταρίας επίτρεψε σε αυτή την εφαρμογή απεριόριστη λειτουργία. Σε Honor/Huawei πρόσθεσέ την και στις προστατευμένες εφαρμογές και επίτρεψε την αυτόματη εκκίνηση.';

  @override
  String get batteryPromptAction => 'Άνοιγμα ρυθμίσεων';

  @override
  String get speed => 'Ταχύτητα';

  @override
  String get dateFormatLabel => 'Μορφή ημερομηνίας';

  @override
  String get dateFormatByLanguage => 'Κατά τη γλώσσα της εφαρμογής';

  @override
  String get crewCertTitle => 'Βεβαίωση διανυθέντων μιλίων';

  @override
  String get crewCertVoyage => 'Ταξίδι';

  @override
  String get crewCertArea => 'Περιοχή πλεύσης';

  @override
  String get crewCertDayMiles => 'Ημερήσια μίλια';

  @override
  String get crewCertNightMiles => 'Νυχτερινά μίλια';

  @override
  String get crewCertNightHours => 'Νυχτερινές ώρες';

  @override
  String get crewCertQualifications => 'Προσόντα';

  @override
  String get crewCertAssessment => 'Αξιολόγηση κυβερνήτη';

  @override
  String get crewCertStamp => 'Σφραγίδα';

  @override
  String get crewCertHashCoverage =>
      'Το αποτύπωμα καλύπτει τη σύνοψη του ταξιδιού και την αξιολόγηση του πληρώματος.';

  @override
  String get crewSkillHelming => 'Πηδαλιούχηση';

  @override
  String get crewSkillNavigation => 'Ναυσιπλοΐα';

  @override
  String get crewSkillHarbour => 'Ελιγμοί στο λιμάνι';

  @override
  String get crewSkillTeamwork => 'Ομαδικότητα';

  @override
  String get crewSkillNightSailing => 'Νυχτερινή πλεύση';

  @override
  String get crewCertExport => 'Εξαγωγή βεβαιώσεων';

  @override
  String get crewCertNoteHint => 'Γραπτή αξιολόγηση (προαιρετικά)';

  @override
  String get crewCertNoCrew =>
      'Αυτό το ταξίδι δεν έχει πλήρωμα. Πρόσθεσέ το στην κάρτα ταξιδιού.';

  @override
  String get crewCertNotRated => 'χωρίς αξιολόγηση';

  @override
  String get crewCertShared => 'Οι βεβαιώσεις δημιουργήθηκαν';

  @override
  String get more => 'Περισσότερα';

  @override
  String get crewCertSkipperRates =>
      'Ο κυβερνήτης αξιολογεί το πλήρωμα και δεν αξιολογείται. Βεβαίωση μιλίων παίρνει κι αυτός.';

  @override
  String get crewCertVesselSize => 'Διαστάσεις σκάφους';

  @override
  String get crewCertVesselRegistration => 'Νηολόγηση';

  @override
  String get crewCertWaters => 'Ύδατα';

  @override
  String get crewCertWatersTidal => 'παλιρροϊκά';

  @override
  String get crewCertWatersNonTidal => 'μη παλιρροϊκά';

  @override
  String get crewCertIdDocument => 'Αριθμός διαβατηρίου / ταυτότητας';

  @override
  String get crewCertDaysAtSea => 'Ημέρες στη θάλασσα';

  @override
  String get crewCertTotal => 'Σύνολο';

  @override
  String get crewCertWatersLabel => 'Τύπος υδάτων';

  @override
  String get bearingTakeSight => 'Λήψη διόπτευσης';

  @override
  String bearingSaved(String bearing) {
    return 'Η διόπτευση $bearing αποθηκεύτηκε';
  }

  @override
  String get bearingNoPosition =>
      'Χωρίς GPS δεν προσδιορίζεται άγνωστο σημείο. Άλλαξε σε «Η θέση μου» — το στίγμα από γνωστά σημεία δεν χρειάζεται GPS.';

  @override
  String get bearingSaveFailed => 'Δεν ήταν δυνατή η αποθήκευση της διόπτευσης';

  @override
  String get bearingLabelHint => 'Τι διοπτεύεις; (προαιρετικό)';

  @override
  String bearingDeclinationApplied(String value) {
    return 'Απόκλιση $value';
  }

  @override
  String get bearingDeclinationExpired =>
      'Το μαγνητικό μοντέλο έληξε — η απόκλιση είναι εκτίμηση';

  @override
  String get bearingsLayer => 'Διοπτεύσεις';

  @override
  String get bearingsTitle => 'Διοπτεύσεις';

  @override
  String get bearingsClearAll => 'Απόκρυψη όλων από τον χάρτη';

  @override
  String get bearingsClearConfirm =>
      'Απόκρυψη όλων των διοπτεύσεων από τον χάρτη; Οι γραμμές και το στίγμα εξαφανίζονται από τον χάρτη, παραμένουν στο ημερολόγιο.';

  @override
  String get bearingsEmpty =>
      'Καμία διόπτευση ακόμη. Στόχευσε το τηλέφωνο σε ένα αντικείμενο και πάτησε Λήψη διόπτευσης.';

  @override
  String get bearingsDeleteDayConfirm =>
      'Όλες οι διοπτεύσεις αυτής της ημέρας θα διαγραφούν οριστικά, και από την εξαγωγή PDF. Η ενέργεια δεν αναιρείται.';

  @override
  String bearingFixFrom(int count) {
    return 'Θέση από $count διοπτεύσεις';
  }

  @override
  String bearingFixWeak(String angle) {
    return 'Αδύναμο στίγμα — οι γραμμές τέμνονται μόλις υπό $angle';
  }

  @override
  String bearingFixOffGps(String distance) {
    return 'Απόκλιση από το GPS: $distance';
  }

  @override
  String get bearingTrueLabel => 'αληθής';

  @override
  String get bearingMagneticLabel => 'μαγνητική';

  @override
  String bearingUncertaintyNote(String deg) {
    return 'Ο κώνος δείχνει την αβεβαιότητα ±$deg της πυξίδας του τηλεφώνου.';
  }

  @override
  String get bearingPdfSection => 'Διοπτεύσεις';

  @override
  String get bearingPdfObject => 'Αντικείμενο';

  @override
  String get bearingPdfBearing => 'Αληθής διόπτευση';

  @override
  String get bearingModeResection => 'Η θέση μου';

  @override
  String get bearingModeObject => 'Άγνωστο σημείο';

  @override
  String get bearingModeResectionHint =>
      'Διόπτευσε 2–3 γνωστά σημεία του χάρτη. Δεν χρειάζεται GPS.';

  @override
  String get bearingModeObjectHint =>
      'Διόπτευσε το ίδιο σημείο από 2–3 διαφορετικά μέρη. Χρειάζεται GPS.';

  @override
  String get bearingPickTarget => 'Διάλεξε το σημείο για διόπτευση';

  @override
  String get bearingNeedsTarget =>
      'Διάλεξε πρώτα γνωστό σημείο του χάρτη, μετά διόπτευσε';

  @override
  String get bearingNeedsObject => 'Δώσε πρώτα όνομα στο σημείο που διοπτεύεις';

  @override
  String get bearingNewObject => 'Νέο σημείο…';

  @override
  String get bearingObjectName => 'Όνομα σημείου (π.χ. άγνωστη ξέρα)';

  @override
  String get bearingOpenObjects => 'Σημεία σε προσδιορισμό';

  @override
  String bearingSightCount(int count) {
    return '$count διοπτεύσεις';
  }

  @override
  String get bearingSameTargetHint =>
      'Το ίδιο σημείο όπως πριν — το στίγμα χρειάζεται άλλο.';

  @override
  String get bearingShortBaselineHint =>
      'Κοντή βάση — μετακινήσου και διόπτευσε ξανά.';

  @override
  String get bearingMovedHint =>
      'Το σκάφος μετακινήθηκε μεταξύ των διοπτεύσεων — το στίγμα προϋποθέτει ότι στέκεται.';

  @override
  String get bearingNeedsSecondSight =>
      'Μία διόπτευση ακόμη σε άλλο σημείο και η θέση θα βγει.';

  @override
  String get bearingMyPositionFix => 'Η θέση μου';

  @override
  String get bearingObjectFix => 'Προσδιορισμένο σημείο';

  @override
  String get bearingSaveObjectAsWaypoint => 'Αποθήκευση ως waypoint';

  @override
  String bearingObjectSaved(String name) {
    return 'Το $name αποθηκεύτηκε ως waypoint';
  }

  @override
  String get bearingDeclinationFromTarget =>
      'Η απόκλιση υπολογίστηκε στη θέση του διοπτευμένου σημείου';

  @override
  String get bearingResectionSection => 'Στίγμα από γνωστά σημεία';

  @override
  String get bearingObjectSection => 'Προσδιορισμός άγνωστων σημείων';

  @override
  String get bearingPdfMark => 'Διοπτευμένο σημείο';

  @override
  String get bearingPdfResult => 'Αποτέλεσμα';

  @override
  String get bearingStartNew => 'Έναρξη νέας διόπτευσης';

  @override
  String get bearingHideFromMap => 'Απόκρυψη από τον χάρτη';
}
