import 'package:json_annotation/json_annotation.dart';
import 'package:life_calendar/utils.dart';

part 'week.g.dart';

@JsonSerializable(explicitToJson: true)
class Week {
  Week(this.id, this.yearId, this.start, this.end, this.state, this.assessment, this.goals, this.resume);

  final int id;
  final int yearId;
  @JsonKey(toJson: dateToJson, fromJson: dateFromJson)
  final DateTime start;
  @JsonKey(toJson: dateToJson, fromJson: dateFromJson)
  final DateTime end;

  WeekState state;
  WeekAssessment assessment;

  List<Goal> goals = [];
  List<Event> events = [];
  String resume = '';

  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);


  // static String _eventsToJson(List<String> values) => jsonEncode(values);
  // static List<String> _eventsFromJson(String values) => jsonDecode(values).cast<String>().toList();
}

enum WeekState {
  past,
  current,
  future,
}

enum WeekAssessment {
  good,
  bad,
  poor
}

@JsonSerializable()
class Goal {
  String title;
  bool isCompleted;

  Goal(this.title, this.isCompleted);

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}

@JsonSerializable()
class Event {
  String title;

  @JsonKey(toJson: dateToJson, fromJson: dateFromJson)
  DateTime date;

  Event(this.title, this.date);

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}