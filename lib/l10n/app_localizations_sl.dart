// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get poiTypeAnchorage => 'Sidrišče';

  @override
  String get poiTypeMarina => 'Marina';

  @override
  String get poiTypeFuel => 'Bencinska postaja';

  @override
  String get poiTypeHarbour => 'Pristanišče';

  @override
  String get poiVhfChannel => 'Kanal VHF';

  @override
  String get poiPhone => 'Telefon';

  @override
  String get poiCannotOpen => 'Ni mogoče odpreti';

  @override
  String get poiWebsite => 'Spletna stran';

  @override
  String get poiEmail => 'E-pošta';

  @override
  String get poiCapacity => 'Zmogljivost';

  @override
  String get poiServices => 'Storitve';

  @override
  String get poiSaveAsWaypoint => 'Shrani kot točko poti';

  @override
  String poiWaypointSaved(String name) {
    return 'Točka poti \"$name\" shranjena';
  }

  @override
  String get poiSource => 'Vir: OpenStreetMap';

  @override
  String get mapLayerSatellite => 'Satelit';

  @override
  String get mapLayerMap => 'Zemljevid';

  @override
  String get mapLayers => 'Sloji';

  @override
  String get mapSeamarks => 'Pomorske oznake';

  @override
  String get mapDepths => 'Globine';

  @override
  String mapDepthHere(String depth) {
    return 'Globina tukaj: $depth';
  }

  @override
  String get mapDepthNoData => 'Ni podatkov o globini za to točko';

  @override
  String weatherModelSource(String model) {
    return 'Model: $model';
  }

  @override
  String get weatherOfflineNoAge => 'Brez signala — zadnja shranjena napoved';

  @override
  String weatherOfflineSince(String when) {
    return 'Brez signala — napoved z $when';
  }

  @override
  String weatherStaleSince(String when) {
    return 'Napoved je stara — prenesena $when';
  }

  @override
  String get warningNoDetail => 'Podrobnosti ni bilo mogoče naložiti.';

  @override
  String get warningSourceMeteoalarm => 'Vir: MeteoAlarm';

  @override
  String warningLanguageNote(String lang) {
    return 'Besedilo je v jeziku: $lang';
  }

  @override
  String get mapHarbours => 'Pristanišča in sidrišča';

  @override
  String get mapZoomInForPois =>
      'Približajte za nalaganje pristanišč in sidrišč';

  @override
  String get mapRainRadar => 'Radar padavin';

  @override
  String get mapTools => 'Orodja';

  @override
  String get mapVoyageOverview => 'Pregled plovbe';

  @override
  String get playbackTitle => 'Predvajaj plovbo';

  @override
  String get playbackSpeed => 'Hitrost';

  @override
  String get playbackNoTrack => 'Za ta dan ni zabeležene poti';

  @override
  String playbackAtTime(String time) {
    return 'Stanje ob $time';
  }

  @override
  String get mapRuler => 'Ravnilo / pot';

  @override
  String get mapDownloadOffline => 'Prenesi območje brez povezave';

  @override
  String get mapGpsDisabled => 'GPS je izklopljen';

  @override
  String get mapLocationDenied => 'Lokacija ni dovoljena';

  @override
  String get mapFollowGps => 'Sledi GPS';

  @override
  String mapAreaTooLarge(int count) {
    return 'Območje je preveliko ($count ploščic). Približajte in poskusite znova.';
  }

  @override
  String get mapLivePreview => 'V živo (trenutno sledenje)';

  @override
  String get mapWholeVoyage => 'Celotna plovba';

  @override
  String get offlineSheetTitle => 'Zemljevid vidnega območja brez povezave';

  @override
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb) {
    return 'Zemljevid + pomorske oznake, povečava $minZ–$maxZ, $tiles ploščic (~$mb MB). Prenesena območja delujejo na morju brez signala.';
  }

  @override
  String offlineDone(int n) {
    return 'Končano — shranjenih $n ploščic';
  }

  @override
  String offlineDoneErrors(int n) {
    return 'Končano z napakami: $n ploščic ni bilo preneseno';
  }

  @override
  String get downloadAction => 'Prenesi';

  @override
  String get rulerTapHint => 'Tapnite točke na zemljevidu';

  @override
  String get mapEntryPhoto => 'Fotografski zapis';

  @override
  String get mapEntryNote => 'Zapis v dnevniku';

  @override
  String get openSettingsAction => 'Odpri nastavitve';

  @override
  String get morseConverter => 'Pretvornik besedila v Morsejevo abecedo';

  @override
  String saveError(String error) {
    return 'Napaka pri shranjevanju: $error';
  }

  @override
  String get languageName => 'Slovenščina';

  @override
  String get navMap => 'Zemljevid';

  @override
  String get navTracking => 'Sledenje';

  @override
  String get navLogbook => 'Dnevnik';

  @override
  String get navWeather => 'Vreme';

  @override
  String get navSafety => 'Varnost';

  @override
  String get navCompass => 'Kompas';

  @override
  String get navSettings => 'Nastavitve';

  @override
  String get navCustomizeTitle => 'Spodnji meni';

  @override
  String get navCustomizeHint =>
      'Pritisnite in povlecite za spreminjanje vrstnega reda ikon. S stikalom skrijete zavihek iz spodnjega menija — Nastavitve so vedno prikazane.';

  @override
  String get navAlwaysShown => 'Vedno prikazano';

  @override
  String get navIconSizeLabel => 'Velikost ikon';

  @override
  String get navOpenHiddenTitle => 'Odpri skrite zavihke';

  @override
  String get cameraPermissionDenied =>
      'Dostop do kamere je bil zavrnjen. Omogočite ga v nastavitvah naprave.';

  @override
  String get cameraUnavailable => 'Kamera ni na voljo';

  @override
  String get compassCalibrationNote =>
      'Magnetni kompas. Na natančnost lahko vplivajo kovina ali elektronika v bližini. Če ni umerjen, premikajte napravo v obliki osmice.';

  @override
  String get cancel => 'Prekliči';

  @override
  String get delete => 'Izbriši';

  @override
  String get edit => 'Uredi';

  @override
  String get save => 'Shrani';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Ne';

  @override
  String get ok => 'V redu';

  @override
  String get close => 'Zapri';

  @override
  String get retry => 'Poskusi znova';

  @override
  String get share => 'Deli';

  @override
  String get selectAll => 'Izberi vse';

  @override
  String get error => 'Napaka';

  @override
  String errorMsg(String msg) {
    return 'Napaka: $msg';
  }

  @override
  String get pressBackToExit => 'Za izhod znova pritisnite Nazaj';

  @override
  String get trackingRunningTitle => 'Sledenje poteka';

  @override
  String get trackingRunningContent =>
      'Sledenje je aktivno. Kaj želite storiti?';

  @override
  String get stopAndExit => 'Ustavi in zapri';

  @override
  String get keepRunning => 'Nadaljuj sledenje';

  @override
  String get marineInstrumentsTitle => 'Ladijski instrumenti';

  @override
  String get marineInstrumentsPrompt =>
      'Želite povezati aplikacijo z ladijskimi instrumenti (npr. Raymarine prek prehoda WiFi)? Aplikacija bo nato brala GPS, veter, globino in druge podatke neposredno z ladje.\n\nBrez povezave bosta uporabljena GPS telefona in spletna vremenska napoved – to lahko kadar koli spremenite v Nastavitvah.';

  @override
  String get notNow => 'Ne zdaj';

  @override
  String get setupConnection => 'Nastavi povezavo';

  @override
  String get autoDetectAction => 'Samodejno zaznavanje';

  @override
  String get autoDetectWifiHintTitle => 'Najprej se povežite z WiFi ladje';

  @override
  String get autoDetectWifiHintBody =>
      'V Nastavitvah telefona → WiFi preverite, da ste povezani z omrežjem ladijskih instrumentov (npr. RayNet, WiFi-1). Aplikacija bo nato poskusila samodejno najti prehod v tem omrežju.';

  @override
  String get openWifiSettings => 'Nastavitve WiFi';

  @override
  String get continueAction => 'Nadaljuj';

  @override
  String get autoDetecting => 'Iščem instrumente v omrežju WiFi…';

  @override
  String get autoDetectFailed =>
      'V bližini ni bilo najdenega prehoda. Preverite, ali ste v omrežju WiFi ladje, ali ročno vnesite IP v Nastavitvah.';

  @override
  String autoDetectSuccess(String host) {
    return 'Povezano z $host';
  }

  @override
  String get guidePromptTitle => 'Prvič tukaj? Hitri vodnik';

  @override
  String get guidePromptBody =>
      'Aplikacija vsebuje kratek uporabniški vodnik – zemljevid, dnevnik, vreme, varnostni kontrolni seznam in več. Si ga želite na hitro ogledati? Vedno ga najdete pozneje pod Nastavitve → Uporabniški vodnik.';

  @override
  String get guidePromptAction => 'Prikaži vodnik';

  @override
  String get notifPromptTitle => 'Dovolim obvestila?';

  @override
  String get notifPromptBody =>
      'Med sledenjem plovbi obvestilo ostane v vrstici stanja in na zaklenjenem zaslonu — tako vidite, da je sledenje aktivno, in ga hitro dosežete. Brez dovoljenja lahko sistem omeji sledenje v ozadju.';

  @override
  String get notifPromptAllow => 'Dovoli';

  @override
  String get trackingActiveTitle => 'Sledenje aktivno';

  @override
  String get trackingTitle => 'Sledenje';

  @override
  String get waitingForGps => 'Čakam na GPS...';

  @override
  String get gpsUnavailable => 'GPS ni na voljo';

  @override
  String get lastKnownPosition => 'Zadnji znani položaj';

  @override
  String get accuracy => 'Natančnost';

  @override
  String get logbookBtn => 'Dnevnik';

  @override
  String get stop => 'Ustavi';

  @override
  String get stopTrackingDay => 'Ustavim sledenje?';

  @override
  String get startVoyage => 'Začni plovbo';

  @override
  String get starting => 'Zaganjam...';

  @override
  String get newVoyage => 'Nova plovba';

  @override
  String get multiday => 'Večdnevna';

  @override
  String get standalone => 'Samostojna';

  @override
  String get voyageName => 'Ime plovbe';

  @override
  String get voyageNameOptional => 'Ime (neobvezno)';

  @override
  String get voyageNameHint => 'npr. Izlet po zalivu';

  @override
  String get existingVoyage => 'Nadaljuj obstoječo plovbo';

  @override
  String get newVoyageDropdown => '— Nova plovba —';

  @override
  String get firstVoyageHint => 'Prva plovba – izpolnite osnovne podatke:';

  @override
  String get briefingRequiredHint =>
      'Sledenje je mogoče začeti šele, ko je Varnostni brifing za to plovbo končan.';

  @override
  String get briefingPending => 'VB potreben';

  @override
  String get briefingPendingListWarning =>
      'Varnostni brifing ni končan – sledenja še ni mogoče začeti';

  @override
  String get estimatedDays => 'Predvideno število dni:';

  @override
  String get logFrequency => 'Pogostost zapisov v dnevnik';

  @override
  String get startTracking => 'Začni sledenje';

  @override
  String get trackingInProgress => 'Sledite svoji plovbi';

  @override
  String dayNofTotal(int n, int total) {
    return 'Dan $n od $total';
  }

  @override
  String get newDay => '(nov dan)';

  @override
  String get endVoyageTitle => 'Končam plovbo?';

  @override
  String get endVoyageContent =>
      'Dosegli ste zadnji načrtovani dan plovbe.\n\nAli se bo plovba jutri nadaljevala?';

  @override
  String get decideLayer => 'Odloči se pozneje';

  @override
  String get continuesTomorrow => 'Nadaljuje se jutri';

  @override
  String get endVoyage => 'Končaj plovbo';

  @override
  String get newMultidayVoyage => 'Nova večdnevna plovba';

  @override
  String get deleteCharterTitle => 'Izbrišem plovbo?';

  @override
  String get deleteCharterContent => 'Vsi dnevi in zapisi bodo izbrisani.';

  @override
  String get cannotDeleteWhileTracking =>
      'Plovbe ni mogoče izbrisati, dokler je sledenje aktivno.';

  @override
  String get noVoyages => 'Ni plovb';

  @override
  String get createFirstCharter => 'Ustvari svojo prvo plovbo';

  @override
  String get briefingDone => 'Brifing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Plovba ni bila najdena';

  @override
  String get unknownVessel => 'Neznano plovilo';

  @override
  String get captain => 'Skiper';

  @override
  String get crew => 'Posadka';

  @override
  String get total => 'Skupaj';

  @override
  String voyageDaysCount(int n) {
    return 'Dnevi plovbe ($n)';
  }

  @override
  String get bulkDelete => 'Množično brisanje';

  @override
  String get noDays =>
      'Ni dni.\nZačnite sledenje in prvi dan bo ustvarjen samodejno.';

  @override
  String get deleteDayTitle => 'Izbrišem dan?';

  @override
  String deleteDayContent(String day) {
    return 'Vsi zapisi za $day bodo izbrisani.';
  }

  @override
  String get exportPdf => 'Izvozi PDF';

  @override
  String get selectDaysTitle => 'Izberite dneve za brisanje';

  @override
  String deleteCount(int n) {
    return 'Izbriši ($n)';
  }

  @override
  String get safety => 'Varnost';

  @override
  String get mobHoldToActivate => 'Držite za aktivacijo';

  @override
  String get mobActive => '⚠️ MOB AKTIVEN';

  @override
  String get mobTime => 'Čas';

  @override
  String get mobDistance => 'Razdalja';

  @override
  String get mobDirection => 'Smer';

  @override
  String get navigateToMob => 'Navigiraj do MOB';

  @override
  String get gpsPositionNotAvailable => 'Položaj GPS ni na voljo!';

  @override
  String get anchorAlarm => 'Alarm sidra';

  @override
  String get drifting => 'SIDRO ORJE';

  @override
  String get anchorRadiusLabel => 'Polmer sidranja';

  @override
  String get anchorZoneTool => 'Sidrno območje';

  @override
  String get undoLastPoint => 'Razveljavi zadnjo točko';

  @override
  String get anchorZoneDrawFromMap => 'Nariši območje na zemljevidu';

  @override
  String get anchorZoneDrawHint => 'Tapni vogale območja na zemljevidu';

  @override
  String get anchorZoneNeedsPoints => 'Območje potrebuje vsaj tri vogale';

  @override
  String get anchorZoneSelfIntersects =>
      'Območje se seka samo s sabo — popravi vogale';

  @override
  String get anchorZoneArm => 'Nadzoruj to območje';

  @override
  String get anchorZoneActive => 'Nadzor območja';

  @override
  String anchorZoneInside(String m) {
    return '$m m do roba območja';
  }

  @override
  String anchorZoneOutside(String m) {
    return '$m m zunaj območja';
  }

  @override
  String get anchorZoneNotInside => 'Si zunaj narisanega območja';

  @override
  String get anchorZoneTooTight => 'Območje je tesnejše od natančnosti GPS';

  @override
  String get anchorZoneNoFix =>
      'Brez položaja GPS — sidrna točka je vzeta iz območja';

  @override
  String get anchorNoFix => 'Sidrna straža potrebuje položaj GPS';

  @override
  String get activate => 'Aktiviraj';

  @override
  String get deactivate => 'Deaktiviraj';

  @override
  String get safetyBriefingCard => 'Varnostni brifing';

  @override
  String get maydayCard => 'Kartica Mayday';

  @override
  String get yachtHandover => 'Primopredaja jahte';

  @override
  String get gearList => 'Seznam opreme';

  @override
  String get pdfEntriesSection => 'Zapisi v dnevniku';

  @override
  String get pdfSkipperMessage => 'Poročilo skiperja';

  @override
  String get pdfWeatherSection => 'Vreme';

  @override
  String get pdfDaySummary => 'Dnevni povzetek';

  @override
  String get pdfDaysOverview => 'Pregled dni';

  @override
  String get pdfVoyageSummary => 'Povzetek plovbe';

  @override
  String get pdfCrewSection => 'Posadka';

  @override
  String get pdfSignatures => 'Podpisi';

  @override
  String get pdfCrewSignatures => 'Podpisi posadke';

  @override
  String get pdfSkipperSignature => 'Podpis skiperja';

  @override
  String get pdfSkipperLicences => 'Skiper – dovoljenja';

  @override
  String get pdfSafetyBriefing => 'Varnostni brifing';

  @override
  String get pdfChecklistSection => 'Kontrolni seznam';

  @override
  String get pdfMoreNotes => 'Dodatne opombe';

  @override
  String get pdfIntegrityCheck => 'Preverjanje celovitosti dokumenta';

  @override
  String get pdfHandoverTitle => 'Zapisnik o primopredaji';

  @override
  String get pdfMilesTitle => 'Potrdilo o preplutih miljah';

  @override
  String get pdfDeparture => 'Izplutje';

  @override
  String get pdfArrival => 'Priplutje';

  @override
  String get pdfTotalLabel => 'Skupaj';

  @override
  String get pdfDayCount => 'Dni';

  @override
  String get pdfEngineHours => 'Ure motorja';

  @override
  String get pdfFuelLabel => 'Gorivo';

  @override
  String get pdfWaterLabel => 'Voda';

  @override
  String get pdfVesselLabel => 'Plovilo';

  @override
  String get pdfSkipperLabel => 'Skiper';

  @override
  String get pdfDateLabel => 'Datum';

  @override
  String get pdfColFrom => 'Od';

  @override
  String get pdfColTo => 'Do';

  @override
  String get pdfColEntriesShort => 'Zapisi';

  @override
  String get pdfColTimeUtc => 'Čas UTC';

  @override
  String pdfColTimeLocal(String offset) {
    return 'Čas $offset';
  }

  @override
  String get timeZoneLabel => 'Časovni pas';

  @override
  String get timeZoneLocalShort => 'Lokalni';

  @override
  String get pdfColWind => 'Veter';

  @override
  String get pdfColPropulsion => 'Pogon';

  @override
  String get pdfColWeatherShort => 'Vrem.';

  @override
  String get pdfColNote => 'Opomba';

  @override
  String get pdfColDay => 'Dan';

  @override
  String get pdfColItem => 'Postavka';

  @override
  String get pdfColStatus => 'Stanje';

  @override
  String get pdfColNotePosition => 'Opomba / položaj';

  @override
  String get pdfColPhoto => 'Foto';

  @override
  String get pdfColDateRange => 'Datum od-do';

  @override
  String get pdfColArea => 'Območje';

  @override
  String get pdfColTidal => 'Vode';

  @override
  String get pdfTidal => 'plimske';

  @override
  String get pdfNonTidal => 'neplimske';

  @override
  String get pdfMilesIssuedFor => 'Izdano za';

  @override
  String get pdfMilesIssuedBy => 'Izdal';

  @override
  String get pdfMilesOwnRecord => 'Lastna evidenca preplutih milj';

  @override
  String get pdfMilesByRole => 'Milje po vlogi';

  @override
  String get pdfMilesSkipperSummary => 'Skiperski povzetek';

  @override
  String get pdfMilesSkipperConfirms => 'Potrditev vodje plovbe';

  @override
  String get milesExportTitle => 'Izdaj potrdilo';

  @override
  String get milesExportFor => 'Za koga';

  @override
  String get milesExportForSelf => 'Zase';

  @override
  String get milesExportForCrew => 'Za člana posadke';

  @override
  String get milesExportRecipient => 'Ime prejemnika';

  @override
  String get milesExportIssuer => 'Izdajatelj';

  @override
  String get milesExportQualification => 'Kvalifikacija';

  @override
  String get milesExportVoyages => 'Plovbe v potrdilu';

  @override
  String get milesExportSelectAll => 'Izberi vse';

  @override
  String get milesExportSelectNone => 'Počisti izbor';

  @override
  String milesExportChosenSummary(String count, String nm) {
    return 'Izbranih plovb: $count  ·  $nm NM';
  }

  @override
  String get milesExportNoVoyages => 'Izbrana ni nobena plovba';

  @override
  String get milesTidalWaters => 'Plimske vode';

  @override
  String get notSpecified => 'Ni navedeno';

  @override
  String get pdfColRole => 'Vloga';

  @override
  String get pdfNameLabel => 'Ime';

  @override
  String get pdfLicenceLabel => 'Licenca';

  @override
  String get pdfIssuedValidLabel => 'Izdal / velja';

  @override
  String get pdfOtherCertsLabel => 'Drugi cert.';

  @override
  String get pdfContinued => 'nadaljevanje';

  @override
  String get pdfExportedAt => 'Izvoženo';

  @override
  String get pdfSignedAt => 'Podpisano';

  @override
  String get pdfSignatureLabel => 'Podpis';

  @override
  String get pdfDatePlaceLabel => 'Datum / kraj';

  @override
  String get pdfManualEntryNote => '* ročni vnos (vnesen ročno)';

  @override
  String get pdfStatTotalDistance => 'Skupna razdalja';

  @override
  String get pdfStatLogEntries => 'Zapisi dnevnika';

  @override
  String get pdfStatMaxBeaufort => 'Maks. Beaufort';

  @override
  String get pdfStatDaysAtSea => 'Dni na morju';

  @override
  String get pdfStatVoyages => 'Število plovb';

  @override
  String get pdfStatNightHours => 'Nočne ure';

  @override
  String get pdfFuelShort => 'G';

  @override
  String get pdfWaterShort => 'V';

  @override
  String get pdfNoData => 'Ni podatkov';

  @override
  String get pdfMapUnavailable => 'Zemljevid GPS ni na voljo';

  @override
  String get pdfUnsigned => 'Nepodpisano';

  @override
  String get pdfNoSignatures => 'Ni podpisov';

  @override
  String get pdfSha256Label => 'Izvleček SHA-256 podatkov dnevnika:';

  @override
  String get pdfVerifyQr => 'QR za preverjanje';

  @override
  String get pdfSbLifejackets => 'Rešilni jopiči – lokacija in uporaba';

  @override
  String get pdfSbLifebuoy => 'Rešilni obroč in postopek MOB';

  @override
  String get pdfSbFlares => 'Signalne rakete – vrste in uporaba';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – aktivacija';

  @override
  String get pdfSbVhf => 'Radio VHF – kanal 16, postopek Mayday';

  @override
  String get pdfSbExtinguisher => 'Gasilni aparat – lokacija in uporaba';

  @override
  String get pdfSbFirstAid => 'Komplet prve pomoči – lokacija';

  @override
  String get pdfSbEngineStop => 'Zasilna zaustavitev motorja';

  @override
  String get pdfSbLeaks => 'Puščanje – voda, plin';

  @override
  String get pdfSbAnchor => 'Sidro in veriga – postopek sidranja';

  @override
  String get pdfSbRules => 'Pravila na krovu';

  @override
  String get pdfSbEmergencyContacts => 'Klici v sili in VHF 16';

  @override
  String get pdfBriefingDeclaration =>
      'Vsi člani posadke so bili seznanjeni z varnostnimi pravili, so jih razumeli in to potrjujejo s podpisom.';

  @override
  String get pdfHashCoverage =>
      'Izvleček zajema ime plovbe, plovilo, posadko in vsak zapis (čas UTC, GPS, hitrost, kurz). Vsaka sprememba podatkov spremeni izvleček.';

  @override
  String get pdfForCharterCompany => 'Za čarter podjetje';

  @override
  String get dutyRoster => 'Posadka na straži';

  @override
  String get dutyStartAction => 'Prevzemi stražo';

  @override
  String get dutyEndAction => 'Končaj';

  @override
  String get dutyStartTitle => 'Kdo prevzema stražo?';

  @override
  String get dutyRunningChip => 'NA STRAŽI';

  @override
  String dutySince(String time) {
    return 'od $time';
  }

  @override
  String dutyElapsed(int h, int m) {
    return '$h h $m min';
  }

  @override
  String get dutyNobodyOnDuty => 'Nihče ni na straži';

  @override
  String get dutyInspectionView => 'Prikaži za inšpekcijo';

  @override
  String get dutyRosterHistory => 'Razpored straž';

  @override
  String get dutyAddRetrospective => 'Dodaj pretekso stražo';

  @override
  String get dutyEditTitle => 'Uredi stražo';

  @override
  String get dutyDeleteTitle => 'Izbrišem stražo?';

  @override
  String dutyDeleteConfirm(String name) {
    return 'Zapis o straži za $name bo izbrisan.';
  }

  @override
  String get dutyNoCrewDefined => 'Za to plovbo ni določena posadka';

  @override
  String get dutyDefineCrew => 'Dodaj posadko';

  @override
  String get dutyErrorEndBeforeStart => 'Konec mora biti za začetkom.';

  @override
  String dutyErrorOverlap(String name) {
    return '$name je v tem času že na straži.';
  }

  @override
  String get dutyErrorFutureStart => 'Začetek ne more biti v prihodnosti.';

  @override
  String get dutyNoteLabel => 'Opomba';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'Na straži že $hours h — je bila morda pozabljena?';
  }

  @override
  String get dutyFrom => 'Od';

  @override
  String get dutyTo => 'Do';

  @override
  String get dutyToOngoing => '— še na straži';

  @override
  String get dutySelectPerson => 'Izberite člana posadke';

  @override
  String get dutyNoRecords => 'Zaenkrat ni zabeleženih straž';

  @override
  String get logDutySection => 'Posadka na straži';

  @override
  String get logDutyStillRunning => 'poteka';

  @override
  String get autoEntryNote => 'Samodejni zapis';

  @override
  String get logEventSailChange => 'Sprememba jader';

  @override
  String get logEventCourseChange => 'Sprememba kurza';

  @override
  String get pdfNightShort => 'noč';

  @override
  String nightSailingHours(String hours) {
    return 'Nočna plovba $hours h';
  }

  @override
  String logEventSailChangeTo(String direction) {
    return 'Sprememba jader: $direction';
  }

  @override
  String get logEventHelmsmanChange => 'Zamenjava krmarja';

  @override
  String logEventHelmsmanChangeTo(String name) {
    return 'Krmar: $name';
  }

  @override
  String get crewListEmpty => 'Plovba nima vnesene posadke.';

  @override
  String get logEventAnchorDropped => 'Sidro spuščeno';

  @override
  String get logEventAnchorRaised => 'Sidro dvignjeno';

  @override
  String get logEventDriftOut => 'Orjenje – presežen obseg';

  @override
  String get logEventDriftIn => 'Orjenje – plovilo se je vrnilo';

  @override
  String logEventAutopilotOn(String mode) {
    return 'Avtopilot VKLOP - $mode';
  }

  @override
  String get logEventAutopilotOff => 'Avtopilot IZKLOP';

  @override
  String get logEventEngineStart => 'Motor zagnan';

  @override
  String get logEventEngineStop => 'Motor ustavljen';

  @override
  String get updateDownloaded => 'Posodobitev je prenesena';

  @override
  String get updateRestart => 'Znova zaženi';

  @override
  String get autopilotLabel => 'Avtopilot';

  @override
  String get autopilotModeAuto => 'Auto';

  @override
  String get autopilotModeWind => 'Veter';

  @override
  String get autopilotModeTrack => 'Proga';

  @override
  String get autopilotModeHeading => 'Smer';

  @override
  String get autopilotModeRudder => 'Krmilo';

  @override
  String get autopilotModeStandby => 'Standby';

  @override
  String logEventDutyStart(String name) {
    return 'Prevzel stražo: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Predal stražo: $name';
  }

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Klici v sili';

  @override
  String get backToToc => 'Nazaj na kazalo';

  @override
  String get briefingComplete => 'Brifing končan';

  @override
  String get updateByPosition => 'Posodobi glede na lokacijo';

  @override
  String get detectedByGps => 'zaznano prek GPS';

  @override
  String get locationUnavailable =>
      '📍 Lokacija ni na voljo – prikazani so globalni stiki';

  @override
  String get detectingLocation => 'Zaznavanje lokacije...';

  @override
  String get tapToCall => 'Tapnite za klic';

  @override
  String cannotCall(String name) {
    return 'Ni mogoče poklicati: $name';
  }

  @override
  String get vhfChannel16 =>
      'Kanal VHF 16 – uporabite ladijsko radijsko postajo';

  @override
  String get hmbHandbook => 'Priročnik HMB';

  @override
  String get checkInLabel => 'Check-in (prevzem plovila)';

  @override
  String get checkOutLabel => 'Check-out (predaja plovila)';

  @override
  String get charterCheckCard => 'Plovba';

  @override
  String get weatherTitle => 'Vreme in morje';

  @override
  String get updateForecast => 'Posodobi napoved';

  @override
  String get gpsNotAvailableTracking => 'GPS ni na voljo – vklopite sledenje';

  @override
  String get downloadingForecast => 'Prenašanje napovedi...';

  @override
  String get loadingForecast => 'Nalaganje napovedi...';

  @override
  String get noConnection => 'Povezava ni na voljo';

  @override
  String get pressRefreshWhenOnline => 'Pritisnite osveži, ko ste povezani';

  @override
  String get noWeatherData => 'Ni vremenskih podatkov';

  @override
  String get forecastAutoDownload =>
      'Napoved se bo prenesla samodejno ob začetku sledenja ali pritisnite Osveži.';

  @override
  String get enableGpsFirst => 'Najprej vklopite GPS / sledenje';

  @override
  String get downloadForecast => 'Prenesi napoved';

  @override
  String downloadError(String error) {
    return 'Napaka pri prenosu: $error';
  }

  @override
  String get errorNoInternetOnThisNetwork =>
      'Ta Wi-Fi nima interneta — pogosto pri Wi-Fi ladijskih instrumentov. Prikazana je zadnja shranjena napoved; za novo uporabi mobilne podatke.';

  @override
  String get errorNoConnection =>
      'Ni povezave. Prikazana je zadnja shranjena napoved.';

  @override
  String get liveInstrumentData => 'Podatki ladijskih instrumentov v živo';

  @override
  String get windRelative => 'Veter (rel.)';

  @override
  String get windTrue => 'Veter (pravi)';

  @override
  String get depthLabel => 'Globina';

  @override
  String get waterTempLabel => 'Temp. morja';

  @override
  String get courseTrue => 'Kurz (pravi)';

  @override
  String get courseMag => 'Kurz (magn.)';

  @override
  String get engineLabel => 'Motor';

  @override
  String get wavesLabel => 'Valovi';

  @override
  String get pressureLabel => 'Zračni tlak';

  @override
  String get airTempLabel => 'Zrak';

  @override
  String get waterLabel => 'Morje';

  @override
  String get wind24h => 'Veter – 3 dni';

  @override
  String get waves24h => 'Valovi – 3 dni';

  @override
  String get hourlyForecast => 'Tridnevna napoved';

  @override
  String get dailyForecast => 'Dnevna temperatura';

  @override
  String get timeCol => 'Čas';

  @override
  String get windCol => 'Veter';

  @override
  String get wavesCol => 'Valovi';

  @override
  String get rainCol => 'Dež';

  @override
  String get beaufort0 => 'Zatišje';

  @override
  String get beaufort1 => 'Lahen vetrič';

  @override
  String get beaufort2 => 'Vetrič';

  @override
  String get beaufort3 => 'Šibek veter';

  @override
  String get beaufort4 => 'Zmeren veter';

  @override
  String get beaufort5 => 'Zmerno močan veter';

  @override
  String get beaufort6 => 'Močan veter';

  @override
  String get beaufort7 => 'Zelo močan veter';

  @override
  String get beaufort8 => 'Viharni veter';

  @override
  String get beaufort9 => 'Močan viharni veter';

  @override
  String get beaufort10 => 'Orkanski veter';

  @override
  String get beaufort11 => 'Silovit orkanski veter';

  @override
  String get beaufort12 => 'Orkan';

  @override
  String get sunAndMoonCard => 'Sonce in Luna';

  @override
  String get sunriseLabel => 'Sončni vzhod';

  @override
  String get sunsetLabel => 'Sončni zahod';

  @override
  String get moonPhaseLabel => 'Lunina mena';

  @override
  String get moonIlluminationLabel => 'Osvetljeno';

  @override
  String get moonPhaseNew => 'Mlaj';

  @override
  String get moonPhaseWaxingCrescent => 'Mlad srp';

  @override
  String get moonPhaseFirstQuarter => 'Prvi krajec';

  @override
  String get moonPhaseWaxingGibbous => 'Rastoča Luna';

  @override
  String get moonPhaseFull => 'Ščip';

  @override
  String get moonPhaseWaningGibbous => 'Pojemajoča Luna';

  @override
  String get moonPhaseLastQuarter => 'Zadnji krajec';

  @override
  String get moonPhaseWaningCrescent => 'Star srp';

  @override
  String get noSunMoonGps => 'Za sončni vzhod/zahod je potreben položaj GPS';

  @override
  String get oceanCurrentsTitle => 'Oceanski tokovi';

  @override
  String get oceanCurrentsTooltip => 'Oceanski tokovi';

  @override
  String get oceanCurrentsDisclaimer =>
      'Zgolj referenčni podatki (značilna smer/hitrost iz pilotskih kart) — niso za natančno navigacijo; tokovi se sezonsko spreminjajo.';

  @override
  String get tideCardTitle => 'Plima in oseka';

  @override
  String get nextHighTideLabel => 'Naslednja plima';

  @override
  String get nextLowTideLabel => 'Naslednja oseka';

  @override
  String get noTideData => 'Še ni podatkov o plimi';

  @override
  String get downloadTides => 'Prenesi napoved plime';

  @override
  String get downloadingTides => 'Prenašanje napovedi plime...';

  @override
  String get tideMslWarning =>
      'Višine so nad srednjo gladino morja, ne nad hidrografsko ničlo — nikoli jih ne uporabljajte za globino pod gredljem.';

  @override
  String get tideNoCoverage =>
      'Za ta položaj ni podatkov o plimi — je zunaj območja pomorske napovedi.';

  @override
  String get tideDownloadFailed =>
      'Napovedi plime ni bilo mogoče prenesti. Preverite povezavo in poskusite znova.';

  @override
  String get tideForecastExpired => 'Shranjena napoved plime je potekla.';

  @override
  String tideForecastFarAway(int km) {
    return 'Napoved je bila prenesena $km km od tu — prenesite jo znova za ta položaj.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Preneseno $when — prenesite znova za najnovejšo napoved.';
  }

  @override
  String get oceanCurrentCardTitle => 'Morski tok';

  @override
  String get oceanCurrentSetsToward => 'Teče proti (hitrost v vozlih)';

  @override
  String get oceanCurrentNoCoverage => 'Za ta položaj ni podatkov o toku.';

  @override
  String get oceanCurrentUnavailable =>
      'Napoved toka ni na voljo — preverite povezavo.';

  @override
  String get tideOtherArea => 'Napoved za drugo območje';

  @override
  String get tideAreaSearchLabel => 'Pristanišče, mesto ali zaliv';

  @override
  String get tideAreaSearchHint => 'npr. Koper';

  @override
  String get tideAreaNoResults =>
      'Nič ni bilo najdeno — poskusite z drugim imenom.';

  @override
  String tideForecastForArea(String place) {
    return 'Napoved za $place';
  }

  @override
  String get settingsTitle => 'Nastavitve';

  @override
  String get measurementUnits => 'Merske enote';

  @override
  String get temperature => 'Temperatura';

  @override
  String get depthWaves => 'Globina / valovi';

  @override
  String get wind => 'Veter';

  @override
  String get language => 'Jezik';

  @override
  String get appLanguage => 'Jezik aplikacije';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get displaySettings => 'Prikaz';

  @override
  String get nightMode => 'Nočni način';

  @override
  String get nightModeDesc => 'Rdeči filter za ohranjanje nočnega vida';

  @override
  String get aboutApp => 'O aplikaciji';

  @override
  String get backupSection => 'Varnostna kopija podatkov';

  @override
  String get exportBackup => 'Izvozi varnostno kopijo';

  @override
  String get exportBackupDesc =>
      'Shrani celoten dnevnik (plovbe, zapise, nastavitve) v eno datoteko';

  @override
  String get restoreBackup => 'Obnovi iz varnostne kopije';

  @override
  String get restoreBackupDesc =>
      'Zamenja trenutne podatke z vsebino izbrane datoteke varnostne kopije';

  @override
  String get restoreBlockedTrackingTitle => 'Sledenje GPS poteka';

  @override
  String get restoreBlockedTrackingBody =>
      'Pred obnovitvijo varnostne kopije ustavite aktivno sledenje plovbi.';

  @override
  String get restoreSchemaTooNewTitle =>
      'Varnostna kopija je iz novejše različice';

  @override
  String get restoreSchemaTooNewBody =>
      'Ta varnostna kopija je bila ustvarjena z novejšo različico aplikacije od trenutno nameščene. Najprej posodobite aplikacijo.';

  @override
  String get restoreConfirmTitle => 'Obnovim iz varnostne kopije?';

  @override
  String get restoreConfirmBody =>
      'Trenutni podatki bodo zamenjani z vsebino varnostne kopije. Pred tem bo samodejno ustvarjena varnostna kopija trenutnega stanja.';

  @override
  String get restoreSuccess =>
      'Podatki so bili uspešno obnovljeni iz varnostne kopije.';

  @override
  String get restoreInvalidFile =>
      'Izbrana datoteka ni veljavna varnostna kopija HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Knjiga milj';

  @override
  String get totalNm => 'Skupaj NM';

  @override
  String get daysAtSea => 'Dni na morju';

  @override
  String get voyageCount => 'Število plovb';

  @override
  String get nightHoursLabel => 'Nočne ure';

  @override
  String get byYear => 'Po letu';

  @override
  String get byVessel => 'Po plovilu';

  @override
  String get addHistoricalVoyage => 'Dodaj preteklo plovbo';

  @override
  String get editHistoricalVoyage => 'Uredi preteklo plovbo';

  @override
  String get deleteHistoricalVoyageConfirm => 'Izbrišem to preteklo plovbo?';

  @override
  String get manualEntryExplanation => '* ročni vnos (vnesen ročno)';

  @override
  String get roleLabel => 'Vloga na krovu';

  @override
  String get roleSkipper => 'Skiper';

  @override
  String get roleCoSkipper => 'Soskiper';

  @override
  String get roleCrew => 'Posadka';

  @override
  String get areaLabel => 'Območje / pot';

  @override
  String get distanceNmLabel => 'Razdalja (NM)';

  @override
  String get daysCountLabel => 'Število dni';

  @override
  String get milesCertificateTitle => 'Potrdilo o preplutih miljah';

  @override
  String get logbookRecordTitle => 'Zapis v dnevniku';

  @override
  String get logbookTrackedHint =>
      'Datumi, milje, območje in vloga se izračunajo iz sledenja/uvoza.';

  @override
  String get vesselFlag => 'Zastava vpisa';

  @override
  String get captainFirstName => 'Ime skiperja';

  @override
  String get captainLastName => 'Priimek skiperja';

  @override
  String get captainQualification => 'Najvišja pridobljena usposobljenost';

  @override
  String get logbookSignatureSection => 'Podpis, ki potrjuje milje';

  @override
  String get addSignature => 'Dodaj podpis';

  @override
  String get filterAllYears => 'Vsa leta';

  @override
  String get filterCustomRange => 'Poljubno obdobje';

  @override
  String get handoverMenuTitle => 'Zapisnik o primopredaji';

  @override
  String get checkInProtocol => 'Zapisnik o prevzemu';

  @override
  String get checkOutProtocol => 'Zapisnik o predaji';

  @override
  String get nextStepLabel => 'Naslednji korak';

  @override
  String get readyToTrackHint => 'Pripravljeno za začetek sledenja';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Korak $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Varnostni\nbrifing';

  @override
  String get handoverChecklistShort => 'Seznam\nprimopredaje';

  @override
  String get safetyBriefingRefTitle => 'Varnostni brifing';

  @override
  String get handoverChecklistRefTitle => 'Seznam primopredaje';

  @override
  String get handoverDateTime => 'Datum in čas';

  @override
  String get handoverLocation => 'Kraj (marina)';

  @override
  String get checklistItemOk => 'V redu';

  @override
  String get checklistItemDamaged => 'Poškodovano';

  @override
  String get checklistItemMissing => 'Manjka';

  @override
  String get damagePosition => 'Položaj na plovilu';

  @override
  String get newDamageBadge => 'NOVA POŠKODBA';

  @override
  String get companySignatureSection => 'Podpis predstavnika čarter podjetja';

  @override
  String get companyRepName => 'Ime predstavnika';

  @override
  String get companyNameLabel => 'Naziv podjetja';

  @override
  String get protocolClosedNotice =>
      'Zapisnik je zaključen (obe strani sta podpisali) – samo za branje.';

  @override
  String get handoverCertTitle => 'Zapisnik o primopredaji plovila';

  @override
  String get itemSails => 'Jadra';

  @override
  String get itemRigging => 'Oprema jadrovja';

  @override
  String get itemAnchorChain => 'Sidro in veriga';

  @override
  String get itemNavInstruments => 'Navigacijski instrumenti';

  @override
  String get itemLifeJackets => 'Rešilni jopiči';

  @override
  String get itemRaft => 'Rešilni splav';

  @override
  String get itemFirstAidKit => 'Komplet prve pomoči';

  @override
  String get itemDinghyMotor => 'Gumenjak in izvenkrmni motor';

  @override
  String get itemLights => 'Luči';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Dodatne opombe';

  @override
  String get gpxImportTitle => 'Uvoz GPX';

  @override
  String get gpxImportPickFile => 'Izberi datoteko GPX';

  @override
  String get gpxTracksFound => 'Najdenih sledi';

  @override
  String get gpxWaypointsFound => 'Najdenih točk poti';

  @override
  String get gpxAssignTarget => 'Dodeli plovbi';

  @override
  String get gpxNewVoyage => 'Nova plovba';

  @override
  String get gpxImportButton => 'Uvozi';

  @override
  String get gpxImportSuccess => 'GPX je bil uspešno uvožen.';

  @override
  String get connectionConnected => 'Povezano';

  @override
  String get connectionConnecting => 'Povezovanje...';

  @override
  String get connectionError => 'Napaka povezave';

  @override
  String get connectionDisconnected =>
      'Prekinjeno (uporablja se GPS telefona / napoved)';

  @override
  String get ipAddressLabel => 'Naslov IP prehoda';

  @override
  String get portLabel => 'Vrata';

  @override
  String get autoConnectLabel => 'Samodejno povezovanje ob zagonu';

  @override
  String get disconnect => 'Prekini';

  @override
  String get connect => 'Poveži';

  @override
  String get gatewayHint =>
      'Povežite telefon z omrežjem Raymarine WiFi (npr. WiFi-1, RayNet). IP, ki ga je treba vnesti, NI IP, prikazan v nastavitvah Raymarine — to je IP prehoda tega omrežja WiFi. Najdete ga na telefonu: Nastavitve → WiFi → podrobnosti omrežja → Prehod. Vrata 2000 (TCP) so standardna. Brez povezave aplikacija samodejno uporablja GPS telefona.';

  @override
  String connectedToHost(String host, int port) {
    return 'Povezano z $host:$port';
  }

  @override
  String get enterIpAddress => 'Vnesite naslov IP prehoda';

  @override
  String connectionFailed(String error) {
    return 'Povezava ni uspela: $error';
  }

  @override
  String get liveWind => 'Veter';

  @override
  String get liveDepth => 'Globina';

  @override
  String get liveWaterTemp => 'Temp. morja';

  @override
  String get liveCompass => 'Kompas';

  @override
  String get liveEngine => 'Motor';

  @override
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Vrata za poslušanje';

  @override
  String get startListening => 'Zaženi';

  @override
  String get stopListening => 'Ustavi';

  @override
  String connectionListening(String port) {
    return 'Poslušam UDP na vratih $port';
  }

  @override
  String udpHint(String port) {
    return 'Nastavite simulator/prehod, da pošilja UDP na IP tega telefona, vrata $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Poslušam na vratih UDP $port';
  }

  @override
  String get dayNotFound => 'Dan ni bil najden';

  @override
  String get saved => 'Shranjeno';

  @override
  String get trackingThisDay => 'Sledenje poteka za ta dan';

  @override
  String get trackingOtherDay => 'Sledenje poteka za drug dan';

  @override
  String recordCount(int n) {
    return '$n zapisov';
  }

  @override
  String get addManual => 'Dodaj ročno';

  @override
  String get noEntries => 'Ni zapisov';

  @override
  String get entriesAutoAdded => 'Zapisi se med sledenjem dodajajo samodejno';

  @override
  String get deleteEntryTitle => 'Izbrišem zapis?';

  @override
  String get autoRecord => 'Samodejni zapis';

  @override
  String get routeSection => 'Pot';

  @override
  String get fromPort => 'Od';

  @override
  String get toPort => 'Do';

  @override
  String get distance => 'Razdalja';

  @override
  String get vessel => 'Plovilo';

  @override
  String get weatherSection => 'Vreme';

  @override
  String get morning => 'Jutro';

  @override
  String get noon => 'Poldne';

  @override
  String get evening => 'Večer';

  @override
  String get windDir => 'Smer vetra';

  @override
  String get seaState => 'Stanje morja';

  @override
  String get waveHeight => 'Višina valov';

  @override
  String get dailyNote => 'Dnevni zapis';

  @override
  String get dailyNoteHint => 'Opis plovbe, poudarki, dogodki dneva...';

  @override
  String get seaCalm => 'Mirno';

  @override
  String get seaLight => 'Rahlo valovito';

  @override
  String get seaModerate => 'Zmerno valovito';

  @override
  String get seaRough => 'Razburkano';

  @override
  String get seaStormy => 'Viharno';

  @override
  String get editEntry => 'Uredi zapis';

  @override
  String get newEntry => 'Nov zapis';

  @override
  String get sailMode => 'Način plovbe';

  @override
  String get sailMain => 'Glavno jadro';

  @override
  String get sailDirection => 'Kurz glede na veter';

  @override
  String get pointOfSailCloseHauled => 'Ostri bidevind';

  @override
  String get pointOfSailCloseReach => 'Bidevind';

  @override
  String get pointOfSailBeamReach => 'Polveter';

  @override
  String get pointOfSailBroadReach => 'Bakštag';

  @override
  String get pointOfSailRunning => 'Fordevind';

  @override
  String get tackPort => 'Levi bok';

  @override
  String get tackStarboard => 'Desni bok';

  @override
  String get navigationSection => 'Navigacija';

  @override
  String get latitude => 'Zemljepisna širina';

  @override
  String get longitude => 'Zemljepisna dolžina';

  @override
  String get weatherSeaSection => 'Vreme in morje';

  @override
  String get mapStationWindLayer => 'Postaje – izmerjeno';

  @override
  String get windGust => 'Sunek';

  @override
  String get radarTitle => 'Radar padavin';

  @override
  String get radarRefresh => 'Osveži sliko';

  @override
  String get radarUnavailable =>
      'Radarske slike ni bilo mogoče naložiti. Poskusi znova, ko boš imel signal.';

  @override
  String get radarSourceDhmz => 'Vir: DHMZ – meteo.hr';

  @override
  String get weatherSourceInstruments => 'Izmerjeno z ladijskimi instrumenti';

  @override
  String get pdfWeatherSourceInstruments => 'Instrumenti';

  @override
  String pdfWeatherSourceStation(String name) {
    return 'Postaja $name';
  }

  @override
  String pdfWeatherSourceStationAt(String name, String km) {
    return '$name, $km km';
  }

  @override
  String get pdfWeatherSourceStationUnknown => 'Meteo postaja';

  @override
  String get pdfWeatherSourceModel => 'Model';

  @override
  String weatherSourceStation(String name) {
    return 'Izmerjeno na postaji $name';
  }

  @override
  String weatherSourceStationAt(String name, String km) {
    return 'Izmerjeno na postaji $name, $km km daleč';
  }

  @override
  String get weatherSourceStationUnknown => 'Izmerjeno na meteorološki postaji';

  @override
  String get weatherSourceModel => 'Napovedni model, ne meritev';

  @override
  String get windSpeed => 'Veter';

  @override
  String get windDirection => 'Smer';

  @override
  String get waveHeight2 => 'Višina valov';

  @override
  String get engineSection => 'Motor in rezervoarji';

  @override
  String get engineHours => 'Ure motorja';

  @override
  String get fuel => 'Gorivo';

  @override
  String get fuelLevel => 'Raven goriva';

  @override
  String get waterLevel => 'Raven vode';

  @override
  String get helmsmanLabel => 'Krmar';

  @override
  String get noteSection => 'Opomba';

  @override
  String get noteHint => 'Razmere na plovbi, dogodki, menjava posadke...';

  @override
  String get quickPhotoLogTitle => 'Hitri zapis v dnevnik';

  @override
  String get quickPhotoNoteHint => 'Kaj je to? (neobvezno)';

  @override
  String get exportDayTitle => 'Izvoz dneva';

  @override
  String get exportCharterTitle => 'Izvoz plovbe';

  @override
  String get loadingData => 'Nalaganje podatkov...';

  @override
  String get mapsReady => 'Zemljevidi so pripravljeni – lahko izvozite';

  @override
  String generatingMaps(int current, int total) {
    return 'Ustvarjanje predogledov zemljevidov ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Izvozi dan';

  @override
  String get exportCharterBtn => 'Izvozi plovbo';

  @override
  String get entriesLabel => 'Zapisi';

  @override
  String get routePoints => 'Točke poti';

  @override
  String get anchorDriftTitle => '⚓ SIDRO ORJE!';

  @override
  String get anchorDriftContent =>
      'Plovilo je preseglo obseg sidranja.\nTakoj preverite položaj!';

  @override
  String get cancelAnchor => 'Prekliči sidro';

  @override
  String get stopAlarm => 'Ustavi alarm';

  @override
  String get briefingItem1 => 'Rešilni jopiči – lokacija in uporaba';

  @override
  String get briefingItem2 => 'Rešilni obroč in postopek MOB';

  @override
  String get briefingItem3 => 'Signalne rakete – vrste in uporaba';

  @override
  String get briefingItem4 => 'EPIRB / PLB – aktivacija';

  @override
  String get briefingItem5 => 'Radio VHF – kanal 16, postopek Mayday';

  @override
  String get briefingItem6 => 'Gasilni aparat – lokacija in uporaba';

  @override
  String get briefingItem7 => 'Komplet prve pomoči – lokacija';

  @override
  String get briefingItem8 => 'Zasilna zaustavitev motorja';

  @override
  String get briefingItem9 => 'Puščanje – voda, plin';

  @override
  String get briefingItem10 => 'Sidro in veriga – postopek sidranja';

  @override
  String get briefingItem11 => 'Pravila na krovu';

  @override
  String get briefingItem12 => 'Klici v sili in VHF 16';

  @override
  String get checkInItem1 => 'Dokumenti plovila (vpis, zavarovanje)';

  @override
  String get checkInItem2 => 'Varnostna oprema – popolna';

  @override
  String get checkInItem3 => 'Zaloge goriva';

  @override
  String get checkInItem4 => 'Zaloge vode';

  @override
  String get checkInItem5 => 'Sidro in veriga – pregled';

  @override
  String get checkInItem6 => 'Motor – preizkusni zagon';

  @override
  String get checkInItem7 => 'Navigacijski instrumenti';

  @override
  String get checkInItem8 => 'Oprema jadrovja – vrvi in jadra';

  @override
  String get checkInItem9 => 'Kuhinja – plin, štedilnik';

  @override
  String get checkInItem10 => 'Stranišče – delovanje';

  @override
  String get checkInItem11 => 'Obstoječe poškodbe – fotodokumentacija';

  @override
  String get checkOutItem1 => 'Plovilo očiščeno – zunanjost';

  @override
  String get checkOutItem2 => 'Plovilo očiščeno – notranjost';

  @override
  String get checkOutItem3 => 'Gorivo dopolnjeno';

  @override
  String get checkOutItem4 => 'Voda dopolnjena';

  @override
  String get checkOutItem5 => 'Smeti odstranjene';

  @override
  String get checkOutItem6 => 'Poškodbe prijavljene';

  @override
  String get checkOutItem7 => 'Ključi predani';

  @override
  String get gearListShort => 'Osebna\noprema';

  @override
  String get colregRules => 'Pravila\nCOLREG';

  @override
  String get checkInShort => 'Check-in\nPrevzem';

  @override
  String get checkOutShort => 'Check-out\nPredaja';

  @override
  String get appTagline => 'Vaš zanesljiv ladijski dnevnik';

  @override
  String exportSavedMsg(String path) {
    return 'Shranjeno: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Shranjeno: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Napaka pri izvozu: $error';
  }

  @override
  String get generatingPdf => 'Ustvarjanje PDF...';

  @override
  String get colregTitle => 'COLREG – Pravila za izogibanje trčenju na morju';

  @override
  String get tableOfContents => 'KAZALO';

  @override
  String get inThisChapter => 'V tem poglavju:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Pravilo $n';
  }

  @override
  String get resetChecklistTitle => 'Ponastavim kontrolni seznam?';

  @override
  String get resetChecklistContent => 'Vse kljukice bodo izbrisane.';

  @override
  String get reset => 'Ponastavi';

  @override
  String get checkInReceivingTitle => 'Check-in – Prevzem plovila';

  @override
  String get checkOutHandoverTitle => 'Check-out – Predaja plovila';

  @override
  String get checkInCompletedMsg => 'Plovilo prevzeto – vse preverjeno ✓';

  @override
  String get checkOutCompletedMsg => 'Plovilo vrnjeno – vse v redu ✓';

  @override
  String get briefingDoneMsg => 'Brifing končan – posadka obveščena';

  @override
  String get sectionBriefed => 'Razdelek opravljen ✓';

  @override
  String get confirmSection => 'Potrdi razdelek';

  @override
  String get gearListTitle => 'Osebna oprema';

  @override
  String get newCategory => 'Nova kategorija';

  @override
  String get add => 'Dodaj';

  @override
  String get deleteItemTitle => 'Izbrišem postavko?';

  @override
  String get allPackedMsg => 'Vse spakirano, pripravljeni na izplutje! 🎉';

  @override
  String get addItemLabel => 'Dodaj postavko';

  @override
  String addToCategoryTitle(String category) {
    return 'Dodaj v: $category';
  }

  @override
  String get newItemHint => 'Nova postavka...';

  @override
  String get addWaypoint => 'Dodaj točko poti';

  @override
  String get editWaypoint => 'Uredi točko poti';

  @override
  String get deleteWaypointTitle => 'Izbrisati točko poti?';

  @override
  String deleteWaypointNavActive(String name) {
    return 'Navigacija do $name je aktivna. Z izbrisom točke se bo izklopila.';
  }

  @override
  String get waypointNameLabel => 'Ime';

  @override
  String get skipperSignature => 'Podpis skiperja';

  @override
  String get skipperNameLabel => 'Ime skiperja';

  @override
  String get signWithFinger => 'Podpišite se s prstom';

  @override
  String get clear => 'Počisti';

  @override
  String get signAndExport => 'Podpiši in izvozi';

  @override
  String get pleaseSign => 'Pred izvozom se podpišite';

  @override
  String get generatingPdfPreview => 'Ustvarjanje predogleda PDF...';

  @override
  String generationError(String error) {
    return 'Napaka pri ustvarjanju: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Shranjevanje in ustvarjanje GPX...';

  @override
  String get editCharter => 'Uredi plovbo';

  @override
  String get basicInfo => 'Osnovni podatki';

  @override
  String get voyageNameRequired => 'Ime plovbe *';

  @override
  String get dateFrom => 'Datum od';

  @override
  String get dateTo => 'Datum do';

  @override
  String get vesselName => 'Ime plovila';

  @override
  String get vesselType => 'Vrsta plovila';

  @override
  String get homePort => 'Matično pristanišče';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Klicni znak';

  @override
  String get vesselLengthM => 'Dolžina (m)';

  @override
  String get vesselBeamM => 'Širina (m)';

  @override
  String get vesselDraftM => 'Ugrez (m)';

  @override
  String get selectExistingVoyage => 'Izberi obstoječo plovbo';

  @override
  String get newVoyageForm => 'Nova plovba';

  @override
  String get fillFormAndBriefing =>
      'Izpolnite obrazec in podpišite varnostni brifing';

  @override
  String get notesLabel => 'Zapiski';

  @override
  String get statusLabel => 'Stanje';

  @override
  String get safetyBriefingDoneLabel => 'Varnostni brifing končan';

  @override
  String get checkInDoneLabel => 'Check-in končan';

  @override
  String get checkOutDoneLabel => 'Check-out končan';

  @override
  String get enterVoyageName => 'Vnesite ime plovbe';

  @override
  String daysCount(int n) {
    return '$n dni';
  }

  @override
  String get selectTargetWaypoint => 'Izberite ciljno točko poti';

  @override
  String get noWaypoints => 'Ni točk poti.';

  @override
  String get goToMap => 'Pojdi na zemljevid';

  @override
  String get noTarget => 'Ni cilja';

  @override
  String get selectWaypointHint => 'Navigiraj do točke poti';

  @override
  String get sessionStats => 'Statistika plovbe';

  @override
  String get maxSpeed => 'Najv. hitrost';

  @override
  String get avgSpeed => 'Povpr. hitrost';

  @override
  String get sailingTime => 'Čas plovbe';

  @override
  String get gpsData => 'Podatki GPS';

  @override
  String get gpsPosition => 'Položaj';

  @override
  String get courseCog => 'Kurz (COG)';

  @override
  String get altitudeLabel => 'Nadmorska višina';

  @override
  String get dscProcedure => 'POSTOPEK DSC';

  @override
  String get voiceScript => 'GLASOVNA PREDLOGA';

  @override
  String get dscWarningUseOnly => '⚠️ UPORABITE SAMO V PRIMERU';

  @override
  String get dscWarningDanger => 'RESNE IN NEPOSREDNE NEVARNOSTI';

  @override
  String get dscWarningTypes => 'Požar · Potapljanje · Človek v morju';

  @override
  String get dscProcedureSubtitle =>
      'Ta postopek hranite ob radijski postaji VHF DSC';

  @override
  String get fillBeforeSailing => 'Izpolnite pred izplutjem:';

  @override
  String get copyTooltip => 'Kopiraj';

  @override
  String get scriptCopied => 'Predloga kopirana';

  @override
  String get sendOnCh16 =>
      '📻 Oddajajte na kanalu 16 · Polna moč · Ponavljajte vsaki 2 minuti, če ni odziva';

  @override
  String get enterAbove => '[vnesite v polje zgoraj]';

  @override
  String get distressNature => 'Vrsta nevarnosti';

  @override
  String get vesselNameLabel => 'Ime plovila';

  @override
  String get numberOfPersons => 'Število oseb';

  @override
  String get additionalInfo => 'Dodatne informacije';

  @override
  String get voiceScriptTitle => 'GLASOVNA PREDLOGA MAYDAY';

  @override
  String voiceScriptTitleFor(String type) {
    return 'GLASOVNA PREDLOGA · $type';
  }

  @override
  String get distressCallMayday => 'MAYDAY';

  @override
  String get distressCallPanPan => 'PAN PAN';

  @override
  String get distressCallSecurite => 'SÉCURITÉ';

  @override
  String get distressNoteMayday =>
      'MAYDAY: samo ob resni in neposredni nevarnosti za življenje ali plovilo. Npr. „MAYDAY, MAYDAY, MAYDAY, taking on water, sinking“ (nabiramo vodo, tonemo).';

  @override
  String get distressNotePanPan =>
      'PAN PAN: nujno sporočilo, ki neposredno ne ogroža življenja. Npr. „PAN PAN, PAN PAN, PAN PAN, engine failure, drifting toward rocks“ (okvara motorja, zanaša nas proti skalam).';

  @override
  String get distressNoteSecurite =>
      'SÉCURITÉ: varnostno sporočilo o plovbi ali vremenu za druga plovila. Npr. „SÉCURITÉ, SÉCURITÉ, SÉCURITÉ, uncharted wreck reported at position…“ (na položaju… prijavljena nevrisana razbitina).';

  @override
  String get dscStep1 => 'Prepričajte se, da je radijska postaja vklopljena.';

  @override
  String get dscStep2 => 'Odprite pokrov nad RDEČIM gumbom za klic v sili.';

  @override
  String get dscStep3 => 'Pritisnite RDEČI gumb ENKRAT in spustite.';

  @override
  String get dscStep4 =>
      'Izberite vrsto nevarnosti.\n(Požar, potapljanje, MOB itd.)\nČe preskočite, bo poslan nedoločen klic v sili.';

  @override
  String get dscStep5 =>
      'Pritisnite in DRŽITE RDEČI gumb 5 sekund, da pošljete klic.';

  @override
  String get dscStep6 =>
      'Počakajte do 15 sekund na potrditev (prikazana na zaslonu), nato pošljite glasovno sporočilo na kanalu 16 s polno močjo.';

  @override
  String get appDescription => 'Profesionalni ladijski dnevnik za jadralce.';

  @override
  String get vesselIdTitle => 'Identifikacija plovila';

  @override
  String get vesselIdHint =>
      'Klicni znak in MMSI se samodejno izpolnita v kartici Mayday.';

  @override
  String get maritimeReference => 'Pomorski priročnik';

  @override
  String get phonetic => 'Fonetična abeceda';

  @override
  String get flagAlphabet => 'Signalne zastave';

  @override
  String get dayShapes => 'Dnevni znaki';

  @override
  String get marineReferenceTile => 'Signali in abeceda';

  @override
  String get navInstruments => 'Ladijski instrumenti';

  @override
  String get enterPort => 'Vnesite pristanišče...';

  @override
  String get closeWithoutSaving => 'Zapri brez shranjevanja';

  @override
  String get saveToDevice => 'Shrani v napravo';

  @override
  String get saveAndShare => 'Shrani in deli';

  @override
  String get timestampCannotBeChanged => 'Časa zapisa ni mogoče spremeniti';

  @override
  String entriesShort(int n) {
    return '$n zapisov';
  }

  @override
  String get mainsail => 'Glavno jadro';

  @override
  String get weatherConditionTitle => 'Vremenske razmere';

  @override
  String get weatherConditionLabel => 'Stanje';

  @override
  String get wcSunny => 'Sončno';

  @override
  String get wcPartlyCloudy => 'Delno oblačno';

  @override
  String get wcOvercast => 'Oblačno';

  @override
  String get wcLightRain => 'Rahel dež';

  @override
  String get wcRain => 'Dež';

  @override
  String get wcHeavyRain => 'Močan dež';

  @override
  String get wcDrizzle => 'Rosenje';

  @override
  String get wcThunderstorm => 'Nevihte';

  @override
  String get wcIsoThunderstorm => 'Posamezne nevihte';

  @override
  String get wcHail => 'Toča';

  @override
  String get wcDust => 'Prah';

  @override
  String get wcFoggy => 'Megleno';

  @override
  String get wcWindy => 'Vetrovno';

  @override
  String get wcCold => 'Hladno';

  @override
  String get photoSection => 'Fotografija';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerija';

  @override
  String get addPhoto => 'Dodaj fotografijo';

  @override
  String get photoAddedToEntry => 'Fotografija priložena';

  @override
  String get voyageStart => 'Začetek plovbe';

  @override
  String get voyageEnd => 'Konec plovbe';

  @override
  String get onlineAccount => 'Spletni račun';

  @override
  String get onlineAccountDesc => 'Spletna sinhronizacija dnevnika — kmalu';

  @override
  String get register => 'Registracija';

  @override
  String get login => 'Prijava';

  @override
  String get logout => 'Odjava';

  @override
  String get logoutConfirm =>
      'Odjavljeni boste. Podatki, shranjeni v napravi, ostanejo.';

  @override
  String get notLoggedIn => 'Niste prijavljeni';

  @override
  String get fullName => 'Ime in priimek';

  @override
  String get password => 'Geslo';

  @override
  String get userGuide => 'Uporabniški vodnik';

  @override
  String get guideQuickStart => 'Hitri začetek – 5 korakov';

  @override
  String get guideQuickStartBody =>
      '1. Tapnite velik gumb \"Začni plovbo\" na vrhu (na Zemljevidu, v Dnevniku ali na Instrumentih) – izberite pogostost zapisov in sledenje steče, ničesar drugega ni treba izpolniti vnaprej\n2. Če imate odprto plovbo, aplikacija vpraša, ali jo želite nadaljevati ali začeti nov zapis\n3. Manjkajoče podatke (check-in, varnostni brifing, kartica plovila/posadke) izpolnite kadar koli – aplikacija vas opozarja z oznakami v Dnevniku\n4. Med dnevom dodajajte zapise: čas, položaj, opomba\n5. Ob koncu plovbe odprite Nastavitve → Izvozi PDF\n\nAplikacija deluje čez cel zaslon – povlecite z zgornjega ali spodnjega roba, da začasno prikažete sistemski vrstici telefona.';

  @override
  String get guideMapTitle => 'Zemljevid';

  @override
  String get guideMapBody =>
      'Zavihek Zemljevid prikazuje vaš trenutni položaj in sled plovbe.\n\n• Modra pika = trenutni položaj\n• Modra črta = sled, ki se trenutno beleži\n• Ikona poti – izberite katero koli plovbo ali dan za predogled sledi na zemljevidu (oranžno), brez izvoza PDF Spodaj se pojavi predvajanje: z drsnikom se premikaš skozi plovbo v času in vidiš položaj, hitrost, smer, veter in tlak v katerem koli trenutku. Črtice na drsniku so dogodki — začetek in konec plovbe, sidro, zanos, MOB.\n• Preklop med satelitskim in kartografskim prikazom\n• Pomorske oznake – vklopite navtične oznake (razbitine, plitvine, boje)\n• Globine – izobate iz EMODnet z globino v metrih. Model dna iz meritev, NI pomorska karta: za načrtovanje plovbe da, za odločitev, ali lahko prečkate, ne. Privzeto izklopljeno; ogledane ploščice se shranijo kot druge. Ko je sloj vklopljen, se z dotikom zemljevida izpiše globina v tej točki (potreben je signal).\n• Pristanišča – tapljiv sloj sidrišč, marin in pristanišč (podatki OpenStreetMap): tapnite ikono za ime, kanal VHF, telefon, spletno stran (tap takoj pokliče ali odpre stran), globino ali zmogljivost, kjer so znani; kraj shranite kot točko poti z enim tapom; sloj vključuje tudi črpalke za gorivo (oranžna črpalka)\n• Ravnilo (vijolična ikona) – tapkajte točke na zemljevidu: skupaj NM, azimut zadnjega odseka in ETA pri trenutni hitrosti; točke se pripnejo na točke poti, tako da lahko merite pot skozi svoje cilje\n• Zemljevid brez povezave (ikona prenosa) — prenese vidno območje za uporabo brez signala, od trenutne povečave tri ravni globlje. Vedno pomorske oznake; ob vklopljenem satelitu tudi posnetke in njihova krajevna imena. Poleg tega se vsaka ogledana ploščica shrani samodejno.\n• V nočnem načinu zemljevid samodejno preklopi na temne ploščice\n• Ikona sidra = položaj sidranja (samo ko je alarm sidra aktiven)\n• Ikona uvoza – naložite sledi in točke poti iz datoteke .gpx (glejte \"Uvoz GPX\")\n• Zaklep severa – dolgo pritisnite vetrovnico (zgoraj levo); zemljevid se preneha vrteti in ostane s severom navzgor. Tapnite jo kadar koli za vrnitev na sever.\n• Izbrani sloji (satelit, pomorske oznake, globine, pristanišča), sledenje GPS in zaklep severa se ohranijo med zagoni\n• Dolg pritisk na zemljevid = dodajanje točke poti (navigacijskega cilja); tapnite obstoječo točko za preimenovanje ali brisanje';

  @override
  String get guideInstrTitle => 'Ladijski instrumenti';

  @override
  String get guideInstrBody =>
      'Zavihek Instrumenti prikazuje navigacijske podatke v realnem času.\n\n• SOG – hitrost nad dnom (vozli)\n• TWS – hitrost pravega vetra\n• TWA – kot pravega vetra glede na plovilo (zeleno = desni bok, rdeče = levi bok)\n• DEPTH – globina morja (rdeče = manj kot 5 m)\n• VMG WP – hitrost proti izbrani točki poti; izberite jo na ploščici za prikaz razdalje/azimuta in puščice neposredno na vetrovnici. Navigacijo izklopite z izbiro \"Ni cilja\" na isti ploščici — izklopi jo tudi izbris točke poti na zemljevidu\n• AVTOPILOT – kaže VKLOP/IZKLOP in način krmiljenja, kadar ga instrumenti sporočajo (HTC/HTD, APB ali SeaTalk). Vsak preklop se samodejno zapiše v dnevnik, kot v letalskem dnevniku.\n\nVir podatkov: GPS telefona ali Raymarine (prehod WiFi TCP ali UDP).\nNastavitve povezave (vključno z izbiro TCP/UDP) so v Nastavitve → Instrumenti.\n\nKako se plovilo poveže: aplikacija bere podatke NMEA prek WiFi (TCP ali UDP). Lastna dostopna točka WiFi na Raymarine MFD običajno ne zadostuje — namenjena je Raymarinovim aplikacijam in praviloma ne izpostavlja surovih podatkov NMEA tretjim osebam. Potrebujete prehod NMEA-na-WiFi (npr. Digital Yacht, Yacht Devices, Actisense, Quark-elec), priključen na ladijsko vodilo, ki bodisi ustvari lastno dostopno točko bodisi oddaja NMEA v omrežje WiFi. Povežite se z WiFi tega prehoda in v Nastavitvah vnesite njegov IP in vrata (ali poskusite Samodejno zaznavanje).\n\nB&G Zeus in podobni ploterji Navico: telefon poveži na WiFi ploterja in v Nastavitvah izberi TCP. Naslov ploterja v omrežju WiFi NE deluje — strežnik NMEA teče na njegovem vmesniku Ethernet. Ta naslov najdeš v samem ploterju: Settings → Network → Diagnostics, postavka IP address (običajno v obliki 169.254.x.x). Vnesi ga skupaj z vrati 10110. Preverjeno na Zeus III s programsko opremo NOS v25.2. Vrata 2053 povezavo sprejmejo, a podatkov ne pošiljajo — to je storitev GoFree z lastnim protokolom, ne NMEA. Vklopi Samodejno poveži ob zagonu. Če nekoč preneha delovati, se je naslov morda spremenil — znova ga preberi v Diagnostics.';

  @override
  String get guideLogbookTitle => 'Dnevnik plovbe';

  @override
  String get guideLogbookBody =>
      'Dnevnik je glavni zavihek za upravljanje plovb.\n\n• Velik gumb \"Začni plovbo\" na vrhu zažene sledenje – vpraša le po pogostosti samodejnih zapisov (spremenljivi ob vsakem zagonu), brez obrazca za vnaprejšnje izpolnjevanje\n• Če je plovba že odprta, aplikacija vpraša, ali jo želite nadaljevati ali začeti nov zapis\n• Na manjkajoče podatke (check-in, varnostni brifing, kartica plovila/posadke) opozarjajo barvne oznake neposredno na kartici plovbe – tapnite oznako, da jih izpolnite\n• Vsak dan plovbe je prikazan posebej\n• Zapise lahko med dnevom dodajate ročno, vključno z urami motorja, gorivom in vodo v razdelku \"Motor in rezervoarji\"\n• Med sledenjem gumb kamere (spodaj levo) omogoča posnetek zanimive točke in shranjevanje kot hiter zapis s položajem in časom\n• Dnevnik lahko izvozite v PDF prek menija dneva\n• Ikona rokovanja v podrobnostih plovbe odpre zapisnik o primopredaji (check-in/check-out)\n• Podroben obrazec plovbe (ikona plovila v podrobnostih) beleži plovilo in njegove parametre, območje plovbe, posadko z dovoljenji skiperja ter fotografije plovila (največ 3, prenesejo se v PDF)\n• Nedokončane kartice (Varnostni brifing, check-in/out, kartica plovila) utripajo rdeče v zgornji vrstici podrobnosti plovbe, dokler niso dokončane\n• Če se aplikacija med plovbo zapre brez ustavitve sledenja (zapre jo sistem, nenamerni poteg), ob naslednjem zagonu ponudi nadaljevanje iste plovbe – vključno z razdaljo, prevoženo med tem, ko ni tekla\n• Ob prvem zagonu plovbe aplikacija opomni na nastavitve baterije – brez njih lahko sistem (zlasti Honor/Huawei) ustavi sledenje v ozadju\n• Ikona poti v glavi plovbe (poleg brifinga, protokola in kartice plovila) pokaže celotno sled plovbe na zemljevidu\n• Po plovbi lahko za vsakega člana posadke izvoziš potrdilo o preplutih miljah – dnevi na morju, dnevne in nočne milje, območje, ocena skiperja in QR za preverjanje\n• Način plovbe (motor/jadra) se prenese tudi v samodejne vpise – nastaviš ga enkrat, naslednji ga ohranijo\n• Potrdilo je dvojezično (tvoj jezik + angleščina), vsebuje dimenzije in registracijo plovila, vrsto voda (plimne/neplimne) in polje za številko potnega lista ali osebne; lahko ga deliš ali shraniš v telefon\n• Kurz glede na veter – silhueta ladje iz papirnatega dnevnika: tapni položaj na boku, s katerega piha (levi bok rdeč, desni zelen). Fordevind je spodaj, tam boka ni. Ponoven tap izbiro izbriše – ugibana vrednost je slabša od praznega polja. V PDF gre poleg pogona.\n• Med sledenjem drugi hitri gumb (ikona jadrnice, spodaj levo) zabeleži obrat ali letanje: izberi nov kurz na silhueti in zapis se shrani s položajem in časom. Naslednji samodejni zapisi ta kurz ohranijo, dokler ga spet ne spremeniš.\n• Globina s sonde se shrani k samodejnim zapisom, pri ročnem zapisu pa je vnaprej izpolnjena (potrebni so povezani instrumenti).\n• Motorne ure se računajo iz vrtljajev z instrumentov, zagon in ustavitev motorja pa se v dnevnik zapišeta sama.\n• Hitri gumb z jadrnico (spodaj levo med plovbo) zdaj zapiše tudi pogon — Motor / Glavno / Genova / Krajšanje. Naslednji samodejni zapisi ga prevzamejo, dokler ga ne spremeniš, zato stolpec Pogon v PDF ne ostane več prazen.\n• Aplikacija sama zapiše spremembo kurza: ko se smer odkloni za 30° ali več in novo smer zadrži vsaj minuto. Vijuganje na valu ali skok GPS tega ne sproži.\n• Samodejni zapisi nosijo tudi stanje neba — dopolni se iz modela za čas in položaj zapisa, tako kot veter in tlak.\n• Nočna plovba se izračuna sama, po dejanskem sončnem zahodu in vzhodu za položaj ladje. Zapis po mraku nosi luno, dan in celotna plovba pa vsoto nočnih ur, v dnevniku in v PDF.\n• Novo plovbo ustvariš z gumbom **Nova plovba** v Dnevniku — izpolniš plovilo, območje in posadko pred izplutjem, beleženje pa se nato naveže nanjo. Zagon z gumbom Start še vedno deluje.';

  @override
  String get guideMilesTitle => 'Knjiga milj';

  @override
  String get guideMilesBody =>
      'Povzetek vseh vaših plovb na enem mestu (ikona v zavihku Dnevnik).\n\n• Skupaj navtičnih milj, dni na morju, število plovb in nočne ure\n• Razčlenitev po letu in po plovilu\n• Filter po letu\n• Tapnite plovbo (vključno s sledeno/uvoženo), da izpolnite njen zapis v dnevniku – pot, zastava plovila, ime in usposobljenost poveljnika, podpis, ki potrjuje milje\n• Gumb + – dodajte preteklo plovbo iz časa pred uporabo aplikacije (v celoti se šteje v povzetke, na seznamu je označena z zvezdico)\n• Izvoz PDF potrdila o preplutih miljah s prostorom za podpis\n• Potrdilo o miljah se izda prek obrazca (ikona PDF zgoraj): zase ali za člana posadke, z imenom prejemnika, imenom in kvalifikacijo izdajatelja (predizpolnjeno iz profila skiperja) in seznamom plovb s potrditvenimi polji. Dokument nosi plovilo, vodjo plovbe, območje, plimske ali neplimske vode in vlogo, v kateri si plul, ter razdelitev milj po vlogi. Pri plovbah, kjer nisi bil vodja, ostane prostor za njegov podpis z imenom. Potrdilo zase nosi tudi skiperski povzetek. Shrani se tudi v mapo aplikacije, ne le prek sistemskega pogovornega okna.';

  @override
  String get guideHandoverTitle =>
      'Zapisnik o primopredaji (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Uradni zapis o prevzemu in vrnitvi plovila na čarterju – ikona rokovanja v podrobnostih plovbe.\n\n• Kontrolni seznam opreme (jadra, oprema jadrovja, sidro, navigacija, rešilni jopiči, splav, komplet prve pomoči, gumenjak, luči, bimini...) – v redu / poškodovano / manjka, z opombo, položajem na krovu in fotografijo\n• Stanje goriva, vode in ur motorja\n• Podpis skiperja in predstavnika čarter podjetja\n• Zapisnik postane samo za branje, ko podpišeta obe strani\n• Check-out vnaprej izpolni podatke iz zapisnika check-in in izpostavi nove poškodbe\n• Izvoz PDF z obema podpisoma drug ob drugem';

  @override
  String get guideGpxImportTitle => 'Uvoz GPX';

  @override
  String get guideGpxImportBody =>
      'Uvozite sledi in točke poti iz drugih navigacijskih aplikacij ali naprav GPS (ikona na Zemljevidu).\n\n• Izberite datoteko .gpx iz naprave\n• Večdnevni izvoz (več sledi v eni datoteki, npr. iz Garmin Explore) se samodejno združi v eno plovbo z enim dnem na koledarski dan\n• Najdene sledi lahko tudi ročno dodelite obstoječi plovbi\n• Točke poti (vključno s tistimi iz poti) se dodajo neposredno na zemljevid\n• Za poškodovano datoteko se prikaže jasno sporočilo o napaki';

  @override
  String get guideWeatherTitle => 'Vreme';

  @override
  String get guideWeatherBody =>
      'Zavihek Vreme prikazuje napoved glede na vaš trenutni položaj.\n\n• Samodejno se posodobi ob spremembi položaja\n• Na vrhu so URADNA OPOZORILA (MeteoAlarm), če za tvojo državo katera veljajo. Ne izdaja jih model, ampak nacionalna meteorološka služba — na Hrvaškem DHMZ, v Britaniji Met Office, na Švedskem SMHI. Ob razprtju vidiš opis in navodilo; če besedila v tvojem jeziku ni, aplikacija pove, v katerem jeziku ga bereš.\n• Napoved prihaja iz NACIONALNEGA MODELA za kraj, kjer si — Jadran in Italija ARPAE ICON-2I, Britanija UKMO, Skandinavija MET Norway, srednja Evropa ICON-D2, drugod ECMWF. Ime modela je pod trenutnim vremenom.\n• Kartica Postaje – izmerjeno kaže, kaj je nekdo resnično izmeril, z razdaljo in časom meritve. Model in meritev se lahko razlikujeta tudi za polovico.\n• Brez signala se prikaže zadnja shranjena napoved, vedno tudi s časom prenosa. Starejša od šestih ur je označena oranžno.\n\nSonce, Luna in plima:\n• Sončni vzhod, zahod in Lunina mena se izračunajo v napravi — povezava ni potrebna\n• Tapnite osveži na kartici Plima in oseka za prenos sedemdnevne napovedi plime (brezplačno, brez ključa API)\n• Plima se shrani v predpomnilnik, zato ostane berljiva brez povezave; kartica vas opozori, ko je napoved stara ali prenesena daleč od tu\n• ⚠ Višine plime so nad srednjo gladino morja, ne nad hidrografsko ničlo — nikoli jih ne uporabljajte za izračun globine pod gredljem\n\nMorski tok:\n• Kartica Morski tok prikazuje dejansko napoved za vaš položaj v vozlih in smer, proti kateri tok teče\n• Ne zamenjujte ga s slojem Oceanski tokovi — to je referenčna karta velikih globalnih tokov';

  @override
  String get guideSafetyMobTitle => 'MOB in sidro';

  @override
  String get guideSafetyMobBody =>
      'Zavihek Varnost vsebuje funkcije za primer sile.\n\nMOB (človek v morju):\n• Držite rdeči gumb MOB za aktivacijo\n• Aplikacija zabeleži položaj GPS ter spremlja čas in razdaljo\n• Navigirajte nazaj do mesta padca\n\nAlarm sidra:\n• Nastavite polmer sidranja (priporočilo: 2× dolžina verige/vrvi)\n• Alarm zavibrira, če plovilo zaide izven dovoljenega polmera\n• Sidrna straža zdaj beleži lastno sled, zato noč na sidru ni več luknja v GPX. To je samostojen odsek — nikoli se ne šteje v milje, dnevno razdaljo ali nočne ure, saj zibanje na verigi ni plovba.\n• Straža preživi ponovni zagon aplikacije: če jo sistem v ozadju ubije, po zagonu nadaljuje na istem sidru.\n• Zapisa o spustu in dvigu sidra zdaj nosita tudi veter, tlak, temperature, globino pod gredljem in pogon — doslej sta imela le čas in položaj.';

  @override
  String get guideSafetyBriefingTitle => 'Varnostni brifing in MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'Zavihek Varnost vsebuje tudi referenčne kartice.\n\n• Varnostni brifing – kontrolni seznam za posadko pred izplutjem\n• Vsak član posadke se podpiše z lastnim podpisom na zaslonu\n• Podpisi se shranijo in samodejno vključijo v izvoz PDF plovbe\n• Seznam primopredaje – pregled postavk check-in/check-out, na voljo tudi brez odprte plovbe\n• Kartica MAYDAY – postopek klica v sili na kanalu VHF 16\n• COLREG – pravila za izogibanje trčenju na morju (na voljo v slovaščini in angleščini; drugi jeziki prikazujejo angleško besedilo)\n• Stiki – številke in stiki za klic v sili\n\nOpomba: sledenje lahko začnete kadar koli, tudi brez končanega brifinga – aplikacija vas le opozarja z oznako \"Manjka varnostni brifing\" v Dnevniku, dokler ni končan. Brifing zahteva predhodno izpolnjeno kartico plovila in posadke, shraniti pa ga je mogoče šele, ko se podpiše vsak član posadke.\n• Klici v sili sledijo položaju tudi brez vklopljenega sledenja – aplikacija sama zahteva položaj in ob prehodu v drugo državo zamenja številke';

  @override
  String get guideDutyTitle => 'Posadka na straži';

  @override
  String get guideDutyBody =>
      'Zapis o tem, kdo in kdaj je bil na straži — v Varnosti, nad alarmom sidra.\n\n• Prevzemi stražo — izberite eno ali več oseb hkrati; vsaka nato posebej preda stražo\n• Imena prihajajo iz posadke plovbe. Če posadka ni določena, vas gumb popelje na kartico plovbe\n• Čas začetka je mogoče popraviti, če ste gumb pritisnili z zamudo\n• Prikaži za inšpekcijo — kartica čez cel zaslon za predložitev na krovu: kdo je na straži, od kdaj, lokalni in čas UTC. Iz nje ni mogoče ničesar spremeniti\n• Razpored straž — vnesite preteklo stražo ali jo uredite. Pustite čas \"do\" prazen in straža ostane v teku\n• Nočna straža čez polnoč je en zapis, ne dva. V PDF se pojavi na obeh dneh, označena s puščico\n• Prevzem in predaja straže se zapišeta v dnevnik in v izvoz PDF\n\nOpomba: aplikacija nikoli sama ne konča straže. Po 12 urah vas le opozori — čas konca, ki ga niste videli, bi bil izmišljen podatek.';

  @override
  String get guideCompassTitle => 'Kompas za merjenje azimuta';

  @override
  String get guideCompassBody =>
      'Zavihek Kompas prikazuje magnetni azimut s pomočjo senzorjev telefona, z zadnjo kamero kot ozadjem za merjenje azimuta na predmete.\n\n• Rumeni nitni križ – smer, v katero merite\n• Trak kompasa na vrhu – S / SV / V / JV / J / JZ / Z / SZ\n• Številčni prikaz – stopinje in stran neba\n• Zelena pika = stabilen odčitek  ·  Oranžna pika = umerjanje\n\nČe je odčitek nestabilen, počasi premikajte telefon v obliki osmice, da umerite magnetometer.\n\nNatančnost je lahko manjša v bližini kovinskih konstrukcij, zvočnikov ali elektronske opreme.\n\nKompas rešuje dve različni nalogi — najti SEBE, ko ne veš, kje si, ali določiti NEZNANO TOČKO, ko želiš na karto vnesti nekaj, česar tam še ni. Stikalo nad gumbom Izmeri azimut izbere, katero od njiju trenutno počneš.\n\nMOJ POLOŽAJ — najdi sebe (GPS ni potreben)\n\n1. Preveri na zemljevidu, ali poznaš vsaj dve vidni točki (svetilnik, vrh, cerkev), shranjeni kot waypointa. Manjkajočo dodaš z dolgim pritiskom na zemljevid natanko na njeno mesto.\n2. Na kompasu preklopi na \"Moj položaj\".\n3. Dotakni se oznake pod stikalom in izberi prvo točko, ki jo meriš.\n4. Nitni križ usmeri natanko nanjo in pritisni Izmeri azimut.\n5. V pogovornem oknu preveri izmerjeni azimut in pritisni Shrani (Prekliči zavrže osnutek brez shranjevanja).\n6. Izberi drugo, DRUGO točko (izbira se po shranjevanju sama izprazni) in ponovi.\n7. Na zemljevidu boš videl dve črtkani črti od točk proti tebi. Njuno presečišče je tvoj položaj — zeleni križec pomeni dober rez, oranžni oster kot in negotov položaj.\n8. Tretja točka, najbolje pod drugim kotom, izboljša oceno in nariše trikotnik napake.\n\nNaredi to hitro, v 5 minutah — presečišče predpostavlja, da barka med meritvama stoji.\n\nNEZNANA TOČKA — določi objekt (GPS je potreben)\n\n1. Preklopi na \"Neznana točka\".\n2. Dotakni se oznake, izberi \"Nova točka…\" in poimenuj, kaj meriš, npr. \"neznana čer\".\n3. Nameri, Izmeri azimut, potrdi Shrani.\n4. Premakni barko vsaj nekaj sto metrov — dlje ko greš, zanesljivejši je rezultat.\n5. Znova odpri izbiro cilja, izberi ISTI objekt s seznama (ne \"Nova točka\") in izmeri drugič.\n6. Na zemljevidu se prikaže oznaka z izračunanim položajem objekta. Z dotikom jo shraniš kot waypoint — odtlej jo lahko uporabiš tudi za presečišče.\n\nNatančnost\n\nKompas v telefonu ima realno napako okoli ±8°, kar je na 10 NM več kot 2,5 NM stranskega odstopanja — prav zato aplikacija riše stožec negotovosti namesto tanke črte. Najboljši rez dajo točke pod kotom blizu 90°; kadar ležijo skoraj v isti liniji s tabo, se presečišče razmaže na stotine metrov ali več.\n\nAzimuti brez plovbe\n\nAzimut se shrani tudi brez vklopljenega sledenja — na sidru, na kopnem. Najdeš ga na seznamu plovb kot samostojno vrstico z datumom, med posameznimi plovbami. Z odprtjem prikažeš azimute tega dne z majhnim zemljevidom, od tam pa sprožiš izvoz preprostega PDF-ja z zemljevidom in tabelo azimutov.\n\nČiščenje zemljevida in brisanje azimutov\n\nMerjenje na čistem zemljevidu – na Kompasu ikona osvežitve zgoraj desno. Umakne dosedanje azimute z zemljevida in počisti izbrano točko ali predmet, tako da naslednje Izmeri azimut začne na novo. Nič se ne izgubi: zapisi ostanejo v zavihku Ladijski dnevnik in v izvozu PDF.\n\nTrajen izbris – odpri vrstico z datumom na seznamu plovb. Križec ob vrstici izbriše en azimut (pri predmetu celoten niz meritev nanj). Koš v zgornji vrstici izbriše cel dan naenkrat in te vrne na seznam. Brisanje je nepovratno in ti azimuti izginejo tudi iz izvoza PDF.\n\nNa kratko: čiščenje pospravi zemljevid, brisanje odstrani zapis. Vsebino PDF spremeni le brisanje.';

  @override
  String get guideSettingsTitle => 'Nastavitve';

  @override
  String get guideSettingsBody =>
      '• Jezik – sprememba jezika aplikacije\n• Instrumenti – nastavite naslov IP prehoda Raymarine WiFi (TCP ali UDP)\n• Vir GPS – telefon ali Raymarine\n• Enote – razdalja NM/km, hitrost vozli/km/h, posebej temperatura, globina in veter (na reki ustrezata km + km/h)\n• Pogostost zapisov v dnevnik\n• Spodnji meni – prilagodite ga: pritisnite in povlecite ikono za spremembo vrstnega reda, s stikalom skrijte zavihke, ki jih ne uporabljate, in nastavite velikost ikon (S/M/L). Skrite zavihke lahko odprete prav tu v Nastavitvah; Nastavitve so vedno prikazane. Vrstni red in velikost se ohranita. Napisi pod ikonami so skriti, da ikone stojijo enako v vseh jezikih; z dolgim pritiskom se pokaže ime.\n• Prikaz – Nočni način (rdeči filter za ohranjanje nočnega vida)\n• Izvoz v oblak (Google Drive) – po prijavi se PDF in GPX vsakega končanega dne samodejno naložita na vaš Google Drive. Brez prijave vse ostane v napravi.\n• Varnostna kopija podatkov – glejte \"Varnostna kopija in obnovitev podatkov\"\n• O aplikaciji – različica in stik\n• Baterija – GPS deluje s polno natančnostjo le tam, kjer je natančen položaj pomemben (sledenje plovbi, zemljevid, kompas, instrumenti, sidrna straža, MOB); drugod preklopi v varčni način, v ozadju brez vklopljenega sledenja pa se povsem izklopi. Ob povezanih ladijskih instrumentih GPS telefona ostane izklopljen, položaj pa prihaja z NMEA.\n• Posodobitve – ko je v Google Play novejša različica, jo aplikacija prenese v ozadju in ponudi ponovni zagon. Med snemanjem plovbe ne vpraša nikoli.\n• Časovni pas – čas na zaslonu in v PDF se prikaže krajevno (pas telefona, torej tam, kjer si) ali v UTC. Shranjeni zapisi se ne spremenijo, spremeni se le prikaz; PDF vedno navede, kateri pas velja.\n\nGoogle račun in izvoz v oblak\n\nPrijava z Google računom je prostovoljna. Brez nje aplikacija deluje v celoti in vsi zapisi ostanejo samo v telefonu.\n\nKaj se naloži – ob zaključku dneva plovbe PDF dnevnika in sled GPX tistega dne. Nič drugega: ne fotografije, ne stiki posadke, ne položaji v živo.\n\nKam – na tvoj lastni Google Drive, v mapo HMB_Sailing_Log_DATA / ime plovbe / Day_datum. Ne na strežnik aplikacije – ta ne obstaja.\n\nKaj aplikacija vidi na Drivu – samo datoteke, ki jih je tam ustvarila sama. Uporablja najožje dovoljenje, ki ga Google ponuja (drive.file), zato ostane preostanek tvojega Driva nedosegljiv. Dovoljenje zahteva šele ob prvem nalaganju, ne ob prijavi.\n\nKako to razveljaviš – odjavi račun v Nastavitvah. Datoteke, ki so že na Drivu, ostanejo tvoje – aplikacija jih ne briše.';

  @override
  String get guideBackupTitle => 'Varnostna kopija in obnovitev podatkov';

  @override
  String get guideBackupBody =>
      'V Nastavitve → Varnostna kopija podatkov.\n\n• Izvozi varnostno kopijo – shrani celoten dnevnik (plovbe, zapise, nastavitve) v eno datoteko (.hmbbackup), ki jo lahko delite po e-pošti, v oblak ali shranite lokalno\n• Obnovi iz varnostne kopije – zamenja trenutne podatke z vsebino izbrane kopije; varnostna kopija trenutnega stanja se pred tem ustvari samodejno\n• Obnovitev je onemogočena, dokler je aktivno sledenje plovbi prek GPS\n• Kopija z novejšo shemo, kot jo aplikacija podpira, je zavrnjena z razlago';

  @override
  String get guideExportTitle => 'Izvoz dnevnika';

  @override
  String get guideExportBody =>
      'Dnevnik lahko izvozite kot profesionalen dokument PDF.\n\n1. Odprite Dnevnik → izberite plovbo\n2. Tapnite ikono izvoza ali tri pike → Izvozi PDF\n3. Podpišite se kot skiper → PDF se ustvari\n4. PDF vsebuje: sled, zapise iz dnevnika, fotografije, varnostni brifing s podpisi posadke; glava naslovnice prikazuje fotografijo plovila s kartice plovila (če je naložena)\n5. Delite po e-pošti, natisnite ali shranite v telefon\n\nVsak PDF dobi enolično oznako dokumenta (npr. HMBSL-5-2026) in številko revizije (Rev. 1, Rev. 2...), vidno v nogi vsake strani. Vsak nov izvoz številko samodejno poveča — s čimer je vidno, kolikokrat je bil dokument ustvarjen.\n\nKoda QR na strani s podpisi vsebuje oznako, revizijo in kriptografski odtis vsebine. Vsaka sprememba podatkov spremeni kodo QR.\n\nPDF se ustvari v jeziku aplikacije, vključno z imeni in diakritičnimi znaki. Vsaka stran dneva nosi tudi trak s posadko na straži.\n• Če se je sledenje čez dan prekinilo in znova zagnalo, vsak odsek dobi svojo datoteko GPX\n• Razdalje, hitrosti in temperature v PDF sledijo enotam, nastavljenim v Nastavitvah';

  @override
  String get safetyBriefingScreenTitle => 'Varnostni brifing';

  @override
  String get briefingCrewSignaturesSection => 'Podpisi posadke';

  @override
  String get briefingSignHere => 'Podpišite se tukaj';

  @override
  String get briefingClear => 'Počisti';

  @override
  String get briefingSigned => 'Podpisano';

  @override
  String get briefingSave => 'Shrani podpise';

  @override
  String get briefingSavedOk => 'Podpisi shranjeni';

  @override
  String get briefingOpenBriefing => 'Varnostni brifing';

  @override
  String get briefingSkipper => 'Skiper';

  @override
  String get briefingCrew => 'Posadka';

  @override
  String get briefingNoCrew =>
      'Posadka ni določena. Dodajte člane posadke v nastavitvah plovbe.';

  @override
  String get briefingDate => 'Datum';

  @override
  String get briefingLocation => 'Kraj';

  @override
  String get briefingDoneLabel => 'Varnostni brifing končan';

  @override
  String get briefingDoneSubtitle =>
      'Vsi podpisi posadke so shranjeni. Ponavljanje ni potrebno.';

  @override
  String get briefingEditSignature => 'Spremeni podpis';

  @override
  String get briefingRequiredTitle => 'Potreben je varnostni brifing';

  @override
  String get briefingRequiredBody =>
      'Pred začetkom prvega sledenja končajte varnostni brifing in zberite podpise posadke.';

  @override
  String get goToBriefing => 'Pojdi na brifing';

  @override
  String get skipperProfile => 'Profil skiperja';

  @override
  String get skipperProfileHint =>
      'Ti podatki se pojavijo v izvozu plovbe v PDF.';

  @override
  String get skipperFullName => 'Ime skiperja';

  @override
  String get skipperLicenseSection => 'Dovoljenje skiperja';

  @override
  String get skipperLicenseType => 'Vrsta dovoljenja';

  @override
  String get skipperLicenseNumber => 'Številka dovoljenja';

  @override
  String get skipperLicenseAuthority => 'Organ izdaje';

  @override
  String get skipperLicenseExpiry => 'Velja do';

  @override
  String get skipperVhfSection => 'Dovoljenje VHF / SRC';

  @override
  String get skipperVhfNumber => 'Številka VHF/SRC';

  @override
  String get skipperVhfExpiry => 'VHF velja do';

  @override
  String get skipperOtherCerts => 'Druga potrdila / dovoljenja';

  @override
  String get skipperOtherCertsHint =>
      'npr. Yachtmaster, RYA, STCW, tečaji reševanja...';

  @override
  String get continueLastVoyageTitle => 'Nadaljujem zadnjo plovbo?';

  @override
  String get continueVoyageAction => 'Nadaljuj';

  @override
  String get newRecordAction => 'Nov zapis';

  @override
  String get missingCheckInChip => 'Manjka check-in';

  @override
  String get missingBriefingChip => 'Manjka varnostni brifing';

  @override
  String get missingDetailsChip => 'Manjkajo podatki o plovilu/posadki';

  @override
  String get missingCheckOutChip => 'Manjka check-out';

  @override
  String get vesselModel => 'Model';

  @override
  String get vesselTypeMonohull => 'Enotrupnik';

  @override
  String get vesselTypeCatamaran => 'Katamaran';

  @override
  String get vesselTypeTrimaran => 'Trimaran';

  @override
  String get vesselTypeMotorYacht => 'Motorna jahta';

  @override
  String get vesselTypeGulet => 'Gulet';

  @override
  String get vesselTypeDinghy => 'Mala jadrnica';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Drugo';

  @override
  String get charterCompanyLabel => 'Čarter podjetje';

  @override
  String get yachtParamsSection => 'Parametri jahte';

  @override
  String get berthsLabel => 'Ležišča';

  @override
  String get yearBuiltLabel => 'Leto izdelave';

  @override
  String get waterTankLabel => 'Rezervoar za vodo';

  @override
  String get fuelTankLabel => 'Rezervoar za gorivo';

  @override
  String get engineHoursStartLabel => 'Ure motorja · začetek';

  @override
  String get engineHoursEndLabel => 'Ure motorja · konec';

  @override
  String get whereWhenSection => 'Kje in kdaj';

  @override
  String get countryLabel => 'Država';

  @override
  String get cruisingAreaLabel => 'Območje plovbe';

  @override
  String get charterContactsSection => 'Čarter stiki';

  @override
  String get charterContactsHint =>
      'Do 3 številke za klic / WhatsApp / SMS. Vedno z mednarodno predpono (npr. +386...).';

  @override
  String get addPhoneNumber => 'Dodaj telefonsko številko';

  @override
  String get costsSection => 'Stroški';

  @override
  String get charterPriceLabel => 'Cena plovbe';

  @override
  String get currencyLabel => 'Valuta';

  @override
  String get addCostItem => 'Dodaj strošek';

  @override
  String get costName => 'Naziv stroška';

  @override
  String get crewSectionHint =>
      'Tapnite oznako, da določite poveljnika — ostali so posadka.';

  @override
  String get addCrewMember => 'Dodaj člana posadke';

  @override
  String get crewNameLabel => 'Ime';

  @override
  String get skipperBadge => 'SKIPER';

  @override
  String get crewBadge => 'POSADKA';

  @override
  String get vesselTypeSailboat => 'Jadrnica';

  @override
  String get vesselTypeMotorBoat => 'Motorno plovilo';

  @override
  String get sbNeedsVesselCard =>
      'Najprej izpolnite kartico plovila in posadke — Varnostni brifing potrebuje seznam posadke za podpise.';

  @override
  String get prefillSkipperTitle => 'Izpolnim shranjene podatke skiperja?';

  @override
  String get prefillSkipperFill => 'Izpolni';

  @override
  String get prefillSkipperNew => 'Nov skiper';

  @override
  String get boatLicenceLabel => 'Št. dovoljenja za vodenje';

  @override
  String get radioLicenceLabel => 'Št. radijskega dovoljenja';

  @override
  String get vesselPhotosSection => 'Fotografije plovila (največ 3)';

  @override
  String get addPhotoLabel => 'Dodaj';

  @override
  String get createVoyageButton => 'Ustvari plovbo';

  @override
  String get saveVoyageButton => 'Shrani plovbo';

  @override
  String get costBaseCharter => 'Osnovna cena plovbe';

  @override
  String get costDeposit => 'Varščina';

  @override
  String get costDinghyOutboard => 'Gumenjak / izvenkrmni motor';

  @override
  String get costOutboardFuel => 'Gorivo za izvenkrmni motor';

  @override
  String get costTransitLog => 'Transit log';

  @override
  String get costTouristTax => 'Turistična taksa';

  @override
  String get costFinalCleaning => 'Končno čiščenje';

  @override
  String get costLinenTowels => 'Posteljnina in brisače';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / kajak';

  @override
  String get costSkipperFee => 'Nadomestilo za skiperja';

  @override
  String get costHostessFee => 'Nadomestilo za hosteso';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m m';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Približna lokacija · ±$m m · omrežno določanje položaja';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Zadnja znana lokacija · pred $mins min';
  }

  @override
  String get locationQualityUnknown => 'Natančnost neznana';

  @override
  String get locationQualityMocked => '⚠️ Zaznana lažna lokacija';

  @override
  String get syncQueueTitle => 'Čakalna vrsta sinhronizacije';

  @override
  String get syncQueueEmpty => 'Vrsta je prazna';

  @override
  String get syncNowAction => 'Sinhroniziraj zdaj';

  @override
  String get syncRetryFailedAction => 'Ponovi neuspele';

  @override
  String get syncStatusPending => 'Na čakanju';

  @override
  String get syncStatusSending => 'Pošiljanje';

  @override
  String get syncStatusSent => 'Poslano';

  @override
  String get syncStatusFailed => 'Neuspelo';

  @override
  String get syncStatusConflict => 'Spor';

  @override
  String get syncStatusDeferred => 'Odloženo';

  @override
  String syncRetryCount(int n) {
    return 'Poskus $n';
  }

  @override
  String get syncOffline => 'brez povezave';

  @override
  String syncPendingCount(int n) {
    return '$n na čakanju';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n odloženih';
  }

  @override
  String syncFailedCount(int n) {
    return '$n neuspelih';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Priloga čaka na Wi-Fi (na morju običajno ni na voljo).';

  @override
  String get syncWifiOverrideAction => 'Uporabi mobilne podatke';

  @override
  String get syncWifiOverrideActive => 'Mobilni podatki dovoljeni za priloge';

  @override
  String get syncClearQueueAction => 'Izprazni vrsto';

  @override
  String get syncClearQueueConfirmTitle => 'Izpraznim celotno vrsto?';

  @override
  String get syncClearQueueConfirmContent =>
      'Odstrani vsako postavko iz čakalne vrste, vključno z že poslanimi. Tega ni mogoče razveljaviti.';

  @override
  String get syncClearQueueDone => 'Vrsta izpraznjena';

  @override
  String get syncEnableToggle => 'Sinhroniziraj dnevnik';

  @override
  String get syncEnableToggleDesc =>
      'Pošilja zapise na strežnik, dokler je aplikacija odprta in povezana';

  @override
  String get syncTargetLabel => 'Cilj sinhronizacije';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Lasten strežnik';

  @override
  String get syncCustomUrlLabel => 'URL strežnika';

  @override
  String get syncCustomTokenLabel => 'Žeton';

  @override
  String get syncTestConnectionAction => 'Preizkusi povezavo';

  @override
  String get syncTestSuccess => 'Povezava deluje';

  @override
  String syncTestFailure(String detail) {
    return 'Neuspelo: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Vnesite URL strežnika';

  @override
  String get syncUrlErrorInvalid => 'Neveljaven URL';

  @override
  String get syncUrlErrorHttps => 'URL se mora začeti s https://';

  @override
  String get syncIntervalLabel => 'Interval sinhronizacije';

  @override
  String syncIntervalMinutes(int n) {
    return '$n min';
  }

  @override
  String get syncIntervalNote =>
      'Sinhronizacija deluje samo, dokler je aplikacija odprta';

  @override
  String get syncAttachmentPolicyLabel => 'Priloge (fotografije)';

  @override
  String get syncAttachmentNever => 'Nikoli';

  @override
  String get syncAttachmentWifiOnly => 'Samo Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Vedno';

  @override
  String get syncBackfillAction => 'Uvrsti starejše zapise v vrsto';

  @override
  String get syncBackfillDesc =>
      'Doda zapise, ustvarjene med izklopljeno sinhronizacijo, v čakalno vrsto za pošiljanje';

  @override
  String syncBackfillResult(int n) {
    return '$n uvrščenih';
  }

  @override
  String get syncBackfillNone =>
      'Nič za uvrstitev — vse je že v vrsti ali poslano';

  @override
  String get syncCloudEnableToggle => 'Izvoz v oblak (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Po prijavi se PDF in GPX vsakega končanega dne samodejno naložita na Google Drive. Brez prijave vse ostane v napravi.';

  @override
  String get syncCloudSignInAction => 'Prijavi se z Googlom';

  @override
  String get syncCloudSignOutAction => 'Odjavi se';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Prijavljeni kot $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Niste prijavljeni';

  @override
  String get waypointNameHint => 'npr. Sidrišče, Pristanišče...';

  @override
  String waypointDefaultName(String time) {
    return 'Točka $time';
  }

  @override
  String get mobFullName => 'Človek v morju';

  @override
  String get maydayCardShort => 'Kartica\nMayday';

  @override
  String get morseInputHint => 'Vnesite besedilo...';

  @override
  String get morseSosTitle => 'SOS – SIGNAL V SILI';

  @override
  String get morseSosCopied => 'SOS kopiran';

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
    return '$n h';
  }

  @override
  String get aboutFeatureGps => 'Sledenje GPS s samodejnimi zapisi';

  @override
  String get aboutFeatureLogbook => 'Dnevnik večdnevnih plovb';

  @override
  String get aboutFeatureMaps =>
      'Pomorski zemljevidi brez povezave (OpenSeaMap)';

  @override
  String get aboutFeatureWeather => 'Pomorska vremenska napoved (Open-Meteo)';

  @override
  String get aboutFeatureExport => 'Izvoz PDF + GPX';

  @override
  String get aboutFeatureSafety => 'Varnostni brifing in kartica Mayday';

  @override
  String get aboutAuthorLabel => 'Avtor';

  @override
  String get aboutVersionLabel => 'Različica';

  @override
  String get aboutPlatformLabel => 'Platforma';

  @override
  String cloudSignInFailed(String error) {
    return 'Prijava ni uspela: $error';
  }

  @override
  String cloudSignOutFailed(String error) {
    return 'Odjava ni uspela: $error';
  }

  @override
  String get marineInstrumentsWifiNote =>
      'Deluje samo prek WiFi omrežja plovila – telefon mora biti povezan s prehodom NMEA (Raymarine, Digital Yacht, Yacht Devices…). Brez WiFi aplikacija uporablja GPS telefona in vremensko napoved z interneta.';

  @override
  String get interruptedVoyageTitle => 'Sledenje je bilo prekinjeno';

  @override
  String interruptedVoyageBody(String time) {
    return 'Aplikacija se je zaprla ob $time brez zaključka plovbe. Nadaljevati isto plovbo?';
  }

  @override
  String interruptedVoyageGap(String distance) {
    return 'Trenutni položaj je $distance NM od zadnje zabeležene točke.';
  }

  @override
  String get interruptedVoyageAddGap => 'Prištej to razdaljo k plovbi';

  @override
  String get interruptedVoyageResume => 'Nadaljuj';

  @override
  String get trackingStalledTitle => 'Plovba teče, a se nič ne beleži';

  @override
  String trackingStalledSince(String minutes) {
    return 'Zadnja točka pred $minutes min';
  }

  @override
  String get trackingResumeAction => 'Nadaljuj';

  @override
  String trackingResumedAuto(String minutes) {
    return 'Beleženje se nadaljuje. Sistem je ustavil aplikacijo — manjka $minutes min.';
  }

  @override
  String trackingResumedAddGap(String nm) {
    return 'Dodaj $nm NM';
  }

  @override
  String get batteryPromptTitle => 'Naj aplikacija teče vso plovbo';

  @override
  String get batteryPromptBody =>
      'Android — zlasti Honor, Huawei in Xiaomi — zapira aplikacije, ki tečejo v ozadju, zato se sledenje prekine sredi plovbe.\n\nV nastavitvah baterije dovolite tej aplikaciji delovanje brez omejitev. Na Honor/Huawei jo dodajte še med zaščitene aplikacije in dovolite samodejni zagon.';

  @override
  String get batteryPromptAction => 'Odpri nastavitve';

  @override
  String get speed => 'Hitrost';

  @override
  String get dateFormatLabel => 'Oblika datuma';

  @override
  String get dateFormatByLanguage => 'Po jeziku aplikacije';

  @override
  String get crewCertTitle => 'Potrdilo o preplutih miljah';

  @override
  String get crewCertVoyage => 'Plovba';

  @override
  String get crewCertArea => 'Območje plovbe';

  @override
  String get crewCertDayMiles => 'Dnevne milje';

  @override
  String get crewCertNightMiles => 'Nočne milje';

  @override
  String get crewCertNightHours => 'Nočne ure';

  @override
  String get crewCertQualifications => 'Kvalifikacije';

  @override
  String get crewCertAssessment => 'Ocena skiperja';

  @override
  String get crewCertStamp => 'Žig';

  @override
  String get crewCertHashCoverage =>
      'Odtis pokriva povzetek plovbe in oceno posadke.';

  @override
  String get crewSkillHelming => 'Krmarjenje';

  @override
  String get crewSkillNavigation => 'Navigacija';

  @override
  String get crewSkillHarbour => 'Manevri v pristanišču';

  @override
  String get crewSkillTeamwork => 'Timsko delo';

  @override
  String get crewSkillNightSailing => 'Nočna plovba';

  @override
  String get crewCertExport => 'Izvozi potrdila';

  @override
  String get crewCertNoteHint => 'Opisna ocena (neobvezno)';

  @override
  String get crewCertNoCrew =>
      'Ta plovba nima posadke. Dodaj jo v kartici plovbe.';

  @override
  String get crewCertNotRated => 'ni ocenjeno';

  @override
  String get crewCertShared => 'Potrdila so ustvarjena';

  @override
  String get more => 'Več';

  @override
  String get crewCertSkipperRates =>
      'Skiper ocenjuje posadko in sam ni ocenjen. Potrdilo o miljah vseeno dobi.';

  @override
  String get crewCertVesselSize => 'Dimenzije plovila';

  @override
  String get crewCertVesselRegistration => 'Registracija';

  @override
  String get crewCertWaters => 'Vode';

  @override
  String get crewCertWatersTidal => 'plimne';

  @override
  String get crewCertWatersNonTidal => 'neplimne';

  @override
  String get crewCertIdDocument => 'Številka potnega lista / osebne';

  @override
  String get crewCertDaysAtSea => 'Dnevi na morju';

  @override
  String get crewCertTotal => 'Skupaj';

  @override
  String get crewCertWatersLabel => 'Vrsta voda';

  @override
  String get bearingTakeSight => 'Izmeri azimut';

  @override
  String bearingSaved(String bearing) {
    return 'Azimut $bearing shranjen';
  }

  @override
  String get bearingNoPosition =>
      'Brez GPS neznane točke ni mogoče določiti. Preklopi na „Moj položaj“ — presečišče znanih točk GPS ne potrebuje.';

  @override
  String get bearingSaveFailed => 'Azimuta ni bilo mogoče shraniti';

  @override
  String get bearingLabelHint => 'Kaj meriš? (neobvezno)';

  @override
  String bearingDeclinationApplied(String value) {
    return 'Deklinacija $value';
  }

  @override
  String get bearingDeclinationExpired =>
      'Magnetni model je potekel — deklinacija je le ocena';

  @override
  String get bearingsLayer => 'Azimuti';

  @override
  String get bearingsTitle => 'Azimuti';

  @override
  String get bearingsClearAll => 'Skrij vse z zemljevida';

  @override
  String get bearingsClearConfirm =>
      'Skriti vse azimute z zemljevida? Črte in presečišče izginejo z zemljevida, v dnevniku ostanejo.';

  @override
  String get bearingsEmpty =>
      'Še ni azimutov. Usmeri telefon v objekt in pritisni Izmeri azimut.';

  @override
  String get bearingsDeleteDayConfirm =>
      'Vsi azimuti tega dne bodo trajno izbrisani, tudi iz izvoza PDF. Tega dejanja ni mogoče razveljaviti.';

  @override
  String bearingFixFrom(int count) {
    return 'Položaj iz $count azimutov';
  }

  @override
  String bearingFixWeak(String angle) {
    return 'Šibko presečišče — črti se sekata le pod $angle';
  }

  @override
  String bearingFixOffGps(String distance) {
    return 'Odstopanje od GPS: $distance';
  }

  @override
  String get bearingTrueLabel => 'pravi';

  @override
  String get bearingMagneticLabel => 'magnetni';

  @override
  String bearingUncertaintyNote(String deg) {
    return 'Stožec prikazuje ±$deg negotovost telefonskega kompasa.';
  }

  @override
  String get bearingPdfSection => 'Azimuti';

  @override
  String get bearingPdfObject => 'Objekt';

  @override
  String get bearingPdfBearing => 'Pravi azimut';

  @override
  String get bearingModeResection => 'Moj položaj';

  @override
  String get bearingModeObject => 'Neznana točka';

  @override
  String get bearingModeResectionHint =>
      'Izmeri azimut na 2–3 znane točke s karte. GPS ni potreben.';

  @override
  String get bearingModeObjectHint =>
      'Izmeri isto točko z 2–3 različnih mest. Potreben je GPS.';

  @override
  String get bearingPickTarget => 'Izberi točko za merjenje';

  @override
  String get bearingNeedsTarget =>
      'Najprej izberi znano točko s karte, nato izmeri';

  @override
  String get bearingNeedsObject => 'Najprej poimenuj točko, ki jo meriš';

  @override
  String get bearingNewObject => 'Nova točka…';

  @override
  String get bearingObjectName => 'Ime točke (npr. neznana čer)';

  @override
  String get bearingOpenObjects => 'Točke v določanju';

  @override
  String bearingSightCount(int count) {
    return '$count azimutov';
  }

  @override
  String get bearingSameTargetHint =>
      'Ista točka kot prej — za presečišče je potrebna druga.';

  @override
  String get bearingShortBaselineHint =>
      'Kratka bazna črta — premakni se in izmeri znova.';

  @override
  String get bearingMovedHint =>
      'Barka se je med meritvama premaknila — presečišče predpostavlja, da stoji.';

  @override
  String get bearingNeedsSecondSight =>
      'Še en azimut na drugo točko in položaj bo izšel.';

  @override
  String get bearingMyPositionFix => 'Moj položaj';

  @override
  String get bearingObjectFix => 'Določena točka';

  @override
  String get bearingSaveObjectAsWaypoint => 'Shrani kot waypoint';

  @override
  String bearingObjectSaved(String name) {
    return '$name shranjen kot waypoint';
  }

  @override
  String get bearingDeclinationFromTarget =>
      'Deklinacija računana v položaju izmerjene točke';

  @override
  String get bearingResectionSection => 'Presečišče — položaj iz znanih točk';

  @override
  String get bearingObjectSection => 'Določanje neznanih točk';

  @override
  String get bearingPdfMark => 'Izmerjena točka';

  @override
  String get bearingPdfResult => 'Rezultat';

  @override
  String get bearingStartNew => 'Začni novo meritev';

  @override
  String get bearingHideFromMap => 'Skrij z zemljevida';
}
