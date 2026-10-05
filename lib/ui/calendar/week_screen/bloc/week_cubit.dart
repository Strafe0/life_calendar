import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/core/uuid/app_uuid.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/domain/models/week/event/event.dart';
import 'package:life_calendar/domain/models/week/goal/goal.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/services/home_widget_service.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_state.dart';
import 'package:life_calendar/utils/result.dart';

class WeekCubit extends Cubit<WeekState> {
  final AnalyticsService _analytics;
  final WeekRepository _weekRepository;
  final HomeWidgetService _homeWidgetService;

  WeekCubit({
    required WeekRepository weekRepository,
    required AnalyticsService analytics,
    required HomeWidgetService homeWidgetService,
  }) : _weekRepository = weekRepository,
       _analytics = analytics,
       _homeWidgetService = homeWidgetService,
       super(const WeekInitial());

  bool get isLoading => state == const WeekLoading();

  Future<void> getWeek({required int? weekId}) async {
    emit(const WeekLoading());

    if (weekId == null) {
      emit(const WeekFailure(FormatException('Cannot find week with null id')));
      return;
    }

    final weekResult = await _weekRepository.getWeek(weekId);

    switch (weekResult) {
      case Ok<Week>():
        logger.d('Got week $weekId');
        emit(WeekSuccess(week: weekResult.value, lastUpdate: DateTime.now()));
      case ResultError<Week>():
        emit(WeekFailure(Exception('Failed to get week with id: $weekId')));
        logger.e('Failed to receive week $weekId', error: weekResult.error);
    }
  }

  Future<void> changeAssessment(WeekAssessment newAssessment) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      emit(prevState.copyWith(assessment: newAssessment));

