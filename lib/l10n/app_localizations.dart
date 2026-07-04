import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_sk.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('sk'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In sk, this message translates to:
  /// **'HMB Sailing Log'**
  String get appTitle;

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
  /// **'Ukončiť tracking pre tento deň?'**
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
  /// **'Existujúca plavba'**
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
  /// **'Zmazať charter?'**
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
  /// **'Vytvor svoj prvý charter'**
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
  /// **'Kapitán'**
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
  /// **'Charter'**
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
  /// **'Skipper'**
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

  /// No description provided for @exportDayTitle.
  ///
  /// In sk, this message translates to:
  /// **'Export dňa'**
  String get exportDayTitle;

  /// No description provided for @exportCharterTitle.
  ///
  /// In sk, this message translates to:
  /// **'Export chartera'**
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
  /// **'Exportovať charter'**
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
  /// **'Upraviť charter'**
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
  /// **'Vyber waypoint...'**
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
  /// **'Nástroje'**
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
  /// **'1. Otvor Denník → stlač + → vyber \"Nová plavba\"\n2. Vyplň názov lode a zadaj predpokladaný počet dní\n3. Tracking štartuje automaticky – telefón si ulož do vrecka\n4. Počas dňa pridávaj záznamy: čas, pozícia, poznámka\n5. Na konci plavby otvor Nastavenia → Export PDF'**
  String get guideQuickStartBody;

  /// No description provided for @guideMapTitle.
  ///
  /// In sk, this message translates to:
  /// **'Mapa'**
  String get guideMapTitle;

  /// No description provided for @guideMapBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Mapa zobrazuje tvoju aktuálnu polohu a trasu plavby.\n\n• Modrá bodka = aktuálna poloha\n• Červená čiara = prejdená trasa\n• Môžeš prepínať medzi satelitnou a mapovou vrstvou\n• Seamarky – prepínač pre námorné značky (vraky, plytčiny, bóje)\n• Ikona kotvy = miesto kotvenia (len keď je kotva aktívna)\n• Ikona importu – načíta trasy a waypointy z .gpx súboru (pozri sekciu \"Import GPX\")'**
  String get guideMapBody;

  /// No description provided for @guideInstrTitle.
  ///
  /// In sk, this message translates to:
  /// **'Námorné prístroje'**
  String get guideInstrTitle;

  /// No description provided for @guideInstrBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Prístroje zobrazuje navigačné dáta v reálnom čase.\n\n• SOG – rýchlosť nad dnom (uzly)\n• TWS – skutočná rýchlosť vetra\n• TWA – smer vetra voči lodi (zelená = pravobok, červená = ľavobok)\n• DEPTH – hĺbka vody (červené = menej ako 5 m)\n• VMG WP – rýchlosť k cieľovému bodu\n\nZdroj dát: telefónne GPS alebo Raymarine (TCP aj UDP WiFi gateway).\nNastavenia pripojenia (vrátane voľby TCP/UDP) nájdeš v Nastavenia → Prístroje.'**
  String get guideInstrBody;

  /// No description provided for @guideLogbookTitle.
  ///
  /// In sk, this message translates to:
  /// **'Denník plavby'**
  String get guideLogbookTitle;

  /// No description provided for @guideLogbookBody.
  ///
  /// In sk, this message translates to:
  /// **'Denník je hlavná záložka pre správu pláv.\n\n• Stlač + (FAB) → \"Nová plavba\" pre vytvorenie chárteru\n• Tracking sa spúšťa z tohto dialógu – pozícia sa zaznamená automaticky\n• Každý deň plavby sa zobrazuje zvlášť\n• Záznamy možno pridávať ručne počas dňa, vrátane motohodín, paliva a vody v sekcii \"Motor a nádrže\"\n• Denník možno exportovať do PDF cez menu dňa\n• Ikona podania rúk v detaile plavby otvorí odovzdávací protokol (check-in/check-out)'**
  String get guideLogbookBody;

  /// No description provided for @guideMilesTitle.
  ///
  /// In sk, this message translates to:
  /// **'Kniha míľ'**
  String get guideMilesTitle;

  /// No description provided for @guideMilesBody.
  ///
  /// In sk, this message translates to:
  /// **'Súhrn všetkých plavieb na jednom mieste (ikona v Denníku plavby).\n\n• Celkové námorné míle, dni na mori, počet plavieb a nočné hodiny\n• Rozpad podľa roka a podľa lode\n• Filter podľa roka\n• Tlačidlo + – pridaj historickú plavbu spred používania appky (počíta sa plne do súhrnov, v zozname označená hviezdičkou)\n• Export PDF potvrdenia o najazdených míľach s miestom na podpis'**
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
  /// **'Importuj trasy a waypointy z iných navigačných aplikácií alebo GPS zariadení (ikona na Mape).\n\n• Vyber .gpx súbor zo zariadenia\n• Nájdené tracky priraď k existujúcej alebo novej plavbe\n• Waypointy (aj z trás/routes) sa pridajú rovno na mapu\n• Pri poškodenom súbore appka zobrazí zrozumiteľnú chybovú hlášku'**
  String get guideGpxImportBody;

  /// No description provided for @guideWeatherTitle.
  ///
  /// In sk, this message translates to:
  /// **'Počasie'**
  String get guideWeatherTitle;

  /// No description provided for @guideWeatherBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Počasie zobrazuje predpoveď podľa aktuálnej polohy.\n\n• Aktualizuje sa automaticky pri zmene polohy\n• Zobrazuje vietor, vlny, teplotu a podmienky nasledujúcich hodín\n• Ak nemáš internet, zobrazí sa posledná uložená predpoveď'**
  String get guideWeatherBody;

  /// No description provided for @guideSafetyMobTitle.
  ///
  /// In sk, this message translates to:
  /// **'MOB a kotva'**
  String get guideSafetyMobTitle;

  /// No description provided for @guideSafetyMobBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Bezpečnosť obsahuje núdzové funkcie.\n\nMOB (Človek cez palubu):\n• Podržte červené tlačidlo MOB pre aktiváciu\n• Aplikácia zaznamená GPS polohu a meria čas a vzdialenosť\n• Navigácia späť k miestu pádu\n\nKotva:\n• Nastav polomer kotvenia (odporúčané: 2× dĺžka kotevného lana)\n• Alarm zavibruje, ak sa loď vzdiali z povoleného okruhu'**
  String get guideSafetyMobBody;

  /// No description provided for @guideSafetyBriefingTitle.
  ///
  /// In sk, this message translates to:
  /// **'Bezpečnostný brífing a MAYDAY'**
  String get guideSafetyBriefingTitle;

  /// No description provided for @guideSafetyBriefingBody.
  ///
  /// In sk, this message translates to:
  /// **'V Bezpečnosti nájdeš aj záložky s referenčnými kartami.\n\n• Bezpečnostný brífing – checklist pre posádku pred plavbou\n• Každý člen posádky podpíše vlastným podpisom na obrazovke\n• Podpisy sa uložia a automaticky sa zahrnú do PDF exportu chartera\n• MAYDAY karta – postup pre tiesňové volanie na VHF kanál 16\n• COLREG – pravidlá predchádzania zrážkam na mori\n• Kontakty – núdzové čísla a kontakty'**
  String get guideSafetyBriefingBody;

  /// No description provided for @guideCompassTitle.
  ///
  /// In sk, this message translates to:
  /// **'Námerový kompas'**
  String get guideCompassTitle;

  /// No description provided for @guideCompassBody.
  ///
  /// In sk, this message translates to:
  /// **'Záložka Kompas zobrazuje magnetický azimut pomocou senzorov telefónu, s výhľadom zadnej kamery ako pozadím pre zameranie objektov.\n\n• Žltý kríž – smer, na ktorý mierite\n• Kompasová lišta hore – N / NE / E / SE / S / SW / W / NW\n• Číselné zobrazenie – stupne a svetová strana\n• Zelená bodka = stabilné čítanie  ·  Oranžová bodka = kalibruje\n\nAk je čítanie nestabilné, pomaly pohybuj telefónom do tvaru osmičky pre kalibráciu magnetometra.\n\nPozor: presnosť môže byť znížená v blízkosti kovových konštrukcií, reproduktorov alebo elektroniky.'**
  String get guideCompassBody;

  /// No description provided for @guideSettingsTitle.
  ///
  /// In sk, this message translates to:
  /// **'Nastavenia'**
  String get guideSettingsTitle;

  /// No description provided for @guideSettingsBody.
  ///
  /// In sk, this message translates to:
  /// **'• Jazyk – zmeň jazyk aplikácie\n• Prístroje – nastav IP adresu Raymarine WiFi gateway (TCP alebo UDP)\n• GPS zdroj – telefón alebo Raymarine\n• Jednotky – uzly/km/h, metre/stopy\n• Frekvencia zápisov do denníka\n• Zobrazenie – nočný režim (červený filter pre zachovanie nočného videnia)\n• Online účet – synchronizácia pripravovaná (v2.0)\n• Záloha dát – pozri sekciu \"Záloha a obnova dát\"\n• O aplikácii – verzia a kontakt'**
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
  /// **'Denník možno exportovať ako profesionálny PDF dokument.\n\n1. Otvor Denník → vyber charter\n2. Klepni na ikonu exportu alebo tri bodky → Export PDF\n3. Podpíš ako skipér → vygeneruje sa PDF\n4. PDF obsahuje: trasu, záznamy, fotky, safety brífing s podpismi posádky\n5. Zdieľaj cez email, tlač alebo ulož do telefónu\n\nKaždý PDF dostane jedinečné ID dokumentu (napr. HMBSL-5-2026) a číslo revízie (Rev. 1, Rev. 2...) viditeľné v pätičke každej strany. Pri každom novom exporte sa číslo automaticky zvýši – je tak viditeľné, koľkokrát bol dokument vygenerovaný.\n\nQR kód na podpisovej strane obsahuje ID, revíziu a kryptografický odtlačok obsahu. Akákoľvek zmena dát zmení QR kód.'**
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
  /// **'Kapitán'**
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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'sk', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'sk':
      return AppLocalizationsSk();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
