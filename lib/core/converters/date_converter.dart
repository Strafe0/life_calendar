import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:life_calendar/core/logger/logger.dart';

class DateConverter implements JsonConverter<DateTime, Object> {
  const DateConverter();

  @override
  DateTime fromJson(Object json) {
    try {
      if (json is int) {
        return DateTime.fromMillisecondsSinceEpoch(json);
      } else if (json is String) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(json));
      }
      throw FormatException('Invalid type: ${json.runtimeType}');
    } on Exception catch (e, s) {
      logger.e('Failed to parse DateTime from $json', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  int toJson(DateTime date) => date.millisecondsSinceEpoch;
}
