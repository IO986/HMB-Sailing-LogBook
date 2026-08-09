// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get poiTypeAnchorage => 'Kotwicowisko';

  @override
  String get poiTypeMarina => 'Marina';

  @override
  String get poiTypeFuel => 'Stacja paliw';

  @override
  String get poiTypeHarbour => 'Port';

  @override
  String get poiVhfChannel => 'Kanał VHF';

  @override
  String get poiPhone => 'Telefon';

  @override
  String get poiWebsite => 'Strona';

  @override
  String get poiEmail => 'Email';

  @override
  String get poiCapacity => 'Pojemność';

  @override
  String get poiServices => 'Usługi';

  @override
  String get poiSaveAsWaypoint => 'Zapisz jako punkt trasy';

  @override
  String poiWaypointSaved(String name) {
    return 'Punkt trasy \"$name\" zapisany';
  }

  @override
  String get poiSource => 'Źródło: OpenStreetMap';

  @override
  String get mapLayerSatellite => 'Satelita';

  @override
  String get mapLayerMap => 'Mapa';

  @override
  String get mapLayers => 'Warstwy';

  @override
  String get mapSeamarks => 'Znaki morskie';

  @override
  String get mapHarbours => 'Porty i kotwicowiska';

  @override
  String get mapZoomInForPois =>
      'Przybliż mapę, aby wczytać porty i kotwicowiska';

  @override
  String get mapRainRadar => 'Radar opadów';

  @override
  String get mapOceanCurrentsTooltip =>
      'Prądy oceaniczne (przytrzymaj, aby zobaczyć listę)';

  @override
  String get mapCurrentForecast => 'Prąd morski — prognoza (kt)';

  @override
  String get mapTools => 'Narzędzia';

  @override
  String get mapVoyageOverview => 'Przegląd rejsu';

  @override
  String get mapRuler => 'Linijka / trasa';

  @override
  String get mapDownloadOffline => 'Pobierz obszar offline';

  @override
  String get mapGpsDisabled => 'GPS jest wyłączony';

  @override
  String get mapLocationDenied => 'Lokalizacja niedozwolona';

  @override
  String get mapFollowGps => 'Śledź GPS';

  @override
  String mapAreaTooLarge(int count) {
    return 'Obszar jest zbyt duży ($count kafelków). Przybliż mapę i spróbuj ponownie.';
  }

  @override
  String get mapLivePreview => 'Na żywo (bieżący tracking)';

  @override
  String get mapWholeVoyage => 'Cały rejs';

  @override
  String get offlineSheetTitle => 'Mapa offline widocznego obszaru';

  @override
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb) {
    return 'Mapa + znaki morskie, zoom $minZ–$maxZ, $tiles kafelków (~$mb MB). Pobrane obszary działają na morzu bez zasięgu.';
  }

  @override
  String offlineDone(int n) {
    return 'Gotowe — zapisano $n kafelków';
  }

  @override
  String offlineDoneErrors(int n) {
    return 'Gotowe z błędami: nie udało się pobrać $n kafelków';
  }

  @override
  String get downloadAction => 'Pobierz';

  @override
  String get rulerTapHint => 'Dotknij punktów na mapie';

  @override
  String get mapEntryPhoto => 'Wpis foto';

  @override
  String get mapEntryNote => 'Wpis dziennika';

  @override
  String get openSettingsAction => 'Otwórz ustawienia';

  @override
  String get morseConverter => 'Konwerter tekst → Morse';

  @override
  String saveError(String error) {
    return 'Błąd zapisu: $error';
  }

  @override
  String get languageName => 'Polski';

  @override
  String get navMap => 'Mapa';

  @override
  String get navTracking => 'Śledzenie';

  @override
  String get navLogbook => 'Dziennik';

  @override
  String get navWeather => 'Pogoda';

  @override
  String get navSafety => 'Bezpieczeństwo';

  @override
  String get navCompass => 'Kompas';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get navCustomizeTitle => 'Dolne menu';

  @override
  String get navCustomizeHint =>
      'Przytrzymaj i przeciągnij, aby zmienić kolejność ikon. Przełącznikiem ukryjesz kartę z dolnego menu — Ustawienia są zawsze widoczne.';

  @override
  String get navAlwaysShown => 'Zawsze widoczne';

  @override
  String get navIconSizeLabel => 'Rozmiar ikon';

  @override
  String get navOpenHiddenTitle => 'Otwórz ukryte karty';

  @override
  String get cameraPermissionDenied =>
      'Odmówiono dostępu do kamery. Włącz go w ustawieniach urządzenia.';

  @override
  String get cameraUnavailable => 'Kamera niedostępna';

  @override
  String get compassCalibrationNote =>
      'Kompas magnetyczny. Na dokładność może wpływać metal lub elektronika w pobliżu. Nieskalibrowany kompas kalibruj ruchem w kształcie ósemki.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get edit => 'Edytuj';

  @override
  String get save => 'Zapisz';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Zamknij';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get share => 'Udostępnij';

  @override
  String get selectAll => 'Zaznacz wszystko';

  @override
  String get error => 'Błąd';

  @override
  String errorMsg(String msg) {
    return 'Błąd: $msg';
  }

  @override
  String get pressBackToExit => 'Naciśnij Wstecz ponownie, aby wyjść';

  @override
  String get trackingRunningTitle => 'Śledzenie działa';

  @override
  String get trackingRunningContent =>
      'Śledzenie jest aktywne. Co chcesz zrobić?';

  @override
  String get stopAndExit => 'Zatrzymaj i wyjdź';

  @override
  String get keepRunning => 'Zostaw uruchomione';

  @override
  String get marineInstrumentsTitle => 'Przyrządy pokładowe';

  @override
  String get marineInstrumentsPrompt =>
      'Chcesz połączyć aplikację z przyrządami pokładowymi (np. Raymarine przez WiFi gateway)? Aplikacja będzie wtedy czytać GPS, wiatr, głębokość i inne dane bezpośrednio z jachtu.\n\nBez połączenia użyty zostanie GPS telefonu i prognoza pogody z internetu – w każdej chwili zmienisz to w Ustawieniach.';

  @override
  String get notNow => 'Nie teraz';

  @override
  String get setupConnection => 'Skonfiguruj połączenie';

  @override
  String get autoDetectAction => 'Autowykrywanie';

  @override
  String get autoDetectWifiHintTitle => 'Najpierw połącz się z WiFi jachtu';

  @override
  String get autoDetectWifiHintBody =>
      'Sprawdź w Ustawieniach telefonu → WiFi, że jesteś połączony z siecią przyrządów pokładowych (np. RayNet, WiFi-1). Wtedy aplikacja spróbuje automatycznie znaleźć gateway w tej sieci.';

  @override
  String get openWifiSettings => 'Ustawienia WiFi';

  @override
  String get continueAction => 'Kontynuuj';

  @override
  String get autoDetecting => 'Szukam przyrządów w sieci WiFi…';

  @override
  String get autoDetectFailed =>
      'Nie znaleziono gateway. Sprawdź, czy jesteś połączony z siecią WiFi jachtu, lub podaj IP ręcznie w Ustawieniach.';

  @override
  String autoDetectSuccess(String host) {
    return 'Połączono z $host';
  }

  @override
  String get guidePromptTitle => 'Pierwszy raz tutaj? Szybki przewodnik';

  @override
  String get guidePromptBody =>
      'Aplikacja ma krótki przewodnik użytkownika – mapa, dziennik pokładowy, pogoda, lista kontrolna bezpieczeństwa i więcej. Chcesz rzucić okiem teraz? Znajdziesz go też później w Ustawieniach → Przewodnik użytkownika.';

  @override
  String get guidePromptAction => 'Pokaż przewodnik';

  @override
  String get notifPromptTitle => 'Zezwolić na powiadomienia?';

  @override
  String get notifPromptBody =>
      'Podczas śledzenia rejsu powiadomienie pozostaje na pasku stanu i ekranie blokady — widzisz, że śledzenie jest aktywne, i masz do niego szybki dostęp. Bez zgody system może ograniczyć śledzenie w tle.';

  @override
  String get notifPromptAllow => 'Zezwól';

  @override
  String get trackingActiveTitle => 'Śledzenie aktywne';

  @override
  String get trackingTitle => 'Śledzenie';

  @override
  String get waitingForGps => 'Czekam na GPS...';

  @override
  String get gpsUnavailable => 'GPS niedostępny';

  @override
  String get lastKnownPosition => 'Ostatnia znana pozycja';

  @override
  String get accuracy => 'Dokładność';

  @override
  String get logbookBtn => 'Dziennik';

  @override
  String get stop => 'Zatrzymaj';

  @override
  String get stopTrackingDay => 'Zakończyć śledzenie?';

  @override
  String get startVoyage => 'Rozpocznij rejs';

  @override
  String get starting => 'Uruchamiam...';

  @override
  String get newVoyage => 'Nowy rejs';

  @override
  String get multiday => 'Wielodniowy';

  @override
  String get standalone => 'Samodzielny';

  @override
  String get voyageName => 'Nazwa rejsu';

  @override
  String get voyageNameOptional => 'Nazwa (opcjonalnie)';

  @override
  String get voyageNameHint => 'np. Wypad do zatoki';

  @override
  String get existingVoyage => 'Kontynuacja istniejącego rejsu';

  @override
  String get newVoyageDropdown => '— Nowy rejs —';

  @override
  String get firstVoyageHint => 'Pierwszy rejs – uzupełnij podstawowe info:';

  @override
  String get briefingRequiredHint =>
      'Śledzenie można uruchomić dopiero po ukończeniu Safety Briefingu dla danego rejsu.';

  @override
  String get briefingPending => 'Wymagany SB';

  @override
  String get briefingPendingListWarning =>
      'Safety Briefing nieukończony – śledzenia jeszcze nie można uruchomić';

  @override
  String get estimatedDays => 'Przewidywana liczba dni:';

  @override
  String get logFrequency => 'Częstotliwość zapisów w dzienniku';

  @override
  String get startTracking => 'Uruchom śledzenie';

  @override
  String get trackingInProgress => 'Śledzenie rejsu';

  @override
  String dayNofTotal(int n, int total) {
    return 'Dzień $n z $total';
  }

  @override
  String get newDay => '(nowy dzień)';

  @override
  String get endVoyageTitle => 'Koniec rejsu?';

  @override
  String get endVoyageContent =>
      'Osiągnąłeś ostatni zaplanowany dzień rejsu.\n\nCzy rejs będzie kontynuowany jutro?';

  @override
  String get decideLayer => 'Zdecyduję później';

  @override
  String get continuesTomorrow => 'Kontynuuje jutro';

  @override
  String get endVoyage => 'Zakończ rejs';

  @override
  String get newMultidayVoyage => 'Nowy wielodniowy rejs';

  @override
  String get deleteCharterTitle => 'Usunąć czarter?';

  @override
  String get deleteCharterContent => 'Usunięte zostaną wszystkie dni i wpisy.';

  @override
  String get cannotDeleteWhileTracking =>
      'Nie można usunąć rejsu podczas aktywnego śledzenia.';

  @override
  String get noVoyages => 'Brak rejsów';

  @override
  String get createFirstCharter => 'Utwórz swój pierwszy czarter';

  @override
  String get briefingDone => 'Briefing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Nie znaleziono rejsu';

  @override
  String get unknownVessel => 'Nieznana jednostka';

  @override
  String get captain => 'Skipper';

  @override
  String get crew => 'Załoga';

  @override
  String get total => 'Razem';

  @override
  String voyageDaysCount(int n) {
    return 'Dni rejsu ($n)';
  }

  @override
  String get bulkDelete => 'Usuwanie zbiorcze';

  @override
  String get noDays =>
      'Brak dni.\nUruchom śledzenie, a pierwszy dzień utworzy się automatycznie.';

  @override
  String get deleteDayTitle => 'Usunąć dzień?';

  @override
  String deleteDayContent(String day) {
    return 'Usunięte zostaną wszystkie wpisy dla $day.';
  }

  @override
  String get exportPdf => 'Eksport PDF';

  @override
  String get selectDaysTitle => 'Wybierz dni do usunięcia';

  @override
  String deleteCount(int n) {
    return 'Usuń ($n)';
  }

  @override
  String get safety => 'Bezpieczeństwo';

  @override
  String get mobHoldToActivate => 'Przytrzymaj, aby aktywować';

  @override
  String get mobActive => '⚠️ MOB AKTYWNY';

  @override
  String get mobTime => 'Czas';

  @override
  String get mobDistance => 'Odległość';

  @override
  String get mobDirection => 'Kierunek';

  @override
  String get navigateToMob => 'Nawiguj do MOB';

  @override
  String get gpsPositionNotAvailable => 'Pozycja GPS niedostępna!';

  @override
  String get anchorAlarm => 'Alarm kotwiczny';

  @override
  String get drifting => 'DRYFUJE';

  @override
  String get anchorRadiusLabel => 'Monitorowany promień ruchu';

  @override
  String get activate => 'Aktywuj';

  @override
  String get deactivate => 'Dezaktywuj';

  @override
  String get safetyBriefingCard => 'Safety Briefing';

  @override
  String get maydayCard => 'Karta Mayday';

  @override
  String get yachtHandover => 'Przekazanie jachtu';

  @override
  String get gearList => 'Lista wyposażenia';

  @override
  String get pdfEntriesSection => 'Wpisy dziennika';

  @override
  String get pdfSkipperMessage => 'Raport skippera';

  @override
  String get pdfWeatherSection => 'Pogoda';

  @override
  String get pdfDaySummary => 'Przegląd dnia';

  @override
  String get pdfDaysOverview => 'Przegląd dni';

  @override
  String get pdfVoyageSummary => 'Podsumowanie rejsu';

  @override
  String get pdfCrewSection => 'Załoga';

  @override
  String get pdfSignatures => 'Podpisy';

  @override
  String get pdfCrewSignatures => 'Podpisy załogi';

  @override
  String get pdfSkipperSignature => 'Podpis skippera';

  @override
  String get pdfSkipperLicences => 'Skipper – licencje';

  @override
  String get pdfSafetyBriefing => 'Odprawa bezpieczeństwa';

  @override
  String get pdfChecklistSection => 'Lista kontrolna';

  @override
  String get pdfMoreNotes => 'Dodatkowe uwagi';

  @override
  String get pdfIntegrityCheck => 'Weryfikacja integralności dokumentu';

  @override
  String get pdfHandoverTitle => 'Protokół przekazania';

  @override
  String get pdfMilesTitle => 'Potwierdzenie przepłyniętych mil';

  @override
  String get pdfDeparture => 'Wypłynięcie';

  @override
  String get pdfArrival => 'Przypłynięcie';

  @override
  String get pdfTotalLabel => 'Suma';

  @override
  String get pdfDayCount => 'Liczba dni';

  @override
  String get pdfEngineHours => 'Motogodziny';

  @override
  String get pdfFuelLabel => 'Paliwo';

  @override
  String get pdfWaterLabel => 'Woda';

  @override
  String get pdfVesselLabel => 'Jednostka';

  @override
  String get pdfSkipperLabel => 'Skipper';

  @override
  String get pdfDateLabel => 'Data';

  @override
  String get pdfColFrom => 'Skąd';

  @override
  String get pdfColTo => 'Dokąd';

  @override
  String get pdfColEntriesShort => 'Wpisy';

  @override
  String get pdfColTimeUtc => 'Czas UTC';

  @override
  String get pdfColWind => 'Wiatr';

  @override
  String get pdfColPropulsion => 'Napęd';

  @override
  String get pdfColWeatherShort => 'Pog.';

  @override
  String get pdfColNote => 'Uwaga';

  @override
  String get pdfColDay => 'Dzień';

  @override
  String get pdfColItem => 'Pozycja';

  @override
  String get pdfColStatus => 'Stan';

  @override
  String get pdfColNotePosition => 'Uwaga / pozycja';

  @override
  String get pdfColPhoto => 'Foto';

  @override
  String get pdfColDateRange => 'Data od-do';

  @override
  String get pdfColArea => 'Akwen';

  @override
  String get pdfColRole => 'Rola';

  @override
  String get pdfNoData => 'Brak danych';

  @override
  String get pdfMapUnavailable => 'Mapa GPS niedostępna';

  @override
  String get pdfUnsigned => 'Niepodpisane';

  @override
  String get pdfNoSignatures => 'Brak podpisów';

  @override
  String get pdfSha256Label => 'Odcisk SHA-256 danych dziennika:';

  @override
  String get pdfVerifyQr => 'QR weryfikacyjny';

  @override
  String get pdfSbLifejackets =>
      'Kamizelki ratunkowe – umiejscowienie i użycie';

  @override
  String get pdfSbLifebuoy => 'Koło ratunkowe i procedura MOB';

  @override
  String get pdfSbFlares => 'Flary – typy i użycie';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – aktywacja';

  @override
  String get pdfSbVhf => 'Radio VHF – kanał 16, procedura Mayday';

  @override
  String get pdfSbExtinguisher => 'Gaśnica – umiejscowienie i użycie';

  @override
  String get pdfSbFirstAid => 'Apteczka – umiejscowienie';

  @override
  String get pdfSbEngineStop => 'Awaryjne wyłączenie silnika';

  @override
  String get pdfSbLeaks => 'Wycieki – woda, gaz';

  @override
  String get pdfSbAnchor => 'Kotwica i łańcuch – procedura kotwiczenia';

  @override
  String get pdfSbRules => 'Zasady na pokładzie';

  @override
  String get pdfSbEmergencyContacts => 'Kontakty alarmowe i VHF 16';

  @override
  String get pdfBriefingDeclaration =>
      'Wszyscy członkowie załogi zostali zapoznani i zrozumieli zasady bezpieczeństwa. Potwierdzają to podpisem.';

  @override
  String get pdfHashCoverage =>
      'Odcisk obejmuje nazwę rejsu, jednostkę, załogę i wszystkie wpisy (czas UTC, GPS, prędkość, kurs). Każda zmiana danych zmienia odcisk.';

  @override
  String get pdfForCharterCompany => 'Za firmę czarterową';

  @override
  String get dutyRoster => 'Wachta załogi';

  @override
  String get dutyStartAction => 'Objąć wachtę';

  @override
  String get dutyEndAction => 'Zakończ';

  @override
  String get dutyStartTitle => 'Kto obejmuje wachtę?';

  @override
  String get dutyRunningChip => 'NA WACHCIE';

  @override
  String dutySince(String time) {
    return 'od $time';
  }

  @override
  String dutyElapsed(int h, int m) {
    return '$h h $m min';
  }

  @override
  String get dutyNobodyOnDuty => 'Obecnie nikt nie pełni wachty';

  @override
  String get dutyInspectionView => 'Pokaż do kontroli';

  @override
  String get dutyRosterHistory => 'Harmonogram wacht';

  @override
  String get dutyAddRetrospective => 'Dodaj wachtę';

  @override
  String get dutyEditTitle => 'Edytuj wachtę';

  @override
  String get dutyDeleteTitle => 'Usunąć wachtę?';

  @override
  String dutyDeleteConfirm(String name) {
    return 'Wpis wachty dla $name zostanie usunięty.';
  }

  @override
  String get dutyNoCrewDefined => 'Rejs nie ma zdefiniowanej załogi';

  @override
  String get dutyDefineCrew => 'Uzupełnij załogę';

  @override
  String get dutyErrorEndBeforeStart => 'Koniec musi być po początku.';

  @override
  String dutyErrorOverlap(String name) {
    return '$name już pełni wachtę w tym czasie.';
  }

  @override
  String get dutyErrorFutureStart => 'Początek nie może być w przyszłości.';

  @override
  String get dutyNoteLabel => 'Uwaga';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'Wachta trwa $hours h — nie zapomniałeś jej zakończyć?';
  }

  @override
  String get dutyFrom => 'Od';

  @override
  String get dutyTo => 'Do';

  @override
  String get dutyToOngoing => '— nadal pełni';

  @override
  String get dutySelectPerson => 'Wybierz członka załogi';

  @override
  String get dutyNoRecords => 'Na razie brak wacht';

  @override
  String get logDutySection => 'Wachta załogi';

  @override
  String get logDutyStillRunning => 'trwa';

  @override
  String get logEventAnchorDropped => 'Kotwica rzucona';

  @override
  String get logEventAnchorRaised => 'Kotwica podniesiona';

  @override
  String get logEventDriftOut => 'Dryf – przekroczono perymetr';

  @override
  String get logEventDriftIn => 'Dryf – jednostka z powrotem w perymetrze';

  @override
  String logEventDutyStart(String name) {
    return 'Objęcie wachty: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Koniec wachty: $name';
  }

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Kontakty alarmowe';

  @override
  String get backToToc => 'Powrót do spisu treści';

  @override
  String get briefingComplete => 'Briefing ukończony';

  @override
  String get updateByPosition => 'Aktualizuj według pozycji';

  @override
  String get detectedByGps => 'wykryto przez GPS';

  @override
  String get locationUnavailable =>
      '📍 Lokalizacja niedostępna – pokazano kontakty globalne';

  @override
  String get detectingLocation => 'Ustalam lokalizację...';

  @override
  String get tapToCall => 'Dotknij, aby zadzwonić';

  @override
  String cannotCall(String name) {
    return 'Nie można zadzwonić: $name';
  }

  @override
  String get vhfChannel16 => 'VHF kanał 16 – użyj radia na pokładzie';

  @override
  String get hmbHandbook => 'Podręcznik HMB';

  @override
  String get checkInLabel => 'Check-in (odbiór jachtu)';

  @override
  String get checkOutLabel => 'Check-out (zdanie jachtu)';

  @override
  String get charterCheckCard => 'Czarter';

  @override
  String get weatherTitle => 'Pogoda i morze';

  @override
  String get updateForecast => 'Aktualizuj prognozę';

  @override
  String get gpsNotAvailableTracking => 'GPS niedostępny – włącz śledzenie';

  @override
  String get downloadingForecast => 'Pobieram prognozę...';

  @override
  String get loadingForecast => 'Ładuję prognozę...';

  @override
  String get noConnection => 'Brak połączenia';

  @override
  String get pressRefreshWhenOnline => 'Naciśnij odśwież, gdy jesteś online';

  @override
  String get noWeatherData => 'Brak danych pogodowych';

  @override
  String get forecastAutoDownload =>
      'Prognoza pobierze się automatycznie po uruchomieniu śledzenia lub naciśnij Odśwież.';

  @override
  String get enableGpsFirst => 'Najpierw włącz GPS / śledzenie';

  @override
  String get downloadForecast => 'Pobierz prognozę';

  @override
  String downloadError(String error) {
    return 'Błąd pobierania: $error';
  }

  @override
  String get liveInstrumentData => 'Dane na żywo z przyrządów pokładowych';

  @override
  String get windRelative => 'Wiatr (wzgl.)';

  @override
  String get windTrue => 'Wiatr (rzecz.)';

  @override
  String get depthLabel => 'Głębokość';

  @override
  String get waterTempLabel => 'Temperatura wody';

  @override
  String get courseTrue => 'Kurs (rzecz.)';

  @override
  String get courseMag => 'Kurs (mag.)';

  @override
  String get engineLabel => 'Silnik';

  @override
  String get wavesLabel => 'Fale';

  @override
  String get pressureLabel => 'Ciśnienie';

  @override
  String get airTempLabel => 'Powietrze';

  @override
  String get waterLabel => 'Woda';

  @override
  String get wind24h => 'Wiatr – 3 dni';

  @override
  String get waves24h => 'Fale – 3 dni';

  @override
  String get hourlyForecast => 'Prognoza na 3 dni';

  @override
  String get dailyForecast => 'Temperatura dzienna';

  @override
  String get timeCol => 'Czas';

  @override
  String get windCol => 'Wiatr';

  @override
  String get wavesCol => 'Fale';

  @override
  String get rainCol => 'Deszcz';

  @override
  String get beaufort0 => 'Cisza';

  @override
  String get beaufort1 => 'Powiew';

  @override
  String get beaufort2 => 'Słaby wiatr';

  @override
  String get beaufort3 => 'Łagodny wiatr';

  @override
  String get beaufort4 => 'Umiarkowany wiatr';

  @override
  String get beaufort5 => 'Dość silny wiatr';

  @override
  String get beaufort6 => 'Silny wiatr';

  @override
  String get beaufort7 => 'Bardzo silny wiatr';

  @override
  String get beaufort8 => 'Sztormowy wiatr';

  @override
  String get beaufort9 => 'Sztorm';

  @override
  String get beaufort10 => 'Silny sztorm';

  @override
  String get beaufort11 => 'Gwałtowny sztorm';

  @override
  String get beaufort12 => 'Huragan';

  @override
  String get sunAndMoonCard => 'Słońce i księżyc';

  @override
  String get sunriseLabel => 'Wschód słońca';

  @override
  String get sunsetLabel => 'Zachód słońca';

  @override
  String get moonPhaseLabel => 'Faza księżyca';

  @override
  String get moonIlluminationLabel => 'Oświetlenie';

  @override
  String get moonPhaseNew => 'Nów';

  @override
  String get moonPhaseWaxingCrescent => 'Przybywający sierp';

  @override
  String get moonPhaseFirstQuarter => 'Pierwsza kwadra';

  @override
  String get moonPhaseWaxingGibbous => 'Przybywający księżyc';

  @override
  String get moonPhaseFull => 'Pełnia';

  @override
  String get moonPhaseWaningGibbous => 'Ubywający księżyc';

  @override
  String get moonPhaseLastQuarter => 'Ostatnia kwadra';

  @override
  String get moonPhaseWaningCrescent => 'Ubywający sierp';

  @override
  String get noSunMoonGps =>
      'Do wschodu/zachodu słońca potrzebna jest pozycja GPS';

  @override
  String get oceanCurrentsTitle => 'Prądy oceaniczne';

  @override
  String get oceanCurrentsTooltip => 'Prądy oceaniczne';

  @override
  String get oceanCurrentsDisclaimer =>
      'Tylko dane orientacyjne (typowy kierunek/prędkość z map pilotowych) — nie do dokładnej nawigacji, prądy zmieniają się sezonowo.';

  @override
  String get tideCardTitle => 'Przypływ/odpływ';

  @override
  String get nextHighTideLabel => 'Najbliższy przypływ';

  @override
  String get nextLowTideLabel => 'Najbliższy odpływ';

  @override
  String get noTideData => 'Na razie brak danych o pływach';

  @override
  String get downloadTides => 'Pobierz prognozę pływów';

  @override
  String get downloadingTides => 'Pobieram prognozę pływów...';

  @override
  String get tideMslWarning =>
      'Wysokości są nad średnim poziomem morza, nie nad zerem mapy — nigdy nie używaj ich do głębokości pod kilem.';

  @override
  String get tideNoCoverage =>
      'Dla tej pozycji nie mamy danych o pływach — jest poza obszarem prognozy morskiej.';

  @override
  String get tideDownloadFailed =>
      'Nie udało się pobrać prognozy pływów. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get tideForecastExpired => 'Zapisana prognoza pływów wygasła.';

  @override
  String tideForecastFarAway(int km) {
    return 'Prognozę pobrano $km km stąd — pobierz ją ponownie dla tej pozycji.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Pobrano $when — pobierz ponownie po najnowszą prognozę.';
  }

  @override
  String get oceanCurrentCardTitle => 'Prąd morski';

  @override
  String get oceanCurrentSetsToward => 'Płynie w kierunku (prędkość w węzłach)';

  @override
  String get oceanCurrentNoCoverage =>
      'Dla tej pozycji nie mamy danych o prądzie.';

  @override
  String get oceanCurrentUnavailable =>
      'Prognoza prądu niedostępna — sprawdź połączenie.';

  @override
  String get tideOtherArea => 'Prognoza dla innego obszaru';

  @override
  String get tideAreaSearchLabel => 'Port, miasto lub zatoka';

  @override
  String get tideAreaSearchHint => 'np. Split';

  @override
  String get tideAreaNoResults => 'Nic nie znaleziono — spróbuj innej nazwy.';

  @override
  String tideForecastForArea(String place) {
    return 'Prognoza dla $place';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get measurementUnits => 'Jednostki miary';

  @override
  String get temperature => 'Temperatura';

  @override
  String get depthWaves => 'Głębokość / fale';

  @override
  String get wind => 'Wiatr';

  @override
  String get language => 'Język';

  @override
  String get appLanguage => 'Język aplikacji';

  @override
  String get languageDialogTitle => 'Język / Language';

  @override
  String get displaySettings => 'Wyświetlanie';

  @override
  String get nightMode => 'Tryb nocny';

  @override
  String get nightModeDesc => 'Czerwony filtr dla zachowania widzenia nocnego';

  @override
  String get aboutApp => 'O aplikacji';

  @override
  String get backupSection => 'Kopia zapasowa danych';

  @override
  String get exportBackup => 'Eksportuj kopię';

  @override
  String get exportBackupDesc =>
      'Zapisuje cały dziennik (rejsy, wpisy, ustawienia) do jednego pliku';

  @override
  String get restoreBackup => 'Przywróć z kopii';

  @override
  String get restoreBackupDesc =>
      'Zastępuje aktualne dane zawartością wybranego pliku kopii';

  @override
  String get restoreBlockedTrackingTitle => 'Działa śledzenie GPS';

  @override
  String get restoreBlockedTrackingBody =>
      'Przed przywróceniem kopii najpierw zatrzymaj aktywne śledzenie rejsu.';

  @override
  String get restoreSchemaTooNewTitle => 'Kopia z nowszej wersji';

  @override
  String get restoreSchemaTooNewBody =>
      'Ta kopia została utworzona nowszą wersją aplikacji niż aktualnie zainstalowana. Najpierw zaktualizuj aplikację.';

  @override
  String get restoreConfirmTitle => 'Przywrócić z kopii?';

  @override
  String get restoreConfirmBody =>
      'Aktualne dane zostaną zastąpione zawartością kopii. Przed przywróceniem automatycznie powstanie kopia bezpieczeństwa bieżącego stanu.';

  @override
  String get restoreSuccess => 'Dane pomyślnie przywrócono z kopii.';

  @override
  String get restoreInvalidFile =>
      'Wybrany plik nie jest prawidłową kopią HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Książka mil';

  @override
  String get totalNm => 'Łączne NM';

  @override
  String get daysAtSea => 'Dni na morzu';

  @override
  String get voyageCount => 'Liczba rejsów';

  @override
  String get nightHoursLabel => 'Godziny nocne';

  @override
  String get byYear => 'Według roku';

  @override
  String get byVessel => 'Według jednostki';

  @override
  String get addHistoricalVoyage => 'Dodaj rejs historyczny';

  @override
  String get editHistoricalVoyage => 'Edytuj rejs historyczny';

  @override
  String get deleteHistoricalVoyageConfirm =>
      'Na pewno usunąć ten rejs historyczny?';

  @override
  String get manualEntryExplanation => '* wpis ręczny (wprowadzony ręcznie)';

  @override
  String get roleLabel => 'Rola na pokładzie';

  @override
  String get roleSkipper => 'Skipper';

  @override
  String get roleCoSkipper => 'Sternik';

  @override
  String get roleCrew => 'Załoga';

  @override
  String get areaLabel => 'Akwen / trasa';

  @override
  String get distanceNmLabel => 'Odległość (NM)';

  @override
  String get daysCountLabel => 'Liczba dni';

  @override
  String get milesCertificateTitle => 'Potwierdzenie przepłyniętych mil';

  @override
  String get logbookRecordTitle => 'Wpis Książki mil';

  @override
  String get logbookTrackedHint =>
      'Daty, mile, akwen i rola liczone są ze śledzenia/importu.';

  @override
  String get vesselFlag => 'Bandera rejestracji';

  @override
  String get captainFirstName => 'Imię skippera';

  @override
  String get captainLastName => 'Nazwisko skippera';

  @override
  String get captainQualification => 'Najwyższe uzyskane kwalifikacje';

  @override
  String get logbookSignatureSection => 'Podpis potwierdzający mile';

  @override
  String get addSignature => 'Dodaj podpis';

  @override
  String get filterAllYears => 'Wszystkie lata';

  @override
  String get filterCustomRange => 'Własny zakres';

  @override
  String get handoverMenuTitle => 'Protokół przekazania';

  @override
  String get checkInProtocol => 'Protokół check-in';

  @override
  String get checkOutProtocol => 'Protokół check-out';

  @override
  String get nextStepLabel => 'Następny krok';

  @override
  String get readyToTrackHint => 'Gotowe do śledzenia';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Krok $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Safety\nBriefing';

  @override
  String get handoverChecklistShort => 'Lista\nprzekazania';

  @override
  String get safetyBriefingRefTitle => 'Odprawa bezpieczeństwa';

  @override
  String get handoverChecklistRefTitle => 'Lista przekazania';

  @override
  String get handoverDateTime => 'Data i czas';

  @override
  String get handoverLocation => 'Miejsce (marina)';

  @override
  String get checklistItemOk => 'OK';

  @override
  String get checklistItemDamaged => 'Uszkodzone';

  @override
  String get checklistItemMissing => 'Brak';

  @override
  String get damagePosition => 'Pozycja na jachcie';

  @override
  String get newDamageBadge => 'NOWE USZKODZENIE';

  @override
  String get companySignatureSection =>
      'Podpis przedstawiciela firmy czarterowej';

  @override
  String get companyRepName => 'Imię i nazwisko przedstawiciela';

  @override
  String get companyNameLabel => 'Nazwa firmy';

  @override
  String get protocolClosedNotice =>
      'Protokół jest zamknięty (podpisały obie strony) – tylko do odczytu.';

  @override
  String get handoverCertTitle => 'Protokół przekazania jachtu';

  @override
  String get itemSails => 'Żagle';

  @override
  String get itemRigging => 'Olinowanie';

  @override
  String get itemAnchorChain => 'Kotwica i łańcuch';

  @override
  String get itemNavInstruments => 'Przyrządy nawigacyjne';

  @override
  String get itemLifeJackets => 'Kamizelki ratunkowe';

  @override
  String get itemRaft => 'Tratwa ratunkowa';

  @override
  String get itemFirstAidKit => 'Apteczka';

  @override
  String get itemDinghyMotor => 'Dinghy i silnik zaburtowy';

  @override
  String get itemLights => 'Światła';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Dodatkowe uwagi';

  @override
  String get gpxImportTitle => 'Import GPX';

  @override
  String get gpxImportPickFile => 'Wybierz plik GPX';

  @override
  String get gpxTracksFound => 'Znalezione trasy';

  @override
  String get gpxWaypointsFound => 'Znalezione waypointy';

  @override
  String get gpxAssignTarget => 'Przypisz do rejsu';

  @override
  String get gpxNewVoyage => 'Nowy rejs';

  @override
  String get gpxImportButton => 'Importuj';

  @override
  String get gpxImportSuccess => 'GPX zaimportowany pomyślnie.';

  @override
  String get connectionConnected => 'Połączono';

  @override
  String get connectionConnecting => 'Łączę...';

  @override
  String get connectionError => 'Błąd połączenia';

  @override
  String get connectionDisconnected =>
      'Niepołączono (używany GPS telefonu / prognoza)';

  @override
  String get ipAddressLabel => 'Adres IP gateway';

  @override
  String get portLabel => 'Port';

  @override
  String get autoConnectLabel => 'Automatycznie łącz przy uruchomieniu';

  @override
  String get disconnect => 'Rozłącz';

  @override
  String get connect => 'Połącz';

  @override
  String get gatewayHint =>
      'Połącz telefon z siecią WiFi Raymarine (np. WiFi-1, RayNet). Adres IP do wpisania NIE jest tym z ustawień Raymarine — to brama (gateway) tej sieci WiFi. Znajdziesz ją w telefonie: Ustawienia → WiFi → szczegóły sieci → Brama. Port 2000 (TCP) to standard. Bez połączenia aplikacja automatycznie używa GPS telefonu.';

  @override
  String connectedToHost(String host, int port) {
    return 'Połączono z $host:$port';
  }

  @override
  String get enterIpAddress => 'Podaj adres IP gateway';

  @override
  String connectionFailed(String error) {
    return 'Nie udało się połączyć: $error';
  }

  @override
  String get liveWind => 'Wiatr';

  @override
  String get liveDepth => 'Głębokość';

  @override
  String get liveWaterTemp => 'Temperatura wody';

  @override
  String get liveCompass => 'Kompas';

  @override
  String get liveEngine => 'Silnik';

  @override
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Port nasłuchu';

  @override
  String get startListening => 'Uruchom';

  @override
  String get stopListening => 'Zatrzymaj';

  @override
  String connectionListening(String port) {
    return 'Nasłuchuje UDP na porcie $port';
  }

  @override
  String udpHint(String port) {
    return 'Ustaw symulator/gateway, aby wysyłał UDP na IP tego telefonu, port $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Nasłuchuję UDP na porcie $port';
  }

  @override
  String get dayNotFound => 'Nie znaleziono dnia';

  @override
  String get saved => 'Zapisano';

  @override
  String get trackingThisDay => 'Śledzenie działa dla tego dnia';

  @override
  String get trackingOtherDay => 'Śledzenie działa dla innego dnia';

  @override
  String recordCount(int n) {
    return '$n wpisów';
  }

  @override
  String get addManual => 'Dodaj ręcznie';

  @override
  String get noEntries => 'Brak wpisów';

  @override
  String get entriesAutoAdded =>
      'Wpisy dodają się automatycznie podczas śledzenia';

  @override
  String get deleteEntryTitle => 'Usunąć wpis?';

  @override
  String get autoRecord => 'Zapis automatyczny';

  @override
  String get routeSection => 'Trasa';

  @override
  String get fromPort => 'Skąd';

  @override
  String get toPort => 'Dokąd';

  @override
  String get distance => 'Odległość';

  @override
  String get vessel => 'Jednostka / łódź';

  @override
  String get weatherSection => 'Pogoda';

  @override
  String get morning => 'Rano';

  @override
  String get noon => 'Południe';

  @override
  String get evening => 'Wieczór';

  @override
  String get windDir => 'Kierunek wiatru';

  @override
  String get seaState => 'Stan morza';

  @override
  String get waveHeight => 'Wysokość fal';

  @override
  String get dailyNote => 'Notatka dnia';

  @override
  String get dailyNoteHint => 'Opis rejsu, ciekawostki, wydarzenia dnia...';

  @override
  String get seaCalm => 'Spokojne';

  @override
  String get seaLight => 'Lekkie';

  @override
  String get seaModerate => 'Umiarkowane';

  @override
  String get seaRough => 'Wzburzone';

  @override
  String get seaStormy => 'Sztormowe';

  @override
  String get editEntry => 'Edytuj wpis';

  @override
  String get newEntry => 'Nowy wpis';

  @override
  String get sailMode => 'Sposób żeglugi';

  @override
  String get sailMain => 'Grot';

  @override
  String get navigationSection => 'Nawigacja';

  @override
  String get latitude => 'Szerokość';

  @override
  String get longitude => 'Długość';

  @override
  String get weatherSeaSection => 'Pogoda i morze';

  @override
  String get windSpeed => 'Wiatr';

  @override
  String get windDirection => 'Kierunek';

  @override
  String get waveHeight2 => 'Wysokość fal';

  @override
  String get engineSection => 'Silnik i zbiorniki';

  @override
  String get engineHours => 'Motogodziny';

  @override
  String get fuel => 'Paliwo';

  @override
  String get fuelLevel => 'Poziom paliwa';

  @override
  String get waterLevel => 'Poziom wody';

  @override
  String get noteSection => 'Uwaga';

  @override
  String get noteHint => 'Warunki żeglugi, wydarzenia, zmiana załogi...';

  @override
  String get quickPhotoLogTitle => 'Szybki wpis';

  @override
  String get quickPhotoNoteHint => 'Co to jest? (opcjonalnie)';

  @override
  String get exportDayTitle => 'Eksport dnia';

  @override
  String get exportCharterTitle => 'Eksport czarteru';

  @override
  String get loadingData => 'Ładuję dane...';

  @override
  String get mapsReady => 'Mapy gotowe – możesz eksportować';

  @override
  String generatingMaps(int current, int total) {
    return 'Generuję podglądy map ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Eksportuj dzień';

  @override
  String get exportCharterBtn => 'Eksportuj czarter';

  @override
  String get entriesLabel => 'Wpisy';

  @override
  String get routePoints => 'Punkty trasy';

  @override
  String get anchorDriftTitle => '⚓ KOTWICA DRYFUJE!';

  @override
  String get anchorDriftContent =>
      'Jednostka przekroczyła perymetr kotwicy.\nNatychmiast sprawdź pozycję!';

  @override
  String get cancelAnchor => 'Anuluj kotwicę';

  @override
  String get stopAlarm => 'Zatrzymaj alarm';

  @override
  String get briefingItem1 => 'Kamizelki ratunkowe – umiejscowienie i użycie';

  @override
  String get briefingItem2 => 'Koło ratunkowe i procedura MOB';

  @override
  String get briefingItem3 => 'Flary – typy i użycie';

  @override
  String get briefingItem4 => 'EPIRB / PLB – aktywacja';

  @override
  String get briefingItem5 => 'Radio VHF – kanał 16, procedura Mayday';

  @override
  String get briefingItem6 => 'Gaśnica – umiejscowienie i użycie';

  @override
  String get briefingItem7 => 'Apteczka – umiejscowienie';

  @override
  String get briefingItem8 => 'Awaryjne wyłączenie silnika';

  @override
  String get briefingItem9 => 'Wycieki – woda, gaz';

  @override
  String get briefingItem10 => 'Kotwica i łańcuch – procedura kotwiczenia';

  @override
  String get briefingItem11 => 'Zasady na pokładzie';

  @override
  String get briefingItem12 => 'Kontakty alarmowe i VHF 16';

  @override
  String get checkInItem1 => 'Dokumenty jachtu (rejestracja, ubezpieczenie)';

  @override
  String get checkInItem2 => 'Wyposażenie ratunkowe – komplet';

  @override
  String get checkInItem3 => 'Zapasy paliwa';

  @override
  String get checkInItem4 => 'Zapasy wody';

  @override
  String get checkInItem5 => 'Kotwica i łańcuch – kontrola';

  @override
  String get checkInItem6 => 'Silnik – rozruch próbny';

  @override
  String get checkInItem7 => 'Przyrządy nawigacyjne';

  @override
  String get checkInItem8 => 'Omasztowanie – liny i żagle';

  @override
  String get checkInItem9 => 'Kambuz – gaz, kuchenka';

  @override
  String get checkInItem10 => 'WC – sprawność';

  @override
  String get checkInItem11 => 'Istniejące uszkodzenia – dokumentacja foto';

  @override
  String get checkOutItem1 => 'Jacht wyczyszczony – na zewnątrz';

  @override
  String get checkOutItem2 => 'Jacht wyczyszczony – wewnątrz';

  @override
  String get checkOutItem3 => 'Paliwo uzupełnione';

  @override
  String get checkOutItem4 => 'Woda uzupełniona';

  @override
  String get checkOutItem5 => 'Śmieci usunięte';

  @override
  String get checkOutItem6 => 'Uszkodzenia zgłoszone';

  @override
  String get checkOutItem7 => 'Klucze przekazane';

  @override
  String get gearListShort => 'Wyposażenie\nindywidualne';

  @override
  String get colregRules => 'COLREG\nPrzepisy';

  @override
  String get checkInShort => 'Check-in\nOdbiór';

  @override
  String get checkOutShort => 'Check-out\nZdanie';

  @override
  String get appTagline => 'Twój niezawodny dziennik pokładowy';

  @override
  String exportSavedMsg(String path) {
    return 'Zapisano: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Zapisano: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Błąd eksportu: $error';
  }

  @override
  String get generatingPdf => 'Generuję PDF...';

  @override
  String get colregTitle => 'COLREG – Przepisy o zapobieganiu zderzeniom';

  @override
  String get tableOfContents => 'SPIS TREŚCI';

  @override
  String get inThisChapter => 'W tym rozdziale:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Praw. $n';
  }

  @override
  String get resetChecklistTitle => 'Zresetować listę?';

  @override
  String get resetChecklistContent => 'Wszystkie zaznaczenia zostaną usunięte.';

  @override
  String get reset => 'Resetuj';

  @override
  String get checkInReceivingTitle => 'Check-in – Odbiór jachtu';

  @override
  String get checkOutHandoverTitle => 'Check-out – Zdanie jachtu';

  @override
  String get checkInCompletedMsg => 'Jacht odebrany – wszystko sprawdzone ✓';

  @override
  String get checkOutCompletedMsg => 'Jacht zdany – wszystko w porządku ✓';

  @override
  String get briefingDoneMsg => 'Briefing ukończony – załoga poinformowana';

  @override
  String get sectionBriefed => 'Sekcja omówiona ✓';

  @override
  String get confirmSection => 'Potwierdź sekcję';

  @override
  String get gearListTitle => 'Wyposażenie indywidualne';

  @override
  String get newCategory => 'Nowa kategoria';

  @override
  String get add => 'Dodaj';

  @override
  String get deleteItemTitle => 'Usunąć pozycję?';

  @override
  String get allPackedMsg => 'Wszystko spakowane, gotów do rejsu! 🎉';

  @override
  String get addItemLabel => 'Dodaj pozycję';

  @override
  String addToCategoryTitle(String category) {
    return 'Dodaj do: $category';
  }

  @override
  String get newItemHint => 'Nowa pozycja...';

  @override
  String get addWaypoint => 'Dodaj waypoint';

  @override
  String get editWaypoint => 'Edytuj waypoint';

  @override
  String get waypointNameLabel => 'Nazwa';

  @override
  String get skipperSignature => 'Podpis skippera';

  @override
  String get skipperNameLabel => 'Imię skippera';

  @override
  String get signWithFinger => 'Podpisz się palcem';

  @override
  String get clear => 'Wyczyść';

  @override
  String get signAndExport => 'Podpisz i eksportuj';

  @override
  String get pleaseSign => 'Proszę podpisać przed eksportem';

  @override
  String get generatingPdfPreview => 'Generuję podgląd PDF...';

  @override
  String generationError(String error) {
    return 'Błąd generowania: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Zapisuję i generuję GPX...';

  @override
  String get editCharter => 'Edytuj czarter';

  @override
  String get basicInfo => 'Podstawowe informacje';

  @override
  String get voyageNameRequired => 'Nazwa rejsu *';

  @override
  String get dateFrom => 'Data od';

  @override
  String get dateTo => 'Data do';

  @override
  String get vesselName => 'Nazwa jednostki';

  @override
  String get vesselType => 'Typ jednostki';

  @override
  String get homePort => 'Port macierzysty';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Znak wywoławczy';

  @override
  String get vesselLengthM => 'Długość (m)';

  @override
  String get vesselBeamM => 'Szerokość (m)';

  @override
  String get vesselDraftM => 'Zanurzenie (m)';

  @override
  String get selectExistingVoyage => 'Wybierz istniejący rejs';

  @override
  String get newVoyageForm => 'Nowy rejs';

  @override
  String get fillFormAndBriefing => 'Wypełnij formularz i podpisz SB';

  @override
  String get notesLabel => 'Uwagi';

  @override
  String get statusLabel => 'Stan';

  @override
  String get safetyBriefingDoneLabel => 'Safety Briefing wykonany';

  @override
  String get checkInDoneLabel => 'Check-in ukończony';

  @override
  String get checkOutDoneLabel => 'Check-out ukończony';

  @override
  String get enterVoyageName => 'Podaj nazwę rejsu';

  @override
  String daysCount(int n) {
    return '$n dni';
  }

  @override
  String get selectTargetWaypoint => 'Wybierz docelowy waypoint';

  @override
  String get noWaypoints => 'Brak waypointów.';

  @override
  String get goToMap => 'Idź do mapy';

  @override
  String get noTarget => 'Brak celu';

  @override
  String get selectWaypointHint => 'Nawiguj do waypointu';

  @override
  String get sessionStats => 'Statystyki rejsu';

  @override
  String get maxSpeed => 'Maks. prędkość';

  @override
  String get avgSpeed => 'Śr. prędkość';

  @override
  String get sailingTime => 'Czas rejsu';

  @override
  String get gpsData => 'Dane GPS';

  @override
  String get gpsPosition => 'Pozycja';

  @override
  String get courseCog => 'Kurs (COG)';

  @override
  String get altitudeLabel => 'Wysokość';

  @override
  String get dscProcedure => 'PROCEDURA DSC';

  @override
  String get voiceScript => 'SKRYPT GŁOSOWY';

  @override
  String get dscWarningUseOnly => '⚠️ UŻYWAĆ TYLKO W PRZYPADKU';

  @override
  String get dscWarningDanger => 'POWAŻNEGO I BEZPOŚREDNIEGO NIEBEZPIECZEŃSTWA';

  @override
  String get dscWarningTypes => 'Pożar · Zatonięcie · Człowiek za burtą';

  @override
  String get dscProcedureSubtitle => 'Zachowaj tę procedurę przy radiu VHF DSC';

  @override
  String get fillBeforeSailing => 'Wypełnij przed rejsem:';

  @override
  String get copyTooltip => 'Kopiuj';

  @override
  String get scriptCopied => 'Skrypt skopiowany';

  @override
  String get sendOnCh16 =>
      '📻 Nadawaj na Kanale 16 · Wysoka moc · Powtarzaj co 2 minuty, jeśli brak odpowiedzi';

  @override
  String get enterAbove => '[wpisz w polu powyżej]';

  @override
  String get distressNature => 'Rodzaj zagrożenia';

  @override
  String get vesselNameLabel => 'Nazwa jednostki';

  @override
  String get numberOfPersons => 'Liczba osób';

  @override
  String get additionalInfo => 'Dodatkowe info';

  @override
  String get voiceScriptTitle => 'GŁOSOWY SKRYPT MAYDAY';

  @override
  String get dscStep1 => 'Upewnij się, że radio jest włączone.';

  @override
  String get dscStep2 => 'Otwórz osłonę nad CZERWONYM przyciskiem zagrożenia.';

  @override
  String get dscStep3 => 'Naciśnij CZERWONY przycisk RAZ i zwolnij.';

  @override
  String get dscStep4 =>
      'Wybierz rodzaj zagrożenia.\n(Pożar, Zatonięcie, MOB itp.)\nJeśli pominiesz, wyśle się Nieoznaczone zagrożenie.';

  @override
  String get dscStep5 =>
      'Naciśnij i PRZYTRZYMAJ CZERWONY przycisk przez 5 sekund, aby wysłać wezwanie.';

  @override
  String get dscStep6 =>
      'Czekaj maks. 15 sekund na potwierdzenie (pojawi się na ekranie), potem nadaj komunikat głosowy na Kanale 16 na WYSOKIEJ mocy.';

  @override
  String get appDescription => 'Profesjonalny dziennik pokładowy dla żeglarzy.';

  @override
  String get vesselIdTitle => 'Identyfikacja jednostki';

  @override
  String get vesselIdHint =>
      'Call sign i MMSI wypełnią się automatycznie w Mayday Card.';

  @override
  String get maritimeReference => 'Alfabet morski';

  @override
  String get phonetic => 'Fonetyczny';

  @override
  String get flagAlphabet => 'Sygnały flagowe';

  @override
  String get dayShapes => 'Znaki dzienne';

  @override
  String get marineReferenceTile => 'Sygnały i alfabet';

  @override
  String get navInstruments => 'Przyrządy pokładowe';

  @override
  String get enterPort => 'Podaj port...';

  @override
  String get closeWithoutSaving => 'Zamknij bez zapisu';

  @override
  String get saveToDevice => 'Zapisz w urządzeniu';

  @override
  String get saveAndShare => 'Zapisz i udostępnij';

  @override
  String get timestampCannotBeChanged => 'Czasu wpisu nie można zmienić';

  @override
  String entriesShort(int n) {
    return '$n wp.';
  }

  @override
  String get mainsail => 'Grot';

  @override
  String get weatherConditionTitle => 'Stan pogody';

  @override
  String get weatherConditionLabel => 'Warunki';

  @override
  String get wcSunny => 'Słonecznie';

  @override
  String get wcPartlyCloudy => 'Częściowe zachmurzenie';

  @override
  String get wcOvercast => 'Pochmurno';

  @override
  String get wcLightRain => 'Słaby deszcz';

  @override
  String get wcRain => 'Deszcz';

  @override
  String get wcHeavyRain => 'Silny deszcz';

  @override
  String get wcDrizzle => 'Mżawka';

  @override
  String get wcThunderstorm => 'Burza';

  @override
  String get wcIsoThunderstorm => 'Pojedyncze burze';

  @override
  String get wcHail => 'Grad';

  @override
  String get wcDust => 'Pył';

  @override
  String get wcFoggy => 'Mgła';

  @override
  String get wcWindy => 'Wietrznie';

  @override
  String get wcCold => 'Mróz';

  @override
  String get photoSection => 'Zdjęcie';

  @override
  String get camera => 'Aparat';

  @override
  String get gallery => 'Galeria';

  @override
  String get addPhoto => 'Dodaj zdjęcie';

  @override
  String get photoAddedToEntry => 'Zdjęcie dołączone';

  @override
  String get voyageStart => 'Początek rejsu';

  @override
  String get voyageEnd => 'Koniec rejsu';

  @override
  String get onlineAccount => 'Konto online';

  @override
  String get onlineAccountDesc =>
      'Synchronizacja dziennika online — w przygotowaniu';

  @override
  String get register => 'Zarejestruj';

  @override
  String get login => 'Zaloguj';

  @override
  String get logout => 'Wyloguj';

  @override
  String get logoutConfirm =>
      'Zostaniesz wylogowany. Dane zapisane w urządzeniu pozostaną.';

  @override
  String get notLoggedIn => 'Niezalogowany';

  @override
  String get fullName => 'Imię i nazwisko';

  @override
  String get password => 'Hasło';

  @override
  String get userGuide => 'Przewodnik użytkownika';

  @override
  String get guideQuickStart => 'Szybki start – 5 kroków';

  @override
  String get guideQuickStartBody =>
      '1. Dotknij dużego przycisku \"Rozpocznij rejs\" u góry (na Mapie, w Dzienniku lub przy Przyrządach) – wybierz częstotliwość zapisów i śledzenie działa, nic więcej nie trzeba wypełniać z góry\n2. Jeśli masz rozpoczęty rejs, aplikacja zapyta: kontynuować go, czy nowy wpis\n3. Brakujące dane (check-in, safety briefing, karta jachtu/załogi) uzupełnij kiedykolwiek – aplikacja przypomni o nich kolorowymi chipami w Dzienniku\n4. W ciągu dnia dodawaj wpisy: czas, pozycja, uwaga\n5. Na koniec rejsu otwórz Ustawienia → Eksport PDF\n\nAplikacja działa na pełnym ekranie – paski systemowe telefonu wyświetlisz przeciągnięciem palca od górnej lub dolnej krawędzi.';

  @override
  String get guideMapTitle => 'Mapa';

  @override
  String get guideMapBody =>
      'Zakładka Mapa pokazuje twoją aktualną pozycję i trasę rejsu.\n\n• Niebieska kropka = aktualna pozycja\n• Niebieska linia = aktualnie śledzona trasa\n• Ikona trasy – wybierz dowolny rejs lub dzień i zobacz jego trasę na mapie (na pomarańczowo), nawet bez eksportu PDF\n• Możesz przełączać między warstwą satelitarną a mapową\n• Seamarki – przełącznik dla znaków morskich (wraki, mielizny, boje)\n• Porty – klikalna warstwa kotwicowisk, marin i portów (dane z OpenStreetMap): dotknij ikonki i zobaczysz nazwę, kanał VHF, telefon, stronę www, głębokość czy pojemność, jeśli są znane; miejsce od razu zapiszesz jako waypoint; warstwa obejmuje też stacje paliw dla łodzi (pomarańczowa pompa)\n• Radar – radar opadów nad mapą (RainViewer), obraz odświeża się ~co 10 minut\n• Wiatr – strzałki kierunku i siły wiatru (węzły) w siatce dla widocznego obszaru\n• Linijka (fioletowa ikona) – dotykaj punkty na mapie: suma NM, kurs ostatniego odcinka i ETA przy aktualnej prędkości; punkty przyciągają się do waypointów, więc zmierzysz trasę przez cele\n• Mapa offline (ikona pobierania) – pobiera widoczny obszar (mapa + seamarki, aktualny zoom +3 poziomy) do użytku bez zasięgu; dodatkowo każdy przeglądany kafelek zapisuje się automatycznie\n• W trybie nocnym mapa automatycznie przełącza się na ciemne kafelki\n• Ikona kotwicy = miejsce kotwiczenia (tylko gdy kotwica aktywna)\n• Ikona importu – wczytuje trasy i waypointy z pliku .gpx (zobacz sekcję \"Import GPX\")\n• Blokada północy – przytrzymaj różę kompasu w lewym górnym rogu; mapa przestanie się obracać i pozostanie na północ. Dotknięciem wrócisz na północ w każdej chwili.\n• Wybrane warstwy (satelita, seamarki, porty, radar, wiatr…), śledzenie GPS i blokada północy zapamiętują się między uruchomieniami\n• Przytrzymaj palec na mapie = dodaj waypoint (cel nawigacji); dotknięciem istniejącego waypointu zmienisz jego nazwę lub go usuniesz';

  @override
  String get guideInstrTitle => 'Przyrządy morskie';

  @override
  String get guideInstrBody =>
      'Zakładka Przyrządy pokazuje dane nawigacyjne w czasie rzeczywistym.\n\n• SOG – prędkość nad dnem (węzły)\n• TWS – rzeczywista prędkość wiatru\n• TWA – kąt wiatru względem jednostki (zielony = prawa burta, czerwony = lewa burta)\n• DEPTH – głębokość wody (czerwone = mniej niż 5 m)\n• VMG WP – prędkość do wybranego waypointu; po wyborze z kafelka zobaczysz odległość/kierunek oraz strzałkę wprost na róży kursowej\n\nŹródło danych: GPS telefonu lub Raymarine (TCP i UDP WiFi gateway).\nUstawienia połączenia (w tym wybór TCP/UDP) znajdziesz w Ustawienia → Przyrządy.\n\nJak łączy się jednostka: aplikacja czyta dane NMEA przez WiFi (TCP lub UDP). Sam hotspot WiFi Raymarine MFD zwykle nie wystarcza — służy aplikacjom Raymarine i surowego NMEA zwykle nie udostępnia stronom trzecim. Potrzebujesz gateway NMEA→WiFi (np. Digital Yacht, Yacht Devices, Actisense, Quark-elec) podłączonego do magistrali jachtu, który albo tworzy własny hotspot, albo rozgłasza NMEA do WiFi. Połącz telefon z WiFi tego gateway i w Ustawieniach podaj jego IP i port (lub spróbuj Autowykrywania).';

  @override
  String get guideLogbookTitle => 'Dziennik pokładowy';

  @override
  String get guideLogbookBody =>
      'Dziennik to główna zakładka do zarządzania rejsami.\n\n• Duży przycisk \"Rozpocznij rejs\" u góry uruchamia śledzenie – pyta tylko o częstotliwość automatycznych zapisów (można zmienić przy każdym kolejnym uruchomieniu), żadnego formularza nie trzeba wypełniać z góry\n• Jeśli istnieje rozpoczęty rejs, aplikacja zapyta, czy kontynuować go, czy założyć nowy wpis\n• Brakujące dane (check-in, safety briefing, karta jachtu/załogi) aplikacja przypomni kolorowymi chipami wprost na karcie rejsu – dotknięciem chipa je uzupełnisz\n• Każdy dzień rejsu wyświetla się osobno\n• Wpisy można dodawać ręcznie w ciągu dnia, w tym motogodziny, paliwo i wodę w sekcji \"Silnik i zbiorniki\"\n• Podczas śledzenia pojawia się przycisk aparatu (lewy dolny róg) – zrób zdjęcie ciekawego miejsca i szybko zapisz je jako wpis z pozycją i czasem\n• Dziennik można wyeksportować do PDF przez menu dnia\n• Ikona uścisku dłoni w szczegółach rejsu otwiera protokół przekazania (check-in/check-out)\n• Szczegółowy formularz rejsu (ikona jachtu w szczegółach) ewidencjonuje jednostkę i jej parametry, akwen, załogę z uprawnieniami skippera oraz zdjęcia jachtu (maks. 3, przenoszą się do PDF)\n• Niewypełnione karty (Safety Briefing, check-in/out, karta jachtu) migają na czerwono w górnym pasku szczegółów rejsu, dopóki ich nie ukończysz\n• Jeśli aplikacja zamknie się w trakcie rejsu bez zatrzymania śledzenia (zamknie ją system, przypadkowy swipe), przy kolejnym uruchomieniu zaproponuje kontynuację tego samego rejsu – wraz z doliczeniem odległości pokonanej, gdy nie działała\n• Przy pierwszym starcie rejsu aplikacja przypomni o ustawieniach baterii – bez nich system (zwłaszcza Honor/Huawei) może wyłączyć śledzenie w tle\n• Ikona trasy w nagłówku rejsu (obok briefingu, protokołu i karty jachtu) pokazuje cały ślad rejsu na mapie';

  @override
  String get guideMilesTitle => 'Książka mil';

  @override
  String get guideMilesBody =>
      'Podsumowanie wszystkich rejsów w jednym miejscu (ikona w Dzienniku pokładowym).\n\n• Łączne mile morskie, dni na morzu, liczba rejsów i godziny nocne\n• Podział według roku i według jednostki\n• Filtr według roku\n• Dotknij rejs (także śledzony/importowany) i uzupełnij wpis Książki mil – trasę, banderę jednostki, imię i kwalifikacje skippera, podpis potwierdzający mile\n• Przycisk + – dodaj rejs historyczny sprzed używania aplikacji (liczy się w pełni do podsumowań, na liście oznaczony gwiazdką)\n• Eksport PDF potwierdzenia przepłyniętych mil z miejscem na podpis';

  @override
  String get guideHandoverTitle => 'Protokół przekazania (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Formalny zapis odbioru i zwrotu jachtu w czarterze – ikona uścisku dłoni w szczegółach rejsu.\n\n• Lista kontrolna wyposażenia (żagle, olinowanie, kotwica, nawigacja, kamizelki, tratwa, apteczka, dinghy, światła, bimini...) – OK / uszkodzone / brak, z uwagą, pozycją na jachcie i zdjęciem\n• Stan paliwa, wody i motogodzin\n• Podpis skippera oraz przedstawiciela firmy czarterowej\n• Protokół zamyka się (tylko do odczytu) dopiero gdy podpiszą obaj\n• Check-out wstępnie wypełnia dane z protokołu check-in i podkreśla nowe uszkodzenia\n• Eksport PDF z obydwoma podpisami obok siebie';

  @override
  String get guideGpxImportTitle => 'Import GPX';

  @override
  String get guideGpxImportBody =>
      'Importuj trasy i waypointy z innych aplikacji nawigacyjnych lub urządzeń GPS (ikona na Mapie).\n\n• Wybierz plik .gpx z urządzenia\n• Eksport wielodniowy (wiele tras w jednym pliku, np. z Garmin Explore) automatycznie łączy się w jeden rejs z dniem dla każdego dnia kalendarzowego\n• Znalezione trasy możesz też ręcznie przypisać do istniejącego rejsu\n• Waypointy (także z tras/routes) dodają się wprost na mapę\n• Przy uszkodzonym pliku aplikacja wyświetli zrozumiały komunikat błędu';

  @override
  String get guideWeatherTitle => 'Pogoda';

  @override
  String get guideWeatherBody =>
      'Zakładka Pogoda pokazuje prognozę według aktualnej pozycji.\n\n• Aktualizuje się automatycznie przy zmianie pozycji\n• Pokazuje wiatr, fale, temperaturę i warunki najbliższych godzin\n• Bez internetu wyświetli się ostatnia zapisana prognoza\n\nSłońce, księżyc i pływy:\n• Wschód, zachód słońca i faza księżyca liczone są wprost w urządzeniu — internet nie jest potrzebny\n• Dotknięciem odśwież w karcie Przypływ/odpływ pobierzesz 7-dniową prognozę (za darmo, bez klucza API)\n• Pływy są keszowane, więc pozostają czytelne także offline; karta ostrzeże, gdy prognoza jest stara lub pobrana daleko stąd\n• ⚠ Wysokości pływów są nad średnim poziomem morza, nie nad zerem mapy — nigdy nie używaj ich do obliczania głębokości pod kilem\n\nPrąd morski:\n• Karta Prąd morski pokazuje realną prognozę dla twojej pozycji w węzłach i kierunek, DOKĄD prąd płynie\n• Na mapie przycisk z podwójną strzałką rysuje siatkę prądu dla widocznego obszaru; strzałki pokazują, dokąd przemieszcza się woda\n• Nie myl z warstwą Prądy oceaniczne — to referencyjna mapa wielkich prądów globalnych';

  @override
  String get guideSafetyMobTitle => 'MOB i kotwica';

  @override
  String get guideSafetyMobBody =>
      'Zakładka Bezpieczeństwo zawiera funkcje awaryjne.\n\nMOB (Człowiek za burtą):\n• Przytrzymaj czerwony przycisk MOB, aby aktywować\n• Aplikacja zapisze pozycję GPS i mierzy czas oraz odległość\n• Nawigacja z powrotem do miejsca upadku\n\nKotwica:\n• Ustaw promień kotwiczenia (zalecane: 2× długość liny kotwicznej)\n• Alarm zawibruje, jeśli jednostka oddali się z dozwolonego okręgu';

  @override
  String get guideSafetyBriefingTitle => 'Odprawa bezpieczeństwa i MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'W Bezpieczeństwie znajdziesz też zakładki z kartami referencyjnymi.\n\n• Odprawa bezpieczeństwa – lista kontrolna dla załogi przed rejsem\n• Każdy członek załogi podpisuje się własnym podpisem na ekranie\n• Podpisy zapisują się i automatycznie trafiają do eksportu PDF czarteru\n• Lista przekazania – przegląd pozycji do odbioru/zwrotu jachtu, dostępny także bez otwartego rejsu\n• Karta MAYDAY – procedura wezwania pomocy na kanale VHF 16\n• COLREG – przepisy o zapobieganiu zderzeniom na morzu (dostępne po słowacku i angielsku; pozostałe języki wyświetlają tekst angielski)\n• Kontakty – numery i kontakty alarmowe\n\nUwaga: Śledzenie można uruchomić kiedykolwiek, także bez wypełnionej odprawy – aplikacja jedynie przypomni chipem \"Brak SB\" w Dzienniku, dopóki jej nie ukończysz. Odprawa wymaga najpierw wypełnionej karty jachtu i załogi i zapisuje się dopiero z podpisami wszystkich członków.';

  @override
  String get guideDutyTitle => 'Wachta załogi';

  @override
  String get guideDutyBody =>
      'Zapis o tym, kto kiedy pełnił wachtę — w Bezpieczeństwie, nad kotwicą.\n\n• Objąć wachtę — wybierz jedną lub więcej osób naraz; każda kończy potem osobno\n• Imiona pobierane są z załogi rejsu. Jeśli załoga nie jest wypełniona, przycisk przeniesie cię do karty rejsu\n• Czas objęcia można poprawić, jeśli nacisnąłeś przycisk później\n• Pokaż do kontroli — pełnoekranowa karta do kontroli na pokładzie: kto pełni, od kiedy, czas lokalnie i UTC. Nic z niej nie można zmienić\n• Harmonogram wacht — dodanie wachty wstecz oraz edycja. Jeśli nie wypełnisz czasu „do\", wachta trwa dalej\n• Wachta nocna przez północ to jeden zapis, nie dwa. W PDF pojawia się w obu dniach, oznaczona strzałką\n• Objęcie i zakończenie zapisują się do dziennika i do eksportu PDF\n\nUwaga: aplikacja nigdy nie kończy wachty sama. Po 12 godzinach jedynie ostrzega — koniec, którego nie widziałeś, byłby zmyślonym zapisem.';

  @override
  String get guideCompassTitle => 'Kompas namiarowy';

  @override
  String get guideCompassBody =>
      'Zakładka Kompas pokazuje azymut magnetyczny za pomocą czujników telefonu, z podglądem tylnej kamery jako tłem do namierzania obiektów.\n\n• Żółty krzyż – kierunek, na który celujesz\n• Pasek kompasu u góry – N / NE / E / SE / S / SW / W / NW\n• Odczyt liczbowy – stopnie i strona świata\n• Zielona kropka = stabilny odczyt  ·  Pomarańczowa kropka = kalibruje\n\nJeśli odczyt jest niestabilny, powoli poruszaj telefonem w kształcie ósemki, aby skalibrować magnetometr.\n\nUwaga: dokładność może być obniżona w pobliżu konstrukcji metalowych, głośników lub elektroniki.';

  @override
  String get guideSettingsTitle => 'Ustawienia';

  @override
  String get guideSettingsBody =>
      '• Jednostki – odległość Mm/km, prędkość węzły/km/h, osobno temperatura, głębokość i wiatr (na rzece pasują km + km/h)';

  @override
  String get guideBackupTitle => 'Kopia zapasowa i przywracanie danych';

  @override
  String get guideBackupBody =>
      'W Ustawienia → Kopia zapasowa danych.\n\n• Eksportuj kopię – zapisuje cały dziennik (rejsy, wpisy, ustawienia) do jednego pliku (.hmbbackup), który możesz udostępnić e-mailem, do chmury lub zapisać lokalnie\n• Przywróć z kopii – zastępuje aktualne dane zawartością wybranej kopii; przed nadpisaniem automatycznie powstaje kopia bezpieczeństwa bieżącego stanu\n• Przywracanie jest zablokowane podczas aktywnego śledzenia GPS rejsu\n• Kopię z nowszym schematem niż obsługuje aplikacja, aplikacja odrzuci z wyjaśnieniem';

  @override
  String get guideExportTitle => 'Eksport dziennika';

  @override
  String get guideExportBody =>
      'Dziennik można wyeksportować jako profesjonalny dokument PDF.\n\n1. Otwórz Dziennik → wybierz czarter\n2. Dotknij ikony eksportu lub trzech kropek → Eksport PDF\n3. Podpisz jako skipper → wygeneruje się PDF\n4. PDF zawiera: trasę, wpisy, zdjęcia, safety briefing z podpisami załogi; strona tytułowa ma w nagłówku zdjęcie jachtu z karty jachtu (jeśli wgrane)\n5. Udostępnij e-mailem, wydrukuj lub zapisz w telefonie\n\nKażdy PDF otrzymuje unikalne ID dokumentu (np. HMBSL-5-2026) i numer rewizji (Rev. 1, Rev. 2...) widoczny w stopce każdej strony. Przy każdym nowym eksporcie numer automatycznie rośnie – widać więc, ile razy dokument wygenerowano.\n\nKod QR na stronie podpisu zawiera ID, rewizję i kryptograficzny odcisk zawartości. Każda zmiana danych zmienia kod QR.\n\nPDF tworzy się w języku ustawionym w aplikacji, wraz z imionami i znakami diakrytycznymi. Na stronie dnia jest też przegląd wachty załogi.';

  @override
  String get safetyBriefingScreenTitle => 'Safety Briefing';

  @override
  String get briefingCrewSignaturesSection => 'Podpisy załogi';

  @override
  String get briefingSignHere => 'Podpisz tutaj';

  @override
  String get briefingClear => 'Wyczyść';

  @override
  String get briefingSigned => 'Podpisano';

  @override
  String get briefingSave => 'Zapisz podpisy';

  @override
  String get briefingSavedOk => 'Podpisy zapisane';

  @override
  String get briefingOpenBriefing => 'Safety Briefing';

  @override
  String get briefingSkipper => 'Skipper';

  @override
  String get briefingCrew => 'Załoga';

  @override
  String get briefingNoCrew =>
      'Załoga nie jest zdefiniowana. Dodaj członków w ustawieniach rejsu.';

  @override
  String get briefingDate => 'Data';

  @override
  String get briefingLocation => 'Miejsce';

  @override
  String get briefingDoneLabel => 'Safety Briefing ukończony';

  @override
  String get briefingDoneSubtitle =>
      'Podpisy załogi są zapisane. Nie trzeba powtarzać.';

  @override
  String get briefingEditSignature => 'Zmień podpis';

  @override
  String get briefingRequiredTitle => 'Wymagany Safety Briefing';

  @override
  String get briefingRequiredBody =>
      'Przed pierwszym uruchomieniem śledzenia należy ukończyć Safety Briefing i zebrać podpisy załogi.';

  @override
  String get goToBriefing => 'Przejdź do Briefingu';

  @override
  String get skipperProfile => 'Profil skippera';

  @override
  String get skipperProfileHint => 'Te dane pojawią się w eksporcie PDF rejsu.';

  @override
  String get skipperFullName => 'Imię skippera';

  @override
  String get skipperLicenseSection => 'Licencja skippera';

  @override
  String get skipperLicenseType => 'Typ licencji';

  @override
  String get skipperLicenseNumber => 'Numer licencji';

  @override
  String get skipperLicenseAuthority => 'Wydawca';

  @override
  String get skipperLicenseExpiry => 'Ważna do';

  @override
  String get skipperVhfSection => 'Licencja VHF / SRC';

  @override
  String get skipperVhfNumber => 'Numer VHF/SRC';

  @override
  String get skipperVhfExpiry => 'Ważność VHF';

  @override
  String get skipperOtherCerts => 'Pozostałe certyfikaty / licencje';

  @override
  String get skipperOtherCertsHint =>
      'np. Yachtmaster, RYA, STCW, kursy ratownicze...';

  @override
  String get continueLastVoyageTitle => 'Kontynuować ostatni rejs?';

  @override
  String get continueVoyageAction => 'Kontynuuj';

  @override
  String get newRecordAction => 'Nowy wpis';

  @override
  String get missingCheckInChip => 'Brak Check-in';

  @override
  String get missingBriefingChip => 'Brak SB';

  @override
  String get missingDetailsChip => 'Brak karty jachtu/załogi';

  @override
  String get missingCheckOutChip => 'Brak Check-out';

  @override
  String get vesselModel => 'Model';

  @override
  String get vesselTypeMonohull => 'Jednokadłubowa';

  @override
  String get vesselTypeCatamaran => 'Katamaran';

  @override
  String get vesselTypeTrimaran => 'Trimaran';

  @override
  String get vesselTypeMotorYacht => 'Jacht motorowy';

  @override
  String get vesselTypeGulet => 'Gulet';

  @override
  String get vesselTypeDinghy => 'Łódź';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Inne';

  @override
  String get charterCompanyLabel => 'Firma czarterowa';

  @override
  String get yachtParamsSection => 'Parametry jachtu';

  @override
  String get berthsLabel => 'Koje';

  @override
  String get yearBuiltLabel => 'Rok produkcji';

  @override
  String get waterTankLabel => 'Zbiornik na wodę';

  @override
  String get fuelTankLabel => 'Zbiornik paliwa';

  @override
  String get engineHoursStartLabel => 'Motogodziny · początek';

  @override
  String get engineHoursEndLabel => 'Motogodziny · koniec';

  @override
  String get whereWhenSection => 'Gdzie i kiedy';

  @override
  String get countryLabel => 'Kraj';

  @override
  String get cruisingAreaLabel => 'Akwen rejsu';

  @override
  String get charterContactsSection => 'Kontakty czarteru';

  @override
  String get charterContactsHint =>
      'Do 3 numerów do połączeń / WhatsApp / SMS. Zawsze z prefiksem międzynarodowym (np. +385...).';

  @override
  String get addPhoneNumber => 'Dodaj numer telefonu';

  @override
  String get costsSection => 'Koszty';

  @override
  String get charterPriceLabel => 'Cena czarteru';

  @override
  String get currencyLabel => 'Waluta';

  @override
  String get addCostItem => 'Dodaj koszt';

  @override
  String get costName => 'Nazwa kosztu';

  @override
  String get crewSectionHint =>
      'Dotknij odznaki, aby ustawić skippera — pozostali to załoga.';

  @override
  String get addCrewMember => 'Dodaj członka załogi';

  @override
  String get crewNameLabel => 'Imię';

  @override
  String get skipperBadge => 'SKIPPER';

  @override
  String get crewBadge => 'CREW';

  @override
  String get vesselTypeSailboat => 'Żaglówka';

  @override
  String get vesselTypeMotorBoat => 'Łódź motorowa';

  @override
  String get sbNeedsVesselCard =>
      'Najpierw wypełnij kartę jachtu i załogi — Safety Briefing potrzebuje listy członków załogi do podpisów.';

  @override
  String get prefillSkipperTitle => 'Uzupełnić zapisane dane skippera?';

  @override
  String get prefillSkipperFill => 'Uzupełnij';

  @override
  String get prefillSkipperNew => 'Nowy skipper';

  @override
  String get boatLicenceLabel => 'Nr patentu żeglarskiego';

  @override
  String get radioLicenceLabel => 'Nr świadectwa radiowego';

  @override
  String get vesselPhotosSection => 'Zdjęcia jednostki (maks. 3)';

  @override
  String get addPhotoLabel => 'Dodaj';

  @override
  String get createVoyageButton => 'Utwórz rejs';

  @override
  String get saveVoyageButton => 'Zapisz rejs';

  @override
  String get costBaseCharter => 'Cena podstawowa czarteru';

  @override
  String get costDeposit => 'Kaucja';

  @override
  String get costDinghyOutboard => 'Dinghy / silnik zaburtowy';

  @override
  String get costOutboardFuel => 'Paliwo silnika zaburtowego';

  @override
  String get costTransitLog => 'Transit log';

  @override
  String get costTouristTax => 'Opłata klimatyczna';

  @override
  String get costFinalCleaning => 'Sprzątanie końcowe';

  @override
  String get costLinenTowels => 'Pościel i ręczniki';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / kajak';

  @override
  String get costSkipperFee => 'Opłata za skippera';

  @override
  String get costHostessFee => 'Opłata za hostessę';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m m';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Przybliżona pozycja · ±$m m · lokalizacja sieciowa';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Ostatnia znana pozycja · $mins min temu';
  }

  @override
  String get locationQualityUnknown => 'Dokładność nieznana';

  @override
  String get locationQualityMocked => '⚠️ Wykryto fałszywą pozycję';

  @override
  String get syncQueueTitle => 'Kolejka synchronizacji';

  @override
  String get syncQueueEmpty => 'Kolejka jest pusta';

  @override
  String get syncNowAction => 'Synchronizuj teraz';

  @override
  String get syncRetryFailedAction => 'Spróbuj ponownie';

  @override
  String get syncStatusPending => 'Oczekuje';

  @override
  String get syncStatusSending => 'Wysyłanie';

  @override
  String get syncStatusSent => 'Wysłano';

  @override
  String get syncStatusFailed => 'Niepowodzenie';

  @override
  String get syncStatusConflict => 'Konflikt';

  @override
  String get syncStatusDeferred => 'Odłożone';

  @override
  String syncRetryCount(int n) {
    return 'Próba $n';
  }

  @override
  String get syncOffline => 'offline';

  @override
  String syncPendingCount(int n) {
    return '$n oczekuje';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n odłożonych';
  }

  @override
  String syncFailedCount(int n) {
    return '$n nieudanych';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Załącznik czeka na Wi-Fi (na morzu zwykle niedostępne).';

  @override
  String get syncWifiOverrideAction => 'Użyj danych komórkowych';

  @override
  String get syncWifiOverrideActive =>
      'Dane komórkowe dozwolone dla załączników';

  @override
  String get syncClearQueueAction => 'Wyczyść kolejkę';

  @override
  String get syncClearQueueConfirmTitle => 'Wyczyścić całą kolejkę?';

  @override
  String get syncClearQueueConfirmContent =>
      'Usunie wszystkie pozycje z kolejki synchronizacji, w tym już wysłane. Tej akcji nie można cofnąć.';

  @override
  String get syncClearQueueDone => 'Kolejka wyczyszczona';

  @override
  String get syncEnableToggle => 'Synchronizuj dziennik';

  @override
  String get syncEnableToggleDesc =>
      'Wysyłaj wpisy na serwer, gdy aplikacja jest otwarta i online';

  @override
  String get syncTargetLabel => 'Cel synchronizacji';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Własny serwer';

  @override
  String get syncCustomUrlLabel => 'URL serwera';

  @override
  String get syncCustomTokenLabel => 'Token';

  @override
  String get syncTestConnectionAction => 'Testuj połączenie';

  @override
  String get syncTestSuccess => 'Połączenie działa';

  @override
  String syncTestFailure(String detail) {
    return 'Niepowodzenie: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Podaj URL serwera';

  @override
  String get syncUrlErrorInvalid => 'Nieprawidłowy URL';

  @override
  String get syncUrlErrorHttps => 'URL musi zaczynać się od https://';

  @override
  String get syncIntervalLabel => 'Interwał synchronizacji';

  @override
  String syncIntervalMinutes(int n) {
    return '$n min';
  }

  @override
  String get syncIntervalNote =>
      'Synchronizacja działa, dopóki aplikacja jest otwarta';

  @override
  String get syncAttachmentPolicyLabel => 'Załączniki (zdjęcia)';

  @override
  String get syncAttachmentNever => 'Nigdy';

  @override
  String get syncAttachmentWifiOnly => 'Tylko przez Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Zawsze';

  @override
  String get syncBackfillAction => 'Uzupełnij starsze wpisy';

  @override
  String get syncBackfillDesc =>
      'Doda do kolejki wpisy zapisane, gdy synchronizacja była wyłączona';

  @override
  String syncBackfillResult(int n) {
    return '$n dodano do kolejki';
  }

  @override
  String get syncBackfillNone =>
      'Nic do uzupełnienia — wszystko jest już w kolejce lub wysłane';

  @override
  String get syncCloudEnableToggle => 'Cloud export (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Po zalogowaniu PDF i GPX z zakończonego dnia automatycznie wgrają się na Google Drive. Bez logowania wszystko pozostaje tylko w urządzeniu.';

  @override
  String get syncCloudSignInAction => 'Zaloguj konto Google';

  @override
  String get syncCloudSignOutAction => 'Wyloguj';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Zalogowano jako $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Niezalogowany';

  @override
  String get waypointNameHint => 'np. Kotwicowisko, Port...';

  @override
  String waypointDefaultName(String time) {
    return 'Punkt $time';
  }

  @override
  String get mobFullName => 'Człowiek za burtą';

  @override
  String get maydayCardShort => 'Karta\nMayday';

  @override
  String get morseInputHint => 'Wpisz tekst...';

  @override
  String get morseSosTitle => 'SOS – SYGNAŁ ALARMOWY';

  @override
  String get morseSosCopied => 'Skopiowano SOS';

  @override
  String intervalSeconds(int n) {
    return '$n sek';
  }

  @override
  String intervalMinutes(int n) {
    return '$n min';
  }

  @override
  String intervalHours(int n) {
    return '$n godz';
  }

  @override
  String get aboutFeatureGps => 'Śledzenie GPS z automatycznymi wpisami';

  @override
  String get aboutFeatureLogbook => 'Dziennik wielodniowych rejsów';

  @override
  String get aboutFeatureMaps => 'Mapy morskie offline (OpenSeaMap)';

  @override
  String get aboutFeatureWeather => 'Pogoda morska (Open-Meteo)';

  @override
  String get aboutFeatureExport => 'Eksport PDF + GPX';

  @override
  String get aboutFeatureSafety => 'Instruktaż bezpieczeństwa i karta Mayday';

  @override
  String get aboutAuthorLabel => 'Autor';

  @override
  String get aboutVersionLabel => 'Wersja';

  @override
  String get aboutPlatformLabel => 'Platforma';

  @override
  String cloudSignInFailed(String error) {
    return 'Logowanie nie powiodło się: $error';
  }

  @override
  String cloudSignOutFailed(String error) {
    return 'Wylogowanie nie powiodło się: $error';
  }

  @override
  String get marineInstrumentsWifiNote =>
      'Działa tylko przez sieć WiFi jachtu – telefon musi być połączony z bramką NMEA (Raymarine, Digital Yacht, Yacht Devices…). Bez WiFi aplikacja korzysta z GPS telefonu i prognozy pogody z internetu.';

  @override
  String get interruptedVoyageTitle => 'Śledzenie zostało przerwane';

  @override
  String interruptedVoyageBody(String time) {
    return 'Aplikacja zamknęła się o $time bez zakończenia rejsu. Kontynuować ten sam rejs?';
  }

  @override
  String interruptedVoyageGap(String distance) {
    return 'Aktualna pozycja jest $distance Mm od ostatniego zapisanego punktu.';
  }

  @override
  String get interruptedVoyageAddGap => 'Doliczyć tę odległość do rejsu';

  @override
  String get interruptedVoyageResume => 'Kontynuuj';

  @override
  String get batteryPromptTitle => 'Niech aplikacja działa przez cały rejs';

  @override
  String get batteryPromptBody =>
      'Android — zwłaszcza Honor, Huawei i Xiaomi — zamyka aplikacje działające w tle, przez co śledzenie przerywa się w środku rejsu.\n\nW ustawieniach baterii zezwól tej aplikacji na działanie bez ograniczeń. Na Honor/Huawei dodaj ją też do aplikacji chronionych i zezwól na autostart.';

  @override
  String get batteryPromptAction => 'Otwórz ustawienia';

  @override
  String get speed => 'Prędkość';
}
