// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get poiTypeAnchorage => 'Kotviště';

  @override
  String get poiTypeMarina => 'Marína';

  @override
  String get poiTypeFuel => 'Čerpací stanice';

  @override
  String get poiTypeHarbour => 'Přístav';

  @override
  String get poiVhfChannel => 'VHF kanál';

  @override
  String get poiPhone => 'Telefon';

  @override
  String get poiCannotOpen => 'Nelze otevřít';

  @override
  String get poiWebsite => 'Web';

  @override
  String get poiEmail => 'Email';

  @override
  String get poiCapacity => 'Kapacita';

  @override
  String get poiServices => 'Služby';

  @override
  String get poiSaveAsWaypoint => 'Uložit jako trasový bod';

  @override
  String poiWaypointSaved(String name) {
    return 'Trasový bod \"$name\" uložen';
  }

  @override
  String get poiSource => 'Zdroj: OpenStreetMap';

  @override
  String get mapLayerSatellite => 'Satelit';

  @override
  String get mapLayerMap => 'Mapa';

  @override
  String get mapLayers => 'Vrstvy';

  @override
  String get mapSeamarks => 'Námořní značky';

  @override
  String get mapDepths => 'Hloubky';

  @override
  String mapDepthHere(String depth) {
    return 'Hloubka zde: $depth';
  }

  @override
  String get mapDepthNoData => 'Pro tento bod nejsou údaje o hloubce';

  @override
  String weatherModelSource(String model) {
    return 'Model: $model';
  }

  @override
  String get weatherOfflineNoAge =>
      'Bez signálu — zobrazena poslední uložená předpověď';

  @override
  String weatherOfflineSince(String when) {
    return 'Bez signálu — předpověď z $when';
  }

  @override
  String weatherStaleSince(String when) {
    return 'Předpověď je stará — stažena $when';
  }

  @override
  String get warningNoDetail => 'Podrobnosti se nepodařilo načíst.';

  @override
  String get warningSourceMeteoalarm => 'Zdroj: MeteoAlarm';

  @override
  String warningLanguageNote(String lang) {
    return 'Text je v jazyce: $lang';
  }

  @override
  String get mapHarbours => 'Přístavy a kotviště';

  @override
  String get mapZoomInForPois => 'Přibliž mapu pro načtení přístavů a kotvišť';

  @override
  String get mapRainRadar => 'Srážkový radar';

  @override
  String get mapTools => 'Nástroje';

  @override
  String get mapVoyageOverview => 'Přehled plavby';

  @override
  String get playbackTitle => 'Přehrát plavbu';

  @override
  String get playbackSpeed => 'Rychlost';

  @override
  String get playbackNoTrack => 'Tento den nemá zaznamenanou trasu';

  @override
  String playbackAtTime(String time) {
    return 'Stav v $time';
  }

  @override
  String get mapRuler => 'Pravítko / trasa';

  @override
  String get mapDownloadOffline => 'Stáhnout oblast offline';

  @override
  String get mapGpsDisabled => 'GPS je vypnuté';

  @override
  String get mapLocationDenied => 'Poloha není povolena';

  @override
  String get mapFollowGps => 'Sledovat GPS';

  @override
  String mapAreaTooLarge(int count) {
    return 'Oblast je příliš velká ($count dlaždic). Přibliž mapu a zkus to znovu.';
  }

  @override
  String get mapLivePreview => 'Živě (aktuální tracking)';

  @override
  String get mapWholeVoyage => 'Celá plavba';

  @override
  String get offlineSheetTitle => 'Offline mapa viditelné oblasti';

  @override
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb) {
    return 'Mapa + námořní značky, zoom $minZ–$maxZ, $tiles dlaždic (~$mb MB). Stažené oblasti fungují na moři bez signálu.';
  }

  @override
  String offlineDone(int n) {
    return 'Hotovo — $n dlaždic uloženo';
  }

  @override
  String offlineDoneErrors(int n) {
    return 'Hotovo s chybami: $n dlaždic se nepodařilo stáhnout';
  }

  @override
  String get downloadAction => 'Stáhnout';

  @override
  String get rulerTapHint => 'Ťukni body na mapě';

  @override
  String get mapEntryPhoto => 'Foto záznam';

  @override
  String get mapEntryNote => 'Záznam deníku';

  @override
  String get openSettingsAction => 'Otevřít nastavení';

  @override
  String get morseConverter => 'Převodník text → Morse';

  @override
  String saveError(String error) {
    return 'Chyba při ukládání: $error';
  }

  @override
  String get languageName => 'Čeština';

  @override
  String get navMap => 'Mapa';

  @override
  String get navTracking => 'Tracking';

  @override
  String get navLogbook => 'Deník';

  @override
  String get navWeather => 'Počasí';

  @override
  String get navSafety => 'Bezpečnost';

  @override
  String get navCompass => 'Kompas';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get navCustomizeTitle => 'Spodní menu';

  @override
  String get navCustomizeHint =>
      'Podrž a táhni pro změnu pořadí ikon. Přepínačem kartu skryješ ze spodního menu — Nastavení jsou vždy zobrazena.';

  @override
  String get navAlwaysShown => 'Vždy zobrazeno';

  @override
  String get navIconSizeLabel => 'Velikost ikon';

  @override
  String get navOpenHiddenTitle => 'Otevřít skryté karty';

  @override
  String get cameraPermissionDenied =>
      'Přístup ke kameře byl zamítnut. Povol ho v nastavení zařízení.';

  @override
  String get cameraUnavailable => 'Kamera nedostupná';

  @override
  String get compassCalibrationNote =>
      'Magnetický kompas. Přesnost může být ovlivněna kovem nebo elektronikou v blízkosti. Nekalibrovaný kompas kalibruj pohybem ve tvaru osmičky.';

  @override
  String get cancel => 'Zrušit';

  @override
  String get delete => 'Smazat';

  @override
  String get edit => 'Upravit';

  @override
  String get save => 'Uložit';

  @override
  String get editRouteTitle => 'Upravit trasu';

  @override
  String get portFromLabel => 'Přístav odjezdu';

  @override
  String get portToLabel => 'Přístav příjezdu';

  @override
  String get routeAutoFillHint =>
      'Doplňuje se automaticky z GPS, když je síť. Pokud zůstal prázdný, vyplň ho tady.';

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Zavřít';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get share => 'Sdílet';

  @override
  String get selectAll => 'Vybrat vše';

  @override
  String get error => 'Chyba';

  @override
  String errorMsg(String msg) {
    return 'Chyba: $msg';
  }

  @override
  String get pressBackToExit => 'Stiskni Zpět ještě jednou pro ukončení';

  @override
  String get trackingRunningTitle => 'Tracking běží';

  @override
  String get trackingRunningContent => 'Tracking je aktivní. Co chceš udělat?';

  @override
  String get stopAndExit => 'Zastavit a ukončit';

  @override
  String get keepRunning => 'Nechat běžet';

  @override
  String get marineInstrumentsTitle => 'Lodní přístroje';

  @override
  String get marineInstrumentsPrompt =>
      'Chceš připojit aplikaci k lodním přístrojům (např. Raymarine přes WiFi gateway)? Aplikace pak bude číst GPS, vítr, hloubku a další údaje přímo z lodi.\n\nBez připojení se použije GPS telefonu a předpověď počasí z internetu – kdykoli to můžeš změnit v Nastavení.';

  @override
  String get notNow => 'Teď ne';

  @override
  String get setupConnection => 'Nastavit připojení';

  @override
  String get autoDetectAction => 'Auto-detekce';

  @override
  String get autoDetectWifiHintTitle => 'Nejprve se připoj na WiFi lodi';

  @override
  String get autoDetectWifiHintBody =>
      'Zkontroluj v Nastavení telefonu → WiFi, že jsi připojen k síti lodních přístrojů (např. RayNet, WiFi-1). Pak se aplikace pokusí gateway v této síti najít automaticky.';

  @override
  String get openWifiSettings => 'WiFi nastavení';

  @override
  String get continueAction => 'Pokračovat';

  @override
  String get autoDetecting => 'Hledám přístroje na WiFi síti…';

  @override
  String get autoDetectFailed =>
      'Gateway se nenašel. Zkontroluj, zda jsi připojen k WiFi síti lodi, nebo zadej IP ručně v Nastavení.';

  @override
  String autoDetectSuccess(String host) {
    return 'Připojeno k $host';
  }

  @override
  String get guidePromptTitle => 'Poprvé tady? Rychlá příručka';

  @override
  String get guidePromptBody =>
      'Aplikace má krátkou uživatelskou příručku – mapa, lodní deník, počasí, bezpečnostní checklist a další. Chceš se na ni rychle podívat teď? Kdykoli ji najdeš i později v Nastavení → Uživatelská příručka.';

  @override
  String get guidePromptAction => 'Ukázat příručku';

  @override
  String get notifPromptTitle => 'Povolit oznámení?';

  @override
  String get notifPromptBody =>
      'Během sledování plavby běží oznámení v systémové liště a na zamčené obrazovce — vidíš, že tracking je aktivní, a máš k němu rychlý přístup. Bez povolení může systém sledování na pozadí omezit.';

  @override
  String get notifPromptAllow => 'Povolit';

  @override
  String get trackingActiveTitle => 'Tracking aktivní';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get waitingForGps => 'Čekám na GPS...';

  @override
  String get gpsUnavailable => 'GPS nedostupné';

  @override
  String get lastKnownPosition => 'Poslední známá poloha';

  @override
  String get accuracy => 'Přesnost';

  @override
  String get logbookBtn => 'Deník';

  @override
  String get stop => 'Zastavit';

  @override
  String get stopTrackingDay => 'Ukončit tracking?';

  @override
  String get startVoyage => 'Spustit plavbu';

  @override
  String get starting => 'Spouštím...';

  @override
  String get newVoyage => 'Nová plavba';

  @override
  String get multiday => 'Vícedenní';

  @override
  String get standalone => 'Samostatná';

  @override
  String get voyageName => 'Název plavby';

  @override
  String get voyageNameOptional => 'Název (volitelné)';

  @override
  String get voyageNameHint => 'např. Výlet do zátoky';

  @override
  String get existingVoyage => 'Pokračování existující plavby';

  @override
  String get newVoyageDropdown => '— Nová plavba —';

  @override
  String get firstVoyageHint => 'První plavba – vyplň základní info:';

  @override
  String get briefingRequiredHint =>
      'Tracking lze spustit až po dokončení Safety Briefingu pro danou plavbu.';

  @override
  String get briefingPending => 'SB potřebný';

  @override
  String get briefingPendingListWarning =>
      'Safety Briefing nedokončen – tracking zatím nelze spustit';

  @override
  String get estimatedDays => 'Předpokládaný počet dní:';

  @override
  String get logFrequency => 'Frekvence zápisů do deníku';

  @override
  String get startTracking => 'Spustit tracking';

  @override
  String get trackingInProgress => 'Sledování plavby';

  @override
  String dayNofTotal(int n, int total) {
    return 'Den $n z $total';
  }

  @override
  String get newDay => '(nový den)';

  @override
  String get endVoyageTitle => 'Konec plavby?';

  @override
  String get endVoyageContent =>
      'Dosáhli jste posledního plánovaného dne plavby.\n\nBude plavba pokračovat i zítra?';

  @override
  String get decideLayer => 'Rozhodnu později';

  @override
  String get continuesTomorrow => 'Pokračuje zítra';

  @override
  String get endVoyage => 'Ukončit plavbu';

  @override
  String get newMultidayVoyage => 'Nová vícedenní plavba';

  @override
  String get deleteCharterTitle => 'Smazat plavbu?';

  @override
  String get deleteCharterContent => 'Smažou se všechny dny a záznamy.';

  @override
  String get cannotDeleteWhileTracking =>
      'Nelze smazat plavbu během aktivního trackingu.';

  @override
  String get noVoyages => 'Žádné plavby';

  @override
  String get createFirstCharter => 'Vytvoř svou první plavbu';

  @override
  String get briefingDone => 'Briefing ✓';

  @override
  String get checkInDone => 'Check-in ✓';

  @override
  String get checkOutDone => 'Check-out ✓';

  @override
  String get voyageNotFound => 'Plavba nenalezena';

  @override
  String get unknownVessel => 'Neznámá loď';

  @override
  String get captain => 'Skipper';

  @override
  String get crew => 'Posádka';

  @override
  String get total => 'Celkem';

  @override
  String voyageDaysCount(int n) {
    return 'Dny plavby ($n)';
  }

  @override
  String get bulkDelete => 'Hromadné mazání';

  @override
  String get noDays =>
      'Žádné dny.\nSpusť tracking a první den se vytvoří automaticky.';

  @override
  String get deleteDayTitle => 'Smazat den?';

  @override
  String deleteDayContent(String day) {
    return 'Smažou se všechny záznamy pro $day.';
  }

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get selectDaysTitle => 'Vybrat dny ke smazání';

  @override
  String deleteCount(int n) {
    return 'Smazat ($n)';
  }

  @override
  String get safety => 'Bezpečnost';

  @override
  String get mobHoldToActivate => 'Podrž pro aktivaci';

  @override
  String get mobActive => '⚠️ MOB AKTIVNÍ';

  @override
  String get mobTime => 'Čas';

  @override
  String get mobDistance => 'Vzdálenost';

  @override
  String get mobDirection => 'Směr';

  @override
  String get navigateToMob => 'Naviguj k MOB';

  @override
  String get gpsPositionNotAvailable => 'GPS pozice není dostupná!';

  @override
  String get anchorAlarm => 'Kotevní alarm';

  @override
  String get drifting => 'UJÍŽDÍ';

  @override
  String get anchorRadiusLabel => 'Sledovaný poloměr pohybu';

  @override
  String get anchorZoneTool => 'Kotevní plocha';

  @override
  String get undoLastPoint => 'Vzít zpět poslední bod';

  @override
  String get anchorZoneDrawFromMap => 'Vyznačit plochu na mapě';

  @override
  String get anchorZoneDrawHint => 'Ťukej rohy plochy na mapě';

  @override
  String get anchorZoneNeedsPoints => 'Plocha potřebuje aspoň tři rohy';

  @override
  String get anchorZoneSelfIntersects =>
      'Plocha se sama překřížila — oprav rohy';

  @override
  String get anchorZoneArm => 'Hlídat tuto plochu';

  @override
  String get anchorZoneActive => 'Hlídání plochy';

  @override
  String anchorZoneInside(String m) {
    return '$m m k okraji plochy';
  }

  @override
  String anchorZoneOutside(String m) {
    return '$m m za okrajem plochy';
  }

  @override
  String get anchorZoneNotInside => 'Jsi mimo nakreslenou plochu';

  @override
  String get anchorZoneTooTight => 'Plocha je těsnější než přesnost GPS';

  @override
  String get anchorZoneNoFix =>
      'Bez GPS polohy — kotva se vzala ze středu plochy';

  @override
  String get anchorNoFix => 'Bez GPS polohy nelze kotvu spustit';

  @override
  String get activate => 'Aktivovat';

  @override
  String get deactivate => 'Deaktivovat';

  @override
  String get safetyBriefingCard => 'Safety Briefing';

  @override
  String get maydayCard => 'Mayday karta';

  @override
  String get yachtHandover => 'Předání jachty';

  @override
  String get gearList => 'Seznam vybavení';

  @override
  String get pdfEntriesSection => 'Záznamy deníku';

  @override
  String get pdfSkipperMessage => 'Zpráva skippera';

  @override
  String get pdfWeatherSection => 'Počasí';

  @override
  String get pdfDaySummary => 'Denní přehled';

  @override
  String get pdfDaysOverview => 'Přehled dní';

  @override
  String get pdfVoyageSummary => 'Závěrečný přehled plavby';

  @override
  String get pdfCrewSection => 'Posádka';

  @override
  String get pdfSignatures => 'Podpisy';

  @override
  String get pdfCrewSignatures => 'Podpisy posádky';

  @override
  String get pdfSkipperSignature => 'Podpis skippera';

  @override
  String get pdfSkipperLicences => 'Skipper – licence';

  @override
  String get pdfSafetyBriefing => 'Bezpečnostní briefing';

  @override
  String get pdfChecklistSection => 'Kontrolní seznam';

  @override
  String get pdfMoreNotes => 'Další poznámky';

  @override
  String get pdfIntegrityCheck => 'Ověření integrity dokumentu';

  @override
  String get pdfHandoverTitle => 'Předávací protokol';

  @override
  String get pdfMilesTitle => 'Potvrzení o najetých mílích';

  @override
  String get pdfDeparture => 'Odplutí';

  @override
  String get pdfArrival => 'Připlutí';

  @override
  String get pdfTotalLabel => 'Celkem';

  @override
  String get pdfDayCount => 'Počet dní';

  @override
  String get pdfEngineHours => 'Motohodiny';

  @override
  String get pdfFuelLabel => 'Palivo';

  @override
  String get pdfWaterLabel => 'Voda';

  @override
  String get pdfVesselLabel => 'Loď';

  @override
  String get pdfSkipperLabel => 'Skipper';

  @override
  String get pdfDateLabel => 'Datum';

  @override
  String get pdfColFrom => 'Odkud';

  @override
  String get pdfColTo => 'Kam';

  @override
  String get pdfColEntriesShort => 'Zázn.';

  @override
  String get pdfColTimeUtc => 'Čas UTC';

  @override
  String pdfColTimeLocal(String offset) {
    return 'Čas $offset';
  }

  @override
  String get timeZoneLabel => 'Časové pásmo';

  @override
  String get timeZoneLocalShort => 'Místní';

  @override
  String get pdfColWind => 'Vítr';

  @override
  String get pdfColPropulsion => 'Pohon';

  @override
  String get pdfColWeatherShort => 'Poč.';

  @override
  String get pdfColNote => 'Poznámka';

  @override
  String get pdfColDay => 'Den';

  @override
  String get pdfColItem => 'Položka';

  @override
  String get pdfColStatus => 'Stav';

  @override
  String get pdfColNotePosition => 'Poznámka / poloha';

  @override
  String get pdfColPhoto => 'Foto';

  @override
  String get pdfColDateRange => 'Datum od-do';

  @override
  String get pdfColArea => 'Oblast';

  @override
  String get pdfColTidal => 'Vody';

  @override
  String get pdfTidal => 'přílivové';

  @override
  String get pdfNonTidal => 'nepřílivové';

  @override
  String get pdfMilesIssuedFor => 'Vystaveno pro';

  @override
  String get pdfMilesIssuedBy => 'Vystavil';

  @override
  String get pdfMilesOwnRecord => 'Vlastní záznam naplavaných mil';

  @override
  String get pdfMilesByRole => 'Mile podle funkce';

  @override
  String get pdfMilesSkipperSummary => 'Skipperský souhrn';

  @override
  String get pdfMilesSkipperConfirms => 'Potvrzení velitele plavby';

  @override
  String get milesExportTitle => 'Vystavit potvrzení';

  @override
  String get milesExportFor => 'Pro koho';

  @override
  String get milesExportForSelf => 'Pro sebe';

  @override
  String get milesExportForCrew => 'Pro člena posádky';

  @override
  String get milesExportRecipient => 'Jméno příjemce';

  @override
  String get milesExportPickCrew => 'Vybrat z posádky';

  @override
  String get milesExportIssuer => 'Vystavovatel';

  @override
  String get milesExportQualification => 'Kvalifikace';

  @override
  String get milesExportVoyages => 'Plavby v potvrzení';

  @override
  String get milesExportSelectAll => 'Vybrat všechny';

  @override
  String get milesExportSelectNone => 'Zrušit výběr';

  @override
  String milesExportChosenSummary(String count, String nm) {
    return 'Vybraných plaveb: $count  ·  $nm NM';
  }

  @override
  String get milesExportNoVoyages => 'Nevybral jsi žádnou plavbu';

  @override
  String get milesTidalWaters => 'Přílivové vody';

  @override
  String get notSpecified => 'Neuvedeno';

  @override
  String get pdfColRole => 'Role';

  @override
  String get pdfNameLabel => 'Jméno';

  @override
  String get pdfLicenceLabel => 'Licence';

  @override
  String get pdfIssuedValidLabel => 'Vydal / platnost';

  @override
  String get pdfOtherCertsLabel => 'Jiné cert.';

  @override
  String get pdfContinued => 'pokračování';

  @override
  String get pdfExportedAt => 'Exportováno';

  @override
  String get pdfSignedAt => 'Podepsáno';

  @override
  String get pdfSignatureLabel => 'Podpis';

  @override
  String get pdfDatePlaceLabel => 'Datum / místo';

  @override
  String get pdfManualEntryNote => '* manuální záznam (zadáno ručně)';

  @override
  String get pdfStatTotalDistance => 'Celková vzdálenost';

  @override
  String get pdfStatLogEntries => 'Záznamy deníku';

  @override
  String get pdfStatMaxBeaufort => 'Max Beaufort';

  @override
  String get pdfStatDaysAtSea => 'Dny na moři';

  @override
  String get pdfStatVoyages => 'Počet plaveb';

  @override
  String get pdfStatNightHours => 'Noční hodiny';

  @override
  String get pdfFuelShort => 'P';

  @override
  String get pdfWaterShort => 'V';

  @override
  String get pdfNoData => 'Bez údajů';

  @override
  String get pdfMapUnavailable => 'GPS mapa nedostupná';

  @override
  String get pdfUnsigned => 'Nepodepsáno';

  @override
  String get pdfNoSignatures => 'Žádné podpisy';

  @override
  String get pdfSha256Label => 'SHA-256 otisk dat deníku:';

  @override
  String get pdfVerifyQr => 'Ověřovací QR';

  @override
  String get pdfSbLifejackets => 'Záchranné vesty – umístění a použití';

  @override
  String get pdfSbLifebuoy => 'Záchranný kruh a MOB postup';

  @override
  String get pdfSbFlares => 'Světlice – typy a použití';

  @override
  String get pdfSbEpirb => 'EPIRB / PLB – aktivace';

  @override
  String get pdfSbVhf => 'VHF rádio – kanál 16, Mayday postup';

  @override
  String get pdfSbExtinguisher => 'Hasicí přístroj – umístění a použití';

  @override
  String get pdfSbFirstAid => 'Lékárnička – umístění';

  @override
  String get pdfSbEngineStop => 'Nouzové vypnutí motoru';

  @override
  String get pdfSbLeaks => 'Úniky – voda, plyn';

  @override
  String get pdfSbAnchor => 'Kotva a řetěz – postup kotvení';

  @override
  String get pdfSbRules => 'Pravidla na palubě';

  @override
  String get pdfSbEmergencyContacts => 'Nouzové kontakty a VHF 16';

  @override
  String get pdfBriefingDeclaration =>
      'Všichni členové posádky byli seznámeni a porozuměli bezpečnostním pravidlům. Potvrzují to podpisem.';

  @override
  String get pdfHashCoverage =>
      'Otisk pokrývá název plavby, loď, posádku a všechny záznamy (čas UTC, GPS, rychlost, kurz). Jakákoli změna dat změní otisk.';

  @override
  String get pdfForCharterCompany => 'Za charterovou společnost';

  @override
  String get dutyRoster => 'Služba posádky';

  @override
  String get dutyStartAction => 'Nastoupit do služby';

  @override
  String get dutyEndAction => 'Ukončit';

  @override
  String get dutyStartTitle => 'Kdo nastupuje do služby?';

  @override
  String get dutyRunningChip => 'SLOUŽÍ';

  @override
  String dutySince(String time) {
    return 'od $time';
  }

  @override
  String dutyElapsed(int h, int m) {
    return '$h h $m min';
  }

  @override
  String get dutyNobodyOnDuty => 'Momentálně nikdo neslouží';

  @override
  String get dutyInspectionView => 'Zobrazit pro kontrolu';

  @override
  String get dutyRosterHistory => 'Rozpis služeb';

  @override
  String get dutyAddRetrospective => 'Doplnit službu';

  @override
  String get dutyEditTitle => 'Upravit službu';

  @override
  String get dutyDeleteTitle => 'Smazat službu?';

  @override
  String dutyDeleteConfirm(String name) {
    return 'Záznam služby pro $name bude smazán.';
  }

  @override
  String get dutyNoCrewDefined => 'Plavba nemá zadanou posádku';

  @override
  String get dutyDefineCrew => 'Doplnit posádku';

  @override
  String get dutyErrorEndBeforeStart => 'Konec musí být po začátku.';

  @override
  String dutyErrorOverlap(String name) {
    return '$name už v tomto čase slouží.';
  }

  @override
  String get dutyErrorFutureStart => 'Začátek nemůže být v budoucnosti.';

  @override
  String get dutyNoteLabel => 'Poznámka';

  @override
  String dutyLongRunningWarning(int hours) {
    return 'Služba běží $hours h — nezapomněl jsi ji ukončit?';
  }

  @override
  String get dutyFrom => 'Od';

  @override
  String get dutyTo => 'Do';

  @override
  String get dutyToOngoing => '— stále slouží';

  @override
  String get dutySelectPerson => 'Vyber člena posádky';

  @override
  String get dutyNoRecords => 'Zatím žádné služby';

  @override
  String get logDutySection => 'Služba posádky';

  @override
  String get logDutyStillRunning => 'trvá';

  @override
  String get autoEntryNote => 'Automatický záznam';

  @override
  String get logEventSailChange => 'Přehození plachet';

  @override
  String get logEventCourseChange => 'Změna kurzu';

  @override
  String get pdfNightShort => 'noc';

  @override
  String nightSailingHours(String hours) {
    return 'Noční plavba $hours h';
  }

  @override
  String logEventSailChangeTo(String direction) {
    return 'Změna plachet: $direction';
  }

  @override
  String get logEventHelmsmanChange => 'Změna kormidelníka';

  @override
  String logEventHelmsmanChangeTo(String name) {
    return 'Kormidelník: $name';
  }

  @override
  String get crewListEmpty => 'Plavba nemá vyplněnou posádku.';

  @override
  String get logEventAnchorDropped => 'Kotva spuštěna';

  @override
  String get logEventAnchorRaised => 'Kotva zdvižena';

  @override
  String get logEventDriftOut => 'Drift – překročen perimetr';

  @override
  String get logEventDriftIn => 'Drift – loď zpět v perimetru';

  @override
  String logEventAutopilotOn(String mode) {
    return 'Autopilot ZAP - $mode';
  }

  @override
  String get logEventAutopilotOff => 'Autopilot VYP';

  @override
  String get logEventEngineStart => 'Motor nastartován';

  @override
  String get logEventEngineStop => 'Motor zastaven';

  @override
  String get updateDownloaded => 'Aktualizace je stažena';

  @override
  String get updateRestart => 'Restartovat';

  @override
  String get autopilotLabel => 'Autopilot';

  @override
  String get autopilotModeAuto => 'Auto';

  @override
  String get autopilotModeWind => 'Vítr';

  @override
  String get autopilotModeTrack => 'Trasa';

  @override
  String get autopilotModeHeading => 'Kurz';

  @override
  String get autopilotModeRudder => 'Kormidlo';

  @override
  String get autopilotModeStandby => 'Standby';

  @override
  String logEventDutyStart(String name) {
    return 'Nástup do služby: $name';
  }

  @override
  String logEventDutyEnd(String name) {
    return 'Konec služby: $name';
  }

  @override
  String get colreg => 'COLREG';

  @override
  String get emergencyContacts => 'Nouzové kontakty';

  @override
  String get backToToc => 'Zpět na obsah';

  @override
  String get briefingComplete => 'Briefing dokončen';

  @override
  String get updateByPosition => 'Aktualizovat podle polohy';

  @override
  String get detectedByGps => 'detekováno podle GPS';

  @override
  String get locationUnavailable =>
      '📍 Poloha nedostupná – zobrazeny globální kontakty';

  @override
  String get detectingLocation => 'Zjišťuji polohu...';

  @override
  String get tapToCall => 'Klepni pro zavolání';

  @override
  String cannotCall(String name) {
    return 'Nelze zavolat: $name';
  }

  @override
  String get vhfChannel16 => 'VHF kanál 16 – použij rádio na palubě';

  @override
  String get hmbHandbook => 'HMB Příručka';

  @override
  String get checkInLabel => 'Check-in (převzetí lodi)';

  @override
  String get checkOutLabel => 'Check-out (předání lodi)';

  @override
  String get charterCheckCard => 'Plavba';

  @override
  String get weatherTitle => 'Počasí a moře';

  @override
  String get updateForecast => 'Aktualizovat předpověď';

  @override
  String get gpsNotAvailableTracking => 'GPS není dostupné – zapni tracking';

  @override
  String get downloadingForecast => 'Stahuji předpověď...';

  @override
  String get loadingForecast => 'Načítám předpověď...';

  @override
  String get noConnection => 'Není dostupné spojení';

  @override
  String get pressRefreshWhenOnline => 'Stiskni refresh, když jsi online';

  @override
  String get noWeatherData => 'Žádná data počasí';

  @override
  String get forecastAutoDownload =>
      'Předpověď se stáhne automaticky po spuštění trackingu, nebo stiskni Refresh.';

  @override
  String get enableGpsFirst => 'Zapni nejprve GPS / tracking';

  @override
  String get downloadForecast => 'Stáhnout předpověď';

  @override
  String downloadError(String error) {
    return 'Chyba stahování: $error';
  }

  @override
  String get errorNoInternetOnThisNetwork =>
      'Tato WiFi nemá internet (často WiFi lodních přístrojů). Zobrazena je poslední uložená předpověď; novou stažneš na mobilních datech.';

  @override
  String get errorNoConnection =>
      'Bez připojení. Zobrazena je poslední uložená předpověď.';

  @override
  String get liveInstrumentData => 'Živá data z lodních přístrojů';

  @override
  String get windRelative => 'Vítr (rel.)';

  @override
  String get windTrue => 'Vítr (skut.)';

  @override
  String get depthLabel => 'Hloubka';

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
  String get wind24h => 'Vítr – 3 dny';

  @override
  String get waves24h => 'Vlny – 3 dny';

  @override
  String get hourlyForecast => 'Předpověď na 3 dny';

  @override
  String get dailyForecast => 'Denní teplota';

  @override
  String get timeCol => 'Čas';

  @override
  String get windCol => 'Vítr';

  @override
  String get wavesCol => 'Vlny';

  @override
  String get rainCol => 'Déšť';

  @override
  String get beaufort0 => 'Bezvětří';

  @override
  String get beaufort1 => 'Vánek';

  @override
  String get beaufort2 => 'Slabý vítr';

  @override
  String get beaufort3 => 'Mírný vítr';

  @override
  String get beaufort4 => 'Dosti čerstvý vítr';

  @override
  String get beaufort5 => 'Čerstvý vítr';

  @override
  String get beaufort6 => 'Silný vítr';

  @override
  String get beaufort7 => 'Prudký vítr';

  @override
  String get beaufort8 => 'Bouřlivý vítr';

  @override
  String get beaufort9 => 'Vichřice';

  @override
  String get beaufort10 => 'Silná vichřice';

  @override
  String get beaufort11 => 'Mohutná vichřice';

  @override
  String get beaufort12 => 'Orkán';

  @override
  String get sunAndMoonCard => 'Slunce a měsíc';

  @override
  String get sunriseLabel => 'Východ slunce';

  @override
  String get sunsetLabel => 'Západ slunce';

  @override
  String get moonPhaseLabel => 'Fáze měsíce';

  @override
  String get moonIlluminationLabel => 'Osvětleno';

  @override
  String get moonPhaseNew => 'Nov';

  @override
  String get moonPhaseWaxingCrescent => 'Dorůstající srpek';

  @override
  String get moonPhaseFirstQuarter => 'První čtvrť';

  @override
  String get moonPhaseWaxingGibbous => 'Dorůstající měsíc';

  @override
  String get moonPhaseFull => 'Úplněk';

  @override
  String get moonPhaseWaningGibbous => 'Couvající měsíc';

  @override
  String get moonPhaseLastQuarter => 'Poslední čtvrť';

  @override
  String get moonPhaseWaningCrescent => 'Couvající srpek';

  @override
  String get noSunMoonGps => 'Pro východ/západ slunce je potřeba GPS poloha';

  @override
  String get oceanCurrentsTitle => 'Oceánské proudy';

  @override
  String get oceanCurrentsTooltip => 'Oceánské proudy';

  @override
  String get oceanCurrentsDisclaimer =>
      'Jen orientační data (typický směr/rychlost z pilotních map) — ne pro přesnou navigaci, proudy se sezonně mění.';

  @override
  String get tideCardTitle => 'Příliv/odliv';

  @override
  String get nextHighTideLabel => 'Nejbližší příliv';

  @override
  String get nextLowTideLabel => 'Nejbližší odliv';

  @override
  String get noTideData => 'Zatím žádná data o přílivu';

  @override
  String get downloadTides => 'Stáhnout předpověď přílivu';

  @override
  String get downloadingTides => 'Stahuji předpověď přílivu...';

  @override
  String get tideMslWarning =>
      'Výšky jsou nad střední hladinou moře, ne nad mapovým datem — nikdy je nepoužívej pro hloubku pod kýlem.';

  @override
  String get tideNoCoverage =>
      'Pro tuto polohu nemáme data o přílivu — je mimo oblast mořské předpovědi.';

  @override
  String get tideDownloadFailed =>
      'Předpověď přílivu se nepodařilo stáhnout. Zkontroluj připojení a zkus znovu.';

  @override
  String get tideForecastExpired => 'Uložená předpověď přílivu vypršela.';

  @override
  String tideForecastFarAway(int km) {
    return 'Předpověď byla stažena $km km odsud — stáhni ji znovu pro tuto polohu.';
  }

  @override
  String tideForecastStale(String when) {
    return 'Staženo $when — pro nejnovější předpověď stáhni znovu.';
  }

  @override
  String get oceanCurrentCardTitle => 'Mořský proud';

  @override
  String get oceanCurrentSetsToward => 'Teče směrem na (rychlost v uzlech)';

  @override
  String get oceanCurrentNoCoverage => 'Pro tuto polohu nemáme data o proudu.';

  @override
  String get oceanCurrentUnavailable =>
      'Předpověď proudu není dostupná — zkontroluj připojení.';

  @override
  String get tideOtherArea => 'Předpověď pro jinou oblast';

  @override
  String get tideAreaSearchLabel => 'Přístav, město nebo zátoka';

  @override
  String get tideAreaSearchHint => 'např. Split';

  @override
  String get tideAreaNoResults => 'Nic se nenašlo — zkus jiný název.';

  @override
  String tideForecastForArea(String place) {
    return 'Předpověď pro $place';
  }

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get measurementUnits => 'Jednotky měření';

  @override
  String get temperature => 'Teplota';

  @override
  String get depthWaves => 'Hloubka / vlny';

  @override
  String get wind => 'Vítr';

  @override
  String get language => 'Jazyk';

  @override
  String get appLanguage => 'Jazyk aplikace';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get displaySettings => 'Zobrazení';

  @override
  String get nightMode => 'Noční režim';

  @override
  String get nightModeDesc => 'Červený filtr pro zachování nočního vidění';

  @override
  String get aboutApp => 'O aplikaci';

  @override
  String get backupSection => 'Záloha dat';

  @override
  String get exportBackup => 'Exportovat zálohu';

  @override
  String get exportBackupDesc =>
      'Uloží celý deník (plavby, záznamy, nastavení) do jednoho souboru';

  @override
  String get restoreBackup => 'Obnovit ze zálohy';

  @override
  String get restoreBackupDesc =>
      'Nahradí aktuální data obsahem vybraného souboru zálohy';

  @override
  String get restoreBlockedTrackingTitle => 'Běží GPS tracking';

  @override
  String get restoreBlockedTrackingBody =>
      'Před obnovou zálohy nejprve zastav aktivní sledování plavby.';

  @override
  String get restoreSchemaTooNewTitle => 'Záloha je z novější verze';

  @override
  String get restoreSchemaTooNewBody =>
      'Tato záloha byla vytvořena novější verzí aplikace, než je právě nainstalovaná. Nejprve aktualizuj aplikaci.';

  @override
  String get restoreConfirmTitle => 'Obnovit ze zálohy?';

  @override
  String get restoreConfirmBody =>
      'Aktuální data budou nahrazena obsahem zálohy. Před obnovou se automaticky vytvoří bezpečnostní záloha současného stavu.';

  @override
  String get restoreSuccess => 'Data byla úspěšně obnovena ze zálohy.';

  @override
  String get restoreInvalidFile =>
      'Vybraný soubor není platná záloha HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Kniha mil';

  @override
  String get totalNm => 'Celkové NM';

  @override
  String get daysAtSea => 'Dny na moři';

  @override
  String get voyageCount => 'Počet plaveb';

  @override
  String get nightHoursLabel => 'Noční hodiny';

  @override
  String get byYear => 'Podle roku';

  @override
  String get byVessel => 'Podle lodi';

  @override
  String get addHistoricalVoyage => 'Přidat historickou plavbu';

  @override
  String get editHistoricalVoyage => 'Upravit historickou plavbu';

  @override
  String get deleteHistoricalVoyageConfirm =>
      'Opravdu smazat tuto historickou plavbu?';

  @override
  String get manualEntryExplanation => '* manuální záznam (zadáno ručně)';

  @override
  String get roleLabel => 'Role na palubě';

  @override
  String get roleSkipper => 'Skipper';

  @override
  String get roleCoSkipper => 'Kormidelník';

  @override
  String get roleCrew => 'Posádka';

  @override
  String get areaLabel => 'Oblast / trasa';

  @override
  String get distanceNmLabel => 'Vzdálenost (NM)';

  @override
  String get daysCountLabel => 'Počet dní';

  @override
  String get milesCertificateTitle => 'Potvrzení o najetých mílích';

  @override
  String get logbookRecordTitle => 'Záznam Knihy mil';

  @override
  String get logbookTrackedHint =>
      'Data, míle, oblast a role se počítají z trackingu/importu.';

  @override
  String get vesselFlag => 'Vlajka registrace';

  @override
  String get captainFirstName => 'Jméno skippera';

  @override
  String get captainLastName => 'Příjmení skippera';

  @override
  String get captainQualification => 'Nejvyšší dosažená kvalifikace';

  @override
  String get logbookSignatureSection => 'Podpis potvrzující míle';

  @override
  String get addSignature => 'Přidat podpis';

  @override
  String get filterAllYears => 'Všechny roky';

  @override
  String get filterCustomRange => 'Vlastní rozsah';

  @override
  String get handoverMenuTitle => 'Předávací protokol';

  @override
  String get checkInProtocol => 'Check-in protokol';

  @override
  String get checkOutProtocol => 'Check-out protokol';

  @override
  String get nextStepLabel => 'Další krok';

  @override
  String get readyToTrackHint => 'Připraveno na tracking';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Krok $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Safety\nBriefing';

  @override
  String get handoverChecklistShort => 'Předávací\nChecklist';

  @override
  String get safetyBriefingRefTitle => 'Bezpečnostní briefing';

  @override
  String get handoverChecklistRefTitle => 'Předávací checklist';

  @override
  String get handoverDateTime => 'Datum a čas';

  @override
  String get handoverLocation => 'Místo (marína)';

  @override
  String get checklistItemOk => 'OK';

  @override
  String get checklistItemDamaged => 'Poškozeno';

  @override
  String get checklistItemMissing => 'Chybí';

  @override
  String get damagePosition => 'Poloha na lodi';

  @override
  String get newDamageBadge => 'NOVÉ POŠKOZENÍ';

  @override
  String get companySignatureSection =>
      'Podpis zástupce charterové společnosti';

  @override
  String get companyRepName => 'Jméno zástupce';

  @override
  String get companyNameLabel => 'Název společnosti';

  @override
  String get protocolClosedNotice =>
      'Protokol je uzavřen (podepsaly obě strany) – jen ke čtení.';

  @override
  String get handoverCertTitle => 'Předávací protokol lodi';

  @override
  String get itemSails => 'Plachty';

  @override
  String get itemRigging => 'Lanoví';

  @override
  String get itemAnchorChain => 'Kotva a řetěz';

  @override
  String get itemNavInstruments => 'Navigační přístroje';

  @override
  String get itemLifeJackets => 'Záchranné vesty';

  @override
  String get itemRaft => 'Záchranný raft';

  @override
  String get itemFirstAidKit => 'Lékárnička';

  @override
  String get itemDinghyMotor => 'Dinghy a přívěsný motor';

  @override
  String get itemLights => 'Světla';

  @override
  String get itemBimini => 'Bimini';

  @override
  String get extraNotesLabel => 'Další poznámky';

  @override
  String get gpxImportTitle => 'Import GPX';

  @override
  String get gpxImportPickFile => 'Vybrat GPX soubor';

  @override
  String get gpxTracksFound => 'Nalezené tracky';

  @override
  String get gpxWaypointsFound => 'Nalezené waypointy';

  @override
  String get gpxAssignTarget => 'Přiřadit k plavbě';

  @override
  String get gpxNewVoyage => 'Nová plavba';

  @override
  String get gpxImportButton => 'Importovat';

  @override
  String get gpxImportSuccess => 'GPX úspěšně importován.';

  @override
  String get connectionConnected => 'Připojeno';

  @override
  String get connectionConnecting => 'Připojuji se...';

  @override
  String get connectionError => 'Chyba připojení';

  @override
  String get connectionDisconnected =>
      'Nepřipojeno (používá se telefon GPS / předpověď)';

  @override
  String get ipAddressLabel => 'IP adresa gateway';

  @override
  String get portLabel => 'Port';

  @override
  String get autoConnectLabel => 'Automaticky připojit při spuštění';

  @override
  String get disconnect => 'Odpojit';

  @override
  String get connect => 'Připojit';

  @override
  String get gatewayHint =>
      'Připoj telefon k WiFi síti Raymarine (např. WiFi-1, RayNet). IP adresa k zadání NENÍ ta z nastavení Raymarine — je to brána (gateway) té WiFi sítě. Najdeš ji v telefonu: Nastavení → WiFi → detail sítě → Brána. Port 2000 (TCP) je standard. Bez připojení aplikace automaticky používá GPS telefonu.';

  @override
  String connectedToHost(String host, int port) {
    return 'Připojeno k $host:$port';
  }

  @override
  String get enterIpAddress => 'Zadej IP adresu gateway';

  @override
  String connectionFailed(String error) {
    return 'Nepodařilo se připojit: $error';
  }

  @override
  String get liveWind => 'Vítr';

  @override
  String get liveDepth => 'Hloubka';

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
  String get udpListenPort => 'Port pro naslouchání';

  @override
  String get startListening => 'Spustit';

  @override
  String get stopListening => 'Zastavit';

  @override
  String connectionListening(String port) {
    return 'Naslouchá UDP na portu $port';
  }

  @override
  String udpHint(String port) {
    return 'Nastav simulátor/gateway, aby posílal UDP na IP tohoto telefonu, port $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Naslouchám UDP na portu $port';
  }

  @override
  String get dayNotFound => 'Den nenalezen';

  @override
  String get saved => 'Uloženo';

  @override
  String get trackingThisDay => 'Tracking běží pro tento den';

  @override
  String get trackingOtherDay => 'Tracking běží pro jiný den';

  @override
  String recordCount(int n) {
    return '$n záznamů';
  }

  @override
  String get addManual => 'Přidat manuální';

  @override
  String get noEntries => 'Žádné záznamy';

  @override
  String get entriesAutoAdded =>
      'Záznamy se přidávají automaticky během trackingu';

  @override
  String get deleteEntryTitle => 'Smazat záznam?';

  @override
  String get autoRecord => 'Automatický záznam';

  @override
  String get routeSection => 'Trasa';

  @override
  String get fromPort => 'Odkud';

  @override
  String get toPort => 'Kam';

  @override
  String get distance => 'Vzdálenost';

  @override
  String get vessel => 'Loď / člun';

  @override
  String get weatherSection => 'Počasí';

  @override
  String get morning => 'Ráno';

  @override
  String get noon => 'Poledne';

  @override
  String get evening => 'Večer';

  @override
  String get windDir => 'Směr větru';

  @override
  String get seaState => 'Stav moře';

  @override
  String get waveHeight => 'Výška vln';

  @override
  String get dailyNote => 'Zpráva dne';

  @override
  String get dailyNoteHint => 'Popis plavby, zajímavosti, události dne...';

  @override
  String get seaCalm => 'Klidné';

  @override
  String get seaLight => 'Mírné';

  @override
  String get seaModerate => 'Střední';

  @override
  String get seaRough => 'Rozbouřené';

  @override
  String get seaStormy => 'Bouřlivé';

  @override
  String get editEntry => 'Upravit záznam';

  @override
  String get newEntry => 'Nový záznam';

  @override
  String get sailMode => 'Způsob plavby';

  @override
  String get sailMain => 'Hlavní';

  @override
  String get sailDirection => 'Kurz vůči větru';

  @override
  String get pointOfSailCloseHauled => 'Ostře proti větru';

  @override
  String get pointOfSailCloseReach => 'Ostrý bočák';

  @override
  String get pointOfSailBeamReach => 'Boční vítr';

  @override
  String get pointOfSailBroadReach => 'Zadoboční vítr';

  @override
  String get pointOfSailRunning => 'Zadní vítr';

  @override
  String get tackPort => 'Levobok';

  @override
  String get tackStarboard => 'Pravobok';

  @override
  String get navigationSection => 'Navigace';

  @override
  String get latitude => 'Šířka';

  @override
  String get longitude => 'Délka';

  @override
  String get weatherSeaSection => 'Počasí a moře';

  @override
  String get mapStationWindLayer => 'Stanice – naměřeno';

  @override
  String get windGust => 'Náraz';

  @override
  String get radarTitle => 'Srážkový radar';

  @override
  String get radarRefresh => 'Obnovit snímek';

  @override
  String get radarUnavailable =>
      'Radarový snímek se nepodařilo načíst. Zkus to znovu, až budeš mít signál.';

  @override
  String get radarSourceDhmz => 'Zdroj: DHMZ – meteo.hr';

  @override
  String get weatherSourceInstruments => 'Naměřeno lodními přístroji';

  @override
  String get pdfWeatherSourceInstruments => 'Přístroje';

  @override
  String pdfWeatherSourceStation(String name) {
    return 'Stanice $name';
  }

  @override
  String pdfWeatherSourceStationAt(String name, String km) {
    return '$name, $km km';
  }

  @override
  String get pdfWeatherSourceStationUnknown => 'Meteostanice';

  @override
  String get pdfWeatherSourceModel => 'Model';

  @override
  String weatherSourceStation(String name) {
    return 'Naměřeno na stanici $name';
  }

  @override
  String weatherSourceStationAt(String name, String km) {
    return 'Naměřeno na stanici $name, $km km daleko';
  }

  @override
  String get weatherSourceStationUnknown => 'Naměřeno na meteostanici';

  @override
  String get weatherSourceModel => 'Předpovědní model, nikoli měření';

  @override
  String get windSpeed => 'Vítr';

  @override
  String get windDirection => 'Směr';

  @override
  String get waveHeight2 => 'Výška vln';

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
  String get helmsmanLabel => 'Kormidelník';

  @override
  String get noteSection => 'Poznámka';

  @override
  String get noteHint => 'Podmínky plavby, události, změna posádky...';

  @override
  String get quickPhotoLogTitle => 'Rychlý záznam';

  @override
  String get quickPhotoNoteHint => 'Co to je? (volitelné)';

  @override
  String get exportDayTitle => 'Export dne';

  @override
  String get exportCharterTitle => 'Export plavby';

  @override
  String get loadingData => 'Načítám data...';

  @override
  String get mapsReady => 'Mapy připraveny – můžeš exportovat';

  @override
  String generatingMaps(int current, int total) {
    return 'Generuji náhledy map ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Exportovat den';

  @override
  String get exportCharterBtn => 'Exportovat plavbu';

  @override
  String get entriesLabel => 'Záznamy';

  @override
  String get routePoints => 'Body trasy';

  @override
  String get anchorDriftTitle => '⚓ KOTVA UJÍŽDÍ!';

  @override
  String get anchorDriftContent =>
      'Loď překročila perimetr kotvy.\nOkamžitě zkontrolujte polohu!';

  @override
  String get cancelAnchor => 'Zrušit kotvu';

  @override
  String get stopAlarm => 'Zastavit alarm';

  @override
  String get briefingItem1 => 'Záchranné vesty – umístění a použití';

  @override
  String get briefingItem2 => 'Záchranný kruh a MOB postup';

  @override
  String get briefingItem3 => 'Světlice – typy a použití';

  @override
  String get briefingItem4 => 'EPIRB / PLB – aktivace';

  @override
  String get briefingItem5 => 'VHF rádio – kanál 16, Mayday postup';

  @override
  String get briefingItem6 => 'Hasicí přístroj – umístění a použití';

  @override
  String get briefingItem7 => 'Lékárnička – umístění';

  @override
  String get briefingItem8 => 'Nouzové vypnutí motoru';

  @override
  String get briefingItem9 => 'Úniky – voda, plyn';

  @override
  String get briefingItem10 => 'Kotva a řetěz – postup kotvení';

  @override
  String get briefingItem11 => 'Pravidla na palubě';

  @override
  String get briefingItem12 => 'Nouzové kontakty a VHF 16';

  @override
  String get checkInItem1 => 'Doklady lodi (registrace, pojištění)';

  @override
  String get checkInItem2 => 'Záchranné vybavení – kompletní';

  @override
  String get checkInItem3 => 'Zásoby paliva';

  @override
  String get checkInItem4 => 'Zásoby vody';

  @override
  String get checkInItem5 => 'Kotva a řetěz – kontrola';

  @override
  String get checkInItem6 => 'Motor – zkušební provoz';

  @override
  String get checkInItem7 => 'Navigační přístroje';

  @override
  String get checkInItem8 => 'Ráhnoví – lana a plachty';

  @override
  String get checkInItem9 => 'Kuchyně – plyn, vařič';

  @override
  String get checkInItem10 => 'WC – funkčnost';

  @override
  String get checkInItem11 => 'Existující poškození – fotodokumentace';

  @override
  String get checkOutItem1 => 'Loď vyčištěna – exteriér';

  @override
  String get checkOutItem2 => 'Loď vyčištěna – interiér';

  @override
  String get checkOutItem3 => 'Palivo doplněno';

  @override
  String get checkOutItem4 => 'Voda doplněna';

  @override
  String get checkOutItem5 => 'Odpadky odstraněny';

  @override
  String get checkOutItem6 => 'Poškození nahlášena';

  @override
  String get checkOutItem7 => 'Klíče předány';

  @override
  String get gearListShort => 'Výbava\njednotlivce';

  @override
  String get colregRules => 'COLREG\nPravidla';

  @override
  String get checkInShort => 'Check-in\nPřevzetí';

  @override
  String get checkOutShort => 'Check-out\nPředání';

  @override
  String get appTagline => 'Váš spolehlivý lodní deník';

  @override
  String exportSavedMsg(String path) {
    return 'Uloženo: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Uloženo: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Chyba exportu: $error';
  }

  @override
  String get generatingPdf => 'Generuji PDF...';

  @override
  String get colregTitle => 'COLREG – Pravidla pro vyhýbání';

  @override
  String get tableOfContents => 'OBSAH';

  @override
  String get inThisChapter => 'V této kapitole:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Pr. $n';
  }

  @override
  String get resetChecklistTitle => 'Resetovat seznam?';

  @override
  String get resetChecklistContent => 'Všechna zaškrtnutí se vymažou.';

  @override
  String get reset => 'Resetovat';

  @override
  String get checkInReceivingTitle => 'Check-in – Převzetí lodi';

  @override
  String get checkOutHandoverTitle => 'Check-out – Předání lodi';

  @override
  String get checkInCompletedMsg => 'Loď převzata – vše zkontrolováno ✓';

  @override
  String get checkOutCompletedMsg => 'Loď předána – vše v pořádku ✓';

  @override
  String get briefingDoneMsg => 'Briefing dokončen – posádka informována';

  @override
  String get sectionBriefed => 'Sekce probriefována ✓';

  @override
  String get confirmSection => 'Potvrdit sekci';

  @override
  String get gearListTitle => 'Výbava jednotlivce';

  @override
  String get newCategory => 'Nová kategorie';

  @override
  String get add => 'Přidat';

  @override
  String get deleteItemTitle => 'Smazat položku?';

  @override
  String get allPackedMsg => 'Vše zabaleno, připraven na plavbu! 🎉';

  @override
  String get addItemLabel => 'Přidat položku';

  @override
  String addToCategoryTitle(String category) {
    return 'Přidat do: $category';
  }

  @override
  String get newItemHint => 'Nová položka...';

  @override
  String get addWaypoint => 'Přidat waypoint';

  @override
  String get editWaypoint => 'Upravit waypoint';

  @override
  String get deleteWaypointTitle => 'Smazat waypoint?';

  @override
  String deleteWaypointNavActive(String name) {
    return 'Navigace na $name je aktivní. Smazáním bodu se vypne.';
  }

  @override
  String get waypointNameLabel => 'Název';

  @override
  String get skipperSignature => 'Podpis skippera';

  @override
  String get skipperNameLabel => 'Jméno skippera';

  @override
  String get signWithFinger => 'Podepiš se prstem';

  @override
  String get clear => 'Vymazat';

  @override
  String get signAndExport => 'Podepsat a exportovat';

  @override
  String get pleaseSign => 'Prosím podepiš se před exportem';

  @override
  String get generatingPdfPreview => 'Generuji náhled PDF...';

  @override
  String generationError(String error) {
    return 'Chyba generování: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Ukládám a generuji GPX...';

  @override
  String get editCharter => 'Upravit plavbu';

  @override
  String get basicInfo => 'Základní informace';

  @override
  String get voyageNameRequired => 'Název plavby *';

  @override
  String get dateFrom => 'Datum od';

  @override
  String get dateTo => 'Datum do';

  @override
  String get vesselName => 'Jméno lodi';

  @override
  String get vesselType => 'Typ lodi';

  @override
  String get homePort => 'Domovský přístav';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Volací znak';

  @override
  String get vesselLengthM => 'Délka (m)';

  @override
  String get vesselBeamM => 'Šířka (m)';

  @override
  String get vesselDraftM => 'Ponor (m)';

  @override
  String get selectExistingVoyage => 'Vybrat existující plavbu';

  @override
  String get newVoyageForm => 'Nová plavba';

  @override
  String get fillFormAndBriefing => 'Vyplnit dotazník a podepsat SB';

  @override
  String get notesLabel => 'Poznámky';

  @override
  String get statusLabel => 'Stav';

  @override
  String get safetyBriefingDoneLabel => 'Safety Briefing proveden';

  @override
  String get checkInDoneLabel => 'Check-in dokončen';

  @override
  String get checkOutDoneLabel => 'Check-out dokončen';

  @override
  String get enterVoyageName => 'Zadej název plavby';

  @override
  String daysCount(int n) {
    return '$n dní';
  }

  @override
  String get selectTargetWaypoint => 'Vyber cílový waypoint';

  @override
  String get noWaypoints => 'Žádné waypointy.';

  @override
  String get goToMap => 'Jít na mapu';

  @override
  String get noTarget => 'Žádný cíl';

  @override
  String get selectWaypointHint => 'Naviguj k waypointu';

  @override
  String get sessionStats => 'Statistiky plavby';

  @override
  String get maxSpeed => 'Max rychlost';

  @override
  String get avgSpeed => 'Prům. rychlost';

  @override
  String get sailingTime => 'Čas plavby';

  @override
  String get gpsData => 'Data GPS';

  @override
  String get gpsPosition => 'Poloha';

  @override
  String get courseCog => 'Kurz (COG)';

  @override
  String get altitudeLabel => 'Výška';

  @override
  String get dscProcedure => 'DSC POSTUP';

  @override
  String get voiceScript => 'HLASOVÝ SKRIPT';

  @override
  String get dscWarningUseOnly => '⚠️ POUŽÍVAT POUZE V PŘÍPADĚ';

  @override
  String get dscWarningDanger => 'VÁŽNÉHO A BEZPROSTŘEDNÍHO NEBEZPEČÍ';

  @override
  String get dscWarningTypes => 'Požár · Potápění · Muž přes palubu';

  @override
  String get dscProcedureSubtitle => 'Uchovejte tento postup u VHF DSC rádia';

  @override
  String get fillBeforeSailing => 'Vyplňte před plavbou:';

  @override
  String get copyTooltip => 'Kopírovat';

  @override
  String get scriptCopied => 'Skript zkopírován';

  @override
  String get sendOnCh16 =>
      '📻 Odeslat na Kanálu 16 · Vysoký výkon · Opakovat každé 2 minuty, pokud bez odpovědi';

  @override
  String get enterAbove => '[zadej v poli výše]';

  @override
  String get distressNature => 'Povaha tísně';

  @override
  String get vesselNameLabel => 'Název lodi';

  @override
  String get numberOfPersons => 'Počet osob';

  @override
  String get additionalInfo => 'Další info';

  @override
  String get voiceScriptTitle => 'HLASOVÝ MAYDAY SKRIPT';

  @override
  String voiceScriptTitleFor(String type) {
    return 'HLASOVÝ SKRIPT · $type';
  }

  @override
  String get distressCallMayday => 'MAYDAY';

  @override
  String get distressCallPanPan => 'PAN PAN';

  @override
  String get distressCallSecurite => 'SÉCURITÉ';

  @override
  String get distressNoteMayday =>
      'MAYDAY: pouze při vážném a bezprostředním ohrožení života nebo lodi. Např. „MAYDAY, MAYDAY, MAYDAY, taking on water, sinking“ (nabíráme vodu, potápíme se).';

  @override
  String get distressNotePanPan =>
      'PAN PAN: naléhavé hlášení, které přímo neohrožuje život. Např. „PAN PAN, PAN PAN, PAN PAN, engine failure, drifting toward rocks“ (výpadek motoru, unášeni ke skalám).';

  @override
  String get distressNoteSecurite =>
      'SÉCURITÉ: bezpečnostní hlášení o plavbě nebo počasí pro ostatní lodě. Např. „SÉCURITÉ, SÉCURITÉ, SÉCURITÉ, uncharted wreck reported at position…“ (nezakreslený vrak nahlášen na poloze…).';

  @override
  String get dscStep1 => 'Ujistěte se, že rádio je zapnuté.';

  @override
  String get dscStep2 => 'Otevřete kryt nad ČERVENÝM tlačítkem tísně.';

  @override
  String get dscStep3 => 'Stiskněte ČERVENÉ tlačítko JEDNOU a uvolněte.';

  @override
  String get dscStep4 =>
      'Vyberte povahu tísně.\n(Požár, Potápění, MOB apod.)\nPokud vynecháte, odešle se Neoznačená tíseň.';

  @override
  String get dscStep5 =>
      'Stiskněte a PODRŽTE ČERVENÉ tlačítko po dobu 5 sekund pro odeslání výzvy.';

  @override
  String get dscStep6 =>
      'Čekejte max. 15 sekund na potvrzení (zobrazí se na obrazovce), poté odešlete hlasovou zprávu na Kanálu 16 na VYSOKÝ výkon.';

  @override
  String get appDescription => 'Profesionální lodní deník pro jachtaře.';

  @override
  String get vesselIdTitle => 'Identifikace plavidla';

  @override
  String get vesselIdHint =>
      'Call sign a MMSI se automaticky vyplní v Mayday Card.';

  @override
  String get maritimeReference => 'Námořní abeceda';

  @override
  String get phonetic => 'Fonetická';

  @override
  String get flagAlphabet => 'Vlajkové signály';

  @override
  String get dayShapes => 'Denní znaky';

  @override
  String get marineReferenceTile => 'Signály & abeceda';

  @override
  String get navInstruments => 'Lodní přístroje';

  @override
  String get enterPort => 'Zadej přístav...';

  @override
  String get closeWithoutSaving => 'Zavřít bez uložení';

  @override
  String get saveToDevice => 'Uložit do zařízení';

  @override
  String get saveAndShare => 'Uložit a sdílet';

  @override
  String get timestampCannotBeChanged => 'Čas záznamu nelze změnit';

  @override
  String entriesShort(int n) {
    return '$n zázn.';
  }

  @override
  String get mainsail => 'Hlavní';

  @override
  String get weatherConditionTitle => 'Stav počasí';

  @override
  String get weatherConditionLabel => 'Podmínky';

  @override
  String get wcSunny => 'Slunečno';

  @override
  String get wcPartlyCloudy => 'Částečně oblačno';

  @override
  String get wcOvercast => 'Zataženo';

  @override
  String get wcLightRain => 'Slabý déšť';

  @override
  String get wcRain => 'Déšť';

  @override
  String get wcHeavyRain => 'Silný déšť';

  @override
  String get wcDrizzle => 'Mrholení';

  @override
  String get wcThunderstorm => 'Bouřka';

  @override
  String get wcIsoThunderstorm => 'Ojedinělé bouřky';

  @override
  String get wcHail => 'Kroupy';

  @override
  String get wcDust => 'Prach';

  @override
  String get wcFoggy => 'Mlha';

  @override
  String get wcWindy => 'Větrno';

  @override
  String get wcCold => 'Mráz';

  @override
  String get photoSection => 'Fotografie';

  @override
  String get camera => 'Fotoaparát';

  @override
  String get gallery => 'Galerie';

  @override
  String get addPhoto => 'Přidat fotku';

  @override
  String get photoAddedToEntry => 'Fotografie přiložena';

  @override
  String get voyageStart => 'Začátek plavby';

  @override
  String get voyageEnd => 'Konec plavby';

  @override
  String get onlineAccount => 'Online účet';

  @override
  String get onlineAccountDesc => 'Online synchronizace deníku — připravujeme';

  @override
  String get register => 'Registrovat';

  @override
  String get login => 'Přihlásit';

  @override
  String get logout => 'Odhlásit';

  @override
  String get logoutConfirm =>
      'Budete odhlášeni. Data uložená v zařízení zůstanou.';

  @override
  String get notLoggedIn => 'Nepřihlášen';

  @override
  String get fullName => 'Celé jméno';

  @override
  String get password => 'Heslo';

  @override
  String get userGuide => 'Uživatelská příručka';

  @override
  String get guideQuickStart => 'Rychlý start – 5 kroků';

  @override
  String get guideQuickStartBody =>
      '1. Klepni na velké tlačítko \"Spustit plavbu\" nahoře (na Mapě, v Deníku nebo u Přístrojů) – vyber frekvenci zápisů a tracking běží, nic jiného není třeba vyplňovat předem\n2. Pokud máš rozdělanou plavbu, aplikace se zeptá: pokračovat v ní, nebo nový záznam\n3. Chybějící údaje (check-in, safety briefing, karta lodi/posádky) doplň kdykoli – aplikace je připomene barevnými chipy v Deníku\n4. Během dne přidávej záznamy: čas, pozice, poznámka\n5. Na konci plavby otevři Nastavení → Export PDF\n\nAplikace běží na celou obrazovku – systémové lišty telefonu zobrazíš tažením prstu od horního nebo spodního okraje.';

  @override
  String get guideMapTitle => 'Mapa';

  @override
  String get guideMapBody =>
      'Záložka Mapa zobrazuje tvou aktuální polohu a trasu plavby.\n\n• Modrá tečka = aktuální poloha\n• Modrá čára = právě trackovaná trasa\n• Ikona trasy – vyber libovolnou plavbu nebo den a podívej se na její trasu na mapě (oranžově), i bez PDF exportu Dole se objeví přehrávání: posuvníkem projdeš plavbu v čase a vidíš polohu, rychlost, kurz, vítr i tlak v kterékoli chvíli. Svislé čárky na posuvníku jsou události — začátek a konec plavby, kotva, drift, MOB.\n• Můžeš přepínat mezi satelitní a mapovou vrstvou\n• Seamarky – přepínač pro námořní značky (vraky, mělčiny, bóje)\n• Hloubky – hloubnice z EMODnet s hloubkou v metrech. Model dna z průzkumů, NENÍ to námořní mapa: na plánování průlivu ano, na rozhodnutí „projedu tudy“ ne. Standardně vypnuto; prohlížené dlaždice se ukládají jako ostatní. Když je vrstva zapnutá, klepnutím do mapy přečteš hloubku v daném bodě (je potřeba signál).\n• Přístavy – klikatelná vrstva kotvišť, marín a přístavů (data z OpenStreetMap): klepni na ikonku a uvidíš název, VHF kanál, telefon, web (klepnutím rovnou zavoláš nebo otevřeš stránku), hloubku či kapacitu, pokud jsou známé; místo si můžeš rovnou uložit jako waypoint; vrstva zahrnuje i tankovací stanice pro lodě (oranžová pumpa)\n• Pravítko (fialová ikona) – klepej body na mapě: součet NM, kurz posledního úseku a ETA při aktuální rychlosti; body se přichytávají k waypointům, takže si můžeš změřit trasu přes cíle\n• Offline mapa (ikona stažení) — stáhne viditelnou oblast pro použití bez signálu, od aktuálního přiblížení o tři úrovně hlouběji. Vždy seamarky; když máš zapnutý satelit, i snímky a jejich popisky. Navíc se každá prohlížená dlaždice ukládá automaticky.\n• V nočním režimu se mapa automaticky přepne na tmavé dlaždice\n• Ikona kotvy = místo kotvení (jen když je kotva aktivní)\n• Ikona importu – načte trasy a waypointy z .gpx souboru (viz sekce \"Import GPX\")\n• Zámek severu – podrž růžici kompasu vlevo nahoře; mapa se přestane otáčet a zůstane na sever. Klepnutím ji kdykoli vrátíš na sever.\n• Zvolené vrstvy (satelit, seamarky, hloubky, přístavy), sledování GPS i zámek severu se pamatují mezi spuštěními\n• Podrž prst na mapě = přidej waypoint (navigační cíl); klepnutím na existující waypoint ho přejmenuješ nebo smažeš';

  @override
  String get guideInstrTitle => 'Námořní přístroje';

  @override
  String get guideInstrBody =>
      'Záložka Přístroje zobrazuje navigační data v reálném čase.\n\n• SOG – rychlost nad dnem (uzly)\n• TWS – skutečná rychlost větru\n• TWA – směr větru vůči lodi (zelená = pravobok, červená = levobok)\n• DEPTH – hloubka vody (červené = méně než 5 m)\n• VMG WP – rychlost k vybranému waypointu; po výběru z dlaždice uvidíš vzdálenost/směr i šipku přímo na směrové růžici. Navigaci vypneš volbou \"Žádný cíl\" ve stejné dlaždici — vypne ji i smazání waypointu na mapě\n• AUTOPILOT – ukazuje ZAP/VYP i režim řízení, když to přístroje hlásí (HTC/HTD, APB nebo SeaTalk). Každé přepnutí se automaticky zapíše do deníku, jako v palubním deníku letadla.\n\nZdroj dat: telefonní GPS nebo Raymarine (TCP i UDP WiFi gateway).\nNastavení připojení (včetně volby TCP/UDP) najdeš v Nastavení → Přístroje.\n\nJak se loď připojuje: aplikace čte NMEA data přes WiFi (TCP nebo UDP). Samotný WiFi hotspot Raymarine MFD obvykle nestačí — slouží pro aplikace Raymarine a surové NMEA třetím stranám většinou nepouští. Potřebuješ NMEA→WiFi gateway (např. Digital Yacht, Yacht Devices, Actisense, Quark-elec) připojený na lodní sběrnici, který buď vytvoří vlastní hotspot, nebo broadcastuje NMEA do WiFi. Telefon připoj k WiFi tohoto gateway a v Nastavení zadej jeho IP a port (nebo zkus Automaticky najít).\n\nB&G Zeus a podobné plottery Navico: připoj telefon na WiFi plotru a v Nastavení zvol TCP. Adresa plotru ve WiFi síti ale NEFUNGUJE — server NMEA běží na jeho ethernetovém rozhraní. Tu adresu najdeš přímo v plotru: Settings → Network → Diagnostics, položka IP address (bývá ve tvaru 169.254.x.x). Zadej ji spolu s portem 10110. Ověřeno na Zeus III se softwarem NOS v25.2. Port 2053 spojení přijme, ale data neposílá — to je služba GoFree s vlastním protokolem, ne NMEA. Zapni si Automaticky připojit při spuštění. Pokud to jednou přestane fungovat, adresa se mohla změnit — přečti ji znovu v Diagnostics.\n• Růžice kompasu má uprostřed kruhu heading a pod ním malým písmem COG. Rozdíl mezi nimi je snos od proudu a větru — z jednoho čísla se vyčíst nedá.';

  @override
  String get guideLogbookTitle => 'Deník plavby';

  @override
  String get guideLogbookBody =>
      'Deník je hlavní záložka pro správu plaveb.\n\n• Velké tlačítko \"Spustit plavbu\" nahoře spustí tracking – zeptá se jen na frekvenci automatických zápisů (lze změnit při každém dalším spuštění), žádný formulář není třeba vyplnit předem\n• Pokud existuje rozdělaná plavba, aplikace se zeptá, zda pokračovat v ní nebo založit nový záznam\n• Chybějící údaje (check-in, safety briefing, karta lodi/posádky) aplikace připomene barevnými chipy přímo na kartě plavby – klepnutím na chip je doplníš\n• Každý den plavby se zobrazuje zvlášť\n• Záznamy lze přidávat ručně během dne, včetně motohodin, paliva a vody v sekci \"Motor a nádrže\"\n• Během trackingu se objeví tlačítko fotoaparátu (vlevo dole) – vyfoť zajímavý bod a rychle ho ulož jako záznam s polohou a časem\n• Deník lze exportovat do PDF přes menu dne\n• Ikona podání rukou v detailu plavby otevře předávací protokol (check-in/check-out)\n• Podrobný formulář plavby (ikona lodi v detailu) eviduje loď a její parametry, oblast plavby, posádku s průkazy skippera i fotky lodi (max 3, přenášejí se do PDF)\n• Nevyplněné karty (Safety Briefing, check-in/out, karta lodi) blikají červeně v horní liště detailu plavby, dokud je nedokončíš\n• Pokud se aplikace během plavby vypne bez ukončení trasování (zavře ji systém, nechtěný swipe), při dalším spuštění nabídne pokračování ve stejné plavbě – včetně dopočítání vzdálenosti ujeté, když aplikace neběžela\n• Při prvním spuštění plavby aplikace připomene nastavení baterie – bez něj může systém (hlavně Honor/Huawei) trasování na pozadí vypnout\n• Ikona trasy v hlavičce plavby (vedle SB, protokolu a karty lodi) zobrazí trasu celé plavby na mapě\n• Po plavbě můžeš pro každého člena posádky vyexportovat potvrzení o naplavaných mílích – dny na moři, denní a noční míle, oblast plavby, hodnocení od skippera a QR pro ověření\n• Způsob plavby (motor/plachty) se přebírá i do automatických zápisů – přepneš ho jednou a další zápisy v něm pokračují\n• Potvrzení je dvojjazyčné (tvůj jazyk + angličtina), obsahuje rozměry a registraci lodi, typ vod (přílivové/nepřílivové) a kolonku na číslo pasu nebo OP; dá se sdílet i uložit přímo do telefonu\n• Kurz vůči větru – silueta lodi z papírového deníku: klepni na polohu na tom boku, ze kterého fouká (levobok červený, pravobok zelený). Zadní vítr je dole, tam se bok nerozlišuje. Opětovné klepnutí výběr zruší – odhadnutý údaj je horší než prázdné políčko. Do PDF jde vedle způsobu plavby.\n• Během plavby je vlevo dole druhé rychlé tlačítko (ikona plachetnice) na obrat nebo halzu: vyber nový kurz na siluetě a záznam se zapíše i s polohou a časem. Další automatické zápisy ten kurz přebírají, dokud ho znovu nezměníš.\n• Hloubka ze sondy se ukládá k automatickým záznamům a v ručním záznamu je předvyplněná (potřebuje připojené přístroje).\n• Motohodiny se počítají z otáček z přístrojů a nastartování i zastavení motoru se zapíše do deníku samo.\n• Rychlé tlačítko plachetnice (vlevo dole během plavby) nyní zapisuje i pohon — Motor / Hlavní / Genova / Reef. Další automatické záznamy ho přebírají, dokud ho nezměníš, takže sloupec Pohon v PDF už nezůstává prázdný.\n• Appka si sama zapíše změnu kurzu: když se směr odkloní o 30° a více a v novém směru vydrží aspoň minutu. Kličkování na vlně ani zákmit GPS to nespustí.\n• Automatické záznamy mají i stav oblohy — doplňuje se z modelu k času a poloze záznamu, stejně jako vítr a tlak.\n• Noční plavba se počítá sama: podle skutečného západu a východu slunce pro polohu, kde loď byla. Záznam po setmění má měsíček, den i celá plavba mají součet nočních hodin v deníku i v PDF.\n• Novou plavbu založíš tlačítkem **Nová plavba** v Deníku — vyplníš loď, oblast a posádku ještě před vyplutím a trasování pak na tuto plavbu naváže. Spustit plavbu rovnou tlačítkem Start lze i nadále.\n• Trasa dne (odkud → kam) se doplňuje z GPS, ale jen když je funkční internet — na Wi-Fi lodních přístrojů ho telefon nemá, takže přístavy mohou zůstat prázdné. Aplikace je později doplní sama a kdykoli je zadáš klepnutím na trasu v kartě dne. Kde přístav chybí, PDF vytiskne polohu místo otazníku.\n• Pohon je na začátku Motor: z přístavu se vyplouvá na motor a prázdný sloupec Pohon nebyl pravdivější než motor, jen nečitelnější. První změna (rychlé tlačítko nebo ruční záznam) jej přepíše a další automatické zápisy v ní pokračují.';

  @override
  String get guideMilesTitle => 'Kniha mil';

  @override
  String get guideMilesBody =>
      'Souhrn všech plaveb na jednom místě (ikona v Deníku plavby).\n\n• Celkové námořní míle, dny na moři, počet plaveb a noční hodiny\n• Rozpad podle roku a podle lodi\n• Filtr podle roku\n• Klepni na plavbu (i trackovanou/importovanou) a doplň záznam Knihy mil – trasu, vlajku lodi, jméno a kvalifikaci skippera, podpis potvrzující míle\n• Tlačítko + – přidej historickou plavbu z doby před používáním aplikace (počítá se plně do souhrnů, v seznamu označena hvězdičkou)\n• Export PDF potvrzení o najetých mílích s místem na podpis\n• Potvrzení nese i trasu plavby po dnech — Biograd – Žut – Veli Rat – Zadar – Biograd — složenou z přístavů jednotlivých dnů; stejná zastávka dvakrát po sobě se spojí a den bez zapsaného přístavu se přeskočí.\n• Ve formuláři potvrzení nabízí pole „Pro koho\" posádku z tvých plaveb — jméno vyber, nemusíš ho psát; překlep by z jednoho člověka udělal dva záznamy.';

  @override
  String get guideHandoverTitle => 'Předávací protokol (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Formální záznam o převzetí a vrácení lodi při charteru – ikona podání rukou v detailu plavby.\n\n• Kontrolní seznam výbavy (plachty, lanoví, kotva, navigace, vesty, raft, lékárnička, dinghy, světla, bimini...) – OK / poškozeno / chybí, s poznámkou, polohou na lodi a fotkou\n• Stav paliva, vody a motohodin\n• Podpis skippera i zástupce charterové společnosti\n• Protokol se uzavře (jen ke čtení) až když podepíšou oba\n• Check-out si předvyplní údaje z check-in protokolu a zvýrazní nová poškození\n• Export PDF s oběma podpisy vedle sebe';

  @override
  String get guideGpxImportTitle => 'Import GPX';

  @override
  String get guideGpxImportBody =>
      'Importuj trasy a waypointy z jiných navigačních aplikací nebo GPS zařízení (ikona na Mapě).\n\n• Vyber .gpx soubor ze zařízení\n• Vícedenní export (více tracků v jednom souboru, např. z Garmin Explore) se automaticky spojí do jedné plavby s dnem pro každý kalendářní den\n• Nalezené tracky můžeš i ručně přiřadit k existující plavbě\n• Waypointy (i z tras/routes) se přidají rovnou na mapu\n• Při poškozeném souboru aplikace zobrazí srozumitelnou chybovou hlášku';

  @override
  String get guideWeatherTitle => 'Počasí';

  @override
  String get guideWeatherBody =>
      'Záložka Počasí zobrazuje předpověď podle aktuální polohy.\n\n• Aktualizuje se automaticky při změně polohy\n• Nahoře jsou ÚŘEDNÍ VÝSTRAHY (MeteoAlarm), pokud pro tvoji zemi nějaké platí. Nevydává je model, ale národní meteorologická služba — v Chorvatsku DHMZ, v Británii Met Office, ve Švédsku SMHI. Rozbalením uvidíš popis a pokyn; když text ve tvém jazyce není, aplikace řekne, v jakém jazyce ho čteš.\n• Předpověď bere NÁRODNÍ MODEL podle toho, kde jsi — Jadran a Itálie ARPAE ICON-2I, Británie UKMO, Skandinávie MET Norway, střední Evropa ICON-D2, jinde ECMWF. Název modelu je vidět pod aktuálním počasím.\n• Karta Stanice – naměřeno ukazuje, co opravdu někdo naměřil, i se vzdáleností a časem měření. Model a měření se mohou lišit i o polovinu.\n• Bez signálu se zobrazí poslední uložená předpověď a vždy i to, kdy se stahovala. Předpověď starší než šest hodin se označí oranžově.\n\nSlunce, měsíc a přílivy:\n• Východ, západ slunce a fáze měsíce se počítají přímo v zařízení — internet není potřeba\n• Klepnutím na obnovit v kartě Příliv/odliv stáhneš 7denní předpověď (zdarma, bez API klíče)\n• Přílivy se kešují, takže zůstanou čitelné i offline; karta tě upozorní, když je předpověď stará nebo stažená daleko odsud\n• ⚠ Výšky přílivu jsou nad střední hladinou moře, ne nad mapovým datem — nikdy je nepoužívej pro výpočet hloubky pod kýlem\n\nMořský proud:\n• Karta Mořský proud ukazuje reálnou předpověď pro tvou polohu v uzlech a směr, KAM proud teče\n• Nezaměňuj s vrstvou Oceánské proudy — ta je referenční mapa velkých globálních proudů';

  @override
  String get guideSafetyMobTitle => 'MOB a kotva';

  @override
  String get guideSafetyMobBody =>
      'Záložka Bezpečnost obsahuje nouzové funkce.\n\nMOB (Muž přes palubu):\n• Podrž červené tlačítko MOB pro aktivaci\n• Aplikace zaznamená GPS polohu a měří čas a vzdálenost\n• Navigace zpět k místu pádu\n\nKotva:\n• Nastav poloměr kotvení (doporučeno: 2× délka kotevního lana)\n• Alarm zavibruje, pokud se loď vzdálí z povoleného okruhu\n• Kotevní stráž si zapisuje vlastní trasu, takže noc na kotvě už není v GPX díra. Je to samostatný úsek — do najetých mil, vzdálenosti dne ani nočních hodin se nepočítá, houpání na řetězu není plavba.\n• Stráž přežije i restart appky: když ji systém na pozadí zabije, po spuštění sama pokračuje na téže kotvě.\n• Záznam o spuštění a vytažení kotvy už nese i vítr, tlak, teploty, hloubku pod kýlem a pohon — do té doby v něm byl jen čas a poloha.';

  @override
  String get guideSafetyBriefingTitle => 'Bezpečnostní briefing a MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'V Bezpečnosti najdeš i záložky s referenčními kartami.\n\n• Bezpečnostní briefing – checklist pro posádku před plavbou\n• Každý člen posádky se podepíše vlastním podpisem na obrazovce\n• Podpisy se uloží a automaticky se zahrnou do PDF exportu plavby\n• Předávací checklist – přehled položek pro převzetí/vrácení lodi, dostupný i bez otevřené plavby\n• MAYDAY karta – postup pro tísňové volání na VHF kanál 16\n• COLREG – pravidla pro předcházení srážkám na moři (dostupná slovensky a anglicky; ostatní jazyky zobrazí anglický text)\n• Kontakty – nouzová čísla a kontakty\n\nPozn.: Tracking lze spustit kdykoli, i bez vyplněného briefingu – aplikace to jen připomene chipem \"Chybí SB\" v Deníku, dokud ho nedokončíš. Briefing vyžaduje nejprve vyplněnou kartu lodi a posádky a uloží se až s podpisy všech členů.\n• Nouzové kontakty se vybírají podle aktuální polohy i bez zapnutého trasování – aplikace si polohu vyžádá sama a při přechodu do jiné země čísla vymění';

  @override
  String get guideDutyTitle => 'Služba posádky';

  @override
  String get guideDutyBody =>
      'Záznam o tom, kdo měl kdy službu — v Bezpečnosti, nad kotvou.\n\n• Nastoupit do služby — vyber jednoho nebo více lidí najednou; každý se pak ukončuje samostatně\n• Jména se berou z posádky plavby. Pokud posádka není vyplněna, tlačítko tě pošle do karty plavby\n• Čas nástupu lze opravit, pokud jsi tlačítko stiskl později\n• Zobrazit pro kontrolu — celoobrazovková karta pro kontrolu na palubě: kdo slouží, od kdy, čas lokálně i UTC. Nelze z ní nic měnit\n• Rozpis služeb — doplnění služby zpětně i úprava. Pokud nevyplníš čas „do\", služba běží dál\n• Noční služba přes půlnoc je jeden záznam, ne dva. V PDF se objeví na obou dnech, označená šipkou\n• Nástup i ukončení se zapíšou do deníku a do PDF exportu\n\nPozn.: aplikace službu nikdy neukončí sama. Po 12 hodinách jen upozorní — konec, který jsi neviděl, by byl vymyšlený údaj.';

  @override
  String get guideCompassTitle => 'Zaměřovací kompas';

  @override
  String get guideCompassBody =>
      'Záložka Kompas zobrazuje magnetický azimut pomocí senzorů telefonu, s výhledem zadní kamery jako pozadím pro zaměřování objektů.\n\n• Žlutý kříž – směr, na který míříš\n• Kompasová lišta nahoře – N / NE / E / SE / S / SW / W / NW\n• Číselné zobrazení – stupně a světová strana\n• Zelená tečka = stabilní čtení  ·  Oranžová tečka = kalibruje\n\nPokud je čtení nestabilní, pomalu pohybuj telefonem do tvaru osmičky pro kalibraci magnetometru.\n\nPozor: přesnost může být snížena v blízkosti kovových konstrukcí, reproduktorů nebo elektroniky.\n\nKompas řeší dva odlišné úkoly — najít SEBE, když nevíš, kde jsi, nebo najít NEZNÁMÝ BOD, když chceš na mapu zaznačit něco, co tam ještě není. Přepínač nad tlačítkem Zaměřit vybírá, který z nich právě děláš.\n\nMOJE POLOHA — najdi sebe (GPS není potřeba)\n\n1. Ověř si na mapě, že znáš alespoň dva viditelné body (maják, vrchol, kostel) jako waypointy. Chybějící bod přidáš dlouhým podržením na mapě přesně na jeho místě.\n2. Na kompase přepni na \"Moje poloha\".\n3. Klepni na štítek pod přepínačem a vyber první zaměřovaný bod.\n4. Namiř kříž přesně na něj a stiskni Zaměřit.\n5. V dialogu zkontroluj naměřený kurz a stiskni Uložit (Zrušit návrh zahodí bez zápisu).\n6. Vyber druhý, JINÝ bod (výběr se po uložení sám vyprázdní) a zopakuj.\n7. Na mapě uvidíš dvě čárkované čáry od bodů k tobě. Jejich průsečík je tvoje poloha — zelený křížek znamená dobrý řez, oranžový ostrý úhel a nejistou polohu.\n8. Třetí bod, ideálně pod jiným úhlem, zpřesní odhad a ukáže trojúhelník chyby.\n\nDělej to rychle za sebou, do 5 minut — resekce předpokládá, že loď mezi zaměřeními stojí.\n\nNEZNÁMÝ BOD — najdi objekt (GPS je potřeba)\n\n1. Přepni na \"Neznámý bod\".\n2. Klepni na štítek, zvol \"Nový bod…\" a pojmenuj, co zaměřuješ, například \"neznámá skála\".\n3. Namiř, Zaměřit, potvrď Uložit.\n4. Přesuň loď alespoň o pár set metrů — čím dál, tím jistější výsledek.\n5. Znovu otevři výběr cíle, vyber ten samý objekt ze seznamu (ne \"Nový bod\") a zaměř podruhé.\n6. Na mapě se objeví značka s vypočítanou polohou objektu. Klepnutím ji uložíš jako waypoint — a od té chvíle se dá použít i na resekci.\n\nPřesnost\n\nKompas v telefonu má reálnou chybu kolem ±8°, což je na 10 mílích vzdálenosti přes 2,5 míle do strany — přesně proto se kreslí kužel nejistoty, ne tenká čára. Nejlepší řez dávají body pod úhlem blízkým 90°; když leží skoro v jedné linii s tebou, průsečík se rozmaže na stovky metrů až kilometry.\n\nZaměření bez plavby\n\nZaměření se uloží i bez zapnutého trackingu — na kotvě, na břehu. Najdeš ho v seznamu plaveb jako samostatný řádek s datem, mezi jednotlivými plavbami. Otevřením zobrazíš zaměření toho dne i s mapkou a odtud spustíš export jednoduchého PDF s mapkou a tabulkou zaměření.\n\nČištění mapy a mazání zaměření\n\nZaměřování na čistou mapu – na Kompasu ikona obnovení vpravo nahoře. Odloží dosavadní zaměření z mapy a zruší vybraný bod či objekt, takže další Zaměř začíná načisto. Nic se neztrácí: záznamy zůstávají v kartě Lodní deník i v PDF exportu.\n\nSmazání natrvalo – otevři řádek s datem v seznamu plaveb. Křížek u řádku smaže jedno zaměření (u objektu celou sadu zaměření na něj). Koš v horní liště smaže celý den najednou a vrátí tě zpět do seznamu. Mazání je nevratné a ta zaměření zmizí i z PDF exportu.\n\nZkráceně: čištění uklízí mapu, mazání odstraňuje záznam. Obsah PDF mění jedině mazání.';

  @override
  String get guideSettingsTitle => 'Nastavení';

  @override
  String get guideSettingsBody =>
      '• Jazyk – změň jazyk aplikace\n• Přístroje – nastav IP adresu Raymarine WiFi gateway (TCP nebo UDP)\n• GPS zdroj – telefon nebo Raymarine\n• Jednotky – vzdálenost NM/km, rychlost uzly/km/h, zvlášť teplota, hloubka a vítr (na řece se hodí km + km/h)\n• Frekvence zápisů do deníku\n• Spodní menu – přizpůsob si ho: podrž a táhni ikonu pro změnu pořadí, přepínačem skryj karty, které nepoužíváš, a nastav velikost ikon (S/M/L). Skryté karty otevřeš přímo tady v Nastavení; Nastavení jsou vždy zobrazena. Pořadí i velikost se pamatují. Popisky pod ikonami jsou skryté, aby ikony seděly stejně ve všech jazycích; podržením ikony se název zobrazí.\n• Zobrazení – noční režim (červený filtr pro zachování nočního vidění)\n• Cloud export (Google Drive) – po přihlášení Google účtu se PDF a GPX z ukončeného dne automaticky nahrají na tvůj vlastní Google Drive. Bez přihlášení zůstává vše jen v zařízení.\n• Záloha dat – viz sekce \"Záloha a obnova dat\"\n• O aplikaci – verze a kontakt\n• Baterie – GPS běží na plnou přesnost jen tam, kde na přesné poloze záleží (sledování plavby, mapa, kompas, přístroje, kotevní stráž, MOB); jinde přepne do úsporného režimu a na pozadí bez zapnutého sledování se vypne úplně. Při připojených lodních přístrojích zůstává GPS telefonu vypnuté a poloha jde z NMEA.\n• Aktualizace – když je na Google Play novější verze, aplikace ji stáhne na pozadí a nabídne restart. Během záznamu plavby se neptá nikdy.\n• Časové pásmo – čas na obrazovce i v PDF se zobrazuje buď místně (pásmo telefonu, tedy oblasti, kde právě jsi), nebo v UTC. Uložené záznamy se tím nemění, přepíná se jen zobrazení; PDF vždy uvede, které pásmo platí.\n\nGoogle účet a cloudový export\n\nPřihlášení Google účtu je dobrovolné. Bez něj aplikace funguje celá a všechny záznamy zůstávají jen v telefonu.\n\nCo se nahrává – po ukončení dne plavby PDF deníku a GPX trasa toho dne. Nic jiného: žádné fotky, žádné kontakty posádky, žádné polohy v reálném čase.\n\nKam – na tvůj vlastní Google Disk, do složky HMB_Sailing_Log_DATA / název plavby / Day_datum. Ne na server aplikace – ten neexistuje.\n\nCo aplikace na Disku vidí – pouze soubory, které tam sama vytvořila. Používá nejužší oprávnění, jaké Google nabízí (drive.file), takže k ostatnímu obsahu tvého Disku se nedostane. Oprávnění si navíc žádá až při prvním nahrávání, ne při přihlášení.\n\nJak to zrušíš – odhlas účet v Nastavení. Soubory, které už na Disku jsou, zůstanou tvoje – aplikace je nemaže. Přístup lze kdykoli odebrat i v nastavení Google účtu.';

  @override
  String get guideBackupTitle => 'Záloha a obnova dat';

  @override
  String get guideBackupBody =>
      'V Nastavení → Záloha dat.\n\n• Exportovat zálohu – uloží celý deník (plavby, záznamy, nastavení) do jednoho souboru (.hmbbackup), který můžeš sdílet e-mailem, do cloudu nebo si ho uložit lokálně\n• Obnovit ze zálohy – nahradí aktuální data obsahem vybrané zálohy; před přepsáním se automaticky vytvoří bezpečnostní záloha současného stavu\n• Obnova je zablokována během aktivního GPS trackingu plavby\n• Zálohu s novějším schématem, než jaké aplikace podporuje, aplikace odmítne s vysvětlením';

  @override
  String get guideExportTitle => 'Export deníku';

  @override
  String get guideExportBody =>
      'Deník lze exportovat jako profesionální PDF dokument.\n\n1. Otevři Deník → vyber plavbu\n2. Klepni na ikonu exportu nebo tři tečky → Export PDF\n3. Podepiš jako skipper → vygeneruje se PDF\n4. PDF obsahuje: trasu, záznamy, fotky, safety briefing s podpisy posádky; titulní strana má v hlavičce fotku lodi z karty lodi (pokud je nahrána)\n5. Sdílej e-mailem, tiskni nebo ulož do telefonu\n\nKaždé PDF dostane jedinečné ID dokumentu (např. HMBSL-5-2026) a číslo revize (Rev. 1, Rev. 2...) viditelné v patičce každé strany. Při každém novém exportu se číslo automaticky zvýší – je tak vidět, kolikrát byl dokument vygenerován.\n\nQR kód na podpisové straně obsahuje ID, revizi a kryptografický otisk obsahu. Jakákoli změna dat změní QR kód.\n\nPDF se vytvoří v jazyce, který má aplikace nastaven, včetně jmen a diakritiky. Na denní straně je i přehled služby posádky.\n• Pokud se trasování během dne přerušilo a znovu spustilo, každý úsek dostane vlastní GPX soubor\n• Vzdálenosti, rychlosti a teploty v PDF se řídí jednotkami z Nastavení';

  @override
  String get safetyBriefingScreenTitle => 'Safety Briefing';

  @override
  String get briefingCrewSignaturesSection => 'Podpisy posádky';

  @override
  String get briefingSignHere => 'Podepsat zde';

  @override
  String get briefingClear => 'Smazat';

  @override
  String get briefingSigned => 'Podepsáno';

  @override
  String get briefingSave => 'Uložit podpisy';

  @override
  String get briefingSavedOk => 'Podpisy uloženy';

  @override
  String get briefingOpenBriefing => 'Safety Briefing';

  @override
  String get briefingSkipper => 'Skipper';

  @override
  String get briefingCrew => 'Posádka';

  @override
  String get briefingNoCrew =>
      'Posádka není zadána. Přidej členy v nastavení plavby.';

  @override
  String get briefingDate => 'Datum';

  @override
  String get briefingLocation => 'Místo';

  @override
  String get briefingDoneLabel => 'Safety Briefing dokončen';

  @override
  String get briefingDoneSubtitle =>
      'Podpisy posádky jsou uloženy. Není potřeba opakovat.';

  @override
  String get briefingEditSignature => 'Změnit podpis';

  @override
  String get briefingRequiredTitle => 'Vyžaduje se Safety Briefing';

  @override
  String get briefingRequiredBody =>
      'Před prvním spuštěním trackingu je potřeba dokončit Safety Briefing a shromáždit podpisy posádky.';

  @override
  String get goToBriefing => 'Přejít na Briefing';

  @override
  String get skipperProfile => 'Profil skippera';

  @override
  String get skipperProfileHint =>
      'Tyto údaje se zobrazí v PDF exportu plavby.';

  @override
  String get skipperFullName => 'Jméno skippera';

  @override
  String get skipperLicenseSection => 'Skipperská licence';

  @override
  String get skipperLicenseType => 'Typ licence';

  @override
  String get skipperLicenseNumber => 'Číslo licence';

  @override
  String get skipperLicenseAuthority => 'Vydavatel';

  @override
  String get skipperLicenseExpiry => 'Platnost do';

  @override
  String get skipperVhfSection => 'VHF / SRC licence';

  @override
  String get skipperVhfNumber => 'Číslo VHF/SRC';

  @override
  String get skipperVhfExpiry => 'Platnost VHF';

  @override
  String get skipperOtherCerts => 'Ostatní certifikáty / licence';

  @override
  String get skipperOtherCertsHint =>
      'např. Yachtmaster, RYA, STCW, záchranářské kurzy...';

  @override
  String get continueLastVoyageTitle => 'Pokračovat v poslední plavbě?';

  @override
  String get continueVoyageAction => 'Pokračovat';

  @override
  String get newRecordAction => 'Nový záznam';

  @override
  String get missingCheckInChip => 'Chybí Check-in';

  @override
  String get missingBriefingChip => 'Chybí SB';

  @override
  String get missingDetailsChip => 'Chybí karta lodi/posádky';

  @override
  String get missingCheckOutChip => 'Chybí Check-out';

  @override
  String get vesselModel => 'Model';

  @override
  String get vesselTypeMonohull => 'Jednotrupé';

  @override
  String get vesselTypeCatamaran => 'Katamarán';

  @override
  String get vesselTypeTrimaran => 'Trimaran';

  @override
  String get vesselTypeMotorYacht => 'Motorová jachta';

  @override
  String get vesselTypeGulet => 'Gulet';

  @override
  String get vesselTypeDinghy => 'Člun';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Jiné';

  @override
  String get charterCompanyLabel => 'Charterová společnost';

  @override
  String get yachtParamsSection => 'Parametry jachty';

  @override
  String get berthsLabel => 'Lůžka';

  @override
  String get yearBuiltLabel => 'Rok výroby';

  @override
  String get waterTankLabel => 'Nádrž na vodu';

  @override
  String get fuelTankLabel => 'Palivová nádrž';

  @override
  String get engineHoursStartLabel => 'Motohodiny · začátek';

  @override
  String get engineHoursEndLabel => 'Motohodiny · konec';

  @override
  String get whereWhenSection => 'Kde & kdy';

  @override
  String get countryLabel => 'Země';

  @override
  String get cruisingAreaLabel => 'Oblast plavby';

  @override
  String get charterContactsSection => 'Kontakty charteru';

  @override
  String get charterContactsHint =>
      'Až 3 čísla pro hovor / WhatsApp / SMS. Vždy s mezinárodní předvolbou (např. +385...).';

  @override
  String get addPhoneNumber => 'Přidat telefonní číslo';

  @override
  String get costsSection => 'Náklady';

  @override
  String get charterPriceLabel => 'Cena plavby';

  @override
  String get currencyLabel => 'Měna';

  @override
  String get addCostItem => 'Přidat náklad';

  @override
  String get costName => 'Název nákladu';

  @override
  String get crewSectionHint =>
      'Klepni na odznak pro nastavení skippera — ostatní jsou posádka.';

  @override
  String get addCrewMember => 'Přidat člena posádky';

  @override
  String get crewNameLabel => 'Jméno';

  @override
  String get skipperBadge => 'SKIPPER';

  @override
  String get crewBadge => 'CREW';

  @override
  String get vesselTypeSailboat => 'Plachetnice';

  @override
  String get vesselTypeMotorBoat => 'Motorový člun';

  @override
  String get sbNeedsVesselCard =>
      'Nejprve vyplň kartu lodi a posádky — Safety Briefing potřebuje seznam členů posádky pro podpisy.';

  @override
  String get prefillSkipperTitle => 'Doplnit uložené údaje skippera?';

  @override
  String get prefillSkipperFill => 'Doplnit';

  @override
  String get prefillSkipperNew => 'Nový skipper';

  @override
  String get boatLicenceLabel => 'Č. lodního průkazu';

  @override
  String get radioLicenceLabel => 'Č. rádiového průkazu';

  @override
  String get vesselPhotosSection => 'Fotky plavidla (max 3)';

  @override
  String get addPhotoLabel => 'Přidat';

  @override
  String get createVoyageButton => 'Vytvořit plavbu';

  @override
  String get saveVoyageButton => 'Uložit plavbu';

  @override
  String get costBaseCharter => 'Základní cena plavby';

  @override
  String get costDeposit => 'Kauce';

  @override
  String get costDinghyOutboard => 'Člun / přívěsný motor';

  @override
  String get costOutboardFuel => 'Palivo přívěsného motoru';

  @override
  String get costTransitLog => 'Transit log';

  @override
  String get costTouristTax => 'Pobytová daň';

  @override
  String get costFinalCleaning => 'Závěrečný úklid';

  @override
  String get costLinenTowels => 'Ložní prádlo a ručníky';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / kajak';

  @override
  String get costSkipperFee => 'Poplatek za skippera';

  @override
  String get costHostessFee => 'Poplatek za hostesku';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m m';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Přibližná poloha · ±$m m · síťová lokalizace';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Poslední známá poloha · před $mins min';
  }

  @override
  String get locationQualityUnknown => 'Přesnost neznámá';

  @override
  String get locationQualityMocked => '⚠️ Zjištěna falešná poloha';

  @override
  String get syncQueueTitle => 'Fronta synchronizace';

  @override
  String get syncQueueEmpty => 'Fronta je prázdná';

  @override
  String get syncNowAction => 'Synchronizovat nyní';

  @override
  String get syncRetryFailedAction => 'Zkusit znovu';

  @override
  String get syncStatusPending => 'Čeká';

  @override
  String get syncStatusSending => 'Odesílá se';

  @override
  String get syncStatusSent => 'Odesláno';

  @override
  String get syncStatusFailed => 'Selhalo';

  @override
  String get syncStatusConflict => 'Konflikt';

  @override
  String get syncStatusDeferred => 'Odloženo';

  @override
  String syncRetryCount(int n) {
    return 'Pokus $n';
  }

  @override
  String get syncOffline => 'offline';

  @override
  String syncPendingCount(int n) {
    return '$n čeká';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n odloženo';
  }

  @override
  String syncFailedCount(int n) {
    return '$n selhalo';
  }

  @override
  String get syncWifiOverrideBanner =>
      'Příloha čeká na Wi-Fi (na moři obvykle nedostupné).';

  @override
  String get syncWifiOverrideAction => 'Použít mobilní data';

  @override
  String get syncWifiOverrideActive => 'Mobilní data povolena pro přílohy';

  @override
  String get syncClearQueueAction => 'Vymazat frontu';

  @override
  String get syncClearQueueConfirmTitle => 'Vymazat celou frontu?';

  @override
  String get syncClearQueueConfirmContent =>
      'Odstraní všechny položky ve frontě synchronizace včetně již odeslaných. Tuto akci nelze vrátit.';

  @override
  String get syncClearQueueDone => 'Fronta vymazána';

  @override
  String get syncEnableToggle => 'Synchronizovat deník';

  @override
  String get syncEnableToggleDesc =>
      'Odesílat záznamy na server, když je aplikace otevřená a online';

  @override
  String get syncTargetLabel => 'Cíl synchronizace';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Vlastní server';

  @override
  String get syncCustomUrlLabel => 'URL serveru';

  @override
  String get syncCustomTokenLabel => 'Token';

  @override
  String get syncTestConnectionAction => 'Otestovat připojení';

  @override
  String get syncTestSuccess => 'Připojení funguje';

  @override
  String syncTestFailure(String detail) {
    return 'Selhalo: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Zadej URL serveru';

  @override
  String get syncUrlErrorInvalid => 'Neplatná URL';

  @override
  String get syncUrlErrorHttps => 'URL musí začínat https://';

  @override
  String get syncIntervalLabel => 'Interval synchronizace';

  @override
  String syncIntervalMinutes(int n) {
    return '$n min';
  }

  @override
  String get syncIntervalNote =>
      'Synchronizace běží, dokud je aplikace otevřená';

  @override
  String get syncAttachmentPolicyLabel => 'Přílohy (fotky)';

  @override
  String get syncAttachmentNever => 'Nikdy';

  @override
  String get syncAttachmentWifiOnly => 'Jen na Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Vždy';

  @override
  String get syncBackfillAction => 'Doplnit starší záznamy';

  @override
  String get syncBackfillDesc =>
      'Zařadí do fronty záznamy zapsané, když byla synchronizace vypnutá';

  @override
  String syncBackfillResult(int n) {
    return '$n doplněno do fronty';
  }

  @override
  String get syncBackfillNone =>
      'Nic k doplnění — vše je již ve frontě nebo odesláno';

  @override
  String get syncCloudEnableToggle => 'Cloud export (Google Drive)';

  @override
  String get syncCloudEnableToggleDesc =>
      'Po přihlášení se PDF a GPX z ukončeného dne automaticky nahrají na Google Drive. Bez přihlášení zůstává vše jen v zařízení.';

  @override
  String get syncCloudSignInAction => 'Přihlásit Google účet';

  @override
  String get syncCloudSignOutAction => 'Odhlásit';

  @override
  String syncCloudSignedInAs(String email) {
    return 'Přihlášen jako $email';
  }

  @override
  String get syncCloudNotSignedIn => 'Nepřihlášen';

  @override
  String get waypointNameHint => 'např. Kotviště, Přístav...';

  @override
  String waypointDefaultName(String time) {
    return 'Bod $time';
  }

  @override
  String get mobFullName => 'Muž přes palubu';

  @override
  String get maydayCardShort => 'Mayday\nkarta';

  @override
  String get morseInputHint => 'Zadejte text...';

  @override
  String get morseSosTitle => 'SOS – TÍSŇOVÝ SIGNÁL';

  @override
  String get morseSosCopied => 'SOS zkopírováno';

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
    return '$n hod';
  }

  @override
  String get aboutFeatureGps => 'GPS sledování s automatickými zápisy';

  @override
  String get aboutFeatureLogbook => 'Deník vícedenních plaveb';

  @override
  String get aboutFeatureMaps => 'Offline námořní mapy (OpenSeaMap)';

  @override
  String get aboutFeatureWeather => 'Námořní předpověď počasí (Open-Meteo)';

  @override
  String get aboutFeatureExport => 'Export PDF + GPX';

  @override
  String get aboutFeatureSafety => 'Bezpečnostní instruktáž a Mayday karta';

  @override
  String get aboutAuthorLabel => 'Autor';

  @override
  String get aboutVersionLabel => 'Verze';

  @override
  String get aboutPlatformLabel => 'Platforma';

  @override
  String cloudSignInFailed(String error) {
    return 'Přihlášení selhalo: $error';
  }

  @override
  String cloudSignOutFailed(String error) {
    return 'Odhlášení selhalo: $error';
  }

  @override
  String get marineInstrumentsWifiNote =>
      'Funguje jen přes WiFi síť lodi – telefon musí být připojen k NMEA gateway (Raymarine, Digital Yacht, Yacht Devices…). Bez WiFi aplikace používá GPS telefonu a předpověď počasí z internetu.';

  @override
  String get interruptedVoyageTitle => 'Trasování bylo přerušeno';

  @override
  String interruptedVoyageBody(String time) {
    return 'Aplikace se vypnula v $time bez ukončení plavby. Pokračovat ve stejné plavbě?';
  }

  @override
  String interruptedVoyageGap(String distance) {
    return 'Aktuální poloha je $distance NM od posledního zaznamenaného bodu.';
  }

  @override
  String get interruptedVoyageAddGap => 'Dopočítat tuto vzdálenost do plavby';

  @override
  String get interruptedVoyageResume => 'Pokračovat';

  @override
  String get trackingStalledTitle => 'Plavba běží, ale nic se nezapisuje';

  @override
  String trackingStalledSince(String minutes) {
    return 'Poslední bod před $minutes min';
  }

  @override
  String get trackingResumeAction => 'Pokračovat';

  @override
  String trackingResumedAuto(String minutes) {
    return 'Trasování pokračuje. Appku mezitím vypnul systém — chybí $minutes min.';
  }

  @override
  String trackingResumedAddGap(String nm) {
    return 'Dopočítat $nm NM';
  }

  @override
  String get batteryPromptTitle => 'Ať aplikace běží celou plavbu';

  @override
  String get batteryPromptBody =>
      'Android — a hlavně Honor, Huawei či Xiaomi — vypíná aplikace běžící na pozadí, čímž se trasování uprostřed plavby přeruší.\n\nV nastavení baterie povolte této aplikaci běh bez omezení. Na Honor/Huawei ji navíc přidejte mezi chráněné aplikace a povolte automatické spouštění.';

  @override
  String get batteryPromptAction => 'Otevřít nastavení';

  @override
  String get speed => 'Rychlost';

  @override
  String get dateFormatLabel => 'Formát data';

  @override
  String get dateFormatByLanguage => 'Podle jazyka aplikace';

  @override
  String get crewCertTitle => 'Potvrzení o naplavaných mílích';

  @override
  String get crewCertVoyage => 'Plavba';

  @override
  String get crewCertArea => 'Oblast plavby';

  @override
  String get crewCertRoute => 'Trasa plavby';

  @override
  String get crewCertDayMiles => 'Denní míle';

  @override
  String get crewCertNightMiles => 'Noční míle';

  @override
  String get crewCertNightHours => 'Noční hodiny';

  @override
  String get crewCertQualifications => 'Kvalifikace';

  @override
  String get crewCertAssessment => 'Hodnocení skippera';

  @override
  String get crewCertStamp => 'Razítko';

  @override
  String get crewCertHashCoverage =>
      'Otisk pokrývá souhrn plavby i hodnocení posádky.';

  @override
  String get crewSkillHelming => 'Kormidlování';

  @override
  String get crewSkillNavigation => 'Navigace';

  @override
  String get crewSkillHarbour => 'Manévry v přístavu';

  @override
  String get crewSkillTeamwork => 'Práce v týmu';

  @override
  String get crewSkillNightSailing => 'Noční plavba';

  @override
  String get crewCertExport => 'Exportovat potvrzení';

  @override
  String get crewCertNoteHint => 'Slovní hodnocení (nepovinné)';

  @override
  String get crewCertNoCrew =>
      'Plavba nemá zadanou posádku. Doplň ji v kartě plavby.';

  @override
  String get crewCertNotRated => 'nehodnoceno';

  @override
  String get crewCertShared => 'Potvrzení vytvořena';

  @override
  String get more => 'Více';

  @override
  String get crewCertSkipperRates =>
      'Skipper hodnotí posádku — sám se nehodnotí. Potvrzení o mílích dostane také.';

  @override
  String get crewCertVesselSize => 'Rozměry lodi';

  @override
  String get crewCertVesselRegistration => 'Registrace';

  @override
  String get crewCertWaters => 'Vody';

  @override
  String get crewCertWatersTidal => 'přílivové';

  @override
  String get crewCertWatersNonTidal => 'nepřílivové';

  @override
  String get crewCertIdDocument => 'Číslo pasu / OP';

  @override
  String get crewCertDaysAtSea => 'Dny na moři';

  @override
  String get crewCertTotal => 'Celkem';

  @override
  String get crewCertWatersLabel => 'Typ vod';

  @override
  String get bearingTakeSight => 'Zaměřit';

  @override
  String bearingSaved(String bearing) {
    return 'Zaměření $bearing uloženo';
  }

  @override
  String get bearingNoPosition =>
      'Bez GPS nelze neznámý bod určit. Přepni na „Moje poloha“ — resekce ze známých bodů GPS nepotřebuje.';

  @override
  String get bearingSaveFailed => 'Zaměření se nepodařilo uložit';

  @override
  String get bearingLabelHint => 'Co zaměřuješ? (nepovinné)';

  @override
  String bearingDeclinationApplied(String value) {
    return 'Deklinace $value';
  }

  @override
  String get bearingDeclinationExpired =>
      'Magnetický model vypršel – deklinace je jen odhad';

  @override
  String get bearingsLayer => 'Zaměření';

  @override
  String get bearingsTitle => 'Zaměření';

  @override
  String get bearingsClearAll => 'Skrýt vše z mapy';

  @override
  String get bearingsClearConfirm =>
      'Skrýt všechna zaměření z mapy? Čáry i křížové zaměření zmizí z mapy, v deníku zůstanou.';

  @override
  String get bearingsEmpty =>
      'Zatím žádná zaměření. Namiř telefon na objekt a stiskni Zaměřit.';

  @override
  String get bearingsDeleteDayConfirm =>
      'Všechna zaměření z tohoto dne se nenávratně smažou, i z PDF exportu. Tento krok nelze vrátit.';

  @override
  String bearingFixFrom(int count) {
    return 'Poloha z $count zaměření';
  }

  @override
  String bearingFixWeak(String angle) {
    return 'Slabý fix – čáry se protínají pod $angle';
  }

  @override
  String bearingFixOffGps(String distance) {
    return 'Odchylka od GPS: $distance';
  }

  @override
  String get bearingTrueLabel => 'pravý';

  @override
  String get bearingMagneticLabel => 'magnetický';

  @override
  String bearingUncertaintyNote(String deg) {
    return 'Kužel ukazuje ±$deg nejistotu kompasu v telefonu.';
  }

  @override
  String get bearingPdfSection => 'Zaměření';

  @override
  String get bearingPdfObject => 'Objekt';

  @override
  String get bearingPdfBearing => 'Pravý kurz';

  @override
  String get bearingModeResection => 'Moje poloha';

  @override
  String get bearingModeObject => 'Neznámý bod';

  @override
  String get bearingModeResectionHint =>
      'Zaměř 2–3 známé body z mapy. GPS není potřeba.';

  @override
  String get bearingModeObjectHint =>
      'Zaměř ten samý bod z 2–3 různých míst. Je potřeba GPS.';

  @override
  String get bearingPickTarget => 'Vyber zaměřovaný bod';

  @override
  String get bearingNeedsTarget => 'Nejprve vyber známý bod z mapy, pak zaměř';

  @override
  String get bearingNeedsObject => 'Nejprve pojmenuj zaměřovaný bod';

  @override
  String get bearingNewObject => 'Nový bod…';

  @override
  String get bearingObjectName => 'Název bodu (např. neznámá skála)';

  @override
  String get bearingOpenObjects => 'Zaměřované body';

  @override
  String bearingSightCount(int count) {
    return '$count zaměření';
  }

  @override
  String get bearingSameTargetHint =>
      'Ten samý bod jako předtím — na resekci je potřeba jiný.';

  @override
  String get bearingShortBaselineHint =>
      'Krátká základna — přesuň se a zaměř znovu.';

  @override
  String get bearingMovedHint =>
      'Loď se mezi zaměřeními posunula — resekce předpokládá, že stojí.';

  @override
  String get bearingNeedsSecondSight =>
      'Ještě jedno zaměření na jiný bod a poloha vyjde.';

  @override
  String get bearingMyPositionFix => 'Moje poloha';

  @override
  String get bearingObjectFix => 'Určený bod';

  @override
  String get bearingSaveObjectAsWaypoint => 'Ulož jako waypoint';

  @override
  String bearingObjectSaved(String name) {
    return '$name uložen jako waypoint';
  }

  @override
  String get bearingDeclinationFromTarget =>
      'Deklinace počítaná v poloze zaměřeného bodu';

  @override
  String get bearingResectionSection => 'Resekce — poloha ze známých bodů';

  @override
  String get bearingObjectSection => 'Zaměření neznámých bodů';

  @override
  String get bearingPdfMark => 'Zaměřený bod';

  @override
  String get bearingPdfResult => 'Výsledek';

  @override
  String get bearingStartNew => 'Začít nové zaměření';

  @override
  String get bearingHideFromMap => 'Skrýt z mapy';
}
