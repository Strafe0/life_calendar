import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/data/repositories/auth_repository/auth_repository.dart';
import 'package:life_calendar/data/repositories/week_repository/week_repository.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/ui/registration/bloc/registration_state.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:life_calendar/utils/result.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final AuthRepository _authRepository;
  final WeekRepository _weekRepository;
  final AnalyticsService _analytics;

  RegistrationCubit({
    required AuthRepository authRepository,
    required WeekRepository weekRepository,
    required AnalyticsService analytics,
  }) : _authRepository = authRepository,
       _weekRepository = weekRepository,
       _analytics = analytics,
       super(const RegistrationInitial());

  Future<void> register({
    required DateTime birthday,
    required int lifeSpan,
  }) async {
    emit(const RegistrationLoading());
    logger.d('Started registration');

    final result = await _authRepository.register(
      birthdate: birthday,
      lifeSpan: lifeSpan,
    );

    switch (result) {
      case Ok<User>():
        logger.d('Successfully saved user');
        final generator = CalendarGenerator(
          birthday: birthday,
          lifeSpan: lifeSpan,
        );
        final weeks = generator.generateWeeks();
        final weekGenerationResult = await _weekRepository.insertWeeks(weeks);

        switch (weekGenerationResult) {
          case Ok():
            logger.d('Successfully registered and generated weeks');
            emit(RegistrationSuccess(result.value));
            unawaited(_analytics.logRegistration(birthday, lifeSpan));
          case ResultError():
            logger.e('User saved, but weeks weren\'t generated');
            emit(const RegistrationCalendarFailure());
        }
      case ResultError():
        logger.e('Registration is failed', error: result.error);
        emit(const RegistrationFailure());
    }
  }
}
