import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:life_calendar/calendar_app.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/l10n/app_localizations.dart';
import 'package:life_calendar/data/services/database_service.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/firebase_options.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_cubit.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/bloc/calendar_state.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/models/week_box.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_view_body.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_cubit.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_state.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_screen.dart';
import 'package:life_calendar/ui/registration/widgets/registration_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const english = Locale('en');

/// Birth date of the user created by the upgrade check.
final upgradeBirthDate = DateTime(1990);

AppLocalizations l10nFor(Locale locale) => lookupAppLocalizations(locale);

Future<String> databasePath() async =>
    p.join(await getDatabasesPath(), DatabaseService.tableName);

/// Wipes everything the app stores, so each test starts as a fresh install.
Future<void> resetAppData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  // Also closes the connection a previous test left open.
  await deleteDatabase(await databasePath());
  final documents = await getApplicationDocumentsDirectory();
  final images = Directory(p.join(documents.path, kImageDirName));
  if (images.existsSync()) images.deleteSync(recursive: true);
}

var _firebaseReady = false;

Future<void> _initFirebase() async {
  if (_firebaseReady) return;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Test runs must not show up in the app's statistics or crash reports.
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  _firebaseReady = true;
}

/// A widget test that undoes the app's global side effects at its end.
///
/// The app sets ErrorWidget.builder in MaterialApp.builder, and the test
/// binding fails a test that leaves it changed.
void appTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    final errorWidgetBuilder = ErrorWidget.builder;
    try {
      await body(tester);
    } finally {
      ErrorWidget.builder = errorWidgetBuilder;
    }
  });
}

/// A fresh install with Firebase ready, before the app is started.
Future<void> prepareInstall() async {
  await _initFirebase();
  await resetAppData();
}

/// Starts the app in [locale]. Pass `reset: false` to keep the stored data,
/// which is what an app restart looks like.
Future<void> launchApp(
  WidgetTester tester, {
  Locale locale = english,
  bool reset = true,
}) async {
  await _initFirebase();
  if (reset) await resetAppData();
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  // A new key gives a new app instance, like a real restart.
  await tester.pumpWidget(CalendarApp(key: UniqueKey()));
}

/// Pumps frames until [finder] matches something.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

/// Pumps frames until [condition] holds.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  String description = 'condition',
  Duration timeout = const Duration(seconds: 30),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  }
  throw TestFailure('Timed out waiting for $description');
}

/// Lets animations and async work finish. Unlike pumpAndSettle it never
/// hangs on the splash spinner.
Future<void> settle(WidgetTester tester, [int frames = 15]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await settle(tester);
}

/// Types [date] the way a person would in [locale]: digits only, the field
/// inserts the separators itself.
String dateDigits(DateTime date, Locale locale) {
  final pattern = DateFormat.yMd(locale.toString()).pattern ?? 'dd.MM.y';
  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final yyyy = date.year.toString();
  if (pattern.startsWith('y')) return '$yyyy$mm$dd';
  return pattern.startsWith('M') ? '$mm$dd$yyyy' : '$dd$mm$yyyy';
}

/// Skips the onboarding and registers through the form.
Future<void> register(
  WidgetTester tester, {
  required DateTime birthDate,
  required int lifeSpan,
  Locale locale = english,
}) async {
  final l10n = l10nFor(locale);
  await pumpUntilFound(tester, find.text(l10n.skip));
  await tapText(tester, l10n.skip);
  await fillRegistration(
    tester,
    birthDate: dateDigits(birthDate, locale),
    lifeSpan: '$lifeSpan',
  );
  await tapText(tester, l10n.ready);
  await pumpUntilFound(tester, find.byType(CalendarViewBody));
  await settle(tester);
}

Future<void> fillRegistration(
  WidgetTester tester, {
  required String birthDate,
  required String lifeSpan,
}) async {
  final fields = find.descendant(
    of: find.byType(RegistrationPage),
    matching: find.byType(TextFormField),
  );
  await pumpUntilFound(tester, fields);
  await tester.enterText(fields.at(0), birthDate);
  await tester.enterText(fields.at(1), lifeSpan);
  await settle(tester, 5);
}

