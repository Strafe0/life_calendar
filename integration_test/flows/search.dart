import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support.dart';

void searchTests() {
  final l10n = l10nFor(english);

  group('Search', () {
    // A Sunday birthday: 3.0.0 opened the next week for most dates.
    appTest('pulling down finds the week of a date', (tester) async {
      await launchRegistered(tester, birthDate: DateTime(1990, 1, 7));

      await pullCalendar(tester, down: true);
      await pumpUntilFound(tester, find.text(l10n.search));
      final date = DateTime(2010, 6, 15);
      await tester.enterText(
        find.byType(TextFormField).last,
        dateDigits(date, english),
      );
      await tapText(tester, l10n.ready);
      await waitForWeek(tester);

      final week = openedWeek(tester);
      expect(week.start.isAfter(date), isFalse, reason: '${week.start}');
      expect(week.end.isBefore(date), isFalse, reason: '${week.end}');
    });
  });
}
