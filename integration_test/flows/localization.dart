import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_view_body.dart';
import 'package:life_calendar/ui/registration/widgets/registration_page.dart';

import '../support.dart';

/// Walks the main screens in every language. Text that does not fit makes
/// Flutter report an overflow, which fails the test.
void localizationTests() {
  const locales = [
    Locale('en'),
    Locale('ru'),
    Locale('de'),
    Locale('es'),
    Locale('pt'),
    Locale('fr'),
    // Not supported: the app must fall back to English.
    Locale('it'),
  ];

  group('Localization', () {
    for (final locale in locales) {
      final appLocale = locale.languageCode == 'it' ? english : locale;
      final l10n = l10nFor(appLocale);

      appTest('${locale.languageCode}: screens fit and are translated', (
        tester,
      ) async {
        await launchApp(tester, locale: locale);
        await pumpUntilFound(tester, find.text(l10n.skip));

        // Every onboarding page; the last one holds the registration form
        // and has no forward arrow.
        final forward = find.byIcon(Icons.arrow_forward_ios);
        for (var i = 0; i < 10 && forward.evaluate().isNotEmpty; i++) {
          await tester.tap(forward);
          await settle(tester);
        }
        expect(
          find
              .descendant(
                of: find.byType(RegistrationPage),
                matching: find.byType(TextFormField),
              )
              .hitTestable(),
          findsNWidgets(2),
        );

        await fillRegistration(tester, birthDate: '1', lifeSpan: '200');
        await tapText(tester, l10n.ready);
        expect(find.text(l10n.dateFormatError), findsOneWidget);
        expect(
          find.text(l10n.lifespanInterval(User.minLifeSpan, User.maxLifeSpan)),
          findsOneWidget,
        );

        await fillRegistration(
          tester,
          birthDate: dateDigits(DateTime(1990, 5, 17), appLocale),
          lifeSpan: '80',
        );
        await tapText(tester, l10n.ready);
        await pumpUntilFound(tester, find.byType(CalendarViewBody));
        await settle(tester);
        expect(
          Localizations.localeOf(tester.element(find.byType(CalendarViewBody))),
          appLocale,
        );

        await openMenu(tester);
        await tapText(tester, l10n.calendarImport);
        expect(find.text(l10n.importDrawerDialogMessage), findsOneWidget);
        await tapText(tester, l10n.cancel);
        await tapText(tester, l10n.donate);
        expect(find.text(l10n.donateDialogMessage), findsOneWidget);
        await tapText(tester, l10n.donateDialogButtonNegative);
        await tapText(tester, l10n.changeLifespan);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tapText(tester, l10n.cancel);
        await closeMenu(tester);

        await pullCalendar(tester, down: false);
        await waitForWeek(tester);
        expect(find.text(l10n.rateWeek), findsOneWidget);
        await tester.tap(find.byIcon(Icons.add));
        await settle(tester);
        for (final label in [l10n.goal, l10n.event, l10n.photo, l10n.resume]) {
          expect(
            find.descendant(
              of: find.byType(FloatingActionButton),
              matching: find.text(label),
            ),
            findsOneWidget,
            reason: label,
          );
        }
      });
    }
  });
}
