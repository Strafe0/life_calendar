import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils/utility_functions.dart';

class Year {
  Year(this.start, this.end, this.age);

  DateTime start;
  DateTime end;
  List<Week> weeks = [];
  int age;

  int get numberOfWeeks => weeksAmountBetweenMondays(start, end);
}