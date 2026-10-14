import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/services/database_service.dart';
import 'package:life_calendar/data/services/shared_preferences_service.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:sqflite/sqflite.dart';

import '../support.dart';

void migrationTests() {
  final birthDate = DateTime(1990);
  const table = DatabaseService.tableName;

  /// Leaves the data the way 3.0.0 did after a lifespan increase from 60 to
  /// 70: the appended weeks start from the id of the last existing week.
  Future<void> installBrokenVersion4() async {
    const prefs = SharedPreferencesService();
    await prefs.setFirstLaunch(isFirstLaunch: false);
    await prefs.setFirstLaunchV3(isFirstLaunch: false);
    await prefs.setUserId('integration-test-user');
    await prefs.setBirthday(birthDate);
    await prefs.setLifespan(70);

    final db = await openDatabase(
      await databasePath(),
      version: 4,
      onCreate: (db, _) => db.execute(
        'CREATE TABLE $table ('
        'id INTEGER PRIMARY KEY,'
        'yearId INTEGER NOT NULL,'
        'state TEXT NOT NULL,'
        'start INTEGER NOT NULL,'
        'end INTEGER NOT NULL,'
        'assessment TEXT,'
        'goals TEXT,'
        'events TEXT,'
        'resume TEXT,'
        'photos TEXT)',
      ),
    );
    Future<void> insert(List<Week> weeks) async {
      final batch = db.batch();
      for (final week in weeks) {
        batch.insert(
          table,
          week.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }

    final original = CalendarGenerator(
      birthday: birthDate,
      lifeSpan: 60,
    ).generateWeeks();
    await insert(original);
    await insert(
      CalendarGenerator(
        birthday: birthDate.copyWith(year: birthDate.year + 61),
        lifeSpan: 9,
      ).generateWeeks(startWeekIndex: original.last.id, startYearIndex: 61),
    );
    await db.update(
      table,
      {'resume': 'Appended week'},
      where: 'id = ?',
      whereArgs: [original.last.id + 10],
    );
    await db.close();
  }

  group('Migration', () {
    appTest('3.0.0 data after a lifespan increase is repaired on start', (
      tester,
    ) async {
      await prepareInstall();
      await installBrokenVersion4();

      await launchApp(tester, reset: false);
      await waitForCalendar(
        tester,
        (weeks) => weeks.last.yearId == 70,
        description: 'the repaired calendar',
      );

      final expected = CalendarGenerator(
        birthday: birthDate,
        lifeSpan: 70,
      ).generateWeeks();
      final weeks = calendarWeeks(tester);
      expect(weeks.map((w) => w.weekId), expected.map((w) => w.id));
      expect(weeks.map((w) => w.week.start), expected.map((w) => w.start));

      final lastOriginalId = CalendarGenerator(
        birthday: birthDate,
        lifeSpan: 60,
      ).generateWeeks().last.id;
      // The appended week moved one id up together with its data.
      final moved = weeks.firstWhere((w) => w.weekId == lastOriginalId + 11);
      expect(moved.week.resume, 'Appended week');
    });
  });
}
