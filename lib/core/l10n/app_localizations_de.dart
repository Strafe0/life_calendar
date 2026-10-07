// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Lebenskalender';

  @override
  String get loading => 'Wird geladen';

  @override
  String get errorHappened => 'Ein Fehler ist aufgetreten';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get week => 'Woche';

  @override
  String get goals => 'Ziele';

  @override
  String get goal => 'Ziel';

  @override
  String get noGoals => 'Keine Ziele';

  @override
  String get goalCreation => 'Ziel erstellen';

  @override
  String get goalEdit => 'Ziel bearbeiten';

  @override
  String get events => 'Ereignisse';

  @override
  String get event => 'Ereignis';

  @override
  String get noEvents => 'Keine Ereignisse';

  @override
  String get eventCreation => 'Ereignis erstellen';

  @override
  String get eventEdit => 'Ereignis bearbeiten';

  @override
  String get photos => 'Fotos';

  @override
  String get photo => 'Foto';

  @override
  String get noPhotos => 'Keine Fotos';

  @override
  String get resume => 'Fazit';

  @override
  String get noResume => 'Kein Fazit';

  @override
  String get rateWeek => 'Woche bewerten';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get skip => 'Überspringen';

  @override
  String get onboardingTitleWelcome => 'Lebenskalender in Wochen';

  @override
  String get onboardingContentWelcome =>
      'Dieser Kalender zeigt anschaulich, wie viele Wochen deines Lebens bereits vergangen sind und wie viele noch vor dir liegen.';

  @override
  String get onboardingTitleGrid => 'Lebenskalender in Wochen';

  @override
  String get onboardingContentGrid =>
      'Jede Zeile des Kalenders entspricht einem Lebensjahr (52 oder 53 Wochen). Jedes Jahr beginnt mit der Woche, in die dein Geburtstag fällt.';

  @override
  String get onboardingTitleZoom => 'Heranzoomen und Woche wählen';

  @override
  String get onboardingContentZoom =>
      'Du kannst den Kalender vergrößern. Tippe auf ein Quadrat, um die gewählte Woche zu öffnen.';

  @override
  String get onboardingTitleJumpToCurrentWeek =>
      'Mit einer Geste zur aktuellen Woche';

  @override
  String get onboardingContentJumpToCurrentWeek =>
      'Um schnell zur aktuellen Woche zu gelangen, ziehe von unten nach oben.';

  @override
  String get onboardingTitleSearch => 'Mit einer Geste zur Wochensuche';

  @override
  String get onboardingContentSearch =>
      'Um die Wochensuche zu öffnen, ziehe von oben nach unten.';

  @override
  String get onboardingTitleSideMenu => 'Seitenmenü per Wischgeste öffnen';

  @override
  String get onboardingContentSideMenu =>
      'Um das Seitenmenü zu öffnen, ziehe vom linken Rand zur Mitte des Bildschirms.';

  @override
  String get enterBirthdate => 'Geburtsdatum eingeben';

  @override
  String get dateFormatError => 'Ungültiges Datumsformat';

  @override
  String dateInvalid(String start, String end) {
    return 'Gib ein Datum zwischen $start und $end ein';
  }

  @override
  String get enterDate => 'Datum eingeben';

  @override
  String get enterLifespan => 'Lebenserwartung eingeben';

  @override
  String get lifespanFormatError => 'Ungültiges Format';

  @override
  String get ready => 'Fertig';

  @override
  String lifespanInterval(int start, int end) {
    return 'Gib eine ganze Zahl zwischen $start und $end Jahren ein';
  }

  @override
  String get registrationUserError => 'Benutzer konnte nicht erstellt werden';

  @override
  String get registrationCalendarError =>
      'Kalender konnte nicht erstellt werden';

  @override
  String get errorEmptyField => 'Das Feld darf nicht leer sein';

  @override
  String get error => 'Fehler';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get errorPhotoAttach => 'Foto konnte nicht angehängt werden';

  @override
  String get birthdate => 'Geburtsdatum';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get calendarExport => 'Kalender exportieren';

  @override
  String get exportDialogTitle => 'App-Daten exportieren';

  @override
  String get archiveCreationInProcess => 'Archiv wird erstellt...';

  @override
  String get archiveCreationSuccess => 'Archiv erfolgreich erstellt';

  @override
  String get errorArchiveCreation =>
      'Beim Erstellen des Archivs ist ein Fehler aufgetreten. Bitte versuche es erneut.';

  @override
  String get calendarImport => 'Kalender importieren';

  @override
  String get importDialogTitle => 'App-Daten importieren';

  @override
  String get importDrawerDialogMessage =>
      'Beim Import des Kalenders werden alle aktuellen Daten gelöscht und durch neue ersetzt!\n\nStelle sicher, dass du die alten Daten nicht mehr brauchst, oder exportiere sie vorher.\n\nNach dem Import musst du die App neu öffnen.';

  @override
  String get errorImport => 'Beim Import ist ein Fehler aufgetreten';

  @override
  String get errorPrivacyPolicy =>
      'Datenschutzerklärung konnte nicht geöffnet werden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get continueButton => 'Weiter';

  @override
  String get feedback => 'Feedback';

  @override
  String get contactDeveloper => 'Entwickler kontaktieren';

  @override
  String get leaveReviewMessage =>
      'Wenn dir die App gefällt,\nhinterlasse bitte eine positive Bewertung!';

  @override
  String get writeFeedbackToMail =>
      'Für Vorschläge und Fehlermeldungen\nschreib uns eine E-Mail.';

  @override
  String get errorWriteFeedback =>
      'Hoppla... Ein unbekanntes Problem ist aufgetreten';

  @override
  String get writeButton => 'Schreiben';

  @override
  String get pullToSearch => 'Zum Suchen ziehen';

  @override
  String get releaseToSearch => 'Zum Suchen loslassen';

  @override
  String get search => 'Suche';

  @override
  String get pullToGoToCurrentWeek => 'Zur aktuellen Woche';

  @override
  String get donate => 'Spenden';

  @override
  String get donateDialogTitle => 'Deine Unterstützung ist wichtig';

  @override
  String get donateDialogMessage =>
      'Dieses Projekt entsteht in meiner Freizeit, mit viel Herzblut und Liebe zum Detail. Wenn dir die App nützt, freue ich mich über deine Unterstützung: Sie hilft mir, weiterzumachen.';

  @override
  String get donateDialogButtonPositive => 'Projekt unterstützen';

  @override
  String get donateDialogButtonNegative => 'Noch nicht';

  @override
  String get tryAgainLater => 'Versuche es später erneut';

  @override
  String get buttonYes => 'Ja';

  @override
  String get buttonNo => 'Nein';

  @override
  String get changeLifespan => 'Lebenserwartung ändern';

  @override
  String get confirmChanges => 'Änderungen bestätigen';

  @override
  String get lifespanChangeDialogMessage =>
      'Wenn du die Lebenserwartung verringerst, werden die Daten der späteren Wochen gelöscht. Fortfahren?';

  @override
  String get exitAppDialogTitle => 'App beenden';

  @override
  String get exitAppDialogMessage => 'Möchtest du die App wirklich beenden?';

  @override
  String get daySymbol => 'T';

  @override
  String get monthSymbol => 'M';

  @override
  String get yearSymbol => 'J';

  @override
  String get assessmentGood => 'Gut 🤩';

  @override
  String get assessmentBad => 'Schlecht ☹️';

  @override
  String get assessmentPoor => 'Normal 😐';

  @override
  String widgetWeeksStats(int current, int total) {
    return '$current/$total Wochen';
  }

  @override
  String widgetLifeStats(int percent) {
    return '$percent % des Lebens';
  }

  @override
  String widgetGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ziele',
      one: '1 Ziel',
      zero: 'Keine Ziele',
    );
    return '$_temp0';
  }

  @override
  String widgetEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ereignisse',
      one: '1 Ereignis',
      zero: 'Keine Ereignisse',
    );
    return '$_temp0';
  }

  @override
  String get notificationSwitchTitle => 'Erinnerung am Sonntagabend';

  @override
  String get notificationWeeklyReviewTitle => 'Zeit für dich';

  @override
  String get notificationChannelDescription =>
      'Erinnerungen an deinen Wochenrückblick';

  @override
  String get notificationWeeklyReviewBody =>
      'Der Sonntagabend ist die perfekte Zeit, sich an die schönen Momente zu erinnern. Wirf einen Blick in deinen Kalender.';

  @override
  String get aboutAppDrawerTitle => 'Über die App';

  @override
  String get notificationPermissionDeniedHint =>
      'Um Erinnerungen zu erhalten, erlaube Benachrichtigungen in den Einstellungen';

  @override
  String get onboardingTitle3v => 'Update 3.0.0';

  @override
  String get onboardingContent3v =>
      'Widget für den Startbildschirm, Erinnerungen, neuer Hauptbildschirm, anpassbare Lebenserwartung, iOS-Version und keine Werbung!';
}
