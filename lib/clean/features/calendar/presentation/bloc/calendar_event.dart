part of 'calendar_bloc.dart';

sealed class CalendarEvent {
  const CalendarEvent();
}

class CalendarBuildRequested extends CalendarEvent {
  const CalendarBuildRequested();
}