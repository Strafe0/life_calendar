import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/core/navigation/app_routes.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/models/week_box.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_interactive_viewer.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_painter.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/current_week_indicator.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/search/search_pull_indicator.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/search/search_ui_utils.dart';
import 'package:life_calendar/ui/calendar/drawer/calendar_drawer_controller.dart';
import 'package:life_calendar/ui/user/bloc/user_bloc.dart';
import 'package:life_calendar/ui/user/bloc/user_state.dart';
import 'package:life_calendar/utils/calendar/calendar_size.dart';
import 'package:life_calendar/utils/calendar/search_utils.dart';

class CalendarViewBody extends StatefulWidget {
  const CalendarViewBody({
    super.key,
    required this.weekBoxes,
    required this.calendarSize,
    required this.lastUpdateTime,
  });

  final List<WeekBox> weekBoxes;
  final CalendarSize calendarSize;
  final DateTime lastUpdateTime;

  @override
  State<CalendarViewBody> createState() => _CalendarViewBodyState();
}

class _CalendarViewBodyState extends State<CalendarViewBody> {
  final _transformationController = TransformationController();
  final _topNotifier = ValueNotifier<double>(0);
  bool _hapticFired = false;

  static const _indicatorHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    logger.d('Build CalendarViewBody');
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            // The painted calendar is additionally shifted by
            // _topNotifier.value via Transform.translate inside the viewer, so
            // undo that offset on top of the InteractiveViewer transform
            // before hit-testing.
            final scenePosition = _transformationController
                .toScene(details.localPosition)
                .translate(0, -_topNotifier.value);
            _onCalendarTap(context, scenePosition, widget.calendarSize);
          },
          child: CalendarInteractiveViewer(
            controller: _transformationController,
            maxDragDistance: _indicatorHeight * 1.5,
            onDragStart: () => _hapticFired = false,
            onDrag: (dragDistance) {
              _topNotifier.value = dragDistance;

              // Fire haptic once when crossing into the trigger zone, and
              // re-arm it once the drag returns inside the threshold so the
              // gesture can be cancelled (or re-triggered) without releasing.
              if (dragDistance.abs() > _indicatorHeight) {
                if (!_hapticFired) {
                  _hapticFired = true;
                  HapticFeedback.lightImpact();
                }
              } else {
                _hapticFired = false;
              }
            },
            onDragEnd: (dragDistance) {
              if (dragDistance > _indicatorHeight) {
                showSearchSheet(context);
              } else if (dragDistance < -_indicatorHeight) {
                _goToCurrentWeek(context);
              }
            },
            onHorizontalDragUpdate: (dx) =>
                context.read<CalendarDrawerController>().openDrag(dx),
            onHorizontalDragEnd: (velocityX) =>
                context.read<CalendarDrawerController>().endDrag(velocityX),
            child: Stack(
              children: [
                ValueListenableBuilder(
                  valueListenable: _topNotifier,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, -_indicatorHeight + value),
                      child: SearchPullIndicator(
                        isSearchTriggered: value > _indicatorHeight,
                        height: _indicatorHeight,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _topNotifier,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, constraints.maxHeight + value),
                      child: CurrentWeekIndicator(
                        isCurrentWeekTriggered: value < -_indicatorHeight,
                        height: _indicatorHeight,
                      ),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _topNotifier,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: CalendarPainter(
                        weekBoxes: widget.weekBoxes,
                        calendarSize: widget.calendarSize,
                        lastUpdateTime: widget.lastUpdateTime,
                        textColor: Theme.of(context).colorScheme.onSurface,
                        brightness: Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCalendarTap(
    BuildContext context,
    Offset position,
    CalendarSize calendarSize,
  ) {
    final weekId = widget.weekBoxes
        .firstWhere(
          (weekRect) =>
              weekRect.rect.left <= position.dx &&
              position.dx <= weekRect.rect.right &&
              weekRect.rect.top <= position.dy &&
              position.dy <= weekRect.rect.bottom,
          orElse: WeekBox.empty,
        )
        .weekId;

    logger.i('Tapped on $weekId week');
    if (weekId != -1) {
      context.read<AnalyticsService>().logWeekOpening(
        WeekTransitionEvent.weekBox,
      );
      context.push(AppRoute.weekId(weekId));
    }
  }

  void _goToCurrentWeek(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    if (userState is UserSuccess) {
      final user = userState.user;

      final weekId = findWeekIdByDate(
        DateTime.now(),
        birthdate: user.birthdate,
        lifeSpan: user.lifeSpan,
      );

      if (weekId != -1) {
        context.read<AnalyticsService>().logWeekOpening(
          WeekTransitionEvent.currentWeek,
        );
        context.push(AppRoute.weekId(weekId));
      }
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _topNotifier.dispose();
    super.dispose();
  }
}
