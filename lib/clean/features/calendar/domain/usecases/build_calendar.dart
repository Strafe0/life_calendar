import 'package:life_calendar/clean/common/utils/calendar_utils.dart';
import 'package:life_calendar/clean/features/auth/data/repositories/user_repository.dart';
import 'package:life_calendar/clean/features/calendar/data/repositories/week_repository.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week.dart';

class BuildCalendar {
  BuildCalendar(this._userRepository, this._weekRepository);

  final UserRepository _userRepository;
  final WeekRepository _weekRepository;

  Future<List<Week>> call() async {
    List<Week> weeks = [];

    DateTime birthdate = _userRepository.getBirthdate();
    int lifeSpan = _userRepository.getLifeSpan();

    Map<int, Week> changedWeeks = await _getWeeksMap();

    var currentBirthday = birthdate.copyWith();

    int weekNumber = 0;
    DateTime now = DateTime.now();
    for (int yearNumber = 0; yearNumber < lifeSpan + 1; yearNumber++) {
      DateTime monday = CalendarUtils.mondayOfWeekContaining(currentBirthday);
      DateTime nextYearBirthday = CalendarUtils.mondayOfWeekContaining(
        currentBirthday.copyWith(
          year: currentBirthday.year + 1,
        ),
      );

      while (monday.isBefore(nextYearBirthday)) {
        Week week = changedWeeks[weekNumber] ??
            Week.empty(
              yearId: yearNumber,
              number: weekNumber,
              start: monday,
              end: CalendarUtils.sundayOfWeekContaining(monday),
            );

        week.timeState = week.constructTimeState(now);

        weeks.add(week);

        monday = monday.copyWith(day: monday.day + 7);
        weekNumber++;
      }

      currentBirthday = currentBirthday.copyWith(
        year: currentBirthday.year + 1,
      );
    }

    return weeks;
  }

  Future<Map<int, Week>> _getWeeksMap() async {
    List<Week> changedWeeks = await _weekRepository.getAllWeeks();

    return {for (var week in changedWeeks) week.number: week};
  }
}
