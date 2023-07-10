import 'package:life_calendar/utils/utility_variables.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/calendar/year.dart';
import 'package:flutter/material.dart' show debugPrint;

class AppDatabase {
  static const String tableName = 'TheCalendarDatabase';
  late Database _db;
  final int _dbVersion = 1;

  Future init() async {
    _db = await openDatabase(join(await getDatabasesPath(), tableName),
      version: _dbVersion,
      onCreate: (db, version) {
        return db.execute('CREATE TABLE IF NOT EXISTS $tableName ('
            'id INTEGER PRIMARY KEY,'
            'yearId INTEGER NOT NULL,'
            'state TEXT NOT NULL,'
            'start INTEGER NOT NULL,'
            'end INTEGER NOT NULL,'
            'assessment TEXT,'
            'goals TEXT,'
            'events TEXT,'
            'resume TEXT)');
      }
    );
  }

  Future<bool> insertWeek(Week week) async {
    return await _db.insert(tableName, week.toJson(), conflictAlgorithm: ConflictAlgorithm.replace) != 0;
  }

  Future<bool> insertAllYears(List<Year> years) async {
    return await _db.transaction((txn) async {
      var batch = txn.batch();
      for (var year in years) {
        for (var week in year.weeks) {
          batch.insert(tableName, week.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      var result = await batch.commit(continueOnError: false, noResult: false);
      if (result.isNotEmpty) {
        debugPrint('Inserted ${result.length} rows in table');
        return true;
      }
      debugPrint('Some error: inserted 0 rows');
      return false;
    });
  }

  Future<List<Year>> getAll() async {
    List<Year> years = [];
    for (int yearIndex = 0; yearIndex < maxAge + 1; yearIndex++) {
      var records = await _db.query(tableName, where: 'yearId = ?', whereArgs: [yearIndex]);

      List<Week> weeks = List.generate(records.length, (i) => Week.fromJson(records[i]));
      years.add(Year(weeks.first.start, weeks.last.end, yearIndex)..weeks = weeks);
    }

    return years;
  }

  Future<Week> getCurrentWeek() async {
    var records = await _db.query(tableName, where: 'state = ?', whereArgs: [WeekState.current.name]);
    return Week.fromJson(records.first);
  }

  Future<void> updateDatabase() async {
    int changeNumber = 0;
    int currentWeekId = (await getCurrentWeek()).id;

    changeNumber += await _db.rawUpdate('UPDATE $tableName SET state = ? WHERE id < ?', [WeekState.past.name, currentWeekId]);
    changeNumber += await _db.rawUpdate('UPDATE $tableName SET state = ? WHERE id > ?', [WeekState.future.name, currentWeekId]);

    debugPrint('Changed $changeNumber weeks');
  }

  Future<void> updateCurrentWeek(int currentWeekId) async {
    int changeNumber = 0;
    changeNumber += await _db.rawUpdate('UPDATE $tableName SET state = ? WHERE state = ?', [WeekState.past.name, WeekState.current.name]);
    changeNumber += await _db.rawUpdate('UPDATE $tableName SET state = ? WHERE id = ?', [WeekState.current.name, currentWeekId]);

    if (changeNumber == 2) {
      debugPrint('The current week has been successfully updated.');
    } else {
      debugPrint('Some error in current week update: number of changes in db - $changeNumber');
    }
  }

  Future<int> updateAssessment(Week week) async {
    return await _db.rawUpdate('UPDATE $tableName SET assessment = ? WHERE id = ?', [week.assessment.name, week.id]);
  }

  Future<int> updateEvents(Week week) async {
    return await _db.rawUpdate('UPDATE $tableName SET events = ? WHERE id = ?', [Week.eventsToJson(week.events), week.id]);
  }

  Future<int> updateGoals(Week week) async {
    return await _db.rawUpdate('UPDATE $tableName SET goals = ? WHERE id = ?', [Week.goalsToJson(week.goals), week.id]);
  }

  Future<int> updateResume(Week week) async {
    return await _db.rawUpdate('UPDATE $tableName SET resume = ? WHERE id = ?', [week.resume, week.id]);
  }

  Future<bool> tableIsEmpty() async {
    int? count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM $tableName'));

    if (count != null && count != 0) {
      return false;
    } else {
      return true;
    }
  }
}