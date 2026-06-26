// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get languageName => 'Deutsch';

  @override
  String get navMap => 'Karte';

  @override
  String get navTracking => 'Tracking';

  @override
  String get navLogbook => 'Logbuch';

  @override
  String get navWeather => 'Wetter';

  @override
  String get navSafety => 'Sicherheit';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Schließen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get share => 'Teilen';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get error => 'Fehler';

  @override
  String errorMsg(String msg) {
    return 'Fehler: $msg';
  }

  @override
  String get pressBackToExit => 'Zurück erneut drücken zum Beenden';

  @override
  String get trackingRunningTitle => 'Tracking läuft';

  @override
  String get trackingRunningContent =>
      'Tracking ist aktiv. Was möchten Sie tun?';

  @override
  String get stopAndExit => 'Stoppen und beenden';

  @override
  String get keepRunning => 'Weiter laufen lassen';

  @override
  String get marineInstrumentsTitle => 'Marineinstrumente';

  @override
  String get marineInstrumentsPrompt =>
      'Möchten Sie die App mit Marineinstrumenten verbinden (z.B. Raymarine über WiFi-Gateway)? Die App liest dann GPS, Wind, Tiefe und andere Daten direkt vom Boot.\n\nOhne Verbindung wird das Telefon-GPS und die Internet-Wettervorhersage verwendet – das können Sie jederzeit in den Einstellungen ändern.';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get setupConnection => 'Verbindung einrichten';

  @override
  String get trackingActiveTitle => 'Tracking aktiv';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get waitingForGps => 'Warte auf GPS...';

  @override
  String get gpsUnavailable => 'GPS nicht verfügbar';

  @override
  String get lastKnownPosition => 'Letzte bekannte Position';

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String get logbookBtn => 'Logbuch';

  @override
  String get stop => 'Stoppen';

  @override
  String get startVoyage => 'Fahrt starten';

  @override
  String get starting => 'Starte...';

  @override
  String get newVoyage => 'Neue Fahrt';

  @override
  String get multiday => 'Mehrtägig';

  @override
  String get standalone => 'Eigenständig';

  @override
  String get voyageName => 'Fahrtname';

  @override
  String get voyageNameOptional => 'Name (optional)';

  @override
  String get voyageNameHint => 'z.B. Ausflug in die Bucht';

  @override
  String get existingVoyage => 'Bestehende Fahrt';

  @override
  String get newVoyageDropdown => '— Neue Fahrt —';

  @override
  String get firstVoyageHint => 'Erste Fahrt – Grundinfos ausfüllen:';

  @override
  String get estimatedDays => 'Geschätzte Tagesanzahl:';

  @override
  String get logFrequency => 'Häufigkeit der Logbucheinträge';

  @override
  String get startTracking => 'Tracking starten';

  @override
  String get trackingInProgress => 'Fahrt aufzeichnen';

  @override
  String dayNofTotal(int n, int total) {
    return 'Tag $n von $total';
  }

  @override
  String get newDay => '(neuer Tag)';

  @override
  String get endVoyageTitle => 'Fahrt beenden?';

  @override
  String get endVoyageContent =>
      'Sie haben den letzten geplanten Tag der Fahrt erreicht.\n\nWird die Fahrt morgen fortgesetzt?';

  @override
  String get decideLayer => 'Später entscheiden';

  @override
  String get continuesTomorrow => 'Geht morgen weiter';

  @override
  String get endVoyage => 'Fahrt beenden';

  @override
  String get newMultidayVoyage => 'Neue mehrtägige Fahrt';

  @override
  String get deleteCharterTitle => 'Charter löschen?';

  @override
  String get deleteCharterContent => 'Alle Tage und Einträge werden gelöscht.';

  @override
  String get noVoyages => 'Keine Fahrten';

  @override
  String get createFirstCharter => 'Ersten Charter erstellen';

  @override
  String get briefingDone => 'Briefing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Fahrt nicht gefunden';

  @override
  String get unknownVessel => 'Unbekanntes Schiff';

  @override
  String get captain => 'Kapitän';

  @override
  String get crew => 'Besatzung';

  @override
  String get total => 'Gesamt';

  @override
  String voyageDaysCount(int n) {
    return 'Fahrt-Tage ($n)';
  }

  @override
  String get bulkDelete => 'Massenlöschen';

  @override
  String get noDays =>
      'Keine Tage.\nTracking starten und der erste Tag wird automatisch erstellt.';

  @override
  String get deleteDayTitle => 'Tag löschen?';

  @override
  String deleteDayContent(String day) {
    return 'Alle Einträge für $day werden gelöscht.';
  }

  @override
  String get exportPdf => 'PDF exportieren';

  @override
  String get selectDaysTitle => 'Tage zum Löschen auswählen';

  @override
  String deleteCount(int n) {
    return 'Löschen ($n)';
  }

  @override
  String get safety => 'Sicherheit';

  @override
  String get mobHoldToActivate => 'Halten zum Aktivieren';

  @override
  String get mobActive => '⚠️ MOB AKTIV';

  @override
  String get mobTime => 'Zeit';

  @override
  String get mobDistance => 'Entfernung';

  @override
  String get mobDirection => 'Richtung';

  @override
  String get navigateToMob => 'Zu MOB navigieren';

  @override
  String get gpsPositionNotAvailable => 'GPS-Position nicht verfügbar!';

  @override
  String get anchorAlarm => 'Ankeralarm';

  @override
  String get drifting => 'TREIBT';

  @override
  String get anchorRadiusLabel => 'Ankerradius';

  @override
  String get activate => 'Aktivieren';

  @override
  String get deactivate => 'Deaktivieren';

  @override
  String get safetyBriefingCard => 'Sicherheitsbriefing';

  @override
  String get maydayCard => 'Mayday-Karte';

  @override
  String get yachtHandover => 'Yachtübergabe';

  @override
  String get gearList => 'Ausrüstungsliste';

  @override
  String get colreg => 'KVR';

  @override
  String get emergencyContacts => 'Notfallkontakte';

  @override
  String get backToToc => 'Zurück zum Inhalt';

  @override
  String get briefingComplete => 'Briefing abgeschlossen';

  @override
  String get updateByPosition => 'Nach Position aktualisieren';

  @override
  String get detectedByGps => 'per GPS erkannt';

  @override
  String get locationUnavailable =>
      '📍 Position nicht verfügbar – globale Kontakte';

  @override
  String get detectingLocation => 'Position wird ermittelt...';

  @override
  String get tapToCall => 'Tippen zum Anrufen';

  @override
  String cannotCall(String name) {
    return 'Kann nicht anrufen: $name';
  }

  @override
  String get vhfChannel16 => 'VHF Kanal 16 – Bordfunkgerät benutzen';

  @override
  String get hmbHandbook => 'HMB Handbuch';

  @override
  String get checkInLabel => 'Check-in (Bootsübernahme)';

  @override
  String get checkOutLabel => 'Check-out (Bootsrückgabe)';

  @override
  String get charterCheckCard => 'Charter';

  @override
  String get weatherTitle => 'Wetter & See';

  @override
  String get updateForecast => 'Vorhersage aktualisieren';

  @override
  String get gpsNotAvailableTracking =>
      'GPS nicht verfügbar – Tracking aktivieren';

  @override
  String get downloadingForecast => 'Lade Vorhersage...';

  @override
  String get loadingForecast => 'Vorhersage wird geladen...';

  @override
  String get noConnection => 'Keine Verbindung verfügbar';

  @override
  String get pressRefreshWhenOnline => 'Aktualisieren drücken wenn online';

  @override
  String get noWeatherData => 'Keine Wetterdaten';

  @override
  String get forecastAutoDownload =>
      'Vorhersage wird automatisch heruntergeladen wenn Tracking startet, oder Aktualisieren drücken.';

  @override
  String get enableGpsFirst => 'Zuerst GPS / Tracking aktivieren';

  @override
  String get downloadForecast => 'Vorhersage herunterladen';

  @override
  String downloadError(String error) {
    return 'Downloadfehler: $error';
  }

  @override
  String get liveInstrumentData => 'Live-Marineinstrumentdaten';

  @override
  String get windRelative => 'Wind (rel.)';

  @override
  String get windTrue => 'Wind (wahr)';

  @override
  String get depthLabel => 'Tiefe';

  @override
  String get waterTempLabel => 'Wassertemperatur';

  @override
  String get courseTrue => 'Kurs (wahr)';

  @override
  String get courseMag => 'Kurs (magn.)';

  @override
  String get engineLabel => 'Motor';

  @override
  String get wavesLabel => 'Wellen';

  @override
  String get pressureLabel => 'Druck';

  @override
  String get airTempLabel => 'Luft';

  @override
  String get waterLabel => 'Wasser';

  @override
  String get wind24h => 'Wind – 3 Tage';

  @override
  String get waves24h => 'Wellen – 3 Tage';

  @override
  String get hourlyForecast => '3-Tage-Vorhersage';

  @override
  String get dailyForecast => 'Tagestemperatur';

  @override
  String get timeCol => 'Zeit';

  @override
  String get windCol => 'Wind';

  @override
  String get wavesCol => 'Wellen';

  @override
  String get rainCol => 'Regen';

  @override
  String get beaufort0 => 'Windstille';

  @override
  String get beaufort1 => 'Leiser Zug';

  @override
  String get beaufort2 => 'Leichte Brise';

  @override
  String get beaufort3 => 'Schwache Brise';

  @override
  String get beaufort4 => 'Mäßige Brise';

  @override
  String get beaufort5 => 'Frische Brise';

  @override
  String get beaufort6 => 'Starker Wind';

  @override
  String get beaufort7 => 'Steifer Wind';

  @override
  String get beaufort8 => 'Stürmischer Wind';

  @override
  String get beaufort9 => 'Sturm';

  @override
  String get beaufort10 => 'Schwerer Sturm';

  @override
  String get beaufort11 => 'Orkanartiger Sturm';

  @override
  String get beaufort12 => 'Orkan';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get measurementUnits => 'Maßeinheiten';

  @override
  String get temperature => 'Temperatur';

  @override
  String get depthWaves => 'Tiefe / Wellen';

  @override
  String get wind => 'Wind';

  @override
  String get language => 'Sprache';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get connectionConnected => 'Verbunden';

  @override
  String get connectionConnecting => 'Verbinde...';

  @override
  String get connectionError => 'Verbindungsfehler';

  @override
  String get connectionDisconnected =>
      'Getrennt (Telefon-GPS / Vorhersage wird verwendet)';

  @override
  String get ipAddressLabel => 'Gateway-IP-Adresse';

  @override
  String get portLabel => 'Port';

  @override
  String get autoConnectLabel => 'Beim Start automatisch verbinden';

  @override
  String get disconnect => 'Trennen';

  @override
  String get connect => 'Verbinden';

  @override
  String get gatewayHint =>
      'Telefon mit dem WLAN des Boot-Gateways verbinden (Raymarine WiFi-1, RayNet und ähnliche laufen typischerweise auf 10.0.0.1, Port 2000). Ohne Verbindung verwendet die App automatisch Telefon-GPS und Internet-Wettervorhersage.';

  @override
  String connectedToHost(String host, int port) {
    return 'Verbunden mit $host:$port';
  }

  @override
  String get enterIpAddress => 'Gateway-IP-Adresse eingeben';

  @override
  String connectionFailed(String error) {
    return 'Verbindung fehlgeschlagen: $error';
  }

  @override
  String get liveWind => 'Wind';

  @override
  String get liveDepth => 'Tiefe';

  @override
  String get liveWaterTemp => 'Wassertemperatur';

  @override
  String get liveCompass => 'Kompass';

  @override
  String get liveEngine => 'Motor';

  @override
  String get dayNotFound => 'Tag nicht gefunden';

  @override
  String get saved => 'Gespeichert';

  @override
  String get trackingThisDay => 'Tracking für diesen Tag aktiv';

  @override
  String get trackingOtherDay => 'Tracking für anderen Tag aktiv';

  @override
  String recordCount(int n) {
    return '$n Einträge';
  }

  @override
  String get addManual => 'Manuell hinzufügen';

  @override
  String get noEntries => 'Keine Einträge';

  @override
  String get entriesAutoAdded =>
      'Einträge werden während des Trackings automatisch hinzugefügt';

  @override
  String get deleteEntryTitle => 'Eintrag löschen?';

  @override
  String get autoRecord => 'Automatischer Eintrag';

  @override
  String get routeSection => 'Route';

  @override
  String get fromPort => 'Von';

  @override
  String get toPort => 'Nach';

  @override
  String get distance => 'Entfernung';

  @override
  String get vessel => 'Schiff';

  @override
  String get weatherSection => 'Wetter';

  @override
  String get morning => 'Morgens';

  @override
  String get noon => 'Mittags';

  @override
  String get evening => 'Abends';

  @override
  String get windDir => 'Windrichtung';

  @override
  String get seaState => 'Seegang';

  @override
  String get waveHeight => 'Wellenhöhe';

  @override
  String get dailyNote => 'Tagesbericht';

  @override
  String get dailyNoteHint =>
      'Beschreibung der Fahrt, Highlights, Ereignisse des Tages...';

  @override
  String get seaCalm => 'Ruhig';

  @override
  String get seaLight => 'Leicht';

  @override
  String get seaModerate => 'Mäßig';

  @override
  String get seaRough => 'Unruhig';

  @override
  String get seaStormy => 'Stürmisch';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get newEntry => 'Neuer Eintrag';

  @override
  String get sailMode => 'Segelart';

  @override
  String get sailMain => 'Haupt';

  @override
  String get navigationSection => 'Navigation';

  @override
  String get latitude => 'Breite';

  @override
  String get longitude => 'Länge';

  @override
  String get weatherSeaSection => 'Wetter & See';

  @override
  String get windSpeed => 'Wind';

  @override
  String get windDirection => 'Richtung';

  @override
  String get waveHeight2 => 'Wellenhöhe';

  @override
  String get engineSection => 'Motor';

  @override
  String get engineHours => 'Motorstunden';

  @override
  String get fuel => 'Kraftstoff';

  @override
  String get noteSection => 'Notiz';

  @override
  String get noteHint => 'Segelbedingungen, Ereignisse, Crewwechsel...';

  @override
  String get exportDayTitle => 'Tagesexport';

  @override
  String get exportCharterTitle => 'Charterexport';

  @override
  String get loadingData => 'Daten werden geladen...';

  @override
  String get mapsReady => 'Karten bereit – Export möglich';

  @override
  String generatingMaps(int current, int total) {
    return 'Kartenvorschauen werden erstellt ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Tag exportieren';

  @override
  String get exportCharterBtn => 'Charter exportieren';

  @override
  String get entriesLabel => 'Einträge';

  @override
  String get routePoints => 'Routenpunkte';

  @override
  String get anchorDriftTitle => '⚓ ANKER TREIBT!';

  @override
  String get anchorDriftContent =>
      'Boot hat den Ankerperimeter überschritten.\nPosition sofort überprüfen!';

  @override
  String get cancelAnchor => 'Anker aufgeben';

  @override
  String get stopAlarm => 'Alarm stoppen';

  @override
  String get briefingItem1 => 'Rettungswesten – Standort und Verwendung';

  @override
  String get briefingItem2 => 'Rettungsring und MOB-Verfahren';

  @override
  String get briefingItem3 => 'Leuchtraketen – Typen und Verwendung';

  @override
  String get briefingItem4 => 'EPIRB / PLB – Aktivierung';

  @override
  String get briefingItem5 => 'VHF-Funk – Kanal 16, Mayday-Verfahren';

  @override
  String get briefingItem6 => 'Feuerlöscher – Standort und Verwendung';

  @override
  String get briefingItem7 => 'Erste-Hilfe-Set – Standort';

  @override
  String get briefingItem8 => 'Notstopp des Motors';

  @override
  String get briefingItem9 => 'Lecks – Wasser, Gas';

  @override
  String get briefingItem10 => 'Anker und Kette – Ankermanöver';

  @override
  String get briefingItem11 => 'Bordregeln';

  @override
  String get briefingItem12 => 'Notfallkontakte und VHF 16';

  @override
  String get checkInItem1 => 'Bootsdokumente (Zulassung, Versicherung)';

  @override
  String get checkInItem2 => 'Sicherheitsausrüstung – vollständig';

  @override
  String get checkInItem3 => 'Kraftstoffvorräte';

  @override
  String get checkInItem4 => 'Wasservorräte';

  @override
  String get checkInItem5 => 'Anker und Kette – Kontrolle';

  @override
  String get checkInItem6 => 'Motor – Probelauf';

  @override
  String get checkInItem7 => 'Navigationsinstrumente';

  @override
  String get checkInItem8 => 'Rigg – Taue und Segel';

  @override
  String get checkInItem9 => 'Kombüse – Gas, Herd';

  @override
  String get checkInItem10 => 'WC – Funktionsfähigkeit';

  @override
  String get checkInItem11 => 'Vorhandene Schäden – Fotodokumentation';

  @override
  String get checkOutItem1 => 'Boot gereinigt – Außen';

  @override
  String get checkOutItem2 => 'Boot gereinigt – Innen';

  @override
  String get checkOutItem3 => 'Kraftstoff aufgefüllt';

  @override
  String get checkOutItem4 => 'Wasser aufgefüllt';

  @override
  String get checkOutItem5 => 'Müll entsorgt';

  @override
  String get checkOutItem6 => 'Schäden gemeldet';

  @override
  String get checkOutItem7 => 'Schlüssel übergeben';

  @override
  String get gearListShort => 'Persönliche\nAusrüstung';

  @override
  String get colregRules => 'COLREG\nRegeln';

  @override
  String get checkInShort => 'Check-in\nÜbernahme';

  @override
  String get checkOutShort => 'Check-out\nÜbergabe';

  @override
  String get appTagline => 'Ihr zuverlässiges Schiffslogbuch';

  @override
  String exportSavedMsg(String path) {
    return 'Gespeichert: $path';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Exportfehler: $error';
  }

  @override
  String get generatingPdf => 'PDF wird erstellt...';

  @override
  String get colregTitle => 'COLREG – Kollisionsverhütungsregeln';

  @override
  String get tableOfContents => 'INHALTSVERZEICHNIS';

  @override
  String get inThisChapter => 'In diesem Kapitel:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Regel $n';
  }

  @override
  String get resetChecklistTitle => 'Checkliste zurücksetzen?';

  @override
  String get resetChecklistContent => 'Alle Häkchen werden gelöscht.';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get checkInReceivingTitle => 'Check-in – Schiff übernehmen';

  @override
  String get checkOutHandoverTitle => 'Check-out – Schiff übergeben';

  @override
  String get checkInCompletedMsg => 'Schiff übernommen – alles geprüft ✓';

  @override
  String get checkOutCompletedMsg => 'Schiff übergeben – alles in Ordnung ✓';

  @override
  String get briefingDoneMsg => 'Briefing abgeschlossen – Crew informiert';

  @override
  String get sectionBriefed => 'Abschnitt gebrieft ✓';

  @override
  String get confirmSection => 'Abschnitt bestätigen';

  @override
  String get gearListTitle => 'Persönliche Ausrüstung';

  @override
  String get newCategory => 'Neue Kategorie';

  @override
  String get add => 'Hinzufügen';

  @override
  String get deleteItemTitle => 'Element löschen?';

  @override
  String get allPackedMsg => 'Alles gepackt, bereit zum Segeln! 🎉';

  @override
  String get addItemLabel => 'Element hinzufügen';

  @override
  String addToCategoryTitle(String category) {
    return 'Zu $category hinzufügen';
  }

  @override
  String get newItemHint => 'Neues Element...';

  @override
  String get addWaypoint => 'Wegpunkt hinzufügen';

  @override
  String get waypointNameLabel => 'Name';

  @override
  String get skipperSignature => 'Unterschrift des Skippers';

  @override
  String get signWithFinger => 'Mit dem Finger unterschreiben';

  @override
  String get clear => 'Löschen';

  @override
  String get signAndExport => 'Unterschreiben & exportieren';

  @override
  String get pleaseSign => 'Bitte vor dem Export unterschreiben';

  @override
  String get generatingPdfPreview => 'PDF-Vorschau wird erstellt...';

  @override
  String generationError(String error) {
    return 'Erzeugungsfehler: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Speichern und GPX generieren...';

  @override
  String get editCharter => 'Charter bearbeiten';

  @override
  String get basicInfo => 'Grundinformationen';

  @override
  String get voyageNameRequired => 'Reisename *';

  @override
  String get dateFrom => 'Datum von';

  @override
  String get dateTo => 'Datum bis';

  @override
  String get vesselName => 'Schiffsname';

  @override
  String get vesselType => 'Schiffstyp';

  @override
  String get homePort => 'Heimathafen';

  @override
  String get notesLabel => 'Notizen';

  @override
  String get statusLabel => 'Status';

  @override
  String get safetyBriefingDoneLabel => 'Safety-Briefing abgeschlossen';

  @override
  String get checkInDoneLabel => 'Check-in abgeschlossen';

  @override
  String get checkOutDoneLabel => 'Check-out abgeschlossen';

  @override
  String get enterVoyageName => 'Reisename eingeben';

  @override
  String daysCount(int n) {
    return '$n Tage';
  }

  @override
  String get selectTargetWaypoint => 'Ziel-Wegpunkt auswählen';

  @override
  String get noWaypoints => 'Keine Wegpunkte.';

  @override
  String get goToMap => 'Zur Karte';

  @override
  String get noTarget => 'Kein Ziel';

  @override
  String get selectWaypointHint => 'Wegpunkt auswählen...';

  @override
  String get sessionStats => 'Reisestatistik';

  @override
  String get maxSpeed => 'Höchstgeschwindigkeit';

  @override
  String get avgSpeed => 'Durchschnittsgeschwindigkeit';

  @override
  String get sailingTime => 'Segelzeit';

  @override
  String get gpsData => 'GPS-Daten';

  @override
  String get gpsPosition => 'Position';

  @override
  String get courseCog => 'Kurs (COG)';

  @override
  String get altitudeLabel => 'Höhe';

  @override
  String get dscProcedure => 'DSC-VERFAHREN';

  @override
  String get voiceScript => 'SPRACHSKRIPT';

  @override
  String get dscWarningUseOnly => '⚠️ NUR IM FALL';

  @override
  String get dscWarningDanger =>
      'EINER ERNSTHAFTEN UND UNMITTELBAREN GEFAHR VERWENDEN';

  @override
  String get dscWarningTypes => 'Brand · Sinken · Mann über Bord';

  @override
  String get dscProcedureSubtitle =>
      'Dieses Verfahren beim VHF-DSC-Funk aufbewahren';

  @override
  String get fillBeforeSailing => 'Vor der Abfahrt ausfüllen:';

  @override
  String get copyTooltip => 'Kopieren';

  @override
  String get scriptCopied => 'Skript kopiert';

  @override
  String get sendOnCh16 =>
      '📻 Auf Kanal 16 senden · Hohe Leistung · Alle 2 Minuten wiederholen, wenn keine Antwort';

  @override
  String get enterAbove => '[oben eingeben]';

  @override
  String get distressNature => 'Art des Notfalls';

  @override
  String get vesselNameLabel => 'Schiffsname';

  @override
  String get numberOfPersons => 'Anzahl Personen';

  @override
  String get additionalInfo => 'Weitere Infos';

  @override
  String get voiceScriptTitle => 'SPRACH-MAYDAY-SKRIPT';

  @override
  String get dscStep1 =>
      'Vergewissern Sie sich, dass das Gerät eingeschaltet ist.';

  @override
  String get dscStep2 => 'Öffnen Sie die Abdeckung über der ROTEN Not-Taste.';

  @override
  String get dscStep3 =>
      'Drücken Sie die ROTE Taste EINMAL und lassen Sie los.';

  @override
  String get dscStep4 =>
      'Wählen Sie die Art des Notfalls.\n(Brand, Sinken, MOB usw.)\nWenn übersprungen, wird Unbezeichneter Notfall gesendet.';

  @override
  String get dscStep5 =>
      'Drücken Sie die ROTE Taste 5 Sekunden lang, um den Ruf abzusenden.';

  @override
  String get dscStep6 =>
      'Warten Sie bis zu 15 Sekunden auf Bestätigung (auf dem Bildschirm), dann Sprachnachricht auf Kanal 16 mit HOHER LEISTUNG senden.';

  @override
  String get appDescription => 'Professionelles Bordbuch für Segler.';

  @override
  String get vesselIdTitle => 'Schiffsidentifikation';

  @override
  String get vesselIdHint =>
      'Rufzeichen und MMSI werden in der Mayday-Karte automatisch ausgefüllt.';

  @override
  String get maritimeReference => 'Nautische Referenz';

  @override
  String get phonetic => 'Phonetisch';

  @override
  String get flagAlphabet => 'Signalflaggen';

  @override
  String get dayShapes => 'Tageszeichen';

  @override
  String get marineReferenceTile => 'Signale & Alphabet';

  @override
  String get navInstruments => 'Instrumente';

  @override
  String get enterPort => 'Hafen eingeben...';

  @override
  String get closeWithoutSaving => 'Schließen ohne Speichern';

  @override
  String get saveToDevice => 'Auf Gerät speichern';

  @override
  String get saveAndShare => 'Speichern & teilen';

  @override
  String get timestampCannotBeChanged =>
      'Eintragszeit kann nicht geändert werden';

  @override
  String entriesShort(int n) {
    return '$n Eintr.';
  }

  @override
  String get mainsail => 'Großsegel';

  @override
  String get weatherConditionTitle => 'Wetterbedingungen';

  @override
  String get weatherConditionLabel => 'Bedingungen';

  @override
  String get wcSunny => 'Sonnig';

  @override
  String get wcPartlyCloudy => 'Teilweise bewölkt';

  @override
  String get wcOvercast => 'Bedeckt';

  @override
  String get wcLightRain => 'Leichter Regen';

  @override
  String get wcRain => 'Regen';

  @override
  String get wcHeavyRain => 'Starker Regen';

  @override
  String get wcDrizzle => 'Nieselregen';

  @override
  String get wcThunderstorm => 'Gewitter';

  @override
  String get wcIsoThunderstorm => 'Vereinzelte Gewitter';

  @override
  String get wcHail => 'Hagel';

  @override
  String get wcDust => 'Staub';

  @override
  String get wcFoggy => 'Nebelig';

  @override
  String get wcWindy => 'Windig';

  @override
  String get wcCold => 'Kalt';

  @override
  String get photoSection => 'Foto';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerie';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get photoAddedToEntry => 'Foto angehängt';

  @override
  String get voyageStart => 'Reisebeginn';

  @override
  String get voyageEnd => 'Reiseende';

  @override
  String get onlineAccount => 'Online-Konto';

  @override
  String get onlineAccountDesc =>
      'Logbuch mit logbook.hmba.boats synchronisieren';

  @override
  String get register => 'Registrieren';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirm =>
      'Sie werden abgemeldet. Lokale Daten bleiben erhalten.';

  @override
  String get notLoggedIn => 'Nicht angemeldet';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get password => 'Passwort';
}
