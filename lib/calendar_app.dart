import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/l10n/app_localizations.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/core/navigation/router.dart';
import 'package:life_calendar/data/repositories/auth_repository/auth_repository.dart';
import 'package:life_calendar/data/repositories/auth_repository/auth_repository_impl.dart';
import 'package:life_calendar/data/repositories/onboarding_repository/onboarding_repository.dart';
import 'package:life_calendar/data/repositories/onboarding_repository/onboarding_repository_impl.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository_impl.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository_impl.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository_impl.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/data/services/analytics/firebase_analytics_service.dart';
import 'package:life_calendar/data/services/backup/cache_backup_strategy_impl.dart';
import 'package:life_calendar/data/services/backup/database_backup_strategy_impl.dart';
import 'package:life_calendar/data/services/backup/shared_prefs_backup_strategy_impl.dart';
import 'package:life_calendar/data/services/database_service.dart';
import 'package:life_calendar/data/services/home_widget_service_impl.dart';
import 'package:life_calendar/data/services/image_picker_service_impl.dart';
import 'package:life_calendar/data/services/image_storage_service_impl.dart';
import 'package:life_calendar/data/services/local_backup_service_impl.dart';
import 'package:life_calendar/data/services/notifications/local_notification_service.dart';
import 'package:life_calendar/data/services/shared_preferences_service.dart';
import 'package:life_calendar/domain/interactor/app_initializer.dart';
import 'package:life_calendar/domain/interactor/weekly_notification_interactor.dart';
import 'package:life_calendar/domain/services/home_widget_service.dart';
import 'package:life_calendar/domain/services/image_picker_service.dart';
import 'package:life_calendar/domain/services/image_storage_service.dart';
import 'package:life_calendar/domain/services/local_backup_service.dart';
import 'package:life_calendar/ui/calendar/drawer/bloc/settings_cubit.dart';
import 'package:life_calendar/ui/core/themes/app_theme.dart';
import 'package:life_calendar/ui/user/bloc/user_bloc.dart';

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => DatabaseService()),
        RepositoryProvider(create: (_) => const SharedPreferencesService()),
        RepositoryProvider(
          create: (context) => AppInitializer(context.read<DatabaseService>()),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) =>
              SettingsRepositoryImpl(sharedPreferencesService: context.read()),
        ),
        RepositoryProvider(create: (context) => LocalNotificationService()),
        RepositoryProvider(
          create: (context) => WeeklyNotificationInteractor(
            context.read<LocalNotificationService>(),
            context.read<SharedPreferencesService>(),
          ),
        ),
        RepositoryProvider<AnalyticsService>(
          create: (context) => FirebaseAnalyticsService(),
        ),
        RepositoryProvider<ImagePickerService>(
          create: (_) => const ImagePickerServiceImpl(),
        ),
        RepositoryProvider<HomeWidgetService>(
          create: (_) => const HomeWidgetServiceImpl(),
        ),
        RepositoryProvider<ImageStorageService>(
          create: (_) => const ImageStorageServiceImpl(),
        ),
        RepositoryProvider<OnboardingRepository>(
          create: (_) => const OnboardingRepositoryImpl(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) {
            return AuthRepositoryImpl(sharedPreferencesService: context.read());
          },
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryImpl(
            sharedPreferencesService: context.read(),
            databaseService: context.read(),
          ),
        ),
        RepositoryProvider<WeekRepository>(
          create: (context) => WeekRepositoryImpl(
            databaseService: context.read(),
            imageStorageService: context.read(),
          ),
        ),
        RepositoryProvider<LocalBackupService>(
          create: (context) => LocalBackupServiceImpl(
            strategies: [
              DatabaseBackupStrategy(databaseService: context.read()),
              const SharedPreferencesBackupStrategy(),
              CacheBackupStrategy(databaseService: context.read()),
            ],
            analytics: context.read(),
            sharedPreferencesService: context.read(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SettingsCubit(
              context.read<WeeklyNotificationInteractor>(),
              context.read<SettingsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              userRepository: context.read(),
              analytics: context.read(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Life Calendar',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: goRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            Widget error = Center(child: Text(context.l10n.errorHappened));
            if (widget is Scaffold || widget is Navigator) {
              error = Scaffold(body: error);
            }
            ErrorWidget.builder = (errorDetails) {
              logger.e('Error building widget ${widget.runtimeType}');
              return error;
            };
            if (widget != null) return widget;
            throw StateError('Widget is null');
          },
        ),
      ),
    );
  }
}
