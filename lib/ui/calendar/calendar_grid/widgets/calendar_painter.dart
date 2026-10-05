import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/models/week_box.dart';
import 'package:life_calendar/utils/calendar/calendar_size.dart';

class CalendarPainter extends CustomPainter {
  final List<WeekBox> weekBoxes;
  final CalendarSize calendarSize;
  final Color textColor;
  final Brightness brightness;
  final DateTime lastUpdateTime;

  const CalendarPainter({
    required this.weekBoxes,
    required this.calendarSize,
    required this.textColor,
    required this.brightness,
    required this.lastUpdateTime,
  });

  @override
  bool shouldRepaint(covariant CalendarPainter oldDelegate) =>
      lastUpdateTime != oldDelegate.lastUpdateTime ||
      weekBoxes.length != oldDelegate.weekBoxes.length ||
      calendarSize != oldDelegate.calendarSize ||
      textColor != oldDelegate.textColor ||
      brightness != oldDelegate.brightness;

  @override
  void paint(Canvas canvas, Size size) {
    logger.d('Paint Calendar');

    _drawWeekLabels(canvas, textColor);

    // Batch the boxes into one path per distinct colour. A life grid holds
    // thousands of identical rounded rects but only a handful of colours, so
    // this turns ~4000 draw commands into ~5. That matters most on re-raster
    // (e.g. while zooming), where the whole display list is replayed: Impeller
    // tessellates rounded rects rather than taking Skia's analytic fast path,
    // so per-rect commands are expensive there.
    final pathsByColor = <Color, Path>{};

    int yearId = 0;
    int? labelledYear;
    for (int weekId = 0; weekId < weekBoxes.length; weekId++) {
      // Draw the label once per year, not once per week of that year — the
      // year label is identical for all 52 weeks and was being overdrawn (and
      // its paragraph re-laid-out) every iteration.
      if (yearId % 5 == 0 && labelledYear != yearId) {
        _drawYearLabel(yearId, canvas, textColor);
        labelledYear = yearId;
      }

      final week = weekBoxes[weekId];
      (pathsByColor[week.color(brightness: brightness)] ??= Path()).addRRect(
        week.rect,
      );

      if (weekId + 1 < weekBoxes.length &&
          weekBoxes[weekId + 1].yearId > yearId) {
        yearId++;
      }
    }

    // Boxes never overlap, so collapsing them by colour cannot change the
    // rendered result. One Paint is reused: the canvas snapshots its state per
    // draw call.
    final boxPaint = Paint();
    for (final entry in pathsByColor.entries) {
      canvas.drawPath(entry.value, boxPaint..color = entry.key);
    }
  }

  void _drawWeekLabels(Canvas canvas, Color textColor) {
    for (int i = 0; i < 11; i++) {
      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontSize: calendarSize.weekBoxSide,
          textAlign: TextAlign.center,
          maxLines: 1,
          height: 1,
        ),
      )..pushStyle(ui.TextStyle(color: textColor));

      final String label = (i == 0 ? 1 : i * 5).toString();
      builder.addText(label);
      final ui.Paragraph paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: calendarSize.weekBoxSide * 2));

      final double leftPadding =
          calendarSize.horPadding + calendarSize.labelHorPadding;
      final double k = i == 0 ? 0 : 1;
      canvas.drawParagraph(
        paragraph,
        Offset(
          leftPadding +
              (i * 5 - k) *
                  (calendarSize.weekBoxSide + calendarSize.weekBoxPaddingX) -
              calendarSize.weekBoxSide / 2,
          calendarSize.vrtPadding - calendarSize.weekBoxPaddingX * 2,
        ),
      );
    }
  }

  void _drawYearLabel(int yearNumber, Canvas canvas, Color textColor) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontSize: calendarSize.weekBoxSide,
              textAlign: TextAlign.end,
              maxLines: 1,
              height: 1,
            ),
          )
          ..pushStyle(ui.TextStyle(color: textColor))
          ..addText(yearNumber.toString());

    final ui.Paragraph paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: calendarSize.labelHorPadding));

    final double topPadding =
        calendarSize.vrtPadding + calendarSize.labelVrtPadding;

    canvas.drawParagraph(
      paragraph,
      Offset(
        calendarSize.horPadding - calendarSize.weekBoxPaddingY,
        topPadding +
            yearNumber *
                (calendarSize.weekBoxSide + calendarSize.weekBoxPaddingY),
      ),
    );
  }
}
