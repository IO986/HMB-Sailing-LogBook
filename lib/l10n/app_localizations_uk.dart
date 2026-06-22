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
  String get wind24h => 'Вітер – 24г';

  @override
  String get waves24h => 'Хвилі – 24г';

  @override
  String get hourlyForecast => 'Погодинний прогноз';

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
}
