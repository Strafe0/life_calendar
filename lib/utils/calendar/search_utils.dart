import 'package:life_calendar/core/logger/logger.dart';

/// Returns the id of the calendar week that contains [date], or -1 if the date
/// lies outside the calendar.
///
/// Mirrors `CalendarGenerator`: weeks are contiguous Monday–Sunday blocks
/// starting from the Monday on or before [birthdate], so the id is the number
/// of whole weeks since that Monday. Days are counted in UTC to keep DST
/// shifts from moving a date into the previous week.
int findWeekIdByDate(
  DateTime date, {
  required DateTime birthdate,
  required int lifeSpan,
}) {
  final day = _utcDate(date);
  final birthday = _utcDate(birthdate);

  if (day.isBefore(birthday)) {
    logger.w('Searched date cannot be earlier than birthdate');
    return -1;
  }

  // The generator stops right before the week of the final birthday.
  final lastBirthday = DateTime.utc(
    birthdate.year + lifeSpan + 1,
    birthdate.month,
    birthdate.day,
  );
  if (!day.isBefore(_mondayOnOrBefore(lastBirthday))) {
    logger.w('Searched date cannot be later than last day');
    return -1;
  }

  final weekId = day.difference(_mondayOnOrBefore(birthday)).inDays ~/ 7;
  logger.d('Found week id: $weekId');

  return weekId;
}

DateTime _utcDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

DateTime _mondayOnOrBefore(DateTime date) =>
    date.subtract(Duration(days: date.weekday - DateTime.monday));
