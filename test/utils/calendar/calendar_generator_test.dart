import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';

void main() {
  DateTime now() => DateTime(2026, 10, 7, 12);

  DateTime utcDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  DateTime mondayOnOrBefore(DateTime date) =>
      DateTime(date.year, date.month, date.day - date.weekday + 1);

  List<Week> generate(DateTime birthday, int lifeSpan, {DateTime? time}) =>
      CalendarGenerator(
        birthday: birthday,
        lifeSpan: lifeSpan,
        time: () => time ?? now(),
      ).generateWeeks();

  // 1990-01-01 is a Monday, so these cover every birthday weekday plus month
  // and year ends and a leap day.
  final birthdays = [
    for (var day = 1; day <= 7; day++) DateTime(1990, 1, day),
    DateTime(1985, 12, 31),
    DateTime(2000, 3, 31),
    DateTime(1992, 2, 29),
  ];

  for (final birthday in birthdays) {
    group('birthday $birthday', () {
      const lifeSpan = 60;
      final weeks = generate(birthday, lifeSpan);

      test('ids are sequential from 0', () {
        expect(weeks.map((w) => w.id), List.generate(weeks.length, (i) => i));
      });

      test('every week runs from Monday 00:00 to Sunday 23:59:59', () {
        for (final week in weeks) {
          final start = week.start;
          expect(start.weekday, DateTime.monday, reason: '$start');
          expect(start, DateTime(start.year, start.month, start.day));
          expect(
            week.end,
            DateTime(start.year, start.month, start.day + 6, 23, 59, 59),
          );
        }
      });

      test('weeks are contiguous', () {
        for (var i = 1; i < weeks.length; i++) {
          final previous = weeks[i - 1].start;
          expect(
            weeks[i].start,
            DateTime(previous.year, previous.month, previous.day + 7),
          );
        }
      });

      test('the first week contains the birthday', () {
        expect(weeks.first.start, mondayOnOrBefore(birthday));
        expect(weeks.first.end.isBefore(birthday), isFalse);
      });

      test('the calendar stops before the week of the final birthday', () {
        final finalBirthday = DateTime(
          birthday.year + lifeSpan + 1,
          birthday.month,
          birthday.day,
        );
        final firstMonday = utcDate(weeks.first.start);
        final stopMonday = utcDate(mondayOnOrBefore(finalBirthday));

        expect(weeks.last.end.isBefore(finalBirthday), isTrue);
        expect(weeks.length, stopMonday.difference(firstMonday).inDays ~/ 7);
      });

      test('year ids go from 0 to the lifespan with 52 or 53 weeks each', () {
        final counts = <int, int>{};
        for (final week in weeks) {
          counts[week.yearId] = (counts[week.yearId] ?? 0) + 1;
        }

        expect(counts.keys, List.generate(lifeSpan + 1, (i) => i));
        expect(counts.values, everyElement(anyOf(52, 53)));
        for (var i = 1; i < weeks.length; i++) {
          expect(weeks[i].yearId - weeks[i - 1].yearId, anyOf(0, 1));
        }
      });

      test('weeks start empty', () {
        for (final week in weeks) {
          expect(week.assessment, WeekAssessment.poor);
          expect(week.goals, isEmpty);
          expect(week.events, isEmpty);
          expect(week.photos, isEmpty);
          expect(week.resume, isEmpty);
        }
      });
    });
  }

  test('a new year starts with the week of each birthday', () {
    final birthday = DateTime(1990, 5, 15);
    final weeks = generate(birthday, 60);

    for (var year = 1; year <= 60; year++) {
      final firstWeek = weeks.firstWhere((w) => w.yearId == year);
      final yearBirthday = DateTime(1990 + year, 5, 15);

      expect(firstWeek.start, mondayOnOrBefore(yearBirthday), reason: '$year');
      expect(weeks[firstWeek.id - 1].yearId, year - 1);
    }
  });

  test('generates 3182 weeks for 60 years from Monday 1990-01-01', () {
    final weeks = generate(DateTime(1990, 1, 1), 60);

    expect(weeks, hasLength(3182));
    expect(weeks.last.start, DateTime(2050, 12, 19));
  });

  test('the week count grows with the lifespan', () {
    final birthday = DateTime(1990, 5, 15);
    final weeks60 = generate(birthday, 60);
    final weeks100 = generate(birthday, 100);

    expect(weeks100.take(weeks60.length).map((w) => w.start), [
      for (final week in weeks60) week.start,
    ]);
    expect(weeks100.length - weeks60.length, inInclusiveRange(2080, 2090));
  });

  group('tense', () {
    final birthday = DateTime(1990, 5, 15);

    test('splits weeks into past, current and future around now', () {
      final weeks = generate(birthday, 60, time: DateTime(2026, 10, 7, 12));
      final current = weeks.singleWhere((w) => w.tense == WeekTense.current);

      expect(current.start, DateTime(2026, 10, 5));
      expect(
        weeks.take(current.id).map((w) => w.tense),
        everyElement(WeekTense.past),
      );
      expect(
        weeks.skip(current.id + 1).map((w) => w.tense),
        everyElement(WeekTense.future),
      );
    });

    test('marks the week current through Monday morning and Sunday night', () {
      for (final time in [
        DateTime(2026, 10, 5, 0, 0, 1),
        DateTime(2026, 10, 11, 23, 59, 58),
      ]) {
        final weeks = generate(birthday, 60, time: time);
        final current = weeks.singleWhere((w) => w.tense == WeekTense.current);

        expect(current.start, DateTime(2026, 10, 5), reason: '$time');
      }
    });

    test('marks every week future before birth', () {
      final weeks = generate(birthday, 60, time: DateTime(1980));

      expect(weeks.map((w) => w.tense), everyElement(WeekTense.future));
    });

    test('marks every week past after the last week', () {
      final weeks = generate(birthday, 60, time: DateTime(2100));

      expect(weeks.map((w) => w.tense), everyElement(WeekTense.past));
    });
  });

  test('offsets ids and year ids by the start indexes', () {
    final weeks = CalendarGenerator(
      birthday: DateTime(2051, 5, 15),
      lifeSpan: 1,
      time: now,
    ).generateWeeks(startWeekIndex: 100, startYearIndex: 61);

    expect(weeks.first.id, 100);
    expect(weeks.map((w) => w.id), List.generate(weeks.length, (i) => 100 + i));
    expect(weeks.map((w) => w.yearId).toSet(), {61, 62});
  });

  group('previousMonday', () {
    final generator = CalendarGenerator(
      birthday: DateTime(1990),
      lifeSpan: 60,
      time: now,
    );

    test('returns the Monday on or before every day of a week', () {
      for (var day = 5; day <= 11; day++) {
        expect(
          generator.previousMonday(DateTime(2026, 10, day)),
          DateTime(2026, 10, 5),
        );
      }
    });

    test('crosses month and year boundaries', () {
      expect(
        generator.previousMonday(DateTime(2026, 3, 1)),
        DateTime(2026, 2, 23),
      );
      expect(
        generator.previousMonday(DateTime(2027, 1, 1)),
        DateTime(2026, 12, 28),
      );
    });
  });
}
