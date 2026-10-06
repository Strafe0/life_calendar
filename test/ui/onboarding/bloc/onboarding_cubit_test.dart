import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/repositories/onboarding_repository/onboarding_repository.dart';
import 'package:life_calendar/domain/models/onboarding/onboarding_page.dart';
import 'package:life_calendar/ui/onboarding/bloc/onboarding_cubit.dart';
import 'package:life_calendar/ui/onboarding/bloc/onboarding_state.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late _MockOnboardingRepository repository;

  final pages = [
    OnboardingPage(
      image: 'assets/onboarding/1.png',
      titleResolver: (_) => 'Title',
      contentResolver: (_) => 'Content',
    ),
  ];
  final error = Exception('failure');

  setUp(() => repository = _MockOnboardingRepository());

  OnboardingCubit build() => OnboardingCubit(onboardingRepository: repository);

  void stubPages(Result<List<OnboardingPage>> result) => when(
    () => repository.getPages(isFullOnboarding: any(named: 'isFullOnboarding')),
  ).thenAnswer((_) async => result);

  blocTest<OnboardingCubit, OnboardingState>(
    'emits loading then the pages',
    setUp: () => stubPages(Result.ok(pages)),
    build: build,
    act: (cubit) => cubit.loadPages(isFullOnboarding: false),
    expect: () => [isA<OnboardingLoading>(), OnboardingSuccess(pages: pages)],
    verify: (_) =>
        verify(() => repository.getPages(isFullOnboarding: false)).called(1),
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'emits failure when pages fail to load',
    setUp: () => stubPages(Result.error(error)),
    build: build,
    act: (cubit) => cubit.loadPages(isFullOnboarding: true),
    expect: () => [
      isA<OnboardingLoading>(),
      isA<OnboardingFailure>().having((s) => s.exception, 'exception', error),
    ],
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'ignores requests while pages are loading',
    setUp: () => stubPages(Result.ok(pages)),
    build: build,
    act: (cubit) async {
      unawaited(cubit.loadPages(isFullOnboarding: true));
      await cubit.loadPages(isFullOnboarding: false);
    },
    expect: () => [isA<OnboardingLoading>(), OnboardingSuccess(pages: pages)],
    verify: (_) {
      verify(() => repository.getPages(isFullOnboarding: true)).called(1);
      verifyNever(() => repository.getPages(isFullOnboarding: false));
    },
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'loads again after a failure',
    setUp: () => stubPages(Result.ok(pages)),
    build: build,
    seed: () => OnboardingFailure(error),
    act: (cubit) => cubit.loadPages(isFullOnboarding: true),
    expect: () => [isA<OnboardingLoading>(), OnboardingSuccess(pages: pages)],
  );
}
