import 'package:bloc/bloc.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week.dart';
import 'package:life_calendar/clean/features/calendar/domain/usecases/build_calendar.dart';

part 'calendar_event.dart';

part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc({required BuildCalendar buildCalendar})
      : _buildCalendar = buildCalendar,
        super(const CalendarInitial()) {
    on<CalendarBuildRequested>(_onBuildRequested);
  }

  final BuildCalendar _buildCalendar;

  Future<void> _onBuildRequested(
    CalendarBuildRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarBuilding());

    List<Week> weeks = await _buildCalendar();

    emit(CalendarSuccess(weeks: weeks));
  }
}
