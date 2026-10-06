import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/data/repositories/settings_repository/settings_repository.dart';
import 'package:life_calendar/domain/interactor/weekly_notification_interactor.dart';
import 'package:life_calendar/ui/calendar/drawer/bloc/settings_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeeklyNotificationInteractor extends Mock
    implements WeeklyNotificationInteractor {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockWeeklyNotificationInteractor interactor;
  late _MockSettingsRepository settingsRepository;

  const enabled = SettingsState(isWeeklyReminderEnabled: true);
  const disabled = SettingsState(isWeeklyReminderEnabled: false);

  setUp(() {
    interactor = _MockWeeklyNotificationInteractor();
    settingsRepository = _MockSettingsRepository();
  });

  SettingsCubit build() => SettingsCubit(interactor, settingsRepository);

  void stubToggle(ToggleReminderResult result) => when(
    () => interactor.toggleNotification(isEnabled: any(named: 'isEnabled')),
  ).thenAnswer((_) async => result);

  test('initial state has the reminder disabled', () {
    expect(build().state, disabled);
  });

  blocTest<SettingsCubit, SettingsState>(
    'loadSettings emits the stored reminder flag',
    setUp: () => when(
      () => settingsRepository.isWeeklyReminderEnabled(),
    ).thenAnswer((_) async => true),
    build: build,
    act: (cubit) => cubit.loadSettings(),
    expect: () => [enabled],
  );

  group('toggleReminder', () {
    final cases = {
      (true, ToggleReminderResult.enabled): [enabled],
      (true, ToggleReminderResult.permissionDenied): [enabled, disabled],
      (true, ToggleReminderResult.error): [enabled, disabled],
      (false, ToggleReminderResult.disabled): [disabled],
      (false, ToggleReminderResult.error): [disabled, enabled],
    };

    for (final MapEntry(key: (value, result), value: states) in cases.entries) {
      ToggleReminderResult? returned;

      blocTest<SettingsCubit, SettingsState>(
        'toggling to $value with ${result.name} emits $states',
        setUp: () => stubToggle(result),
        build: build,
        seed: () => SettingsState(isWeeklyReminderEnabled: !value),
        act: (cubit) async => returned = await cubit.toggleReminder(value),
        expect: () => states,
        verify: (_) {
          expect(returned, result);
          verify(
            () => interactor.toggleNotification(isEnabled: value),
          ).called(1);
        },
      );
    }
  });
}
