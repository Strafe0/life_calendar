import 'package:life_calendar/clean/features/calendar/data/dto/week_dto.dart';

abstract class WeekProvider {
  Future<bool> createWeek(WeekDto weekDto);
  Future<WeekDto> getWeekById(int id);
  Future<WeekDto> updateWeek(WeekDto weekDto);
  Future<List<WeekDto>> getWeeks();
  Future<bool> updateWeekState(int id, String state);
  Future<bool> updateWeekAssessment(int id, String assessment);
}