import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('hr'),
    Locale('it'),
    Locale('pl'),
    Locale('sk'),
    Locale('sl'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In sk, this message translates to:
  /// **'HMB Sailing Log'**
  String get appTitle;

  /// No description provided for @poiTypeAnchorage.
  ///
  /// In sk, this message translates to:
  /// **'Kotvisko'**
  String get poiTypeAnchorage;

  /// No description provided for @poiTypeMarina.
  ///
  /// In sk, this message translates to:
  /// **'Marína'**
  String get poiTypeMarina;

  /// No description provided for @poiTypeFuel.
  ///
  /// In sk, this message translates to:
  /// **'Tankovacia stanica'**
  String get poiTypeFuel;

  /// No description provided for @poiTypeHarbour.
  ///
  /// In sk, this message translates to:
  /// **'Prístav'**
  String get poiTypeHarbour;

  /// No description provided for @poiVhfChannel.
  ///
  /// In sk, this message translates to:
  /// **'VHF kanál'**
  String get poiVhfChannel;

  /// No description provided for @poiPhone.
  ///
  /// In sk, this message translates to:
  /// **'Telefón'**
  String get poiPhone;

  /// No description provided for @poiCannotOpen.
  ///
  /// In sk, this message translates to:
  /// **'Nedá sa otvoriť'**
  String get poiCannotOpen;

  /// No description provided for @poiWebsite.
  ///
  /// In sk, this message translates to:
  /// **'Web'**
  String get poiWebsite;

  /// No description provided for @poiEmail.
  ///
  /// In sk, this message translates to:
  /// **'Email'**
  String get poiEmail;

  /// No description provided for @poiCapacity.
  ///
  /// In sk, this message translates to:
  /// **'Kapacita'**
  String get poiCapacity;

  /// No description provided for @poiServices.
  ///
  /// In sk, this message translates to:
  /// **'Služby'**
  String get poiServices;

  /// No description provided for @poiSaveAsWaypoint.
  ///
  /// In sk, this message translates to:
  /// **'Uložiť ako waypoint'**
  String get poiSaveAsWaypoint;

  /// No description provided for @poiWaypointSaved.
  ///
  /// In sk, this message translates to:
  /// **'Waypoint \"{name}\" uložený'**
  String poiWaypointSaved(String name);

  /// No description provided for @poiSource.
  ///
  /// In sk, this message translates to:
  /// **'Zdroj: OpenStreetMap'**
  String get poiSource;

  /// No description provided for @mapLayerSatellite.
  ///
  /// In sk, this message translates to:
  /// **'Satelit'**
  String get mapLayerSatellite;

  /// No description provided for @mapLayerMap.
  ///
  /// In sk, this message translates to:
  /// **'Mapa'**
  String get mapLayerMap;

  /// No description provided for @mapLayers.
  ///
  /// In sk, this message translates to:
  /// **'Vrstvy'**
  String get mapLayers;

  /// No description provided for @mapSeamarks.
  ///
  /// In sk, this message translates to:
  /// **'Seamarky'**
  String get mapSeamarks;

  /// No description provided for @mapDepths.
  ///
  /// In sk, this message translates to:
  /// **'Hĺbky'**
  String get mapDepths;

  /// No description provided for @mapDepthHere.
  ///
  /// In sk, this message translates to:
  /// **'Hĺbka tu: {depth}'**
  String mapDepthHere(String depth);

  /// No description provided for @mapDepthNoData.
  ///
  /// In sk, this message translates to:
  /// **'Pre tento bod nie sú údaje o hĺbke'**
  String get mapDepthNoData;

  /// No description provided for @weatherModelSource.
  ///
  /// In sk, this message translates to:
  /// **'Model: {model}'**
  String weatherModelSource(String model);

  /// No description provided for @weatherOfflineNoAge.
  ///
  /// In sk, this message translates to:
  /// **'Bez signálu — zobrazená posledná uložená predpoveď'**
  String get weatherOfflineNoAge;

  /// No description provided for @weatherOfflineSince.
  ///
  /// In sk, this message translates to:
  /// **'Bez signálu — predpoveď z {when}'**
  String weatherOfflineSince(String when);

  /// No description provided for @weatherStaleSince.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď je stará — stiahnutá {when}'**
  String weatherStaleSince(String when);

  /// No description provided for @warningNoDetail.
  ///
  /// In sk, this message translates to:
  /// **'Podrobnosti sa nepodarilo načítať.'**
  String get warningNoDetail;

  /// No description provided for @warningSourceMeteoalarm.
  ///
  /// In sk, this message translates to:
  /// **'Zdroj: MeteoAlarm'**
  String get warningSourceMeteoalarm;

  /// No description provided for @warningLanguageNote.
  ///
  /// In sk, this message translates to:
  /// **'Text je v jazyku: {lang}'**
  String warningLanguageNote(String lang);

  /// No description provided for @mapHarbours.
  ///
  /// In sk, this message translates to:
  /// **'Prístavy a kotviská'**
  String get mapHarbours;

  /// No description provided for @mapZoomInForPois.
  ///
  /// In sk, this message translates to:
  /// **'Priblíž mapu pre načítanie prístavov a kotvísk'**
  String get mapZoomInForPois;

  /// No description provided for @mapRainRadar.
  ///
  /// In sk, this message translates to:
  /// **'Zrážkový radar'**
  String get mapRainRadar;

  /// No description provided for @mapTools.
  ///
  /// In sk, this message translates to:
  /// **'Nástroje'**
  String get mapTools;

  /// No description provided for @mapVoyageOverview.
  ///
  /// In sk, this message translates to:
  /// **'Prehľad plavby'**
  String get mapVoyageOverview;

  /// No description provided for @playbackTitle.
  ///
  /// In sk, this message translates to:
  /// **'Prehrať plavbu'**
  String get playbackTitle;

  /// No description provided for @playbackSpeed.
  ///
  /// In sk, this message translates to:
  /// **'Rýchlosť'**
  String get playbackSpeed;

  /// No description provided for @playbackNoTrack.
  ///
  /// In sk, this message translates to:
  /// **'Tento deň nemá zaznamenanú trasu'**
  String get playbackNoTrack;

  /// No description provided for @playbackAtTime.
  ///
  /// In sk, this message translates to:
  /// **'Stav o {time}'**
  String playbackAtTime(String time);

  /// No description provided for @mapRuler.
  ///
  /// In sk, this message translates to:
  /// **'Pravítko / trasa'**
  String get mapRuler;

  /// No description provided for @mapDownloadOffline.
  ///
  /// In sk, this message translates to:
  /// **'Stiahnuť oblasť offline'**
  String get mapDownloadOffline;

  /// No description provided for @mapGpsDisabled.
  ///
  /// In sk, this message translates to:
  /// **'GPS je vypnuté'**
  String get mapGpsDisabled;

  /// No description provided for @mapLocationDenied.
  ///
  /// In sk, this message translates to:
  /// **'Poloha nie je povolená'**
  String get mapLocationDenied;

  /// No description provided for @mapFollowGps.
  ///
  /// In sk, this message translates to:
  /// **'Sleduj GPS'**
  String get mapFollowGps;

  /// No description provided for @mapAreaTooLarge.
  ///
  /// In sk, this message translates to:
  /// **'Oblasť je príliš veľká ({count} dlaždíc). Priblíž mapu a skús znova.'**
  String mapAreaTooLarge(int count);

  /// No description provided for @mapLivePreview.
  ///
  /// In sk, this message translates to:
  /// **'Naživo (aktuálny tracking)'**
  String get mapLivePreview;

  /// No description provided for @mapWholeVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Celá plavba'**
  String get mapWholeVoyage;

  /// No description provided for @offlineSheetTitle.
  ///
  /// In sk, this message translates to:
  /// **'Offline mapa viditeľnej oblasti'**
  String get offlineSheetTitle;

  /// No description provided for @offlineSheetDesc.
  ///
  /// In sk, this message translates to:
  /// **'Mapa + seamarky, zoom {minZ}–{maxZ}, {tiles} dlaždíc (~{mb} MB). Stiahnuté oblasti fungujú na mori bez signálu.'**
  String offlineSheetDesc(int minZ, int maxZ, int tiles, String mb);

  /// No description provided for @offlineDone.
  ///
  /// In sk, this message translates to:
  /// **'Hotovo — {n} dlaždíc uložených'**
  String offlineDone(int n);

  /// No description provided for @offlineDoneErrors.
  ///
  /// In sk, this message translates to:
  /// **'Hotovo s chybami: {n} dlaždíc sa nepodarilo stiahnuť'**
  String offlineDoneErrors(int n);

  /// No description provided for @downloadAction.
  ///
  /// In sk, this message translates to:
  /// **'Stiahnuť'**
  String get downloadAction;

  /// No description provided for @rulerTapHint.
  ///
  /// In sk, this message translates to:
  /// **'Ťukni body na mape'**
  String get rulerTapHint;

  /// No description provided for @mapEntryPhoto.
  ///
  /// In sk, this message translates to:
  /// **'Foto záznam'**
  String get mapEntryPhoto;

  /// No description provided for @mapEntryNote.
  ///
  /// In sk, this message translates to:
  /// **'Záznam denníka'**
  String get mapEntryNote;

  /// No description provided for @openSettingsAction.
  ///
  /// In sk, this message translates to:
  /// **'Otvoriť nastavenia'**
  String get openSettingsAction;

  /// No description provided for @morseConverter.
  ///
  /// In sk, this message translates to:
  /// **'Prevodník text → Morse'**
  String get morseConverter;

  /// No description provided for @saveError.
  ///
  /// In sk, this message translates to:
  /// **'Chyba pri ukladaní: {error}'**
  String saveError(String error);

  /// No description provided for @languageName.
  ///
  /// In sk, this message translates to:
  /// **'Slovenčina'**
  String get languageName;

  /// No description provided for @navMap.
  ///
  /// In sk, this message translates to:
  /// **'Mapa'**
  String get navMap;

  /// No description provided for @navTracking.
  ///
  /// In sk, this message translates to:
  /// **'Tracking'**
  String get navTracking;

  /// No description provided for @navLogbook.
  ///
  /// In sk, this message translates to:
  /// **'Denník'**
  String get navLogbook;

  /// No description provided for @navWeather.
  ///
  /// In sk, this message translates to:
  /// **'Počasie'**
  String get navWeather;

  /// No description provided for @navSafety.
  ///
  /// In sk, this message translates to:
  /// **'Bezpečnosť'**
  String get navSafety;

  /// No description provided for @navCompass.
  ///
  /// In sk, this message translates to:
  /// **'Kompas'**
  String get navCompass;

  /// No description provided for @navSettings.
  ///
  /// In sk, this message translates to:
  /// **'Nastavenia'**
  String get navSettings;

  /// No description provided for @navCustomizeTitle.
  ///
  /// In sk, this message translates to:
  /// **'Spodné menu'**
  String get navCustomizeTitle;

  /// No description provided for @navCustomizeHint.
  ///
  /// In sk, this message translates to:
  /// **'Podrž a potiahni pre zmenu poradia ikon. Prepínačom kartu skryješ zo spodného menu — Nastavenia sú vždy zobrazené.'**
  String get navCustomizeHint;

  /// No description provided for @navAlwaysShown.
  ///
  /// In sk, this message translates to:
  /// **'Vždy zobrazené'**
  String get navAlwaysShown;

  /// No description provided for @navIconSizeLabel.
  ///
  /// In sk, this message translates to:
  /// **'Veľkosť ikon'**
  String get navIconSizeLabel;

  /// No description provided for @navOpenHiddenTitle.
  ///
  /// In sk, this message translates to:
  /// **'Otvoriť skryté karty'**
  String get navOpenHiddenTitle;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In sk, this message translates to:
  /// **'Prístup ku kamere bol zamietnutý. Povoľ ho v nastaveniach zariadenia.'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraUnavailable.
  ///
  /// In sk, this message translates to:
  /// **'Kamera nedostupná'**
  String get cameraUnavailable;

  /// No description provided for @compassCalibrationNote.
  ///
  /// In sk, this message translates to:
  /// **'Magnetický kompas. Presnosť môže byť ovplyvnená kovom alebo elektronikou v blízkosti. Nekalibrovaný kompas kalibruj pohybom v tvare osmičky.'**
  String get compassCalibrationNote;

  /// No description provided for @cancel.
  ///
  /// In sk, this message translates to:
  /// **'Zrušiť'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In sk, this message translates to:
  /// **'Upraviť'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In sk, this message translates to:
  /// **'Uložiť'**
  String get save;

  /// No description provided for @yes.
  ///
  /// In sk, this message translates to:
  /// **'Áno'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In sk, this message translates to:
  /// **'Nie'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In sk, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In sk, this message translates to:
  /// **'Zavrieť'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In sk, this message translates to:
  /// **'Skúsiť znova'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In sk, this message translates to:
  /// **'Zdieľať'**
  String get share;

  /// No description provided for @selectAll.
  ///
  /// In sk, this message translates to:
  /// **'Vybrať všetko'**
  String get selectAll;

  /// No description provided for @error.
  ///
  /// In sk, this message translates to:
  /// **'Chyba'**
  String get error;

  /// No description provided for @errorMsg.
  ///
  /// In sk, this message translates to:
  /// **'Chyba: {msg}'**
  String errorMsg(String msg);

  /// No description provided for @pressBackToExit.
  ///
  /// In sk, this message translates to:
  /// **'Stlač Späť ešte raz pre ukončenie'**
  String get pressBackToExit;

  /// No description provided for @trackingRunningTitle.
  ///
  /// In sk, this message translates to:
  /// **'Tracking beží'**
  String get trackingRunningTitle;

  /// No description provided for @trackingRunningContent.
  ///
  /// In sk, this message translates to:
  /// **'Tracking je aktívny. Čo chceš urobiť?'**
  String get trackingRunningContent;

  /// No description provided for @stopAndExit.
  ///
  /// In sk, this message translates to:
  /// **'Zastaviť a ukončiť'**
  String get stopAndExit;

  /// No description provided for @keepRunning.
  ///
  /// In sk, this message translates to:
  /// **'Nechať bežať'**
  String get keepRunning;

  /// No description provided for @marineInstrumentsTitle.
  ///
  /// In sk, this message translates to:
  /// **'Lodné inštrumenty'**
  String get marineInstrumentsTitle;

  /// No description provided for @marineInstrumentsPrompt.
  ///
  /// In sk, this message translates to:
  /// **'Chceš pripojiť aplikáciu k lodným inštrumentom (napr. Raymarine cez WiFi gateway)? Aplikácia potom bude čítať GPS, vietor, hĺbku a ďalšie údaje priamo z lode.\n\nBez pripojenia sa použije GPS telefónu a predpoveď počasia z internetu – kedykoľvek to vieš zmeniť v Nastaveniach.'**
  String get marineInstrumentsPrompt;

  /// No description provided for @notNow.
  ///
  /// In sk, this message translates to:
  /// **'Teraz nie'**
  String get notNow;

  /// No description provided for @setupConnection.
  ///
  /// In sk, this message translates to:
  /// **'Nastaviť pripojenie'**
  String get setupConnection;

  /// No description provided for @autoDetectAction.
  ///
  /// In sk, this message translates to:
  /// **'Auto-detekcia'**
  String get autoDetectAction;

  /// No description provided for @autoDetectWifiHintTitle.
  ///
  /// In sk, this message translates to:
  /// **'Najprv sa pripoj na WiFi lode'**
  String get autoDetectWifiHintTitle;

  /// No description provided for @autoDetectWifiHintBody.
  ///
  /// In sk, this message translates to:
  /// **'Skontroluj v Nastaveniach telefónu → WiFi, že si pripojený na sieť lodných inštrumentov (napr. RayNet, WiFi-1). Potom appka skúsi automaticky nájsť gateway na tejto sieti.'**
  String get autoDetectWifiHintBody;

  /// No description provided for @openWifiSettings.
  ///
  /// In sk, this message translates to:
  /// **'WiFi nastavenia'**
  String get openWifiSettings;

  /// No description provided for @continueAction.
  ///
  /// In sk, this message translates to:
  /// **'Pokračovať'**
  String get continueAction;

  /// No description provided for @autoDetecting.
  ///
  /// In sk, this message translates to:
  /// **'Hľadám prístroje na WiFi sieti…'**
  String get autoDetecting;

  /// No description provided for @autoDetectFailed.
  ///
  /// In sk, this message translates to:
  /// **'Gateway sa nenašiel. Skontroluj, či si pripojený na WiFi sieť lode, alebo zadaj IP ručne v Nastaveniach.'**
  String get autoDetectFailed;

  /// No description provided for @autoDetectSuccess.
  ///
  /// In sk, this message translates to:
  /// **'Pripojené na {host}'**
  String autoDetectSuccess(String host);

  /// No description provided for @guidePromptTitle.
  ///
  /// In sk, this message translates to:
  /// **'Prvýkrát tu? Rýchla príručka'**
  String get guidePromptTitle;

  /// No description provided for @guidePromptBody.
  ///
  /// In sk, this message translates to:
  /// **'Aplikácia má krátku používateľskú príručku – mapa, lodný denník, počasie, bezpečnostný checklist a ďalšie. Chceš sa na ňu rýchlo pozrieť teraz? Kedykoľvek ju nájdeš aj neskôr v Nastaveniach → Používateľská príručka.'**
  String get guidePromptBody;

  /// No description provided for @guidePromptAction.
  ///
  /// In sk, this message translates to:
  /// **'Ukázať príručku'**
  String get guidePromptAction;

  /// No description provided for @notifPromptTitle.
  ///
  /// In sk, this message translates to:
  /// **'Povoliť upozornenia?'**
  String get notifPromptTitle;

  /// No description provided for @notifPromptBody.
  ///
  /// In sk, this message translates to:
  /// **'Počas sledovania plavby beží upozornenie v systémovej lište a na zamknutej obrazovke — vidíš, že tracking je aktívny, a máš k nemu rýchly prístup. Bez povolenia môže systém sledovanie na pozadí obmedziť.'**
  String get notifPromptBody;

  /// No description provided for @notifPromptAllow.
  ///
  /// In sk, this message translates to:
  /// **'Povoliť'**
  String get notifPromptAllow;

  /// No description provided for @trackingActiveTitle.
  ///
  /// In sk, this message translates to:
  /// **'Tracking aktívny'**
  String get trackingActiveTitle;

  /// No description provided for @trackingTitle.
  ///
  /// In sk, this message translates to:
  /// **'Tracking'**
  String get trackingTitle;

  /// No description provided for @waitingForGps.
  ///
  /// In sk, this message translates to:
  /// **'Čakám na GPS...'**
  String get waitingForGps;

  /// No description provided for @gpsUnavailable.
  ///
  /// In sk, this message translates to:
  /// **'GPS nedostupné'**
  String get gpsUnavailable;

  /// No description provided for @lastKnownPosition.
  ///
  /// In sk, this message translates to:
  /// **'Posledná známa poloha'**
  String get lastKnownPosition;

  /// No description provided for @accuracy.
  ///
  /// In sk, this message translates to:
  /// **'Presnosť'**
  String get accuracy;

  /// No description provided for @logbookBtn.
  ///
  /// In sk, this message translates to:
  /// **'Denník'**
  String get logbookBtn;

  /// No description provided for @stop.
  ///
  /// In sk, this message translates to:
  /// **'Zastaviť'**
  String get stop;

  /// No description provided for @stopTrackingDay.
  ///
  /// In sk, this message translates to:
  /// **'Ukončiť tracking?'**
  String get stopTrackingDay;

  /// No description provided for @startVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Spustiť plavbu'**
  String get startVoyage;

  /// No description provided for @starting.
  ///
  /// In sk, this message translates to:
  /// **'Spúšťam...'**
  String get starting;

  /// No description provided for @newVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Nová plavba'**
  String get newVoyage;

  /// No description provided for @multiday.
  ///
  /// In sk, this message translates to:
  /// **'Viacdenná'**
  String get multiday;

  /// No description provided for @standalone.
  ///
  /// In sk, this message translates to:
  /// **'Samostatný'**
  String get standalone;

  /// No description provided for @voyageName.
  ///
  /// In sk, this message translates to:
  /// **'Názov plavby'**
  String get voyageName;

  /// No description provided for @voyageNameOptional.
  ///
  /// In sk, this message translates to:
  /// **'Názov (voliteľné)'**
  String get voyageNameOptional;

  /// No description provided for @voyageNameHint.
  ///
  /// In sk, this message translates to:
  /// **'napr. Výlet do zátoky'**
  String get voyageNameHint;

  /// No description provided for @existingVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Pokračovanie existujúcej plavby'**
  String get existingVoyage;

  /// No description provided for @newVoyageDropdown.
  ///
  /// In sk, this message translates to:
  /// **'— Nová plavba —'**
  String get newVoyageDropdown;

  /// No description provided for @firstVoyageHint.
  ///
  /// In sk, this message translates to:
  /// **'Prvá plavba – vyplň základné info:'**
  String get firstVoyageHint;

  /// No description provided for @briefingRequiredHint.
  ///
  /// In sk, this message translates to:
  /// **'Tracking sa dá spustiť až po dokončení Safety Briefingu pre danú plavbu.'**
  String get briefingRequiredHint;

  /// No description provided for @briefingPending.
  ///
  /// In sk, this message translates to:
  /// **'SB potrebný'**
  String get briefingPending;

  /// No description provided for @briefingPendingListWarning.
  ///
  /// In sk, this message translates to:
  /// **'Safety Briefing nedokončený – tracking zatiaľ nejde spustiť'**
  String get briefingPendingListWarning;

  /// No description provided for @estimatedDays.
  ///
  /// In sk, this message translates to:
  /// **'Predpokladaný počet dní:'**
  String get estimatedDays;

  /// No description provided for @logFrequency.
  ///
  /// In sk, this message translates to:
  /// **'Frekvencia zápisov do denníka'**
  String get logFrequency;

  /// No description provided for @startTracking.
  ///
  /// In sk, this message translates to:
  /// **'Spustiť tracking'**
  String get startTracking;

  /// No description provided for @trackingInProgress.
  ///
  /// In sk, this message translates to:
  /// **'Sledovanie plavby'**
  String get trackingInProgress;

  /// No description provided for @dayNofTotal.
  ///
  /// In sk, this message translates to:
  /// **'Deň {n} z {total}'**
  String dayNofTotal(int n, int total);

  /// No description provided for @newDay.
  ///
  /// In sk, this message translates to:
  /// **'(nový deň)'**
  String get newDay;

  /// No description provided for @endVoyageTitle.
  ///
  /// In sk, this message translates to:
  /// **'Koniec plavby?'**
  String get endVoyageTitle;

  /// No description provided for @endVoyageContent.
  ///
  /// In sk, this message translates to:
  /// **'Dosiahli ste posledný plánovaný deň plavby.\n\nBude plavba pokračovať aj zajtra?'**
  String get endVoyageContent;

  /// No description provided for @decideLayer.
  ///
  /// In sk, this message translates to:
  /// **'Neskôr rozhodnem'**
  String get decideLayer;

  /// No description provided for @continuesTomorrow.
  ///
  /// In sk, this message translates to:
  /// **'Pokračuje zajtra'**
  String get continuesTomorrow;

  /// No description provided for @endVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Ukončiť plavbu'**
  String get endVoyage;

  /// No description provided for @newMultidayVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Nová viacdenná plavba'**
  String get newMultidayVoyage;

  /// No description provided for @deleteCharterTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať plavbu?'**
  String get deleteCharterTitle;

  /// No description provided for @deleteCharterContent.
  ///
  /// In sk, this message translates to:
  /// **'Zmažú sa všetky dni a záznamy.'**
  String get deleteCharterContent;

  /// No description provided for @cannotDeleteWhileTracking.
  ///
  /// In sk, this message translates to:
  /// **'Nemožno zmazať plavbu počas aktívneho trackingu.'**
  String get cannotDeleteWhileTracking;

  /// No description provided for @noVoyages.
  ///
  /// In sk, this message translates to:
  /// **'Žiadne plavby'**
  String get noVoyages;

  /// No description provided for @createFirstCharter.
  ///
  /// In sk, this message translates to:
  /// **'Vytvor svoju prvú plavbu'**
  String get createFirstCharter;

  /// No description provided for @briefingDone.
  ///
  /// In sk, this message translates to:
  /// **'Briefing ✓'**
  String get briefingDone;

  /// No description provided for @checkInDone.
  ///
  /// In sk, this message translates to:
  /// **'Check-in ✓'**
  String get checkInDone;

  /// No description provided for @checkOutDone.
  ///
  /// In sk, this message translates to:
  /// **'Check-out ✓'**
  String get checkOutDone;

  /// No description provided for @voyageNotFound.
  ///
  /// In sk, this message translates to:
  /// **'Plavba nenájdená'**
  String get voyageNotFound;

  /// No description provided for @unknownVessel.
  ///
  /// In sk, this message translates to:
  /// **'Neznáma loď'**
  String get unknownVessel;

  /// No description provided for @captain.
  ///
  /// In sk, this message translates to:
  /// **'Skipper'**
  String get captain;

  /// No description provided for @crew.
  ///
  /// In sk, this message translates to:
  /// **'Posádka'**
  String get crew;

  /// No description provided for @total.
  ///
  /// In sk, this message translates to:
  /// **'Celkom'**
  String get total;

  /// No description provided for @voyageDaysCount.
  ///
  /// In sk, this message translates to:
  /// **'Dni plavby ({n})'**
  String voyageDaysCount(int n);

  /// No description provided for @bulkDelete.
  ///
  /// In sk, this message translates to:
  /// **'Hromadné mazanie'**
  String get bulkDelete;

  /// No description provided for @noDays.
  ///
  /// In sk, this message translates to:
  /// **'Žiadne dni.\nSpusti tracking a prvý deň sa vytvorí automaticky.'**
  String get noDays;

  /// No description provided for @deleteDayTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať deň?'**
  String get deleteDayTitle;

  /// No description provided for @deleteDayContent.
  ///
  /// In sk, this message translates to:
  /// **'Zmažú sa všetky záznamy pre {day}.'**
  String deleteDayContent(String day);

  /// No description provided for @exportPdf.
  ///
  /// In sk, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @selectDaysTitle.
  ///
  /// In sk, this message translates to:
  /// **'Vybrať dni na mazanie'**
  String get selectDaysTitle;

  /// No description provided for @deleteCount.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať ({n})'**
  String deleteCount(int n);

  /// No description provided for @safety.
  ///
  /// In sk, this message translates to:
  /// **'Bezpečnosť'**
  String get safety;

  /// No description provided for @mobHoldToActivate.
  ///
  /// In sk, this message translates to:
  /// **'Podržte pre aktiváciu'**
  String get mobHoldToActivate;

  /// No description provided for @mobActive.
  ///
  /// In sk, this message translates to:
  /// **'⚠️ MOB AKTÍVNY'**
  String get mobActive;

  /// No description provided for @mobTime.
  ///
  /// In sk, this message translates to:
  /// **'Čas'**
  String get mobTime;

  /// No description provided for @mobDistance.
  ///
  /// In sk, this message translates to:
  /// **'Vzdialenosť'**
  String get mobDistance;

  /// No description provided for @mobDirection.
  ///
  /// In sk, this message translates to:
  /// **'Smer'**
  String get mobDirection;

  /// No description provided for @navigateToMob.
  ///
  /// In sk, this message translates to:
  /// **'Naviguj k MOB'**
  String get navigateToMob;

  /// No description provided for @gpsPositionNotAvailable.
  ///
  /// In sk, this message translates to:
  /// **'GPS pozícia nie je dostupná!'**
  String get gpsPositionNotAvailable;

  /// No description provided for @anchorAlarm.
  ///
  /// In sk, this message translates to:
  /// **'Anchor Alarm'**
  String get anchorAlarm;

  /// No description provided for @drifting.
  ///
  /// In sk, this message translates to:
  /// **'DRIFTUJE'**
  String get drifting;

  /// No description provided for @anchorRadiusLabel.
  ///
  /// In sk, this message translates to:
  /// **'Sledovaný polomer pohybu'**
  String get anchorRadiusLabel;

  /// No description provided for @anchorZoneTool.
  ///
  /// In sk, this message translates to:
  /// **'Kotevná plocha'**
  String get anchorZoneTool;

  /// No description provided for @undoLastPoint.
  ///
  /// In sk, this message translates to:
  /// **'Vziať späť posledný bod'**
  String get undoLastPoint;

  /// No description provided for @anchorZoneDrawFromMap.
  ///
  /// In sk, this message translates to:
  /// **'Vyznačiť plochu na mape'**
  String get anchorZoneDrawFromMap;

  /// No description provided for @anchorZoneDrawHint.
  ///
  /// In sk, this message translates to:
  /// **'Ťukaj rohy plochy na mape'**
  String get anchorZoneDrawHint;

  /// No description provided for @anchorZoneNeedsPoints.
  ///
  /// In sk, this message translates to:
  /// **'Plocha potrebuje aspoň tri rohy'**
  String get anchorZoneNeedsPoints;

  /// No description provided for @anchorZoneSelfIntersects.
  ///
  /// In sk, this message translates to:
  /// **'Plocha sa sama prekrížila — oprav rohy'**
  String get anchorZoneSelfIntersects;

  /// No description provided for @anchorZoneArm.
  ///
  /// In sk, this message translates to:
  /// **'Strážiť túto plochu'**
  String get anchorZoneArm;

  /// No description provided for @anchorZoneActive.
  ///
  /// In sk, this message translates to:
  /// **'Stráženie plochy'**
  String get anchorZoneActive;

  /// No description provided for @anchorZoneInside.
  ///
  /// In sk, this message translates to:
  /// **'{m} m k okraju plochy'**
  String anchorZoneInside(String m);

  /// No description provided for @anchorZoneOutside.
  ///
  /// In sk, this message translates to:
  /// **'{m} m za okrajom plochy'**
  String anchorZoneOutside(String m);

  /// No description provided for @anchorZoneNotInside.
  ///
  /// In sk, this message translates to:
  /// **'Si mimo nakreslenej plochy'**
  String get anchorZoneNotInside;

  /// No description provided for @anchorZoneTooTight.
  ///
  /// In sk, this message translates to:
  /// **'Plocha je tesnejšia než presnosť GPS'**
  String get anchorZoneTooTight;

  /// No description provided for @anchorZoneNoFix.
  ///
  /// In sk, this message translates to:
  /// **'Bez GPS polohy — kotva sa vzala zo stredu plochy'**
  String get anchorZoneNoFix;

  /// No description provided for @anchorNoFix.
  ///
  /// In sk, this message translates to:
  /// **'Bez GPS polohy sa kotva nedá spustiť'**
  String get anchorNoFix;

  /// No description provided for @activate.
  ///
  /// In sk, this message translates to:
  /// **'Aktivovať'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In sk, this message translates to:
  /// **'Deaktivovať'**
  String get deactivate;

  /// No description provided for @safetyBriefingCard.
  ///
  /// In sk, this message translates to:
  /// **'Safety Briefing'**
  String get safetyBriefingCard;

  /// No description provided for @maydayCard.
  ///
  /// In sk, this message translates to:
  /// **'Mayday karta'**
  String get maydayCard;

  /// No description provided for @yachtHandover.
  ///
  /// In sk, this message translates to:
  /// **'Odovzdanie jachty'**
  String get yachtHandover;

  /// No description provided for @gearList.
  ///
  /// In sk, this message translates to:
  /// **'Zoznam vybavenia'**
  String get gearList;

  /// No description provided for @pdfEntriesSection.
  ///
  /// In sk, this message translates to:
  /// **'Záznamy denníka'**
  String get pdfEntriesSection;

  /// No description provided for @pdfSkipperMessage.
  ///
  /// In sk, this message translates to:
  /// **'Správa skippera'**
  String get pdfSkipperMessage;

  /// No description provided for @pdfWeatherSection.
  ///
  /// In sk, this message translates to:
  /// **'Počasie'**
  String get pdfWeatherSection;

  /// No description provided for @pdfDaySummary.
  ///
  /// In sk, this message translates to:
  /// **'Denný prehľad'**
  String get pdfDaySummary;

  /// No description provided for @pdfDaysOverview.
  ///
  /// In sk, this message translates to:
  /// **'Prehľad dní'**
  String get pdfDaysOverview;

  /// No description provided for @pdfVoyageSummary.
  ///
  /// In sk, this message translates to:
  /// **'Záverečný prehľad plavby'**
  String get pdfVoyageSummary;

  /// No description provided for @pdfCrewSection.
  ///
  /// In sk, this message translates to:
  /// **'Posádka'**
  String get pdfCrewSection;

  /// No description provided for @pdfSignatures.
  ///
  /// In sk, this message translates to:
  /// **'Podpisy'**
  String get pdfSignatures;

  /// No description provided for @pdfCrewSignatures.
  ///
  /// In sk, this message translates to:
  /// **'Podpisy posádky'**
  String get pdfCrewSignatures;

  /// No description provided for @pdfSkipperSignature.
  ///
  /// In sk, this message translates to:
  /// **'Podpis skippera'**
  String get pdfSkipperSignature;

  /// No description provided for @pdfSkipperLicences.
  ///
  /// In sk, this message translates to:
  /// **'Skipper – licencie'**
  String get pdfSkipperLicences;

  /// No description provided for @pdfSafetyBriefing.
  ///
  /// In sk, this message translates to:
  /// **'Bezpečnostný brífing'**
  String get pdfSafetyBriefing;

  /// No description provided for @pdfChecklistSection.
  ///
  /// In sk, this message translates to:
  /// **'Kontrolný zoznam'**
  String get pdfChecklistSection;

  /// No description provided for @pdfMoreNotes.
  ///
  /// In sk, this message translates to:
  /// **'Ďalšie poznámky'**
  String get pdfMoreNotes;

  /// No description provided for @pdfIntegrityCheck.
  ///
  /// In sk, this message translates to:
  /// **'Overenie integrity dokumentu'**
  String get pdfIntegrityCheck;

  /// No description provided for @pdfHandoverTitle.
  ///
  /// In sk, this message translates to:
  /// **'Odovzdávací protokol'**
  String get pdfHandoverTitle;

  /// No description provided for @pdfMilesTitle.
  ///
  /// In sk, this message translates to:
  /// **'Potvrdenie o najazdených míľach'**
  String get pdfMilesTitle;

  /// No description provided for @pdfDeparture.
  ///
  /// In sk, this message translates to:
  /// **'Odchod'**
  String get pdfDeparture;

  /// No description provided for @pdfArrival.
  ///
  /// In sk, this message translates to:
  /// **'Príchod'**
  String get pdfArrival;

  /// No description provided for @pdfTotalLabel.
  ///
  /// In sk, this message translates to:
  /// **'Spolu'**
  String get pdfTotalLabel;

  /// No description provided for @pdfDayCount.
  ///
  /// In sk, this message translates to:
  /// **'Počet dní'**
  String get pdfDayCount;

  /// No description provided for @pdfEngineHours.
  ///
  /// In sk, this message translates to:
  /// **'Motohodiny'**
  String get pdfEngineHours;

  /// No description provided for @pdfFuelLabel.
  ///
  /// In sk, this message translates to:
  /// **'Palivo'**
  String get pdfFuelLabel;

  /// No description provided for @pdfWaterLabel.
  ///
  /// In sk, this message translates to:
  /// **'Voda'**
  String get pdfWaterLabel;

  /// No description provided for @pdfVesselLabel.
  ///
  /// In sk, this message translates to:
  /// **'Loď'**
  String get pdfVesselLabel;

  /// No description provided for @pdfSkipperLabel.
  ///
  /// In sk, this message translates to:
  /// **'Skipper'**
  String get pdfSkipperLabel;

  /// No description provided for @pdfDateLabel.
  ///
  /// In sk, this message translates to:
  /// **'Dátum'**
  String get pdfDateLabel;

  /// No description provided for @pdfColFrom.
  ///
  /// In sk, this message translates to:
  /// **'Odkiaľ'**
  String get pdfColFrom;

  /// No description provided for @pdfColTo.
  ///
  /// In sk, this message translates to:
  /// **'Kam'**
  String get pdfColTo;

  /// No description provided for @pdfColEntriesShort.
  ///
  /// In sk, this message translates to:
  /// **'Zázn.'**
  String get pdfColEntriesShort;

  /// No description provided for @pdfColTimeUtc.
  ///
  /// In sk, this message translates to:
  /// **'Čas UTC'**
  String get pdfColTimeUtc;

  /// No description provided for @pdfColTimeLocal.
  ///
  /// In sk, this message translates to:
  /// **'Čas {offset}'**
  String pdfColTimeLocal(String offset);

  /// No description provided for @timeZoneLabel.
  ///
  /// In sk, this message translates to:
  /// **'Časové pásmo'**
  String get timeZoneLabel;

  /// No description provided for @timeZoneLocalShort.
  ///
  /// In sk, this message translates to:
  /// **'Miestny'**
  String get timeZoneLocalShort;

  /// No description provided for @pdfColWind.
  ///
  /// In sk, this message translates to:
  /// **'Vietor'**
  String get pdfColWind;

  /// No description provided for @pdfColPropulsion.
  ///
  /// In sk, this message translates to:
  /// **'Pohon'**
  String get pdfColPropulsion;

  /// No description provided for @pdfColWeatherShort.
  ///
  /// In sk, this message translates to:
  /// **'Poč.'**
  String get pdfColWeatherShort;

  /// No description provided for @pdfColNote.
  ///
  /// In sk, this message translates to:
  /// **'Poznámka'**
  String get pdfColNote;

  /// No description provided for @pdfColDay.
  ///
  /// In sk, this message translates to:
  /// **'Deň'**
  String get pdfColDay;

  /// No description provided for @pdfColItem.
  ///
  /// In sk, this message translates to:
  /// **'Položka'**
  String get pdfColItem;

  /// No description provided for @pdfColStatus.
  ///
  /// In sk, this message translates to:
  /// **'Stav'**
  String get pdfColStatus;

  /// No description provided for @pdfColNotePosition.
  ///
  /// In sk, this message translates to:
  /// **'Poznámka / poloha'**
  String get pdfColNotePosition;

  /// No description provided for @pdfColPhoto.
  ///
  /// In sk, this message translates to:
  /// **'Foto'**
  String get pdfColPhoto;

  /// No description provided for @pdfColDateRange.
  ///
  /// In sk, this message translates to:
  /// **'Dátum od-do'**
  String get pdfColDateRange;

  /// No description provided for @pdfColArea.
  ///
  /// In sk, this message translates to:
  /// **'Oblasť'**
  String get pdfColArea;

  /// No description provided for @pdfColTidal.
  ///
  /// In sk, this message translates to:
  /// **'Vody'**
  String get pdfColTidal;

  /// No description provided for @pdfTidal.
  ///
  /// In sk, this message translates to:
  /// **'prílivové'**
  String get pdfTidal;

  /// No description provided for @pdfNonTidal.
  ///
  /// In sk, this message translates to:
  /// **'neprílivové'**
  String get pdfNonTidal;

  /// No description provided for @pdfMilesIssuedFor.
  ///
  /// In sk, this message translates to:
  /// **'Vystavené pre'**
  String get pdfMilesIssuedFor;

  /// No description provided for @pdfMilesIssuedBy.
  ///
  /// In sk, this message translates to:
  /// **'Vystavil'**
  String get pdfMilesIssuedBy;

  /// No description provided for @pdfMilesOwnRecord.
  ///
  /// In sk, this message translates to:
  /// **'Vlastný záznam naplavaných míľ'**
  String get pdfMilesOwnRecord;

  /// No description provided for @pdfMilesByRole.
  ///
  /// In sk, this message translates to:
  /// **'Míľe podľa funkcie'**
  String get pdfMilesByRole;

  /// No description provided for @pdfMilesSkipperSummary.
  ///
  /// In sk, this message translates to:
  /// **'Skiperský súhrn'**
  String get pdfMilesSkipperSummary;

  /// No description provided for @pdfMilesSkipperConfirms.
  ///
  /// In sk, this message translates to:
  /// **'Potvrdenie veliteľa plavby'**
  String get pdfMilesSkipperConfirms;

  /// No description provided for @milesExportTitle.
  ///
  /// In sk, this message translates to:
  /// **'Vystaviť potvrdenie'**
  String get milesExportTitle;

  /// No description provided for @milesExportFor.
  ///
  /// In sk, this message translates to:
  /// **'Pre koho'**
  String get milesExportFor;

  /// No description provided for @milesExportForSelf.
  ///
  /// In sk, this message translates to:
  /// **'Pre seba'**
  String get milesExportForSelf;

  /// No description provided for @milesExportForCrew.
  ///
  /// In sk, this message translates to:
  /// **'Pre člena posádky'**
  String get milesExportForCrew;

  /// No description provided for @milesExportRecipient.
  ///
  /// In sk, this message translates to:
  /// **'Meno príjemcu'**
  String get milesExportRecipient;

  /// No description provided for @milesExportIssuer.
  ///
  /// In sk, this message translates to:
  /// **'Vystavovateľ'**
  String get milesExportIssuer;

  /// No description provided for @milesExportQualification.
  ///
  /// In sk, this message translates to:
  /// **'Kvalifikácia'**
  String get milesExportQualification;

  /// No description provided for @milesExportVoyages.
  ///
  /// In sk, this message translates to:
  /// **'Plavby v potvrdení'**
  String get milesExportVoyages;

  /// No description provided for @milesExportSelectAll.
  ///
  /// In sk, this message translates to:
  /// **'Vybrať všetky'**
  String get milesExportSelectAll;

  /// No description provided for @milesExportSelectNone.
  ///
  /// In sk, this message translates to:
  /// **'Zrušiť výber'**
  String get milesExportSelectNone;

  /// No description provided for @milesExportChosenSummary.
  ///
  /// In sk, this message translates to:
  /// **'Vybraných plaváb: {count}  ·  {nm} NM'**
  String milesExportChosenSummary(String count, String nm);

  /// No description provided for @milesExportNoVoyages.
  ///
  /// In sk, this message translates to:
  /// **'Nevybral si žiadnu plavbu'**
  String get milesExportNoVoyages;

  /// No description provided for @milesTidalWaters.
  ///
  /// In sk, this message translates to:
  /// **'Prílivové vody'**
  String get milesTidalWaters;

  /// No description provided for @notSpecified.
  ///
  /// In sk, this message translates to:
  /// **'Neuvedené'**
  String get notSpecified;

  /// No description provided for @pdfColRole.
  ///
  /// In sk, this message translates to:
  /// **'Rola'**
  String get pdfColRole;

  /// No description provided for @pdfNameLabel.
  ///
  /// In sk, this message translates to:
  /// **'Meno'**
  String get pdfNameLabel;

  /// No description provided for @pdfLicenceLabel.
  ///
  /// In sk, this message translates to:
  /// **'Licencia'**
  String get pdfLicenceLabel;

  /// No description provided for @pdfIssuedValidLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vydal / platnosť'**
  String get pdfIssuedValidLabel;

  /// No description provided for @pdfOtherCertsLabel.
  ///
  /// In sk, this message translates to:
  /// **'Iné cert.'**
  String get pdfOtherCertsLabel;

  /// No description provided for @pdfContinued.
  ///
  /// In sk, this message translates to:
  /// **'pokračovanie'**
  String get pdfContinued;

  /// No description provided for @pdfExportedAt.
  ///
  /// In sk, this message translates to:
  /// **'Exportované'**
  String get pdfExportedAt;

  /// No description provided for @pdfSignedAt.
  ///
  /// In sk, this message translates to:
  /// **'Podpísané'**
  String get pdfSignedAt;

  /// No description provided for @pdfSignatureLabel.
  ///
  /// In sk, this message translates to:
  /// **'Podpis'**
  String get pdfSignatureLabel;

  /// No description provided for @pdfDatePlaceLabel.
  ///
  /// In sk, this message translates to:
  /// **'Dátum / miesto'**
  String get pdfDatePlaceLabel;

  /// No description provided for @pdfManualEntryNote.
  ///
  /// In sk, this message translates to:
  /// **'* manuálny záznam (zadané ručne)'**
  String get pdfManualEntryNote;

  /// No description provided for @pdfStatTotalDistance.
  ///
  /// In sk, this message translates to:
  /// **'Celková vzdialenosť'**
  String get pdfStatTotalDistance;

  /// No description provided for @pdfStatLogEntries.
  ///
  /// In sk, this message translates to:
  /// **'Záznamy denníka'**
  String get pdfStatLogEntries;

  /// No description provided for @pdfStatMaxBeaufort.
  ///
  /// In sk, this message translates to:
  /// **'Max Beaufort'**
  String get pdfStatMaxBeaufort;

  /// No description provided for @pdfStatDaysAtSea.
  ///
  /// In sk, this message translates to:
  /// **'Dni na mori'**
  String get pdfStatDaysAtSea;

  /// No description provided for @pdfStatVoyages.
  ///
  /// In sk, this message translates to:
  /// **'Počet plavieb'**
  String get pdfStatVoyages;

  /// No description provided for @pdfStatNightHours.
  ///
  /// In sk, this message translates to:
  /// **'Nočné hodiny'**
  String get pdfStatNightHours;

  /// No description provided for @pdfFuelShort.
  ///
  /// In sk, this message translates to:
  /// **'P'**
  String get pdfFuelShort;

  /// No description provided for @pdfWaterShort.
  ///
  /// In sk, this message translates to:
  /// **'V'**
  String get pdfWaterShort;

  /// No description provided for @pdfNoData.
  ///
  /// In sk, this message translates to:
  /// **'Bez údajov'**
  String get pdfNoData;

  /// No description provided for @pdfMapUnavailable.
  ///
  /// In sk, this message translates to:
  /// **'GPS mapa nedostupná'**
  String get pdfMapUnavailable;

  /// No description provided for @pdfUnsigned.
  ///
  /// In sk, this message translates to:
  /// **'Nepodpísané'**
  String get pdfUnsigned;

  /// No description provided for @pdfNoSignatures.
  ///
  /// In sk, this message translates to:
  /// **'Žiadne podpisy'**
  String get pdfNoSignatures;

  /// No description provided for @pdfSha256Label.
  ///
  /// In sk, this message translates to:
  /// **'SHA-256 odtlačok dát denníka:'**
  String get pdfSha256Label;

  /// No description provided for @pdfVerifyQr.
  ///
  /// In sk, this message translates to:
  /// **'Overovací QR'**
  String get pdfVerifyQr;

  /// No description provided for @pdfSbLifejackets.
  ///
  /// In sk, this message translates to:
  /// **'Záchranné vesty – umiestnenie a použitie'**
  String get pdfSbLifejackets;

  /// No description provided for @pdfSbLifebuoy.
  ///
  /// In sk, this message translates to:
  /// **'Záchranný kruh a MOB postup'**
  String get pdfSbLifebuoy;

  /// No description provided for @pdfSbFlares.
  ///
  /// In sk, this message translates to:
  /// **'Svetlice – typy a použitie'**
  String get pdfSbFlares;

  /// No description provided for @pdfSbEpirb.
  ///
  /// In sk, this message translates to:
  /// **'EPIRB / PLB – aktivácia'**
  String get pdfSbEpirb;

  /// No description provided for @pdfSbVhf.
  ///
  /// In sk, this message translates to:
  /// **'VHF rádio – kanál 16, Mayday postup'**
  String get pdfSbVhf;

  /// No description provided for @pdfSbExtinguisher.
  ///
  /// In sk, this message translates to:
  /// **'Hasiaci prístroj – umiestnenie a použitie'**
  String get pdfSbExtinguisher;

  /// No description provided for @pdfSbFirstAid.
  ///
  /// In sk, this message translates to:
  /// **'Lekárnička – umiestnenie'**
  String get pdfSbFirstAid;

  /// No description provided for @pdfSbEngineStop.
  ///
  /// In sk, this message translates to:
  /// **'Núdzové vypnutie motora'**
  String get pdfSbEngineStop;

  /// No description provided for @pdfSbLeaks.
  ///
  /// In sk, this message translates to:
  /// **'Úniky – voda, plyn'**
  String get pdfSbLeaks;

  /// No description provided for @pdfSbAnchor.
  ///
  /// In sk, this message translates to:
  /// **'Kotva a reťaz – postup kotvenia'**
  String get pdfSbAnchor;

  /// No description provided for @pdfSbRules.
  ///
  /// In sk, this message translates to:
  /// **'Pravidlá na palube'**
  String get pdfSbRules;

  /// No description provided for @pdfSbEmergencyContacts.
  ///
  /// In sk, this message translates to:
  /// **'Núdzové kontakty a VHF 16'**
  String get pdfSbEmergencyContacts;

  /// No description provided for @pdfBriefingDeclaration.
  ///
  /// In sk, this message translates to:
  /// **'Všetci členovia posádky boli oboznámení a porozumeli bezpečnostným pravidlám. Potvrdzujú to podpisom.'**
  String get pdfBriefingDeclaration;

  /// No description provided for @pdfHashCoverage.
  ///
  /// In sk, this message translates to:
  /// **'Odtlačok pokrýva názov plavby, loď, posádku a všetky záznamy (čas UTC, GPS, rýchlosť, kurz). Akákoľvek zmena dát zmení odtlačok.'**
  String get pdfHashCoverage;

  /// No description provided for @pdfForCharterCompany.
  ///
  /// In sk, this message translates to:
  /// **'Za charterovú spoločnosť'**
  String get pdfForCharterCompany;

  /// No description provided for @dutyRoster.
  ///
  /// In sk, this message translates to:
  /// **'Služba posádky'**
  String get dutyRoster;

  /// No description provided for @dutyStartAction.
  ///
  /// In sk, this message translates to:
  /// **'Nastúpiť do služby'**
  String get dutyStartAction;

  /// No description provided for @dutyEndAction.
  ///
  /// In sk, this message translates to:
  /// **'Ukončiť'**
  String get dutyEndAction;

  /// No description provided for @dutyStartTitle.
  ///
  /// In sk, this message translates to:
  /// **'Kto nastupuje do služby?'**
  String get dutyStartTitle;

  /// No description provided for @dutyRunningChip.
  ///
  /// In sk, this message translates to:
  /// **'SLÚŽI'**
  String get dutyRunningChip;

  /// No description provided for @dutySince.
  ///
  /// In sk, this message translates to:
  /// **'od {time}'**
  String dutySince(String time);

  /// No description provided for @dutyElapsed.
  ///
  /// In sk, this message translates to:
  /// **'{h} h {m} min'**
  String dutyElapsed(int h, int m);

  /// No description provided for @dutyNobodyOnDuty.
  ///
  /// In sk, this message translates to:
  /// **'Momentálne nikto neslúži'**
  String get dutyNobodyOnDuty;

  /// No description provided for @dutyInspectionView.
  ///
  /// In sk, this message translates to:
  /// **'Zobraziť pre kontrolu'**
  String get dutyInspectionView;

  /// No description provided for @dutyRosterHistory.
  ///
  /// In sk, this message translates to:
  /// **'Rozpis služieb'**
  String get dutyRosterHistory;

  /// No description provided for @dutyAddRetrospective.
  ///
  /// In sk, this message translates to:
  /// **'Doplniť službu'**
  String get dutyAddRetrospective;

  /// No description provided for @dutyEditTitle.
  ///
  /// In sk, this message translates to:
  /// **'Upraviť službu'**
  String get dutyEditTitle;

  /// No description provided for @dutyDeleteTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať službu?'**
  String get dutyDeleteTitle;

  /// No description provided for @dutyDeleteConfirm.
  ///
  /// In sk, this message translates to:
  /// **'Záznam služby pre {name} bude zmazaný.'**
  String dutyDeleteConfirm(String name);

  /// No description provided for @dutyNoCrewDefined.
  ///
  /// In sk, this message translates to:
  /// **'Plavba nemá zadanú posádku'**
  String get dutyNoCrewDefined;

  /// No description provided for @dutyDefineCrew.
  ///
  /// In sk, this message translates to:
  /// **'Doplniť posádku'**
  String get dutyDefineCrew;

  /// No description provided for @dutyErrorEndBeforeStart.
  ///
  /// In sk, this message translates to:
  /// **'Koniec musí byť po začiatku.'**
  String get dutyErrorEndBeforeStart;

  /// No description provided for @dutyErrorOverlap.
  ///
  /// In sk, this message translates to:
  /// **'{name} už v tomto čase slúži.'**
  String dutyErrorOverlap(String name);

  /// No description provided for @dutyErrorFutureStart.
  ///
  /// In sk, this message translates to:
  /// **'Začiatok nemôže byť v budúcnosti.'**
  String get dutyErrorFutureStart;

  /// No description provided for @dutyNoteLabel.
  ///
  /// In sk, this message translates to:
  /// **'Poznámka'**
  String get dutyNoteLabel;

  /// No description provided for @dutyLongRunningWarning.
  ///
  /// In sk, this message translates to:
  /// **'Služba beží {hours} h — nezabudol si ju ukončiť?'**
  String dutyLongRunningWarning(int hours);

  /// No description provided for @dutyFrom.
  ///
  /// In sk, this message translates to:
  /// **'Od'**
  String get dutyFrom;

  /// No description provided for @dutyTo.
  ///
  /// In sk, this message translates to:
  /// **'Do'**
  String get dutyTo;

  /// No description provided for @dutyToOngoing.
  ///
  /// In sk, this message translates to:
  /// **'— stále slúži'**
  String get dutyToOngoing;

  /// No description provided for @dutySelectPerson.
  ///
  /// In sk, this message translates to:
  /// **'Vyber člena posádky'**
  String get dutySelectPerson;

  /// No description provided for @dutyNoRecords.
  ///
  /// In sk, this message translates to:
  /// **'Zatiaľ žiadne služby'**
  String get dutyNoRecords;

  /// No description provided for @logDutySection.
  ///
  /// In sk, this message translates to:
  /// **'Služba posádky'**
  String get logDutySection;

  /// No description provided for @logDutyStillRunning.
  ///
  /// In sk, this message translates to:
  /// **'trvá'**
  String get logDutyStillRunning;

  /// No description provided for @autoEntryNote.
  ///
  /// In sk, this message translates to:
  /// **'Automatický záznam'**
  String get autoEntryNote;

  /// No description provided for @logEventSailChange.
  ///
  /// In sk, this message translates to:
  /// **'Prehodenie plachiet'**
  String get logEventSailChange;

  /// No description provided for @logEventCourseChange.
  ///
  /// In sk, this message translates to:
  /// **'Zmena kurzu'**
  String get logEventCourseChange;

  /// No description provided for @pdfNightShort.
  ///
  /// In sk, this message translates to:
  /// **'noc'**
  String get pdfNightShort;

  /// No description provided for @nightSailingHours.
  ///
  /// In sk, this message translates to:
  /// **'Nočná plavba {hours} h'**
  String nightSailingHours(String hours);

  /// No description provided for @logEventSailChangeTo.
  ///
  /// In sk, this message translates to:
  /// **'Zmena plachiet: {direction}'**
  String logEventSailChangeTo(String direction);

  /// No description provided for @logEventHelmsmanChange.
  ///
  /// In sk, this message translates to:
  /// **'Zmena kormidelníka'**
  String get logEventHelmsmanChange;

  /// No description provided for @logEventHelmsmanChangeTo.
  ///
  /// In sk, this message translates to:
  /// **'Kormidelník: {name}'**
  String logEventHelmsmanChangeTo(String name);

  /// No description provided for @crewListEmpty.
  ///
  /// In sk, this message translates to:
  /// **'Plavba nemá vyplnenú posádku.'**
  String get crewListEmpty;

  /// No description provided for @logEventAnchorDropped.
  ///
  /// In sk, this message translates to:
  /// **'Kotva spustená'**
  String get logEventAnchorDropped;

  /// No description provided for @logEventAnchorRaised.
  ///
  /// In sk, this message translates to:
  /// **'Kotva zdvihnutá'**
  String get logEventAnchorRaised;

  /// No description provided for @logEventDriftOut.
  ///
  /// In sk, this message translates to:
  /// **'Drift – prekročený perimeter'**
  String get logEventDriftOut;

  /// No description provided for @logEventDriftIn.
  ///
  /// In sk, this message translates to:
  /// **'Drift – loď späť v perimetri'**
  String get logEventDriftIn;

  /// No description provided for @logEventAutopilotOn.
  ///
  /// In sk, this message translates to:
  /// **'Autopilot ZAP - {mode}'**
  String logEventAutopilotOn(String mode);

  /// No description provided for @logEventAutopilotOff.
  ///
  /// In sk, this message translates to:
  /// **'Autopilot VYP'**
  String get logEventAutopilotOff;

  /// No description provided for @logEventEngineStart.
  ///
  /// In sk, this message translates to:
  /// **'Motor naštartovaný'**
  String get logEventEngineStart;

  /// No description provided for @logEventEngineStop.
  ///
  /// In sk, this message translates to:
  /// **'Motor zastavený'**
  String get logEventEngineStop;

  /// No description provided for @updateDownloaded.
  ///
  /// In sk, this message translates to:
  /// **'Aktualizácia je stiahnutá'**
  String get updateDownloaded;

  /// No description provided for @updateRestart.
  ///
  /// In sk, this message translates to:
  /// **'Reštartovať'**
  String get updateRestart;

  /// No description provided for @autopilotLabel.
  ///
  /// In sk, this message translates to:
  /// **'Autopilot'**
  String get autopilotLabel;

  /// No description provided for @quickAutopilotOn.
  ///
  /// In sk, this message translates to:
  /// **'Autopilot ZAP'**
  String get quickAutopilotOn;

  /// No description provided for @quickAutopilotOff.
  ///
  /// In sk, this message translates to:
  /// **'Autopilot VYP'**
  String get quickAutopilotOff;

  /// No description provided for @autopilotModeAuto.
  ///
  /// In sk, this message translates to:
  /// **'Auto'**
  String get autopilotModeAuto;

  /// No description provided for @autopilotModeWind.
  ///
  /// In sk, this message translates to:
  /// **'Vietor'**
  String get autopilotModeWind;

  /// No description provided for @autopilotModeTrack.
  ///
  /// In sk, this message translates to:
  /// **'Trasa'**
  String get autopilotModeTrack;

  /// No description provided for @autopilotModeHeading.
  ///
  /// In sk, this message translates to:
  /// **'Kurz'**
  String get autopilotModeHeading;

  /// No description provided for @autopilotModeRudder.
  ///
  /// In sk, this message translates to:
  /// **'Kormidlo'**
  String get autopilotModeRudder;

  /// No description provided for @autopilotModeStandby.
  ///
  /// In sk, this message translates to:
  /// **'Standby'**
  String get autopilotModeStandby;

  /// No description provided for @logEventDutyStart.
  ///
  /// In sk, this message translates to:
  /// **'Nástup do služby: {name}'**
  String logEventDutyStart(String name);

  /// No description provided for @logEventDutyEnd.
  ///
  /// In sk, this message translates to:
  /// **'Koniec služby: {name}'**
  String logEventDutyEnd(String name);

  /// No description provided for @colreg.
  ///
  /// In sk, this message translates to:
  /// **'COLREG'**
  String get colreg;

  /// No description provided for @emergencyContacts.
  ///
  /// In sk, this message translates to:
  /// **'Núdzové kontakty'**
  String get emergencyContacts;

  /// No description provided for @backToToc.
  ///
  /// In sk, this message translates to:
  /// **'Späť na obsah'**
  String get backToToc;

  /// No description provided for @briefingComplete.
  ///
  /// In sk, this message translates to:
  /// **'Briefing dokončený'**
  String get briefingComplete;

  /// No description provided for @updateByPosition.
  ///
  /// In sk, this message translates to:
  /// **'Aktualizovať podľa polohy'**
  String get updateByPosition;

  /// No description provided for @detectedByGps.
  ///
  /// In sk, this message translates to:
  /// **'detekované podľa GPS'**
  String get detectedByGps;

  /// No description provided for @locationUnavailable.
  ///
  /// In sk, this message translates to:
  /// **'📍 Poloha nedostupná – zobrazené globálne kontakty'**
  String get locationUnavailable;

  /// No description provided for @detectingLocation.
  ///
  /// In sk, this message translates to:
  /// **'Zisťujem polohu...'**
  String get detectingLocation;

  /// No description provided for @tapToCall.
  ///
  /// In sk, this message translates to:
  /// **'Klepni pre zavolanie'**
  String get tapToCall;

  /// No description provided for @cannotCall.
  ///
  /// In sk, this message translates to:
  /// **'Nedá sa zavolať: {name}'**
  String cannotCall(String name);

  /// No description provided for @vhfChannel16.
  ///
  /// In sk, this message translates to:
  /// **'VHF kanál 16 – použite rádio na palube'**
  String get vhfChannel16;

  /// No description provided for @hmbHandbook.
  ///
  /// In sk, this message translates to:
  /// **'HMB Príručka'**
  String get hmbHandbook;

  /// No description provided for @checkInLabel.
  ///
  /// In sk, this message translates to:
  /// **'Check-in (prevzatie lode)'**
  String get checkInLabel;

  /// No description provided for @checkOutLabel.
  ///
  /// In sk, this message translates to:
  /// **'Check-out (odovzdanie lode)'**
  String get checkOutLabel;

  /// No description provided for @charterCheckCard.
  ///
  /// In sk, this message translates to:
  /// **'Plavba'**
  String get charterCheckCard;

  /// No description provided for @weatherTitle.
  ///
  /// In sk, this message translates to:
  /// **'Počasie a more'**
  String get weatherTitle;

  /// No description provided for @updateForecast.
  ///
  /// In sk, this message translates to:
  /// **'Aktualizovať predpoveď'**
  String get updateForecast;

  /// No description provided for @gpsNotAvailableTracking.
  ///
  /// In sk, this message translates to:
  /// **'GPS nie je dostupné – zapnite tracking'**
  String get gpsNotAvailableTracking;

  /// No description provided for @downloadingForecast.
  ///
  /// In sk, this message translates to:
  /// **'Sťahujem predpoveď...'**
  String get downloadingForecast;

  /// No description provided for @loadingForecast.
  ///
  /// In sk, this message translates to:
  /// **'Načítavam predpoveď...'**
  String get loadingForecast;

  /// No description provided for @noConnection.
  ///
  /// In sk, this message translates to:
  /// **'Nie je dostupné spojenie'**
  String get noConnection;

  /// No description provided for @pressRefreshWhenOnline.
  ///
  /// In sk, this message translates to:
  /// **'Stlačte refresh keď ste online'**
  String get pressRefreshWhenOnline;

  /// No description provided for @noWeatherData.
  ///
  /// In sk, this message translates to:
  /// **'Žiadne dáta počasia'**
  String get noWeatherData;

  /// No description provided for @forecastAutoDownload.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď sa stiahne automaticky po spustení trackingu, alebo stlačte Refresh.'**
  String get forecastAutoDownload;

  /// No description provided for @enableGpsFirst.
  ///
  /// In sk, this message translates to:
  /// **'Zapnite GPS / tracking najprv'**
  String get enableGpsFirst;

  /// No description provided for @downloadForecast.
  ///
  /// In sk, this message translates to:
  /// **'Stiahnuť predpoveď'**
  String get downloadForecast;

  /// No description provided for @downloadError.
  ///
  /// In sk, this message translates to:
  /// **'Chyba sťahovania: {error}'**
  String downloadError(String error);

  /// No description provided for @errorNoInternetOnThisNetwork.
  ///
  /// In sk, this message translates to:
  /// **'Táto WiFi nemá internet (často WiFi lodných prístrojov). Zobrazená je posledná uložená predpoveď; novú stiahneš na mobilných dátach.'**
  String get errorNoInternetOnThisNetwork;

  /// No description provided for @errorNoConnection.
  ///
  /// In sk, this message translates to:
  /// **'Bez pripojenia. Zobrazená je posledná uložená predpoveď.'**
  String get errorNoConnection;

  /// No description provided for @liveInstrumentData.
  ///
  /// In sk, this message translates to:
  /// **'Živé dáta z lodných inštrumentov'**
  String get liveInstrumentData;

  /// No description provided for @windRelative.
  ///
  /// In sk, this message translates to:
  /// **'Vietor (rel.)'**
  String get windRelative;

  /// No description provided for @windTrue.
  ///
  /// In sk, this message translates to:
  /// **'Vietor (skut.)'**
  String get windTrue;

  /// No description provided for @depthLabel.
  ///
  /// In sk, this message translates to:
  /// **'Hĺbka'**
  String get depthLabel;

  /// No description provided for @waterTempLabel.
  ///
  /// In sk, this message translates to:
  /// **'Teplota vody'**
  String get waterTempLabel;

  /// No description provided for @courseTrue.
  ///
  /// In sk, this message translates to:
  /// **'Kurz (skut.)'**
  String get courseTrue;

  /// No description provided for @courseMag.
  ///
  /// In sk, this message translates to:
  /// **'Kurz (mag.)'**
  String get courseMag;

  /// No description provided for @engineLabel.
  ///
  /// In sk, this message translates to:
  /// **'Motor'**
  String get engineLabel;

  /// No description provided for @wavesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vlny'**
  String get wavesLabel;

  /// No description provided for @pressureLabel.
  ///
  /// In sk, this message translates to:
  /// **'Tlak'**
  String get pressureLabel;

  /// No description provided for @airTempLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vzduch'**
  String get airTempLabel;

  /// No description provided for @waterLabel.
  ///
  /// In sk, this message translates to:
  /// **'Voda'**
  String get waterLabel;

  /// No description provided for @wind24h.
  ///
  /// In sk, this message translates to:
  /// **'Vietor – 3 dni'**
  String get wind24h;

  /// No description provided for @waves24h.
  ///
  /// In sk, this message translates to:
  /// **'Vlny – 3 dni'**
  String get waves24h;

  /// No description provided for @hourlyForecast.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď na 3 dni'**
  String get hourlyForecast;

  /// No description provided for @dailyForecast.
  ///
  /// In sk, this message translates to:
  /// **'Denná teplota'**
  String get dailyForecast;

  /// No description provided for @timeCol.
  ///
  /// In sk, this message translates to:
  /// **'Čas'**
  String get timeCol;

  /// No description provided for @windCol.
  ///
  /// In sk, this message translates to:
  /// **'Vietor'**
  String get windCol;

  /// No description provided for @wavesCol.
  ///
  /// In sk, this message translates to:
  /// **'Vlny'**
  String get wavesCol;

  /// No description provided for @rainCol.
  ///
  /// In sk, this message translates to:
  /// **'Dážď'**
  String get rainCol;

  /// No description provided for @beaufort0.
  ///
  /// In sk, this message translates to:
  /// **'Bezvetrie'**
  String get beaufort0;

  /// No description provided for @beaufort1.
  ///
  /// In sk, this message translates to:
  /// **'Tichý vánok'**
  String get beaufort1;

  /// No description provided for @beaufort2.
  ///
  /// In sk, this message translates to:
  /// **'Slabý vietor'**
  String get beaufort2;

  /// No description provided for @beaufort3.
  ///
  /// In sk, this message translates to:
  /// **'Slabý vietor'**
  String get beaufort3;

  /// No description provided for @beaufort4.
  ///
  /// In sk, this message translates to:
  /// **'Mierny vietor'**
  String get beaufort4;

  /// No description provided for @beaufort5.
  ///
  /// In sk, this message translates to:
  /// **'Dosť čerstvý'**
  String get beaufort5;

  /// No description provided for @beaufort6.
  ///
  /// In sk, this message translates to:
  /// **'Čerstvý vietor'**
  String get beaufort6;

  /// No description provided for @beaufort7.
  ///
  /// In sk, this message translates to:
  /// **'Silný vietor'**
  String get beaufort7;

  /// No description provided for @beaufort8.
  ///
  /// In sk, this message translates to:
  /// **'Búrlivý vietor'**
  String get beaufort8;

  /// No description provided for @beaufort9.
  ///
  /// In sk, this message translates to:
  /// **'Búrka'**
  String get beaufort9;

  /// No description provided for @beaufort10.
  ///
  /// In sk, this message translates to:
  /// **'Silná búrka'**
  String get beaufort10;

  /// No description provided for @beaufort11.
  ///
  /// In sk, this message translates to:
  /// **'Mimoriadna búrka'**
  String get beaufort11;

  /// No description provided for @beaufort12.
  ///
  /// In sk, this message translates to:
  /// **'Orkán'**
  String get beaufort12;

  /// No description provided for @sunAndMoonCard.
  ///
  /// In sk, this message translates to:
  /// **'Slnko a mesiac'**
  String get sunAndMoonCard;

  /// No description provided for @sunriseLabel.
  ///
  /// In sk, this message translates to:
  /// **'Východ slnka'**
  String get sunriseLabel;

  /// No description provided for @sunsetLabel.
  ///
  /// In sk, this message translates to:
  /// **'Západ slnka'**
  String get sunsetLabel;

  /// No description provided for @moonPhaseLabel.
  ///
  /// In sk, this message translates to:
  /// **'Fáza mesiaca'**
  String get moonPhaseLabel;

  /// No description provided for @moonIlluminationLabel.
  ///
  /// In sk, this message translates to:
  /// **'Osvetlené'**
  String get moonIlluminationLabel;

  /// No description provided for @moonPhaseNew.
  ///
  /// In sk, this message translates to:
  /// **'Novmesiac'**
  String get moonPhaseNew;

  /// No description provided for @moonPhaseWaxingCrescent.
  ///
  /// In sk, this message translates to:
  /// **'Dorastajúci kosáčik'**
  String get moonPhaseWaxingCrescent;

  /// No description provided for @moonPhaseFirstQuarter.
  ///
  /// In sk, this message translates to:
  /// **'Prvá štvrť'**
  String get moonPhaseFirstQuarter;

  /// No description provided for @moonPhaseWaxingGibbous.
  ///
  /// In sk, this message translates to:
  /// **'Dorastajúci mesiac'**
  String get moonPhaseWaxingGibbous;

  /// No description provided for @moonPhaseFull.
  ///
  /// In sk, this message translates to:
  /// **'Spln'**
  String get moonPhaseFull;

  /// No description provided for @moonPhaseWaningGibbous.
  ///
  /// In sk, this message translates to:
  /// **'Cúvajúci mesiac'**
  String get moonPhaseWaningGibbous;

  /// No description provided for @moonPhaseLastQuarter.
  ///
  /// In sk, this message translates to:
  /// **'Posledná štvrť'**
  String get moonPhaseLastQuarter;

  /// No description provided for @moonPhaseWaningCrescent.
  ///
  /// In sk, this message translates to:
  /// **'Cúvajúci kosáčik'**
  String get moonPhaseWaningCrescent;

  /// No description provided for @noSunMoonGps.
  ///
  /// In sk, this message translates to:
  /// **'Pre východ/západ slnka je potrebná GPS poloha'**
  String get noSunMoonGps;

  /// No description provided for @oceanCurrentsTitle.
  ///
  /// In sk, this message translates to:
  /// **'Oceánske prúdy'**
  String get oceanCurrentsTitle;

  /// No description provided for @oceanCurrentsTooltip.
  ///
  /// In sk, this message translates to:
  /// **'Oceánske prúdy'**
  String get oceanCurrentsTooltip;

  /// No description provided for @oceanCurrentsDisclaimer.
  ///
  /// In sk, this message translates to:
  /// **'Len orientačné dáta (typický smer/rýchlosť z pilotných máp) — nie pre presnú navigáciu, prúdy sa sezónne menia.'**
  String get oceanCurrentsDisclaimer;

  /// No description provided for @tideCardTitle.
  ///
  /// In sk, this message translates to:
  /// **'Príliv/odliv'**
  String get tideCardTitle;

  /// No description provided for @nextHighTideLabel.
  ///
  /// In sk, this message translates to:
  /// **'Najbližší príliv'**
  String get nextHighTideLabel;

  /// No description provided for @nextLowTideLabel.
  ///
  /// In sk, this message translates to:
  /// **'Najbližší odliv'**
  String get nextLowTideLabel;

  /// No description provided for @noTideData.
  ///
  /// In sk, this message translates to:
  /// **'Zatiaľ žiadne dáta o prílive'**
  String get noTideData;

  /// No description provided for @downloadTides.
  ///
  /// In sk, this message translates to:
  /// **'Stiahnuť predpoveď prílivu'**
  String get downloadTides;

  /// No description provided for @downloadingTides.
  ///
  /// In sk, this message translates to:
  /// **'Sťahujem predpoveď prílivu...'**
  String get downloadingTides;

  /// No description provided for @tideMslWarning.
  ///
  /// In sk, this message translates to:
  /// **'Výšky sú nad strednou hladinou mora, nie nad mapovým datom — nikdy ich nepoužívaj na hĺbku pod kýlom.'**
  String get tideMslWarning;

  /// No description provided for @tideNoCoverage.
  ///
  /// In sk, this message translates to:
  /// **'Pre túto polohu nemáme dáta o prílive — je mimo oblasti morskej predpovede.'**
  String get tideNoCoverage;

  /// No description provided for @tideDownloadFailed.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď prílivu sa nepodarilo stiahnuť. Skontroluj pripojenie a skús znova.'**
  String get tideDownloadFailed;

  /// No description provided for @tideForecastExpired.
  ///
  /// In sk, this message translates to:
  /// **'Uložená predpoveď prílivu sa minula.'**
  String get tideForecastExpired;

  /// No description provided for @tideForecastFarAway.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď bola stiahnutá {km} km odtiaľto — stiahni ju znova pre túto polohu.'**
  String tideForecastFarAway(int km);

  /// No description provided for @tideForecastStale.
  ///
  /// In sk, this message translates to:
  /// **'Stiahnuté {when} — pre najnovšiu predpoveď stiahni znova.'**
  String tideForecastStale(String when);

  /// No description provided for @oceanCurrentCardTitle.
  ///
  /// In sk, this message translates to:
  /// **'Morský prúd'**
  String get oceanCurrentCardTitle;

  /// No description provided for @oceanCurrentSetsToward.
  ///
  /// In sk, this message translates to:
  /// **'Tečie smerom na (rýchlosť v uzloch)'**
  String get oceanCurrentSetsToward;

  /// No description provided for @oceanCurrentNoCoverage.
  ///
  /// In sk, this message translates to:
  /// **'Pre túto polohu nemáme dáta o prúde.'**
  String get oceanCurrentNoCoverage;

  /// No description provided for @oceanCurrentUnavailable.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď prúdu nie je dostupná — skontroluj pripojenie.'**
  String get oceanCurrentUnavailable;

  /// No description provided for @tideOtherArea.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď pre inú oblasť'**
  String get tideOtherArea;

  /// No description provided for @tideAreaSearchLabel.
  ///
  /// In sk, this message translates to:
  /// **'Prístav, mesto alebo zátoka'**
  String get tideAreaSearchLabel;

  /// No description provided for @tideAreaSearchHint.
  ///
  /// In sk, this message translates to:
  /// **'napr. Split'**
  String get tideAreaSearchHint;

  /// No description provided for @tideAreaNoResults.
  ///
  /// In sk, this message translates to:
  /// **'Nič sa nenašlo — skús iný názov.'**
  String get tideAreaNoResults;

  /// No description provided for @tideForecastForArea.
  ///
  /// In sk, this message translates to:
  /// **'Predpoveď pre {place}'**
  String tideForecastForArea(String place);

  /// No description provided for @settingsTitle.
  ///
  /// In sk, this message translates to:
  /// **'Nastavenia'**
  String get settingsTitle;

  /// No description provided for @measurementUnits.
  ///
  /// In sk, this message translates to:
  /// **'Jednotky merania'**
  String get measurementUnits;

  /// No description provided for @temperature.
  ///
  /// In sk, this message translates to:
  /// **'Teplota'**
  String get temperature;

  /// No description provided for @depthWaves.
  ///
  /// In sk, this message translates to:
  /// **'Hĺbka / vlny'**
  String get depthWaves;

  /// No description provided for @wind.
  ///
  /// In sk, this message translates to:
  /// **'Vietor'**
  String get wind;

  /// No description provided for @language.
  ///
  /// In sk, this message translates to:
  /// **'Jazyk'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In sk, this message translates to:
  /// **'Jazyk aplikácie'**
  String get appLanguage;

  /// No description provided for @languageDialogTitle.
  ///
  /// In sk, this message translates to:
  /// **'Jazyk / Language'**
  String get languageDialogTitle;

  /// No description provided for @displaySettings.
  ///
  /// In sk, this message translates to:
  /// **'Zobrazenie'**
  String get displaySettings;

  /// No description provided for @nightMode.
  ///
  /// In sk, this message translates to:
  /// **'Nočný režim'**
  String get nightMode;

  /// No description provided for @nightModeDesc.
  ///
  /// In sk, this message translates to:
  /// **'Červený filter pre zachovanie nočného videnia'**
  String get nightModeDesc;

  /// No description provided for @aboutApp.
  ///
  /// In sk, this message translates to:
  /// **'O aplikácii'**
  String get aboutApp;

  /// No description provided for @backupSection.
  ///
  /// In sk, this message translates to:
  /// **'Záloha dát'**
  String get backupSection;

  /// No description provided for @exportBackup.
  ///
  /// In sk, this message translates to:
  /// **'Exportovať zálohu'**
  String get exportBackup;

  /// No description provided for @exportBackupDesc.
  ///
  /// In sk, this message translates to:
  /// **'Uloží celý denník (plavby, záznamy, nastavenia) do jedného súboru'**
  String get exportBackupDesc;

  /// No description provided for @restoreBackup.
  ///
  /// In sk, this message translates to:
  /// **'Obnoviť zo zálohy'**
  String get restoreBackup;

  /// No description provided for @restoreBackupDesc.
  ///
  /// In sk, this message translates to:
  /// **'Nahradí aktuálne dáta obsahom vybraného súboru zálohy'**
  String get restoreBackupDesc;

  /// No description provided for @restoreBlockedTrackingTitle.
  ///
  /// In sk, this message translates to:
  /// **'Beží GPS tracking'**
  String get restoreBlockedTrackingTitle;

  /// No description provided for @restoreBlockedTrackingBody.
  ///
  /// In sk, this message translates to:
  /// **'Pred obnovou zálohy najprv zastav aktívne trasovanie plavby.'**
  String get restoreBlockedTrackingBody;

  /// No description provided for @restoreSchemaTooNewTitle.
  ///
  /// In sk, this message translates to:
  /// **'Záloha je z novšej verzie'**
  String get restoreSchemaTooNewTitle;

  /// No description provided for @restoreSchemaTooNewBody.
  ///
  /// In sk, this message translates to:
  /// **'Táto záloha bola vytvorená novšou verziou aplikácie, ako je práve nainštalovaná. Najprv aktualizuj aplikáciu.'**
  String get restoreSchemaTooNewBody;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In sk, this message translates to:
  /// **'Obnoviť zo zálohy?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In sk, this message translates to:
  /// **'Aktuálne dáta budú nahradené obsahom zálohy. Pred obnovou sa automaticky vytvorí bezpečnostná záloha súčasného stavu.'**
  String get restoreConfirmBody;

  /// No description provided for @restoreSuccess.
  ///
  /// In sk, this message translates to:
  /// **'Dáta boli úspešne obnovené zo zálohy.'**
  String get restoreSuccess;

  /// No description provided for @restoreInvalidFile.
  ///
  /// In sk, this message translates to:
  /// **'Vybraný súbor nie je platná záloha HMB Sailing Log.'**
  String get restoreInvalidFile;

  /// No description provided for @milesBookTitle.
  ///
  /// In sk, this message translates to:
  /// **'Kniha míľ'**
  String get milesBookTitle;

  /// No description provided for @totalNm.
  ///
  /// In sk, this message translates to:
  /// **'Celkové NM'**
  String get totalNm;

  /// No description provided for @daysAtSea.
  ///
  /// In sk, this message translates to:
  /// **'Dni na mori'**
  String get daysAtSea;

  /// No description provided for @voyageCount.
  ///
  /// In sk, this message translates to:
  /// **'Počet plavieb'**
  String get voyageCount;

  /// No description provided for @nightHoursLabel.
  ///
  /// In sk, this message translates to:
  /// **'Nočné hodiny'**
  String get nightHoursLabel;

  /// No description provided for @byYear.
  ///
  /// In sk, this message translates to:
  /// **'Podľa roka'**
  String get byYear;

  /// No description provided for @byVessel.
  ///
  /// In sk, this message translates to:
  /// **'Podľa lode'**
  String get byVessel;

  /// No description provided for @addHistoricalVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Pridať historickú plavbu'**
  String get addHistoricalVoyage;

  /// No description provided for @editHistoricalVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Upraviť historickú plavbu'**
  String get editHistoricalVoyage;

  /// No description provided for @deleteHistoricalVoyageConfirm.
  ///
  /// In sk, this message translates to:
  /// **'Naozaj zmazať túto historickú plavbu?'**
  String get deleteHistoricalVoyageConfirm;

  /// No description provided for @manualEntryExplanation.
  ///
  /// In sk, this message translates to:
  /// **'* manuálny záznam (zadané ručne)'**
  String get manualEntryExplanation;

  /// No description provided for @roleLabel.
  ///
  /// In sk, this message translates to:
  /// **'Rola na palube'**
  String get roleLabel;

  /// No description provided for @roleSkipper.
  ///
  /// In sk, this message translates to:
  /// **'Skiper'**
  String get roleSkipper;

  /// No description provided for @roleCoSkipper.
  ///
  /// In sk, this message translates to:
  /// **'Kormidelník'**
  String get roleCoSkipper;

  /// No description provided for @roleCrew.
  ///
  /// In sk, this message translates to:
  /// **'Posádka'**
  String get roleCrew;

  /// No description provided for @areaLabel.
  ///
  /// In sk, this message translates to:
  /// **'Oblasť / trasa'**
  String get areaLabel;

  /// No description provided for @distanceNmLabel.
  ///
  /// In sk, this message translates to:
  /// **'Vzdialenosť (NM)'**
  String get distanceNmLabel;

  /// No description provided for @daysCountLabel.
  ///
  /// In sk, this message translates to:
  /// **'Počet dní'**
  String get daysCountLabel;

  /// No description provided for @milesCertificateTitle.
  ///
  /// In sk, this message translates to:
  /// **'Potvrdenie o najazdených míľach'**
  String get milesCertificateTitle;

  /// No description provided for @logbookRecordTitle.
  ///
  /// In sk, this message translates to:
  /// **'Záznam Knihy míľ'**
  String get logbookRecordTitle;

  /// No description provided for @logbookTrackedHint.
  ///
  /// In sk, this message translates to:
  /// **'Dátumy, míle, oblasť a rola sa počítajú z trackingu/importu.'**
  String get logbookTrackedHint;

  /// No description provided for @vesselFlag.
  ///
  /// In sk, this message translates to:
  /// **'Vlajka registrácie'**
  String get vesselFlag;

  /// No description provided for @captainFirstName.
  ///
  /// In sk, this message translates to:
  /// **'Meno skippera'**
  String get captainFirstName;

  /// No description provided for @captainLastName.
  ///
  /// In sk, this message translates to:
  /// **'Priezvisko skippera'**
  String get captainLastName;

  /// No description provided for @captainQualification.
  ///
  /// In sk, this message translates to:
  /// **'Najvyššia dosiahnutá kvalifikácia'**
  String get captainQualification;

  /// No description provided for @logbookSignatureSection.
  ///
  /// In sk, this message translates to:
  /// **'Podpis potvrdzujúci míle'**
  String get logbookSignatureSection;

  /// No description provided for @addSignature.
  ///
  /// In sk, this message translates to:
  /// **'Pridať podpis'**
  String get addSignature;

  /// No description provided for @filterAllYears.
  ///
  /// In sk, this message translates to:
  /// **'Všetky roky'**
  String get filterAllYears;

  /// No description provided for @filterCustomRange.
  ///
  /// In sk, this message translates to:
  /// **'Vlastný rozsah'**
  String get filterCustomRange;

  /// No description provided for @handoverMenuTitle.
  ///
  /// In sk, this message translates to:
  /// **'Odovzdávací protokol'**
  String get handoverMenuTitle;

  /// No description provided for @checkInProtocol.
  ///
  /// In sk, this message translates to:
  /// **'Check-in protokol'**
  String get checkInProtocol;

  /// No description provided for @checkOutProtocol.
  ///
  /// In sk, this message translates to:
  /// **'Check-out protokol'**
  String get checkOutProtocol;

  /// No description provided for @nextStepLabel.
  ///
  /// In sk, this message translates to:
  /// **'Ďalší krok'**
  String get nextStepLabel;

  /// No description provided for @readyToTrackHint.
  ///
  /// In sk, this message translates to:
  /// **'Pripravené na tracking'**
  String get readyToTrackHint;

  /// No description provided for @wizardStepHeader.
  ///
  /// In sk, this message translates to:
  /// **'Krok {step}/{total} · {label}'**
  String wizardStepHeader(int step, int total, String label);

  /// No description provided for @safetyBriefingShort.
  ///
  /// In sk, this message translates to:
  /// **'Safety\nBrífing'**
  String get safetyBriefingShort;

  /// No description provided for @handoverChecklistShort.
  ///
  /// In sk, this message translates to:
  /// **'Odovzdávací\nChecklist'**
  String get handoverChecklistShort;

  /// No description provided for @safetyBriefingRefTitle.
  ///
  /// In sk, this message translates to:
  /// **'Bezpečnostný brífing'**
  String get safetyBriefingRefTitle;

  /// No description provided for @handoverChecklistRefTitle.
  ///
  /// In sk, this message translates to:
  /// **'Odovzdávací checklist'**
  String get handoverChecklistRefTitle;

  /// No description provided for @handoverDateTime.
  ///
  /// In sk, this message translates to:
  /// **'Dátum a čas'**
  String get handoverDateTime;

  /// No description provided for @handoverLocation.
  ///
  /// In sk, this message translates to:
  /// **'Miesto (marína)'**
  String get handoverLocation;

  /// No description provided for @checklistItemOk.
  ///
  /// In sk, this message translates to:
  /// **'OK'**
  String get checklistItemOk;

  /// No description provided for @checklistItemDamaged.
  ///
  /// In sk, this message translates to:
  /// **'Poškodené'**
  String get checklistItemDamaged;

  /// No description provided for @checklistItemMissing.
  ///
  /// In sk, this message translates to:
  /// **'Chýba'**
  String get checklistItemMissing;

  /// No description provided for @damagePosition.
  ///
  /// In sk, this message translates to:
  /// **'Poloha na lodi'**
  String get damagePosition;

  /// No description provided for @newDamageBadge.
  ///
  /// In sk, this message translates to:
  /// **'NOVÉ POŠKODENIE'**
  String get newDamageBadge;

  /// No description provided for @companySignatureSection.
  ///
  /// In sk, this message translates to:
  /// **'Podpis zástupcu charterovej spoločnosti'**
  String get companySignatureSection;

  /// No description provided for @companyRepName.
  ///
  /// In sk, this message translates to:
  /// **'Meno zástupcu'**
  String get companyRepName;

  /// No description provided for @companyNameLabel.
  ///
  /// In sk, this message translates to:
  /// **'Názov spoločnosti'**
  String get companyNameLabel;

  /// No description provided for @protocolClosedNotice.
  ///
  /// In sk, this message translates to:
  /// **'Protokol je uzavretý (podpísali obe strany) – len na čítanie.'**
  String get protocolClosedNotice;

  /// No description provided for @handoverCertTitle.
  ///
  /// In sk, this message translates to:
  /// **'Odovzdávací protokol lode'**
  String get handoverCertTitle;

  /// No description provided for @itemSails.
  ///
  /// In sk, this message translates to:
  /// **'Plachty'**
  String get itemSails;

  /// No description provided for @itemRigging.
  ///
  /// In sk, this message translates to:
  /// **'Lanovie'**
  String get itemRigging;

  /// No description provided for @itemAnchorChain.
  ///
  /// In sk, this message translates to:
  /// **'Kotva a reťaz'**
  String get itemAnchorChain;

  /// No description provided for @itemNavInstruments.
  ///
  /// In sk, this message translates to:
  /// **'Navigačné prístroje'**
  String get itemNavInstruments;

  /// No description provided for @itemLifeJackets.
  ///
  /// In sk, this message translates to:
  /// **'Záchranné vesty'**
  String get itemLifeJackets;

  /// No description provided for @itemRaft.
  ///
  /// In sk, this message translates to:
  /// **'Záchranný raft'**
  String get itemRaft;

  /// No description provided for @itemFirstAidKit.
  ///
  /// In sk, this message translates to:
  /// **'Lekárnička'**
  String get itemFirstAidKit;

  /// No description provided for @itemDinghyMotor.
  ///
  /// In sk, this message translates to:
  /// **'Dinghy a prívesný motor'**
  String get itemDinghyMotor;

  /// No description provided for @itemLights.
  ///
  /// In sk, this message translates to:
  /// **'Svetlá'**
  String get itemLights;

  /// No description provided for @itemBimini.
  ///
  /// In sk, this message translates to:
  /// **'Bimini'**
  String get itemBimini;

  /// No description provided for @extraNotesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Ďalšie poznámky'**
  String get extraNotesLabel;

  /// No description provided for @gpxImportTitle.
  ///
  /// In sk, this message translates to:
  /// **'Import GPX'**
  String get gpxImportTitle;

  /// No description provided for @gpxImportPickFile.
  ///
  /// In sk, this message translates to:
  /// **'Vybrať GPX súbor'**
  String get gpxImportPickFile;

  /// No description provided for @gpxTracksFound.
  ///
  /// In sk, this message translates to:
  /// **'Nájdené tracky'**
  String get gpxTracksFound;

  /// No description provided for @gpxWaypointsFound.
  ///
  /// In sk, this message translates to:
  /// **'Nájdené waypointy'**
  String get gpxWaypointsFound;

  /// No description provided for @gpxAssignTarget.
  ///
  /// In sk, this message translates to:
  /// **'Priradiť k plavbe'**
  String get gpxAssignTarget;

  /// No description provided for @gpxNewVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Nová plavba'**
  String get gpxNewVoyage;

  /// No description provided for @gpxImportButton.
  ///
  /// In sk, this message translates to:
  /// **'Importovať'**
  String get gpxImportButton;

  /// No description provided for @gpxImportSuccess.
  ///
  /// In sk, this message translates to:
  /// **'GPX úspešne importovaný.'**
  String get gpxImportSuccess;

  /// No description provided for @connectionConnected.
  ///
  /// In sk, this message translates to:
  /// **'Pripojené'**
  String get connectionConnected;

  /// No description provided for @connectionConnecting.
  ///
  /// In sk, this message translates to:
  /// **'Pripájam sa...'**
  String get connectionConnecting;

  /// No description provided for @connectionError.
  ///
  /// In sk, this message translates to:
  /// **'Chyba pripojenia'**
  String get connectionError;

  /// No description provided for @connectionDisconnected.
  ///
  /// In sk, this message translates to:
  /// **'Nepripojené (používa sa telefón GPS / predpoveď)'**
  String get connectionDisconnected;

  /// No description provided for @ipAddressLabel.
  ///
  /// In sk, this message translates to:
  /// **'IP adresa gateway'**
  String get ipAddressLabel;

  /// No description provided for @portLabel.
  ///
  /// In sk, this message translates to:
  /// **'Port'**
  String get portLabel;

  /// No description provided for @autoConnectLabel.
  ///
  /// In sk, this message translates to:
  /// **'Automaticky pripojiť pri spustení'**
  String get autoConnectLabel;

  /// No description provided for @disconnect.
  ///
  /// In sk, this message translates to:
  /// **'Odpojiť'**
  String get disconnect;

  /// No description provided for @connect.
  ///
  /// In sk, this message translates to:
  /// **'Pripojiť'**
  String get connect;

  /// No description provided for @gatewayHint.
  ///
  /// In sk, this message translates to:
  /// **'Pripoj telefón na WiFi sieť Raymarine (napr. WiFi-1, RayNet). IP adresa na zadanie NIE je tá z nastavení Raymarine — je to brána (gateway) tej WiFi siete. Nájdeš ju v telefóne: Nastavenia → WiFi → detail siete → Brána. Port 2000 (TCP) je štandard. Bez pripojenia appka automaticky používa GPS telefónu.'**
  String get gatewayHint;

  /// No description provided for @connectedToHost.
  ///
  /// In sk, this message translates to:
  /// **'Pripojené na {host}:{port}'**
  String connectedToHost(String host, int port);

  /// No description provided for @enterIpAddress.
  ///
  /// In sk, this message translates to:
  /// **'Zadajte IP adresu gateway'**
  String get enterIpAddress;

  /// No description provided for @connectionFailed.
  ///
  /// In sk, this message translates to:
  /// **'Nepodarilo sa pripojiť: {error}'**
  String connectionFailed(String error);

  /// No description provided for @liveWind.
  ///
  /// In sk, this message translates to:
  /// **'Vietor'**
  String get liveWind;

  /// No description provided for @liveDepth.
  ///
  /// In sk, this message translates to:
  /// **'Hĺbka'**
  String get liveDepth;

  /// No description provided for @liveWaterTemp.
  ///
  /// In sk, this message translates to:
  /// **'Teplota vody'**
  String get liveWaterTemp;

  /// No description provided for @liveCompass.
  ///
  /// In sk, this message translates to:
  /// **'Kompas'**
  String get liveCompass;

  /// No description provided for @liveEngine.
  ///
  /// In sk, this message translates to:
  /// **'Motor'**
  String get liveEngine;

  /// No description provided for @nmeaTcp.
  ///
  /// In sk, this message translates to:
  /// **'TCP'**
  String get nmeaTcp;

  /// No description provided for @nmeaUdp.
  ///
  /// In sk, this message translates to:
  /// **'UDP'**
  String get nmeaUdp;

  /// No description provided for @udpListenPort.
  ///
  /// In sk, this message translates to:
  /// **'Port na počúvanie'**
  String get udpListenPort;

  /// No description provided for @startListening.
  ///
  /// In sk, this message translates to:
  /// **'Spustiť'**
  String get startListening;

  /// No description provided for @stopListening.
  ///
  /// In sk, this message translates to:
  /// **'Zastaviť'**
  String get stopListening;

  /// No description provided for @connectionListening.
  ///
  /// In sk, this message translates to:
  /// **'Počúva UDP na porte {port}'**
  String connectionListening(String port);

  /// No description provided for @udpHint.
  ///
  /// In sk, this message translates to:
  /// **'Nastav simulátor/gateway aby posielal UDP na IP tohto telefónu, port {port}.'**
  String udpHint(String port);

  /// No description provided for @udpListeningOnPort.
  ///
  /// In sk, this message translates to:
  /// **'Počúvam UDP na porte {port}'**
  String udpListeningOnPort(int port);

  /// No description provided for @dayNotFound.
  ///
  /// In sk, this message translates to:
  /// **'Deň nenájdený'**
  String get dayNotFound;

  /// No description provided for @saved.
  ///
  /// In sk, this message translates to:
  /// **'Uložené'**
  String get saved;

  /// No description provided for @trackingThisDay.
  ///
  /// In sk, this message translates to:
  /// **'Tracking beží pre tento deň'**
  String get trackingThisDay;

  /// No description provided for @trackingOtherDay.
  ///
  /// In sk, this message translates to:
  /// **'Tracking beží pre iný deň'**
  String get trackingOtherDay;

  /// No description provided for @recordCount.
  ///
  /// In sk, this message translates to:
  /// **'{n} záznamov'**
  String recordCount(int n);

  /// No description provided for @addManual.
  ///
  /// In sk, this message translates to:
  /// **'Pridať manuálny'**
  String get addManual;

  /// No description provided for @noEntries.
  ///
  /// In sk, this message translates to:
  /// **'Žiadne záznamy'**
  String get noEntries;

  /// No description provided for @entriesAutoAdded.
  ///
  /// In sk, this message translates to:
  /// **'Záznamy sa pridávajú automaticky počas trackingu'**
  String get entriesAutoAdded;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať záznam?'**
  String get deleteEntryTitle;

  /// No description provided for @autoRecord.
  ///
  /// In sk, this message translates to:
  /// **'Automatický záznam'**
  String get autoRecord;

  /// No description provided for @routeSection.
  ///
  /// In sk, this message translates to:
  /// **'Trasa'**
  String get routeSection;

  /// No description provided for @fromPort.
  ///
  /// In sk, this message translates to:
  /// **'Odkiaľ'**
  String get fromPort;

  /// No description provided for @toPort.
  ///
  /// In sk, this message translates to:
  /// **'Kam'**
  String get toPort;

  /// No description provided for @distance.
  ///
  /// In sk, this message translates to:
  /// **'Vzdialenosť'**
  String get distance;

  /// No description provided for @vessel.
  ///
  /// In sk, this message translates to:
  /// **'Loď / čln'**
  String get vessel;

  /// No description provided for @weatherSection.
  ///
  /// In sk, this message translates to:
  /// **'Počasie'**
  String get weatherSection;

  /// No description provided for @morning.
  ///
  /// In sk, this message translates to:
  /// **'Ráno'**
  String get morning;

  /// No description provided for @noon.
  ///
  /// In sk, this message translates to:
  /// **'Poludnie'**
  String get noon;

  /// No description provided for @evening.
  ///
  /// In sk, this message translates to:
  /// **'Večer'**
  String get evening;

  /// No description provided for @windDir.
  ///
  /// In sk, this message translates to:
  /// **'Smer vetra'**
  String get windDir;

  /// No description provided for @seaState.
  ///
  /// In sk, this message translates to:
  /// **'Stav mora'**
  String get seaState;

  /// No description provided for @waveHeight.
  ///
  /// In sk, this message translates to:
  /// **'Výška vĺn'**
  String get waveHeight;

  /// No description provided for @dailyNote.
  ///
  /// In sk, this message translates to:
  /// **'Správa dňa'**
  String get dailyNote;

  /// No description provided for @dailyNoteHint.
  ///
  /// In sk, this message translates to:
  /// **'Popis plavby, zaujímavosti, udalosti dňa...'**
  String get dailyNoteHint;

  /// No description provided for @seaCalm.
  ///
  /// In sk, this message translates to:
  /// **'Pokojné'**
  String get seaCalm;

  /// No description provided for @seaLight.
  ///
  /// In sk, this message translates to:
  /// **'Mierne'**
  String get seaLight;

  /// No description provided for @seaModerate.
  ///
  /// In sk, this message translates to:
  /// **'Stredné'**
  String get seaModerate;

  /// No description provided for @seaRough.
  ///
  /// In sk, this message translates to:
  /// **'Rozbúrené'**
  String get seaRough;

  /// No description provided for @seaStormy.
  ///
  /// In sk, this message translates to:
  /// **'Búrlivé'**
  String get seaStormy;

  /// No description provided for @editEntry.
  ///
  /// In sk, this message translates to:
  /// **'Upraviť záznam'**
  String get editEntry;

  /// No description provided for @newEntry.
  ///
  /// In sk, this message translates to:
  /// **'Nový záznam'**
  String get newEntry;

  /// No description provided for @sailMode.
  ///
  /// In sk, this message translates to:
  /// **'Spôsob plavby'**
  String get sailMode;

  /// No description provided for @sailMain.
  ///
  /// In sk, this message translates to:
  /// **'Hlavná'**
  String get sailMain;

  /// No description provided for @sailDirection.
  ///
  /// In sk, this message translates to:
  /// **'Kurz voči vetru'**
  String get sailDirection;

  /// No description provided for @pointOfSailCloseHauled.
  ///
  /// In sk, this message translates to:
  /// **'Ostro proti vetru'**
  String get pointOfSailCloseHauled;

  /// No description provided for @pointOfSailCloseReach.
  ///
  /// In sk, this message translates to:
  /// **'Predobočný'**
  String get pointOfSailCloseReach;

  /// No description provided for @pointOfSailBeamReach.
  ///
  /// In sk, this message translates to:
  /// **'Bočný vietor'**
  String get pointOfSailBeamReach;

  /// No description provided for @pointOfSailBroadReach.
  ///
  /// In sk, this message translates to:
  /// **'Zadobočný vietor'**
  String get pointOfSailBroadReach;

  /// No description provided for @pointOfSailRunning.
  ///
  /// In sk, this message translates to:
  /// **'Zadný vietor'**
  String get pointOfSailRunning;

  /// No description provided for @tackPort.
  ///
  /// In sk, this message translates to:
  /// **'Ľavobok'**
  String get tackPort;

  /// No description provided for @tackStarboard.
  ///
  /// In sk, this message translates to:
  /// **'Pravobok'**
  String get tackStarboard;

  /// No description provided for @navigationSection.
  ///
  /// In sk, this message translates to:
  /// **'Navigácia'**
  String get navigationSection;

  /// No description provided for @latitude.
  ///
  /// In sk, this message translates to:
  /// **'Šírka'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In sk, this message translates to:
  /// **'Dĺžka'**
  String get longitude;

  /// No description provided for @weatherSeaSection.
  ///
  /// In sk, this message translates to:
  /// **'Počasie a more'**
  String get weatherSeaSection;

  /// Map layer toggle: measured wind from DHMZ weather stations
  ///
  /// In sk, this message translates to:
  /// **'Stanice – namerané'**
  String get mapStationWindLayer;

  /// No description provided for @windGust.
  ///
  /// In sk, this message translates to:
  /// **'Náraz'**
  String get windGust;

  /// No description provided for @radarTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zrážkový radar'**
  String get radarTitle;

  /// No description provided for @radarRefresh.
  ///
  /// In sk, this message translates to:
  /// **'Obnoviť snímku'**
  String get radarRefresh;

  /// No description provided for @radarUnavailable.
  ///
  /// In sk, this message translates to:
  /// **'Radarová snímka sa nedá načítať. Skús to znova, keď budeš mať signál.'**
  String get radarUnavailable;

  /// No description provided for @radarSourceDhmz.
  ///
  /// In sk, this message translates to:
  /// **'Zdroj: DHMZ – meteo.hr'**
  String get radarSourceDhmz;

  /// No description provided for @weatherSourceInstruments.
  ///
  /// In sk, this message translates to:
  /// **'Namerané lodnými prístrojmi'**
  String get weatherSourceInstruments;

  /// No description provided for @pdfWeatherSourceInstruments.
  ///
  /// In sk, this message translates to:
  /// **'Prístroje'**
  String get pdfWeatherSourceInstruments;

  /// No description provided for @pdfWeatherSourceStation.
  ///
  /// In sk, this message translates to:
  /// **'Stanica {name}'**
  String pdfWeatherSourceStation(String name);

  /// No description provided for @pdfWeatherSourceStationAt.
  ///
  /// In sk, this message translates to:
  /// **'{name}, {km} km'**
  String pdfWeatherSourceStationAt(String name, String km);

  /// No description provided for @pdfWeatherSourceStationUnknown.
  ///
  /// In sk, this message translates to:
  /// **'Meteostanica'**
  String get pdfWeatherSourceStationUnknown;

  /// No description provided for @pdfWeatherSourceModel.
  ///
  /// In sk, this message translates to:
  /// **'Model'**
  String get pdfWeatherSourceModel;

  /// No description provided for @weatherSourceStation.
  ///
  /// In sk, this message translates to:
  /// **'Namerané na stanici {name}'**
  String weatherSourceStation(String name);

  /// No description provided for @weatherSourceStationAt.
  ///
  /// In sk, this message translates to:
  /// **'Namerané na stanici {name}, {km} km ďaleko'**
  String weatherSourceStationAt(String name, String km);

  /// No description provided for @weatherSourceStationUnknown.
  ///
  /// In sk, this message translates to:
  /// **'Namerané na meteostanici'**
  String get weatherSourceStationUnknown;

  /// No description provided for @weatherSourceModel.
  ///
  /// In sk, this message translates to:
  /// **'Predpovedný model, nie meranie'**
  String get weatherSourceModel;

  /// No description provided for @windSpeed.
  ///
  /// In sk, this message translates to:
  /// **'Vietor'**
  String get windSpeed;

  /// No description provided for @windDirection.
  ///
  /// In sk, this message translates to:
  /// **'Smer'**
  String get windDirection;

  /// No description provided for @waveHeight2.
  ///
  /// In sk, this message translates to:
  /// **'Výška vĺn'**
  String get waveHeight2;

  /// No description provided for @engineSection.
  ///
  /// In sk, this message translates to:
  /// **'Motor a nádrže'**
  String get engineSection;

  /// No description provided for @engineHours.
  ///
  /// In sk, this message translates to:
  /// **'Motohodiny'**
  String get engineHours;

  /// No description provided for @fuel.
  ///
  /// In sk, this message translates to:
  /// **'Palivo'**
  String get fuel;

  /// No description provided for @fuelLevel.
  ///
  /// In sk, this message translates to:
  /// **'Hladina paliva'**
  String get fuelLevel;

  /// No description provided for @waterLevel.
  ///
  /// In sk, this message translates to:
  /// **'Hladina vody'**
  String get waterLevel;

  /// No description provided for @helmsmanLabel.
  ///
  /// In sk, this message translates to:
  /// **'Kormidelník'**
  String get helmsmanLabel;

  /// No description provided for @noteSection.
  ///
  /// In sk, this message translates to:
  /// **'Poznámka'**
  String get noteSection;

  /// No description provided for @noteHint.
  ///
  /// In sk, this message translates to:
  /// **'Podmienky plavby, udalosti, zmena posádky...'**
  String get noteHint;

  /// No description provided for @quickPhotoLogTitle.
  ///
  /// In sk, this message translates to:
  /// **'Rýchly záznam'**
  String get quickPhotoLogTitle;

  /// No description provided for @quickPhotoNoteHint.
  ///
  /// In sk, this message translates to:
  /// **'Čo je to? (voliteľné)'**
  String get quickPhotoNoteHint;

  /// No description provided for @exportDayTitle.
  ///
  /// In sk, this message translates to:
  /// **'Export dňa'**
  String get exportDayTitle;

  /// No description provided for @exportCharterTitle.
  ///
  /// In sk, this message translates to:
  /// **'Export plavby'**
  String get exportCharterTitle;

  /// No description provided for @loadingData.
  ///
  /// In sk, this message translates to:
  /// **'Načítavam dáta...'**
  String get loadingData;

  /// No description provided for @mapsReady.
  ///
  /// In sk, this message translates to:
  /// **'Mapy pripravené – môžeš exportovať'**
  String get mapsReady;

  /// No description provided for @generatingMaps.
  ///
  /// In sk, this message translates to:
  /// **'Generujem náhľady máp ({current}/{total})...'**
  String generatingMaps(int current, int total);

  /// No description provided for @exportDayBtn.
  ///
  /// In sk, this message translates to:
  /// **'Exportovať deň'**
  String get exportDayBtn;

  /// No description provided for @exportCharterBtn.
  ///
  /// In sk, this message translates to:
  /// **'Exportovať plavbu'**
  String get exportCharterBtn;

  /// No description provided for @entriesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Záznamy'**
  String get entriesLabel;

  /// No description provided for @routePoints.
  ///
  /// In sk, this message translates to:
  /// **'Body trasy'**
  String get routePoints;

  /// No description provided for @anchorDriftTitle.
  ///
  /// In sk, this message translates to:
  /// **'⚓ KOTVA DRIFTUJE!'**
  String get anchorDriftTitle;

  /// No description provided for @anchorDriftContent.
  ///
  /// In sk, this message translates to:
  /// **'Loď prekročila perimeter kotvy.\nOkamžite skontrolujte polohu!'**
  String get anchorDriftContent;

  /// No description provided for @cancelAnchor.
  ///
  /// In sk, this message translates to:
  /// **'Zrušiť kotvu'**
  String get cancelAnchor;

  /// No description provided for @stopAlarm.
  ///
  /// In sk, this message translates to:
  /// **'Zastaviť alarm'**
  String get stopAlarm;

  /// No description provided for @briefingItem1.
  ///
  /// In sk, this message translates to:
  /// **'Záchranné vesty – umiestnenie a použitie'**
  String get briefingItem1;

  /// No description provided for @briefingItem2.
  ///
  /// In sk, this message translates to:
  /// **'Záchranný kruh a MOB postup'**
  String get briefingItem2;

  /// No description provided for @briefingItem3.
  ///
  /// In sk, this message translates to:
  /// **'Svetlice – typy a použitie'**
  String get briefingItem3;

  /// No description provided for @briefingItem4.
  ///
  /// In sk, this message translates to:
  /// **'EPIRB / PLB – aktivácia'**
  String get briefingItem4;

  /// No description provided for @briefingItem5.
  ///
  /// In sk, this message translates to:
  /// **'VHF rádio – kanál 16, Mayday postup'**
  String get briefingItem5;

  /// No description provided for @briefingItem6.
  ///
  /// In sk, this message translates to:
  /// **'Hasiaci prístroj – umiestnenie a použitie'**
  String get briefingItem6;

  /// No description provided for @briefingItem7.
  ///
  /// In sk, this message translates to:
  /// **'Lekárnička – umiestnenie'**
  String get briefingItem7;

  /// No description provided for @briefingItem8.
  ///
  /// In sk, this message translates to:
  /// **'Núdzové vypnutie motora'**
  String get briefingItem8;

  /// No description provided for @briefingItem9.
  ///
  /// In sk, this message translates to:
  /// **'Úniky – voda, plyn'**
  String get briefingItem9;

  /// No description provided for @briefingItem10.
  ///
  /// In sk, this message translates to:
  /// **'Kotva a reťaz – postup kotvenia'**
  String get briefingItem10;

  /// No description provided for @briefingItem11.
  ///
  /// In sk, this message translates to:
  /// **'Pravidlá na palube'**
  String get briefingItem11;

  /// No description provided for @briefingItem12.
  ///
  /// In sk, this message translates to:
  /// **'Núdzové kontakty a VHF 16'**
  String get briefingItem12;

  /// No description provided for @checkInItem1.
  ///
  /// In sk, this message translates to:
  /// **'Doklady lode (registrácia, poistenie)'**
  String get checkInItem1;

  /// No description provided for @checkInItem2.
  ///
  /// In sk, this message translates to:
  /// **'Záchranné vybavenie – komplet'**
  String get checkInItem2;

  /// No description provided for @checkInItem3.
  ///
  /// In sk, this message translates to:
  /// **'Zásoby paliva'**
  String get checkInItem3;

  /// No description provided for @checkInItem4.
  ///
  /// In sk, this message translates to:
  /// **'Zásoby vody'**
  String get checkInItem4;

  /// No description provided for @checkInItem5.
  ///
  /// In sk, this message translates to:
  /// **'Kotva a reťaz – kontrola'**
  String get checkInItem5;

  /// No description provided for @checkInItem6.
  ///
  /// In sk, this message translates to:
  /// **'Motor – skúšobná prevádzka'**
  String get checkInItem6;

  /// No description provided for @checkInItem7.
  ///
  /// In sk, this message translates to:
  /// **'Navigačné prístroje'**
  String get checkInItem7;

  /// No description provided for @checkInItem8.
  ///
  /// In sk, this message translates to:
  /// **'Lezenie – lana a plachty'**
  String get checkInItem8;

  /// No description provided for @checkInItem9.
  ///
  /// In sk, this message translates to:
  /// **'Kuchyňa – plyn, sporák'**
  String get checkInItem9;

  /// No description provided for @checkInItem10.
  ///
  /// In sk, this message translates to:
  /// **'WC – funkčnosť'**
  String get checkInItem10;

  /// No description provided for @checkInItem11.
  ///
  /// In sk, this message translates to:
  /// **'Existujúce poškodenia – fotodokumentácia'**
  String get checkInItem11;

  /// No description provided for @checkOutItem1.
  ///
  /// In sk, this message translates to:
  /// **'Loď vyčistená – exteriér'**
  String get checkOutItem1;

  /// No description provided for @checkOutItem2.
  ///
  /// In sk, this message translates to:
  /// **'Loď vyčistená – interiér'**
  String get checkOutItem2;

  /// No description provided for @checkOutItem3.
  ///
  /// In sk, this message translates to:
  /// **'Palivo doplnené'**
  String get checkOutItem3;

  /// No description provided for @checkOutItem4.
  ///
  /// In sk, this message translates to:
  /// **'Voda doplnená'**
  String get checkOutItem4;

  /// No description provided for @checkOutItem5.
  ///
  /// In sk, this message translates to:
  /// **'Odpadky odstránené'**
  String get checkOutItem5;

  /// No description provided for @checkOutItem6.
  ///
  /// In sk, this message translates to:
  /// **'Poškodenia hlásené'**
  String get checkOutItem6;

  /// No description provided for @checkOutItem7.
  ///
  /// In sk, this message translates to:
  /// **'Kľúče odovzdané'**
  String get checkOutItem7;

  /// No description provided for @gearListShort.
  ///
  /// In sk, this message translates to:
  /// **'Výbava\njednotlivca'**
  String get gearListShort;

  /// No description provided for @colregRules.
  ///
  /// In sk, this message translates to:
  /// **'COLREG\nPravidlá'**
  String get colregRules;

  /// No description provided for @checkInShort.
  ///
  /// In sk, this message translates to:
  /// **'Check-in\nPrevzatie'**
  String get checkInShort;

  /// No description provided for @checkOutShort.
  ///
  /// In sk, this message translates to:
  /// **'Check-out\nOdovzdanie'**
  String get checkOutShort;

  /// No description provided for @appTagline.
  ///
  /// In sk, this message translates to:
  /// **'Váš spoľahlivý lodný denník'**
  String get appTagline;

  /// No description provided for @exportSavedMsg.
  ///
  /// In sk, this message translates to:
  /// **'Uložené: {path}'**
  String exportSavedMsg(String path);

  /// No description provided for @exportSavedPdfGpx.
  ///
  /// In sk, this message translates to:
  /// **'Uložené: {pdf} + {gpx}'**
  String exportSavedPdfGpx(String pdf, String gpx);

  /// No description provided for @exportErrorMsg.
  ///
  /// In sk, this message translates to:
  /// **'Chyba exportu: {error}'**
  String exportErrorMsg(String error);

  /// No description provided for @generatingPdf.
  ///
  /// In sk, this message translates to:
  /// **'Generujem PDF...'**
  String get generatingPdf;

  /// No description provided for @colregTitle.
  ///
  /// In sk, this message translates to:
  /// **'COLREG – Pravidlá pre vyhýbanie'**
  String get colregTitle;

  /// No description provided for @tableOfContents.
  ///
  /// In sk, this message translates to:
  /// **'OBSAH'**
  String get tableOfContents;

  /// No description provided for @inThisChapter.
  ///
  /// In sk, this message translates to:
  /// **'V tejto kapitole:'**
  String get inThisChapter;

  /// No description provided for @ruleNumberLabel.
  ///
  /// In sk, this message translates to:
  /// **'Pr. {n}'**
  String ruleNumberLabel(Object n);

  /// No description provided for @resetChecklistTitle.
  ///
  /// In sk, this message translates to:
  /// **'Resetovať zoznam?'**
  String get resetChecklistTitle;

  /// No description provided for @resetChecklistContent.
  ///
  /// In sk, this message translates to:
  /// **'Všetky zaškrtnutia sa vymažú.'**
  String get resetChecklistContent;

  /// No description provided for @reset.
  ///
  /// In sk, this message translates to:
  /// **'Resetovať'**
  String get reset;

  /// No description provided for @checkInReceivingTitle.
  ///
  /// In sk, this message translates to:
  /// **'Check-in – Prevzatie lode'**
  String get checkInReceivingTitle;

  /// No description provided for @checkOutHandoverTitle.
  ///
  /// In sk, this message translates to:
  /// **'Check-out – Odovzdanie lode'**
  String get checkOutHandoverTitle;

  /// No description provided for @checkInCompletedMsg.
  ///
  /// In sk, this message translates to:
  /// **'Loď prevzatá – všetko skontrolované ✓'**
  String get checkInCompletedMsg;

  /// No description provided for @checkOutCompletedMsg.
  ///
  /// In sk, this message translates to:
  /// **'Loď odovzdaná – všetko v poriadku ✓'**
  String get checkOutCompletedMsg;

  /// No description provided for @briefingDoneMsg.
  ///
  /// In sk, this message translates to:
  /// **'Briefing dokončený – posádka informovaná'**
  String get briefingDoneMsg;

  /// No description provided for @sectionBriefed.
  ///
  /// In sk, this message translates to:
  /// **'Sekcia prebriefovaná ✓'**
  String get sectionBriefed;

  /// No description provided for @confirmSection.
  ///
  /// In sk, this message translates to:
  /// **'Potvrdiť sekciu'**
  String get confirmSection;

  /// No description provided for @gearListTitle.
  ///
  /// In sk, this message translates to:
  /// **'Výbava jednotlivca'**
  String get gearListTitle;

  /// No description provided for @newCategory.
  ///
  /// In sk, this message translates to:
  /// **'Nová kategória'**
  String get newCategory;

  /// No description provided for @add.
  ///
  /// In sk, this message translates to:
  /// **'Pridať'**
  String get add;

  /// No description provided for @deleteItemTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať položku?'**
  String get deleteItemTitle;

  /// No description provided for @allPackedMsg.
  ///
  /// In sk, this message translates to:
  /// **'Všetko zabalené, pripravený na plavbu! 🎉'**
  String get allPackedMsg;

  /// No description provided for @addItemLabel.
  ///
  /// In sk, this message translates to:
  /// **'Pridať položku'**
  String get addItemLabel;

  /// No description provided for @addToCategoryTitle.
  ///
  /// In sk, this message translates to:
  /// **'Pridať do: {category}'**
  String addToCategoryTitle(String category);

  /// No description provided for @newItemHint.
  ///
  /// In sk, this message translates to:
  /// **'Nová položka...'**
  String get newItemHint;

  /// No description provided for @addWaypoint.
  ///
  /// In sk, this message translates to:
  /// **'Pridať waypoint'**
  String get addWaypoint;

  /// No description provided for @editWaypoint.
  ///
  /// In sk, this message translates to:
  /// **'Upraviť waypoint'**
  String get editWaypoint;

  /// No description provided for @deleteWaypointTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať waypoint?'**
  String get deleteWaypointTitle;

  /// No description provided for @deleteWaypointNavActive.
  ///
  /// In sk, this message translates to:
  /// **'Navigácia na {name} je aktívna. Zmazaním bodu sa vypne.'**
  String deleteWaypointNavActive(String name);

  /// No description provided for @waypointNameLabel.
  ///
  /// In sk, this message translates to:
  /// **'Názov'**
  String get waypointNameLabel;

  /// No description provided for @skipperSignature.
  ///
  /// In sk, this message translates to:
  /// **'Podpis skippera'**
  String get skipperSignature;

  /// No description provided for @skipperNameLabel.
  ///
  /// In sk, this message translates to:
  /// **'Meno skippera'**
  String get skipperNameLabel;

  /// No description provided for @signWithFinger.
  ///
  /// In sk, this message translates to:
  /// **'Podpíšte sa prstom'**
  String get signWithFinger;

  /// No description provided for @clear.
  ///
  /// In sk, this message translates to:
  /// **'Vymazať'**
  String get clear;

  /// No description provided for @signAndExport.
  ///
  /// In sk, this message translates to:
  /// **'Podpísať a exportovať'**
  String get signAndExport;

  /// No description provided for @pleaseSign.
  ///
  /// In sk, this message translates to:
  /// **'Prosím podpíšte sa pred exportom'**
  String get pleaseSign;

  /// No description provided for @generatingPdfPreview.
  ///
  /// In sk, this message translates to:
  /// **'Generujem náhľad PDF...'**
  String get generatingPdfPreview;

  /// No description provided for @generationError.
  ///
  /// In sk, this message translates to:
  /// **'Chyba generovania: {error}'**
  String generationError(String error);

  /// No description provided for @savingAndGeneratingGpx.
  ///
  /// In sk, this message translates to:
  /// **'Ukladám a generujem GPX...'**
  String get savingAndGeneratingGpx;

  /// No description provided for @editCharter.
  ///
  /// In sk, this message translates to:
  /// **'Upraviť plavbu'**
  String get editCharter;

  /// No description provided for @basicInfo.
  ///
  /// In sk, this message translates to:
  /// **'Základné informácie'**
  String get basicInfo;

  /// No description provided for @voyageNameRequired.
  ///
  /// In sk, this message translates to:
  /// **'Názov plavby *'**
  String get voyageNameRequired;

  /// No description provided for @dateFrom.
  ///
  /// In sk, this message translates to:
  /// **'Dátum od'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In sk, this message translates to:
  /// **'Dátum do'**
  String get dateTo;

  /// No description provided for @vesselName.
  ///
  /// In sk, this message translates to:
  /// **'Meno lode'**
  String get vesselName;

  /// No description provided for @vesselType.
  ///
  /// In sk, this message translates to:
  /// **'Typ lode'**
  String get vesselType;

  /// No description provided for @homePort.
  ///
  /// In sk, this message translates to:
  /// **'Domovský prístav'**
  String get homePort;

  /// No description provided for @mmsi.
  ///
  /// In sk, this message translates to:
  /// **'MMSI'**
  String get mmsi;

  /// No description provided for @callsign.
  ///
  /// In sk, this message translates to:
  /// **'Volací znak'**
  String get callsign;

  /// No description provided for @vesselLengthM.
  ///
  /// In sk, this message translates to:
  /// **'Dĺžka (m)'**
  String get vesselLengthM;

  /// No description provided for @vesselBeamM.
  ///
  /// In sk, this message translates to:
  /// **'Šírka (m)'**
  String get vesselBeamM;

  /// No description provided for @vesselDraftM.
  ///
  /// In sk, this message translates to:
  /// **'Ponor (m)'**
  String get vesselDraftM;

  /// No description provided for @selectExistingVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Vybrať existujúcu plavbu'**
  String get selectExistingVoyage;

  /// No description provided for @newVoyageForm.
  ///
  /// In sk, this message translates to:
  /// **'Nová plavba'**
  String get newVoyageForm;

  /// No description provided for @fillFormAndBriefing.
  ///
  /// In sk, this message translates to:
  /// **'Vyplniť dotazník a podpísať SB'**
  String get fillFormAndBriefing;

  /// No description provided for @notesLabel.
  ///
  /// In sk, this message translates to:
  /// **'Poznámky'**
  String get notesLabel;

  /// No description provided for @statusLabel.
  ///
  /// In sk, this message translates to:
  /// **'Stav'**
  String get statusLabel;

  /// No description provided for @safetyBriefingDoneLabel.
  ///
  /// In sk, this message translates to:
  /// **'Safety Briefing vykonaný'**
  String get safetyBriefingDoneLabel;

  /// No description provided for @checkInDoneLabel.
  ///
  /// In sk, this message translates to:
  /// **'Check-in dokončený'**
  String get checkInDoneLabel;

  /// No description provided for @checkOutDoneLabel.
  ///
  /// In sk, this message translates to:
  /// **'Check-out dokončený'**
  String get checkOutDoneLabel;

  /// No description provided for @enterVoyageName.
  ///
  /// In sk, this message translates to:
  /// **'Zadaj názov plavby'**
  String get enterVoyageName;

  /// No description provided for @daysCount.
  ///
  /// In sk, this message translates to:
  /// **'{n} dní'**
  String daysCount(int n);

  /// No description provided for @selectTargetWaypoint.
  ///
  /// In sk, this message translates to:
  /// **'Vyber cieľový waypoint'**
  String get selectTargetWaypoint;

  /// No description provided for @noWaypoints.
  ///
  /// In sk, this message translates to:
  /// **'Žiadne waypointy.'**
  String get noWaypoints;

  /// No description provided for @goToMap.
  ///
  /// In sk, this message translates to:
  /// **'Ísť na mapu'**
  String get goToMap;

  /// No description provided for @noTarget.
  ///
  /// In sk, this message translates to:
  /// **'Žiadny cieľ'**
  String get noTarget;

  /// No description provided for @selectWaypointHint.
  ///
  /// In sk, this message translates to:
  /// **'Naviguj k waypointu'**
  String get selectWaypointHint;

  /// No description provided for @sessionStats.
  ///
  /// In sk, this message translates to:
  /// **'Štatistiky plavby'**
  String get sessionStats;

  /// No description provided for @maxSpeed.
  ///
  /// In sk, this message translates to:
  /// **'Max rýchlosť'**
  String get maxSpeed;

  /// No description provided for @avgSpeed.
  ///
  /// In sk, this message translates to:
  /// **'Priem. rýchlosť'**
  String get avgSpeed;

  /// No description provided for @sailingTime.
  ///
  /// In sk, this message translates to:
  /// **'Čas plavby'**
  String get sailingTime;

  /// No description provided for @gpsData.
  ///
  /// In sk, this message translates to:
  /// **'GPS Dáta'**
  String get gpsData;

  /// No description provided for @gpsPosition.
  ///
  /// In sk, this message translates to:
  /// **'Poloha'**
  String get gpsPosition;

  /// No description provided for @courseCog.
  ///
  /// In sk, this message translates to:
  /// **'Kurz (COG)'**
  String get courseCog;

  /// No description provided for @altitudeLabel.
  ///
  /// In sk, this message translates to:
  /// **'Výška'**
  String get altitudeLabel;

  /// No description provided for @dscProcedure.
  ///
  /// In sk, this message translates to:
  /// **'DSC POSTUP'**
  String get dscProcedure;

  /// No description provided for @voiceScript.
  ///
  /// In sk, this message translates to:
  /// **'HLAS SKRIPT'**
  String get voiceScript;

  /// No description provided for @dscWarningUseOnly.
  ///
  /// In sk, this message translates to:
  /// **'⚠️ POUŽÍVAŤ IBA V PRÍPADE'**
  String get dscWarningUseOnly;

  /// No description provided for @dscWarningDanger.
  ///
  /// In sk, this message translates to:
  /// **'VÁŽNEHO A BEZPROSTREDNÉHO NEBEZPEČENSTVA'**
  String get dscWarningDanger;

  /// No description provided for @dscWarningTypes.
  ///
  /// In sk, this message translates to:
  /// **'Požiar · Potápanie · Muž cez palubu'**
  String get dscWarningTypes;

  /// No description provided for @dscProcedureSubtitle.
  ///
  /// In sk, this message translates to:
  /// **'Uchovajte tento postup pri VHF DSC rádiu'**
  String get dscProcedureSubtitle;

  /// No description provided for @fillBeforeSailing.
  ///
  /// In sk, this message translates to:
  /// **'Vyplňte pred plavbou:'**
  String get fillBeforeSailing;

  /// No description provided for @copyTooltip.
  ///
  /// In sk, this message translates to:
  /// **'Kopírovať'**
  String get copyTooltip;

  /// No description provided for @scriptCopied.
  ///
  /// In sk, this message translates to:
  /// **'Skript skopírovaný'**
  String get scriptCopied;

  /// No description provided for @sendOnCh16.
  ///
  /// In sk, this message translates to:
  /// **'📻 Odoslať na Kanáli 16 · Vysoký výkon · Opakovať každé 2 minúty ak bez odpovede'**
  String get sendOnCh16;

  /// No description provided for @enterAbove.
  ///
  /// In sk, this message translates to:
  /// **'[zadaj v polí vyššie]'**
  String get enterAbove;

  /// No description provided for @distressNature.
  ///
  /// In sk, this message translates to:
  /// **'Povaha tiesne'**
  String get distressNature;

  /// No description provided for @vesselNameLabel.
  ///
  /// In sk, this message translates to:
  /// **'Názov lode'**
  String get vesselNameLabel;

  /// No description provided for @numberOfPersons.
  ///
  /// In sk, this message translates to:
  /// **'Počet osôb'**
  String get numberOfPersons;

  /// No description provided for @additionalInfo.
  ///
  /// In sk, this message translates to:
  /// **'Ďalšie info'**
  String get additionalInfo;

  /// No description provided for @voiceScriptTitle.
  ///
  /// In sk, this message translates to:
  /// **'HLASOVÝ MAYDAY SKRIPT'**
  String get voiceScriptTitle;

  /// No description provided for @voiceScriptTitleFor.
  ///
  /// In sk, this message translates to:
  /// **'HLASOVÝ SKRIPT · {type}'**
  String voiceScriptTitleFor(String type);

  /// No description provided for @distressCallMayday.
  ///
  /// In sk, this message translates to:
  /// **'MAYDAY'**
  String get distressCallMayday;

  /// No description provided for @distressCallPanPan.
  ///
  /// In sk, this message translates to:
  /// **'PAN PAN'**
  String get distressCallPanPan;

  /// No description provided for @distressCallSecurite.
  ///
  /// In sk, this message translates to:
  /// **'SÉCURITÉ'**
  String get distressCallSecurite;

  /// No description provided for @distressNoteMayday.
  ///
  /// In sk, this message translates to:
  /// **'MAYDAY: len pri vážnom a bezprostrednom ohrození života alebo lode. Napr. „MAYDAY, MAYDAY, MAYDAY, taking on water, sinking“ (naberáme vodu, potápame sa).'**
  String get distressNoteMayday;

  /// No description provided for @distressNotePanPan.
  ///
  /// In sk, this message translates to:
  /// **'PAN PAN: naliehavé hlásenie, ktoré priamo neohrozuje život. Napr. „PAN PAN, PAN PAN, PAN PAN, engine failure, drifting toward rocks“ (výpadok motora, unášaní k skalám).'**
  String get distressNotePanPan;

  /// No description provided for @distressNoteSecurite.
  ///
  /// In sk, this message translates to:
  /// **'SÉCURITÉ: bezpečnostné hlásenie o plavbe alebo počasí pre ostatné lode. Napr. „SÉCURITÉ, SÉCURITÉ, SÉCURITÉ, uncharted wreck reported at position…“ (nezakreslený vrak nahlásený na polohe…).'**
  String get distressNoteSecurite;

  /// No description provided for @dscStep1.
  ///
  /// In sk, this message translates to:
  /// **'Uistite sa, že rádio je zapnuté.'**
  String get dscStep1;

  /// No description provided for @dscStep2.
  ///
  /// In sk, this message translates to:
  /// **'Otvorte kryt nad ČERVENÝM tlačidlom tiesne.'**
  String get dscStep2;

  /// No description provided for @dscStep3.
  ///
  /// In sk, this message translates to:
  /// **'Stlačte ČERVENÉ tlačidlo RAZ a uvoľnite.'**
  String get dscStep3;

  /// No description provided for @dscStep4.
  ///
  /// In sk, this message translates to:
  /// **'Vyberte povahu tiesne.\n(Požiar, Potápanie, MOB a pod.)\nAk vynecháte, odošle sa Neoznačená tieseň.'**
  String get dscStep4;

  /// No description provided for @dscStep5.
  ///
  /// In sk, this message translates to:
  /// **'Stlačte a PODRŽTE ČERVENÉ tlačidlo po dobu 5 sekúnd na odoslanie výzvy.'**
  String get dscStep5;

  /// No description provided for @dscStep6.
  ///
  /// In sk, this message translates to:
  /// **'Čakajte max. 15 sekúnd na potvrdenie (zobrazí sa na obrazovke), potom pošlite hlasovú správu na Kanáli 16 na VYSOKÝ výkon.'**
  String get dscStep6;

  /// No description provided for @appDescription.
  ///
  /// In sk, this message translates to:
  /// **'Profesionálny lodný denník pre jachtárov.'**
  String get appDescription;

  /// No description provided for @vesselIdTitle.
  ///
  /// In sk, this message translates to:
  /// **'Identifikácia plavidla'**
  String get vesselIdTitle;

  /// No description provided for @vesselIdHint.
  ///
  /// In sk, this message translates to:
  /// **'Call sign a MMSI sa automaticky vyplnia v Mayday Card.'**
  String get vesselIdHint;

  /// No description provided for @maritimeReference.
  ///
  /// In sk, this message translates to:
  /// **'Námorná abeceda'**
  String get maritimeReference;

  /// No description provided for @phonetic.
  ///
  /// In sk, this message translates to:
  /// **'Fonetická'**
  String get phonetic;

  /// No description provided for @flagAlphabet.
  ///
  /// In sk, this message translates to:
  /// **'Vlajkové signály'**
  String get flagAlphabet;

  /// No description provided for @dayShapes.
  ///
  /// In sk, this message translates to:
  /// **'Denné znaky'**
  String get dayShapes;

  /// No description provided for @marineReferenceTile.
  ///
  /// In sk, this message translates to:
  /// **'Signály & abeceda'**
  String get marineReferenceTile;

  /// No description provided for @navInstruments.
  ///
  /// In sk, this message translates to:
  /// **'Lodné prístroje'**
  String get navInstruments;

  /// No description provided for @enterPort.
  ///
  /// In sk, this message translates to:
  /// **'Zadaj prístav...'**
  String get enterPort;

  /// No description provided for @closeWithoutSaving.
  ///
  /// In sk, this message translates to:
  /// **'Zavrieť bez uloženia'**
  String get closeWithoutSaving;

  /// No description provided for @saveToDevice.
  ///
  /// In sk, this message translates to:
  /// **'Uložiť do zariadenia'**
  String get saveToDevice;

  /// No description provided for @saveAndShare.
  ///
  /// In sk, this message translates to:
  /// **'Uložiť a zdieľať'**
  String get saveAndShare;

  /// No description provided for @timestampCannotBeChanged.
  ///
  /// In sk, this message translates to:
  /// **'Čas záznamu sa nedá zmeniť'**
  String get timestampCannotBeChanged;

  /// No description provided for @entriesShort.
  ///
  /// In sk, this message translates to:
  /// **'{n} záz.'**
  String entriesShort(int n);

  /// No description provided for @mainsail.
  ///
  /// In sk, this message translates to:
  /// **'Hlavná'**
  String get mainsail;

  /// No description provided for @weatherConditionTitle.
  ///
  /// In sk, this message translates to:
  /// **'Stav počasia'**
  String get weatherConditionTitle;

  /// No description provided for @weatherConditionLabel.
  ///
  /// In sk, this message translates to:
  /// **'Podmienky'**
  String get weatherConditionLabel;

  /// No description provided for @wcSunny.
  ///
  /// In sk, this message translates to:
  /// **'Slnečno'**
  String get wcSunny;

  /// No description provided for @wcPartlyCloudy.
  ///
  /// In sk, this message translates to:
  /// **'Čiastočne oblačno'**
  String get wcPartlyCloudy;

  /// No description provided for @wcOvercast.
  ///
  /// In sk, this message translates to:
  /// **'Zamračené'**
  String get wcOvercast;

  /// No description provided for @wcLightRain.
  ///
  /// In sk, this message translates to:
  /// **'Slabý dážď'**
  String get wcLightRain;

  /// No description provided for @wcRain.
  ///
  /// In sk, this message translates to:
  /// **'Dážď'**
  String get wcRain;

  /// No description provided for @wcHeavyRain.
  ///
  /// In sk, this message translates to:
  /// **'Silný dážď'**
  String get wcHeavyRain;

  /// No description provided for @wcDrizzle.
  ///
  /// In sk, this message translates to:
  /// **'Mrholenie'**
  String get wcDrizzle;

  /// No description provided for @wcThunderstorm.
  ///
  /// In sk, this message translates to:
  /// **'Búrka'**
  String get wcThunderstorm;

  /// No description provided for @wcIsoThunderstorm.
  ///
  /// In sk, this message translates to:
  /// **'Ojedinelé búrky'**
  String get wcIsoThunderstorm;

  /// No description provided for @wcHail.
  ///
  /// In sk, this message translates to:
  /// **'Krúpy'**
  String get wcHail;

  /// No description provided for @wcDust.
  ///
  /// In sk, this message translates to:
  /// **'Prach'**
  String get wcDust;

  /// No description provided for @wcFoggy.
  ///
  /// In sk, this message translates to:
  /// **'Hmla'**
  String get wcFoggy;

  /// No description provided for @wcWindy.
  ///
  /// In sk, this message translates to:
  /// **'Veterné'**
  String get wcWindy;

  /// No description provided for @wcCold.
  ///
  /// In sk, this message translates to:
  /// **'Mráz'**
  String get wcCold;

  /// No description provided for @photoSection.
  ///
  /// In sk, this message translates to:
  /// **'Fotografia'**
  String get photoSection;

  /// No description provided for @camera.
  ///
  /// In sk, this message translates to:
  /// **'Fotoaparát'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In sk, this message translates to:
  /// **'Galéria'**
  String get gallery;

  /// No description provided for @addPhoto.
  ///
  /// In sk, this message translates to:
  /// **'Pridať fotku'**
  String get addPhoto;

  /// No description provided for @photoAddedToEntry.
  ///
  /// In sk, this message translates to:
  /// **'Fotografia priložená'**
  String get photoAddedToEntry;

  /// No description provided for @voyageStart.
  ///
  /// In sk, this message translates to:
  /// **'Začiatok plavby'**
  String get voyageStart;

  /// No description provided for @voyageEnd.
  ///
  /// In sk, this message translates to:
  /// **'Koniec plavby'**
  String get voyageEnd;

  /// No description provided for @onlineAccount.
  ///
  /// In sk, this message translates to:
  /// **'Online účet'**
  String get onlineAccount;

  /// No description provided for @onlineAccountDesc.
  ///
  /// In sk, this message translates to:
  /// **'Online synchronizácia denníka — pripravujeme'**
  String get onlineAccountDesc;

  /// No description provided for @register.
  ///
  /// In sk, this message translates to:
  /// **'Registrovať'**
  String get register;

  /// No description provided for @login.
  ///
  /// In sk, this message translates to:
  /// **'Prihlásiť'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In sk, this message translates to:
  /// **'Odhlásiť'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In sk, this message translates to:
  /// **'Budete odhlásený. Dáta uložené v zariadení zostanú.'**
  String get logoutConfirm;

  /// No description provided for @notLoggedIn.
  ///
  /// In sk, this message translates to:
  /// **'Neprihlásený'**
  String get notLoggedIn;

  /// No description provided for @fullName.
  ///
  /// In sk, this message translates to:
  /// **'Celé meno'**
  String get fullName;

  /// No description provided for @password.
  ///
  /// In sk, this message translates to:
  /// **'Heslo'**
  String get password;

  /// No description provided for @userGuide.
  ///
  /// In sk, this message translates to:
  /// **'Používateľská príručka'**
  String get userGuide;

  /// No description provided for @guideQuickStart.
  ///
  /// In sk, this message translates to:
  /// **'Rýchly štart – 5 krokov'**
  String get guideQuickStart;

  /// No description provided for @guideQuickStartBody.
  ///
  /// In sk, this message translates to:
  /// **'1. Ťukni na veľké tlačidlo \"Spustiť plavbu\" hore (na Mape, v Denníku alebo pri Prístrojoch) – vyber frekvenciu zápisov a tracking beží, nič iné netreba vypĺňať vopred\n2. Ak máš rozostavanú plavbu, appka sa opýta: pokračovať v nej, alebo nový záznam\n3. Chýbajúce údaje (check-in, safety briefing, karta lode/posádky) doplň kedykoľvek – appka ich pripomenie farebnými chipmi v Denníku\n4. Počas dňa pridávaj záznamy: čas, pozícia, poznámka\n5. Na konci plavby otvor Nastavenia → Export PDF\n\nAppka beží na celú obrazovku – systémové lišty telefónu zobrazíš potiahnutím prsta od horného alebo spodného okraja.'**
  String get guideQuickStartBody;

  /// No description provided for @guideMapTitle.
  ///
  /// In sk, this message translates to:
  /// **'Mapa'**
  String get guideMapTitle;

  /// No description provided for @guideMapBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Mapa zobrazuje tvoju aktuálnu polohu a trasu plavby.\n\n• Modrá bodka = aktuálna poloha\n• Modrá čiara = práve trackovaná trasa\n• Ikona trasy – vyber ľubovoľnú plavbu alebo deň a pozri jej trasu na mape (oranžovo), aj bez PDF exportu Dole sa objaví prehrávanie: posuvníkom prejdeš plavbu v čase a vidíš polohu, rýchlosť, kurz, vietor aj tlak v ktoromkoľvek okamihu. Zvislé čiarky na posuvníku sú udalosti — začiatok a koniec plavby, kotva, drift, MOB.\n• Môžeš prepínať medzi satelitnou a mapovou vrstvou\n• Seamarky – prepínač pre námorné značky (vraky, plytčiny, bóje)\n• Hĺbky – hĺbnice z EMODnet s hĺbkou v metroch. Model dna z prieskumov, NIE námorná mapa: na plánovanie prielivu áno, na rozhodnutie „prejdem tadiaľ“ nie. Štandardne vypnuté; prezerané dlaždice sa ukladajú ako ostatné. Keď je vrstva zapnutá, ťuknutím do mapy prečítaš hĺbku v tom bode (treba signál).\n• Prístavy – klikateľná vrstva kotvísk, marín a prístavov (dáta z OpenStreetMap): ťukni na ikonku a uvidíš názov, VHF kanál, telefón, web (ťuknutím rovno zavoláš alebo otvoríš stránku), hĺbku či kapacitu, ak sú známe; miesto si vieš rovno uložiť ako waypoint; vrstva zahŕňa aj tankovacie stanice pre lode (oranžová pumpa)\n• Pravítko (fialová ikona) – ťukaj body na mape: súčet NM, kurz poslednej nohy a ETA pri aktuálnej rýchlosti; body sa prichytávajú na waypointy, takže si vieš zmerať trasu cez ciele\n• Offline mapa (ikona sťahovania) — stiahne viditeľnú oblasť na použitie bez signálu, od aktuálneho priblíženia o tri úrovne hlbšie. Vždy seamarky; keď máš zapnutý satelit, aj snímky a ich popisky. Navyše sa každá prezretá dlaždica ukladá automaticky.\n• V nočnom režime sa mapa automaticky prepne na tmavé dlaždice\n• Ikona kotvy = miesto kotvenia (len keď je kotva aktívna)\n• Ikona importu – načíta trasy a waypointy z .gpx súboru (pozri sekciu \"Import GPX\")\n• Zámok severu – podrž ružicu kompasu vľavo hore; mapa sa prestane otáčať a ostane na sever. Ťuknutím ju kedykoľvek vrátiš na sever.\n• Zvolené vrstvy (satelit, seamarky, hĺbky, prístavy), sledovanie GPS aj zámok severu sa pamätajú medzi spusteniami\n• Podrž prst na mape = pridaj waypoint (navigačný cieľ); ťuknutím na existujúci waypoint ho premenuješ alebo zmažeš'**
  String get guideMapBody;

  /// No description provided for @guideInstrTitle.
  ///
  /// In sk, this message translates to:
  /// **'Námorné prístroje'**
  String get guideInstrTitle;

  /// No description provided for @guideInstrBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Prístroje zobrazuje navigačné dáta v reálnom čase.\n\n• SOG – rýchlosť nad dnom (uzly)\n• TWS – skutočná rýchlosť vetra\n• TWA – smer vetra voči lodi (zelená = pravobok, červená = ľavobok)\n• DEPTH – hĺbka vody (červené = menej ako 5 m)\n• VMG WP – rýchlosť k vybranému waypointu; po výbere z dlaždice uvidíš vzdialenosť/smer aj šípku priamo na smerovej ružici. Navigáciu vypneš voľbou \"Žiadny cieľ\" v tej istej dlaždici — vypne ju aj zmazanie waypointu na mape\n• AUTOPILOT – ukazuje ZAP/VYP aj režim riadenia, keď to prístroje hlásia (HTC/HTD, APB alebo SeaTalk). Každé prepnutie sa automaticky zapíše do denníka, ako v palubnom denníku lietadla.\n\nZdroj dát: telefónne GPS alebo Raymarine (TCP aj UDP WiFi gateway).\nNastavenia pripojenia (vrátane voľby TCP/UDP) nájdeš v Nastavenia → Prístroje.\n\nAko sa loď pripája: appka číta NMEA dáta cez WiFi (TCP alebo UDP). Samotný WiFi hotspot Raymarine MFD zvyčajne nestačí — slúži pre appky Raymarine a surové NMEA tretím stranám väčšinou nepúšťa. Potrebuješ NMEA→WiFi gateway (napr. Digital Yacht, Yacht Devices, Actisense, Quark-elec) pripojený na lodnú zbernicu, ktorý buď vytvorí vlastný hotspot, alebo broadcastuje NMEA do WiFi. Telefón pripoj na WiFi tohto gateway a v Nastaveniach zadaj jeho IP a port (alebo skús Automaticky nájsť).\n\nB&G Zeus a podobné Navico plottery: pripoj telefón na WiFi plotra a v Nastaveniach zvoľ TCP. Adresa plotra vo WiFi sieti ale NEFUNGUJE — server NMEA beží na jeho ethernetovom rozhraní. Tú adresu nájdeš priamo v plotri: Settings → Network → Diagnostics, položka IP address (býva v tvare 169.254.x.x). Zadaj ju spolu s portom 10110. Overené na Zeus III so softvérom NOS v25.2. Port 2053 spojenie prijme, ale dáta neposiela — to je služba GoFree s vlastným protokolom, nie NMEA. Zapni si Automaticky pripojiť pri spustení. Ak to raz prestane fungovať, adresa sa mohla zmeniť — prečítaj ju znova v Diagnostics.'**
  String get guideInstrBody;

  /// No description provided for @guideLogbookTitle.
  ///
  /// In sk, this message translates to:
  /// **'Denník plavby'**
  String get guideLogbookTitle;

  /// No description provided for @guideLogbookBody.
  ///
  /// In sk, this message translates to:
  /// **'Denník je hlavná záložka pre správu pláv.\n\n• Veľké tlačidlo \"Spustiť plavbu\" hore spustí tracking – opýta sa len na frekvenciu automatických zápisov (dá sa zmeniť pri každom ďalšom spustení), žiadny formulár netreba vyplniť vopred\n• Ak existuje rozostavaná plavba, appka sa opýta, či pokračovať v nej alebo založiť nový záznam\n• Chýbajúce údaje (check-in, safety briefing, karta lode/posádky) appka pripomenie farebnými chipmi priamo na karte plavby – ťuknutím na chip ich doplníš\n• Každý deň plavby sa zobrazuje zvlášť\n• Záznamy možno pridávať ručne počas dňa, vrátane motohodín, paliva a vody v sekcii \"Motor a nádrže\"\n• Počas trackingu sa objaví tlačidlo fotoaparátu (vľavo dole) – odfoť zaujímavý bod a rýchlo ho ulož ako záznam s polohou a časom\n• Denník možno exportovať do PDF cez menu dňa\n• Ikona podania rúk v detaile plavby otvorí odovzdávací protokol (check-in/check-out)\n• Podrobný formulár plavby (ikona lode v detaile) eviduje loď a jej parametre, oblasť plavby, posádku s preukazmi skippera aj fotky lode (max 3, prenášajú sa do PDF)\n• Nevyplnené karty (Safety Briefing, check-in/out, karta lode) blikajú červeno v hornej lište detailu plavby, kým ich nedokončíš\n• Ak sa appka počas plavby vypne bez ukončenia trasovania (systém ju zavrie, nechcený swipe), pri ďalšom spustení ponúkne pokračovanie v tej istej plavbe – vrátane dopočítania vzdialenosti prejdenej, kým appka nebežala\n• Pri prvom spustení plavby appka pripomenie nastavenie batérie – bez neho vie systém (najmä Honor/Huawei) trasovanie na pozadí vypnúť\n• Ikona trasy v hlavičke plavby (vedľa SB, protokolu a karty lode) zobrazí trasu celej plavby na mape\n• Po plavbe vieš pre každého člena posádky vyexportovať potvrdenie o naplávaných míľach – dni na mori, denné a nočné míle, oblasť plavby, hodnotenie zručností od skipera a QR na overenie pravosti\n• Spôsob plavby (motor/plachty) sa preberá aj do automatických zápisov – prepneš ho raz a ďalšie zápisy v ňom pokračujú, kým ho nezmeníš\n• Potvrdenie je dvojjazyčné (tvoj jazyk + angličtina), obsahuje rozmery a registráciu lode, typ vôd (prílivové/neprílivové) a kolonku na číslo pasu alebo OP; dá sa zdieľať aj uložiť priamo do telefónu\n• Kurz voči vetru – silueta lode z papierového denníka: ťukni na polohu na tom boku, z ktorého fúka (ľavobok červený, pravobok zelený). Zadný vietor je dole, tam sa bok nerozlišuje. Opätovné ťuknutie výber zruší – odhadnutý údaj je horší ako prázdne políčko. Do PDF ide vedľa spôsobu plavby.\n• Počas plavby je vľavo dole druhé rýchle tlačidlo (ikona plachetnice) na obrat alebo halzu: vyber nový kurz na siluete a záznam sa zapíše aj s polohou a časom. Ďalšie automatické zápisy ten kurz preberajú, kým ho znova nezmeníš.\n• Hĺbka zo sondy sa ukladá k automatickým záznamom a v ručnom zázname je predvyplnená (treba pripojené prístroje).\n• Motohodiny sa rátajú z otáčok z prístrojov a naštartovanie aj zastavenie motora sa zapíše do denníka samo.\n• Rýchle tlačidlo plachetnice (vľavo dole počas plavby) teraz zapisuje aj pohon — Motor / Hlavná / Genova / Reef. Ďalšie automatické záznamy ho preberajú, kým ho nezmeníš, takže stĺpec Pohon v PDF už neostáva prázdny.\n• Appka si sama zapíše zmenu kurzu: keď sa smer odkloní o 30° a viac a v novom smere vydrží aspoň minútu. Kľučkovanie na vlne ani zákmit GPS to nespustí.\n• Automatické záznamy majú aj stav oblohy — dopĺňa sa z modelu k času a polohe záznamu, rovnako ako vietor a tlak.\n• Nočná plavba sa počíta sama: podľa skutočného západu a východu slnka pre polohu, kde loď bola. Záznam po zotmení má mesiačik, deň aj celá plavba majú súčet nočných hodín v denníku aj v PDF.\n• Novú plavbu založíš tlačidlom **Nová plavba** v Denníku — vyplníš loď, oblasť a posádku ešte pred vyplávaním a trasovanie potom na túto plavbu nadviae. Spústiť plavbu rovno tlačidlom Štart sa dá naďalej; vtedy sa záznam založí sám a údaje doplníš neskôr cez farebné chipy.'**
  String get guideLogbookBody;

  /// No description provided for @guideMilesTitle.
  ///
  /// In sk, this message translates to:
  /// **'Kniha míľ'**
  String get guideMilesTitle;

  /// No description provided for @guideMilesBody.
  ///
  /// In sk, this message translates to:
  /// **'Súhrn všetkých plavieb na jednom mieste (ikona v Denníku plavby).\n\n• Celkové námorné míle, dni na mori, počet plavieb a nočné hodiny\n• Rozpad podľa roka a podľa lode\n• Filter podľa roka\n• Klikni na plavbu (aj trackovanú/importovanú) a doplň záznam Knihy míľ – trasu, vlajku lode, meno a kvalifikáciu skippera, podpis potvrdzujúci míle\n• Tlačidlo + – pridaj historickú plavbu spred používania appky (počíta sa plne do súhrnov, v zozname označená hviezdičkou)\n• Export PDF potvrdenia o najazdených míľach s miestom na podpis'**
  String get guideMilesBody;

  /// No description provided for @guideHandoverTitle.
  ///
  /// In sk, this message translates to:
  /// **'Odovzdávací protokol (check-in/check-out)'**
  String get guideHandoverTitle;

  /// No description provided for @guideHandoverBody.
  ///
  /// In sk, this message translates to:
  /// **'Formálny záznam o prevzatí a vrátení lode pri chartri – ikona podania rúk v detaile plavby.\n\n• Kontrolný zoznam výbavy (plachty, lanovie, kotva, navigácia, vesty, raft, lekárnička, dinghy, svetlá, bimini...) – OK / poškodené / chýba, s poznámkou, polohou na lodi a fotkou\n• Stav paliva, vody a motohodín\n• Podpis skippera aj zástupcu charterovej spoločnosti\n• Protokol sa uzavrie (len na čítanie) až keď podpíšu obaja\n• Check-out si predvyplní údaje z check-in protokolu a zvýrazní nové poškodenia\n• Export PDF s oboma podpismi vedľa seba'**
  String get guideHandoverBody;

  /// No description provided for @guideGpxImportTitle.
  ///
  /// In sk, this message translates to:
  /// **'Import GPX'**
  String get guideGpxImportTitle;

  /// No description provided for @guideGpxImportBody.
  ///
  /// In sk, this message translates to:
  /// **'Importuj trasy a waypointy z iných navigačných aplikácií alebo GPS zariadení (ikona na Mape).\n\n• Vyber .gpx súbor zo zariadenia\n• Viacdňový export (viac trackov v jednom súbore, napr. z Garmin Explore) sa automaticky spojí do jednej plavby s dňom pre každý kalendárny deň\n• Nájdené tracky vieš aj ručne priradiť k existujúcej plavbe\n• Waypointy (aj z trás/routes) sa pridajú rovno na mapu\n• Pri poškodenom súbore appka zobrazí zrozumiteľnú chybovú hlášku'**
  String get guideGpxImportBody;

  /// No description provided for @guideWeatherTitle.
  ///
  /// In sk, this message translates to:
  /// **'Počasie'**
  String get guideWeatherTitle;

  /// No description provided for @guideWeatherBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Počasie zobrazuje predpoveď podľa aktuálnej polohy.\n\n• Aktualizuje sa automaticky pri zmene polohy\n• Hoře ostávajú ÚRADNÉ VÝSTRAHY (MeteoAlarm), ak pre tvoju krajinu nejaké platia. Nevydáva ich model, ale národná meteorologická služba — v Chorvátsku DHMZ, v Británii Met Office, vo Švédsku SMHI. Rozbalením uvidíš popis a pokyn; keď text v tvojom jazyku nie je, appka povie, v akom jazyku ho čítaš.\n• Predpoveď berie NÁRODNÝ MODEL podľa toho, kde si — Jadran a Taliansko ARPAE ICON-2I, Británia UKMO, Škandinávia MET Norway, stredná Európa ICON-D2, inde ECMWF. Názov modelu je vidno pod aktuálnym počasím.\n• Karta Stanice – namerané ukazuje, čo naozaj niekto nameral, aj so vzdialenosťou a časom merania. Model a meranie sa vedia líšiť aj o polovicu a vidieť oboje vedľa seba je jediný spôsob, ako to zistiš.\n• Bez signálu sa zobrazí posledná uložená predpoveď a **vždy aj to, kedy sa stiahla**. Predpoveď staršia než šesť hodín sa označí oranžovo.\n\nSlnko, mesiac a prílivy:\n• Východ, západ slnka a fáza mesiaca sa počítajú priamo v zariadení — internet netreba\n• Ťuknutím na obnoviť v karte Príliv/odliv stiahneš 7-dňovú predpoveď (zadarmo, bez API kľúča)\n• Prílivy sa kešujú, takže zostanú čitateľné aj offline; karta ťa upozorní, keď je predpoveď stará alebo stiahnutá ďaleko odtiaľto\n• ⚠ Výšky prílivu sú nad strednou hladinou mora, nie nad mapovým datom — nikdy ich nepoužívaj na výpočet hĺbky pod kýlom\n\nMorský prúd:\n• Karta Morský prúd ukazuje reálnu predpoveď pre tvoju polohu v uzloch a smer, KAM prúd tečie\n• Nezamieňaj s vrstvou Oceánske prúdy — tá je referenčná mapa veľkých globálnych prúdov'**
  String get guideWeatherBody;

  /// No description provided for @guideSafetyMobTitle.
  ///
  /// In sk, this message translates to:
  /// **'MOB a kotva'**
  String get guideSafetyMobTitle;

  /// No description provided for @guideSafetyMobBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Bezpečnosť obsahuje núdzové funkcie.\n\nMOB (Človek cez palubu):\n• Podržte červené tlačidlo MOB pre aktiváciu\n• Aplikácia zaznamená GPS polohu a meria čas a vzdialenosť\n• Navigácia späť k miestu pádu\n\nKotva:\n• Nastav polomer kotvenia (odporúčané: 2× dĺžka kotevného lana)\n• Alarm zavibruje, ak sa loď vzdiali z povoleného okruhu\n• Kotvová stráž si zapisuje vlastnú trasu, takže noč na kotve už nie je v GPX diera. Je to samostatný úsek — do najazdených míľ, vzdialenosti dňa ani nočných hodín sa nepočíta, hojdanie na reťazi nie je plavba.\n• Stráž prežije aj reštart appky: keď ju systém na pozadí zabije, po spustení sa sama rozbehne ďalej na tej istej kotve.\n• Záznam o spustení a vytiahnutí kotvy už nesú aj vietor, tlak, teploty, hĺbku pod kýľom a pohon — dovtedy v ňom bol len čas a poloha.'**
  String get guideSafetyMobBody;

  /// No description provided for @guideSafetyBriefingTitle.
  ///
  /// In sk, this message translates to:
  /// **'Bezpečnostný brífing a MAYDAY'**
  String get guideSafetyBriefingTitle;

  /// No description provided for @guideSafetyBriefingBody.
  ///
  /// In sk, this message translates to:
  /// **'V Bezpečnosti nájdeš aj záložky s referenčnými kartami.\n\n• Bezpečnostný brífing – checklist pre posádku pred plavbou\n• Každý člen posádky podpíše vlastným podpisom na obrazovke\n• Podpisy sa uložia a automaticky sa zahrnú do PDF exportu plavby\n• Odovzdávací checklist – prehľad položiek na prevzatie/vrátenie lode, dostupný aj bez otvorenej plavby\n• MAYDAY karta – postup pre tiesňové volanie na VHF kanál 16\n• COLREG – pravidlá predchádzania zrážkam na mori (dostupné po slovensky a anglicky; ostatné jazyky zobrazia anglický text)\n• Kontakty – núdzové čísla a kontakty\n\nPozn.: Tracking sa dá spustiť kedykoľvek, aj bez vyplneného briefingu – appka to len pripomenie chipom \"Chýba SB\" v Denníku, kým ho nedokončíš. Briefing vyžaduje najprv vyplnenú kartu lode a posádky a uloží sa až s podpismi všetkých členov.\n• Núdzové kontakty sa vyberajú podľa aktuálnej polohy aj bez zapnutého trasovania – appka si polohu vypýta sama a pri prechode do inej krajiny čísla vymení'**
  String get guideSafetyBriefingBody;

  /// No description provided for @guideDutyTitle.
  ///
  /// In sk, this message translates to:
  /// **'Služba posádky'**
  String get guideDutyTitle;

  /// No description provided for @guideDutyBody.
  ///
  /// In sk, this message translates to:
  /// **'Záznam o tom, kto mal kedy službu — v Bezpečnosti, nad kotvou.\n\n• Nastúpiť do služby — vyber jedného alebo viacerých ľudí naraz; každý sa potom ukončuje samostatne\n• Mená sa berú z posádky plavby. Ak posádka nie je vyplnená, tlačidlo ťa pošle do karty plavby\n• Čas nástupu sa dá opraviť, ak si tlačidlo stlačil neskôr\n• Zobraziť pre kontrolu — celoobrazovková karta pre kontrolu na palube: kto slúži, od kedy, čas lokálne aj UTC. Nedá sa z nej nič meniť\n• Rozpis služieb — doplnenie služby spätne aj úprava. Ak nevyplníš čas „do\", služba beží ďalej\n• Nočná služba cez polnoc je jeden záznam, nie dva. V PDF sa objaví na oboch dňoch, označená šípkou\n• Nástup aj ukončenie sa zapíšu do denníka a do PDF exportu\n\nPozn.: appka službu nikdy neukončí sama. Po 12 hodinách len upozorní — koniec, ktorý si nevidel, by bol vymyslený údaj.'**
  String get guideDutyBody;

  /// No description provided for @guideCompassTitle.
  ///
  /// In sk, this message translates to:
  /// **'Námerový kompas'**
  String get guideCompassTitle;

  /// No description provided for @guideCompassBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Kompas zobrazuje magnetický azimut pomocou senzorov telefónu, s výhľadom zadnej kamery ako pozadím pre zameranie objektov.\n\n• Žltý kríž – smer, na ktorý mierite\n• Kompasová lišta hore – N / NE / E / SE / S / SW / W / NW\n• Číselné zobrazenie – stupne a svetová strana\n• Zelená bodka = stabilné čítanie  ·  Oranžová bodka = kalibruje\n\nAk je čítanie nestabilné, pomaly pohybuj telefónom do tvaru osmičky pre kalibráciu magnetometra.\n\nPozor: presnosť môže byť znížená v blízkosti kovových konštrukcií, reproduktorov alebo elektroniky.\n\nKompas rieši dve odlišné úlohy — nájsť SEBA, keď nevieš, kde si, alebo nájsť NEZNÁMY BOD, keď chceš na mapu zaznačiť niečo, čo tam ešte nie je. Prepínač nad tlačidlom Zameraj vyberá, ktorú z nich práve robíš.\n\nMOJA POLOHA — nájdi seba (GPS netreba)\n\n1. Over si na mape, že poznáš aspoň dva viditeľné body (maják, vrchol, kostol) ako waypointy. Chýbajúci bod pridáš dlhým podržaním na mape presne na jeho mieste.\n2. Na kompase prepni na \"Moja poloha\".\n3. Ťukni na štítok pod prepínačom a vyber prvý zameriavaný bod.\n4. Namier kríž presne naň a stlač Zameraj.\n5. V dialógu skontroluj nameraný kurz a stlač Uložiť (Zrušiť návrh zahodí bez zápisu).\n6. Vyber druhý, INÝ bod (výber sa po uložení sám vyprázdni) a zopakuj.\n7. Na mape uvidíš dve čiarkované čiary od bodov k tebe. Ich priesečník je tvoja poloha — zelený krížik znamená dobrý rez, oranžový ostrý uhol a neistú polohu.\n8. Tretí bod, ideálne pod iným uhlom, spresní odhad a ukáže trojuholník chyby.\n\nRob to rýchlo za sebou, do 5 minút — resekcia predpokladá, že loď medzi zameraniami stojí.\n\nNEZNÁMY BOD — nájdi objekt (GPS treba)\n\n1. Prepni na \"Neznámy bod\".\n2. Ťukni na štítok, zvoľ \"Nový bod…\" a pomenuj, čo zameriavaš, napríklad \"neznáma skala\".\n3. Namier, Zameraj, potvrď Uložiť.\n4. Presuň loď aspoň o pár sto metrov — čím ďalej, tým istejší výsledok.\n5. Znova otvor výber cieľa, vyber ten istý objekt zo zoznamu (nie \"Nový bod\") a zameraj druhýkrát.\n6. Na mape sa objaví značka s vypočítanou polohou objektu. Ťuknutím ju uložíš ako waypoint — a od tej chvíle sa dá použiť aj na resekciu.\n\nPresnosť\n\nTelefónový kompas má reálnu chybu okolo ±8°, čo je na 10 míľach vzdialenosti vyše 2,5 míle do strany — presne preto sa kreslí kužeľ neistoty, nie tenká čiara. Najlepší rez dávajú body pod uhlom blízko 90°; keď ležia takmer v jednej línii s tebou, priesečník sa rozmaže na stovky metrov až kilometre.\n\nZamerania bez plavby\n\nZameranie sa uloží aj bez zapnutého trackingu — na kotve, na brehu. Nájdeš ho v zozname plavieb ako samostatný riadok s dátumom, medzi jednotlivými plavbami. Otvorením zobrazíš zamerania toho dňa aj s mapkou a odtiaľ spustíš export jednoduchého PDF s mapkou a tabuľkou zameraní.\n\nČistenie mapy a mazanie zameraní\n\nZameriavanie na čistú mapu – na Kompase ikona obnovenia vpravo hore. Odloží doterajšie zamerania z mapy a zruší vybraný bod či objekt, takže ďalšie Zameraj začína načisto. Nič sa nestráca: záznamy zostávajú v karte Lodný denník aj v PDF exporte.\n\nZmazanie natrvalo – otvor riadok s dátumom v zozname plavieb. Krížik pri riadku zmaže jedno zameranie (pri objekte celú sadu zameraní naň). Kôš v hornej lište zmaže celý deň naraz a vráti ťa späť do zoznamu. Mazanie je nevratné a tie zamerania zmiznú aj z PDF exportu.\n\nSkrátene: čistenie upratuje mapu, mazanie odstraňuje záznam. Obsah PDF mení jedine mazanie.'**
  String get guideCompassBody;

  /// No description provided for @guideSettingsTitle.
  ///
  /// In sk, this message translates to:
  /// **'Nastavenia'**
  String get guideSettingsTitle;

  /// No description provided for @guideSettingsBody.
  ///
  /// In sk, this message translates to:
  /// **'• Jazyk – zmeň jazyk aplikácie\n• Prístroje – nastav IP adresu Raymarine WiFi gateway (TCP alebo UDP)\n• GPS zdroj – telefón alebo Raymarine\n• Jednotky – vzdialenosť NM/km, rýchlosť uzly/km/h, teplota, hĺbka a vietor zvlášť (na rieke sa hodí km + km/h)\n• Frekvencia zápisov do denníka\n• Spodné menu – prispôsob si ho: podrž a potiahni ikonu pre zmenu poradia, prepínačom skry karty ktoré nepoužívaš, a nastav veľkosť ikon (S/M/L). Skryté karty otvoríš priamo tu v Nastaveniach; Nastavenia sú vždy zobrazené. Poradie aj veľkosť sa pamätajú. Popisky pod ikonami sú skryté, aby ikony sedeli rovnako vo všetkých jazykoch; podržaním ikony sa názov zobrazí.\n• Zobrazenie – nočný režim (červený filter pre zachovanie nočného videnia)\n• Cloud export (Google Drive) – po prihlásení Google účtu sa PDF a GPX z ukončeného dňa automaticky nahrajú na tvoj vlastný Google Drive. Bez prihlásenia zostáva všetko len v zariadení.\n• Záloha dát – pozri sekciu \"Záloha a obnova dát\"\n• O aplikácii – verzia a kontakt\n• Batéria – GPS beží na plnú presnosť len tam, kde na presnej polohe záleží (sledovanie plavby, mapa, kompas, prístroje, kotvová stráž, MOB); inde prepne do úsporného režimu a na pozadí bez zapnutého sledovania sa vypne úplne. Pri pripojených lodných prístrojoch ostáva GPS telefónu vypnuté a poloha ide z NMEA.\n• Aktualizácie – keď je na Google Play novšia verzia, appka ju stiahne na pozadí a ponúkne reštart. Počas záznamu plavby sa nepýta nikdy.\n• Časové pásmo – čas na obrazovke aj v PDF sa zobrazuje buď miestne (pásmo telefónu, teda oblasti, kde práve si), alebo v UTC. Uložené záznamy sa tým nemenia, prepína sa len zobrazenie; PDF vždy uvedie, ktoré pásmo platí.\n\nGoogle konto a cloudový export\n\nPrihlásenie Google konta je dobrovoľné. Bez neho appka funguje celá a všetky záznamy zostávajú iba v telefóne.\n\nČo sa nahráva – po ukončení dňa plavby PDF denníka a GPX trasa toho dňa. Nič iné: žiadne fotky, žiadne kontakty posádky, žiadne polohy v reálnom čase.\n\nKam – na tvoj vlastný Google Disk, do priečinka HMB_Sailing_Log_DATA / názov plavby / Day_dátum. Nie na server appky – ten neexistuje.\n\nČo appka na Disku vidí – iba súbory, ktoré tam sama vytvorila. Používa najužšie oprávnenie, aké Google ponúka (drive.file), takže k ostatnému obsahu tvojho Disku sa nedostane. Oprávnenie si navyše pýta až pri prvom nahrávaní, nie pri prihlásení.\n\nAko to zrušíš – odhlás konto v Nastaveniach. Súbory, ktoré už na Disku sú, zostanú tvoje – appka ich nemaže. Prístup sa dá kedykoľvek odobrať aj v nastaveniach Google konta.'**
  String get guideSettingsBody;

  /// No description provided for @guideBackupTitle.
  ///
  /// In sk, this message translates to:
  /// **'Záloha a obnova dát'**
  String get guideBackupTitle;

  /// No description provided for @guideBackupBody.
  ///
  /// In sk, this message translates to:
  /// **'V Nastavenia → Záloha dát.\n\n• Exportovať zálohu – uloží celý denník (plavby, záznamy, nastavenia) do jedného súboru (.hmbbackup), ktorý môžeš zdieľať emailom, do cloudu alebo si ho uložiť lokálne\n• Obnoviť zo zálohy – nahradí aktuálne dáta obsahom vybranej zálohy; pred prepísaním sa automaticky vytvorí bezpečnostná záloha súčasného stavu\n• Obnova je zablokovaná počas aktívneho GPS trackingu plavby\n• Zálohu s novšou schémou, než akú appka podporuje, appka odmietne s vysvetlením'**
  String get guideBackupBody;

  /// No description provided for @guideExportTitle.
  ///
  /// In sk, this message translates to:
  /// **'Export denníka'**
  String get guideExportTitle;

  /// No description provided for @guideExportBody.
  ///
  /// In sk, this message translates to:
  /// **'Denník možno exportovať ako profesionálny PDF dokument.\n\n1. Otvor Denník → vyber plavbu\n2. Klepni na ikonu exportu alebo tri bodky → Export PDF\n3. Podpíš ako skipér → vygeneruje sa PDF\n4. PDF obsahuje: trasu, záznamy, fotky, safety brífing s podpismi posádky; titulná strana má v hlavičke fotku lode z karty lode (ak je nahratá)\n5. Zdieľaj cez email, tlač alebo ulož do telefónu\n\nKaždý PDF dostane jedinečné ID dokumentu (napr. HMBSL-5-2026) a číslo revízie (Rev. 1, Rev. 2...) viditeľné v pätičke každej strany. Pri každom novom exporte sa číslo automaticky zvýši – je tak viditeľné, koľkokrát bol dokument vygenerovaný.\n\nQR kód na podpisovej strane obsahuje ID, revíziu a kryptografický odtlačok obsahu. Akákoľvek zmena dát zmení QR kód.\n\nPDF sa vytvorí v jazyku, ktorý má appka nastavený, vrátane mien a diakritiky. Na dennej strane je aj prehľad služby posádky.\n• Ak sa trasovanie počas dňa prerušilo a znova spustilo, každý úsek dostane vlastný GPX súbor\n• Vzdialenosti, rýchlosti a teploty v PDF sa riadia jednotkami z Nastavení'**
  String get guideExportBody;

  /// No description provided for @safetyBriefingScreenTitle.
  ///
  /// In sk, this message translates to:
  /// **'Safety Briefing'**
  String get safetyBriefingScreenTitle;

  /// No description provided for @briefingCrewSignaturesSection.
  ///
  /// In sk, this message translates to:
  /// **'Podpisy posádky'**
  String get briefingCrewSignaturesSection;

  /// No description provided for @briefingSignHere.
  ///
  /// In sk, this message translates to:
  /// **'Podpísať tu'**
  String get briefingSignHere;

  /// No description provided for @briefingClear.
  ///
  /// In sk, this message translates to:
  /// **'Zmazať'**
  String get briefingClear;

  /// No description provided for @briefingSigned.
  ///
  /// In sk, this message translates to:
  /// **'Podpísané'**
  String get briefingSigned;

  /// No description provided for @briefingSave.
  ///
  /// In sk, this message translates to:
  /// **'Uložiť podpisy'**
  String get briefingSave;

  /// No description provided for @briefingSavedOk.
  ///
  /// In sk, this message translates to:
  /// **'Podpisy uložené'**
  String get briefingSavedOk;

  /// No description provided for @briefingOpenBriefing.
  ///
  /// In sk, this message translates to:
  /// **'Safety Briefing'**
  String get briefingOpenBriefing;

  /// No description provided for @briefingSkipper.
  ///
  /// In sk, this message translates to:
  /// **'Skipper'**
  String get briefingSkipper;

  /// No description provided for @briefingCrew.
  ///
  /// In sk, this message translates to:
  /// **'Posádka'**
  String get briefingCrew;

  /// No description provided for @briefingNoCrew.
  ///
  /// In sk, this message translates to:
  /// **'Posádka nie je zadaná. Pridaj členov v nastaveniach plavby.'**
  String get briefingNoCrew;

  /// No description provided for @briefingDate.
  ///
  /// In sk, this message translates to:
  /// **'Dátum'**
  String get briefingDate;

  /// No description provided for @briefingLocation.
  ///
  /// In sk, this message translates to:
  /// **'Miesto'**
  String get briefingLocation;

  /// No description provided for @briefingDoneLabel.
  ///
  /// In sk, this message translates to:
  /// **'Safety Briefing dokončený'**
  String get briefingDoneLabel;

  /// No description provided for @briefingDoneSubtitle.
  ///
  /// In sk, this message translates to:
  /// **'Podpisy posádky sú uložené. Nie je potrebné opakovať.'**
  String get briefingDoneSubtitle;

  /// No description provided for @briefingEditSignature.
  ///
  /// In sk, this message translates to:
  /// **'Zmeniť podpis'**
  String get briefingEditSignature;

  /// No description provided for @briefingRequiredTitle.
  ///
  /// In sk, this message translates to:
  /// **'Vyžaduje sa Safety Briefing'**
  String get briefingRequiredTitle;

  /// No description provided for @briefingRequiredBody.
  ///
  /// In sk, this message translates to:
  /// **'Pred prvým spustením trackingu je potrebné dokončiť Safety Briefing a zozbierať podpisy posádky.'**
  String get briefingRequiredBody;

  /// No description provided for @goToBriefing.
  ///
  /// In sk, this message translates to:
  /// **'Prejsť na Briefing'**
  String get goToBriefing;

  /// No description provided for @skipperProfile.
  ///
  /// In sk, this message translates to:
  /// **'Profil skippera'**
  String get skipperProfile;

  /// No description provided for @skipperProfileHint.
  ///
  /// In sk, this message translates to:
  /// **'Tieto údaje sa zobrazia v PDF exporte plavby.'**
  String get skipperProfileHint;

  /// No description provided for @skipperFullName.
  ///
  /// In sk, this message translates to:
  /// **'Meno skippera'**
  String get skipperFullName;

  /// No description provided for @skipperLicenseSection.
  ///
  /// In sk, this message translates to:
  /// **'Skipperská licencia'**
  String get skipperLicenseSection;

  /// No description provided for @skipperLicenseType.
  ///
  /// In sk, this message translates to:
  /// **'Typ licencie'**
  String get skipperLicenseType;

  /// No description provided for @skipperLicenseNumber.
  ///
  /// In sk, this message translates to:
  /// **'Číslo licencie'**
  String get skipperLicenseNumber;

  /// No description provided for @skipperLicenseAuthority.
  ///
  /// In sk, this message translates to:
  /// **'Vydavateľ'**
  String get skipperLicenseAuthority;

  /// No description provided for @skipperLicenseExpiry.
  ///
  /// In sk, this message translates to:
  /// **'Platnosť do'**
  String get skipperLicenseExpiry;

  /// No description provided for @skipperVhfSection.
  ///
  /// In sk, this message translates to:
  /// **'VHF / SRC licencia'**
  String get skipperVhfSection;

  /// No description provided for @skipperVhfNumber.
  ///
  /// In sk, this message translates to:
  /// **'Číslo VHF/SRC'**
  String get skipperVhfNumber;

  /// No description provided for @skipperVhfExpiry.
  ///
  /// In sk, this message translates to:
  /// **'Platnosť VHF'**
  String get skipperVhfExpiry;

  /// No description provided for @skipperOtherCerts.
  ///
  /// In sk, this message translates to:
  /// **'Ostatné certifikáty / licencie'**
  String get skipperOtherCerts;

  /// No description provided for @skipperOtherCertsHint.
  ///
  /// In sk, this message translates to:
  /// **'napr. Yachtmaster, RYA, STCW, záchranárske kurzy...'**
  String get skipperOtherCertsHint;

  /// No description provided for @continueLastVoyageTitle.
  ///
  /// In sk, this message translates to:
  /// **'Pokračovať v poslednej plavbe?'**
  String get continueLastVoyageTitle;

  /// No description provided for @continueVoyageAction.
  ///
  /// In sk, this message translates to:
  /// **'Pokračovať'**
  String get continueVoyageAction;

  /// No description provided for @newRecordAction.
  ///
  /// In sk, this message translates to:
  /// **'Nový záznam'**
  String get newRecordAction;

  /// No description provided for @missingCheckInChip.
  ///
  /// In sk, this message translates to:
  /// **'Chýba Check-in'**
  String get missingCheckInChip;

  /// No description provided for @missingBriefingChip.
  ///
  /// In sk, this message translates to:
  /// **'Chýba SB'**
  String get missingBriefingChip;

  /// No description provided for @missingDetailsChip.
  ///
  /// In sk, this message translates to:
  /// **'Chýba karta lode/posádky'**
  String get missingDetailsChip;

  /// No description provided for @missingCheckOutChip.
  ///
  /// In sk, this message translates to:
  /// **'Chýba Check-out'**
  String get missingCheckOutChip;

  /// No description provided for @vesselModel.
  ///
  /// In sk, this message translates to:
  /// **'Model'**
  String get vesselModel;

  /// No description provided for @vesselTypeMonohull.
  ///
  /// In sk, this message translates to:
  /// **'Jednotrupové'**
  String get vesselTypeMonohull;

  /// No description provided for @vesselTypeCatamaran.
  ///
  /// In sk, this message translates to:
  /// **'Katamarán'**
  String get vesselTypeCatamaran;

  /// No description provided for @vesselTypeTrimaran.
  ///
  /// In sk, this message translates to:
  /// **'Trimaran'**
  String get vesselTypeTrimaran;

  /// No description provided for @vesselTypeMotorYacht.
  ///
  /// In sk, this message translates to:
  /// **'Motorová jachta'**
  String get vesselTypeMotorYacht;

  /// No description provided for @vesselTypeGulet.
  ///
  /// In sk, this message translates to:
  /// **'Gulet'**
  String get vesselTypeGulet;

  /// No description provided for @vesselTypeDinghy.
  ///
  /// In sk, this message translates to:
  /// **'Čln'**
  String get vesselTypeDinghy;

  /// No description provided for @vesselTypeRib.
  ///
  /// In sk, this message translates to:
  /// **'RIB'**
  String get vesselTypeRib;

  /// No description provided for @vesselTypeOther.
  ///
  /// In sk, this message translates to:
  /// **'Iné'**
  String get vesselTypeOther;

  /// No description provided for @charterCompanyLabel.
  ///
  /// In sk, this message translates to:
  /// **'Charterová spoločnosť'**
  String get charterCompanyLabel;

  /// No description provided for @yachtParamsSection.
  ///
  /// In sk, this message translates to:
  /// **'Parametre jachty'**
  String get yachtParamsSection;

  /// No description provided for @berthsLabel.
  ///
  /// In sk, this message translates to:
  /// **'Lôžka'**
  String get berthsLabel;

  /// No description provided for @yearBuiltLabel.
  ///
  /// In sk, this message translates to:
  /// **'Rok výroby'**
  String get yearBuiltLabel;

  /// No description provided for @waterTankLabel.
  ///
  /// In sk, this message translates to:
  /// **'Nádrž na vodu'**
  String get waterTankLabel;

  /// No description provided for @fuelTankLabel.
  ///
  /// In sk, this message translates to:
  /// **'Palivová nádrž'**
  String get fuelTankLabel;

  /// No description provided for @engineHoursStartLabel.
  ///
  /// In sk, this message translates to:
  /// **'Motohodiny · začiatok'**
  String get engineHoursStartLabel;

  /// No description provided for @engineHoursEndLabel.
  ///
  /// In sk, this message translates to:
  /// **'Motohodiny · koniec'**
  String get engineHoursEndLabel;

  /// No description provided for @whereWhenSection.
  ///
  /// In sk, this message translates to:
  /// **'Kde & kedy'**
  String get whereWhenSection;

  /// No description provided for @countryLabel.
  ///
  /// In sk, this message translates to:
  /// **'Krajina'**
  String get countryLabel;

  /// No description provided for @cruisingAreaLabel.
  ///
  /// In sk, this message translates to:
  /// **'Oblasť plavby'**
  String get cruisingAreaLabel;

  /// No description provided for @charterContactsSection.
  ///
  /// In sk, this message translates to:
  /// **'Kontakty chartru'**
  String get charterContactsSection;

  /// No description provided for @charterContactsHint.
  ///
  /// In sk, this message translates to:
  /// **'Až 3 čísla pre hovor / WhatsApp / SMS. Vždy s medzinárodnou predvoľbou (napr. +385...).'**
  String get charterContactsHint;

  /// No description provided for @addPhoneNumber.
  ///
  /// In sk, this message translates to:
  /// **'Pridať telefónne číslo'**
  String get addPhoneNumber;

  /// No description provided for @costsSection.
  ///
  /// In sk, this message translates to:
  /// **'Náklady'**
  String get costsSection;

  /// No description provided for @charterPriceLabel.
  ///
  /// In sk, this message translates to:
  /// **'Cena plavby'**
  String get charterPriceLabel;

  /// No description provided for @currencyLabel.
  ///
  /// In sk, this message translates to:
  /// **'Mena'**
  String get currencyLabel;

  /// No description provided for @addCostItem.
  ///
  /// In sk, this message translates to:
  /// **'Pridať náklad'**
  String get addCostItem;

  /// No description provided for @costName.
  ///
  /// In sk, this message translates to:
  /// **'Názov nákladu'**
  String get costName;

  /// No description provided for @crewSectionHint.
  ///
  /// In sk, this message translates to:
  /// **'Ťuknite na odznak na nastavenie skippera — ostatní sú posádka.'**
  String get crewSectionHint;

  /// No description provided for @addCrewMember.
  ///
  /// In sk, this message translates to:
  /// **'Pridať člena posádky'**
  String get addCrewMember;

  /// No description provided for @crewNameLabel.
  ///
  /// In sk, this message translates to:
  /// **'Meno'**
  String get crewNameLabel;

  /// No description provided for @skipperBadge.
  ///
  /// In sk, this message translates to:
  /// **'SKIPPER'**
  String get skipperBadge;

  /// No description provided for @crewBadge.
  ///
  /// In sk, this message translates to:
  /// **'CREW'**
  String get crewBadge;

  /// No description provided for @vesselTypeSailboat.
  ///
  /// In sk, this message translates to:
  /// **'Plachetnica'**
  String get vesselTypeSailboat;

  /// No description provided for @vesselTypeMotorBoat.
  ///
  /// In sk, this message translates to:
  /// **'Motorový čln'**
  String get vesselTypeMotorBoat;

  /// No description provided for @sbNeedsVesselCard.
  ///
  /// In sk, this message translates to:
  /// **'Najprv vyplň kartu lode a posádky — Safety Briefing potrebuje zoznam členov posádky na podpisy.'**
  String get sbNeedsVesselCard;

  /// No description provided for @prefillSkipperTitle.
  ///
  /// In sk, this message translates to:
  /// **'Doplniť uložené údaje skippera?'**
  String get prefillSkipperTitle;

  /// No description provided for @prefillSkipperFill.
  ///
  /// In sk, this message translates to:
  /// **'Doplniť'**
  String get prefillSkipperFill;

  /// No description provided for @prefillSkipperNew.
  ///
  /// In sk, this message translates to:
  /// **'Nový skipper'**
  String get prefillSkipperNew;

  /// No description provided for @boatLicenceLabel.
  ///
  /// In sk, this message translates to:
  /// **'Č. lodného preukazu'**
  String get boatLicenceLabel;

  /// No description provided for @radioLicenceLabel.
  ///
  /// In sk, this message translates to:
  /// **'Č. rádiového preukazu'**
  String get radioLicenceLabel;

  /// No description provided for @vesselPhotosSection.
  ///
  /// In sk, this message translates to:
  /// **'Fotky plavidla (max 3)'**
  String get vesselPhotosSection;

  /// No description provided for @addPhotoLabel.
  ///
  /// In sk, this message translates to:
  /// **'Pridať'**
  String get addPhotoLabel;

  /// No description provided for @createVoyageButton.
  ///
  /// In sk, this message translates to:
  /// **'Vytvoriť plavbu'**
  String get createVoyageButton;

  /// No description provided for @saveVoyageButton.
  ///
  /// In sk, this message translates to:
  /// **'Uložiť plavbu'**
  String get saveVoyageButton;

  /// No description provided for @costBaseCharter.
  ///
  /// In sk, this message translates to:
  /// **'Základná cena plavby'**
  String get costBaseCharter;

  /// No description provided for @costDeposit.
  ///
  /// In sk, this message translates to:
  /// **'Kaucia'**
  String get costDeposit;

  /// No description provided for @costDinghyOutboard.
  ///
  /// In sk, this message translates to:
  /// **'Čln / prívesný motor'**
  String get costDinghyOutboard;

  /// No description provided for @costOutboardFuel.
  ///
  /// In sk, this message translates to:
  /// **'Palivo prívesného motora'**
  String get costOutboardFuel;

  /// No description provided for @costTransitLog.
  ///
  /// In sk, this message translates to:
  /// **'Transit log'**
  String get costTransitLog;

  /// No description provided for @costTouristTax.
  ///
  /// In sk, this message translates to:
  /// **'Pobytová daň'**
  String get costTouristTax;

  /// No description provided for @costFinalCleaning.
  ///
  /// In sk, this message translates to:
  /// **'Záverečné upratovanie'**
  String get costFinalCleaning;

  /// No description provided for @costLinenTowels.
  ///
  /// In sk, this message translates to:
  /// **'Posteľná bielizeň a uteráky'**
  String get costLinenTowels;

  /// No description provided for @costWifi.
  ///
  /// In sk, this message translates to:
  /// **'WiFi'**
  String get costWifi;

  /// No description provided for @costSupKayak.
  ///
  /// In sk, this message translates to:
  /// **'SUP / kajak'**
  String get costSupKayak;

  /// No description provided for @costSkipperFee.
  ///
  /// In sk, this message translates to:
  /// **'Poplatok za skippera'**
  String get costSkipperFee;

  /// No description provided for @costHostessFee.
  ///
  /// In sk, this message translates to:
  /// **'Poplatok za hostesku'**
  String get costHostessFee;

  /// No description provided for @locationQualityPrecise.
  ///
  /// In sk, this message translates to:
  /// **'GPS ±{m} m'**
  String locationQualityPrecise(int m);

  /// No description provided for @locationQualityApproximate.
  ///
  /// In sk, this message translates to:
  /// **'⚠️ Približná poloha · ±{m} m · sieťová lokalizácia'**
  String locationQualityApproximate(int m);

  /// No description provided for @locationQualityCached.
  ///
  /// In sk, this message translates to:
  /// **'⚠️ Posledná známa poloha · pred {mins} min'**
  String locationQualityCached(int mins);

  /// No description provided for @locationQualityUnknown.
  ///
  /// In sk, this message translates to:
  /// **'Presnosť neznáma'**
  String get locationQualityUnknown;

  /// No description provided for @locationQualityMocked.
  ///
  /// In sk, this message translates to:
  /// **'⚠️ Zistená falošná poloha'**
  String get locationQualityMocked;

  /// No description provided for @syncQueueTitle.
  ///
  /// In sk, this message translates to:
  /// **'Fronta synchronizácie'**
  String get syncQueueTitle;

  /// No description provided for @syncQueueEmpty.
  ///
  /// In sk, this message translates to:
  /// **'Fronta je prázdna'**
  String get syncQueueEmpty;

  /// No description provided for @syncNowAction.
  ///
  /// In sk, this message translates to:
  /// **'Synchronizovať teraz'**
  String get syncNowAction;

  /// No description provided for @syncRetryFailedAction.
  ///
  /// In sk, this message translates to:
  /// **'Skúsiť znova'**
  String get syncRetryFailedAction;

  /// No description provided for @syncStatusPending.
  ///
  /// In sk, this message translates to:
  /// **'Čaká'**
  String get syncStatusPending;

  /// No description provided for @syncStatusSending.
  ///
  /// In sk, this message translates to:
  /// **'Odosiela sa'**
  String get syncStatusSending;

  /// No description provided for @syncStatusSent.
  ///
  /// In sk, this message translates to:
  /// **'Odoslané'**
  String get syncStatusSent;

  /// No description provided for @syncStatusFailed.
  ///
  /// In sk, this message translates to:
  /// **'Zlyhalo'**
  String get syncStatusFailed;

  /// No description provided for @syncStatusConflict.
  ///
  /// In sk, this message translates to:
  /// **'Konflikt'**
  String get syncStatusConflict;

  /// No description provided for @syncStatusDeferred.
  ///
  /// In sk, this message translates to:
  /// **'Odložené'**
  String get syncStatusDeferred;

  /// No description provided for @syncRetryCount.
  ///
  /// In sk, this message translates to:
  /// **'Pokus {n}'**
  String syncRetryCount(int n);

  /// No description provided for @syncOffline.
  ///
  /// In sk, this message translates to:
  /// **'offline'**
  String get syncOffline;

  /// No description provided for @syncPendingCount.
  ///
  /// In sk, this message translates to:
  /// **'{n} čakajú'**
  String syncPendingCount(int n);

  /// No description provided for @syncDeferredCount.
  ///
  /// In sk, this message translates to:
  /// **'{n} odložených'**
  String syncDeferredCount(int n);

  /// No description provided for @syncFailedCount.
  ///
  /// In sk, this message translates to:
  /// **'{n} zlyhalo'**
  String syncFailedCount(int n);

  /// No description provided for @syncWifiOverrideBanner.
  ///
  /// In sk, this message translates to:
  /// **'Príloha čaká na Wi-Fi (na mori zvyčajne nedostupné).'**
  String get syncWifiOverrideBanner;

  /// No description provided for @syncWifiOverrideAction.
  ///
  /// In sk, this message translates to:
  /// **'Použiť mobilné dáta'**
  String get syncWifiOverrideAction;

  /// No description provided for @syncWifiOverrideActive.
  ///
  /// In sk, this message translates to:
  /// **'Mobilné dáta povolené pre prílohy'**
  String get syncWifiOverrideActive;

  /// No description provided for @syncClearQueueAction.
  ///
  /// In sk, this message translates to:
  /// **'Vymazať frontu'**
  String get syncClearQueueAction;

  /// No description provided for @syncClearQueueConfirmTitle.
  ///
  /// In sk, this message translates to:
  /// **'Vymazať celú frontu?'**
  String get syncClearQueueConfirmTitle;

  /// No description provided for @syncClearQueueConfirmContent.
  ///
  /// In sk, this message translates to:
  /// **'Odstráni všetky položky vo fronte synchronizácie vrátane už odoslaných. Túto akciu nemožno vrátiť.'**
  String get syncClearQueueConfirmContent;

  /// No description provided for @syncClearQueueDone.
  ///
  /// In sk, this message translates to:
  /// **'Fronta vymazaná'**
  String get syncClearQueueDone;

  /// No description provided for @syncEnableToggle.
  ///
  /// In sk, this message translates to:
  /// **'Synchronizovať denník'**
  String get syncEnableToggle;

  /// No description provided for @syncEnableToggleDesc.
  ///
  /// In sk, this message translates to:
  /// **'Odosielať záznamy na server, keď je appka otvorená a online'**
  String get syncEnableToggleDesc;

  /// No description provided for @syncTargetLabel.
  ///
  /// In sk, this message translates to:
  /// **'Cieľ synchronizácie'**
  String get syncTargetLabel;

  /// No description provided for @syncTargetHmbAcademy.
  ///
  /// In sk, this message translates to:
  /// **'HMB Sailing Academy (hmba.boats)'**
  String get syncTargetHmbAcademy;

  /// No description provided for @syncTargetCustom.
  ///
  /// In sk, this message translates to:
  /// **'Vlastný server'**
  String get syncTargetCustom;

  /// No description provided for @syncCustomUrlLabel.
  ///
  /// In sk, this message translates to:
  /// **'URL servera'**
  String get syncCustomUrlLabel;

  /// No description provided for @syncCustomTokenLabel.
  ///
  /// In sk, this message translates to:
  /// **'Token'**
  String get syncCustomTokenLabel;

  /// No description provided for @syncTestConnectionAction.
  ///
  /// In sk, this message translates to:
  /// **'Otestovať pripojenie'**
  String get syncTestConnectionAction;

  /// No description provided for @syncTestSuccess.
  ///
  /// In sk, this message translates to:
  /// **'Pripojenie funguje'**
  String get syncTestSuccess;

  /// No description provided for @syncTestFailure.
  ///
  /// In sk, this message translates to:
  /// **'Zlyhalo: {detail}'**
  String syncTestFailure(String detail);

  /// No description provided for @syncUrlErrorEmpty.
  ///
  /// In sk, this message translates to:
  /// **'Zadaj URL servera'**
  String get syncUrlErrorEmpty;

  /// No description provided for @syncUrlErrorInvalid.
  ///
  /// In sk, this message translates to:
  /// **'Neplatná URL'**
  String get syncUrlErrorInvalid;

  /// No description provided for @syncUrlErrorHttps.
  ///
  /// In sk, this message translates to:
  /// **'URL musí začínať https://'**
  String get syncUrlErrorHttps;

  /// No description provided for @syncIntervalLabel.
  ///
  /// In sk, this message translates to:
  /// **'Interval synchronizácie'**
  String get syncIntervalLabel;

  /// No description provided for @syncIntervalMinutes.
  ///
  /// In sk, this message translates to:
  /// **'{n} min'**
  String syncIntervalMinutes(int n);

  /// No description provided for @syncIntervalNote.
  ///
  /// In sk, this message translates to:
  /// **'Synchronizácia beží, kým je aplikácia otvorená'**
  String get syncIntervalNote;

  /// No description provided for @syncAttachmentPolicyLabel.
  ///
  /// In sk, this message translates to:
  /// **'Prílohy (fotky)'**
  String get syncAttachmentPolicyLabel;

  /// No description provided for @syncAttachmentNever.
  ///
  /// In sk, this message translates to:
  /// **'Nikdy'**
  String get syncAttachmentNever;

  /// No description provided for @syncAttachmentWifiOnly.
  ///
  /// In sk, this message translates to:
  /// **'Len na Wi-Fi'**
  String get syncAttachmentWifiOnly;

  /// No description provided for @syncAttachmentAlways.
  ///
  /// In sk, this message translates to:
  /// **'Vždy'**
  String get syncAttachmentAlways;

  /// No description provided for @syncBackfillAction.
  ///
  /// In sk, this message translates to:
  /// **'Doplniť staršie záznamy'**
  String get syncBackfillAction;

  /// No description provided for @syncBackfillDesc.
  ///
  /// In sk, this message translates to:
  /// **'Zaradí do fronty záznamy zapísané, kým bola synchronizácia vypnutá'**
  String get syncBackfillDesc;

  /// No description provided for @syncBackfillResult.
  ///
  /// In sk, this message translates to:
  /// **'{n} doplnených do fronty'**
  String syncBackfillResult(int n);

  /// No description provided for @syncBackfillNone.
  ///
  /// In sk, this message translates to:
  /// **'Nič na doplnenie — všetko je už vo fronte alebo odoslané'**
  String get syncBackfillNone;

  /// No description provided for @syncCloudEnableToggle.
  ///
  /// In sk, this message translates to:
  /// **'Cloud export (Google Drive)'**
  String get syncCloudEnableToggle;

  /// No description provided for @syncCloudEnableToggleDesc.
  ///
  /// In sk, this message translates to:
  /// **'Po prihlásení sa PDF a GPX z ukončeného dňa automaticky nahrajú na Google Drive. Bez prihlásenia zostáva všetko len v zariadení.'**
  String get syncCloudEnableToggleDesc;

  /// No description provided for @syncCloudSignInAction.
  ///
  /// In sk, this message translates to:
  /// **'Prihlásiť Google účet'**
  String get syncCloudSignInAction;

  /// No description provided for @syncCloudSignOutAction.
  ///
  /// In sk, this message translates to:
  /// **'Odhlásiť'**
  String get syncCloudSignOutAction;

  /// No description provided for @syncCloudSignedInAs.
  ///
  /// In sk, this message translates to:
  /// **'Prihlásený ako {email}'**
  String syncCloudSignedInAs(String email);

  /// No description provided for @syncCloudNotSignedIn.
  ///
  /// In sk, this message translates to:
  /// **'Neprihlásený'**
  String get syncCloudNotSignedIn;

  /// No description provided for @waypointNameHint.
  ///
  /// In sk, this message translates to:
  /// **'napr. Kotvisko, Prístav...'**
  String get waypointNameHint;

  /// No description provided for @waypointDefaultName.
  ///
  /// In sk, this message translates to:
  /// **'Bod {time}'**
  String waypointDefaultName(String time);

  /// No description provided for @mobFullName.
  ///
  /// In sk, this message translates to:
  /// **'Muž cez palubu'**
  String get mobFullName;

  /// No description provided for @maydayCardShort.
  ///
  /// In sk, this message translates to:
  /// **'Mayday\nkarta'**
  String get maydayCardShort;

  /// No description provided for @morseInputHint.
  ///
  /// In sk, this message translates to:
  /// **'Zadajte text...'**
  String get morseInputHint;

  /// No description provided for @morseSosTitle.
  ///
  /// In sk, this message translates to:
  /// **'SOS – TIESŇOVÝ SIGNÁL'**
  String get morseSosTitle;

  /// No description provided for @morseSosCopied.
  ///
  /// In sk, this message translates to:
  /// **'SOS skopírované'**
  String get morseSosCopied;

  /// No description provided for @intervalSeconds.
  ///
  /// In sk, this message translates to:
  /// **'{n} sek'**
  String intervalSeconds(int n);

  /// No description provided for @intervalMinutes.
  ///
  /// In sk, this message translates to:
  /// **'{n} min'**
  String intervalMinutes(int n);

  /// No description provided for @intervalHours.
  ///
  /// In sk, this message translates to:
  /// **'{n} hod'**
  String intervalHours(int n);

  /// No description provided for @aboutFeatureGps.
  ///
  /// In sk, this message translates to:
  /// **'GPS sledovanie s automatickými zápismi'**
  String get aboutFeatureGps;

  /// No description provided for @aboutFeatureLogbook.
  ///
  /// In sk, this message translates to:
  /// **'Denník viacdňových plavieb'**
  String get aboutFeatureLogbook;

  /// No description provided for @aboutFeatureMaps.
  ///
  /// In sk, this message translates to:
  /// **'Offline námorné mapy (OpenSeaMap)'**
  String get aboutFeatureMaps;

  /// No description provided for @aboutFeatureWeather.
  ///
  /// In sk, this message translates to:
  /// **'Námorná predpoveď počasia (Open-Meteo)'**
  String get aboutFeatureWeather;

  /// No description provided for @aboutFeatureExport.
  ///
  /// In sk, this message translates to:
  /// **'Export PDF + GPX'**
  String get aboutFeatureExport;

  /// No description provided for @aboutFeatureSafety.
  ///
  /// In sk, this message translates to:
  /// **'Bezpečnostná inštruktáž a Mayday karta'**
  String get aboutFeatureSafety;

  /// No description provided for @aboutAuthorLabel.
  ///
  /// In sk, this message translates to:
  /// **'Autor'**
  String get aboutAuthorLabel;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In sk, this message translates to:
  /// **'Verzia'**
  String get aboutVersionLabel;

  /// No description provided for @aboutPlatformLabel.
  ///
  /// In sk, this message translates to:
  /// **'Platforma'**
  String get aboutPlatformLabel;

  /// No description provided for @cloudSignInFailed.
  ///
  /// In sk, this message translates to:
  /// **'Prihlásenie zlyhalo: {error}'**
  String cloudSignInFailed(String error);

  /// No description provided for @cloudSignOutFailed.
  ///
  /// In sk, this message translates to:
  /// **'Odhlásenie zlyhalo: {error}'**
  String cloudSignOutFailed(String error);

  /// No description provided for @marineInstrumentsWifiNote.
  ///
  /// In sk, this message translates to:
  /// **'Funguje len cez WiFi sieť lode – telefón musí byť pripojený k NMEA gateway (Raymarine, Digital Yacht, Yacht Devices…). Bez WiFi appka používa GPS telefónu a predpoveď počasia z internetu.'**
  String get marineInstrumentsWifiNote;

  /// No description provided for @interruptedVoyageTitle.
  ///
  /// In sk, this message translates to:
  /// **'Trasovanie bolo prerušené'**
  String get interruptedVoyageTitle;

  /// No description provided for @interruptedVoyageBody.
  ///
  /// In sk, this message translates to:
  /// **'Appka sa vypla o {time} bez ukončenia plavby. Chcete pokračovať v tej istej plavbe?'**
  String interruptedVoyageBody(String time);

  /// No description provided for @interruptedVoyageGap.
  ///
  /// In sk, this message translates to:
  /// **'Aktuálna poloha je {distance} NM od posledného zaznamenaného bodu.'**
  String interruptedVoyageGap(String distance);

  /// No description provided for @interruptedVoyageAddGap.
  ///
  /// In sk, this message translates to:
  /// **'Dopočítať túto vzdialenosť do plavby'**
  String get interruptedVoyageAddGap;

  /// No description provided for @interruptedVoyageResume.
  ///
  /// In sk, this message translates to:
  /// **'Pokračovať'**
  String get interruptedVoyageResume;

  /// No description provided for @trackingStalledTitle.
  ///
  /// In sk, this message translates to:
  /// **'Plavba beží, ale nič sa nezapisuje'**
  String get trackingStalledTitle;

  /// No description provided for @trackingStalledSince.
  ///
  /// In sk, this message translates to:
  /// **'Posledný bod pred {minutes} min'**
  String trackingStalledSince(String minutes);

  /// No description provided for @trackingResumeAction.
  ///
  /// In sk, this message translates to:
  /// **'Pokračovať'**
  String get trackingResumeAction;

  /// No description provided for @trackingResumedAuto.
  ///
  /// In sk, this message translates to:
  /// **'Trasovanie pokračuje. Appku medzitým vypol systém — chýba {minutes} min.'**
  String trackingResumedAuto(String minutes);

  /// No description provided for @trackingResumedAddGap.
  ///
  /// In sk, this message translates to:
  /// **'Dopočítať {nm} NM'**
  String trackingResumedAddGap(String nm);

  /// No description provided for @batteryPromptTitle.
  ///
  /// In sk, this message translates to:
  /// **'Nech appka beží celú plavbu'**
  String get batteryPromptTitle;

  /// No description provided for @batteryPromptBody.
  ///
  /// In sk, this message translates to:
  /// **'Android — a najmä Honor, Huawei či Xiaomi — vypína aplikácie bežiace na pozadí. Trasovanie sa tým preruší uprostred plavby.\n\nV nastaveniach batérie povoľte tejto appke beh bez obmedzení. Na Honor/Huawei ju navyše pridajte medzi chránené aplikácie a povoľte automatické spúšťanie.'**
  String get batteryPromptBody;

  /// No description provided for @batteryPromptAction.
  ///
  /// In sk, this message translates to:
  /// **'Otvoriť nastavenia'**
  String get batteryPromptAction;

  /// No description provided for @speed.
  ///
  /// In sk, this message translates to:
  /// **'Rýchlosť'**
  String get speed;

  /// No description provided for @dateFormatLabel.
  ///
  /// In sk, this message translates to:
  /// **'Formát dátumu'**
  String get dateFormatLabel;

  /// No description provided for @dateFormatByLanguage.
  ///
  /// In sk, this message translates to:
  /// **'Podľa jazyka appky'**
  String get dateFormatByLanguage;

  /// No description provided for @crewCertTitle.
  ///
  /// In sk, this message translates to:
  /// **'Potvrdenie o naplávaných míľach'**
  String get crewCertTitle;

  /// No description provided for @crewCertVoyage.
  ///
  /// In sk, this message translates to:
  /// **'Plavba'**
  String get crewCertVoyage;

  /// No description provided for @crewCertArea.
  ///
  /// In sk, this message translates to:
  /// **'Oblasť plavby'**
  String get crewCertArea;

  /// No description provided for @crewCertDayMiles.
  ///
  /// In sk, this message translates to:
  /// **'Denné míle'**
  String get crewCertDayMiles;

  /// No description provided for @crewCertNightMiles.
  ///
  /// In sk, this message translates to:
  /// **'Nočné míle'**
  String get crewCertNightMiles;

  /// No description provided for @crewCertNightHours.
  ///
  /// In sk, this message translates to:
  /// **'Nočné hodiny'**
  String get crewCertNightHours;

  /// No description provided for @crewCertQualifications.
  ///
  /// In sk, this message translates to:
  /// **'Kvalifikácie'**
  String get crewCertQualifications;

  /// No description provided for @crewCertAssessment.
  ///
  /// In sk, this message translates to:
  /// **'Hodnotenie skipera'**
  String get crewCertAssessment;

  /// No description provided for @crewCertStamp.
  ///
  /// In sk, this message translates to:
  /// **'Pečiatka'**
  String get crewCertStamp;

  /// No description provided for @crewCertHashCoverage.
  ///
  /// In sk, this message translates to:
  /// **'Odtlačok pokrýva súhrn plavby aj hodnotenie posádky.'**
  String get crewCertHashCoverage;

  /// No description provided for @crewSkillHelming.
  ///
  /// In sk, this message translates to:
  /// **'Kormidlovanie'**
  String get crewSkillHelming;

  /// No description provided for @crewSkillNavigation.
  ///
  /// In sk, this message translates to:
  /// **'Navigácia'**
  String get crewSkillNavigation;

  /// No description provided for @crewSkillHarbour.
  ///
  /// In sk, this message translates to:
  /// **'Manévre v prístave'**
  String get crewSkillHarbour;

  /// No description provided for @crewSkillTeamwork.
  ///
  /// In sk, this message translates to:
  /// **'Práca v tíme'**
  String get crewSkillTeamwork;

  /// No description provided for @crewSkillNightSailing.
  ///
  /// In sk, this message translates to:
  /// **'Nočná plavba'**
  String get crewSkillNightSailing;

  /// No description provided for @crewCertExport.
  ///
  /// In sk, this message translates to:
  /// **'Exportovať potvrdenia'**
  String get crewCertExport;

  /// No description provided for @crewCertNoteHint.
  ///
  /// In sk, this message translates to:
  /// **'Slovné hodnotenie (nepovinné)'**
  String get crewCertNoteHint;

  /// No description provided for @crewCertNoCrew.
  ///
  /// In sk, this message translates to:
  /// **'Plavba nemá zadanú posádku. Doplň ju v karte plavby.'**
  String get crewCertNoCrew;

  /// No description provided for @crewCertNotRated.
  ///
  /// In sk, this message translates to:
  /// **'nehodnotené'**
  String get crewCertNotRated;

  /// No description provided for @crewCertShared.
  ///
  /// In sk, this message translates to:
  /// **'Potvrdenia vytvorené'**
  String get crewCertShared;

  /// No description provided for @more.
  ///
  /// In sk, this message translates to:
  /// **'Viac'**
  String get more;

  /// No description provided for @crewCertSkipperRates.
  ///
  /// In sk, this message translates to:
  /// **'Skiper hodnotí posádku — sám sa nehodnotí. Potvrdenie o míľach dostane tiež.'**
  String get crewCertSkipperRates;

  /// No description provided for @crewCertVesselSize.
  ///
  /// In sk, this message translates to:
  /// **'Rozmery lode'**
  String get crewCertVesselSize;

  /// No description provided for @crewCertVesselRegistration.
  ///
  /// In sk, this message translates to:
  /// **'Registrácia'**
  String get crewCertVesselRegistration;

  /// No description provided for @crewCertWaters.
  ///
  /// In sk, this message translates to:
  /// **'Vody'**
  String get crewCertWaters;

  /// No description provided for @crewCertWatersTidal.
  ///
  /// In sk, this message translates to:
  /// **'prílivové'**
  String get crewCertWatersTidal;

  /// No description provided for @crewCertWatersNonTidal.
  ///
  /// In sk, this message translates to:
  /// **'neprílivové'**
  String get crewCertWatersNonTidal;

  /// No description provided for @crewCertIdDocument.
  ///
  /// In sk, this message translates to:
  /// **'Číslo pasu / OP'**
  String get crewCertIdDocument;

  /// No description provided for @crewCertDaysAtSea.
  ///
  /// In sk, this message translates to:
  /// **'Dni na mori'**
  String get crewCertDaysAtSea;

  /// No description provided for @crewCertTotal.
  ///
  /// In sk, this message translates to:
  /// **'Spolu'**
  String get crewCertTotal;

  /// No description provided for @crewCertWatersLabel.
  ///
  /// In sk, this message translates to:
  /// **'Typ vôd'**
  String get crewCertWatersLabel;

  /// No description provided for @bearingTakeSight.
  ///
  /// In sk, this message translates to:
  /// **'Zameraj'**
  String get bearingTakeSight;

  /// No description provided for @bearingSaved.
  ///
  /// In sk, this message translates to:
  /// **'Zameranie {bearing} uložené'**
  String bearingSaved(String bearing);

  /// No description provided for @bearingNoPosition.
  ///
  /// In sk, this message translates to:
  /// **'Bez GPS sa neznámy bod určiť nedá. Prepni na „Moja poloha“ — resekcia zo známych bodov GPS nepotrebuje.'**
  String get bearingNoPosition;

  /// No description provided for @bearingSaveFailed.
  ///
  /// In sk, this message translates to:
  /// **'Zameranie sa nepodarilo uložiť'**
  String get bearingSaveFailed;

  /// No description provided for @bearingLabelHint.
  ///
  /// In sk, this message translates to:
  /// **'Čo zameriavaš? (nepovinné)'**
  String get bearingLabelHint;

  /// No description provided for @bearingDeclinationApplied.
  ///
  /// In sk, this message translates to:
  /// **'Deklinácia {value}'**
  String bearingDeclinationApplied(String value);

  /// No description provided for @bearingDeclinationExpired.
  ///
  /// In sk, this message translates to:
  /// **'Magnetický model vypršal – deklinácia je len odhad'**
  String get bearingDeclinationExpired;

  /// No description provided for @bearingsLayer.
  ///
  /// In sk, this message translates to:
  /// **'Zamerania'**
  String get bearingsLayer;

  /// No description provided for @bearingsTitle.
  ///
  /// In sk, this message translates to:
  /// **'Zamerania'**
  String get bearingsTitle;

  /// No description provided for @bearingsClearAll.
  ///
  /// In sk, this message translates to:
  /// **'Skryť všetky z mapy'**
  String get bearingsClearAll;

  /// No description provided for @bearingsClearConfirm.
  ///
  /// In sk, this message translates to:
  /// **'Skryť všetky zamerania z mapy? Čiary aj krížový fix zmiznú z mapy, v denníku zostanú.'**
  String get bearingsClearConfirm;

  /// No description provided for @bearingsEmpty.
  ///
  /// In sk, this message translates to:
  /// **'Zatiaľ žiadne zamerania. Namier telefón na objekt a stlač Zameraj.'**
  String get bearingsEmpty;

  /// No description provided for @bearingsDeleteDayConfirm.
  ///
  /// In sk, this message translates to:
  /// **'Všetky zamerania z tohto dňa sa nenávratne zmažu, aj z PDF exportu. Tento krok sa nedá vrátiť.'**
  String get bearingsDeleteDayConfirm;

  /// No description provided for @bearingFixFrom.
  ///
  /// In sk, this message translates to:
  /// **'Poloha z {count} zameraní'**
  String bearingFixFrom(int count);

  /// No description provided for @bearingFixWeak.
  ///
  /// In sk, this message translates to:
  /// **'Slabý fix – čiary sa pretínajú pod {angle}'**
  String bearingFixWeak(String angle);

  /// No description provided for @bearingFixOffGps.
  ///
  /// In sk, this message translates to:
  /// **'Odchýlka od GPS: {distance}'**
  String bearingFixOffGps(String distance);

  /// No description provided for @bearingTrueLabel.
  ///
  /// In sk, this message translates to:
  /// **'pravý'**
  String get bearingTrueLabel;

  /// No description provided for @bearingMagneticLabel.
  ///
  /// In sk, this message translates to:
  /// **'magnetický'**
  String get bearingMagneticLabel;

  /// No description provided for @bearingUncertaintyNote.
  ///
  /// In sk, this message translates to:
  /// **'Kužeľ ukazuje ±{deg} neistotu telefónového kompasu.'**
  String bearingUncertaintyNote(String deg);

  /// No description provided for @bearingPdfSection.
  ///
  /// In sk, this message translates to:
  /// **'Zamerania'**
  String get bearingPdfSection;

  /// No description provided for @bearingPdfObject.
  ///
  /// In sk, this message translates to:
  /// **'Objekt'**
  String get bearingPdfObject;

  /// No description provided for @bearingPdfBearing.
  ///
  /// In sk, this message translates to:
  /// **'Pravý kurz'**
  String get bearingPdfBearing;

  /// No description provided for @bearingModeResection.
  ///
  /// In sk, this message translates to:
  /// **'Moja poloha'**
  String get bearingModeResection;

  /// No description provided for @bearingModeObject.
  ///
  /// In sk, this message translates to:
  /// **'Neznámy bod'**
  String get bearingModeObject;

  /// No description provided for @bearingModeResectionHint.
  ///
  /// In sk, this message translates to:
  /// **'Zameraj 2–3 známe body z mapy. GPS netreba.'**
  String get bearingModeResectionHint;

  /// No description provided for @bearingModeObjectHint.
  ///
  /// In sk, this message translates to:
  /// **'Zameraj ten istý bod z 2–3 rôznych miest. Treba GPS.'**
  String get bearingModeObjectHint;

  /// No description provided for @bearingPickTarget.
  ///
  /// In sk, this message translates to:
  /// **'Vyber zameriavaný bod'**
  String get bearingPickTarget;

  /// No description provided for @bearingNeedsTarget.
  ///
  /// In sk, this message translates to:
  /// **'Najprv vyber známy bod z mapy, potom zameraj'**
  String get bearingNeedsTarget;

  /// No description provided for @bearingNeedsObject.
  ///
  /// In sk, this message translates to:
  /// **'Najprv pomenuj zameriavaný bod'**
  String get bearingNeedsObject;

  /// No description provided for @bearingNewObject.
  ///
  /// In sk, this message translates to:
  /// **'Nový bod…'**
  String get bearingNewObject;

  /// No description provided for @bearingObjectName.
  ///
  /// In sk, this message translates to:
  /// **'Názov bodu (napr. neznáma skala)'**
  String get bearingObjectName;

  /// No description provided for @bearingOpenObjects.
  ///
  /// In sk, this message translates to:
  /// **'Zameriavané body'**
  String get bearingOpenObjects;

  /// No description provided for @bearingSightCount.
  ///
  /// In sk, this message translates to:
  /// **'{count} zameraní'**
  String bearingSightCount(int count);

  /// No description provided for @bearingSameTargetHint.
  ///
  /// In sk, this message translates to:
  /// **'Ten istý bod ako predtým — na resekciu treba iný.'**
  String get bearingSameTargetHint;

  /// No description provided for @bearingShortBaselineHint.
  ///
  /// In sk, this message translates to:
  /// **'Krátka základnica — presuň sa a zameraj znova.'**
  String get bearingShortBaselineHint;

  /// No description provided for @bearingMovedHint.
  ///
  /// In sk, this message translates to:
  /// **'Loď sa medzi zameraniami posunula — resekcia predpokladá, že stojí.'**
  String get bearingMovedHint;

  /// No description provided for @bearingNeedsSecondSight.
  ///
  /// In sk, this message translates to:
  /// **'Ešte jeden námer na iný bod a poloha vyjde.'**
  String get bearingNeedsSecondSight;

  /// No description provided for @bearingMyPositionFix.
  ///
  /// In sk, this message translates to:
  /// **'Moja poloha'**
  String get bearingMyPositionFix;

  /// No description provided for @bearingObjectFix.
  ///
  /// In sk, this message translates to:
  /// **'Určený bod'**
  String get bearingObjectFix;

  /// No description provided for @bearingSaveObjectAsWaypoint.
  ///
  /// In sk, this message translates to:
  /// **'Ulož ako waypoint'**
  String get bearingSaveObjectAsWaypoint;

  /// No description provided for @bearingObjectSaved.
  ///
  /// In sk, this message translates to:
  /// **'{name} uložený ako waypoint'**
  String bearingObjectSaved(String name);

  /// No description provided for @bearingDeclinationFromTarget.
  ///
  /// In sk, this message translates to:
  /// **'Deklinácia počítaná v polohe zameraného bodu'**
  String get bearingDeclinationFromTarget;

  /// No description provided for @bearingResectionSection.
  ///
  /// In sk, this message translates to:
  /// **'Resekcia — poloha zo známych bodov'**
  String get bearingResectionSection;

  /// No description provided for @bearingObjectSection.
  ///
  /// In sk, this message translates to:
  /// **'Zameranie neznámych bodov'**
  String get bearingObjectSection;

  /// No description provided for @bearingPdfMark.
  ///
  /// In sk, this message translates to:
  /// **'Zameraný bod'**
  String get bearingPdfMark;

  /// No description provided for @bearingPdfResult.
  ///
  /// In sk, this message translates to:
  /// **'Výsledok'**
  String get bearingPdfResult;

  /// No description provided for @bearingStartNew.
  ///
  /// In sk, this message translates to:
  /// **'Začať nové zameranie'**
  String get bearingStartNew;

  /// No description provided for @bearingHideFromMap.
  ///
  /// In sk, this message translates to:
  /// **'Skryť z mapy'**
  String get bearingHideFromMap;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'cs',
        'de',
        'el',
        'en',
        'es',
        'hr',
        'it',
        'pl',
        'sk',
        'sl',
        'uk'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hr':
      return AppLocalizationsHr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
