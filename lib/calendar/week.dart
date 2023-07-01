import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:life_calendar/utils/utility_functions.dart';

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

  @JsonKey(toJson: goalsToJson, fromJson: goalsFromJson)
  List<Goal> goals = [];
  @JsonKey(toJson: eventsToJson, fromJson: eventsFromJson)
  List<Event> events = [];
  String resume = '';

  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);


  static String eventsToJson(List<Event> values) => jsonEncode(values);
  static List<Event> eventsFromJson(String values) {
    List list = jsonDecode(values);
    return List.generate(list.length, (i) => Event(
      list[i]['title'],
      DateTime.fromMillisecondsSinceEpoch(list[i]['date']),
    ));
  }

  static String goalsToJson(List<Goal> values) => jsonEncode(values);
  static List<Goal> goalsFromJson(String values) {
    List list = jsonDecode(values);
    return List.generate(list.length, (i) => Goal(
      list[i]['title'],
      list[i]['isCompleted'],
    ));
  }
}

enum WeekState {
  past,
  current,
  future,
}

@JsonEnum(valueField: 'name')
enum WeekAssessment {
  good("Хорошо"),
  bad("Плохо"),
  poor("Нейтрально");

  final String name;
  const WeekAssessment(this.name);
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