/// Fresh install, registered and showing the calendar.
Future<void> launchRegistered(
  WidgetTester tester, {
  DateTime? birthDate,
  int lifeSpan = 80,
  Locale locale = english,
}) async {
  await launchApp(tester, locale: locale);
  await register(
    tester,
    birthDate: birthDate ?? DateTime(1995, 3, 14),
    lifeSpan: lifeSpan,
    locale: locale,
  );
}

/// The loaded calendar, or null while it is loading or not on screen.
List<WeekBox>? loadedWeeks(WidgetTester tester) {
  final body = find.byType(CalendarViewBody);
  if (body.evaluate().isEmpty) return null;
  final state = tester.element(body).read<CalendarCubit>().state;
  return state is CalendarSuccess ? state.weeks : null;
}

Future<void> waitForCalendar(
  WidgetTester tester,
  bool Function(List<WeekBox> weeks) condition, {
  String description = 'the calendar',
}) => pumpUntil(tester, () {
  final weeks = loadedWeeks(tester);
  return weeks != null && condition(weeks);
}, description: description);

List<WeekBox> calendarWeeks(WidgetTester tester) {
  final context = tester.element(find.byType(CalendarViewBody));
  final state = context.read<CalendarCubit>().state;
  if (state is! CalendarSuccess) {
    throw TestFailure('Calendar is not loaded: $state');
  }
  return state.weeks;
}

/// Taps the square of [weekId] on the painted grid.
Future<void> tapWeek(WidgetTester tester, int weekId) async {
  final box = calendarWeeks(tester).firstWhere((w) => w.weekId == weekId);
  final origin = tester.getTopLeft(find.byType(CalendarViewBody));
  await tester.tapAt(origin + box.rect.center);
  await waitForWeek(tester);
}

Future<void> waitForWeek(WidgetTester tester) async {
  await pumpUntilFound(tester, find.byType(WeekScreen));
  await pumpUntil(
    tester,
    () =>
        tester.element(find.byType(WeekScreen)).read<WeekCubit>().state
            is WeekSuccess,
    description: 'the week to load',
  );
  await settle(tester);
}

Week openedWeek(WidgetTester tester) {
  final context = tester.element(find.byType(WeekScreen));
  final state = context.read<WeekCubit>().state;
  if (state is! WeekSuccess) throw TestFailure('Week is not loaded: $state');
  return state.week;
}

Future<void> closeWeek(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await pumpUntilFound(tester, find.byType(CalendarViewBody));
  await settle(tester);
}

/// Pulls the calendar down (search) or up (current week) past the trigger.
Future<void> pullCalendar(WidgetTester tester, {required bool down}) async {
  final body = find.byType(CalendarViewBody);
  final center = tester.getCenter(body);
  final gesture = await tester.startGesture(center);
  for (var i = 0; i < 20; i++) {
    await gesture.moveBy(Offset(0, down ? 12 : -12));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await settle(tester);
}

/// Swipes the calendar to the right, which pulls the side menu open.
Future<void> openMenu(WidgetTester tester) async {
  final body = find.byType(CalendarViewBody);
  final topLeft = tester.getTopLeft(body);
  final size = tester.getSize(body);
  final gesture = await tester.startGesture(
    topLeft + Offset(20, size.height / 2),
  );
  for (var i = 0; i < 20; i++) {
    await gesture.moveBy(Offset(size.width * 0.04, 0));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await settle(tester);
}

/// Taps the dimmed area to the right of the open menu.
Future<void> closeMenu(WidgetTester tester) async {
  final size = tester.getSize(find.byType(CalendarViewBody));
  final origin = tester.getTopLeft(find.byType(CalendarViewBody));
  await tester.tapAt(origin + Offset(size.width - 8, size.height / 2));
  await settle(tester);
}
