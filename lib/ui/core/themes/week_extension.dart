import 'package:flutter/material.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';
import 'package:life_calendar/ui/core/themes/app_theme.dart';
import 'package:life_calendar/ui/core/themes/week_color.dart';

extension WeekColorExtension on Week {
  /// Called once per week box on every calendar paint, so it stays allocation
  /// free and only touches the theme on the branches that actually need it.
  Color getColor({required Brightness brightness}) {
    return switch (tense) {
      WeekTense.past => switch (assessment) {
        WeekAssessment.good => WeekColor.goodWeekColor,
        WeekAssessment.bad => WeekColor.badWeekColor,
        WeekAssessment.poor => _schemeFor(brightness).secondary,
      },
      WeekTense.current => Colors.blueAccent,
      WeekTense.future => switch (assessment) {
        WeekAssessment.good => WeekColor.goodWeekColor,
        WeekAssessment.bad => WeekColor.badWeekColor,
        WeekAssessment.poor => _schemeFor(brightness).secondaryContainer,
      },
    };
  }
}

ColorScheme _schemeFor(Brightness brightness) => brightness == Brightness.light
    ? AppTheme.lightTheme.colorScheme
    : AppTheme.darkTheme.colorScheme;
