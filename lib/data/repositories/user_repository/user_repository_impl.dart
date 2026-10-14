import 'package:life_calendar/core/exceptions/data_exceptions.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/core/uuid/app_uuid.dart';
import 'package:life_calendar/data/repositories/user_repository/user_repository.dart';
import 'package:life_calendar/data/services/database_service.dart';
import 'package:life_calendar/data/services/shared_preferences_service.dart';
import 'package:life_calendar/domain/models/user/user.dart';
import 'package:life_calendar/utils/calendar/calendar_generator.dart';
import 'package:life_calendar/utils/result.dart';

class UserRepositoryImpl implements UserRepository {
  final SharedPreferencesService _sharedPreferencesService;
  final DatabaseService _databaseService;

  const UserRepositoryImpl({
    required SharedPreferencesService sharedPreferencesService,
    required DatabaseService databaseService,
  }) : _sharedPreferencesService = sharedPreferencesService,
       _databaseService = databaseService;

  @override
  Future<Result<void>> createUser(User user) async {
    try {
      await _sharedPreferencesService.setBirthday(user.birthdate);
      await _sharedPreferencesService.setLifespan(user.lifeSpan);

      return const Result.ok(null);
    } catch (e, s) {
      logger.e('Failed to save user info in prefs', error: e, stackTrace: s);
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> getUser() async {
    try {
      final isFirstLaunch = await _sharedPreferencesService.isFirstLaunch();
      if (isFirstLaunch) {
        return Result.ok(User.empty());
      }

      String? userId = await _sharedPreferencesService.getUserId();
      final birthdate = await _sharedPreferencesService.getBirthday();
      int? lifeSpan = await _sharedPreferencesService.getLifespan();

      if (birthdate == null) {
        logger.e(
          'Failed to get from prefs UserID (null - ${userId == null}), '
          'or birthdate: (null - ${birthdate == null}), '
          'or lifeSpan(null - ${lifeSpan == null})',
        );
        return const Result.error(
          UserDataException('Stored user profile has no birthdate'),
        );
      }

      if (userId == null) {
        userId = AppUuid.generateTimeBasedUuid();
        await _sharedPreferencesService.setUserId(userId);
      }

      if (lifeSpan == null) {
        lifeSpan = (await _databaseService.getLastWeek()).yearId;
        await _sharedPreferencesService.setLifespan(lifeSpan);
      }

      return Result.ok(
        User(id: userId, birthdate: birthdate, lifeSpan: lifeSpan),
      );
    } catch (e, s) {
      logger.e('Failed to get user info from prefs', error: e, stackTrace: s);
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> increaseLifeSpan({
    required int oldLifeSpan,
    required int newLifeSpan,
  }) async {
    try {
      if (newLifeSpan < oldLifeSpan) {
        throw Exception('Invalid range, $newLifeSpan < $oldLifeSpan');
      }
      await _sharedPreferencesService.setLifespan(newLifeSpan);
      final lastWeek = await _databaseService.getLastWeek();
      final birthdate = await _sharedPreferencesService.getBirthday();

      if (birthdate == null) {
        throw Exception('Null birthdate');
      }

      final lifeSpanDiff = newLifeSpan - oldLifeSpan;
      final generator = CalendarGenerator(
        birthday: birthdate.copyWith(year: birthdate.year + oldLifeSpan + 1),
        lifeSpan: lifeSpanDiff - 1,
      );

      await _databaseService.insertWeeks(
        generator.generateWeeks(
          startWeekIndex: lastWeek.id + 1,
          startYearIndex: oldLifeSpan + 1,
        ),
      );

      return const Result.ok(null);
    } catch (e, s) {
      logger.e('Failed to change user lifespan', error: e, stackTrace: s);
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> reduceLifeSpan({
    required int oldLifeSpan,
    required int newLifeSpan,
  }) async {
    try {
      if (newLifeSpan > oldLifeSpan) {
        throw Exception('Invalid range, $newLifeSpan > $oldLifeSpan');
      }
      await _sharedPreferencesService.setLifespan(newLifeSpan);
      await _databaseService.removeWeeksByYearIds(
        startYearId: newLifeSpan + 1,
        endYearId: oldLifeSpan,
      );

      return const Result.ok(null);
    } catch (e, s) {
      logger.e('Failed to reduce life span', error: e, stackTrace: s);
      return Result.error(e);
    }
  }
}
