import 'dart:convert';
import 'package:flutter/material.dart' show debugPrint;
import 'package:intl/intl.dart';

const int maxAge = 80;
const int maxWeekNumber = 53;
DateTime minDate = DateTime(1970, 1, 1);
DateTime maxDate = DateTime(2009, 1, 1);
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

bool datesIsTheSame(DateTime first, DateTime second) {
  if (first.year == second.year) {
    if (first.month == second.month) {
      if (first.day == second.day) {
        return true;
      }
    }
  }
  return false;
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

String listToJson(List<dynamic> list) => jsonEncode(list.map((e) => e.toJson()).toList());
List jsonStringToList(String jsonString) => jsonDecode(jsonString);

bool validateDateTime(DateTime dateTime) {
  int day = dateTime.day;
  int month = dateTime.month;
  int year = dateTime.year;

  if (year < minDate.year || year > maxDate.year || month <= 0 || month > 12) {
    debugPrint('The year or month is out of range');
    return false;
  }

  List<int> monthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (year % 400 == 0 || (year % 100 != 0 && year % 4 == 0)) {
    monthLength[1] = 29;
  }

  if (day > 0 && day <= monthLength[month - 1]) {
    return true;
  } else {
    debugPrint('The invalid number of days $day in the ${month}th month');
    return false;
  }
}

final RegExp dateRegExp = RegExp(r'[0-3]\d\.[01]\d\.\d\d\d\d');

DateTime? convertStringToDateTime(String dateTime) {
  if (!dateRegExp.hasMatch(dateTime)) {
    debugPrint('The date does not match the pattern.');
    return null;
  }

  int? day = int.tryParse(dateTime.substring(0, 2));
  int? month = int.tryParse(dateTime.substring(3, 5));
  int? year = int.tryParse(dateTime.substring(6, 10));

  if (day != null && month != null && year != null) {
    if (year < minDate.year || year > maxDate.year || month <= 0 || month > 12) {
      print('The year or month is out of range');
      return null;
    }

    List<int> monthLength = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (year % 400 == 0 || (year % 100 != 0 && year % 4 == 0)) {
      monthLength[1] = 29;
    }

    if (day > 0 && day <= monthLength[month - 1]) {
      return DateTime(year, month, day);
    } else {
      print('The invalid number of days $day in the ${month}th month');
    }
  }
  return null;
}