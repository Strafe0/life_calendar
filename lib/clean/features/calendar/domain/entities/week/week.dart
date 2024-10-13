import 'package:life_calendar/clean/features/calendar/domain/entities/week/event.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/goal.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_assessment.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_time_state.dart';

class Week {
  Week({
    required this.id,
    required this.yearId,
    required this.number,
    required this.start,
    required this.end,
    required this.timeState,
    required this.assessment,
    this.goals = const [],
    this.events = const [],
    this.photos = const [],
    required this.resume,
  });

  String id;
  int yearId;
  int number;
  DateTime start;
  DateTime end;
  WeekTimeState timeState;
  WeekAssessment assessment;
  List<Goal> goals;
  List<Event> events;
  List<String> photos;
  String resume;

  Week.empty({
    required this.yearId,
    required this.number,
    required this.start,
    required this.end,
  })  : id = '',
        timeState = WeekTimeState.past,
        assessment = WeekAssessment.poor,
        goals = [],
        events = [],
        resume = '',
        photos = [];
}
