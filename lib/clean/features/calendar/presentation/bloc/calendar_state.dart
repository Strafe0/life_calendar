part of 'calendar_bloc.dart';

sealed class CalendarState {
  const CalendarState();
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarBuilding extends CalendarState {
  const CalendarBuilding();
}

class CalendarSuccess extends CalendarState {
  const CalendarSuccess({required this.weeks});

  final List<Week> weeks;
}

class CalendarFailure extends CalendarState {
  const CalendarFailure({required this.exception});

  final Exception exception;
}