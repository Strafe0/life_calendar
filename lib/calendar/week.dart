enum WeekState {
  past,
  current,
  future,
}

class Week {
  Week(this.start, this.end, this.state);

  DateTime start;
  DateTime end;

  WeekState state;
}