import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:flutter/material.dart' show debugPrint;

class AppDatabase {
  static const String tableName = 'TheCalendarDatabase';
  late Database _db;
  final int _dbVersion = 2;

  Future init() async {
    _db = await openDatabase(
      "${await getDatabasesPath()}${Platform.pathSeparator}$tableName",
      version: _dbVersion,
      onCreate: (db, version) async {
        var batch = db.batch();
        _createTableV2(batch);
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();
        if (oldVersion == 1) {
          _updateTableV1toV2(batch);
        }
        await batch.commit();
      },
    );
  }

  void _createTableV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $tableName');
    batch.execute('CREATE TABLE IF NOT EXISTS $tableName ('
        'id INTEGER PRIMARY KEY,'
        'yearId INTEGER NOT NULL,'
        'state TEXT NOT NULL,'
        'start INTEGER NOT NULL,'
        'end INTEGER NOT NULL,'
        'assessment TEXT,'
        'goals TEXT,'
        'events TEXT,'
        'resume TEXT,'
        'photos TEXT)');
  }

  void _updateTableV1toV2(Batch batch) {
    batch.execute('ALTER TABLE $tableName ADD photos TEXT');
  }

  Future<bool> insertWeek(Week week) async {
    return await _db.insert(tableName, week.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace) !=
        0;
  }

  Future<bool> insertAllWeeks(List<Week> weeks) async {
    return await _db.transaction((txn) async {
      var batch = txn.batch();
      for (var week in weeks) {
        batch.insert(tableName, week.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
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

  Future<List<Week>> getAllWeeks() async {
    var records = await _db.query(tableName);
    List<Week> weeks =
        List.generate(records.length, (i) => Week.fromJson(records[i]));
    return weeks;
  }

  Future<Week> getWeekById(int id) async {
    var records = await _db.query(tableName, where: 'id = ?', whereArgs: [id]);
    return Week.fromJson(records.first);
  }

  Future<Week> getCurrentWeek() async {
    var records = await _db.query(tableName,
        where: 'state = ?', whereArgs: [WeekState.current.name]);
    return Week.fromJson(records.first);
  }

  Future<void> updateWeekStates() async {
    int changeNumber = 0;
    int currentWeekId = (await getCurrentWeek()).id;

    changeNumber += await _db.rawUpdate(
        'UPDATE $tableName SET state = ? WHERE id < ?',
        [WeekState.past.name, currentWeekId]);
    changeNumber += await _db.rawUpdate(
        'UPDATE $tableName SET state = ? WHERE id > ?',
        [WeekState.future.name, currentWeekId]);

    debugPrint('Changed $changeNumber weeks');
  }

  Future<void> updateCurrentWeek(int currentWeekId) async {
    await _db.rawUpdate('UPDATE $tableName SET state = ? WHERE id = ?',
        [WeekState.current.name, currentWeekId]);
    await updateWeekStates();
  }

  Future<int> updateAssessment(Week week) async {
    return await _db.rawUpdate(
        'UPDATE $tableName SET assessment = ? WHERE id = ?',
        [week.assessment.name, week.id]);
  }

  Future<int> updateEvents(Week week) async {
    return await _db.rawUpdate('UPDATE $tableName SET events = ? WHERE id = ?',
        [Week.eventsToJson(week.events), week.id]);
  }

  Future<int> updateGoals(Week week) async {
    return await _db.rawUpdate('UPDATE $tableName SET goals = ? WHERE id = ?',
        [Week.goalsToJson(week.goals), week.id]);
  }

  Future<int> updateResume(Week week) async {
    return await _db.rawUpdate('UPDATE $tableName SET resume = ? WHERE id = ?',
        [week.resume, week.id]);
  }

  Future<int> updatePhoto(Week week) async {
    // return await _db.update(tableName, week.toJson(), where: 'id = ?', whereArgs: [week.id]);
    return await _db.rawUpdate('UPDATE $tableName SET photos = ? WHERE id = ?',
        [jsonEncode(week.photos), week.id]);
  }

  Future<bool> tableIsEmpty() async {
    int? count = Sqflite.firstIntValue(
        await _db.rawQuery('SELECT COUNT(*) FROM $tableName'));

    if (count != null && count != 0) {
      return false;
    } else {
      return true;
    }
  }

  Future clearTable() async {
    await _db.execute('DELETE FROM $tableName');
  }
}
