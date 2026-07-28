import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/domain/services/reminder_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService implements ReminderSettingsService {
  const SharedPreferencesService();

  static const _firstLaunchKey = 'firstTime';
  static const _firstLaunchV3Key = 'firstTimeV3';
  static const _birthdayKey = 'birthday';
  static const _lifespanKey = 'lifespan';
  static const _userIdKey = 'user_id';
  static const _weeklyReminderKey = 'is_weekly_reminder_enabled';

  /// Boundary (≈ year 5138 in seconds / 1973 in ms) separating legacy birthday
  /// timestamps stored in seconds from the current milliseconds format.
  static const _birthdayMillisThreshold = 100000000000;

  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isFirstLaunch = prefs.getBool(_firstLaunchKey);

      if (isFirstLaunch == null) {
        logger.d('isFirstLaunch from prefs is null');
        return true;
      }

      return isFirstLaunch;
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
      return true;
    }
  }

  Future<void> setFirstLaunch({required bool isFirstLaunch}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_firstLaunchKey, isFirstLaunch);
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
    }
  }

  Future<DateTime?> getBirthday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var birthday = prefs.getInt(_birthdayKey);

      if (birthday == null) {
        logger.d('Birthday from prefs is null');
        return null;
      }

      // One-time migration: legacy builds stored the birthday in seconds.
      // Detect such values, rewrite them as milliseconds, and from then on
      // the stored value is always above the threshold (i.e. milliseconds).
      if (birthday < _birthdayMillisThreshold) {
        birthday *= 1000;
        await prefs.setInt(_birthdayKey, birthday);
        logger.d('Migrated birthday from seconds to milliseconds');
      }

      return DateTime.fromMillisecondsSinceEpoch(birthday);
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> setBirthday(DateTime birthday) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_birthdayKey, birthday.millisecondsSinceEpoch);
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
    }
  }

  Future<int?> getLifespan() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lifespan = prefs.getInt(_lifespanKey);

      if (lifespan == null) {
        logger.d('Lifespan from prefs is null');
      }

      return lifespan;
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> setLifespan(int lifespan) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_lifespanKey, lifespan);
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getString(_userIdKey);

      if (userId == null) {
        logger.d('UserId from prefs is null');
      }

      return userId;
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_userIdKey, userId);
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
    }
  }

  Future<bool> isFirstLaunchV3() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isFirstLaunch = prefs.getBool(_firstLaunchV3Key);

      if (isFirstLaunch == null) {
        logger.d('isFirstLaunchV3 from prefs is null');
        return true;
      }

      return isFirstLaunch;
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
      return true;
    }
  }

  Future<void> setFirstLaunchV3({required bool isFirstLaunch}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_firstLaunchV3Key, isFirstLaunch);
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
    }
  }

  /// Whether the weekly reminder is enabled (defaults to false, so the app
  /// never requests notification permission until the user opts in).
  @override
  Future<bool> isWeeklyReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(_weeklyReminderKey) ?? false;
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<void> setWeeklyReminderEnabled({required bool isEnabled}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_weeklyReminderKey, isEnabled);
    } catch (e, s) {
      logger.e('SharedPrefs error', error: e, stackTrace: s);
    }
  }
}
