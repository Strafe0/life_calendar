import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils.dart';

class Year {
  Year(this.start, this.end);

  DateTime start;
  DateTime end;
  List<Week> weeks = [];

  int get numberOfWeeks => weeksAmountBetweenMondays(start, end);
}