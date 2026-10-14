import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_view_body.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_assessment/week_assessment_ui_extension.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_events/event_change_sheet.dart';
import 'package:life_calendar/ui/core/menus/adaptive_action_menu.dart';

import '../support.dart';

void weekTests() {
  final l10n = l10nFor(english);

  Future<void> openFabItem(WidgetTester tester, String label) async {
    await tester.tap(find.byIcon(Icons.add));
    await settle(tester);
    await tapText(tester, label);
  }

  Future<void> addGoal(WidgetTester tester, String title) async {
    await openFabItem(tester, l10n.goal);
    await tester.enterText(find.byType(TextFormField).last, title);
    await tapText(tester, l10n.ready);
  }

  Future<void> addEvent(
    WidgetTester tester,
    String title,
    DateTime date,
  ) async {
    await openFabItem(tester, l10n.event);
    final fields = find.descendant(
      of: find.byType(EventChangeSheet),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), title);
    await tester.enterText(fields.at(1), dateDigits(date, english));
    await tapText(tester, l10n.ready);
  }

  Future<void> writeSummary(WidgetTester tester, String text) async {
    await openFabItem(tester, l10n.resume);
    await tester.enterText(find.byType(TextField).last, text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
  }

  int currentWeekId(WidgetTester tester) => calendarWeeks(
    tester,
  ).firstWhere((w) => w.week.tense == WeekTense.current).weekId;

  group('Week', () {
    appTest('pulling the calendar up opens the current week', (tester) async {
      await launchRegistered(tester);

      await pullCalendar(tester, down: false);
      await waitForWeek(tester);

      expect(openedWeek(tester).tense, WeekTense.current);
    });

    appTest('edits are saved and survive a restart', (tester) async {
      await launchRegistered(tester);
      final weekId = currentWeekId(tester);
      await tapWeek(tester, weekId);
      final eventDate = openedWeek(tester).start;

      await tapText(tester, WeekAssessment.good.label(l10n));
      await addGoal(tester, 'Run 5 km');
      await tester.tap(find.byType(CheckboxListTile));
      await settle(tester);
      await addEvent(tester, 'Dentist', eventDate);
      await writeSummary(tester, 'A calm and productive week');

      void expectSaved() {
        final week = openedWeek(tester);
        expect(week.assessment, WeekAssessment.good);
        expect(week.goals.single.title, 'Run 5 km');
        expect(week.goals.single.isCompleted, isTrue);
        expect(week.events.single.title, 'Dentist');
        expect(week.resume, 'A calm and productive week');
      }

      expectSaved();

      await closeWeek(tester);
      await tapWeek(tester, weekId);
      expectSaved();

      await launchApp(tester, reset: false);
      await pumpUntilFound(tester, find.byType(CalendarViewBody));
      await settle(tester);
      await tapWeek(tester, weekId);
      expectSaved();
      expect(find.text('Run 5 km'), findsOneWidget);
      expect(find.text('Dentist'), findsOneWidget);
    });

    appTest('a goal can be deleted', (tester) async {
      await launchRegistered(tester);
      await tapWeek(tester, currentWeekId(tester));
      await addGoal(tester, 'Read a book');

      await tester.tap(find.byType(AdaptiveActionMenu).first);
      await settle(tester);
      await tapText(tester, l10n.delete);

      expect(openedWeek(tester).goals, isEmpty);
      expect(find.text('Read a book'), findsNothing);
      expect(find.text(l10n.noGoals), findsOneWidget);
    });
  });
}
