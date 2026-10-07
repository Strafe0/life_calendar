import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository_impl.dart';
import 'package:life_calendar/data/services/database_service.dart';
import 'package:life_calendar/data/services/shared_preferences_service.dart';
import 'package:life_calendar/domain/models/week/week.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatabaseService extends Mock implements DatabaseService {}

class _MockSharedPreferencesService extends Mock
    implements SharedPreferencesService {}

void main() {
  final birthday = DateTime(1990, 1, 1);
  DateTime now() => DateTime(2026, 10, 7);

  late _MockDatabaseService databaseService;
  late _MockSharedPreferencesService prefs;
  late UserRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(<Week>[]));

  setUp(() {
    databaseService = _MockDatabaseService();
    prefs = _MockSharedPreferencesService();
    repository = UserRepositoryImpl(
      sharedPreferencesService: prefs,
      databaseService: databaseService,
    );

    when(() => prefs.setLifespan(any())).thenAnswer((_) async {});
    when(() => prefs.getBirthday()).thenAnswer((_) async => birthday);
    when(
      () => databaseService.insertWeeks(any()),
    ).thenAnswer((_) async => true);
  });

  List<Week> generate(int lifeSpan) => CalendarGenerator(
    birthday: birthday,
    lifeSpan: lifeSpan,
    time: now,
  ).generateWeeks();

  group('increaseLifeSpan', () {
    test('appends weeks right after the last week without overlap', () async {
      final existing = generate(60);
      when(
        () => databaseService.getLastWeek(),
      ).thenAnswer((_) async => existing.last);

      final result = await repository.increaseLifeSpan(
        oldLifeSpan: 60,
        newLifeSpan: 70,
      );

      expect(result, isA<Ok<void>>());
      final appended =
          verify(
                () => databaseService.insertWeeks(captureAny()),
              ).captured.single
              as List<Week>;

      final expected = generate(70).skip(existing.length).toList();
      expect(appended.map((w) => w.id), expected.map((w) => w.id));
      expect(appended.map((w) => w.yearId), expected.map((w) => w.yearId));
      expect(appended.map((w) => w.start), expected.map((w) => w.start));
      expect(appended.first.id, existing.last.id + 1);
    });

    test('rejects a smaller lifespan', () async {
      final result = await repository.increaseLifeSpan(
        oldLifeSpan: 70,
        newLifeSpan: 60,
      );

      expect(result, isA<ResultError<void>>());
      verifyNever(() => databaseService.insertWeeks(any()));
    });
  });
}
