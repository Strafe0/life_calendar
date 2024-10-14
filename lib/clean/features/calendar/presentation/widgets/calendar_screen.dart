import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/clean/features/calendar/domain/entities/week/week.dart';
import 'package:life_calendar/clean/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:life_calendar/logger.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      body: BlocBuilder<CalendarBloc, CalendarState>(
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
      painter: CalendarPainter(weeks),
      child: Container(),
    );
  }
}

class CalendarPainter extends CustomPainter {
  CalendarPainter(this.weeks);

  static const int weekInRowCount = 53;

  final List<Week> weeks;

  @override
  void paint(Canvas canvas, Size size) {
    double horSpaceBetweenBoxes = size.width / (29 + 11 * weekInRowCount);

    double boxSide = 10 * horSpaceBetweenBoxes;
    double labelsSpace = 20 * horSpaceBetweenBoxes;
    double labelsPadding = 10 * horSpaceBetweenBoxes;

    int lifeSpan = weeks.last.yearId + 1;
    double vrtSpaceBetweenBoxes =
        (size.height - labelsSpace - labelsPadding - lifeSpan * boxSide) /
            (lifeSpan - 1);

    logger.d('size.width = ${size.width}, size.height = ${size.height},\n'
        'boxSize = $boxSide, '
        'horSpaceBetweenBoxes = $horSpaceBetweenBoxes, '
        'vrtSpaceBetweenBoxes = $vrtSpaceBetweenBoxes,\n'
        'labelsSpace = $labelsSpace, labelsPadding = $labelsPadding');

    _drawTopLabels(
      canvas,
      labelsSpace,
      labelsPadding,
      boxSide,
      horSpaceBetweenBoxes,
      size.width,
    );
    _drawLeftLabels(
      canvas: canvas,
      lifeSpan: lifeSpan,
      labelSize: labelsSpace,
      labelPadding: labelsPadding,
      boxSide: boxSide,
      boxPadding: vrtSpaceBetweenBoxes,
      screenHeight: size.height,
    );

    double left = labelsSpace + labelsPadding;
    double top = labelsSpace + labelsPadding;

    int yearNumber = 0;
    for (int i = 0; i < weeks.length; i++) {
      final Rect rect = Rect.fromLTWH(left, top, boxSide, boxSide);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
        Paint()..color = Colors.blueGrey,
      );

      if (i + 1 < weeks.length) {
        if (yearNumber == weeks[i + 1].yearId) {
          left += boxSide + horSpaceBetweenBoxes;
        } else {
          top += boxSide + vrtSpaceBetweenBoxes;
          left = labelsSpace + labelsPadding;
          yearNumber++;
        }
      }
    }

    logger.d('yearNumber = $yearNumber, lifeSpan = $lifeSpan');
  }

  void _drawTopLabels(
    Canvas canvas,
    double labelSize,
    double labelPadding,
    double boxSide,
    double boxPadding,
    double screenWidth,
  ) {
    for (int i = 0; i < 11; i++) {
      String label = (i == 0 ? 1 : i * 5).toString();
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: labelSize,
          color: Colors.black,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: boxSide);

      double textWidth = textPainter.width;

      int k = i == 0 ? 0 : 1;
      textPainter.paint(
        canvas,
        Offset(
          labelSize +
              labelPadding +
              (i * 5 - k) * (boxSide + boxPadding) +
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
          color: Colors.black,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(minWidth: labelSize);

      double textHeight = textPainter.height;

      textPainter.paint(
        canvas,
        Offset(
          0,
          labelSize + labelPadding +
              i * (boxSide + boxPadding) +
              boxSide / 2 - textHeight / 2,
        ),
      );

      textPainter.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
