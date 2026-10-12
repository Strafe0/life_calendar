import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_assessment/week_assessment_ui_extension.dart';

import '../support.dart';

/// Runs against the 3.0.0 sources (scripts/upgrade_test.sh copies it there)
/// and leaves the data a 3.0.0 user would have, including the lifespan
/// increase that 3.0.0 saved with shifted week ids.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = l10nFor(english);

  appTest('3.0.0 saves weeks and extends the lifespan', (tester) async {
    await launchRegistered(tester, birthDate: upgradeBirthDate, lifeSpan: 60);
    await rateFirstWeekOfYear(tester, 10, WeekAssessment.good);

    await openMenu(tester);
    await tapText(tester, l10n.changeLifespan);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      '70',
    );
    await tapText(tester, l10n.ready);
    await waitForCalendar(
      tester,
      (weeks) => weeks.last.yearId == 70,
      description: 'the calendar to grow to 70 years',
    );
    await closeMenu(tester);

    await rateFirstWeekOfYear(tester, 65, WeekAssessment.bad);
  });
}

Future<void> rateFirstWeekOfYear(
  WidgetTester tester,
  int year,
  WeekAssessment assessment,
) async {
  final weekId = calendarWeeks(
    tester,
  ).firstWhere((w) => w.yearId == year).weekId;
  await tapWeek(tester, weekId);
  await tapText(tester, assessment.label(l10nFor(english)));
  await closeWeek(tester);
}
