import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';

class CalendarController {
  final CalendarModel _calendarModel = getIt<CalendarModel>();

  int get numberOfWeeks => _calendarModel.totalNumberOfWeeksInLife;

  List<Year> get allYears => _calendarModel.calendar.years;
  
  List<Week> get allWeeks {
    List<Week> result = [];
    for (var year in _calendarModel.calendar.years) {
      result.addAll(year.weeks);
    }
    return result;
  }
}