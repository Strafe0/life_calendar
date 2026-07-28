import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository.dart';
import 'package:life_calendar/domain/interactor/app_initializer.dart';
import 'package:life_calendar/domain/interactor/weekly_notification_interactor.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/ui/splash/bloc/splash_state.dart';
import 'package:life_calendar/utils/result.dart';

class SplashCubit extends Cubit<SplashState> {
  final AppInitializer _appInitializer;
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;
  final WeeklyNotificationInteractor _weeklyNotificationInteractor;

  SplashCubit({
    required AppInitializer appInitializer,
    required UserRepository userRepository,
    required WeeklyNotificationInteractor weeklyNotificationInteractor,
    required SettingsRepository settingsRepository,
  }) : _appInitializer = appInitializer,
       _userRepository = userRepository,
       _weeklyNotificationInteractor = weeklyNotificationInteractor,
       _settingsRepository = settingsRepository,
       super(const SplashInitial());

  Future<void> prepareApp() async {
    emit(const SplashLoading());
    final result = await _appInitializer.initialize();
    if (result is! Ok) {
      emit(const SplashFailure());
      return;
    }

    final userResult = await _userRepository.getUser();
    final isFirstLaunchV3 = await _settingsRepository.isFirstLaunchV3();

    await _prepareNotifications();

    if (userResult is Ok<User>) {
      await _settingsRepository.setFirstLaunchV3(isFirstLaunch: false);
      emit(
        SplashReady(user: userResult.value, isFirstLaunchV3: isFirstLaunchV3),
      );
    } else {
      emit(const SplashFailure());
    }
  }

  Future<void> _prepareNotifications() async {
    await _weeklyNotificationInteractor.initialize();
    await _weeklyNotificationInteractor.checkAndScheduleAtStartup();
  }
}
