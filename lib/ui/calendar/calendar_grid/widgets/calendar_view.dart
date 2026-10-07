import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_cubit.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_state.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_view_body.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_view_failure_body.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_view_loading_body.dart';
import 'package:life_calendar/ui/user/bloc/user_bloc.dart';
import 'package:life_calendar/ui/user/bloc/user_state.dart';
import 'package:life_calendar/utils/calendar/calendar_size.dart';
import 'package:life_calendar/utils/device_type.dart' as device_type;

class CalendarView extends StatefulWidget {
  const CalendarView({super.key, required this.constraints});

  final BoxConstraints constraints;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late BoxConstraints _constraints;
  CalendarSize? _calendarSize;

  @override
  void initState() {
    super.initState();

    _constraints = widget.constraints;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalendar();
    });
  }

  Future<void> _loadCalendar() async {
    final userState = context.read<UserBloc>().state;

    if (userState is! UserSuccess) {
      logger.w('Cancel loading of calendar: user is not ready');
      return;
    }

    // Years 0..lifeSpan, both inclusive.
    final yearsCount = userState.user.lifeSpan + 1;
    logger.i('_loadCalendar, yearsCount: $yearsCount');

    final deviceType = device_type.getDeviceType();
    final calendarSize = switch (deviceType) {
      device_type.DeviceType.phone => CalendarSize.forPhone(
        _constraints.maxWidth,
        _constraints.maxHeight,
        yearsCount,
      ),
      device_type.DeviceType.tablet => CalendarSize.forTablet(
        _constraints.maxWidth,
        _constraints.maxHeight,
        yearsCount,
      ),
    };

    _calendarSize = calendarSize;

    await context.read<CalendarCubit>().getWeeks(calendarSize: calendarSize);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserSuccess) {
          _loadCalendar();
        }
      },
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          logger.d('BlocBuilder<CalendarState>: $state');

          if (_calendarSize == null) {
            return const CalendarViewLoadingBody();
          }

          return switch (state) {
            CalendarInitial() ||
            CalendarLoading() => const CalendarViewLoadingBody(),
            CalendarFailure() => const CalendarViewFailureBody(),
            CalendarSuccess() => CalendarViewBody(
              weekBoxes: state.weeks,
              calendarSize: _calendarSize!,
              lastUpdateTime: state.lastUpdateTime,
            ),
          };
        },
      ),
    );
  }
}
