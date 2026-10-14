// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Calendário da Vida';

  @override
  String get loading => 'Carregando';

  @override
  String get errorHappened => 'Ocorreu um erro';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get week => 'Semana';

  @override
  String get goals => 'Metas';

  @override
  String get goal => 'Meta';

  @override
  String get noGoals => 'Nenhuma meta';

  @override
  String get goalCreation => 'Criar meta';

  @override
  String get goalEdit => 'Editar meta';

  @override
  String get events => 'Eventos';

  @override
  String get event => 'Evento';

  @override
  String get noEvents => 'Nenhum evento';

  @override
  String get eventCreation => 'Criar evento';

  @override
  String get eventEdit => 'Editar evento';

  @override
  String get photos => 'Fotos';

  @override
  String get photo => 'Foto';

  @override
  String get noPhotos => 'Nenhuma foto';

  @override
  String get resume => 'Resumo';

  @override
  String get noResume => 'Nenhum resumo';

  @override
  String get rateWeek => 'Avalie a semana';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get skip => 'Pular';

  @override
  String get onboardingTitleWelcome => 'Calendário da vida em semanas';

  @override
  String get onboardingContentWelcome =>
      'Este calendário mostra de forma visual as semanas já vividas e as que ainda restam na sua vida.';

  @override
  String get onboardingTitleGrid => 'Calendário da vida em semanas';

  @override
  String get onboardingContentGrid =>
      'Cada linha do calendário corresponde a um ano (52 ou 53 semanas). Cada ano começa na semana do seu aniversário.';

  @override
  String get onboardingTitleZoom => 'Aproxime e escolha uma semana';

  @override
  String get onboardingContentZoom =>
      'Você pode ampliar o calendário. Toque em um quadrado para abrir a semana selecionada.';

  @override
  String get onboardingTitleJumpToCurrentWeek =>
      'Vá para a semana atual com um gesto';

  @override
  String get onboardingContentJumpToCurrentWeek =>
      'Para ir rapidamente para a semana atual, deslize de baixo para cima.';

  @override
  String get onboardingTitleSearch => 'Busque uma semana com um gesto';

  @override
  String get onboardingContentSearch =>
      'Para abrir a busca de semanas, deslize de cima para baixo.';

  @override
  String get onboardingTitleSideMenu => 'Abra o menu lateral deslizando';

  @override
  String get onboardingContentSideMenu =>
      'Para abrir o menu lateral, deslize da borda esquerda para o centro da tela.';

  @override
  String get enterBirthdate => 'Informe sua data de nascimento';

  @override
  String get dateFormatError => 'Formato de data inválido';

  @override
  String dateInvalid(String start, String end) {
    return 'Informe uma data entre $start e $end';
  }

  @override
  String get enterDate => 'Informe uma data';

  @override
  String get enterLifespan => 'Informe sua expectativa de vida';

  @override
  String get lifespanFormatError => 'Formato inválido';

  @override
  String get ready => 'Pronto';

  @override
  String lifespanInterval(int start, int end) {
    return 'Informe um número inteiro entre $start e $end anos';
  }

  @override
  String get registrationUserError => 'Não foi possível criar o usuário';

  @override
  String get registrationCalendarError => 'Não foi possível criar o calendário';

  @override
  String get errorEmptyField => 'O campo não pode ficar vazio';

  @override
  String get error => 'Erro';

  @override
  String get gotIt => 'Entendi';

  @override
  String get errorPhotoAttach => 'Não foi possível anexar a foto';

  @override
  String get birthdate => 'Data de nascimento';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get calendarExport => 'Exportar calendário';

  @override
  String get exportDialogTitle => 'Exportar dados do app';

  @override
  String get archiveCreationInProcess => 'Criando arquivo...';

  @override
  String get archiveCreationSuccess => 'Arquivo criado com sucesso';

  @override
  String get errorArchiveCreation =>
      'Ocorreu um erro ao criar o arquivo. Tente novamente.';

  @override
  String get calendarImport => 'Importar calendário';

  @override
  String get importDialogTitle => 'Importar dados do app';

  @override
  String get importDrawerDialogMessage =>
      'Ao importar o calendário, todos os seus dados atuais serão excluídos e substituídos pelos novos!\n\nVerifique se você não precisa mais dos dados antigos ou exporte-os antes.\n\nDepois da importação, será preciso abrir o app novamente.';

  @override
  String get errorImport => 'Ocorreu um erro durante a importação';

  @override
  String get errorPrivacyPolicy =>
      'Não foi possível abrir a Política de Privacidade';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueButton => 'Continuar';

  @override
  String get feedback => 'Feedback';

  @override
  String get contactDeveloper => 'Falar com o desenvolvedor';

  @override
  String get leaveReviewMessage =>
      'Se você gosta do app,\ndeixe uma avaliação positiva!';

  @override
  String get writeFeedbackToMail =>
      'Para sugestões e relatos de erros,\nenvie um e-mail.';

  @override
  String get errorWriteFeedback => 'Ops... Ocorreu um problema desconhecido';

  @override
  String get writeButton => 'Escrever';

  @override
  String get pullToSearch => 'Deslize para buscar';

  @override
  String get releaseToSearch => 'Solte para buscar';

  @override
  String get search => 'Buscar';

  @override
  String get pullToGoToCurrentWeek => 'Ir para a semana atual';

  @override
  String get donate => 'Doar';

  @override
  String get donateDialogTitle => 'Seu apoio é importante';

  @override
  String get donateDialogMessage =>
      'Este projeto é feito no meu tempo livre, com carinho e atenção aos detalhes. Se o app for útil para você, ficarei grato pelo seu apoio: ele me ajuda a seguir em frente.';

  @override
  String get donateDialogButtonPositive => 'Apoiar o projeto';

  @override
  String get donateDialogButtonNegative => 'Agora não';

  @override
  String get tryAgainLater => 'Tente novamente mais tarde';

  @override
  String get buttonYes => 'Sim';

  @override
  String get buttonNo => 'Não';

  @override
  String get changeLifespan => 'Alterar expectativa de vida';

  @override
  String get confirmChanges => 'Confirmar alterações';

  @override
  String get lifespanChangeDialogMessage =>
      'Ao reduzir a expectativa de vida, os dados das semanas futuras serão excluídos. Continuar?';

  @override
  String get exitAppDialogTitle => 'Sair do app';

  @override
  String get exitAppDialogMessage => 'Deseja mesmo sair do app?';

  @override
  String get daySymbol => 'D';

  @override
  String get monthSymbol => 'M';

  @override
  String get yearSymbol => 'A';

  @override
  String get assessmentGood => 'Boa 🤩';

  @override
  String get assessmentBad => 'Ruim ☹️';

  @override
  String get assessmentPoor => 'Normal 😐';

  @override
  String widgetWeeksStats(int current, int total) {
    return '$current/$total semanas';
  }

  @override
  String widgetLifeStats(int percent) {
    return '$percent% da vida';
  }

  @override
  String widgetGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count metas',
      one: '1 meta',
      zero: 'Nenhuma meta',
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
      zero: 'Nenhum evento',
    );
    return '$_temp0';
  }

  @override
  String get notificationSwitchTitle => 'Lembrete de domingo à noite';

  @override
  String get notificationWeeklyReviewTitle => 'Um tempo para você';

  @override
  String get notificationChannelDescription =>
      'Lembretes para revisar sua semana';

  @override
  String get notificationWeeklyReviewBody =>
      'Domingo à noite é o momento perfeito para lembrar os bons momentos. Dê uma olhada no seu calendário.';

  @override
  String get aboutAppDrawerTitle => 'Sobre o app';

  @override
  String get notificationPermissionDeniedHint =>
      'Para receber lembretes, permita as notificações nas configurações';

  @override
  String get onboardingTitle3v => 'Atualização 3.0.0';

  @override
  String get onboardingContent3v =>
      'Widget para a tela inicial, lembretes, nova tela principal, expectativa de vida editável, versão para iOS e nada de anúncios!';
}
