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
  String get navCompass => 'Kompass';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get cameraPermissionDenied =>
      'Kamerazugriff wurde verweigert. Bitte in den Geräteeinstellungen aktivieren.';

  @override
  String get cameraUnavailable => 'Kamera nicht verfügbar';

  @override
  String get compassCalibrationNote =>
      'Magnetkompass. Die Genauigkeit kann durch nahes Metall oder Elektronik beeinträchtigt werden. Bei Fehler das Gerät in einer Achterbewegung kalibrieren.';

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
  String get autoDetectAction => 'Automatisch erkennen';

  @override
  String get autoDetectWifiHintTitle =>
      'Zuerst mit dem WLAN des Bootes verbinden';

  @override
  String get autoDetectWifiHintBody =>
      'Prüfen Sie in den Telefoneinstellungen → WLAN, dass Sie mit dem Netzwerk der Marineinstrumente verbunden sind (z.B. RayNet, WiFi-1). Die App versucht dann automatisch, das Gateway in diesem Netzwerk zu finden.';

  @override
  String get openWifiSettings => 'WLAN-Einstellungen';

  @override
  String get continueAction => 'Weiter';

  @override
  String get autoDetecting => 'Suche nach Instrumenten im WLAN…';

  @override
  String get autoDetectFailed =>
      'Kein Gateway gefunden. Prüfen Sie, ob Sie mit dem WLAN des Bootes verbunden sind, oder geben Sie die IP manuell in den Einstellungen ein.';

  @override
  String autoDetectSuccess(String host) {
    return 'Verbunden mit $host';
  }

  @override
  String get guidePromptTitle => 'Neu hier? Kurzanleitung';

  @override
  String get guidePromptBody =>
      'Die App enthält eine kurze Bedienungsanleitung – Karte, Logbuch, Wetter, Sicherheits-Checkliste und mehr. Möchten Sie sie sich jetzt kurz ansehen? Sie finden sie jederzeit auch später unter Einstellungen → Bedienungsanleitung.';

  @override
  String get guidePromptAction => 'Anleitung zeigen';

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
  String get stopTrackingDay => 'Tracking beenden?';

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
  String get existingVoyage => 'Bestehende Fahrt fortsetzen';

  @override
  String get newVoyageDropdown => '— Neue Fahrt —';

  @override
  String get firstVoyageHint => 'Erste Fahrt – Grundinfos ausfüllen:';

  @override
  String get briefingRequiredHint =>
      'Tracking kann erst gestartet werden, wenn das Safety Briefing für diese Fahrt abgeschlossen ist.';

  @override
  String get briefingPending => 'SB erforderlich';

  @override
  String get briefingPendingListWarning =>
      'Safety Briefing nicht abgeschlossen – Tracking kann noch nicht gestartet werden';

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
  String get cannotDeleteWhileTracking =>
      'Fahrt kann während aktivem Tracking nicht gelöscht werden.';

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
  String get captain => 'Skipper';

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
  String get pdfEntriesSection => 'Logbucheinträge';

  @override
  String get pdfSkipperMessage => 'Bericht des Skippers';

  @override
  String get pdfWeatherSection => 'Wetter';

  @override
  String get pdfDaySummary => 'Tagesübersicht';

  @override
  String get pdfDaysOverview => 'Übersicht der Tage';

  @override
  String get pdfVoyageSummary => 'Törnzusammenfassung';

  @override
  String get pdfCrewSection => 'Crew';

  @override
  String get pdfSignatures => 'Unterschriften';

  @override
  String get pdfCrewSignatures => 'Unterschriften der Crew';

  @override
  String get pdfSkipperSignature => 'Unterschrift des Skippers';

  @override
  String get pdfSkipperLicences => 'Skipper – Lizenzen';

  @override
  String get pdfSafetyBriefing => 'Sicherheitseinweisung';

  @override
  String get pdfChecklistSection => 'Checkliste';

  @override
  String get pdfMoreNotes => 'Weitere Anmerkungen';

  @override
  String get pdfIntegrityCheck => 'Prüfung der Dokumentintegrität';

  @override
  String get pdfHandoverTitle => 'Übergabeprotokoll';

  @override
  String get pdfMilesTitle => 'Bestätigung der Seemeilen';

  @override
  String get pdfDeparture => 'Abfahrt';

  @override
  String get pdfArrival => 'Ankunft';

  @override
  String get pdfTotalLabel => 'Gesamt';

  @override
  String get pdfDayCount => 'Anzahl Tage';

  @override
  String get pdfEngineHours => 'Motorstunden';

  @override
  String get pdfFuelLabel => 'Kraftstoff';

  @override
  String get pdfWaterLabel => 'Wasser';

  @override
  String get pdfVesselLabel => 'Schiff';

  @override
  String get pdfSkipperLabel => 'Skipper';

  @override
  String get pdfDateLabel => 'Datum';

  @override
  String get pdfColFrom => 'Von';

  @override
  String get pdfColTo => 'Nach';

  @override
  String get pdfColEntriesShort => 'Einträge';

  @override
  String get pdfColTimeUtc => 'Zeit UTC';

  @override
  String get pdfColWind => 'Wind';

  @override
  String get pdfColPropulsion => 'Antrieb';

  @override
  String get pdfColWeatherShort => 'Wetter';

  @override
  String get pdfColNote => 'Anmerkung';

  @override
  String get pdfColDay => 'Tag';

  @override
  String get pdfColItem => 'Position';

  @override
  String get pdfColStatus => 'Zustand';

  @override
  String get pdfColNotePosition => 'Anmerkung / Position';

  @override
  String get pdfColPhoto => 'Foto';

  @override
  String get pdfColDateRange => 'Datum von-bis';

  @override
  String get pdfColArea => 'Gebiet';

  @override
  String get pdfColRole => 'Rolle';

  @override
  String get pdfNoData => 'Keine Daten';

  @override
  String get pdfMapUnavailable => 'GPS-Karte nicht verfügbar';

  @override
  String get pdfUnsigned => 'Nicht unterschrieben';

  @override
  String get pdfNoSignatures => 'Keine Unterschriften';

  @override
  String get pdfSha256Label => 'SHA-256-Prüfsumme der Logbuchdaten:';

  @override
  String get pdfVerifyQr => 'Prüf-QR';

  @override
  String get pdfSbLifejackets => 'Rettungswesten – Ort und Gebrauch';

  @override
  String get pdfSbLifebuoy => 'Rettungsring und MOB-Verfahren';

  @override
  String get pdfSbFlares => 'Signalmittel – Typen und Gebrauch';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – Aktivierung';

  @override
  String get pdfSbVhf => 'UKW-Funk – Kanal 16, Mayday-Verfahren';

  @override
  String get pdfSbExtinguisher => 'Feuerlöscher – Ort und Gebrauch';

  @override
  String get pdfSbFirstAid => 'Erste-Hilfe-Kasten – Ort';

  @override
  String get pdfSbEngineStop => 'Not-Aus des Motors';

  @override
  String get pdfSbLeaks => 'Lecks – Wasser, Gas';

  @override
  String get pdfSbAnchor => 'Anker und Kette – Ankerverfahren';

  @override
  String get pdfSbRules => 'Regeln an Bord';

  @override
  String get pdfSbEmergencyContacts => 'Notfallkontakte und UKW 16';

  @override
  String get pdfBriefingDeclaration =>
      'Alle Crewmitglieder wurden über die Sicherheitsregeln unterrichtet, haben sie verstanden und bestätigen dies mit ihrer Unterschrift.';

  @override
  String get pdfHashCoverage =>
      'Die Prüfsumme umfasst Törnname, Schiff, Crew und alle Einträge (UTC-Zeit, GPS, Geschwindigkeit, Kurs). Jede Datenänderung ändert die Prüfsumme.';

  @override
  String get pdfForCharterCompany => 'Für die Charterfirma';

  @override
  String get dutyRoster => 'Wachdienst';

  @override
  String get dutyStartAction => 'Wache übernehmen';

  @override
  String get dutyEndAction => 'Beenden';

  @override
  String get dutyStartTitle => 'Wer übernimmt die Wache?';

  @override
  String get dutyRunningChip => 'IM DIENST';

  @override
  String dutySince(String time) {
    return 'seit $time';
  }

  @override
  String dutyElapsed(int h, int m) {
    return '$h Std. $m Min.';
  }

  @override
  String get dutyNobodyOnDuty => 'Derzeit hat niemand Wache';

  @override
  String get dutyInspectionView => 'Für Kontrolle anzeigen';

  @override
  String get dutyRosterHistory => 'Wachplan';

  @override
  String get dutyAddRetrospective => 'Wache nachtragen';

  @override
  String get dutyEditTitle => 'Wache bearbeiten';

  @override
  String get dutyDeleteTitle => 'Wache löschen?';

  @override
  String dutyDeleteConfirm(String name) {
    return 'Der Wacheintrag für $name wird gelöscht.';
  }

  @override
  String get dutyNoCrewDefined => 'Für diese Fahrt ist keine Crew erfasst';

  @override
  String get dutyDefineCrew => 'Crew erfassen';

  @override
  String get dutyErrorEndBeforeStart => 'Das Ende muss nach dem Beginn liegen.';

  @override
  String dutyErrorOverlap(String name) {
    return '$name hat zu dieser Zeit bereits Wache.';
  }

  @override
  String get dutyErrorFutureStart =>
      'Der Beginn kann nicht in der Zukunft liegen.';

  @override
  String get dutyNoteLabel => 'Anmerkung';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'Seit $hours Std. im Dienst — vergessen zu beenden?';
  }

  @override
  String get dutyFrom => 'Von';

  @override
  String get dutyTo => 'Bis';

  @override
  String get dutyToOngoing => '— noch im Dienst';

  @override
  String get dutySelectPerson => 'Crewmitglied wählen';

  @override
  String get dutyNoRecords => 'Noch keine Wachen erfasst';

  @override
  String get logDutySection => 'Wachdienst';

  @override
  String get logDutyStillRunning => 'laufend';

  @override
  String get logEventAnchorDropped => 'Anker gefallen';

  @override
  String get logEventAnchorRaised => 'Anker gelichtet';

  @override
  String get logEventDriftOut => 'Drift – Radius überschritten';

  @override
  String get logEventDriftIn => 'Drift – Schiff zurück im Radius';

  @override
  String logEventDutyStart(String name) {
    return 'Wache übernommen: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Wache beendet: $name';
  }

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
  String get sunAndMoonCard => 'Sonne & Mond';

  @override
  String get sunriseLabel => 'Sonnenaufgang';

  @override
  String get sunsetLabel => 'Sonnenuntergang';

  @override
  String get moonPhaseLabel => 'Mondphase';

  @override
  String get moonIlluminationLabel => 'Beleuchtet';

  @override
  String get moonPhaseNew => 'Neumond';

  @override
  String get moonPhaseWaxingCrescent => 'Zunehmende Sichel';

  @override
  String get moonPhaseFirstQuarter => 'Erstes Viertel';

  @override
  String get moonPhaseWaxingGibbous => 'Zunehmender Mond';

  @override
  String get moonPhaseFull => 'Vollmond';

  @override
  String get moonPhaseWaningGibbous => 'Abnehmender Mond';

  @override
  String get moonPhaseLastQuarter => 'Letztes Viertel';

  @override
  String get moonPhaseWaningCrescent => 'Abnehmende Sichel';

  @override
  String get noSunMoonGps =>
      'GPS-Position für Sonnenauf-/-untergang erforderlich';

  @override
  String get oceanCurrentsTitle => 'Meeresströmungen';

  @override
  String get oceanCurrentsTooltip => 'Meeresströmungen';

  @override
  String get oceanCurrentsDisclaimer =>
      'Nur Orientierungsdaten (typische Richtung/Geschwindigkeit aus Seekarten) — nicht für präzise Navigation; Strömungen variieren saisonal.';

  @override
  String get tideCardTitle => 'Gezeiten';

  @override
  String get nextHighTideLabel => 'Nächste Flut';

  @override
  String get nextLowTideLabel => 'Nächste Ebbe';

  @override
  String get noTideData => 'Noch keine Gezeitendaten';

  @override
  String get downloadTides => 'Gezeitenvorhersage herunterladen';

  @override
  String get downloadingTides => 'Gezeitenvorhersage wird heruntergeladen...';

  @override
  String get tideMslWarning =>
      'Höhen beziehen sich auf den mittleren Meeresspiegel, nicht auf das Kartennull — niemals für die Wassertiefe unter dem Kiel verwenden.';

  @override
  String get tideNoCoverage =>
      'Für diese Position gibt es keine Gezeitendaten — sie liegt außerhalb des Seewettergebiets.';

  @override
  String get tideDownloadFailed =>
      'Gezeitenvorhersage konnte nicht heruntergeladen werden. Prüfe die Verbindung und versuche es erneut.';

  @override
  String get tideForecastExpired =>
      'Die gespeicherte Gezeitenvorhersage ist abgelaufen.';

  @override
  String tideForecastFarAway(int km) {
    return 'Vorhersage wurde $km km von hier heruntergeladen — lade sie für diese Position neu.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Heruntergeladen am $when — für die aktuelle Vorhersage neu laden.';
  }

  @override
  String get oceanCurrentCardTitle => 'Meeresströmung';

  @override
  String get oceanCurrentSetsToward => 'Setzt nach (Geschwindigkeit in Knoten)';

  @override
  String get oceanCurrentNoCoverage =>
      'Für diese Position gibt es keine Strömungsdaten.';

  @override
  String get oceanCurrentUnavailable =>
      'Strömungsvorhersage nicht verfügbar — prüfe die Verbindung.';

  @override
  String get tideOtherArea => 'Vorhersage für ein anderes Gebiet';

  @override
  String get tideAreaSearchLabel => 'Hafen, Ort oder Bucht';

  @override
  String get tideAreaSearchHint => 'z. B. Split';

  @override
  String get tideAreaNoResults =>
      'Nichts gefunden — versuche einen anderen Namen.';

  @override
  String tideForecastForArea(String place) {
    return 'Vorhersage für $place';
  }

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
  String get displaySettings => 'Anzeige';

  @override
  String get nightMode => 'Nachtmodus';

  @override
  String get nightModeDesc => 'Roter Filter zum Schutz der Nachtsicht';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get backupSection => 'Datensicherung';

  @override
  String get exportBackup => 'Sicherung exportieren';

  @override
  String get exportBackupDesc =>
      'Speichert das gesamte Logbuch (Fahrten, Einträge, Einstellungen) in einer Datei';

  @override
  String get restoreBackup => 'Aus Sicherung wiederherstellen';

  @override
  String get restoreBackupDesc =>
      'Ersetzt die aktuellen Daten durch den Inhalt einer ausgewählten Sicherungsdatei';

  @override
  String get restoreBlockedTrackingTitle => 'GPS-Tracking läuft';

  @override
  String get restoreBlockedTrackingBody =>
      'Beende das aktive Tracking der Fahrt, bevor du eine Sicherung wiederherstellst.';

  @override
  String get restoreSchemaTooNewTitle => 'Sicherung ist neuer';

  @override
  String get restoreSchemaTooNewBody =>
      'Diese Sicherung wurde mit einer neueren App-Version erstellt als der aktuell installierten. Aktualisiere zuerst die App.';

  @override
  String get restoreConfirmTitle => 'Aus Sicherung wiederherstellen?';

  @override
  String get restoreConfirmBody =>
      'Die aktuellen Daten werden durch den Inhalt der Sicherung ersetzt. Zuvor wird automatisch eine Sicherung des aktuellen Zustands erstellt.';

  @override
  String get restoreSuccess =>
      'Die Daten wurden erfolgreich aus der Sicherung wiederhergestellt.';

  @override
  String get restoreInvalidFile =>
      'Die ausgewählte Datei ist keine gültige HMB Sailing Log-Sicherung.';

  @override
  String get milesBookTitle => 'Meilenbuch';

  @override
  String get totalNm => 'Gesamt-NM';

  @override
  String get daysAtSea => 'Tage auf See';

  @override
  String get voyageCount => 'Anzahl Fahrten';

  @override
  String get nightHoursLabel => 'Nachtstunden';

  @override
  String get byYear => 'Nach Jahr';

  @override
  String get byVessel => 'Nach Schiff';

  @override
  String get addHistoricalVoyage => 'Historische Fahrt hinzufügen';

  @override
  String get editHistoricalVoyage => 'Historische Fahrt bearbeiten';

  @override
  String get deleteHistoricalVoyageConfirm =>
      'Diese historische Fahrt wirklich löschen?';

  @override
  String get manualEntryExplanation =>
      '* manueller Eintrag (von Hand eingegeben)';

  @override
  String get roleLabel => 'Rolle an Bord';

  @override
  String get roleSkipper => 'Skipper';

  @override
  String get roleCoSkipper => 'Co-Skipper';

  @override
  String get roleCrew => 'Crew';

  @override
  String get areaLabel => 'Gebiet / Route';

  @override
  String get distanceNmLabel => 'Distanz (NM)';

  @override
  String get daysCountLabel => 'Anzahl Tage';

  @override
  String get milesCertificateTitle => 'Bescheinigung der gesegelten Meilen';

  @override
  String get logbookRecordTitle => 'Logbucheintrag';

  @override
  String get logbookTrackedHint =>
      'Datum, Meilen, Revier und Rolle werden aus Tracking/Import berechnet.';

  @override
  String get vesselFlag => 'Registrierungsflagge';

  @override
  String get captainFirstName => 'Vorname des Skippers';

  @override
  String get captainLastName => 'Nachname des Skippers';

  @override
  String get captainQualification => 'Höchste erreichte Qualifikation';

  @override
  String get logbookSignatureSection =>
      'Unterschrift zur Bestätigung der Meilen';

  @override
  String get addSignature => 'Unterschrift hinzufügen';

  @override
  String get filterAllYears => 'Alle Jahre';

  @override
  String get filterCustomRange => 'Eigener Zeitraum';

  @override
  String get handoverMenuTitle => 'Übergabeprotokoll';

  @override
  String get checkInProtocol => 'Check-in-Protokoll';

  @override
  String get checkOutProtocol => 'Check-out-Protokoll';

  @override
  String get nextStepLabel => 'Nächster Schritt';

  @override
  String get readyToTrackHint => 'Bereit für Tracking';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Schritt $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Sicherheits-\neinweisung';

  @override
  String get handoverChecklistShort => 'Übergabe-\nChecklist';

  @override
  String get safetyBriefingRefTitle => 'Sicherheitseinweisung';

  @override
  String get handoverChecklistRefTitle => 'Übergabe-Checkliste';

  @override
  String get handoverDateTime => 'Datum und Uhrzeit';

  @override
  String get handoverLocation => 'Ort (Marina)';

  @override
  String get checklistItemOk => 'OK';

  @override
  String get checklistItemDamaged => 'Beschädigt';

  @override
  String get checklistItemMissing => 'Fehlt';

  @override
  String get damagePosition => 'Position am Boot';

  @override
  String get newDamageBadge => 'NEUER SCHADEN';

  @override
  String get companySignatureSection =>
      'Unterschrift des Vertreters der Charterfirma';

  @override
  String get companyRepName => 'Name des Vertreters';

  @override
  String get companyNameLabel => 'Firmenname';

  @override
  String get protocolClosedNotice =>
      'Das Protokoll ist abgeschlossen (beide Parteien haben unterschrieben) – nur lesbar.';

  @override
  String get handoverCertTitle => 'Schiffsübergabeprotokoll';

  @override
  String get itemSails => 'Segel';

  @override
  String get itemRigging => 'Takelage';

  @override
  String get itemAnchorChain => 'Anker und Kette';

  @override
  String get itemNavInstruments => 'Navigationsinstrumente';

  @override
  String get itemLifeJackets => 'Rettungswesten';

  @override
  String get itemRaft => 'Rettungsinsel';

  @override
  String get itemFirstAidKit => 'Erste-Hilfe-Kasten';

  @override
  String get itemDinghyMotor => 'Beiboot und Außenbordmotor';

  @override
  String get itemLights => 'Beleuchtung';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Zusätzliche Notizen';

  @override
  String get gpxImportTitle => 'GPX-Import';

  @override
  String get gpxImportPickFile => 'GPX-Datei auswählen';

  @override
  String get gpxTracksFound => 'Gefundene Tracks';

  @override
  String get gpxWaypointsFound => 'Gefundene Wegpunkte';

  @override
  String get gpxAssignTarget => 'Fahrt zuordnen';

  @override
  String get gpxNewVoyage => 'Neue Fahrt';

  @override
  String get gpxImportButton => 'Importieren';

  @override
  String get gpxImportSuccess => 'GPX erfolgreich importiert.';

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
      'Telefon mit dem Raymarine-WLAN verbinden (z. B. WiFi-1, RayNet). Die einzugebende IP ist NICHT die in den Raymarine-Einstellungen angezeigte — es ist die Gateway-IP dieses WLANs. Am Telefon: Einstellungen → WLAN → Netzwerkdetails → Gateway. Port 2000 (TCP) ist Standard. Ohne Verbindung nutzt die App automatisch das Telefon-GPS.';

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
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Lauschport';

  @override
  String get startListening => 'Starten';

  @override
  String get stopListening => 'Stoppen';

  @override
  String connectionListening(String port) {
    return 'Lauscht UDP auf Port $port';
  }

  @override
  String udpHint(String port) {
    return 'Simulator/Gateway so konfigurieren, dass UDP an die IP dieses Telefons, Port $port, gesendet wird.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Lausche auf UDP-Port $port';
  }

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
  String get engineSection => 'Motor & Tanks';

  @override
  String get engineHours => 'Motorstunden';

  @override
  String get fuel => 'Kraftstoff';

  @override
  String get fuelLevel => 'Kraftstoffstand';

  @override
  String get waterLevel => 'Wasserstand';

  @override
  String get noteSection => 'Notiz';

  @override
  String get noteHint => 'Segelbedingungen, Ereignisse, Crewwechsel...';

  @override
  String get quickPhotoLogTitle => 'Schnelleintrag';

  @override
  String get quickPhotoNoteHint => 'Was ist das? (optional)';

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
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Gespeichert: $pdf + $gpx';
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
  String get editWaypoint => 'Wegpunkt bearbeiten';

  @override
  String get waypointNameLabel => 'Name';

  @override
  String get skipperSignature => 'Unterschrift des Skippers';

  @override
  String get skipperNameLabel => 'Name des Skippers';

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
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Rufzeichen';

  @override
  String get vesselLengthM => 'Länge (m)';

  @override
  String get vesselBeamM => 'Breite (m)';

  @override
  String get vesselDraftM => 'Tiefgang (m)';

  @override
  String get selectExistingVoyage => 'Bestehende Reise auswählen';

  @override
  String get newVoyageForm => 'Neue Reise';

  @override
  String get fillFormAndBriefing =>
      'Formular ausfüllen & Sicherheitsunterw. unterschreiben';

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
  String get selectWaypointHint => 'Zum Wegpunkt navigieren';

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
  String get navInstruments => 'Bordinstrumente';

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
      'Online-Logbuch-Synchronisation — demnächst verfügbar';

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

  @override
  String get userGuide => 'Benutzerhandbuch';

  @override
  String get guideQuickStart => 'Schnellstart – 5 Schritte';

  @override
  String get guideQuickStartBody =>
      '1. Tippe oben auf die große Schaltfläche \"Reise starten\" (auf Karte, Logbuch oder Instrumente) – wähle die Eintragsfrequenz und die Aufzeichnung läuft, sonst muss nichts vorher ausgefüllt werden\n2. Gibt es eine offene Reise, fragt die App: fortsetzen oder neuen Eintrag beginnen\n3. Fehlende Angaben (Check-in, Sicherheitseinweisung, Schiffs-/Crew-Daten) trägst du jederzeit nach – die App erinnert dich mit Chips im Logbuch\n4. Trage tagsüber Einträge ein: Zeit, Position, Notiz\n5. Am Ende der Reise: Einstellungen → PDF-Export\n\nDie App läuft im Vollbildmodus – wische vom oberen oder unteren Rand, um die Systemleisten des Telefons vorübergehend einzublenden.';

  @override
  String get guideMapTitle => 'Karte';

  @override
  String get guideMapBody =>
      'Die Karte zeigt deine aktuelle Position und die Fahrtroute.\n\n• Blauer Punkt = aktuelle Position\n• Blaue Linie = gerade aufgezeichnete Route\n• Routen-Symbol – wähle eine Fahrt oder einen Tag, um die Route auf der Karte anzuzeigen (orange), ohne PDF-Export\n• Zwischen Satelliten- und Kartenansicht wechseln\n• Seezeichen – Schalter für nautische Markierungen (Wracks, Untiefen, Bojen)\n• Häfen – antippbare Ebene mit Ankerplätzen, Marinas und Häfen (OpenStreetMap-Daten): tippe auf ein Symbol für Name, VHF-Kanal, Telefon, Website, Tiefe oder Kapazität (sofern bekannt); der Ort lässt sich direkt als Wegpunkt speichern; die Ebene enthält auch Boots-Tankstellen (orange Zapfsäule)\n• Radar – Regenradar-Overlay (RainViewer), Bild aktualisiert sich ~alle 10 Minuten\n• Wind – Windrichtungs-/Stärke-Pfeile (Knoten) im Raster über dem sichtbaren Bereich\n• Lineal (lila Symbol) – tippe Punkte auf die Karte: Gesamt-NM, Kurs der letzten Etappe und ETA bei aktueller Geschwindigkeit; Punkte rasten an Wegpunkten ein\n• Offline-Karte (Download-Symbol) – lädt den sichtbaren Bereich (Karte + Seezeichen, aktueller Zoom +3 Stufen) für die Nutzung ohne Empfang; jede betrachtete Kachel wird zudem automatisch gespeichert\n• Im Nachtmodus wechselt die Karte automatisch zu dunklen Kacheln\n• Ankersymbol = Ankerposition (nur bei aktivem Ankeralarm)\n• Import-Symbol – lädt Tracks und Wegpunkte aus einer .gpx-Datei (siehe \"GPX-Import\")\n• Lange auf die Karte drücken = Wegpunkt hinzufügen (Navigationsziel); auf einen vorhandenen Wegpunkt tippen, um ihn umzubenennen oder zu löschen';

  @override
  String get guideInstrTitle => 'Marine-Instrumente';

  @override
  String get guideInstrBody =>
      'Die Instrumenten-Karte zeigt Navigationsdaten in Echtzeit.\n\n• SOG – Fahrt über Grund (Knoten)\n• TWS – wahre Windgeschwindigkeit\n• TWA – wahrer Windwinkel (grün = Steuerbord, rot = Backbord)\n• DEPTH – Wassertiefe (rot = unter 5 m)\n• VMG WP – Geschwindigkeit zu einem gewählten Wegpunkt; nach Auswahl siehst du Distanz/Peilung sowie einen Pfeil direkt auf der Kompassrose\n\nDatenquelle: Telefon-GPS oder Raymarine (TCP- oder UDP-WiFi-Gateway).\nVerbindungseinstellungen (inkl. TCP/UDP-Wahl): Einstellungen → Instrumente.';

  @override
  String get guideLogbookTitle => 'Fahrtenbuch';

  @override
  String get guideLogbookBody =>
      'Das Logbuch ist die Hauptregisterkarte für die Reiseverwaltung.\n\n• Die große Schaltfläche \"Reise starten\" oben startet die Aufzeichnung – gefragt wird nur nach der Frequenz der automatischen Einträge (bei jedem Neustart änderbar), kein Formular vorher nötig\n• Ist bereits eine Reise offen, fragt die App, ob sie fortgesetzt oder ein neuer Eintrag begonnen werden soll\n• Fehlende Angaben (Check-in, Sicherheitseinweisung, Schiffs-/Crew-Daten) werden mit farbigen Chips direkt auf der Reisekarte angezeigt – tippe auf einen Chip, um sie nachzutragen\n• Jeder Reisetag wird separat angezeigt\n• Einträge können tagsüber manuell hinzugefügt werden, inklusive Motorstunden, Kraftstoff und Wasser im Bereich \"Motor & Tanks\"\n• Während des Trackings erscheint unten links ein Kamera-Button – fotografiere einen interessanten Punkt und speichere ihn als schnellen Logbucheintrag mit Position und Zeit\n• Export als PDF über das Tagesmenü\n• Das Handschlag-Symbol in der Reisedetailansicht öffnet das Übergabeprotokoll (Check-in/Check-out)\n• Das ausführliche Reiseformular (Schiffssymbol im Detail) erfasst das Schiff samt Parametern, Fahrtgebiet, Crew mit den Scheinen des Skippers und Schiffsfotos (max. 3, erscheinen im PDF)\n• Unvollständige Karten (Sicherheitseinweisung, Check-in/out, Schiffskarte) blinken rot in der oberen Leiste der Reisedetails, bis sie ausgefüllt sind';

  @override
  String get guideMilesTitle => 'Meilenbuch';

  @override
  String get guideMilesBody =>
      'Zusammenfassung aller Reisen an einem Ort (Symbol im Fahrtenbuch).\n\n• Gesamt-Seemeilen, Tage auf See, Anzahl Fahrten und Nachtstunden\n• Aufschlüsselung nach Jahr und Schiff\n• Filter nach Jahr\n• Tippe auf eine Fahrt (auch eine getrackte/importierte), um den Logbucheintrag auszufüllen – Route, Flagge, Name und Qualifikation des Skippers, Unterschrift zur Bestätigung der Meilen\n• +-Taste – historische Fahrt vor der Nutzung der App hinzufügen (wird voll in die Zusammenfassungen eingerechnet, in der Liste mit Sternchen markiert)\n• PDF-Export einer Bescheinigung der gesegelten Meilen mit Unterschriftsfeld';

  @override
  String get guideHandoverTitle => 'Übergabeprotokoll (Check-in/Check-out)';

  @override
  String get guideHandoverBody =>
      'Formelle Aufzeichnung der Übernahme und Rückgabe des Bootes bei einem Charter – Handschlag-Symbol in der Reisedetailansicht.\n\n• Ausrüstungs-Checkliste (Segel, Takelage, Anker, Navigation, Rettungswesten, Rettungsinsel, Erste-Hilfe-Kasten, Beiboot, Beleuchtung, Bimini...) – OK / beschädigt / fehlt, mit Notiz, Position am Boot und Foto\n• Zustand von Kraftstoff, Wasser und Motorstunden\n• Unterschrift des Skippers und des Vertreters der Charterfirma\n• Das Protokoll wird schreibgeschützt, sobald beide unterschrieben haben\n• Check-out übernimmt die Daten aus dem Check-in-Protokoll und hebt neue Schäden hervor\n• PDF-Export mit beiden Unterschriften nebeneinander';

  @override
  String get guideGpxImportTitle => 'GPX-Import';

  @override
  String get guideGpxImportBody =>
      'Importiere Tracks und Wegpunkte aus anderen Navigations-Apps oder GPS-Geräten (Symbol auf der Karte).\n\n• .gpx-Datei vom Gerät auswählen\n• Ein mehrtägiger Export (mehrere Tracks in einer Datei, z. B. von Garmin Explore) wird automatisch zu einer einzigen Fahrt mit einem Tag pro Kalendertag zusammengeführt\n• Gefundene Tracks können auch manuell einer bestehenden Fahrt zugeordnet werden\n• Wegpunkte (auch aus Routen) werden direkt zur Karte hinzugefügt\n• Bei einer beschädigten Datei wird eine verständliche Fehlermeldung angezeigt';

  @override
  String get guideWeatherTitle => 'Wetter';

  @override
  String get guideWeatherBody =>
      'Die Wetter-Registerkarte zeigt die Vorhersage für deine aktuelle Position.\n\n• Aktualisiert sich automatisch bei Positionsänderung\n• Wind, Wellen, Temperatur und Bedingungen für die kommenden Stunden\n• Offline: letzte gespeicherte Vorhersage wird angezeigt\n\nSonne, Mond und Gezeiten:\n• Sonnenauf- und -untergang sowie die Mondphase werden auf dem Gerät berechnet — ohne Verbindung\n• Tippe auf Aktualisieren in der Gezeiten-Karte für eine 7-Tage-Vorhersage (kostenlos, ohne API-Schlüssel)\n• Gezeiten werden zwischengespeichert und bleiben offline lesbar; die Karte warnt, wenn die Vorhersage alt ist oder weit von hier geladen wurde\n• ⚠ Gezeitenhöhen beziehen sich auf den mittleren Meeresspiegel, nicht auf das Kartennull — niemals für die Wassertiefe unter dem Kiel verwenden\n\nMeeresströmung:\n• Die Karte Meeresströmung zeigt die echte Vorhersage für deine Position in Knoten und die Richtung, in die die Strömung setzt\n• Auf der Karte zeichnet die Doppelpfeil-Schaltfläche ein Strömungsgitter für den sichtbaren Bereich; die Pfeile zeigen, wohin das Wasser fließt\n• Nicht zu verwechseln mit der Ebene Ozeanströmungen — das ist eine Referenzkarte der großen globalen Strömungen';

  @override
  String get guideSafetyMobTitle => 'MOB & Anker';

  @override
  String get guideSafetyMobBody =>
      'Die Sicherheits-Registerkarte enthält Notfallfunktionen.\n\nMOB (Mann über Bord):\n• Roten MOB-Knopf gedrückt halten zum Aktivieren\n• App speichert GPS-Position und misst Zeit und Entfernung\n• Navigation zurück zum Fallpunkt\n\nAnkeralarm:\n• Ankerradius einstellen (empfohlen: 2× Kettenlänge)\n• Alarm vibriert, wenn das Boot den erlaubten Radius verlässt';

  @override
  String get guideSafetyBriefingTitle => 'Sicherheitseinweisung & MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'Die Sicherheits-Registerkarte enthält auch Referenzkarten.\n\n• Sicherheitseinweisung – Checkliste für die Crew vor der Abfahrt\n• Jedes Crewmitglied unterschreibt mit einer eigenen Bildschirm-Unterschrift\n• Unterschriften werden gespeichert und automatisch in den PDF-Charter-Export aufgenommen\n• Übergabe-Checkliste – Übersicht der Check-in/Check-out-Punkte, auch ohne offene Fahrt verfügbar\n• MAYDAY-Karte – Verfahren für Notrufe auf VHF-Kanal 16\n• COLREG – Kollisionsverhütungsregeln auf See (auf Slowakisch und Englisch verfügbar; andere Sprachen zeigen den englischen Text)\n• Notfallkontakte – Notrufnummern und Kontakte\n\nHinweis: Das Tracking kann jederzeit gestartet werden, auch ohne abgeschlossene Einweisung – die App erinnert nur mit einem Chip \"Sicherheitseinweisung fehlt\" im Logbuch, bis sie erledigt ist. Die Einweisung setzt eine ausgefüllte Schiffs- und Crew-Karte voraus und lässt sich erst speichern, wenn jedes Crew-Mitglied unterschrieben hat.';

  @override
  String get guideDutyTitle => 'Wachdienst';

  @override
  String get guideDutyBody =>
      'Ein Nachweis darüber, wer wann Wache hatte — unter Sicherheit, über dem Ankeralarm.\n\n• Wache übernehmen — eine oder mehrere Personen gleichzeitig wählen; jede beendet ihre Wache dann einzeln\n• Die Namen stammen aus der Crew der Fahrt. Ist keine Crew erfasst, führt die Schaltfläche zur Fahrtkarte\n• Die Anfangszeit lässt sich korrigieren, wenn du zu spät gedrückt hast\n• Für Kontrolle anzeigen — eine bildschirmfüllende Karte zum Vorzeigen an Bord: wer Wache hat, seit wann, Orts- und UTC-Zeit. Von dort ist nichts änderbar\n• Wachplan — Wache nachtragen oder bearbeiten. Ohne Endzeit läuft die Wache weiter\n• Eine Nachtwache über Mitternacht ist ein Eintrag, nicht zwei. Im PDF erscheint sie an beiden Tagen, mit Pfeil markiert\n• Beginn und Ende werden ins Logbuch und in den PDF-Export geschrieben\n\nHinweis: Die App beendet eine Wache nie von selbst. Nach 12 Stunden warnt sie nur — eine Endzeit, die du nicht beobachtet hast, wäre erfunden.';

  @override
  String get guideCompassTitle => 'Peilkompass';

  @override
  String get guideCompassBody =>
      'Die Kompass-Registerkarte zeigt den Magnetkurs mithilfe der Telefonsensoren, mit der Rückkamera als Hintergrund zum Anpeilen von Objekten.\n\n• Gelbes Fadenkreuz – Richtung, in die du zielst\n• Kompassstreifen oben – N / NE / E / SE / S / SW / W / NW\n• Numerische Anzeige – Grad und Himmelsrichtung\n• Grüner Punkt = stabiles Ergebnis  ·  Oranger Punkt = kalibriert noch\n\nBei instabiler Anzeige: Telefon langsam in einer Achterbewegung führen.\n\nHinweis: Genauigkeit kann durch Metallstrukturen, Lautsprecher oder Elektronik beeinträchtigt werden.';

  @override
  String get guideSettingsTitle => 'Einstellungen';

  @override
  String get guideSettingsBody =>
      '• Sprache – App-Sprache ändern\n• Instrumente – Raymarine WiFi-Gateway IP-Adresse einstellen (TCP oder UDP)\n• GPS-Quelle – Telefon oder Raymarine\n• Einheiten – Knoten/km/h, Meter/Fuß\n• Häufigkeit der Logbucheinträge\n• Anzeige – Nachtmodus (Rotfilter für Nachtvisionsschutz)\n• Online-Konto – Synchronisation in Vorbereitung (v2.0)\n• Datensicherung – siehe \"Datensicherung und Wiederherstellung\"\n• Über die App – Version und Kontakt';

  @override
  String get guideBackupTitle => 'Datensicherung und Wiederherstellung';

  @override
  String get guideBackupBody =>
      'In Einstellungen → Datensicherung.\n\n• Sicherung exportieren – speichert das gesamte Logbuch (Fahrten, Einträge, Einstellungen) in einer Datei (.hmbbackup), die du per E-Mail, in die Cloud oder lokal speichern kannst\n• Aus Sicherung wiederherstellen – ersetzt die aktuellen Daten durch den Inhalt der ausgewählten Sicherung; zuvor wird automatisch eine Sicherung des aktuellen Zustands erstellt\n• Die Wiederherstellung ist gesperrt, während das GPS-Tracking einer Fahrt aktiv ist\n• Eine Sicherung mit einer neueren Schema-Version als von der App unterstützt wird abgelehnt, mit Erklärung';

  @override
  String get guideExportTitle => 'Logbuch-Export';

  @override
  String get guideExportBody =>
      'Das Logbuch kann als professionelles PDF-Dokument exportiert werden.\n\n1. Logbuch öffnen → Charter auswählen\n2. Export-Symbol oder drei Punkte tippen → PDF exportieren\n3. Als Skipper unterschreiben → PDF wird erstellt\n4. PDF enthält: Route, Einträge, Fotos, Titelseite mit Schiffsfoto aus der Schiffskarte (falls hochgeladen), Sicherheitseinweisung mit Crew-Unterschriften\n5. Per E-Mail teilen, drucken oder auf dem Telefon speichern\n\nJedes PDF erhält eine eindeutige Dokument-ID (z.B. HMBSL-5-2026) und eine Revisionsnummer (Rev. 1, Rev. 2...) in der Fußzeile jeder Seite. Bei jedem neuen Export wird die Nummer automatisch erhöht – so ist sichtbar, wie oft das Dokument erstellt wurde.\n\nDer QR-Code auf der Unterschriftsseite enthält ID, Revision und einen kryptografischen Fingerabdruck des Inhalts. Jede Datenänderung ändert den QR-Code.\n\nDas PDF wird in der eingestellten App-Sprache erzeugt, samt Namen und Diakritika. Jede Tagesseite enthält zudem eine Übersicht des Wachdiensts.';

  @override
  String get safetyBriefingScreenTitle => 'Sicherheitseinweisung';

  @override
  String get briefingCrewSignaturesSection => 'Unterschriften der Crew';

  @override
  String get briefingSignHere => 'Hier unterschreiben';

  @override
  String get briefingClear => 'Löschen';

  @override
  String get briefingSigned => 'Unterschrieben';

  @override
  String get briefingSave => 'Unterschriften speichern';

  @override
  String get briefingSavedOk => 'Unterschriften gespeichert';

  @override
  String get briefingOpenBriefing => 'Sicherheitseinweisung';

  @override
  String get briefingSkipper => 'Skipper';

  @override
  String get briefingCrew => 'Crew';

  @override
  String get briefingNoCrew =>
      'Keine Crew definiert. Crew-Mitglieder in den Reiseeinstellungen hinzufügen.';

  @override
  String get briefingDate => 'Datum';

  @override
  String get briefingLocation => 'Ort';

  @override
  String get briefingDoneLabel => 'Sicherheitseinweisung abgeschlossen';

  @override
  String get briefingDoneSubtitle =>
      'Alle Unterschriften gespeichert. Keine Wiederholung erforderlich.';

  @override
  String get briefingEditSignature => 'Unterschrift ändern';

  @override
  String get briefingRequiredTitle => 'Sicherheitseinweisung erforderlich';

  @override
  String get briefingRequiredBody =>
      'Bitte Sicherheitseinweisung abschließen und Unterschriften sammeln, bevor das erste Tracking gestartet wird.';

  @override
  String get goToBriefing => 'Zur Einweisung';

  @override
  String get skipperProfile => 'Skipper-Profil';

  @override
  String get skipperProfileHint =>
      'Diese Daten erscheinen im PDF-Export der Fahrt.';

  @override
  String get skipperFullName => 'Name des Skippers';

  @override
  String get skipperLicenseSection => 'Skipper-Lizenz';

  @override
  String get skipperLicenseType => 'Lizenztyp';

  @override
  String get skipperLicenseNumber => 'Lizenznummer';

  @override
  String get skipperLicenseAuthority => 'Ausstellende Behörde';

  @override
  String get skipperLicenseExpiry => 'Gültig bis';

  @override
  String get skipperVhfSection => 'VHF / SRC-Lizenz';

  @override
  String get skipperVhfNumber => 'VHF/SRC-Nummer';

  @override
  String get skipperVhfExpiry => 'VHF gültig bis';

  @override
  String get skipperOtherCerts => 'Weitere Zertifikate / Lizenzen';

  @override
  String get skipperOtherCertsHint =>
      'z.B. Yachtmaster, RYA, STCW, Rettungskurse...';

  @override
  String get continueLastVoyageTitle => 'Letzte Reise fortsetzen?';

  @override
  String get continueVoyageAction => 'Fortsetzen';

  @override
  String get newRecordAction => 'Neuer Eintrag';

  @override
  String get missingCheckInChip => 'Check-in fehlt';

  @override
  String get missingBriefingChip => 'Sicherheitseinweisung fehlt';

  @override
  String get missingDetailsChip => 'Schiffs-/Crew-Daten fehlen';

  @override
  String get missingCheckOutChip => 'Check-out fehlt';

  @override
  String get vesselModel => 'Modell';

  @override
  String get vesselTypeMonohull => 'Einrumpf';

  @override
  String get vesselTypeCatamaran => 'Katamaran';

  @override
  String get vesselTypeTrimaran => 'Trimaran';

  @override
  String get vesselTypeMotorYacht => 'Motoryacht';

  @override
  String get vesselTypeGulet => 'Gulet';

  @override
  String get vesselTypeDinghy => 'Beiboot';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Andere';

  @override
  String get charterCompanyLabel => 'Charterfirma';

  @override
  String get yachtParamsSection => 'Yacht-Parameter';

  @override
  String get berthsLabel => 'Kojen';

  @override
  String get yearBuiltLabel => 'Baujahr';

  @override
  String get waterTankLabel => 'Wassertank';

  @override
  String get fuelTankLabel => 'Kraftstofftank';

  @override
  String get engineHoursStartLabel => 'Motorstunden · Start';

  @override
  String get engineHoursEndLabel => 'Motorstunden · Ende';

  @override
  String get whereWhenSection => 'Wo & wann';

  @override
  String get countryLabel => 'Land';

  @override
  String get cruisingAreaLabel => 'Fahrtgebiet';

  @override
  String get charterContactsSection => 'Charter-Kontakte';

  @override
  String get charterContactsHint =>
      'Bis zu 3 Nummern für Anruf / WhatsApp / SMS. Immer mit internationaler Vorwahl (z. B. +385...).';

  @override
  String get addPhoneNumber => 'Telefonnummer hinzufügen';

  @override
  String get costsSection => 'Kosten';

  @override
  String get charterPriceLabel => 'Charterpreis';

  @override
  String get currencyLabel => 'Währung';

  @override
  String get addCostItem => 'Kosten hinzufügen';

  @override
  String get costName => 'Kostenbezeichnung';

  @override
  String get crewSectionHint =>
      'Tippe auf das Abzeichen, um den Skipper festzulegen — der Rest ist Crew.';

  @override
  String get addCrewMember => 'Crew-Mitglied hinzufügen';

  @override
  String get crewNameLabel => 'Name';

  @override
  String get skipperBadge => 'SKIPPER';

  @override
  String get crewBadge => 'CREW';

  @override
  String get vesselTypeSailboat => 'Segelboot';

  @override
  String get vesselTypeMotorBoat => 'Motorboot';

  @override
  String get sbNeedsVesselCard =>
      'Fülle zuerst die Schiffs- und Crew-Karte aus — die Sicherheitseinweisung braucht die Crew-Liste für Unterschriften.';

  @override
  String get prefillSkipperTitle => 'Gespeicherte Skipper-Daten übernehmen?';

  @override
  String get prefillSkipperFill => 'Übernehmen';

  @override
  String get prefillSkipperNew => 'Neuer Skipper';

  @override
  String get boatLicenceLabel => 'Bootsführerschein-Nr.';

  @override
  String get radioLicenceLabel => 'Funkschein-Nr.';

  @override
  String get vesselPhotosSection => 'Schiffsfotos (max. 3)';

  @override
  String get addPhotoLabel => 'Hinzufügen';

  @override
  String get createVoyageButton => 'Reise erstellen';

  @override
  String get saveVoyageButton => 'Reise speichern';

  @override
  String get costBaseCharter => 'Charter-Grundpreis';

  @override
  String get costDeposit => 'Kaution';

  @override
  String get costDinghyOutboard => 'Beiboot / Außenborder';

  @override
  String get costOutboardFuel => 'Kraftstoff Außenborder';

  @override
  String get costTransitLog => 'Transitlog';

  @override
  String get costTouristTax => 'Kurtaxe';

  @override
  String get costFinalCleaning => 'Endreinigung';

  @override
  String get costLinenTowels => 'Bettwäsche und Handtücher';

  @override
  String get costWifi => 'WLAN';

  @override
  String get costSupKayak => 'SUP / Kajak';

  @override
  String get costSkipperFee => 'Skipper-Gebühr';

  @override
  String get costHostessFee => 'Hostessen-Gebühr';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m m';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Ungefähre Position · ±$m m · Netzwerkortung';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Letzte bekannte Position · vor $mins Min.';
  }

  @override
  String get locationQualityUnknown => 'Genauigkeit unbekannt';

  @override
  String get locationQualityMocked => '⚠️ Fake-Standort erkannt';

  @override
  String get syncQueueTitle => 'Sync-Warteschlange';

  @override
  String get syncQueueEmpty => 'Warteschlange ist leer';

  @override
  String get syncNowAction => 'Jetzt synchronisieren';

  @override
  String get syncRetryFailedAction => 'Erneut versuchen';

  @override
  String get syncStatusPending => 'Wartend';

  @override
  String get syncStatusSending => 'Wird gesendet';

  @override
  String get syncStatusSent => 'Gesendet';

  @override
  String get syncStatusFailed => 'Fehlgeschlagen';

  @override
  String get syncStatusConflict => 'Konflikt';

  @override
  String get syncStatusDeferred => 'Zurückgestellt';

  @override
  String syncRetryCount(int n) {
    return 'Versuch $n';
  }

  @override
  String get syncOffline => 'offline';

  @override
  String syncPendingCount(int n) {
    return '$n wartend';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n zurückgestellt';
  }

  @override
  String syncFailedCount(int n) {
    return '$n fehlgeschlagen';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Anhang wartet auf WLAN (auf See meist nicht verfügbar).';

  @override
  String get syncWifiOverrideAction => 'Mobile Daten verwenden';

  @override
  String get syncWifiOverrideActive => 'Mobile Daten für Anhänge erlaubt';

  @override
  String get syncClearQueueAction => 'Warteschlange leeren';

  @override
  String get syncClearQueueConfirmTitle => 'Gesamte Warteschlange leeren?';

  @override
  String get syncClearQueueConfirmContent =>
      'Entfernt alle Einträge in der Sync-Warteschlange, auch bereits gesendete. Kann nicht rückgängig gemacht werden.';

  @override
  String get syncClearQueueDone => 'Warteschlange geleert';

  @override
  String get syncEnableToggle => 'Logbuch synchronisieren';

  @override
  String get syncEnableToggleDesc =>
      'Einträge an den Server senden, solange die App offen und online ist';

  @override
  String get syncTargetLabel => 'Sync-Ziel';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Eigener Server';

  @override
  String get syncCustomUrlLabel => 'Server-URL';

  @override
  String get syncCustomTokenLabel => 'Token';

  @override
  String get syncTestConnectionAction => 'Verbindung testen';

  @override
  String get syncTestSuccess => 'Verbindung funktioniert';

  @override
  String syncTestFailure(String detail) {
    return 'Fehlgeschlagen: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Server-URL eingeben';

  @override
  String get syncUrlErrorInvalid => 'Ungültige URL';

  @override
  String get syncUrlErrorHttps => 'URL muss mit https:// beginnen';

  @override
  String get syncIntervalLabel => 'Sync-Intervall';

  @override
  String syncIntervalMinutes(int n) {
    return '$n Min.';
  }

  @override
  String get syncIntervalNote =>
      'Synchronisierung läuft nur, solange die App geöffnet ist';

  @override
  String get syncAttachmentPolicyLabel => 'Anhänge (Fotos)';

  @override
  String get syncAttachmentNever => 'Nie';

  @override
  String get syncAttachmentWifiOnly => 'Nur WLAN';

  @override
  String get syncAttachmentAlways => 'Immer';

  @override
  String get syncBackfillAction => 'Ältere Einträge nachtragen';

  @override
  String get syncBackfillDesc =>
      'Nimmt Einträge, die bei ausgeschalteter Synchronisierung entstanden sind, in die Warteschlange auf';

  @override
  String syncBackfillResult(int n) {
    return '$n nachgetragen';
  }

  @override
  String get syncBackfillNone =>
      'Nichts nachzutragen — alles ist bereits in der Warteschlange oder gesendet';

  @override
  String get syncCloudEnableToggle => 'Cloud-Export (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Nach der Anmeldung werden PDF und GPX jedes beendeten Tages automatisch zu Google Drive hochgeladen. Ohne Anmeldung bleibt alles nur auf dem Gerät.';

  @override
  String get syncCloudSignInAction => 'Mit Google anmelden';

  @override
  String get syncCloudSignOutAction => 'Abmelden';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Angemeldet als $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Nicht angemeldet';
}
