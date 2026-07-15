// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'HMB Sailing Log';

  @override
  String get languageName => 'Українська';

  @override
  String get navMap => 'Карта';

  @override
  String get navTracking => 'Трекінг';

  @override
  String get navLogbook => 'Журнал';

  @override
  String get navWeather => 'Погода';

  @override
  String get navSafety => 'Безпека';

  @override
  String get navCompass => 'Компас';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get cameraPermissionDenied =>
      'Доступ до камери заборонено. Увімкніть його в налаштуваннях пристрою.';

  @override
  String get cameraUnavailable => 'Камера недоступна';

  @override
  String get compassCalibrationNote =>
      'Магнітний компас. Точність може бути знижена через метал або електроніку поруч. Для калібрування рухайте пристрій по вісімці.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get edit => 'Редагувати';

  @override
  String get save => 'Зберегти';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Закрити';

  @override
  String get retry => 'Повторити';

  @override
  String get share => 'Поділитися';

  @override
  String get selectAll => 'Вибрати все';

  @override
  String get error => 'Помилка';

  @override
  String errorMsg(String msg) {
    return 'Помилка: $msg';
  }

  @override
  String get pressBackToExit => 'Натисніть Назад ще раз для виходу';

  @override
  String get trackingRunningTitle => 'Трекінг працює';

  @override
  String get trackingRunningContent =>
      'Трекінг активний. Що ви хочете зробити?';

  @override
  String get stopAndExit => 'Зупинити та вийти';

  @override
  String get keepRunning => 'Залишити активним';

  @override
  String get marineInstrumentsTitle => 'Морські інструменти';

  @override
  String get marineInstrumentsPrompt =>
      'Бажаєте підключити додаток до морських інструментів (наприклад, Raymarine через WiFi-шлюз)? Додаток читатиме GPS, вітер, глибину та інші дані безпосередньо з судна.\n\nБез підключення використовуватиметься GPS телефону та інтернет-прогноз погоди – це можна змінити в будь-який час у Налаштуваннях.';

  @override
  String get notNow => 'Не зараз';

  @override
  String get setupConnection => 'Налаштувати підключення';

  @override
  String get autoDetectAction => 'Автовизначення';

  @override
  String get autoDetectWifiHintTitle => 'Спочатку підключіться до WiFi судна';

  @override
  String get autoDetectWifiHintBody =>
      'Перевірте в Налаштуваннях телефону → WiFi, що ви підключені до мережі морських інструментів (наприклад, RayNet, WiFi-1). Тоді додаток автоматично спробує знайти шлюз у цій мережі.';

  @override
  String get openWifiSettings => 'Налаштування WiFi';

  @override
  String get continueAction => 'Продовжити';

  @override
  String get autoDetecting => 'Пошук приладів у мережі WiFi…';

  @override
  String get autoDetectFailed =>
      'Шлюз не знайдено. Перевірте, чи підключені до WiFi судна, або введіть IP вручну в Налаштуваннях.';

  @override
  String autoDetectSuccess(String host) {
    return 'Підключено до $host';
  }

  @override
  String get guidePromptTitle => 'Вперше тут? Короткий гід';

  @override
  String get guidePromptBody =>
      'Додаток має короткий посібник користувача – карта, судновий журнал, погода, контрольний список безпеки та інше. Хочете швидко переглянути зараз? Ви завжди знайдете його пізніше в Налаштування → Посібник користувача.';

  @override
  String get guidePromptAction => 'Показати посібник';

  @override
  String get trackingActiveTitle => 'Трекінг активний';

  @override
  String get trackingTitle => 'Трекінг';

  @override
  String get waitingForGps => 'Очікую GPS...';

  @override
  String get gpsUnavailable => 'GPS недоступний';

  @override
  String get lastKnownPosition => 'Остання відома позиція';

  @override
  String get accuracy => 'Точність';

  @override
  String get logbookBtn => 'Журнал';

  @override
  String get stop => 'Зупинити';

  @override
  String get stopTrackingDay => 'Зупинити відстеження?';

  @override
  String get startVoyage => 'Розпочати плавання';

  @override
  String get starting => 'Запускаю...';

  @override
  String get newVoyage => 'Нове плавання';

  @override
  String get multiday => 'Багатоденне';

  @override
  String get standalone => 'Окреме';

  @override
  String get voyageName => 'Назва плавання';

  @override
  String get voyageNameOptional => 'Назва (необов\'язково)';

  @override
  String get voyageNameHint => 'напр. Прогулянка до бухти';

  @override
  String get existingVoyage => 'Продовжити існуюче плавання';

  @override
  String get newVoyageDropdown => '— Нове плавання —';

  @override
  String get firstVoyageHint =>
      'Перше плавання – заповніть основну інформацію:';

  @override
  String get briefingRequiredHint =>
      'Трекінг можна запустити лише після завершення інструктажу з безпеки (Safety Briefing) для цього плавання.';

  @override
  String get briefingPending => 'Потрібен SB';

  @override
  String get briefingPendingListWarning =>
      'Інструктаж з безпеки не завершено – трекінг поки що не можна запустити';

  @override
  String get estimatedDays => 'Очікувана кількість днів:';

  @override
  String get logFrequency => 'Частота записів у журнал';

  @override
  String get startTracking => 'Розпочати трекінг';

  @override
  String get trackingInProgress => 'Відстеження плавання';

  @override
  String dayNofTotal(int n, int total) {
    return 'День $n з $total';
  }

  @override
  String get newDay => '(новий день)';

  @override
  String get endVoyageTitle => 'Закінчити плавання?';

  @override
  String get endVoyageContent =>
      'Ви досягли останнього запланованого дня плавання.\n\nПлавання продовжиться завтра?';

  @override
  String get decideLayer => 'Вирішу пізніше';

  @override
  String get continuesTomorrow => 'Продовжується завтра';

  @override
  String get endVoyage => 'Закінчити плавання';

  @override
  String get newMultidayVoyage => 'Нове багатоденне плавання';

  @override
  String get deleteCharterTitle => 'Видалити чартер?';

  @override
  String get deleteCharterContent => 'Всі дні та записи будуть видалені.';

  @override
  String get cannotDeleteWhileTracking =>
      'Неможливо видалити плавання під час активного трекінгу.';

  @override
  String get noVoyages => 'Немає плавань';

  @override
  String get createFirstCharter => 'Створіть свій перший чартер';

  @override
  String get briefingDone => 'Брифінг ✓';

  @override
  String get checkInDone => 'Заїзд ✓';

  @override
  String get checkOutDone => 'Виїзд ✓';

  @override
  String get voyageNotFound => 'Плавання не знайдено';

  @override
  String get unknownVessel => 'Невідоме судно';

  @override
  String get captain => 'Капітан';

  @override
  String get crew => 'Екіпаж';

  @override
  String get total => 'Всього';

  @override
  String voyageDaysCount(int n) {
    return 'Дні плавання ($n)';
  }

  @override
  String get bulkDelete => 'Масове видалення';

  @override
  String get noDays =>
      'Немає днів.\nРозпочніть трекінг і перший день буде створено автоматично.';

  @override
  String get deleteDayTitle => 'Видалити день?';

  @override
  String deleteDayContent(String day) {
    return 'Всі записи за $day будуть видалені.';
  }

  @override
  String get exportPdf => 'Експорт PDF';

  @override
  String get selectDaysTitle => 'Вибрати дні для видалення';

  @override
  String deleteCount(int n) {
    return 'Видалити ($n)';
  }

  @override
  String get safety => 'Безпека';

  @override
  String get mobHoldToActivate => 'Утримуйте для активації';

  @override
  String get mobActive => '⚠️ МЛБ АКТИВНИЙ';

  @override
  String get mobTime => 'Час';

  @override
  String get mobDistance => 'Відстань';

  @override
  String get mobDirection => 'Напрямок';

  @override
  String get navigateToMob => 'Навігація до МЛБ';

  @override
  String get gpsPositionNotAvailable => 'GPS-позиція недоступна!';

  @override
  String get anchorAlarm => 'Сигнал якоря';

  @override
  String get drifting => 'ДРЕЙФУЄ';

  @override
  String get anchorRadiusLabel => 'Радіус якірної стоянки';

  @override
  String get activate => 'Активувати';

  @override
  String get deactivate => 'Деактивувати';

  @override
  String get safetyBriefingCard => 'Інструктаж з безпеки';

  @override
  String get maydayCard => 'Картка Mayday';

  @override
  String get yachtHandover => 'Передача яхти';

  @override
  String get gearList => 'Список обладнання';

  @override
  String get colreg => 'МППЗС';

  @override
  String get emergencyContacts => 'Екстрені контакти';

  @override
  String get backToToc => 'Назад до змісту';

  @override
  String get briefingComplete => 'Інструктаж завершено';

  @override
  String get updateByPosition => 'Оновити за позицією';

  @override
  String get detectedByGps => 'визначено за GPS';

  @override
  String get locationUnavailable =>
      '📍 Позиція недоступна – показані глобальні контакти';

  @override
  String get detectingLocation => 'Визначаю позицію...';

  @override
  String get tapToCall => 'Натисни для дзвінка';

  @override
  String cannotCall(String name) {
    return 'Не вдалося зателефонувати: $name';
  }

  @override
  String get vhfChannel16 => 'Канал VHF 16 – використовуйте корабельне радіо';

  @override
  String get hmbHandbook => 'Довідник HMB';

  @override
  String get checkInLabel => 'Чек-ін (отримання яхти)';

  @override
  String get checkOutLabel => 'Чек-аут (здача яхти)';

  @override
  String get charterCheckCard => 'Чартер';

  @override
  String get weatherTitle => 'Погода та море';

  @override
  String get updateForecast => 'Оновити прогноз';

  @override
  String get gpsNotAvailableTracking => 'GPS недоступний – увімкніть трекінг';

  @override
  String get downloadingForecast => 'Завантажую прогноз...';

  @override
  String get loadingForecast => 'Завантажую прогноз...';

  @override
  String get noConnection => 'Немає доступного підключення';

  @override
  String get pressRefreshWhenOnline => 'Натисніть оновити коли онлайн';

  @override
  String get noWeatherData => 'Немає даних погоди';

  @override
  String get forecastAutoDownload =>
      'Прогноз завантажиться автоматично при запуску трекінгу, або натисніть Оновити.';

  @override
  String get enableGpsFirst => 'Спочатку увімкніть GPS / трекінг';

  @override
  String get downloadForecast => 'Завантажити прогноз';

  @override
  String downloadError(String error) {
    return 'Помилка завантаження: $error';
  }

  @override
  String get liveInstrumentData =>
      'Дані морських інструментів в реальному часі';

  @override
  String get windRelative => 'Вітер (відн.)';

  @override
  String get windTrue => 'Вітер (справж.)';

  @override
  String get depthLabel => 'Глибина';

  @override
  String get waterTempLabel => 'Темп. води';

  @override
  String get courseTrue => 'Курс (справж.)';

  @override
  String get courseMag => 'Курс (магн.)';

  @override
  String get engineLabel => 'Двигун';

  @override
  String get wavesLabel => 'Хвилі';

  @override
  String get pressureLabel => 'Тиск';

  @override
  String get airTempLabel => 'Повітря';

  @override
  String get waterLabel => 'Вода';

  @override
  String get wind24h => 'Вітер – 3 дні';

  @override
  String get waves24h => 'Хвилі – 3 дні';

  @override
  String get hourlyForecast => 'Прогноз на 3 дні';

  @override
  String get dailyForecast => 'Денна температура';

  @override
  String get timeCol => 'Час';

  @override
  String get windCol => 'Вітер';

  @override
  String get wavesCol => 'Хвилі';

  @override
  String get rainCol => 'Дощ';

  @override
  String get beaufort0 => 'Штиль';

  @override
  String get beaufort1 => 'Тихий вітерець';

  @override
  String get beaufort2 => 'Легкий бриз';

  @override
  String get beaufort3 => 'Слабкий бриз';

  @override
  String get beaufort4 => 'Помірний бриз';

  @override
  String get beaufort5 => 'Свіжий бриз';

  @override
  String get beaufort6 => 'Сильний бриз';

  @override
  String get beaufort7 => 'Міцний вітер';

  @override
  String get beaufort8 => 'Буревій';

  @override
  String get beaufort9 => 'Шторм';

  @override
  String get beaufort10 => 'Сильний шторм';

  @override
  String get beaufort11 => 'Жорстокий шторм';

  @override
  String get beaufort12 => 'Ураган';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get measurementUnits => 'Одиниці вимірювання';

  @override
  String get temperature => 'Температура';

  @override
  String get depthWaves => 'Глибина / хвилі';

  @override
  String get wind => 'Вітер';

  @override
  String get language => 'Мова';

  @override
  String get appLanguage => 'Мова додатку';

  @override
  String get languageDialogTitle => 'Jazyk / Language';

  @override
  String get displaySettings => 'Відображення';

  @override
  String get nightMode => 'Нічний режим';

  @override
  String get nightModeDesc => 'Червоний фільтр для збереження нічного зору';

  @override
  String get aboutApp => 'Про додаток';

  @override
  String get backupSection => 'Резервна копія даних';

  @override
  String get exportBackup => 'Експортувати резервну копію';

  @override
  String get exportBackupDesc =>
      'Зберігає весь журнал (плавання, записи, налаштування) в одному файлі';

  @override
  String get restoreBackup => 'Відновити з резервної копії';

  @override
  String get restoreBackupDesc =>
      'Замінює поточні дані вмістом обраного файлу резервної копії';

  @override
  String get restoreBlockedTrackingTitle => 'Триває GPS-трекінг';

  @override
  String get restoreBlockedTrackingBody =>
      'Спочатку зупини активне трасування плавання перед відновленням резервної копії.';

  @override
  String get restoreSchemaTooNewTitle => 'Резервна копія новіша';

  @override
  String get restoreSchemaTooNewBody =>
      'Ця резервна копія створена новішою версією додатку, ніж встановлена зараз. Спочатку онови додаток.';

  @override
  String get restoreConfirmTitle => 'Відновити з резервної копії?';

  @override
  String get restoreConfirmBody =>
      'Поточні дані буде замінено вмістом резервної копії. Перед цим автоматично буде створено резервну копію поточного стану.';

  @override
  String get restoreSuccess => 'Дані успішно відновлено з резервної копії.';

  @override
  String get restoreInvalidFile =>
      'Обраний файл не є дійсною резервною копією HMB Sailing Log.';

  @override
  String get milesBookTitle => 'Книга миль';

  @override
  String get totalNm => 'Всього NM';

  @override
  String get daysAtSea => 'Днів у морі';

  @override
  String get voyageCount => 'Кількість плавань';

  @override
  String get nightHoursLabel => 'Нічні години';

  @override
  String get byYear => 'За роком';

  @override
  String get byVessel => 'За судном';

  @override
  String get addHistoricalVoyage => 'Додати історичне плавання';

  @override
  String get editHistoricalVoyage => 'Редагувати історичне плавання';

  @override
  String get deleteHistoricalVoyageConfirm =>
      'Справді видалити це історичне плавання?';

  @override
  String get manualEntryExplanation => '* ручний запис (введено вручну)';

  @override
  String get roleLabel => 'Роль на борту';

  @override
  String get roleSkipper => 'Шкіпер';

  @override
  String get roleCoSkipper => 'Помічник шкіпера';

  @override
  String get roleCrew => 'Екіпаж';

  @override
  String get areaLabel => 'Район / маршрут';

  @override
  String get distanceNmLabel => 'Відстань (NM)';

  @override
  String get daysCountLabel => 'Кількість днів';

  @override
  String get milesCertificateTitle => 'Підтвердження пройдених миль';

  @override
  String get logbookRecordTitle => 'Запис книги миль';

  @override
  String get logbookTrackedHint =>
      'Дати, милі, район і роль розраховуються з трекінгу/імпорту.';

  @override
  String get vesselFlag => 'Прапор реєстрації';

  @override
  String get captainFirstName => 'Ім\'я капітана';

  @override
  String get captainLastName => 'Прізвище капітана';

  @override
  String get captainQualification => 'Найвища здобута кваліфікація';

  @override
  String get logbookSignatureSection => 'Підпис, що підтверджує милі';

  @override
  String get addSignature => 'Додати підпис';

  @override
  String get filterAllYears => 'Всі роки';

  @override
  String get filterCustomRange => 'Власний діапазон';

  @override
  String get handoverMenuTitle => 'Протокол передачі';

  @override
  String get checkInProtocol => 'Протокол прийому (check-in)';

  @override
  String get checkOutProtocol => 'Протокол повернення (check-out)';

  @override
  String get nextStepLabel => 'Наступний крок';

  @override
  String get readyToTrackHint => 'Готово до трекінгу';

  @override
  String wizardStepHeader(int step, int total, String label) {
    return 'Крок $step/$total · $label';
  }

  @override
  String get safetyBriefingShort => 'Інструктаж з\nбезпеки';

  @override
  String get handoverChecklistShort => 'Чекліст\nпередачі';

  @override
  String get safetyBriefingRefTitle => 'Інструктаж з безпеки';

  @override
  String get handoverChecklistRefTitle => 'Чекліст передачі судна';

  @override
  String get handoverDateTime => 'Дата і час';

  @override
  String get handoverLocation => 'Місце (марина)';

  @override
  String get checklistItemOk => 'ОК';

  @override
  String get checklistItemDamaged => 'Пошкоджено';

  @override
  String get checklistItemMissing => 'Відсутнє';

  @override
  String get damagePosition => 'Розташування на судні';

  @override
  String get newDamageBadge => 'НОВЕ ПОШКОДЖЕННЯ';

  @override
  String get companySignatureSection =>
      'Підпис представника чартерної компанії';

  @override
  String get companyRepName => 'Ім\'я представника';

  @override
  String get companyNameLabel => 'Назва компанії';

  @override
  String get protocolClosedNotice =>
      'Протокол закрито (обидві сторони підписали) – лише перегляд.';

  @override
  String get handoverCertTitle => 'Протокол передачі судна';

  @override
  String get itemSails => 'Вітрила';

  @override
  String get itemRigging => 'Такелаж';

  @override
  String get itemAnchorChain => 'Якір і ланцюг';

  @override
  String get itemNavInstruments => 'Навігаційні прилади';

  @override
  String get itemLifeJackets => 'Рятувальні жилети';

  @override
  String get itemRaft => 'Рятувальний пліт';

  @override
  String get itemFirstAidKit => 'Аптечка';

  @override
  String get itemDinghyMotor => 'Тузик і підвісний мотор';

  @override
  String get itemLights => 'Освітлення';

  @override
  String get itemBimini => 'Тент бімін';

  @override
  String get extraNotesLabel => 'Додаткові примітки';

  @override
  String get gpxImportTitle => 'Імпорт GPX';

  @override
  String get gpxImportPickFile => 'Вибрати GPX файл';

  @override
  String get gpxTracksFound => 'Знайдені треки';

  @override
  String get gpxWaypointsFound => 'Знайдені точки маршруту';

  @override
  String get gpxAssignTarget => 'Прив\'язати до плавання';

  @override
  String get gpxNewVoyage => 'Нове плавання';

  @override
  String get gpxImportButton => 'Імпортувати';

  @override
  String get gpxImportSuccess => 'GPX успішно імпортовано.';

  @override
  String get connectionConnected => 'Підключено';

  @override
  String get connectionConnecting => 'Підключаюся...';

  @override
  String get connectionError => 'Помилка підключення';

  @override
  String get connectionDisconnected =>
      'Відключено (використовується GPS телефону / прогноз)';

  @override
  String get ipAddressLabel => 'IP-адреса шлюзу';

  @override
  String get portLabel => 'Порт';

  @override
  String get autoConnectLabel => 'Автоматично підключатися при запуску';

  @override
  String get disconnect => 'Відключитися';

  @override
  String get connect => 'Підключитися';

  @override
  String get gatewayHint =>
      'Підключіть телефон до мережі WiFi Raymarine (напр. WiFi-1, RayNet). IP-адреса для введення — це НЕ та, що показана в налаштуваннях Raymarine — це шлюз (gateway) тієї WiFi-мережі. Знайдіть її на телефоні: Налаштування → WiFi → деталі мережі → Шлюз. Порт 2000 (TCP) — стандартний. Без підключення додаток автоматично використовує GPS телефону.';

  @override
  String connectedToHost(String host, int port) {
    return 'Підключено до $host:$port';
  }

  @override
  String get enterIpAddress => 'Введіть IP-адресу шлюзу';

  @override
  String connectionFailed(String error) {
    return 'Не вдалося підключитися: $error';
  }

  @override
  String get liveWind => 'Вітер';

  @override
  String get liveDepth => 'Глибина';

  @override
  String get liveWaterTemp => 'Темп. води';

  @override
  String get liveCompass => 'Компас';

  @override
  String get liveEngine => 'Двигун';

  @override
  String get nmeaTcp => 'TCP';

  @override
  String get nmeaUdp => 'UDP';

  @override
  String get udpListenPort => 'Порт прослуховування';

  @override
  String get startListening => 'Запустити';

  @override
  String get stopListening => 'Зупинити';

  @override
  String connectionListening(String port) {
    return 'Прослуховує UDP на порті $port';
  }

  @override
  String udpHint(String port) {
    return 'Налаштуйте симулятор/шлюз для надсилання UDP на IP цього телефону, порт $port.';
  }

  @override
  String udpListeningOnPort(int port) {
    return 'Прослуховую UDP порт $port';
  }

  @override
  String get dayNotFound => 'День не знайдено';

  @override
  String get saved => 'Збережено';

  @override
  String get trackingThisDay => 'Трекінг активний для цього дня';

  @override
  String get trackingOtherDay => 'Трекінг активний для іншого дня';

  @override
  String recordCount(int n) {
    return '$n записів';
  }

  @override
  String get addManual => 'Додати вручну';

  @override
  String get noEntries => 'Немає записів';

  @override
  String get entriesAutoAdded =>
      'Записи додаються автоматично під час трекінгу';

  @override
  String get deleteEntryTitle => 'Видалити запис?';

  @override
  String get autoRecord => 'Автоматичний запис';

  @override
  String get routeSection => 'Маршрут';

  @override
  String get fromPort => 'Звідки';

  @override
  String get toPort => 'Куди';

  @override
  String get distance => 'Відстань';

  @override
  String get vessel => 'Судно';

  @override
  String get weatherSection => 'Погода';

  @override
  String get morning => 'Ранок';

  @override
  String get noon => 'Полудень';

  @override
  String get evening => 'Вечір';

  @override
  String get windDir => 'Напрямок вітру';

  @override
  String get seaState => 'Стан моря';

  @override
  String get waveHeight => 'Висота хвиль';

  @override
  String get dailyNote => 'Щоденний звіт';

  @override
  String get dailyNoteHint => 'Опис плавання, цікаві моменти, події дня...';

  @override
  String get seaCalm => 'Спокійне';

  @override
  String get seaLight => 'Легке';

  @override
  String get seaModerate => 'Помірне';

  @override
  String get seaRough => 'Неспокійне';

  @override
  String get seaStormy => 'Штормове';

  @override
  String get editEntry => 'Редагувати запис';

  @override
  String get newEntry => 'Новий запис';

  @override
  String get sailMode => 'Режим плавання';

  @override
  String get sailMain => 'Основний';

  @override
  String get navigationSection => 'Навігація';

  @override
  String get latitude => 'Широта';

  @override
  String get longitude => 'Довгота';

  @override
  String get weatherSeaSection => 'Погода та море';

  @override
  String get windSpeed => 'Вітер';

  @override
  String get windDirection => 'Напрямок';

  @override
  String get waveHeight2 => 'Висота хвиль';

  @override
  String get engineSection => 'Двигун і баки';

  @override
  String get engineHours => 'Мотогодини';

  @override
  String get fuel => 'Паливо';

  @override
  String get fuelLevel => 'Рівень палива';

  @override
  String get waterLevel => 'Рівень води';

  @override
  String get noteSection => 'Нотатка';

  @override
  String get noteHint => 'Умови плавання, події, зміна екіпажу...';

  @override
  String get quickPhotoLogTitle => 'Швидкий запис';

  @override
  String get quickPhotoNoteHint => 'Що це? (необов\'язково)';

  @override
  String get exportDayTitle => 'Експорт дня';

  @override
  String get exportCharterTitle => 'Експорт чартеру';

  @override
  String get loadingData => 'Завантажую дані...';

  @override
  String get mapsReady => 'Карти готові – можна експортувати';

  @override
  String generatingMaps(int current, int total) {
    return 'Генерую попередній перегляд карт ($current/$total)...';
  }

  @override
  String get exportDayBtn => 'Експортувати день';

  @override
  String get exportCharterBtn => 'Експортувати чартер';

  @override
  String get entriesLabel => 'Записи';

  @override
  String get routePoints => 'Точки маршруту';

  @override
  String get anchorDriftTitle => '⚓ ЯКІР ДРЕЙФУЄ!';

  @override
  String get anchorDriftContent =>
      'Судно перевищило периметр якоря.\nНегайно перевірте позицію!';

  @override
  String get cancelAnchor => 'Скасувати якір';

  @override
  String get stopAlarm => 'Зупинити сигнал';

  @override
  String get briefingItem1 =>
      'Рятувальні жилети – розташування та використання';

  @override
  String get briefingItem2 => 'Рятувальний круг та процедура MOB';

  @override
  String get briefingItem3 => 'Сигнальні ракети – типи та використання';

  @override
  String get briefingItem4 => 'EPIRB / PLB – активація';

  @override
  String get briefingItem5 => 'УКХ-радіо – канал 16, процедура Mayday';

  @override
  String get briefingItem6 => 'Вогнегасник – розташування та використання';

  @override
  String get briefingItem7 => 'Аптечка – розташування';

  @override
  String get briefingItem8 => 'Аварійна зупинка двигуна';

  @override
  String get briefingItem9 => 'Протікання – вода, газ';

  @override
  String get briefingItem10 => 'Якір та ланцюг – процедура постановки на якір';

  @override
  String get briefingItem11 => 'Правила на борту';

  @override
  String get briefingItem12 => 'Екстрені контакти та УКХ 16';

  @override
  String get checkInItem1 => 'Документи судна (реєстрація, страховка)';

  @override
  String get checkInItem2 => 'Рятувальне обладнання – повний комплект';

  @override
  String get checkInItem3 => 'Запаси пального';

  @override
  String get checkInItem4 => 'Запаси води';

  @override
  String get checkInItem5 => 'Якір та ланцюг – перевірка';

  @override
  String get checkInItem6 => 'Двигун – пробний запуск';

  @override
  String get checkInItem7 => 'Навігаційні прилади';

  @override
  String get checkInItem8 => 'Такелаж – троси та вітрила';

  @override
  String get checkInItem9 => 'Камбуз – газ, плита';

  @override
  String get checkInItem10 => 'Туалет – функціональність';

  @override
  String get checkInItem11 => 'Наявні пошкодження – фотодокументація';

  @override
  String get checkOutItem1 => 'Судно прибране – зовні';

  @override
  String get checkOutItem2 => 'Судно прибране – всередині';

  @override
  String get checkOutItem3 => 'Паливо поповнено';

  @override
  String get checkOutItem4 => 'Вода поповнена';

  @override
  String get checkOutItem5 => 'Сміття вивезено';

  @override
  String get checkOutItem6 => 'Пошкодження повідомлено';

  @override
  String get checkOutItem7 => 'Ключі передано';

  @override
  String get gearListShort => 'Особисте\nСпорядження';

  @override
  String get colregRules => 'COLREG\nПравила';

  @override
  String get checkInShort => 'Check-in\nПриймання';

  @override
  String get checkOutShort => 'Check-out\nПередача';

  @override
  String get appTagline => 'Ваш надійний судновий журнал';

  @override
  String exportSavedMsg(String path) {
    return 'Збережено: $path';
  }

  @override
  String exportSavedPdfGpx(String pdf, String gpx) {
    return 'Збережено: $pdf + $gpx';
  }

  @override
  String exportErrorMsg(String error) {
    return 'Помилка експорту: $error';
  }

  @override
  String get generatingPdf => 'Генерую PDF...';

  @override
  String get colregTitle => 'КОЛРЕГ – Правила попередження зіткнень';

  @override
  String get tableOfContents => 'ЗМІСТ';

  @override
  String get inThisChapter => 'У цьому розділі:';

  @override
  String ruleNumberLabel(Object n) {
    return 'Прав. $n';
  }

  @override
  String get resetChecklistTitle => 'Скинути список?';

  @override
  String get resetChecklistContent => 'Усі позначки буде видалено.';

  @override
  String get reset => 'Скинути';

  @override
  String get checkInReceivingTitle => 'Заселення – Прийом судна';

  @override
  String get checkOutHandoverTitle => 'Виселення – Здача судна';

  @override
  String get checkInCompletedMsg => 'Судно прийнято – все перевірено ✓';

  @override
  String get checkOutCompletedMsg => 'Судно здано – все в порядку ✓';

  @override
  String get briefingDoneMsg => 'Інструктаж завершено – екіпаж проінформовано';

  @override
  String get sectionBriefed => 'Розділ проінструктовано ✓';

  @override
  String get confirmSection => 'Підтвердити розділ';

  @override
  String get gearListTitle => 'Особисте спорядження';

  @override
  String get newCategory => 'Нова категорія';

  @override
  String get add => 'Додати';

  @override
  String get deleteItemTitle => 'Видалити елемент?';

  @override
  String get allPackedMsg => 'Все зібрано, готові до плавання! 🎉';

  @override
  String get addItemLabel => 'Додати елемент';

  @override
  String addToCategoryTitle(String category) {
    return 'Додати до: $category';
  }

  @override
  String get newItemHint => 'Новий елемент...';

  @override
  String get addWaypoint => 'Додати путьову точку';

  @override
  String get editWaypoint => 'Редагувати путьову точку';

  @override
  String get waypointNameLabel => 'Назва';

  @override
  String get skipperSignature => 'Підпис шкіпера';

  @override
  String get skipperNameLabel => 'Ім\'я шкіпера';

  @override
  String get signWithFinger => 'Підпишіть пальцем';

  @override
  String get clear => 'Очистити';

  @override
  String get signAndExport => 'Підписати та експортувати';

  @override
  String get pleaseSign => 'Будь ласка, підпишіть перед експортом';

  @override
  String get generatingPdfPreview => 'Генерую попередній перегляд PDF...';

  @override
  String generationError(String error) {
    return 'Помилка генерації: $error';
  }

  @override
  String get savingAndGeneratingGpx => 'Збереження та генерація GPX...';

  @override
  String get editCharter => 'Редагувати чартер';

  @override
  String get basicInfo => 'Основна інформація';

  @override
  String get voyageNameRequired => 'Назва плавання *';

  @override
  String get dateFrom => 'Дата від';

  @override
  String get dateTo => 'Дата до';

  @override
  String get vesselName => 'Назва судна';

  @override
  String get vesselType => 'Тип судна';

  @override
  String get homePort => 'Порт приписки';

  @override
  String get mmsi => 'MMSI';

  @override
  String get callsign => 'Позивний';

  @override
  String get vesselLengthM => 'Довжина (м)';

  @override
  String get vesselBeamM => 'Ширина (м)';

  @override
  String get vesselDraftM => 'Осадка (м)';

  @override
  String get selectExistingVoyage => 'Вибрати існуючий рейс';

  @override
  String get newVoyageForm => 'Новий рейс';

  @override
  String get fillFormAndBriefing => 'Заповнити анкету та підписати інструктаж';

  @override
  String get notesLabel => 'Нотатки';

  @override
  String get statusLabel => 'Статус';

  @override
  String get safetyBriefingDoneLabel => 'Інструктаж з безпеки завершено';

  @override
  String get checkInDoneLabel => 'Заселення завершено';

  @override
  String get checkOutDoneLabel => 'Виселення завершено';

  @override
  String get enterVoyageName => 'Введіть назву плавання';

  @override
  String daysCount(int n) {
    return '$n днів';
  }

  @override
  String get selectTargetWaypoint => 'Вибрати цільову точку';

  @override
  String get noWaypoints => 'Немає путьових точок.';

  @override
  String get goToMap => 'Перейти на карту';

  @override
  String get noTarget => 'Без цілі';

  @override
  String get selectWaypointHint => 'Навігація до точки';

  @override
  String get sessionStats => 'Статистика плавання';

  @override
  String get maxSpeed => 'Макс. швидкість';

  @override
  String get avgSpeed => 'Серед. швидкість';

  @override
  String get sailingTime => 'Час плавання';

  @override
  String get gpsData => 'Дані GPS';

  @override
  String get gpsPosition => 'Позиція';

  @override
  String get courseCog => 'Курс (COG)';

  @override
  String get altitudeLabel => 'Висота';

  @override
  String get dscProcedure => 'ПРОЦЕДУРА DSC';

  @override
  String get voiceScript => 'ГОЛОСОВИЙ СЦЕНАРІЙ';

  @override
  String get dscWarningUseOnly => '⚠️ ВИКОРИСТОВУВАТИ ЛИШЕ У РАЗІ';

  @override
  String get dscWarningDanger => 'СЕРЙОЗНОЇ ТА БЕЗПОСЕРЕДНЬОЇ НЕБЕЗПЕКИ';

  @override
  String get dscWarningTypes => 'Пожежа · Затоплення · Людина за бортом';

  @override
  String get dscProcedureSubtitle =>
      'Зберігайте цю процедуру біля VHF DSC радіо';

  @override
  String get fillBeforeSailing => 'Заповніть перед відплиттям:';

  @override
  String get copyTooltip => 'Копіювати';

  @override
  String get scriptCopied => 'Сценарій скопійовано';

  @override
  String get sendOnCh16 =>
      '📻 Надіслати на Каналі 16 · Висока потужність · Повторювати кожні 2 хвилини без відповіді';

  @override
  String get enterAbove => '[введіть у полі вище]';

  @override
  String get distressNature => 'Характер лиха';

  @override
  String get vesselNameLabel => 'Назва судна';

  @override
  String get numberOfPersons => 'Кількість осіб';

  @override
  String get additionalInfo => 'Додаткова інформація';

  @override
  String get voiceScriptTitle => 'ГОЛОСОВИЙ СЦЕНАРІЙ MAYDAY';

  @override
  String get dscStep1 => 'Переконайтеся, що рація увімкнена.';

  @override
  String get dscStep2 => 'Відкрийте кришку над ЧЕРВОНОЮ кнопкою лиха.';

  @override
  String get dscStep3 => 'Натисніть ЧЕРВОНУ кнопку РАЗ та відпустіть.';

  @override
  String get dscStep4 =>
      'Оберіть характер лиха.\n(Пожежа, Затоплення, MOB тощо)\nЯкщо пропустити, надішлеться Невизначене лихо.';

  @override
  String get dscStep5 =>
      'Натисніть та УТРИМУЙТЕ ЧЕРВОНУ кнопку 5 секунд для надсилання виклику.';

  @override
  String get dscStep6 =>
      'Зачекайте до 15 секунд на підтвердження (на екрані), потім надішліть голосове повідомлення на Каналі 16 на ВЕЛИКІЙ потужності.';

  @override
  String get appDescription => 'Професійний судновий журнал для яхтсменів.';

  @override
  String get vesselIdTitle => 'Ідентифікація судна';

  @override
  String get vesselIdHint =>
      'Позивний та MMSI автоматично заповнюються у Картці Mayday.';

  @override
  String get maritimeReference => 'Морська абетка';

  @override
  String get phonetic => 'Фонетична';

  @override
  String get flagAlphabet => 'Сигнальні прапори';

  @override
  String get dayShapes => 'Денні знаки';

  @override
  String get marineReferenceTile => 'Сигнали & абетка';

  @override
  String get navInstruments => 'Суднові прилади';

  @override
  String get enterPort => 'Введіть порт...';

  @override
  String get closeWithoutSaving => 'Закрити без збереження';

  @override
  String get saveToDevice => 'Зберегти на пристрій';

  @override
  String get saveAndShare => 'Зберегти та поділитися';

  @override
  String get timestampCannotBeChanged => 'Час запису не можна змінити';

  @override
  String entriesShort(int n) {
    return '$n зап.';
  }

  @override
  String get mainsail => 'Грот';

  @override
  String get weatherConditionTitle => 'Стан погоди';

  @override
  String get weatherConditionLabel => 'Умови';

  @override
  String get wcSunny => 'Сонячно';

  @override
  String get wcPartlyCloudy => 'Мінлива хмарність';

  @override
  String get wcOvercast => 'Похмуро';

  @override
  String get wcLightRain => 'Слабкий дощ';

  @override
  String get wcRain => 'Дощ';

  @override
  String get wcHeavyRain => 'Сильний дощ';

  @override
  String get wcDrizzle => 'Мряка';

  @override
  String get wcThunderstorm => 'Гроза';

  @override
  String get wcIsoThunderstorm => 'Поодинокі грози';

  @override
  String get wcHail => 'Град';

  @override
  String get wcDust => 'Пил';

  @override
  String get wcFoggy => 'Туман';

  @override
  String get wcWindy => 'Вітряно';

  @override
  String get wcCold => 'Мороз';

  @override
  String get photoSection => 'Фото';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get addPhoto => 'Додати фото';

  @override
  String get photoAddedToEntry => 'Фото додано';

  @override
  String get voyageStart => 'Початок плавання';

  @override
  String get voyageEnd => 'Кінець плавання';

  @override
  String get onlineAccount => 'Онлайн-акаунт';

  @override
  String get onlineAccountDesc => 'Онлайн-синхронізація журналу — незабаром';

  @override
  String get register => 'Зареєструватися';

  @override
  String get login => 'Увійти';

  @override
  String get logout => 'Вийти';

  @override
  String get logoutConfirm =>
      'Ви вийдете з акаунту. Дані на пристрої залишаться.';

  @override
  String get notLoggedIn => 'Не авторизовано';

  @override
  String get fullName => 'Повне ім\'я';

  @override
  String get password => 'Пароль';

  @override
  String get userGuide => 'Посібник користувача';

  @override
  String get guideQuickStart => 'Швидкий старт – 5 кроків';

  @override
  String get guideQuickStartBody =>
      '1. Натисни велику кнопку \"Почати рейс\" вгорі (на Карті, в Журналі або на Приладах) – вибери частоту записів і трекінг працює, більше нічого заповнювати заздалегідь не треба\n2. Якщо є відкритий рейс, застосунок запитає: продовжити його чи почати новий запис\n3. Заповни відсутні дані (чек-ін, інструктаж з безпеки, картку судна/екіпажу) коли зручно – застосунок нагадає чипами в Журналі\n4. Протягом дня додавай записи: час, позицію, нотатку\n5. Наприкінці рейсу відкрий Налаштування → Експорт PDF\n\nЗастосунок працює на повний екран – проведи пальцем від верхнього чи нижнього краю, щоб тимчасово показати системні панелі телефону.';

  @override
  String get guideMapTitle => 'Карта';

  @override
  String get guideMapBody =>
      'Вкладка Карта показує твоє поточне місцезнаходження та маршрут рейсу.\n\n• Синя точка = поточна позиція\n• Синя лінія = маршрут, що зараз записується\n• Значок маршруту – вибери будь-який рейс або день і подивись його трек на карті (помаранчевим), без PDF-експорту\n• Перемикання між супутниковим і карт-видом\n• Морські знаки – перемикач навігаційних знаків (затонулі судна, мілини, буї)\n• Порти – клікабельний шар якірних стоянок, марин і портів (дані OpenStreetMap): торкнись значка, щоб побачити назву, канал VHF, телефон, сайт, глибину чи місткість, якщо відомі; місце можна одразу зберегти як путьову точку; шар містить і паливні станції для човнів (помаранчева колонка)\n• Радар – опадовий радар (RainViewer), знімок оновлюється ~кожні 10 хвилин\n• Вітер – стрілки напряму/сили вітру (вузли) сіткою по видимій області\n• Лінійка (фіолетовий значок) – торкайся точок на карті: сума NM, курс останнього відрізка та ETA при поточній швидкості; точки прилипають до путьових точок\n• Офлайн-карта (значок завантаження) – завантажує видиму область (карта + морські знаки, поточний зум +3 рівні) для використання без сигналу; кожна переглянута плитка також зберігається автоматично\n• У нічному режимі карта автоматично перемикається на темні плитки\n• Значок якоря = місце стоянки (лише при активній якірній сигналізації)\n• Значок імпорту – завантажує треки і точки маршруту з файлу .gpx (див. \"Імпорт GPX\")\n• Довге натискання на карту = додати путьову точку (ціль навігації); торкнись існуючої точки, щоб перейменувати або видалити її';

  @override
  String get guideInstrTitle => 'Морські прилади';

  @override
  String get guideInstrBody =>
      'Вкладка Прилади показує навігаційні дані в реальному часі.\n\n• SOG – швидкість над ґрунтом (вузли)\n• TWS – істинна швидкість вітру\n• TWA – кут вітру відносно судна (зелений = правий борт, червоний = лівий борт)\n• DEPTH – глибина води (червоний = менше 5 м)\n• VMG WP – швидкість до обраної путьової точки; після вибору побачиш відстань/пеленг і стрілку прямо на компасній розі\n\nДжерело даних: GPS телефону або Raymarine (WiFi-шлюз TCP чи UDP).\nНалаштування підключення (включно з вибором TCP/UDP): Налаштування → Прилади.';

  @override
  String get guideLogbookTitle => 'Судновий журнал';

  @override
  String get guideLogbookBody =>
      'Журнал — головна вкладка для керування рейсами.\n\n• Велика кнопка \"Почати рейс\" вгорі запускає трекінг – запитує лише частоту автоматичних записів (можна змінити при кожному новому старті), жодної форми заповнювати заздалегідь не потрібно\n• Якщо вже є відкритий рейс, застосунок запитає, чи продовжити його, чи почати новий запис\n• Відсутні дані (чек-ін, інструктаж з безпеки, картка судна/екіпажу) нагадуються кольоровими чипами прямо на картці рейсу – торкнись чипа, щоб заповнити\n• Кожен день рейсу відображається окремо\n• Записи можна вносити вручну протягом дня, включно з мотогодинами, паливом і водою в розділі \"Двигун і баки\"\n• Під час відстеження внизу зліва з\'являється кнопка камери – сфотографуй цікаву точку і збережи як швидкий запис із позицією та часом\n• Журнал можна експортувати в PDF через меню дня\n• Значок рукостискання в деталях рейсу відкриває протокол передачі (check-in/check-out)\n• Детальна форма рейсу (значок судна в деталях) фіксує судно та його параметри, район плавання, екіпаж із посвідченнями шкіпера та фото судна (макс. 3, переносяться в PDF)\n• Незаповнені картки (інструктаж з безпеки, чек-ін/аут, картка судна) блимають червоним у верхній панелі деталей рейсу, поки їх не завершиш';

  @override
  String get guideMilesTitle => 'Книга миль';

  @override
  String get guideMilesBody =>
      'Зведення всіх рейсів в одному місці (значок у Журналі).\n\n• Загальна кількість морських миль, дні у морі, кількість рейсів і нічні години\n• Розподіл за роком і за судном\n• Фільтр за роком\n• Натисни на рейс (також трекований/імпортований), щоб заповнити запис книги миль – маршрут, прапор судна, ім\'я та кваліфікацію капітана, підпис що підтверджує милі\n• Кнопка + – додай історичне плавання до початку використання додатку (повністю враховується у зведеннях, у списку позначене зірочкою)\n• Експорт PDF підтвердження пройдених миль з місцем для підпису';

  @override
  String get guideHandoverTitle => 'Протокол передачі (check-in/check-out)';

  @override
  String get guideHandoverBody =>
      'Формальний запис прийому і повернення судна при чартері – значок рукостискання в деталях рейсу.\n\n• Чекліст обладнання (вітрила, такелаж, якір, навігація, жилети, пліт, аптечка, тузик, освітлення, бімін...) – ОК / пошкоджено / відсутнє, з приміткою, розташуванням на судні та фото\n• Стан палива, води та мотогодин\n• Підпис шкіпера і представника чартерної компанії\n• Протокол стає доступним лише для читання, коли підписали обидві сторони\n• Check-out підставляє дані з check-in протоколу і виділяє нові пошкодження\n• Експорт PDF з обома підписами поруч';

  @override
  String get guideGpxImportTitle => 'Імпорт GPX';

  @override
  String get guideGpxImportBody =>
      'Імпортуй треки і точки маршруту з інших навігаційних додатків або GPS-пристроїв (значок на Карті).\n\n• Обери файл .gpx з пристрою\n• Багатоденний експорт (кілька треків в одному файлі, напр. з Garmin Explore) автоматично об\'єднається в один рейс з окремим днем на кожен календарний день\n• Знайдені треки можна теж вручну прив\'язати до існуючого рейсу\n• Точки маршруту (також з маршрутів/routes) додаються прямо на карту\n• При пошкодженому файлі додаток покаже зрозуміле повідомлення про помилку';

  @override
  String get guideWeatherTitle => 'Погода';

  @override
  String get guideWeatherBody =>
      'Вкладка Погода показує прогноз за поточним місцезнаходженням.\n\n• Оновлюється автоматично при зміні позиції\n• Показує вітер, хвилі, температуру та умови на найближчі години\n• Без інтернету: відображається останній збережений прогноз';

  @override
  String get guideSafetyMobTitle => 'МЗБ і якір';

  @override
  String get guideSafetyMobBody =>
      'Вкладка Безпека містить функції екстреної допомоги.\n\nМЗБ (Людина за бортом):\n• Утримуй червону кнопку МЗБ для активації\n• Додаток записує GPS-позицію та відраховує час і відстань\n• Навігація назад до місця падіння\n\nЯкірна сигналізація:\n• Встанови радіус стоянки (рекомендовано: 2× довжина ланцюга)\n• Сигналізація вібрує, якщо судно виходить за допустимий радіус';

  @override
  String get guideSafetyBriefingTitle => 'Інструктаж з безпеки та MAYDAY';

  @override
  String get guideSafetyBriefingBody =>
      'Вкладка Безпека також містить довідкові картки.\n\n• Інструктаж з безпеки – чекліст для екіпажу перед відплиттям\n• Кожен член екіпажу підписується власним підписом на екрані\n• Підписи зберігаються та автоматично включаються до PDF-експорту чартеру\n• Чекліст передачі судна – огляд пунктів прийому/повернення, доступний навіть без відкритого рейсу\n• Картка MAYDAY – процедура виклику допомоги на каналі 16 ОВЧ\n• МППЗС – правила запобігання зіткненням на морі\n• Екстрені контакти – номери і контакти для надзвичайних ситуацій\n\nПримітка: трекінг можна запустити будь-коли, навіть без завершеного інструктажу – застосунок лише нагадає чипом \"Немає інструктажу з безпеки\" в Журналі, доки його не завершиш. Інструктаж вимагає спершу заповненої картки судна та екіпажу і зберігається лише після підписів усіх членів.';

  @override
  String get guideCompassTitle => 'Компас пеленгування';

  @override
  String get guideCompassBody =>
      'Вкладка Компас показує магнітний пеленг за допомогою сенсорів телефону, з виглядом задньої камери як тло для пеленгування об\'єктів.\n\n• Жовтий приціл – напрям, на який ви вказуєте\n• Компасна смуга вгорі – N / NE / E / SE / S / SW / W / NW\n• Числовий показник – градуси та сторона світу\n• Зелена точка = стабільне показання  ·  Помаранчева точка = калібрується\n\nЯкщо показник нестабільний, повільно рухай телефоном у формі вісімки для калібрування магнетометра.\n\nУвага: точність може знижуватись поблизу металевих конструкцій, динаміків або електроніки.';

  @override
  String get guideSettingsTitle => 'Налаштування';

  @override
  String get guideSettingsBody =>
      '• Мова – змінити мову додатку\n• Прилади – налаштувати IP-адресу WiFi-шлюзу Raymarine (TCP чи UDP)\n• Джерело GPS – телефон або Raymarine\n• Одиниці – вузли/км/год, метри/фути\n• Частота записів у журнал\n• Відображення – нічний режим (червоний фільтр для збереження нічного зору)\n• Онлайн-акаунт – синхронізація готується (v2.0)\n• Резервна копія даних – див. \"Резервна копія та відновлення даних\"\n• Про додаток – версія та контакт';

  @override
  String get guideBackupTitle => 'Резервна копія та відновлення даних';

  @override
  String get guideBackupBody =>
      'У Налаштування → Резервна копія даних.\n\n• Експортувати резервну копію – зберігає весь журнал (рейси, записи, налаштування) в одному файлі (.hmbbackup), яким можна поділитися електронною поштою, у хмарі або зберегти локально\n• Відновити з резервної копії – замінює поточні дані вмістом обраної копії; перед цим автоматично створюється резервна копія поточного стану\n• Відновлення заблоковано під час активного GPS-трекінгу рейсу\n• Резервну копію з новішою схемою, ніж підтримує додаток, буде відхилено з поясненням';

  @override
  String get guideExportTitle => 'Експорт журналу';

  @override
  String get guideExportBody =>
      'Журнал можна експортувати як професійний PDF-документ.\n\n1. Відкрий Журнал → обери чартер\n2. Натисни значок експорту або три крапки → Експорт PDF\n3. Підпиши як шкіпер → PDF створюється\n4. PDF містить: маршрут, записи, фото, титульна сторінка з фото судна з картки судна (якщо завантажене), інструктаж з безпеки з підписами екіпажу\n5. Поділись електронною поштою, роздрукуй або збережи на телефоні\n\nКожен PDF отримує унікальний ID документа (напр. HMBSL-5-2026) та номер ревізії (Rev. 1, Rev. 2...) видимий у підвалі кожної сторінки. Кожен новий експорт автоматично збільшує номер — так видно, скільки разів документ було згенеровано.\n\nQR-код на сторінці підпису містить ID, ревізію та криптографічний відбиток вмісту. Будь-яка зміна даних змінює QR-код.';

  @override
  String get safetyBriefingScreenTitle => 'Інструктаж з безпеки';

  @override
  String get briefingCrewSignaturesSection => 'Підписи екіпажу';

  @override
  String get briefingSignHere => 'Підписати тут';

  @override
  String get briefingClear => 'Очистити';

  @override
  String get briefingSigned => 'Підписано';

  @override
  String get briefingSave => 'Зберегти підписи';

  @override
  String get briefingSavedOk => 'Підписи збережено';

  @override
  String get briefingOpenBriefing => 'Інструктаж з безпеки';

  @override
  String get briefingSkipper => 'Шкіпер';

  @override
  String get briefingCrew => 'Екіпаж';

  @override
  String get briefingNoCrew =>
      'Екіпаж не визначено. Додайте членів у налаштуваннях подорожі.';

  @override
  String get briefingDate => 'Дата';

  @override
  String get briefingLocation => 'Місце';

  @override
  String get briefingDoneLabel => 'Інструктаж з безпеки завершено';

  @override
  String get briefingDoneSubtitle =>
      'Підписи екіпажу збережені. Повторювати не потрібно.';

  @override
  String get briefingEditSignature => 'Змінити підпис';

  @override
  String get briefingRequiredTitle => 'Потрібен інструктаж з безпеки';

  @override
  String get briefingRequiredBody =>
      'Перед першим запуском трекінгу потрібно завершити інструктаж і зібрати підписи екіпажу.';

  @override
  String get goToBriefing => 'До інструктажу';

  @override
  String get skipperProfile => 'Профіль шкіпера';

  @override
  String get skipperProfileHint =>
      'Ці дані з\'являться в PDF-експорті плавання.';

  @override
  String get skipperFullName => 'Ім\'я шкіпера';

  @override
  String get skipperLicenseSection => 'Ліцензія шкіпера';

  @override
  String get skipperLicenseType => 'Тип ліцензії';

  @override
  String get skipperLicenseNumber => 'Номер ліцензії';

  @override
  String get skipperLicenseAuthority => 'Видавець';

  @override
  String get skipperLicenseExpiry => 'Дійсна до';

  @override
  String get skipperVhfSection => 'Ліцензія VHF / SRC';

  @override
  String get skipperVhfNumber => 'Номер VHF/SRC';

  @override
  String get skipperVhfExpiry => 'VHF дійсна до';

  @override
  String get skipperOtherCerts => 'Інші сертифікати / ліцензії';

  @override
  String get skipperOtherCertsHint =>
      'напр. Yachtmaster, RYA, STCW, рятувальні курси...';

  @override
  String get continueLastVoyageTitle => 'Продовжити останній рейс?';

  @override
  String get continueVoyageAction => 'Продовжити';

  @override
  String get newRecordAction => 'Новий запис';

  @override
  String get missingCheckInChip => 'Немає чек-іну';

  @override
  String get missingBriefingChip => 'Немає інструктажу з безпеки';

  @override
  String get missingDetailsChip => 'Бракує даних судна/екіпажу';

  @override
  String get missingCheckOutChip => 'Немає чек-ауту';

  @override
  String get vesselModel => 'Модель';

  @override
  String get vesselTypeMonohull => 'Однокорпусне';

  @override
  String get vesselTypeCatamaran => 'Катамаран';

  @override
  String get vesselTypeTrimaran => 'Тримаран';

  @override
  String get vesselTypeMotorYacht => 'Моторна яхта';

  @override
  String get vesselTypeGulet => 'Гулет';

  @override
  String get vesselTypeDinghy => 'Човен';

  @override
  String get vesselTypeRib => 'RIB';

  @override
  String get vesselTypeOther => 'Інше';

  @override
  String get charterCompanyLabel => 'Чартерна компанія';

  @override
  String get yachtParamsSection => 'Параметри яхти';

  @override
  String get berthsLabel => 'Спальні місця';

  @override
  String get yearBuiltLabel => 'Рік побудови';

  @override
  String get waterTankLabel => 'Бак для води';

  @override
  String get fuelTankLabel => 'Паливний бак';

  @override
  String get engineHoursStartLabel => 'Мотогодини · початок';

  @override
  String get engineHoursEndLabel => 'Мотогодини · кінець';

  @override
  String get whereWhenSection => 'Де і коли';

  @override
  String get countryLabel => 'Країна';

  @override
  String get cruisingAreaLabel => 'Район плавання';

  @override
  String get charterContactsSection => 'Контакти чартеру';

  @override
  String get charterContactsHint =>
      'До 3 номерів для дзвінка / WhatsApp / SMS. Завжди з міжнародним кодом (напр. +385...).';

  @override
  String get addPhoneNumber => 'Додати номер телефону';

  @override
  String get costsSection => 'Витрати';

  @override
  String get charterPriceLabel => 'Ціна чартеру';

  @override
  String get currencyLabel => 'Валюта';

  @override
  String get addCostItem => 'Додати витрату';

  @override
  String get costName => 'Назва витрати';

  @override
  String get crewSectionHint =>
      'Торкнись значка, щоб призначити капітана — решта є екіпажем.';

  @override
  String get addCrewMember => 'Додати члена екіпажу';

  @override
  String get crewNameLabel => 'Ім\'я';

  @override
  String get skipperBadge => 'ШКІПЕР';

  @override
  String get crewBadge => 'ЕКІПАЖ';

  @override
  String get vesselTypeSailboat => 'Вітрильник';

  @override
  String get vesselTypeMotorBoat => 'Моторний човен';

  @override
  String get sbNeedsVesselCard =>
      'Спочатку заповни картку судна та екіпажу — інструктаж з безпеки потребує список екіпажу для підписів.';

  @override
  String get prefillSkipperTitle => 'Заповнити збережені дані шкіпера?';

  @override
  String get prefillSkipperFill => 'Заповнити';

  @override
  String get prefillSkipperNew => 'Новий шкіпер';

  @override
  String get boatLicenceLabel => '№ посвідчення судноводія';

  @override
  String get radioLicenceLabel => '№ радіопосвідчення';

  @override
  String get vesselPhotosSection => 'Фото судна (макс. 3)';

  @override
  String get addPhotoLabel => 'Додати';

  @override
  String get createVoyageButton => 'Створити рейс';

  @override
  String get saveVoyageButton => 'Зберегти рейс';

  @override
  String get costBaseCharter => 'Базова ціна чартеру';

  @override
  String get costDeposit => 'Застава';

  @override
  String get costDinghyOutboard => 'Човен / підвісний мотор';

  @override
  String get costOutboardFuel => 'Паливо підвісного мотора';

  @override
  String get costTransitLog => 'Транзитний лог';

  @override
  String get costTouristTax => 'Туристичний збір';

  @override
  String get costFinalCleaning => 'Фінальне прибирання';

  @override
  String get costLinenTowels => 'Постільна білизна та рушники';

  @override
  String get costWifi => 'WiFi';

  @override
  String get costSupKayak => 'SUP / каяк';

  @override
  String get costSkipperFee => 'Плата за шкіпера';

  @override
  String get costHostessFee => 'Плата за хостес';

  @override
  String locationQualityPrecise(int m) {
    return 'GPS ±$m м';
  }

  @override
  String locationQualityApproximate(int m) {
    return '⚠️ Приблизне місцезнаходження · ±$m м · мережеве визначення';
  }

  @override
  String locationQualityCached(int mins) {
    return '⚠️ Останнє відоме місцезнаходження · $mins хв тому';
  }

  @override
  String get locationQualityUnknown => 'Точність невідома';

  @override
  String get locationQualityMocked => '⚠️ Виявлено фальшиве місцезнаходження';

  @override
  String get syncQueueTitle => 'Черга синхронізації';

  @override
  String get syncQueueEmpty => 'Черга порожня';

  @override
  String get syncNowAction => 'Синхронізувати зараз';

  @override
  String get syncRetryFailedAction => 'Повторити';

  @override
  String get syncStatusPending => 'Очікує';

  @override
  String get syncStatusSending => 'Надсилається';

  @override
  String get syncStatusSent => 'Надіслано';

  @override
  String get syncStatusFailed => 'Помилка';

  @override
  String get syncStatusConflict => 'Конфлікт';

  @override
  String get syncStatusDeferred => 'Відкладено';

  @override
  String syncRetryCount(int n) {
    return 'Спроба $n';
  }

  @override
  String get syncOffline => 'офлайн';

  @override
  String syncPendingCount(int n) {
    return '$n в черзі';
  }

  @override
  String syncDeferredCount(int n) {
    return '$n відкладено';
  }

  @override
  String syncFailedCount(int n) {
    return '$n помилок';
  }

  @override
  String get syncEnableToggle => 'Синхронізувати журнал';

  @override
  String get syncEnableToggleDesc =>
      'Надсилати записи на сервер, поки застосунок відкритий і онлайн';

  @override
  String get syncTargetLabel => 'Ціль синхронізації';

  @override
  String get syncTargetHmbAcademy => 'HMB Sailing Academy (hmba.boats)';

  @override
  String get syncTargetCustom => 'Власний сервер';

  @override
  String get syncCustomUrlLabel => 'URL сервера';

  @override
  String get syncCustomTokenLabel => 'Токен';

  @override
  String get syncTestConnectionAction => 'Перевірити з\'єднання';

  @override
  String get syncTestSuccess => 'З\'єднання працює';

  @override
  String syncTestFailure(String detail) {
    return 'Помилка: $detail';
  }

  @override
  String get syncUrlErrorEmpty => 'Введіть URL сервера';

  @override
  String get syncUrlErrorInvalid => 'Недійсний URL';

  @override
  String get syncUrlErrorHttps => 'URL має починатися з https://';

  @override
  String get syncIntervalLabel => 'Інтервал синхронізації';

  @override
  String syncIntervalMinutes(int n) {
    return '$n хв';
  }

  @override
  String get syncIntervalNote =>
      'Синхронізація працює, лише поки застосунок відкритий';

  @override
  String get syncAttachmentPolicyLabel => 'Вкладення (фото)';

  @override
  String get syncAttachmentNever => 'Ніколи';

  @override
  String get syncAttachmentWifiOnly => 'Лише через Wi-Fi';

  @override
  String get syncAttachmentAlways => 'Завжди';
}
