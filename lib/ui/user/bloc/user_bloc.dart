import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/ui/user/bloc/user_event.dart';
import 'package:life_calendar/ui/user/bloc/user_state.dart';
import 'package:life_calendar/utils/result.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final AnalyticsService _analytics;

  UserBloc({
    required UserRepository userRepository,
    required AnalyticsService analytics,
  }) : _userRepository = userRepository,
       _analytics = analytics,
       super(const UserInitial()) {
    on<UserReceived>((event, emit) => emit(UserSuccess(user: event.user)));
    on<UserLoadingTriggered>(_getUser);
    on<UserChangeLifeSpanRequested>(_changeLifeSpan);
  }

  int? get age =>
      state is UserSuccess ? (state as UserSuccess).user.age() : null;

  Future<void> _getUser(UserEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    final userResult = await _userRepository.getUser();

    switch (userResult) {
      case Ok<User>():
        logger.d(
          'Got user ${userResult.value.id} '
          '(${userResult.value.birthdate}, '
          '${userResult.value.lifeSpan})',
        );
        emit(UserSuccess(user: userResult.value));
      case ResultError<User>():
        logger.d('Failed to get user', error: userResult.error);
        emit(UserFailure(userResult.error));
    }
  }

  Future<void> _changeLifeSpan(
    UserChangeLifeSpanRequested event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;

    if (currentState is! UserSuccess) {
      logger.e('Cannot change life span, because user is not ready');
      return;
    }

    final newLifeSpan = event.lifeSpan;
    final oldLifeSpan = currentState.user.lifeSpan;

    emit(const UserLoading());

    final resultFuture = newLifeSpan < oldLifeSpan
        ? _userRepository.reduceLifeSpan(
            oldLifeSpan: oldLifeSpan,
            newLifeSpan: newLifeSpan,
          )
        : _userRepository.increaseLifeSpan(
            oldLifeSpan: oldLifeSpan,
            newLifeSpan: newLifeSpan,
          );

    final result = await resultFuture;

    switch (result) {
      case Ok<void>():
        logger.d(
          'Changed user life span '
          'from $oldLifeSpan to $newLifeSpan',
        );
        emit(
          UserSuccess(user: currentState.user.copyWith(lifeSpan: newLifeSpan)),
        );
        unawaited(_analytics.logChangeLifespan(oldLifeSpan, newLifeSpan));
      case ResultError<void>():
        logger.e('Failed to change user life span', error: result.error);
        emit(UserFailure(result.error));
    }
  }
}
