import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/repositories/auth_repository/auth_repository.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/ui/registration/bloc/registration_cubit.dart';
import 'package:life_calendar/ui/registration/bloc/registration_state.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockWeekRepository extends Mock implements WeekRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockWeekRepository weekRepository;
  late _MockAnalyticsService analytics;

  final birthday = DateTime(1990, 5, 15);
  const lifeSpan = 60;
  final user = User(id: 'id', birthdate: birthday, lifeSpan: lifeSpan);
  final error = Exception('failure');

  setUpAll(() => registerFallbackValue(<Week>[]));

  setUp(() {
    authRepository = _MockAuthRepository();
    weekRepository = _MockWeekRepository();
    analytics = _MockAnalyticsService();

    when(
      () => analytics.logRegistration(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => weekRepository.insertWeeks(any()),
    ).thenAnswer((_) async => const Result.ok(null));
  });

  RegistrationCubit build() => RegistrationCubit(
    authRepository: authRepository,
    weekRepository: weekRepository,
    analytics: analytics,
  );

  void stubRegister(Result<User> result) => when(
    () => authRepository.register(
      birthdate: any(named: 'birthdate'),
      lifeSpan: any(named: 'lifeSpan'),
    ),
  ).thenAnswer((_) async => result);

  Future<void> register(RegistrationCubit cubit) =>
      cubit.register(birthday: birthday, lifeSpan: lifeSpan);

  blocTest<RegistrationCubit, RegistrationState>(
    'saves the user, generates the calendar and emits success',
    setUp: () => stubRegister(Result.ok(user)),
    build: build,
    act: register,
    expect: () => [
      isA<RegistrationLoading>(),
      isA<RegistrationSuccess>().having((s) => s.user, 'user', user),
    ],
    verify: (_) {
      verify(
        () => authRepository.register(birthdate: birthday, lifeSpan: lifeSpan),
      ).called(1);

      final captured = verify(
        () => weekRepository.insertWeeks(captureAny()),
      ).captured;
      final inserted = captured.single as List<Week>;
      final expected = CalendarGenerator(
        birthday: birthday,
        lifeSpan: lifeSpan,
        time: () => DateTime(2026, 10, 6),
      ).generateWeeks();

      expect(
        inserted.map((w) => (w.id, w.yearId, w.start, w.end)),
        expected.map((w) => (w.id, w.yearId, w.start, w.end)),
      );
      verify(() => analytics.logRegistration(birthday, lifeSpan)).called(1);
    },
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'emits calendar failure when weeks are not saved',
    setUp: () {
      stubRegister(Result.ok(user));
      when(
        () => weekRepository.insertWeeks(any()),
      ).thenAnswer((_) async => Result.error(error));
    },
    build: build,
    act: register,
    expect: () => [
      isA<RegistrationLoading>(),
      isA<RegistrationCalendarFailure>(),
    ],
  );

  blocTest<RegistrationCubit, RegistrationState>(
    'emits failure without generating weeks when the user is not saved',
    setUp: () => stubRegister(Result.error(error)),
    build: build,
    act: register,
    expect: () => [isA<RegistrationLoading>(), isA<RegistrationFailure>()],
    verify: (_) => verifyNever(() => weekRepository.insertWeeks(any())),
  );
}
