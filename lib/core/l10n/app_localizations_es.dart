// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calendario de vida';

  @override
  String get loading => 'Cargando';

  @override
  String get errorHappened => 'Se ha producido un error';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get week => 'Semana';

  @override
  String get goals => 'Objetivos';

  @override
  String get goal => 'Objetivo';

  @override
  String get noGoals => 'Sin objetivos';

  @override
  String get goalCreation => 'Crear objetivo';

  @override
  String get goalEdit => 'Editar objetivo';

  @override
  String get events => 'Eventos';

  @override
  String get event => 'Evento';

  @override
  String get noEvents => 'Sin eventos';

  @override
  String get eventCreation => 'Crear evento';

  @override
  String get eventEdit => 'Editar evento';

  @override
  String get photos => 'Fotos';

  @override
  String get photo => 'Foto';

  @override
  String get noPhotos => 'Sin fotos';

  @override
  String get resume => 'Resumen';

  @override
  String get noResume => 'Sin resumen';

  @override
  String get rateWeek => 'Valora la semana';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get skip => 'Omitir';

  @override
  String get onboardingTitleWelcome => 'Calendario de vida en semanas';

  @override
  String get onboardingContentWelcome =>
      'Este calendario muestra de forma visual las semanas que ya has vivido y las que te quedan por vivir.';

  @override
  String get onboardingTitleGrid => 'Calendario de vida en semanas';

  @override
  String get onboardingContentGrid =>
      'Cada fila del calendario corresponde a un año (52 o 53 semanas). Cada año empieza con la semana de tu cumpleaños.';

  @override
  String get onboardingTitleZoom => 'Acerca y elige una semana';

  @override
  String get onboardingContentZoom =>
      'Puedes ampliar el calendario. Toca un cuadrado para abrir la semana seleccionada.';

  @override
  String get onboardingTitleJumpToCurrentWeek =>
      'Ve a la semana actual con un gesto';

  @override
  String get onboardingContentJumpToCurrentWeek =>
      'Para ir rápidamente a la semana actual, desliza de abajo hacia arriba.';

  @override
  String get onboardingTitleSearch => 'Busca una semana con un gesto';

  @override
  String get onboardingContentSearch =>
      'Para abrir la búsqueda de semanas, desliza de arriba hacia abajo.';

  @override
  String get onboardingTitleSideMenu => 'Abre el menú lateral deslizando';

  @override
  String get onboardingContentSideMenu =>
      'Para abrir el menú lateral, desliza desde el borde izquierdo hacia el centro de la pantalla.';

  @override
  String get enterBirthdate => 'Introduce tu fecha de nacimiento';

  @override
  String get dateFormatError => 'Formato de fecha no válido';

  @override
  String dateInvalid(String start, String end) {
    return 'Introduce una fecha entre $start y $end';
  }

  @override
  String get enterDate => 'Introduce una fecha';

  @override
  String get enterLifespan => 'Introduce tu esperanza de vida';

  @override
  String get lifespanFormatError => 'Formato no válido';

  @override
  String get ready => 'Listo';

  @override
  String lifespanInterval(int start, int end) {
    return 'Introduce un número entero entre $start y $end años';
  }

  @override
  String get registrationUserError => 'No se pudo crear el usuario';

  @override
  String get registrationCalendarError => 'No se pudo crear el calendario';

  @override
  String get errorEmptyField => 'El campo no puede estar vacío';

  @override
  String get error => 'Error';

  @override
  String get gotIt => 'Entendido';

  @override
  String get errorPhotoAttach => 'No se pudo adjuntar la foto';

  @override
  String get birthdate => 'Fecha de nacimiento';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get calendarExport => 'Exportar calendario';

  @override
  String get exportDialogTitle => 'Exportar datos de la app';

  @override
  String get archiveCreationInProcess => 'Creando archivo...';

  @override
  String get archiveCreationSuccess => 'Archivo creado correctamente';

  @override
  String get errorArchiveCreation =>
      'Se produjo un error al crear el archivo. Inténtalo de nuevo.';

  @override
  String get calendarImport => 'Importar calendario';

  @override
  String get importDialogTitle => 'Importar datos de la app';

  @override
  String get importDrawerDialogMessage =>
      '¡Al importar el calendario se eliminarán todos tus datos actuales y se sustituirán por los nuevos!\n\nAsegúrate de que ya no necesitas los datos antiguos o expórtalos antes.\n\nDespués de importar, tendrás que volver a abrir la app.';

  @override
  String get errorImport => 'Se produjo un error durante la importación';

  @override
  String get errorPrivacyPolicy => 'No se pudo abrir la política de privacidad';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueButton => 'Continuar';

  @override
  String get feedback => 'Comentarios';

  @override
  String get contactDeveloper => 'Contactar con el desarrollador';

  @override
  String get leaveReviewMessage =>
      'Si te gusta la app,\n¡deja una reseña positiva!';

  @override
  String get writeFeedbackToMail =>
      'Para sugerencias e informes de errores,\nescríbenos por correo.';

  @override
  String get errorWriteFeedback =>
      'Vaya... Se ha producido un problema desconocido';

  @override
  String get writeButton => 'Escribir';

  @override
  String get pullToSearch => 'Desliza para buscar';

  @override
  String get releaseToSearch => 'Suelta para buscar';

  @override
  String get search => 'Buscar';

  @override
  String get pullToGoToCurrentWeek => 'Ir a la semana actual';

  @override
  String get donate => 'Donar';

  @override
  String get donateDialogTitle => 'Tu apoyo es importante';

  @override
  String get donateDialogMessage =>
      'Este proyecto nace en mi tiempo libre, con cariño y atención al detalle. Si la app te resulta útil, te agradecería tu apoyo: me ayuda a seguir adelante.';

  @override
  String get donateDialogButtonPositive => 'Apoyar el proyecto';

  @override
  String get donateDialogButtonNegative => 'Ahora no';

  @override
  String get tryAgainLater => 'Inténtalo más tarde';

  @override
  String get buttonYes => 'Sí';

  @override
  String get buttonNo => 'No';

  @override
  String get changeLifespan => 'Cambiar esperanza de vida';

  @override
  String get confirmChanges => 'Confirmar cambios';

  @override
  String get lifespanChangeDialogMessage =>
      'Al reducir la esperanza de vida se eliminarán los datos de las semanas futuras. ¿Continuar?';

  @override
  String get exitAppDialogTitle => 'Salir de la app';

  @override
  String get exitAppDialogMessage => '¿Seguro que quieres salir de la app?';

  @override
  String get daySymbol => 'D';

  @override
  String get monthSymbol => 'M';

  @override
  String get yearSymbol => 'A';

  @override
  String get assessmentGood => 'Buena 🤩';

  @override
  String get assessmentBad => 'Mala ☹️';

  @override
  String get assessmentPoor => 'Normal 😐';

  @override
  String widgetWeeksStats(int current, int total) {
    return '$current/$total semanas';
  }

  @override
  String widgetLifeStats(int percent) {
    return '$percent % de la vida';
  }

  @override
  String widgetGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objetivos',
      one: '1 objetivo',
      zero: 'Sin objetivos',
    );
    return '$_temp0';
  }

  @override
  String widgetEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
      zero: 'Sin eventos',
    );
    return '$_temp0';
  }

  @override
  String get notificationSwitchTitle => 'Recordatorio del domingo por la noche';

  @override
  String get notificationWeeklyReviewTitle => 'Tiempo para ti';

  @override
  String get notificationChannelDescription =>
      'Recordatorios para repasar tu semana';

  @override
  String get notificationWeeklyReviewBody =>
      'El domingo por la noche es el momento perfecto para recordar lo bueno. Echa un vistazo a tu calendario.';

  @override
  String get aboutAppDrawerTitle => 'Acerca de la app';

  @override
  String get notificationPermissionDeniedHint =>
      'Para recibir recordatorios, permite las notificaciones en los ajustes';

  @override
  String get onboardingTitle3v => 'Actualización 3.0.0';

  @override
  String get onboardingContent3v =>
      'Widget para la pantalla de inicio, recordatorios, nueva pantalla principal, esperanza de vida editable, versión para iOS ¡y sin anuncios!';
}
