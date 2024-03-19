import 'package:flutter/foundation.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:life_calendar/utils/utility_functions.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarModel {
  late DateTime _birthday;
  late DateTime _mondayOfBirthdayWeek;
  final _db = getIt<AppDatabase>();
  late Week currentWeek;
  final List<Week> _weeks = [];

  Future<void> updateCurrentWeek() async {
    await _db.updateWeekStates();
    currentWeek = await currentWeekFromDb();

    if (DateTime.now().isAfter(currentWeek.end) || DateTime.now().isBefore(currentWeek.start)) {
      DateTime realCurrentMonday = previousMonday(DateTime.now());
      bool isCurrentWeekInPast = DateTime.now().isAfter(currentWeek.end) ? true : false;

      int realCurrentWeekIndex = _weeks.indexWhere((week) => datesIsTheSame(week.start, realCurrentMonday));
      Week realCurrentWeek = _weeks[realCurrentWeekIndex];

      for (int i = currentWeek.id; i != realCurrentWeek.id; isCurrentWeekInPast ? i++ : i--) {
        _weeks[i].state = isCurrentWeekInPast ? WeekState.past : WeekState.future;
      }

      for (int i = 0; i < realCurrentWeekIndex; i++) {
        _weeks[i].state = WeekState.past;
      }
      for (int i = realCurrentWeekIndex; i < _weeks.length; i++) {
        _weeks[i].state = WeekState.future;
      }

      realCurrentWeek.state = WeekState.current;
      // _weeks[currentWeek.id].state = isCurrentWeekInPast ? WeekState.past : WeekState.future;

      currentWeek = realCurrentWeek;
      await updateCurrentWeekInDb();
    }
  }

  Future<Week> currentWeekFromDb() async => await _db.getCurrentWeek();

  Future<void> updateCurrentWeekInDb() async => await _db.updateCurrentWeek(currentWeek.id);

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
    await updateCurrentWeek();
  }

  DateTime get birthday => _birthday;
  DateTime get firstMonday => _mondayOfBirthdayWeek;
  DateTime get lastDay => _weeks.last.end;
  int get numberOfWeeks => _weeks.length;
  int get numberOfYears => _weeks.last.yearId + 1;

  int get currentWeekIndex =>
      weeksAmountBetweenMondays(DateTime.now(), _birthday);

  int get totalNumberOfWeeksInLife {
    DateTime maxAgeDate = DateTime(_birthday.year + userMaxAge + 1, _birthday.month, _birthday.day);
    return weeksAmountBetweenMondays(_birthday, maxAgeDate);
  }

  Future buildNewCalendar() async {
    int resultNumberOfWeeks = 0;
    var lastBirthday = _birthday;
    var yearMonday = previousMonday(lastBirthday);

    for (int yearIndex = 0; yearIndex < userMaxAge + 1; yearIndex++) {
      var nextBirthday = DateTime(lastBirthday.year + 1, lastBirthday.month, lastBirthday.day);
      // var yearSunday = previousMonday(nextBirthday).subtract(const Duration(days: 1));

      var weekMonday = DateTime(yearMonday.year, yearMonday.month, yearMonday.day);
      var weekSunday = DateTime(weekMonday.year, weekMonday.month, weekMonday.day + 6, 23, 59, 59);
      // var weekSunday = weekMonday.add(const Duration(days: 6));

      while (nextBirthday.isAfter(weekSunday)) {
        _weeks.add(Week(
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

      lastBirthday = nextBirthday;
      yearMonday = previousMonday(lastBirthday);
    }

    if (resultNumberOfWeeks == totalNumberOfWeeksInLife) {
      debugPrint('Number of weeks is the same');
    }

    if (!(await _db.tableIsEmpty())) {
      await _db.clearTable();
    }

    await _db.insertAllWeeks(_weeks);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTime', false);
  }

  Future buildFromDatabase() async {
    _weeks.clear();
    _weeks.addAll(await _db.getAllWeeks());
  }

  Week getWeek(int id) => _weeks[id];

  Future<Week> getWeekById(int id) => _db.getWeekById(id);

  List<Week> getWeeksInYear(int yearId) {
    List<Week> result = [];
    int lowerBound = yearId * 52;
    int upperBound = (yearId + 1) * 53;
    if (upperBound > _weeks.length) {
      upperBound = _weeks.length;
    }
    for (int id = lowerBound; id < upperBound; id++) {
      if (_weeks[id].yearId == yearId) {
        result.add(_weeks[id]);
      }
    }
    return result;
  }

  void updateAssessment(Week week) {
    _db.updateAssessment(week);
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

  Future updatePhoto(Week week) async {
    await _db.updatePhoto(week);
  }
}