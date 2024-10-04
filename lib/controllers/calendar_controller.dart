import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_calendar/logger.dart';
import 'package:life_calendar/models/calendar_model.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_calendar/theme.dart';

class CalendarController extends ChangeNotifier {
  final CalendarModel _calendarModel = getIt<CalendarModel>();

  DateTime get birthday => _calendarModel.birthday;
  DateTime get lastDay => _calendarModel.lastDay;
  int get numberOfWeeks => _calendarModel.numberOfWeeks;
  late Week selectedWeek;
  Week get currentWeek => _calendarModel.currentWeek;
  int get numberOfYears => _calendarModel.numberOfYears;
  int get age => currentWeek.yearId;


  ValueNotifier<int> changedWeekId = ValueNotifier(0);

  void calendarIsReady() => notifyListeners();

  Future<DateTime> setBirthday(DateTime bDay) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('birthday', bDay.millisecondsSinceEpoch);

    _calendarModel.selectedBirthday = bDay;
    _calendarModel.buildCalendar(true);
    return bDay;
  }

  void changeAssessment(WeekAssessment assessment) {
    selectedWeek.assessment = assessment;
    _calendarModel.updateAssessment(selectedWeek);
  }

  Future<void> addEvent(Event newEvent) async {
    selectedWeek.events.add(newEvent);
    selectedWeek.events.sort((first, second) => first.date.compareTo(second.date));
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> changeEventTitle(int index, String newTitle) async {
    selectedWeek.events[index].title = newTitle;
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> changeEvent(int index, Event newEvent) async {
    selectedWeek.events[index] = newEvent;
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> deleteEvent(int index) async {
    selectedWeek.events.removeAt(index);
    await _calendarModel.updateEvent(selectedWeek);
  }

  Future<void> addGoal(String title) async {
    selectedWeek.goals.add(Goal(title, false));
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> changeGoalTitle(int index, String newTitle) async {
    selectedWeek.goals[index].title = newTitle;
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> changeGoalCompletion(int index, bool newValue) async {
    selectedWeek.goals[index].isCompleted = newValue;
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> deleteGoal(int index) async {
    selectedWeek.goals.removeAt(index);
    await _calendarModel.updateGoal(selectedWeek);
  }

  Future<void> addResume(String resumeText) async {
    selectedWeek.resume = resumeText;
    await _calendarModel.updateResume(selectedWeek);
  }

  Future<void> addPhoto(XFile photo) async {
    selectedWeek.photos.add(photo.path);
    await _calendarModel.updatePhoto(selectedWeek);
    selectedWeek = await _calendarModel.getWeekById(selectedWeek.id);
  }

  Future<void> deletePhoto(String photoPath) async {
    bool isRemoved = selectedWeek.photos.remove(photoPath);
    if (isRemoved) {
      await _calendarModel.updatePhoto(selectedWeek);
      selectedWeek = await _calendarModel.getWeekById(selectedWeek.id);
    } else {
      logger.w("Cannot remove photo from selected week");
    }
  }

  Future<void> deleteResume() async {
    selectedWeek.resume = '';
    await _calendarModel.updateResume(selectedWeek);
  }

  selectWeek(int id) {
    selectedWeek = getWeek(id);
  }

  Week getWeek(int id) => _calendarModel.getWeek(id);
  List<Week> getWeeksInYear(int yearId) => _calendarModel.getWeeksInYear(yearId);

  Color getWeekColor(int id, Brightness brightness) {
    Week week = getWeek(id);

    var theme = brightness == Brightness.light ? lightTheme : darkTheme;
    final Color weekColor = switch (week.state) {
      WeekState.past => switch (week.assessment) {
        WeekAssessment.good => goodWeekColor,
        WeekAssessment.bad => badWeekColor,
        WeekAssessment.poor => theme.colorScheme.secondary,
      },
      WeekState.current => currentWeekColor,
      WeekState.future => switch (week.assessment) {
        WeekAssessment.good => goodWeekColor,
        WeekAssessment.bad => badWeekColor,
        WeekAssessment.poor => theme.colorScheme.secondaryContainer,
      }
    };

    return weekColor;
  }

  Week? findWeekByDate(DateTime date) {
    DateTime birthday = DateTime(date.year, _calendarModel.birthday.month, _calendarModel.birthday.day);
    int yearId = date.year - _calendarModel.birthday.year;
    if (date.isBefore(birthday)) {
      yearId--;
    }

    for (int id = yearId * 52; id < _calendarModel.numberOfWeeks; id++) {
      Week week = _calendarModel.getWeek(id);
      if (date.isBefore(week.end)) {
        return week;
      }
    }

    return null;
  }

  Future<File?> exportCalendar() => _calendarModel.export();

  Future<ImportResult> importCalendar() => _calendarModel.import();
}