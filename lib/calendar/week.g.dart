// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Week _$WeekFromJson(Map<String, dynamic> json) => Week(
      json['id'] as int,
      json['yearId'] as int,
      dateFromJson(json['start'] as int),
      dateFromJson(json['end'] as int),
      $enumDecode(_$WeekStateEnumMap, json['state']),
      $enumDecode(_$WeekAssessmentEnumMap, json['assessment']),
      Week.goalsFromJson(json['goals'] as String),
      json['resume'] as String,
    )..events = Week.eventsFromJson(json['events'] as String);

Map<String, dynamic> _$WeekToJson(Week instance) => <String, dynamic>{
      'id': instance.id,
      'yearId': instance.yearId,
      'start': dateToJson(instance.start),
      'end': dateToJson(instance.end),
      'state': _$WeekStateEnumMap[instance.state]!,
      'assessment': _$WeekAssessmentEnumMap[instance.assessment]!,
      'goals': Week.goalsToJson(instance.goals),
      'events': Week.eventsToJson(instance.events),
      'resume': instance.resume,
    };

const _$WeekStateEnumMap = {
  WeekState.past: 'past',
  WeekState.current: 'current',
  WeekState.future: 'future',
};

const _$WeekAssessmentEnumMap = {
  WeekAssessment.good: 'Хорошо',
  WeekAssessment.bad: 'Плохо',
  WeekAssessment.poor: 'Нейтрально',
};

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
      json['title'] as String,
      json['isCompleted'] as bool,
    );

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
      'title': instance.title,
      'isCompleted': instance.isCompleted,
    };

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      json['title'] as String,
      dateFromJson(json['date'] as int),
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'title': instance.title,
      'date': dateToJson(instance.date),
    };
