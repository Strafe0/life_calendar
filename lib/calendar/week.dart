import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'week.g.dart';

enum WeekState {
  past,
  current,
  future,
}

enum WeekAssessment {
  good,
  bad,
  poor,
}

@JsonSerializable()
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

  @JsonKey(toJson: _goalsToJson, fromJson: _goalsFromJson)
  List<String> goals = [];
  String resume = '';

  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);

  static int _dateToJson(DateTime value) => value.millisecondsSinceEpoch;
  static DateTime _dateFromJson(int value) => DateTime.fromMillisecondsSinceEpoch(value);

  static String _goalsToJson(List<String> values) => jsonEncode(values);
  static List<String> _goalsFromJson(String values) => jsonDecode(values).cast<String>().toList();
}