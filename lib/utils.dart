import 'package:intl/intl.dart';

const int maxAge = 80;
const int maxWeekNumber = 53;
// const double weekBoxSide = 6;
// const double weekBoxPadding = 0.5;

DateTime previousMonday(DateTime date) {
  DateTime monday = date;
  for (int i = 0; i < 7; i++) {
    DateTime dayBefore = date.subtract(Duration(hours: 24 * i));
    if (dayBefore.weekday == DateTime.monday) {
      monday = dayBefore;
      break;
    }
  }

  return monday;
}

int weeksAmountBetweenMondays(DateTime firstDate, DateTime secondDate) {
  Duration diff;
  if (firstDate.isBefore(secondDate)) {
    diff = previousMonday(secondDate).difference(previousMonday(firstDate));
  } else {
    diff = previousMonday(firstDate).difference(previousMonday(secondDate));
  }

  return diff.inDays ~/ 7;
}

String formatDate(DateTime date) {
  return DateFormat('dd.MM.yyyy').format(date);
}

int dateToJson(DateTime value) => value.millisecondsSinceEpoch;
DateTime dateFromJson(int value) => DateTime.fromMillisecondsSinceEpoch(value);