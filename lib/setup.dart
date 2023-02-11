import 'package:get_it/get_it.dart';
import 'package:life_calendar/database/database.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/models/user_model.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';

final getIt = GetIt.instance;

Future setup() async {
  getIt.registerLazySingletonAsync<AppDatabase>(() async {
    final db = AppDatabase();
    await db.init();
    return db;
  });
  await getIt.getAsync<AppDatabase>();
  // getIt.registerSingletonWithDependencies<CalendarModel>(() => CalendarModel(), dependsOn: [AppDatabase]);
  getIt.registerLazySingleton<CalendarModel>(() => CalendarModel());
  // getIt.registerSingletonWithDependencies<CalendarController>(() => CalendarController(), dependsOn: [AppDatabase, CalendarModel]);
  getIt.registerLazySingleton<CalendarController>(() => CalendarController());
  getIt.registerLazySingleton<UserModel>(() => UserModel());
}