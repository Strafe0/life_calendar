import 'package:life_calendar/clean/features/calendar/domain/entities/week/week.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_assessment.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_time_state.dart';

abstract interface class WeekRepository {
  Future<Week> getCurrentWeek();
  Future<Week> getWeekById(int id);
  Future<bool> insertAllWeeks(List<Week> weeks);
  Future<List<Week>> getAllWeeks();
  Future<bool> updateWeek(Week week);
  Future<bool> updateWeekState(int id, WeekTimeState newState);
  Future<bool> updateWeekAssessment(int id, WeekAssessment newAssessment);
}
