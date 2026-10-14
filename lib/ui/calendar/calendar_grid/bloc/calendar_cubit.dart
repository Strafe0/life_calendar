import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/services/home_widget_service.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_state.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/models/week_box.dart';
import 'package:life_calendar/utils/calendar/calendar_size.dart';
import 'package:life_calendar/utils/result.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final WeekRepository _weekRepository;
  final SettingsRepository _settingsRepository;
  final HomeWidgetService _homeWidgetService;

  CalendarCubit({
    required WeekRepository weekRepository,
    required SettingsRepository settingsRepository,
    required HomeWidgetService homeWidgetService,
  }) : _weekRepository = weekRepository,
       _settingsRepository = settingsRepository,
       _homeWidgetService = homeWidgetService,
       super(const CalendarInitial());

  Future<void> getWeeks({required CalendarSize calendarSize}) async {
    emit(const CalendarLoading());

    final updateCurrWeekResult = await _weekRepository.updateCurrentWeek();

    final weeksResult = await _weekRepository.getWeeks();

    switch (weeksResult) {
      case Ok<List<Week>>():
        logger.d('Got ${weeksResult.value.length} weeks');

        if (weeksResult.value.isEmpty) {
          final isFirstLaunch = await _settingsRepository.isFirstLaunch();
          if (!isFirstLaunch) {
            logger.e('Week list is empty and it is not first launch');
            emit(CalendarFailure(Exception('No data')));
            return;
          }
        }

        await _updateHomeWidget(updateCurrWeekResult, weeksResult.value.length);

        emit(
          CalendarSuccess(
            weeks: _prepareWeekBoxes(weeksResult.value, calendarSize),
            lastUpdateTime: DateTime.now(),
          ),
        );
      case ResultError<List<Week>>():
        logger.e('Failed to get weeks', error: weeksResult.error);
        emit(CalendarFailure(weeksResult.error));
    }
  }

  void updateWeek({required Week week}) {
    final currentState = state;
    if (currentState is! CalendarSuccess) {
      return;
    }

    final weekBoxIndex = currentState.weeks.indexWhere(
      (w) => w.weekId == week.id,
    );
    if (weekBoxIndex == -1) {
      return;
    }

    final newWeeks = [...currentState.weeks];
    newWeeks[weekBoxIndex] = WeekBox.fromWeek(
      week: week,
      rect: newWeeks[weekBoxIndex].rect,
    );

    emit(CalendarSuccess(weeks: newWeeks, lastUpdateTime: DateTime.now()));
  }

  List<WeekBox> _prepareWeekBoxes(List<Week> weeks, CalendarSize calendarSize) {
    final y0 =
        calendarSize.vrtPadding +
        calendarSize.labelVrtPadding +
        calendarSize.weekBoxSide / 2;

    int yearId = 0;
    int previousYearsWeekCount = 0;
    int weekInYearCount = 0;

    return List.generate(weeks.length, growable: false, (weekId) {
      weekInYearCount++;

      final x0 =
          calendarSize.horPadding +
          calendarSize.labelHorPadding +
          calendarSize.weekBoxSide / 2;
      final y =
          y0 +
          yearId * (calendarSize.weekBoxSide + calendarSize.weekBoxPaddingY);

      final x =
          x0 +
          (weekId - previousYearsWeekCount) *
              (calendarSize.weekBoxSide + calendarSize.weekBoxPaddingX);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y),
          width: calendarSize.weekBoxSide,
          height: calendarSize.weekBoxSide,
        ),
        const Radius.circular(1.5),
      );

      if (weekId + 1 < weeks.length && weeks[weekId + 1].yearId > yearId) {
        previousYearsWeekCount += weekInYearCount;
        weekInYearCount = 0;
        yearId++;
      }

      return WeekBox(
        weekId: weeks[weekId].id,
        yearId: weeks[weekId].yearId,
        rect: rrect,
        week: weeks[weekId],
      );
    });
  }

  Future<bool> hasChangedWeeks({required int newLifeSpan}) async {
    final oldLifeSpan = await _settingsRepository.getLifespan();

    if (oldLifeSpan == null) {
      logger.w('Failed to check changed weeks, because old lifespan is null');
      return false;
    }

    // Only a reduction deletes weeks: the years after the new lifespan.
    if (newLifeSpan >= oldLifeSpan) return false;

    final result = await _weekRepository.hasChangesInRange(
      startYearId: newLifeSpan + 1,
      endYearId: oldLifeSpan,
    );

    return switch (result) {
      Ok<bool>() => result.value,
      _ => false,
    };
  }

  Future<void> _updateHomeWidget(
    Result<Week> currentWeekResult,
    int weeksCount,
  ) async {
    switch (currentWeekResult) {
      case Ok<Week>():
        await _homeWidgetService.updateProgress(
          currentWeekNumber: currentWeekResult.value.id + 1,
          totalWeeksCount: weeksCount,
          currentWeekGoalsCount: currentWeekResult.value.goals.length,
          currentWeekEventsCount: currentWeekResult.value.events.length,
        );
      case ResultError<Week>():
        logger.w(
          'Failed to update current week in DB',
          error: currentWeekResult.error,
        );
    }
  }
}
