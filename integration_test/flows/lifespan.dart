import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_assessment/week_assessment_ui_extension.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';

import '../support.dart';

void lifespanTests() {
  final l10n = l10nFor(english);
  final birthDate = DateTime(1990);

  Future<void> changeLifespan(WidgetTester tester, int years) async {
    await openMenu(tester);
    await tapText(tester, l10n.changeLifespan);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      '$years',
    );
    await tapText(tester, l10n.ready);
  }

  group('Lifespan', () {
    appTest('increasing it keeps every week and adds the new years', (
      tester,
    ) async {
      await launchRegistered(tester, birthDate: birthDate, lifeSpan: 60);

      await changeLifespan(tester, 70);
      expect(find.text(l10n.lifespanChangeDialogMessage), findsNothing);
      await waitForCalendar(
        tester,
        (weeks) => weeks.last.yearId == 70,
        description: 'the calendar to grow to 70 years',
      );

      final expected = CalendarGenerator(
        birthday: birthDate,
        lifeSpan: 70,
      ).generateWeeks();
      final weeks = calendarWeeks(tester);
      expect(weeks.map((w) => w.weekId), expected.map((w) => w.id));
      expect(weeks.map((w) => w.week.start), expected.map((w) => w.start));
    });

    appTest('reducing it warns only when removed years have data', (
      tester,
    ) async {
      await launchRegistered(tester, birthDate: birthDate, lifeSpan: 70);
      final inYear65 = calendarWeeks(
        tester,
      ).firstWhere((w) => w.yearId == 65).weekId;
      await tapWeek(tester, inYear65);
      await tapText(tester, WeekAssessment.good.label(l10n));
      await closeWeek(tester);

      await changeLifespan(tester, 62);
      expect(find.text(l10n.lifespanChangeDialogMessage), findsOneWidget);
      await tapText(tester, l10n.buttonYes);
      await waitForCalendar(
        tester,
        (weeks) => weeks.last.yearId == 62,
        description: 'the calendar to shrink to 62 years',
      );
      await closeMenu(tester);

      await changeLifespan(tester, 61);
      expect(find.text(l10n.lifespanChangeDialogMessage), findsNothing);
      await waitForCalendar(
        tester,
        (weeks) => weeks.last.yearId == 61,
        description: 'the calendar to shrink to 61 years',
      );
    });
  });
}
