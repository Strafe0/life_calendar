import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/ui/user/bloc/user_bloc.dart';
import 'package:life_calendar/ui/user/bloc/user_event.dart';
import 'package:life_calendar/ui/user/bloc/user_state.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserRepository extends Mock implements UserRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockUserRepository userRepository;
  late _MockAnalyticsService analytics;

  final user = User(id: 'id', birthdate: DateTime(1990, 5, 15), lifeSpan: 80);
  final error = Exception('failure');

  setUp(() {
    userRepository = _MockUserRepository();
    analytics = _MockAnalyticsService();
    when(
      () => analytics.logChangeLifespan(any(), any()),
    ).thenAnswer((_) async {});
  });

  UserBloc build() =>
      UserBloc(userRepository: userRepository, analytics: analytics);

  test('initial state is UserInitial and age is null', () {
    final bloc = build();

    expect(bloc.state, isA<UserInitial>());
    expect(bloc.age, isNull);
  });

  blocTest<UserBloc, UserState>(
    'emits UserSuccess on UserReceived',
    build: build,
    act: (bloc) => bloc.add(UserReceived(user)),
    expect: () => [UserSuccess(user: user)],
    verify: (bloc) => expect(bloc.age, user.age()),
  );

  group('UserLoadingTriggered', () {
    blocTest<UserBloc, UserState>(
      'emits loading then success when the user is loaded',
      setUp: () => when(
        () => userRepository.getUser(),
      ).thenAnswer((_) async => Result.ok(user)),
      build: build,
      act: (bloc) => bloc.add(const UserLoadingTriggered()),
      expect: () => [isA<UserLoading>(), UserSuccess(user: user)],
    );

    blocTest<UserBloc, UserState>(
      'emits loading then failure when the repository fails',
      setUp: () => when(
        () => userRepository.getUser(),
      ).thenAnswer((_) async => Result.error(error)),
      build: build,
      act: (bloc) => bloc.add(const UserLoadingTriggered()),
      expect: () => [isA<UserLoading>(), UserFailure(error)],
    );
  });

  group('UserChangeLifeSpanRequested', () {
    void stubReduce(Result<void> result) => when(
      () => userRepository.reduceLifeSpan(
        oldLifeSpan: any(named: 'oldLifeSpan'),
        newLifeSpan: any(named: 'newLifeSpan'),
      ),
    ).thenAnswer((_) async => result);

    void stubIncrease(Result<void> result) => when(
      () => userRepository.increaseLifeSpan(
        oldLifeSpan: any(named: 'oldLifeSpan'),
        newLifeSpan: any(named: 'newLifeSpan'),
      ),
    ).thenAnswer((_) async => result);

    blocTest<UserBloc, UserState>(
      'reduces the lifespan when the new value is smaller',
      setUp: () => stubReduce(const Result.ok(null)),
      build: build,
      seed: () => UserSuccess(user: user),
      act: (bloc) => bloc.add(const UserChangeLifeSpanRequested(70)),
      expect: () => [
        isA<UserLoading>(),
        UserSuccess(user: user.copyWith(lifeSpan: 70)),
      ],
      verify: (_) {
        verify(
          () => userRepository.reduceLifeSpan(oldLifeSpan: 80, newLifeSpan: 70),
        ).called(1);
        verifyNever(
          () => userRepository.increaseLifeSpan(
            oldLifeSpan: any(named: 'oldLifeSpan'),
            newLifeSpan: any(named: 'newLifeSpan'),
          ),
        );
        verify(() => analytics.logChangeLifespan(80, 70)).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'increases the lifespan when the new value is bigger',
      setUp: () => stubIncrease(const Result.ok(null)),
      build: build,
      seed: () => UserSuccess(user: user),
      act: (bloc) => bloc.add(const UserChangeLifeSpanRequested(90)),
      expect: () => [
        isA<UserLoading>(),
        UserSuccess(user: user.copyWith(lifeSpan: 90)),
      ],
      verify: (_) {
        verify(
          () =>
              userRepository.increaseLifeSpan(oldLifeSpan: 80, newLifeSpan: 90),
        ).called(1);
        verifyNever(
          () => userRepository.reduceLifeSpan(
            oldLifeSpan: any(named: 'oldLifeSpan'),
            newLifeSpan: any(named: 'newLifeSpan'),
          ),
        );
        verify(() => analytics.logChangeLifespan(80, 90)).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits failure when the repository fails',
      setUp: () => stubReduce(Result.error(error)),
      build: build,
      seed: () => UserSuccess(user: user),
      act: (bloc) => bloc.add(const UserChangeLifeSpanRequested(70)),
      expect: () => [isA<UserLoading>(), UserFailure(error)],
    );

    blocTest<UserBloc, UserState>(
      'is ignored when the user is not loaded',
      build: build,
      act: (bloc) => bloc.add(const UserChangeLifeSpanRequested(70)),
      expect: () => <UserState>[],
      verify: (_) {
        verifyZeroInteractions(userRepository);
        verifyZeroInteractions(analytics);
      },
    );
  });
}
