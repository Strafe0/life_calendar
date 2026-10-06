import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository.dart';
import 'package:life_calendar/domain/interactor/app_initializer.dart';
import 'package:life_calendar/domain/interactor/weekly_notification_interactor.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/ui/splash/bloc/splash_cubit.dart';
import 'package:life_calendar/ui/splash/bloc/splash_state.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppInitializer extends Mock implements AppInitializer {}

class _MockUserRepository extends Mock implements UserRepository {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockWeeklyNotificationInteractor extends Mock
    implements WeeklyNotificationInteractor {}

void main() {
  late _MockAppInitializer appInitializer;
  late _MockUserRepository userRepository;
  late _MockSettingsRepository settingsRepository;
  late _MockWeeklyNotificationInteractor interactor;

  final user = User(id: 'id', birthdate: DateTime(1990, 5, 15), lifeSpan: 80);
  final error = Exception('failure');

  setUp(() {
    appInitializer = _MockAppInitializer();
    userRepository = _MockUserRepository();
    settingsRepository = _MockSettingsRepository();
    interactor = _MockWeeklyNotificationInteractor();

    when(
      () => appInitializer.initialize(),
    ).thenAnswer((_) async => const Result.ok(null));
    when(
      () => settingsRepository.isFirstLaunchV3(),
    ).thenAnswer((_) async => true);
    when(
      () => settingsRepository.setFirstLaunchV3(
        isFirstLaunch: any(named: 'isFirstLaunch'),
      ),
    ).thenAnswer((_) async {});
    when(() => interactor.initialize()).thenAnswer((_) async {});
    when(() => interactor.checkAndScheduleAtStartup()).thenAnswer((_) async {});
  });

  SplashCubit build() => SplashCubit(
    appInitializer: appInitializer,
    userRepository: userRepository,
    weeklyNotificationInteractor: interactor,
    settingsRepository: settingsRepository,
  );

  void stubUser(Result<User> result) =>
      when(() => userRepository.getUser()).thenAnswer((_) async => result);

  blocTest<SplashCubit, SplashState>(
    'emits ready with the user and prepares notifications',
    setUp: () => stubUser(Result.ok(user)),
    build: build,
    act: (cubit) => cubit.prepareApp(),
    expect: () => [
      isA<SplashLoading>(),
      isA<SplashReady>()
          .having((s) => s.user, 'user', user)
          .having((s) => s.isFirstLaunchV3, 'isFirstLaunchV3', isTrue)
          .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue),
    ],
    verify: (_) {
      verifyInOrder([
        () => interactor.initialize(),
        () => interactor.checkAndScheduleAtStartup(),
      ]);
      verify(
        () => settingsRepository.setFirstLaunchV3(isFirstLaunch: false),
      ).called(1);
    },
  );

  blocTest<SplashCubit, SplashState>(
    'emits ready but not authenticated for an empty user',
    setUp: () => stubUser(Result.ok(User.empty())),
    build: build,
    act: (cubit) => cubit.prepareApp(),
    expect: () => [
      isA<SplashLoading>(),
      isA<SplashReady>().having(
        (s) => s.isAuthenticated,
        'isAuthenticated',
        isFalse,
      ),
    ],
  );

  blocTest<SplashCubit, SplashState>(
    'emits failure without loading the user when initialization fails',
    setUp: () => when(
      () => appInitializer.initialize(),
    ).thenAnswer((_) async => Result.error(error)),
    build: build,
    act: (cubit) => cubit.prepareApp(),
    expect: () => [isA<SplashLoading>(), isA<SplashFailure>()],
    verify: (_) {
      verifyZeroInteractions(userRepository);
      verifyZeroInteractions(interactor);
      verifyZeroInteractions(settingsRepository);
    },
  );

  blocTest<SplashCubit, SplashState>(
    'emits failure and keeps the first launch flag when the user fails',
    setUp: () => stubUser(Result.error(error)),
    build: build,
    act: (cubit) => cubit.prepareApp(),
    expect: () => [isA<SplashLoading>(), isA<SplashFailure>()],
    verify: (_) {
      verify(() => interactor.checkAndScheduleAtStartup()).called(1);
      verifyNever(
        () => settingsRepository.setFirstLaunchV3(
          isFirstLaunch: any(named: 'isFirstLaunch'),
        ),
      );
    },
  );
}
