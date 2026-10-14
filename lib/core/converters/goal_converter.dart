import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/core/uuid/app_uuid.dart';
import 'package:life_calendar/domain/models/week/goal/goal.dart';

class GoalConverter implements JsonConverter<List<Goal>, String> {
  const GoalConverter();

  @override
  List<Goal> fromJson(String json) {
    try {
      final List values = jsonDecode(json);
      return values.map((goal) {
        if (goal is Map && goal['id'] == null) {
          goal['id'] = AppUuid.generateTimeBasedUuid();
        }

        return Goal.fromJson(goal);
      }).toList();
    } on FormatException catch (e, s) {
      // FormatException.source holds the stored JSON, i.e. the user's text.
      logger.e(
        'Failed to parse goals',
        error: FormatException(e.message),
        stackTrace: s,
      );
      return [];
    }
  }

  @override
  String toJson(List<Goal> goals) => jsonEncode(goals);
}
