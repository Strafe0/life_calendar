// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Life Calendar';

  @override
  String get loading => 'Loading';

  @override
  String get errorHappened => 'An error occurred';

  @override
  String get tryAgain => 'Try again';

  @override
  String get week => 'Week';

  @override
  String get goals => 'Goals';

  @override
  String get goal => 'Goal';

  @override
  String get noGoals => 'No goals';

  @override
  String get goalCreation => 'Create goal';

  @override
  String get goalEdit => 'Edit goal';

  @override
  String get events => 'Events';

  @override
  String get event => 'Event';

  @override
  String get noEvents => 'No events';

  @override
  String get eventCreation => 'Create event';

  @override
  String get eventEdit => 'Edit event';

  @override
  String get photos => 'Photos';

  @override
  String get photo => 'Photo';

  @override
  String get noPhotos => 'No photos';

  @override
  String get resume => 'Summary';

  @override
  String get noResume => 'No summary';

  @override
  String get rateWeek => 'Rate the week';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get skip => 'Skip';

  @override
  String get onboardingTitleWelcome => 'Life Calendar in Weeks';

  @override
  String get onboardingContentWelcome =>
      'This calendar provides a visual representation of the weeks lived and the weeks remaining in your life.';

  @override
  String get onboardingTitleGrid => 'Life Calendar in Weeks';

  @override
  String get onboardingContentGrid =>
      'Each row of the calendar corresponds to one year (52 or 53 weeks). Each year starts with the week containing your birthday.';

  @override
  String get onboardingTitleZoom => 'Zoom in and select a week';

  @override
  String get onboardingContentZoom =>
      'You can zoom in on the calendar. Tapping on a square will take you to the screen for the selected week.';

  @override
  String get onboardingTitleJumpToCurrentWeek =>
      'Jump to the current week in one move';

  @override
  String get onboardingContentJumpToCurrentWeek =>
      'To quickly navigate to the current week, pull up from the bottom.';

  @override
  String get onboardingTitleSearch => 'Jump to week search in one move';

  @override
  String get onboardingContentSearch =>
      'To access week search, swipe down from the top.';

  @override
  String get onboardingTitleSideMenu => 'Open the side menu by swiping';

  @override
  String get onboardingContentSideMenu =>
      'To open the side menu, pull from the left edge toward the center of the screen.';

  @override
  String get enterBirthdate => 'Enter date of birth';

  @override
  String get dateFormatError => 'Invalid date format';

  @override
  String dateInvalid(String start, String end) {
    return 'Enter date between $start - $end';
  }

  @override
  String get enterDate => 'Enter date';

  @override
  String get enterLifespan => 'Enter expected lifespan';

  @override
  String get lifespanFormatError => 'Invalid format';

  @override
  String get ready => 'Done';

  @override
  String lifespanInterval(int start, int end) {
    return 'Enter an integer between $start and $end years';
  }

  @override
  String get registrationUserError => 'Failed to create user';

  @override
  String get registrationCalendarError => 'Failed to create calendar';

  @override
  String get errorEmptyField => 'Field cannot be empty';

  @override
  String get error => 'Error';

  @override
  String get errorAdLoading => 'Failed to load ad';

  @override
  String get gotIt => 'Got it';

  @override
  String get errorPhotoAttach => 'Failed to attach photo';

  @override
  String get birthdate => 'Date of birth';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get calendarExport => 'Export calendar';

  @override
  String get exportDialogTitle => 'Export app data';

  @override
  String get archiveCreationInProcess => 'Creating archive...';

  @override
  String get archiveCreationSuccess => 'Archive created successfully';

  @override
  String get errorArchiveCreation =>
      'An error occurred while creating the archive. Please try again.';

  @override
  String get calendarImport => 'Import calendar';

  @override
  String get importDialogTitle => 'Import app data';

  @override
  String get importDrawerDialogMessage =>
      'Importing the calendar will delete all your current data and replace it with new data!\n\nMake sure you don\'t need the old data, or export it first.\n\nAfter importing, you will need to log back into the app.';

  @override
  String get errorImport => 'An error occurred during import';

  @override
  String get errorPrivacyPolicy => 'Failed to open Privacy Policy';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueButton => 'Continue';

  @override
  String get feedback => 'Feedback';

  @override
  String get contactDeveloper => 'Contact developer';

  @override
  String get leaveReviewMessage =>
      'If you like the app,\nplease leave a positive review!';

  @override
  String get writeFeedbackToMail =>
      'For suggestions and bug reports,\nplease email us.';

  @override
  String get errorWriteFeedback => 'Oops... An unknown problem occurred';

  @override
  String get writeButton => 'Write';

  @override
  String get pullToSearch => 'Pull to search';

  @override
  String get releaseToSearch => 'Release to search';

  @override
  String get search => 'Search';

  @override
  String get pullToGoToCurrentWeek => 'Go to current week';

  @override
  String get donate => 'Donate';

  @override
  String get donateDialogTitle => 'Your support is important';

  @override
  String get donateDialogMessage =>
      'This project is created in my free time with love and attention to detail. If you find the app useful, I would be grateful for your support — it helps me move forward.';

  @override
  String get donateDialogButtonPositive => 'Support the project';

  @override
  String get donateDialogButtonNegative => 'Not ready yet';

  @override
  String get tryAgainLater => 'Try again later';

  @override
  String get buttonYes => 'Yes';

  @override
  String get buttonNo => 'No';

  @override
  String get changeLifespan => 'Change lifespan';

  @override
  String get confirmChanges => 'Confirm changes';

  @override
  String get lifespanChangeDialogMessage =>
      'Reducing the lifespan will delete data for future weeks. Continue?';

  @override
  String get exitAppDialogTitle => 'Exit App';

  @override
  String get exitAppDialogMessage => 'Do you really want to exit the app?';

  @override
  String get daySymbol => 'D';

  @override
  String get monthSymbol => 'M';

  @override
  String get yearSymbol => 'Y';

  @override
  String get assessmentGood => 'Good 🤩';

  @override
  String get assessmentBad => 'Bad ☹️';

  @override
  String get assessmentPoor => 'Normal 😐';

  @override
  String widgetWeeksStats(int current, int total) {
    return '$current/$total weeks';
  }

  @override
  String widgetLifeStats(int percent) {
    return '$percent% life';
  }

  @override
  String widgetGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goals',
      one: '1 goal',
      zero: 'No goals',
    );
    return '$_temp0';
  }

  @override
  String widgetEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get notificationSwitchTitle => 'Sunday Evening Reminder';

  @override
  String get notificationWeeklyReviewTitle => 'Time for yourself';

  @override
  String get notificationWeeklyReviewBody =>
      'Sunday evening is the perfect time to remember the good moments. Take a look at your calendar.';

  @override
  String get aboutAppDrawerTitle => 'About app';

  @override
  String get onboardingTitle3v => 'Update 3.0.0';

  @override
  String get onboardingContent3v =>
      'Home screen widget, reminders, main screen update, editable life expectancy, iOS release, and no ads!';
}
