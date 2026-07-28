import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:life_calendar/core/l10n/app_localizations.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/data/services/notifications/local_notification_id_enum.dart';
import 'package:life_calendar/domain/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService implements NotificationService {
  // Main plugin instance
  final _plugin = FlutterLocalNotificationsPlugin();

  // Initialization logic
  @override
  Future<void> initialize() async {
    // 1. Initialize Timezones (needed for scheduled notifications).
    // Loading the DB is not enough: tz.local defaults to UTC until we point
    // it at the device's zone. Without this, zonedSchedule with
    // matchDateTimeComponents computes the wall-clock in UTC and can fire
    // immediately.
    tz.initializeTimeZones();
    await _configureLocalTimeZone();

    // 2. Android Initialization
    // 'notification_icon' must exist in android/app/src/main/res/drawable
    const androidSettings = AndroidInitializationSettings('notification_icon');

    // 3. iOS Initialization
    // We request permissions manually later, so requestAlert/Badge/Sound are false initially
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 4. Finalize initialization
    await _plugin.initialize(settings: initSettings);
  }

  /// Points `tz.local` at the device's real time zone so scheduled
  /// notifications fire at the intended wall-clock time.
  Future<void> _configureLocalTimeZone() async {
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e, s) {
      // Fall back to UTC rather than crashing; scheduling still works,
      // just without device-local wall-clock alignment.
      logger.e('Failed to resolve local time zone', error: e, stackTrace: s);
    }
  }

  /// Request permissions.
  /// Android 13+ requires manual request. iOS always requires it.
  /// Returns whether the permission was granted.
  @override
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      // For Android 13+ (API 33+)
      final granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// Show an instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel', // Channel ID
      'Main Channel', // Channel Name
      channelDescription: 'For generic notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Schedule a notification for a future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Makes it repeat (e.g. every week on this weekday at this time):
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  @override
  Future<void> scheduleWeeklyReview(Locale locale) async {
    final l10n = lookupAppLocalizations(locale);

    final scheduledDate = _nextSundayAt(hour: 20, minute: 0);

    const androidDetails = AndroidNotificationDetails(
      'weekly_review_channel',
      'Weekly Review',
      channelDescription: 'Reminders to review your week',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: LocalNotificationId.sumUpWeek.id,
      title: l10n.notificationWeeklyReviewTitle,
      body: l10n.notificationWeeklyReviewBody,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    logger.i('Set weekly notification for $scheduledDate');
  }

  /// Next occurrence of Sunday at [hour]:[minute] in the device's local zone,
  /// strictly in the future. Built in `tz.local` so the wall-clock the plugin
  /// matches against is the device's, not UTC.
  tz.TZDateTime _nextSundayAt({required int hour, required int minute}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != DateTime.sunday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  @override
  Future<void> cancelWeeklyReview() async {
    await _plugin.cancel(id: LocalNotificationId.sumUpWeek.id);
    logger.i('Canceled weekly notification');
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }
}
