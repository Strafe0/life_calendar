import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarController {
  final CalendarModel _calendarModel = getIt<CalendarModel>();

  int get numberOfWeeks => _calendarModel.totalNumberOfWeeksInLife;
  late Week selectedWeek;

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

  Future<void> addEvent(String title) async {
    // var week = _calendarModel.calendar.years[selectedWeek!.yearId].weeks.firstWhere((element) => element.id == selectedWeek?.id);
    selectedWeek.events.add(title);
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> changeEvent(String newTitle, int index) async {
    selectedWeek.events[index] = newTitle;
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> deleteEvent(int index) async {
    selectedWeek.events.removeAt(index);
    await _calendarModel.updateEvent(selectedWeek);
  }
}