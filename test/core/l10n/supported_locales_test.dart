import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/l10n/app_localizations.dart';

void main() {
  test('English is the fallback for unsupported languages', () {
    expect(AppLocalizations.supportedLocales.first, const Locale('en'));
  });

  testWidgets('an unsupported device language resolves to English', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('it', 'IT')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    late Locale resolved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            resolved = Localizations.localeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved, const Locale('en'));
  });
}
