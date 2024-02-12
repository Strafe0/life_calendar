import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:life_calendar/views/calendar/week_rect_holder.dart';

class CalendarCanvas extends StatelessWidget {
  const CalendarCanvas({super.key, required this.weekRectHolder});

  final WeekRectHolder weekRectHolder;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CalendarPainter(
        weekRectHolder,
        Theme.of(context),
      ),
      child: Container(),
    );
  }
}

class CalendarPainter extends CustomPainter {
  CalendarPainter(this.weekRectHolder, this.theme);

  final CalendarController controller = getIt.get<CalendarController>();
  final WeekRectHolder weekRectHolder;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    weekRectHolder.clear();
    double y0 = vrtPadding + labelVrtPadding + weekBoxSide / 2;

    drawWeekLabels(canvas, theme.colorScheme.onBackground);

    for (int yearId = 0; yearId < controller.numberOfYears; yearId++) {
      double x0 = horPadding + labelHorPadding + weekBoxSide / 2;
      double y = y0 + yearId * (weekBoxSide + weekBoxPaddingY);

      if (yearId % 5 == 0) {
        drawYearLabel(yearId, canvas, theme.colorScheme.onBackground);
      }
      
      List<Week> weeks = controller.getWeeksInYear(yearId);
      for (int weekId = 0; weekId < weeks.length; weekId++) {
        Week week = weeks[weekId];
        double x = x0 + weekId * (weekBoxSide + weekBoxPaddingX);

        final Rect rect = Rect.fromCenter(
          center: Offset(x, y),
          width: weekBoxSide,
          height: weekBoxSide,
        );

        final RRect rrect = RRect.fromRectAndRadius(
          rect,
          const Radius.circular(1.5),
        );

        Color color = controller.getWeekColor(week.id, theme.brightness);
        canvas.drawRRect(rrect, Paint()..color = color);
        weekRectHolder.add(week.id, rect);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawWeekLabels(Canvas canvas, Color textColor) {
    for (int i = 0; i < 11; i++) {
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontSize: labelVrtPadding,
        textAlign: TextAlign.center,
        maxLines: 1,
        height: 1.0,
      ));
      builder.pushStyle(ui.TextStyle(color: textColor));

      String label = (i == 0 ? 1 : i * 5).toString();
      builder.addText(label);
      final ui.Paragraph paragraph = builder.build();
      paragraph.layout(ui.ParagraphConstraints(width: weekBoxSide*2));

      double leftPadding = horPadding + labelHorPadding;
      double k = i == 0 ? 0 : 1;
      canvas.drawParagraph(
        paragraph,
        Offset(
          leftPadding +
              (i * 5 - k) * (weekBoxSide + weekBoxPaddingX) -
              weekBoxSide / 2,
          vrtPadding - weekBoxPaddingX * 2,
        ),
      );
    }
  }

  void drawYearLabel(int yearNumber, Canvas canvas, Color textColor) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontSize: weekBoxSide * 1.5,
      textAlign: TextAlign.end,
      maxLines: 1,
      height: 1.0,
    ));
    builder.pushStyle(ui.TextStyle(color: textColor));
    builder.addText(yearNumber.toString());
    // builder.addPlaceholder(vrtLabelWidth, weekBoxSide, PlaceholderAlignment.middle);
    final ui.Paragraph paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: labelHorPadding));
    double topPadding = vrtPadding + labelVrtPadding;

    canvas.drawParagraph(
      paragraph,
      Offset(
        horPadding - 2 * weekBoxPaddingX,
        // horPadding - weekBoxSide * 2 - weekBoxPaddingX,
        topPadding + yearNumber * (weekBoxSide + weekBoxPaddingY),
      ),
    );
  }
}