import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/domain/models/week/event/event.dart';
import 'package:life_calendar/domain/models/week/goal/goal.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';
import 'package:life_calendar/domain/services/home_widget_service.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_cubit.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_state.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeekRepository extends Mock implements WeekRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockHomeWidgetService extends Mock implements HomeWidgetService {}

void main() {
  late _MockWeekRepository weekRepository;
  late _MockAnalyticsService analytics;
  late _MockHomeWidgetService homeWidget;

  const goal1 = Goal(id: 'g1', title: 'Run', isCompleted: false);
  const goal2 = Goal(id: 'g2', title: 'Read', isCompleted: true);
  final event1 = Event(id: 'e1', title: 'Meeting', date: DateTime(2026, 10, 6));
  final event2 = Event(id: 'e2', title: 'Party', date: DateTime(2026, 10, 9));

  final week = Week(
    id: 7,
    yearId: 0,
    start: DateTime(2026, 10, 5),
    end: DateTime(2026, 10, 11, 23, 59, 59),
    tense: WeekTense.current,
    assessment: WeekAssessment.poor,
    goals: const [goal1, goal2],
    events: [event1, event2],
    resume: 'Resume',
    photos: const ['a.jpg', 'b.jpg'],
  );
  final loaded = WeekSuccess(week: week, lastUpdate: DateTime(2000));
  final error = Exception('failure');

  Matcher successWith(Object? week) =>
      isA<WeekSuccess>().having((s) => s.week, 'week', week);

  void stubUpdates(Result<void> result) {
    when(
      () => weekRepository.updateAssessment(
        weekId: any(named: 'weekId'),
        assessment: any(named: 'assessment'),
      ),
    ).thenAnswer((_) async => result);
    when(
      () => weekRepository.updateGoals(
        weekId: any(named: 'weekId'),
        goals: any(named: 'goals'),
      ),
    ).thenAnswer((_) async => result);
    when(
      () => weekRepository.updateEvents(
        weekId: any(named: 'weekId'),
        events: any(named: 'events'),
      ),
    ).thenAnswer((_) async => result);
    when(
      () => weekRepository.updateResume(
        weekId: any(named: 'weekId'),
        resume: any(named: 'resume'),
      ),
    ).thenAnswer((_) async => result);
    when(
      () => weekRepository.updatePhotos(
        weekId: any(named: 'weekId'),
        photos: any(named: 'photos'),
      ),
    ).thenAnswer((_) async => result);
  }

  setUpAll(() {
    registerFallbackValue(WeekAssessment.poor);
    registerFallbackValue(WeekContentEvent.goal);
    registerFallbackValue(<Goal>[]);
    registerFallbackValue(<Event>[]);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    weekRepository = _MockWeekRepository();
    analytics = _MockAnalyticsService();
    homeWidget = _MockHomeWidgetService();

    stubUpdates(const Result.ok(null));
    when(() => analytics.logAddWeekContent(any())).thenAnswer((_) async {});
    when(() => analytics.logChangeWeekContent(any())).thenAnswer((_) async {});
    when(() => analytics.logDeleteWeekContent(any())).thenAnswer((_) async {});
    when(() => analytics.logAssessmentChange(any())).thenAnswer((_) async {});
    when(
      () => homeWidget.updateGoalsCount(goalsCount: any(named: 'goalsCount')),
    ).thenAnswer((_) async {});
    when(
      () =>
          homeWidget.updateEventsCount(eventsCount: any(named: 'eventsCount')),
    ).thenAnswer((_) async {});
  });

  WeekCubit build() => WeekCubit(
    weekRepository: weekRepository,
    analytics: analytics,
    homeWidgetService: homeWidget,
  );

  group('getWeek', () {
    blocTest<WeekCubit, WeekState>(
      'emits loading then the loaded week',
      setUp: () => when(
        () => weekRepository.getWeek(7),
      ).thenAnswer((_) async => Result.ok(week)),
      build: build,
      act: (cubit) => cubit.getWeek(weekId: 7),
      expect: () => [isA<WeekLoading>(), successWith(week)],
    );

    blocTest<WeekCubit, WeekState>(
      'emits failure when the repository fails',
      setUp: () => when(
        () => weekRepository.getWeek(7),
      ).thenAnswer((_) async => Result.error(error)),
      build: build,
      act: (cubit) => cubit.getWeek(weekId: 7),
      expect: () => [
        isA<WeekLoading>(),
        isA<WeekFailure>().having(
          (s) => s.exception.toString(),
          'exception',
          contains('7'),
        ),
      ],
    );

    blocTest<WeekCubit, WeekState>(
      'emits failure without a query when the id is null',
      build: build,
      act: (cubit) => cubit.getWeek(weekId: null),
      expect: () => [
        isA<WeekLoading>(),
        isA<WeekFailure>().having(
          (s) => s.exception,
          'exception',
          isA<FormatException>(),
        ),
      ],
      verify: (_) => verifyNever(() => weekRepository.getWeek(any())),
    );

    test('isLoading is true only while the week is loading', () async {
      final completer = Completer<Result<Week>>();
      when(() => weekRepository.getWeek(7)).thenAnswer((_) => completer.future);
      final cubit = build();

      final loading = cubit.getWeek(weekId: 7);
      expect(cubit.isLoading, isTrue);

      completer.complete(Result.ok(week));
      await loading;
      expect(cubit.isLoading, isFalse);

      await cubit.close();
    });
  });

  group('changeAssessment', () {
    blocTest<WeekCubit, WeekState>(
      'emits and saves the new assessment',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.changeAssessment(WeekAssessment.good),
      expect: () => [
        successWith(week.copyWith(assessment: WeekAssessment.good)),
      ],
      verify: (_) {
        verify(
          () => weekRepository.updateAssessment(
            weekId: 7,
            assessment: WeekAssessment.good,
          ),
        ).called(1);
        verify(
          () => analytics.logAssessmentChange(WeekAssessment.good),
        ).called(1);
      },
    );
  });

  group('toggleGoal', () {
    final goals = [goal1.copyWith(isCompleted: true), goal2];

    blocTest<WeekCubit, WeekState>(
      'completes only the matching goal',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.toggleGoal(goalId: 'g1', isCompleted: true),
      expect: () => [successWith(week.copyWith(goals: goals))],
      verify: (_) {
        verify(
          () => weekRepository.updateGoals(weekId: 7, goals: goals),
        ).called(1);
        verify(
          () => analytics.logChangeWeekContent(WeekContentEvent.goal),
        ).called(1);
        verifyZeroInteractions(homeWidget);
      },
    );
  });

  group('changeResume', () {
    blocTest<WeekCubit, WeekState>(
      'emits and saves the new resume',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.changeResume('New'),
      expect: () => [successWith(week.copyWith(resume: 'New'))],
      verify: (_) {
        verify(
          () => weekRepository.updateResume(weekId: 7, resume: 'New'),
        ).called(1);
        verify(
          () => analytics.logChangeWeekContent(WeekContentEvent.resume),
        ).called(1);
        verifyNever(() => analytics.logAddWeekContent(any()));
      },
    );

    blocTest<WeekCubit, WeekState>(
      'logs an added resume when there was none',
      build: build,
      seed: () => WeekSuccess(
        week: week.copyWith(resume: ''),
        lastUpdate: DateTime(2000),
      ),
      act: (cubit) => cubit.changeResume('New'),
      expect: () => [successWith(week.copyWith(resume: 'New'))],
      verify: (_) {
        verify(
          () => analytics.logAddWeekContent(WeekContentEvent.resume),
        ).called(1);
        verifyNever(() => analytics.logChangeWeekContent(any()));
      },
    );
  });

  group('deleteResume', () {
    blocTest<WeekCubit, WeekState>(
      'clears and saves an empty resume',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.deleteResume(),
      expect: () => [successWith(week.copyWith(resume: ''))],
      verify: (_) {
        verify(
          () => weekRepository.updateResume(weekId: 7, resume: ''),
        ).called(1);
        verify(
          () => analytics.logDeleteWeekContent(WeekContentEvent.resume),
        ).called(1);
      },
    );
  });

  group('addEvent', () {
    blocTest<WeekCubit, WeekState>(
      'inserts the event sorted by date and updates the widget',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.addEvent(DateTime(2026, 10, 7), 'Call'),
      expect: () => [
        isA<WeekSuccess>().having(
          (s) => s.week.events.map((e) => e.title),
          'event titles',
          ['Meeting', 'Call', 'Party'],
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => weekRepository.updateEvents(
            weekId: 7,
            events: captureAny(named: 'events'),
          ),
        ).captured;
        final events = captured.single as List<Event>;

        expect(events.map((e) => e.date), [
          DateTime(2026, 10, 6),
          DateTime(2026, 10, 7),
          DateTime(2026, 10, 9),
        ]);
        expect(events[1].id, isNotEmpty);
        expect(events.map((e) => e.id).toSet(), hasLength(3));
        verify(() => homeWidget.updateEventsCount(eventsCount: 3)).called(1);
        verify(
          () => analytics.logAddWeekContent(WeekContentEvent.event),
        ).called(1);
      },
    );
  });

  group('changeEvent', () {
    final changed = event2.copyWith(title: 'Concert');

    blocTest<WeekCubit, WeekState>(
      'replaces the event with the same id',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.changeEvent(changed),
      expect: () => [
        successWith(week.copyWith(events: [event1, changed])),
      ],
      verify: (_) {
        verify(
          () =>
              weekRepository.updateEvents(weekId: 7, events: [event1, changed]),
        ).called(1);
        verify(
          () => analytics.logChangeWeekContent(WeekContentEvent.event),
        ).called(1);
        verifyZeroInteractions(homeWidget);
      },
    );
  });

  group('deleteEvent', () {
    blocTest<WeekCubit, WeekState>(
      'removes the event and updates the widget',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.deleteEvent(event1),
      expect: () => [
        successWith(week.copyWith(events: [event2])),
      ],
      verify: (_) {
        verify(
          () => weekRepository.updateEvents(weekId: 7, events: [event2]),
        ).called(1);
        verify(() => homeWidget.updateEventsCount(eventsCount: 1)).called(1);
      },
    );

    blocTest<WeekCubit, WeekState>(
      'does nothing when the event is not found',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.deleteEvent(event1.copyWith(id: 'missing')),
      expect: () => <WeekState>[],
      verify: (_) {
        verifyZeroInteractions(weekRepository);
        verifyZeroInteractions(homeWidget);
        verifyZeroInteractions(analytics);
      },
    );
  });

  group('addGoal', () {
    blocTest<WeekCubit, WeekState>(
      'appends an uncompleted goal and updates the widget',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.addGoal('Swim'),
      expect: () => [
        isA<WeekSuccess>()
            .having((s) => s.week.goals.map((g) => g.title), 'goal titles', [
              'Run',
              'Read',
              'Swim',
            ])
            .having(
              (s) => s.week.goals.last.isCompleted,
              'last goal completed',
              isFalse,
            ),
      ],
      verify: (_) {
        final captured = verify(
          () => weekRepository.updateGoals(
            weekId: 7,
            goals: captureAny(named: 'goals'),
          ),
        ).captured;
        final goals = captured.single as List<Goal>;

        expect(goals.take(2), [goal1, goal2]);
        expect(goals.last.id, isNotEmpty);
        verify(() => homeWidget.updateGoalsCount(goalsCount: 3)).called(1);
        verify(
          () => analytics.logAddWeekContent(WeekContentEvent.goal),
        ).called(1);
      },
    );
  });

  group('changeGoal', () {
    final changed = goal1.copyWith(title: 'Swim');

    blocTest<WeekCubit, WeekState>(
      'replaces the goal with the same id',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.changeGoal(changed),
      expect: () => [
        successWith(week.copyWith(goals: [changed, goal2])),
      ],
      verify: (_) {
        verify(
          () => weekRepository.updateGoals(weekId: 7, goals: [changed, goal2]),
        ).called(1);
        verify(
          () => analytics.logChangeWeekContent(WeekContentEvent.goal),
        ).called(1);
        verifyZeroInteractions(homeWidget);
      },
    );
  });

  group('deleteGoal', () {
    blocTest<WeekCubit, WeekState>(
      'removes the goal and updates the widget',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.deleteGoal(goal1),
      expect: () => [
        successWith(week.copyWith(goals: [goal2])),
      ],
      verify: (_) {
        verify(
          () => weekRepository.updateGoals(weekId: 7, goals: [goal2]),
        ).called(1);
        verify(() => homeWidget.updateGoalsCount(goalsCount: 1)).called(1);
        verify(
          () => analytics.logDeleteWeekContent(WeekContentEvent.goal),
        ).called(1);
      },
    );
  });

  group('addPhotos', () {
    blocTest<WeekCubit, WeekState>(
      'appends the photo path',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.addPhotos(XFile('c.jpg')),
      expect: () => [
        successWith(week.copyWith(photos: ['a.jpg', 'b.jpg', 'c.jpg'])),
      ],
      verify: (_) {
        verify(
          () => weekRepository.updatePhotos(
            weekId: 7,
            photos: ['a.jpg', 'b.jpg', 'c.jpg'],
          ),
        ).called(1);
        verify(
          () => analytics.logAddWeekContent(WeekContentEvent.photo),
        ).called(1);
      },
    );
  });

  group('deletePhoto', () {
    blocTest<WeekCubit, WeekState>(
      'removes the photo at the index',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.deletePhoto(0),
      expect: () => [
        successWith(week.copyWith(photos: ['b.jpg'])),
      ],
      verify: (_) {
        verify(
          () => weekRepository.updatePhotos(weekId: 7, photos: ['b.jpg']),
        ).called(1);
        verify(
          () => analytics.logDeleteWeekContent(WeekContentEvent.photo),
        ).called(1);
      },
    );
  });

  final mutations = <String, Future<void> Function(WeekCubit)>{
    'changeAssessment': (cubit) => cubit.changeAssessment(WeekAssessment.good),
    'toggleGoal': (cubit) => cubit.toggleGoal(goalId: 'g1', isCompleted: true),
    'changeResume': (cubit) => cubit.changeResume('New'),
    'deleteResume': (cubit) => cubit.deleteResume(),
    'addEvent': (cubit) => cubit.addEvent(DateTime(2026, 10, 7), 'Call'),
    'changeEvent': (cubit) => cubit.changeEvent(event1.copyWith(title: 'X')),
    'deleteEvent': (cubit) => cubit.deleteEvent(event1),
    'addGoal': (cubit) => cubit.addGoal('Swim'),
    'changeGoal': (cubit) => cubit.changeGoal(goal1.copyWith(title: 'Swim')),
    'deleteGoal': (cubit) => cubit.deleteGoal(goal1),
    'addPhotos': (cubit) => cubit.addPhotos(XFile('c.jpg')),
    'deletePhoto': (cubit) => cubit.deletePhoto(0),
  };

  for (final MapEntry(key: name, value: mutate) in mutations.entries) {
    group(name, () {
      blocTest<WeekCubit, WeekState>(
        'rolls back to the previous state when saving fails',
        setUp: () => stubUpdates(Result.error(error)),
        build: build,
        seed: () => loaded,
        act: mutate,
        expect: () => [successWith(isNot(week)), loaded],
      );

      blocTest<WeekCubit, WeekState>(
        'does nothing when the week is not loaded',
        build: build,
        act: mutate,
        expect: () => <WeekState>[],
        verify: (_) {
          verifyZeroInteractions(weekRepository);
          verifyZeroInteractions(analytics);
          verifyZeroInteractions(homeWidget);
        },
      );
    });
  }
}
