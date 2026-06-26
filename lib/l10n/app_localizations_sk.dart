// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get languageName => 'Slovenčina';

  @override
  String get navMap => 'Mapa';

  @override
  String get navTracking => 'Tracking';

  @override
  String get navLogbook => 'Denník';

  @override
  String get navWeather => 'Počasie';

  @override
  String get navSafety => 'Bezpečnosť';

  @override
  String get navSettings => 'Nastavenia';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get delete => 'Zmazať';

  @override
  String get edit => 'Upraviť';

  @override
  String get save => 'Uložiť';

  @override
  String get yes => 'Áno';

  @override
  String get no => 'Nie';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Zavrieť';

  @override
  String get retry => 'Retry';

  @override
  String get share => 'Zdieľať';

  @override
  String get selectAll => 'Vybrať všetko';

  @override
  String get error => 'Chyba';

  @override
  String errorMsg(String msg) {
    return 'Chyba: $msg';
  }

  @override
  String get pressBackToExit => 'Stlač Späť ešte raz pre ukončenie';

  @override
  String get trackingRunningTitle => 'Tracking beží';

  @override
  String get trackingRunningContent => 'Tracking je aktívny. Čo chceš urobiť?';

  @override
  String get stopAndExit => 'Zastaviť a ukončiť';

  @override
  String get keepRunning => 'Nechať bežať';

  @override
  String get marineInstrumentsTitle => 'Lodné inštrumenty';

  @override
  String get marineInstrumentsPrompt =>
      'Chceš pripojiť aplikáciu k lodným inštrumentom (napr. Raymarine cez WiFi gateway)? Aplikácia potom bude čítať GPS, vietor, hĺbku a ďalšie údaje priamo z lode.\n\nBez pripojenia sa použije GPS telefónu a predpoveď počasia z internetu – kedykoľvek to vieš zmeniť v Nastaveniach.';

  @override
  String get notNow => 'Teraz nie';

  @override
  String get setupConnection => 'Nastaviť pripojenie';

  @override
  String get trackingActiveTitle => 'Tracking aktívny';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get waitingForGps => 'Čakám na GPS...';

  @override
  String get gpsUnavailable => 'GPS nedostupné';

  @override
  String get lastKnownPosition => 'Posledná známa poloha';

  @override
  String get accuracy => 'Presnosť';

  @override
  String get logbookBtn => 'Denník';

  @override
  String get stop => 'Zastaviť';

  @override
  String get startVoyage => 'Spustiť plavbu';

  @override
  String get starting => 'Spúšťam...';

  @override
  String get newVoyage => 'Nová plavba';

  @override
  String get multiday => 'Viacdenná';

  @override
  String get standalone => 'Samostatný';

  @override
  String get voyageName => 'Názov plavby';

  @override
  String get voyageNameOptional => 'Názov (voliteľné)';

  @override
  String get voyageNameHint => 'napr. Výlet do zátoky';

  @override
  String get existingVoyage => 'Existujúca plavba';

  @override
  String get newVoyageDropdown => '— Nová plavba —';

  @override
  String get firstVoyageHint => 'Prvá plavba – vyplň základné info:';

  @override
  String get estimatedDays => 'Predpokladaný počet dní:';

  @override
  String get logFrequency => 'Frekvencia zápisov do denníka';

  @override
  String get startTracking => 'Spustiť tracking';

  @override
  String dayNofTotal(int n, int total) {
    return 'Deň $n z $total';
  }

  @override
  String get newDay => '(nový deň)';

  @override
  String get endVoyageTitle => 'Koniec plavby?';

  @override
  String get endVoyageContent =>
      'Dosiahli ste posledný plánovaný deň plavby.\n\nBude plavba pokračovať aj zajtra?';

  @override
  String get decideLayer => 'Neskôr rozhodnem';

  @override
  String get continuesTomorrow => 'Pokračuje zajtra';

  @override
  String get endVoyage => 'Ukončiť plavbu';

  @override
  String get newMultidayVoyage => 'Nová viacdenná plavba';

  @override
  String get deleteCharterTitle => 'Zmazať charter?';

  @override
  String get deleteCharterContent => 'Zmažú sa všetky dni a záznamy.';

  @override
  String get noVoyages => 'Žiadne plavby';

  @override
  String get createFirstCharter => 'Vytvor svoj prvý charter';

  @override
  String get briefingDone => 'Briefing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Plavba nenájdená';

  @override
  String get unknownVessel => 'Neznáma loď';

  @override
  String get captain => 'Kapitán';

  @override
  String get crew => 'Posádka';

  @override
  String get total => 'Celkom';

  @override
  String voyageDaysCount(int n) {
    return 'Dni plavby ($n)';
  }

  @override
  String get bulkDelete => 'Hromadné mazanie';

  @override
  String get noDays =>
      'Žiadne dni.\nSpusti tracking a prvý deň sa vytvorí automaticky.';

  @override
  String get deleteDayTitle => 'Zmazať deň?';

  @override
  String deleteDayContent(String day) {
    return 'Zmažú sa všetky záznamy pre $day.';
  }

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get selectDaysTitle => 'Vybrať dni na mazanie';

  @override
  String deleteCount(int n) {
    return 'Zmazať ($n)';
  }

  @override
  String get safety => 'Bezpečnosť';

  @override
  String get mobHoldToActivate => 'Podržte pre aktiváciu';

  @override
  String get mobActive => '⚠️ MOB AKTÍVNY';

  @override
  String get mobTime => 'Čas';

  @override
  String get mobDistance => 'Vzdialenosť';

  @override
  String get mobDirection => 'Smer';

  @override
  String get navigateToMob => 'Naviguj k MOB';

  @override
  String get gpsPositionNotAvailable => 'GPS pozícia nie je dostupná!';

  @override
  String get anchorAlarm => 'Anchor Alarm';

  @override
  String get drifting => 'DRIFTUJE';

  @override
  String get anchorRadiusLabel => 'Polomer kotevníka';

  @override
  String get activate => 'Aktivovať';

  @override
  String get deactivate => 'Deaktivovať';

  @override
  String get safetyBriefingCard => 'Safety Briefing';

  @override
  String get maydayCard => 'Mayday karta';

  @override
  String get yachtHandover => 'Odovzdanie jachty';

  @override
  String get gearList => 'Zoznam vybavenia';

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Núdzové kontakty';

  @override
  String get backToToc => 'Späť na obsah';

  @override
  String get briefingComplete => 'Briefing dokončený';

  @override
  String get updateByPosition => 'Aktualizovať podľa polohy';

  @override
  String get detectedByGps => 'detekované podľa GPS';

  @override
  String get locationUnavailable =>
      '📍 Poloha nedostupná – zobrazené globálne kontakty';

  @override
  String get detectingLocation => 'Zisťujem polohu...';

  @override
  String get tapToCall => 'Klepni pre zavolanie';

  @override
  String cannotCall(String name) {
    return 'Nedá sa zavolať: $name';
  }

  @override
  String get vhfChannel16 => 'VHF kanál 16 – použite rádio na palube';

  @override
  String get hmbHandbook => 'HMB Príručka';

  @override
  String get checkInLabel => 'Check-in (prevzatie lode)';

  @override
  String get checkOutLabel => 'Check-out (odovzdanie lode)';

  @override
  String get charterCheckCard => 'Charter';

  @override
  String get weatherTitle => 'Počasie a more';

  @override
  String get updateForecast => 'Aktualizovať predpoveď';

  @override
  String get gpsNotAvailableTracking =>
      'GPS nie je dostupné – zapnite tracking';

  @override
  String get downloadingForecast => 'Sťahujem predpoveď...';

  @override
  String get loadingForecast => 'Načítavam predpoveď...';

  @override
  String get noConnection => 'Nie je dostupné spojenie';

  @override
  String get pressRefreshWhenOnline => 'Stlačte refresh keď ste online';

  @override
  String get noWeatherData => 'Žiadne dáta počasia';

  @override
  String get forecastAutoDownload =>
      'Predpoveď sa stiahne automaticky po spustení trackingu, alebo stlačte Refresh.';

  @override
  String get enableGpsFirst => 'Zapnite GPS / tracking najprv';

  @override
  String get downloadForecast => 'Stiahnuť predpoveď';

  @override
  String downloadError(String error) {
    return 'Chyba sťahovania: $error';
  }

  @override
  String get liveInstrumentData => 'Živé dáta z lodných inštrumentov';

  @override
  String get windRelative => 'Vietor (rel.)';

  @override
  String get windTrue => 'Vietor (skut.)';

  @override
  String get depthLabel => 'Hĺbka';

  @override
  String get waterTempLabel => 'Teplota vody';

  @override
  String get courseTrue => 'Kurz (skut.)';

  @override
  String get courseMag => 'Kurz (mag.)';

  @override
  String get engineLabel => 'Motor';

  @override
  String get wavesLabel => 'Vlny';

  @override
  String get pressureLabel => 'Tlak';

  @override
  String get airTempLabel => 'Vzduch';

  @override
  String get waterLabel => 'Voda';

  @override
  String get wind24h => 'Vietor – 3 dni';

  @override
  String get waves24h => 'Vlny – 3 dni';

  @override
  String get hourlyForecast => 'Predpoveď na 3 dni';

  @override
  String get timeCol => 'Čas';

  @override
  String get windCol => 'Vietor';

  @override
  String get wavesCol => 'Vlny';

  @override
  String get beaufort0 => 'Bezvetrie';

  @override
  String get beaufort1 => 'Tichý vánok';

  @override
  String get beaufort2 => 'Slabý vietor';

  @override
  String get beaufort3 => 'Slabý vietor';

  @override
  String get beaufort4 => 'Mierny vietor';

  @override
  String get beaufort5 => 'Dosť čerstvý';

  @override
  String get beaufort6 => 'Čerstvý vietor';

  @override
  String get beaufort7 => 'Silný vietor';

  @override
  String get beaufort8 => 'Búrlivý vietor';

  @override
  String get beaufort9 => 'Búrka';

  @override
  String get beaufort10 => 'Silná búrka';

  @override
  String get beaufort11 => 'Mimoriadna búrka';

  @override
  String get beaufort12 => 'Orkán';

  @override
  String get settingsTitle => 'Nastavenia';

  @override
  String get measurementUnits => 'Jednotky merania';

  @override
  String get temperature => 'Teplota';

  @override
  String get depthWaves => 'Hĺbka / vlny';

  @override
  String get wind => 'Vietor';

  @override
  String get language => 'Jazyk';

  @override
  String get appLanguage => 'Jazyk aplikácie';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get aboutApp => 'O aplikácii';

  @override
  String get connectionConnected => 'Pripojené';

  @override
  String get connectionConnecting => 'Pripájam sa...';

  @override
  String get connectionError => 'Chyba pripojenia';

  @override
  String get connectionDisconnected =>
      'Nepripojené (používa sa telefón GPS / predpoveď)';

  @override
  String get ipAddressLabel => 'IP adresa gateway';

  @override
  String get portLabel => 'Port';

  @override
  String get autoConnectLabel => 'Automaticky pripojiť pri spustení';

  @override
  String get disconnect => 'Odpojiť';

  @override
  String get connect => 'Pripojiť';

  @override
  String get gatewayHint =>
      'Pripoj telefón na WiFi sieť lodného gateway (Raymarine WiFi-1, RayNet a podobné typicky bežia na 10.0.0.1, port 2000). Bez pripojenia aplikácia automaticky používa GPS telefónu a predpoveď počasia z internetu.';

  @override
  String connectedToHost(String host, int port) {
    return 'Pripojené na $host:$port';
  }

  @override
  String get enterIpAddress => 'Zadajte IP adresu gateway';

  @override
  String connectionFailed(String error) {
    return 'Nepodarilo sa pripojiť: $error';
  }

  @override
  String get liveWind => 'Vietor';

  @override
  String get liveDepth => 'Hĺbka';

  @override
  String get liveWaterTemp => 'Teplota vody';

  @override
  String get liveCompass => 'Kompas';

  @override
  String get liveEngine => 'Motor';

  @override
  String get dayNotFound => 'Deň nenájdený';

  @override
  String get saved => 'Uložené';

  @override
  String get trackingThisDay => 'Tracking beží pre tento deň';

  @override
  String get trackingOtherDay => 'Tracking beží pre iný deň';

  @override
  String recordCount(int n) {
    return '$n záznamov';
  }

  @override
  String get addManual => 'Pridať manuálny';

  @override
  String get noEntries => 'Žiadne záznamy';

  @override
  String get entriesAutoAdded =>
      'Záznamy sa pridávajú automaticky počas trackingu';

  @override
  String get deleteEntryTitle => 'Zmazať záznam?';

  @override
  String get autoRecord => 'Automatický záznam';

  @override
  String get routeSection => 'Trasa';

  @override
  String get fromPort => 'Odkiaľ';

  @override
  String get toPort => 'Kam';

  @override
  String get distance => 'Vzdialenosť';

  @override
  String get vessel => 'Loď / čln';

  @override
  String get weatherSection => 'Počasie';

  @override
  String get morning => 'Ráno';

  @override
  String get noon => 'Poludnie';

  @override
  String get evening => 'Večer';

  @override
  String get windDir => 'Smer vetra';

  @override
  String get seaState => 'Stav mora';

  @override
  String get waveHeight => 'Výška vĺn';

  @override
  String get dailyNote => 'Správa dňa';

  @override
  String get dailyNoteHint => 'Popis plavby, zaujímavosti, udalosti dňa...';

  @override
  String get seaCalm => 'Pokojné';

  @override
  String get seaLight => 'Mierne';

  @override
  String get seaModerate => 'Stredné';

  @override
  String get seaRough => 'Rozbúrené';

  @override
  String get seaStormy => 'Búrlivé';

  @override
  String get editEntry => 'Upraviť záznam';

  @override
  String get newEntry => 'Nový záznam';

  @override
  String get sailMode => 'Spôsob plavby';

  @override
  String get sailMain => 'Hlavná';

  @override
  String get navigationSection => 'Navigácia';

  @override
  String get latitude => 'Šírka';

  @override
  String get longitude => 'Dĺžka';

  @override
  String get weatherSeaSection => 'Počasie a more';

  @override
  String get windSpeed => 'Vietor';

  @override
  String get windDirection => 'Smer';

  @override
  String get waveHeight2 => 'Výška vĺn';

  @override
  String get engineSection => 'Motor';

  @override
  String get engineHours => 'Motohodiny';

  @override
  String get fuel => 'Palivo';

  @override
  String get noteSection => 'Poznámka';

  @override
  String get noteHint => 'Podmienky plavby, udalosti, zmena posádky...';

  @override
  String get exportDayTitle => 'Export dňa';

  @override
  String get exportCharterTitle => 'Export chartera';

  @override
  String get loadingData => 'Načítavam dáta...';

  @override
  String get mapsReady => 'Mapy pripravené – môžeš exportovať';

  @override
  String generatingMaps(int current, int total) {
    return 'Generujem náhľady máp ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Exportovať deň';

  @override
  String get exportCharterBtn => 'Exportovať charter';

  @override
  String get entriesLabel => 'Záznamy';

  @override
  String get routePoints => 'Body trasy';

  @override
  String get anchorDriftTitle => '⚓ KOTVA DRIFTUJE!';

  @override
  String get anchorDriftContent =>
      'Loď prekročila perimeter kotvy.\nOkamžite skontrolujte polohu!';

  @override
  String get cancelAnchor => 'Zrušiť kotvu';

  @override
  String get stopAlarm => 'Zastaviť alarm';

  @override
  String get briefingItem1 => 'Záchranné vesty – umiestnenie a použitie';

  @override
  String get briefingItem2 => 'Záchranný kruh a MOB postup';

  @override
  String get briefingItem3 => 'Svetlice – typy a použitie';

  @override
  String get briefingItem4 => 'EPIRB / PLB – aktivácia';

  @override
  String get briefingItem5 => 'VHF rádio – kanál 16, Mayday postup';

  @override
  String get briefingItem6 => 'Hasiaci prístroj – umiestnenie a použitie';

  @override
  String get briefingItem7 => 'Lekárnička – umiestnenie';

  @override
  String get briefingItem8 => 'Núdzové vypnutie motora';

  @override
  String get briefingItem9 => 'Úniky – voda, plyn';

  @override
  String get briefingItem10 => 'Kotva a reťaz – postup kotvenia';

  @override
  String get briefingItem11 => 'Pravidlá na palube';

  @override
  String get briefingItem12 => 'Núdzové kontakty a VHF 16';

  @override
  String get checkInItem1 => 'Doklady lode (registrácia, poistenie)';

  @override
  String get checkInItem2 => 'Záchranné vybavenie – komplet';

  @override
  String get checkInItem3 => 'Zásoby paliva';

  @override
  String get checkInItem4 => 'Zásoby vody';

  @override
  String get checkInItem5 => 'Kotva a reťaz – kontrola';

  @override
  String get checkInItem6 => 'Motor – skúšobná prevádzka';

  @override
  String get checkInItem7 => 'Navigačné prístroje';

  @override
  String get checkInItem8 => 'Lezenie – lana a plachty';

  @override
  String get checkInItem9 => 'Kuchyňa – plyn, sporák';

  @override
  String get checkInItem10 => 'WC – funkčnosť';

  @override
  String get checkInItem11 => 'Existujúce poškodenia – fotodokumentácia';

  @override
  String get checkOutItem1 => 'Loď vyčistená – exteriér';

  @override
  String get checkOutItem2 => 'Loď vyčistená – interiér';

  @override
  String get checkOutItem3 => 'Palivo doplnené';

  @override
  String get checkOutItem4 => 'Voda doplnená';

  @override
  String get checkOutItem5 => 'Odpadky odstránené';

  @override
  String get checkOutItem6 => 'Poškodenia hlásené';

  @override
  String get checkOutItem7 => 'Kľúče odovzdané';

  @override
  String get gearListShort => 'Výbava\njednotlivca';

  @override
  String get colregRules => 'COLREG\nPravidlá';

  @override
  String get checkInShort => 'Check-in\nPrevzatie';

  @override
  String get checkOutShort => 'Check-out\nOdovzdanie';

  @override
  String get appTagline => 'Váš spoľahlivý lodný denník';

  @override
  String exportSavedMsg(String path) {
    return 'Uložené: $path';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Chyba exportu: $error';
  }

  @override
  String get generatingPdf => 'Generujem PDF...';

  @override
  String get colregTitle => 'COLREG – Pravidlá pre vyhýbanie';

  @override
  String get tableOfContents => 'OBSAH';

  @override
  String get inThisChapter => 'V tejto kapitole:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Pr. $n';
  }

  @override
  String get resetChecklistTitle => 'Resetovať zoznam?';

  @override
  String get resetChecklistContent => 'Všetky zaškrtnutia sa vymažú.';

  @override
  String get reset => 'Resetovať';

  @override
  String get checkInReceivingTitle => 'Check-in – Prevzatie lode';

  @override
  String get checkOutHandoverTitle => 'Check-out – Odovzdanie lode';

  @override
  String get checkInCompletedMsg => 'Loď prevzatá – všetko skontrolované ✓';

  @override
  String get checkOutCompletedMsg => 'Loď odovzdaná – všetko v poriadku ✓';

  @override
  String get briefingDoneMsg => 'Briefing dokončený – posádka informovaná';

  @override
  String get sectionBriefed => 'Sekcia prebriefovaná ✓';

  @override
  String get confirmSection => 'Potvrdiť sekciu';

  @override
  String get gearListTitle => 'Výbava jednotlivca';

  @override
  String get newCategory => 'Nová kategória';

  @override
  String get add => 'Pridať';

  @override
  String get deleteItemTitle => 'Zmazať položku?';

  @override
  String get allPackedMsg => 'Všetko zabalené, pripravený na plavbu! 🎉';

  @override
  String get addItemLabel => 'Pridať položku';

  @override
  String addToCategoryTitle(String category) {
    return 'Pridať do: $category';
  }

  @override
  String get newItemHint => 'Nová položka...';

  @override
  String get addWaypoint => 'Pridať waypoint';

  @override
  String get waypointNameLabel => 'Názov';

  @override
  String get skipperSignature => 'Podpis skippera';

  @override
  String get signWithFinger => 'Podpíšte sa prstom';

  @override
  String get clear => 'Vymazať';

  @override
  String get signAndExport => 'Podpísať a exportovať';

  @override
  String get pleaseSign => 'Prosím podpíšte sa pred exportom';

  @override
  String get generatingPdfPreview => 'Generujem náhľad PDF...';

  @override
  String generationError(String error) {
    return 'Chyba generovania: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Ukladám a generujem GPX...';

  @override
  String get editCharter => 'Upraviť charter';

  @override
  String get basicInfo => 'Základné informácie';

  @override
  String get voyageNameRequired => 'Názov plavby *';

  @override
  String get dateFrom => 'Dátum od';

  @override
  String get dateTo => 'Dátum do';

  @override
  String get vesselName => 'Názov lode';

  @override
  String get vesselType => 'Typ lode';

  @override
  String get homePort => 'Domovský prístav';

  @override
  String get notesLabel => 'Poznámky';

  @override
  String get statusLabel => 'Stav';

  @override
  String get safetyBriefingDoneLabel => 'Safety Briefing vykonaný';

  @override
  String get checkInDoneLabel => 'Check-in dokončený';

  @override
  String get checkOutDoneLabel => 'Check-out dokončený';

  @override
  String get enterVoyageName => 'Zadaj názov plavby';

  @override
  String daysCount(int n) {
    return '$n dní';
  }

  @override
  String get selectTargetWaypoint => 'Vyber cieľový waypoint';

  @override
  String get noWaypoints => 'Žiadne waypointy.';

  @override
  String get goToMap => 'Ísť na mapu';

  @override
  String get noTarget => 'Žiadny cieľ';

  @override
  String get selectWaypointHint => 'Vyber waypoint...';

  @override
  String get sessionStats => 'Štatistiky plavby';

  @override
  String get maxSpeed => 'Max rýchlosť';

  @override
  String get avgSpeed => 'Priem. rýchlosť';

  @override
  String get sailingTime => 'Čas plavby';

  @override
  String get gpsData => 'GPS Dáta';

  @override
  String get gpsPosition => 'Poloha';

  @override
  String get courseCog => 'Kurz (COG)';

  @override
  String get altitudeLabel => 'Výška';

  @override
  String get dscProcedure => 'DSC POSTUP';

  @override
  String get voiceScript => 'HLAS SKRIPT';

  @override
  String get dscWarningUseOnly => '⚠️ POUŽÍVAŤ IBA V PRÍPADE';

  @override
  String get dscWarningDanger => 'VÁŽNEHO A BEZPROSTREDNÉHO NEBEZPEČENSTVA';

  @override
  String get dscWarningTypes => 'Požiar · Potápanie · Muž cez palubu';

  @override
  String get dscProcedureSubtitle => 'Uchovajte tento postup pri VHF DSC rádiu';

  @override
  String get fillBeforeSailing => 'Vyplňte pred plavbou:';

  @override
  String get copyTooltip => 'Kopírovať';

  @override
  String get scriptCopied => 'Skript skopírovaný';

  @override
  String get sendOnCh16 =>
      '📻 Odoslať na Kanáli 16 · Vysoký výkon · Opakovať každé 2 minúty ak bez odpovede';

  @override
  String get enterAbove => '[zadaj v polí vyššie]';

  @override
  String get distressNature => 'Povaha tiesne';

  @override
  String get vesselNameLabel => 'Názov lode';

  @override
  String get numberOfPersons => 'Počet osôb';

  @override
  String get additionalInfo => 'Ďalšie info';

  @override
  String get voiceScriptTitle => 'HLASOVÝ MAYDAY SKRIPT';

  @override
  String get dscStep1 => 'Uistite sa, že rádio je zapnuté.';

  @override
  String get dscStep2 => 'Otvorte kryt nad ČERVENÝM tlačidlom tiesne.';

  @override
  String get dscStep3 => 'Stlačte ČERVENÉ tlačidlo RAZ a uvoľnite.';

  @override
  String get dscStep4 =>
      'Vyberte povahu tiesne.\n(Požiar, Potápanie, MOB a pod.)\nAk vynecháte, odošle sa Neoznačená tieseň.';

  @override
  String get dscStep5 =>
      'Stlačte a PODRŽTE ČERVENÉ tlačidlo po dobu 5 sekúnd na odoslanie výzvy.';

  @override
  String get dscStep6 =>
      'Čakajte max. 15 sekúnd na potvrdenie (zobrazí sa na obrazovke), potom pošlite hlasovú správu na Kanáli 16 na VYSOKÝ výkon.';

  @override
  String get appDescription => 'Profesionálny lodný denník pre jachtárov.';

  @override
  String get vesselIdTitle => 'Identifikácia plavidla';

  @override
  String get vesselIdHint =>
      'Call sign a MMSI sa automaticky vyplnia v Mayday Card.';

  @override
  String get maritimeReference => 'Námorná abeceda';

  @override
  String get phonetic => 'Fonetická';

  @override
  String get flagAlphabet => 'Vlajkové signály';

  @override
  String get dayShapes => 'Denné znaky';

  @override
  String get marineReferenceTile => 'Signály & abeceda';

  @override
  String get navInstruments => 'Nástroje';

  @override
  String get enterPort => 'Zadaj prístav...';

  @override
  String get closeWithoutSaving => 'Zavrieť bez uloženia';

  @override
  String get saveAndShare => 'Uložiť a zdieľať';

  @override
  String get timestampCannotBeChanged => 'Čas záznamu sa nedá zmeniť';

  @override
  String entriesShort(int n) {
    return '$n záz.';
  }

  @override
  String get mainsail => 'Hlavná';
}
