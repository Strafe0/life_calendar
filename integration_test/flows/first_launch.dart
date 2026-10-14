import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';

import '../support.dart';

void firstLaunchTests() {
  group('First launch', () {
    appTest('onboarding leads to a calendar of lifespan + 1 years', (
      tester,
    ) async {
      await launchRegistered(tester, lifeSpan: 80);

      final weeks = calendarWeeks(tester);
      expect(weeks.first.yearId, 0);
      expect(weeks.last.yearId, 80);
      expect(
        weeks.where((w) => w.week.tense == WeekTense.current),
        hasLength(1),
      );
    });
  });
}
