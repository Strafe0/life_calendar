import 'package:flutter/cupertino.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_calendar/theme.dart';

class CalendarController extends ChangeNotifier {
  final CalendarModel _calendarModel = getIt<CalendarModel>();

  DateTime get birthday => _calendarModel.birthday;
  DateTime get lastDay => _calendarModel.calendar.years.last.weeks.last.end;
  int get numberOfWeeks => _calendarModel.totalNumberOfWeeksInLife;
  late Week selectedWeek;
  Week get currentWeek => _calendarModel.currentWeek;

  List<Year> get allYears => _calendarModel.calendar.years;

  ValueNotifier<int> changedWeekId = ValueNotifier(0);

  List<Week> get allWeeks {
    List<Week> result = [];
    for (var year in _calendarModel.calendar.years) {
      result.addAll(year.weeks);
    }
    return result;
  }

  void calendarIsReady() => notifyListeners();

  Future<DateTime> setBirthday(DateTime bDay) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('birthday', bDay.millisecondsSinceEpoch);

    _calendarModel.selectedBirthday = bDay;
    _calendarModel.buildCalendar(true);
    return bDay;
  }

  Future<void> changeAssessment(WeekAssessment assessment) async {
    selectedWeek.assessment = assessment;
    await _calendarModel.updateAssessment(selectedWeek);
  }

  Future<void> addEvent(Event newEvent) async {
    // var week = _calendarModel.calendar.years[selectedWeek!.yearId].weeks.firstWhere((element) => element.id == selectedWeek?.id);
    selectedWeek.events.add(newEvent);
    selectedWeek.events.sort((first, second) => first.date.compareTo(second.date));
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> changeEventTitle(int index, String newTitle) async {
    selectedWeek.events[index].title = newTitle;
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> changeEvent(int index, Event newEvent) async {
    selectedWeek.events[index] = newEvent;
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> deleteEvent(int index) async {
    selectedWeek.events.removeAt(index);
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> addGoal(String title) async {
    selectedWeek.goals.add(Goal(title, false));
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> changeGoalTitle(int index, String newTitle) async {
    selectedWeek.goals[index].title = newTitle;
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> changeGoalCompletion(int index, bool newValue) async {
    selectedWeek.goals[index].isCompleted = newValue;
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> deleteGoal(int index) async {
    selectedWeek.goals.removeAt(index);
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> addResume(String resumeText) async {
    selectedWeek.resume = resumeText;
    await _calendarModel.updateResume(selectedWeek);
  }

  Future<void> deleteResume() async {
    selectedWeek.resume = '';
    await _calendarModel.updateResume(selectedWeek);
  }

  selectWeek(int id, int yearId) {
    selectedWeek = getWeek(id, yearId);
  }

  Week getWeek(int id, int yearId) {
    int firstWeekId = _calendarModel.calendar.years[yearId].weeks.first.id;
    return _calendarModel.calendar.years[yearId].weeks[id - firstWeekId];
  }

  Color getWeekColor(int id, int yearId, Brightness brightness) {
    Week week = getWeek(id, yearId);

    var theme = brightness == Brightness.light ? lightTheme : darkTheme;
    final Color weekColor = switch (week.state) {
      WeekState.past => switch (week.assessment) {
        WeekAssessment.good => goodWeekColor,
        WeekAssessment.bad => badWeekColor,
        WeekAssessment.poor => theme.colorScheme.secondary,
      },
      WeekState.current => currentWeekColor,
      WeekState.future => switch (week.assessment) {
        WeekAssessment.good => goodWeekColor,
        WeekAssessment.bad => badWeekColor,
        WeekAssessment.poor => theme.colorScheme.secondaryContainer,
      }
    };

    return weekColor;
  }

  Week findWeekByDate(DateTime date) {
    DateTime birthday = DateTime(date.year, _calendarModel.birthday.month, _calendarModel.birthday.day);
    int yearId = date.year - _calendarModel.birthday.year;
    if (date.isBefore(birthday)) {
      yearId--;
    }

    Year year = _calendarModel.calendar.years[yearId];

    for (int i = 0; i < year.weeks.length; i++) {
      if (date.isBefore(year.weeks[i].end)) {
        return year.weeks[i];
      }
    }

    return year.weeks.first;
  }
}