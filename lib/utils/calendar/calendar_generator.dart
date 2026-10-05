import 'package:life_calendar/core/time/time_source.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';

class CalendarGenerator {
  final DateTime birthday;
  final int lifeSpan;
  final TimeSource time;

  const CalendarGenerator({
    required this.birthday,
    required this.lifeSpan,
    this.time = systemTime,
  });

  List<Week> generateWeeks({int? startWeekIndex, int? startYearIndex}) {
    final now = time();
    final List<Week> weeks = [];
    int count = startWeekIndex ?? 0;
    var lastBirthday = birthday;
    var yearMonday = previousMonday(lastBirthday);

    for (int yearId = 0; yearId < lifeSpan + 1; yearId++) {
      final nextBirthday = lastBirthday.copyWith(year: lastBirthday.year + 1);

      var weekMonday = DateTime(
        yearMonday.year,
        yearMonday.month,
        yearMonday.day,
      );
      var weekSunday = DateTime(
        weekMonday.year,
        weekMonday.month,
        weekMonday.day + 6,
        23,
        59,
        59,
      );

      while (nextBirthday.isAfter(weekSunday)) {
        weeks.add(
          Week(
            id: count,
            yearId: (startYearIndex ?? 0) + yearId,
            start: weekMonday,
            end: weekSunday,
            tense: weekSunday.isBefore(now)
                ? WeekTense.past
                : weekMonday.isBefore(now)
                ? WeekTense.current
                : WeekTense.future,
            assessment: WeekAssessment.poor,
            goals: [],
            events: [],
            resume: '',
            photos: [],
          ),
        );

        weekMonday = weekMonday.copyWith(day: weekMonday.day + 7);
        weekSunday = weekSunday.copyWith(
          day: weekSunday.day + 7,
          hour: 23,
          minute: 59,
          second: 59,
        );

        count++;
      }

      lastBirthday = nextBirthday;
      yearMonday = previousMonday(lastBirthday);
    }

    return weeks;
  }

  DateTime previousMonday(DateTime date) {
    DateTime monday = date;
    for (int i = 0; i < 7; i++) {
      final dayBefore = date.subtract(Duration(hours: 24 * i));
      if (dayBefore.weekday == DateTime.monday) {
        monday = dayBefore;
        break;
      }
    }

    return monday;
  }
}
