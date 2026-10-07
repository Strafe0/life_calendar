import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/services/database_service.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  final birthday = DateTime(1990, 1, 1);
  final now = DateTime(2026, 10, 7);
  const table = DatabaseService.tableName;

  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    // Mirrors DatabaseService._createTableV2 (+ the photos column).
    await db.execute(
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
    );
  });

  tearDown(() => db.close());

  List<Week> generate(int lifeSpan) => CalendarGenerator(
    birthday: birthday,
    lifeSpan: lifeSpan,
    time: () => now,
  ).generateWeeks();

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

  Future<List<Week>> readAll() async {
    final rows = await db.query(table, orderBy: 'id ASC');
    return rows.map(Week.fromJson).toList();
  }

  Future<void> setResume(int id, String resume) =>
      db.update(table, {'resume': resume}, where: 'id = ?', whereArgs: [id]);

  /// Appends weeks the way 3.0.0 did it, starting from the last week's id.
  Future<void> increaseLikeV3(int oldLifeSpan, int newLifeSpan) async {
    final weeks = await readAll();
    await insert(
      CalendarGenerator(
        birthday: birthday.copyWith(year: birthday.year + oldLifeSpan + 1),
        lifeSpan: newLifeSpan - oldLifeSpan - 1,
        time: () => now,
      ).generateWeeks(
        startWeekIndex: weeks.last.id,
        startYearIndex: oldLifeSpan + 1,
      ),
    );
  }

  void expectLayoutOf(List<Week> actual, List<Week> expected) {
    expect(actual.map((w) => w.id), expected.map((w) => w.id));
    expect(actual.map((w) => w.yearId), expected.map((w) => w.yearId));
    expect(actual.map((w) => w.start), expected.map((w) => w.start));
    expect(actual.map((w) => w.end), expected.map((w) => w.end));
  }

  test('leaves an intact calendar untouched', () async {
    await insert(generate(60));
    await setResume(100, 'kept');
    final before = await readAll();

    await DatabaseService().repairShiftedWeekIds(db, now: now);

    expect(await readAll(), before);
  });

  test('restores ids after a lifespan increase made by 3.0.0', () async {
    await insert(generate(60));
    final oldLastId = (await readAll()).last.id;
    await setResume(100, 'early week');
    await increaseLikeV3(60, 70);
    // The 6th appended week, stored one id too low by 3.0.0.
    await setResume(oldLastId + 5, 'appended week');
    final appendedStart = (await readAll())[oldLastId + 5].start;

    await DatabaseService().repairShiftedWeekIds(db, now: now);

    final repaired = await readAll();
    expectLayoutOf(repaired, generate(70));
    expect(repaired[100].resume, 'early week');
    expect(repaired[oldLastId + 6].resume, 'appended week');
    expect(repaired[oldLastId + 6].start, appendedStart);
    expect(repaired[oldLastId].resume, isEmpty);
    expect(repaired[oldLastId].yearId, 60);
  });

  test('restores ids after two increases in a row', () async {
    await insert(generate(60));
    await increaseLikeV3(60, 65);
    await increaseLikeV3(65, 70);

    await DatabaseService().repairShiftedWeekIds(db, now: now);

    expectLayoutOf(await readAll(), generate(70));
  });

  test('skips tables whose weeks are not 7 days apart', () async {
    final weeks = generate(60);
    final shifted = weeks[10].copyWith(
      start: weeks[10].start.add(const Duration(days: 1)),
    );
    await insert([...weeks.take(10), shifted, ...weeks.skip(11)]);
    await db.delete(table, where: 'id = ?', whereArgs: [weeks.last.id]);
    final before = await readAll();

    await DatabaseService().repairShiftedWeekIds(db, now: now);

    expect(await readAll(), before);
  });

  test('does nothing on an empty table', () async {
    await DatabaseService().repairShiftedWeekIds(db, now: now);

    expect(await readAll(), isEmpty);
  });
}
