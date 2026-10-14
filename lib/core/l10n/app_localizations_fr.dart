// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Calendrier de vie';

  @override
  String get loading => 'Chargement';

  @override
  String get errorHappened => 'Une erreur s\'est produite';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get week => 'Semaine';

  @override
  String get goals => 'Objectifs';

  @override
  String get goal => 'Objectif';

  @override
  String get noGoals => 'Aucun objectif';

  @override
  String get goalCreation => 'Créer un objectif';

  @override
  String get goalEdit => 'Modifier l\'objectif';

  @override
  String get events => 'Événements';

  @override
  String get event => 'Événement';

  @override
  String get noEvents => 'Aucun événement';

  @override
  String get eventCreation => 'Créer un événement';

  @override
  String get eventEdit => 'Modifier l\'événement';

  @override
  String get photos => 'Photos';

  @override
  String get photo => 'Photo';

  @override
  String get noPhotos => 'Aucune photo';

  @override
  String get resume => 'Bilan';

  @override
  String get noResume => 'Aucun bilan';

  @override
  String get rateWeek => 'Évaluez la semaine';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get skip => 'Passer';

  @override
  String get onboardingTitleWelcome => 'Calendrier de vie en semaines';

  @override
  String get onboardingContentWelcome =>
      'Ce calendrier offre une représentation visuelle des semaines déjà vécues et de celles qu\'il vous reste à vivre.';

  @override
  String get onboardingTitleGrid => 'Calendrier de vie en semaines';

  @override
  String get onboardingContentGrid =>
      'Chaque ligne du calendrier correspond à une année (52 ou 53 semaines). Chaque année commence par la semaine de votre anniversaire.';

  @override
  String get onboardingTitleZoom => 'Zoomez et choisissez une semaine';

  @override
  String get onboardingContentZoom =>
      'Vous pouvez agrandir le calendrier. Touchez un carré pour ouvrir la semaine choisie.';

  @override
  String get onboardingTitleJumpToCurrentWeek =>
      'Accédez à la semaine en cours d\'un geste';

  @override
  String get onboardingContentJumpToCurrentWeek =>
      'Pour aller rapidement à la semaine en cours, faites glisser du bas vers le haut.';

  @override
  String get onboardingTitleSearch => 'Recherchez une semaine d\'un geste';

  @override
  String get onboardingContentSearch =>
      'Pour ouvrir la recherche de semaines, faites glisser du haut vers le bas.';

  @override
  String get onboardingTitleSideMenu => 'Ouvrez le menu latéral en balayant';

  @override
  String get onboardingContentSideMenu =>
      'Pour ouvrir le menu latéral, faites glisser depuis le bord gauche vers le centre de l\'écran.';

  @override
  String get enterBirthdate => 'Saisissez votre date de naissance';

  @override
  String get dateFormatError => 'Format de date non valide';

  @override
  String dateInvalid(String start, String end) {
    return 'Saisissez une date entre le $start et le $end';
  }

  @override
  String get enterDate => 'Saisissez une date';

  @override
  String get enterLifespan => 'Saisissez votre espérance de vie';

  @override
  String get lifespanFormatError => 'Format non valide';

  @override
  String get ready => 'Terminé';

  @override
  String lifespanInterval(int start, int end) {
    return 'Saisissez un nombre entier entre $start et $end ans';
  }

  @override
  String get registrationUserError => 'Impossible de créer l\'utilisateur';

  @override
  String get registrationCalendarError => 'Impossible de créer le calendrier';

  @override
  String get errorEmptyField => 'Le champ ne peut pas être vide';

  @override
  String get error => 'Erreur';

  @override
  String get gotIt => 'Compris';

  @override
  String get errorPhotoAttach => 'Impossible de joindre la photo';

  @override
  String get birthdate => 'Date de naissance';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get calendarExport => 'Exporter le calendrier';

  @override
  String get exportDialogTitle => 'Exporter les données de l\'app';

  @override
  String get archiveCreationInProcess => 'Création de l\'archive...';

  @override
  String get archiveCreationSuccess => 'Archive créée avec succès';

  @override
  String get errorArchiveCreation =>
      'Une erreur s\'est produite lors de la création de l\'archive. Veuillez réessayer.';

  @override
  String get calendarImport => 'Importer le calendrier';

  @override
  String get importDialogTitle => 'Importer les données de l\'app';

  @override
  String get importDrawerDialogMessage =>
      'L\'importation du calendrier supprimera toutes vos données actuelles et les remplacera par les nouvelles !\n\nAssurez-vous de ne plus avoir besoin des anciennes données ou exportez-les d\'abord.\n\nAprès l\'importation, vous devrez rouvrir l\'application.';

  @override
  String get errorImport => 'Une erreur s\'est produite lors de l\'importation';

  @override
  String get errorPrivacyPolicy =>
      'Impossible d\'ouvrir la politique de confidentialité';

  @override
  String get cancel => 'Annuler';

  @override
  String get continueButton => 'Continuer';

  @override
  String get feedback => 'Commentaires';

  @override
  String get contactDeveloper => 'Contacter le développeur';

  @override
  String get leaveReviewMessage =>
      'Si l\'application vous plaît,\nlaissez un avis positif !';

  @override
  String get writeFeedbackToMail =>
      'Pour toute suggestion ou signalement de bug,\nécrivez-nous par e-mail.';

  @override
  String get errorWriteFeedback => 'Oups... Un problème inconnu est survenu';

  @override
  String get writeButton => 'Écrire';

  @override
  String get pullToSearch => 'Tirez pour rechercher';

  @override
  String get releaseToSearch => 'Relâchez pour rechercher';

  @override
  String get search => 'Rechercher';

  @override
  String get pullToGoToCurrentWeek => 'Aller à la semaine en cours';

  @override
  String get donate => 'Faire un don';

  @override
  String get donateDialogTitle => 'Votre soutien compte';

  @override
  String get donateDialogMessage =>
      'Ce projet est réalisé sur mon temps libre, avec soin et attention aux détails. Si l\'application vous est utile, je vous serais reconnaissant de votre soutien : il m\'aide à aller de l\'avant.';

  @override
  String get donateDialogButtonPositive => 'Soutenir le projet';

  @override
  String get donateDialogButtonNegative => 'Pas maintenant';

  @override
  String get tryAgainLater => 'Réessayez plus tard';

  @override
  String get buttonYes => 'Oui';

  @override
  String get buttonNo => 'Non';

  @override
  String get changeLifespan => 'Modifier l\'espérance de vie';

  @override
  String get confirmChanges => 'Confirmer les modifications';

  @override
  String get lifespanChangeDialogMessage =>
      'Réduire l\'espérance de vie supprimera les données des semaines futures. Continuer ?';

  @override
  String get exitAppDialogTitle => 'Quitter l\'application';

  @override
  String get exitAppDialogMessage =>
      'Voulez-vous vraiment quitter l\'application ?';

  @override
  String get daySymbol => 'J';

  @override
  String get monthSymbol => 'M';

  @override
  String get yearSymbol => 'A';

  @override
  String get assessmentGood => 'Bonne 🤩';

  @override
  String get assessmentBad => 'Mauvaise ☹️';

  @override
  String get assessmentPoor => 'Normale 😐';

  @override
  String widgetWeeksStats(int current, int total) {
    return '$current/$total semaines';
  }

  @override
  String widgetLifeStats(int percent) {
    return '$percent % de la vie';
  }

  @override
  String widgetGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objectifs',
      one: '1 objectif',
      zero: 'Aucun objectif',
    );
    return '$_temp0';
  }

  @override
  String widgetEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements',
      one: '1 événement',
      zero: 'Aucun événement',
    );
    return '$_temp0';
  }

  @override
  String get notificationSwitchTitle => 'Rappel du dimanche soir';

  @override
  String get notificationWeeklyReviewTitle => 'Un moment pour vous';

  @override
  String get notificationChannelDescription =>
      'Rappels pour faire le bilan de votre semaine';

  @override
  String get notificationWeeklyReviewBody =>
      'Le dimanche soir est le moment idéal pour se souvenir des bons moments. Jetez un œil à votre calendrier.';

  @override
  String get aboutAppDrawerTitle => 'À propos';

  @override
  String get notificationPermissionDeniedHint =>
      'Pour recevoir des rappels, autorisez les notifications dans les réglages';

  @override
  String get onboardingTitle3v => 'Mise à jour 3.0.0';

  @override
  String get onboardingContent3v =>
      'Widget pour l\'écran d\'accueil, rappels, nouvel écran principal, espérance de vie modifiable, version iOS et plus aucune publicité !';
}
