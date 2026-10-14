import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/core/uuid/app_uuid.dart';
import 'package:life_calendar/domain/models/week/event/event.dart';

class EventConverter implements JsonConverter<List<Event>, String> {
  const EventConverter();

  @override
  List<Event> fromJson(String json) {
    try {
      final List values = jsonDecode(json);
      return values.map((event) {
        if (event is Map && event['id'] == null) {
          event['id'] = AppUuid.generateTimeBasedUuid();
        }
        return Event.fromJson(event);
      }).toList();
    } on FormatException catch (e, s) {
      // FormatException.source holds the stored JSON, i.e. the user's text.
      logger.e(
        'Failed to parse events',
        error: FormatException(e.message),
        stackTrace: s,
      );
      return [];
    }
  }

  @override
  String toJson(List<Event> events) => jsonEncode(events);
}
