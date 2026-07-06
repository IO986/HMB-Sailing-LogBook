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
  String get navCompass => 'Kompas';

  @override
  String get navSettings => 'Nastavenia';

  @override
  String get cameraPermissionDenied =>
      'Prístup ku kamere bol zamietnutý. Povoľ ho v nastaveniach zariadenia.';

  @override
  String get cameraUnavailable => 'Kamera nedostupná';

  @override
  String get compassCalibrationNote =>
      'Magnetický kompas. Presnosť môže byť ovplyvnená kovom alebo elektronikou v blízkosti. Nekalibrovaný kompas kalibruj pohybom v tvare osmičky.';

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
  String get retry => 'Skúsiť znova';

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
  String get autoDetectAction => 'Auto-detekcia';

  @override
  String get autoDetectWifiHintTitle => 'Najprv sa pripoj na WiFi lode';

  @override
  String get autoDetectWifiHintBody =>
      'Skontroluj v Nastaveniach telefónu → WiFi, že si pripojený na sieť lodných inštrumentov (napr. RayNet, WiFi-1). Potom appka skúsi automaticky nájsť gateway na tejto sieti.';

  @override
  String get openWifiSettings => 'WiFi nastavenia';

  @override
  String get continueAction => 'Pokračovať';

  @override
  String get autoDetecting => 'Hľadám prístroje na WiFi sieti…';

  @override
  String get autoDetectFailed =>
      'Gateway sa nenašiel. Skontroluj, či si pripojený na WiFi sieť lode, alebo zadaj IP ručne v Nastaveniach.';

  @override
  String autoDetectSuccess(String host) {
    return 'Pripojené na $host';
  }

  @override
  String get guidePromptTitle => 'Prvýkrát tu? Rýchla príručka';

  @override
  String get guidePromptBody =>
      'Aplikácia má krátku používateľskú príručku – mapa, lodný denník, počasie, bezpečnostný checklist a ďalšie. Chceš sa na ňu rýchlo pozrieť teraz? Kedykoľvek ju nájdeš aj neskôr v Nastaveniach → Používateľská príručka.';

  @override
  String get guidePromptAction => 'Ukázať príručku';

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
  String get stopTrackingDay => 'Ukončiť tracking pre tento deň?';

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
  String get existingVoyage => 'Pokračovanie existujúcej plavby';

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
  String get trackingInProgress => 'Sledovanie plavby';

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
  String get cannotDeleteWhileTracking =>
      'Nemožno zmazať plavbu počas aktívneho trackingu.';

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
  String get anchorRadiusLabel => 'Sledovaný polomer pohybu';

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
  String get dailyForecast => 'Denná teplota';

  @override
  String get timeCol => 'Čas';

  @override
  String get windCol => 'Vietor';

  @override
  String get wavesCol => 'Vlny';

  @override
  String get rainCol => 'Dážď';

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
  String get displaySettings => 'Zobrazenie';

  @override
  String get nightMode => 'Nočný režim';

  @override
  String get nightModeDesc => 'Červený filter pre zachovanie nočného videnia';

  @override
  String get aboutApp => 'O aplikácii';

  @override
  String get backupSection => 'Záloha dát';

  @override
  String get exportBackup => 'Exportovať zálohu';

  @override
  String get exportBackupDesc =>
      'Uloží celý denník (plavby, záznamy, nastavenia) do jedného súboru';

  @override
  String get restoreBackup => 'Obnoviť zo zálohy';

  @override
  String get restoreBackupDesc =>
      'Nahradí aktuálne dáta obsahom vybraného súboru zálohy';

  @override
  String get restoreBlockedTrackingTitle => 'Beží GPS tracking';

  @override
  String get restoreBlockedTrackingBody =>
      'Pred obnovou zálohy najprv zastav aktívne trasovanie plavby.';

  @override
  String get restoreSchemaTooNewTitle => 'Záloha je z novšej verzie';

  @override
  String get restoreSchemaTooNewBody =>
      'Táto záloha bola vytvorená novšou verziou aplikácie, ako je práve nainštalovaná. Najprv aktualizuj aplikáciu.';

  @override
  String get restoreConfirmTitle => 'Obnoviť zo zálohy?';

  @override
  String get restoreConfirmBody =>
      'Aktuálne dáta budú nahradené obsahom zálohy. Pred obnovou sa automaticky vytvorí bezpečnostná záloha súčasného stavu.';

  @override
  String get restoreSuccess => 'Dáta boli úspešne obnovené zo zálohy.';

  @override
  String get restoreInvalidFile =>
      'Vybraný súbor nie je platná záloha HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Kniha míľ';

  @override
  String get totalNm => 'Celkové NM';

  @override
  String get daysAtSea => 'Dni na mori';

  @override
  String get voyageCount => 'Počet plavieb';

  @override
  String get nightHoursLabel => 'Nočné hodiny';

  @override
  String get byYear => 'Podľa roka';

  @override
  String get byVessel => 'Podľa lode';

  @override
  String get addHistoricalVoyage => 'Pridať historickú plavbu';

  @override
  String get editHistoricalVoyage => 'Upraviť historickú plavbu';

  @override
  String get deleteHistoricalVoyageConfirm =>
      'Naozaj zmazať túto historickú plavbu?';

  @override
  String get manualEntryExplanation => '* manuálny záznam (zadané ručne)';

  @override
  String get roleLabel => 'Rola na palube';

  @override
  String get roleSkipper => 'Skipper';

  @override
  String get roleCoSkipper => 'Kormidelník';

  @override
  String get roleCrew => 'Posádka';

  @override
  String get areaLabel => 'Oblasť / trasa';

  @override
  String get distanceNmLabel => 'Vzdialenosť (NM)';

  @override
  String get daysCountLabel => 'Počet dní';

  @override
  String get milesCertificateTitle => 'Potvrdenie o najazdených míľach';

  @override
  String get logbookRecordTitle => 'Záznam Knihy míľ';

  @override
  String get logbookTrackedHint =>
      'Dátumy, míle, oblasť a rola sa počítajú z trackingu/importu.';

  @override
  String get vesselFlag => 'Vlajka registrácie';

  @override
  String get captainFirstName => 'Meno kapitána';

  @override
  String get captainLastName => 'Priezvisko kapitána';

  @override
  String get captainQualification => 'Najvyššia dosiahnutá kvalifikácia';

  @override
  String get logbookSignatureSection => 'Podpis potvrdzujúci míle';

  @override
  String get addSignature => 'Pridať podpis';

  @override
  String get filterAllYears => 'Všetky roky';

  @override
  String get filterCustomRange => 'Vlastný rozsah';

  @override
  String get handoverMenuTitle => 'Odovzdávací protokol';

  @override
  String get checkInProtocol => 'Check-in protokol';

  @override
  String get checkOutProtocol => 'Check-out protokol';

  @override
  String get safetyBriefingShort => 'Safety\nBrífing';

  @override
  String get handoverChecklistShort => 'Odovzdávací\nChecklist';

  @override
  String get safetyBriefingRefTitle => 'Bezpečnostný brífing';

  @override
  String get handoverChecklistRefTitle => 'Odovzdávací checklist';

  @override
  String get handoverDateTime => 'Dátum a čas';

  @override
  String get handoverLocation => 'Miesto (marína)';

  @override
  String get checklistItemOk => 'OK';

  @override
  String get checklistItemDamaged => 'Poškodené';

  @override
  String get checklistItemMissing => 'Chýba';

  @override
  String get damagePosition => 'Poloha na lodi';

  @override
  String get newDamageBadge => 'NOVÉ POŠKODENIE';

  @override
  String get companySignatureSection =>
      'Podpis zástupcu charterovej spoločnosti';

  @override
  String get companyRepName => 'Meno zástupcu';

  @override
  String get companyNameLabel => 'Názov spoločnosti';

  @override
  String get protocolClosedNotice =>
      'Protokol je uzavretý (podpísali obe strany) – len na čítanie.';

  @override
  String get handoverCertTitle => 'Odovzdávací protokol lode';

  @override
  String get itemSails => 'Plachty';

  @override
  String get itemRigging => 'Lanovie';

  @override
  String get itemAnchorChain => 'Kotva a reťaz';

  @override
  String get itemNavInstruments => 'Navigačné prístroje';

  @override
  String get itemLifeJackets => 'Záchranné vesty';

  @override
  String get itemRaft => 'Záchranný raft';

  @override
  String get itemFirstAidKit => 'Lekárnička';

  @override
  String get itemDinghyMotor => 'Dinghy a prívesný motor';

  @override
  String get itemLights => 'Svetlá';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Ďalšie poznámky';

  @override
  String get gpxImportTitle => 'Import GPX';

  @override
  String get gpxImportPickFile => 'Vybrať GPX súbor';

  @override
  String get gpxTracksFound => 'Nájdené tracky';

  @override
  String get gpxWaypointsFound => 'Nájdené waypointy';

  @override
  String get gpxAssignTarget => 'Priradiť k plavbe';

  @override
  String get gpxNewVoyage => 'Nová plavba';

  @override
  String get gpxImportButton => 'Importovať';

  @override
  String get gpxImportSuccess => 'GPX úspešne importovaný.';

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
      'Pripoj telefón na WiFi sieť Raymarine (napr. WiFi-1, RayNet). IP adresa na zadanie NIE je tá z nastavení Raymarine — je to brána (gateway) tej WiFi siete. Nájdeš ju v telefóne: Nastavenia → WiFi → detail siete → Brána. Port 2000 (TCP) je štandard. Bez pripojenia appka automaticky používa GPS telefónu.';

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
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Port na počúvanie';

  @override
  String get startListening => 'Spustiť';

  @override
  String get stopListening => 'Zastaviť';

  @override
  String connectionListening(String port) {
    return 'Počúva UDP na porte $port';
  }

  @override
  String udpHint(String port) {
    return 'Nastav simulátor/gateway aby posielal UDP na IP tohto telefónu, port $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Počúvam UDP na porte $port';
  }

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
  String get engineSection => 'Motor a nádrže';

  @override
  String get engineHours => 'Motohodiny';

  @override
  String get fuel => 'Palivo';

  @override
  String get fuelLevel => 'Hladina paliva';

  @override
  String get waterLevel => 'Hladina vody';

  @override
  String get noteSection => 'Poznámka';

  @override
  String get noteHint => 'Podmienky plavby, udalosti, zmena posádky...';

  @override
  String get quickPhotoLogTitle => 'Rýchly záznam';

  @override
  String get quickPhotoNoteHint => 'Čo je to? (voliteľné)';

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
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Uložené: $pdf + $gpx';
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
  String get editWaypoint => 'Upraviť waypoint';

  @override
  String get waypointNameLabel => 'Názov';

  @override
  String get skipperSignature => 'Podpis skippera';

  @override
  String get skipperNameLabel => 'Meno skippera';

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
  String get vesselName => 'Meno lode';

  @override
  String get vesselType => 'Typ lode';

  @override
  String get homePort => 'Domovský prístav';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Volací znak';

  @override
  String get vesselLengthM => 'Dĺžka (m)';

  @override
  String get vesselBeamM => 'Šírka (m)';

  @override
  String get vesselDraftM => 'Ponor (m)';

  @override
  String get selectExistingVoyage => 'Vybrať existujúcu plavbu';

  @override
  String get newVoyageForm => 'Nová plavba';

  @override
  String get fillFormAndBriefing => 'Vyplniť dotazník a podpísať SB';

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
  String get saveToDevice => 'Uložiť do zariadenia';

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

  @override
  String get weatherConditionTitle => 'Stav počasia';

  @override
  String get weatherConditionLabel => 'Podmienky';

  @override
  String get wcSunny => 'Slnečno';

  @override
  String get wcPartlyCloudy => 'Čiastočne oblačno';

  @override
  String get wcOvercast => 'Zamračené';

  @override
  String get wcLightRain => 'Slabý dážď';

  @override
  String get wcRain => 'Dážď';

  @override
  String get wcHeavyRain => 'Silný dážď';

  @override
  String get wcDrizzle => 'Mrholenie';

  @override
  String get wcThunderstorm => 'Búrka';

  @override
  String get wcIsoThunderstorm => 'Ojedinelé búrky';

  @override
  String get wcHail => 'Krúpy';

  @override
  String get wcDust => 'Prach';

  @override
  String get wcFoggy => 'Hmla';

  @override
  String get wcWindy => 'Veterné';

  @override
  String get wcCold => 'Mráz';

  @override
  String get photoSection => 'Fotografia';

  @override
  String get camera => 'Fotoaparát';

  @override
  String get gallery => 'Galéria';

  @override
  String get addPhoto => 'Pridať fotku';

  @override
  String get photoAddedToEntry => 'Fotografia priložená';

  @override
  String get voyageStart => 'Začiatok plavby';

  @override
  String get voyageEnd => 'Koniec plavby';

  @override
  String get onlineAccount => 'Online účet';

  @override
  String get onlineAccountDesc =>
      'Online synchronizácia denníka — pripravujeme';

  @override
  String get register => 'Registrovať';

  @override
  String get login => 'Prihlásiť';

  @override
  String get logout => 'Odhlásiť';

  @override
  String get logoutConfirm =>
      'Budete odhlásený. Dáta uložené v zariadení zostanú.';

  @override
  String get notLoggedIn => 'Neprihlásený';

  @override
  String get fullName => 'Celé meno';

  @override
  String get password => 'Heslo';

  @override
  String get userGuide => 'Používateľská príručka';

  @override
  String get guideQuickStart => 'Rýchly štart – 5 krokov';

  @override
  String get guideQuickStartBody =>
      '1. Otvor Denník → stlač + → vyber \"Nová plavba\"\n2. Vyplň názov lode a zadaj predpokladaný počet dní\n3. Tracking štartuje automaticky – telefón si ulož do vrecka\n4. Počas dňa pridávaj záznamy: čas, pozícia, poznámka\n5. Na konci plavby otvor Nastavenia → Export PDF';

  @override
  String get guideMapTitle => 'Mapa';

  @override
  String get guideMapBody =>
      'Záložka Mapa zobrazuje tvoju aktuálnu polohu a trasu plavby.\n\n• Modrá bodka = aktuálna poloha\n• Modrá čiara = práve trackovaná trasa\n• Ikona trasy – vyber ľubovoľnú plavbu alebo deň a pozri jej trasu na mape (oranžovo), aj bez PDF exportu\n• Môžeš prepínať medzi satelitnou a mapovou vrstvou\n• Seamarky – prepínač pre námorné značky (vraky, plytčiny, bóje)\n• Ikona kotvy = miesto kotvenia (len keď je kotva aktívna)\n• Ikona importu – načíta trasy a waypointy z .gpx súboru (pozri sekciu \"Import GPX\")\n• Podrž prst na mape = pridaj waypoint (navigačný cieľ); ťuknutím na existujúci waypoint ho premenuješ alebo zmažeš';

  @override
  String get guideInstrTitle => 'Námorné prístroje';

  @override
  String get guideInstrBody =>
      'Záložka Prístroje zobrazuje navigačné dáta v reálnom čase.\n\n• SOG – rýchlosť nad dnom (uzly)\n• TWS – skutočná rýchlosť vetra\n• TWA – smer vetra voči lodi (zelená = pravobok, červená = ľavobok)\n• DEPTH – hĺbka vody (červené = menej ako 5 m)\n• VMG WP – rýchlosť k vybranému waypointu; po výbere z dlaždice uvidíš vzdialenosť/smer aj šípku priamo na smerovej ružici\n\nZdroj dát: telefónne GPS alebo Raymarine (TCP aj UDP WiFi gateway).\nNastavenia pripojenia (vrátane voľby TCP/UDP) nájdeš v Nastavenia → Prístroje.';

  @override
  String get guideLogbookTitle => 'Denník plavby';

  @override
  String get guideLogbookBody =>
      'Denník je hlavná záložka pre správu pláv.\n\n• Stlač + (FAB) → \"Nová plavba\" pre vytvorenie chárteru\n• Tracking sa spúšťa z tohto dialógu – pozícia sa zaznamená automaticky\n• Každý deň plavby sa zobrazuje zvlášť\n• Záznamy možno pridávať ručne počas dňa, vrátane motohodín, paliva a vody v sekcii \"Motor a nádrže\"\n• Počas trackingu sa objaví tlačidlo fotoaparátu (vľavo dole) – odfoť zaujímavý bod a rýchlo ho ulož ako záznam s polohou a časom\n• Denník možno exportovať do PDF cez menu dňa\n• Ikona podania rúk v detaile plavby otvorí odovzdávací protokol (check-in/check-out)';

  @override
  String get guideMilesTitle => 'Kniha míľ';

  @override
  String get guideMilesBody =>
      'Súhrn všetkých plavieb na jednom mieste (ikona v Denníku plavby).\n\n• Celkové námorné míle, dni na mori, počet plavieb a nočné hodiny\n• Rozpad podľa roka a podľa lode\n• Filter podľa roka\n• Klikni na plavbu (aj trackovanú/importovanú) a doplň záznam Knihy míľ – trasu, vlajku lode, meno a kvalifikáciu kapitána, podpis potvrdzujúci míle\n• Tlačidlo + – pridaj historickú plavbu spred používania appky (počíta sa plne do súhrnov, v zozname označená hviezdičkou)\n• Export PDF potvrdenia o najazdených míľach s miestom na podpis';

  @override
  String get guideHandoverTitle => 'Odovzdávací protokol (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Formálny záznam o prevzatí a vrátení lode pri chartri – ikona podania rúk v detaile plavby.\n\n• Kontrolný zoznam výbavy (plachty, lanovie, kotva, navigácia, vesty, raft, lekárnička, dinghy, svetlá, bimini...) – OK / poškodené / chýba, s poznámkou, polohou na lodi a fotkou\n• Stav paliva, vody a motohodín\n• Podpis skippera aj zástupcu charterovej spoločnosti\n• Protokol sa uzavrie (len na čítanie) až keď podpíšu obaja\n• Check-out si predvyplní údaje z check-in protokolu a zvýrazní nové poškodenia\n• Export PDF s oboma podpismi vedľa seba';

  @override
  String get guideGpxImportTitle => 'Import GPX';

  @override
  String get guideGpxImportBody =>
      'Importuj trasy a waypointy z iných navigačných aplikácií alebo GPS zariadení (ikona na Mape).\n\n• Vyber .gpx súbor zo zariadenia\n• Viacdňový export (viac trackov v jednom súbore, napr. z Garmin Explore) sa automaticky spojí do jednej plavby s dňom pre každý kalendárny deň\n• Nájdené tracky vieš aj ručne priradiť k existujúcej plavbe\n• Waypointy (aj z trás/routes) sa pridajú rovno na mapu\n• Pri poškodenom súbore appka zobrazí zrozumiteľnú chybovú hlášku';

  @override
  String get guideWeatherTitle => 'Počasie';

  @override
  String get guideWeatherBody =>
      'Záložka Počasie zobrazuje predpoveď podľa aktuálnej polohy.\n\n• Aktualizuje sa automaticky pri zmene polohy\n• Zobrazuje vietor, vlny, teplotu a podmienky nasledujúcich hodín\n• Ak nemáš internet, zobrazí sa posledná uložená predpoveď';

  @override
  String get guideSafetyMobTitle => 'MOB a kotva';

  @override
  String get guideSafetyMobBody =>
      'Záložka Bezpečnosť obsahuje núdzové funkcie.\n\nMOB (Človek cez palubu):\n• Podržte červené tlačidlo MOB pre aktiváciu\n• Aplikácia zaznamená GPS polohu a meria čas a vzdialenosť\n• Navigácia späť k miestu pádu\n\nKotva:\n• Nastav polomer kotvenia (odporúčané: 2× dĺžka kotevného lana)\n• Alarm zavibruje, ak sa loď vzdiali z povoleného okruhu';

  @override
  String get guideSafetyBriefingTitle => 'Bezpečnostný brífing a MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'V Bezpečnosti nájdeš aj záložky s referenčnými kartami.\n\n• Bezpečnostný brífing – checklist pre posádku pred plavbou\n• Každý člen posádky podpíše vlastným podpisom na obrazovke\n• Podpisy sa uložia a automaticky sa zahrnú do PDF exportu chartera\n• Odovzdávací checklist – prehľad položiek na prevzatie/vrátenie lode, dostupný aj bez otvorenej plavby\n• MAYDAY karta – postup pre tiesňové volanie na VHF kanál 16\n• COLREG – pravidlá predchádzania zrážkam na mori\n• Kontakty – núdzové čísla a kontakty';

  @override
  String get guideCompassTitle => 'Námerový kompas';

  @override
  String get guideCompassBody =>
      'Záložka Kompas zobrazuje magnetický azimut pomocou senzorov telefónu, s výhľadom zadnej kamery ako pozadím pre zameranie objektov.\n\n• Žltý kríž – smer, na ktorý mierite\n• Kompasová lišta hore – N / NE / E / SE / S / SW / W / NW\n• Číselné zobrazenie – stupne a svetová strana\n• Zelená bodka = stabilné čítanie  ·  Oranžová bodka = kalibruje\n\nAk je čítanie nestabilné, pomaly pohybuj telefónom do tvaru osmičky pre kalibráciu magnetometra.\n\nPozor: presnosť môže byť znížená v blízkosti kovových konštrukcií, reproduktorov alebo elektroniky.';

  @override
  String get guideSettingsTitle => 'Nastavenia';

  @override
  String get guideSettingsBody =>
      '• Jazyk – zmeň jazyk aplikácie\n• Prístroje – nastav IP adresu Raymarine WiFi gateway (TCP alebo UDP)\n• GPS zdroj – telefón alebo Raymarine\n• Jednotky – uzly/km/h, metre/stopy\n• Frekvencia zápisov do denníka\n• Zobrazenie – nočný režim (červený filter pre zachovanie nočného videnia)\n• Online účet – synchronizácia pripravovaná (v2.0)\n• Záloha dát – pozri sekciu \"Záloha a obnova dát\"\n• O aplikácii – verzia a kontakt';

  @override
  String get guideBackupTitle => 'Záloha a obnova dát';

  @override
  String get guideBackupBody =>
      'V Nastavenia → Záloha dát.\n\n• Exportovať zálohu – uloží celý denník (plavby, záznamy, nastavenia) do jedného súboru (.hmbbackup), ktorý môžeš zdieľať emailom, do cloudu alebo si ho uložiť lokálne\n• Obnoviť zo zálohy – nahradí aktuálne dáta obsahom vybranej zálohy; pred prepísaním sa automaticky vytvorí bezpečnostná záloha súčasného stavu\n• Obnova je zablokovaná počas aktívneho GPS trackingu plavby\n• Zálohu s novšou schémou, než akú appka podporuje, appka odmietne s vysvetlením';

  @override
  String get guideExportTitle => 'Export denníka';

  @override
  String get guideExportBody =>
      'Denník možno exportovať ako profesionálny PDF dokument.\n\n1. Otvor Denník → vyber charter\n2. Klepni na ikonu exportu alebo tri bodky → Export PDF\n3. Podpíš ako skipér → vygeneruje sa PDF\n4. PDF obsahuje: trasu, záznamy, fotky, safety brífing s podpismi posádky\n5. Zdieľaj cez email, tlač alebo ulož do telefónu\n\nKaždý PDF dostane jedinečné ID dokumentu (napr. HMBSL-5-2026) a číslo revízie (Rev. 1, Rev. 2...) viditeľné v pätičke každej strany. Pri každom novom exporte sa číslo automaticky zvýši – je tak viditeľné, koľkokrát bol dokument vygenerovaný.\n\nQR kód na podpisovej strane obsahuje ID, revíziu a kryptografický odtlačok obsahu. Akákoľvek zmena dát zmení QR kód.';

  @override
  String get safetyBriefingScreenTitle => 'Safety Briefing';

  @override
  String get briefingCrewSignaturesSection => 'Podpisy posádky';

  @override
  String get briefingSignHere => 'Podpísať tu';

  @override
  String get briefingClear => 'Zmazať';

  @override
  String get briefingSigned => 'Podpísané';

  @override
  String get briefingSave => 'Uložiť podpisy';

  @override
  String get briefingSavedOk => 'Podpisy uložené';

  @override
  String get briefingOpenBriefing => 'Safety Briefing';

  @override
  String get briefingSkipper => 'Kapitán';

  @override
  String get briefingCrew => 'Posádka';

  @override
  String get briefingNoCrew =>
      'Posádka nie je zadaná. Pridaj členov v nastaveniach plavby.';

  @override
  String get briefingDate => 'Dátum';

  @override
  String get briefingLocation => 'Miesto';

  @override
  String get briefingDoneLabel => 'Safety Briefing dokončený';

  @override
  String get briefingDoneSubtitle =>
      'Podpisy posádky sú uložené. Nie je potrebné opakovať.';

  @override
  String get briefingEditSignature => 'Zmeniť podpis';

  @override
  String get briefingRequiredTitle => 'Vyžaduje sa Safety Briefing';

  @override
  String get briefingRequiredBody =>
      'Pred prvým spustením trackingu je potrebné dokončiť Safety Briefing a zozbierať podpisy posádky.';

  @override
  String get goToBriefing => 'Prejsť na Briefing';

  @override
  String get skipperProfile => 'Profil skippera';

  @override
  String get skipperProfileHint =>
      'Tieto údaje sa zobrazia v PDF exporte plavby.';

  @override
  String get skipperFullName => 'Meno skippera';

  @override
  String get skipperLicenseSection => 'Skipperská licencia';

  @override
  String get skipperLicenseType => 'Typ licencie';

  @override
  String get skipperLicenseNumber => 'Číslo licencie';

  @override
  String get skipperLicenseAuthority => 'Vydavateľ';

  @override
  String get skipperLicenseExpiry => 'Platnosť do';

  @override
  String get skipperVhfSection => 'VHF / SRC licencia';

  @override
  String get skipperVhfNumber => 'Číslo VHF/SRC';

  @override
  String get skipperVhfExpiry => 'Platnosť VHF';

  @override
  String get skipperOtherCerts => 'Ostatné certifikáty / licencie';

  @override
  String get skipperOtherCertsHint =>
      'napr. Yachtmaster, RYA, STCW, záchranárske kurzy...';
}
