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
  String get wind24h => 'Vietor – 24h';

  @override
  String get waves24h => 'Vlny – 24h';

  @override
  String get hourlyForecast => 'Hodinová predpoveď';

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
}
