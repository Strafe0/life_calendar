import 'package:life_calendar/domain/entities/week_assessment.dart';
import 'package:life_calendar/domain/entities/week.dart';
import 'package:life_calendar/domain/entities/week_state.dart';

abstract class Repository {
  Future<Week> getCurrentWeek();
  Future<Week> getWeekById(int id);
  Future<bool> insertAllWeeks(List<Week> weeks);
  Future<List<Week>> getAllWeeks();
  Future<bool> updateWeek(Week week);
  Future<bool> updateWeekState(int id, WeekState newState);
  Future<bool> updateWeekAssessment(int id, WeekAssessment newAssessment);
}
