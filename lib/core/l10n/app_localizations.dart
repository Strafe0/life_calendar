import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('ru'),
  ];

  /// Название приложения
  ///
  /// In ru, this message translates to:
  /// **'Календарь жизни'**
  String get appTitle;

  /// Текст загрузки
  ///
  /// In ru, this message translates to:
  /// **'Загрузка'**
  String get loading;

  /// Текст общей ошибки без конкретики
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get errorHappened;

  /// Текст для кнопки
  ///
  /// In ru, this message translates to:
  /// **'Попробовать снова'**
  String get tryAgain;

  /// No description provided for @week.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get week;

  /// No description provided for @goals.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get goals;

  /// No description provided for @goal.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get goal;

  /// No description provided for @noGoals.
  ///
  /// In ru, this message translates to:
  /// **'Нет целей'**
  String get noGoals;

  /// No description provided for @goalCreation.
  ///
  /// In ru, this message translates to:
  /// **'Создание цели'**
  String get goalCreation;

  /// No description provided for @goalEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменение цели'**
  String get goalEdit;

  /// No description provided for @events.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get events;

  /// No description provided for @event.
  ///
  /// In ru, this message translates to:
  /// **'Событие'**
  String get event;

  /// No description provided for @noEvents.
  ///
  /// In ru, this message translates to:
  /// **'Нет событий'**
  String get noEvents;

  /// No description provided for @eventCreation.
  ///
  /// In ru, this message translates to:
  /// **'Создание события'**
  String get eventCreation;

  /// No description provided for @eventEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменение события'**
  String get eventEdit;

  /// No description provided for @photos.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get photos;

  /// No description provided for @photo.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get photo;

  /// No description provided for @noPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Нет фото'**
  String get noPhotos;

  /// No description provided for @resume.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get resume;

  /// No description provided for @noResume.
  ///
  /// In ru, this message translates to:
  /// **'Нет итога'**
  String get noResume;

  /// No description provided for @rateWeek.
  ///
  /// In ru, this message translates to:
  /// **'Дайте оценку неделе'**
  String get rateWeek;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @onboardingTitleWelcome.
  ///
  /// In ru, this message translates to:
  /// **'Календарь жизни в неделях'**
  String get onboardingTitleWelcome;

  /// No description provided for @onboardingContentWelcome.
  ///
  /// In ru, this message translates to:
  /// **'Этот календарь дает наглядное представление о количестве прожитых и оставшихся неделей нашей жизни.'**
  String get onboardingContentWelcome;

  /// No description provided for @onboardingTitleGrid.
  ///
  /// In ru, this message translates to:
  /// **'Календарь жизни в неделях'**
  String get onboardingTitleGrid;

  /// No description provided for @onboardingContentGrid.
  ///
  /// In ru, this message translates to:
  /// **'Каждая строка календаря соответствует одному году (52 или 53 недели). Каждый год начинается с недели, которая содержит ваш день рождения.'**
  String get onboardingContentGrid;

  /// Заголовок подсказки о приближении календаря
  ///
  /// In ru, this message translates to:
  /// **'Увеличивайте календарь и выбирайте неделю'**
  String get onboardingTitleZoom;

  /// Текст подсказки о приближении календаря
  ///
  /// In ru, this message translates to:
  /// **'Вы можете приблизить календарь. Нажав на квадрат, вы перейдете на экран выбранной недели.'**
  String get onboardingContentZoom;

  /// Заголовок подсказки о переходе к текущей неделе
  ///
  /// In ru, this message translates to:
  /// **'Переходите к текущей неделе одним движением'**
  String get onboardingTitleJumpToCurrentWeek;

  /// Текст подсказки о переходе к текущей неделе
  ///
  /// In ru, this message translates to:
  /// **'Чтобы сразу перейти к текущей неделе, потяните снизу вверх.'**
  String get onboardingContentJumpToCurrentWeek;

  /// Заголовок подсказки о переходе к поиску недели
  ///
  /// In ru, this message translates to:
  /// **'Переходите к поиску недели одним движением'**
  String get onboardingTitleSearch;

  /// No description provided for @onboardingContentSearch.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы перейти к поиску недели, сделайте свайп сверху вниз'**
  String get onboardingContentSearch;

  /// Заголовок подсказки об открытии бокового меню
  ///
  /// In ru, this message translates to:
  /// **'Открывайте боковое меню вытягиванием'**
  String get onboardingTitleSideMenu;

  /// No description provided for @onboardingContentSideMenu.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы открыть боковое меню, потяните от левого края к центру экрана.'**
  String get onboardingContentSideMenu;

  /// No description provided for @enterBirthdate.
  ///
  /// In ru, this message translates to:
  /// **'Введите дату рождения'**
  String get enterBirthdate;

  /// No description provided for @dateFormatError.
  ///
  /// In ru, this message translates to:
  /// **'Неверный формат даты'**
  String get dateFormatError;

  /// No description provided for @dateInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите дату {start} - {end}'**
  String dateInvalid(String start, String end);

  /// No description provided for @enterDate.
  ///
  /// In ru, this message translates to:
  /// **'Введите дату'**
  String get enterDate;

  /// No description provided for @enterLifespan.
  ///
  /// In ru, this message translates to:
  /// **'Введите продолжительность жизни'**
  String get enterLifespan;

  /// No description provided for @lifespanFormatError.
  ///
  /// In ru, this message translates to:
  /// **'Неверный формат'**
  String get lifespanFormatError;

  /// No description provided for @ready.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get ready;

  /// No description provided for @lifespanInterval.
  ///
  /// In ru, this message translates to:
  /// **'Введите целое число от {start} до {end} лет'**
  String lifespanInterval(int start, int end);

  /// No description provided for @registrationUserError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать пользователя'**
  String get registrationUserError;

  /// No description provided for @registrationCalendarError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось создать календарь'**
  String get registrationCalendarError;

  /// No description provided for @errorEmptyField.
  ///
  /// In ru, this message translates to:
  /// **'Поле не может быть пустым'**
  String get errorEmptyField;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @errorAdLoading.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось загрузить рекламу'**
  String get errorAdLoading;

  /// No description provided for @gotIt.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get gotIt;

  /// No description provided for @errorPhotoAttach.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось прикрепить фото'**
  String get errorPhotoAttach;

  /// No description provided for @birthdate.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get birthdate;

  /// No description provided for @privacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacyPolicy;

  /// No description provided for @calendarExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт календаря'**
  String get calendarExport;

  /// No description provided for @exportDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт данных приложения'**
  String get exportDialogTitle;

  /// No description provided for @archiveCreationInProcess.
  ///
  /// In ru, this message translates to:
  /// **'Происходит создание архива'**
  String get archiveCreationInProcess;

  /// No description provided for @archiveCreationSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Архив успешно создан'**
  String get archiveCreationSuccess;

  /// No description provided for @errorArchiveCreation.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка при создании архива. Попробуйте снова.'**
  String get errorArchiveCreation;

  /// No description provided for @calendarImport.
  ///
  /// In ru, this message translates to:
  /// **'Импорт календаря'**
  String get calendarImport;

  /// No description provided for @importDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт данных приложения'**
  String get importDialogTitle;

  /// No description provided for @importDrawerDialogMessage.
  ///
  /// In ru, this message translates to:
  /// **'При импорте календаря все ваши текущие данные будут удалены и заменены новыми!\n\nУбедитесь, что старые данные вам не нужны, или сделайте экспорт.\n\nПосле импорта вам нужно будет перезайти в приложение.'**
  String get importDrawerDialogMessage;

  /// No description provided for @errorImport.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка во время импорта'**
  String get errorImport;

  /// No description provided for @errorPrivacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось перейти к политике конфиденциальности'**
  String get errorPrivacyPolicy;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @continueButton.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueButton;

  /// No description provided for @feedback.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get feedback;

  /// No description provided for @contactDeveloper.
  ///
  /// In ru, this message translates to:
  /// **'Связь с разработчиком'**
  String get contactDeveloper;

  /// No description provided for @leaveReviewMessage.
  ///
  /// In ru, this message translates to:
  /// **'Если вам понравилось приложение,\n напишите положительный отзыв!'**
  String get leaveReviewMessage;

  /// No description provided for @writeFeedbackToMail.
  ///
  /// In ru, this message translates to:
  /// **'Для предложений и сообщениях об ошибках\n пишите на почту.'**
  String get writeFeedbackToMail;

  /// No description provided for @errorWriteFeedback.
  ///
  /// In ru, this message translates to:
  /// **'Упс... Возникла неизвестная проблема'**
  String get errorWriteFeedback;

  /// No description provided for @writeButton.
  ///
  /// In ru, this message translates to:
  /// **'Написать'**
  String get writeButton;

  /// No description provided for @pullToSearch.
  ///
  /// In ru, this message translates to:
  /// **'Потяните для поиска'**
  String get pullToSearch;

  /// No description provided for @releaseToSearch.
  ///
  /// In ru, this message translates to:
  /// **'Отпустите для поиска'**
  String get releaseToSearch;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @pullToGoToCurrentWeek.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к текущей неделе'**
  String get pullToGoToCurrentWeek;

  /// No description provided for @donate.
  ///
  /// In ru, this message translates to:
  /// **'Поблагодарить'**
  String get donate;

  /// No description provided for @donateDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваша поддержка важна'**
  String get donateDialogTitle;

  /// No description provided for @donateDialogMessage.
  ///
  /// In ru, this message translates to:
  /// **'Проект создаётся в свободное время с любовью и вниманием к деталям. Если приложение оказалось полезным, буду благодарен за поддержку — она помогает мне двигаться дальше.'**
  String get donateDialogMessage;

  /// No description provided for @donateDialogButtonPositive.
  ///
  /// In ru, this message translates to:
  /// **'Поддержать проект'**
  String get donateDialogButtonPositive;

  /// No description provided for @donateDialogButtonNegative.
  ///
  /// In ru, this message translates to:
  /// **'Пока не готов'**
  String get donateDialogButtonNegative;

  /// No description provided for @tryAgainLater.
  ///
  /// In ru, this message translates to:
  /// **'Попробовать позже'**
  String get tryAgainLater;

  /// No description provided for @buttonYes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get buttonYes;

  /// No description provided for @buttonNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get buttonNo;

  /// No description provided for @changeLifespan.
  ///
  /// In ru, this message translates to:
  /// **'Изменить продолжительности жизни'**
  String get changeLifespan;

  /// No description provided for @confirmChanges.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите изменения'**
  String get confirmChanges;

  /// No description provided for @lifespanChangeDialogMessage.
  ///
  /// In ru, this message translates to:
  /// **'При уменьшении срока жизни будут удалены данные будущих недель. Продолжить?'**
  String get lifespanChangeDialogMessage;

  /// No description provided for @exitAppDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выход из приложения'**
  String get exitAppDialogTitle;

  /// No description provided for @exitAppDialogMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы действительно хотите покинуть приложение?'**
  String get exitAppDialogMessage;

  /// No description provided for @daySymbol.
  ///
  /// In ru, this message translates to:
  /// **'Д'**
  String get daySymbol;

  /// No description provided for @monthSymbol.
  ///
  /// In ru, this message translates to:
  /// **'М'**
  String get monthSymbol;

  /// No description provided for @yearSymbol.
  ///
  /// In ru, this message translates to:
  /// **'Г'**
  String get yearSymbol;

  /// No description provided for @assessmentGood.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо 🤩'**
  String get assessmentGood;

  /// No description provided for @assessmentBad.
  ///
  /// In ru, this message translates to:
  /// **'Плохо ☹️'**
  String get assessmentBad;

  /// No description provided for @assessmentPoor.
  ///
  /// In ru, this message translates to:
  /// **'Нейтрально 😐'**
  String get assessmentPoor;

  /// Статистика недель (1408/4226 недель)
  ///
  /// In ru, this message translates to:
  /// **'{current}/{total} недель'**
  String widgetWeeksStats(int current, int total);

  /// Процент прожитой жизни
  ///
  /// In ru, this message translates to:
  /// **'{percent}% жизни'**
  String widgetLifeStats(int percent);

  /// Количество целей с правильным склонением
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет целей} one{{count} цель} few{{count} цели} many{{count} целей} other{{count} целей}}'**
  String widgetGoalsCount(int count);

  /// Количество событий с правильным склонением
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет событий} one{{count} событие} few{{count} события} many{{count} событий} other{{count} событий}}'**
  String widgetEventsCount(int count);

  /// No description provided for @notificationSwitchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Воскресное напоминание'**
  String get notificationSwitchTitle;

  /// No description provided for @notificationWeeklyReviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Время для себя'**
  String get notificationWeeklyReviewTitle;

  /// No description provided for @notificationWeeklyReviewBody.
  ///
  /// In ru, this message translates to:
  /// **'Воскресный вечер — лучшее время, чтобы вспомнить всё хорошее. Загляни в календарь.'**
  String get notificationWeeklyReviewBody;

  /// No description provided for @aboutAppDrawerTitle.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutAppDrawerTitle;

  /// No description provided for @notificationPermissionDeniedHint.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы получать напоминания, разрешите уведомления в настройках'**
  String get notificationPermissionDeniedHint;

  /// No description provided for @onboardingTitle3v.
  ///
  /// In ru, this message translates to:
  /// **'Обновление 3.0.0'**
  String get onboardingTitle3v;

  /// No description provided for @onboardingContent3v.
  ///
  /// In ru, this message translates to:
  /// **'Виджет на домашний экран, напоминания, обновление основного экрана, изменение продоложительности жизни, релиз для iOS и никакой рекламы!'**
  String get onboardingContent3v;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
