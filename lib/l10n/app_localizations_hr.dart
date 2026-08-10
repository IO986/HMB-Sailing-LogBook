// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get poiTypeAnchorage => 'Sidrište';

  @override
  String get poiTypeMarina => 'Marina';

  @override
  String get poiTypeFuel => 'Benzinska postaja';

  @override
  String get poiTypeHarbour => 'Luka';

  @override
  String get poiVhfChannel => 'VHF kanal';

  @override
  String get poiPhone => 'Telefon';

  @override
  String get poiWebsite => 'Web stranica';

  @override
  String get poiEmail => 'E-mail';

  @override
  String get poiCapacity => 'Kapacitet';

  @override
  String get poiServices => 'Usluge';

  @override
  String get poiSaveAsWaypoint => 'Spremi kao točku rute';

  @override
  String poiWaypointSaved(String name) {
    return 'Točka rute \"$name\" spremljena';
  }

  @override
  String get poiSource => 'Izvor: OpenStreetMap';

  @override
  String get mapLayerSatellite => 'Satelit';

  @override
  String get mapLayerMap => 'Karta';

  @override
  String get mapLayers => 'Slojevi';

  @override
  String get mapSeamarks => 'Pomorske oznake';

  @override
  String get mapHarbours => 'Luke i sidrišta';

  @override
  String get mapZoomInForPois =>
      'Približite prikaz za učitavanje luka i sidrišta';

  @override
  String get mapRainRadar => 'Radar oborina';

  @override
  String get mapOceanCurrentsTooltip => 'Oceanske struje (držite za popis)';

  @override
  String get mapCurrentForecast => 'Morska struja — prognoza (čv)';

  @override
  String get mapTools => 'Alati';

  @override
  String get mapVoyageOverview => 'Pregled plovidbe';

  @override
  String get mapRuler => 'Ravnalo / ruta';

  @override
  String get mapDownloadOffline => 'Preuzmi područje izvanmrežno';

  @override
  String get mapGpsDisabled => 'GPS je isključen';

  @override
  String get mapLocationDenied => 'Lokacija nije dopuštena';

  @override
  String get mapFollowGps => 'Prati GPS';

  @override
  String mapAreaTooLarge(int count) {
    return 'Područje je preveliko ($count pločica). Približite prikaz i pokušajte ponovno.';
  }

  @override
  String get mapLivePreview => 'Uživo (trenutno praćenje)';

  @override
  String get mapWholeVoyage => 'Cijela plovidba';

  @override
  String get offlineSheetTitle => 'Izvanmrežna karta vidljivog područja';

  @override
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb) {
    return 'Karta + pomorske oznake, zumiranje $minZ–$maxZ, $tiles pločica (~$mb MB). Preuzeta područja rade na moru bez signala.';
  }

  @override
  String offlineDone(int n) {
    return 'Gotovo — spremljeno $n pločica';
  }

  @override
  String offlineDoneErrors(int n) {
    return 'Gotovo s greškama: $n pločica nije preuzeto';
  }

  @override
  String get downloadAction => 'Preuzmi';

  @override
  String get rulerTapHint => 'Dodirnite točke na karti';

  @override
  String get mapEntryPhoto => 'Foto zapis';

  @override
  String get mapEntryNote => 'Zapis u dnevniku';

  @override
  String get openSettingsAction => 'Otvori postavke';

  @override
  String get morseConverter => 'Pretvarač teksta u Morseov kod';

  @override
  String saveError(String error) {
    return 'Greška pri spremanju: $error';
  }

  @override
  String get languageName => 'Hrvatski';

  @override
  String get navMap => 'Karta';

  @override
  String get navTracking => 'Praćenje';

  @override
  String get navLogbook => 'Dnevnik';

  @override
  String get navWeather => 'Vrijeme';

  @override
  String get navSafety => 'Sigurnost';

  @override
  String get navCompass => 'Kompas';

  @override
  String get navSettings => 'Postavke';

  @override
  String get navCustomizeTitle => 'Donji izbornik';

  @override
  String get navCustomizeHint =>
      'Pritisnite i povucite za promjenu redoslijeda ikona. Prekidačem sakrijte karticu iz donjeg izbornika — Postavke su uvijek prikazane.';

  @override
  String get navAlwaysShown => 'Uvijek prikazano';

  @override
  String get navIconSizeLabel => 'Veličina ikona';

  @override
  String get navOpenHiddenTitle => 'Otvori skrivene kartice';

  @override
  String get cameraPermissionDenied =>
      'Pristup kameri je odbijen. Omogućite ga u postavkama uređaja.';

  @override
  String get cameraUnavailable => 'Kamera nije dostupna';

  @override
  String get compassCalibrationNote =>
      'Magnetski kompas. Na točnost mogu utjecati metal ili elektronika u blizini. Ako nije kalibriran, pomičite uređaj u obliku osmice.';

  @override
  String get cancel => 'Odustani';

  @override
  String get delete => 'Obriši';

  @override
  String get edit => 'Uredi';

  @override
  String get save => 'Spremi';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Ne';

  @override
  String get ok => 'U redu';

  @override
  String get close => 'Zatvori';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String get share => 'Podijeli';

  @override
  String get selectAll => 'Odaberi sve';

  @override
  String get error => 'Greška';

  @override
  String errorMsg(String msg) {
    return 'Greška: $msg';
  }

  @override
  String get pressBackToExit => 'Pritisnite Natrag ponovno za izlaz';

  @override
  String get trackingRunningTitle => 'Praćenje je aktivno';

  @override
  String get trackingRunningContent =>
      'Praćenje je aktivno. Što želite učiniti?';

  @override
  String get stopAndExit => 'Zaustavi i izađi';

  @override
  String get keepRunning => 'Nastavi praćenje';

  @override
  String get marineInstrumentsTitle => 'Brodski instrumenti';

  @override
  String get marineInstrumentsPrompt =>
      'Želite li povezati aplikaciju s brodskim instrumentima (npr. Raymarine putem WiFi pristupnika)? Aplikacija će tada čitati GPS, vjetar, dubinu i ostale podatke izravno s broda.\n\nBez veze koristit će se GPS telefona i internetska vremenska prognoza – to možete promijeniti bilo kada u Postavkama.';

  @override
  String get notNow => 'Ne sada';

  @override
  String get setupConnection => 'Postavi vezu';

  @override
  String get autoDetectAction => 'Automatsko otkrivanje';

  @override
  String get autoDetectWifiHintTitle => 'Najprije se spojite na WiFi broda';

  @override
  String get autoDetectWifiHintBody =>
      'Provjerite u Postavkama telefona → WiFi da ste spojeni na mrežu brodskih instrumenata (npr. RayNet, WiFi-1). Aplikacija će zatim pokušati automatski pronaći pristupnik na toj mreži.';

  @override
  String get openWifiSettings => 'WiFi postavke';

  @override
  String get continueAction => 'Nastavi';

  @override
  String get autoDetecting => 'Tražim instrumente na WiFi mreži…';

  @override
  String get autoDetectFailed =>
      'Pristupnik nije pronađen u blizini. Provjerite jeste li na WiFi mreži broda ili ručno unesite IP u Postavkama.';

  @override
  String autoDetectSuccess(String host) {
    return 'Povezano s $host';
  }

  @override
  String get guidePromptTitle => 'Prvi put ovdje? Brzi vodič';

  @override
  String get guidePromptBody =>
      'Aplikacija sadrži kratak korisnički vodič – karta, dnevnik, vrijeme, sigurnosna lista i više. Želite li ga brzo pogledati? Uvijek ga možete naći poslije pod Postavke → Korisnički vodič.';

  @override
  String get guidePromptAction => 'Prikaži vodič';

  @override
  String get notifPromptTitle => 'Dopustiti obavijesti?';

  @override
  String get notifPromptBody =>
      'Dok se plovidba prati, obavijest ostaje u traci stanja i na zaključanom zaslonu — tako vidite da je praćenje aktivno i brzo mu pristupate. Bez dopuštenja sustav može ograničiti praćenje u pozadini.';

  @override
  String get notifPromptAllow => 'Dopusti';

  @override
  String get trackingActiveTitle => 'Praćenje aktivno';

  @override
  String get trackingTitle => 'Praćenje';

  @override
  String get waitingForGps => 'Čekam GPS...';

  @override
  String get gpsUnavailable => 'GPS nije dostupan';

  @override
  String get lastKnownPosition => 'Zadnja poznata pozicija';

  @override
  String get accuracy => 'Točnost';

  @override
  String get logbookBtn => 'Dnevnik';

  @override
  String get stop => 'Zaustavi';

  @override
  String get stopTrackingDay => 'Zaustaviti praćenje?';

  @override
  String get startVoyage => 'Započni plovidbu';

  @override
  String get starting => 'Pokretanje...';

  @override
  String get newVoyage => 'Nova plovidba';

  @override
  String get multiday => 'Višednevna';

  @override
  String get standalone => 'Samostalna';

  @override
  String get voyageName => 'Naziv plovidbe';

  @override
  String get voyageNameOptional => 'Naziv (neobavezno)';

  @override
  String get voyageNameHint => 'npr. Izlet po zaljevu';

  @override
  String get existingVoyage => 'Nastavi postojeću plovidbu';

  @override
  String get newVoyageDropdown => '— Nova plovidba —';

  @override
  String get firstVoyageHint => 'Prva plovidba – ispunite osnovne podatke:';

  @override
  String get briefingRequiredHint =>
      'Praćenje se može pokrenuti tek nakon što je Sigurnosna instruktaža za ovu plovidbu dovršena.';

  @override
  String get briefingPending => 'SI potrebna';

  @override
  String get briefingPendingListWarning =>
      'Sigurnosna instruktaža nije dovršena – praćenje se još ne može pokrenuti';

  @override
  String get estimatedDays => 'Predviđeni broj dana:';

  @override
  String get logFrequency => 'Učestalost zapisa u dnevnik';

  @override
  String get startTracking => 'Pokreni praćenje';

  @override
  String get trackingInProgress => 'Pratite svoju plovidbu';

  @override
  String dayNofTotal(int n, int total) {
    return 'Dan $n od $total';
  }

  @override
  String get newDay => '(novi dan)';

  @override
  String get endVoyageTitle => 'Završiti plovidbu?';

  @override
  String get endVoyageContent =>
      'Dosegli ste zadnji planirani dan plovidbe.\n\nHoće li se plovidba nastaviti sutra?';

  @override
  String get decideLayer => 'Odluči kasnije';

  @override
  String get continuesTomorrow => 'Nastavlja se sutra';

  @override
  String get endVoyage => 'Završi plovidbu';

  @override
  String get newMultidayVoyage => 'Nova višednevna plovidba';

  @override
  String get deleteCharterTitle => 'Obrisati charter?';

  @override
  String get deleteCharterContent => 'Svi dani i zapisi bit će obrisani.';

  @override
  String get cannotDeleteWhileTracking =>
      'Plovidbu nije moguće obrisati dok je praćenje aktivno.';

  @override
  String get noVoyages => 'Nema plovidbi';

  @override
  String get createFirstCharter => 'Kreirajte svoj prvi charter';

  @override
  String get briefingDone => 'Instruktaža ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Plovidba nije pronađena';

  @override
  String get unknownVessel => 'Nepoznato plovilo';

  @override
  String get captain => 'Skiper';

  @override
  String get crew => 'Posada';

  @override
  String get total => 'Ukupno';

  @override
  String voyageDaysCount(int n) {
    return 'Dani plovidbe ($n)';
  }

  @override
  String get bulkDelete => 'Skupno brisanje';

  @override
  String get noDays =>
      'Nema dana.\nPokrenite praćenje i prvi dan bit će kreiran automatski.';

  @override
  String get deleteDayTitle => 'Obrisati dan?';

  @override
  String deleteDayContent(String day) {
    return 'Svi zapisi za $day bit će obrisani.';
  }

  @override
  String get exportPdf => 'Izvezi PDF';

  @override
  String get selectDaysTitle => 'Odaberite dane za brisanje';

  @override
  String deleteCount(int n) {
    return 'Obriši ($n)';
  }

  @override
  String get safety => 'Sigurnost';

  @override
  String get mobHoldToActivate => 'Držite za aktivaciju';

  @override
  String get mobActive => '⚠️ MOB AKTIVAN';

  @override
  String get mobTime => 'Vrijeme';

  @override
  String get mobDistance => 'Udaljenost';

  @override
  String get mobDirection => 'Smjer';

  @override
  String get navigateToMob => 'Navigiraj do MOB-a';

  @override
  String get gpsPositionNotAvailable => 'GPS pozicija nije dostupna!';

  @override
  String get anchorAlarm => 'Alarm sidra';

  @override
  String get drifting => 'ORANJE';

  @override
  String get anchorRadiusLabel => 'Radijus sidrenja';

  @override
  String get activate => 'Aktiviraj';

  @override
  String get deactivate => 'Deaktiviraj';

  @override
  String get safetyBriefingCard => 'Sigurnosna instruktaža';

  @override
  String get maydayCard => 'Mayday kartica';

  @override
  String get yachtHandover => 'Primopredaja jahte';

  @override
  String get gearList => 'Popis opreme';

  @override
  String get pdfEntriesSection => 'Zapisi u dnevniku';

  @override
  String get pdfSkipperMessage => 'Izvješće skipera';

  @override
  String get pdfWeatherSection => 'Vrijeme';

  @override
  String get pdfDaySummary => 'Dnevni sažetak';

  @override
  String get pdfDaysOverview => 'Pregled dana';

  @override
  String get pdfVoyageSummary => 'Sažetak plovidbe';

  @override
  String get pdfCrewSection => 'Posada';

  @override
  String get pdfSignatures => 'Potpisi';

  @override
  String get pdfCrewSignatures => 'Potpisi posade';

  @override
  String get pdfSkipperSignature => 'Potpis skipera';

  @override
  String get pdfSkipperLicences => 'Skiper – ovlaštenja';

  @override
  String get pdfSafetyBriefing => 'Sigurnosna instruktaža';

  @override
  String get pdfChecklistSection => 'Kontrolna lista';

  @override
  String get pdfMoreNotes => 'Dodatne napomene';

  @override
  String get pdfIntegrityCheck => 'Provjera cjelovitosti dokumenta';

  @override
  String get pdfHandoverTitle => 'Zapisnik o primopredaji';

  @override
  String get pdfMilesTitle => 'Potvrda o preplovljenim miljama';

  @override
  String get pdfDeparture => 'Isplovljenje';

  @override
  String get pdfArrival => 'Uplovljenje';

  @override
  String get pdfTotalLabel => 'Ukupno';

  @override
  String get pdfDayCount => 'Dana';

  @override
  String get pdfEngineHours => 'Sati motora';

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
  String get pdfColTimeUtc => 'Vrijeme UTC';

  @override
  String get pdfColWind => 'Vjetar';

  @override
  String get pdfColPropulsion => 'Pogon';

  @override
  String get pdfColWeatherShort => 'Vrij.';

  @override
  String get pdfColNote => 'Napomena';

  @override
  String get pdfColDay => 'Dan';

  @override
  String get pdfColItem => 'Stavka';

  @override
  String get pdfColStatus => 'Status';

  @override
  String get pdfColNotePosition => 'Napomena / pozicija';

  @override
  String get pdfColPhoto => 'Foto';

  @override
  String get pdfColDateRange => 'Datum od-do';

  @override
  String get pdfColArea => 'Područje';

  @override
  String get pdfColRole => 'Uloga';

  @override
  String get pdfNoData => 'Nema podataka';

  @override
  String get pdfMapUnavailable => 'GPS karta nije dostupna';

  @override
  String get pdfUnsigned => 'Nepotpisano';

  @override
  String get pdfNoSignatures => 'Nema potpisa';

  @override
  String get pdfSha256Label => 'SHA-256 sažetak podataka dnevnika:';

  @override
  String get pdfVerifyQr => 'QR za provjeru';

  @override
  String get pdfSbLifejackets => 'Prsluci za spašavanje – lokacija i uporaba';

  @override
  String get pdfSbLifebuoy => 'Kolut za spašavanje i MOB postupak';

  @override
  String get pdfSbFlares => 'Signalne rakete – vrste i uporaba';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – aktivacija';

  @override
  String get pdfSbVhf => 'VHF radio – kanal 16, Mayday postupak';

  @override
  String get pdfSbExtinguisher => 'Vatrogasni aparat – lokacija i uporaba';

  @override
  String get pdfSbFirstAid => 'Kutija prve pomoći – lokacija';

  @override
  String get pdfSbEngineStop => 'Nužno zaustavljanje motora';

  @override
  String get pdfSbLeaks => 'Propuštanja – voda, plin';

  @override
  String get pdfSbAnchor => 'Sidro i lanac – postupak sidrenja';

  @override
  String get pdfSbRules => 'Pravila na brodu';

  @override
  String get pdfSbEmergencyContacts => 'Hitni kontakti i VHF 16';

  @override
  String get pdfBriefingDeclaration =>
      'Svi članovi posade upoznati su sa sigurnosnim pravilima, razumjeli su ih i to potvrđuju potpisom.';

  @override
  String get pdfHashCoverage =>
      'Sažetak obuhvaća naziv plovidbe, plovilo, posadu i svaki zapis (UTC vrijeme, GPS, brzina, kurs). Svaka promjena podataka mijenja sažetak.';

  @override
  String get pdfForCharterCompany => 'Za charter tvrtku';

  @override
  String get dutyRoster => 'Posada na straži';

  @override
  String get dutyStartAction => 'Preuzmi stražu';

  @override
  String get dutyEndAction => 'Završi';

  @override
  String get dutyStartTitle => 'Tko preuzima stražu?';

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
  String get dutyNobodyOnDuty => 'Nitko nije na straži';

  @override
  String get dutyInspectionView => 'Prikaži za inspekciju';

  @override
  String get dutyRosterHistory => 'Raspored straža';

  @override
  String get dutyAddRetrospective => 'Dodaj prošlu stražu';

  @override
  String get dutyEditTitle => 'Uredi stražu';

  @override
  String get dutyDeleteTitle => 'Obrisati stražu?';

  @override
  String dutyDeleteConfirm(String name) {
    return 'Zapis o straži za $name bit će obrisan.';
  }

  @override
  String get dutyNoCrewDefined => 'Za ovu plovidbu nije definirana posada';

  @override
  String get dutyDefineCrew => 'Dodaj posadu';

  @override
  String get dutyErrorEndBeforeStart => 'Kraj mora biti nakon početka.';

  @override
  String dutyErrorOverlap(String name) {
    return '$name je u to vrijeme već na straži.';
  }

  @override
  String get dutyErrorFutureStart => 'Početak ne može biti u budućnosti.';

  @override
  String get dutyNoteLabel => 'Napomena';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'Na straži $hours h — je li ostala otvorena?';
  }

  @override
  String get dutyFrom => 'Od';

  @override
  String get dutyTo => 'Do';

  @override
  String get dutyToOngoing => '— još na straži';

  @override
  String get dutySelectPerson => 'Odaberite člana posade';

  @override
  String get dutyNoRecords => 'Još nema zabilježenih straža';

  @override
  String get logDutySection => 'Posada na straži';

  @override
  String get logDutyStillRunning => 'u tijeku';

  @override
  String get logEventAnchorDropped => 'Sidro spušteno';

  @override
  String get logEventAnchorRaised => 'Sidro podignuto';

  @override
  String get logEventDriftOut => 'Oranje – prekoračen perimetar';

  @override
  String get logEventDriftIn => 'Oranje – plovilo se vratilo';

  @override
  String logEventDutyStart(String name) {
    return 'Preuzeo stražu: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Predao stražu: $name';
  }

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Hitni kontakti';

  @override
  String get backToToc => 'Natrag na sadržaj';

  @override
  String get briefingComplete => 'Instruktaža dovršena';

  @override
  String get updateByPosition => 'Ažuriraj prema lokaciji';

  @override
  String get detectedByGps => 'otkriveno GPS-om';

  @override
  String get locationUnavailable =>
      '📍 Lokacija nije dostupna – prikazani su globalni kontakti';

  @override
  String get detectingLocation => 'Otkrivanje lokacije...';

  @override
  String get tapToCall => 'Dodirnite za poziv';

  @override
  String cannotCall(String name) {
    return 'Nije moguće nazvati: $name';
  }

  @override
  String get vhfChannel16 => 'VHF kanal 16 – koristite brodsku radiostanicu';

  @override
  String get hmbHandbook => 'HMB priručnik';

  @override
  String get checkInLabel => 'Check-in (preuzimanje broda)';

  @override
  String get checkOutLabel => 'Check-out (predaja broda)';

  @override
  String get charterCheckCard => 'Charter';

  @override
  String get weatherTitle => 'Vrijeme i more';

  @override
  String get updateForecast => 'Ažuriraj prognozu';

  @override
  String get gpsNotAvailableTracking =>
      'GPS nije dostupan – uključite praćenje';

  @override
  String get downloadingForecast => 'Preuzimanje prognoze...';

  @override
  String get loadingForecast => 'Učitavanje prognoze...';

  @override
  String get noConnection => 'Veza nije dostupna';

  @override
  String get pressRefreshWhenOnline => 'Pritisnite osvježi kad ste na mreži';

  @override
  String get noWeatherData => 'Nema podataka o vremenu';

  @override
  String get forecastAutoDownload =>
      'Prognoza će se preuzeti automatski kad počne praćenje ili pritisnite Osvježi.';

  @override
  String get enableGpsFirst => 'Najprije uključite GPS / praćenje';

  @override
  String get downloadForecast => 'Preuzmi prognozu';

  @override
  String downloadError(String error) {
    return 'Greška pri preuzimanju: $error';
  }

  @override
  String get liveInstrumentData => 'Podaci brodskih instrumenata uživo';

  @override
  String get windRelative => 'Vjetar (rel.)';

  @override
  String get windTrue => 'Vjetar (pravi)';

  @override
  String get depthLabel => 'Dubina';

  @override
  String get waterTempLabel => 'Temp. mora';

  @override
  String get courseTrue => 'Kurs (pravi)';

  @override
  String get courseMag => 'Kurs (magn.)';

  @override
  String get engineLabel => 'Motor';

  @override
  String get wavesLabel => 'Valovi';

  @override
  String get pressureLabel => 'Tlak';

  @override
  String get airTempLabel => 'Zrak';

  @override
  String get waterLabel => 'More';

  @override
  String get wind24h => 'Vjetar – 3 dana';

  @override
  String get waves24h => 'Valovi – 3 dana';

  @override
  String get hourlyForecast => 'Trodnevna prognoza';

  @override
  String get dailyForecast => 'Dnevna temperatura';

  @override
  String get timeCol => 'Vrijeme';

  @override
  String get windCol => 'Vjetar';

  @override
  String get wavesCol => 'Valovi';

  @override
  String get rainCol => 'Kiša';

  @override
  String get beaufort0 => 'Tišina';

  @override
  String get beaufort1 => 'Lahor';

  @override
  String get beaufort2 => 'Povjetarac';

  @override
  String get beaufort3 => 'Slab vjetar';

  @override
  String get beaufort4 => 'Umjeren vjetar';

  @override
  String get beaufort5 => 'Umjereno jak vjetar';

  @override
  String get beaufort6 => 'Jak vjetar';

  @override
  String get beaufort7 => 'Žestok vjetar';

  @override
  String get beaufort8 => 'Olujni vjetar';

  @override
  String get beaufort9 => 'Jak olujni vjetar';

  @override
  String get beaufort10 => 'Orkanski vjetar';

  @override
  String get beaufort11 => 'Jak orkanski vjetar';

  @override
  String get beaufort12 => 'Orkan';

  @override
  String get sunAndMoonCard => 'Sunce i Mjesec';

  @override
  String get sunriseLabel => 'Izlazak sunca';

  @override
  String get sunsetLabel => 'Zalazak sunca';

  @override
  String get moonPhaseLabel => 'Mjesečeva mijena';

  @override
  String get moonIlluminationLabel => 'Osvijetljeno';

  @override
  String get moonPhaseNew => 'Mlađak';

  @override
  String get moonPhaseWaxingCrescent => 'Mladi srp';

  @override
  String get moonPhaseFirstQuarter => 'Prva četvrt';

  @override
  String get moonPhaseWaxingGibbous => 'Rastući grbavi Mjesec';

  @override
  String get moonPhaseFull => 'Uštap';

  @override
  String get moonPhaseWaningGibbous => 'Opadajući grbavi Mjesec';

  @override
  String get moonPhaseLastQuarter => 'Zadnja četvrt';

  @override
  String get moonPhaseWaningCrescent => 'Stari srp';

  @override
  String get noSunMoonGps =>
      'Za izlazak/zalazak sunca potrebna je GPS pozicija';

  @override
  String get oceanCurrentsTitle => 'Oceanske struje';

  @override
  String get oceanCurrentsTooltip => 'Oceanske struje';

  @override
  String get oceanCurrentsDisclaimer =>
      'Samo referentni podaci (tipičan smjer/brzina iz pilotnih karata) — nisu za preciznu navigaciju; struje se mijenjaju sezonski.';

  @override
  String get tideCardTitle => 'Plima i oseka';

  @override
  String get nextHighTideLabel => 'Sljedeća plima';

  @override
  String get nextLowTideLabel => 'Sljedeća oseka';

  @override
  String get noTideData => 'Još nema podataka o plimi';

  @override
  String get downloadTides => 'Preuzmi prognozu plime';

  @override
  String get downloadingTides => 'Preuzimanje prognoze plime...';

  @override
  String get tideMslWarning =>
      'Visine su iznad srednje razine mora, ne iznad hidrografske nule — nikada ih ne koristite za dubinu ispod kobilice.';

  @override
  String get tideNoCoverage =>
      'Nema podataka o plimi za ovu poziciju — izvan je područja pomorske prognoze.';

  @override
  String get tideDownloadFailed =>
      'Prognozu plime nije bilo moguće preuzeti. Provjerite vezu i pokušajte ponovno.';

  @override
  String get tideForecastExpired => 'Spremljena prognoza plime je istekla.';

  @override
  String tideForecastFarAway(int km) {
    return 'Prognoza je preuzeta $km km odavde — preuzmite je ponovno za ovu poziciju.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Preuzeto $when — preuzmite ponovno za najnoviju prognozu.';
  }

  @override
  String get oceanCurrentCardTitle => 'Morska struja';

  @override
  String get oceanCurrentSetsToward => 'Teče prema (brzina u čvorovima)';

  @override
  String get oceanCurrentNoCoverage =>
      'Nema podataka o struji za ovu poziciju.';

  @override
  String get oceanCurrentUnavailable =>
      'Prognoza struje nije dostupna — provjerite vezu.';

  @override
  String get tideOtherArea => 'Prognoza za drugo područje';

  @override
  String get tideAreaSearchLabel => 'Luka, grad ili uvala';

  @override
  String get tideAreaSearchHint => 'npr. Split';

  @override
  String get tideAreaNoResults =>
      'Ništa nije pronađeno — pokušajte s drugim nazivom.';

  @override
  String tideForecastForArea(String place) {
    return 'Prognoza za $place';
  }

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get measurementUnits => 'Mjerne jedinice';

  @override
  String get temperature => 'Temperatura';

  @override
  String get depthWaves => 'Dubina / valovi';

  @override
  String get wind => 'Vjetar';

  @override
  String get language => 'Jezik';

  @override
  String get appLanguage => 'Jezik aplikacije';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get displaySettings => 'Prikaz';

  @override
  String get nightMode => 'Noćni način';

  @override
  String get nightModeDesc => 'Crveni filtar za očuvanje noćnog vida';

  @override
  String get aboutApp => 'O aplikaciji';

  @override
  String get backupSection => 'Sigurnosna kopija podataka';

  @override
  String get exportBackup => 'Izvezi sigurnosnu kopiju';

  @override
  String get exportBackupDesc =>
      'Sprema cijeli dnevnik (plovidbe, zapise, postavke) u jednu datoteku';

  @override
  String get restoreBackup => 'Vrati iz sigurnosne kopije';

  @override
  String get restoreBackupDesc =>
      'Zamjenjuje trenutne podatke sadržajem odabrane datoteke sigurnosne kopije';

  @override
  String get restoreBlockedTrackingTitle => 'GPS praćenje je u tijeku';

  @override
  String get restoreBlockedTrackingBody =>
      'Zaustavite aktivno praćenje plovidbe prije vraćanja sigurnosne kopije.';

  @override
  String get restoreSchemaTooNewTitle =>
      'Sigurnosna kopija je iz novije verzije';

  @override
  String get restoreSchemaTooNewBody =>
      'Ova sigurnosna kopija stvorena je novijom verzijom aplikacije od trenutno instalirane. Najprije ažurirajte aplikaciju.';

  @override
  String get restoreConfirmTitle => 'Vratiti iz sigurnosne kopije?';

  @override
  String get restoreConfirmBody =>
      'Trenutni podaci bit će zamijenjeni sadržajem sigurnosne kopije. Sigurnosna kopija trenutnog stanja bit će automatski stvorena prije toga.';

  @override
  String get restoreSuccess =>
      'Podaci su uspješno vraćeni iz sigurnosne kopije.';

  @override
  String get restoreInvalidFile =>
      'Odabrana datoteka nije valjana sigurnosna kopija HMB Sailing Loga.';

  @override
  String get milesBookTitle => 'Knjiga milja';

  @override
  String get totalNm => 'Ukupno NM';

  @override
  String get daysAtSea => 'Dana na moru';

  @override
  String get voyageCount => 'Broj plovidbi';

  @override
  String get nightHoursLabel => 'Noćni sati';

  @override
  String get byYear => 'Po godini';

  @override
  String get byVessel => 'Po plovilu';

  @override
  String get addHistoricalVoyage => 'Dodaj prošlu plovidbu';

  @override
  String get editHistoricalVoyage => 'Uredi prošlu plovidbu';

  @override
  String get deleteHistoricalVoyageConfirm => 'Obrisati ovu prošlu plovidbu?';

  @override
  String get manualEntryExplanation => '* ručni unos (unesen rukom)';

  @override
  String get roleLabel => 'Uloga na brodu';

  @override
  String get roleSkipper => 'Skiper';

  @override
  String get roleCoSkipper => 'Suskiper';

  @override
  String get roleCrew => 'Posada';

  @override
  String get areaLabel => 'Područje / ruta';

  @override
  String get distanceNmLabel => 'Udaljenost (NM)';

  @override
  String get daysCountLabel => 'Broj dana';

  @override
  String get milesCertificateTitle => 'Potvrda o preplovljenim miljama';

  @override
  String get logbookRecordTitle => 'Zapis u dnevniku';

  @override
  String get logbookTrackedHint =>
      'Datumi, milje, područje i uloga izračunavaju se iz praćenja/uvoza.';

  @override
  String get vesselFlag => 'Zastava upisa';

  @override
  String get captainFirstName => 'Ime skipera';

  @override
  String get captainLastName => 'Prezime skipera';

  @override
  String get captainQualification => 'Najviše stečeno ovlaštenje';

  @override
  String get logbookSignatureSection => 'Potpis kojim se potvrđuju milje';

  @override
  String get addSignature => 'Dodaj potpis';

  @override
  String get filterAllYears => 'Sve godine';

  @override
  String get filterCustomRange => 'Prilagođeni raspon';

  @override
  String get handoverMenuTitle => 'Zapisnik o primopredaji';

  @override
  String get checkInProtocol => 'Zapisnik o preuzimanju';

  @override
  String get checkOutProtocol => 'Zapisnik o predaji';

  @override
  String get nextStepLabel => 'Sljedeći korak';

  @override
  String get readyToTrackHint => 'Spremno za pokretanje praćenja';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Korak $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Sigurnosna\ninstruktaža';

  @override
  String get handoverChecklistShort => 'Lista\nprimopredaje';

  @override
  String get safetyBriefingRefTitle => 'Sigurnosna instruktaža';

  @override
  String get handoverChecklistRefTitle => 'Lista primopredaje';

  @override
  String get handoverDateTime => 'Datum i vrijeme';

  @override
  String get handoverLocation => 'Mjesto (marina)';

  @override
  String get checklistItemOk => 'U redu';

  @override
  String get checklistItemDamaged => 'Oštećeno';

  @override
  String get checklistItemMissing => 'Nedostaje';

  @override
  String get damagePosition => 'Pozicija na brodu';

  @override
  String get newDamageBadge => 'NOVO OŠTEĆENJE';

  @override
  String get companySignatureSection => 'Potpis predstavnika charter tvrtke';

  @override
  String get companyRepName => 'Ime predstavnika';

  @override
  String get companyNameLabel => 'Naziv tvrtke';

  @override
  String get protocolClosedNotice =>
      'Zapisnik je zaključen (obje strane potpisale) – samo za čitanje.';

  @override
  String get handoverCertTitle => 'Zapisnik o primopredaji plovila';

  @override
  String get itemSails => 'Jedra';

  @override
  String get itemRigging => 'Oputa';

  @override
  String get itemAnchorChain => 'Sidro i lanac';

  @override
  String get itemNavInstruments => 'Navigacijski instrumenti';

  @override
  String get itemLifeJackets => 'Prsluci za spašavanje';

  @override
  String get itemRaft => 'Splav za spašavanje';

  @override
  String get itemFirstAidKit => 'Kutija prve pomoći';

  @override
  String get itemDinghyMotor => 'Gumenjak i vanbrodski motor';

  @override
  String get itemLights => 'Svjetla';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Dodatne napomene';

  @override
  String get gpxImportTitle => 'GPX uvoz';

  @override
  String get gpxImportPickFile => 'Odaberi GPX datoteku';

  @override
  String get gpxTracksFound => 'Pronađenih tragova';

  @override
  String get gpxWaypointsFound => 'Pronađenih točaka rute';

  @override
  String get gpxAssignTarget => 'Dodijeli plovidbi';

  @override
  String get gpxNewVoyage => 'Nova plovidba';

  @override
  String get gpxImportButton => 'Uvezi';

  @override
  String get gpxImportSuccess => 'GPX je uspješno uvezen.';

  @override
  String get connectionConnected => 'Povezano';

  @override
  String get connectionConnecting => 'Povezivanje...';

  @override
  String get connectionError => 'Greška veze';

  @override
  String get connectionDisconnected =>
      'Odspojeno (koristi se GPS telefona / prognoza)';

  @override
  String get ipAddressLabel => 'IP adresa pristupnika';

  @override
  String get portLabel => 'Port';

  @override
  String get autoConnectLabel => 'Automatsko povezivanje pri pokretanju';

  @override
  String get disconnect => 'Odspoji';

  @override
  String get connect => 'Poveži';

  @override
  String get gatewayHint =>
      'Spojite telefon na Raymarine WiFi mrežu (npr. WiFi-1, RayNet). IP koji treba unijeti NIJE IP prikazan u Raymarine postavkama — to je IP pristupnika te WiFi mreže. Pronađite ga na telefonu: Postavke → WiFi → detalji mreže → Pristupnik. Port 2000 (TCP) je standardan. Bez veze aplikacija automatski koristi GPS telefona.';

  @override
  String connectedToHost(String host, int port) {
    return 'Povezano s $host:$port';
  }

  @override
  String get enterIpAddress => 'Unesite IP adresu pristupnika';

  @override
  String connectionFailed(String error) {
    return 'Povezivanje nije uspjelo: $error';
  }

  @override
  String get liveWind => 'Vjetar';

  @override
  String get liveDepth => 'Dubina';

  @override
  String get liveWaterTemp => 'Temp. mora';

  @override
  String get liveCompass => 'Kompas';

  @override
  String get liveEngine => 'Motor';

  @override
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Port za slušanje';

  @override
  String get startListening => 'Pokreni';

  @override
  String get stopListening => 'Zaustavi';

  @override
  String connectionListening(String port) {
    return 'Slušam UDP na portu $port';
  }

  @override
  String udpHint(String port) {
    return 'Postavite simulator/pristupnik da šalje UDP na IP ovog telefona, port $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Slušam na UDP portu $port';
  }

  @override
  String get dayNotFound => 'Dan nije pronađen';

  @override
  String get saved => 'Spremljeno';

  @override
  String get trackingThisDay => 'Praćenje je aktivno za ovaj dan';

  @override
  String get trackingOtherDay => 'Praćenje je aktivno za drugi dan';

  @override
  String recordCount(int n) {
    return '$n zapisa';
  }

  @override
  String get addManual => 'Dodaj ručno';

  @override
  String get noEntries => 'Nema zapisa';

  @override
  String get entriesAutoAdded => 'Zapisi se dodaju automatski tijekom praćenja';

  @override
  String get deleteEntryTitle => 'Obrisati zapis?';

  @override
  String get autoRecord => 'Automatski zapis';

  @override
  String get routeSection => 'Ruta';

  @override
  String get fromPort => 'Od';

  @override
  String get toPort => 'Do';

  @override
  String get distance => 'Udaljenost';

  @override
  String get vessel => 'Plovilo';

  @override
  String get weatherSection => 'Vrijeme';

  @override
  String get morning => 'Jutro';

  @override
  String get noon => 'Podne';

  @override
  String get evening => 'Večer';

  @override
  String get windDir => 'Smjer vjetra';

  @override
  String get seaState => 'Stanje mora';

  @override
  String get waveHeight => 'Visina valova';

  @override
  String get dailyNote => 'Dnevni zapis';

  @override
  String get dailyNoteHint =>
      'Opis plovidbe, istaknuti trenuci, događaji dana...';

  @override
  String get seaCalm => 'Mirno';

  @override
  String get seaLight => 'Malo valovito';

  @override
  String get seaModerate => 'Umjereno valovito';

  @override
  String get seaRough => 'Uzburkano';

  @override
  String get seaStormy => 'Olujno';

  @override
  String get editEntry => 'Uredi zapis';

  @override
  String get newEntry => 'Novi zapis';

  @override
  String get sailMode => 'Način plovidbe';

  @override
  String get sailMain => 'Grot';

  @override
  String get navigationSection => 'Navigacija';

  @override
  String get latitude => 'Geografska širina';

  @override
  String get longitude => 'Geografska dužina';

  @override
  String get weatherSeaSection => 'Vrijeme i more';

  @override
  String get windSpeed => 'Vjetar';

  @override
  String get windDirection => 'Smjer';

  @override
  String get waveHeight2 => 'Visina valova';

  @override
  String get engineSection => 'Motor i tankovi';

  @override
  String get engineHours => 'Sati motora';

  @override
  String get fuel => 'Gorivo';

  @override
  String get fuelLevel => 'Razina goriva';

  @override
  String get waterLevel => 'Razina vode';

  @override
  String get noteSection => 'Napomena';

  @override
  String get noteHint => 'Uvjeti plovidbe, događaji, izmjena posade...';

  @override
  String get quickPhotoLogTitle => 'Brzi zapis u dnevnik';

  @override
  String get quickPhotoNoteHint => 'Što je ovo? (neobavezno)';

  @override
  String get exportDayTitle => 'Izvoz dana';

  @override
  String get exportCharterTitle => 'Izvoz chartera';

  @override
  String get loadingData => 'Učitavanje podataka...';

  @override
  String get mapsReady => 'Karte su spremne – možete izvesti';

  @override
  String generatingMaps(int current, int total) {
    return 'Generiranje pregleda karata ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Izvezi dan';

  @override
  String get exportCharterBtn => 'Izvezi charter';

  @override
  String get entriesLabel => 'Zapisi';

  @override
  String get routePoints => 'Točke rute';

  @override
  String get anchorDriftTitle => '⚓ SIDRO ORE!';

  @override
  String get anchorDriftContent =>
      'Plovilo je prekoračilo perimetar sidrenja.\nOdmah provjerite poziciju!';

  @override
  String get cancelAnchor => 'Poništi sidro';

  @override
  String get stopAlarm => 'Zaustavi alarm';

  @override
  String get briefingItem1 => 'Prsluci za spašavanje – lokacija i uporaba';

  @override
  String get briefingItem2 => 'Kolut za spašavanje i MOB postupak';

  @override
  String get briefingItem3 => 'Signalne rakete – vrste i uporaba';

  @override
  String get briefingItem4 => 'EPIRB / PLB – aktivacija';

  @override
  String get briefingItem5 => 'VHF radio – kanal 16, Mayday postupak';

  @override
  String get briefingItem6 => 'Vatrogasni aparat – lokacija i uporaba';

  @override
  String get briefingItem7 => 'Kutija prve pomoći – lokacija';

  @override
  String get briefingItem8 => 'Nužno zaustavljanje motora';

  @override
  String get briefingItem9 => 'Propuštanja – voda, plin';

  @override
  String get briefingItem10 => 'Sidro i lanac – postupak sidrenja';

  @override
  String get briefingItem11 => 'Pravila na brodu';

  @override
  String get briefingItem12 => 'Hitni kontakti i VHF 16';

  @override
  String get checkInItem1 => 'Dokumenti broda (upis, osiguranje)';

  @override
  String get checkInItem2 => 'Sigurnosna oprema – kompletna';

  @override
  String get checkInItem3 => 'Zalihe goriva';

  @override
  String get checkInItem4 => 'Zalihe vode';

  @override
  String get checkInItem5 => 'Sidro i lanac – provjera';

  @override
  String get checkInItem6 => 'Motor – probni rad';

  @override
  String get checkInItem7 => 'Navigacijski instrumenti';

  @override
  String get checkInItem8 => 'Oputa – konopi i jedra';

  @override
  String get checkInItem9 => 'Kuhinja – plin, štednjak';

  @override
  String get checkInItem10 => 'Toalet – ispravnost';

  @override
  String get checkInItem11 => 'Postojeća oštećenja – fotodokumentacija';

  @override
  String get checkOutItem1 => 'Brod očišćen – vanjski dio';

  @override
  String get checkOutItem2 => 'Brod očišćen – unutrašnjost';

  @override
  String get checkOutItem3 => 'Gorivo nadopunjeno';

  @override
  String get checkOutItem4 => 'Voda nadopunjena';

  @override
  String get checkOutItem5 => 'Smeće uklonjeno';

  @override
  String get checkOutItem6 => 'Oštećenja prijavljena';

  @override
  String get checkOutItem7 => 'Ključevi predani';

  @override
  String get gearListShort => 'Osobna\noprema';

  @override
  String get colregRules => 'COLREG\npravila';

  @override
  String get checkInShort => 'Check-in\nPreuzimanje';

  @override
  String get checkOutShort => 'Check-out\nPredaja';

  @override
  String get appTagline => 'Vaš pouzdani brodski dnevnik';

  @override
  String exportSavedMsg(String path) {
    return 'Spremljeno: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Spremljeno: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Greška pri izvozu: $error';
  }

  @override
  String get generatingPdf => 'Generiranje PDF-a...';

  @override
  String get colregTitle => 'COLREG – Pravila izbjegavanja sudara na moru';

  @override
  String get tableOfContents => 'SADRŽAJ';

  @override
  String get inThisChapter => 'U ovom poglavlju:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Pravilo $n';
  }

  @override
  String get resetChecklistTitle => 'Poništiti kontrolnu listu?';

  @override
  String get resetChecklistContent => 'Sve kvačice bit će obrisane.';

  @override
  String get reset => 'Poništi';

  @override
  String get checkInReceivingTitle => 'Check-in – Preuzimanje broda';

  @override
  String get checkOutHandoverTitle => 'Check-out – Predaja broda';

  @override
  String get checkInCompletedMsg => 'Brod preuzet – sve provjereno ✓';

  @override
  String get checkOutCompletedMsg => 'Brod vraćen – sve u redu ✓';

  @override
  String get briefingDoneMsg => 'Instruktaža dovršena – posada informirana';

  @override
  String get sectionBriefed => 'Dio odrađen ✓';

  @override
  String get confirmSection => 'Potvrdi dio';

  @override
  String get gearListTitle => 'Osobna oprema';

  @override
  String get newCategory => 'Nova kategorija';

  @override
  String get add => 'Dodaj';

  @override
  String get deleteItemTitle => 'Obrisati stavku?';

  @override
  String get allPackedMsg => 'Sve spakirano, spremni za isplovljenje! 🎉';

  @override
  String get addItemLabel => 'Dodaj stavku';

  @override
  String addToCategoryTitle(String category) {
    return 'Dodaj u: $category';
  }

  @override
  String get newItemHint => 'Nova stavka...';

  @override
  String get addWaypoint => 'Dodaj točku rute';

  @override
  String get editWaypoint => 'Uredi točku rute';

  @override
  String get waypointNameLabel => 'Naziv';

  @override
  String get skipperSignature => 'Potpis skipera';

  @override
  String get skipperNameLabel => 'Ime skipera';

  @override
  String get signWithFinger => 'Potpišite prstom';

  @override
  String get clear => 'Očisti';

  @override
  String get signAndExport => 'Potpiši i izvezi';

  @override
  String get pleaseSign => 'Potpišite prije izvoza';

  @override
  String get generatingPdfPreview => 'Generiranje pregleda PDF-a...';

  @override
  String generationError(String error) {
    return 'Greška pri generiranju: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Spremanje i generiranje GPX-a...';

  @override
  String get editCharter => 'Uredi charter';

  @override
  String get basicInfo => 'Osnovni podaci';

  @override
  String get voyageNameRequired => 'Naziv plovidbe *';

  @override
  String get dateFrom => 'Datum od';

  @override
  String get dateTo => 'Datum do';

  @override
  String get vesselName => 'Naziv plovila';

  @override
  String get vesselType => 'Vrsta plovila';

  @override
  String get homePort => 'Matična luka';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Pozivni znak';

  @override
  String get vesselLengthM => 'Duljina (m)';

  @override
  String get vesselBeamM => 'Širina (m)';

  @override
  String get vesselDraftM => 'Gaz (m)';

  @override
  String get selectExistingVoyage => 'Odaberi postojeću plovidbu';

  @override
  String get newVoyageForm => 'Nova plovidba';

  @override
  String get fillFormAndBriefing =>
      'Ispunite obrazac i potpišite sigurnosnu instruktažu';

  @override
  String get notesLabel => 'Bilješke';

  @override
  String get statusLabel => 'Status';

  @override
  String get safetyBriefingDoneLabel => 'Sigurnosna instruktaža dovršena';

  @override
  String get checkInDoneLabel => 'Check-in dovršen';

  @override
  String get checkOutDoneLabel => 'Check-out dovršen';

  @override
  String get enterVoyageName => 'Unesite naziv plovidbe';

  @override
  String daysCount(int n) {
    return '$n dana';
  }

  @override
  String get selectTargetWaypoint => 'Odaberite ciljnu točku rute';

  @override
  String get noWaypoints => 'Nema točaka rute.';

  @override
  String get goToMap => 'Idi na kartu';

  @override
  String get noTarget => 'Nema cilja';

  @override
  String get selectWaypointHint => 'Navigiraj do točke rute';

  @override
  String get sessionStats => 'Statistika plovidbe';

  @override
  String get maxSpeed => 'Maks. brzina';

  @override
  String get avgSpeed => 'Prosj. brzina';

  @override
  String get sailingTime => 'Vrijeme plovidbe';

  @override
  String get gpsData => 'GPS podaci';

  @override
  String get gpsPosition => 'Pozicija';

  @override
  String get courseCog => 'Kurs (COG)';

  @override
  String get altitudeLabel => 'Nadmorska visina';

  @override
  String get dscProcedure => 'DSC POSTUPAK';

  @override
  String get voiceScript => 'GLASOVNI PREDLOŽAK';

  @override
  String get dscWarningUseOnly => '⚠️ KORISTITI SAMO U SLUČAJU';

  @override
  String get dscWarningDanger => 'OZBILJNE I NEPOSREDNE OPASNOSTI';

  @override
  String get dscWarningTypes => 'Požar · Potonuće · Čovjek u moru';

  @override
  String get dscProcedureSubtitle =>
      'Držite ovaj postupak uz VHF DSC radiostanicu';

  @override
  String get fillBeforeSailing => 'Ispunite prije isplovljenja:';

  @override
  String get copyTooltip => 'Kopiraj';

  @override
  String get scriptCopied => 'Predložak kopiran';

  @override
  String get sendOnCh16 =>
      '📻 Šaljite na kanalu 16 · Puna snaga · Ponavljajte svake 2 minute ako nema odgovora';

  @override
  String get enterAbove => '[unesite u polje iznad]';

  @override
  String get distressNature => 'Vrsta pogibli';

  @override
  String get vesselNameLabel => 'Naziv plovila';

  @override
  String get numberOfPersons => 'Broj osoba';

  @override
  String get additionalInfo => 'Dodatne informacije';

  @override
  String get voiceScriptTitle => 'GLASOVNI MAYDAY PREDLOŽAK';

  @override
  String get dscStep1 => 'Provjerite je li radiostanica uključena.';

  @override
  String get dscStep2 => 'Otvorite poklopac iznad CRVENE tipke za pogibelj.';

  @override
  String get dscStep3 => 'Pritisnite CRVENU tipku JEDNOM i pustite.';

  @override
  String get dscStep4 =>
      'Odaberite vrstu pogibli.\n(Požar, potonuće, MOB itd.)\nAko preskočite, poslat će se neodređena pogibelj.';

  @override
  String get dscStep5 =>
      'Pritisnite i DRŽITE CRVENU tipku 5 sekundi da biste poslali poziv.';

  @override
  String get dscStep6 =>
      'Pričekajte do 15 sekundi na potvrdu (prikazuje se na zaslonu), zatim pošaljite glasovnu poruku na kanalu 16 punom snagom.';

  @override
  String get appDescription => 'Profesionalni brodski dnevnik za jedriličare.';

  @override
  String get vesselIdTitle => 'Identifikacija plovila';

  @override
  String get vesselIdHint =>
      'Pozivni znak i MMSI automatski se ispunjavaju u Mayday kartici.';

  @override
  String get maritimeReference => 'Pomorski priručnik';

  @override
  String get phonetic => 'Fonetska abeceda';

  @override
  String get flagAlphabet => 'Signalne zastave';

  @override
  String get dayShapes => 'Dnevni znakovi';

  @override
  String get marineReferenceTile => 'Signali i abeceda';

  @override
  String get navInstruments => 'Brodski instrumenti';

  @override
  String get enterPort => 'Unesite luku...';

  @override
  String get closeWithoutSaving => 'Zatvori bez spremanja';

  @override
  String get saveToDevice => 'Spremi na uređaj';

  @override
  String get saveAndShare => 'Spremi i podijeli';

  @override
  String get timestampCannotBeChanged =>
      'Vrijeme zapisa nije moguće promijeniti';

  @override
  String entriesShort(int n) {
    return '$n zapisa';
  }

  @override
  String get mainsail => 'Grot';

  @override
  String get weatherConditionTitle => 'Vremenske prilike';

  @override
  String get weatherConditionLabel => 'Stanje';

  @override
  String get wcSunny => 'Sunčano';

  @override
  String get wcPartlyCloudy => 'Djelomično oblačno';

  @override
  String get wcOvercast => 'Oblačno';

  @override
  String get wcLightRain => 'Slaba kiša';

  @override
  String get wcRain => 'Kiša';

  @override
  String get wcHeavyRain => 'Jaka kiša';

  @override
  String get wcDrizzle => 'Rosulja';

  @override
  String get wcThunderstorm => 'Grmljavinsko nevrijeme';

  @override
  String get wcIsoThunderstorm => 'Izolirana grmljavina';

  @override
  String get wcHail => 'Tuča';

  @override
  String get wcDust => 'Prašina';

  @override
  String get wcFoggy => 'Maglovito';

  @override
  String get wcWindy => 'Vjetrovito';

  @override
  String get wcCold => 'Hladno';

  @override
  String get photoSection => 'Fotografija';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerija';

  @override
  String get addPhoto => 'Dodaj fotografiju';

  @override
  String get photoAddedToEntry => 'Fotografija priložena';

  @override
  String get voyageStart => 'Početak plovidbe';

  @override
  String get voyageEnd => 'Kraj plovidbe';

  @override
  String get onlineAccount => 'Mrežni račun';

  @override
  String get onlineAccountDesc => 'Mrežna sinkronizacija dnevnika — uskoro';

  @override
  String get register => 'Registracija';

  @override
  String get login => 'Prijava';

  @override
  String get logout => 'Odjava';

  @override
  String get logoutConfirm =>
      'Bit ćete odjavljeni. Podaci spremljeni na uređaju ostaju.';

  @override
  String get notLoggedIn => 'Niste prijavljeni';

  @override
  String get fullName => 'Ime i prezime';

  @override
  String get password => 'Lozinka';

  @override
  String get userGuide => 'Korisnički vodič';

  @override
  String get guideQuickStart => 'Brzi početak – 5 koraka';

  @override
  String get guideQuickStartBody =>
      '1. Dodirnite veliku tipku \"Započni plovidbu\" na vrhu (na Karti, u Dnevniku ili na Instrumentima) – odaberite učestalost zapisa i praćenje kreće, ništa drugo ne treba ispunjavati unaprijed\n2. Ako imate otvorenu plovidbu, aplikacija pita želite li je nastaviti ili započeti novi zapis\n3. Nedostajuće podatke (check-in, sigurnosna instruktaža, kartica plovila/posade) ispunite kad god želite – aplikacija vas podsjeća oznakama u Dnevniku\n4. Tijekom dana dodajte zapise: vrijeme, pozicija, napomena\n5. Na kraju plovidbe otvorite Postavke → Izvezi PDF\n\nAplikacija radi preko cijelog zaslona – povucite s gornjeg ili donjeg ruba da privremeno prikažete sistemske trake telefona.';

  @override
  String get guideMapTitle => 'Karta';

  @override
  String get guideMapBody =>
      'Kartica Karta prikazuje vašu trenutnu poziciju i trag plovidbe.\n\n• Plava točka = trenutna pozicija\n• Plava linija = trag koji se trenutno bilježi\n• Ikona rute – odaberite bilo koju plovidbu ili dan za pregled traga na karti (narančasto), bez potrebe za PDF izvozom\n• Prebacivanje između satelitskog i kartografskog prikaza\n• Pomorske oznake – uključite nautičke oznake (olupine, plićine, plutače)\n• Luke – sloj sidrišta, marina i luka na dodir (podaci OpenStreetMap): dodirnite ikonu za naziv, VHF kanal, telefon, web stranicu, dubinu ili kapacitet gdje su poznati; spremite mjesto kao točku rute jednim dodirom; sloj uključuje i pumpe za gorivo (narančasta pumpa)\n• Radar – sloj radara oborina (RainViewer), sličica se osvježava otprilike svakih 10 minuta\n• Vjetar – strelice smjera/brzine vjetra (čvorovi) u mreži preko vidljivog područja\n• Ravnalo (ljubičasta ikona) – dodirujte točke na karti: ukupno NM, azimut zadnje dionice i ETA pri trenutnoj brzini; točke se lijepe na točke rute pa možete mjeriti rutu kroz svoje ciljeve\n• Izvanmrežna karta (ikona preuzimanja) – preuzima vidljivo područje (karta + pomorske oznake, trenutni zum +3 razine) za uporabu bez signala; svaka pregledana pločica također se automatski sprema\n• U noćnom načinu karta automatski prelazi na tamne pločice\n• Ikona sidra = pozicija sidrenja (samo kad je alarm sidra aktivan)\n• Ikona uvoza – učitajte tragove i točke rute iz .gpx datoteke (vidi \"GPX uvoz\")\n• Zaključavanje sjevera – dugo pritisnite ružu vjetrova (gore lijevo); karta se prestaje rotirati i ostaje sjeverom prema gore. Dodirnite je bilo kada za povratak na sjever.\n• Odabrani slojevi (satelit, pomorske oznake, luke, radar, vjetar…), praćenje GPS-a i zaključavanje sjevera pamte se između pokretanja\n• Dugi pritisak na kartu = dodavanje točke rute (navigacijskog cilja); dodirnite postojeću točku za preimenovanje ili brisanje';

  @override
  String get guideInstrTitle => 'Brodski instrumenti';

  @override
  String get guideInstrBody =>
      'Kartica Instrumenti prikazuje navigacijske podatke u stvarnom vremenu.\n\n• SOG – brzina preko dna (čvorovi)\n• TWS – brzina pravog vjetra\n• TWA – kut pravog vjetra u odnosu na brod (zeleno = desni bok, crveno = lijevi bok)\n• DEPTH – dubina mora (crveno = manje od 5 m)\n• VMG WP – brzina prema odabranoj točki rute; odaberite je na pločici za prikaz udaljenosti/azimuta i strelice izravno na ruži vjetrova\n\nIzvor podataka: GPS telefona ili Raymarine (TCP ili UDP WiFi pristupnik).\nPostavke veze (uključujući izbor TCP/UDP) nalaze se u Postavke → Instrumenti.\n\nKako se brod povezuje: aplikacija čita NMEA podatke preko WiFi-ja (TCP ili UDP). Vlastita WiFi pristupna točka Raymarine MFD-a obično nije dovoljna — namijenjena je Raymarineovim aplikacijama i najčešće ne izlaže sirove NMEA podatke trećim stranama. Potreban vam je NMEA-na-WiFi pristupnik (npr. Digital Yacht, Yacht Devices, Actisense, Quark-elec) spojen na brodsku sabirnicu, koji ili stvara vlastitu pristupnu točku ili emitira NMEA na WiFi. Spojite se na WiFi tog pristupnika i unesite njegov IP i port u Postavkama (ili pokušajte s Automatskim otkrivanjem).';

  @override
  String get guideLogbookTitle => 'Dnevnik plovidbe';

  @override
  String get guideLogbookBody =>
      'Dnevnik je glavna kartica za upravljanje plovidbama.\n\n• Velika tipka \"Započni plovidbu\" na vrhu pokreće praćenje – traži samo učestalost automatskih zapisa (promjenjivu pri svakom pokretanju), bez obrasca koji treba ispuniti unaprijed\n• Ako je plovidba već otvorena, aplikacija pita želite li je nastaviti ili započeti novi zapis\n• Na nedostajuće podatke (check-in, sigurnosna instruktaža, kartica plovila/posade) podsjećaju obojene oznake izravno na kartici plovidbe – dodirnite oznaku da ih ispunite\n• Svaki dan plovidbe prikazan je zasebno\n• Zapisi se mogu dodavati ručno tijekom dana, uključujući sate motora, gorivo i vodu u odjeljku \"Motor i tankovi\"\n• Tijekom praćenja tipka kamere (dolje lijevo) omogućuje snimanje zanimljive točke i spremanje kao brzi zapis s pozicijom i vremenom\n• Dnevnik se može izvesti u PDF putem izbornika dana\n• Ikona rukovanja u detalju plovidbe otvara zapisnik o primopredaji (check-in/check-out)\n• Detaljni obrazac plovidbe (ikona broda u detalju) bilježi plovilo i njegove parametre, područje plovidbe, posadu s ovlaštenjima skipera te fotografije plovila (najviše 3, prenose se u PDF)\n• Nedovršene kartice (Sigurnosna instruktaža, check-in/out, kartica plovila) trepere crveno u gornjoj traci detalja plovidbe dok se ne dovrše\n• Ako se aplikacija tijekom plovidbe zatvori bez zaustavljanja praćenja (zatvori je sustav, slučajan swipe), pri sljedećem pokretanju ponudit će nastavak iste plovidbe – uključujući udaljenost prijeđenu dok nije radila\n• Pri prvom pokretanju plovidbe aplikacija podsjeti na postavke baterije – bez njih sustav (osobito Honor/Huawei) može ugasiti praćenje u pozadini\n• Ikona rute u zaglavlju plovidbe (uz brifing, protokol i karticu plovila) prikazuje cijeli trag plovidbe na karti\n• Nakon plovidbe možeš za svakog člana posade izvesti potvrdu o preplovljenim miljama – dani na moru, dnevne i noćne milje, područje, ocjena skipera i QR za provjeru\n• Način plovidbe (motor/jedra) prenosi se i u automatske zapise – postaviš ga jednom i sljedeći ga zadržavaju';

  @override
  String get guideMilesTitle => 'Knjiga milja';

  @override
  String get guideMilesBody =>
      'Sažetak svih vaših plovidbi na jednom mjestu (ikona u kartici Dnevnik).\n\n• Ukupno nautičkih milja, dana na moru, broj plovidbi i noćni sati\n• Raščlamba po godini i po plovilu\n• Filtar po godini\n• Dodirnite plovidbu (uključujući praćenu/uvezenu) da ispunite njezin zapis u dnevniku – ruta, zastava plovila, ime i ovlaštenje zapovjednika, potpis kojim se potvrđuju milje\n• Tipka + – dodajte prošlu plovidbu od prije nego što ste počeli koristiti aplikaciju (u potpunosti se uračunava u sažetke, u popisu je označena zvjezdicom)\n• PDF izvoz potvrde o preplovljenim miljama s mjestom za potpis';

  @override
  String get guideHandoverTitle =>
      'Zapisnik o primopredaji (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Formalni zapis o preuzimanju i vraćanju broda na charteru – ikona rukovanja u detalju plovidbe.\n\n• Kontrolna lista opreme (jedra, oputa, sidro, navigacija, prsluci za spašavanje, splav, kutija prve pomoći, gumenjak, svjetla, bimini...) – u redu / oštećeno / nedostaje, s napomenom, pozicijom na brodu i fotografijom\n• Stanje goriva, vode i sati motora\n• Potpis skipera i predstavnika charter tvrtke\n• Zapisnik postaje samo za čitanje čim obje strane potpišu\n• Check-out unaprijed popunjava podatke iz check-in zapisnika i ističe nova oštećenja\n• PDF izvoz s oba potpisa jedan uz drugi';

  @override
  String get guideGpxImportTitle => 'GPX uvoz';

  @override
  String get guideGpxImportBody =>
      'Uvezite tragove i točke rute iz drugih navigacijskih aplikacija ili GPS uređaja (ikona na Karti).\n\n• Odaberite .gpx datoteku s uređaja\n• Višednevni izvoz (nekoliko tragova u jednoj datoteci, npr. iz Garmin Explorea) automatski se spaja u jednu plovidbu s jednim danom po kalendarskom danu\n• Pronađeni tragovi mogu se i ručno dodijeliti postojećoj plovidbi\n• Točke rute (uključujući one iz ruta) dodaju se izravno na kartu\n• Za oštećenu datoteku prikazuje se jasna poruka o grešci';

  @override
  String get guideWeatherTitle => 'Vrijeme';

  @override
  String get guideWeatherBody =>
      'Kartica Vrijeme prikazuje prognozu na temelju vaše trenutne pozicije.\n\n• Ažurira se automatski kad se pozicija promijeni\n• Prikazuje vjetar, valove, temperaturu i uvjete za nadolazeće sate\n• Bez mreže prikazuje se zadnja spremljena prognoza\n\nSunce, Mjesec i plima:\n• Izlazak i zalazak sunca te Mjesečeva mijena izračunavaju se na uređaju — veza nije potrebna\n• Dodirnite osvježi na kartici Plima i oseka za preuzimanje sedmodnevne prognoze plime (besplatno, bez API ključa)\n• Plima se sprema u predmemoriju pa ostaje čitljiva bez mreže; kartica vas upozorava kad je prognoza stara ili preuzeta daleko odavde\n• ⚠ Visine plime su iznad srednje razine mora, ne iznad hidrografske nule — nikada ih ne koristite za izračun dubine ispod kobilice\n\nMorska struja:\n• Kartica Morska struja prikazuje stvarnu prognozu za vašu poziciju u čvorovima i smjer prema kojem struja teče\n• Na karti tipka s dvostrukom strelicom crta mrežu struja za vidljivo područje; strelice pokazuju kamo se voda kreće\n• Ne treba je brkati sa slojem Oceanske struje — to je referentna karta velikih globalnih struja';

  @override
  String get guideSafetyMobTitle => 'MOB i sidro';

  @override
  String get guideSafetyMobBody =>
      'Kartica Sigurnost sadrži funkcije za slučaj nužde.\n\nMOB (čovjek u moru):\n• Držite crvenu MOB tipku za aktivaciju\n• Aplikacija bilježi GPS poziciju te prati vrijeme i udaljenost\n• Navigirajte natrag do mjesta pada\n\nAlarm sidra:\n• Postavite radijus sidrenja (preporuka: 2× duljina lanca/konopa)\n• Alarm vibrira ako brod izađe izvan dopuštenog radijusa';

  @override
  String get guideSafetyBriefingTitle => 'Sigurnosna instruktaža i MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'Kartica Sigurnost sadrži i referentne kartice.\n\n• Sigurnosna instruktaža – kontrolna lista za posadu prije isplovljenja\n• Svaki član posade potpisuje se vlastitim potpisom na zaslonu\n• Potpisi se spremaju i automatski uključuju u PDF izvoz chartera\n• Lista primopredaje – pregled stavki check-ina/check-outa, dostupna i bez otvorene plovidbe\n• MAYDAY kartica – postupak poziva u pogibli na VHF kanalu 16\n• COLREG – pravila izbjegavanja sudara na moru (dostupna na slovačkom i engleskom; ostali jezici prikazuju engleski tekst)\n• Kontakti – hitni brojevi i kontakti\n\nNapomena: praćenje se može pokrenuti bilo kada, i bez dovršene instruktaže – aplikacija vas samo podsjeća oznakom \"Nedostaje sigurnosna instruktaža\" u Dnevniku dok je ne dovršite. Instruktaža zahtijeva prethodno ispunjenu karticu plovila i posade, a može se spremiti tek kad se potpiše svaki član posade.\n• Kontakti za nuždu prate poziciju i kad praćenje ne radi – aplikacija sama zatraži poziciju i mijenja brojeve pri prelasku u drugu državu';

  @override
  String get guideDutyTitle => 'Posada na straži';

  @override
  String get guideDutyBody =>
      'Zapis o tome tko je i kada bio na straži — u Sigurnosti, iznad alarma sidra.\n\n• Preuzmi stražu — odaberite jednu ili više osoba odjednom; svaka zatim zasebno predaje stražu\n• Imena dolaze iz posade plovidbe. Ako posada nije postavljena, tipka vas vodi na karticu plovidbe\n• Vrijeme početka može se ispraviti ako ste tipku pritisnuli sa zakašnjenjem\n• Prikaži za inspekciju — kartica preko cijelog zaslona za predočenje na brodu: tko je na straži, od kada, lokalno i UTC vrijeme. Iz nje se ništa ne može mijenjati\n• Raspored straža — unesite prošlu stražu ili je uredite. Ostavite vrijeme \"do\" prazno i straža ostaje u tijeku\n• Noćna straža preko ponoći je jedan zapis, ne dva. U PDF-u se pojavljuje na oba dana, označena strelicom\n• Preuzimanje i predaja straže upisuju se u dnevnik i u PDF izvoz\n\nNapomena: aplikacija nikada sama ne završava stražu. Nakon 12 sati vas samo upozorava — vrijeme završetka koje niste vidjeli bio bi izmišljen podatak.';

  @override
  String get guideCompassTitle => 'Kompas za azimutiranje';

  @override
  String get guideCompassBody =>
      'Kartica Kompas prikazuje magnetski azimut pomoću senzora telefona, sa stražnjom kamerom kao pozadinom za uzimanje azimuta na objekte.\n\n• Žuti nišan – smjer u koji ciljate\n• Traka kompasa na vrhu – S / SI / I / JI / J / JZ / Z / SZ\n• Brojčani prikaz – stupnjevi i strana svijeta\n• Zelena točka = stabilno očitanje  ·  Narančasta točka = kalibracija\n\nAko je očitanje nestabilno, polako pomičite telefon u obliku osmice da kalibrirate magnetometar.\n\nTočnost može biti smanjena u blizini metalnih konstrukcija, zvučnika ili elektroničke opreme.';

  @override
  String get guideSettingsTitle => 'Postavke';

  @override
  String get guideSettingsBody =>
      '• Jezik – promjena jezika aplikacije\n• Instrumenti – postavite IP adresu Raymarine WiFi pristupnika (TCP ili UDP)\n• Izvor GPS-a – telefon ili Raymarine\n• Jedinice – udaljenost NM/km, brzina čvorovi/km/h, posebno temperatura, dubina i vjetar (na rijeci odgovaraju km + km/h)\n• Učestalost zapisa u dnevnik\n• Donji izbornik – prilagodite ga: pritisnite i povucite ikonu za promjenu redoslijeda, prekidačem sakrijte kartice koje ne koristite i postavite veličinu ikona (S/M/L). Skrivene kartice mogu se otvoriti upravo ovdje u Postavkama; Postavke su uvijek prikazane. Redoslijed i veličina se pamte. Natpisi ispod ikona su skriveni kako bi ikone stajale jednako u svim jezicima; dugim pritiskom prikaže se naziv.\n• Prikaz – Noćni način (crveni filtar za očuvanje noćnog vida)\n• Izvoz u oblak (Google Drive) – nakon prijave PDF i GPX svakog dovršenog dana automatski se prenose na vaš Google Drive. Bez prijave sve ostaje na uređaju.\n• Sigurnosna kopija podataka – vidi \"Sigurnosna kopija i vraćanje podataka\"\n• O aplikaciji – verzija i kontakt';

  @override
  String get guideBackupTitle => 'Sigurnosna kopija i vraćanje podataka';

  @override
  String get guideBackupBody =>
      'U Postavke → Sigurnosna kopija podataka.\n\n• Izvezi sigurnosnu kopiju – sprema cijeli dnevnik (plovidbe, zapise, postavke) u jednu datoteku (.hmbbackup) koju možete podijeliti e-poštom, u oblak ili spremiti lokalno\n• Vrati iz sigurnosne kopije – zamjenjuje trenutne podatke sadržajem odabrane kopije; sigurnosna kopija trenutnog stanja stvara se automatski prije toga\n• Vraćanje je onemogućeno dok je aktivno GPS praćenje plovidbe\n• Kopija s novijom shemom od one koju aplikacija podržava odbija se uz objašnjenje';

  @override
  String get guideExportTitle => 'Izvoz dnevnika';

  @override
  String get guideExportBody =>
      'Dnevnik se može izvesti kao profesionalan PDF dokument.\n\n1. Otvorite Dnevnik → odaberite charter\n2. Dodirnite ikonu izvoza ili tri točke → Izvezi PDF\n3. Potpišite se kao skiper → PDF se generira\n4. PDF sadrži: trag, zapise iz dnevnika, fotografije, sigurnosnu instruktažu s potpisima posade; zaglavlje naslovnice prikazuje fotografiju plovila s kartice plovila (ako je učitana)\n5. Podijelite e-poštom, ispišite ili spremite na telefon\n\nSvaki PDF dobiva jedinstvenu oznaku dokumenta (npr. HMBSL-5-2026) i broj revizije (Rev. 1, Rev. 2...) vidljiv u podnožju svake stranice. Svaki novi izvoz automatski povećava broj — čime je vidljivo koliko je puta dokument generiran.\n\nQR kod na stranici s potpisima sadrži oznaku, reviziju i kriptografski otisak sadržaja. Svaka promjena podataka mijenja QR kod.\n\nPDF se generira na jeziku aplikacije, uključujući imena i dijakritičke znakove. Svaka stranica dana nosi i traku s posadom na straži.\n• Ako se praćenje tijekom dana prekinulo i ponovno pokrenulo, svaka dionica dobiva vlastitu GPX datoteku';

  @override
  String get safetyBriefingScreenTitle => 'Sigurnosna instruktaža';

  @override
  String get briefingCrewSignaturesSection => 'Potpisi posade';

  @override
  String get briefingSignHere => 'Potpišite ovdje';

  @override
  String get briefingClear => 'Očisti';

  @override
  String get briefingSigned => 'Potpisano';

  @override
  String get briefingSave => 'Spremi potpise';

  @override
  String get briefingSavedOk => 'Potpisi spremljeni';

  @override
  String get briefingOpenBriefing => 'Sigurnosna instruktaža';

  @override
  String get briefingSkipper => 'Skiper';

  @override
  String get briefingCrew => 'Posada';

  @override
  String get briefingNoCrew =>
      'Posada nije definirana. Dodajte članove posade u postavkama plovidbe.';

  @override
  String get briefingDate => 'Datum';

  @override
  String get briefingLocation => 'Mjesto';

  @override
  String get briefingDoneLabel => 'Sigurnosna instruktaža dovršena';

  @override
  String get briefingDoneSubtitle =>
      'Svi potpisi posade su spremljeni. Nije potrebno ponavljati.';

  @override
  String get briefingEditSignature => 'Promijeni potpis';

  @override
  String get briefingRequiredTitle => 'Potrebna je sigurnosna instruktaža';

  @override
  String get briefingRequiredBody =>
      'Dovršite sigurnosnu instruktažu i prikupite potpise posade prije pokretanja prvog praćenja.';

  @override
  String get goToBriefing => 'Idi na instruktažu';

  @override
  String get skipperProfile => 'Profil skipera';

  @override
  String get skipperProfileHint =>
      'Ovi podaci pojavljuju se u PDF izvozu plovidbe.';

  @override
  String get skipperFullName => 'Ime skipera';

  @override
  String get skipperLicenseSection => 'Ovlaštenje skipera';

  @override
  String get skipperLicenseType => 'Vrsta ovlaštenja';

  @override
  String get skipperLicenseNumber => 'Broj ovlaštenja';

  @override
  String get skipperLicenseAuthority => 'Tijelo izdavanja';

  @override
  String get skipperLicenseExpiry => 'Vrijedi do';

  @override
  String get skipperVhfSection => 'VHF / SRC ovlaštenje';

  @override
  String get skipperVhfNumber => 'VHF/SRC broj';

  @override
  String get skipperVhfExpiry => 'VHF vrijedi do';

  @override
  String get skipperOtherCerts => 'Ostale svjedodžbe / ovlaštenja';

  @override
  String get skipperOtherCertsHint =>
      'npr. Yachtmaster, RYA, STCW, tečajevi spašavanja...';

  @override
  String get continueLastVoyageTitle => 'Nastaviti zadnju plovidbu?';

  @override
  String get continueVoyageAction => 'Nastavi';

  @override
  String get newRecordAction => 'Novi zapis';

  @override
  String get missingCheckInChip => 'Nedostaje check-in';

  @override
  String get missingBriefingChip => 'Nedostaje sigurnosna instruktaža';

  @override
  String get missingDetailsChip => 'Nedostaju podaci o plovilu/posadi';

  @override
  String get missingCheckOutChip => 'Nedostaje check-out';

  @override
  String get vesselModel => 'Model';

  @override
  String get vesselTypeMonohull => 'Jednotrupac';

  @override
  String get vesselTypeCatamaran => 'Katamaran';

  @override
  String get vesselTypeTrimaran => 'Trimaran';

  @override
  String get vesselTypeMotorYacht => 'Motorna jahta';

  @override
  String get vesselTypeGulet => 'Gulet';

  @override
  String get vesselTypeDinghy => 'Mala jedrilica';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Ostalo';

  @override
  String get charterCompanyLabel => 'Charter tvrtka';

  @override
  String get yachtParamsSection => 'Parametri jahte';

  @override
  String get berthsLabel => 'Ležajevi';

  @override
  String get yearBuiltLabel => 'Godina gradnje';

  @override
  String get waterTankLabel => 'Tank za vodu';

  @override
  String get fuelTankLabel => 'Tank za gorivo';

  @override
  String get engineHoursStartLabel => 'Sati motora · početak';

  @override
  String get engineHoursEndLabel => 'Sati motora · kraj';

  @override
  String get whereWhenSection => 'Gdje i kada';

  @override
  String get countryLabel => 'Država';

  @override
  String get cruisingAreaLabel => 'Područje plovidbe';

  @override
  String get charterContactsSection => 'Charter kontakti';

  @override
  String get charterContactsHint =>
      'Do 3 broja za poziv / WhatsApp / SMS. Uvijek s međunarodnim pozivnim brojem (npr. +385...).';

  @override
  String get addPhoneNumber => 'Dodaj broj telefona';

  @override
  String get costsSection => 'Troškovi';

  @override
  String get charterPriceLabel => 'Cijena chartera';

  @override
  String get currencyLabel => 'Valuta';

  @override
  String get addCostItem => 'Dodaj trošak';

  @override
  String get costName => 'Naziv troška';

  @override
  String get crewSectionHint =>
      'Dodirnite oznaku da postavite zapovjednika — ostali su posada.';

  @override
  String get addCrewMember => 'Dodaj člana posade';

  @override
  String get crewNameLabel => 'Ime';

  @override
  String get skipperBadge => 'SKIPER';

  @override
  String get crewBadge => 'POSADA';

  @override
  String get vesselTypeSailboat => 'Jedrilica';

  @override
  String get vesselTypeMotorBoat => 'Motorni brod';

  @override
  String get sbNeedsVesselCard =>
      'Najprije ispunite karticu plovila i posade — Sigurnosnoj instruktaži treba popis posade za potpise.';

  @override
  String get prefillSkipperTitle => 'Ispuniti spremljene podatke skipera?';

  @override
  String get prefillSkipperFill => 'Ispuni';

  @override
  String get prefillSkipperNew => 'Novi skiper';

  @override
  String get boatLicenceLabel => 'Br. voditeljske dozvole';

  @override
  String get radioLicenceLabel => 'Br. radijske dozvole';

  @override
  String get vesselPhotosSection => 'Fotografije plovila (najviše 3)';

  @override
  String get addPhotoLabel => 'Dodaj';

  @override
  String get createVoyageButton => 'Kreiraj plovidbu';

  @override
  String get saveVoyageButton => 'Spremi plovidbu';

  @override
  String get costBaseCharter => 'Osnovna cijena chartera';

  @override
  String get costDeposit => 'Depozit';

  @override
  String get costDinghyOutboard => 'Gumenjak / vanbrodski motor';

  @override
  String get costOutboardFuel => 'Gorivo za vanbrodski motor';

  @override
  String get costTransitLog => 'Transit log';

  @override
  String get costTouristTax => 'Boravišna pristojba';

  @override
  String get costFinalCleaning => 'Završno čišćenje';

  @override
  String get costLinenTowels => 'Posteljina i ručnici';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / kajak';

  @override
  String get costSkipperFee => 'Naknada za skipera';

  @override
  String get costHostessFee => 'Naknada za hostesu';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m m';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Približna lokacija · ±$m m · mrežno pozicioniranje';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Zadnja poznata lokacija · prije $mins min';
  }

  @override
  String get locationQualityUnknown => 'Točnost nepoznata';

  @override
  String get locationQualityMocked => '⚠️ Otkrivena lažna lokacija';

  @override
  String get syncQueueTitle => 'Red za sinkronizaciju';

  @override
  String get syncQueueEmpty => 'Red je prazan';

  @override
  String get syncNowAction => 'Sinkroniziraj sada';

  @override
  String get syncRetryFailedAction => 'Ponovi neuspjele';

  @override
  String get syncStatusPending => 'Na čekanju';

  @override
  String get syncStatusSending => 'Šalje se';

  @override
  String get syncStatusSent => 'Poslano';

  @override
  String get syncStatusFailed => 'Neuspjelo';

  @override
  String get syncStatusConflict => 'Sukob';

  @override
  String get syncStatusDeferred => 'Odgođeno';

  @override
  String syncRetryCount(int n) {
    return 'Pokušaj $n';
  }

  @override
  String get syncOffline => 'izvan mreže';

  @override
  String syncPendingCount(int n) {
    return '$n na čekanju';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n odgođeno';
  }

  @override
  String syncFailedCount(int n) {
    return '$n neuspjelo';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Privitak čeka Wi-Fi (na moru obično nedostupan).';

  @override
  String get syncWifiOverrideAction => 'Koristi mobilne podatke';

  @override
  String get syncWifiOverrideActive => 'Mobilni podaci dopušteni za privitke';

  @override
  String get syncClearQueueAction => 'Isprazni red';

  @override
  String get syncClearQueueConfirmTitle => 'Isprazniti cijeli red?';

  @override
  String get syncClearQueueConfirmContent =>
      'Uklanja svaku stavku iz reda za sinkronizaciju, uključujući već poslane. Ovo se ne može poništiti.';

  @override
  String get syncClearQueueDone => 'Red ispražnjen';

  @override
  String get syncEnableToggle => 'Sinkroniziraj dnevnik';

  @override
  String get syncEnableToggleDesc =>
      'Šalje zapise na poslužitelj dok je aplikacija otvorena i na mreži';

  @override
  String get syncTargetLabel => 'Odredište sinkronizacije';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Vlastiti poslužitelj';

  @override
  String get syncCustomUrlLabel => 'URL poslužitelja';

  @override
  String get syncCustomTokenLabel => 'Token';

  @override
  String get syncTestConnectionAction => 'Testiraj vezu';

  @override
  String get syncTestSuccess => 'Veza radi';

  @override
  String syncTestFailure(String detail) {
    return 'Neuspjelo: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Unesite URL poslužitelja';

  @override
  String get syncUrlErrorInvalid => 'Neispravan URL';

  @override
  String get syncUrlErrorHttps => 'URL mora počinjati s https://';

  @override
  String get syncIntervalLabel => 'Interval sinkronizacije';

  @override
  String syncIntervalMinutes(int n) {
    return '$n min';
  }

  @override
  String get syncIntervalNote =>
      'Sinkronizacija radi samo dok je aplikacija otvorena';

  @override
  String get syncAttachmentPolicyLabel => 'Privici (fotografije)';

  @override
  String get syncAttachmentNever => 'Nikada';

  @override
  String get syncAttachmentWifiOnly => 'Samo Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Uvijek';

  @override
  String get syncBackfillAction => 'Stavi starije zapise u red';

  @override
  String get syncBackfillDesc =>
      'Dodaje zapise stvorene dok je sinkronizacija bila isključena u red za slanje';

  @override
  String syncBackfillResult(int n) {
    return '$n stavljeno u red';
  }

  @override
  String get syncBackfillNone => 'Ništa za red — sve je već u redu ili poslano';

  @override
  String get syncCloudEnableToggle => 'Izvoz u oblak (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Nakon prijave PDF i GPX svakog dovršenog dana automatski se prenose na Google Drive. Bez prijave sve ostaje na uređaju.';

  @override
  String get syncCloudSignInAction => 'Prijavi se Googleom';

  @override
  String get syncCloudSignOutAction => 'Odjavi se';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Prijavljeni kao $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Niste prijavljeni';

  @override
  String get waypointNameHint => 'npr. Sidrište, Luka...';

  @override
  String waypointDefaultName(String time) {
    return 'Točka $time';
  }

  @override
  String get mobFullName => 'Čovjek u moru';

  @override
  String get maydayCardShort => 'Mayday\nkartica';

  @override
  String get morseInputHint => 'Unesite tekst...';

  @override
  String get morseSosTitle => 'SOS – SIGNAL POGIBLI';

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
  String get aboutFeatureGps => 'GPS praćenje s automatskim zapisima';

  @override
  String get aboutFeatureLogbook => 'Dnevnik višednevnih plovidbi';

  @override
  String get aboutFeatureMaps => 'Izvanmrežne pomorske karte (OpenSeaMap)';

  @override
  String get aboutFeatureWeather => 'Pomorska prognoza (Open-Meteo)';

  @override
  String get aboutFeatureExport => 'Izvoz PDF + GPX';

  @override
  String get aboutFeatureSafety => 'Sigurnosna instruktaža i Mayday kartica';

  @override
  String get aboutAuthorLabel => 'Autor';

  @override
  String get aboutVersionLabel => 'Verzija';

  @override
  String get aboutPlatformLabel => 'Platforma';

  @override
  String cloudSignInFailed(String error) {
    return 'Prijava nije uspjela: $error';
  }

  @override
  String cloudSignOutFailed(String error) {
    return 'Odjava nije uspjela: $error';
  }

  @override
  String get marineInstrumentsWifiNote =>
      'Radi samo preko WiFi mreže broda – telefon mora biti povezan s NMEA pristupnikom (Raymarine, Digital Yacht, Yacht Devices…). Bez WiFi-ja aplikacija koristi GPS telefona i vremensku prognozu s interneta.';

  @override
  String get interruptedVoyageTitle => 'Praćenje je prekinuto';

  @override
  String interruptedVoyageBody(String time) {
    return 'Aplikacija se zatvorila u $time bez završetka plovidbe. Nastaviti istu plovidbu?';
  }

  @override
  String interruptedVoyageGap(String distance) {
    return 'Trenutna pozicija je $distance NM od zadnje zabilježene točke.';
  }

  @override
  String get interruptedVoyageAddGap => 'Pribroji ovu udaljenost plovidbi';

  @override
  String get interruptedVoyageResume => 'Nastavi';

  @override
  String get batteryPromptTitle => 'Neka aplikacija radi cijelu plovidbu';

  @override
  String get batteryPromptBody =>
      'Android — osobito Honor, Huawei i Xiaomi — gasi aplikacije koje rade u pozadini, čime se praćenje prekida usred plovidbe.\n\nU postavkama baterije dopustite ovoj aplikaciji rad bez ograničenja. Na Honor/Huawei dodajte je i među zaštićene aplikacije te dopustite automatsko pokretanje.';

  @override
  String get batteryPromptAction => 'Otvori postavke';

  @override
  String get speed => 'Brzina';

  @override
  String get crewCertTitle => 'Potvrda o preplovljenim miljama';

  @override
  String get crewCertVoyage => 'Plovidba';

  @override
  String get crewCertArea => 'Područje plovidbe';

  @override
  String get crewCertDayMiles => 'Dnevne milje';

  @override
  String get crewCertNightMiles => 'Noćne milje';

  @override
  String get crewCertNightHours => 'Noćni sati';

  @override
  String get crewCertQualifications => 'Kvalifikacije';

  @override
  String get crewCertAssessment => 'Ocjena skipera';

  @override
  String get crewCertStamp => 'Pečat';

  @override
  String get crewCertHashCoverage =>
      'Otisak pokriva sažetak plovidbe i ocjenu posade.';

  @override
  String get crewSkillHelming => 'Kormilarenje';

  @override
  String get crewSkillNavigation => 'Navigacija';

  @override
  String get crewSkillHarbour => 'Manevri u luci';

  @override
  String get crewSkillTeamwork => 'Timski rad';

  @override
  String get crewSkillNightSailing => 'Noćna plovidba';

  @override
  String get crewCertExport => 'Izvezi potvrde';

  @override
  String get crewCertNoteHint => 'Opisna ocjena (nije obavezno)';

  @override
  String get crewCertNoCrew =>
      'Ova plovidba nema posadu. Dodaj je u kartici plovidbe.';

  @override
  String get crewCertNotRated => 'nije ocijenjeno';

  @override
  String get crewCertShared => 'Potvrde su izrađene';

  @override
  String get more => 'Više';

  @override
  String get crewCertSkipperRates =>
      'Skiper ocjenjuje posadu i sam se ne ocjenjuje. Potvrdu o miljama ipak dobiva.';
}
