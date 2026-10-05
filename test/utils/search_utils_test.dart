import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:life_calendar/utils/calendar/search_utils.dart';

void main() {
  const lifeSpan = 60;

  List<Week> generate(DateTime birthday) => CalendarGenerator(
    birthday: birthday,
    lifeSpan: lifeSpan,
    time: () => DateTime(2026, 10, 5),
  ).generateWeeks();

  int find(DateTime date, DateTime birthday) =>
      findWeekIdByDate(date, birthdate: birthday, lifeSpan: lifeSpan);

  // 1990-01-01 is a Monday, so these cover every birthday weekday; the leap
  // day checks the year-boundary normalization.
  final birthdays = [
    for (var day = 1; day <= 7; day++) DateTime(1990, 1, day),
    DateTime(1992, 2, 29),
  ];

  for (final birthday in birthdays) {
    group('birthday $birthday (weekday ${birthday.weekday})', () {
      final weeks = generate(birthday);

      test('every date maps to the generated week containing it', () {
        for (var i = 0; ; i++) {
          final date = DateTime(
            birthday.year,
            birthday.month,
            birthday.day + i,
          );
          if (date.isAfter(weeks.last.end)) break;

          final week = weeks[find(date, birthday)];
          expect(
            !date.isBefore(week.start) && !date.isAfter(week.end),
            isTrue,
            reason: '$date resolved to ${week.start}..${week.end}',
          );
        }
      });

      test('dates outside the calendar return -1', () {
        final dayBefore = DateTime(
          birthday.year,
          birthday.month,
          birthday.day - 1,
        );
        final dayAfterLastWeek = DateTime(
          weeks.last.end.year,
          weeks.last.end.month,
          weeks.last.end.day + 1,
        );

        expect(find(dayBefore, birthday), -1);
        expect(find(dayAfterLastWeek, birthday), -1);
      });
    });
  }

  test('time of day does not change the result', () {
    final birthday = DateTime(1990, 1, 7);
    final morning = DateTime(2026, 10, 4, 0, 1);
    final evening = DateTime(2026, 10, 4, 23, 59);

    expect(find(morning, birthday), find(evening, birthday));
  });
}