      final result = await _weekRepository.updateAssessment(
        weekId: prevState.week.id,
        assessment: newAssessment,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to change assessment. Returning previous state',
          error: result.error,
        );
      }

      unawaited(_analytics.logAssessmentChange(newAssessment));
    } else {
      logger.e('Cannot change assessment, because week is not ready');
    }
  }

  Future<void> toggleGoal({
    required String goalId,
    required bool isCompleted,
  }) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newGoals = prevState.week.goals.map((goal) {
        return goal.id == goalId
            ? goal.copyWith(isCompleted: isCompleted)
            : goal;
      }).toList();
      emit(prevState.copyWith(goals: newGoals));

      final result = await _weekRepository.updateGoals(
        weekId: prevState.week.id,
        goals: newGoals,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to change goal. Returning previous state',
          error: result.error,
        );
      }

      unawaited(_analytics.logChangeWeekContent(WeekContentEvent.goal));
    } else {
      logger.e('Cannot change goal, because week is not ready');
    }
  }

  Future<void> changeResume(String resume) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      emit(prevState.copyWith(resume: resume));

      final result = await _weekRepository.updateResume(
        weekId: prevState.week.id,
        resume: resume,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to change resume. Returning previous state',
          error: result.error,
        );
      }

      unawaited(
        prevState.week.resume.isEmpty
            ? _analytics.logAddWeekContent(WeekContentEvent.resume)
            : _analytics.logChangeWeekContent(WeekContentEvent.resume),
      );
    } else {
      logger.e('Cannot change resume, because week is not ready');
    }
  }

  Future<void> deleteResume() async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      emit(prevState.copyWith(resume: ''));

      final result = await _weekRepository.updateResume(
        weekId: prevState.week.id,
        resume: '',
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to delete resume. Returning previous state',
          error: result.error,
        );
      }

      unawaited(_analytics.logDeleteWeekContent(WeekContentEvent.resume));
    } else {
      logger.e('Cannot delete resume, because week is not ready');
    }
  }

  Future<void> addEvent(DateTime date, String title) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newEventList = [
        ...prevState.week.events,
        Event(id: AppUuid.generateTimeBasedUuid(), title: title, date: date),
      ]..sort((a, b) => a.date.compareTo(b.date));

      emit(prevState.copyWith(events: newEventList));

      final result = await _weekRepository.updateEvents(
        weekId: prevState.week.id,
        events: newEventList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to add new event. Returning previous state',
          error: result.error,
        );
      }

      unawaited(
        _homeWidgetService.updateEventsCount(eventsCount: newEventList.length),
      );
      unawaited(_analytics.logAddWeekContent(WeekContentEvent.event));
    } else {
      logger.e('Cannot change event, because week is not ready');
    }
  }

  Future<void> changeEvent(Event newEvent) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newEventList = [
        for (final e in prevState.week.events)
          if (e.id == newEvent.id) newEvent else e,
      ];

      emit(prevState.copyWith(events: newEventList));

      final result = await _weekRepository.updateEvents(
        weekId: prevState.week.id,
        events: newEventList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to change event. Returning previous state',
          error: result.error,
        );
      }

      unawaited(_analytics.logChangeWeekContent(WeekContentEvent.event));
    } else {
      logger.e('Cannot change event, because week is not ready');
    }
  }

  Future<void> deleteEvent(Event event) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final eventIndex = prevState.week.events.indexWhere(
        (e) => e.id == event.id,
      );

      if (eventIndex == -1) {
        logger.e('Cannot delete event ${event.id}, because it was not found');
        return;
      }

      final newEventList = [...prevState.week.events]..removeAt(eventIndex);

      emit(prevState.copyWith(events: newEventList));

      final result = await _weekRepository.updateEvents(
        weekId: prevState.week.id,
        events: newEventList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to delete event. Returning previous state',
          error: result.error,
        );
      }

      unawaited(
        _homeWidgetService.updateEventsCount(eventsCount: newEventList.length),
      );
      unawaited(_analytics.logChangeWeekContent(WeekContentEvent.event));
    } else {
      logger.e('Cannot delete event, because week is not ready');
    }
  }

  Future<void> addGoal(String title) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newGoalList = [
        ...prevState.week.goals,
        Goal(
          id: AppUuid.generateTimeBasedUuid(),
          title: title,
          isCompleted: false,
        ),
      ];

      emit(prevState.copyWith(goals: newGoalList));

      final result = await _weekRepository.updateGoals(
        weekId: prevState.week.id,
        goals: newGoalList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to add new goal. Returning previous state',
          error: result.error,
        );
      }

      unawaited(
        _homeWidgetService.updateGoalsCount(goalsCount: newGoalList.length),
      );
      unawaited(_analytics.logAddWeekContent(WeekContentEvent.goal));
    } else {
      logger.e('Cannot add goal, because week is not ready');
    }
  }

  Future<void> changeGoal(Goal newGoal) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newGoalList = [
        for (final g in prevState.week.goals)
          if (g.id == newGoal.id) newGoal else g,
      ];

      emit(prevState.copyWith(goals: newGoalList));

      final result = await _weekRepository.updateGoals(
        weekId: prevState.week.id,
        goals: newGoalList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to change goal. Returning previous state',
          error: result.error,
        );
      }

      unawaited(_analytics.logChangeWeekContent(WeekContentEvent.goal));
    } else {
      logger.e('Cannot change goal, because week is not ready');
    }
  }

  Future<void> deleteGoal(Goal goal) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newGoalList = [
        for (final g in prevState.week.goals)
          if (g.id != goal.id) g,
      ];

      emit(prevState.copyWith(goals: newGoalList));

      final result = await _weekRepository.updateGoals(
        weekId: prevState.week.id,
        goals: newGoalList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to delete goal. Returning previous state',
          error: result.error,
        );
      }

      unawaited(
        _homeWidgetService.updateGoalsCount(goalsCount: newGoalList.length),
      );
      unawaited(_analytics.logDeleteWeekContent(WeekContentEvent.goal));
    } else {
      logger.e('Cannot delete goal, because week is not ready');
    }
  }

  Future<void> addPhotos(XFile photo) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newPhotoList = [...prevState.week.photos, photo.path];

      emit(prevState.copyWith(photos: newPhotoList));

      final result = await _weekRepository.updatePhotos(
        weekId: prevState.week.id,
        photos: newPhotoList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to add new goal. Returning previous state',
          error: result.error,
        );
      }

      unawaited(_analytics.logAddWeekContent(WeekContentEvent.photo));
    } else {
      logger.e('Cannot change goal, because week is not ready');
    }
  }

  Future<void> deletePhoto(int index) async {
    final prevState = state;
    if (prevState is WeekSuccess) {
      final newPhotoList = [...prevState.week.photos]..removeAt(index);

      emit(prevState.copyWith(photos: newPhotoList));

      final result = await _weekRepository.updatePhotos(
        weekId: prevState.week.id,
        photos: newPhotoList,
      );

      if (result is ResultError) {
        emit(prevState);
        logger.e(
          'Failed to delete photo. Returning previous state',
          error: result.error,
        );
      }

      unawaited(_analytics.logAddWeekContent(WeekContentEvent.photo));
    } else {
      logger.e('Cannot delete photo, because week is not ready');
    }
  }
}
