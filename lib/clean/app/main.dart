import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:life_calendar/clean/app/bloc_observer.dart';
import 'package:life_calendar/clean/features/auth/data/repositories/fake_user_repository.dart';
import 'package:life_calendar/clean/features/auth/data/repositories/user_repository.dart';
import 'package:life_calendar/clean/features/calendar/data/repositories/fake_week_repository.dart';
import 'package:life_calendar/clean/features/calendar/data/repositories/week_repository.dart';

import 'calendar_app.dart';

void main() async {
  Bloc.observer = AppBlocObserver();
  runApp(await bootstrap());
}

Future<CalendarApp> bootstrap() async {
  UserRepository userRepository = FakeUserRepository();
  WeekRepository weekRepository = FakeWeekRepository();

  return Future.value(
    CalendarApp(
      userRepository: userRepository,
      weekRepository: weekRepository,
    ),
  );
}
