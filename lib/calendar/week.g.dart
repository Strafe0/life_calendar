// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Week _$WeekFromJson(Map<String, dynamic> json) => Week(
      json['id'] as int,
      json['yearId'] as int,
      Week._dateFromJson(json['start'] as int),
      Week._dateFromJson(json['end'] as int),
      $enumDecode(_$WeekStateEnumMap, json['state']),
      $enumDecode(_$WeekAssessmentEnumMap, json['assessment']),
      (json['goals'] as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['resume'] as String,
    )..events = Week._eventsFromJson(json['events'] as String);

Map<String, dynamic> _$WeekToJson(Week instance) => <String, dynamic>{
      'id': instance.id,
      'yearId': instance.yearId,
      'start': Week._dateToJson(instance.start),
      'end': Week._dateToJson(instance.end),
      'state': _$WeekStateEnumMap[instance.state]!,
      'assessment': _$WeekAssessmentEnumMap[instance.assessment]!,
      'goals': instance.goals.map((e) => e.toJson()).toList(),
      'events': Week._eventsToJson(instance.events),
      'resume': instance.resume,
    };

const _$WeekStateEnumMap = {
  WeekState.past: 'past',
  WeekState.current: 'current',
  WeekState.future: 'future',
};

const _$WeekAssessmentEnumMap = {
  WeekAssessment.good: 'good',
  WeekAssessment.bad: 'bad',
  WeekAssessment.poor: 'poor',
};

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
      json['title'] as String,
      json['isCompleted'] as bool,
    );

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
      'title': instance.title,
      'isCompleted': instance.isCompleted,
    };
