import 'package:life_calendar/clean/features/calendar/data/repositories/week_repository.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_assessment.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_time_state.dart';

class FakeWeekRepository implements WeekRepository {
  @override
  Future<List<Week>> getAllWeeks() {
    return Future.value([
      Week(
        id: 'fake',
        yearId: 25,
        number: 1305,
        start: DateTime(2023, 12, 18),
        end: DateTime(2023, 12, 24, 23, 59, 59),
        timeState: WeekTimeState.past,
        assessment: WeekAssessment.good,
        resume: '',
      ),
    ]);
  }

  @override
  Future<Week> getCurrentWeek() {
    // TODO: implement getCurrentWeek
    throw UnimplementedError();
  }

  @override
  Future<Week> getWeekById(int id) {
    // TODO: implement getWeekById
    throw UnimplementedError();
  }

  @override
  Future<bool> insertAllWeeks(List<Week> weeks) {
    // TODO: implement insertAllWeeks
    throw UnimplementedError();
  }

  @override
  Future<bool> updateWeek(Week week) {
    // TODO: implement updateWeek
    throw UnimplementedError();
  }

  @override
  Future<bool> updateWeekAssessment(int id, WeekAssessment newAssessment) {
    // TODO: implement updateWeekAssessment
    throw UnimplementedError();
  }

  @override
  Future<bool> updateWeekState(int id, WeekTimeState newState) {
    // TODO: implement updateWeekState
    throw UnimplementedError();
  }
}
