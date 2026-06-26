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
  String get navSettings => 'Налаштування';

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
  String get existingVoyage => 'Існуюче плавання';

  @override
  String get newVoyageDropdown => '— Нове плавання —';

  @override
  String get firstVoyageHint =>
      'Перше плавання – заповніть основну інформацію:';

  @override
  String get estimatedDays => 'Очікувана кількість днів:';

  @override
  String get logFrequency => 'Частота записів у журнал';

  @override
  String get startTracking => 'Розпочати трекінг';

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
  String get timeCol => 'Час';

  @override
  String get windCol => 'Вітер';

  @override
  String get wavesCol => 'Хвилі';

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
  String get aboutApp => 'Про додаток';

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
      'Підключіть телефон до мережі WiFi судового шлюзу (Raymarine WiFi-1, RayNet та подібні зазвичай працюють на 10.0.0.1, порт 2000). Без підключення додаток автоматично використовує GPS телефону та інтернет-прогноз погоди.';

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
  String get engineSection => 'Двигун';

  @override
  String get engineHours => 'Мотогодини';

  @override
  String get fuel => 'Паливо';

  @override
  String get noteSection => 'Нотатка';

  @override
  String get noteHint => 'Умови плавання, події, зміна екіпажу...';

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
  String get waypointNameLabel => 'Назва';

  @override
  String get skipperSignature => 'Підпис шкіпера';

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
  String get selectWaypointHint => 'Вибрати точку...';

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
  String get navInstruments => 'Інструменти';

  @override
  String get enterPort => 'Введіть порт...';

  @override
  String get closeWithoutSaving => 'Закрити без збереження';

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
}
