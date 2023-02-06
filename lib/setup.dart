import 'package:get_it/get_it.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/models/user_model.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<CalendarModel>(CalendarModel());
  getIt.registerSingleton<UserModel>(UserModel());
}