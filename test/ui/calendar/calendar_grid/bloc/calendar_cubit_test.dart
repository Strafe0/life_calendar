import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository.dart';
import 'package:life_calendar/domain/models/week/event/event.dart';
import 'package:life_calendar/domain/models/week/goal/goal.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/services/home_widget_service.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_cubit.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_state.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/models/week_box.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:life_calendar/utils/calendar/calendar_size.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeekRepository extends Mock implements WeekRepository {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockHomeWidgetService extends Mock implements HomeWidgetService {}

void main() {
  late _MockWeekRepository weekRepository;
  late _MockSettingsRepository settingsRepository;
  late _MockHomeWidgetService homeWidget;

  const size = CalendarSize(
    weekBoxSide: 10,
    weekBoxPaddingX: 1,
    weekBoxPaddingY: 2,
    vrtPadding: 3,
    horPadding: 4,
    labelVrtPadding: 5,
    labelHorPadding: 6,
  );
  final weeks = CalendarGenerator(
    birthday: DateTime(1990, 5, 15),
    lifeSpan: 2,
    time: () => DateTime(1991, 1, 9),
  ).generateWeeks();
  final currentWeek = weeks[34].copyWith(
    goals: const [Goal(id: 'g', title: 'Goal', isCompleted: false)],
    events: [
      Event(id: 'e1', title: 'One', date: DateTime(1991, 1, 8)),
      Event(id: 'e2', title: 'Two', date: DateTime(1991, 1, 9)),
    ],
  );
  final error = Exception('failure');

  setUp(() {
    weekRepository = _MockWeekRepository();
    settingsRepository = _MockSettingsRepository();
    homeWidget = _MockHomeWidgetService();

    when(
      () => homeWidget.updateProgress(
        currentWeekNumber: any(named: 'currentWeekNumber'),
        totalWeeksCount: any(named: 'totalWeeksCount'),
        currentWeekGoalsCount: any(named: 'currentWeekGoalsCount'),
        currentWeekEventsCount: any(named: 'currentWeekEventsCount'),
      ),
    ).thenAnswer((_) async {});
  });

  CalendarCubit build() => CalendarCubit(
    weekRepository: weekRepository,
    settingsRepository: settingsRepository,
    homeWidgetService: homeWidget,
  );

  Matcher successWithIds(Object? ids) => isA<CalendarSuccess>().having(
    (s) => s.weeks.map((b) => b.weekId),
    'week ids',
    ids,
  );

  group('getWeeks', () {
    void stubWeeks(Result<List<Week>> result) =>
        when(() => weekRepository.getWeeks()).thenAnswer((_) async => result);

    void stubCurrentWeek(Result<Week> result) => when(
      () => weekRepository.updateCurrentWeek(),
    ).thenAnswer((_) async => result);

    blocTest<CalendarCubit, CalendarState>(
      'emits a box for every week and updates the widget',
      setUp: () {
        stubCurrentWeek(Result.ok(currentWeek));
        stubWeeks(Result.ok(weeks));
      },
      build: build,
      act: (cubit) => cubit.getWeeks(calendarSize: size),
      expect: () => [
        isA<CalendarLoading>(),
        successWithIds(weeks.map((w) => w.id)),
      ],
      verify: (_) {
        verify(
          () => homeWidget.updateProgress(
            currentWeekNumber: 35,
            totalWeeksCount: weeks.length,
            currentWeekGoalsCount: 1,
            currentWeekEventsCount: 2,
          ),
        ).called(1);
        verifyNever(() => settingsRepository.isFirstLaunch());
      },
    );

    blocTest<CalendarCubit, CalendarState>(
      'lays out one row per year starting from the first column',
      setUp: () {
        stubCurrentWeek(Result.ok(currentWeek));
        stubWeeks(Result.ok(weeks));
      },
      build: build,
      act: (cubit) => cubit.getWeeks(calendarSize: size),
      verify: (cubit) {
        final boxes = (cubit.state as CalendarSuccess).weeks;
        var column = 0;

        for (var i = 0; i < boxes.length; i++) {
          if (i > 0 && boxes[i].yearId != boxes[i - 1].yearId) column = 0;

          final rect = boxes[i].rect;
          expect(boxes[i].week, weeks[i]);
          expect(
            rect.center,
            Offset(15.0 + 11 * column, 13.0 + 12 * boxes[i].yearId),
            reason: 'week ${boxes[i].weekId}',
          );
          expect(rect.width, 10);
          expect(rect.height, 10);
          column++;
        }
        expect(boxes.last.yearId, 2);
      },
    );

    blocTest<CalendarCubit, CalendarState>(
      'skips the widget update when the current week fails to update',
      setUp: () {
        stubCurrentWeek(Result.error(error));
        stubWeeks(Result.ok(weeks));
      },
      build: build,
      act: (cubit) => cubit.getWeeks(calendarSize: size),
      expect: () => [
        isA<CalendarLoading>(),
        successWithIds(weeks.map((w) => w.id)),
      ],
      verify: (_) => verifyZeroInteractions(homeWidget),
    );

    blocTest<CalendarCubit, CalendarState>(
      'emits failure when weeks fail to load',
      setUp: () {
        stubCurrentWeek(Result.ok(currentWeek));
        stubWeeks(Result.error(error));
      },
      build: build,
      act: (cubit) => cubit.getWeeks(calendarSize: size),
      expect: () => [isA<CalendarLoading>(), CalendarFailure(error)],
      verify: (_) => verifyZeroInteractions(homeWidget),
    );

    blocTest<CalendarCubit, CalendarState>(
      'emits an empty calendar on the first launch',
      setUp: () {
        stubCurrentWeek(Result.error(error));
        stubWeeks(const Result.ok([]));
        when(
          () => settingsRepository.isFirstLaunch(),
        ).thenAnswer((_) async => true);
      },
      build: build,
      act: (cubit) => cubit.getWeeks(calendarSize: size),
      expect: () => [isA<CalendarLoading>(), successWithIds(isEmpty)],
    );

    blocTest<CalendarCubit, CalendarState>(
      'emits failure for an empty calendar after the first launch',
      setUp: () {
        stubCurrentWeek(Result.error(error));
        stubWeeks(const Result.ok([]));
        when(
          () => settingsRepository.isFirstLaunch(),
        ).thenAnswer((_) async => false);
      },
      build: build,
      act: (cubit) => cubit.getWeeks(calendarSize: size),
      expect: () => [isA<CalendarLoading>(), isA<CalendarFailure>()],
      verify: (_) => verifyZeroInteractions(homeWidget),
    );
  });

  group('updateWeek', () {
    final boxes = [
      for (final week in weeks.take(3))
        WeekBox.fromWeek(
          week: week,
          rect: RRect.fromLTRBR(
            week.id * 10,
            0,
            week.id * 10 + 8,
            8,
            Radius.zero,
          ),
        ),
    ];
    final loaded = CalendarSuccess(
      weeks: boxes,
      lastUpdateTime: DateTime(2000),
    );
    final changed = weeks[1].copyWith(assessment: WeekAssessment.good);

    blocTest<CalendarCubit, CalendarState>(
      'replaces the box of the week and keeps its rect',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.updateWeek(week: changed),
      expect: () => [
        isA<CalendarSuccess>()
            .having((s) => s.weeks[1].week, 'changed week', changed)
            .having((s) => s.weeks[1].rect, 'rect', boxes[1].rect)
            .having((s) => s.weeks[0], 'first box', same(boxes[0]))
            .having((s) => s.weeks[2], 'last box', same(boxes[2])),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'does nothing for an unknown week',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.updateWeek(week: weeks[5]),
      expect: () => <CalendarState>[],
    );

    blocTest<CalendarCubit, CalendarState>(
      'does nothing before the calendar is loaded',
      build: build,
      act: (cubit) => cubit.updateWeek(week: changed),
      expect: () => <CalendarState>[],
    );
  });

  group('hasChangedWeeks', () {
    void stubLifespan(int? lifeSpan) => when(
      () => settingsRepository.getLifespan(),
    ).thenAnswer((_) async => lifeSpan);

    void stubChanges(Result<bool> result) => when(
      () => weekRepository.hasChangesInRange(
        startYearId: any(named: 'startYearId'),
        endYearId: any(named: 'endYearId'),
      ),
    ).thenAnswer((_) async => result);

    test('checks the years between new and old lifespan on reduce', () async {
      stubLifespan(80);
      stubChanges(const Result.ok(true));

      expect(await build().hasChangedWeeks(newLifeSpan: 70), isTrue);
      verify(
        () => weekRepository.hasChangesInRange(startYearId: 70, endYearId: 80),
      ).called(1);
    });

    test('checks the years between old and new lifespan on increase', () async {
      stubLifespan(80);
      stubChanges(const Result.ok(false));

      expect(await build().hasChangedWeeks(newLifeSpan: 90), isFalse);
      verify(
        () => weekRepository.hasChangesInRange(startYearId: 80, endYearId: 90),
      ).called(1);
    });

    test('returns false without a stored lifespan', () async {
      stubLifespan(null);

      expect(await build().hasChangedWeeks(newLifeSpan: 70), isFalse);
      verifyZeroInteractions(weekRepository);
    });

    test('returns false when the check fails', () async {
      stubLifespan(80);
      stubChanges(Result.error(error));

      expect(await build().hasChangedWeeks(newLifeSpan: 70), isFalse);
    });
  });
}
