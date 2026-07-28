import 'dart:ui' show Locale, PlatformDispatcher;
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/domain/services/notification_service.dart';
import 'package:life_calendar/domain/services/reminder_settings_service.dart';

/// Outcome of toggling the weekly reminder, so the UI can react
/// (e.g. revert the switch and prompt the user to allow notifications).
enum ToggleReminderResult { enabled, disabled, permissionDenied, error }

class WeeklyNotificationInteractor {
  final NotificationService _notificationService;
  final ReminderSettingsService _settingsService;
  final Locale Function() _localeProvider;

  WeeklyNotificationInteractor(
    this._notificationService,
    this._settingsService, {
    Locale Function() localeProvider = _platformLocale,
  }) : _localeProvider = localeProvider;

  static Locale _platformLocale() => PlatformDispatcher.instance.locale;

  /// Initializes the notification plugin without requesting any permission.
  /// Permission is requested only when the user enables the reminder.
  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  Future<void> checkAndScheduleAtStartup() async {
    try {
      final isEnabled = await _settingsService.isWeeklyReminderEnabled();
      await _syncNotificationState(isEnabled: isEnabled);
    } catch (e, s) {
      logger.e(
        'Failed to check and schedule weekly notification',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<ToggleReminderResult> toggleNotification({
    required bool isEnabled,
  }) async {
    try {
      // Ask for permission in-context, only when the user turns it on.
      if (isEnabled) {
        final granted = await _notificationService.requestPermissions();
        if (!granted) {
          await _settingsService.setWeeklyReminderEnabled(isEnabled: false);
          return ToggleReminderResult.permissionDenied;
        }
      }

      await _settingsService.setWeeklyReminderEnabled(isEnabled: isEnabled);
      await _syncNotificationState(isEnabled: isEnabled);

      return isEnabled
          ? ToggleReminderResult.enabled
          : ToggleReminderResult.disabled;
    } catch (e, s) {
      logger.e(
        'Failed to set $isEnabled for weekly notification',
        error: e,
        stackTrace: s,
      );

      return ToggleReminderResult.error;
    }
  }

  Future<void> _syncNotificationState({required bool isEnabled}) async {
    if (!isEnabled) return _notificationService.cancelWeeklyReview();

    await _notificationService.scheduleWeeklyReview(_localeProvider());
  }
}
