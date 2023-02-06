import 'package:flutter/foundation.dart';
import 'package:life_calendar/calendar/calendar.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:life_calendar/utils.dart';

class CalendarModel {
  late DateTime _birthday;
  late DateTime _mondayOfBirthdayWeek;
  Calendar calendar = Calendar();

  void init() {
    //TODO: get user settings from shared preferences and database

  }

  set selectedBirthday(DateTime dateTime) {
    _birthday = dateTime;
    _mondayOfBirthdayWeek = previousMonday(dateTime);
    buildCalendar();
  }

  DateTime get birthday => _birthday;
  DateTime get firstMonday => _mondayOfBirthdayWeek;

  int get currentWeekIndex =>
      weeksAmountBetweenMondays(DateTime.now(), _birthday);

  int get totalNumberOfWeeksInLife {
    DateTime maxAgeDate = DateTime(_birthday.year + maxAge, _birthday.month, _birthday.day);
    return weeksAmountBetweenMondays(_birthday, maxAgeDate);
  }

  void buildCalendar() {
    int resultNumberOfWeeks = 0;
    var lastBirthday = _birthday;
    var yearMonday = previousMonday(lastBirthday);

    for (int yearIndex = 0; yearIndex < maxAge; yearIndex++) {
      var nextBirthday = DateTime(lastBirthday.year + 1, lastBirthday.month, lastBirthday.day);
      var yearSunday = previousMonday(nextBirthday).subtract(const Duration(days: 1));

      var year = Year(yearMonday, yearSunday);

      var weekMonday = DateTime(yearMonday.year, yearMonday.month, yearMonday.day);
      var weekSunday = weekMonday.add(const Duration(days: 6));

      while (nextBirthday.isAfter(weekSunday)) {
        resultNumberOfWeeks++;

        year.weeks.add(Week(
            weekMonday,
            weekSunday,
            weekSunday.isBefore(DateTime.now()) ? WeekState.past : weekMonday.isBefore(DateTime.now()) ? WeekState.current : WeekState.future
        ));

        weekMonday = weekMonday.add(const Duration(days: 7));
        weekSunday = DateTime(weekSunday.year, weekSunday.month, weekSunday.day + 7);
      }
      // for (int weekIndex = 0; weekIndex < year.numberOfWeeks; weekIndex++) {
      //   resultNumberOfWeeks++;
      //
      //   year.weeks.add(Week(
      //       weekMonday,
      //       weekSunday,
      //       weekSunday.isBefore(DateTime.now()) ? WeekState.past : weekMonday.isBefore(DateTime.now()) ? WeekState.current : WeekState.future
      //   ));
      //
      //   weekMonday = weekMonday.add(const Duration(days: 7));
      //   weekSunday = weekSunday.add(const Duration(days: 7));
      // }
      calendar.years.add(year);
      lastBirthday = nextBirthday;
      yearMonday = previousMonday(lastBirthday);
    }

    if (resultNumberOfWeeks == totalNumberOfWeeksInLife) {
      debugPrint('Number of weeks is the same');
    }
  }
}