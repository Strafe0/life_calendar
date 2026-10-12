import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';

import '../support.dart';

/// Runs on top of the data left by seed_3_0_0.dart, the way a store update
/// installs the new version over the old one (scripts/upgrade_test.sh).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  appTest('data saved by 3.0.0 survives the upgrade and is repaired', (
    tester,
  ) async {
    await launchApp(tester, reset: false);
    await waitForCalendar(
      tester,
      (weeks) => weeks.last.yearId == 70,
      description: 'the calendar saved by 3.0.0',
    );

    final expected = CalendarGenerator(
      birthday: upgradeBirthDate,
      lifeSpan: 70,
    ).generateWeeks();
    final weeks = calendarWeeks(tester);
    expect(weeks.map((w) => w.weekId), expected.map((w) => w.id));
    expect(weeks.map((w) => w.week.start), expected.map((w) => w.start));

    WeekAssessment firstWeekOf(int year) =>
        weeks.firstWhere((w) => w.yearId == year).week.assessment;
    expect(firstWeekOf(10), WeekAssessment.good);
    expect(firstWeekOf(65), WeekAssessment.bad);
  });
}
