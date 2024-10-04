import 'package:life_calendar/clean/features/calendar/data/dto/week_dto.dart';
import 'package:life_calendar/clean/features/calendar/data/providers/week_provider.dart';

class LocalWeekProvider implements WeekProvider {
  @override
  Future<bool> createWeek(WeekDto weekDto) {
    // TODO: implement createWeek
    throw UnimplementedError();
  }

  @override
  Future<WeekDto> getWeekById(int id) {
    // TODO: implement getWeekById
    throw UnimplementedError();
  }

  @override
  Future<List<WeekDto>> getWeeks() {
    // TODO: implement getWeeks
    throw UnimplementedError();
  }

  @override
  Future<WeekDto> updateWeek(WeekDto weekDto) {
    // TODO: implement updateWeek
    throw UnimplementedError();
  }

  @override
  Future<bool> updateWeekAssessment(int id, String assessment) {
    // TODO: implement updateWeekAssessment
    throw UnimplementedError();
  }

  @override
  Future<bool> updateWeekState(int id, String state) {
    // TODO: implement updateWeekState
    throw UnimplementedError();
  }

}