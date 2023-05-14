import 'package:flutter/cupertino.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_calendar/theme.dart';

class CalendarController extends ChangeNotifier {
  final CalendarModel _calendarModel = getIt<CalendarModel>();

  int get numberOfWeeks => _calendarModel.totalNumberOfWeeksInLife;
  late Week selectedWeek;
  Week get currentWeek => _calendarModel.currentWeek;

  List<Year> get allYears => _calendarModel.calendar.years;
  
  List<Week> get allWeeks {
    List<Week> result = [];
    for (var year in _calendarModel.calendar.years) {
      result.addAll(year.weeks);
    }
    return result;
  }

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
    notifyListeners();
  }

  Future<void> addEvent(Event newEvent) async {
    // var week = _calendarModel.calendar.years[selectedWeek!.yearId].weeks.firstWhere((element) => element.id == selectedWeek?.id);
    selectedWeek.events.add(newEvent);
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> changeEventTitle(int index, String newTitle) async {
    selectedWeek.events[index].title = newTitle;
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
  }

  selectWeek(int id, int yearId) {
    selectedWeek = getWeek(id, yearId);
  }

  Week getWeek(int id, int yearId) {
    return _calendarModel.calendar.years[yearId].weeks.firstWhere((element) => element.id == id);
  }

  Color getWeekColor(int id, int yearId) {
    Week week = getWeek(id, yearId);
    final Color weekColor = week.state == WeekState.past
        ? week.assessment == WeekAssessment.good ? goodWeekColor :
          week.assessment == WeekAssessment.bad ? badWeekColor : poorWeekColor
        : week.state == WeekState.future
            ? futureWeekColor
            : currentWeekColor;
    return weekColor;
  }
}