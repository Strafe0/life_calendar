import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/clean/common/styles/theme.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_assessment.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week_time_state.dart';
import 'package:life_calendar/clean/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:life_calendar/logger.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      body: InteractiveViewer(
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            if (state is CalendarBuilding) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CalendarSuccess) {
              return SafeArea(
                child: CalendarPadding(
                  child: CalendarCanvas(weeks: state.weeks),
                ),
              );
            }

            return const Center(child: Text('Ошибка'));
          },
        ),
      ),
    );
  }
}

class CalendarPadding extends StatelessWidget {
  const CalendarPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        logger.d('width = $width, height = $height,\n'
            'MQ.width = ${MediaQuery.sizeOf(context).width}, '
            'MQ.height = ${MediaQuery.sizeOf(context).height}');

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        );
      },
    );
  }
}

class CalendarCanvas extends StatelessWidget {
  const CalendarCanvas({super.key, required this.weeks});

  final List<Week> weeks;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CalendarPainter(weeks, Theme.of(context).colorScheme),
      child: Container(),
    );
  }
}

class CalendarPainter extends CustomPainter {
  CalendarPainter(this.weeks, this.colorScheme);

  static const int weekInRowCount = 53;

  final List<Week> weeks;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    double boxPaddingHor = size.width / (29 + 11 * weekInRowCount);

    double boxSide = 10 * boxPaddingHor;
    double labelSize = 20 * boxPaddingHor;
    double labelPadding = 10 * boxPaddingHor;

    int lifeSpan = weeks.last.yearId + 1;
    double boxPaddingVert =
        (size.height - labelSize - labelPadding - lifeSpan * boxSide) /
            (lifeSpan - 1);

    logger.d('size.width = ${size.width}, size.height = ${size.height},\n'
        'boxSize = $boxSide, '
        'boxPaddingHor = $boxPaddingHor, '
        'boxPaddingVert = $boxPaddingVert,\n'
        'labelSize = $labelSize, labelPadding = $labelPadding');

    _drawTopLabels(
      canvas: canvas,
      labelSize: labelSize,
      labelPadding: labelPadding,
      boxSide: boxSide,
      boxPadding: boxPaddingHor,
      screenWidth: size.width,
    );

    _drawLeftLabels(
      canvas: canvas,
      lifeSpan: lifeSpan,
      labelSize: labelSize,
      labelPadding: labelPadding,
      boxSide: boxSide,
      boxPadding: boxPaddingVert,
      screenHeight: size.height,
    );

    _drawCalendarGrid(
      canvas: canvas,
      labelSize: labelSize,
      labelPadding: labelPadding,
      boxSide: boxSide,
      boxPaddingHor: boxPaddingHor,
      boxPaddingVert: boxPaddingVert,
    );
  }

  void _drawTopLabels({
    required Canvas canvas,
    required double labelSize,
    required double labelPadding,
    required double boxSide,
    required double boxPadding,
    required double screenWidth,
  }) {
    for (int i = 1; i <= 53; i += i == 1 ? 4 : 5) {
      final textSpan = TextSpan(
        text: i.toString(),
        style: TextStyle(
          fontSize: labelSize,
          color: colorScheme.onSurface,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: boxSide);

      double textWidth = textPainter.width;

      textPainter.paint(
        canvas,
        Offset(
          labelSize +
              labelPadding +
              (i - 1) * (boxSide + boxPadding) +
              boxSide / 2 -
              textWidth / 2,
          0,
        ),
      );

      textPainter.dispose();
    }
  }

  void _drawLeftLabels({
    required Canvas canvas,
    required int lifeSpan,
    required double labelSize,
    required double labelPadding,
    required double boxSide,
    required double boxPadding,
    required double screenHeight,
  }) {
    for (int i = 0; i <= lifeSpan; i += 5) {
      final textSpan = TextSpan(
        text: i.toString(),
        style: TextStyle(
          fontSize: labelSize,
          color: colorScheme.onSurface,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.end,
      );
      textPainter.layout(minWidth: labelSize);

      double textHeight = textPainter.height;

      textPainter.paint(
        canvas,
        Offset(
          0,
          labelSize +
              labelPadding +
              i * (boxSide + boxPadding) +
              boxSide / 2 -
              textHeight / 2,
        ),
      );

      textPainter.dispose();
    }
  }

  void _drawCalendarGrid({
    required Canvas canvas,
    required labelSize,
    required labelPadding,
    required boxSide,
    required boxPaddingHor,
    required boxPaddingVert,
  }) {
    double left = labelSize + labelPadding;
    double top = labelSize + labelPadding;
    int yearNumber = 0;

    for (int i = 0; i < weeks.length; i++) {
      final Rect rect = Rect.fromLTWH(left, top, boxSide, boxSide);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
        Paint()..color = getWeekColor(weeks[i]),
      );

      if (i + 1 < weeks.length) {
        if (yearNumber == weeks[i + 1].yearId) {
          left += boxSide + boxPaddingHor;
        } else {
          top += boxSide + boxPaddingVert;
          left = labelSize + labelPadding;
          yearNumber++;
        }
      }
    }
  }

  Color getWeekColor(Week week) {
    return switch (week.assessment) {
      WeekAssessment.good => AppTheme.goodWeekColor,
      WeekAssessment.bad => AppTheme.badWeekColor,
      WeekAssessment.poor => switch (week.timeState) {
        WeekTimeState.current => AppTheme.currentWeekColor,
        WeekTimeState.past => colorScheme.secondary,
        WeekTimeState.future => colorScheme.secondaryContainer,
      }
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
