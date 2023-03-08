import 'package:flutter/foundation.dart';
import 'package:life_calendar/calendar/calendar.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:life_calendar/utils.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarModel {
  late DateTime _birthday;
  late DateTime _mondayOfBirthdayWeek;
  Calendar calendar = Calendar();
  final _db = getIt<AppDatabase>();

  void init() {
    //TODO: get user settings from shared preferences and database

  }

  set selectedBirthday(DateTime dateTime) {
    _birthday = dateTime;
    _mondayOfBirthdayWeek = previousMonday(dateTime);
    // buildCalendar();
  }

  Future buildCalendar(bool firstTime) async {
    if (firstTime || (await _db.tableIsEmpty())) {
      await buildNewCalendar();
    } else {
      await buildFromDatabase();
    }
  }

  DateTime get birthday => _birthday;
  DateTime get firstMonday => _mondayOfBirthdayWeek;

  int get currentWeekIndex =>
      weeksAmountBetweenMondays(DateTime.now(), _birthday);

  int get totalNumberOfWeeksInLife {
    DateTime maxAgeDate = DateTime(_birthday.year + maxAge + 1, _birthday.month, _birthday.day);
    return weeksAmountBetweenMondays(_birthday, maxAgeDate);
  }

  Future buildNewCalendar() async {
    int resultNumberOfWeeks = 0;
    var lastBirthday = _birthday;
    var yearMonday = previousMonday(lastBirthday);

    for (int yearIndex = 0; yearIndex < maxAge + 1; yearIndex++) {
      var nextBirthday = DateTime(lastBirthday.year + 1, lastBirthday.month, lastBirthday.day);
      var firstMondayNextYear = previousMonday(nextBirthday);
      var yearSunday = DateTime(firstMondayNextYear.year, firstMondayNextYear.month, firstMondayNextYear.day - 1, 23, 59, 59);
      // var yearSunday = previousMonday(nextBirthday).subtract(const Duration(days: 1));

      var year = Year(yearMonday, yearSunday, yearIndex);

      var weekMonday = DateTime(yearMonday.year, yearMonday.month, yearMonday.day);
      var weekSunday = DateTime(weekMonday.year, weekMonday.month, weekMonday.day + 6, 23, 59, 59);
      // var weekSunday = weekMonday.add(const Duration(days: 6));

      while (nextBirthday.isAfter(weekSunday)) {
        year.weeks.add(Week(
          resultNumberOfWeeks,
          yearIndex,
          weekMonday,
          weekSunday,
          weekSunday.isBefore(DateTime.now()) ? WeekState.past : weekMonday.isBefore(DateTime.now()) ? WeekState.current : WeekState.future,
          WeekAssessment.poor,
          [],
          '',
        ));

        resultNumberOfWeeks++;
        weekMonday = DateTime(weekMonday.year, weekMonday.month, weekMonday.day + 7);
        // weekMonday = weekMonday.add(const Duration(days: 7));
        weekSunday = DateTime(weekSunday.year, weekSunday.month, weekSunday.day + 7, 23, 59, 59);
      }

      calendar.years.add(year);
      lastBirthday = nextBirthday;
      yearMonday = previousMonday(lastBirthday);
    }

    if (resultNumberOfWeeks == totalNumberOfWeeksInLife) {
      debugPrint('Number of weeks is the same');
    }

    await _db.insertAllYears(calendar.years);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTime', false);
  }

  Future buildFromDatabase() async {
    calendar.years.clear();
    calendar.years.addAll(await _db.getAll());
  }

  Future updateAssessment(Week week) async {
    var year = calendar.years.where((element) => element.age == week.yearId).first;
    var selectedWeek = year.weeks.where((element) => element.id == week.id).first;
    selectedWeek.assessment = week.assessment;

    await _db.updateAssessment(week);
  }

  Future updateEvent(Week week) async {
    await _db.updateEvents(week);
  }

  Future updateGoal(Week week) async {
    await _db.updateGoals(week);
  }

  Future updateResume(Week week) async {
    await _db.updateResume(week);
  }
}