import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/clean/common/utils/calendar_utils.dart';
import 'package:life_calendar/clean/features/auth/data/repositories/user_repository.dart';
import 'package:life_calendar/clean/features/calendar/data/repositories/week_repository.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/event.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/goal.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_assessment.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_time_state.dart';
import 'package:life_calendar/clean/features/calendar/domain/usecases/build_calendar.dart';
import 'package:mocktail/mocktail.dart';

class MockWeekRepo extends Mock implements WeekRepository {}

class MockUserRepo extends Mock implements UserRepository {}

void main() {
  WeekRepository weekRepo = MockWeekRepo();
  UserRepository userRepo = MockUserRepo();
  BuildCalendar buildCalendar = BuildCalendar(userRepo, weekRepo);

  group('BuildCalendar use case', () {
    setUp(() {
      when(() => userRepo.getBirthdate()).thenReturn(DateTime(1998, 12, 22));
      when(() => userRepo.getLifeSpan()).thenReturn(90);
      when(() => weekRepo.getAllWeeks()).thenAnswer((_) => Future.value([
            Week(
              id: 'test',
              yearId: 25,
              number: 1184,
              start: DateTime(2023, 8, 21),
              end: DateTime(2023, 8, 27, 23, 59, 59),
              timeState: WeekTimeState.past,
              assessment: WeekAssessment.good,
              goals: [Goal('Жениться')],
              events: [Event('Свадьба', DateTime(2023, 8, 26))],
              resume: 'Свадьба',
            )
          ]));
    });

    test('возвращает нужное количество недель', () async {
      // arrange
      DateTime birthdate = userRepo.getBirthdate();
      int lifeSpan = userRepo.getLifeSpan();

      // act
      List<Week> weeks = await buildCalendar();

      // assert
      expect(
        weeks.length,
        equals(
          CalendarUtils.calculateWeeksAmountBetween(
            birthdate,
            birthdate.copyWith(year: birthdate.year + lifeSpan + 1),
          ),
        ),
      );
    });
  });
}
