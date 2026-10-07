import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/exceptions/data_exceptions.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/domain/models/week/event/event.dart';
import 'package:life_calendar/domain/models/week/goal/goal.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';
import 'package:life_calendar/domain/services/database_initializer.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:path/path.dart' as p show basename, join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';

class DatabaseService implements DatabaseInitializer {
  static const tableName = 'TheCalendarDatabase';
  late Database _db;
  final int _dbVersion = 5;

  @override
  Future<Result> init() async {
    try {
      _db = await openDatabase(
        '${await getDatabasesPath()}${Platform.pathSeparator}$tableName',
        version: _dbVersion,
        onCreate: (db, version) async {
          final batch = db.batch();
          _createTableV2(batch);
          await batch.commit();
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          final batch = db.batch();
          // Cumulative thresholds so multi-step jumps (e.g. v1→v3, including
          // restoring an old backup file) run every required step.
          if (oldVersion < 2) {
            _updateTableV1toV2(batch);
          }
          if (oldVersion < 3) {
            _migrateAssessmentValuesV2toV3(batch);
          }
          await batch.commit();

          // Runs after the batch: needs async file I/O (path_provider +
          // File.copy), which cannot be queued into a sqflite Batch.
          if (oldVersion < 4) {
            await _migratePhotosToAppDirV3toV4(db);
          }
          if (oldVersion < 5) {
            await repairShiftedWeekIds(db);
          }
        },
      );

      return const Result.ok(null);
    } on Exception catch (e, s) {
      logger.e('Failed to open database', error: e, stackTrace: s);
      return Result.error(e);
    }
  }

  void _createTableV2(Batch batch) {
    batch
      ..execute('DROP TABLE IF EXISTS $tableName')
      ..execute(
        'CREATE TABLE IF NOT EXISTS $tableName ('
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
      );
  }

  void _updateTableV1toV2(Batch batch) {
    batch.execute('ALTER TABLE $tableName ADD photos TEXT');
  }

  /// Rewrites legacy localized assessment values to language-neutral codes.
  ///
  /// Builds <= db v2 stored the Russian display strings; the literals below are
  /// frozen historical values and intentionally hardcoded (not derived from the
  /// current enum).
  void _migrateAssessmentValuesV2toV3(Batch batch) {
    const legacyToCode = {
      'Хорошо': 'good',
      'Плохо': 'bad',
      'Нейтрально': 'poor',
    };
    for (final entry in legacyToCode.entries) {
      batch.rawUpdate(
        'UPDATE $tableName SET assessment = ? WHERE assessment = ?',
        [entry.value, entry.key],
      );
    }
  }

