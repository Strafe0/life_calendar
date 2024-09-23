import 'package:life_calendar/calendar/week.dart';

export 'week_assessment.dart';
export 'week_state.dart';
export 'event.dart';
export 'goal.dart';

class Week {
  Week({
    required this.id,
    required this.yearId,
    required this.start,
    required this.end,
    required this.weekState,
    required this.assessment,
    this.goals = const [],
    this.events = const [],
    required this.resume,
    this.photos = const [],
  });

  int id;
  int yearId;
  DateTime start;
  DateTime end;
  WeekState weekState;
  WeekAssessment assessment;
  List<Goal> goals;
  List<Event> events;
  String resume;
  List<String> photos;
}
