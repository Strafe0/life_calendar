import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'week.g.dart';

@JsonSerializable(explicitToJson: true)
class Week {
  Week(this.id, this.yearId, this.start, this.end, this.state, this.assessment, this.goals, this.resume);

  final int id;
  final int yearId;
  @JsonKey(toJson: _dateToJson, fromJson: _dateFromJson)
  final DateTime start;
  @JsonKey(toJson: _dateToJson, fromJson: _dateFromJson)
  final DateTime end;

  WeekState state;
  WeekAssessment assessment;

  List<Goal> goals = [];
  @JsonKey(toJson: _eventsToJson, fromJson: _eventsFromJson)
  List<String> events = [];
  String resume = '';

  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);

  static int _dateToJson(DateTime value) => value.millisecondsSinceEpoch;
  static DateTime _dateFromJson(int value) => DateTime.fromMillisecondsSinceEpoch(value);

  static String _eventsToJson(List<String> values) => jsonEncode(values);
  static List<String> _eventsFromJson(String values) => jsonDecode(values).cast<String>().toList();
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