  /// Adopts photos captured by the pre-3.0 app into the new storage model.
  ///
  /// Older builds stored the raw `image_picker` cache path in the DB and never
  /// copied the file anywhere, whereas the current app resolves every photo
  /// against `getApplicationDocumentsDirectory()/$kImageDirName`. On an in-place
  /// upgrade the old files still sit in the cache dir, so we copy each one into
  /// the canonical images dir and rewrite the DB entry to a bare filename.
  ///
  /// Best-effort: a photo whose source file the OS has already evicted from the
  /// cache is left as a filename record (nothing to recover), and any per-row
  /// failure is logged without aborting the remaining rows.
  Future<void> _migratePhotosToAppDirV3toV4(Database db) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDocDir.path, kImageDirName));

    await migratePhotosToImagesDir(db, imagesDir);
  }

  /// Testable core of the v3→v4 photo migration.
  ///
  /// Copies every photo referenced in the DB into [imagesDir] (keeping its
  /// file name) and rewrites each row's `photos` column to bare file names.
  /// Split out from [_migratePhotosToAppDirV3toV4] so tests can pass a temp
  /// directory instead of relying on `path_provider`.
  @visibleForTesting
  Future<void> migratePhotosToImagesDir(
    Database db,
    Directory imagesDir,
  ) async {
    final List<Map<String, dynamic>> rows = await db.query(
      tableName,
      columns: ['id', 'photos'],
      where: 'photos IS NOT NULL AND photos != ?',
      whereArgs: ['[]'],
    );

    if (rows.isEmpty) return;

    if (!imagesDir.existsSync()) {
      imagesDir.createSync(recursive: true);
    }

    for (final row in rows) {
      final int id = row['id'] as int;
      final String rawPhotos = row['photos'] as String;

      try {
        final decoded = jsonDecode(rawPhotos);
        if (decoded is! List) continue;

        final oldPaths = decoded.map((e) => e.toString()).toList();
        final newPaths = <String>[];

        for (final oldPath in oldPaths) {
          final fileName = p.basename(oldPath);
          final destPath = p.join(imagesDir.path, fileName);

          // Copy the source file into the images dir unless it is already
          // there (idempotent re-runs, or a path that was already canonical).
          if (!File(destPath).existsSync() && File(oldPath).existsSync()) {
            File(oldPath).copySync(destPath);
          }

          newPaths.add(fileName);
        }

        await db.update(
          tableName,
          {'photos': jsonEncode(newPaths)},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e, s) {
        logger.e(
          'Failed to migrate photos for week $id (v3→v4)',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  /// Repairs week ids broken by lifespan increases in 3.0.0 (v4→v5).
  ///
  /// That build appended new weeks starting from the id of the last existing
  /// week, so every increase overwrote that week and shifted all appended
  /// weeks one id down. Weeks are contiguous Monday to Sunday blocks, so the
  /// correct id of a week is the number of weeks since the first one: rows are
  /// renumbered by that rule and each overwritten week is recreated empty.
  ///
  /// Only this exact damage is repaired. If start dates aren't 7 days apart or
  /// an id would have to move down, the table is left as is.
  @visibleForTesting
  Future<void> repairShiftedWeekIds(Database db, {DateTime? now}) async {
    try {
      final rows = await db.query(
        tableName,
        columns: ['id', 'yearId', 'start'],
        orderBy: 'start ASC',
      );
      if (rows.isEmpty) return;

      final firstStart = _calendarDay(rows.first['start']! as int);
      final expectedIds = <int>[];
      for (final row in rows) {
        final days = _calendarDay(
          row['start']! as int,
        ).difference(firstStart).inDays;
        if (days % 7 != 0 || days ~/ 7 < (row['id']! as int)) {
          logger.w('Unexpected week layout, week ids are not repaired');
          return;
        }
        expectedIds.add(days ~/ 7);
      }
      if (expectedIds.toSet().length != expectedIds.length) {
        logger.w('Duplicate week start dates, week ids are not repaired');
        return;
      }

      var isIntact = expectedIds.last + 1 == rows.length;
      for (var i = 0; isIntact && i < rows.length; i++) {
        isIntact = rows[i]['id'] == expectedIds[i];
      }
      if (isIntact) return;

      final firstMonday = DateTime.fromMillisecondsSinceEpoch(
        rows.first['start']! as int,
      );
      final today = now ?? DateTime.now();

      await db.transaction((txn) async {
        // Two passes through negative ids, so a row never takes the id of a
        // row that hasn't moved yet.
        for (var i = 0; i < rows.length; i++) {
          await txn.rawUpdate('UPDATE $tableName SET id = ? WHERE id = ?', [
            -expectedIds[i] - 1,
            rows[i]['id'],
          ]);
        }
        await txn.rawUpdate('UPDATE $tableName SET id = -id - 1 WHERE id < 0');

        final yearIds = {
          for (var i = 0; i < rows.length; i++)
            expectedIds[i]: rows[i]['yearId']! as int,
        };
        var yearId = yearIds[0]!;
        for (var id = 0; id <= expectedIds.last; id++) {
          final knownYearId = yearIds[id];
          if (knownYearId != null) {
            yearId = knownYearId;
            continue;
          }

          final start = DateTime(
            firstMonday.year,
            firstMonday.month,
            firstMonday.day + 7 * id,
          );
          final end = DateTime(
            start.year,
            start.month,
            start.day + 6,
            23,
            59,
            59,
          );
          final week = Week(
            id: id,
            yearId: yearId,
            start: start,
            end: end,
            tense: end.isBefore(today) ? WeekTense.past : WeekTense.future,
            assessment: WeekAssessment.poor,
            goals: const [],
            events: const [],
            resume: '',
            photos: const [],
          );
          await txn.insert(tableName, week.toJson());
        }
      });
      logger.i('Repaired week ids after lifespan increase');
    } catch (e, s) {
      logger.e('Failed to repair week ids (v4→v5)', error: e, stackTrace: s);
    }
  }

  static DateTime _calendarDay(int millisecondsSinceEpoch) {
    final date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<bool> insertWeeks(List<Week> weeks) {
    return _db.transaction((txn) async {
      final batch = txn.batch();

      for (final week in weeks) {
        batch.insert(
          tableName,
          week.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      final result = await batch.commit(
        continueOnError: false,
        noResult: false,
      );

      if (result.isNotEmpty) {
        logger.d('Inserted ${result.length} rows in table');
        return true;
      }

      logger.e('Some error: inserted 0 rows');
      return false;
    });
  }

  Future<bool> insertWeek(Week week) async {
    final insertCount = await _db.insert(
      tableName,
      week.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return insertCount == 1;
  }

  Future<List<Week>> getAllWeeks() async {
    final records = await _db.query(tableName);

    final weeks = await compute(_parseWeeks, records);

    return weeks;
  }

  static List<Week> _parseWeeks(List<Map<String, Object?>> records) {
    final weeks = List.generate(
      records.length,
      (i) => Week.fromJson(records[i]),
      growable: false,
    );

    return weeks;
  }

  Future<Week> getWeek(int id) async {
    final records = await _db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    final record = records.firstOrNull;
    if (record == null) {
      throw WeekNotFoundException('No week with id $id in DB');
    }

    return Week.fromJson(record);
  }

  Future<Week> getCurrentWeek() async {
    final records = await _db.query(
      tableName,
      where: 'state = ?',
      whereArgs: [WeekTense.current.name],
    );

    if (records.length != 1) {
      logger.w('Number of current week in DB: ${records.length}');
    }

    final record = records.firstOrNull;
    if (record == null) {
      throw const WeekNotFoundException('No current week in DB');
    }

    return Week.fromJson(record);
  }

  /// Advances week tenses to reflect [today] in a single transaction.
  ///
  /// Every week that has already ended (`end < today`) becomes `past`, and the
  /// week covering [today] (smallest `id` with `end >= today`) becomes
  /// `current`. This replaces a week-by-week walk: cost is constant (one query
  /// + two range updates) regardless of how many weeks have elapsed, and only
  /// the `state` column is touched (no full-row JSON re-encode).
  ///
  /// Throws [WeekNotFoundException] if no week covers [today] (e.g. the date is
  /// past the end of the generated calendar, or the table is empty).
  Future<Week> advanceCurrentWeekTo(DateTime today) {
    final todayMs = today.millisecondsSinceEpoch;

    return _db.transaction((txn) async {
      final records = await txn.query(
        tableName,
        where: 'end >= ?',
        whereArgs: [todayMs],
        orderBy: 'id ASC',
        limit: 1,
      );

      final record = records.firstOrNull;
      if (record == null) {
        throw const WeekNotFoundException('No week covers the current date');
      }

      final newCurrentWeek = Week.fromJson(
        record,
      ).copyWith(tense: WeekTense.current);

      await txn.rawUpdate(
        'UPDATE $tableName SET state = ? WHERE end < ? AND state != ?',
        [WeekTense.past.name, todayMs, WeekTense.past.name],
      );
      // Reset any stale `current` other than the one we're about to set. If the
      // device clock moved backwards, the previous current week now has
      // `end >= today` (so it escaped the `past` update above) and would leave
      // the table with two current weeks; demote it to `future`.
      await txn.rawUpdate(
        'UPDATE $tableName SET state = ? WHERE state = ? AND id != ?',
        [WeekTense.future.name, WeekTense.current.name, newCurrentWeek.id],
      );
      await txn.rawUpdate('UPDATE $tableName SET state = ? WHERE id = ?', [
        WeekTense.current.name,
        newCurrentWeek.id,
      ]);

      return newCurrentWeek;
    });
  }

  Future<void> updateAssessment({
    required int weekId,
    required WeekAssessment assessment,
  }) {
    return _db.rawUpdate('UPDATE $tableName SET assessment = ? WHERE id = ?', [
      assessment.name,
      weekId,
    ]);
  }

  Future<void> updateEvents({
    required int weekId,
    required List<Event> events,
  }) {
    return _db.rawUpdate('UPDATE $tableName SET events = ? WHERE id = ?', [
      jsonEncode(events),
      weekId,
    ]);
  }

  Future<void> updateGoals({required int weekId, required List<Goal> goals}) {
    return _db.rawUpdate('UPDATE $tableName SET goals = ? WHERE id = ?', [
      jsonEncode(goals),
      weekId,
    ]);
  }

  Future<void> updateResume({required int weekId, required String resume}) {
    return _db.rawUpdate('UPDATE $tableName SET resume = ? WHERE id = ?', [
      resume,
      weekId,
    ]);
  }

  Future<void> updatePhotos({
    required int weekId,
    required List<String> photos,
  }) {
    return _db.rawUpdate('UPDATE $tableName SET photos = ? WHERE id = ?', [
      jsonEncode(photos),
      weekId,
    ]);
  }

  Future<Week> getLastWeek() async {
    final records = await _db.query(tableName, orderBy: 'id DESC', limit: 1);

    if (records.length != 1) {
      logger.w('Number of current week in DB: ${records.length}');
    }

    final record = records.firstOrNull;
    if (record == null) {
      throw const WeekNotFoundException('No weeks in DB');
    }

    return Week.fromJson(record);
  }

  Future<void> removeWeeksByYearIds({
    required int startYearId,
    required int endYearId,
  }) async {
    if (endYearId < startYearId) {
      throw Exception(
        'Invalid range: end yearId ($endYearId) < start yearId ($startYearId)',
      );
    }

    final deleted = await _db.delete(
      tableName,
      where: 'yearId BETWEEN ? AND ?',
      whereArgs: [startYearId, endYearId],
    );

    logger.i(
      'Deleted $deleted weeks (between years $startYearId and $endYearId)',
    );
  }

  Future<bool> hasChangesInRange({
    required int startYearId,
    required int endYearId,
  }) async {
    final result = await _db.rawQuery(
      '''
        SELECT COUNT(*) as cnt
        FROM $tableName
        WHERE yearId BETWEEN ? AND ?
          AND (
                (assessment IS NOT NULL AND assessment != ?)
            OR (goals IS NOT NULL AND goals != '[]')
            OR (events IS NOT NULL AND events != '[]')
            OR (resume IS NOT NULL AND resume != '')
            OR (photos IS NOT NULL AND photos != '[]')
          )
        LIMIT 1
      ''',
      [startYearId, endYearId, WeekAssessment.poor.name],
    );

    final count = Sqflite.firstIntValue(result) ?? 0;

    return count > 0;
  }

  Future<void> normalizePhotoPaths() async {
    // 1. Read: Select only rows where photos column is not empty/null.
    // We avoid '[]' (empty JSON array) to save resources.
    final List<Map<String, dynamic>> rows = await _db.query(
      tableName, // Your table name variable
      columns: ['id', 'photos'],
      where: 'photos IS NOT NULL AND photos != ?',
      whereArgs: ['[]'],
    );

    if (rows.isEmpty) return;

    final batch = _db.batch();
    bool batchHasOps = false;

    for (final row in rows) {
      final int id = row['id'] as int;
      final String rawPhotos = row['photos'] as String;

      try {
        // 2. Process: Decode JSON
        final decoded = jsonDecode(rawPhotos);

        // If it's not a list, skip it
        if (decoded is! List) continue;

        final List<String> oldPaths = decoded.map((e) => e.toString()).toList();
        final List<String> newPaths = [];
        bool needsUpdate = false;

        for (final fullPath in oldPaths) {
          // Extract filename: '/var/.../image.jpg' -> 'image.jpg'
          final fileName = p.basename(fullPath);
          newPaths.add(fileName);

          // Check if the path was actually changed
          // (to avoid unnecessary updates)
          if (fullPath != fileName) {
            needsUpdate = true;
          }
        }

        // 3. Write: Add to batch if paths were changed
        if (needsUpdate) {
          batch.update(
            tableName,
            {'photos': jsonEncode(newPaths)},
            where: 'id = ?',
            whereArgs: [id],
          );
          batchHasOps = true;
        }
      } catch (e) {
        // Log error but continue with other rows
        logger.e(
          'Failed to parse photos for id $id during migration',
          error: e,
        );
      }
    }

    // Commit transaction if there are pending updates
    if (batchHasOps) {
      await batch.commit(noResult: true);
    }
  }

  Future<void> close() async {
    await _db.close();
    logger.i('DB is closed');
  }
}
