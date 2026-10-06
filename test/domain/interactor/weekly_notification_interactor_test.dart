import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/domain/interactor/weekly_notification_interactor.dart';
import 'package:life_calendar/domain/services/notification_service.dart';
import 'package:life_calendar/domain/services/reminder_settings_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationService extends Mock implements NotificationService {}

class _MockReminderSettingsService extends Mock
    implements ReminderSettingsService {}

void main() {
  late _MockNotificationService notifications;
  late _MockReminderSettingsService settings;
  late WeeklyNotificationInteractor interactor;

  const locale = Locale('ru');

  setUpAll(() => registerFallbackValue(const Locale('en')));

  setUp(() {
    notifications = _MockNotificationService();
    settings = _MockReminderSettingsService();
    interactor = WeeklyNotificationInteractor(
      notifications,
      settings,
      localeProvider: () => locale,
    );

    when(() => notifications.initialize()).thenAnswer((_) async {});
    when(
      () => notifications.requestPermissions(),
    ).thenAnswer((_) async => true);
    when(
      () => notifications.scheduleWeeklyReview(any()),
    ).thenAnswer((_) async {});
    when(() => notifications.cancelWeeklyReview()).thenAnswer((_) async {});
    when(
      () =>
          settings.setWeeklyReminderEnabled(isEnabled: any(named: 'isEnabled')),
    ).thenAnswer((_) async {});
  });

  test('initialize only initializes the notification service', () async {
    await interactor.initialize();

    verify(() => notifications.initialize()).called(1);
    verifyNoMoreInteractions(notifications);
    verifyZeroInteractions(settings);
  });

  group('toggleNotification', () {
    test('enables and schedules when permission is granted', () async {
      final result = await interactor.toggleNotification(isEnabled: true);

      expect(result, ToggleReminderResult.enabled);
      verifyInOrder([
        () => notifications.requestPermissions(),
        () => settings.setWeeklyReminderEnabled(isEnabled: true),
        () => notifications.scheduleWeeklyReview(locale),
      ]);
    });

    test(
      'stores disabled and skips scheduling when permission is denied',
      () async {
        when(
          () => notifications.requestPermissions(),
        ).thenAnswer((_) async => false);

        final result = await interactor.toggleNotification(isEnabled: true);

        expect(result, ToggleReminderResult.permissionDenied);
        verify(
          () => settings.setWeeklyReminderEnabled(isEnabled: false),
        ).called(1);
        verifyNever(() => notifications.scheduleWeeklyReview(any()));
      },
    );

    test('disables and cancels without asking for permission', () async {
      final result = await interactor.toggleNotification(isEnabled: false);

      expect(result, ToggleReminderResult.disabled);
      verify(
        () => settings.setWeeklyReminderEnabled(isEnabled: false),
      ).called(1);
      verify(() => notifications.cancelWeeklyReview()).called(1);
      verifyNever(() => notifications.requestPermissions());
    });

    test('returns error when scheduling throws', () async {
      when(
        () => notifications.scheduleWeeklyReview(any()),
      ).thenThrow(Exception('failure'));

      final result = await interactor.toggleNotification(isEnabled: true);

      expect(result, ToggleReminderResult.error);
    });
  });

  group('checkAndScheduleAtStartup', () {
    test('schedules when the reminder is enabled', () async {
      when(
        () => settings.isWeeklyReminderEnabled(),
      ).thenAnswer((_) async => true);

      await interactor.checkAndScheduleAtStartup();

      verify(() => notifications.scheduleWeeklyReview(locale)).called(1);
      verifyNever(() => notifications.cancelWeeklyReview());
      verifyNever(() => notifications.requestPermissions());
    });

    test('cancels when the reminder is disabled', () async {
      when(
        () => settings.isWeeklyReminderEnabled(),
      ).thenAnswer((_) async => false);

      await interactor.checkAndScheduleAtStartup();

      verify(() => notifications.cancelWeeklyReview()).called(1);
      verifyNever(() => notifications.scheduleWeeklyReview(any()));
    });

    test('swallows errors', () async {
      when(
        () => settings.isWeeklyReminderEnabled(),
      ).thenThrow(Exception('failure'));

      await expectLater(interactor.checkAndScheduleAtStartup(), completes);
      verifyZeroInteractions(notifications);
    });
  });
}
